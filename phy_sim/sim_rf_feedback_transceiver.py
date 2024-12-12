import builtins
import cocotb
from cocotb.triggers import ReadOnly, RisingEdge, FallingEdge, ClockCycles, ReadWrite
from cocotb.utils import get_sim_time
from cocotb.clock import Clock
from cocotb.runner import get_runner
import os
import glob
import sys
from pathlib import Path
import random
import numpy as np
from cocotb_bus.bus import Bus
from cocotb_bus.drivers import BusDriver
from cocotb_bus.monitors import Monitor
from cocotb_bus.scoreboard import Scoreboard
from cocotb_bus.monitors import BusMonitor
from cocotb import logging
import matplotlib.pyplot as plt
from cocotb.handle import SimHandleBase

C_S00_AXIS_TDATA_WIDTH = 32
C_M00_AXIS_TDATA_WIDTH = 32
LENGTH = 256 #10^12 - 1 = 4097
RATE = 4 #10^12 - 1 = 4097
DEBUG = 1
BYTE = 1 << 8
LOG_LEVEL = logging.WARNING
lg2 = logging.getLogger("cocotb2.tb")
lg2.setLevel(LOG_LEVEL)

def print(*args):
    if DEBUG:
        builtins.print(*args)
    else:
        pass


def plot_i_q_time_series(top, bot, length):
    plt.figure()
    plt.plot(bot[:length], label="I")
    plt.plot(top[:length], label="Q")  # according to my implementation
    plt.legend()
    plt.show()


class SplitSquareScoreboard(Scoreboard):
    def compare(self, got, exp, log, strict_type=False):
        # log.info(got)
        # log.info(exp)
        # {'data': got['data'], 'count': got['count']}, {'data': exp['data'], 'count': exp['count']}
        if got != exp:
            self.errors += 1
            log.warning(
                f"actual={got=} != {exp=}")
        super().compare(got, exp, log, strict_type)


class SSSTester:
    """
    Checker of a split square sum instance
    Args
      dut_entity: handle to an instance of split-square-sum
    """

    def __init__(self, dut_entity: SimHandleBase, debug=False):
        self.dut = dut_entity
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)
        self.input_mon = AXISMonitor(self.dut,'s00',self.dut.s00_axis_aclk, callback=self.model)
        self.output_mon = AXISMonitor(self.dut,'m00',self.dut.s00_axis_aclk)
        self.input_driver = AXISDriver(self.dut,'s00',self.dut.s00_axis_aclk)
        self._checker = None
        self.calcs_sent = 0
        # Create a scoreboard on the stream_out bus
        self.expected_output = [] #contains list of expected outputs (Growing)
        self.scoreboard = SplitSquareScoreboard(self.dut, fail_immediately=True)
        self.scoreboard.add_interface(self.output_mon, self.expected_output)
 
    def stop(self) -> None:
        """Stops everything"""
        if self._checker is None:
            raise RuntimeError("Monitor never started")
        self.input_mon.stop()
        self.output_mon.stop()
        self.input_driver.stop()

    def model(self, transaction):
        # passing transmitter output to receiver, identity function
        self.expected_output.append(transaction)


class AXISMonitor(BusMonitor):
    """
    monitors axi streaming bus
    """
    transactions = 0

    def __init__(self, dut, name, clk, callback=None):
        self._signals = ['axis_tvalid', 'axis_tready',
                         'axis_tlast', 'axis_tdata', 'axis_tstrb']
        BusMonitor.__init__(self, dut, name, clk, callback=callback)
        self.clock = clk
        self.transactions = 0
        self.values = []

    async def _monitor_recv(self):
        """
        Monitor receiver
        """
        # rising_edge = RisingEdge(
        #     self.clock)  # make these coroutines once and reuse
        rising_edge = RisingEdge(self.clock) # make these coroutines once and reuse
        falling_edge = FallingEdge(self.clock)
        read_only = ReadOnly()  # This is
        while True:
            await rising_edge
            await falling_edge
            await read_only  # readonly (the postline)
            valid = self.bus.axis_tvalid.value
            ready = self.bus.axis_tready.value
            last = self.bus.axis_tlast.value
            data = self.bus.axis_tdata.value
            self.log.info(f"{valid=}, {ready=}")
            if valid and ready:
                self.transactions += 1
                thing = dict(data=data, valid=valid, last=last, name=self.name,
                             count=self.transactions, time=cocotb.utils.get_sim_time('ns'))
                #self.values.append(data.integer)
                self.log.info(thing)
                self._recv(thing["data"])


class AXISDriver(BusDriver):
    def __init__(self, dut, name, clk):
        self._signals = ['axis_tvalid', 'axis_tready',
                         'axis_tlast', 'axis_tdata', 'axis_tstrb']
        BusDriver.__init__(self, dut, name, clk)
        self.clock = clk
        self.bus.axis_tdata.value = 0
        self.bus.axis_tstrb.value = 0
        self.bus.axis_tlast.value = 0
        self.bus.axis_tvalid.value = 0

    async def _valid_state(self):
        """ Wait until if tready is high"""
        repeat = True
        while repeat:
            await RisingEdge(self.clock)
            await ReadWrite()
            if (self.bus.axis_tready.value):
                repeat = False

            
    async def single_drive(self, data, strb, last):
        await self._valid_state()
        self.bus.axis_tvalid.value = 1
        self.bus.axis_tdata.value = data
        self.bus.axis_tstrb.value = strb
        self.bus.axis_tlast.value = last

    async def burst_drive(self, data):
        total_length = len(data)
        for idx, data_bit in enumerate(data):
            await self._valid_state()
            self.bus.axis_tvalid.value = 1
            self.bus.axis_tdata.value = int(data_bit)
            self.bus.axis_tstrb.value = 15
            self.bus.axis_tlast.value = 1 if idx == total_length - 1 else 0

    async def _driver_send(self, value, sync=True):
        """ process transactions to send to device under test."""
        if sync:
            await RisingEdge(self.clock)
        contents = value["contents"]
        data = contents["data"]
        if (value["type"] == "single"):
            last = contents["last"]
            strb = contents["strb"]
            await self.single_drive(data, strb, last)
        else:
            await self.burst_drive(data)
        # clean up valid and last signals
        await RisingEdge(self.clock)
        self.bus.axis_tvalid.value = 0
        self.bus.axis_tlast.value = 0
        
async def set_up_axi(dut):
    """ Update downstream device ready signal.
    params:
      clk: clk to time. 
      reset_signal: wire to reset. 
      active_high (optional): True, DUT is active high.
      wait_cycles (optional): 2, number of cycles to wait between reset.
    """
    dut.s00_axis_tvalid.value = 0
    dut.s00_axis_tlast.value = 0
    dut.s00_axis_tstrb.value = (dut.C_S00_AXIS_TDATA_WIDTH.value >> 1) - 1
    print((dut.C_S00_AXIS_TDATA_WIDTH.value >> 1) - 1)
    lg2.info(f"{dut.length=}")
    lg2.info(f"{dut.rate=}")

async def wireup_feeback(dut):
    while True:
        await FallingEdge(dut.s00_axis_aclk);
        dut.s01_axis_tdata.value = dut.m01_axis_tdata.value
        dut.s01_axis_tvalid.value = dut.m01_axis_tvalid.value
        dut.s01_axis_tlast.value = dut.m01_axis_tlast.value
        dut.m01_axis_tready.value = dut.s01_axis_tready.value
    
async def setup_test(dut):
    """cocotb test for demodulator"""
    tester = SSSTester(dut)
    cocotb.start_soon(Clock(dut.s00_axis_aclk, 10, units="ns").start())
    await set_up_axi(dut)
    await set_ready(dut, 1)
    cocotb.start_soon(wireup_feeback(dut));
    await reset(dut.s00_axis_aclk, dut.s00_axis_aresetn, 2, 0)
    # feed the driver:
    base_array = np.arange(BYTE)

    # Repeat this array 1024 times
    k = 2
    for _ in range(k):
        samples = np.random.randint(0, BYTE, size=LENGTH)
        samples = samples.astype(np.int32)
        data = {'type': 'burst', "contents": {"data": samples}}
        tester.input_driver.append(data)
        await RisingEdge(dut.m00_axis_tlast)
        await ClockCycles(dut.s00_axis_aclk, 1)
    assert tester.input_mon.transactions == tester.output_mon.transactions, f"Transaction Count doesn't match! :/"

async def reset(clk, reset_signal, wait_cycles=2, active_high=True):
    """ reset reset_signal for WAIT_CYCLES according to ACTIVE_HIGH.
    params:
      clk: clk to time. 
      reset_signal: wire to reset. 
      active_high (optional): True, DUT is active high.
      wait_cycles (optional): 2, number of cycles to wait between reset.
    """
    rst_value = 1 if active_high else 0
    negate = [1, 0]
    reset_signal.value = rst_value
    
    await ClockCycles(clk, wait_cycles)
    reset_signal.value = negate[rst_value]
 
async def set_ready(dut, value):
    """ Update downstream device ready signal.
    params:
      clk: clk to time. 
      reset_signal: wire to reset. 
      active_high (optional): True, DUT is active high.
      wait_cycles (optional): 2, number of cycles to wait between reset.
    """
    dut.m00_axis_tready.value = value


@cocotb.test()
async def test_transiever(dut):
    await setup_test(dut)


PHY_TYPE = "mkWiFiTest"
def transceiver_runner():
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    sim_path = Path(__file__).resolve().parent
    bluefi_path = Path(__file__).resolve().parent.parent
    
    hdl_path = bluefi_path / "phy_hdl"
    
    ofdm_build_path = bluefi_path / "ofdm" / "build" / PHY_TYPE / "src"
    bluespec_verilog_path = Path(os.environ.get('BLUESPECDIR', "/opt/tools/bsc/latest/lib")).resolve() / "Verilog"
    
    sys.path.append(str(sim_path))
    sources = []
    sources.extend(glob.glob(str(hdl_path / "*")))
    sources.extend(glob.glob(str(ofdm_build_path / "*")))
    sources.extend([f for f in glob.glob(str(bluespec_verilog_path / "*.v"))  if not "main.v" in f])
    build_test_args = ["-Wall"]  # ,"COCOTB_RESOLVE_X=ZEROS"]
    parameters = {"length": LENGTH, "rate": RATE} 
    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="rf_feedback_transceiver",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale=('1ns', '1ps'),
        #waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="rf_feedback_transceiver",
        test_module="sim_rf_feedback_transceiver",
        # testcase=["test_fir_filter"],
        test_args=run_test_args,
        #waves=True
    )


if __name__ == "__main__":
    transceiver_runner()
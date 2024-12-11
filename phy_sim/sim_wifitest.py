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


async def setup_test(dut, noise_mul):
    """cocotb test for demodulator"""
    cocotb.start_soon(Clock(dut.s00_axis_aclk, 10, units="ns").start())
    await set_up_axi(dut)
    await set_ready(dut, 1)
    await reset(dut.s00_axis_aclk, dut.s00_axis_aresetn, 2, 0)
    # feed the driver:

    fs = 100e6  # sampling frequency
    n = 1024  # number of samples
    T = n*1.0/fs  # total time
    fc = 10e6  # carrier frequency
    cps = 8  # cycles per symbol
    sps = fs/fc*cps  # samples per symbol
    t = np.linspace(0, T, n, endpoint=False)  # time vector in seconds
    ns = np.linspace(0, fs, n, endpoint=False)  # sample vector
    # phase ranges from 0 to 2pi over the duration
    phase_noise = np.arange(len(t))/len(t) * 6.28
    general_noise = np.random.randn(len(t))*noise_mul
    # general_noise = np.random.randn(len(t))*100
    samples = 500*np.cos(10e6*2*np.pi*t+phase_noise + 0) + general_noise
    samples = samples.astype(np.int32)
    data = {'type': 'burst', "contents": {"data": samples}}
    tester.input_driver.append(data)
    await RisingEdge(dut.m00_axis_tlast)
    await ClockCycles(dut.s00_axis_aclk, 1)
    tester.plot_result(n - 16) # the last 16 data points are no good and result during fir flushing
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
    #
    await ClockCycles(clk, wait_cycles)
    reset_signal.value = negate[rst_value]
  
async def setup_connections(dut):
    # setup connections for self stimulation
    dut.transmitter_txData_inData
    dut.reciever_in_put

@cocotb.test()
async def test_wifiTest(dut):
    cocotb.start_soon(Clock(dut.CLK, 10, units="ns").start())
    await reset(dut.CLK, dut.RST_N, 2, 0)
    await ClockCycles(dut.CLK, 50000)

PHY_TYPE = "mkWiFiTest"
def transciever_runner():
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    sim_path = Path(__file__).resolve().parent
    bluefi_path = Path(__file__).resolve().parent.parent
    #bluefi_path = Path(__file__).resolve().parent.parent.parent
    
    ofdm_build_path = bluefi_path / "ofdm" / "build" / PHY_TYPE / "src"
    bluespec_verilog_path = Path(os.environ.get('BLUESPECDIR', "/opt/tools/bsc/latest/lib")).resolve() / "Verilog"
    
    print(ofdm_build_path  / "*")
    sys.path.append(str(sim_path))
    sources = []
    sources.extend(glob.glob(str(ofdm_build_path / "*")))
    sources.extend([f for f in glob.glob(str(bluespec_verilog_path / "*.v"))  if not "main.v" in f])
    build_test_args = ["-Wall"]  # ,"COCOTB_RESOLVE_X=ZEROS"]
    parameters = {} 
    # parameters = {"C_S00_AXIS_TDATA_WIDTH": C_S00_AXIS_TDATA_WIDTH,
    #               "C_M00_AXIS_TDATA_WIDTH": C_M00_AXIS_TDATA_WIDTH}
   
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="mkWiFiTest",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale=('1ns', '1ps'),
        #waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="mkWiFiTest",
        test_module="sim_wifitest",
        # testcase=["test_fir_filter"],
        test_args=run_test_args,
        #waves=True
    )


if __name__ == "__main__":
    transciever_runner()
import Connectable::*;
import FIFO::*;
import GetPut::*;
import Vector::*;

import Controls::*;
import DataTypes::*;
import Interfaces::*;
import Parameters::*;
import Receiver::*;
import Transmitter::*;
import RXController::*;
import TXController::*;
import LibraryFunctions::*;

interface WiMAXTransmitter;
   method Action txStart(TXVector txVec);    // fromMAC 
   method Action txData(Bit#(8) inData);    // fromMAC
   method Action txEnd();                    // fromMAC
   interface Get#(DACMesg#(TXFPIPrec,TXFPFPrec)) out; // to DAC
endinterface
      
interface WiMAXReceiver;
   interface Put#(RXFeedback) inFeedback;
   interface Put#(SynchronizerMesg#(RXFPIPrec,RXFPFPrec)) in;
   interface Get#(Bit#(11)) outLength;
   interface Get#(Bit#(8))  outData;
endinterface

interface WiMAXTransceiver;
   interface WiMAXTransmitter transmitter;
   interface WiMAXReceiver    receiver;
endinterface      

(* synthesize *)
module mkWiMAXTransmitter(WiMAXTransmitter);
   // state element
   let tx_controller <- mkTXController;
   let transmitter <- mkTransmitterInstance;
   
   // make connection
   mkConnection(tx_controller.out,transmitter.in);
   
   // methods
   method Action txStart(TXVector txVec);
      tx_controller.txStart(txVec);
   endmethod
   
   method Action txData(Bit#(8) inData);
      tx_controller.txData(inData);
   endmethod
   
   method Action txEnd();
      tx_controller.txEnd;
   endmethod
   
   interface out = transmitter.out;
endmodule

(* synthesize *)
module mkWiMAXReceiver(WiMAXReceiver);
   // state elements
   let rx_controller <- mkRXController;
   let receiver_preFFT <- mkReceiverPreFFTInstance;
   let receiver_preDescrambler <- mkReceiverPreDescramblerInstance;
   let descrambler <- mkDescramblerInstance;
   
   // connections
   mkConnectionPrint("PreFFT -> RXCtrl0",receiver_preFFT.out,rx_controller.inFromPreFFT);
   mkConnectionPrint("RXCtrl0 -> PreDesc",rx_controller.outToPreDescrambler,receiver_preDescrambler.in);
   mkConnectionPrint("PreDesc -> RXCtrl1",receiver_preDescrambler.out,rx_controller.inFromPreDescrambler);
   mkConnectionPrint("RXCtrl1 -> Desc",rx_controller.outToDescrambler,descrambler.in);
   mkConnectionPrint("Desc -> RXCtrl2",descrambler.out,rx_controller.inFromDescrambler);
   
   // methods
   interface inFeedback = rx_controller.inFeedback;
   interface in = receiver_preFFT.in;
   interface outLength = rx_controller.outLength;
   interface outData = rx_controller.outData;
endmodule

(* synthesize *)
module mkTransceiver(WiMAXTransceiver);
   let wimaxTransmitter <- mkWiMAXTransmitter;
   let wimaxReceiver    <- mkWiMAXReceiver;
   
   interface transmitter = wimaxTransmitter;
   interface receiver    = wimaxReceiver;
      
endmodule



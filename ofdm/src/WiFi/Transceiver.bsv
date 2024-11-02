//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2007 Alfred Man Cheuk Ng, mcn02@mit.edu 
// 
// Permission is hereby granted, free of charge, to any person 
// obtaining a copy of this software and associated documentation 
// files (the "Software"), to deal in the Software without 
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------//

import Connectable::*;
import FIFO::*;
import GetPut::*;

import Controls::*;
import DataTypes::*;
import Interfaces::*;
import Parameters::*;
import Receiver::*;
import Transmitter::*;
import TXController::*;
import RXController::*;
import LibraryFunctions::*;

interface WiFiTransmitter;
   method Action txStart(TXVector txVec);    // fromMAC 
   method Action txData(Bit#(8) inData);    // fromMAC
   method Action txEnd();                    // fromMAC
   interface Get#(DACMesg#(TXFPIPrec,TXFPFPrec)) out; // to DAC
endinterface

interface WiFiReceiver;
   interface Put#(SynchronizerMesg#(RXFPIPrec,RXFPFPrec)) in;
   interface Get#(Bit#(12)) outLength;
   interface Get#(Bit#(8))  outData;
endinterface

interface WiFiTransceiver;
   interface WiFiTransmitter transmitter;
   interface WiFiReceiver receiver;
endinterface      

(* synthesize *)
module mkWiFiTransmitter(WiFiTransmitter);
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
module mkWiFiReceiver(WiFiReceiver);
   // state elements
   let rx_controller <- mkRXController;
   let receiver_preFFT <- mkReceiverPreFFTInstance;
   let receiver_preDescrambler <- mkReceiverPreDescramblerInstance;
   let descrambler <- mkDescramblerInstance;
   
   // connections
   mkConnectionPrint("PreFFT -> RXCtrl0",receiver_preFFT.out,rx_controller.inFromPreFFT);
   mkConnectionPrint("RXCtrl0 -> PreDes",rx_controller.outToPreDescrambler,receiver_preDescrambler.in);
   mkConnectionPrint("PreDes -> RXCtrl1",receiver_preDescrambler.out,rx_controller.inFromPreDescrambler);
   mkConnectionPrint("RXCtrl1 -> Desc",rx_controller.outToDescrambler,descrambler.in);
   mkConnectionPrint("Desc -> RXCtrl2",descrambler.out,rx_controller.inFromDescrambler);
//    mkConnection(receiver_preFFT.out,rx_controller.inFromPreFFT);
//    mkConnection(rx_controller.outToPreDescrambler,receiver_preDescrambler.in);
//    mkConnection(receiver_preDescrambler.out,rx_controller.inFromPreDescrambler);
//    mkConnection(rx_controller.outToDescrambler,descrambler.in);
//    mkConnection(descrambler.out,rx_controller.inFromDescrambler);
   
   // methods
   interface in = receiver_preFFT.in;
   interface outLength = rx_controller.outLength;
   interface outData = rx_controller.outData;
endmodule

(* synthesize *)
module mkTransceiver(WiFiTransceiver);
   let wifiTransmitter <- mkWiFiTransmitter;
   let wifiReceiver    <- mkWiFiReceiver;
   
   interface transmitter = wifiTransmitter;
   interface receiver    = wifiReceiver;
      
endmodule

      
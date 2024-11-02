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

import Controls::*;
import DataTypes::*;
import Interfaces::*;
import Parameters::*;
import Transceiver::*;
import RandomGen::*;
import LibraryFunctions::*;
import FPComplex::*;
import GetPut::*;
import TXController::*;
import RXController::*;

function Rate nextRate(Rate rate);
   return case (rate)
  	     R0: R1;
 	     R1: R2;
  	     R2: R3;
  	     R3: R4;
  	     R4: R5;
 	     R5: R6;
 	     R6: R0;
	  endcase;
endfunction

function CPSizeCtrl nextCPSize(CPSizeCtrl cpSize);
   return case (cpSize)
	     CP0: CP1;
	     CP1: CP2;
	     CP2: CP3;
	     CP3: CP0;
	  endcase;
endfunction

(* synthesize *)
module mkWiMAXTransmitterTest(Empty);
   
   // state elements
   let transmitter <- mkWiMAXTransmitter;
   Reg#(Bit#(32)) packetNo <- mkReg(0);
   Reg#(Bit#(8))  data <- mkReg(0);
   Reg#(Rate)     rate <- mkReg(R0);
   Reg#(CPSizeCtrl) cpSize <- mkReg(CP0);
//   Reg#(Bit#(11)) counter <- mkReg(0);
   Reg#(Bit#(32)) cycle <- mkReg(0);
   RandomGen#(64) randGen <- mkMersenneTwister(64'hB573AE980FF1134C);
   
   rule putTXStart(True);
      let randData <- randGen.genRand;
      let newRate = nextRate(rate);
      let newLength = randData[22:12];
      let newBSID = randData[11:8];
      let newUIUC = randData[7:4];
      let newFID  = randData[3:0];
      let txVec = TXVector{rate: newRate,
			   length: newLength,
			   bsid: newBSID,
			   uiuc: newUIUC,
			   fid:  newFID,
			   power: 0};
      rate <= newRate;
      packetNo <= packetNo + 1;
      transmitter.txStart(txVec);
      $display("Going to send a packet %d at rate:%d, length:%d,bsid:%d, uiuc:%d, fid:%d",packetNo,newRate,newLength,newBSID,newUIUC,newFID);
      if (packetNo == 51)
	$finish;
   endrule
   
   rule putData(True);
      data <= data + 1;
      transmitter.txData(data);
      $display("input: rate:%d, data:%h",rate,data);
   endrule
   
   rule getOutput(True);
      let mesg <- transmitter.out.get;
      $write("output: data:");
      fpcmplxWrite(4,mesg);
      $display("");
   endrule
   
   rule tick(True);
      cycle <= cycle + 1;
      if (cycle == 500000)
	 $finish;
      $display("Cycle: %d",cycle);
   endrule
endmodule

(* synthesize *)
module mkWiMAXTest (Empty);
   
   // state elements
   let transceiver <- mkTransceiver;
   let transmitter =  transceiver.transmitter;
   let receiver    =  transceiver.receiver;
   Reg#(Bit#(32)) packetNo <- mkReg(0);
   Reg#(Bit#(8))  data <- mkReg(0);
   Reg#(Rate)     rate <- mkReg(R0);
   Reg#(Bit#(32)) cycle <- mkReg(0);
   RandomGen#(64) randGen <- mkMersenneTwister(64'hB573AE980FF1134C);
   
   // rules
   rule putTXStart(True);
      let randData <- randGen.genRand;
      let newRate = nextRate(rate);
      Bit#(11) newLength = truncate(randData);
      let txVec = TXVector{rate: newRate,
			   length: newLength,
			   cpSize: CP0,
			   bsid: randData[3:0],
			   uiuc: randData[7:4],
			   fid: randData[11:8],
			   power: 0};
      rate <= newRate;
      packetNo <= packetNo + 1;
      transmitter.txStart(txVec);
      receiver.inFeedback.put(txVec);
      $display("Going to send a packet %d at rate:%d, length:%d",packetNo,newRate,newLength);
      if (packetNo == 51)
	$finish;
   endrule
   
   rule putData(True);
      data <= data + 1;
      transmitter.txData(data);
      $display("transmitter input: rate:%d, data:%h",rate,data);
   endrule
   
   rule getOutput(True);
      let mesg <- transmitter.out.get;
      receiver.in.put(mesg);
      $write("transmitter output: data:");
      fpcmplxWrite(4,mesg);
      $display("");
   endrule
   
   rule getLength(True);
      let length <- receiver.outLength.get;
      $display("Going to receiver a packet of length:%d",length);
   endrule
   
   rule getData(True);
      let outData <- receiver.outData.get;
      $display("receiver output: data:%h",outData);
   endrule
   
   rule tick(True);
      cycle <= cycle + 1;
      if (cycle == 100000)
	 $finish;
//      $display("Cycle: %d",cycle);
   endrule
endmodule

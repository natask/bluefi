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

import Complex::*;
import DataTypes::*;
import FIFO::*;
import FixedPoint::*;
import Interfaces::*;
import Vector::*;
import Controls::*;
import GetPut::*;

//`define debug_mode True // uncomment this line for displaying text

// internal state
typedef enum{ UN_Bypass, UN_Skip } UnserialState deriving (Bits,Eq);
	     
module mkUnserializer(Unserializer#(n,i_prec,f_prec))
   provisos (Log#(n,n_idx));
   
   // state elements
   FIFO#(UnserializerMesg#(i_prec,f_prec))  inQ <- mkLFIFO;
   FIFO#(SPMesgFromSync#(n,i_prec,f_prec)) outQ <- mkSizedFIFO(2);
   Reg#(SyncCtrl) ctrl <- mkRegU;
   Reg#(Symbol#(n,i_prec,f_prec)) tempDataVec <- mkReg(newVector);
   Reg#(Bit#(n_idx)) index <- mkReg(0);
   Reg#(UnserialState) state <- mkRegU;

   // constants/ wires
   Integer nInt = valueOf(n);
   Bit#(n_idx) bypassCheckSz = fromInteger(nInt - 1);
   Bit#(n_idx) skipCheckSz = case (ctrl.cpSize) 
				CP0: fromInteger(nInt/4 - 1);
				CP1: fromInteger(nInt/8 - 1);
				CP2: fromInteger(nInt/16 - 1);
				CP3: fromInteger(nInt/32 - 1);
			     endcase;
   let inMsg = inQ.first();
   let isNewMsg = inMsg.control.isNewPacket;
   let inData = inMsg.data;
   let isSkip = state == UN_Skip;
   let isBypass = state == UN_Bypass;

   rule getNewCtrl(isNewMsg);
   begin
      inQ.deq();
      index <= 1;
      state <= UN_Skip;
      ctrl <= inMsg.control;
      `ifdef debug_mode
         $display("Rule getNewCtrl fired");
      `endif
   end
   endrule

   rule skipMsg(!isNewMsg && isSkip);
   begin
      inQ.deq();
      if (index == 0)
	 ctrl <= inMsg.control;
      if (index == skipCheckSz)
	 begin
	    index <= 0;
	    state <= UN_Bypass;
	 end
      else
	 index <= index + 1;
      `ifdef debug_mode
         $display("Rule skipMsg fired %d times", index);
      `endif
   end
   endrule

   rule bypassMsg(!isNewMsg && isBypass);
   begin
      inQ.deq();
      if (index == bypassCheckSz)
	 begin
	    index <= 0;
	    state <= UN_Skip;
	    outQ.enq(SPMesgFromSync{control: ctrl.isNewPacket, data: Vector::update(tempDataVec,index,inData)});
	 end
      else
	 begin
	    index <= index + 1;
	    tempDataVec <= Vector::update(tempDataVec,index,inData);
	 end
      `ifdef debug_mode
	 $display("Rule bypassMsg fired %d times",index);
      `endif
   end
   endrule
   
   // interfaces
   interface in  = fifoToPut(inQ);
   interface out = fifoToGet(outQ);
endmodule





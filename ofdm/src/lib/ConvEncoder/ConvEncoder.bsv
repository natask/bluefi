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

import DataTypes::*;
import FIFO::*;
import GetPut::*;
import Interfaces::*;
import LibraryFunctions::*;
import Vector::*;

module mkConvEncoder#(Bit#(h_n) g1, Bit#(h_n) g2)
   (ConvEncoder#(ctrl_t,i_n,o_n))
   provisos (Add#(1,xxA,i_n),
	     Add#(1,h_n_m_1,h_n),
	     Mul#(i_n,2,o_n),
	     Bits#(ctrl_t,ctrl_sz));
   
   // state elements
   FIFO#(EncoderMesg#(ctrl_t,i_n)) inQ <- mkLFIFO;
   FIFO#(EncoderMesg#(ctrl_t,o_n)) outQ <- mkLFIFO;
   Reg#(Bit#(h_n)) histVal <- mkReg(0);
   
   // rules
   rule compute(True);
      let mesg = inQ.first;
      Vector#(i_n,Bit#(1)) inData = unpack(mesg.data);
      Vector#(h_n,Bit#(1)) fst = unpack(histVal);
      let histVec = map(pack,sscanl(shiftInAtN,fst,inData));
      let outVec1 = map(genXORFeedback(g1),histVec);
      let outVec2 = map(genXORFeedback(g2),histVec);
      let outData = pack(zip(outVec2,outVec1));
      inQ.deq;
      histVal <= last(histVec);
      outQ.enq(Mesg{ control: mesg.control,
		     data: outData});
   endrule
   
   //methods
   interface in = fifoToPut(inQ);
   interface out = fifoToGet(outQ);
endmodule

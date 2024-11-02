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

import StreamFIFO::*;
import Vector::*;

`define BufferSz 8
`define SSz      2
//`define SSz      TLog#(TAdd#(`BufferSz,1))
`define MaxSSz   fromInteger(valueOf(TExp#(`SSz))-1)
`define DataSz   32
`define CntSz    TMul#(`BufferSz,`DataSz)

(* synthesize *)
module mkStreamFIFOInstance(StreamFIFO#(`BufferSz,`SSz,Bit#(`DataSz)));
   StreamFIFO#(`BufferSz,`SSz,Bit#(`DataSz)) fifos <- mkStreamLFIFO;
   return fifos;
endmodule

(* synthesize *)
module mkStreamFIFOTest(Empty);
   // state elements
   let fifos <- mkStreamFIFOInstance;
   Reg#(Bit#(`CntSz))      counter <- mkReg(0);
   Reg#(Bit#(`SSz))           inSz <- mkReg(1);
   Reg#(Bit#(`SSz))          outSz <- mkReg(1);
   Reg#(Bit#(32))         clockCnt <- mkReg(0);
   
   // rules
   rule enqData(fifos.notFull(inSz));
      counter <= counter + 1;
      fifos.enq(inSz,unpack(counter));
      $display("enq %d elements: %x",inSz,counter);
   endrule

   rule deqData(fifos.notEmpty(outSz));
      let data = fifos.first;
      fifos.deq(outSz);
      $display("deq %d elements: %x",outSz,pack(data));
   endrule

   rule advClock(True);
      inSz <= (inSz == `MaxSSz) ? 1 : inSz + 1;
      outSz <= (outSz == 1) ? `MaxSSz : outSz - 1;
      clockCnt <= clockCnt + 1;
      $display("clock: %d",clockCnt);
   endrule
   
   rule finish(clockCnt == 3000);
      $finish;
   endrule
endmodule


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

import RegFile::*;

// FPGA BRAM interface 
interface BRAM#(type index_t, type data_t);
   method Action readRequest(index_t index);
   method Action writeRequest(index_t index, data_t data);
   method data_t readResponse();
endinterface

// make BRAM with regfile (for simulation)
module mkRegFileBRAM#(index_t lo_index, index_t hi_index)  
   (BRAM#(index_t,data_t))
   provisos (Bits#(index_t,size_index),
	     Bits#(data_t,data_sz));
   
   // state elements
   RegFile#(index_t,data_t) mem <- mkRegFile(lo_index,hi_index);
   Reg#(index_t) readIdx <- mkRegU;
   
   // methods
   method Action readRequest(index_t index);
      readIdx <= index;
   endmethod
   
   method Action writeRequest(index_t index, data_t data);
      mem.upd(index,data);
   endmethod
   
   method data_t readResponse();
      return mem.sub(readIdx);
   endmethod
endmodule

   

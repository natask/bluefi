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

import Vector::*;
//import Monad::*;

interface VRegFile#(numeric type sub_idx_sz,   // sub index
                    numeric type out_sz,       // index to the output vector
		    type value_T);             // storage type

  method Vector#(out_sz, value_T) sub(Bit#(1) cidx,
				      Bit#(sub_idx_sz) sidx);

  method Action upd(Bit#(1) cidx, 
                    Bit#(sub_idx_sz) sidx, 
                    Vector#(out_sz, value_T) v);

endinterface
  
// for correct usage, please make sure that 
// foward step + con_in_sz < log(out_sz)
module mkVRegFile#(function Vector#(out_sz, value_T) readSelect (Bit#(sub_idx_sz) sidx, 
								 Vector#(row_sz, value_T) inVec),
		   function Vector#(row_sz, value_T) writeSelect (Bit#(sub_idx_sz) sidx, 
								  Vector#(row_sz, value_T) inVec1,
								  Vector#(out_sz, value_T) inVec2),
		   value_T initVal)
  (VRegFile#(sub_idx_sz,
	     out_sz,
	     value_T))
  provisos (Bits#(value_T, value_sz),
	    Add#(sub_idx_sz,out_idx_sz,row_idx_sz),
	    Log#(out_sz,out_idx_sz),
	    Add#(0,row_sz,TExp#(row_idx_sz)),
	    Add#(1, xxA, TLog#(TExp#(row_idx_sz))));            

      // states
      Reg#(Vector#(2, Vector#(row_sz, value_T))) rf <- mkReg(replicate(replicate(initVal)));          

      method Vector#(out_sz, value_T) sub(Bit#(1) cidx, 
					  Bit#(sub_idx_sz) sidx);
	 return readSelect(sidx, rf[cidx]);   
      endmethod

      method Action upd(Bit#(1) cidx, 
			Bit#(sub_idx_sz) sidx, 
			Vector#(out_sz, value_T) v);
	 Vector#(2, Vector#(row_sz, value_T)) newRF = rf;
	 newRF[cidx] = writeSelect(sidx, rf[cidx], v);
	 rf <= newRF;
      endmethod
  
endmodule






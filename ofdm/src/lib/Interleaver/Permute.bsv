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
import Parameters::*;
import Controls::*;

function Vector#(sz, data_t) permute(function Integer getIdx(Integer k), Vector#(sz, data_t) inVec);
      Vector#(sz, data_t) outVec = newVector;
      for (Integer i = 0; i < valueOf(sz) ; i = i + 1)
	begin
	   Integer j = getIdx(i);
	   outVec[j] = inVec[i];
	end
      return outVec;
endfunction

(* noinline *)
function Vector#(192, Bit#(1)) permuteQAM64(Vector#(192,Bit#(1)) inVec);
      return permute(interleaverGetIndex(QAM_16), inVec);
endfunction // Vector
      
      
      
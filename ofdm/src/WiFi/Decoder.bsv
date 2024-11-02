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
import GetPut::*;
import Connectable::*;
import Viterbi::*;
import Depuncturer::*;

(* synthesize *)
module mkDepuncturerInstance
   (Depuncturer#(RXGlobalCtrl,DepuncturerInDataSz,
		 DepuncturerOutDataSz,DepuncturerInBufSz,
		 DepuncturerOutBufSz));
   function DepunctData#(DepuncturerF1OutSz) dpp1
      (DepunctData#(DepuncturerF1InSz) x);
      return parDepunctFunc(dp1,x);
   endfunction
   
   function DepunctData#(DepuncturerF2OutSz) dpp2
      (DepunctData#(DepuncturerF2InSz) x);
      return parDepunctFunc(dp2,x);
   endfunction
   
   function DepunctData#(DepuncturerF3OutSz) dpp3
      (DepunctData#(DepuncturerF3InSz) x);
      return parDepunctFunc(dp3,x);
   endfunction
   
   Depuncturer#(RXGlobalCtrl,DepuncturerInDataSz,
		DepuncturerOutDataSz,DepuncturerInBufSz,
		DepuncturerOutBufSz) depuncturer;
   depuncturer <- mkDepuncturer(puncturerMapCtrl,dpp1,dpp2,dpp3);
   return depuncturer;
endmodule

(* synthesize *)
module mkViterbiInstance(Viterbi#(RXGlobalCtrl,ViterbiInDataSz,
				  ViterbiOutDataSz));
   Viterbi#(RXGlobalCtrl,ViterbiInDataSz,ViterbiOutDataSz) viterbi;
   viterbi <- mkViterbi;
   return viterbi;
endmodule

module mkDecoder(Decoder#(RXGlobalCtrl,DecoderInDataSz,ViterbiMetric,
			  DecoderOutDataSz,Bit#(1)));
   // state elements
   let depuncturer <- mkDepuncturerInstance;
   let viterbi <- mkViterbiInstance;   
   
   // connections
   mkConnection(depuncturer.out,viterbi.in);
   
   // methods
   interface in = depuncturer.in;
   interface out = viterbi.out;
endmodule

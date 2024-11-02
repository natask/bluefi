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
import ConvEncoder::*;
import Puncturer::*;
import ReedEncoder::*;

(* synthesize *)
module mkConvEncoderInstance(ConvEncoder#(TXGlobalCtrl,ConvEncoderInDataSz,
					  ConvEncoderOutDataSz));
   ConvEncoder#(TXGlobalCtrl,ConvEncoderInDataSz,
		ConvEncoderOutDataSz) convEncoder;
   convEncoder <- mkConvEncoder(convEncoderG1,convEncoderG2);
   return convEncoder;
endmodule

(* synthesize *)
module mkPuncturerInstance(Puncturer#(TXGlobalCtrl,PuncturerInDataSz,PuncturerOutDataSz,
				      PuncturerInBufSz,PuncturerOutBufSz));
   Bit#(PuncturerF1Sz) f1_sz = 0;
   Bit#(PuncturerF2Sz) f2_sz = 0;
   Bit#(PuncturerF3Sz) f3_sz = 0;
   Puncturer#(TXGlobalCtrl,PuncturerInDataSz,PuncturerOutDataSz,
	      PuncturerInBufSz,PuncturerOutBufSz) puncturer;
   puncturer <- mkPuncturer(puncturerMapCtrl,
			    parFunc(f1_sz,puncturerF1),
			    parFunc(f2_sz,puncturerF2),
			    parFunc(f3_sz,puncturerF3));
   return puncturer;
endmodule

(* synthesize *)
module mkReedEncoderInstance(ReedEncoder#(TXGlobalCtrl,ReedEncoderDataSz,
					  ReedEncoderDataSz));
   ReedEncoder#(TXGlobalCtrl,ReedEncoderDataSz,
		ReedEncoderDataSz) reedEncoder;
   reedEncoder <- mkReedEncoder(reedEncoderMapCtrl);
   return reedEncoder;
endmodule

module mkEncoder(Encoder#(TXGlobalCtrl,EncoderInDataSz,
			  EncoderOutDataSz));   
   // state elements
   let reedEncoder <- mkReedEncoderInstance;
   let convEncoder <- mkConvEncoderInstance;
   let   puncturer <- mkPuncturerInstance;
   
   // connections
   mkConnection(reedEncoder.out,convEncoder.in);
   mkConnection(convEncoder.out,puncturer.in);
   
   // methods
   interface in = reedEncoder.in;
   interface out = puncturer.out;
endmodule





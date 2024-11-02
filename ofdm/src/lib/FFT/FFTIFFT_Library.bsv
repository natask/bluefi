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
import FPComplex::*;
import DataTypes::*;
import CORDIC::*;
import FixedPoint::*;
import Vector::*;
import FIFO::*;
import FIFOF::*;
import FParams::*;
import List::*;
import LibraryFunctions::*;
import Pipeline2::*;
import GetPut::*;

function FFTData genOmega(Integer idx);
      Nat shift_sz = fromInteger(valueOf(LogFFTSz));
      FFTAngle angle = negate(fromInteger(idx)>>shift_sz);
      FFTCosSinPair omg  = getCosSinPair(angle,16);
      FFTData res = cmplx(omg.cos,omg.sin);
      return res;
endfunction

function Vector#(HalfFFTSz,FFTData) genOmegas();
      return map(genOmega, genVector);
endfunction

function Vector#(sz,Bit#(n)) getIdxVec(Integer stage)
  provisos(Log#(sz,n));
      Integer logFFTSz = valueOf(n);
      Nat shiftSz = fromInteger(logFFTSz - stage);
      return map(leftShiftBy(shiftSz),      // shift back
		 map(rightShiftBy(shiftSz), // div
		     map(reverseBits, 
			 map(fromInteger, genVector))));      
endfunction // Vector

function Vector#(sz,FFTData) getIndVec(Vector#(sz,FFTData) inVec,
				       Integer stage);
      return map(select(inVec),getIdxVec(stage));
endfunction // Vector

(* noinline *)
function OmegaVecs genOmegaVecs();
      Vector#(LogFFTSz, Integer) iterVec = genVector;
      return map(getIndVec(genOmegas), iterVec);
endfunction

(* noinline *)
function FFTBFlyData fftRadix2Bfly(Tuple2#(FFTData,FFTBFlyData) 
				   inData);
      match {.omg, .dataVec} = inData;
      match {.i1, .i2} = dataVec;
      let newI2 = omg*i2;
      let o1 = i1 + newI2;
      let o2 = i1 - newI2;      
      return tuple2(o1,o2);
endfunction

(* noinline *)
function FFTBflyMesg fftBflys(FFTBflyMesg inMesg);
      let outData = map(fftRadix2Bfly, inMesg);
      Vector#(NoBfly,FFTData) dummyOmegas = newVector;
      return zip(dummyOmegas, outData);
endfunction      

(* synthesize *)
module mkFFTBflys_RWire(Pipeline2#(FFTBflyMesg));
   Pipeline2#(FFTBflyMesg) pipeStage <- mkPipeStage_RWire(fftBflys);
   return pipeStage;
endmodule   

(* synthesize *)
module mkFFTBflys_FIFO(Pipeline2#(FFTBflyMesg));
   Pipeline2#(FFTBflyMesg) pipeStage <- mkPipeStage_FIFO(fftBflys);
   return pipeStage;
endmodule   

(* noinline *)
function FFTTupleVec fftPermute(FFTDataVec inDataVec);
      Vector#(HalfFFTSz, FFTData) fstHalfVec = take(inDataVec);
      Vector#(HalfFFTSz, FFTData) sndHalfVec = takeTail(inDataVec);
      return zip(fstHalfVec,sndHalfVec);
endfunction // FFTDataVec

(* noinline *)
function FFTDataVec fftPermuteRes(FFTDataVec inDataVec);
      Integer logFFTSz = valueOf(LogFFTSz);      
      return getIndVec(inDataVec, logFFTSz);
endfunction // FFTDataVec

function Vector#(2,a) tuple2Vec(Tuple2#(a,a) in);
      Vector#(2,a) outVec = newVector;
      outVec[0] = tpl_1(in);
      outVec[1] = tpl_2(in);
      return outVec;
endfunction // Vector

(* synthesize *)
module [Module] mkOneStage(Pipeline2#(FFTTuples));

   Pipeline2#(FFTStageMesg) stageFU;
   stageFU <- mkPipeline2_Time(mkFFTBflys_RWire);
   FIFO#(FFTStage) stageQ <- mkLFIFO;

   interface Put in;
      method Action put(FFTTuples inMesg);
      begin
	 let inStage = tpl_1(inMesg);
	 let inDataVec = tpl_2(inMesg);
	 let dataVec = fftPermute(inDataVec);
	 let omgs = genOmegaVecs[inStage];
	 let inVec = zip(omgs,dataVec);
	 stageFU.in.put(inVec);
	 stageQ.enq(inStage + 1);
      end
      endmethod
   endinterface
   
   interface Get out;
      method ActionValue#(FFTTuples) get();
	 let res <- stageFU.out.get;
         stageQ.deq;
         return tuple2(stageQ.first, concat(map(tuple2Vec, tpl_2(unzip(res)))));
      endmethod
   endinterface     
endmodule // FFTDataVec

      





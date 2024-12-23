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

import Connectable::*;
import Complex::*;
import ComplexLibrary::*;
import FPComplex::*;
import DataTypes::*;
import CORDIC::*;
import FixedPoint::*;
import FixedPointLibrary::*;
import Vector::*;
import FIFO::*;
import FIFOF::*;
import FParams::*;
import FFTIFFT_Library::*;
import GetPut::*;
import LibraryFunctions::*;
import Pipeline2::*;
import Controls::*;
import Interfaces::*;

interface FFTIFFT;
	// input
	method Action putInput(Bool isIFFT, 
			       FFTDataVec fpcmplxVec);
	// output
	method ActionValue#(FFTDataVec) getOutput();
endinterface

module [Module] mkFFTIFFT(FFTIFFT);
   FFTStage noStages = fromInteger(valueOf(LogFFTSz)-1);
   
   // state elements
   Pipeline2#(FFTTuples) pipeline <- mkPipeline2_Circ(noStages,mkOneStage); 

   FIFO#(Bool) isIFFTQ <- mkSizedFIFO(valueOf(LogFFTSz));

   function FFTData shifting(FFTData inData);
   begin
      Nat shiftSz = fromInteger(valueOf(LogFFTSz));
      return cmplx(inData.rel>>shiftSz,inData.img>>shiftSz);
   end
   endfunction
   
   // methods
   method Action putInput(Bool isIFFT, FFTDataVec fpcmplxVec);
      if (isIFFT)
	fpcmplxVec = map(cmplxSwap, fpcmplxVec);
      isIFFTQ.enq(isIFFT);
      pipeline.in.put(tuple2(0, fpcmplxVec));
   endmethod

   method ActionValue#(FFTDataVec) getOutput();
      let mesg <- pipeline.out.get;
      let outVec = fftPermuteRes(tpl_2(mesg));
      let isIFFT = isIFFTQ.first;
      if (isIFFT)
	outVec = map(cmplxSwap, map(shifting, outVec));
      isIFFTQ.deq;
      return outVec;
   endmethod
endmodule   

module [Module] mkIFFT(IFFT#(ctrl_t,FFTSz,ISz,FSz))
   provisos (Bits#(ctrl_t,ctrl_sz));
   
   FFTIFFT ifft <- mkFFTIFFT;
   FIFO#(IFFTMesg#(ctrl_t,FFTSz,ISz,FSz)) inQ <- mkLFIFO;
   FIFO#(CPInsertMesg#(ctrl_t,FFTSz,ISz,FSz)) outQ <- mkSizedFIFO(2);
   FIFO#(ctrl_t) ctrlQ <- mkSizedFIFO(valueOf(LogFFTSz));
   
   // rule
   rule putInput(True);
      let mesg = inQ.first;
      let ctrl = mesg.control;
      let data = map(fpcmplxSignExtend,mesg.data);
      Vector#(HalfFFTSz,FFTData) fstHalfVec = take(data);
      Vector#(HalfFFTSz,FFTData) sndHalfVec = takeTail(data);
      data = append(sndHalfVec,fstHalfVec);
      inQ.deq;
      ifft.putInput(True,data);
      ctrlQ.enq(ctrl);
   endrule
   
   rule getOutput(True);
      let data <- ifft.getOutput;
      let oData = map(fpcmplxTruncate,data);
      let oCtrl = ctrlQ.first;
      ctrlQ.deq;
      outQ.enq(Mesg{control:oCtrl,data:oData});
   endrule
	       
   // methods
   interface in = fifoToPut(inQ);
   interface out = fifoToGet(outQ);
endmodule

module [Module] mkFFT(FFT#(ctrl_t,FFTSz,ISz,FSz))
   provisos (Bits#(ctrl_t,ctrl_sz));
   
   FFTIFFT fft <- mkFFTIFFT;
   FIFO#(FFTMesg#(ctrl_t,FFTSz,ISz,FSz)) inQ <- mkLFIFO;
   FIFO#(ChannelEstimatorMesg#(ctrl_t,FFTSz,ISz,FSz)) outQ; 
   outQ <- mkSizedFIFO(2);
   FIFO#(ctrl_t) ctrlQ <- mkSizedFIFO(valueOf(LogFFTSz));
   
   // rule
   rule putInput(True);
      let mesg = inQ.first;
      let ctrl = mesg.control;
      let data = map(fpcmplxSignExtend,mesg.data);
      inQ.deq;
      fft.putInput(False,data);
      ctrlQ.enq(ctrl);
   endrule
   
   rule getOutput(True);
      let data <- fft.getOutput;
      Vector#(HalfFFTSz,FFTData) fstHalfVec = take(data);
      Vector#(HalfFFTSz,FFTData) sndHalfVec = takeTail(data);
      data = append(sndHalfVec,fstHalfVec);
      let oData = map(fpcmplxTruncate,data);
      let oCtrl = ctrlQ.first;
      ctrlQ.deq;
      outQ.enq(Mesg{control:oCtrl,data:oData});
   endrule
	       
   // methods
   interface in = fifoToPut(inQ);
   interface out = fifoToGet(outQ);
endmodule



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
import Synchronizer::*;
import Unserializer::*;
import FFTIFFT::*;
import ChannelEstimator::*;
import Demapper::*;
import Interleaver::*;
import Decoder::*;
import Descrambler::*;
import Connectable::*;
import GetPut::*;
import LibraryFunctions::*;

(* synthesize *)
module mkSynchronizerInstance
   (Synchronizer#(SyncIntPrec,SyncFractPrec));
   Synchronizer#(SyncIntPrec,SyncFractPrec) block <- mkSynchronizer;
   return block;
endmodule

(* synthesize *)
module mkUnserializerInstance
   (Unserializer#(UnserialOutDataSz,RXFPIPrec,RXFPFPrec));
   Unserializer#(UnserialOutDataSz,RXFPIPrec,RXFPFPrec) block <- mkUnserializer;
   return block;
endmodule

(* synthesize *)
module mkReceiverPreFFTInstance
   (ReceiverPreFFT#(UnserialOutDataSz,RXFPIPrec,RXFPFPrec));
   
   // state elements
   let synchronizer <- mkSynchronizerInstance;
   let unserializer <- mkUnserializerInstance;
   
   // connections
   mkConnectionPrint("Sync -> Unse",synchronizer.out,unserializer.in);
//     mkConnection(synchroinzer.out,unserializer.in);
   
   // methods
   interface in = synchronizer.in;
   interface out = unserializer.out;
endmodule		     

(* synthesize *)
module [Module] mkFFTInstance
   (FFT#(RXGlobalCtrl,FFTIFFTSz,RXFPIPrec,RXFPFPrec));
   FFT#(RXGlobalCtrl,FFTIFFTSz,RXFPIPrec,RXFPFPrec) block <- mkFFT;
   return block;
endmodule

(* synthesize *)
module mkChannelEstimatorInstance
   (ChannelEstimator#(RXGlobalCtrl,CEstInDataSz,
		      CEstOutDataSz,RXFPIPrec,RXFPFPrec));
   ChannelEstimator#(RXGlobalCtrl,CEstInDataSz,
		     CEstOutDataSz,RXFPIPrec,RXFPFPrec) block;
   block <- mkChannelEstimator(pilotRemover);
   return block;
endmodule

(* synthesize *)
module mkDemapperInstance
   (Demapper#(RXGlobalCtrl,DemapperInDataSz,DemapperOutDataSz,
	      RXFPIPrec,RXFPFPrec,ViterbiMetric));
   Demapper#(RXGlobalCtrl,DemapperInDataSz,DemapperOutDataSz,
	     RXFPIPrec,RXFPFPrec,ViterbiMetric) block;
   block <- mkDemapper(modulationMapCtrl,demapperNegateOutput);
   return block;
endmodule

(* synthesize *)
module mkDeinterleaverInstance
   (Deinterleaver#(RXGlobalCtrl,DeinterleaverDataSz,
		   DeinterleaverDataSz,ViterbiMetric,MinNcbps));
   Deinterleaver#(RXGlobalCtrl,DeinterleaverDataSz,
		  DeinterleaverDataSz, ViterbiMetric,MinNcbps) block;
   block <- mkDeinterleaver(modulationMapCtrl,deinterleaverGetIndex);
   return block;
endmodule

(* synthesize *)
module mkDecoderInstance
   (Decoder#(RXGlobalCtrl,DecoderInDataSz,ViterbiMetric,
	     DecoderOutDataSz,Bit#(1)));
   Decoder#(RXGlobalCtrl,DecoderInDataSz,ViterbiMetric,
	    DecoderOutDataSz,Bit#(1)) block;
   block <- mkDecoder;
   return block;
endmodule
    
(* synthesize *)
module mkReceiverPreDescramblerInstance
   (ReceiverPreDescrambler#(RXGlobalCtrl,FFTIFFTSz,RXFPIPrec,
			    RXFPFPrec,DecoderOutDataSz,Bit#(1)));
    // state elements
    let fft <- mkFFTInstance;
    let channelEstimator <- mkChannelEstimatorInstance;
    let demapper <- mkDemapperInstance;
    let deinterleaver <- mkDeinterleaverInstance;
    let decoder <- mkDecoderInstance;
    
    // connections
    mkConnectionPrint("FFT  -> CEst",fft.out,channelEstimator.in);
    mkConnectionPrint("CEst -> Dmap",channelEstimator.out,demapper.in);
    mkConnectionPrint("Dmap -> Dint",demapper.out,deinterleaver.in);
    mkConnectionPrint("Dint -> Deco",deinterleaver.out,decoder.in);
    //     mkConnection(synchroinzer.out,unserializer.in);
    
    // methods
    interface in = fft.in;
    interface out = decoder.out;
endmodule

(* synthesize *)
module mkDescramblerInstance
   (Descrambler#(RXDescramblerAndGlobalCtrl,
		 DescramblerDataSz,DescramblerDataSz));
   Descrambler#(RXDescramblerAndGlobalCtrl,
		DescramblerDataSz,DescramblerDataSz) block;
   block <- mkDescrambler(descramblerMapCtrl,
			  descramblerGenPoly);
   return block;
endmodule

// (* synthesize *)
// module mkDescramblerInstance
//    (Descrambler#(RXDescramblerAndGlobalCtrl,
// 		 DescramblerDataSz,DescramblerDataSz));
//    Descrambler#(RXDescramblerAndGlobalCtrl,
// 		DescramblerDataSz,DescramblerDataSz) block;
//    block <- mkScrambler(descramblerMapCtrl,
// 			descramblerConvertCtrl,
// 			descramblerGenPoly);
//    return block;
// endmodule



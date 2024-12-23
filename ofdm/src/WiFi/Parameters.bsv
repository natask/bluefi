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

// WiFi 802.11a Parameters
import Controls::*;
import Vector::*;
import FPComplex::*;
import LibraryFunctions::*;
import Complex::*;
import DataTypes::*;
import Interfaces::*;
import GetPut::*;
import Connectable::*;

// Global Parameters:
typedef enum {
   R0,  // 6Mbps
   R1,  // 9Mbps
   R2,  // 12Mbps
   R3,  // 18Mbps
   R4,  // 24Mbps
   R5,  // 36Mbps
   R6,  // 48Mbps
   R7   // 54Mbps
} Rate deriving(Eq, Bits);

typedef struct {
    Bool firstSymbol;
    Rate rate;
} TXGlobalCtrl deriving(Eq, Bits);


typedef 2  TXFPIPrec; // tx fixedpoint integer precision
typedef 14 TXFPFPrec; // tx fixedpoint fractional precision

typedef 2  RXFPIPrec; // rx fixedpoint integer precision
typedef 14 RXFPFPrec; // rx fixedpoint fractional precision
typedef TXGlobalCtrl RXGlobalCtrl; // same as tx

// Local Parameters:

// Scrambler:
typedef 12 ScramblerDataSz;    
typedef  7 ScramblerShifterSz;
Bit#(ScramblerShifterSz) scramblerGenPoly = 'b1001000;
typedef ScramblerCtrl#(ScramblerDataSz,ScramblerShifterSz) 
	TXScramblerCtrl;

typedef struct {
   TXScramblerCtrl  scramblerCtrl;
   TXGlobalCtrl     globalCtrl;
} TXScramblerAndGlobalCtrl deriving(Eq, Bits); 

function TXScramblerCtrl 
   scramblerMapCtrl(TXScramblerAndGlobalCtrl ctrl);
   return ctrl.scramblerCtrl;
endfunction

function TXGlobalCtrl 
   scramblerConvertCtrl(TXScramblerAndGlobalCtrl ctrl);
    return ctrl.globalCtrl;
endfunction

// Conv. Encoder:
typedef 12 ConvEncoderInDataSz;
typedef TMul#(2,ConvEncoderInDataSz) ConvEncoderOutDataSz;
typedef  7 ConvEncoderHistSz;
Bit#(ConvEncoderHistSz) convEncoderG1 = 'b1011011;
Bit#(ConvEncoderHistSz) convEncoderG2 = 'b1111001;

// Puncturer:
typedef ConvEncoderOutDataSz        PuncturerInDataSz;
typedef 24                          PuncturerOutDataSz;
//typedef TMul#(2,PuncturerInDataSz)  PuncturerInBufSz;  // to be safe 2x inDataSz
//typedef TMul#(2,PuncturerOutDataSz) PuncturerOutBufSz; // to be safe 2x outDataSz 
typedef TAdd#(PuncturerInDataSz,10)                PuncturerInBufSz;
typedef TAdd#(PuncturerInBufSz,PuncturerOutDataSz) PuncturerOutBufSz; 
//typedef TDiv#(PuncturerInDataSz,4)  PuncturerF1Sz; // no. of 2/3 in parallel
//typedef TDiv#(PuncturerInDataSz,6)  PuncturerF2Sz; // no. of 3/4 in parallel
//typedef TDiv#(PuncturerInDataSz,10) PuncturerF3Sz; // no. of 5/6 in parallel
typedef 1  PuncturerF1Sz; // no. of 2/3 in parallel
typedef 1  PuncturerF2Sz; // no. of 3/4 in parallel
typedef 1  PuncturerF3Sz; // no. of 5/6 in parallel

function Bit#(3) puncturerF1 (Bit#(4) x);
   return x[2:0];
endfunction // Bit
   
function Bit#(4) puncturerF2 (Bit#(6) x);
   return {x[5],x[2:0]};
endfunction // Bit

// not used in WiFi   
function Bit#(6) puncturerF3 (Bit#(10) x);
   return 0;
endfunction // Bit

function PuncturerCtrl puncturerMapCtrl(TXGlobalCtrl ctrl);
   return case (ctrl.rate)
	     R0: Half;
	     R1: ThreeFourth;
	     R2: Half;
	     R3: ThreeFourth;
	     R4: Half;
	     R5: ThreeFourth;
	     R6: TwoThird;
	     R7: ThreeFourth;
	  endcase; // case(rate)
endfunction // Bit  

// Encoder: (Construct from ConvEncoder & Puncturer for wifi)
typedef ConvEncoderInDataSz EncoderInDataSz;
typedef PuncturerOutDataSz  EncoderOutDataSz;

// Interleaver:
typedef PuncturerOutDataSz  InterleaverDataSz;
typedef 48                  MinNcbps;

// used for both interleaver, mapper
function Modulation modulationMapCtrl(TXGlobalCtrl ctrl);
   return case (ctrl.rate)
	     R0: BPSK;
	     R1: BPSK;
	     R2: QPSK;
	     R3: QPSK;
	     R4: QAM_16;
	     R5: QAM_16;
	     R6: QAM_64;
	     R7: QAM_64;
          endcase;
endfunction

function Integer interleaverGetIdx(Modulation m, Integer k);
   Integer s = 1;  
   Integer ncbps = valueOf(MinNcbps);
   case (m)
      BPSK:   
      begin
	 ncbps = ncbps;
	 s = 1;
      end
      QPSK:   
      begin
	 ncbps = 2*ncbps;
	 s = 1;
      end
      QAM_16: 
      begin
	 ncbps = 4*ncbps;
	 s = 2;
      end
      QAM_64: 
      begin
	 ncbps = 6*ncbps;
	 s = 3;
      end
   endcase // case(m)
   Integer i = (ncbps/16) * (k%16) + k/16;
   Integer f = (i/s); // expect floor
   Integer j = s*f + (i + ncbps - (16*i/ncbps))%s;
   return (k >= ncbps) ? k : j;
endfunction

//Mapper:
typedef InterleaverDataSz MapperInDataSz;
typedef 48                MapperOutDataSz;
Bool mapperNegateInput = False;

//Pilot:
typedef  MapperOutDataSz  PilotInDataSz;
typedef  64               PilotOutDataSz;
typedef   7               PilotPRBSSz;
Bit#(PilotPRBSSz) pilotPRBSMask = 'b1001000;
Bit#(PilotPRBSSz) pilotInitSeq  = 'b1111111;

function PilotInsertCtrl pilotMapCtrl(TXGlobalCtrl ctrl);
   return ctrl.firstSymbol ? PilotRst : PilotNorm;
endfunction 

function Symbol#(PilotOutDataSz,TXFPIPrec,TXFPFPrec) 
   pilotAdder(Symbol#(PilotInDataSz,TXFPIPrec,TXFPFPrec) x,
	      Bit#(1) ppv);
   
   Integer i =0, j = 0;
   // assume all guards initially
   Symbol#(PilotOutDataSz,TXFPIPrec,TXFPFPrec) syms = replicate(cmplx(0,0));
   
   // data subcarriers
   for(i = 6; i < 11; i = i + 1, j = j + 1)
      syms[i] = x[j];
   for(i = 12; i < 25; i = i + 1, j = j + 1)
      syms[i] = x[j]; 
   for(i = 26; i < 32 ; i = i + 1, j = j + 1)
      syms[i] = x[j];  
   for(i = 33; i < 39 ; i = i + 1, j = j + 1)
      syms[i] = x[j];   
   for(i = 40; i < 53 ; i = i + 1, j = j + 1)
      syms[i] = x[j];
   for(i = 54; i < 59 ; i = i + 1, j = j + 1)
      syms[i] = x[j];

   //pilot subcarriers
   syms[11] = mapBPSK(False, ppv); // map 1 to -1, 0 to 1
   syms[25] = mapBPSK(False, ppv); // map 1 to -1, 0 to 1
   syms[39] = mapBPSK(False, ppv); // map 1 to -1, 0 to 1
   syms[53] = mapBPSK(True,  ppv); // map 0 to -1, 1 to 1
   
   return syms;
endfunction

// FFT/IFFT:
typedef PilotOutDataSz FFTIFFTSz;
typedef 32             FFTIFFTNoBfly;

// CPInsert:
typedef FFTIFFTSz CPInsertDataSz;

function CPInsertCtrl cpInsertMapCtrl(TXGlobalCtrl ctrl);
   let fstEle = ctrl.firstSymbol ? SendBoth : SendNone;
   return tuple2(fstEle, CP0);
endfunction

// Synchronizer:
// specific for OFDM specification
typedef 16  SSLen;        // short symbol length (auto correlation delay 16)
typedef 64  LSLen;        // long symbol length (auto correlation delay 64)
typedef 160 LSStart;      // when the long symbol start
typedef 320 SignalStart;  // when the signal (useful data) start
typedef 80  SymbolLen;    // one symbol length
// implementation parameters
typedef 96  SSyncPos;      // short symbol synchronization position ( 2*SSLen <= this value < LBStart)
typedef 224 LSyncPos;      // long symbol synchronization position  ( LSStart <= this value < SinglaStart)       
typedef 16  FreqMeanLen;   // how many samples we collect to calculate CFO (power of 2, at most 32, bigger == more tolerant to noise)
typedef 480 TimeResetPos;  // reset time if coarCounter is larger than this, must be bigger than SignalStart
typedef 2   CORDICPipe;    // number of pipeline stage of the cordic
typedef 16  CORDICIter;    // number of cordic iterations (max 16 iterations, must be multiple of CORDICPIPE)
typedef RXFPIPrec  SyncIntPrec;   // number of integer bits for internal arithmetic
typedef RXFPFPrec  SyncFractPrec; // number of fractional bits for internal arithmetic 

// Unserializer:
typedef FFTIFFTSz  UnserialOutDataSz;

// ChannelEstimator:
typedef UnserialOutDataSz  CEstInDataSz;
typedef PilotInDataSz      CEstOutDataSz;

function Symbol#(CEstOutDataSz,RXFPIPrec,RXFPFPrec) pilotRemover
   (Symbol#(CEstInDataSz,RXFPIPrec,RXFPFPrec) x);   
   Integer i =0, j = 0;
   // assume all guards initially
   Symbol#(CEstOutDataSz,RXFPIPrec,RXFPFPrec) syms = newVector;
  
   // data subcarriers
   for(i = 6; i < 11; i = i + 1, j = j + 1)
      syms[j] = x[i];
   for(i = 12; i < 25; i = i + 1, j = j + 1)
      syms[j] = x[i]; 
   for(i = 26; i < 32 ; i = i + 1, j = j + 1)
      syms[j] = x[i];  
   for(i = 33; i < 39 ; i = i + 1, j = j + 1)
      syms[j] = x[i];   
   for(i = 40; i < 53 ; i = i + 1, j = j + 1)
      syms[j] = x[i];
   for(i = 54; i < 59 ; i = i + 1, j = j + 1)
      syms[j] = x[i];  
   return syms;
endfunction

// Demapper:
typedef CEstOutDataSz  DemapperInDataSz;
typedef MapperInDataSz DemapperOutDataSz;

Bool demapperNegateOutput = mapperNegateInput;

// Deinterleaver:
typedef DemapperOutDataSz DeinterleaverDataSz;

function Integer deinterleaverGetIndex(Modulation m, Integer j);
   Integer s = 1;  
   Integer ncbps = valueOf(MinNcbps);
   case (m)
      BPSK:  
      begin
	 ncbps = ncbps;
	 s = 1;
      end
      QPSK:  
      begin
	 ncbps = 2*ncbps;
	 s = 1;
      end
      QAM_16:
      begin
	 ncbps = 4*ncbps;
	 s = 2;
      end
      QAM_64:
      begin
	 ncbps = 6*ncbps;
	 s = 3;
      end
   endcase // case(m)
   Integer f = (j/s);
   Integer i = s*f + (j + (16*j/ncbps))%s;
   Integer k = 16*i-(ncbps-1)*(16*i/ncbps);
   return (j >= ncbps) ? j : k;
endfunction			  

// Depuncturer:
typedef DemapperOutDataSz              DepuncturerInDataSz;
typedef PuncturerInDataSz              DepuncturerOutDataSz;
typedef TMul#(2,DepuncturerInDataSz)   DepuncturerInBufSz;  // to be safe 2x inDataSz
typedef TMul#(2,DepuncturerOutDataSz)  DepuncturerOutBufSz; // to be safe 2x outDataSz 
// typedef TDiv#(DepuncturerOutDataSz,4)  DepuncturerF1Sz;     // no. of 2/3 in parallel
// typedef TMul#(DepuncturerF1Sz,3)       DepuncturerF1InSz;   
// typedef TMul#(DepuncturerF1Sz,4)       DepuncturerF1OutSz;
// typedef TDiv#(DepuncturerOutBufSz,6)   DepuncturerF2Sz;     // no. of 3/4 in parallel
// typedef TMul#(DepuncturerF2Sz,4)       DepuncturerF2InSz;   
// typedef TMul#(DepuncturerF2Sz,6)       DepuncturerF2OutSz;
// typedef TDiv#(DepuncturerOutDataSz,10) DepuncturerF3Sz;     // no. of 5/6 in parallel
// typedef TMul#(DepuncturerF3Sz,6)       DepuncturerF3InSz;   
// typedef TMul#(DepuncturerF3Sz,10)      DepuncturerF3OutSz;
typedef 1  DepuncturerF1Sz;     // no. of 2/3 in parallel
typedef 3  DepuncturerF1InSz;   
typedef 4  DepuncturerF1OutSz;
typedef 1  DepuncturerF2Sz;     // no. of 3/4 in parallel
typedef 4  DepuncturerF2InSz;   
typedef 6  DepuncturerF2OutSz;
typedef 1  DepuncturerF3Sz;     // no. of 5/6 in parallel
typedef 6  DepuncturerF3InSz;   
typedef 10 DepuncturerF3OutSz;


function DepunctData#(4) dp1 (DepunctData#(3) x);
   DepunctData#(4) outVec = replicate(4);
   outVec[0] = x[0];
   outVec[1] = x[1];
   outVec[2] = x[2];
   return outVec;
endfunction // Bit
   
function DepunctData#(6) dp2 (DepunctData#(4) x);
   DepunctData#(6) outVec = replicate(4);
   outVec[0] = x[0];
   outVec[1] = x[1];
   outVec[2] = x[2];
   outVec[5] = x[3];
   return outVec;
endfunction // Bit

// not used in wifi   
function DepunctData#(10) dp3 (DepunctData#(6) x);
   DepunctData#(10) outVec = replicate(4);
   return outVec;
endfunction // Bit

// Viterbi:
typedef ConvEncoderOutDataSz ViterbiInDataSz;
typedef ConvEncoderInDataSz  ViterbiOutDataSz;
typedef ConvEncoderHistSz    KSz;       // no of input bits
typedef 35                   TBLength;  // the minimum TB length for each output
typedef 5                    NoOfDecodes;    // no of traceback per stage, TBLength dividible by this value
typedef 3                    MetricSz;  // input metric
typedef 1                    FwdSteps;  // forward step per cycle
typedef 4                    FwdRadii;  // 2^(FwdRadii+FwdSteps*ConvInSz) <= 2^(KSz-1)
typedef 1                    ConvInSz;  // conv input size
typedef 2                    ConvOutSz; // conv output size

// Decoder: (Construct from Depuncturer and Viterbifor wifi)
typedef DepuncturerInDataSz DecoderInDataSz;
typedef ViterbiOutDataSz    DecoderOutDataSz;

// Descrambler:
typedef ScramblerDataSz    DescramblerDataSz;    
typedef ScramblerShifterSz DescramblerShifterSz;
Bit#(DescramblerShifterSz) descramblerGenPoly = scramblerGenPoly;
typedef TXScramblerCtrl    RXDescramblerCtrl;

typedef struct {
   RXDescramblerCtrl  descramblerCtrl;
   Bit#(12)           length;               
   RXGlobalCtrl       globalCtrl;
} RXDescramblerAndGlobalCtrl deriving(Eq, Bits); 

function RXDescramblerCtrl 
   descramblerMapCtrl(RXDescramblerAndGlobalCtrl ctrl);
   return ctrl.descramblerCtrl;
endfunction

// typedef struct {
//    RXDescramblerCtrl  descramblerCtrl;
//    RXGlobalCtrl       globalCtrl;
// } RXDescramblerAndGlobalCtrl deriving(Eq, Bits); 

// function RXDescramblerCtrl 
//    descramblerMapCtrl(RXDescramblerAndGlobalCtrl ctrl);
//    return ctrl.descramblerCtrl;
// endfunction

// function Bit#(0) 
//    descramblerConvertCtrl(RXDescramblerAndGlobalCtrl ctrl);
//     return ?;
// endfunction


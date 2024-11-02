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
import CORDIC::*;
import DataTypes::*;
import FixedPoint::*;
import FPComplex::*;
import Vector::*;
import Parameters::*;

// from parameters file
typedef FFTIFFTSz      FFTSz;
typedef TXFPIPrec        ISz;
typedef TXFPFPrec        FSz;
typedef FFTIFFTNoBfly NoBfly;

// derived parameters
typedef TLog#(FFTSz)                                   LogFFTSz;
typedef TAdd#(LogFFTSz,1)                              LogFFTSzP1;
typedef TDiv#(FFTSz,2)                                 HalfFFTSz;
typedef TLog#(HalfFFTSz)                               LogHalfFFTSz;
typedef TAdd#(LogFFTSzP1,ISz)                          FFTISz;
typedef FixedPoint#(FFTISz, FSz)                       FFTAngle;
typedef FixedPoint#(1,FSz)                             CORDICAngle;
typedef CosSinPair#(FFTISz, FSz)                       FFTCosSinPair;
typedef FPComplex#(FFTISz, FSz)                        FFTData;
typedef Vector#(FFTSz,FPComplex#(ISz,FSz))             FPComplexVec;
typedef Vector#(FFTSz,FFTData)	                       FFTDataVec;
typedef Vector#(LogFFTSz,Vector#(HalfFFTSz,FFTData))   OmegaVecs;
typedef Tuple2#(FFTData,FFTData)                       FFTBFlyData;
typedef Bit#(TLog#(LogFFTSz))                          FFTStage;
typedef Vector#(HalfFFTSz, FFTBFlyData)                FFTTupleVec;
typedef Vector#(NoBfly, Tuple2#(FFTData,FFTBFlyData))  FFTBflyMesg;
typedef Tuple2#(FFTStage, FFTDataVec)                  FFTTuples;
typedef Vector#(HalfFFTSz, Tuple2#(FFTData,FFTBFlyData)) FFTStageMesg;







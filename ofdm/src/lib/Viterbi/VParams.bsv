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

import Parameters::*;
import Vector::*;

//  ////////////////////////////////////////
//  // Viterbi parameters
//  ////////////////////////////////////////

//  typedef 7  KSz;       // no of input bits 

//  //typedef 35 ViterbiTracebackLength;
//  typedef 35 TBLength;  // the minimum TB length for each output
//  typedef 5  NoOfDecodes;    // no of traceback per stage, TBLength dividible by this value

//  typedef 3  MetricSz;  // input metric

//  typedef 1  FwdSteps;  // forward step per cycle

//  typedef 4  FwdRadii;  // 2^(FwdRadii+FwdSteps*ConvInSz) <= 2^(KSz-1)

//  typedef 1  ConvInSz;  // conv input size

//  typedef 2  ConvOutSz; // conv output size

//  Bit#(KSz) convEncoderG1 = 'b1111001;
//  Bit#(KSz) convEncoderG2 = 'b1011011;

////////////////////////////////////////
// Begin of type definitions
////////////////////////////////////////

typedef TSub#(KSz,ConvInSz) VStateSz;
typedef Bit#(VStateSz) VState;
typedef TMul#(FwdSteps, ConvInSz) VStateSuffixSz;
typedef Bit#(VStateSuffixSz) VTBEntry;
typedef TSub#(VStateSz, VStateSuffixSz) VStatePrefixSz;
typedef TExp#(VStateSz) VTotalStates;
typedef TLog#(VStateSz) VStateIdxSz;

// VMaxMetric = ConvOutSz * FwdSteps* (2^Metricsz - 1)
// VMaxMetricSum = VMaxMetric * (KSz) // too large, but OK
// VMetricSum = Bit#(log2 (VMaxMetricSum+1))
// VMetric = Bit#(MetricSz)
typedef TMul#(ConvOutSz,TMul#(FwdSteps,TSub#(TExp#(MetricSz), 1))) VMaxMetric;
typedef TMul#(VMaxMetric, KSz) VMaxMetricSum; // max diff between two states
typedef Bit#(TAdd#(TLog#(TAdd#(VMaxMetricSum,1)),1)) VMetricSum; //add one more bit using murali method 
typedef Bit#(MetricSz) VMetric;
typedef TExp#(VStateSuffixSz)          FwdEntrySz;      // butterfly size
typedef TAdd#(FwdRadii,VStateSuffixSz) VRegsOutIdxSz;   
typedef TExp#(VRegsOutIdxSz)           VRegsOutSz;      // elements processed per cycle
typedef TSub#(VStateSz,VRegsOutIdxSz)  VRegsSubIdxSz;  
typedef Bit#(VRegsOutIdxSz)            VRegsOut;
typedef Bit#(VRegsSubIdxSz)            VRegsSubIdx;

// TBStages = Ceiling((TBLength + VStateSuffixSz - 1)/VStateSuffixSz) = floor((TBLength + 2 * VStateSuffixSz - 2)/VStateSuffixSz)
// VTrellisSz = TBStages * VStateSuffixSz
typedef TDiv#(TAdd#(TBLength, TMul#(2, TSub#(VStateSuffixSz, 1))), VStateSuffixSz) NoOfTBStage; // no of tbstages
typedef TLog#(NoOfTBStage) TBStageIdxSz;
typedef Bit#(TBStageIdxSz) TBStageIdx;  
typedef TMul#(NoOfTBStage, VStateSuffixSz) VTrellisSz;
typedef Bit#(VTrellisSz) VTrellisEntry;
typedef TLog#(VTrellisSz) VTrellisIdxSz;
typedef Bit#(VTrellisIdxSz) VTrellisIdx;

typedef Vector#(FwdSteps, Vector#(ConvOutSz, VMetric)) VInType;
typedef Vector#(FwdSteps, Bit#(ConvInSz)) VOutType;

// for the butterfly
typedef TExp#(ConvInSz) RadixSz;
typedef Tuple3#(VState, VMetricSum, tEntry_T) PrimEntry#(type tEntry_T); 
typedef Vector#(RadixSz, PrimEntry#(tEntry_T)) RadixEntry#(type tEntry_T);
typedef Vector#(FwdEntrySz, PrimEntry#(tEntry_T)) FwdEntry#(type tEntry_T);
typedef Vector#(VRegsOutSz, PrimEntry#(tEntry_T)) VRegsOutEntry#(type tEntry_T);
typedef Vector#(TMul#(VTotalStates,RadixSz), Vector#(ConvOutSz, VMetric)) MetricLUT; // also equal to TExp#(KSz)









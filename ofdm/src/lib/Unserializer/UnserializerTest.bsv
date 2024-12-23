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

import DataTypes::*;
import Interfaces::*;
import Synchronizer::*;
import FixedPoint::*;
import Complex::*;
import Preambles::*;
import SynchronizerLibrary::*;
import Vector::*;
import RegFile::*;
import FPComplex::*;
import GetPut::*;
import Controls::*;
import Unserializer::*;

(* synthesize *)
module mkUnserializerTest(Empty);

   // states
   Synchronizer#(2,14) synchronizer <- mkSynchronizer;
   Unserializer#(64,2,14) unserializer <- mkUnserializer;
   Reg#(Bit#(10)) inCounter <- mkReg(0);
   Reg#(Bit#(10)) outCounter <- mkReg(0);
   RegFile#(Bit#(10), FPComplex#(2,14)) tweakedPacket <- mkTweakedPacket();
   Reg#(Bit#(32)) cycle <- mkReg(0);

   rule toSynchronizer(True);
      FPComplex#(2,14) inCmplx = tweakedPacket.sub(inCounter);
      inCounter <= inCounter + 1;
      synchronizer.in.put(inCmplx);
      $write("Execute toSync at %d:",inCounter);
      cmplxWrite("("," + "," i)",fxptWrite(7),inCmplx);
      $display("");
   endrule

   rule fromSynchronizerToUnserializer(True);
      let result <- synchronizer.out.get;
      let resultCmplx = result.data;
      outCounter <= outCounter + 1;
      unserializer.in.put(result);
      $write("Execute fromSyncToUnserializer at %d:", outCounter);
      $write("new message: %d, ", result.control.isNewPacket);
      $write("cpSize: %b, ", result.control.cpSize);
      cmplxWrite("("," + ","i)",fxptWrite(7),resultCmplx);
      $display("");
   endrule
   
   rule fromUnserializer(True);
      let result <- unserializer.out.get;
      $write("new message: %d, ", result.control);
      $write("data: %h",result.data);
      $display("");
   endrule
   
   // tick
   rule tick(True);
      cycle <= cycle + 1;
      if (cycle == 100000)
	 $finish();
      $display("cycle: %d",cycle);
   endrule
     
endmodule   




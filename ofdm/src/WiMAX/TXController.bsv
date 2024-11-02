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
import FIFO::*;
import GetPut::*;
import Vector::*;

import Controls::*;
import DataTypes::*;
import Interfaces::*;
import LibraryFunctions::*;
import Parameters::*;
import StreamFIFO::*;

typedef struct{
   Bit#(11)   length;  // data to send MAC PDU
   Rate       rate;    // data rate (determine by BS before)
   CPSizeCtrl cpSize;  // cp size in term of symbol size
   Bit#(4)    bsid;    // base station id it subscribe to
   Bit#(4)    uiuc;    // uplink profile
   Bit#(4)    fid;     // frame number 
   Bit#(3)    power;   // transmit power level (not affecting baseband)
} TXVector deriving (Eq, Bits);

typedef enum{ SendData, SendPadding }
        TXState deriving (Eq, Bits);

interface TXController;
   method Action txStart(TXVector txVec);
   method Action txData(Bit#(8) inData);
   method Action txEnd();
   interface Get#(ScramblerMesg#(TXScramblerAndGlobalCtrl,
				 ScramblerDataSz)) out;
endinterface
      
// construct scramblerSeed
function Bit#(ScramblerShifterSz) makeSeed(TXVector txVec);
   return reverseBits({txVec.bsid,2'b11,txVec.uiuc,1'b1,txVec.fid});
endfunction   

// decr txVector length
function TXVector decrTXVectorLength(TXVector txVec);
   return TXVector{length: txVec.length - 1,
		   rate: txVec.rate,
		   cpSize: txVec.cpSize,
		   bsid: txVec.bsid,
		   uiuc: txVec.uiuc,
		   fid: txVec.fid,
		   power: txVec.power};
endfunction


//get maximum number of padding (basic unit is 8 bits) required for each rate
function Bit#(7) maxPadding(Rate rate);
   return case (rate)
	     R0: 12;
 	     R1: 24;
 	     R2: 36; 
 	     R3: 48;
 	     R4: 72;
 	     R5: 96;
 	     R6: 108;
 	  endcase;
endfunction      

// // construct scrambler mesg// get maximum number of padding (basic unit is byte) required for each rate
// function Bit#(7) maxPadding(Rate rate);
//    Bit#(7) scramblerDataSz = fromInteger(valueOf(ScramblerDataSz)/8);
//    return case (rate)
// 	     R0: 12 - scramblerDataSz;
// 	     R1: 24 - scramblerDataSz;
// 	     R2: 36 - scramblerDataSz; 
// 	     R3: 48 - scramblerDataSz;
// 	     R4: 72 - scramblerDataSz;
// 	     R5: 96 - scramblerDataSz;
// 	     R6: 108 - scramblerDataSz;
// 	  endcase;
// endfunction      

function ScramblerMesg#(TXScramblerAndGlobalCtrl,ScramblerDataSz)
   makeMesg(Bit#(ScramblerDataSz) bypass,
	    Maybe#(Bit#(ScramblerShifterSz)) seed,
	    Bool firstSymbol,
	    Rate rate,
	    CPSizeCtrl cpSize,
	    Bit#(ScramblerDataSz) data);
   let sCtrl = TXScramblerCtrl{bypass: bypass,
			       seed: seed};
   let gCtrl = TXGlobalCtrl{firstSymbol: firstSymbol,
			    rate: rate,
			    cpSize: cpSize};
   let ctrl = TXScramblerAndGlobalCtrl{scramblerCtrl: sCtrl,
				       globalCtrl: gCtrl};
   let mesg = Mesg{control:ctrl, data:data};
   return mesg;
endfunction

(* synthesize *)
module mkTXController(TXController);
   
   //state elements
   Reg#(Bool)                 busy <- mkReg(False);
   Reg#(TXState)           txState <- mkRegU;
   Reg#(Bit#(7))             count <- mkRegU;
   Reg#(Bit#(7))       fstSymCount <- mkRegU;
   Reg#(Bool)               fstSym <- mkRegU;
   Reg#(Bool)              rstSeed <- mkRegU;
   Reg#(TXVector)         txVector <- mkRegU;
   StreamFIFO#(32,6,Bit#(1)) sfifo <- mkStreamLFIFO; // buf at most 32
   FIFO#(ScramblerMesg#(TXScramblerAndGlobalCtrl,ScramblerDataSz)) outQ;
   outQ <- mkSizedFIFO(2);
   
   // constants
   let sfifo_usage = sfifo.usage;
   let sfifo_free = sfifo.free;
   Bit#(6) scramblerDataSz = fromInteger(valueOf(ScramblerDataSz));
   
   // rules
   rule sendData(busy && sfifo_usage >= scramblerDataSz);
      let bypass = 0;
      let seedVal = makeSeed(txVector);
      let seed = rstSeed ? tagged Valid seedVal : tagged Invalid;
      let fstSym = (fstSymCount > 0) ? True : False;
      let rate = txVector.rate;
      let cpSz = txVector.cpSize;
      Bit#(ScramblerDataSz) data = pack(take(sfifo.first));
      let mesg = makeMesg(bypass,seed,fstSym,rate,cpSz,data);
      rstSeed <= False;
      outQ.enq(mesg);
      sfifo.deq(scramblerDataSz);
      if (fstSymCount > 0)
	 fstSymCount <= fstSymCount - fromInteger(valueOf(ScramblerDataSz)/8);
      $display("sendData");
   endrule
   
   rule enqPadding(busy && txState == SendPadding && sfifo_free >= 8);
      if (count == 0)
	 begin
	    if (sfifo_usage == 0)
	       begin
		  busy <= False;
		  $display("returnIdle");
	       end
	 end
      else
	 begin
	    let data = 8'hFF;
	    sfifo.enq(8,append(unpack(data),replicate(0)));
	    count <= count - 1;
	    $display("enqPadding"); 
	 end
   endrule
   
   // methods
   method Action txStart(TXVector txVec) if (!busy);
      txVector <= txVec;
      busy <= True;
      txState <= SendData;
      count <= 0;
      rstSeed <= True;
      fstSym <= True;
      fstSymCount <= maxPadding(txVec.rate);
      $display("txStart");
   endmethod
   
   method Action txData(Bit#(8) inData) 
      if (busy && txState == SendData && txVector.length > 0 && sfifo_free >= 8);
      let newTXVec = decrTXVectorLength(txVector);
      sfifo.enq(8,append(unpack(inData),replicate(0)));
      txVector <= newTXVec;
      if (newTXVec.length == 0)
	 begin
	    txState <= SendPadding;
	    if (count == 0)
	       count <= maxPadding(txVector.rate); // need a tail
	 end
      else
	 count <= (count == 0) ? maxPadding(txVector.rate)-1 : count - 1;
      $display("txData");
   endmethod
   
   method Action txEnd();
      busy <= False;
   endmethod
	    
   interface out = fifoToGet(outQ);   
endmodule   







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
import Controls::*;
import FIFO::*;
import GetPut::*;

module mkChannelEstimator#(function Symbol#(out_n,i_prec,f_prec) pilotRemover(Symbol#(in_n,i_prec, f_prec) in))
   (ChannelEstimator#(ctrl_t,in_n,out_n,i_prec,f_prec))
    provisos (Bits#(ctrl_t, ctrl_sz));

    FIFO#(ChannelEstimatorMesg#(ctrl_t,in_n,i_prec,f_prec)) inQ <- mkLFIFO;
    FIFO#(DemapperMesg#(ctrl_t,out_n,i_prec,f_prec))       outQ <- mkSizedFIFO(2);

    rule process(True);
        inQ.deq();
        let mesg = inQ.first();
        let processedData = pilotRemover(mesg.data);
        outQ.enq(Mesg{control: mesg.control, data: processedData});
    endrule

    interface in  = fifoToPut(inQ);
    interface out = fifoToGet(outQ);
endmodule

%----------------------------------------------------------------------%
% The MIT License 
% 
% Copyright (c) 2007 Alfred Man Cheuk Ng, mcn02@mit.edu 
% 
% Permission is hereby granted, free of charge, to any person 
% obtaining a copy of this software and associated documentation 
% files (the "Software"), to deal in the Software without 
% restriction, including without limitation the rights to use,
% copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the
% Software is furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be
% included in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
% HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
% WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
% OTHER DEALINGS IN THE SOFTWARE.
%----------------------------------------------------------------------%

pAll = [ 0; -1-1j; 1+1j; -1+1j; -1+1j; -1-1j; 1+1j; 1+1j; 1+1j; -1-1j; 1+1j; 1-1j; 1-1j; 1-1j; -1+1j; -1+1j; 
	 -1+1j; -1+1j; 1-1j; -1-1j; -1-1j; -1+1j; 1-1j; 1+1j; 1+1j; -1+1j; 1-1j; 1-1j; 1-1j; -1+1j; 1-1j; -1-1j; -1-1j; -1-1j; 1+1j;
	 1+1j; 1+1j; 1+1j; -1-1j; -1+1j; -1+1j; 1+1j; -1-1j; 1-1j; 1-1j; 1+1j; -1-1j; -1-1j; -1-1j; 1+1j; -1-1j; -1+1j; -1+1j; 
	 -1+1j; 1-1j; 1-1j; 1-1j; 1-1j; -1+1j; 1+1j; 1+1j; -1-1j; 1+1j; -1+1j; -1+1j; -1-1j; 1+1j; 1+1j; 1+1j; -1-1j; 1+1j; 1-1j; 
	 1-1j; 1-1j; -1+1j; -1+1j; -1+1j; -1+1j; 1-1j; -1-1j; -1-1j; 1-1j; -1+1j; -1-1j; -1-1j; 1-1j; -1+1j; -1+1j; -1+1j; 1-1j; -1+1j;
	 1+1j; 1+1j; 1+1j; -1-1j; -1-1j; -1-1j; -1-1j; 1+1j; 1-1j; 1-1j;
         0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0;
	 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0;
	 1-1j; 1-1j; -1-1j; 1+1j; 1-1j; 1-1j; -1+1j; 1-1j; 1-1j; 1-1j; 1+1j; -1-1j; 1+1j; 1+1j; -1-1j; 1+1j; -1-1j; -1-1j; 1-1j; 
	 -1+1j; 1-1j; 1-1j; -1-1j; 1+1j; 1-1j; 1-1j; -1+1j; 1-1j; 1-1j; 1-1j; 1+1j; -1-1j; 1+1j; 1+1j; -1-1j; 1+1j; -1-1j; -1-1j; 1-1j; 
	 -1+1j; 1-1j; 1-1j; -1-1j; 1+1j; 1-1j; 1-1j; -1+1j; 1-1j; 1-1j; 1-1j; 1+1j; -1-1j; 1+1j; 1+1j; -1-1j; 1+1j; -1-1j; -1-1j; 1-1j; 
	 -1+1j; 1+1j; 1+1j; 1-1j; -1+1j; 1+1j; 1+1j; -1-1j; 1+1j; 1+1j; 1+1j; -1+1j; 1-1j; -1+1j; -1+1j; 1-1j; -1+1j; 1-1j; 1-1j;
	 1+1j; -1-1j; -1-1j; -1-1j; -1+1j; 1-1j; -1-1j; -1-1j; 1+1j; -1-1j; -1-1j; -1-1j; 1-1j; -1+1j; 1-1j; 1-1j; -1+1j; 1-1j; -1+1j;
	 -1+1j; -1-1j; 1+1j];
pAllSz = size(pAll);
for row = 1:pAllSz(1)
     if (mod(row-1,4) == 0)
        pShort(row) = pAll(row);
     else 
        pShort(row) = 0;
     end
end
pShort = 2*conj(pShort);
pShort = ifft(pShort);
pShortRel = real(pShort);
pShortImg = imag(pShort);
fid = fopen('WiMAXPreambles.txt', 'wt');
fprintf(fid,'Short Preambles:\n');
for row = 1:pAllSz(1)
     fprintf(fid,'%6.5f, %6.5f\n',pShortRel(row),pShortImg(row));
end
for row = 1:pAllSz(1)
     if (mod(row-1,2) == 0)
        pLong(row) = pAll(row);
     else 
        pLong(row) = 0;
     end
end
pLong = sqrt(2)*conj(pLong);
pLong = ifft(pLong);
pLongRel = real(pLong);
pLongImg = imag(pLong);
fprintf(fid,'Long Preambles:\n');
for row = 1:pAllSz(1)
     fprintf(fid,'%6.5f, %6.5f\n',pLongRel(row),pLongImg(row));
end
fclose(fid);



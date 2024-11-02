#----------------------------------------------------------------------#
# The MIT License 
# 
# Copyright (c) 2007 Alfred Man Cheuk Ng, mcn02@mit.edu 
# 
# Permission is hereby granted, free of charge, to any person 
# obtaining a copy of this software and associated documentation 
# files (the "Software"), to deal in the Software without 
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#----------------------------------------------------------------------#

#!/usr/local/bin/perl
use POSIX; # for ceil

my @shortPreambles;
my @longPreambles;
my @longPreSigns;
my @sPreamble_real;
my @sPreamble_imag;
my @lPreamble_real;
my @lPreamble_imag;
my @packet_real; #create a sample packet (no noise)
my @packet_imag;
my @noisePacket_real; # packet with noise and rotation added
my @noisePacket_imag;
my $state = 0;

# constants for channel_model
use constant AWGN_VARIANCE => 0.003; # noise variance
use constant AVERAGE_POWER => 0.333;
use constant PI => 4 * atan2(1,1); 
use constant CFO => 100000; # carrier frequency offset
use constant TIME_STEP => 5e-8;

$num = $#ARGV+1;
if ($num < 4)
{
    print "4 arguments are needed: only $num given \n 1st arg should be file prefix.\n 2nd arg should be cyclic prefix size\n";
    print "3rd arg should be integer precision.\n 4th arg should be fractional precision\n";
    exit 1;
}

my $prefix = $ARGV[0];
my $cpSz   = $ARGV[1];
my $iprec  = $ARGV[2];
my $fprec  = $ARGV[3];

# IO op
$file = "$ARGV[0]Preambles.txt";
open(INFO, $file);
@lines = <INFO>;
close(INFO);

# arrays
foreach $thisLine (@lines)
{
    if ($thisLine =~ /.*Preambles.*/)
    {
	$state += 1;
    }
    elsif($state == 1)
    {
	@temp = split(/, /,$thisLine);
	push(@sPreamble_real, $temp[0]);
	push(@sPreamble_imag, $temp[1]);
	$temp0 = $temp[0]*10000000;
	$temp1 = $temp[1]*10000000;
	push(@shortPreambles, "\t\tList::cons(cmplx(fromRational($temp0,10000000), fromRational($temp1,10000000)),\n");
    } 
    elsif($state == 2)
    {
	@temp = split(/, /,$thisLine);
	push(@lPreamble_real, $temp[0]);
	push(@lPreamble_imag, $temp[1]);
	$temp0 = $temp[0]*10000000;
	$temp1 = $temp[1]*10000000;
	$sign0 = ($temp0 < 0)?1:0;
	$sign1 = ($temp1 < 0)?1:0;
	push(@longPreambles, "\t\tList::cons(cmplx(fromRational($temp0,10000000), fromRational($temp1,10000000)),\n");
	push(@longPreSigns, "\t\tList::cons(cmplx($sign0, $sign1),\n");
    } 
}

# symbol length
$shortLength = @shortPreambles;
$longLength = @longPreambles;
$symbolLength = $shortLength + $cpSz;
print "$symbolLength";

for($i = $cpSz; $i > 0; $i--)
{
    push(@packet_real,$sPreamble_real[$shortLength-$i]);
    push(@packet_imag,$sPreamble_imag[$shortLength-$i]);
}

for($i = 0; $i < $shortLength; $i++)
{
    push(@packet_real,$sPreamble_real[$i]);
    push(@packet_imag,$sPreamble_imag[$i]);
}

for($i = $cpSz; $i > 0; $i--)
{
    push(@packet_real,$lPreamble_real[$longLength-$i]);
    push(@packet_imag,$lPreamble_imag[$longLength-$i]);
}

for($i = 0; $i < $longLength; $i++)
{
    push(@packet_real,$lPreamble_real[$i]);
    push(@packet_imag,$lPreamble_imag[$i]);
}

# channel_model
for($i = @packet_real; $i < 1024 ; $i++)
{
    push(@packet_real,AVERAGE_POWER*(0.5-rand()));
    push(@packet_imag,AVERAGE_POWER*(0.5-rand()));
}
$packetLength = @packet_real;
for($i = 0; $i < $packetLength ; $i++)
{
    # rotation due to difference in oscillators of transmitter and receiver
    $rotAng = $i % 1;
    $rotation_real = cos(2*PI*CFO*$rotAng*TIME_STEP);
    $rotation_imag = sin(2*PI*CFO*$rotAng*TIME_STEP);
    $output_real = $rotation_real*$packet_real[$i]-$rotation_imag*$packet_imag[$i];
    $output_imag = $rotation_real*$packet_imag[$i]+$rotation_imag*$packet_real[$i];
    # noise
    $x1 = rand(1);
    $x2 = rand(1);
    $output_real += AWGN_VARIANCE*sqrt(-2*log($x1))*cos(2*PI*$x2);
    $output_imag += AWGN_VARIANCE*sqrt(-2*log($x1))*sin(2*PI*$x2);
    push(@noisePacket_real, $output_real);
    push(@noisePacket_imag, $output_imag);
} 


# output bluespec code
$file = "$ARGV[0]Preambles.bsv";
open(INFO, ">$file"); # open for output
print INFO "import List::*;\n";
print INFO "import Vector::*;\n";
print INFO "import Complex::*;\n";
print INFO "import DataTypes::*;\n";
print INFO "import RegFile::*;\n";
print INFO "import FixedPoint::*;\n";
print INFO "import FPComplex::*;\n\n";
print INFO "// function to generate short training sequence\n";
print INFO "function Vector#($shortLength, FPComplex#($ARGV[2],$ARGV[3])) getShortPreambles();\n";
print INFO "\tVector#($shortLength, FPComplex#($ARGV[2],$ARGV[3])) tempV = Vector::toVector(\n";
print INFO @shortPreambles;
print INFO "\t\tList::nil)";
for ($i = 0; $i < $shortLength; $i++)
{
    print INFO ")";
}
print INFO ";\n";
print INFO "\treturn tempV;\n";
print INFO "endfunction\n\n";
print INFO "// function to generate long training sequence\n";
print INFO "function Vector#($longLength, FPComplex#($ARGV[2],$ARGV[3])) getLongPreambles();\n";
print INFO "\tVector#($longLength, FPComplex#($ARGV[2],$ARGV[3])) tempV = Vector::toVector(\n";
print INFO @longPreambles;
print INFO "\t\tList::nil)";
for ($i = 0; $i < $longLength; $i++)
{
    print INFO ")";
}
print INFO ";\n";
print INFO "\treturn tempV;\n";
print INFO "endfunction\n\n";
print INFO "// function to generate long training sequence (signs only)\n";
print INFO "function Vector#($longLength, Complex#(Bit#(1))) getLongPreSigns();\n";
print INFO "\tVector#($longLength, Complex#(Bit#(1))) tempV = Vector::toVector(\n";
print INFO @longPreSigns;
print INFO "\t\tList::nil)";
for ($i = 0; $i < $longLength; $i++)
{
    print INFO ")";
}
print INFO ";\n";
print INFO "\treturn tempV;\n";
print INFO "endfunction\n\n";
$logn = ceil(log($packetLength)/log(2));
$maxIndex = $packetLength - 1;
print INFO "// module to generate sample packet\n";
print INFO "(* synthesize *)\n";
print INFO "module mkPacket(RegFile#(Bit#($logn), FPComplex#($ARGV[2],$ARGV[3])));\n";
print INFO "\tRegFile#(Bit#($logn), FPComplex#($ARGV[2],$ARGV[3])) regFile <- mkRegFileLoad(\"$ARGV[0]Packet.txt\",0,$maxIndex);\n";
print INFO "\treturn regFile;\n";
print INFO "endmodule\n\n";
print INFO "// module to generate sample packet\n";
print INFO "(* synthesize *)\n";
print INFO "module mkTweakedPacket(RegFile#(Bit#($logn), FPComplex#($ARGV[2],$ARGV[3])));\n";
print INFO "\tRegFile#(Bit#($logn), FPComplex#($ARGV[2],$ARGV[3])) regFile <- mkRegFileLoad(\"$ARGV[0]TweakedPacket.txt\",0,$maxIndex);\n";
print INFO "\treturn regFile;\n";
print INFO "endmodule\n\n";
close(INFO);

# write regfile "$ARGV[0]Packet.txt" 
$file = "$ARGV[0]Packet.txt";
open(INFO, ">$file"); # open for output
for ($i = 0 ; $i < $packetLength ; $i++)
{
    if ($packet_real[$i]>=0)
    {
	print INFO sprintf("%.4x",floor($packet_real[$i]*(2**$ARGV[3])));
    }
    else
    {
	print INFO sprintf("%.4x",floor($packet_real[$i]*(2**$ARGV[3])+(2**($ARGV[2]+$ARGV[3]))));
    }	
    if ($packet_imag[$i]>=0)
    {
	print INFO sprintf("%.4x\n",floor($packet_imag[$i]*(2**$ARGV[3])));
    }
    else
    {
	print INFO sprintf("%.4x\n",floor($packet_imag[$i]*(2**$ARGV[3])+(2**($ARGV[2]+$ARGV[3]))));
    }	
#    print "$packet_real[$i]";
#    print ", $packet_imag[$i]\n";
}
close(INFO);

print "\n";
# write regfile "$ARGV[0]TweakedPacket.txt" 
$file = "$ARGV[0]TweakedPacket.txt";
open(INFO, ">$file"); # open for output
for ($i = 0 ; $i < $packetLength ; $i++)
{
    if ($noisePacket_real[$i]>=0)
    {
	print INFO sprintf("%.4x",floor($noisePacket_real[$i]*(2**$ARGV[3])));
    }
    else
    {
	print INFO sprintf("%.4x",floor($noisePacket_real[$i]*(2**$ARGV[3])+(2**($ARGV[2]+$ARGV[3]))));
    }	
    if ($noisePacket_imag[$i]>=0)
    {
	print INFO sprintf("%.4x\n",floor($noisePacket_imag[$i]*(2**$ARGV[3])));
    }
    else
    {
	print INFO sprintf("%.4x\n",floor($noisePacket_imag[$i]*(2**$ARGV[3])+(2**($ARGV[2]+$ARGV[3]))));
    }	
#    print "$noisePacket_real[$i]";
#    print ", $noisePacket_imag[$i]\n";
}
close(INFO);










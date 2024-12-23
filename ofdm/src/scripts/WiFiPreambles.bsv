import List::*;
import Vector::*;
import Complex::*;
import DataTypes::*;
import RegFile::*;
import FixedPoint::*;
import FPComplex::*;

// function to generate short training sequence
function Vector#(128, FPComplex#(2,14)) getShortPreambles();
	Vector#(128, FPComplex#(2,14)) tempV = Vector::toVector(
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(920000,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(0,10000000), fromRational(920000,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(920000,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(0,10000000), fromRational(920000,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(920000,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(0,10000000), fromRational(920000,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(920000,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(0,10000000), fromRational(920000,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(920000,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(0,10000000), fromRational(920000,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(920000,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(0,10000000), fromRational(920000,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(920000,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(0,10000000), fromRational(920000,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(920000,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(1427600,10000000), fromRational(-126500,10000000)),
		List::cons(cmplx(fromRational(-134700,10000000), fromRational(-785200,10000000)),
		List::cons(cmplx(fromRational(-1324400,10000000), fromRational(23400,10000000)),
		List::cons(cmplx(fromRational(460000,10000000), fromRational(460000,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(0,10000000), fromRational(920000,10000000)),
		List::cons(cmplx(fromRational(-126500,10000000), fromRational(1427600,10000000)),
		List::cons(cmplx(fromRational(-785200,10000000), fromRational(-134700,10000000)),
		List::cons(cmplx(fromRational(23400,10000000), fromRational(-1324400,10000000)),
		List::nil)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
	return tempV;
endfunction

// function to generate long training sequence
function Vector#(128, FPComplex#(2,14)) getLongPreambles();
	Vector#(128, FPComplex#(2,14)) tempV = Vector::toVector(
		List::cons(cmplx(fromRational(1562500,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(-51200,10000000), fromRational(-1203300,10000000)),
		List::cons(cmplx(fromRational(397500,10000000), fromRational(-1111600,10000000)),
		List::cons(cmplx(fromRational(968300,10000000), fromRational(828000,10000000)),
		List::cons(cmplx(fromRational(211100,10000000), fromRational(278900,10000000)),
		List::cons(cmplx(fromRational(598200,10000000), fromRational(-877100,10000000)),
		List::cons(cmplx(fromRational(-1151300,10000000), fromRational(-551800,10000000)),
		List::cons(cmplx(fromRational(-383200,10000000), fromRational(-1061700,10000000)),
		List::cons(cmplx(fromRational(975400,10000000), fromRational(-258900,10000000)),
		List::cons(cmplx(fromRational(533400,10000000), fromRational(40800,10000000)),
		List::cons(cmplx(fromRational(9900,10000000), fromRational(-1150000,10000000)),
		List::cons(cmplx(fromRational(-1368000,10000000), fromRational(-473800,10000000)),
		List::cons(cmplx(fromRational(244800,10000000), fromRational(-585300,10000000)),
		List::cons(cmplx(fromRational(586700,10000000), fromRational(-149400,10000000)),
		List::cons(cmplx(fromRational(-224800,10000000), fromRational(1606600,10000000)),
		List::cons(cmplx(fromRational(1192400,10000000), fromRational(-41000,10000000)),
		List::cons(cmplx(fromRational(625000,10000000), fromRational(-625000,10000000)),
		List::cons(cmplx(fromRational(369200,10000000), fromRational(983400,10000000)),
		List::cons(cmplx(fromRational(-572100,10000000), fromRational(393000,10000000)),
		List::cons(cmplx(fromRational(-1312600,10000000), fromRational(652300,10000000)),
		List::cons(cmplx(fromRational(822200,10000000), fromRational(923600,10000000)),
		List::cons(cmplx(fromRational(695600,10000000), fromRational(141200,10000000)),
		List::cons(cmplx(fromRational(-603100,10000000), fromRational(812900,10000000)),
		List::cons(cmplx(fromRational(-564600,10000000), fromRational(-218000,10000000)),
		List::cons(cmplx(fromRational(-350400,10000000), fromRational(-1508900,10000000)),
		List::cons(cmplx(fromRational(-1218900,10000000), fromRational(-165700,10000000)),
		List::cons(cmplx(fromRational(-1273200,10000000), fromRational(-205000,10000000)),
		List::cons(cmplx(fromRational(750700,10000000), fromRational(-740400,10000000)),
		List::cons(cmplx(fromRational(-28100,10000000), fromRational(537700,10000000)),
		List::cons(cmplx(fromRational(-918900,10000000), fromRational(1151300,10000000)),
		List::cons(cmplx(fromRational(917200,10000000), fromRational(1058700,10000000)),
		List::cons(cmplx(fromRational(122800,10000000), fromRational(976000,10000000)),
		List::cons(cmplx(fromRational(-1562500,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(122800,10000000), fromRational(-976000,10000000)),
		List::cons(cmplx(fromRational(917200,10000000), fromRational(-1058700,10000000)),
		List::cons(cmplx(fromRational(-918900,10000000), fromRational(-1151300,10000000)),
		List::cons(cmplx(fromRational(-28100,10000000), fromRational(-537700,10000000)),
		List::cons(cmplx(fromRational(750700,10000000), fromRational(740400,10000000)),
		List::cons(cmplx(fromRational(-1273200,10000000), fromRational(205000,10000000)),
		List::cons(cmplx(fromRational(-1218900,10000000), fromRational(165700,10000000)),
		List::cons(cmplx(fromRational(-350400,10000000), fromRational(1508900,10000000)),
		List::cons(cmplx(fromRational(-564600,10000000), fromRational(218000,10000000)),
		List::cons(cmplx(fromRational(-603100,10000000), fromRational(-812900,10000000)),
		List::cons(cmplx(fromRational(695600,10000000), fromRational(-141200,10000000)),
		List::cons(cmplx(fromRational(822200,10000000), fromRational(-923600,10000000)),
		List::cons(cmplx(fromRational(-1312600,10000000), fromRational(-652300,10000000)),
		List::cons(cmplx(fromRational(-572100,10000000), fromRational(-393000,10000000)),
		List::cons(cmplx(fromRational(369200,10000000), fromRational(-983400,10000000)),
		List::cons(cmplx(fromRational(625000,10000000), fromRational(625000,10000000)),
		List::cons(cmplx(fromRational(1192400,10000000), fromRational(41000,10000000)),
		List::cons(cmplx(fromRational(-224800,10000000), fromRational(-1606600,10000000)),
		List::cons(cmplx(fromRational(586700,10000000), fromRational(149400,10000000)),
		List::cons(cmplx(fromRational(244800,10000000), fromRational(585300,10000000)),
		List::cons(cmplx(fromRational(-1368000,10000000), fromRational(473800,10000000)),
		List::cons(cmplx(fromRational(9900,10000000), fromRational(1150000,10000000)),
		List::cons(cmplx(fromRational(533400,10000000), fromRational(-40800,10000000)),
		List::cons(cmplx(fromRational(975400,10000000), fromRational(258900,10000000)),
		List::cons(cmplx(fromRational(-383200,10000000), fromRational(1061700,10000000)),
		List::cons(cmplx(fromRational(-1151300,10000000), fromRational(551800,10000000)),
		List::cons(cmplx(fromRational(598200,10000000), fromRational(877100,10000000)),
		List::cons(cmplx(fromRational(211100,10000000), fromRational(-278900,10000000)),
		List::cons(cmplx(fromRational(968300,10000000), fromRational(-828000,10000000)),
		List::cons(cmplx(fromRational(397500,10000000), fromRational(1111600,10000000)),
		List::cons(cmplx(fromRational(-51200,10000000), fromRational(1203300,10000000)),
		List::cons(cmplx(fromRational(1562500,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(-51200,10000000), fromRational(-1203300,10000000)),
		List::cons(cmplx(fromRational(397500,10000000), fromRational(-1111600,10000000)),
		List::cons(cmplx(fromRational(968300,10000000), fromRational(828000,10000000)),
		List::cons(cmplx(fromRational(211100,10000000), fromRational(278900,10000000)),
		List::cons(cmplx(fromRational(598200,10000000), fromRational(-877100,10000000)),
		List::cons(cmplx(fromRational(-1151300,10000000), fromRational(-551800,10000000)),
		List::cons(cmplx(fromRational(-383200,10000000), fromRational(-1061700,10000000)),
		List::cons(cmplx(fromRational(975400,10000000), fromRational(-258900,10000000)),
		List::cons(cmplx(fromRational(533400,10000000), fromRational(40800,10000000)),
		List::cons(cmplx(fromRational(9900,10000000), fromRational(-1150000,10000000)),
		List::cons(cmplx(fromRational(-1368000,10000000), fromRational(-473800,10000000)),
		List::cons(cmplx(fromRational(244800,10000000), fromRational(-585300,10000000)),
		List::cons(cmplx(fromRational(586700,10000000), fromRational(-149400,10000000)),
		List::cons(cmplx(fromRational(-224800,10000000), fromRational(1606600,10000000)),
		List::cons(cmplx(fromRational(1192400,10000000), fromRational(-41000,10000000)),
		List::cons(cmplx(fromRational(625000,10000000), fromRational(-625000,10000000)),
		List::cons(cmplx(fromRational(369200,10000000), fromRational(983400,10000000)),
		List::cons(cmplx(fromRational(-572100,10000000), fromRational(393000,10000000)),
		List::cons(cmplx(fromRational(-1312600,10000000), fromRational(652300,10000000)),
		List::cons(cmplx(fromRational(822200,10000000), fromRational(923600,10000000)),
		List::cons(cmplx(fromRational(695600,10000000), fromRational(141200,10000000)),
		List::cons(cmplx(fromRational(-603100,10000000), fromRational(812900,10000000)),
		List::cons(cmplx(fromRational(-564600,10000000), fromRational(-218000,10000000)),
		List::cons(cmplx(fromRational(-350400,10000000), fromRational(-1508900,10000000)),
		List::cons(cmplx(fromRational(-1218900,10000000), fromRational(-165700,10000000)),
		List::cons(cmplx(fromRational(-1273200,10000000), fromRational(-205000,10000000)),
		List::cons(cmplx(fromRational(750700,10000000), fromRational(-740400,10000000)),
		List::cons(cmplx(fromRational(-28100,10000000), fromRational(537700,10000000)),
		List::cons(cmplx(fromRational(-918900,10000000), fromRational(1151300,10000000)),
		List::cons(cmplx(fromRational(917200,10000000), fromRational(1058700,10000000)),
		List::cons(cmplx(fromRational(122800,10000000), fromRational(976000,10000000)),
		List::cons(cmplx(fromRational(-1562500,10000000), fromRational(0,10000000)),
		List::cons(cmplx(fromRational(122800,10000000), fromRational(-976000,10000000)),
		List::cons(cmplx(fromRational(917200,10000000), fromRational(-1058700,10000000)),
		List::cons(cmplx(fromRational(-918900,10000000), fromRational(-1151300,10000000)),
		List::cons(cmplx(fromRational(-28100,10000000), fromRational(-537700,10000000)),
		List::cons(cmplx(fromRational(750700,10000000), fromRational(740400,10000000)),
		List::cons(cmplx(fromRational(-1273200,10000000), fromRational(205000,10000000)),
		List::cons(cmplx(fromRational(-1218900,10000000), fromRational(165700,10000000)),
		List::cons(cmplx(fromRational(-350400,10000000), fromRational(1508900,10000000)),
		List::cons(cmplx(fromRational(-564600,10000000), fromRational(218000,10000000)),
		List::cons(cmplx(fromRational(-603100,10000000), fromRational(-812900,10000000)),
		List::cons(cmplx(fromRational(695600,10000000), fromRational(-141200,10000000)),
		List::cons(cmplx(fromRational(822200,10000000), fromRational(-923600,10000000)),
		List::cons(cmplx(fromRational(-1312600,10000000), fromRational(-652300,10000000)),
		List::cons(cmplx(fromRational(-572100,10000000), fromRational(-393000,10000000)),
		List::cons(cmplx(fromRational(369200,10000000), fromRational(-983400,10000000)),
		List::cons(cmplx(fromRational(625000,10000000), fromRational(625000,10000000)),
		List::cons(cmplx(fromRational(1192400,10000000), fromRational(41000,10000000)),
		List::cons(cmplx(fromRational(-224800,10000000), fromRational(-1606600,10000000)),
		List::cons(cmplx(fromRational(586700,10000000), fromRational(149400,10000000)),
		List::cons(cmplx(fromRational(244800,10000000), fromRational(585300,10000000)),
		List::cons(cmplx(fromRational(-1368000,10000000), fromRational(473800,10000000)),
		List::cons(cmplx(fromRational(9900,10000000), fromRational(1150000,10000000)),
		List::cons(cmplx(fromRational(533400,10000000), fromRational(-40800,10000000)),
		List::cons(cmplx(fromRational(975400,10000000), fromRational(258900,10000000)),
		List::cons(cmplx(fromRational(-383200,10000000), fromRational(1061700,10000000)),
		List::cons(cmplx(fromRational(-1151300,10000000), fromRational(551800,10000000)),
		List::cons(cmplx(fromRational(598200,10000000), fromRational(877100,10000000)),
		List::cons(cmplx(fromRational(211100,10000000), fromRational(-278900,10000000)),
		List::cons(cmplx(fromRational(968300,10000000), fromRational(-828000,10000000)),
		List::cons(cmplx(fromRational(397500,10000000), fromRational(1111600,10000000)),
		List::cons(cmplx(fromRational(-51200,10000000), fromRational(1203300,10000000)),
		List::nil)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
	return tempV;
endfunction

// function to generate long training sequence (signs only)
function Vector#(128, Complex#(Bit#(1))) getLongPreSigns();
	Vector#(128, Complex#(Bit#(1))) tempV = Vector::toVector(
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(1, 0),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 1),
		List::cons(cmplx(0, 0),
		List::cons(cmplx(1, 0),
		List::nil)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
	return tempV;
endfunction

// module to generate sample packet
(* synthesize *)
module mkPacket(RegFile#(Bit#(10), FPComplex#(2,14)));
	RegFile#(Bit#(10), FPComplex#(2,14)) regFile <- mkRegFileLoad("WiFiPacket.txt",0,1023);
	return regFile;
endmodule

// module to generate sample packet
(* synthesize *)
module mkTweakedPacket(RegFile#(Bit#(10), FPComplex#(2,14)));
	RegFile#(Bit#(10), FPComplex#(2,14)) regFile <- mkRegFileLoad("WiFiTweakedPacket.txt",0,1023);
	return regFile;
endmodule


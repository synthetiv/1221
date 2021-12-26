(
{
	arg hz = 113;
	var rati = [ 1, 9/8, 3/2, 1/3, 1/4, 7/4, 2, 9/4 ];
	var brea = Line.kr * 0.65;
	var feed = LocalIn.ar(rati.size);
	var lfos = LFTri.kr(0.059, 1, 0.05) + LFTri.kr(0.13, (1..rati.size) * 4 / rati.size, 0.07);
	var embo = DelayL.ar(
		feed * 0.5 + (brea * (1 + WhiteNoise.ar(0.001))),
		0.2,
		(2 * hz * Select.kr(LFTri.kr(0.01).range(0, rati.size - 1), rati).lag(0.2) * 2.pow(lfos)).reciprocal
	);
	var bore = OnePole.ar(DelayL.ar(feed * 0.55 + embo - embo.cubed, 0.2, (hz * rati).reciprocal - ControlRate.ir.reciprocal), 0.6);
	var out = Splay.ar(bore - brea);
	LocalOut.ar(bore);
	Peak.ar(out).poll;
	out * -5.dbamp;
}.play;
)
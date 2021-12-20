(
{
	var hz = 440;
	var modmodhz = 0.13;
	var modmod = LFTri.kr(modmodhz).range(0, 1).exp;
	var modbase = [0.42, 0.21];
	var mod = (LFTri.kr(modbase * modmod) / modmod) * 4 + 5;
	var noterate = modbase * 4;
	var hzz = hz * mod[0].floor / mod[1].floor;
	var chdhz = Latch.kr(hzz, Impulse.kr(noterate[0] / (5..9)) + Impulse.kr(0)).lag((5..9) / 10);
	var chdenv = EnvGen.kr(Env.perc(0.6, 7), Impulse.kr(noterate[0] / 11) - Impulse.kr(0));
	var ton = SinOsc.ar(hzz, SinOsc.ar(chdhz[4]) * chdenv.cubed * 3pi * [-1, 1]) * -13.dbamp;
	var chd = SVF.ar(Mix(Pan2.ar(Saw.ar(chdhz), SinOsc.ar(modmodhz, (0..4) / 5 * 2pi))), chdenv.squared * 7000 + 100) * chdenv;
	var del = RLPF.ar(DelayL.ar((ton * chdenv + LocalIn.ar(2) + chd).distort * -4.dbamp, 2, 1.3 + SinOsc.ar(0.17, 0, 0.01)), 3000);
	var out = ton + del * 3.dbamp;
	LocalOut.ar(del.reverse);
	out;
}.play;
)
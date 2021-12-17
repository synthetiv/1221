(
{
	arg hz = 110;
	var sins = SinOsc.kr(0.2 * (3..7), (0..4) * 2pi / 5) / (7..11);
	var sels = LFTri.kr(0.02, (0..7) / 2).range(0, 4);
	var lung = SelectX.kr(sels, sins);
	var tone = SinOsc.ar(hz * (4..10)) * lung;
	var ring = Mix(Pan2.ar(tone, SinOsc.kr(0.1, (0..7) * pi / 4)));

	var lharm = Select.kr(LFSaw.kr(0.2).range(0, 10), (10..1));
	var lsub = Select.kr(Select.kr(LFSaw.kr(0.00375).range(0, 4), LFSaw.kr(0.3, (0..3) / 2)).range(0, 10), (11..2));
	var lhz = hz * Lag.kr(lharm / lsub, 0.02);
	var lo = SinOsc.ar(lhz) * lharm.linexp(1, 2, 1, -3.dbamp);

	var mix = Mix([
		lo * Line.kr(dur: 21).cubed * -8.dbamp,
		ring * Line.kr(dur: 7).squared * -5.dbamp
	]);

	mix;
}.play;
)
(
Routine {
	// 48kHz sample rate recommended! not sure what this will do at 44.1
	// volume warning again -- starts quiet but does not stay that way
    SynthDef(\moo, {
        arg dc = -0.27,
        rq = 0.23,
        del = 0.053;
		var modcut = [113, 115] + DelayL.ar(LocalIn.ar(2).reverse, 1, del, [45, 46]);
        var filter = BLowPass.ar(K2A.ar(dc), modcut, rq);
		var ears = SVF.ar(Splay.ar((filter - dc).softclip, 0.6), 9000, 0.06) * -3.dbamp;
		ears.scope;
		Peak.ar(ears).poll;
        LocalOut.ar(filter);
		Out.ar(0, ears);
    }).add;
    s.sync;
    z = Synth(\moo);
}.play;
)
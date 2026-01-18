// Αρχείο wav.

~b0 = Buffer.read(s, "C:/Users/User/Desktop/Universcity/Μουσική Πληροφορική/CreatureAudio/girl.wav");
~b0.play;    // Test.


// 1) Δημιουργία Synthdef για τον συνδυασμό ring modulation, playback rate, amplitude envelope & low-pass filter & reverb.

SynthDef(\mixTest2, { |out=0, buf=0, rate=1, modFreq=400, amp=0.0, ampLag=0.1,
	atk=0.2, rel=1.0, gate=1, lpf=18000, revMix=0.0|
    var samp, tone, sig, env, a, wet;

	// Sample ΄κ προθήκη playback rate.
	samp = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, loop: 1);

	// Sine wave για ring modulation. & low-pass filter.
	tone = SinOsc.ar(modFreq);
	sig  = LPF.ar(samp * tone, lpf);

	// Lag στην ένταση για να μην κάνει clicks.
	a = Lag.kr(amp, ampLag);

	// doneAction: 0 => ΔΕΝ πεθαίνει ο synth & // Envelope (επεξεργασία της αττάκας και της ουράς.
	env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction: 0);

	sig = sig * a * env;
    // Reverb & Crossfade dry/wet & revMix για σωστό mix.
	wet = FreeVerb.ar(sig, mix: revMix, room: 0.6, damp: 0.5);
	sig = XFade2.ar(sig, wet, (revMix * 2 - 1));

	// //Επιλογή 2 καναλιών ήχου stereo.
	Out.ar(out, sig);

}).add;


// 2) Εκκίνηση του synth σε κατάσταση σιωπής. & // Οι αλλαγές γίνονται αργότερα μέσω των states (morning, day, noon, afternoon, evening, night).

~x = Synth(\mixTest2, [\buf, ~b0, \amp, 0.0, \ampLag, 0.2]);



// Ο πίνακας ~states περιέχει functions που αντιστοιχούν σε διαφορετικές καταστάσεις του ήχου. & καθε state αλλάζει παραμέτρους του ίδιου synth σε πραγματικό χρόνο.

~states = (
	morning: {
		// fade in: ανεβάζει amp αργά (με ampLag).
		~x.set(\ampLag, 6.0, \amp, 0.55, \rate, 0.95, \modFreq, 220, \lpf, 14000, \revMix, 0.15);
	},

	day: {
		// γρήγορο.
		~x.set(\ampLag, 0.3, \amp, 0.65, \rate, 1.35, \modFreq, 650, \lpf, 18000, \revMix, 0.05);
	},

	noon: {
		// αργό.
		~x.set(\ampLag, 0.6, \amp, 0.50, \rate, 0.65, \modFreq, 120, \lpf, 9000, \revMix, 0.20);
	},

	afternoon: {
		// wobble / κίνηση: λίγο πιο “ζωντανό” με reverb και χαμηλότερο φίλτρο.
		~x.set(\ampLag, 0.4, \amp, 0.60, \rate, 1.05, \modFreq, 420, \lpf, 7000, \revMix, 0.35);
	},

	evening: {
		// πιο σκοτεινό/ατμοσφαιρικό.
		~x.set(\ampLag, 1.0, \amp, 0.45, \rate, 0.85, \modFreq, 160, \lpf, 4500, \revMix, 0.45);
	},

	night: {
		// fade out: κατεβάζει amp αργά, και μετά κλείνει gate για να τερματίσει.
		~x.set(\ampLag, 7.0, \amp, 0.0, \lpf, 3000, \revMix, 0.55);
		SystemClock.sched(7.5, { if(~x.notNil) { ~x.set(\gate, 0) }; nil });
	}
);

s.freeAll;







Girl : Creature {

	// ---------------------------------------------------------
	// 1) Όνομα του audio file
	// ---------------------------------------------------------
	// Το EvoLab θα χρησιμοποιήσει το girl.wav
	// από τον φάκελο CreatureAudioFiles.
	*fileName {
		^"girl.wav"
	}


	// ---------------------------------------------------------
	// 2) SynthDef
	// ---------------------------------------------------------
	// Ο SynthDef περιέχει την ηχητική επεξεργασία του Girl:
	// playback rate, ring modulation, low-pass filter,
	// amplitude envelope και reverb.
	*addSynthDefs {

		SynthDef(\girl, {
			|out=0, buf=0, rate=1.0, modFreq=400,
			amp=0.0, ampLag=0.1,
			atk=0.2, rel=1.0, gate=1,
			lpf=18000, revMix=0.0|

			var samp, tone, sig, env, a, wet;

			// Sample με δυνατότητα ελέγχου του playback rate.
			// Το girl.wav πρέπει να είναι mono.
			samp = PlayBuf.ar(
				1,
				buf,
				BufRateScale.kr(buf) * rate,
				loop: 1
			);

			// Sine wave για ring modulation.
			tone = SinOsc.ar(modFreq);

			// Ring modulation και low-pass filter.
			sig = LPF.ar(samp * tone, lpf);

			// Ομαλή αλλαγή της έντασης για αποφυγή clicks.
			a = Lag.kr(amp, ampLag);

			// Attack / release envelope.
			// doneAction: 0 ώστε ο synth να μην τερματίζεται
			// αυτόματα από το envelope.
			env = EnvGen.kr(
				Env.asr(atk, 1, rel),
				gate,
				doneAction: 0
			);

			// Εφαρμογή amplitude και envelope.
			sig = sig * a * env;

			// Reverb.
			wet = FreeVerb.ar(
				sig,
				mix: revMix,
				room: 0.6,
				damp: 0.5
			);

			// Crossfade μεταξύ dry και wet.
			// revMix 0..1 μετατρέπεται σε -1..+1
			// όπως απαιτεί το XFade2.
			sig = XFade2.ar(
				sig,
				wet,
				(revMix * 2 - 1)
			);

			// Stereo output.
			Out.ar(
				out,
				Pan2.ar(sig, 0)
			);

		}).add;
	}


	// ---------------------------------------------------------
	// 3) DAWN
	// ---------------------------------------------------------
	// Αντιστοιχεί στην παλιά κατάσταση morning.
	// Ήπια αρχή, αργό fade in και χαμηλότερη κίνηση.

	dawn {

		this.substitute(
			Synth(\girl, [
				\buf, this.buffer,
				\amp, 0.55,
				\ampLag, 6.0,
				\rate, 0.95,
				\modFreq, 220,
				\lpf, 14000,
				\revMix, 0.15,
				\atk, 0.2,
				\rel, 1.2
			])
		);

	}


	// ---------------------------------------------------------
	// 4) DAY
	// ---------------------------------------------------------
	// Αντιστοιχεί στην παλιά κατάσταση day.
	// Πιο γρήγορο playback και πιο έντονο ring modulation.

	day {

		this.substitute(
			Synth(\girl, [
				\buf, this.buffer,
				\amp, 0.65,
				\ampLag, 0.3,
				\rate, 1.35,
				\modFreq, 650,
				\lpf, 18000,
				\revMix, 0.05,
				\atk, 0.2,
				\rel, 1.0
			])
		);

	}


	// ---------------------------------------------------------
	// 5) DUSK
	// ---------------------------------------------------------
	// Εδώ συνδυάζουμε την ιδέα των παλιών noon / afternoon.
	// Ο ήχος γίνεται πιο αργός, πιο σκοτεινός και
	// αποκτά περισσότερο reverb.

	dusk {

		this.substitute(
			Synth(\girl, [
				\buf, this.buffer,
				\amp, 0.55,
				\ampLag, 1.0,
				\rate, 0.85,
				\modFreq, 250,
				\lpf, 7000,
				\revMix, 0.35,
				\atk, 0.4,
				\rel, 1.5
			])
		);

	}


	// ---------------------------------------------------------
	// 6) NIGHT
	// ---------------------------------------------------------
	// Αντιστοιχεί στην παλιά κατάσταση evening.
	// Πιο αργό, σκοτεινό και ατμοσφαιρικό.

	night {

		this.substitute(
			Synth(\girl, [
				\buf, this.buffer,
				\amp, 0.45,
				\ampLag, 1.0,
				\rate, 0.85,
				\modFreq, 160,
				\lpf, 4500,
				\revMix, 0.45,
				\atk, 0.5,
				\rel, 2.0
			])
		);

	}


	// ---------------------------------------------------------
	// 7) DANGER
	// ---------------------------------------------------------
	// Ειδική πιο έντονη / επιθετική κατάσταση.
	// Χρησιμοποιεί τις ίδιες τεχνικές του έργου,
	// αλλά με μεγαλύτερο playback rate και ring modulation.

	danger {

		this.substitute(
			Synth(\girl, [
				\buf, this.buffer,
				\amp, 0.70,
				\ampLag, 0.2,
				\rate, 1.50,
				\modFreq, 900,
				\lpf, 5000,
				\revMix, 0.55,
				\atk, 0.1,
				\rel, 0.5
			])
		);

	}

}





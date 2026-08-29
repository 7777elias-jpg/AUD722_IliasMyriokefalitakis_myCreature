
IliasGirl : Creature {

	*fileName {
		^"girl.wav"
	}

	*addSynthDefs {
		SynthDef(\girl, {
			|out=0, buf=0, rate=1.0, modFreq=400, amp=0.5,
			atk=0.2, rel=1.0, gate=1, lpf=18000, revMix=0.0|

			var samp, tone, sig, env, wet;

			samp = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate, loop: 1);
			tone = SinOsc.ar(modFreq);
			sig = LPF.ar(samp * tone, lpf);

			env = EnvGen.kr(
				Env.asr(atk, 1, rel),
				gate,
				doneAction: 2
			);

			sig = sig * amp * env;

			wet = FreeVerb.ar(
				sig,
				mix: revMix,
				room: 0.6,
				damp: 0.5
			);

			sig = XFade2.ar(sig, wet, (revMix * 2 - 1));

			Out.ar(out, Pan2.ar(sig, 0));
		}).add;
	}

	// DAWN – ήρεμη αρχή
	dawn {
		this.substitute(
			Synth(\girl, [
				\buf, this.buffer,
				\rate, 0.95,
				\modFreq, 220,
				\amp, 0.55,
				\lpf, 14000,
				\revMix, 0.15,
				\atk, 0.2,
				\rel, 1.2
			])
		);
	}

	// DAY – γρήγορο και πιο έντονο
	day {
		this.substitute(
			Synth(\girl, [
				\buf, this.buffer,
				\rate, 1.35,
				\modFreq, 650,
				\amp, 0.65,
				\lpf, 18000,
				\revMix, 0.05
			])
		);
	}

	// DUSK – πιο αργό και σκοτεινό
	dusk {
		this.substitute(
			Synth(\girl, [
				\buf, this.buffer,
				\rate, 0.85,
				\modFreq, 250,
				\amp, 0.55,
				\lpf, 7000,
				\revMix, 0.35
			])
		);
	}

	// NIGHT – σκοτεινό και ατμοσφαιρικό
	night {
		this.substitute(
			Synth(\girl, [
				\buf, this.buffer,
				\rate, 0.85,
				\modFreq, 160,
				\amp, 0.45,
				\lpf, 4500,
				\revMix, 0.45
			])
		);
	}

	// DANGER – πιο έντονο και επιθετικό
	danger {
		this.substitute(
			Synth(\girl, [
				\buf, this.buffer,
				\rate, 1.50,
				\modFreq, 900,
				\amp, 0.70,
				\lpf, 5000,
				\revMix, 0.55
			])
		);
	}

}
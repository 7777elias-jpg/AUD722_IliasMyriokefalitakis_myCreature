//Εκτέλεση του έργου

//Ο κώδικας του έργου δεν εκτελείται ταυτόχρονα, αλλά ακολουθεί διαδοχικά στάδια.
//Αρχικά φορτώνεται το ηχητικό αρχείο (Buffer), το οποίο αποτελεί την πρώτη ύλη του ήχου.
//Στη συνέχεια ορίζεται το SynthDef και δημιουργείται ο synth, ο οποίος είναι υπεύθυνος για την παραγωγή και επεξεργασία του ηχητικού σήματος.

//Έπειτα ορίζονται οι διαφορετικές μουσικές καταστάσεις (states), οι οποίες μεταβάλλουν σε πραγματικό χρόνο τις παραμέτρους του ίδιου synth, καθώς και ο πίνακας διάρκειας που καθορίζει τον χρόνο παραμονής σε κάθε κατάσταση.
//Τέλος, το Routine λειτουργεί ως χρονικός μηχανισμός του έργου, ενεργοποιώντας διαδοχικά τις καταστάσεις με τη σωστή σειρά και διαμορφώνοντας τη συνολική χρονική δομή του κομματιού.






// Αρχείο wav.

~b0 = Buffer.read(s, "C:/Users/User/Desktop/University/Μουσική Πληροφορική/CreatureAudio/girl.wav");
~b0.play;    // Test.


// 1) Δημιουργία Synthdef για τον συνδυασμό ring modulation, playback rate, amplitude envelope & low-pass filter & reverb.

SynthDef(\mixTest2, { |out=0, buf=0, rate=1, modFreq=400, amp=0.0, ampLag=0.1,
	atk=0.2, rel=1.0, gate=1, lpf=18000, revMix=0.0|
    var samp, tone, sig, env, a, wet;

	// Sample με δυνατότητα ελέγχου του playback rate.
	samp = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, loop: 1);

	// Sine wave για ring modulation. & low-pass filter.
	tone = SinOsc.ar(modFreq);
	sig  = LPF.ar(samp * tone, lpf);

	// Lag στην ένταση για να μην κάνει clicks.
	a = Lag.kr(amp, ampLag);

	// Envelope (attack–release). Το doneAction: 0 σημαίνει ότι ο synth. Δεν αυτοκαταστρέφεται μετά το τέλος του envelope.
	env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction: 0);

	sig = sig * a * env;
    // Reverb και crossfade μεταξύ dry και wet σήματος. Η παράμετρος revMix ελέγχει την αναλογία.
	wet = FreeVerb.ar(sig, mix: revMix, room: 0.6, damp: 0.5);
	sig = XFade2.ar(sig, wet, (revMix * 2 - 1));

	// //Επιλογή 2 καναλιών ήχου stereo.
	Out.ar(out, sig);

}).add;


// 2) Εκκίνηση του synth σε κατάσταση σιωπής. & // Οι αλλαγές γίνονται αργότερα μέσω των states (morning, day, noon, afternoon, evening, night).

~x = Synth(\mixTest2, [\buf, ~b0, \amp, 0.0, \ampLag, 0.2]);



// 3) Ο πίνακας ~states περιέχει functions που αντιστοιχούν σε διαφορετικές καταστάσεις του ήχου. & καθε state αλλάζει παραμέτρους του ίδιου synth σε πραγματικό χρόνο.

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


// 4) Timeline: ο πίνακας ~dur αποθηκεύει τη διάρκεια κάθε state σε δευτερόλεπτα & τα ονόματα (morning, day, noon, afternoon, evening, night) αντιστοιχούν στα states του πίνακα ~states.
// Οι τιμές καθορίζουν πόσο χρόνο παραμένει το κομμάτι σε κάθε κατάσταση πριν περάσει στην επόμενη.

~dur = (
	morning: 8,
	day: 10,
	noon: 8,
	afternoon: 10,
	evening: 10,
	night: 10
);


// 5) Το Routine λειτουργεί ως ο “player” του κομματιού & εκτελεί διαδοχικά τα states του πίνακα ~states, παραμένοντας σε κάθε κατάσταση για τον χρόνο που ορίζεται στον πίνακα διάρκειας. ~dur. Επιπλέον η εντολή postln χρησιμοποιείται για οπτική ένδειξη στο Post window, ώστε να φαίνεται σε ποιο στάδιο βρίσκεται το κομμάτι σε πραγματικό χρόνο.

~piece = Routine({
	"MORNING".postln;   ~states[\morning].value;   ~dur[\morning].wait;
	"DAY".postln;       ~states[\day].value;       ~dur[\day].wait;
	"NOON".postln;      ~states[\noon].value;      ~dur[\noon].wait;
	"AFTERNOON".postln; ~states[\afternoon].value; ~dur[\afternoon].wait;
	"EVENING".postln;   ~states[\evening].value;   ~dur[\evening].wait;
	"NIGHT".postln;     ~states[\night].value;     ~dur[\night].wait;
}).play;


// 6) Η function ~stopAll λειτουργεί ως καθολική εντολή διακοπής & συνδυάζει τον τερματισμό του χρονικού σεναρίου (Routine).

~stopAll = {
	"STOP ALL CALLED".postln;

	if(~piece.notNil) { "~piece.stop".postln; ~piece.stop };
	if(~x.notNil and: { ~x.isPlaying }) {
		"FADING OUT".postln;
		~x.set(\ampLag, 2, \amp, 0.0);
	} {
		"~x missing or not playing".postln;
	};
};

// // χρησιμοποιείται μόνο για πλήρη καθαρισμό του server



































s.freeAll;







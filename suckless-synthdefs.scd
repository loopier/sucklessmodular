(
s.waitForBoot {
	SynthDef(\dc, { Out.kr(\out.kr(0), \in.kr(1))}).add;
	SynthDef(\lfnoise0, { Out.kr(\out.kr(0), LFNoise0.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1)))}).add;
	SynthDef(\lfnoise1, { Out.kr(\out.kr(0), LFNoise1.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1)))}).add;
	SynthDef(\lfnoise2, { Out.kr(\out.kr(0), LFNoise2.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1)))}).add;
	SynthDef(\lfpulse, { Out.kr(\out.kr(0), LFPulse.kr(\freq.kr(1)))}).add;
	SynthDef(\lfsaw, { Out.kr(\out.kr(0), LFSaw.kr(\freq.kr(1)))}).add;
	SynthDef(\lftri, { Out.kr(\out.kr(0), LFTri.kr(\freq.kr(1)))}).add;
	SynthDef(\lfosc, { Out.kr(\out.kr(0), SinOsc.kr(\freq.kr(1)))}).add;
	SynthDef(\gverb, { Out.ar(\out.kr(0), GVerb.ar(\in.ar(0), \room.kr(10), \revtime.kr(3), \damp.kr(0.5), mul:\level.kr(1)))}).add;
	SynthDef(\delay, { Out.ar(\out.kr(0), AllpassC.ar(\in.ar(0), 2, \delaytime.kr(0.2), \decaytime.kr(1), mul:\level.kr(1)))}).add;
	SynthDef(\midicps, {Out.kr(\out.kr(0), \in.kr(60).midicps)}).add;
	SynthDef(\out, { Out.ar(\out.kr(0), \in.ar(0))}).add;
	SynthDef(\outs, { Out.ar(\out.kr(0), \in.ar(0!2))}).add;
	SynthDef(\sine, { Out.ar(\out.kr(0), SinOsc.ar(\freq.kr(440), mul:\amp.kr(1)))}).add;
	SynthDef(\saw, { Out.ar(\out.kr(0), Saw.ar(\freq.kr(440), mul:\amp.kr(1)))}).add;
	SynthDef(\pulse, { Out.ar(\out.kr(0), Pulse.ar(\freq.kr(440), mul:\amp.kr(1)))}).add;
	SynthDef(\whitenoise, { Out.ar(\out.kr(0), WhiteNoise.ar(\amp.kr(1))) }).add;
	s.sync;

	"done".postln;

	s.plotTree;
	s.meter(2,4);

	// Loopier.listSynthDefs;
};
)
(
this.preProcessor = { |codeBlock|
	codeBlock.split($\n).collect { |code|
		c = code.split($ );
		if(code.beginsWith("new"), {
			c.scramble.postln;
			"0;"  // you might need a dummy here?
		}, {
			code.replace("(").replace(")");
			"1"
		});
	}
	.join;
};
)
this.preProcessor = nil;
Ndef(\a, \sine).set(\amp, 0.02).play
Ndef(\a).stop
new sin saw
sin freq
Ndef(\b).stop
Ndef(\b) <>> Ndef(\a)
Ndef(\a).play
Ndef(\a).unmap(\in)
Ndef(\a).set(\in, Ndef(\b))
Ndef(\outs).source.postcs
Ndef.all

Ndef(\a).play
Ndef(\a).source.postln
Ndef(\a0.set(\out, 2)
Synth(\sine)

lfp lfpulse
SynthDescLib.global.synthDescs

Loopier
(

SynthDef(\dc, { Out.kr(\out.kr(0), \in.kr(1))}).store;
SynthDef(\lfnoise0, { Out.kr(\out.kr(0), LFNoise0.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1)))}).store;
SynthDef(\lfnoise1, { Out.kr(\out.kr(0), LFNoise1.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1)))}).store;
SynthDef(\lfnoise2, { Out.kr(\out.kr(0), LFNoise2.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1)))}).store;
SynthDef(\lfpulse, { Out.kr(\out.kr(0), LFPulse.kr(\freq.kr(1)))}).store;
SynthDef(\lfsaw, { Out.kr(\out.kr(0), LFSaw.kr(\freq.kr(1)))}).store;
SynthDef(\lftri, { Out.kr(\out.kr(0), LFTri.kr(\freq.kr(1)))}).store;
SynthDef(\lfosc, { Out.kr(\out.kr(0), SinOsc.kr(\freq.kr(1)))}).store;
SynthDef(\gverb, { Out.ar(\out.kr(0), GVerb.ar(\in.ar(0), \room.kr(10), \revtime.kr(3), \damp.kr(0.5), mul:\level.kr(1)))}).store;
SynthDef(\delay, { Out.ar(\out.kr(0), AllpassC.ar(\in.ar(0), 2, \delaytime.kr(0.2), \decaytime.kr(1), mul:\level.kr(1)))}).store;
SynthDef(\midicps, {Out.kr(\out.kr(0), \in.kr(60).midicps)}).store;
SynthDef(\out, { Out.ar(\out.kr(0), \in.ar(0))}).store;
SynthDef(\outs, { Out.ar(\out.kr(0), \in.ar(0!2))}).store;
SynthDef(\sine, { Out.ar(\out.kr(0), SinOsc.ar(\freq.kr(440), mul:\amp.kr(1)))}).store;
SynthDef(\saw, { Out.ar(\out.kr(0), Saw.ar(\freq.kr(440), mul:\amp.kr(1)))}).store;
SynthDef(\pulse, { Out.ar(\out.kr(0), Pulse.ar(\freq.kr(440), mul:\amp.kr(1)))}).store;
SynthDef(\whitenoise, { Out.ar(\out.kr(0), WhiteNoise.ar(\amp.kr(1))) }).store;
SynthDef(\fm7, {
	var sig, env;
	var freq = \freq.kr(440);
	var amp = \amp.kr(1);
	var spread = \spread.kr(0.8);
	var out = \out.kr(0);
	var amps = Array.fill(6, { |i| (\amp++(i+1)).asSymbol.kr(0)});
	var ctls, mods;

	ctls = Array.fill(6, { |i|
		[freq * (\freq++(i+1)).asSymbol.kr(i+1), 0, (\level++(i+1)).asSymbol.kr(1)];
	});

	mods = Array.fill(6, { |i|
		Array.fill(6, { |n| (\mod++(i+1)++(n+1)).asSymbol.kr(0)});
	});

	sig = FM7.ar(ctls, mods) * amps;
	Out.ar(out, Splay.ar(sig * amp, spread));
}).store;

)
(
this.preProcessor = { |codeBlock|
	codeBlock.split($\n).collect { |code|
		var items = code.split($ );
		case
		{code.beginsWith("add")} {
			"Ndef(\\"++items[1]++", \\"++items[2]++");";
		}
		{code.beginsWith("play")} {
			"Ndef(\\"++items[1]++").play;";
		}
		{code.beginsWith("stop")} {
			"Ndef(\\"++items[1]++").stop;";
		}
		{code.beginsWith("clear")} {
			"Ndef(\\"++items[1]++").clear;";
		}
		{true} {
			var name = items[0];
			var param = items[1];
			var value = if ("[a-zA-Z]".matchRegexp(items[2])) {
				"Ndef(\\"++items[2]++")";
			} {
				items[2].asFloat
			};
			"Ndef(\\"++name++").set(\\"++param++", "++value++");";
		};
	}
	.join;
};
)
this.preProcessor = nil;
add fm fm7
add out outs
out in fm
play out
fm amp1 0.1
fm amp2 0.2
add lfp1 lfpulse
fm amp2 lfp1
flp1 freq 2
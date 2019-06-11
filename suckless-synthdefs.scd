(

// SynthDef(\dc, { Out.kr(\out.kr(0), \in.kr(1))}).store;
// SynthDef(\lfnoise0, { Out.kr(\out.kr(0), LFNoise0.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1)))}).store;
// SynthDef(\lfnoise1, { Out.kr(\out.kr(0), LFNoise1.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1)))}).store;
// SynthDef(\lfnoise2, { Out.kr(\out.kr(0), LFNoise2.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1)))}).store;
// SynthDef(\lfpulse, { Out.kr(\out.kr(0), LFPulse.kr(\freq.kr(1)))}).store;
// SynthDef(\lfsaw, { Out.kr(\out.kr(0), LFSaw.kr(\freq.kr(1)))}).store;
// SynthDef(\lftri, { Out.kr(\out.kr(0), LFTri.kr(\freq.kr(1)))}).store;
// SynthDef(\lfosc, { Out.kr(\out.kr(0), SinOsc.kr(\freq.kr(1)))}).store;
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
		// !!! FIXME: Need to change to something more efficient
		{code.beginsWith("lf")} {
			var wave = code.split($ )[0];
			case
			{wave.beginsWith("lfnoise")}{wave = wave.replace("lfnoise", "LFNoise")}
			{wave.beginsWith("lfpulse")}{wave = wave.replace("lfpulse", "LFPulse")}
			{wave.beginsWith("lfsaw")}{wave = wave.replace("lfsaw", "LFSaw")}
			{wave.beginsWith("lftri")}{wave = wave.replace("lftri", "LFTri")}
			{wave.beginsWith("lfsine")}{wave = wave.replace("lfsine", "SinOsc")};
			"Ndef(\\"++items[1]++", {"++wave++".kr(\\freq.kr(1)).range(\\min.kr(0), \\max.kr(1))});";
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
lfpulse p1
p1 max 0.02
fm amp1 p1
lfpulse p2
p2 max 0.02
p2 freq 3
fm amp2 p2
lfsaw s1
s1 freq 0.25
fm mod16 s1
fm freq6 0.25
s2 freq 0.5
fm mod25 s1
fm freq5 0.5
lfnoise0 n1
fm mod11 n1
fm amp1 0.05
add vb gverb
vb in fm
out in vb
clear vb
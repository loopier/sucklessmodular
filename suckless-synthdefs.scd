(
~modules = IdentityDictionary.new;
~modules.put(\dc, { \in.kr(1)});
~modules.put(\lfnoise0, { LFNoise0.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1))});
~modules.put(\lfnoise1, { LFNoise1.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1))});
~modules.put(\lfnoise2, { LFNoise2.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1))});
~modules.put(\lfpulse, { LFPulse.kr(\freq.kr(1))});
~modules.put(\lfsaw, { LFSaw.kr(\freq.kr(1))});
~modules.put(\lftri, { LFTri.kr(\freq.kr(1))});
~modules.put(\lfosc, { SinOsc.kr(\freq.kr(1))});
~modules.put(\gverb, { GVerb.ar(\in.ar(0), \room.kr(10), \revtime.kr(3), \damp.kr(0.5), mul:\level.kr(1))});
~modules.put(\delay, { AllpassC.ar(\in.ar(0), 2, \delaytime.kr(0.2), \decaytime.kr(1), mul:\level.kr(1))});
~modules.put(\midicps, {\in.kr(60).midicps});
~modules.put(\out, { \in.ar(0)});
~modules.put(\outs, { \in.ar(0!2)});
~modules.put(\sine, { SinOsc.ar(\freq.kr(440), mul:\amp.kr(1))});
~modules.put(\saw, { Saw.ar(\freq.kr(440), mul:\amp.kr(1))});
~modules.put(\pulse, { Pulse.ar(\freq.kr(440), mul:\amp.kr(1))});
~modules.put(\whitenoise, { WhiteNoise.ar(\amp.kr(1)) });
~modules.put(\fm7, {
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
});

)
(
this.preProcessor = { |codeBlock|
	codeBlock.split($\n).collect { |code|
		var items = code.split($ );
		case
		{code.beginsWith("add")} {
			~modules.at(items[2].asSymbol).asCompileString.postln;
			"Ndef(\\"++items[1]++", "++~modules.at(items[2].asSymbol).asCompileString++");";
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
add sin sine
add out outs
out in 0
out in 0
play out
add p1 lfpulse
p1 max 0.02
fm amp1 p1
sin amp p1
add p2 lfpulse
p2 max 0.02
p2 freq 3
fm amp2 p2
add s1 lfsaw
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
s.boot.plotTree.meter(2,4);
// p = ProxySpace.new.push;

(
// a stable output location,
// connected (by .play) to the hardware output
Ndef(\outs, { \in.ar(0!2) }).play;
Ndef(\out, { \in.ar(0)!2 }).play;

// modules
Ndef(\fm, {
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
	Splay.ar(sig, spread);
});
Ndef(\dc, {\in.kr(1)});
Ndef(\lfnoise0, {LFNoise0.kr(\freq.kr(1)).range(\rangemin.kr(0), \rangemax.kr(1))});
Ndef(\lfnoise1, {LFNoise1.kr(\freq.kr(1)).range(\rangemin.kr(0), \rangemax.kr(1))});
Ndef(\lfnoise2, {LFNoise2.kr(\freq.kr(1)).range(\rangemin.kr(0), \rangemax.kr(1))});
Ndef(\lfpulse, {LFPulse.kr(\freq.kr(1))});
Ndef(\lfsaw, {LFSaw.kr(\freq.kr(1))});
Ndef(\lftri, {LFTri.kr(\freq.kr(1))});
Ndef(\lfosc, {SinOsc.kr(\freq.kr(1))});
Ndef(\osc, {SinOsc.ar(\freq.ar(440))!2});
Ndef(\gverb, {GVerb.ar(\in.ar(0), \room.kr(10), \revtime.kr(3), \damp.kr(0.5), mul:\level.kr(1))});
Ndef(\delay, {AllpassC.ar(\in.ar(0), 2, \delaytime.kr(0.2), \decaytime.kr(1), mul:\level.kr(1))});

9.do { |i|
	Ndef((\lfn++(i+1)).asSymbol, Ndef(\lfnoise0).source);
	Ndef((\lfn++(i+1)).asSymbol).set(\freq, (i+1));
	Ndef((\lfp++(i+1)).asSymbol, Ndef(\lfpulse).source);
	Ndef((\lfp++(i+1)).asSymbol).set(\freq, (i+1));
	Ndef((\lfs++(i+1)).asSymbol, Ndef(\lfsaw).source);
	Ndef((\lfs++(i+1)).asSymbol).set(\freq, (i+1));
	Ndef((\lft++(i+1)).asSymbol, Ndef(\lftri).source);
	Ndef((\lft++(i+1)).asSymbol).set(\freq, (i+1));
	Ndef((\lfo++(i+1)).asSymbol, Ndef(\lfosc).source);
	Ndef((\lfo++(i+1)).asSymbol).set(\freq, (i+1));
};

/*~cmds = IdentityDictionary.new;
~cmds.put(\build, {|input|
var lists = input.split($, );
// "Building:".postln;
lists.do { |list|
var items = list.stripWhiteSpace.split($ );
if (items.size < 2) {items = items.insert(0, 1)};
items[0].asInt.do { |i|
var name = ("\\"++items[1].copyRange(0,2) ++ (i+1)).asSymbol;
var module = ("\\"++items[1]).asSymbol;
// format("Ndef(%, %)", name, Ndef(module).source).interpretPrint;
Ndef(name, Ndef(module).source);
};
};
});
// ~cmds.put(\listmodules, {~modules.keys.asArray.sort.collect(_.postcs);});
~cmds.put(\boot, {s.boot.plotTree.meter;});
~cmds.put(\out, { |args|
var module = args.split($ )[1].asSymbol;
Ndef(module) <>> Ndef(\out);
[module].postln;
});
~cmds.put(\outs, { |args|
var module = args.split($ )[1].asSymbol;
Ndef(module) <>> Ndef(\outs);
[module].postln;
});*/
)

(
// this.preProcessor = nil;
this.preProcessor = { |code|
	var items = code.split($ );
	var ndef = ("\\"++items[0]).asSymbol;
	var param = ("\\"++items[1]).asSymbol;
	var valueIsFloat = (items[2].asFloat.asBoolean == true);
	var value = if (valueIsFloat) { items[2].asFloat } { ("\\"++items[2]).asSymbol };
	var sccode;
	if (valueIsFloat) {
		sccode = format("Ndef(%).set(%, %)", ndef, param, value);
	} {
		sccode = format("Ndef(%).set(%, Ndef(%))", ndef, param, value);
	};
	sccode.postcs;
	sccode;
};
)
// out in osc
// osc freq 200
out in fm
fm amp1 lfp1
fm amp2 lfp2
fm freq2 2
fm freq5 0.5
fm freq6 0.25
fm mod25 lfn3
lfn3 rangemax 4
fm mod16 lfs1
lfp1 freq 0.5
lfs1 freq 0.5
fm freq 200
gverb in fm
out in gverb
osc
// boot
// build ,os
// build 3 lfnoise0, fm, 4 lfpulse, lfosc, gverb, delay
// fm1 out
// fm1 amp2 1
// lfp4 1.5
// fm1 octave 3
// fm1 deg 0
// fm1 mod16 s3
Ndef(\osc) <>> Ndef(\out)
Ndef(\out).set(\in, Ndef(\osc))
Ndef(\out).set(\in, 0)
// Ndef(\out).unmap(\in)
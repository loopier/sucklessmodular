s.boot.plotTree.meter;
// p = ProxySpace.new.push;

(
// a stable output location,
// connected (by .play) to the hardware output
Ndef(\out, { \in.ar(0!2) }).play;

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
	});
Ndef(\dc, {\in.kr(1)});
Ndef(\lfnoise0, {LFNoise0.kr(\in.kr(1)).range(\rangemin.kr(0), \rangemax.kr(1))});
Ndef(\lfnoise1, {LFNoise1.kr(\in.kr(1)).range(\rangemin.kr(0), \rangemax.kr(1))});
Ndef(\lfnoise2, {LFNoise2.kr(\in.kr(1)).range(\rangemin.kr(0), \rangemax.kr(1))});
Ndef(\lfpulse, {LFPulse.kr(\in.kr(1))});
Ndef(\lfsaw, {LFSaw.kr(\in.kr(1))});
Ndef(\lftri, {LFTri.kr(\in.kr(1))});
Ndef(\lfosc, {SinOsc.kr(\in.kr(1))});
Ndef(\gverb, {GVerb.ar(\in.ar(0), \room.kr(10), \revtime.kr(3), \damp.kr(0.5), mul:\level.kr(1))});
Ndef(\delay, {AllpassC.ar(\in.ar(0), 2, \delaytime.kr(0.2), \decaytime.kr(1), mul:\level.kr(1))});

~cmds = IdentityDictionary.new;
~cmds.put(\build, {|input|
	var lists = input.split($, );
	// "Building:".postln;
	lists.do { |list|
		var items = list.stripWhiteSpace.split($ );
		if (items.size < 2) {items = items.insert(0, 1)};
		items[0].asInt.do { |i|
			var name = (items[1].copyRange(0,2) ++ (i+1)).asSymbol;
			var module = items[1].asSymbol;
			format("Ndef(%, %)", name, Ndef(module).source).postln;
			Ndef(name, Ndef(module).source);
		};
	};
});
// ~cmds.put(\listmodules, {~modules.keys.asArray.sort.collect(_.postcs);});
~cmds.put(\boot, {s.boot.plotTree.meter;});

// ~cmds[\build].value("fm, 3 lfnoise0, 4 lfsaw");
// ~cmds[\listmodules].value;

this.preProcessor = nil;
this.preProcessor = { |code|
	var return;
	var items = code.split($ );
	var symbol = items[0].asSymbol;
	var param = if (items.size > 2) {items[1]} {\in};
	var value = if (items.size > 2) {items[2]} {items[1]};
	var cmd = ~cmds.atFail(symbol) { False };
	// cmd.postcs;
	if (cmd == False) {
		format("Ndef(%).set(%, %)", symbol, param, value).postln;
		Ndef(symbol).set(param, value);
	} {
		cmd.value(code.copyRange(symbol.size, code.size));
	};

	// ["code", code].postln;
	// ["items1", items[1]].postln;
	// ["items", items].postln;
	// [control, controlname, controlugen, valueortarget, isNumber, paramname].postln;
	// ["ndef", ndef].postln;
	// ["param", param].postln;
	// ["value", value].postln;
	// "".postln;
	// return;
	code
};
)
boot
out fm1
build 3 lfnoise0, fm, 4 lfpulse, lfosc, gverb, delay
lfp4 1.5
fm1 amp1 1
fm1 octave 3
fm1 deg 0
fm1 mod16 s3
Ndef(\fm1, \fm)
Ndef(\fm1) <>> Ndef(\out)
~modules[\fm].source
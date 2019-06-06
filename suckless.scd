s.boot.plotTree.meter;
// p = ProxySpace.new.push;

// a stable output location,
// connected (by .play) to the hardware output
Ndef(\out, { \in.ar(0!2) }).play;

// generators
~fm = {
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
};
// inputs
/*~makefm = { |synthname|
	[\freq, \amp, \level, \mod].do { |symbol|
		6.do{ |i|
			if (symbol == \mod) {
				6.do {|n|
					var name = (synthname++symbol++(i+1)++(n+1)).asSymbol.postln;
					Ndef(name, {\in.kr(0)});
					Ndef(synthname.asSymbol).set(name, Ndef(name));
				};
			} {
				var name = (synthname++symbol++(i+1)).asSymbol.postln;
				Ndef(name,  {\in.kr(0)});
				Ndef(synthname.asSymbol).set(name, Ndef(name))
			};
		};
	};
};*/

// module templates
~dc = {1};
~lfnoise0 = {LFNoise0.kr(\in.kr(1)).range(\rangemin.kr(0), \rangemax.kr(1))};
~lfnoise1 = {LFNoise1.kr(\in.kr(1)).range(\rangemin.kr(0), \rangemax.kr(1))};
~lfnoise2 = {LFNoise2.kr(\in.kr(1)).range(\rangemin.kr(0), \rangemax.kr(1))};
~lfpulse = {LFPulse.kr(\in.kr(1))};
~lfsaw = {LFSaw.kr(\in.kr(1))};
~lftri = {LFTri.kr(\in.kr(1))};
~sine = {SinOsc.kr(\in.kr(1))};
~rev = {GVerb.ar(\in.ar(0), \room.kr(10), \revtime.kr(3), \damp.kr(0.5), mul:\level.kr(1))};
~del = {AllpassC.ar(\in.ar(0), 2, \delaytime.kr(0.2), \decaytime.kr(1), mul:\level.kr(1))};

// modulators
// choose the module
// ~makefm.value(\fm1);
Ndef(\fm1, ~fm);
Ndef(\dc1, ~dc);
Ndef(\lfp1, ~lfpulse);
Ndef(\lfp2, ~lfpulse);
Ndef(\rev1, ~rev);
// customize parameters in a given module
Ndef(\lfp1).set(\in, 1);
Ndef(\lfp1).set(\in, 2);
// connect control module 1 output to oscillator module input and oscillator output to out module
Ndef(\dc1) <>> Ndef(\fm1) <>> Ndef(\out);
// connect control module 2 output to oscillator module input
Ndef(\lfp1) <>> Ndef(\fm1);
Ndef(\lfp2) <>> Ndef(\fm1);
// add reverb
Ndef(\fm1) <>> Ndef(\rev1) <>> Ndef(\out);
(
/*
--- DEPRECATED ---
"n1 0.3"
"n1 fm1 m24"
[controlmodule] [value | target]
[target] = [synth] [param]
[param] = [paramname][index]
*/
/*
"n1 2.5"
"fm1 f 60"
"fm1 m24 n1"

ndef [param] value
param = paramname [++ index]
value = [float | ndef]
*/
// returns [paramname, index]
~cmd = ();
~cmd.rosetta = Dictionary.newFrom(List[
	// ugens
	"n", "lfnoise0", // step noise
	"r", "lfnoise1", // ramp noise
	"q", "lfnoise2", // quadratic noise
	"p", "lfpulse", // π
	"s", "lfsaw", // /
	"t", "lftri", // ^
	"o", "sine", // ~
	// "d", "dc",
	// "e", "Env",
	// modifiers
	// "r", "range",
	// params
	"m", "mod", // fm modulator - \mod12 = op1 modulated by op2
	"a", "amp",
	"f", "freq",
	"deg", "degree",
	"octave", "octave",
	"scale", "scale",
]);

~cmd.splitItem = { |self, input|
	var intindex = if (input.findRegexp("[0-9]").size > 0) {input.findRegexp("[0-9]")[0][0]} {input.size};
	// var intindex = "[0-9]".matchRegexp(input);
	var name = input.copyRange(0, intindex-1);
	var number = input.copyRange(intindex,input.size-1);
	// ["intindex", intindex].postln;
	// ["name", name].postln;
	// ["index", index].postln;
	[name, number, intindex]
};

~cmd.paramName = { |self, name|
	// var symbol = ~cmd.rosetta[~cmd.plitItem(name)];
	var items = ~cmd.splitItem(name);
	var  ugen = ~cmd.rosetta[items[0]];
	var number = items.copyRange(1, items.size).asString;
	name = ugen++number;
	[ugen, number];
};

~cmd.process = { |self, input|
	var items = input.split($ );
	var ndef = items[0].asSymbol;
	// var cmd = ~cmd.splitItem(ndef)[0].asString;
	var param = if (not(items[1].asFloat.asBoolean)) {~cmd.paramName(items[1])} {\in};
	var value = if (items[1].asFloat.asBoolean) {items[1].asFloat} {items[2]};
	/*var controlugen = ~cmd.rosetta[controlname];
	var valueortarget = items[1];
	var isNumber = (valueortarget.findRegexpAt("[0-9]") != nil);
	var paramname = nil;
	if (items.size > 2) {
		var param = ~cmd.splitItem(items[2]);
		var paramindex = param[1].asString;
		paramname = ~cmd.rosetta[param[0].asString]++paramindex;
	};

	if (isNumber) {
		"set control".postln;
		["control", control].postln;
		// ["controlugen", controlugen].postln;
		["value", valueortarget.asFloat].postln;
		Ndef(control.asSymbol, controlugen);
		Ndef(control.asSymbol).set(valueortarget);
	} {
		"set synth".postln;
		["target", valueortarget].postln;
		["paramname", paramname].postln;
		["control", control].postln;
		Ndef(valueortarget.asSymbol, ~fm).play;
		Ndef(valueortarget.asSymbol).set(paramname, Ndef(control.asSymbol));
	};*/

	["input", input].postln;
	// ["items1", items[1]].postln;
	// [items].postln;
	// [control, controlname, controlugen, valueortarget, isNumber, paramname].postln;
	["ndef", ndef].postln;
	["param", param].postln;
	["value", value].postln;
	"".postln;
};
~cmd.process("p40 1");
~cmd.process("fm1 a1 p40");
~cmd.process("fm1 f 440");
~cmd.process("fm1 deg 0");
~cmd.process("fm1 mod16 s3");
)
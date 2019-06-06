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
"n1 0.3"
"n1 fm1 m24"
[controlmodule] [value | target]
[target] = [synth] [param]
[param] = [paramname][index]
*/
!!! CHANGE TO [ndef] [param] [value]
[param] = [paramname ++ [index]]
[value] = [float | ndef]
// returns [paramname, index]
~cmd = ();
~cmd.rosetta = Dictionary.newFrom(List[
	// ugens
	"n", ~lfnoise0,
	"p", ~lfpulse,
	"s", ~lfsaw,
	"t", ~lftri,
	"o", ~sine,
	"d", ~dc,
	// "e", "Env",
	// modifiers
	"r", ~range,
	// params
	"m", \mod,
	"a", \amp,
	"f", \freq,
]);
~cmd.splitItem = { |self, input|
	var paramname = input[0];
	var index = input.copyRange(1,input.size-1);
	[paramname, index].postln;
	// [paramname].postln;
};
~cmd.process = { |self, input|
	var items = input.split($ );
	var control = items[0];
	var controlname = ~cmd.splitItem(control)[0].asString;
	var controlugen = ~cmd.rosetta[controlname];
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
	};

	// [input].postln;
	// [items].postln;
	// [control, controlname, controlugen, valueortarget, isNumber, paramname].postln;
	"".postln;
};
// ~cmd.process("n1 fm1 a1");
~cmd.process("p1 1");
~cmd.process("p2 2");
~cmd.process("d 60 fm1 f");
~cmd.process("p1 fm1 a1");
~cmd.process("d1 fm1 f");
~cmd.process("p2 fm1 a2");
Ndef(\fm1).get(\freq, {|f| f.postln});
// ~cmd.process("n1 fm1 m2456");
// input.interpretPrint;
// input.asCompileString;
)
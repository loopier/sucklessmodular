(
~modules = IdentityDictionary.new;
// Module templates - Functions defining modules
~templates = IdentityDictionary.new;
~templates.put(\sine, {SinOsc.ar(\freq.kr(440))});
~templates.put(\saw, {Saw.ar(\freq.kr(440))});
~templates.put(\pulse, {Pulse.ar(\freq.kr(440))});
~templates.put(\dc, {\in.kr(1)});
~templates.put(\lfnoise0, {LFNoise0.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1))});
~templates.put(\lfnoise1, {LFNoise1.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1))});
~templates.put(\lfnoise2, {LFNoise2.kr(\freq.kr(1)).range(\min.kr(0), \max.kr(1))});
~templates.put(\lfpulse, {LFPulse.kr(\freq.kr(1))});
~templates.put(\lfsaw, {LFSaw.kr(\freq.kr(1))});
~templates.put(\lftri, {LFTri.kr(\freq.kr(1))});
~templates.put(\lfosc, {SinOsc.kr(\freq.kr(1))});
~templates.put(\osc, {SinOsc.ar(\freq.ar(440))!2});
~templates.put(\gverb, {GVerb.ar(\in.ar(0), \room.kr(10), \revtime.kr(3), \damp.kr(0.5), mul:\level.kr(1))});
~templates.put(\delay, {AllpassC.ar(\in.ar(0), 2, \delaytime.kr(0.2), \decaytime.kr(1), mul:\level.kr(1))});
~templates.put(\midicps, {\in.kr(60).midicps});

~cmds = IdentityDictionary.new;

~cmds.put(\play, {|args| Ndef(args[0].asSymbol).play});

// args = [name, module]
// name = symbol of the Ndef to be set
// module = template function for the source of the Ndef
~cmds.put(\add, { |args|
	var name = args[1].asSymbol;
	var module = args[0].asSymbol;
	format("Adding module '%' as '%'", module, name).postln;
	~modules.put(name, Ndef(name.asSymbol, ~templates.at(module)));
});
~cmds.put(\post, { |args| args.postln; });
~cmds.put(\source, { |args| Ndef(args[0].asSymbol).source.postcs;});
)
(
// Convert SucklessCollider code to Supercollider code.
// SucklessCollider code may be either a command with some arguments:
// <CMD> [ARGS]
// or a module's parameter being set with either a value or another module.
// <MODULE> <PARAM> <FLOAT | SRCMODULE>
this.preProcessor = { |code|
	try {
		var cmd = code.split($ )[0].asSymbol;
		var args = code.copyRange(code.find(" ")+1, code.size).split($ );
		format("cmd: %\nargs: %", cmd, args).postln;
		if (~modules.includesKey(cmd)) {
			var value = if ("[a-zA-Z]".matchRegexp(args[1])) {
				Ndef(args[1].asSymbol)
			} {
				args[1].asFloat
			};
			code = Ndef(cmd).set(args[0].asSymbol, value);
		};

		if (~cmds.includesKey(cmd)) {
			"cmd".postln;
			code = ~cmds.at(cmd).value(args);
		};
		code.postcs;
		code;
	}
};
)
this.preProcessor = nil
Ndef(\a, {LFPulse.ar}).play
sin
play sin1
sin1 freq lfp1
son1 freq 200
add sine sin1
add osc sin1
add www sin
source sin1
post alo
saw
son
s.reboot
Ndef(\sin).source.postcs
Ndef(\sin, ~templates.at(\sin))
"add sin sin1".copyRange("add sin sin1".find(" "), "add sin sin1".size)
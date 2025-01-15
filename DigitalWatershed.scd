// Run this if your system is running 48kHz sample rate
s.options.sampleRate = 48000;

// Boot the server
s.boot;

(
s.waitForBoot {
    var activeSynths = List.new; // Active synths tracking

    // Define the synth that will be triggered
    SynthDef(\sineNote, { |out = 0, freq = 110, gate = 1|
        var sig, env, amp, reverb;
        // Adjust amplitude based on the number of active synths
        amp = 0.1 / max(activeSynths.size + 1, 1);
        env = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime: 6), gate, doneAction: 2);
        sig = SinOsc.ar(freq, 0) * env * amp;

        // Add simple reverb
        reverb = FreeVerb.ar(sig, mix: 0.5, room: 0.3, damp: 0.9);

        Out.ar(out, reverb ! 2);
    }).add;

    // OSC receiver for Processing messages
    OSCdef(\noteTrigger, { |msg, time, addr, recvPort|
        var noteIndex = msg[1];
        var freq = [65.41, 73.42, 82.41, 98.00, 110.00,
                    130.81, 146.83, 164.81, 196.00, 220.00,
                    261.63, 293.66, 329.63, 392.00, 440.00,
                    523.25, 587.33, 659.25, 783.99, 880.00,
                    1046.50, 1174.66, 1318.51, 1567.98, 1760.00][noteIndex];

        // Create a new synth and add it to the list of active synths
        var newSynth = Synth(\sineNote, [\freq, freq]);
        activeSynths.add(newSynth);
    }, '/triggerNote');

    "Ready to receive OSC messages from Processing.".postln;
}
)

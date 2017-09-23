Flute f => Gain g => JCRev j => dac;

0.3 => g.gain;
0.8 => j.mix;

0.2 => f.vibratoFreq;

[50, 60, 62, 64, 66, 70] @=> int notes[];

while(true){
    f.noteOn(0.1);
    
    int notePicker;
    Math.random2(0,5) => notePicker;
    //Math.random2(600,900) => f.freq;
    
    Std.mtof(notes[notePicker]) => f.freq;
    
    if(Math.random2(0,1)==0){
        for(0 => int i; i < 100; i++){
            f.freq() + Math.random2(-1,1) => f.freq;
            10::ms => now;
        }
    }
    
    1.5::second => dur T;
    T - (now % T) => now;
}
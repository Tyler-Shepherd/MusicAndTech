TriOsc b => Gain g => Envelope e => JCRev j => dac;
    
0.8 => g.gain;
400 => b.freq;

0.2 => j.mix;

0.8 => e.rate;
200::ms => e.duration;

//b.rate(0.2);

while(true){
    e.keyOn();
    200::ms => now;
    e.keyOff();
    
    200::ms => now;
}
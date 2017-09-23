SinOsc s => Gain g => dac;

0.1 => g.gain;

fun void funk(int freq){
    freq => s.freq;
    
    .5::second => dur T;
    T - (now % T) => now;
}

while(true){
    int timer;
    
    spork ~ funk(Math.random2(100,600));

    .5::second => dur T;
    T - (now % T) => now;
}
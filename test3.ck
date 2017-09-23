ModalBar m => Gain g => dac;

0.3 => g.gain;

<<< m.freq() >>>;

m.controlChange(16, 1);
250 => m.freq;
0.4 => m.stickHardness;

while(true){
    int num_strikes;
    
    Math.random2(3,9) => num_strikes;
    
    for(0 => int i; i < num_strikes; i++){
        Math.random2(300,400) => m.freq;
        Math.random2f(0.3,0.8) => m.strike;
        Math.random2(200,1000)::ms => now;
    }
    
    1.5::second => dur T;
    T - (now % T) => now;
}
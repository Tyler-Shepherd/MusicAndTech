Bowed b => Gain g => Envelope e => dac;
    
0.8 => g.gain;
800 => b.freq; //200-800
200 => b.vibratoFreq;

0.2 => e.rate;
2::second => e.duration;

0.6 => b.startBowing;

//b.rate(0.2);

while(true){
    e.keyOn();
    2::second => now;
    e.keyOff();
    
    2::second => now;
}
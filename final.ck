Hid hi;
HidMsg msg;

//this one keeps track of keyboard presses, which are shared globally
//a different shred will determine current bpm using now and last presses
//other shreds use that bpm to make noise

//Possible idea: if at same pace for a while slowly get faster
//   or add more instruments

// Backspace should doh
// Ctrl+s should celebrate
// Numbers should be higher pitched
// Mouse input? -> pans?

// electro-music.com

// Initialize everything

0 => int device;

if (!hi.openKeyboard(device)) me.exit();
    
<<< "keyboard '" + hi.name() + "' ready", "" >>>;

10 => int numRecorded;
time lastPresses[numRecorded];
int lastKeyCodes[numRecorded];
100::ms => dur averageTime;

for(0 => int i; i < numRecorded; i++){
    now => lastPresses[i];
}


// Gets bpm based on last key presses
fun void get_bpm(){
    dur timeBetween[numRecorded];
    
    while(true){
        //get average time between presses
        100::ms => now;
        
        int i;
        for( 0 => i; i < numRecorded - 1; i++ ){
            lastPresses[i+1] - lastPresses[i] => timeBetween[i];
        }
        now - lastPresses[numRecorded-1] => timeBetween[numRecorded-1];
        
        averageTime => dur oldTime;
        
        0::ms => averageTime;
        
        for( 0 => i; i < numRecorded; i++ ){
            averageTime + timeBetween[i] => averageTime;
        }
        
        averageTime / (numRecorded * 0.7) => dur newTime;
        
        if(newTime/ms < 1500){
            newTime => averageTime;
        }
        else{
            oldTime => averageTime;
        }
    }
}

// simple analog-sounding tom-tom with pitch and amp decay and sine overdrive
class kjzTT101
{
   Impulse i; // the attack
   i => Gain g1 => Gain g1_fb => g1 => LPF g1_f => Gain TomFallFreq; // tom decay pitch envelope
   i => Gain g2 => Gain g2_fb => g2 => LPF g2_f; // tom amp envelope
   
   // drum sound oscillator to amp envelope to overdrive to LPF to output
   TomFallFreq => SinOsc s => Gain ampenv => SinOsc s_ws => LPF s_f => Gain output;
   Step BaseFreq => s; // base Tom pitch

   g2_f => ampenv; // amp envelope of the drum sound
   3 => ampenv.op; // set ampenv a multiplier
   1 => s_ws.sync; // prepare the SinOsc to be used as a waveshaper for overdrive
   
   // set default
   100.0 => BaseFreq.next;
   50.0 => TomFallFreq.gain; // tom initial pitch: 80 hz
   1.0 - 1.0 / 4000 => g1_fb.gain; // tom pitch decay
   g1_f.set(100, 1); // set tom pitch attack
   1.0 - 1.0 / 4000 => g2_fb.gain; // tom amp decay
   g2_f.set(50, 1); // set tomD amp attack
   .5 => ampenv.gain; // overdrive gain
   s_f.set(1000, 1); // set tom lowpass filter
   
   fun void hit(float v)
   {
      v => i.next;
   }
   fun void setBaseFreq(float f)
   {
      f => BaseFreq.next;
   }   
   fun void setFreq(float f)
   {
      f => TomFallFreq.gain;
   }
   fun void setPitchDecay(float f)
   {
      f => g1_fb.gain;
   }
   fun void setPitchAttack(float f)
   {
      f => g1_f.freq;
   }
   fun void setDecay(float f)
   {
      f => g2_fb.gain;
   }
   fun void setAttack(float f)
   {
      f => g2_f.freq;
   }
   fun void setDriveGain(float g)
   {
      g => ampenv.gain;
   }
   fun void setFilter(float f)
   {
      f => s_f.freq;
   }
}

fun void work_drums(){
    kjzTT101 D;
    D.output => Gain g => dac;
    
    0.4 => g.gain;
    1 => int lastInstrument;
    
    while(true){
        averageTime / ms => float convertedTime;
        
        if(convertedTime > 1000){
            0.3 => g.gain;
        }
        else{
            0.6 => g.gain;
        }
        
        if(lastInstrument >= 1){
            D.setBaseFreq(Math.random2(50,100));
            D.hit(Math.random2f(0.3,0.8));
            lastInstrument++;
            if(lastInstrument==5){
                0 => lastInstrument;
            }
            else if(Math.random2(0,5-lastInstrument)==0){
                0 => lastInstrument;
            }
        }
        else{
            D.setBaseFreq(Math.random2(350,400));
            D.hit(Math.random2f(0.3,0.8));
            lastInstrument++;
        }
        
        averageTime => dur T;
        
        if(T - (now % T) < 1::ms){ //Weird error that I don't understand
            averageTime => now;
        }
        else{
            T - (now % T) => now;
        }
    }
}

fun void work_shakers(){
    Shakers shake => JCRev r => dac;
    
    0.95 => r.gain;
    0.025 => r.mix;
    
    while(true){
        Math.random2(0,22) => shake.which;
        Std.mtof(Math.random2f(0,128)) => shake.freq;
        Math.random2f(0,128) => shake.objects;
        
        Math.random2(0,20) => int toPlay;
        
        if(toPlay==0){
            Math.random2f(0.8, 1.3) => shake.noteOn;
        }
        else if(toPlay==1){
            Math.random2f(0,100)::ms => now;
            Math.random2f(0.8, 1.3) => shake.noteOn;
        }
        
        averageTime => dur T;
        
        if(T - (now % T) < 1::ms){
            averageTime => now;
        }
        else{
            T - (now % T) => now;
        }
    }
}

fun void work_sitar(){
    Mandolin s => PRCRev r => Gain g => dac;
    
    0.8 => g.gain;
    0.05 => r.mix;
    
    while(true){
        Math.random2(0, 11) => float winner;
        Std.mtof(57 + Math.random2(0,3)*12 + winner) => s.freq;
        
        averageTime / ms => float convertedTime;
        
        if(convertedTime > 1000){
            0.3 => r.mix;
            if(Math.random2(0,3)==0){
                Math.random2f(0.4,0.9) => s.noteOn;
            }
        }
        else if(Math.random2(0,15)==0){
            0.05 => r.mix;
            Math.random2(4,20) => int numRepeat;
            
            Math.random2(0,3)*12 => int octave;
            for(0 => int i; i < numRepeat; i++){
                Math.random2(0, 11) => winner;
                Std.mtof(57 + octave + winner) => s.freq;
                Math.random2f(0.4,0.9) => s.noteOn;
                if(Math.random2(0,4)==0){
                    averageTime/6 => now;
                }
                else{
                    averageTime/3 => now;
                }
            }
        }
        
        averageTime => dur T;
        
        if(T - (now % T) < 1::ms){
            averageTime => now;
        }
        else{
            T - (now % T) => now;
        }
    }
}

fun void work_sin(){
    SinOsc s => Echo e => Gain g => dac;
    
    0.1 => g.gain;
    200 => s.freq;
    1800::ms => e.delay;
    
    1 => int rampDirection;
    
    while(true){
        
        averageTime / ms => float convertedAvg;
        convertedAvg / 3000 => float newGain;
        
        if(newGain <= 0.5){
            newGain => g.gain;
        }
        
        if(Math.random2(0,100) < 5){
            rampDirection * -1 => rampDirection;
        }
        
        if(rampDirection == 1){
            s.freq() + Math.random2(0,3) => s.freq;
        }
        else{
            s.freq() - Math.random2(0,3) => s.freq;
        }
        
        if(s.freq() < 100){
            1 => rampDirection;
        }
        if(s.freq() > 800){
            -1 => rampDirection;
        }
        
        
        if(convertedAvg > 800){
            10::ms => now;
        }
        else{
            1000::ms => now;
        }
    }
}

fun void work_strings(){
    Bowed b => Gain g => Envelope e => dac;
    
    0.9 => g.gain;
    800 => b.freq; //200-800
    200 => b.vibratoFreq;
    
    0.2 => e.rate;
    2::second => e.duration;

    0.6 => b.startBowing;
    
    while(true){
        averageTime / ms => float convertedTime;
        
        if(convertedTime > 800){
            if(Math.random2(0,10)==0){
                <<< "go for it!" >>>;
                Math.random2(200,800) => b.freq;
                
                e.keyOn();
                2::second => now;
                e.keyOff();
            }
        }
        
        averageTime => dur T;
        
        if(T - (now % T) < 1::ms){
            averageTime => now;
        }
        else{
            T - (now % T) => now;
        }
    }
}

fun void work_doh(){
    SndBuf buf => dac;     
    "special:dope" => buf.read;
    
    0.8 => buf.gain;
    0 => buf.pos;    
    1::second => now;
}

fun void work_cheer(){
    me.sourceDir() + "./cheer.wav" => string filename;
    SndBuf buf => dac;
    
    filename => buf.read;
    
    0 => buf.pos;
    0.8 => buf.gain;
    
    5::second => now;
}

spork ~ get_bpm();
spork ~ work_drums();
spork ~ work_shakers();
spork ~ work_sitar();
spork ~ work_sin();
spork ~ work_strings();

// Gets key presses
while(true){
    hi => now;
    
    while(hi.recv(msg)){
        if(msg.isButtonDown()){
            <<< "down:", msg.which, "(code)", msg.key, "(usb key)", msg.ascii, "(ascii)" >>>;
            
            for(1 => int i; i < numRecorded; i++){
                lastPresses[i] => lastPresses[i-1];
                lastKeyCodes[i] => lastKeyCodes[i-1];
            }
            
            if(msg.which == 29){
                hi => now;
                while(hi.recv(msg)){
                    <<< msg.which >>>;
                    if(msg.which == 31){
                        spork ~ work_cheer();
                    }
                    if(msg.which == 29){
                        break;
                    }
                }
            }
            else if(msg.which == 14){
                if(Math.random2(0,5)==0){
                    spork ~ work_doh();
                }
            }
            
            now => lastPresses[numRecorded-1];
            msg.key => lastKeyCodes[numRecorded-1];
            
        }
        else{
            //<<< "up:", msg.which, "(code)", msg.key, "(usb key)", msg.ascii, "(ascii)" >>>;
        }
    }
}
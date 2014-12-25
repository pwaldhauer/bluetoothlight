var NUMBER_OF_LEDS = 25;

// Make bluetooth work when plugged to wall plug
function onInit() {
  if(process.env['CONSOLE'] != 'USB') {
    LoopbackA.setConsole();
  }
}

// Initialize bluetooth stuff
Serial1.setup(9600);
Serial1.on('data', function (data) {
  for (var i = 0; i < data.length; ++i) {
    addByte(data.charCodeAt(i));
  }
});

// Initialize LED connection

SPI2.setup({baud:3200000, mosi:B15});

// Light up each led when starting
var leds = new Uint8Array(NUMBER_OF_LEDS*3);

var n = 0;
for(var i=0; i<NUMBER_OF_LEDS; i++) {
  leds[n++] = 2;
  leds[n++] = 0;
  leds[n++] = 0;
  
  SPI2.send4bit(leds, 0b0001, 0b0011);
}

// Main logic
var stateWaiting = "WAITING";
var stateReceiving = "RECEIVING";

var state = stateWaiting;
var buffer = [];

var pos = 0;
var currentPattern = 0;
var patterns = [];
var ANIMATION_STARTED = false;

function doLights() {
  if(!ANIMATION_STARTED) {
    return;
  }
  
  leds = patterns[currentPattern]();
  SPI2.send4bit(leds, 0b0001, 0b0011);
}


setInterval(doLights,50);

// code zum auslesen
function addByte(byte) {
//  console.log(byte);
  
  if(byte == 129 && state == stateWaiting) {
    console.log('changing pattern');
    currentPattern = (currentPattern+1) % patterns.length;
    ANIMATION_STARTED = true;
    console.log('Starting animation');
  
    return;
  }

    if(byte == 131 && state == stateWaiting) {
    ANIMATION_STARTED = false;
    console.log('Stopping animation');
  
    return;
  }


  if(byte == 127 && state == stateWaiting) {
    console.log("changing state to receiving");

    state = stateReceiving;
    buffer =  [];
    return;
  }

   if(byte == 127 && state == stateReceiving && buffer.length >= 4) {
     console.log("changing state to waiting");

    state = stateWaiting;
     // Reset all.
     if(buffer[0] == 255) {
        var n = 0;
        for(var i=0; i<NUMBER_OF_LEDS; i++) {
          leds[n++] = buffer[1];
          leds[n++] = buffer[2];
          leds[n++] = buffer[3];
        }
       
       return;
     }

     
     var id = buffer[0]*3;
     leds[id] = buffer[1];
     leds[id+1] = buffer[2];
     leds[id+2] = buffer[3];

     buffer = [];
     
     return;
  } 
  
  if(byte == 130 && state == stateWaiting) {
 
    console.log("Setting leds!! ");
    SPI2.send4bit(leds, 0b0001, 0b0011);
    return;
  }
  
  buffer.push(byte);

  
  
}



patterns.push(function() {
  var rgb = new Uint8Array(NUMBER_OF_LEDS*3);
  pos++;
  for (var i=0;i<rgb.length;i+=3) {
     var col = (Math.sin(i+pos*0.2)+1) * 127;
     rgb[i  ] = col;
     rgb[i+1] = col;
     rgb[i+2] = col;
  }
  
  return rgb;
});

patterns.push(function() {
  var rgb = new Uint8Array(NUMBER_OF_LEDS*3);
  pos++;
  for (var i=0;i<rgb.length;i+=3) {
     rgb[i  ] = (1 + Math.sin((i+pos)*0.1324)) * 127;
     rgb[i+1] = (1 + Math.sin((i+pos)*0.1654)) * 127;
     rgb[i+2] = (1 + Math.sin((i+pos)*0.1)) * 127;
  }
  return rgb;
});

patterns.push(function() {
  var rgb = new Uint8Array(NUMBER_OF_LEDS*3);
  for (var i=0;i<rgb.length;i+=3) {
     rgb[i  ] = 0;
     rgb[i+1] = 0;
     rgb[i+2] = Math.random()*255;
  }
  return rgb;
});


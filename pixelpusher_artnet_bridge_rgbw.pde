import ch.bildspur.artnet.*;
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;

DeviceRegistry registry;

// Set up to receive artnet data
ArtNetClient artnet;
byte[] dmxData = new byte[512];

// Get info from the Pixelpusher
class TestObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
        println("Registry changed!");
        if (updatedDevice != null) {
          println("Device change: " + updatedDevice);
        }
        this.hasStrips = true;
    }
}

// Set up an array to save the info received from artnet
Rgbw[] rgbws;

TestObserver testObserver;

void setup()
{
  size(500, 250);
  textAlign(CENTER, CENTER);
  textSize(20);

  // create artnet client
  artnet = new ArtNetClient();
  artnet.start();
  
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  
  // Right now this array holds 128 rgbw pixels, as this is one DMX universe worth (128 x 4 = 512)
  rgbws = new Rgbw[128];
  for (int i=0; i<128; i++){
     rgbws[i] = new Rgbw(0,0,0,0);     
  }
}

void draw()
{
  fill(255);
  rect(0,0,width,height);
  
  
  // read rgb color from the first 3 bytes
  byte[] data = artnet.readDmxData(0, 0);
  
  // save the info from the artnet readout to the array of rgbws
  for (int i=0; i<125; i++){
    int r = data[i*4]& 0xFF;
    int g = data[i*4 + 1]& 0xFF;
    int b = data[i*4 + 2]& 0xFF;
    int w = data[i*4 + 3]& 0xFF;
    
    rgbws[i].update(r,g,b,w);
  }
  
   if (testObserver.hasStrips) {
        registry.startPushing();
        registry.setAutoThrottle(true);
        registry.setAntiLog(true);
        int stripy = 0;
        List<Strip> strips = registry.getStrips();
        
        // There's some looping here to deal with if there are more than one strip but actually this is currently only set up to 
        // work with one, will expand later.
        if (strips.size() > 0) {
          int yscale = height / strips.size();
          for(Strip strip : strips) {
            int xscale = width / strip.getLength();
            
            int stripLength = strip.getLength(); 
             
            // Goes through the whole strip setting the colours, in sets of 4 rgb pixels 
            // as that is how many it takes to repeat the rgbw pattern.
            // This covers 3 actual rgbw pixels.
            for (int i=0; i<stripLength; i+=4) {
              strip.setPixel(color(rgbws[i+0].r, rgbws[i+0].g, rgbws[i+0].b), i);
              strip.setPixel(color(rgbws[i+1].g, rgbws[i+0].w, rgbws[i+1].r), i+1);
              strip.setPixel(color(rgbws[i+1].w, rgbws[i+1].b, rgbws[i+2].g), i+2);
              strip.setPixel(color(rgbws[i+2].b, rgbws[i+2].r, rgbws[i+2].w), i+3);
              stripy++;
            }      
          }
        }
        
    }
    
      // show values for the first 4 rgbw pixels, useful for testing/troubleshooting
    fill(0);
    text("R: " + rgbws[0].r + " Green: " + rgbws[0].g + " Blue: " + rgbws[0].b + " White: " + rgbws[0].w, width / 2, height / 2-20);
    text("R: " + rgbws[1].r + " Green: " + rgbws[1].g + " Blue: " + rgbws[1].b + " White: " + rgbws[1].w, width / 2, height / 2);
    text("R: " + rgbws[2].r + " Green: " + rgbws[2].g + " Blue: " + rgbws[2].b + " White: " + rgbws[2].w, width / 2, height / 2+20);
    text("R: " + rgbws[3].r + " Green: " + rgbws[3].g + " Blue: " + rgbws[3].b + " White: " + rgbws[3].w, width / 2, height / 2+40);



}

// I dunno some exit handler stuff from pixelpusher. 
private void prepareExitHandler () {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run () {
      System.out.println("Shutdown hook running");
      List<Strip> strips = registry.getStrips();
      for (Strip strip : strips) {
        for (int i=0; i<strip.getLength (); i++)
          strip.setPixel(#000000, i);
      }
      for (int i=0; i<100000; i++)
        Thread.yield();
    }
  }
  ));
}

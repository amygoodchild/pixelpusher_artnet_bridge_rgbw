import ch.bildspur.artnet.*;
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;

DeviceRegistry registry;
TestObserver testObserver;

// Set up to receive artnet data
ArtNetClient artnet;

int totalStrips = 6;

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

// Set up an array of PixelPushers
Pixelpusher[] pixelpushers;
int numPixelPushers = 3;



void setup()
{
  size(500, 800);
  textAlign(CENTER, CENTER);
  textSize(20);

  // create artnet client
  artnet = new ArtNetClient();
  artnet.start();
  
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);

  pixelpushers = new Pixelpusher[numPixelPushers];
  
  pixelpushers[0] = new Pixelpusher(2,1);
  pixelpushers[1] = new Pixelpusher(2,2);
  pixelpushers[2] = new Pixelpusher(2,3);
     
}

void draw()
{
  fill(255);
  rect(0,0,width,height);

  readData();
  //setBlank();
  drawData();
  writeLeds();
  
  
}

void writeLeds(){
  
   if (testObserver.hasStrips) {
        registry.startPushing();
        registry.setAutoThrottle(true);
        registry.setAntiLog(true);
        List<Strip> strips = registry.getStrips();
        
        if (strips.size() > 0) {
          int pp = 0;
          int s = 0;
          for(Strip strip : strips) {   
            
            int stripLength = strip.getLength(); 
            //println("strip: " + strip.getStripIdentifier());
            // Goes through the whole strip setting the colours, in sets of 4 rgb pixels 
            // as that is how many it takes to repeat the rgbw pattern.
            // This covers 3 actual rgbw pixels.
            int theSet = 0;
            for (int i=0; i<stripLength; i+=4) {
              int a = i-theSet;
              int b = i-theSet+1;
              int c = i-theSet+2;
              strip.setPixel(color(pixelpushers[pp].strips[s].rgbws[a].r, pixelpushers[pp].strips[s].rgbws[a].g, pixelpushers[pp].strips[s].rgbws[a].b), i);
              strip.setPixel(color(pixelpushers[pp].strips[s].rgbws[b].g, pixelpushers[pp].strips[s].rgbws[a].w, pixelpushers[pp].strips[s].rgbws[b].r), i+1);
              strip.setPixel(color(pixelpushers[pp].strips[s].rgbws[b].w, pixelpushers[pp].strips[s].rgbws[b].b, pixelpushers[pp].strips[s].rgbws[c].g), i+2);
              strip.setPixel(color(pixelpushers[pp].strips[s].rgbws[c].b, pixelpushers[pp].strips[s].rgbws[c].r, pixelpushers[pp].strips[s].rgbws[c].w), i+3);
              theSet++;
            }   
            println("pp: " + pp + " s: " + s);
            if (s == 0){
              s++;
            }
            else{
              pp++;
              s = 0;
            }
          }
        }
        
   }
}

void setBlank(){
  for (int j = 0; j<numPixelPushers; j++){
    for (int k = 0; k<pixelpushers[j].numStrips; k++){
      int universe = j*4 + k*2;
      byte[] data = artnet.readDmxData(0, universe);
      int datacount = 0;
      for (int i=0; i<128; i++){
        int r = 0;
        int g = 0;
        int b = 0;
        int w = 0;
        pixelpushers[j].strips[k].rgbws[i].update(r,g,b,w);  
        datacount += 4;
        
        //println("Pixelpusher: " + j + " strip: " + k + " pixel: " + i + " universe: " + universe + " (section 1)");
      }
      datacount = 0;
      universe+=1;
      data = artnet.readDmxData(0, universe);
      for (int i=128; i<144; i++){
        int r = 0;
        int g = 0;
        int b = 0;
        int w = 0;
        pixelpushers[j].strips[k].rgbws[i].update(r,g,b,w);  
        datacount += 4;
        
        //println("Pixelpusher: " + j + " strip: " + k + " pixel: " + i + " universe: " + universe + " (section 2)");
      }
    }
  } 
  
}


void readData(){
  for (int j = 0; j<numPixelPushers; j++){
    for (int k = 0; k<pixelpushers[j].numStrips; k++){
      int universe = j*4 + k*2;
      byte[] data = artnet.readDmxData(0, universe);
      int datacount = 0;
      for (int i=0; i<128; i++){
        int r = data[datacount]& 0xFF;
        int g = data[datacount + 1]& 0xFF;
        int b = data[datacount + 2]& 0xFF;
        int w = data[datacount + 3]& 0xFF;
        pixelpushers[j].strips[k].rgbws[i].update(r,g,b,w);  
        datacount += 4;
        
        //println("Pixelpusher: " + j + " strip: " + k + " pixel: " + i + " universe: " + universe + " (section 1)");
      }
      datacount = 0;
      universe+=1;
      data = artnet.readDmxData(0, universe);
      for (int i=128; i<144; i++){
        int r = data[datacount]& 0xFF;
        int g = data[datacount + 1]& 0xFF;
        int b = data[datacount + 2]& 0xFF;
        int w = data[datacount + 3]& 0xFF;
        pixelpushers[j].strips[k].rgbws[i].update(r,g,b,w);  
        datacount += 4;
        
        //println("Pixelpusher: " + j + " strip: " + k + " pixel: " + i + " universe: " + universe + " (section 2)");
      }
    }
  } 
}

void drawData(){
  for (int j = 0; j<numPixelPushers; j++){
    for (int k = 0; k<pixelpushers[j].numStrips; k++){
      for (int i=0; i<128; i++){
        pixelpushers[j].strips[k].rgbws[i].display();
      }
    }
  }
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

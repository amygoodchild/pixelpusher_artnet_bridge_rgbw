
class PPStrip{
  
  int numPixels = 144;
  int numFakePixels = 144/3*4;
  Rgbw[] rgbws;
  int stripNumber;
  int x;
    
    
  PPStrip(int stripNumber_, int x_){
    rgbws = new Rgbw[numPixels];
    stripNumber = stripNumber_;
    x = x_;
    
    for (int i=0; i<numPixels; i++){
      int y = ((height-200)/numPixels) * i + 50;
      rgbws[i] = new Rgbw(0,0,0,0,x,y); 
      //println("strip: " + stripNumber + " i: " + i + " x: " + x + " y: " + y);
    }
  }
  
  void update(){
    
  }

}

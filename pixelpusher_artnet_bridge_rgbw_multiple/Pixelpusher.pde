class Pixelpusher{
  
  int numStrips;
  int group;
  
  PPStrip[] strips;
   
  Pixelpusher(int numStrips_, int group_){  
    numStrips = numStrips_;
    group = group_;
    strips = new PPStrip[numStrips];
    
    for (int i=0; i<numStrips; i++){
      int x = ((width-200)/6) * (group*2 + i) + 50;
      println("i: " + i + " x: " + x);
      strips[i] = new PPStrip(i,x);     
    }
  }
  
  void update(){
    
  }

}

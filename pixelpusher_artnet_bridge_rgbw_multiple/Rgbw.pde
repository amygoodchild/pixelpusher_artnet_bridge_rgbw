
class Rgbw{
  
  float r;
  float g;
  float b;
  float w;
  float x;
  float y;
    
  Rgbw(float r_, float g_, float b_, float w_, float x_, float y_){
    r = r_;
    g = g_;
    b = b_;
    w = w_;
    x = x_;
    y = y_;
  }
  
  void update(float r_, float g_, float b_, float w_){
    r = r_;
    g = g_;
    b = b_;
    w = w_; 
  }
  
  void display(){
    
   fill(r,g,b);
   stroke(0,0,0);
   rect(x,y,5,5);
  }

}

import codeanticode.syphon.*;
import controlP5.*;
import de.looksgood.ani.*;
import oscP5.*;
import netP5.*;
import processing.net.*;

String[] types = {"ring_out", "ring_in", "line_ltr", "line_rtl", "line_ttb", "line_btt"};
OscP5 oscP5;
Slider s1, s2;
Numberbox n1, n2, n3, n4;
Toggle t1;
CallbackListener cb;
Bang ipUpdateBang, sWadd, sWsub, sHadd, sHsub;
String ipAdress;

ControlP5 cp5;

Server localServer;

PGraphics syphon;
SyphonServer server;
boolean resizeIO;
int syphonW, syphonH, sW, sH, linewidth;
float speed;
int easing;

ArrayList<Animation> animations = new ArrayList<Animation>();

PImage logo;
int logotint = 10;

void settings() {
  size(400, 600, P3D);
  PJOGL.profile=1;
}

void setup() {
  logo = loadImage("svesketrigger.png");
  Ani.init(this);
  Ani.setDefaultEasing(Ani.LINEAR);

  controlSetup();
  oscP5 = new OscP5(this, 9999);

  syphon = createGraphics(syphonW, syphonH, P3D);
  server = new SyphonServer(this, "svesketrigger syphon");
  smooth();
}

void draw() {
  background(127);
  if (mouseX > 335 && mouseX < 365 && mouseY > 10 && mouseY <40) {
    logotint = 180;
  }
  else {
    logotint = 10;
  }
  tint(logotint);
  image(logo, 335, 10, 30, 30);
    tint(255);
  if (resizeIO) {
    cp5.getController("syphonW").setLock(false);
    cp5.getController("syphonH").setLock(false);
    resizeSyphonToWindow();
  } else {
    cp5.getController("syphonW").setLock(true);
    cp5.getController("syphonH").setLock(true);
  }
  syphon.beginDraw();
  syphon.background(0);
  syphon.endDraw();

  for (int i = animations.size() - 1; i >= 0; i--) {
    Animation a = animations.get(i);
    if (!a.active) {
      animations.remove(i);
    } else { 
      a.update();
    }
  }

  image(syphon, (width/2)-(sW/2), 100+(width/2)-(sH/2), sW, sH);
  server.sendImage(syphon);
}

public void newSyphon() {
  PGraphics s = createGraphics(syphonW, syphonH, P3D);
  syphon = s;
}

void resizeSyphonToWindow() {
  int max = width-20;
  float tW, tH;
  if (syphonW > syphonH) {
    tW = max;
    tH = (tW/syphonW)*syphonH;
  } else {
    tH = max;
    tW = (tH/syphonH)*syphonW;
  }
  sW = ceil(tW);
  sH = ceil(tH);

  // add nice dark grey area
  fill(100);
  noStroke();
  rectMode(CENTER);
  rect(200, 300, 380, 380);
}
//filter osc messages and pass trigger through to chooseAnimation()
void oscEvent(OscMessage theOscMessage) {
  String str_in[] = split(theOscMessage.addrPattern(), '/');
  if (str_in[1].equals("svesketrigger")) {
    if (str_in[2].equals("linewidth") && theOscMessage.checkTypetag("f")) {
      float value = theOscMessage.get(0).floatValue();
      float max = cp5.getController("linewidth").getMax();
      cp5.getController("linewidth").setValue(value*max);
    } else if (str_in[2].equals("speed") && theOscMessage.checkTypetag("f")) {
      float value = theOscMessage.get(0).floatValue();
      float max = cp5.getController("speed").getMax();
      cp5.getController("speed").setValue(value*max);
    } else {
      chooseAnimation(str_in[2]);
    }
  }
}

// filter incoming triggers from osc and cp5
void chooseAnimation(String type) {
  for (String t : types) {
    if (type.equals(t) == true) {
      animations.add(new Animation(t, speed, .0, 1.));
      return;
    }
  }
}

void makeOSC() {  
  int p1 = (int)cp5.getController("n1").getValue();
  int p2 = (int)cp5.getController("n2").getValue();
  int p3 = (int)cp5.getController("n3").getValue();
  int p4 = (int)cp5.getController("n4").getValue();
  oscP5 = new OscP5(this, p1*1000 + p2*100 + p3*10 + p4);
}

void updateIP() {
  ipAdress = Server.ip();
  cp5.getController("ipUpdateBang").setLabel("local IP is: " + ipAdress);
}


void mousePressed() { 
  if (mouseX > 335 && mouseX < 365 && mouseY > 10 && mouseY <40) {
    link("http://sveskenielsen.dk/");
  }
}
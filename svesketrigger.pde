import codeanticode.syphon.*;
import controlP5.*;
import de.looksgood.ani.*;
import oscP5.*;
import netP5.*;
import processing.net.*;

String[] triggers = {"ring_out", "ring_in", "line_ltr", "line_rtl", "line_ttb", "line_btt"};
String[] eases = {"LINEAR", "EASE IN", "EASE OUT", "EASE IN_OUT"};
int[] size_presets = {480, 640, 720, 800, 1024, 1200, 1920};

OscP5 oscP5;
Slider slider_s_w, slider_s_h;
Numberbox n1, n2, n3, n4;
Toggle toggle_resize_lock;
Bang bang_update_ip, bang_s_w_add, bang_s_w_sub, bang_s_h_add, bang_s_h_sub;
CallbackListener cb;
RadioButton radio_w_presets, radio_h_presets, radio_eases;

String ipAdress;

ControlP5 cp5;

Server localServer;

PGraphics canvas;
SyphonServer server;
boolean bool_resize_lock;
int canvas_width, canvas_height, sW, sH, linewidth;
float speed;
int easing;

PShader rings;

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

  canvas = createGraphics(canvas_width, canvas_height, P3D);
  server = new SyphonServer(this, "svesketrigger");
  smooth();

  rings = loadShader("data/rings.glsl");
  rings.set("resolution", float(canvas_width), float(canvas_height));
}

void draw() {
  if (keyPressed && keyCode=='p') println(mouseX + " " + mouseY);
  background(127);
  if (mouseX > 335 && mouseX < 365 && mouseY > 10 && mouseY <40) {
    logotint = 180;
  }
  else {
    logotint = 10;
  }
  tint(logotint);
  image(logo, 345, 10, 30, 30);
  tint(255);
  if (bool_resize_lock) {
    cp5.getController("canvas_width").setLock(false);
    cp5.getController("canvas_height").setLock(false);
    resizeSyphonToWindow();
  } else {
    cp5.getController("canvas_width").setLock(true);
    cp5.getController("canvas_height").setLock(true);
  }
  canvas.beginDraw();
  canvas.background(0);


  for (int i = animations.size() - 1; i >= 0; i--) {
    canvas.noFill();
    canvas.stroke(255);
    Animation a = animations.get(i);
    if (!a.active) {
      animations.remove(i);
    } else {
      a.update();
      if (i == 0) {
        rings.set("nf", a.progress);
        canvas.shader(rings);
        canvas.rect(0,0, canvas_width, canvas_height);
      }
    }
  }
  canvas.endDraw();
  image(canvas, (width/2)-(sW/2), 100+(width/2)-(sH/2), sW, sH);
  server.sendImage(canvas);
}

public void createCanvas() {
  PGraphics temp_canvas = createGraphics(canvas_width, canvas_height, P3D);
  canvas = temp_canvas;
  rings.set("resolution", float(canvas_width), float(canvas_height));
}

void resizeSyphonToWindow() {
  int max = width-20;
  float tW, tH;
  if (canvas_width > canvas_height) {
    tW = max;
    tH = (tW/canvas_width)*canvas_height;
  } else {
    tH = max;
    tW = (tH/canvas_height)*canvas_width;
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
  for (String t : triggers) {
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
  cp5.getController("bang_update_ip").setLabel("local IP is: " + ipAdress);
}


void mousePressed() {
  if (mouseX > 335 && mouseX < 365 && mouseY > 10 && mouseY <40) {
    link("http://sveskenielsen.dk/");
  }
}

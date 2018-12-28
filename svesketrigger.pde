import codeanticode.syphon.*;
import controlP5.*;
import de.looksgood.ani.*;
import oscP5.*;
import netP5.*;
import processing.net.*;

String[] eases = {"LINEAR", "EASE IN", "EASE OUT", "EASE IN_OUT"};
int[] size_presets = {480, 576, 640, 720, 768, 960, 1024, 1280, 1440, 1920};

ControlP5 cp5;
CallbackListener cb;

int triggerID = 0;
int easesID = 1;
int settingsID = 2;
Slider slider_c_w, slider_c_h;
Numberbox n1, n2, n3, n4;
Bang bang_logo, bang_update_ip, bang_c_w_add, bang_c_w_sub, bang_s_h_add, bang_s_h_sub;
RadioButton radio_w_presets, radio_h_presets, radio_eases;
Textfield field_port, field_syphon_name;

OscP5 oscP5;
Server localServer;
String ip;
int port = 9999;

PGraphics canvas;
SyphonServer server;
String syphon_name = "svesketrigger";
boolean bool_resize_lock;
int canvas_width, canvas_height, sW, sH;
int easing;

PImage logo;
int logotint = 10;

int n = 50;
int a_n; //current amount of graphics in action
PShader shader;
ArrayList<Graphic> graphics = new ArrayList<Graphic>();
Animation inactive = new Animation("inactive", 0.);
Animation line_ttb = new Animation("line_ttb", 1., 1., 0.);
Animation line_btt = new Animation("line_btt", 1., 0., 1.);
Animation line_rtl = new Animation("line_rtl", 2., 1., 0.);
Animation line_ltr = new Animation("line_ltr", 2., 0., 1.);
Animation ring_out = new Animation("ring_out", 3., 0., 1.);
Animation ring_in = new Animation("ring_in", 3., 1., 0.);
Animation[] animations = {inactive, ring_out, ring_in, line_rtl, line_ltr, line_ttb, line_btt};

float speed =.1, linewidth =.1, bleed = 0.1;

void settings() {
  size(400, 600, P3D);
  //PJOGL.profile=1;
}

void setup() {
  logo = loadImage("svesketrigger.png");
  Ani.init(this);
  Ani.setDefaultEasing(Ani.LINEAR);

  controlSetup();
  oscP5 = new OscP5(this, port);

  canvas = createGraphics(canvas_width, canvas_height, P3D);
  server = new SyphonServer(this, syphon_name);

  shader = loadShader("data/graphics.glsl");
  shader.set("res", float(canvas.width), float(canvas.height));

  for (int i = 0; i<n; i++) {
    graphics.add(new Graphic(i, inactive));
  }
}

void draw() {
  background(127);

  resizeSyphonToWindow();

  for (Graphic g : graphics) {
    g.update();
    //print("g" + g.target, "s:" + g.offset, round(g.progress, 1), " // ");
  }
  canvas.beginDraw();
  canvas.background(0);
  canvas.rect(0, 0, canvas.width, canvas.height);
  canvas.shader(shader);
  canvas.endDraw();
  image(canvas, (width/2)-(sW/2), 100+(width/2)-(sH/2), sW, sH);

  server.sendImage(canvas);

  String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [fps %6.2f]", width, height, frameRate);
  surface.setTitle(txt_fps);
}

private static double round (double value, int precision) {
  int scale = (int) Math.pow(10, precision);
  return (double) Math.round(value * scale) / scale;
}

public void createCanvas() {
  PGraphics temp_canvas = createGraphics(canvas_width, canvas_height, P3D);
  canvas = temp_canvas;
  shader.set("res", float(canvas.width), float(canvas.height));
}

void resizeSyphonToWindow() {
  int max = width-20;
  float tW, tH;
  if (canvas_width > canvas_height) {
    tW = max;
    tH = (tW/canvas_width)*canvas_height;
  }
  else {
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
  if (str_in[1].equals("svesketrigger") && cp5.getController(str_in[2]) != null) {
    Controller c = cp5.getController(str_in[2]);
    if (c.getId() == triggerID && a_n < n) {
      for (int i = 1; i<animations.length; i++) {
        if (str_in[2].equals(animations[i].type)) trigAnimation(animations[i]);
      }
    }
    else if (c.getId() == settingsID && theOscMessage.checkTypetag("f")) {
      float v = theOscMessage.get(0).floatValue();
      c.setValue(v * c.getMax());
    }
  }
}


void updateIP() {
  ip = Server.ip();
  cp5.getController("bang_update_ip").setLabel("local IP is: " + ip);
}
/*
void keyPressed() {
  if (a_n < n) {
    switch(key) {
      case '1': trigAnimation(ring_in); break;
      case '2': trigAnimation(ring_out); break;
      case '3': trigAnimation(line_btt); break;
      case '4': trigAnimation(line_ttb); break;
      case '5': trigAnimation(line_rtl); break;
      case '6': trigAnimation(line_ltr); break;
    }
  }
}
*/
void trigAnimation(Animation a) {
  /*
  loop through graphics, and set new parameters at the first available (inactive)
  animation object to "add" a new animation.
  */
  boolean found = false;
  int id = 0;
  while (found == false) {
    Graphic g = graphics.get(id);
    if (g.offset == inactive.offset) {
      graphics.set(id, new Graphic(g.target, a));
      found = true;
    }
    else id++;
  }
  a_n++;
}

import codeanticode.syphon.*;
import controlP5.*;
import de.looksgood.ani.*;
import oscP5.*;
import netP5.*;
import processing.net.*;

String[] triggers = {"ring_out", "ring_in", "line_ltr", "line_rtl", "line_ttb", "line_btt"};
String[] eases = {"LINEAR", "EASE IN", "EASE OUT", "EASE IN_OUT"};
int[] size_presets = {480, 640, 720, 800, 1024, 1200, 1920};

ControlP5 cp5;
CallbackListener cb;
Slider slider_s_w, slider_s_h;
Numberbox n1, n2, n3, n4;
Toggle toggle_resize_lock;
Bang bang_update_ip, bang_s_w_add, bang_s_w_sub, bang_s_h_add, bang_s_h_sub;
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
int a_n; //current amount of graphics
PShader shader;
ArrayList<Graphic> graphics = new ArrayList<Graphic>();
Animation inactive = new Animation("inactive", 0.);
Animation line_ttb = new Animation("line_ttb", 1., 0., 1.);
Animation line_btt = new Animation("line_btt", 1., 1., 0.);
Animation line_rtl = new Animation("line_rtl", 2., 0., 1.);
Animation line_ltr = new Animation("line_ltr", 2., 1., 0.);
Animation ring_out = new Animation("ring_out", 3., 0., 1.);
Animation ring_in = new Animation("ring_in", 3., 1., 0.);

float speed =.1, linewidth =.1;
float bleed = 0.1;

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

    }
  }
}

void updateIP() {
  ip = Server.ip();
  cp5.getController("bang_update_ip").setLabel("local IP is: " + ip);
}

void mousePressed() {
  if (mouseX > 335 && mouseX < 365 && mouseY > 10 && mouseY <40) {
    link("http://sveskenielsen.dk/");
  }
}

void keyPressed() {
  if (a_n < n) {
    if (key=='1') trigAnimation(ring_in);
    else if (key=='2') trigAnimation(ring_out);
    else if (key=='3') trigAnimation(line_btt);
    else if (key=='4') trigAnimation(line_ttb);
    else if (key=='5') trigAnimation(line_rtl);
    else if (key=='6') trigAnimation(line_ltr);
  }
}

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

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import codeanticode.syphon.*; 
import controlP5.*; 
import de.looksgood.ani.*; 
import oscP5.*; 
import netP5.*; 
import processing.net.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class svesketrigger extends PApplet {








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
Animation inactive = new Animation("inactive", 0.f);
Animation line_ttb = new Animation("line_ttb", 1.f, 0.f, 1.f);
Animation line_btt = new Animation("line_btt", 1.f, 1.f, 0.f);
Animation line_rtl = new Animation("line_rtl", 2.f, 0.f, 1.f);
Animation line_ltr = new Animation("line_ltr", 2.f, 1.f, 0.f);
Animation ring_out = new Animation("ring_out", 3.f, 0.f, 1.f);
Animation ring_in = new Animation("ring_in", 3.f, 1.f, 0.f);

float speed =.1f, linewidth =.1f;
float bleed = 0.1f;

public void settings() {
  size(400, 600, P3D);
  //PJOGL.profile=1;
}

public void setup() {
  logo = loadImage("svesketrigger.png");
  Ani.init(this);
  Ani.setDefaultEasing(Ani.LINEAR);

  controlSetup();
  oscP5 = new OscP5(this, port);

  canvas = createGraphics(canvas_width, canvas_height, P3D);
  server = new SyphonServer(this, syphon_name);

  shader = loadShader("data/graphics.glsl");
  shader.set("res", PApplet.parseFloat(canvas.width), PApplet.parseFloat(canvas.height));

  for (int i = 0; i<n; i++) {
    graphics.add(new Graphic(i, inactive));
  }
}

public void draw() {
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
  shader.set("res", PApplet.parseFloat(canvas.width), PApplet.parseFloat(canvas.height));
}

public void resizeSyphonToWindow() {
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
public void oscEvent(OscMessage theOscMessage) {

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

public void updateIP() {
  ip = Server.ip();
  cp5.getController("bang_update_ip").setLabel("local IP is: " + ip);
}

public void mousePressed() {
  if (mouseX > 335 && mouseX < 365 && mouseY > 10 && mouseY <40) {
    link("http://sveskenielsen.dk/");
  }
}

public void keyPressed() {
  if (a_n < n) {
    if (key=='1') trigAnimation(ring_in);
    else if (key=='2') trigAnimation(ring_out);
    else if (key=='3') trigAnimation(line_btt);
    else if (key=='4') trigAnimation(line_ttb);
    else if (key=='5') trigAnimation(line_rtl);
    else if (key=='6') trigAnimation(line_ltr);
  }
}

public void trigAnimation(Animation a) {
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
class Animation {
  String type;
  float offset, start, end;
  Animation(String t, float o, float s, float e){
    type = t;
    offset = o;
    start = s;
    end = e;
  }
  Animation(String t, float o) {
    type = t;
    offset = o;
  }
}
  class Graphic {
    PVector output = new PVector(0.0f, 0.0f, 0.0f);
    float offset, progress = 0.f,lw, bl;
    int target;
    Ani ani;

    Graphic(int t, Animation a) {
      offset = a.offset;
      target = t;
      progress = a.start;
      lw = linewidth;
      bl = bleed;
      if (a.offset != inactive.offset) ani = new Ani(this, speed, "progress", a.end, Ani.getDefaultEasing(), "onEnd:reset");
    }

    public void update() {
      output = new PVector(progress+offset, lw, bl);
      shader.set("g"+target, output);
    }

    public void reset() {
      offset = inactive.offset;
      output = new PVector(0.0f, 0.0f, 0.0f);
      /*
      when the initial Graphic objects gets added to graphics, their Ani
      objects runs and thus resets n times, causing a_n to be subtracted below 0.
      The following line prevents this initial error.
      */
      if (a_n>0) a_n--;
    }
  }
public void controlSetup() {
  cp5 = new ControlP5(this);
  int grp_offset = width/3;
  int xoff = 10;
  int yoff = 10;

  Group output = cp5.addGroup("output")
  .setPosition(0, 10)
  .setWidth(grp_offset)
  .setLabel("output")
  .activateEvent(true)
  ;

  Group osc = cp5.addGroup("osc")
  .setPosition(grp_offset,10)
  .setWidth(grp_offset)
  .setLabel("osc connection")
  .activateEvent(true)
  ;

  Group howto = cp5.addGroup("howto")
  .setPosition(grp_offset*2,10)
  .setWidth(grp_offset)
  .setLabel("HOW TO USE")
  .activateEvent(true)
  ;

  switchGroup("output", "osc", "howto");

  cb = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_ENTER):
        cursor(HAND);
        break;
        case(ControlP5.ACTION_LEAVE):
        case(ControlP5.ACTION_RELEASEDOUTSIDE):
        cursor(ARROW);
        break;
      }
    }
  };

  cp5.addCallback(cb);

  // OUTPUT

  bang_s_w_sub = cp5.addBang("syphonWsub")
  .setGroup(output)
  .setPosition(xoff, yoff)
  .setSize(200, 20)
  .setTriggerEvent(Bang.RELEASE)
  .setLabelVisible(false)
  ;

  xoff += 15+5;
  slider_s_w = cp5.addSlider("canvas_width")
  .setGroup(output)
  .setPosition(xoff, yoff)
  .setSize(200, 20)
  .setRange(1, 2400)
  .setValue(640)
  ;

  xoff += slider_s_w.getWidth()+5;
  bang_s_w_add = cp5.addBang("syphonWadd")
  .setGroup(output)
  .setPosition(xoff, yoff)
  .setSize(15, 20)
  .setTriggerEvent(Bang.RELEASE)
  .setLabelVisible(false)
  ;

  xoff = 10;
  yoff+= 25;
  radio_w_presets = cp5.addRadioButton("radio_w_presets")
  .setGroup(output)
  .setPosition(xoff, yoff)
  .setItemWidth(10)
  .setItemHeight(10)
  .setItemsPerRow(size_presets.length)
  .setSpacingColumn(30)
  .setNoneSelectedAllowed(true)
  ;

  xoff=10;
  yoff+=15;
  bang_s_h_sub = cp5.addBang("syphonHsub")
  .setGroup(output)
  .setPosition(xoff, yoff)
  .setSize(15, 20)
  .setTriggerEvent(Bang.RELEASE)
  .setLabelVisible(false);
  ;

  xoff += 15+5;
  slider_s_h = cp5.addSlider("canvas_height")
  .setGroup(output)
  .setPosition(xoff, yoff)
  .setSize(150, 20)
  .setRange(1, 2400)
  .setValue(480)
  ;

  xoff=width-15-50;
  toggle_resize_lock = cp5.addToggle("bool_resize_lock")
  .setGroup(output)
  .setPosition(xoff, yoff)
  .setSize(50, 20)
  .setValue(true)
  .setMode(ControlP5.SWITCH)
  .setLabel("resize lock")
  ;

  xoff += 150+5;
  bang_s_h_add = cp5.addBang("syphonHadd")
  .setGroup(output)
  .setPosition(xoff, yoff)
  .setSize(15, 20)
  .setTriggerEvent(Bang.RELEASE)
  .setLabelVisible(false)
  ;

  xoff = 10;
  yoff += 25;
  radio_h_presets = cp5.addRadioButton("radio_h_presets")
  .setGroup(output)
  .setPosition(xoff, yoff)
  .setItemWidth(10)
  .setItemHeight(10)
  .setItemsPerRow(size_presets.length)
  .setSpacingColumn(30)
  .setNoneSelectedAllowed(true)
  ;

  for (int i = 0; i<size_presets.length; i++) {
    String name = str(size_presets[i]);
    radio_h_presets.addItem(name, i);
    radio_w_presets.addItem(name+" ", i);
  }

  xoff = 0;
  yoff = 10;

  cp5.addTextarea("txt")
  .setGroup("howto")
  .setPosition(5, 5)
  .setSize(120, 400)
  .setFont(createFont("arial", 10))
  .setLineHeight(12)
  .setColor(color(255))
  .setText(addExplainer());

  xoff += 10-grp_offset;
  yoff = 10;
  // OSC
  bang_update_ip =  cp5.addBang("bang_update_ip")
  .setGroup(osc)
  .setPosition(xoff, yoff)
  .setSize(30, 30)
  .setTriggerEvent(Bang.RELEASE)
  .setLabel(ip)
  ;
  yoff+= 50;

  field_port = cp5.addTextfield("field_port")
  .setGroup(osc)
  .setPosition(xoff, yoff)
  .setSize(100, 20)
  .setAutoClear(false)
  .setText(Integer.toString(port))
  .setLabel("osc port")
  ;

  xoff+= 250;
  field_syphon_name = cp5.addTextfield("field_syphon_name")
  .setGroup(osc)
  .setPosition(xoff, yoff)
  .setSize(100, 20)
  .setAutoClear(false)
  .setText(syphon_name)
  .setLabel("syphon server name")
  ;

  updateIP();

  bang_update_ip.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_ENTER) {
        cp5.getController("bang_update_ip").setLabel("Click to update local IP");
      }
      else if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
        cp5.getController("bang_update_ip").setLabel("local IP is: " + ip);
      }
    }
  }
  );
  field_port.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_ENTER) {
        cp5.getController("field_port").setLabel("input value between 0 and 9999 and hit enter");
      }
      else if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
        cp5.getController("field_port").setLabel("osc port");
      }
    }
  }
  );

  field_syphon_name.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_ENTER) {
        cp5.getController("field_syphon_name").setLabel("input syphon server name");
      }
      else if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
        cp5.getController("field_syphon_name").setLabel("syphon server name");
      }
    }
  }
  );
  //TRIGGERS
  xoff = 10;
  yoff = 560;
  int slider_width = 80;
  int slider_height = 20;
  cp5.addSlider("linewidth")
  .setPosition(xoff, yoff)
  .setSize(slider_width, slider_height)
  .setRange(.0f, 1.f)
  .setValue(.2f)
  .setLabel("line width")
  ;
  //cp5.getController("linewidth").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("linewidth").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  xoff += slider_width + 5;
  cp5.addSlider("bleed")
  .setPosition(xoff, yoff)
  .setSize(slider_width, slider_height)
  .setRange(.001f, 1.f)
  .setValue(.5f)
  .setLabel("line bleed")
  ;
  cp5.getController("bleed").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  xoff += slider_width + 5;
  cp5.addSlider("speed")
  .setPosition(xoff, yoff)
  .setSize(slider_width, slider_height)
  .setRange(10.f, 0.1f)
  .setValue(.5f)
  .setLabel("animation speed")
  ;
  cp5.getController("speed").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  xoff = 10;
  yoff = 500;
  for (int i = 0; i<triggers.length; i++) {
    cp5.addBang(triggers[i])
    .setPosition(xoff, yoff)
    .setSize(40, 40)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel(triggers[i])
    ;
    xoff+=45;
  }

  radio_eases = cp5.addRadioButton("radio_eases")
  .setPosition(300, 500)
  .setItemWidth(20)
  .setItemHeight(20)
  .setNoneSelectedAllowed(false)
  ;

  for (int i = 0; i<eases.length; i++) radio_eases.addItem(eases[i], i);
  radio_eases.activate(0);

}

public void typeRadio(int theC) {
  switch(theC) {
    case(0):
    Ani.setDefaultEasing(Ani.LINEAR);
    break;
    case(1):
    Ani.setDefaultEasing(Ani.SINE_IN);
    break;
    case(2):
    Ani.setDefaultEasing(Ani.SINE_OUT);
    break;
    case(3):
    Ani.setDefaultEasing(Ani.SINE_IN_OUT);
    break;
  }
}

public void radio_w_presets(int theC){
  radio_w_presets.deactivateAll();
  cp5.getController("canvas_width").setValue(size_presets[theC]);
}
public void radio_h_presets(int theC){
  radio_h_presets.deactivateAll();
  cp5.getController("canvas_height").setValue(size_presets[theC]);
}

public void switchGroup(String open, String closed1, String closed2) {
  cp5.getGroup(open).open();
  cp5.getGroup(closed1).close();
  cp5.getGroup(closed2).close();
}

public void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    if (theEvent.getGroup().getName().equals("howto")) switchGroup("howto", "output", "osc");
    else if (theEvent.getGroup().getName().equals("output")) switchGroup("output", "howto", "osc");
    else if (theEvent.getGroup().getName().equals("osc")) switchGroup("osc", "howto", "output");
  }

  if (theEvent.isController()) {
    String name =theEvent.getController().getName();
    if (theEvent.getController().equals(slider_s_w) || theEvent.getController().equals(slider_s_h) ) {
      createCanvas();
    }
    else if (theEvent.getController().equals(bang_update_ip)) {
      updateIP();
    }

    if (theEvent.getController().equals(bang_s_w_add)) {
      adjustSyphon("canvas_width", 1);
    }
    else if (theEvent.getController().equals(bang_s_w_sub)) {
      adjustSyphon("canvas_width", -1);
    }
    else if (theEvent.getController().equals(bang_s_h_add)) {
      adjustSyphon("canvas_height", 1);
    }
    else if (theEvent.getController().equals(bang_s_h_sub)) {
      adjustSyphon("canvas_height", -1);
    }

  }
}

public void adjustSyphon(String con, int value) {
  int init = (int)cp5.getController(con).getValue();
  if (value < 0 && init >= 1) {
    cp5.getController(con).setValue(init+value);
  }
  else if (value > 0 && init < cp5.getController(con).getMax()) {
    cp5.getController(con).setValue(init+value);
  }
}

public void field_port(String theText) {

  char[] ints = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
  char[] input = theText.toCharArray();


  String txt = "value not between 0 and 9999";
  if (input.length < 5) {
    int check = 0;
    for (char ch : input) {
      for (char i : ints) {
        if (ch == i) check++;
      }
    }
    if (input.length == check) {
      int nport = Integer.parseInt(theText);
      txt = "osc port is changed from " + port + " to " + nport;
      if (port == nport) txt = "value is not different from " + port;
      else {
        port = nport;
        updateOSC();
      }
    }
  }
  cp5.getController("field_port").setLabel(txt);
}

public void field_syphon_name(String theText){
  if (theText != syphon_name) syphon_name = theText;
  server = new SyphonServer(this, syphon_name);
}

public void updateOSC() {
  ip = Server.ip();
  oscP5 = new OscP5(this, port);
}

public String addExplainer(){
  String t = "Match OSC output IP and port with external OSC source in the OSC CONNECTION menu."
  + "\n" + "\n" +
  "All OSC messages must begin with " + "\n" +  "'' /svesketrigger/ ''"
  + "\n" + "\n" +
  "TRIGGERS:"
  + "\n" +
  "/ring_out"
  + "\n" +
  "/ring_in"
  + "\n" +
  "/line_ltr"
  + "\n" +
  "/line_rtl"
  + "\n" +
  "/line_ttb"
  + "\n" +
  "/line_btt"
  + "\n" + "\n" +
  "SLIDERS:"
  + "\n" +
  "Slider values must be normalised floats"
  + "\n" + "\n" +
  "/linewidth"
  + "\n" +
  "/speed"
  ;
  return t;
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "svesketrigger" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

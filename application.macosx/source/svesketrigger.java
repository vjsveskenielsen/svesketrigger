import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import codeanticode.canvas.*; 
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








String[] types = {"ring_out", "ring_in", "line_ltr", "line_rtl", "line_ttb", "line_btt"};
OscP5 oscP5;
Slider slider_c_w, slider_c_h;
Numberbox n1, n2, n3, n4;
Toggle toggle_resize_lock;
CallbackListener cb;
Bang bang_update_ip, bang_c_w_add, bang_c_w_sub, bang_s_h_add, bang_s_h_sub;
String ip;

ControlP5 cp5;

Server localServer;

PGraphics canvas;
SyphonServer server;
boolean bool_resize_lock;
int canvas_width, canvas_height, canvas_win_width, canvas_win_height, linewidth;
float speed;
int easing;

ArrayList<Animation> animations = new ArrayList<Animation>();

PImage logo;
int logotint = 10;

public void settings() {
  size(400, 600, P3D);
  PJOGL.profile=1;
}

public void setup() {
  logo = loadImage("svesketrigger.png");
  Ani.init(this);
  Ani.setDefaultEasing(Ani.LINEAR);

  controlSetup();
  oscP5 = new OscP5(this, 9999);

  canvas = createGraphics(canvas_width, canvas_height, P3D);
  server = new SyphonServer(this, "svesketrigger canvas");
  
}

public void draw() {
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
  if (bool_resize_lock) {
    cp5.getController("canvas_width").setLock(false);
    cp5.getController("canvas_height").setLock(false);
    fitCanvasInWindow();
  } else {
    cp5.getController("canvas_width").setLock(true);
    cp5.getController("canvas_height").setLock(true);
  }
  canvas.beginDraw();
  canvas.background(0);
  canvas.endDraw();

  for (int i = animations.size() - 1; i >= 0; i--) {
    Animation a = animations.get(i);
    if (!a.active) {
      animations.remove(i);
    } else { 
      a.update();
    }
  }

  image(canvas, (width/2)-(canvas_win_width/2), 100+(width/2)-(canvas_win_height/2), canvas_win_width, canvas_win_height);
  server.sendImage(canvas);
}

public void createCanvas() {
  PGraphics s = createGraphics(canvas_width, canvas_height, P3D);
  canvas = s;
}

public void fitCanvasInWindow() {
  int max = width-20;
  float tW, tH;
  if (canvas_width > canvas_height) {
    tW = max;
    tH = (tW/canvas_width)*canvas_height;
  } else {
    tH = max;
    tW = (tH/canvas_height)*canvas_width;
  }
  canvas_win_width = ceil(tW);
  canvas_win_height = ceil(tH);

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
      chooseAnimation(str_in[2]);
    }
  }
}

// filter incoming triggers from osc and cp5
public void chooseAnimation(String type) {
  for (String t : types) {
    if (type.equals(t) == true) {
      animations.add(new Animation(t, speed, .0f, 1.f));
      return;
    }
  }
}

public void makeOSC() {  
  int p1 = (int)cp5.getController("n1").getValue();
  int p2 = (int)cp5.getController("n2").getValue();
  int p3 = (int)cp5.getController("n3").getValue();
  int p4 = (int)cp5.getController("n4").getValue();
  oscP5 = new OscP5(this, p1*1000 + p2*100 + p3*10 + p4);
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
class Animation {
  boolean active;
  float progress;
  String type;
  int locallinewidth;
  Ani ani;
  // type animation // speed // start // end 
  Animation(String _type, float localspeed, float start, float end) {
    active = true;
    progress = start;
    type = _type;
    ani = new Ani(this, localspeed, "progress", end, Ani.getDefaultEasing(), "onEnd:killObject");
    ani.start();
    locallinewidth = linewidth;
  }
  public void update() {
    canvas.beginDraw();
    canvas.noFill();
    canvas.stroke(255);
    canvas.strokeWeight(locallinewidth);
    if (type=="ring_out") {
      ring_out();
    }
    if (type=="ring_in") {
      ring_in();
    }
    if (type=="line_ltr") {
      line_ltr();
    }
    if (type=="line_rtl") {
      line_rtl();
    }
    if (type=="line_ttb") {
      line_ttb();
    }
    if (type=="line_btt") {
      line_btt();
    }
    canvas.endDraw();
  }

  public void ring_out() {
    canvas.translate(canvas_width/2, canvas_height/2);
    float goal = dist(0, 0, canvas_width+locallinewidth, canvas_height+locallinewidth); 
    canvas.ellipse(0, 0, progress*goal, progress*goal);
  }

  public void ring_in() {
    canvas.translate(canvas_width/2, canvas_height/2);
    float goal = dist(0, 0, canvas_width+locallinewidth, canvas_height+locallinewidth); 
    canvas.ellipse(0, 0, (1-progress)*goal, (1-progress)*goal);
  }

  public void line_ltr() {
    float p = map(progress, 0,1, 0-locallinewidth, canvas_width+locallinewidth);
    canvas.line(p, 0, p, canvas_height);
  }

  public void line_rtl() {
    float p = map(progress, 0,1, canvas_width+locallinewidth,0-locallinewidth);
    canvas.line(p, 0, p, canvas_height);
  }

  public void line_ttb() {
    float p = map(progress, 0,1, 0-locallinewidth, canvas_height+locallinewidth);
    canvas.line(0, p, canvas_width, p);
  }

  public void line_btt() {
    float p = map(progress, 0,1, canvas_height+locallinewidth,0-locallinewidth);
    canvas.line(0, p, canvas_width, p);
  }

  public void killObject() {
    active = false;
  }
}
public void controlSetup() {
  cp5 = new ControlP5(this);

  slider_c_w = cp5.addSlider("canvas_width")
    .setPosition(10, 10)
    .setSize(200, 30)
    .setRange(1, 2400)
    .setValue(1200)
    ;

  bang_c_w_add = cp5.addBang("canvas_width_add")
    .setPosition(170, 40)
    .setSize(40, 10)
    .setTriggerEvent(Bang.RELEASE)
    .setLabelVisible(false)
    ;

  bang_c_w_sub = cp5.addBang("canvas_width_sub")
    .setPosition(10, 40)
    .setSize(40, 10)
    .setTriggerEvent(Bang.RELEASE)
    .setLabelVisible(false);
  ;
  slider_c_h = cp5.addSlider("canvas_height")
    .setPosition(10, 50)
    .setSize(200, 30)
    .setRange(1, 2400)
    .setValue(800)
    ;

  bang_s_h_add = cp5.addBang("syphonHadd")
    .setPosition(170, 80)
    .setSize(40, 10)
    .setTriggerEvent(Bang.RELEASE)
    .setLabelVisible(false)
    ;
  bang_s_h_sub = cp5.addBang("canvas_height_sub")
    .setPosition(10, 80)
    .setSize(40, 10)
    .setTriggerEvent(Bang.RELEASE)
    .setLabelVisible(false);
  ;

  toggle_resize_lock = cp5.addToggle("bool_resize_lock")
    .setPosition(260, 10)
    .setSize(50, 20)
    .setValue(true)
    .setMode(ControlP5.SWITCH)
    .setLabel("resize lock")
    ;

  Group howto = cp5.addGroup("howto")
    .setPosition(260, 80)
    .setWidth(130)
    .activateEvent(true)
    .setBackgroundColor(color(80))
    .setBackgroundHeight(320)
    .setLabel("HOW TO USE")
    .setOpen(false);
    ;

  cp5.addTextarea("txt")
    .setGroup("howto")
    .setPosition(5, 5)
    .setSize(120, 400)
    .setFont(createFont("arial", 10))
    .setLineHeight(12)
    .setColor(color(255))
    .setText(
    "Match OSC output IP and port with external OSC source in the OSC CONNECTION menu."
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
    )
    ;
  Group port = cp5.addGroup("port")
    .setPosition(260, 60)
    .setWidth(130)
    .activateEvent(true)
    .setBackgroundColor(color(80))
    .setBackgroundHeight(110)
    .setLabel("osc connection")
    .setOpen(false);
    ;


  n1 = cp5.addNumberbox("n1")
    .setPosition(5, 10)
    .setSize(30, 20)
    .setScrollSensitivity(1)
    .setDecimalPrecision(0)
    .setValue(9)
    .setMin(0)
    .setMax(9)
    .setLabelVisible(false)
    .setGroup("port")
    ;

  n2 = cp5.addNumberbox("n2")
    .setPosition(35, 10)
    .setSize(30, 20)
    .setScrollSensitivity(1)
    .setDecimalPrecision(0)
    .setValue(9)
    .setMin(0)
    .setMax(9)
    .setLabelVisible(false)
    .setGroup("port")
    ;

  n3 = cp5.addNumberbox("n3")
    .setPosition(65, 10)
    .setSize(30, 20)
    .setScrollSensitivity(1)
    .setDecimalPrecision(0)
    .setValue(9)
    .setMin(0)
    .setMax(9)
    .setLabelVisible(false)
    .setGroup("port")
    ;

  n4 = cp5.addNumberbox("n4")
    .setPosition(95, 10)
    .setSize(30, 20)
    .setScrollSensitivity(1)
    .setDecimalPrecision(0)
    .setValue(9)
    .setMin(0)
    .setMax(9)
    .setLabelVisible(false)
    .setGroup("port")
    ;

  bang_update_ip =  cp5.addBang("bang_update_ip")
    .setPosition(5, 50)
    .setSize(30, 30)
    .setTriggerEvent(Bang.RELEASE)
    .setGroup("port")
    .setLabel(ip)

    ;

  updateIP();

  cp5.addSlider("linewidth")
    .setPosition(10, 570)
    .setSize(50, 20)
    .setRange(1, 100)
    .setValue(20)
    .setLabel("line width")
    ;

  cp5.addSlider("speed")
    .setPosition(150, 570)
    .setSize(50, 20)
    .setRange(.1f, 10.f)
    .setValue(5)
    .setLabel("animation speed")
    ;

  cp5.addBang("ring_out")
    .setPosition(10, 500)
    .setSize(40, 40)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("ring_out")
    ;

  cp5.addBang("ring_in")
    .setPosition(55, 500)
    .setSize(40, 40)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("ring_in")
    ;

  cp5.addBang("line_ltr")
    .setPosition(100, 500)
    .setSize(40, 40)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("line_ltr")
    ;

  cp5.addBang("line_rtl")
    .setPosition(145, 500)
    .setSize(40, 40)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("line_rtl")
    ;

  cp5.addBang("line_ttb")
    .setPosition(190, 500)
    .setSize(40, 40)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("line_ttb")
    ;

  cp5.addBang("line_btt")
    .setPosition(235, 500)
    .setSize(40, 40)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("line_btt")
    ;

  cp5.addRadioButton("typeRadio")
    .setPosition(300, 500)
    .setItemWidth(20)
    .setItemHeight(20)
    .setNoneSelectedAllowed(false)
    .addItem("LINEAR", 0)
    .addItem("EASE IN", 1) 
    .addItem("EASE OUT", 2)
    .addItem("EASE IN_OUT", 3)
    .activate(0)
    ;
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

  n1.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_RELEASED || theEvent.getAction()==ControlP5.ACTION_RELEASEDOUTSIDE) {
        makeOSC();
      }
    }
  }
  );
  n2.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_RELEASED || theEvent.getAction()==ControlP5.ACTION_RELEASEDOUTSIDE) {
        makeOSC();
      }
    }
  }
  );
  n3.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_RELEASED || theEvent.getAction()==ControlP5.ACTION_RELEASEDOUTSIDE) {
        makeOSC();
      }
    }
  }
  );
  n4.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_RELEASED || theEvent.getAction()==ControlP5.ACTION_RELEASEDOUTSIDE) {
        makeOSC();
      }
    }
  }
  );
  n4.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_RELEASED || theEvent.getAction()==ControlP5.ACTION_RELEASEDOUTSIDE) {
        makeOSC();
      }
    }
  }
  );
  bang_update_ip.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction()==ControlP5.ACTION_ENTER) {
        cp5.getController("bang_update_ip").setLabel("Click to update local IP");
      } else if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
        cp5.getController("bang_update_ip").setLabel("local IP is: " + ip);
      }
    }
  }
  );
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

public void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
    String name =theEvent.getController().getName();
    if (theEvent.getController().equals(slider_c_w) || theEvent.getController().equals(slider_c_h) ) {
      createCanvas();
    } else if (theEvent.getController().equals(bang_update_ip)) {
      updateIP();
    } 
    if (theEvent.getController().equals(bang_c_w_add)) {
      adjustSyphon("canvas_width", 1);
    } else if (theEvent.getController().equals(bang_c_w_sub)) {
      adjustSyphon("canvas_width", -1);
    } else if (theEvent.getController().equals(bang_s_h_add)) {
      adjustSyphon("canvas_height", 1);
    } else if (theEvent.getController().equals(bang_s_h_sub)) {
      adjustSyphon("canvas_height", -1);
    }
    // pass through chooseAnimation()
    else {
      for (int t = 0; t<types.length; t++) {
        if (types[t] == name) {
          chooseAnimation(name);
        }
      }
    }
  }
}

public void adjustSyphon(String con, int value) {
  int init = (int)cp5.getController(con).getValue();
  if (value < 0 && init >= 1) {
    cp5.getController(con).setValue(init+value);
  } else if (value > 0 && init < cp5.getController(con).getMax()) {
    cp5.getController(con).setValue(init+value);
  }
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

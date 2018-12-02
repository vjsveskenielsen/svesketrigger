void controlSetup() {
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
  .setRange(.0, 1.)
  .setValue(.2)
  .setLabel("line width")
  ;
  //cp5.getController("linewidth").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("linewidth").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  xoff += slider_width + 5;
  cp5.addSlider("bleed")
  .setPosition(xoff, yoff)
  .setSize(slider_width, slider_height)
  .setRange(.001, 1.)
  .setValue(.5)
  .setLabel("line bleed")
  ;
  cp5.getController("bleed").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  xoff += slider_width + 5;
  cp5.addSlider("speed")
  .setPosition(xoff, yoff)
  .setSize(slider_width, slider_height)
  .setRange(10., 0.1)
  .setValue(.5)
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

void typeRadio(int theC) {
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

void radio_w_presets(int theC){
  radio_w_presets.deactivateAll();
  cp5.getController("canvas_width").setValue(size_presets[theC]);
}
void radio_h_presets(int theC){
  radio_h_presets.deactivateAll();
  cp5.getController("canvas_height").setValue(size_presets[theC]);
}

void switchGroup(String open, String closed1, String closed2) {
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

void adjustSyphon(String con, int value) {
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

void updateOSC() {
  ip = Server.ip();
  oscP5 = new OscP5(this, port);
}

String addExplainer(){
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

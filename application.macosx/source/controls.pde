void controlSetup() {
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
    .setRange(.1, 10.)
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

void adjustSyphon(String con, int value) {
  int init = (int)cp5.getController(con).getValue();
  if (value < 0 && init >= 1) {
    cp5.getController(con).setValue(init+value);
  } else if (value > 0 && init < cp5.getController(con).getMax()) {
    cp5.getController(con).setValue(init+value);
  }
}
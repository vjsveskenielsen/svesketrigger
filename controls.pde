void controlSetup() {
  cp5 = new ControlP5(this);
  int s_width = 100;
  int s_height = 20;
  int xoff = 10;
  int yoff = 15;
  bang_s_w_sub = cp5.addBang("syphonWsub")
  .setPosition(xoff, yoff)
  .setSize(15, 20)
  .setTriggerEvent(Bang.RELEASE)
  .setLabelVisible(false);
  ;

  xoff += 15+5;
  int slider_width = 270;
  slider_s_w = cp5.addSlider("canvas_width")
  .setPosition(xoff, yoff)
  .setSize(slider_width, 20)
  .setRange(1, 2400)
  .setValue(640)
  ;

  xoff += slider_width+5;
  bang_s_w_add = cp5.addBang("syphonWadd")
  .setPosition(xoff, yoff)
  .setSize(15, 20)
  .setTriggerEvent(Bang.RELEASE)
  .setLabelVisible(false)
  ;

  xoff = 10;
  yoff+= 25;
  radio_w_presets = cp5.addRadioButton("radio_w_presets")
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
  .setPosition(xoff, yoff)
  .setSize(15, 20)
  .setTriggerEvent(Bang.RELEASE)
  .setLabelVisible(false);
  ;

  xoff += 15+5;
  slider_s_h = cp5.addSlider("canvas_height")
  .setPosition(xoff, yoff)
  .setSize(150, 20)
  .setRange(1, 2400)
  .setValue(480)
  ;

  xoff=width-15-50;
  toggle_resize_lock = cp5.addToggle("bool_resize_lock")
  .setPosition(xoff, yoff)
  .setSize(50, 20)
  .setValue(true)
  .setMode(ControlP5.SWITCH)
  .setLabel("resize lock")
  ;

  xoff += 150+5;
  bang_s_h_add = cp5.addBang("syphonHadd")
  .setPosition(xoff, yoff)
  .setSize(15, 20)
  .setTriggerEvent(Bang.RELEASE)
  .setLabelVisible(false)
  ;

  xoff = 10;
  yoff += 25;
  radio_h_presets = cp5.addRadioButton("radio_h_presets")
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
  Group howto = cp5.addGroup("howto")
  .setPosition(xoff, yoff)
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
    xoff += 130;
    Group port = cp5.addGroup("port")
    .setPosition(xoff, yoff)
    .setWidth(130)
    .activateEvent(true)
    .setBackgroundColor(color(80))
    .setBackgroundHeight(110)
    .setLabel("osc connection")
    .setOpen(false);
    ;

    bang_update_ip =  cp5.addBang("bang_update_ip")
    .setPosition(5, 50)
    .setSize(30, 30)
    .setTriggerEvent(Bang.RELEASE)
    .setGroup("port")
    .setLabel(ipAdress)

    ;

    updateIP();

    cp5.addSlider("linewidth")
    .setPosition(10, 570)
    .setSize(50, 20)
    .setRange(.0, 1.)
    .setValue(.2)
    .setLabel("line width")
    ;

    cp5.addSlider("speed")
    .setPosition(150, 570)
    .setSize(50, 20)
    .setRange(.1, 10.)
    .setValue(.5)
    .setLabel("animation speed")
    ;

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

    cp5.addTextfield("portValue")
    .setPosition(xoff, yoff)
    .setSize(s_width, s_height)
    .setAutoClear(false)
    ;

    radio_eases = cp5.addRadioButton("radio_eases")
    .setPosition(300, 500)
    .setItemWidth(20)
    .setItemHeight(20)
    .setNoneSelectedAllowed(false)
    ;
    for (int i = 0; i<eases.length; i++) radio_eases.addItem(eases[i], i);
    radio_eases.activate(0);

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

    bang_update_ip.addCallback(new CallbackListener() {
    }
  }
}

public void controlEvent(CallbackEvent theEvent) {
  if (theEvent.getAction()==ControlP5.ACTION_ENTER) {
    cp5.getController("bang_update_ip").setLabel("Click to update local IP");
    } else if (theEvent.getAction()==ControlP5.ACTION_LEAVE) {
      cp5.getController("bang_update_ip").setLabel("local IP is: " + ipAdress);
    }
  }
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

public void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
    String name =theEvent.getController().getName();
    if (theEvent.getController().equals(slider_s_w) || theEvent.getController().equals(slider_s_h) ) {
      createCanvas();
      } else if (theEvent.getController().equals(bang_update_ip)) {
        updateIP();
      }
      if (theEvent.getController().equals(bang_s_w_add)) {
        adjustSyphon("canvas_width", 1);
        } else if (theEvent.getController().equals(bang_s_w_sub)) {
          adjustSyphon("canvas_width", -1);
          } else if (theEvent.getController().equals(bang_s_h_add)) {
            adjustSyphon("canvas_height", 1);
            } else if (theEvent.getController().equals(bang_s_h_sub)) {
              adjustSyphon("canvas_height", -1);
            }

            // pass through chooseAnimation()
            else {
              for (int t = 0; t<triggers.length; t++) {
                if (triggers[t] == name) {
                  //chooseAnimation(name);
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

          public void portValue(String theText) {

            char[] ints = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
            char[] input = theText.toCharArray();

            int check = 0;
            for (char ch : input) {
              for (char i : ints) {
                if (ch == i) check++;
              }
            }
            if (input.length == check && check < 6) port = Integer.parseInt(theText);
            updateOSC();
          }

          void updateOSC() {
            ipAdress = Server.ip();
            oscP5 = new OscP5(this, port);
            cp5.getController("portValue").setLabel("port: " + port);
          }

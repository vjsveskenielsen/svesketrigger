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
  void update() {
    syphon.beginDraw();
    syphon.noFill();
    syphon.stroke(255);
    syphon.strokeWeight(locallinewidth);
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
    syphon.endDraw();
  }

  void ring_out() {
    syphon.translate(syphonW/2, syphonH/2);
    float goal = dist(0, 0, syphonW+locallinewidth, syphonH+locallinewidth); 
    syphon.ellipse(0, 0, progress*goal, progress*goal);
  }

  void ring_in() {
    syphon.translate(syphonW/2, syphonH/2);
    float goal = dist(0, 0, syphonW+locallinewidth, syphonH+locallinewidth); 
    syphon.ellipse(0, 0, (1-progress)*goal, (1-progress)*goal);
  }

  void line_ltr() {
    float p = map(progress, 0,1, 0-locallinewidth, syphonW+locallinewidth);
    syphon.line(p, 0, p, syphonH);
  }

  void line_rtl() {
    float p = map(progress, 0,1, syphonW+locallinewidth,0-locallinewidth);
    syphon.line(p, 0, p, syphonH);
  }

  void line_ttb() {
    float p = map(progress, 0,1, 0-locallinewidth, syphonH+locallinewidth);
    syphon.line(0, p, syphonW, p);
  }

  void line_btt() {
    float p = map(progress, 0,1, syphonH+locallinewidth,0-locallinewidth);
    syphon.line(0, p, syphonW, p);
  }

  void killObject() {
    active = false;
  }
}
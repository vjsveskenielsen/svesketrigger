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

  void ring_out() {
    canvas.translate(canvas_width/2, canvas_height/2);
    float goal = dist(0, 0, canvas_width+locallinewidth, canvas_height+locallinewidth); 
    canvas.ellipse(0, 0, progress*goal, progress*goal);
  }

  void ring_in() {
    canvas.translate(canvas_width/2, canvas_height/2);
    float goal = dist(0, 0, canvas_width+locallinewidth, canvas_height+locallinewidth); 
    canvas.ellipse(0, 0, (1-progress)*goal, (1-progress)*goal);
  }

  void line_ltr() {
    float p = map(progress, 0,1, 0-locallinewidth, canvas_width+locallinewidth);
    canvas.line(p, 0, p, canvas_height);
  }

  void line_rtl() {
    float p = map(progress, 0,1, canvas_width+locallinewidth,0-locallinewidth);
    canvas.line(p, 0, p, canvas_height);
  }

  void line_ttb() {
    float p = map(progress, 0,1, 0-locallinewidth, canvas_height+locallinewidth);
    canvas.line(0, p, canvas_width, p);
  }

  void line_btt() {
    float p = map(progress, 0,1, canvas_height+locallinewidth,0-locallinewidth);
    canvas.line(0, p, canvas_width, p);
  }

  void killObject() {
    active = false;
  }
}
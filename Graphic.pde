  class Graphic {
    PVector output = new PVector(0.0, 0.0, 0.0);
    float offset, progress = 0.,lw, bl;
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

    void update() {
      output = new PVector(progress+offset, lw, bl);
      shader.set("g"+target, output);
    }

    void reset() {
      offset = inactive.offset;
      output = new PVector(0.0, 0.0, 0.0);
      /*
      when the initial Graphic objects gets added to graphics, their Ani
      objects runs and thus resets n times, causing a_n to be subtracted below 0.
      The following line prevents this initial error.
      */
      if (a_n>0) a_n--;
    }
  }

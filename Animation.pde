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

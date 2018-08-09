#define PROCESSING_COLOR_SHADER

uniform vec2 resolution;
uniform float nf;

vec3 makeRing(vec2 p, float r) {
    float ptc = distance(p,vec2(0.5));
    float pte = ptc;
    float s = 0.02;
    pte = smoothstep(r, ptc, r+s); //inside
    ptc = smoothstep(r+s, ptc, r); //outside
    vec3 color = vec3(ptc+pte);
    return color;
}

void main(){
	vec2 st = gl_FragCoord.xy/resolution;
  vec3 color = vec3(1.,.0,.0);

  color += makeRing(st, nf);
	gl_FragColor = vec4( color, 1.0 );
}

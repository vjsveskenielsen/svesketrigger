#define PROCESSING_COLOR_SHADER
#ifdef GL_ES
precision mediump float;
#endif

/* Included in GLSL preview
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
*/

const int n = 1;
uniform float distances[n];

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
	vec2 st = gl_FragCoord.xy/u_resolution;
  vec3 color = vec3(0);

	for (int i = 0; i<n; i++) {
    color += makeRing(st, 0.3+0.2*float(i));
  }

	gl_FragColor = vec4( color, 1.0 );
}

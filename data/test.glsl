#ifdef GL_ES
precision mediump float;
#endif
// #extension GL_OES_standard_derivatives : enable
vec4 cA = vec4(1.,1.,1.,1.); //color A
vec4 cB = vec4(0.,0.,0.,0.); //color B
vec2 res = u_resolution;

vec4 drawRing(vec4 tint, float pr, float lw, float bl) {
	vec2 pos;
	vec4 c;
	float adj;

	float hyp = sqrt(	pow(res.x,2.)+pow(res.y,2.)	);
	if (res.x < res.y) {
		pos = (gl_FragCoord.xy-res/2.) * 2. / res.y;
		adj = res.x;
	}
	else {
		pos = (gl_FragCoord.xy-res/2.) * 2. / res.x;
		adj = res.y;
	}

	lw *= smoothstep(.01, .03, pr);
	float r = length(pos);
	pr *= 1.+adj/hyp;
	pr += lw;
	if(r+lw > pr && r-lw < pr) {
		c = vec4(0., 1., 1.,1.);
	}
	else c = vec4(0.);
	float a = atan(pos.y,pos.x);
	float f = cos(a*0.000)*pr;


	// f = abs(cos(a*3.));
	// f = abs(cos(a*2.5))*.5+.3;
	//f = abs(cos(a*16.)*sin(a*12.3))*.01+.21;
 	//f += smoothstep(-.5,1., cos(a*10.))*0.2+0.5;

	 //return a color vector for inner + outer edge
	if (bl > 0.) {
		bl *= .1;
		bl += 1. + (bl*.1);
		float bl_r = smoothstep(r*bl, f+lw, r)*c.x;

		float bl_g = smoothstep(r*bl, f+lw, r)*c.y;
		float bl_b = smoothstep(r*bl, f+lw, r)*c.z;
		c += drawRingBleed(r*bl, f+lw, r, c);
		c += vec4(vec3( smoothstep(r, f-lw, r*pow(bl, 1.5))),1.);
	}
	return c;
}

vec4 drawRingBleed(float ss1, float ss2, float ss3, vec4 c_input) {
	float r = smoothstep(v1, v2, v3)*c_input.x;
	float g = smoothstep(v1, v2, v3)*c_input.y;
	float b = smoothstep(v1, v2, v3)*c_input.z;
	return vec4(r,g,b,1.);
}
void main( void ) {
	vec4 color = vec4(0.);
	float v = .5+(sin(u_time)*.5); //oscillate pr
	//v = 1.;
	//v = u_mouse.x;
	color += drawRing(cA, v, .02, .04); //color, progress, linewidth, bleed

	gl_FragColor = color;
}

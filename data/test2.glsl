#ifdef GL_ES
precision mediump float;
#endif
// #extension GL_OES_standard_derivatives : enable
vec4 cA = vec4(1.,1.,1.,.5); //color A
vec4 cB = vec4(0.,0.,0.,0.); //color B
vec2 res = u_resolution;

//the following determines wether width or the height is the broadest side
// and returns the
float bs = step(res.x, res.y)*res.y + step(res.y, res.x)*res.x;
float ns = step(res.x, res.y)*res.x + step(res.y, res.x)*res.y;

vec4 drawLine(vec4 c_in, float pr, float lw, float bl, float p){
	//if the y pos of the fragment is within the boundaries of the stroke, color component
	float r = step(p-lw, pr) *	step(pr, p+lw) * c_in.r;
	float g = step(p-lw, pr) *	step(pr, p+lw) * c_in.g;
	float b = step(p-lw, pr) *	step(pr, p+lw) * c_in.b;
	float a = step(p-lw, pr) *	step(pr, p+lw) * c_in.a;
	// add smooth bleed
	r += smoothstep(p, pr+lw, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.r;
	g += smoothstep(p, pr+lw, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.g;
	b += smoothstep(p, pr+lw, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.b;
	a += smoothstep(p, pr+lw, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.a;
	return vec4(r,g,b,a);
}

//color, progress, linewidth, bleed, orientation
vec4 drawLineH(vec4 c_in, float pr, float lw, float bl) {
	//scale pr to % of narrowest side - fixes position offset
	//half lw - line is drawn as to halves on each side of pr
	//decide axis, scale to narrowest side to fix offset
	return drawLine(c_in, pr*res.y/ns, lw*.5, bl, gl_FragCoord.y/ns);
}

vec4 drawLineV(vec4 c_in, float pr, float lw, float bl) {
	return drawLine(c_in, pr*res.x/ns, lw*.5, bl, gl_FragCoord.x/ns);
}
/*
vec4 drawLineV(float pr, float lw, float bl){
  vec2 p = gl_FragCoord.xy / res.xy;
  float pct = smoothstep(pr-bl, pr, p.x+(lw*.5))-smoothstep(pr, pr+bl, p.x-(lw*.5));
  return vec4(pct);
}
*/

vec4 drawRingBleed(float v1, float v2, float v3, vec4 c_in) {
	float r = smoothstep(v1, v2, v3)*c_in.x;
	float g = smoothstep(v1, v2, v3)*c_in.y;
	float b = smoothstep(v1, v2, v3)*c_in.z;
	float a = smoothstep(v1, v2, v3)*c_in.w;
	return vec4(r,g,b,a);
}

vec4 drawRing(vec4 tint, float pr, float lw, float bl) {
	vec2 pos;
	vec4 c = vec4(0.);
	lw*=.5;

	float hyp = sqrt(	pow(res.x,2.)+pow(res.y,2.)	);
	//broadest side
	pos = (gl_FragCoord.xy-res/2.) * 2. / bs;

	//lw *= smoothstep(.01, .03, pr);
	float r = length(pos);
	// pr *= 1.+bs/hyp;
	pr += lw;
	// if(r+lw > pr && r-lw < pr) {
	// 	c += tint;
	// }

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
		c += drawRingBleed(r*bl, f+lw, r, tint);
		c += drawRingBleed(r, f-lw, r*pow(bl, 1.5),tint);
	}
	float e = .01;
	// if (pos.x < e && pos.y < e && pos.x > .0-e && pos.y > .0-e) c = vec4(1.,0.,.0,1.);
	return c;
}

void main( void ) {
	vec4 color = vec4(0.);
	float v = .5+(sin(u_time)*.5); //oscillate pr
	v = .5;
	// v = u_mouse.x;
	color += drawRing(cA, v, .25, 1.); //color, progress, linewidth, bleed
	color += drawLineH(cA, v, .1, u_mouse.y*.2); //color, progress, linewidth, bleed
	color += drawLineV(cA, v, .1, .01); //color, progress, linewidth, bleed
	//color += drawLineV(v, .02, .0); //color, progress, linewidth, bleed

	gl_FragColor = color;
}

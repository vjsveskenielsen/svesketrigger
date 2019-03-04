//#define PROCESSING_COLOR_SHADER
#ifdef GL_ES
precision mediump float;
#endif
// #extension GL_OES_standard_derivatives : enable
vec4 color_in = vec4(1.,1.,1.,1.); //color A
vec2 res = u_resolution;

//the following determines wether width or the height is the broadest side
// and returns the
float bs = step(res.x, res.y)*res.y + step(res.y, res.x)*res.x;
float ns = step(res.x, res.y)*res.x + step(res.y, res.x)*res.y;

vec4 drawLine(vec4 c_in, float pr, float lw, float bl, float p){
	lw *= .5;
	pr = mix(-lw, 1.+lw, pr);
	//if the y pos of the fragment is within the boundaries of the stroke, color component
	float r = step(p, pr) * c_in.r;
	float g = step(p-lw/ns, pr) *	step(pr, p+lw) * c_in.g*.0;
	float b = step(p-lw/ns, pr) *	step(pr, p+lw) * c_in.b*.0;
	float a = step(p-lw/ns, pr) *	step(pr, p+lw) * c_in.a*.0;
	// add smooth bleed
	bl *= .1;
	//bl += 1. + (bl*.1);
	r += smoothstep(p, pr, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.r;
	g += smoothstep(p, pr, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.g;
	b += smoothstep(p, pr, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.b;
	a += smoothstep(p, pr, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.a;
	return vec4(r,g,b,a);
}

//color, progress, linewidth, bleed, orientation
vec4 drawLineH(vec4 c_in, float pr, float lw, float bl) {
	/*
	(res.y/ns)
	scale to % of narrowest side - fixes position offset
	+lw
	offsets position to push line beyond edge
	lw*.5
	line is drawn as two halves on each side of pr
	decide axis, scale to narrowest side to fix offset
	*/
	return drawLine(c_in, pr*((res.y/ns)+lw), lw*.5, bl, gl_FragCoord.y/bs);
}

vec4 drawLineV(vec4 c_in, float pr, float lw, float bl) {
	return drawLine(c_in, pr*(res.x/ns), lw, bl, gl_FragCoord.x/bs);
}

vec4 drawLineNew(float pr, float lw) {
	vec4 c = vec4(0.);
	vec2 uv = gl_FragCoord.xy/res;
	lw *= .5;
	c += step(uv.x, pr+lw)*step(pr-lw, uv.x);
	c += step(uv.y, pr+lw)*step(pr-lw, uv.y);
	return c;
}
vec4 drawRingBleed(float v1, float v2, float v3, vec4 c_in) {
	float r = smoothstep(v1, v2, v3)*c_in.x;
	float g = smoothstep(v1, v2, v3)*c_in.y;
	float b = smoothstep(v1, v2, v3)*c_in.z;
	float a = smoothstep(v1, v2, v3)*c_in.w;
	return vec4(r,g,b,a);
}
vec2 scaleVec2(vec2 v_in, float le, float te) {
	float vx = mix(le, te, v_in.x);
	float vy = mix(le, te, v_in.y);
	return vec2(vx, vy);
}

float Line(float lw, vec2 a, vec2 b) {
	vec2 pos = gl_FragCoord.xy/res;
	lw *= .5;
	a = scaleVec2(a, -lw, 1.+lw);
	b = scaleVec2(b, -lw, 1.+lw);
	vec2 ab=b-a;
	vec2 pa=a+clamp(dot(pos-a,ab)/dot(ab,ab),0.1,1.0)*ab;
	return 1.-smoothstep(lw, lw, length(pa-pos));
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
	pr += lw;

	float a = atan(pos.y,pos.x);
	float f = cos(a*0.000)*pr;

	// f = abs(cos(a*3.));
	// f = abs(cos(a*2.5))*.5+.3;
	 // f = abs(cos(a*16.)*sin(a*12.3))*.01+.21;
 	//f += smoothstep(-.5,1., cos(a*10.))*0.2+0.5;

	 //return a color vector for inner + outer edge
	if (bl > 0.) {
		bl *= .1;
		bl += 1. + (bl*.1);
		c += drawRingBleed(r*bl, f+lw, r, tint);
		c += drawRingBleed(r, f-lw, r*pow(bl, 1.5),tint);
	}
	c += step(pr,r+lw)*step(r-lw, pr)*tint;

	return c;
}

vec4 evaluate(vec3 g) {
	vec4 rgba = vec4(0.);
	if (g.x > 1. && g.x <= 2.) rgba += drawLineH(color_in, g.x-1., g.y, g.z); //color, progress, linewidth, bleed
	else if (g.x > 2. && g.x < 3.) rgba += drawLineV(color_in, g.x-2., g.y, g.z);
	else if (g.x > 3. && g.x < 4.) rgba += drawRing(color_in, g.x-3., g.y, g.z);
	return rgba;
}

float ring(vec2 p, float radius, float width) {
  return abs(length(p) - radius * 0.5) - width;
}
float smoothedge(float v) {
    return smoothstep(0.0, 1.0 / u_resolution.x, v);
}

void main( void ) {
	vec2 uv = gl_FragCoord.xy/res;
	uv -= .5;
	if (bs == res.x) uv.y *= ns/bs;
	if (bs == res.y) uv.x *= ns/bs;
	vec3 color = vec3(0.);
	float pr;
	pr = abs(sin(u_time));
	pr = .5;
	vec3 _g = vec3(2.5, .5, .0);
	float d = 0.;
 	//color += drawLineNew(.5, .25);
	//color += Line(.33, vec2(.0, .5), vec2(1.,.5))*.25;
	//color += Line(.25, vec2(pr, .0), vec2(pr,1.0))*.25;
	//color += Line(.25, vec2(0., pr), vec2(1.0, pr))*.25;
	//color += Line(.25, vec2(0., 0.), vec2(1.0, 1.0))*.25;
	d = min(1., ring(uv, u_mouse.x, .25));
	color += vec3(1.-smoothedge(d));
	gl_FragColor = vec4(color, 1.);
}

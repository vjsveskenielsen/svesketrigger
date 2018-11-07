#ifdef GL_ES
precision mediump float;
#endif
// #extension GL_OES_standard_derivatives : enable
float progress = .6+sin(u_time);
float stroke = .2;
vec4 cA = vec4(1.,1.,1.,.0); //color A
vec4 cB = vec4(0.,0.,0.,0.); //color B
vec2 res = u_resolution;
float hyp = sqrt((res.x*res.x)+(res.y*res.y));

void main( void ) {
	vec2 pos;
	float o = 1.; //overcompensation
	if (res.x < res.y) {
		pos = (gl_FragCoord.xy-res/2.) * 2. / res.y;
		o += (res.x/hyp);
	}
	else {
		pos = (gl_FragCoord.xy-res/2.) * 2. / res.x;
		o += (res.y/hyp);
	}
	float ease1 = smoothstep(.01, .03, progress);
	float ease2 = smoothstep(1., .89, progress);
	stroke *= ease1;
	float r = length(pos);
	vec4 c = mix(cA, cA, step(r, progress*o));

	if(r+stroke < progress*o || r-stroke > progress*o) {
		c = cB;
	}
	float e = .1;
	float a = atan(pos.y,pos.x);
	float f = cos(a*0.000)*progress*o; //radius + overcompensation
	// f = abs(cos(a*3.));
	// f = abs(cos(a*2.5))*.5+.3;
	//f = abs(cos(a*16.)*sin(a*12.3))*.01+.21;
 	//f += smoothstep(-.5,1., cos(a*10.))*0.2+0.5;

	 //return a color vector for inner + outer edge
	 float bleed = 1.02;
	c += vec4(vec3( smoothstep(r*bleed, f+stroke, r) ),1.); //this works
	c += vec4(vec3( smoothstep(r, f-stroke, r*pow(bleed, 4.))),1.);

	gl_FragColor = c;
}

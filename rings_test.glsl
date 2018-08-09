#ifndef GL_ES
#version 330
#endif
#define PROCESSING_COLOR_SHADER

//uniform vec2 resolution;
//uniform float progress;

vec2 resolution = u_resolution;
float progress = .5;

float edge = 0.02;
vec3 color = vec3(0);

void drawLine(){
  float g = 1.;
  float e = 2.5;
  color += vec3( smoothstep(progress, 10., progress+edge) );
}
void drawRing(){
  //vec2 st = gl_FragCoord.xy/resolution;
  vec2 pos;
  if (resolution.x < resolution.y) pos = (gl_FragCoord.xy-resolution/2.) * 2. / resolution.y;
  else pos = (gl_FragCoord.xy-resolution/2.) * 2. / resolution.x;

  float r = length(pos);
  float a = atan(pos.y,pos.x);
  float f = cos(a*0.000)*progress*(1.+8.*edge); //radius + overcompensation
  // f = abs(cos(a*3.));
  // f = abs(cos(a*2.5))*.5+.3;
   //f = abs(cos(a*16.)*sin(a*12.3))*.01+.21;
   //f += smoothstep(-.5,1., cos(a*10.))*0.2+0.5;

  color += vec3( smoothstep(r+edge, f, r) );
  color += vec3( smoothstep(r, f, r+edge) );
}
void main(){
  drawRing();
  drawLine();
	gl_FragColor = vec4( color, 1.0 );
}

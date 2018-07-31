
varying vec4 vColor;
varying vec2 vAnchor;

void main () {
	vec4 color = vColor;
	float y = sin(vAnchor.y*10.);
	float thin = .01 + .01/abs(1.-clamp(y*.5+.5,0.,1.));
	float l = abs(vAnchor.x);
	float fadeout = smoothstep(1., .5, l);
	color.a = .5*clamp(thin * fadeout / l, 0., 1.);
	gl_FragColor = color;
}
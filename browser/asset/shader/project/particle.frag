
varying vec4 vColor;
varying vec2 vAnchor;
varying float vDepth;

void main () {
	vec4 color = vColor;
	float thin = .01 + .01/abs(1.-clamp(vAnchor.y*.5+.5,0.,1.));
	float l = abs(vAnchor.x);
	float fadeout = smoothstep(1., .5, l);
	// color.a = pow(color.a, 1./2.2);
	// color.a = clamp(thin * fadeout / l, 0., 1.);
	color.a = clamp(thin * fadeout / l, 0., 1.);
	// color.a = 1.-l;
	gl_FragColor = color;
}
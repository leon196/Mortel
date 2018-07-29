
varying vec4 vColor;
varying vec2 vAnchor;

void main () {
	vec4 color = vColor;
	float thin = .1;
	float l = abs(vAnchor.x);
	float fadeout = smoothstep(1., .5, l);
	color.a = clamp(thin * fadeout / l, 0., 1.);
	gl_FragColor = color;
}
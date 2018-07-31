
varying vec4 vColor;
varying vec3 vView, vNormal;
varying vec2 vAnchor;
varying float vDepth;

void main () {
	vec4 color = vColor;// * (dot(normalize(-vView), normalize(vNormal))*.5+.5);
	float thin = .1;
	float l = abs(vAnchor.y);
	float fadeout = smoothstep(1., .5, l);
	color.a = vDepth;
	// color.a = pow(color.a, 1./2.2);
	// color.a = clamp(thin * fadeout / l, 0., 1.);
	// color.a = 1.-l;
	gl_FragColor = color;
}
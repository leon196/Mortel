
varying vec3 vNormal, vView;

void main () {
	gl_FragColor.rgb = normalize(vNormal)*.5+.5;
	gl_FragColor.a = length(vView);
}
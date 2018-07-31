
attribute vec2 anchor, quantity;
uniform vec3 showFXlines;
varying vec4 vColor;
varying vec2 vAnchor;

void main () {
	float size = .5 * showFXlines.z;
	vColor = vec4(1);
	vAnchor = anchor;
	vec4 pos = modelMatrix * vec4(position, 1);

	float y = anchor.y*.5+.5 ;
	pos.xyz = displace(y);
	vec3 next = displace(y+.001);
	vec3 up = normalize(pos.xyz);
	// vec3 up = normalize(cross(normalize(pos.xyz), normalize(next-pos.xyz)));
	pos.xyz += up * anchor.x * size;

	gl_Position = projectionMatrix * viewMatrix * pos;
}

attribute vec2 anchor, quantity;
varying vec4 vColor;
varying vec2 vAnchor;

void main () {
	float size = .2;
	vColor = vec4(1);
	vAnchor = anchor;
	vec4 pos = modelMatrix * vec4(position, 1);

	float y = anchor.y*.5+.5 ;
	pos.xyz = displace(y);
	vec3 up = normalize(pos.xyz);
	pos.xyz += up * anchor.x * size;

	gl_Position = projectionMatrix * viewMatrix * pos;
}
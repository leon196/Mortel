
attribute vec2 anchor, quantity;
uniform float time;
uniform vec3 uRotation;
varying vec4 vColor;
varying vec2 vAnchor;
varying float vDepth;

vec3 displace (float ratio) {
	vec3 p = vec3(2.+ratio, 0, 0);
	float a = ratio * TAU;// - time * 10.;
	p.xz *= rotation(a*uRotation.y);
	p.yz *= rotation(a*uRotation.x);
	p.yx *= rotation(a*uRotation.z);
	p = mix(vec3(0), p, smoothstep(.0,.1,sin(ratio * PI)));
	return p;
}

void main () {
	float size = .4;
	vColor = vec4(1);
	vAnchor = anchor;
	vec4 pos = modelMatrix * vec4(position, 1);

	float y = anchor.y*.5+.5 ;
	pos.xyz = displace(y);
	vec3 next = displace(y+.01);
	vec3 view = normalize(pos.xyz - cameraPosition);
	vec3 up = normalize(pos.xyz);
	// vec3 right = cross(normalize(next-pos.xyz), up);
	// right = (rotationMatrix(up, PI/2.) * vec4(right, 1.)).xyz;
	pos.xyz += up * anchor.x * 2. * size;

	vDepth = length(pos.xyz - cameraPosition);

	gl_Position = projectionMatrix * viewMatrix * pos;
}

attribute vec2 anchor, quantity;
uniform float time;
uniform vec3 uRotation;
varying vec4 vColor;
varying vec3 vView, vNormal;
varying vec2 vAnchor;
varying float vDepth;

vec3 displace (float ratio) {
	vec3 p = vec3(2.+ratio, 0, 0);
	float a = ratio * TAU;
	p.xz *= rotation(a*uRotation.y);
	p.yz *= rotation(a*uRotation.x);
	p.yx *= rotation(a*uRotation.z);
	p = mix(vec3(0), p, smoothstep(.0,.1,sin(ratio * PI)));
	return p;
}

void main () {
	float range = 3.;
	float size = .01;
	
	vec4 pos = modelMatrix * vec4(position, 1);
	float y = anchor.y*.5+.5;
	float t = quantity.x + anchor.y * .0005 + time * .02;
	float index = floor(t);
	float ratio = mod(t, 1.);
	float fadeout = smoothstep(1., .8, ratio);

	pos.xyz = displace(ratio);
	vec3 next = displace(ratio+.01);
	// pos.xyz *= .01 + y;

	vec3 up = normalize(pos.xyz);
	vec3 right = cross(normalize(next-pos.xyz), up);
	// right = normalize((rotationMatrix(up, sin(anchor.x*3.+time)) * vec4(right, 1.)).xyz);
	float dist = length(anchor);
	float wave = sin(quantity.x*10000.);
	pos.xyz += up * wave * .2;
	pos.xyz += right * anchor.x * size;

	vColor = vec4(1.);
	vAnchor = anchor;
	vView = pos.xyz - cameraPosition;
	vNormal = up;//cross(right, up);
	vDepth = length(pos.xyz - cameraPosition);

	gl_Position = projectionMatrix * viewMatrix * pos;
}
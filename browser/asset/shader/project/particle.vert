
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
	float range = 3.;
	float size = .2;
	vColor = vec4(1);
	vAnchor = anchor;
	
	vec4 pos = modelMatrix * vec4(position, 1);
	float y = anchor.y*.5+.5;
	float t = quantity.x + time * .01;
	float index = floor(t);
	float ratio = mod(t, 1.);
	float fadeout = smoothstep(1., .8, ratio);

	pos.xyz = displace(ratio);
	vec3 next = displace(ratio+.001);


	// vec3 view = pos.xyz - cameraPosition;
	vec3 up = normalize(pos.xyz);
	// vec3 right = normalize(cross(view, up));
	vec3 right = normalize(next-pos.xyz);
	// vec3 right = cross(normalize(next-pos.xyz), up);
	pos.xyz *= .0001 + y;
	pos.xyz += (right * anchor.x * fadeout) * size;

	vDepth = length(pos.xyz - cameraPosition);

	gl_Position = projectionMatrix * viewMatrix * pos;
}
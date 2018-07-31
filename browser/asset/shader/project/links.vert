
attribute vec2 anchor, quantity;
varying vec4 vColor;
varying vec2 vAnchor;

void main () {
	float range = 3.;
	float size = .1;
	vColor = vec4(1);
	vAnchor = anchor;
	
	vec4 pos = modelMatrix * vec4(position, 1);
	float y = anchor.y*.5+.5;
	float t = quantity.x + time;
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

	gl_Position = projectionMatrix * viewMatrix * pos;
}
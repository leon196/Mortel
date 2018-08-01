
uniform float tunnelWalk, tunnelRange, tunnelRadius, tunneTubeRadius;
attribute vec2 anchor, quantity;
varying vec3 vNormal, vView;

vec3 turn (vec3 v, float a) {
	v.zy *= rotation(a * 2. + time);
	v.xz *= rotation(a);
	return v;
}

void main () {
	vec4 pos = vec4(position, 1);
	float salt = random(quantity.xx);
	float bend = .2*smoothstep(-.5,.5,sin((anchor.y-tunnelWalk*2.)*4.+quantity.y));
	float angle = (quantity.x*2.-1.) * PI / 4. - PI/2. + bend;
	vec3 pivot = vec3(tunneTubeRadius, 0, 0.);
	pivot.xy *= rotation(anchor.x*PI/2.+angle+PI);
	
	pos.xy = vec2(cos(angle),sin(angle)) * tunnelRadius;
	pos.z = anchor.y * tunnelRange;
	pos.xyz += pivot;

	vNormal = pivot;
	vView = pos.xyz - cameraPosition;
	gl_Position = projectionMatrix * viewMatrix * pos;
}
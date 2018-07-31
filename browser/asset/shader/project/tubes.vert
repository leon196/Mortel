
attribute vec2 anchor, quantity;
varying vec3 vNormal, vView;

vec3 turn (vec3 v, float a) {
	v.zy *= rotation(a * 2. + time);
	v.xz *= rotation(a);
	return v;
}

void main () {
	float radius = .15;
	float longness = 10.;
	float range = 2.8;
	vec4 pos = vec4(position, 1);
	float salt = random(quantity.xx);
	float bend = .2*smoothstep(-.5,.5,sin(anchor.y*4.+quantity.y));
	float a = (quantity.x*2.-1.) * PI / 4. - PI/2. + bend;
	pos.xy = vec2(cos(a),sin(a)) * range;
	pos.z = 0.;

	vec3 pivot = vec3(1. * radius, 0, 0.);
	pivot.xy *= rotation(anchor.x*PI);
	pos.xyz += pivot;
	vNormal = pivot;

	pos.z += anchor.y * longness;
	vView = pos.xyz - cameraPosition;

	gl_Position = projectionMatrix * viewMatrix * pos;
}
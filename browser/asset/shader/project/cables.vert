
attribute vec2 anchor, quantity;
varying vec3 vNormal, vView;

vec3 turn (vec3 v, float a) {
	v.zy *= rotation(a * 2. + time);
	v.xz *= rotation(a);
	return v;
}

void main () {
	float radius = .05;
	float longness = 10.;
	float range = 2.8;
	vec4 pos = vec4(position, 1);
	float salt = random(quantity.xx);
	float a = PI/2.+(quantity.x-.5) * mix(PI*.75, PI*1., smoothstep(.0, .3, sin(anchor.y*5./* - time*1.2*/)*.5+.5)) + sin(anchor.y*4. + salt * 243./*-time*/) * salt / 2.;
	pos.xy = vec2(cos(a),sin(a)) * range;
	pos.z = 0.;

	// radius += .1 * (.5+.5*sin(anchor.y*20.+time * 10.))*smoothstep(0.0, 1., sin(anchor.y*20. + time * 10.+quantity.x*265.));

	vec3 pivot = vec3(1. * radius, 0, 0.);
	pivot.xy *= rotation(anchor.x*PI);
	pos.xyz += pivot;

	// vNormal = vec3(1,0,0);
	// vNormal.xy *= rotation(anchor.x*PI);
	vNormal = pivot;

	pos.z += anchor.y * longness;
	vView = pos.xyz - cameraPosition;

	gl_Position = projectionMatrix * viewMatrix * pos;
}
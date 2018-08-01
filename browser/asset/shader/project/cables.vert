
uniform float tunnelWalk, tunnelRadius, tunnelRange, tunnelCableRadius, tunnelCableFrequency, tunnelDoors, tunnelCableMess;
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
	float y = anchor.y-tunnelWalk*2.;
	float door = smoothstep(-.75, .75, -cos(y*tunnelDoors*PI+PI));
	door *= smoothstep(0.9, 1., quantity.x);
	float pump = 0.;//.1 * (.5+.5*sin(anchor.y*20.+time * 10.))*smoothstep(0.0, 1., sin(anchor.y*20. + time * 10.+quantity.x*265.));

	float angle = PI/2.+(quantity.x-.5) * mix(PI*.8, PI, door);
	angle += (door*.5+.5) * sin(y*tunnelCableFrequency + salt * TAU) * salt * tunnelCableMess;
	pos.xy = vec2(cos(angle),sin(angle)) * (tunnelRadius-pump);
	pos.z = anchor.y * tunnelRange;

	vec3 pivot = vec3(tunnelCableRadius+pump, 0, 0.);
	pivot.xy *= rotation(anchor.x*PI/2.+angle+PI);
	pos.xyz += pivot;

	vView = pos.xyz - cameraPosition;
	vNormal = pivot;

	gl_Position = projectionMatrix * viewMatrix * pos;
}
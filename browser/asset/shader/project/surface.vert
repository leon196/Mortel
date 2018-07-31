
attribute vec2 anchor, quantity;
varying vec3 vNormal, vView;

vec3 turn (vec3 v, float a) {
	v.xz *= rotation(a * .1);
	v.zy *= rotation(a * .1);
	v.xy *= rotation(a * .2);
	return v;
}

void main () {
	float size = .5;
	vec4 pos = vec4(position, 1);

	// grid distribution	
	float w = 40.;
	float h = 50.;
	vec2 r = vec2(w, h) * size;

	// depth
	pos.z = floor(quantity.y/w)/h;
	pos.z = mod(pos.z + time * .1, 1.);
	float fade = smoothstep(.0, .1, pos.z) * smoothstep(1., .9, pos.z);
	pos.z = (pos.z - .5)*r.y;

	pos.x = mod(quantity.y,w)/w;
	pos.y = 0.;
	// pos.x = (pos.x-.5) * r.x + size;
	float a = pos.x * TAU;
	a += floor(quantity.y/w)*PI/w;
	pos.xy = vec2(cos(a),sin(a))*r.x/TAU;

	// pos.xz *= rotation(pos.z*.05);

	float salt = random(quantity.xx);
	float dist = length(pos);
	float blend = smoothstep(.0, .1, 1./abs(pos.z));
	float angle = salt * TAU;

	vec3 pivot = vec3(anchor.x, 0, anchor.y);
	pivot = lookAt(pos.xyz, vec3(0,0,pos.z), anchor);
	// pivot = mix(pivot, turn(pivot, angle), blend);
	// pos.xyz *= mix(1., 1.+salt*.5, blend);

	vNormal = normalize(vec3(0,0,pos.z) - pos.xyz);
	vNormal = mix(vNormal, turn(vNormal, angle), blend);

	pos.xyz += pivot * size * fade;
	vView = pos.xyz - cameraPosition;

	gl_Position = projectionMatrix * viewMatrix * pos;
}
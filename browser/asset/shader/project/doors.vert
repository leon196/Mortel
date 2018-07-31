
attribute vec2 anchor, quantity;
varying vec3 vNormal, vView;

void main () {
	float range = 2.89;
	vec4 pos = vec4(position, 1);

	pos.xy = vec2(-range, 0.);
	pos.z = (quantity.x*2.-1.) * 20.;

	pos.xy *= rotation(.3+anchor.y*.4-.1*sin((anchor.x*.5+.5)*PI)*step(anchor.y,.5));
	pos.z += anchor.x * .6;
	// pos.yz += vec2(anchor.x, anchor.y);
	vNormal = vec3(0);
	vView = pos.xyz - cameraPosition;

	gl_Position = projectionMatrix * viewMatrix * pos;
}
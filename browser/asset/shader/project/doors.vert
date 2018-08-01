
uniform float tunnelWalk, tunnelRange, tunnelRadius, tunnelDoors, tunnelDoorWidth, tunnelDoorHeight, tunnelDoorArc, tunnelDoorGround;
attribute vec2 anchor, quantity;
varying vec3 vNormal, vView;

void main () {
	vec4 pos = vec4(position, 1);

	pos.xy = vec2(-tunnelRadius+.01, 0.);
	float x = mod(quantity.y/tunnelDoors + tunnelWalk, 1.);
	pos.z = (x*2.-1.) * tunnelRange;	

	pos.xy *= rotation(tunnelDoorGround+anchor.y*tunnelDoorHeight-tunnelDoorArc*sin((anchor.x*.5+.5)*PI)*step(anchor.y,.5));
	pos.z += anchor.x * tunnelDoorWidth;

	vNormal = vec3(0);
	vView = pos.xyz - cameraPosition;

	gl_Position = projectionMatrix * viewMatrix * pos;
}
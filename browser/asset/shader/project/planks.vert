
uniform float tunnelWalk, tunnelRadius, tunnelRange, tunnelPlankCount;
attribute vec2 quantity;
varying vec3 vNormal, vView;

void main () {
	float count = tunnelPlankCount/2.;
	float x = floor(quantity.x*count)/count;
	float depth = mod(x+tunnelWalk, 1.);
	float isPlank = step(mod(quantity.y, 2.), .5);
	vec3 scale = mix(vec3(.05,1.,.05), vec3(1.5,.05,.4), isPlank);
	scale *= smoothstep(.0, .2, depth) * smoothstep(1., .8, depth);
	vec3 offset = vec3(0,-tunnelRadius*.9,0);
	offset.xy *= rotation(mix(-.53, -.82, isPlank));
	vec4 pos = modelMatrix * vec4(position*scale+offset, 1);
	pos.z += (depth*2.-1.)*tunnelRange;
	vView = pos.xyz - cameraPosition;
	vNormal = normal;
	vNormal.xz *= rotation(quantity.x*5.);
	vNormal.yz *= rotation(quantity.x*5.);
	gl_Position = projectionMatrix * viewMatrix * pos;
}
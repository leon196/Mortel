

uniform float tunnelWalk, tunnelTileSize, tunnelTileWidth, tunnelTileCount, tunnelRange, tunnelRadius;
attribute vec2 anchor, quantity;
varying vec3 vNormal, vView;

vec3 turn (vec3 v, float a) {
	v.xz *= rotation(a * .1);
	v.zy *= rotation(a * .1);
	v.xy *= rotation(a * .1);
	return v;
}

void main () {
	float width = tunnelTileWidth;
	float height = tunnelTileCount/width;
	float salt = random(quantity.xx);

	float depth = floor(quantity.y/width)/height;
	depth = mod(depth+tunnelWalk, 1.);
	float fade = smoothstep(.0, .2, depth) * smoothstep(1., .8, depth);
	// float blend = smoothstep(.0, .1, 1./abs(blend));
	float angle = mod(quantity.y,width)/width * TAU;
	angle += floor(quantity.y/width)*PI/width;
	
	vec4 pos = vec4(position, 1);
	pos.xy = vec2(cos(angle),sin(angle))*tunnelRadius;
	vec3 right = vec3(0,0,1);
	vec3 up = cross(right, normalize(vec3(pos.x, pos.y, 0.)));
	pos.z = (depth*2.-1.)*tunnelRange;
	// pos.xyz *= mix(1., 1.+salt*.5, blend);

	// pivot = lookAt(pos.xyz, vec3(0,0,pos.z), anchor);
	pos.xyz += (up * anchor.y + right * anchor.x) * tunnelTileSize * fade;
	// pivot = mix(pivot, turn(pivot, angle), blend);


	vView = pos.xyz - cameraPosition;
	vNormal = normalize(vec3(0,0,pos.z) - pos.xyz);
	vNormal = turn(vNormal, salt * TAU);

	gl_Position = projectionMatrix * viewMatrix * pos;
}
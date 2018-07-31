
uniform sampler2D sceneFX, sceneSDF, sceneMesh;
uniform vec2 resolution;
uniform vec3 cameraPos, cameraTarget;
varying vec2 vUv;

float lines (float value) {
	return smoothstep(1., 0., sin(value*resolution.y/TAU*8.));
}

void main () {

	vec2 uv = vUv;

	vec4 fx = texture2D(sceneFX, vUv);
	vec4 sdf = texture2D(sceneSDF, vUv);
	vec4 mesh = texture2D(sceneMesh, vUv);
	float edgy = smoothstep(.5, 0., luminance(edgeSD(sceneMesh, vUv, resolution).rgb));
	vec4 color = vec4(1);
	float depthSDF = mix(sdf.a, 1000.,step(sdf.a,0.0001));
	float depthMesh = mix(mesh.a, 1000.,step(mesh.a,0.0001));
	color.rgb = mix(sdf.rgb, mesh.rgb, step(depthMesh, depthSDF));
	
	vec2 screen = vUv * 2. - 1.;
	screen.x *= resolution.x / resolution.y;
	float salt = random(vUv);
	vec3 view = lookAt(cameraPos, cameraTarget, screen);
	vec3 normal = color.rgb*2.-1.;
	vec3 position = cameraPos + view * depthMesh;
	float water = step(position.y, -2.8);
	
	float far = step(.001, length(color.rgb));
	// far *= smoothstep(20., 10., depthMesh);
	float shade = (dot(normalize(normal), -view)*.5+.5);
	// shade *= abs(dot(normalize(normal), normalize(vec3(0,1,0))));
	float hashes = 1.;
	hashes *= mix(1., lines(screen.x+screen.y), smoothstep(.7, .3, shade));
	hashes *= mix(1., lines(screen.x-screen.y), smoothstep(.5, .3, shade));
	hashes = mix(hashes, 0., smoothstep(.2, .0, shade));


	// shade *= shade;
	color.rgb = vec3(hashes * step(.01, shade));
	// color.rgb *= shade;
	color.rgb *= edgy;
	color.rgb *= .9+salt*.1;
	color.rgb = 1.-color.rgb;
	// color.rgb = normal * .5 + .5;
	color.rgb *= far;
	color.rgb += fx.rgb;

	vec2 p = abs(vUv*2.-1.);
	color.rgb *= .25+.75*(1.-pow(p.x, 8.));
	color.rgb *= .25+.75*(1.-pow(p.y, 8.));
	color.a = depthMesh;
	// color.rgb += abs(fract(position));
	gl_FragColor = color;
}
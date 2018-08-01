
uniform sampler2D scene;
uniform vec2 resolution;
uniform vec3 cameraPos, cameraTarget;
varying vec2 vUv;

void main () {
	vec2 uv = vUv;
	vec2 screen = vUv * 2. - 1.;
	screen.x *= resolution.x / resolution.y;
	vec4 color = texture2D(scene, uv);
	// vec4 color;
	// float a = 0.;
	// float r = .01 * length(screen);
	// vec2 offset = vec2(cos(a),sin(a))*r;
	// color.r += texture2D(scene, uv + offset).r;
	// a += TAU/3.;
	// offset = vec2(cos(a),sin(a))*r;
	// color.g += texture2D(scene, uv + offset).g;
	// a += TAU/3.;
	// offset = vec2(cos(a),sin(a))*r;
	// color.b += texture2D(scene, uv + offset).b;

	vec3 view = lookAt(cameraPos, cameraTarget, screen);
	vec3 position = cameraPos + view * color.a;

/*
	float waterLevel = -2.+.2*sin(position.z*2.);
	float water = step(position.y, waterLevel);
	// water += step(cameraPos.y, waterLevel);
	water = clamp(water, 0., 1.);
	water *= smoothstep(abs(waterLevel), abs(waterLevel)-.1, abs(position.x));
	float a = sin(position.z*4.+time+sin(screen.y*20.)*2.)*TAU*2.;
	// uv += vec2(cos(a),sin(a))*.002*water*sin(position.z*2.);
	float freq = 100.;
	float strength = .005;
	uv.y += strength*abs(sin(screen.y*freq))*water;
	color = mix(color, texture2D(scene, uv), water);

	// uv = vUv;
	uv.y = 1.-uv.y;
	color = mix(color, texture2D(scene, uv), water*.5);
*/
	gl_FragColor = color;
}
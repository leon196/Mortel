
precision mediump float;

uniform vec2 resolution;
uniform vec3 cameraPos, cameraTarget;

const float steps = 20.;
const float count = 8.;
const float far = 100.;

float fbm (in vec3 seed) {
    float value = 0.0;
    float amplitude = .5;
    float t = time * .02;
    const float steps = 6.;
    for (float i = steps; i > 0.; --i) {
    	float ratio = 1.-i / steps;
      value += amplitude * noise(seed);
      seed *= 2.;
      seed += t*.2;
      seed.xz *= rotation(t*ratio*.1);
      seed.yz *= rotation(t+ratio*.2);
      seed.yx *= rotation(t+ratio*.5);
      amplitude *= .6;
    }
    return value;
}

Shape sdf (vec3 pos) {
	Shape scene;
	scene.dist = 10.;
	scene.mat = 0.;
	scene.pos = pos;

	Shape spheres;
	spheres.dist = 10.;
	spheres.mat = 1.;
	float outer = 4.;
	float inner = 2.;
	float range = .5;
	vec3 p = pos;
	for (float i = count; i > 0.; --i) {
		float r = i / count;
		p = abs(p) - range * r;
		p.xz *= rotation(PI/8.+time*r *.1);
		spheres.dist = min(spheres.dist, max(p.x, max(p.y, p.z)));
		spheres.pos = p;
	}
	spheres.dist = max(-spheres.dist, sdbox(pos, vec3(outer)));
	spheres.dist = max(spheres.dist, -sdbox(pos, vec3(inner)));
	shmin(scene, spheres);
	
	return scene;
}

Shape sdfAlpha (vec3 pos) {

	float outer = 5.;
	float thin = .1;

	Shape orb;
	orb.dist = sdist(pos, outer-thin);
	orb.mat = 3.;
	orb.pos = pos;
	orb.density = vec3(.01, .1, .01);

	return orb;
}

vec3 getNormal (vec3 p) { vec2 e = vec2(.001,0); return normalize(vec3(sdf(p+e.xyy).dist-sdf(p-e.xyy).dist,sdf(p+e.yxy).dist-sdf(p-e.yxy).dist,sdf(p+e.yyx).dist-sdf(p-e.yyx).dist)); }

float getShadow (vec3 pos, vec3 at, float k) {
	vec3 dir = normalize(at);
	float maxt = length(at - pos);
	float f = 1.;
	float t = .01;
	for (float i = 0.; i <= 1.; i += 1./30.) {
		float dist = sdf(pos + dir * t).dist;
		if (dist < .001) return 0.;
		f = min(f, k * dist / t);
		t += dist;
		if (t >= maxt) break;
	}
	return f;
}

Shape raymarching (vec3 pos, vec3 ray, inout vec4 hit)
{
	Shape shape;
	// float dither = random(gl_FragCoord.xy/resolution.xy);
	float total = 0.;
	for (float i = steps; i >= 0.; --i) {

		shape = sdf(pos);
		
		if (shape.dist < .001 * total || total > far) {
			hit.xyz = pos;
			hit.w = i/steps;
			break;
		}

		// shape.dist *= .5;
		// shape.dist *= .9 + .1 * dither;
		total += shape.dist;
		pos += ray * shape.dist;
	}
	return shape;
}

vec3 lighting (Shape shape, vec3 ray, vec4 hit)
{
	vec3 color = vec3(1.);
	vec3 pos = shape.pos;

	vec3 lightPos = vec3(1, 1, 1);

	vec3 ambient = vec3(0);
	vec3 light = vec3(1);
	vec3 specular = vec3(0);
	float specularSharpness = 2.;
	vec3 glow = vec3(0);
	float glowSharpness = 1.;
	vec3 shadow = vec3(0);
	float shadowSharpness = 64.;

	pos = hit.xyz;
	float tile = 8.;
	float thin = .01;
	float pattern =  1.-(clamp(thin/abs(sin(pos.x*tile)*sin(pos.y*tile)*sin(pos.z*tile)), 0., 1.));

	vec3 normal = getNormal(pos);

	vec3 view = normalize(cameraPos-pos);
	vec3 lightDir = normalize(lightPos);
	float lightIntensity = clamp(dot(lightDir, normal),0.,1.);
	float specularIntensity = saturate(pow(max(0., dot(reflect(-lightDir, normal), view)), specularSharpness));
	float glowIntensity = saturate(pow(abs(1.-abs(dot(normal, view))), glowSharpness));

	color = ambient + light * lightIntensity + specular * specularIntensity + glow * glowIntensity;
	color *= .1+.9*getShadow(pos, lightPos, 10.);
	return saturate(color);
}

void main () {
	vec2 uv = (gl_FragCoord.xy-.5*resolution.xy)/resolution.y;
	vec3 ray = lookAt(cameraPos, cameraTarget, uv);
	vec4 hit, hitAlpha;

	vec3 color = lighting(raymarching(cameraPos, ray, hit), ray, hit);
	color = vec3(pow(color.r, 1./2.2));
	gl_FragColor = vec4(color, length(hit.xyz-cameraPos));
}

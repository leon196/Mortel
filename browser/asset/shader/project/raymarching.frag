
precision mediump float;

uniform vec2 resolution;
uniform vec3 cameraPos, cameraTarget;

const float steps = 20.;
const float count = 4.;
const float far = 10.;

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
	float range = 1.;
	float radius = 1.;
	float smoo = .1;
	vec3 p = pos;
	for (float i = count; i > 0.; --i) {
		float r = i / count;
		r *= r;
		p = abs(p) - range * r;
		p.xz *= rotation(time);
		p.yz *= rotation(time);
		p.yx *= rotation(time);
		// spheres.dist = min(spheres.dist, max(p.x, max(p.y, p.z)));
		spheres.dist = smin(spheres.dist, sdist(p, radius*r), smoo*r);
		spheres.pos = p;
	}
	// spheres.dist = max(-spheres.dist, sdbox(pos, vec3(outer)));
	// spheres.dist = max(spheres.dist, -sdbox(pos, vec3(inner)));
	shmin(scene, spheres);
	
	return scene;
}

vec3 getNormal (vec3 p) { vec2 e = vec2(.001,0); return normalize(vec3(sdf(p+e.xyy).dist-sdf(p-e.xyy).dist,sdf(p+e.yxy).dist-sdf(p-e.yxy).dist,sdf(p+e.yyx).dist-sdf(p-e.yyx).dist)); }

Shape raymarching (vec3 pos, vec3 ray, inout vec4 hit)
{
	Shape shape;
	float total = 0.;
	for (float i = steps; i >= 0.; --i) {
		shape = sdf(pos);
		if (shape.dist < .001 * total || total > far) {
			hit.xyz = pos;
			hit.w = i/steps;
			break;
		}
		total += shape.dist;
		pos += ray * shape.dist;
	}
	return shape;
}


void main () {
	vec2 uv = (gl_FragCoord.xy-.5*resolution.xy)/resolution.y;
	vec3 ray = lookAt(cameraPos, cameraTarget, uv);
	vec4 hit = vec4(cameraPos, 0.);
	raymarching(cameraPos, ray, hit);
	vec3 normal = getNormal(hit.xyz);
	gl_FragColor = vec4(normal, length(hit.xyz-cameraPos));
}

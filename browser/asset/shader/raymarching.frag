
precision mediump float;

uniform float time;
uniform vec2 resolution;
uniform vec3 cameraPos, cameraTarget;

const float far = 20.;

#define repeat(p,r) (mod(p,r)-r/2.)
#define sdist(p,r) (length(p)-r)
// #define saturate(p) clamp(p,1.,0.)
float sdbox( vec3 p, vec3 b ) { vec3 d = abs(p) - b; return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)); }
float sdtorus( vec3 p, vec2 t ) { vec2 q = vec2(length(p.xz)-t.x,p.y); return length(q)-t.y; }
float smin (float a, float b, float r) { float h = clamp(.5+.5*(b-a)/r, 0., 1.); return mix(b, a, h)-r*h*(1.-h); }
void amod (inout vec2 p, float c) {
	float an = (3.1459*2.)/c;
	float a = atan(p.y,p.x)+an/2.;
	a = mod(a, an) - an/2.;
	p = vec2(cos(a), sin(a)) * length(p);
}
vec3 look (vec3 eye, vec3 target, vec2 anchor) {
	vec3 forward = normalize(target-eye);
	vec3 right = normalize(cross(forward, vec3(0,1,0)));
	vec3 up = normalize(cross(right, forward));
	return normalize(forward + right * anchor.x + up * anchor.y);
}
struct Shape { float dist, mat; vec3 pos; };
void shmin (inout Shape a, Shape b) {
	float ab = step(a.dist, b.dist);
	a.dist = min(a.dist, b.dist);
	a.mat = mix(b.mat, a.mat, ab);
	a.pos = mix(b.pos, a.pos, ab);
}
void shminsmooth (inout Shape a, Shape b, float r) {
	float ab = clamp(.5+.5*(b.dist-a.dist)/r, 0., 1.);
	a.dist = mix(b.dist, a.dist, ab)-r*ab*(1.-ab);
	a.mat = mix(b.mat, a.mat, ab);
	a.pos = mix(b.pos, a.pos, ab);
}
void shmax (inout Shape a, Shape b) {
	float ab = step(b.dist, a.dist);
	a.mat = mix(a.mat, b.mat, ab);
	a.pos = mix(a.pos, b.pos, ab);
}

Shape sdf (vec3 pos) {
	Shape scene;
	scene.dist = 10.;
	scene.mat = 0.;
	scene.pos = pos;
	vec3 p;

	// pos.xz = repeat(pos.xz, 4.);
// pos /= (dot(pos*pos,pos*pos));

	p = pos;
	Shape structure;
	structure.dist = 10.;
	structure.mat = 0.;


	float breath = sin(time - length(pos)*4. + atan(pos.z, pos.y));



	const float count = 8.;
	float s = .05;// + .1 * wave;
	float u = .4 + .1 * breath;// + .1 * wave;
	float c = 2.;
	float h = .5 - .5 * breath;
	float smoo = .2 + .1 * breath;
	vec3 pp;
	for (float i = count; i > 0.; --i) {
		float r = i / count;
		// r = sin(r*PI);
		r *= r;
		// r = 1.-r;
		float side = sign(p.x);

		float y = pos.y * 8.;// + time;// * side;
		float wave = sin(y + atan(p.x,p.z) * 2. + i);
		wave = wave * .5 + .5;
		float cc = s*32.*r;

		p.xz = abs(p.xz) - u * r;
		p.xz *= rot(+.5);
		p.yz *= rot(+-.5);
		p.yx *= rot(+r*breath*.1+2.);
		pp = p;
		// pp.z = repeat(pp.z, cc);
		// pp.yz *= rot(p.x*10. * r + time);
		// pp.y -= .01 * r;
		// float ic = floor(pp.x/cc);
		// pp.x = repeat(pp.x, cc);
		// pp.x += sin(time * 4. + ic * .5 + i * .5) * cc * .2;
		// pp.yz *= rot(ic + time);
		// p.xz = abs(p.xz) - u * r;
		// p.x -= u * r;
		// structure.dist = sdbox(pp, vec3(s * r));
		structure.dist = sdist(pp.yz, s * r);
		structure.dist = max(abs(pp.x)-h*r, structure.dist);
		// structure.dist = smin(structure.dist, sdist(pp.yx, s * r), smoo * r);
		// structure.dist = max(abs(pp.z)-h*r, structure.dist);
		// structure.dist = smin(structure.dist, sdbox(pp, vec3(.4,1,1)*s*r), smoo * r);
		structure.pos = pp;		
		shminsmooth(scene, structure, smoo * r);

		// pp = p;
		// pp.xz = abs(pp.xz) - .3 * r * wave;
		// structure.dist = sdist(pp.yx, .01 * r);
		// structure.pos = pp;
		// shminsmooth(scene, structure, .1 * r);
	}
	return scene;
}

vec3 getNormal (vec3 p) { vec2 e = vec2(.001,0); return normalize(vec3(sdf(p+e.xyy).dist-sdf(p-e.xyy).dist,sdf(p+e.yxy).dist-sdf(p-e.yxy).dist,sdf(p+e.yyx).dist-sdf(p-e.yyx).dist)); }

float getShadow (vec3 pos, vec3 at, float k) {
	vec3 dir = normalize(at - pos);
	float maxt = length(at - pos);
	float f = 1.;
	float t = .01;
	for (float i = 0.; i <= 1.; i += 1./60.) {
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
	const float steps = 100.;
	float dither = rand(gl_FragCoord.xy/resolution.xy);
	float total = 0.;
	float volume = 0.;
	for (float i = steps; i >= 0.; --i) {
		shape = sdf(pos);

		if (shape.dist < .001 * total || total > far) {
			hit.xyz = pos;
			hit.w = i/steps;
			break;
		}

		shape.dist *= .5;// + .1 * dither;
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
	// lightPos.xz *= rot(time);

	vec3 ambient = vec3(.5);
	vec3 light = vec3(.5);
	vec3 specular = vec3(0);
	float specularSharpness = 10.;
	vec3 glow = vec3(0);
	float glowSharpness = .5;
	vec3 shadow = vec3(.5);
	float shadowSharpness = 64.;


	float tile = 32.;
	float thin = .2;
	float pattern =  1.-(clamp(thin/abs(sin(pos.x*tile)*sin(pos.y*tile)*sin(pos.z*tile)), 0., 1.));


	pos = hit.xyz;
	vec3 normal = getNormal(pos);
	// vec3 bump = smoothstep(.9, 1., (sin(pos.yyy*100.)));
	// vec3 seed = pos * 20.;
	// vec3 bump = vec3(noiseIQ(seed), noiseIQ(seed+vec3(1.213094,9.59419,4.1429)), noiseIQ(seed+vec3(95.25129,410.5491,501.43)))*2.-1.;
	// normal = normalize(normal + bump * .5);
	// float a = sin(pos.y*200.) * .1;
	// normal.zy *= rot(a);

	vec3 view = normalize(cameraPos-pos);
	vec3 lightDir = normalize(lightPos);
	// vec3 lightDir = normalize(lightPos-pos);
	// vec3 lightDir = -ray;
	float lightIntensity = clamp(dot(lightDir, normal),0.,1.);
	float specularIntensity = saturate(pow(max(0., dot(reflect(-lightDir, normal), view)), specularSharpness));
	float glowIntensity = pow(abs(1.-abs(dot(normal, view))), glowSharpness);
	// float shadowIntensity = getShadow(pos, lightPos, shadowSharpness)*lightIntensity;
	// shadowIntensity = step(.001, lightIntensity);

	color = ambient + light * lightIntensity + specular * specularIntensity + glow * glowIntensity;
	color *= hit.w;
	// color = 1.-color;
	// color = mix(color * shadow, color, shadowIntensity);

	color *= step(length(cameraPos-pos), far);
	// color = normal * .5 + .5;

	return saturate(color);
}

void main () {
	vec2 uv = (gl_FragCoord.xy-.5*resolution.xy)/resolution.y;
	vec3 ray = look(cameraPos, cameraTarget, uv);
	vec4 hit;

	Shape shape = raymarching(cameraPos, ray, hit);
	vec3 color = lighting(shape, ray, hit);

	gl_FragColor = vec4(color, 1);
}

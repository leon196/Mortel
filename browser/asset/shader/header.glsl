
// project specific

uniform float time;
uniform vec3 uRotation;

// generic

#define PI 3.14159
#define PI2 6.28318
#define TAU 6.28318
#define HALFPI 1.57079
#define HALF3PI 4.71238

// https://www.shadertoy.com/view/4dS3Wd
float random (in vec2 st) { return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123); }
float hash(float n) { return fract(sin(n) * 1e4); }
float hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }
float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}
float noise(vec3 x) {
    const vec3 step = vec3(110, 241, 171);
    vec3 i = floor(x);
    vec3 f = fract(x);
    float n = dot(i, step);
    vec3 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),
                   mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),
               mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),
                   mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);
}

vec3 lookAt (vec3 eye, vec3 target, vec2 anchor) {
	vec3 forward = normalize(target-eye);
	vec3 right = normalize(cross(forward, vec3(0,1,0)));
	vec3 up = normalize(cross(right, forward));
	return normalize(forward + right * anchor.x + up * anchor.y);
}

mat2 rotation (float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }
mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    return mat4(oc*axis.x*axis.x + c, oc*axis.x*axis.y - axis.z*s, oc*axis.z*axis.x + axis.y*s, 0.0,
                oc*axis.x*axis.y + axis.z*s, oc*axis.y*axis.y + c, oc*axis.y*axis.z - axis.x*s, 0.0,
                oc*axis.z*axis.x - axis.y*s, oc*axis.y*axis.z + axis.x*s, oc*axis.z*axis.z + c, 0.0,
                0.0, 0.0, 0.0, 1.0);
}

// http://mercury.sexy/hg_sdf/
float pModPolar(inout vec2 p, float repetitions) {
	float angle = 2.*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
	a = mod(a,angle) - angle/2.;
	p = vec2(cos(a), sin(a))*r;
	if (abs(c) >= (repetitions/2.)) c = abs(c);
	return c;
}

float colorDistance (vec4 a, vec4 b) { return (abs(a.r-b.r)+abs(a.g-b.g)+abs(a.b-b.b))/3.0; }
float luminance ( vec3 color ) { return (color.r + color.g + color.b) / 3.0; }
float luminance ( vec4 color ) { return (color.r + color.g + color.b + color.a) / 4.0; }
float range (float fromA, float toA, float fromB, float toB, float value) { return smoothstep(fromA, toA, value) * (1. - smoothstep(fromB, toB, value)); }
float reflectance(vec3 a, vec3 b) { return dot(normalize(a), normalize(b)) * 0.5 + 0.5; }
vec2 kaelidoGrid(vec2 p) { return vec2(step(mod(p, 2.0), vec2(1.0))); }

vec4 edgeSD (sampler2D bitmap, vec2 uv, vec2 dimension)
{
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);

    color += abs(texture2D(bitmap, uv + vec2(1, 0) / dimension) - texture2D(bitmap, uv + vec2(-1, 0) / dimension));
    color += abs(texture2D(bitmap, uv + vec2(0, 1) / dimension) - texture2D(bitmap, uv + vec2(0, -1) / dimension));

    return color / 2.;
}

vec4 edge (sampler2D bitmap, vec2 uv, vec2 dimension)
{
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);

    color += -1.0 * texture2D(bitmap, uv + vec2(-2, -2) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2(-2, -1) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2(-2,  0) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2(-2,  1) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2(-2,  2) / dimension);

    color += -1.0 * texture2D(bitmap, uv + vec2(-1, -2) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2(-1, -1) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2(-1,  0) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2(-1,  1) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2(-1,  2) / dimension);

    color += -1.0 * texture2D(bitmap, uv + vec2( 0, -2) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2( 0, -1) / dimension);
    color += 24.0 * texture2D(bitmap, uv + vec2( 0,  0) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2( 0,  1) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2( 0,  2) / dimension);

    color += -1.0 * texture2D(bitmap, uv + vec2( 1, -2) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2( 1, -1) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2( 1,  0) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2( 1,  1) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2( 1,  2) / dimension);

    color += -1.0 * texture2D(bitmap, uv + vec2( 2, -2) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2( 2, -1) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2( 2,  0) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2( 2,  1) / dimension);
    color += -1.0 * texture2D(bitmap, uv + vec2( 2,  2) / dimension);

    return color;
}

// https://stackoverflow.com/questions/15095909/from-rgb-to-hsv-in-opengl-glsl
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define repeat(p,r) (mod(p,r)-r/2.)
#define sdist(p,r) (length(p)-r)

float sdbox( vec3 p, vec3 b ) { vec3 d = abs(p) - b; return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)); }
float sdtorus( vec3 p, vec2 t ) { vec2 q = vec2(length(p.xz)-t.x,p.y); return length(q)-t.y; }
float smin (float a, float b, float r) { float h = clamp(.5+.5*(b-a)/r, 0., 1.); return mix(b, a, h)-r*h*(1.-h); }
void amod (inout vec2 p, float c) {
    float an = (3.1459*2.)/c;
    float a = atan(p.y,p.x)+an/2.;
    a = mod(a, an) - an/2.;
    p = vec2(cos(a), sin(a)) * length(p);
}
struct Shape { float dist, mat; vec3 pos, density; };
void shmin (inout Shape a, Shape b) {
    float ab = step(a.dist, b.dist);
    a.dist = min(a.dist, b.dist);
    a.mat = mix(b.mat, a.mat, ab);
    a.density = mix(b.density, a.density, ab);
    a.pos = mix(b.pos, a.pos, ab);
}
void shminsmooth (inout Shape a, Shape b, float r) {
    float ab = clamp(.5+.5*(b.dist-a.dist)/r, 0., 1.);
    a.dist = mix(b.dist, a.dist, ab)-r*ab*(1.-ab);
    a.mat = mix(b.mat, a.mat, ab);
    a.density = mix(b.density, a.density, ab);
    a.pos = mix(b.pos, a.pos, ab);
}
void shmax (inout Shape a, Shape b) {
    float ab = step(a.dist, b.dist);
    a.dist = max(a.dist, b.dist);
    a.mat = mix(a.mat, b.mat, ab);
    a.density = mix(a.density, b.density, ab);
    a.pos = mix(a.pos, b.pos, ab);
}


// project specific

vec3 displace (float ratio) {
    vec3 p = vec3(ratio*2., 0, 0);
    float a = (ratio - time) * TAU;
    p.xz *= rotation(sin(a*uRotation.y)*TAU*2.);
    p.yz *= rotation(sin(a*uRotation.x)*TAU*2.);
    p.yx *= rotation(sin(a*uRotation.z)*TAU*2.);
    // vec3 range = vec3(1.5);
    // p.y = max(p.y, 0.);
    // p = mix(vec3(0), p, smoothstep(.0,.1,sin(ratio * PI)));
    return p;
}
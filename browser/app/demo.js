
import * as THREE from 'three.js';
import { OrbitControls } from './libs/OrbitControls';
import assets from './engine/assets';
import renderer from './engine/renderer';
import parameters from './engine/parameters';
import { clamp, lerp, lerpArray, lerpVector, lerpVectorArray, saturate } from './engine/misc';
import * as timeline from './engine/timeline';
import * as makeText from './engine/make-text';
import Mouse from './engine/mouse';
import Geometry from './engine/geometry';
import FrameBuffer from './engine/framebuffer';
import { gui } from './engine/gui';

export default function() {
	var scene, sceneSDF, sceneFX, sceneMesh, camera, controls, uniforms;
	var frameSDF, frameFX, frameMesh;
	var keys, deltas;

	assets.load(function() {
		scene = new THREE.Scene();
		sceneSDF = new THREE.Scene();
		sceneFX = new THREE.Scene();
		sceneMesh = new THREE.Scene();
		frameSDF = new FrameBuffer();
		frameFX = new FrameBuffer();
		frameMesh = new FrameBuffer();
		
		camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.01, 2000);
		camera.position.x = 0;
		camera.position.y = 2.5;
		camera.position.z = 5;

		controls = new OrbitControls(camera, renderer.domElement);
		controls.enableDamping = true;
		controls.dampingFactor = 0.5;
		controls.rotateSpeed = 0.25;

		uniforms = {
			time: { value: 0 },
			resolution: { value: [window.innerWidth, window.innerHeight] },
			cameraPos: { value: camera.position },
			cameraTarget: { value: controls.target },
			uRotation: { value: [0,0,0] },
			sceneFX: { value: frameFX.getTexture() },
			sceneSDF: { value: frameSDF.getTexture() },
			sceneMesh: { value: frameMesh.getTexture() },
		}
		keys = Object.keys(assets.animations.actions);
		deltas = {};
		keys.forEach(name => {
			uniforms[name] = {value:[0,0,0]};
			deltas[name] = [0,0,0];
		});

		add(assets.shaders.render);
		// add(assets.shaders.raymarching, [ new THREE.PlaneGeometry(1,1) ], sceneSDF);
		add(assets.shaders.surface, Geometry.create(Geometry.random(2000)), sceneMesh);
		add(assets.shaders.tubes, Geometry.create(Geometry.random(40), [8,100]), sceneMesh);
		// add(assets.shaders.links, Geometry.create(Geometry.random(100)), sceneFX);
		// add(assets.shaders.flux, Geometry.create(Geometry.random(1000), [1,4]), sceneFX);
		// add(assets.shaders.lines, Geometry.create(Geometry.random(1), [1,1000]), sceneFX);
		
		onWindowResize();
		window.addEventListener('resize', onWindowResize, false);
		requestAnimationFrame(animate);
		timeline.start();
	});

	function add(material, geometries, sceneLayer, matrix) {
		material.uniforms = uniforms;
		sceneLayer = sceneLayer || scene;
		geometries = geometries || [ new THREE.PlaneGeometry(1,1) ];
		matrix = matrix || new THREE.Matrix4();
		geometries.forEach(geometry => {
			var mesh = new THREE.Mesh(geometry, material);
			mesh.frustumCulled = false;
			mesh.applyMatrix(matrix);
			sceneLayer.add(mesh);
		});
	}

	function animate(elapsed) {
		requestAnimationFrame(animate);
		// elapsed /= 1000.;
		elapsed = timeline.getTime();
		controls.update();
		
		uniforms.time.value = elapsed;
		uniforms.cameraPos.value = camera.position;
		uniforms.cameraTarget.value = controls.target;
		uniforms.uRotation.value[0] = parameters.debug.rotationX;
		uniforms.uRotation.value[1] = parameters.debug.rotationY;
		uniforms.uRotation.value[2] = parameters.debug.rotationZ;
		keys.forEach(name => {
			var pos = assets.animations.getPosition(name, elapsed);
			deltas[name] = lerpArray(deltas[name], pos, .1);
			uniforms[name].value = pos;
		});
		
		frameFX.record(sceneFX, camera);
		frameSDF.record(sceneSDF, camera);
		frameMesh.record(sceneMesh, camera);
		renderer.render(scene, camera);
	}

	function onWindowResize() {
		var w = window.innerWidth / renderer.scale;
		var h = window.innerHeight / renderer.scale;
		renderer.setSize(window.innerWidth, window.innerHeight);
		uniforms.resolution.value[0] = w;
		uniforms.resolution.value[1] = h;
		frameFX.setSize(w,h);
		frameSDF.setSize(w,h);
		frameMesh.setSize(w,h);
		camera.aspect = w/h;
		camera.updateProjectionMatrix();
	}
}

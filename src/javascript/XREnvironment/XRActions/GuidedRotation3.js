import * as THREE from 'three'
import XREnvironment from '../XREnvironment'

export default class GuidedRotation3 {
    constructor(object3D, gesture = 'pan', pivot, axis) {
        this.xrManager = new XREnvironment();
        this.gestures = this.xrManager.gestures;
        this.scene = this.xrManager.scene;
        this.viewRay = this.gestures.raycasters.view.ray;
        this.handRay = this.gestures.raycasters.hand[0].ray;

        this.object3D = object3D;
        this.pivot = pivot;
        this.axis = axis;
        this.gesture = gesture;
        this.paused = false;

        this.angle = 0;
        this.targetAngle = 0;
        this.dampingFactor = 0.1; // Smoother transition

        this.initialize();
        this.addListener();
    }

    initialize() {
        this.parent = this.object3D.parent;

        this.quaternion = new THREE.Quaternion();
        this.intersection = new THREE.Vector3();
        this.lever = new THREE.Vector3();
        this.coords = new THREE.Vector2();
        this.xAxis = new THREE.Vector3();
        this.yAxis = new THREE.Vector3();
        this.plane = new THREE.Plane();
    }

    addListener() {
        this.listener = (event) => this.onGesture(event);
        this.gestures.addEventListener(this.gesture, this.listener);
    }

    onGesture(event) {
        if (this.paused) return;
        if (event.start) this.onStart();
        if (event.current) this.onCurrent();
        if (event.end) this.onEnd();
    }

    onStart() {
        console.log('guided rotation start', this);

        // Make object world-aligned
        this.scene.attach(this.object3D);

        // Store initial quaternion
        this.quaternion.copy(this.object3D.quaternion);

        // Smoothly blend plane normal with view direction
        this.plane.setFromNormalAndCoplanarPoint(this.viewRay.direction.clone().lerp(this.axis, 0.5), this.pivot);

        // Find intersection with the plane
        if (this.handRay.intersectPlane(this.plane, this.intersection)) {
            // Compute lever vector & project on the rotation axis
            this.lever.copy(this.intersection).sub(this.pivot).projectOnPlane(this.axis);
        }

        // Compute plane coordinate system
        this.xAxis.copy(this.lever).normalize();
        this.yAxis.copy(this.xAxis).applyAxisAngle(this.axis, Math.PI / 2).normalize();
    }

    onCurrent() {
        console.log('guided rotation current', this);

        // Smoothly update the plane normal
        this.plane.normal.lerp(this.viewRay.direction, 0.2).normalize();

        // Find intersection with the updated plane
        if (this.handRay.intersectPlane(this.plane, this.intersection)) {
            // Update lever and project it on the rotation plane
            this.lever.copy(this.intersection).sub(this.pivot).projectOnPlane(this.axis);

            // Compute new rotation angle
            this.coords.set(this.lever.dot(this.xAxis), this.lever.dot(this.yAxis));
            this.targetAngle = this.coords.length() > 0.01 ? this.coords.angle() : 0;
        }

        // Apply rotation with damping for smoother transitions
        this.angle += (this.targetAngle - this.angle) * this.dampingFactor;
        this.object3D.quaternion.copy(this.quaternion);
        this.object3D.rotateOnWorldAxis(this.axis, this.angle);
    }

    onEnd() {
        console.log('guided rotation end', this);

        // Reattach object to parent
        this.parent.attach(this.object3D);
    }

    pause() {
        if (this.paused) return;
        console.log('guided rotation paused');
        this.paused = true;
    }

    resume() {
        if (!this.paused) return;
        console.log('guided rotation resumed');
        this.paused = false;
    }

    destroy() {
        if (this.listener) {
            this.gestures.removeEventListener(this.gesture, this.listener);
            this.listener = null;
        }

        this.object3D = null;
        this.parent = null;
        this.pivot = null;
        this.axis = null;

        this.quaternion = null;
        this.intersection = null;
        this.lever = null;
        this.coords = null;
        this.xAxis = null;
        this.yAxis = null;
        this.plane = null;
    }
}

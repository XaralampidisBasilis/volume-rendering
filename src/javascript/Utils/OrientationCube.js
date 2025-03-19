import * as THREE from 'three';

var HasMoved = false;

function antiMoveOnDown(e) 
{
    this.HasMoved = false;
}
function antiMoveOnMove(e) 
{
    this.HasMoved = true;
}

class OrientationCube
{
    constructor(mainCamera, mainControls)
    {
        this.MainCamera = mainCamera;
        this.MainControls = mainControls;

        this.Build();
    }


    Build()
    {
        window.addEventListener('mousedown', antiMoveOnDown, false);
        window.addEventListener('mousemove', antiMoveOnMove, false);
        window.addEventListener('touchstart', antiMoveOnDown, false);
        window.addEventListener('touchmove', antiMoveOnMove, true);

        var cubeWrapper = document.getElementById('OrientationCubeContainer');

        //var w = cubeWrapper.offsetWidth;
        //var h = cubeWrapper.offsetHeight;
        var w = 150;
        var h = 150;

        cubeWrapper.width = w;
        cubeWrapper.height = h;

        // renderer
        this.Renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true, preserveDrawingBuffer: true });
        this.Renderer.setClearColor(0x000000, 0);
        this.Renderer.setSize(w, h);
        cubeWrapper.appendChild(this.Renderer.domElement);

        // scene
        this.Scene = new THREE.Scene();

        // camera
        this.Camera = new THREE.PerspectiveCamera(50, w / h, 1, 1000);
        this.Camera.up = this.MainCamera.up; // important!

        let materials = [];
        this.ViewNames = ['L', 'R', 'P', 'A', 'H', 'F'];

        let textureLoader = new THREE.TextureLoader();
        let canvas = document.createElement('canvas');
        let ctx = canvas.getContext('2d');

        let size = 80;
        canvas.width = size;
        canvas.height = size;

        ctx.font = 'bolder 62px "Open sans", Arial';
        ctx.textBaseline = 'middle';
        ctx.textAlign = 'center';

        let mainColor = '#fff';
        let otherColor = '#ccc';

        let bg = ctx.createLinearGradient(0, 0, 0, size);
        bg.addColorStop(0, mainColor);
        bg.addColorStop(1, otherColor);

        for (let i = 0; i < 6; i++)
        {
            if (this.ViewNames[i] == 'H')
            {
                ctx.fillStyle = mainColor;
            }
            else if (this.ViewNames[i] == 'F')
            {
                ctx.fillStyle = otherColor;
            }
            else
            {
                ctx.fillStyle = bg;
            }

            ctx.fillRect(0, 0, size, size);
            ctx.strokeStyle = '#aaa';
            ctx.lineWidth = 4;
            ctx.strokeRect(0, 0, size, size);
            ctx.fillStyle = '#999';

            let rotation = 0;
            if (this.ViewNames[i] == 'P') { rotation = Math.PI; }
            if (this.ViewNames[i] == 'R') { rotation = Math.PI / 2; }
            if (this.ViewNames[i] == 'L') { rotation = -Math.PI / 2; }
            if (rotation != 0) 
            {
                ctx.save();
                ctx.translate(size / 2, size / 2);
                ctx.rotate(rotation);
                ctx.textAlign = "center";
                ctx.fillText(this.ViewNames[i], 0, 0);
                ctx.restore();
            }
            else
            {
                ctx.fillText(this.ViewNames[i], size / 2, size / 2);
            }

            materials[i] = new THREE.MeshBasicMaterial({
                map: textureLoader.load(canvas.toDataURL()),
                transparent: true,
                opacity: 0.5,
            });
        }

        this.Planes = [];

        let planeMaterial = new THREE.MeshBasicMaterial({
            side: THREE.DoubleSide,
            color: 0x00c0ff,
            transparent: true,
            opacity: 0.0,
            depthTest: false
        });
        let planeSize = 0.9;
        let planeGeometry = new THREE.PlaneGeometry(planeSize, planeSize);

        let a = 0.51;

        let plane1 = new THREE.Mesh(planeGeometry, planeMaterial.clone());
        plane1.position.z = a;
        plane1.ViewName = 'H';
        this.Scene.add(plane1);
        this.Planes.push(plane1);

        let plane2 = new THREE.Mesh(planeGeometry, planeMaterial.clone());
        plane2.position.z = -a;
        plane2.ViewName = 'F';
        this.Scene.add(plane2);
        this.Planes.push(plane2);

        let plane3 = new THREE.Mesh(planeGeometry, planeMaterial.clone());
        plane3.rotation.y = Math.PI / 2;
        plane3.position.x = a;
        plane3.ViewName = 'L';
        this.Scene.add(plane3);
        this.Planes.push(plane3);

        let plane4 = new THREE.Mesh(planeGeometry, planeMaterial.clone());
        plane4.rotation.y = Math.PI / 2;
        plane4.position.x = -a;
        plane4.ViewName = 'R';
        this.Scene.add(plane4);
        this.Planes.push(plane4);

        let plane5 = new THREE.Mesh(planeGeometry, planeMaterial.clone());
        plane5.rotation.x = Math.PI / 2;
        plane5.position.y = a;
        plane5.ViewName = 'P';
        this.Scene.add(plane5);
        this.Planes.push(plane5);

        let plane6 = new THREE.Mesh(planeGeometry, planeMaterial.clone());
        plane6.rotation.x = Math.PI / 2;
        plane6.position.y = -a;
        plane6.ViewName = 'A';
        this.Scene.add(plane6);
        this.Planes.push(plane6);

        this.Mesh = new THREE.Mesh(new THREE.BoxGeometry(1, 1, 1), materials);
        this.Scene.add(this.Mesh);

        this.ActivePlane = null;

        let scope = this;
        this.Renderer.domElement.onmousemove = function (evt)
        {
            if (!scope.Mesh.visible) { return; }

            if (scope.ActivePlane)
            {
                scope.ActivePlane.material.opacity = 0;
                scope.ActivePlane.material.needsUpdate = true;
                scope.ActivePlane = null;
            }

            let x = evt.offsetX;
            let y = evt.offsetY;
            let size = scope.Renderer.getSize(new THREE.Vector2());
            let mouse = new THREE.Vector2(x / size.width * 2 - 1, -y / size.height * 2 + 1);

            let raycaster = new THREE.Raycaster();
            raycaster.setFromCamera(mouse, scope.Camera);
            let intersects = raycaster.intersectObjects(scope.Planes.concat(scope.Mesh));

            if (intersects.length > 0 && intersects[0].object != scope.Mesh)
            {
                scope.ActivePlane = intersects[0].object;
                scope.ActivePlane.material.opacity = 0.2;
                scope.ActivePlane.material.needsUpdate = true;
            }
        }

        let startTime = 0;
        let duration = 500;
        let play = false;

        this.Renderer.domElement.onclick = function (evt)
        {
            if (!scope.Mesh.visible) { return; }

            scope.Renderer.domElement.onmousemove(evt);

            if (!scope.ActivePlane || scope.HasMoved)
            {
                return false;
            }

            scope.ClickOnPlane(scope.ActivePlane);
        }

        this.Renderer.domElement.ontouchmove = function (e)
        {
            if (!scope.Mesh.visible) { return; }

            let rect = e.target.getBoundingClientRect();
            let x = e.targetTouches[0].pageX - rect.left;
            let y = e.targetTouches[0].pageY - rect.top;
            scope.Renderer.domElement.onmousemove({
                offsetX: x,
                offsetY: y
            });
        }

        this.Renderer.domElement.ontouchstart = function (e)
        {
            if (!scope.Mesh.visible) { return; }

            let rect = e.target.getBoundingClientRect();
            let x = e.targetTouches[0].pageX - rect.left;
            let y = e.targetTouches[0].pageY - rect.top;
            scope.Renderer.domElement.onclick({
                offsetX: x,
                offsetY: y
            });
        }

    }



    UpdateCamera(mainCamera, mainControls)
    {
        //cubeCamera.position.copy( Camera.position );
        //cubeCamera.position.sub( Controls.target );
        //cubeCamera.position.setLength( 300 );
        //cubeCamera.lookAt( cubeScene.position );
        let cubeCameraDistance = 2.75;

        this.Camera.rotation.copy(mainCamera.rotation);
        let dir = mainCamera.position.clone().sub(mainControls.target).normalize();
        this.Camera.position.copy(dir.multiplyScalar(cubeCameraDistance));
    }

    Render()
    {
        this.UpdateCamera(this.MainCamera, this.MainControls);
        this.Renderer.render(this.Scene, this.Camera);
    }

    ClickOnPlane(plane)
    {
        let oldPosition = new THREE.Vector3();
        let newPosition = new THREE.Vector3();

        oldPosition.copy(this.MainCamera.position);

        let distance = this.MainCamera.position.clone().sub(this.MainControls.target).length();
        newPosition.copy(this.MainControls.target);

        if (plane.position.x !== 0)
        {
            newPosition.x += plane.position.x < 0 ? -distance : distance;
        } 
        else if (plane.position.y !== 0)
        {
            newPosition.y += plane.position.y < 0 ? -distance : distance;
        } 
        else if (plane.position.z !== 0)
        {
            newPosition.z += plane.position.z < 0 ? -distance : distance;
        }

        //play = true;
        //startTime = Date.now();
        this.MainCamera.position.copy(newPosition);

        this.MainControls.update();
    }

    SetView(viewName)
    {
        for(var i = 0; i < this.Planes.length; i++)
        {
            if(this.Planes[i].ViewName.substring(0, 1) === viewName)
            {
                this.ClickOnPlane(this.Planes[i]);
                return;
            }
        }
    }

}

export { OrientationCube }

define('DS/XCTWebExperienceAppPlay/CXPWebViewpoint',
// dependencies
[
    'UWA/Core',
    'DS/Visualization/ThreeJS_DS'
],
function (UWA, THREE) {

    'use strict';

    var CXPWebViewpoint = UWA.Class.extend(
    {

        _viewer: null,

        init: function (iViewpoint) {
            this._viewpoint = iViewpoint;
        },
        __stu__IsLocked: function () {
            //0 = not locked by the authoring TODO other cases
            return 0;
        },
        __stu__SetAngle: function (angle) {
            this._viewpoint.setAngle(angle * 2);
        },
        __stu__SetViewpoint: function (position, forward, up) {
            var upVec3 = new THREE.Vector3(up.x, up.y, up.z);
            var forwardVec3 = new THREE.Vector3(forward.x, forward.y, forward.z);
            this._viewpoint.moveTo({
            	eyePosition: position,
                sightDirection: forwardVec3,
                upDirection: upVec3
            });
        },
        __stu__SetClippingValue: function (nearClip, farClip) {
            this._viewpoint.camera.near = nearClip;
            this._viewpoint.camera.far = farClip;
        },
        __stu__SetProjectionType: function (projectionType) {
            this._viewpoint.setProjectionType(projectionType);
        },
        __stu__SetZoom: function (zoom) {
            var camera = this._viewpoint.camera;

            var dx = (camera.right - camera.left) / (2 * zoom);
            var dy = (camera.top - camera.bottom) / (2 * zoom);
            var cx = (camera.right + camera.left) / 2;
            var cy = (camera.top + camera.bottom) / 2;

            camera.projectionMatrix.makeOrthographic(cx - dx, cx + dx, cy + dy, cy - dy, camera.near, camera.far);
        },

        __stu__SetFocusDistance: function (iFocusDistance) {
        	this._viewpoint.setTargetDistance(iFocusDistance);
		}
    });

    return CXPWebViewpoint;
});




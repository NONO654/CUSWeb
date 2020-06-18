/**
 * @exports DS/XCTWebExperienceAppPlay/CXPWebViewer
*/
define('DS/XCTWebExperienceAppPlay/CXPWebViewer',
// dependencies
[
    'UWA/Core',
    'DS/Visualization/ThreeJS_DS',
    'DS/StuCore/StuContext',
    'DS/StuMath/StuSphere',
    'DS/StuMath/StuRay',
    'DS/Visualization/PathElement',
	'MathematicsES/MathsDef',
    'DS/CATCXPModel/CATCXPRenderUtils',

	'DS/StuRenderEngine/StuIntersection'
],
function (UWA, THREE, STU, Sphere, Ray, PathElement, DSMath, CATCXPRenderUtils) {

    'use strict';

    /**
    * @name DS/XCTWebExperienceAppPlay/CXPWebViewer
    * @description 
    * Web Viewer of the application. It has the same methods than the Creative C++ bound viewer.
    * @constructor
    */

    var CXPWebViewer = UWA.Class.extend(
    /** @lends DS/XCTWebExperienceAppPlay/CXPWebViewer.prototype **/
    {
        _viewer : null,

        init:function(iViewer) {
            this._viewer = iViewer ;
        },

        /**
        * Get Viewer size
        * @public
        * @param {DSMath.Vector2D} size - vector to fill
        */
        GetSize: function (oSize) {
        	if (oSize instanceof DSMath.Vector2D) {
                var canvasSize = this._viewer.canvas.getSize();
                oSize.x = canvasSize.width;
                oSize.y = canvasSize.height;
            }
            else {
                UWA.log('StuViewer.GetSize ERROR : parameter is not a Vector2D !');
                oSize = null;
            }
        },

        /**
        * Get bounding sphere of the scene
        * @public
        * @param {STU.Sphere} sphere - sphere to resize according to scene bounding sphere
        */
        GetGlobalBoundingSphere: function (oSphere) {
            if (oSphere instanceof STU.Sphere) {
            	var sphere = this._viewer.getSceneBoundingSphere('show', true);
                oSphere.center = sphere.center;
                oSphere.radius = sphere.radius;
            }
            else {
                UWA.log('StuViewer.GetGlobalBoundingSphere ERROR : parameter is not a STU.Sphere !');
                oSphere = null;
            }
        },

        /**
        * Get Ray from a position on the screen. The ray is build from a normal of the screen.
        * @public
        * @param {DSMath.Vector2D} position - screen position
        * @param {STU.Ray} ray - ray to set origin and direction
        */
        GetRayFromPosition: function (iPosition, oRay) {
        	    if (!(oRay instanceof STU.Ray)) {
        		    UWA.log('StuViewer.GetRayFromPosition ERROR : ray parameter is not a STU.Ray !');
        		    oRay = null;
        		    return;
        	    }
        	    var camera = this._viewer.currentViewpoint.camera;
        	    var ray = this._viewer.currentViewpoint.create3DRayFrom2DPoint(iPosition, camera);
        	    oRay.origin.x = ray.origin.x;
        	    oRay.origin.y = ray.origin.y;
        	    oRay.origin.z = ray.origin.z;
        	    oRay.direction.x = ray.direction.x;
        	    oRay.direction.y = ray.direction.y;
        	    oRay.direction.z = ray.direction.z;
        },

        /**
        * Get Line from a position on the screen. The line is build from a normal of the screen.
        * @public
        * @param {DSMath.Vector2D} position - screen position
        * @param {DSMath.Line} line - line to set origin and direction
        */
        GetLineFromPosition: function (iPosition, oLine) {
        	if (!(oLine instanceof DSMath.Line)) {
        		UWA.log('StuViewer.GetLineFromPosition ERROR : ray parameter is not a DSMath.Line !');
                oLine = null;
                return;
            }
            var camera = this._viewer.currentViewpoint.camera;
            var ray = this._viewer.currentViewpoint.create3DRayFrom2DPoint(iPosition, camera);

            oLine.origin.x = ray.origin.x;
            oLine.origin.y = ray.origin.y;
            oLine.origin.z = ray.origin.z;
            oLine.direction.x = ray.direction.x;
            oLine.direction.y = ray.direction.y;
            oLine.direction.z = ray.direction.z;
        },

        /**
        * Get intersections from a position on the screen
        * @public
        * @param {DSMath.Vector2D} position - screen position
        * @param {STU.Intersection[]} intersections - array to fill with intersections
        * @param {boolean} returnFirstIntersection - true to return 1st intersection, false otherwise
        * @param {boolean} pickAllElements - true to pick all elements of the scene, false otherwise
        * @returns {STU.Intersection} first intersection
        */
        PickFromPosition: function (iPosition, oIntersections, returnFirstIntersection, pickAllElements) {
            if (!(oIntersections instanceof Array)) {
                UWA.log('StuViewer.PickFromPosition ERROR : oIntersections parameter is not an Array !');
                oIntersections = null;
                return undefined;
            }
            var ray = new STU.Ray();
            this.GetRayFromPosition(iPosition, ray);
            return this.PickFromRay(ray, oIntersections, returnFirstIntersection, pickAllElements);
        },

        /**
        * Get intersections from a ray
        * @public
        * @param {STU.Ray} ray - ray to intersect with
        * @param {STU.Intersection[]} intersections - array to fill with intersections
        * @param {boolean} returnFirstIntersection - true to return 1st intersection, false otherwise
        * @param {boolean} pickAllElements - true to pick all elements of the scene, false otherwise
        * @returns {STU.Intersection} first intersection
        */
        PickFromRay: function (iRay, oIntersections, iReturnFirstIntersection) {
            if (!(oIntersections instanceof Array)) {
                UWA.log('StuViewer.PickFromRay ERROR : oIntersections parameter is not an Array !');
                oIntersections = null;
                return undefined;
            }

            var ray = new THREE.Ray();
            ray.origin.set(iRay.getOrigin().x, iRay.getOrigin().y, iRay.getOrigin().z);
            ray.direction.set(iRay.getDirection().x, iRay.getDirection().y, iRay.getDirection().z);
            var length = iRay.getLength();

            var intersects = this._viewer.castRay(ray, null, 'prim');

            for (var i = 0; i < intersects.length; i++) {
                if (intersects[i].distance <= length || length === 0) {
                    var components = CATCXPRenderUtils.getComponentsFromPathElement(intersects[i].pathElement, true);
                    if (components.length === 1) {
                        var Actor3DProtoBuild = components[0].QueryInterface('StuIPrototypeBuild');
                        var actor3D = Actor3DProtoBuild.GetSync();
                        if (this._isClickable(actor3D)) {
                            var intersection = new STU.Intersection();
                            var point = new DSMath.Point(intersects[i].point.x, intersects[i].point.y, intersects[i].point.z);
                            intersection.setPoint(point);
                            var normal = new DSMath.Vector3D(intersects[i].normal.x, intersects[i].normal.y, intersects[i].normal.z);
                            intersection.setNormal(normal);
                            intersection.setActor(actor3D);
                            if (actor3D.name) {
                                intersection.actorName = actor3D.name;
                            }
                            oIntersections.push(intersection);

                            if (iReturnFirstIntersection === true) {
                                return oIntersections;
                            }
                        }
                    }
                }
            }
            return oIntersections;
        },

        _isClickable: function (iActor3D) {
            if (iActor3D.clickable) {
                return iActor3D.parent instanceof STU.Actor3D ? this._isClickable(iActor3D.parent) : true;
            } else {
                return false;
            }
        },

        /**
        * Get intersections from a line
        * @public
        * @param {DSMath.Line} line - line to intersect with
        * @param {STU.Intersection[]} intersections - array to fill with intersections
        * @param {boolean} returnFirstIntersection - true to return 1st intersection, false otherwise
        * @param {boolean} pickAllElements - true to pick all elements of the scene, false otherwise
        * @returns {STU.Intersection} first intersection
        */
        PickFromLine: function (iLine, oIntersections, iReturnFirstIntersection) {

            if (!(oIntersections instanceof Array)) {
                UWA.log('StuViewer.PickFromLine ERROR : oIntersections parameter is not an Array !');
                oIntersections = null;
                return undefined;
            }
            var ray = new STU.Ray();
            ray.origin = iLine.origin;
            ray.direction = iLine.direction;
            this.PickFromRay(ray, oIntersections, iReturnFirstIntersection);
            return oIntersections;
        },

        /**
        * Get mouse position on the screen
        * @public
        * @param {THREE.Vector2} position - position to fill
        */
        GetMousePosition: function (pos) {
            if (!(pos instanceof THREE.Vector2)) {
                UWA.log('StuViewer.GetMousePosition ERROR : pos parameter is not a THREE.Vector2!');
                pos = null;
                return;
            }

            var mousePos = this._viewer.getMousePosition(new THREE.Vector2(0, 0));
            pos.x = mousePos.x;
            pos.y = mousePos.y;
        },

        /**
        * Set mouse position on the screen
        * <b> WARNING : </b> no implementation
        * @public
        * @param {THREE.Vector2} position - position to set
        */
        SetMousePosition: function (iPos) {
            UWA.log('StuViewer.SetMousePosition WARNING : No Implementation !');
        },

        /**
        * Hide mouse cursor
        * @public
        */
        HideMouseCursor: function () {
            this._viewer.setCursor('');
        },

        /**
        * Show mouse cursor
        * @public
        */
        ShowMouseCursor: function () {
            this._viewer.setCursor('auto');
        },

        /**
        * Highlight current selection
        * @public
        * @param {Object} currentActor - selected Actor to highlight
        * @param {Object} option - highlight option
        */
        HighlightDisplay: function (currentActor, option) {
            // todo manage option
            //var toHiglight = [];
            //var path = new PathElement();

            UWA.log('StuViewer.HighlightDisplay WARNING : No Implementation !');

            // todo get node 3D
        	//var geoVisu = currentActor.QueryInterface('CATI3DGeoVisu');
        	//var node = geoVisu.GetNode();

            /*path.setFromOccurrence(root.children[idx].occurrences[0]);
            toHiglight.push(path);
            var xsoNode = {
                path: toHiglight
            };
            this._viewer.addToCSOHSO(xsoNode, { multiSel: false, trapSel: true });*/
        },

        /**
        * pre Highlight selection
        * <b> WARNING : </b> no implementation
        * @public
        * @param {Object} currentActor - selected Actor to pre highlight
        * @param {Object} option - pre highlight option
        */
        PreHighlightDisplay: function (currentActor, option) {
            UWA.log('StuViewer.SetMousePosition WARNING : No Implementation !');
        },

        /**
        * Get coordinates of the viewpoint from a position on screen
        * @public
        * @param {DSMath.Vector2D} position - screen position
        * @param {STU.Camera} camera - camera to compute coordinates from
        * @returns {STU.Ray} ray - computed ray
        */
        GetViewpointCoordinatesFromPixel: function (iPosition, iCamera) {
        	    var ray = this._viewer.currentViewpoint.create3DRayFrom2DPoint(iPosition, iCamera);
        	    return ray.origin;
        },

        /**
        * Unproject a vector from a camera coordinates
        * @public
        * @param {DSMath.Vector2D} vector - vector to unproject
        * @param {STU.Camera} camera - camera to compute projection from
        * @returns {DSMath.Vector2D} unprojected vector
        */
        Unproject : function (iVector, iCamera) {
            var matrix = new THREE.Matrix4();

            var matrixWorld = new THREE.Matrix4();
            this._validateMatrix(iCamera.matrixWorld, matrixWorld);
            var projectionMatrix = new THREE.Matrix4();
            this._validateMatrix(iCamera.projectionMatrix, projectionMatrix);

            matrix.multiplyMatrices(matrixWorld, matrix.getInverse(projectionMatrix));

            return iVector.applyProjection(matrix);
        },

        _validateMatrix: function (iMatrix, oMatrix) {

            for (var i = iMatrix.elements.length - 1; i >= 0; i--) {
                var e = iMatrix.elements[i];
                if (isFinite(e) && !isNaN(e)) {
                    oMatrix.elements[i] = e;
                }
            }

        },

        /**
        * Activate default navigation
        * @public
        */
        ActivateDefaultNavigation: function () {
            this._viewer.currentViewpoint.control.setActive(true);
            this._viewer.setManipulators({ activated: true });
            if (this._saveAuthCamOptions) {
                this._viewer.currentViewpoint.moveTo(this._saveAuthCamOptions);
                this._saveAuthCamOptions = undefined;
            }
        },

        /**
        * Deactivate default navigation
        * @public
        */
        DeactivateDefaultNavigation: function () {
            this._viewer.currentViewpoint.control.setActive(false);
            this._viewer.setManipulators({ activated: false });
            this._saveAuthCamOptions = {
            	eyePosition: this._viewer.currentViewpoint.getCameraPosition().clone(),
            	upDirection: this._viewer.currentViewpoint.getUpDirection().clone(),
                sightDirection: this._viewer.currentViewpoint.getSightDirection().clone(),
                distanceToTarget  : this._viewer.currentViewpoint.getTargetDistance(),
                duration : 500
            };
        }


    });

    return CXPWebViewer;
});




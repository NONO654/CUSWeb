define('DS/CATCXPModel/CATCXPRenderUtils', [
	'UWA/Core',
	'MathematicsES/MathsDef'
],
function (
		UWA,
		DSMath
		) {
	'use strict';

	var CATCXPRenderUtils = UWA.Class.singleton(
    {

        getComponentsFromPathElement: function (iPathElement, iLastComponent) {
            var externalPath = iPathElement.externalPath.slice();
            var components = [];
            while (externalPath.length > 0) {
                var node = externalPath[externalPath.length - 1];
                if (node._components) {
                    for (var iComp = 0; iComp < node._components.length; iComp++) {
                        if (externalPath.equals(node._components[iComp].QueryInterface('CATI3DGeoVisu').GetPathElement().externalPath)) {
                            components.push(node._components[iComp]);
                            if (iLastComponent) {
                                return components;
                            }
                        }
                    }
                }
                externalPath.pop();
            }
            return components;
        },

    	/** 
		* Set camera settings according to current viewpoint
		* @public
		* @param  {Camera} camera - camera to set.
		* @param  {Viewpoint}
		*/
    	setCameraFromViewpoint: function (iCamera, iViewpoint) {
    		var viewpointCamera = iViewpoint.camera;
    		var matrix = viewpointCamera.matrix.elements;

    		var matrix4x3 = [matrix[8], matrix[9], matrix[10],
				matrix[0], matrix[1], matrix[2],
				matrix[4], matrix[5], matrix[6],
				matrix[12], matrix[13], matrix[14]
    		];

    		var transform = new DSMath.Transformation();
    		iCamera.QueryInterface('CATIMovable').GetLocalPosition(transform);

    		transform.setFromArray(matrix4x3);
    		iCamera.QueryInterface('CATIMovable').SetLocalPosition(null, transform);

    		if (iCamera.QueryInterface('CATI3DExperienceObject').GetValueByName('farClip') !== viewpointCamera.near) {
    			iCamera.QueryInterface('CATI3DExperienceObject').SetValueByName('farClip', viewpointCamera.near);
    		}
    		if (iCamera.QueryInterface('CATI3DExperienceObject').GetValueByName('nearClip') !== viewpointCamera.far) {
    			iCamera.QueryInterface('CATI3DExperienceObject').SetValueByName('nearClip', viewpointCamera.far);
    		}
    		if (iCamera.QueryInterface('CATI3DExperienceObject').GetValueByName('viewAngle') !== viewpointCamera.fov) {
    		    iCamera.QueryInterface('CATI3DExperienceObject').SetValueByName('viewAngle', iViewpoint.getAngle() / 2);
    		}
    		if (iCamera.QueryInterface('CATI3DExperienceObject').GetValueByName('aspectRatio') !== window.innerWidth / window.innerHeight) {
    			iCamera.QueryInterface('CATI3DExperienceObject').SetValueByName('aspectRatio', window.innerWidth / window.innerHeight);
    		}
    		iCamera.QueryInterface('CATI3DGeoVisu').Refresh(iViewpoint.viewer);
    	},

    	/** 
		* Set viewpoint according to a camera
		* @public
		* @param  {Viewpoint} viewpoint - viewpoint to edit.
		* @param  {Camera} camera - camera to get settings from.
		* @param  {Number} [duration] - duration in ms of the transition.
		*/
    	setViewpointFromCamera: function (iViewpoint, iCamera, iDuration) {
    		var duration = iDuration ? iDuration : 0;
    		var transform = new DSMath.Transformation();
    		iCamera.QueryInterface('CATIMovable').GetLocalPosition(transform);

    		//sight
    		var quat = new DSMath.Quaternion();
    		transform.matrix.getQuaternion(quat);
    		var startSight = new DSMath.Point();
    		startSight.set(-1, 0, 0);
    		var newSight = startSight.applyQuaternion(quat);
    		var sight = new DSMath.Vector3D();
    		sight.set(newSight.x, newSight.y, newSight.z);
    		sight.normalize();

    		//up
    		var quat = new DSMath.Quaternion();
    		transform.matrix.getQuaternion(quat);
    		var startUp = new DSMath.Point();
    		startUp.set(0, 0, 1);
    		var newUp = startUp.applyQuaternion(quat);
    		var up = new DSMath.Vector3D();
    		up.set(newUp.x, newUp.y, newUp.z);
    		up.normalize();

    		iViewpoint.moveTo({
    			eyePosition: transform.vector.clone(),
    			upDirection: up,
    			sightDirection: sight,
    			duration: duration
    		});

    		iViewpoint.setAngle(iCamera.QueryInterface('CATI3DExperienceObject').GetValueByName('viewAngle') * 2);
    	}

    });

	return CATCXPRenderUtils;
});

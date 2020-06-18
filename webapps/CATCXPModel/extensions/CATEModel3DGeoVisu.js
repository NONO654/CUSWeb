/**
* CATEModel3DGeoVisu
* @category Extension
* @name DS/CATCXPModel/extensions/CATEModel3DGeoVisu
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu}
* @augments DS/CATCXPModel/extensions/CATE3DGeoVisu
* @constructor
*/
define('DS/CATCXPModel/extensions/CATEModel3DGeoVisu',
[
	'UWA/Core',
    'DS/CATCXPModel/extensions/CATE3DGeoVisu',
    'DS/Visualization/Node3D',
    'DS/Visualization/PathElement',
	'DS/Visualization/ThreeJS_DS',
	'MathematicsES/MathsDef'
],

// Declaration
function (
    UWA,
    CATE3DGeoVisu,
    Node3D,
    PathElement,
	THREE,
	DSMath
    ) {
    'use strict';

    var CATEModel3DGeoVisu = CATE3DGeoVisu.extend(
	/** @lends DS/CATCXPModel/extensions/CATEModel3DGeoVisu.prototype **/
    {
        _CreatePathElement: function () {
            var cxpObject = this.QueryInterface('CATICXPObject');
            var parent = cxpObject.GetFatherObject();
            var path = parent.QueryInterface('CATI3DGeoVisu').GetPathElement().externalPath.slice();
            path.push(this.GetNode());
            this._pathElement = new PathElement(path);
            return this._pathElement;
        },

        _Fill: function (iNode3D) {
            this._parent(iNode3D);
            var self = this;

            this.listenTo(this.QueryInterface('CATI3DExperienceObject'), '_varposition.CHANGED', function () {
                self.frameVisuChanges.push(self._RefreshVarPos);
                self.RequestVisuRefresh();
            });
                        
            this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'visible.CHANGED', function () {
                self.frameVisuChanges.push(self._RefreshVisibility);
                self.RequestVisuRefresh();
            });

            this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'clickable.CHANGED', function () {
                self.frameVisuChanges.push(self._RefreshPickability);
                self.RequestVisuRefresh();
            });

            this.frameVisuChanges.push(self._RefreshVarPos);
            this.frameVisuChanges.push(self._RefreshVisibility);
            this.frameVisuChanges.push(self._RefreshPickability);
        },

        _listenGraphicalProperties: function () {
            /** deprecated **/
            console.warn("CATEModel3DGeoVisu._listenGraphicalProperties() : Deprecated !!!");            
        },

        _RefreshVarPos: function () {
            this._setRepPosition(this.QueryInterface('CATI3DExperienceObject').GetValueByName('_varposition'));
        },

        _RefreshVisibility: function () {
            this.GetOverride().setVisibility(this.QueryInterface('CATI3DXGraphicalProperties').GetShowMode());
        },

        _RefreshPickability: function () {
            this.GetOverride().setPickability(this.QueryInterface('CATI3DXGraphicalProperties').GetPickMode() ? 'PICKABLE' : 'NOT_PICKABLE');
        },

    	/**  
		* @public
		*/
        setReady: function (iReady) {
            if (iReady === this._ready) {
                return;
            }
            this._ready = iReady;
            this._setParentReady(iReady);
            this.dispatchEvent('readyChanged', iReady);
        },

        _setParentReady: function (iReady) {
            var cxpObject = this.QueryInterface('CATICXPObject');
            if (cxpObject) {
                var parent = cxpObject.GetFatherObject();
                if (parent && parent.QueryInterface('CATI3DGeoVisu')) {
                    parent.QueryInterface('CATI3DGeoVisu').setReady(iReady);
                }
            }
        },

    	/**  
		* @public
		*/
        GetBoundingBox: function (iMode) {
            var pathElement = this.GetPathElement();
            var viewer = this.GetObject()._experienceBase.getManager('CAT3DXVisuManager').getViewer();
            iMode = iMode ? iMode : 0;
            var Bb;
            if (this.GetOverride().getVisibility()) {
                Bb = pathElement.getBoundingBox(null, viewer, 'visibleSpace');
            }
            else {
                Bb = pathElement.getBoundingBox(null, viewer, 'invisibleSpace');
            }

            if (iMode === 0) {
                var transform = new DSMath.Transformation();
                var catiMovable = this.QueryInterface('CATIMovable');
                catiMovable.GetAbsPosition(transform);
                var matrix12 = transform.getArray();

                var matrixWorld = new THREE.Matrix4(matrix12[0], matrix12[3], matrix12[6], matrix12[9],
											matrix12[1], matrix12[4], matrix12[7], matrix12[10],
											matrix12[2], matrix12[5], matrix12[8], matrix12[11],
											0.0, 0.0, 0.0, 1.0);
                Bb.applyMatrix4(matrixWorld);
            }
            return Bb;
        },

    	/**  
		* @public
		*/
        GetBoundingSphere: function () {
            var viewer = this.GetObject()._experienceBase.getManager('CAT3DXVisuManager').getViewer();
            var bS;
            if (this.GetOverride().getVisibility()) {
                bS = node.getBoundingSphere(viewer, 'visibleSpace');
            }
            else {
                bS = node.getBoundingSphere(viewer, 'invisibleSpace');
            }
            return bS;
        }


    });

    return CATEModel3DGeoVisu;
});


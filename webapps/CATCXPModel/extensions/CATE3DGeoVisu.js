/**
* CATE3DGeoVisu
* @category Extension
* @name DS/CATCXPModel/extensions/CATE3DGeoVisu
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DGeoVisu CATI3DGeoVisu}
* @constructor
*/
define('DS/CATCXPModel/extensions/CATE3DGeoVisu',
[
	'UWA/Core',
    'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
    'DS/Visualization/Node3D',
    'UWA/Class/Events',
    'UWA/Class/Listener',
],

// Declaration
function (
    UWA,
    CAT3DXInterfaceImpl,
    Node3D,
    Events,
    Listener
    ) {
    'use strict';

    var CATE3DGeoVisu = UWA.Class.extend(CAT3DXInterfaceImpl, Events, Listener,
	/** @lends DS/CATCXPModel/extensions/CATE3DGeoVisu.prototype **/
    {

        init: function () {
            this._parent();
            this._node3D = null;
            this._pathElement = null;
            this._override = null;
            this.frameVisuChanges = [];
        },

		// object modeler API
        Build: function () {
            this.setReady(false);
        },

        destroy: function () {
            if (this._node3D) {
                this._node3D.removeChildren();
                var parents = this._node3D.parents;
                for (var i = parents.length - 1; i >= 0; --i) {
                    parents[i].remove(this._node3D);
                }
                this._node3D = null;
            }
            this.frameVisuChanges = [];
            this._ready = false;
            this.stopListening();
        },

        Get: function () {
            console.warn('CATI3DGeoVisu.GET() DEPRECATED use GetNode() instead');
            return this.GetNode();
        },

        _Create: function () {
            console.warn('CATI3DGeoVisu._Create() DEPRECATED use _CreateNode() instead');
            return this._CreateNode();
        },

    	/**  
		* @public
		*/
        GetNode: function () {
            return this._node3D? this._node3D : this._CreateNode();
        },

    	/**  
		* @public
		*/
        GetPathElement:function(){
            return this._pathElement ? this._pathElement : this._CreatePathElement();
        },

    	/**  
		* @public
		*/
        GetOverride: function () {
            return this._override ? this._override : this._CreateOverride();
        },

    	/**  
		* @public
		*/
        GetLocalNodes: function () {
            return null;
        },

        _CreateNode:function(){
            this._node3D = new Node3D();
            this._Fill(this._node3D);
            return this._node3D;
        },

        _CreateOverride:function(){
            var visuManager = this.GetObject()._experienceBase.getManager('CAT3DXVisuManager');
            var overrideSet = visuManager.getOverrideSet();
            var pathElement = this.GetPathElement();
            this._override = overrideSet.createOverride(pathElement);
            return this._override;
        },

        _Fill: function (iNode3D) {
            var component = this.GetObject();
            if (iNode3D._components){
                iNode3D._components.push(component);
                iNode3D.name = iNode3D.name + ' ; ' + component.QueryInterface('CATI3DExperienceObject').GetValueByName('_varName');//DEBUG
            } else {
                iNode3D._components = [component];
                iNode3D.name = component.QueryInterface('CATI3DExperienceObject').GetValueByName('_varName'); //DEBUG
            }
            this.RequestVisuRefresh();
        },

    	/**  
		* @public
		*/
        RequestVisuRefresh: function () {
            var visuManager = this.GetObject()._experienceBase.getManager('CAT3DXVisuManager');
            visuManager.refreshGeoVisu(this);
        },

    	/**  
		* @public
		*/
        Refresh: function () {
            for (var i = 0; i < this.frameVisuChanges.length; ++i) {
                this.frameVisuChanges[i].call(this);
            }
            this.frameVisuChanges.length = 0;
        },

        isReady: function () {
            return this._ready;
        }
    });

    return CATE3DGeoVisu;
});


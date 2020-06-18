/**
* CATE3DXVisuHierarchy
* @category Extension
* @name DS/CAT3DExpModel/extensions/CATE3DXVisuHierarchy
* @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DXVisuHierarchy CATI3DXVisuHierarchy}
* @constructor
*/
define('DS/CAT3DExpModel/extensions/CATE3DXVisuHierarchy',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],

// Declaration
function (
	UWA,
	CAT3DXInterfaceImpl
	) {
	'use strict';

	var CATE3DXVisuHierarchy = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CAT3DExpModel/extensions/CATE3DXVisuHierarchy.prototype **/
	{

		init: function () {
			this._parent();
			this._visuParent = null;
		},

		destroy: function () {
			this._parent();
			this._visuParent = null;
		},

		GetVisuParent: function () {
			if (!this._visuParent) {
			    var parentExpObject = this.QueryInterface('CATICXPObject').GetFatherObject();
			    this._visuParent = this._findVisuParent(parentExpObject);
			    this._visuParent = this._visuParent ? this._visuParent : parentExpObject;
			}
			return this._visuParent;
		},

		ClearVisuParent:function(){
		    this._visuParent = null;
		},

		_findVisuParent: function (iObject) {
			var cache = iObject.QueryInterface('CATI3DXAssetHolder').getCache();
			if (cache && cache.OverrideChildren) {
			    for (var i = 0; i < cache.OverrideChildren.length; i++) {
			        if (this.GetObject() === cache.OverrideChildren[i]) {
			            return iObject;
			        }
			        else {
			            var parent = this._findVisuParent(cache.OverrideChildren[i]);
			            if (parent) {
			                return parent;
			            }
			        }
			    }
			}
			return undefined;
		}

	});

	return CATE3DXVisuHierarchy;
});


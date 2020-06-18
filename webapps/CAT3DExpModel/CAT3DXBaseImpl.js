/**
 * @exports DS/CAT3DExpModel/CAT3DXBaseImpl
 **/
define('DS/CAT3DExpModel/CAT3DXBaseImpl',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXModel'
],
function (UWA, CAT3DXModel) {
	'use strict';

	/**
	 * CAT3DXBaseComponentImpl
	 * Base class for experience objects.
	 * @name DS/CAT3DExpModel/CAT3DXBaseImpl
	 * @constructor
	 **/
	var CAT3DXBaseImpl = UWA.Class.extend(
	/** @lends DS/CAT3DExpModel/CAT3DXBaseImpl.prototype **/
	{
		init: function () {
		},

		destroy: function () {
			for (var extensionsName in this._instanciatedExtensions) {
			    if (this._instanciatedExtensions.hasOwnProperty(extensionsName) && this._instanciatedExtensions[extensionsName].destroy) {
					this._instanciatedExtensions[extensionsName].destroy();
				}
			}

			CAT3DXModel.RemoveComponentFromComponentMap(this);
		},

		GetObject: function () {
			return this;
		},
	});
	return CAT3DXBaseImpl;
});

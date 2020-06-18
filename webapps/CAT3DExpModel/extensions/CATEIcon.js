/**
 * CATEIcon
 * @category Extension
 * @name DS/CAT3DExpModel/extensions/CATEIcon
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATIIcon CATIIcon}
 * @constructor
 */
define('DS/CAT3DExpModel/extensions/CATEIcon',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXModel',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],
function (
	UWA, CAT3DXModel, CAT3DXInterfaceImpl
	) {
	'use strict';

	var CATEIcon = UWA.Class.extend(CAT3DXInterfaceImpl,
	/** @lends DS/CAT3DExpModel/extensions/CATEIcon.prototype **/
	{
		init: function () {
			this._parent();
			this._icon = null;
		},

		destroy: function () {
			this._parent();
			this._icon = null;
		},

		GetIconName: function () {
			if (!UWA.is(this._icon)) {
				var iconName = CAT3DXModel.GetObjectUI(this.GetObject().GetType(), 'iconName');
				if (UWA.is(iconName)) {
					this._icon = iconName;
				}
			}
			if (UWA.is(this._icon)) {
				return this._icon;
			}
			return 'I_CXPUndefined.png';
		},

		SetIconName: function (iName) {
			if (UWA.typeOf(iName) === 'string') {
				this._icon = iName;
			}
		}
	});

	return CATEIcon;
}
);

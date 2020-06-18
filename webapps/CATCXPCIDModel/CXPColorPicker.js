/**
 * @exports DS/CATCXPCIDModel/CXPColorPicker
 */
define('DS/CATCXPCIDModel/CXPColorPicker',
// dependencies
[
    'UWA/Core',
	'DS/WebappsUtils/WebappsUtils',
	'DS/CATCXPCIDModel/CXPUIActor',
	'DS/Controls/ColorChooser'
],
function (UWA, WebappsUtils, CXPUIActor, WUXColorChooser) {

	'use strict';

	/**
	* @name DS/CATCXPCIDModel/CXPColorPicker
    * @description
    * Color Picker
	* @constructor
	*/

	var CXPColorPicker = CXPUIActor.extend(
		/** @lends DS/CATCXPCIDModel/CXPColorPicker.prototype **/
		{

			init: function (iUIActor) {
				this._parent(iUIActor);

				this._colorPicker = new WUXColorChooser().inject(this.getContainer());
				this._colorPicker.informationsVisibleFlag = false;

				Object.defineProperty(this, 'visible', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._visible;
					},
					set: function (iValue) {
						this._visible = iValue;
						this._colorPicker.visibleFlag = this._visible;
					}
				});

				Object.defineProperty(this, 'enable', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._enable;
					},
					set: function (iValue) {
						this._enable = iValue;
						this._colorPicker.disabled = !this._enable;
					}
				});

				Object.defineProperty(this, 'opacity', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._opacity;
					},
					set: function (iValue) {
						this._opacity = iValue;
						this._colorPicker.elements.container.style.opacity = this._opacity/255;
					}
				});

				Object.defineProperty(this, 'minWidth', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._minWidth;
					},
					set: function (iValue) {
						this._minWidth = iValue;
						var x = this._minWidth < 210 ? 210 : this._minWidth;
						this._colorPicker.colorChooserDimensions = { x: x - 8, y: this._colorPicker.colorChooserDimensions.y };
					}
				});

				Object.defineProperty(this, 'minHeight', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._minHeight;
					},
					set: function (iValue) {
						this._minHeight = iValue;
						var y = this._minHeight < 195 ? 195 : this._minHeight;
						this._colorPicker.colorChooserDimensions = { x: this._colorPicker.colorChooserDimensions.x, y: y - 3 };
					}
				});


				Object.defineProperty(this, 'color', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._color;
					},
					set: function (iValue) {
						this._color = iValue;
						var colorEO = this._color.QueryInterface('CATI3DExperienceObject');
						this._colorPicker.value = this._rgbToHex(colorEO.GetValueByName('r'), colorEO.GetValueByName('g'), colorEO.GetValueByName('b'));
					}
				});

			},

			// Register events for play
			// Color change
			registerPlayEvents: function (iSdkObject) {
				this._parent(iSdkObject);
				var self = this;

				this._colorPicker.addEventListener('change', this._colorPickerValueChanged = function () {
				    var color = self._hexToRgb(self._colorPicker.value);
				    iSdkObject.color.r = color.r;
				    iSdkObject.color.g = color.g;
				    iSdkObject.color.b = color.b;

					iSdkObject.doUIDispatchEvent('UIValueChanged', 0);
				});

			},

			// Release play events
			releasePlayEvents: function () {
				this._parent();

				this._colorPicker.removeEventListener('change', this._colorPickerValueChanged);
			},


			getContextualMenuItems: function () {
				var self = this;
				var data = {};
				var container = self.getContainer();

				return [{
					icon: 'url(' + WebappsUtils.getWebappsBaseUrl() + './CATCXPCIDModel/assets/icons/32/I_StuEdit.png)',
					label: 'Set default value',
					callback: function () {
						data.listener = function () {
							self._colorPicker.elements.container.style.zIndex = 'auto';
							self._colorPicker.elements.container.style.position = 'initial';
							container.removeEventListener('mouseleave', data.listener);
							container.style.pointerEvents = 'none';

							var expObj = self._uiActor.QueryInterface('CATI3DExperienceObject');
							var dataObj = expObj.GetValueByName('data').QueryInterface('CATI3DExperienceObject');
							var color = self._hexToRgb(self._colorPicker.value);
							var colorEO = dataObj.GetValueByName('color').QueryInterface('CATI3DExperienceObject');
							colorEO.SetValueByName('r', color.r);
							colorEO.SetValueByName('g', color.g);
							colorEO.SetValueByName('b', color.b);
						};

						self._colorPicker.elements.container.style.zIndex = '100';
						self._colorPicker.elements.container.style.position = 'relative';
						container.addEventListener('mouseleave', data.listener);
						container.style.pointerEvents = 'auto';
					}
				}];
			},

			_hexToRgb : function (hex) {
			    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
			    return result ? {
			        r: parseInt(result[1], 16),
			        g: parseInt(result[2], 16),
			        b: parseInt(result[3], 16)
			    } : null;
			},

            _rgbToHex : function (r, g, b) {
                return '#' + this._componentToHex(r) + this._componentToHex(g) + this._componentToHex(b);
            },

            _componentToHex : function (c) {
                var hex = c.toString(16);
                return hex.length === 1 ? '0' + hex : hex;
            }
		});
	return CXPColorPicker;
});





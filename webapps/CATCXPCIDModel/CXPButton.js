/**
 * @exports DS/CATCXPCIDModel/CXPButton
 */
define('DS/CATCXPCIDModel/CXPButton',
[
	'UWA/Core',
	'DS/WebappsUtils/WebappsUtils',
	'DS/CATCXPCIDModel/CXPUIActor',
	'DS/Controls/Button'
],
function (UWA, WebappsUtils, CXPUIActor, WUXButton) {
	'use strict';
	/**
	* @name DS/CATCXPCIDModel/CXPButton
	* @description
	* Create a button ui actor rep (WUXButton)
	* Define specific properties and bind them to the rep
	* @constructor
	*/

	var CXPButton = CXPUIActor.extend(
	/** @lends DS/CATCXPCIDModel/CXPButton.prototype **/
	{
		init: function (iUIActor) {
			this._parent(iUIActor);

			this._buttonHolder = UWA.createElement('div').inject(this.getContainer());
			this._button = new WUXButton({ emphasize: 'secondary' }).inject(this._buttonHolder);

			Object.defineProperty(this, 'visible', {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._visible;
				},
				set: function (iValue) {
					this._visible = iValue;
					this._button.visibleFlag = this._visible;
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
					this._button.disabled = !this._enable;
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
					this._buttonHolder.style.opacity = this._opacity/255;
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
					this._button.minWidth = this._minWidth;
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
					this._button.elements.container.style.minHeight = this._minHeight + 'px';
				}
			});

			Object.defineProperty(this, 'fontHeight', {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._fontHeight;
				},
				set: function (iValue) {
					this._fontHeight = iValue;
					this._button.elements.container.style.lineHeight = this._fontHeight + 'px';
					this._button.elements.container.style.fontSize = this._fontHeight + 'px';
				}
			});

			Object.defineProperty(this, 'icon', { //not tested can't display base64img
				enumerable: true,
				configurable: true,
				get: function () {
					return this._icon;
				},
				set: function (iValue) {
					this._icon = iValue;
					this._button.icon = this._icon;
				}
			});

			Object.defineProperty(this, 'label', {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._label;
				},
				set: function (iValue) {
					this._label = iValue;
					this._button.label = this._label;
				}
			});

			Object.defineProperty(this, 'pushable', {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._pushable;
				},
				set: function (iValue) {
					this._pushable = iValue;
					if (this._pushable) {
						this._button.type = 'check';
					}
					else {
						this._button.type = 'standard';
					}
				}
			});

			Object.defineProperty(this, 'pushed', {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._pushed;
				},
				set: function (iValue) {
					this._pushed = iValue;
					if (this._pushed && this.pushable) {
						this._button.checkFlag = true;
					} else {
						this._button.checkFlag = false;
					}
				}
			});
		},

		// Register events for play
		registerPlayEvents: function (iSdkObject, index) {
			this._parent(iSdkObject);
			var self = this;
			index = UWA.is(index) ? index : 0;

			this._button.onClick = function () {
				iSdkObject.pushed = self._button.checkFlag;
				iSdkObject.doUIDispatchEvent('UIClicked', index);
			};
		},

		// Release play events
		releasePlayEvents: function () {
			this._parent();
			this._button.onClick = null;
		},

		getContextualMenuItems: function () {
			var self = this;
			var data = {};

			return [{
				icon: 'url(' + WebappsUtils.getWebappsBaseUrl() + './CATCXPCIDModel/assets/icons/32/I_StuEdit.png)',
				label: 'Edit text',
				callback: function () {
					data.input = UWA.createElement('input');
					data.input.style.position = 'absolute';
					data.input.style.top = '0px';
					data.input.style.left = '0px';
					data.input.style.width = self._button.elements.button.offsetWidth + 'px';
					data.input.style.height = self._button.elements.button.offsetHeight + 'px';
					data.input.style.textAlign = 'center';
					data.input.style.lineHeight = self._fontHeight + 'px';
					data.input.style.fontSize = self._fontHeight + 'px';
					data.input.style.boxSizing = 'border-box';
					data.input.inject(self.getContainer());
					data.input.focus();
					data.input.value = self._button.label;

					data.inputListener = function () {
						data.input.removeEventListener('change', data.inputListener);
						var expObj = self._uiActor.QueryInterface('CATI3DExperienceObject');
						var dataObj = expObj.GetValueByName('data').QueryInterface('CATI3DExperienceObject');
						dataObj.SetValueByName('label', data.input.value);
						data.input.destroy();
					};

					data.input.addEventListener('focusout', data.inputListener);
					data.input.addEventListener('change', data.inputListener);
				}
			}];
		}
	});
	return CXPButton;
});





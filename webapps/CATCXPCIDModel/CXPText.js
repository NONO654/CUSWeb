/**
 * @exports DS/CATCXPCIDModel/CXPText
 */
define('DS/CATCXPCIDModel/CXPText',
// dependencies
[
    'UWA/Core',
	'DS/WebappsUtils/WebappsUtils',
	'DS/CATCXPCIDModel/CXPUIActor'
],
function (UWA, WebappsUtils, CXPUIActor) {

	'use strict';

	/**
	* @name DS/CATCXPCIDModel/CXPText
    * @description
	* Create a text ui actor rep (<div><span><\span><\div>)
	* Define specific properties and bind them to the rep
	* @constructor
	*/

	var CXPText = CXPUIActor.extend(
		/** @lends DS/CATCXPCIDModel/CXPText.prototype **/
		{

			init: function (iUIActor) {
				this._parent(iUIActor);

				this._spanHolder = UWA.createElement('div').inject(this.getContainer());
				this._spanHolder.style.boxSizing = 'border-box';
				this._spanHolder.style.cursor = 'default';
				this._span = UWA.createElement('span').inject(this._spanHolder);
				this._span.style.lineHeight = 'initial';
				this._spanHolder.style.border = '2px';
				this._spanHolder.style.borderStyle = 'solid';
				this._spanHolder.style.borderRadius = '5px';
				this._spanHolder.style.padding = '5px';

				Object.defineProperty(this, 'visible', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._visible;
					},
					set: function (iValue) {
						this._visible = iValue;
						if (this._visible) {
							this._spanHolder.style.display = 'inherit';
						}
						else {
							this._spanHolder.style.display = 'none';
						}
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
						if (this._enable) {
							this._spanHolder.style.pointerEvents = 'inherit';
							this._spanHolder.style.filter = 'none';
						}
						else {
							this._spanHolder.style.pointerEvents = 'none';
							this._spanHolder.style.filter = 'brightness(70%) grayscale(100%)';
						}
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
						this._spanHolder.style.opacity = this._opacity/255;
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
						this._spanHolder.style.minWidth = this._minWidth + 'px';
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
						this._spanHolder.style.minHeight = this._minHeight + 'px';
					}
				});

				Object.defineProperty(this, 'alignment', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._alignment;
					},
					set: function (iValue) {
						this._alignment = iValue;
						if (this._alignment === 0) {
							this._spanHolder.style.textAlign = 'left';
						}
						else if (this._alignment === 1) {
							this._spanHolder.style.textAlign = 'center';
						}
						else if (this._alignment === 2) {
							this._spanHolder.style.textAlign = 'right';
						}
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
						this._span.style.color = 'rgb(' + colorEO.GetValueByName('r') + ',' + colorEO.GetValueByName('g') + ',' + colorEO.GetValueByName('b') + ')';
					}
				});

				Object.defineProperty(this, 'text', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._text;
					},
					set: function (iValue) {
						this._text = iValue;
						this._span.innerHTML = this._text;
					}
				});

				Object.defineProperty(this, 'bold', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._bold;
					},
					set: function (iValue) {
						this._bold = iValue;
						if (this._bold) {
							this._span.style.fontWeight = 'bold';
						}
						else {
							this._span.style.fontWeight = 'normal';
						}
					}
				});

				Object.defineProperty(this, 'fontFamily', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._fontFamily;
					},
					set: function (iValue) {
						this._fontFamily = iValue;
						this._span.style.fontFamily = this._fontFamily;
					}
				});


				Object.defineProperty(this, 'height', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._height;
					},
					set: function (iValue) {
						this._height = iValue;
						this._span.style.fontSize = this._height + 'px';
					}
				});

				Object.defineProperty(this, 'italic', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._italic;
					},
					set: function (iValue) {
						this._italic = iValue;
						if (this._italic) {
							this._span.style.fontStyle = 'italic';
						}
						else {
							this._span.style.fontStyle = 'normal';
						}
					}
				});

				Object.defineProperty(this, 'backgroundColor', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._backgroundColor;
					},
					set: function (iValue) {
						this._backgroundColor = iValue;
						if (this.showBackground) {
							var colorEO = this._backgroundColor.QueryInterface('CATI3DExperienceObject');
							this._spanHolder.style.backgroundColor = 'rgb(' + colorEO.GetValueByName('r') + ',' + colorEO.GetValueByName('g') + ',' + colorEO.GetValueByName('b') + ')';
						}
						else {
							this._spanHolder.style.backgroundColor = 'transparent';
						}

					}
				});

				Object.defineProperty(this, 'borderColor', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._borderColor;
					},
					set: function (iValue) {
						this._borderColor = iValue;
						if (this.showBorder) {
							var colorEO = this._borderColor.QueryInterface('CATI3DExperienceObject');
							this._spanHolder.style.borderColor = 'rgb(' + colorEO.GetValueByName('r') + ',' + colorEO.GetValueByName('g') + ',' + colorEO.GetValueByName('b') + ')';
						}
						else {
							this._spanHolder.style.borderColor = 'transparent';
						}
					}
				});

				Object.defineProperty(this, 'showBackground', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._showBackground;
					},
					set: function (iValue) {
						this._showBackground = iValue;
						if (this._showBackground) {
							var color = this.backgroundColor;
							if (color) {
								var colorEO = color.QueryInterface('CATI3DExperienceObject');
								this._spanHolder.style.backgroundColor = 'rgb(' + colorEO.GetValueByName('r') + ',' + colorEO.GetValueByName('g') + ',' + colorEO.GetValueByName('b') + ')';
							}
						}
						else {
							this._spanHolder.style.backgroundColor = 'transparent';
						}
					}
				});

				Object.defineProperty(this, 'showBorder', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._showBorder;
					},
					set: function (iValue) {
						this._showBorder = iValue;
						if (this._showBorder) {
							var color = this.borderColor;
							if (color) {
								var colorEO = color.QueryInterface('CATI3DExperienceObject');
								this._spanHolder.style.borderColor = 'rgb(' + colorEO.GetValueByName('r') + ',' + colorEO.GetValueByName('g') + ',' + colorEO.GetValueByName('b') + ')';
							}
						}
						else {
							this._spanHolder.style.borderColor = 'transparent';
						}
					}
				});


			},

			// Register events for play
			// Click and double click
			registerPlayEvents: function (iSdkObject) {
				this._parent(iSdkObject);

				this._spanHolder.addEventListener('click', this._clickEvent = function () {
					iSdkObject.doUIDispatchEvent('UIClicked', 0);
				});

				this._spanHolder.addEventListener('dblclick', this._dblclickEvent = function () {
					iSdkObject.doUIDispatchEvent('UIDoubleClicked', 0);
				});
			},

			// Release play events
			releasePlayEvents: function () {
				this._parent();

				this._spanHolder.removeEventListener('click', this._clickEvent);
				this._spanHolder.removeEventListener('dblclick', this._dblclickEvent);
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
						data.input.style.width = self._container.offsetWidth + 'px';
						data.input.style.height = self._container.offsetHeight + 'px';
						data.input.style.textAlign = self._spanHolder.style.textAlign;
						data.input.style.lineHeight = self._fontHeight + 'px';
						data.input.style.fontSize = self._fontHeight + 'px';
						data.input.style.boxSizing = 'border-box';
						data.input.inject(self.getContainer());
						data.input.focus();

						data.input.value = self._text;

						data.inputListener = function () {
							var expObj = self._uiActor.QueryInterface('CATI3DExperienceObject');
							var dataObj = expObj.GetValueByName('data').QueryInterface('CATI3DExperienceObject');
							dataObj.SetValueByName('text', data.input.value);
							data.input.destroy();
						};

						data.input.addEventListener('focusout', data.inputListener);
						data.input.addEventListener('change', data.inputListener);
					}
				}];
			}
		});
	return CXPText;
});





/**
 * @exports DS/CATCXPCIDModel/CXPTextField
 */
define('DS/CATCXPCIDModel/CXPTextField',
// dependencies
[
    'UWA/Core',
	'DS/CATCXPCIDModel/CXPUIActor',
	'DS/Controls/Editor'
],
function (UWA, CXPUIActor, WUXEditor) {

	'use strict';

	/**
	* @name DS/CATCXPCIDModel/CXPTextField
    * @description
    * Text Field
	* @constructor
	*/

	var CXPTextField = CXPUIActor.extend(
		/** @lends DS/CATCXPCIDModel/CXPTextField.prototype **/
		{

			init: function (iUIActor) {
				this._parent(iUIActor);

				this._editor = new WUXEditor().inject(this.getContainer());
				this._editor.elements.container.childNodes[0].style.boxSizing = 'border-box';
				this._editor.elements.container.childNodes[0].style.overflow = 'hidden';
				this._editor.elements.container.childNodes[0].style.whiteSpace = 'nowrap';
				this._editor.nbRows = 1;

				Object.defineProperty(this, 'visible', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._visible;
					},
					set: function (iValue) {
						this._visible = iValue;
						this._editor.visibleFlag = this._visible;
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
						this._editor.disabled = !this._enable;
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
						this._editor.elements.container.childNodes[0].style.opacity = this._opacity/255;
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
						this._editor.elements.container.childNodes[0].style.width = this._minWidth + 'px';
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
						this._editor.elements.container.childNodes[0].style.height = this._minHeight + 'px';
						this._editor.elements.container.childNodes[0].style.paddingTop = (this._minHeight / 2) - 9 /*lineHeight / 2*/ + 'px';
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
						this._editor.value = this._text;
					}
				});

			},

			// Register events for play
			// Text change and Return press
			registerPlayEvents: function (iSdkObject) {
				this._parent(iSdkObject);
				var self = this;

				this._editor.addEventListener('uncommittedChange', this._valueChanged = function () {
					iSdkObject.text = self._editor.valueToCommit;
					iSdkObject.doUIDispatchEvent('UIValueChanged', 0);
				});

				this._editor.addEventListener('keypress', this._returnPress = function (e) {
					if (e.keyCode === 13) {
						iSdkObject.doUIDispatchEvent('UIReturnPressed', 0);
						e.preventDefault();
					}
				});
			},

			// Release play events
			releasePlayEvents: function () {
				this._parent();

				this._editor.removeEventListener('uncommittedChange', this._valueChanged);
				this._editor.removeEventListener('keypress', this._returnPress);
			}
		});
	return CXPTextField;
});





/**
 * @exports DS/CATCXPCIDModel/CXPSlider
 */
define('DS/CATCXPCIDModel/CXPSlider',
// dependencies
[
    'UWA/Core',
	'DS/CATCXPCIDModel/CXPUIActor',
	'DS/Controls/Slider'
],
function (UWA, CXPUIActor, WUXSlider) {

	'use strict';

	/**
	* @name DS/CATCXPCIDModel/CXPSlider
	* @description
	* Create a Slider ui actor rep (<div> WUXSlider <\div>)
	* Define specific properties and bind them to the rep
	* @constructor
	*/

	var CXPSlider = CXPUIActor.extend(
		/** @lends DS/CATCXPCIDModel/CXPSlider.prototype **/
		{

			init: function (iUIActor) {
				this._parent(iUIActor);

				this._holder = UWA.createElement('div').inject(this.getContainer());
				this._holder.style.overflow = 'hidden';
				this._slider = new WUXSlider().inject(this._holder);

				Object.defineProperty(this, 'visible', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._visible;
					},
					set: function (iValue) {
						this._visible = iValue;
						if (this._visible) {
							this._holder.style.display = 'inherit';
						}
						else {
							this._holder.style.display = 'none';
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
						this._slider.disabled = !this._enable;
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
						this._holder.style.opacity = this._opacity/255;
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
						this._holder.style.minWidth = this._minWidth + 'px';
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
						this._holder.style.minHeight = this._minHeight + 'px';
					}
				});

				//	Object.defineProperty(this, 'labelPosition', {			TODO	
				//		enumerable: true,										
				//		configurable: true,										
				//		get: function () {										
				//			return this._labelPosition;							
				//		},														
				//		set: function (iValue) {								
				//			this._labelPosition = iValue;						
				//		}														
				//	});															
				//
				//	Object.defineProperty(this, 'showValueLabel', {
				//		enumerable: true,
				//		configurable: true,
				//		get: function () {
				//			return this._showValueLabel;
				//		},
				//		set: function (iValue) {
				//			this._showValueLabel = iValue;
				//			if (this._showValueLabel) {
				//				
				//			}
				//			else {
				//				
				//			}
				//		}
				//	});
				//
				//	Object.defineProperty(this, 'valueUnit', {
				//		enumerable: true,
				//		configurable: true,
				//		get: function () {
				//			return this._valueUnit;
				//		},
				//		set: function (iValue) {
				//			this._valueUnit = iValue;
				//		
				//		}
				//	});

				Object.defineProperty(this, 'orientation', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._orientation;
					},
					set: function (iValue) {
						this._orientation = iValue;
						if (this._orientation === 0) {
							this._slider.displayStyle = 'vertical';
						}
						else if (this._orientation === 1) {
							this._slider.displayStyle = 'horizontal';
						}
					}
				});

				Object.defineProperty(this, 'maximumValue', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._maximumValue;
					},
					set: function (iValue) {
						this._maximumValue = iValue;
						this._slider.maxValue = this._maximumValue;
					}
				});

				Object.defineProperty(this, 'minimumValue', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._minimumValue;
					},
					set: function (iValue) {
						this._minimumValue = iValue;
						this._slider.minValue = this._minimumValue;
					}
				});

				Object.defineProperty(this, 'stepValue', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._stepValue;
					},
					set: function (iValue) {
						this._stepValue = iValue;
						this._slider.stepValue = this._stepValue;
					}
				});

				Object.defineProperty(this, 'value', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._value;
					},
					set: function (iValue) {
						this._value = iValue;
						this._slider.value = this._value;
						//TODO change labelValue
					}
				});

			},

			// Register events for play
			registerPlayEvents: function (iSdkObject) {
				var self = this;
				this._parent(iSdkObject);

				this._slider.addEventListener('change', this._sliderValueLiveChanged = function () {
					iSdkObject.value = self._slider.value;
					iSdkObject.doUIDispatchEvent('UIValueChanged', 0);
				});
			},

			// Release play events
			releasePlayEvents: function () {
				this._parent();

				this._slider.removeEventListener('liveChange', this._sliderValueLiveChanged);
				this._slider.removeEventListener('change', this._sliderValueChanged);
			}

		});
	return CXPSlider;
});





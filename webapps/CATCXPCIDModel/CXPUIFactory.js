/**
 * CXPUIFactory
 * Singleton class responsible to create and configure CXPUIActor_Spec
 * @exports DS/CATCXPCIDModel/CXPUIFactory
 */
define('DS/CATCXPCIDModel/CXPUIFactory',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXModel',
	'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject'
],
function (UWA, CAT3DXModel, CATI3DExperienceObject) {
	'use strict';

	/**
	 * Singleton factory for constructing UIActors
	 * @name DS/CATCXPCIDModel/CXPUIFactory
	 * @constructor
	 */

	//SHOULD BE DONE IN VARIABLES INIT!!!!

	var CXPUIFactory = function () {
		/** @lends DS/CATCXPCIDModel/CXPUIFactory **/
		var instance = {
			init: function () {
				this._parent();
			},

			// FillButtonVariables
			FillButtonVariables: function (iButton) {
				var self = this;
				var data, iconDimension, minimumDimension;
				data = iButton.QueryInterface('CATI3DExperienceObject').GetValueByName('data');
				minimumDimension = iButton.QueryInterface('CATI3DExperienceObject').GetValueByName('minimumDimension');

				this.CreateVariable(data, 'fontHeight', CATI3DExperienceObject.VarType.Integer, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				this.CreateVariable(data, 'icon', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.ReferencingValue);
				this.CreateVariable(data, 'iconDimension', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				this.CreateVariable(data, 'label', CATI3DExperienceObject.VarType.String, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				this.CreateVariable(data, 'pushable', CATI3DExperienceObject.VarType.Boolean, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				this.CreateVariable(data, 'pushed', CATI3DExperienceObject.VarType.Boolean, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);

				return this.CreateComponent('Vector2D_Spec', 'iconDimension', data).done(function (iVector) {
					iconDimension = iVector;
					iconDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('x', 32, CATI3DExperienceObject.SetValueMode.NoCheck);
					iconDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('y', 32, CATI3DExperienceObject.SetValueMode.NoCheck);

					minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('width', 100, CATI3DExperienceObject.SetValueMode.NoCheck);
					minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('height', 32, CATI3DExperienceObject.SetValueMode.NoCheck);

					iButton.QueryInterface('CATI3DExperienceObject').SetValueByName('minimumDimension', minimumDimension, CATI3DExperienceObject.SetValueMode.NoCheck);
					iButton.QueryInterface('CATI3DExperienceObject').SetValueByName('events', ['UIClicked'], CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPButton', CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('fontHeight', 16, CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('iconDimension', iconDimension, CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('label', 'Button', CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('pushable', true, CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('pushed', false, CATI3DExperienceObject.SetValueMode.NoCheck);

					return self._addNaturalLanguageEvent(iButton);
				});
			},

			FillImageVariables: function (iImage) {
				var self = this;
				var data, minimumDimension;
				data = iImage.QueryInterface('CATI3DExperienceObject').GetValueByName('data');
				minimumDimension = iImage.QueryInterface('CATI3DExperienceObject').GetValueByName('minimumDimension');

				this.CreateVariable(data, 'image', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.ReferencingValue);

				minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('width', 200, CATI3DExperienceObject.SetValueMode.NoCheck);
				minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('height', 120, CATI3DExperienceObject.SetValueMode.NoCheck);

				iImage.QueryInterface('CATI3DExperienceObject').SetValueByName('minimumDimension', minimumDimension, CATI3DExperienceObject.SetValueMode.NoCheck);
				iImage.QueryInterface('CATI3DExperienceObject').SetValueByName('events', ['UIClicked', 'UIDoubleClicked'], CATI3DExperienceObject.SetValueMode.NoCheck);
				data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPImage', CATI3DExperienceObject.SetValueMode.NoCheck);

				return self._addNaturalLanguageEvent(iImage);
			},

			FillTextVariables: function (iText) {
			    var self = this;
			    var data, minimumDimension, backgroundColor, borderColor, color;
			    data = iText.QueryInterface('CATI3DExperienceObject').GetValueByName('data');
			    minimumDimension = iText.QueryInterface('CATI3DExperienceObject').GetValueByName('minimumDimension');

			    this.CreateVariable(data, 'alignment', CATI3DExperienceObject.VarType.Double, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'backgroundColor', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'bold', CATI3DExperienceObject.VarType.Boolean, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'borderColor', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'color', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'font', CATI3DExperienceObject.VarType.String, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'height', CATI3DExperienceObject.VarType.Integer, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'italic', CATI3DExperienceObject.VarType.Boolean, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'showBackground', CATI3DExperienceObject.VarType.Boolean, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'showBorder', CATI3DExperienceObject.VarType.Boolean, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'text', CATI3DExperienceObject.VarType.String, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);

			    return this.CreateComponent('Color_Spec', 'backgroundColor', data).done(function (iBackgroundColor) {
			        backgroundColor = iBackgroundColor;

			        return self.CreateComponent('Color_Spec', 'borderColor', data);
			    }).done(function (iBorderColor) {
			        borderColor = iBorderColor;

			        return self.CreateComponent('Color_Spec', 'color', data);
			    }).done(function (iColor) {
			        color = iColor;

			        minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('width', 120, CATI3DExperienceObject.SetValueMode.NoCheck);
			        minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('height', 30, CATI3DExperienceObject.SetValueMode.NoCheck);

			        iText.QueryInterface('CATI3DExperienceObject').SetValueByName('minimumDimension', minimumDimension, CATI3DExperienceObject.SetValueMode.NoCheck);
			        iText.QueryInterface('CATI3DExperienceObject').SetValueByName('events', ['UIClicked', 'UIDoubleClicked'], CATI3DExperienceObject.SetValueMode.NoCheck);

			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPText', CATI3DExperienceObject.SetValueMode.NoCheck);
			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('alignment', 0, CATI3DExperienceObject.SetValueMode.NoCheck);

			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('backgroundColor', self._setColor(backgroundColor, 230, 230, 230, 255), CATI3DExperienceObject.SetValueMode.NoCheck);
			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('bold', false, CATI3DExperienceObject.SetValueMode.NoCheck);
			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('borderColor', self._setColor(borderColor, 150, 150, 150, 255), CATI3DExperienceObject.SetValueMode.NoCheck);
			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('color', self._setColor(color, 0, 0, 0, 255), CATI3DExperienceObject.SetValueMode.NoCheck);
			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('font', 'Arial', CATI3DExperienceObject.SetValueMode.NoCheck);
			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('height', 16, CATI3DExperienceObject.SetValueMode.NoCheck);
			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('italic', false, CATI3DExperienceObject.SetValueMode.NoCheck);
			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('showBackground', true, CATI3DExperienceObject.SetValueMode.NoCheck);
			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('showBorder', true, CATI3DExperienceObject.SetValueMode.NoCheck);
			        data.QueryInterface('CATI3DExperienceObject').SetValueByName('text', 'Text', CATI3DExperienceObject.SetValueMode.NoCheck);

			        return self._addNaturalLanguageEvent(iText);
			    });
			},

			FillSliderVariables: function (iSlider) {
			    var self = this;
			    var data, minimumDimension;
			    data = iSlider.QueryInterface('CATI3DExperienceObject').GetValueByName('data');
			    minimumDimension = iSlider.QueryInterface('CATI3DExperienceObject').GetValueByName('minimumDimension');

			    this.CreateVariable(data, 'labelPosition', CATI3DExperienceObject.VarType.Integer, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'maximumValue', CATI3DExperienceObject.VarType.Double, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'minimumValue', CATI3DExperienceObject.VarType.Double, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'orientation', CATI3DExperienceObject.VarType.Integer, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'showValueLabel', CATI3DExperienceObject.VarType.Boolean, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'stepValue', CATI3DExperienceObject.VarType.Double, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'value', CATI3DExperienceObject.VarType.Double, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
			    this.CreateVariable(data, 'valueUnit', CATI3DExperienceObject.VarType.String, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);

			    minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('width', 200, CATI3DExperienceObject.SetValueMode.NoCheck);
			    minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('height', 36, CATI3DExperienceObject.SetValueMode.NoCheck);

			    iSlider.QueryInterface('CATI3DExperienceObject').SetValueByName('minimumDimension', minimumDimension, CATI3DExperienceObject.SetValueMode.NoCheck);
			    iSlider.QueryInterface('CATI3DExperienceObject').SetValueByName('events', ['UIValueChanged'], CATI3DExperienceObject.SetValueMode.NoCheck);

			    data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPSlider', CATI3DExperienceObject.SetValueMode.NoCheck);
			    data.QueryInterface('CATI3DExperienceObject').SetValueByName('labelPosition', 0, CATI3DExperienceObject.SetValueMode.NoCheck);
			    data.QueryInterface('CATI3DExperienceObject').SetValueByName('maximumValue', 1, CATI3DExperienceObject.SetValueMode.NoCheck);
			    data.QueryInterface('CATI3DExperienceObject').SetValueByName('minimumValue', 0, CATI3DExperienceObject.SetValueMode.NoCheck);
			    data.QueryInterface('CATI3DExperienceObject').SetValueByName('orientation', 1, CATI3DExperienceObject.SetValueMode.NoCheck);
			    data.QueryInterface('CATI3DExperienceObject').SetValueByName('showValueLabel', true, CATI3DExperienceObject.SetValueMode.NoCheck);
			    data.QueryInterface('CATI3DExperienceObject').SetValueByName('stepValue', 1, CATI3DExperienceObject.SetValueMode.NoCheck);
			    data.QueryInterface('CATI3DExperienceObject').SetValueByName('value', 1, CATI3DExperienceObject.SetValueMode.NoCheck);
			    data.QueryInterface('CATI3DExperienceObject').SetValueByName('valueUnit', 'Unit', CATI3DExperienceObject.SetValueMode.NoCheck);

			    return self._addNaturalLanguageEvent(iSlider);
			},

			FillTextFieldVariables: function (iTextField) {
				var self = this;
				var data, minimumDimension;
				data = iTextField.QueryInterface('CATI3DExperienceObject').GetValueByName('data');
				minimumDimension = iTextField.QueryInterface('CATI3DExperienceObject').GetValueByName('minimumDimension');

				this.CreateVariable(data, 'text', CATI3DExperienceObject.VarType.String, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);

				minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('width', 100, CATI3DExperienceObject.SetValueMode.NoCheck);
				minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('height', 22, CATI3DExperienceObject.SetValueMode.NoCheck);

				iTextField.QueryInterface('CATI3DExperienceObject').SetValueByName('minimumDimension', minimumDimension, CATI3DExperienceObject.SetValueMode.NoCheck);
				iTextField.QueryInterface('CATI3DExperienceObject').SetValueByName('events', ['UIReturnPressed', 'UIValueChanged'], CATI3DExperienceObject.SetValueMode.NoCheck);

				data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPTextField', CATI3DExperienceObject.SetValueMode.NoCheck);
				data.QueryInterface('CATI3DExperienceObject').SetValueByName('text', 'Text', CATI3DExperienceObject.SetValueMode.NoCheck);

				return self._addNaturalLanguageEvent(iTextField);
			},

			FillColorPickerVariables: function (iColorPicker) {
				var self = this;
				var data, minimumDimension, color;
				data = iColorPicker.QueryInterface('CATI3DExperienceObject').GetValueByName('data');
				minimumDimension = iColorPicker.QueryInterface('CATI3DExperienceObject').GetValueByName('minimumDimension');

				this.CreateVariable(data, 'color', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);

				return this.CreateComponent('Color_Spec', 'color', data).done(function (iColor) {
					color = iColor;

					minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('width', 0, CATI3DExperienceObject.SetValueMode.NoCheck);
					minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('height', 0, CATI3DExperienceObject.SetValueMode.NoCheck);

					iColorPicker.QueryInterface('CATI3DExperienceObject').SetValueByName('minimumDimension', minimumDimension, CATI3DExperienceObject.SetValueMode.NoCheck);
					iColorPicker.QueryInterface('CATI3DExperienceObject').SetValueByName('events', ['UIValueChanged'], CATI3DExperienceObject.SetValueMode.NoCheck);

					data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPColorPicker', CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('color', self._setColor(color, 230, 230, 230, 255), CATI3DExperienceObject.SetValueMode.NoCheck);
					return self._addNaturalLanguageEvent(iColorPicker);
				});
			},

			FillCameraViewerVariables: function (iCameraViewer) {
				var self = this;
				var data, minimumDimension;
				data = iCameraViewer.QueryInterface('CATI3DExperienceObject').GetValueByName('data');
				minimumDimension = iCameraViewer.QueryInterface('CATI3DExperienceObject').GetValueByName('minimumDimension');

				this.CreateVariable(data, 'liveUpdate', CATI3DExperienceObject.VarType.Boolean, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				this.CreateVariable(data, 'camera', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.ReferencingValue);

				minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('width', 200, CATI3DExperienceObject.SetValueMode.NoCheck);
				minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('height', 200, CATI3DExperienceObject.SetValueMode.NoCheck);

				iCameraViewer.QueryInterface('CATI3DExperienceObject').SetValueByName('minimumDimension', minimumDimension, CATI3DExperienceObject.SetValueMode.NoCheck);
				iCameraViewer.QueryInterface('CATI3DExperienceObject').SetValueByName('events', ['UIClicked', 'UIDoubleClicked'], CATI3DExperienceObject.SetValueMode.NoCheck);

				data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPCameraViewer', CATI3DExperienceObject.SetValueMode.NoCheck);
				data.QueryInterface('CATI3DExperienceObject').SetValueByName('liveUpdate', true, CATI3DExperienceObject.SetValueMode.NoCheck);
				return self._addNaturalLanguageEvent(iCameraViewer);
			},

			FillWebViewerVariables: function (iWebViewer) {
				var self = this;
				var data, minimumDimension;
				data = iWebViewer.QueryInterface('CATI3DExperienceObject').GetValueByName('data');
				minimumDimension = iWebViewer.QueryInterface('CATI3DExperienceObject').GetValueByName('minimumDimension');

				this.CreateVariable(data, 'message', CATI3DExperienceObject.VarType.String, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				this.CreateVariable(data, 'script', CATI3DExperienceObject.VarType.String, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				this.CreateVariable(data, 'url', CATI3DExperienceObject.VarType.String, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);

				minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('width', 400, CATI3DExperienceObject.SetValueMode.NoCheck);
				minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('height', 200, CATI3DExperienceObject.SetValueMode.NoCheck);

				iWebViewer.QueryInterface('CATI3DExperienceObject').SetValueByName('minimumDimension', minimumDimension, CATI3DExperienceObject.SetValueMode.NoCheck);

				data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPWebViewer', CATI3DExperienceObject.SetValueMode.NoCheck);
				data.QueryInterface('CATI3DExperienceObject').SetValueByName('message', '', CATI3DExperienceObject.SetValueMode.NoCheck);
				data.QueryInterface('CATI3DExperienceObject').SetValueByName('script', '', CATI3DExperienceObject.SetValueMode.NoCheck);
				data.QueryInterface('CATI3DExperienceObject').SetValueByName('url', 'https://www.3ds.com/fr/', CATI3DExperienceObject.SetValueMode.NoCheck);
				return self._addNaturalLanguageEvent(iWebViewer);
			},

			FillGalleryVariables: function (iGallery) {
				var data, minimumDimension, item;
				data = iGallery.QueryInterface('CATI3DExperienceObject').GetValueByName('data');
				minimumDimension = iGallery.QueryInterface('CATI3DExperienceObject').GetValueByName('minimumDimension');

				this.CreateVariable(data, 'itemSize', CATI3DExperienceObject.VarType.Object, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				this.CreateVariable(data, 'orientation', CATI3DExperienceObject.VarType.Integer, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				this.CreateVariable(data, 'stretchToContent', CATI3DExperienceObject.VarType.Boolean, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				this.CreateVariable(data, 'items', CATI3DExperienceObject.VarType.Object, 0, CATI3DExperienceObject.ValuationMode.AggregatingValue);

				return this.CreateComponent('CXPDataItem_Spec', 'items', data).done(function (iItem) {
					item = iItem;
					item.QueryInterface('CATI3DExperienceObject').SetValueByName('label', 'My Label', CATI3DExperienceObject.SetValueMode.NoCheck);

					minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('width', NaN, CATI3DExperienceObject.SetValueMode.NoCheck);
					minimumDimension.QueryInterface('CATI3DExperienceObject').SetValueByName('height', NaN, CATI3DExperienceObject.SetValueMode.NoCheck);

					iGallery.QueryInterface('CATI3DExperienceObject').SetValueByName('minimumDimension', minimumDimension, CATI3DExperienceObject.SetValueMode.NoCheck);

					data.QueryInterface('CATI3DExperienceObject').SetValueByName('orientation', 1, CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('stretchToContent', true, CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('items', [item], CATI3DExperienceObject.SetValueMode.NoCheck);
				});
			},


			FillGalleryMenuVariables: function (iGalleryMenu) {
				var self = this;
				var data, itemSize;
				data = iGalleryMenu.QueryInterface('CATI3DExperienceObject').GetValueByName('data');

				this.CreateVariable(data, 'itemFontHeight', CATI3DExperienceObject.VarType.Integer, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);

				return this.FillGalleryVariables(iGalleryMenu).done(function () {
				    return self.CreateComponent('Vector2D_Spec', 'itemSize', data);
				}).done(function (iVector) {
					itemSize = iVector;
					itemSize.QueryInterface('CATI3DExperienceObject').SetValueByName('x', 200, CATI3DExperienceObject.SetValueMode.NoCheck);
					itemSize.QueryInterface('CATI3DExperienceObject').SetValueByName('y', 100, CATI3DExperienceObject.SetValueMode.NoCheck);

					iGalleryMenu.QueryInterface('CATI3DExperienceObject').SetValueByName('events', ['UIClicked'], CATI3DExperienceObject.SetValueMode.NoCheck);

					data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPGalleryMenu', CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('itemSize', itemSize, CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('itemFontHeight', 30, CATI3DExperienceObject.SetValueMode.NoCheck);
					return self._addNaturalLanguageEvent(iGalleryMenu);
				});
			},

			FillGalleryImageVariables: function (iGalleryImage) {
				var self = this;
				var data, itemSize;
				data = iGalleryImage.QueryInterface('CATI3DExperienceObject').GetValueByName('data');

				this.CreateVariable(data, 'itemFontHeight', CATI3DExperienceObject.VarType.Integer, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);

				return this.FillGalleryVariables(iGalleryImage).done(function () {
				    return self.CreateComponent('Vector2D_Spec', 'itemSize', data);
				}).done(function (iVector) {
					itemSize = iVector;
					itemSize.QueryInterface('CATI3DExperienceObject').SetValueByName('x', 200, CATI3DExperienceObject.SetValueMode.NoCheck);
					itemSize.QueryInterface('CATI3DExperienceObject').SetValueByName('y', 120, CATI3DExperienceObject.SetValueMode.NoCheck);

					iGalleryImage.QueryInterface('CATI3DExperienceObject').SetValueByName('events', ['UIClicked', 'UIDoubleClicked'], CATI3DExperienceObject.SetValueMode.NoCheck);

					data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPGalleryImage', CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('itemSize', itemSize, CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('itemFontHeight', 30, CATI3DExperienceObject.SetValueMode.NoCheck);
					return self._addNaturalLanguageEvent(iGalleryImage);
				});
			},

			FillGalleryProductVariables: function (iGalleryProduct) {
				var self = this;
				var data, itemSize;
				data = iGalleryProduct.QueryInterface('CATI3DExperienceObject').GetValueByName('data');

				this.CreateVariable(data, 'itemFontHeight', CATI3DExperienceObject.VarType.Integer, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);

				return this.FillGalleryVariables(iGalleryProduct).done(function () {
				    return self.CreateComponent('Vector2D_Spec', 'itemSize', data);
				}).done(function (iVector) {
					itemSize = iVector;
					itemSize.QueryInterface('CATI3DExperienceObject').SetValueByName('x', 200, CATI3DExperienceObject.SetValueMode.NoCheck);
					itemSize.QueryInterface('CATI3DExperienceObject').SetValueByName('y', 120, CATI3DExperienceObject.SetValueMode.NoCheck);

					iGalleryProduct.QueryInterface('CATI3DExperienceObject').SetValueByName('events', ['UIClicked', 'UIDoubleClicked'], CATI3DExperienceObject.SetValueMode.NoCheck);

					data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPGalleryProduct', CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('itemSize', itemSize, CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('itemFontHeight', 30, CATI3DExperienceObject.SetValueMode.NoCheck);
					return self._addNaturalLanguageEvent(iGalleryProduct);
				});
			},

			FillGalleryViewpointVariables: function (iViewpointGalery) {
				var self = this;
				var data, itemSize, behaviorScript, scriptInstance;
				data = iViewpointGalery.QueryInterface('CATI3DExperienceObject').GetValueByName('data');

				this.CreateVariable(data, 'itemFontHeight', CATI3DExperienceObject.VarType.Integer, 1, CATI3DExperienceObject.ValuationMode.AggregatingValue);

				return this.FillGalleryVariables(iViewpointGalery).done(function () {
				    return self.CreateComponent('Vector2D_Spec', 'itemSize', data);
				}).done(function (iVector) {
					itemSize = iVector;
					itemSize.QueryInterface('CATI3DExperienceObject').SetValueByName('x', 200, CATI3DExperienceObject.SetValueMode.NoCheck);
					itemSize.QueryInterface('CATI3DExperienceObject').SetValueByName('y', 120, CATI3DExperienceObject.SetValueMode.NoCheck);

					return self.CreateComponent('CXPScriptBe_Spec', 'behaviors', iViewpointGalery);
				}).done(function(iScript){
					behaviorScript = iScript;

					return self.CreateComponent('EPSScript_Spec', 'scriptinstance', behaviorScript);
				}).done(function (IScriptInstance) {
					scriptInstance = IScriptInstance;

					var script = 'beScript.onStart = function () {									  \n' +
					'	//Will be called on the experience start.									  \n' +
					'};																				  \n' +
					'																				  \n' +
					'beScript.onStop = function () {												  \n' +
					'	//Will be called on experience stop.										  \n' +
					'};																				  \n' +
					'																				  \n' +
					'beScript.execute = function (context) {									      \n' +
					'	//Will be called on each frame.												  \n' +
					"	//To access last frame duration, use 'context.deltaTime'.					  \n" +
					'																				  \n' +
					'	//Insert your code here.													  \n' +
					'};																				  \n' +
					'																				  \n' +
					'//This event is dispatched when an item of the gallery is double clicked.		  \n' +
					'beScript.onUIDoubleClicked = function (iEvent) {								  \n' +
					'	//You can access to the gallery through iEvent.sender						  \n' +
					'	//You can access to the clicked item index through iEvent.index				  \n' +
					'																				  \n' +
					'	//Retrieve the camera of the clicked item									  \n' +
					'	var selectedCamera = this.getActor().items[iEvent.index].camera;			  \n' +
					'	//Set the camera as current													  \n' +
					'	var renderManager = STU.RenderManager.getInstance();						  \n' +
					'	renderManager.setCurrentCamera(selectedCamera);								  \n' +
					'};																				  \n' +
					'//This event is dispatched when an item of the gallery is clicked.				  \n' +
					'beScript.onUIClicked = function (iEvent) {										  \n' +
					'	//You can access to the gallery through iEvent.sender						  \n' +
					'	//You can access to the clicked item index through iEvent.index				  \n' +
					'																				  \n' +
					'};';
					behaviorScript.QueryInterface('CATI3DExperienceObject').SetValueByName('scriptinstance', scriptInstance, CATI3DExperienceObject.SetValueMode.NoCheck);
					scriptInstance.QueryInterface('CATI3DExperienceObject').SetValueByName('script', script, CATI3DExperienceObject.SetValueMode.NoCheck);
					iViewpointGalery.QueryInterface('CATICXPBehaviorsMgr').AddBehavior(behaviorScript);

					iViewpointGalery.QueryInterface('CATI3DExperienceObject').SetValueByName('events', ['UIClicked', 'UIDoubleClicked'], CATI3DExperienceObject.SetValueMode.NoCheck);

					data.QueryInterface('CATI3DExperienceObject').SetValueByName('__configurationName__', 'CXPGalleryViewpoint', CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('itemSize', itemSize, CATI3DExperienceObject.SetValueMode.NoCheck);
					data.QueryInterface('CATI3DExperienceObject').SetValueByName('itemFontHeight', 30, CATI3DExperienceObject.SetValueMode.NoCheck);
					return self._addNaturalLanguageEvent(iViewpointGalery);
				});
			},


			_setColor: function (color, r, g, b, a) {
				var expObj = color.QueryInterface('CATI3DExperienceObject');
				expObj.SetValueByName('r', r, CATI3DExperienceObject.SetValueMode.NoCheck);
				expObj.SetValueByName('g', g, CATI3DExperienceObject.SetValueMode.NoCheck);
				expObj.SetValueByName('b', b, CATI3DExperienceObject.SetValueMode.NoCheck);
				expObj.SetValueByName('a', a, CATI3DExperienceObject.SetValueMode.NoCheck);
				return color;
			},

			_addEventSpec: function (iEventName, NLEvents, iObject) {
			    var self = this;
				var event;

				return this.CreateComponent('Event_Spec', '_events', iObject).done(function (iEvent) {
				    event = iEvent;
				    event.QueryInterface('CATI3DExperienceObject').SetValueByName('_targetParam', '', CATI3DExperienceObject.SetValueMode.NoCheck);
				    iEvent.QueryInterface('CATIAlias').SetAlias(iEventName + 'Event');
					NLEvents.push(iEvent);

					return self.CreateComponent('NaturalLanguageInfo', '_naturalLanguageInfo', iEvent);
				}).done(function (component) {
					var nlInfoEo = component.QueryInterface('CATI3DExperienceObject');
					nlInfoEo.QueryInterface('CATI3DExperienceObject').SetValueByName('_alias', iEventName, CATI3DExperienceObject.SetValueMode.NoCheck);
					nlInfoEo.QueryInterface('CATI3DExperienceObject').SetValueByName('_capacityType', 'SensorEvent', CATI3DExperienceObject.SetValueMode.NoCheck);
					event.QueryInterface('CATI3DExperienceObject').SetValueByName('_naturalLanguageInfo', component, CATI3DExperienceObject.SetValueMode.NoCheck);
				});
			},

			_addNaturalLanguageEvent: function (iObject) {
			    var events = iObject.QueryInterface('CATI3DExperienceObject').GetValueByName('events');
				var NLEvents = [];
				var promises = [];

				if (events.length > 0) {
				    if (!iObject.QueryInterface('CATI3DExperienceObject').HasVariable('_events')) {
				        this.CreateVariable(iObject, '_events',
							CATI3DExperienceObject.VarType.Object, 0, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				    }
				} else {
				    return UWA.Promise.resolve();
				}

				for (var i = 0; i < events.length; i++) {
				    promises.push(this._addEventSpec(events[i], NLEvents, iObject));
				}
				return UWA.Promise.all(promises).then(function () {
				    var _events = iObject.QueryInterface('CATI3DExperienceObject').GetValueByName('_events');
				    _events = Array.isArray(_events) ? _events.concat(NLEvents) : NLEvents;
				    iObject.QueryInterface('CATI3DExperienceObject').SetValueByName('_events', _events, CATI3DExperienceObject.SetValueMode.NoCheck);
				});
			},

            //Create component or variable with path of ids
			CreateComponent: function (iSpec, iVariableName, iParent) {
			    //will not add component under parent;
			    if (!iParent.QueryInterface('CATI3DExperienceObject').HasVariable(iVariableName)) {
			        console.error(iVariableName + ' is not a variable of ' + iParent.GetType());
			        return UWA.Promise.reject(new Error(iVariableName + ' is not a variable of ' + iParent.GetType()));
			    }

			    var id = iParent.QueryInterface('CATI3DExperienceObject').GetVariableID(iVariableName) + ',' + UWA.Utils.getUUID();
			    return CAT3DXModel.BuildComponent(iSpec, id).done(function (iComponent) {
			        var variablesNames = [];
			        iComponent.QueryInterface('CATI3DExperienceObject').ListVariables(variablesNames);
			        for (var i = 0; i < variablesNames.length; i++) {
			            iComponent.QueryInterface('CATI3DExperienceObject').SetVariableID(variablesNames[i], id + ',' + variablesNames[i]);
			        }
			        return UWA.Promise.resolve(iComponent);
			    });
			},

			CreateVariable: function (iParent, iVariableName, iType, iMaxNumberOfValues, iMode, iRestrictiveTypes) {
			    iParent.QueryInterface('CATI3DExperienceObject').AddVariable(iVariableName, iType, iMaxNumberOfValues, iMode, iRestrictiveTypes);
			    iParent.QueryInterface('CATI3DExperienceObject').SetVariableID(iVariableName, iParent.GetID() + ',' + iVariableName);
			}


    	};
    	return instance;
    };
	return new CXPUIFactory();
});




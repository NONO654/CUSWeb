/**
 * @exports DS/CATCXPCIDModel/CXPUIMapper
 */
define('DS/CATCXPCIDModel/CXPUIMapper',
// dependencies
[
    'UWA/Core',
	'UWA/Class/Listener'
],
function (UWA,
		  Listener) {

	'use strict';

	/**
	* @name DS/CATCXPCIDModel/CXPUIMapper
    * @description
	* Map Model variables with UI properties
	* 
	* @constructor
	*/

	var UIMapper = Listener.extend(
		/** @lends DS/CATCXPCIDModel/CXPUIMapper.prototype **/
		{

		init: function (iUI, iModel, iBindingArray) {
			for (var i = 0; i < iBindingArray.length; i++) {
				this._createBinding(iUI, iBindingArray[i].ui, iModel, iBindingArray[i].model, iBindingArray[i].func);
			}
		},

		_getModelForBinding: function (iPath, iModel) {
			var pathArray = iPath.split('.');
			if (pathArray.length === 0) {
				console.error('UIMapper : invalid model variable path');
				return undefined;
			}

			var object = iModel;
			var variableName = pathArray[0];
			var pathIdx = 0;
			while (pathIdx < pathArray.length -1) {
			    var object = object.QueryInterface('CATI3DExperienceObject').GetValueByName(pathArray[pathIdx]);
				if (!object) {
					console.error('UIMapper : invalid model variable path');
					return undefined;
				}
				pathIdx++;
				variableName = pathArray[pathIdx];
			}

			return {
				object: object,
				variableName : variableName
			};
		},

		_getUIVariable: function (iPath, iUIObject) {
			var pathArray = iPath.split('.');

			if (pathArray.length === 0) {
				console.error('UIMapper : invalid UI variable path');
				return undefined;
			}

			var pathIdx = 0;
			var parentVariable = iUIObject;

			while (pathIdx < pathArray.length - 1) {
				if (!parentVariable)
				{
					console.error('UIMapper : invalid UI variable path');
					return undefined;
				}
				parentVariable = parentVariable[pathArray[pathIdx]];
				pathIdx++;
			}
			return {
				variableName: pathArray[pathArray.length - 1],
				parent: parentVariable
			};
		},

		_createBinding: function (iUI, iPathUI, iModel, iPathModel, iFunc) {
			var pathUIArray = iPathUI.split('.');
			if (pathUIArray.length === 0) {
				console.error('UIMapper : invalid UI variable path');
				return;
			}

			var modelBinding = this._getModelForBinding(iPathModel, iModel);
			var object = modelBinding.object;
			var variableName = modelBinding.variableName;

			var ui = this._getUIVariable(iPathUI, iUI);
			var parentVariableUI = ui.parent;
			var UIVariableName = ui.variableName;

			var setValue = function (iValue) {
				var value;
				if (iFunc) {
					value = iFunc(iValue);
				}
				else {
					value = iValue;
				}
				parentVariableUI[UIVariableName] = value;
			};
			if (object && variableName) {
			    var expObject = object.QueryInterface('CATI3DExperienceObject');
			    this.listenTo(expObject, variableName + '.CHANGED', function (iValue) {
					setValue(iValue);
				});
			    setValue(expObject.GetValueByName(variableName));
			} else {
				console.warn('UIMapper : can t find variable ' + iPathModel);
			}
		},

		destroy: function () {
			this.stopListening();
		}

	});

	return UIMapper;
});

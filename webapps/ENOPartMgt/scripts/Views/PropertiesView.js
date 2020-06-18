/**
 * @overview Displays the properties of a content.
 * @licence Copyright 2006-2014 Dassault Syst�mes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOPartMgt/scripts/Views/PropertiesView', [
										'UWA/Class/View',
										'i18n!DS/ENOPartMgt/assets/nls/ENOPartMgtNLS',
										'css!DS/ENOPartMgt/scripts/Views/PropertiesView.css',
										'UWA/Core',
										'DS/EditPropWidget/EditPropWidget',
										'DS/EditPropWidget/constants/EditPropConstants',
										'DS/EditPropWidget/models/EditPropModel'
], function(
		 View,
         NLS,
         ENGCSS,
         Core,
         EditPropWidget,
         EditPropConstants,
         EditPropModel

) {	
    var PropertiesView = View.extend({
    	render: function () {
			var that = this;
			var objId = this.model.id;
			var facets = [EditPropConstants.FACET_PROPERTIES];
			that.parentContainer = this.container;
			var options_panel = {
					typeOfDisplay: EditPropConstants.ALL,
					selectionType: EditPropConstants.NO_SELECTION,
					facets: facets,
					extraNotif: false,
					editMode: false,
					readOnly: true
			};

			this.EditPropWidget = new EditPropWidget(options_panel);

			if (objId) {
				that.loadModel(objId);
			}

			 
			return this;
		},
		
		getPropModel:  function (objModel) {
			var resultElementSelected = [];
			var selection = new EditPropModel({
				metatype: 'businessobject',
				objectId: objModel.objectId
			});
			selection.set('isTransient', false);
			selection.addEvent('onSave', function () {
			});

			resultElementSelected.push(selection);
			return resultElementSelected;
		},
		
		loadModel: function (objId) {
			var that = this, results = that.getPropModel({objectId: objId});
			that.EditPropWidget.initDatas(results);
			this.EditPropWidget.elements.container.inject(that.parentContainer);
			
		}
    });
    
    return PropertiesView;
});

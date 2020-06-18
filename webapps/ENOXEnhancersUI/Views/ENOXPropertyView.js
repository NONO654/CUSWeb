define('DS/ENOXEnhancersUI/Views/ENOXPropertyView', [
  'UWA/Class/View',
  'UWA/Core',
  'DS/UIKIT/Input/Button',
  'DS/EditPropWidget/EditPropWidget',
  'DS/EditPropWidget/constants/EditPropConstants',
  'DS/EditPropWidget/models/EditPropModel',
  'DS/ENOXEnhancers/Services/SettingsManagement'
], function(
  View,
  Core,
  Button,
  EditPropWidget,
  EditPropConstants,
  EditPropModel,
  SettingsManagement
)
{
  'use strict';
  var PropertyView = View.extend(
  {

    slideinContainer: '',
    skeletonContainer: '',
    slideInContent: '',

    setup: function()
    {
      this.slideInContent = UWA.createElement('div',
      {
        'id': 'slideInPropertiesContent',
        styles:
        { /*display: 'table',*/
          height: '95%',
          width: '100%'
        }
      });
    },

    render: function()
    {
      return this;
    },

    buildSlideIn: function(itemID, option)
    {
      var that = this;
      var editPropertiesView = that.editPropertiesView = new EditPropWidget(
      {
        'typeOfDisplay': EditPropConstants.ONLY_EDIT_PROPERTIES,
        'selectionType': EditPropConstants.NO_SELECTION,
        'readOnly': false,
        'extraNotif': true,
        'setEditButton': true
      });

      var idToUse = itemID;
      var resultElementSelected = [];
      var selection = new EditPropModel(
      {
        //'metatype': 'businessobject',
        'tenant': SettingsManagement.getPlatformURLs().getTenantId(),
        'objectId': idToUse
      });
      resultElementSelected.push(selection);
      setTimeout(function()
      {
        editPropertiesView.initDatas(resultElementSelected);
        editPropertiesView.centerIt();
        widget.addEvent('onResize', function()
        {
          setTimeout(function()
          {
            editPropertiesView.onResize();
          }, 100);
        });
      }, 500);
      editPropertiesView.inject(this.slideInContent);
      var content = UWA.extendElement(this.slideInContent);
      content.inject(option.renderTo);
    }

  });

  return PropertyView;

});

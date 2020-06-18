
/**
 * @fullreview KPE3 I2S 18:08:17
 */

define(//define - file Path
    'DS/QualityManagerUI/GIVisualQualityUIDlg',
     //define - Dependencies 
   ['UWA/Core',
    'DS/QualityManager/QMGIController',
    'DS/WebappsUtils/WebappsUtils',
    'DS/QualityManagerUI/GIVisualQualityCustomPresetDlg',
    'DS/Controls/Button',
    'DS/Windows/Dialog',
	'DS/Controls/ComboBox',
    'DS/Controls/TooltipModel',
    'DS/RuntimeView/NLSManager'
   ],
function (UWACore, QMController, WebappsUtils, GIVisualQualityCustomPresetDlg, WUXButton, WUXDialog, WUXCombobox, WUXTooltipModel, NLSManager) {

 'use strict';

  var uiInitialization = false;

  var GIVisualQualityUIDlg = function (options) {

  this.options = options;  
  this.init();
 }

 GIVisualQualityUIDlg.prototype.init = function () {

  var frameWindow = this.options.frameWindow;
  this._webGLV6Viewer = frameWindow.getViewer();
  this._immersiveFrame = frameWindow.getImmersiveFrame();

  if (!QMController.isInitialized)
      QMController.init();
  this.currentPresetMode = QMController.getCurrentPreset();//"Static"; // "Dynamic", "Linked" ,"Batch"
     // -- will load win_b64/webapps/FrameWindowUI/assets/catrsc/3DShare.CATRsc
  NLSManager.DEFAULT_LANGUAGE = widget.lang ? widget.lang : widget.getValue('lang');
  var self = this;

  NLSManager.loadResource({ resourceFile: 'QualityManagerUI/QualityManager' });
  NLSManager.onResourceLoaded({ resourceFile: 'QualityManagerUI/QualityManager' }, function () {
      self.mbdResources = this;
  });
  this.properties = {};
  this.buildDialog();
  this.initializedUIfromDB();

 };

 GIVisualQualityUIDlg.prototype.initializedUIfromDB = function () {

  var me = this;
  uiInitialization = true;
  var currentPreset = QMController.getCurrentGlobalPreset("Static");
  this.properties["Static"].staticComboBox.currentValue = currentPreset;
  currentPreset = QMController.getCurrentGlobalPreset("Batch");
  this.properties["Batch"].batchComboBox.currentValue = currentPreset;

  uiInitialization = false;
 };

 GIVisualQualityUIDlg.prototype.buildDialog = function () {

  var me = this;
  var container = UWA.createElement('div', { 'class': 'wux-control-inline-container', style: { 'vertical-align': 'top' } });

  me.buildViewContent().inject(container);
  me.GIVisualQualityUIDlg = new WUXDialog({
   title: 'Raytracer Visual Quality',
   content: container,
   immersiveFrame: me._immersiveFrame,
   ResizableFlag: true,
   width: 270,
   height: 80,
   allowedDockAreas: WUXDockAreaEnum.TopDockArea | WUXDockAreaEnum.BottomDockArea | WUXDockAreaEnum.LeftDockArea | WUXDockAreaEnum.RightDockArea
  });

  me.GIVisualQualityUIDlg.addEventListener('close', function () {
      QMController.commitToDB();
  });

 };

 GIVisualQualityUIDlg.prototype.buildViewContent = function () {

  var me = this;
  var container = UWA.createElement('div', { 'class': 'wux-container' });
  var Elements = ['Standard', 'Optimize Interior', 'Optimize Caustics', 'Custom'];
  var values = ['Standard', 'OptimizeInterior', 'OptimizeCaustics', 'Custom'];
  var listPair = [];
  for (var index = 0; index < Elements.length; index++) {
      listPair[index] = { labelItem: Elements[index], valueItem: values[index] };
  }
  me.buildStaticView(listPair).inject(container);
  me.buildBatchView(listPair).inject(container);
  me.buildCustomizeButtonView().inject(container);
  return container;
 };
 
 GIVisualQualityUIDlg.prototype.buildStaticView = function (listPair) {

  var staticElementContainer = new UWA.Element('div', { 'class': 'wux-container' });
  staticElementContainer.setStyles({ width: '200px' });
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Static:' }).inject(staticElementContainer);
  contLabel.setStyles({ width: '40px' });
  var staticComboBox = new WUXCombobox({ elementsList: listPair, selectedIndex: 1, recId: 'Static', enableSearchFlag: false }).inject(staticElementContainer);
  staticComboBox.getContent().style.width = '70%';
  this.properties["Static"] = {};
  this.properties["Static"].staticComboBox = staticComboBox;

  //Add events
  this.addEventListenerComboBox(staticComboBox);
  return staticElementContainer;
 };
 GIVisualQualityUIDlg.prototype.buildBatchView = function (listPair) {

  var batchElementContainer = new UWA.Element('div', { 'class': 'wux-container' });
  batchElementContainer.setStyles({ width: '200px' });
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Batch:' }).inject(batchElementContainer);
  contLabel.setStyles({ width: '40px' });
  var batchComboBox = new WUXCombobox({ elementsList: listPair, selectedIndex: 1, recId: 'Batch', enableSearchFlag: false}).inject(batchElementContainer);
  batchComboBox.getContent().style.width = '70%';
  this.properties["Batch"] = {};
  this.properties["Batch"].batchComboBox = batchComboBox;

  //Add events
  this.addEventListenerComboBox(batchComboBox);

  return batchElementContainer;
 };

 GIVisualQualityUIDlg.prototype.buildCustomizeButtonView = function () {

     var me = this;
     var customizeButtonContainer = UWA.createElement('div', { 'class': 'wux-container' });
     customizeButtonContainer.setStyles({ position: 'absolute', width: '0px', left: '225px', top: '20px' });
     var customizeButton = new WUXButton({ recId: 'customizeButton', displayStyle: 'lite', icon: WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorSettings.png' }).inject(customizeButtonContainer);
     var options = this.options;
     var buttonContent = customizeButton.getContent();
     buttonContent.tooltipInfos = new WUXTooltipModel({ shortHelp: 'Customize' });

     customizeButton.addEventListener('buttonclick', function () {

         me.GIVisualQualityUIDlg.hide();

         var dlg = new GIVisualQualityCustomPresetDlg(options);
       
         dlg.currentPreset = "Custom";
         dlg.QualityManagerDialog.addEventListener('close', function () {
             QMController.restoreFromDB();
             dlg.QualityManagerDialog.close();
             me.GIVisualQualityUIDlg.show();
         });

         dlg.QualityManagerDialog.buttons["Ok"].addEventListener('click', function () {

             if (this.currentPresetMode == "Linked") {
                 QMController.setGlobalPresetOnDB("Static", "Custom", false);
                 QMController.setGlobalPresetOnDB("Dynamic", "Custom", false);
                 me.properties["Static"].staticComboBox.currentValue = "Custom";
                 me.properties["Dynamic"].dynamicComboBox.currentValue = "Custom";
             }
             else {
                 me.currentPresetMode = dlg.currentPresetMode;
                 QMController.setGlobalPresetOnDB(me.currentPresetMode, "Custom", false);
                 if (me.currentPresetMode == "Static")
                     me.properties["Static"].staticComboBox.currentValue = "Custom";
                 else
                     me.properties["Batch"].batchComboBox.currentValue = "Custom";
             }
           
             QMController.commitToDB();
             dlg.QualityManagerDialog.close();

             me.GIVisualQualityUIDlg.show();
         });

         dlg.QualityManagerDialog.buttons["Cancel"].addEventListener('click', function () {
             QMController.restoreFromDB();
             dlg.QualityManagerDialog.close();
             me.GIVisualQualityUIDlg.show();
         });
     });

     return customizeButtonContainer;
 };

 //Add event listeners
 GIVisualQualityUIDlg.prototype.addEventListenerComboBox = function (iComboBox) {

     var me = this;
     iComboBox.addEventListener('change', function () {

         if (!uiInitialization) {
            
             var presetMode = iComboBox.recId; // static or batch
             QMController.setCurrentPreset(presetMode);
             me.currentPresetMode = presetMode;
             var selectedPreset = iComboBox.currentValue;
             me.updateGlobalPreset(presetMode, selectedPreset);
         }

     });
 };

 GIVisualQualityUIDlg.prototype.updateGlobalPreset = function (iPresetMode, selectedPreset) {

     QMController.setGlobalPreset(iPresetMode, selectedPreset, false);
 };
 return GIVisualQualityUIDlg;
 });
 




/**
 * @fullreview XK7 I2S 17:11:29
 */

define(//define - file Path
    'DS/QualityManagerUI/QMUIPresetSelectionDlg',
     //define - Dependencies 
   ['UWA/Core',   
    'DS/QualityManager/QMController',
	'DS/QualityManagerUI/QMUICustomPresetEditDlg',
    'DS/WebappsUtils/WebappsUtils',
    'DS/Controls/Button',
    'DS/Windows/Dialog',
	'DS/Controls/ComboBox'
   ],
function (UWACore, QMController, QMUICustomPresetEditDlg, WebappsUtils, WUXButton, WUXDialog, WUXCombobox) {

 'use strict';

  var uiInitialization = false;

  var QMUIPresetSelectionDlg = function (options) {

  this.options = options;  
  this.init();
 }

 QMUIPresetSelectionDlg.prototype.init = function () {

  var frameWindow = this.options.frameWindow;
  this._webGLV6Viewer = frameWindow.getViewer();
  this._immersiveFrame = frameWindow.getImmersiveFrame();

  //if (!QMController.isInitialized)
  // QMController.init(this._webGLV6Viewer);

  this.currentPresetMode = "Static"; // "Dynamic", "Linked"

  this.properties = {};
  this.buildDialog();
  this.initializedUIfromDB();

 };

 QMUIPresetSelectionDlg.prototype.buildDialog = function () {

  var me = this;
  var container = UWA.createElement('div', { 'class': 'wux-control-inline-container', style: { 'vertical-align': 'top' } });

  me.buildViewContent().inject(container);
  me.QMUIPresetSelectionDlg = new WUXDialog({
   title: 'Rasterizer Visual Quality',
   content: container,
   immersiveFrame: me._immersiveFrame,
   ResizableFlag: true,
   width: 250,
   height: 100,
   recId: 'Rasterizer Visual Quality',
   allowedDockAreas: WUXDockAreaEnum.TopDockArea | WUXDockAreaEnum.BottomDockArea | WUXDockAreaEnum.LeftDockArea | WUXDockAreaEnum.RightDockArea
  });

 me.QMUIPresetSelectionDlg.addEventListener('close', function () {  
  });

 };

 QMUIPresetSelectionDlg.prototype.buildViewContent = function () {

 var me = this;
 var container = UWA.createElement('div', { 'class': 'wux-container'});
 var Elements = ['Low','Medium', 'High', 'Ultra','GPU Default','Custom'];
 var values = ['Low', 'Medium', 'High ', 'Ultra', 'Default', 'Custom'];
 var listPair = [];
 for (var index = 0; index < Elements.length; index++) 
 {
 	listPair[index] = { labelItem: Elements[index], valueItem: values[index] };
 }
 me.buildStaticView(listPair).inject(container);
 //new UWA.Element('br').inject(container);
 me.buildDynamicView(listPair).inject(container);
 me.buildCustomizeButtonView().inject(container);
 me.buildLinkButtonView().inject(container);
 return container;
 };
 
 QMUIPresetSelectionDlg.prototype.buildLinkButtonView = function () {

 var me = this;
 var mainContainer = UWA.createElement('div', { 'class': 'wux-container'});
 var linkLinesContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
 linkLinesContainer.setStyles({ position: 'absolute', width: '0px', left: '165px', top: '11px' });
 var linkLinesButton = new WUXButton({disabled: true, displayStyle: 'lite', icon: WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorLinkLines.png' }).inject(linkLinesContainer);

 var linkButtonContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
 linkButtonContainer.setStyles({position: 'absolute',width:'0px',left:'165px',top:'20px'});
 me.linkButton = new WUXButton({disabled: true,displayStyle: 'lite',recId:'Link',icon:WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorUnlinked.png'}).inject(linkButtonContainer);
 var dynamicCombo = this.properties["Dynamic"].dynamicComboBox;
 

 me.linkButton.addEventListener('buttonclick', function () {
 if (dynamicCombo.disabled) {
     me.linkButton.icon = WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorUnlinked.png';
     dynamicCombo.disabled = false;
 }
 else {
     me.linkButton.icon = WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorLinked.png';
     dynamicCombo.disabled = true;
 }
 }); 
 return mainContainer;
 };
 QMUIPresetSelectionDlg.prototype.buildCustomizeButtonView = function () {

 var me = this;
 var customizeButtonContainer = UWA.createElement('div', { 'class': 'wux-container'});
 customizeButtonContainer.setStyles({position: 'absolute',width:'0px',left:'200px',top:'20px'});
 var customizeButton = new WUXButton({displayStyle: 'lite',icon:WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorSettings.png'}).inject(customizeButtonContainer);
 var options = this.options;
 var dynamicCombo = this.properties["Dynamic"].dynamicComboBox;

 customizeButton.addEventListener('click', function () {
     
   me.QMUIPresetSelectionDlg.hide();
  
   var dlg = new QMUICustomPresetEditDlg(options);
   if (dynamicCombo.disabled) {
       dlg.dynamicButton.disabled = true;
       dlg.linkButton.icon = WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorLinked.png';
   }
   else {
       dlg.dynamicButton.disabled = false;
       dlg.linkButton.icon = WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorUnlinked.png';
   }
   
    dlg.QualityManagerDialog.addEventListener('close', function () {
    QMController.restoreFromDB();
	dlg.QualityManagerDialog.close();
   });
  
   dlg.QualityManagerDialog.buttons["Ok"].addEventListener('click', function () {
    
    if (this.currentPresetMode == "Linked")
    {
     QMController.setGlobalPresetOnDB("Static", "Custom", false);
     QMController.setGlobalPresetOnDB("Dynamic", "Custom", false);
     me.properties["Static"].staticComboBox.currentValue = "Custom";
     me.properties["Dynamic"].dynamicComboBox.currentValue = "Custom";
    }
    else
    {
     QMController.setGlobalPresetOnDB(me.currentPresetMode, "Custom", false);
	 if(me.currentPresetMode == "Static")
     me.properties["Static"].staticComboBox.currentValue = "Custom";
	 else
	 me.properties["Dynamic"].dynamicComboBox.currentValue = "Custom";
    }
    if (dlg.dynamicButton.disabled) {
        dynamicCombo.disabled = true;
        me.linkButton.icon = WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorLinked.png';
    }
    else {
        dynamicCombo.disabled = false;
        me.linkButton.icon = WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorUnlinked.png';
    }
    QMController.commitToDB();
    dlg.QualityManagerDialog.close();
   
    me.QMUIPresetSelectionDlg.show();
   });
   me.QMUIPresetSelectionDlg.hide();
   dlg.QualityManagerDialog.buttons["Cancel"].addEventListener('click', function () {
    QMController.restoreFromDB();
    dlg.QualityManagerDialog.close();
    me.QMUIPresetSelectionDlg.show();
   });
 }); 

 return customizeButtonContainer;
 };
  
 QMUIPresetSelectionDlg.prototype.buildStaticView = function (listPair) {

 var staticElementContainer = new UWA.Element('div', { 'class': 'wux-container' });
 staticElementContainer.setStyles({ width: '200px' });
 var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container' ,text: 'Static:'}).inject(staticElementContainer);
 contLabel.setStyles({ width: '52px' });
 var staticComboBox = new WUXCombobox({ elementsList: listPair, selectedIndex: 4, recId: 'Static', enableSearchFlag: false }).inject(staticElementContainer);
 staticComboBox.getContent().style.width = '52%';
 this.properties["Static"] = {};
 this.properties["Static"].staticComboBox = staticComboBox;

 //Add events
 this.addEventListenerComboBox(staticComboBox);
 return staticElementContainer;
 };

 QMUIPresetSelectionDlg.prototype.buildDynamicView = function (listPair) {

 var dynamicElementContainer = new UWA.Element('div', { 'class': 'wux-container' });
 dynamicElementContainer.setStyles({ width: '200px' });
 var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Dynamic:' }).inject(dynamicElementContainer);
 contLabel.setStyles({ width: '52px'});
 var dynamicComboBox = new WUXCombobox({ elementsList: listPair, selectedIndex: 4, recId: 'Dynamic', enableSearchFlag: false, disabled: true }).inject(dynamicElementContainer);
 dynamicComboBox.getContent().style.width = '52%';
 this.properties["Dynamic"] = {};
 this.properties["Dynamic"].dynamicComboBox = dynamicComboBox;
 
 //Add events
 this.addEventListenerComboBox(dynamicComboBox);

 return dynamicElementContainer;
 };
 
 //Add event listeners
 QMUIPresetSelectionDlg.prototype.addEventListenerComboBox = function (iComboBox) {

 var me = this;
 iComboBox.addEventListener('change', function () {

  if (!uiInitialization) {
  var presetMode = iComboBox.recId; // static or dynamic
  var selectedPreset = iComboBox.currentValue; 
  me.updateGlobalPreset(presetMode, selectedPreset);
   }

 });
 };
 
 QMUIPresetSelectionDlg.prototype.updateGlobalPreset = function (iPresetMode, selectedPreset) {

  QMController.setGlobalPreset(iPresetMode,selectedPreset,false);
 };
 
 QMUIPresetSelectionDlg.prototype.initializedUIfromDB = function () {

  var me = this;

  uiInitialization = true;
  var currentPreset = QMController.getCurrentGlobalPreset("Static");
  this.properties["Static"].staticComboBox.currentValue = currentPreset;

  currentPreset = QMController.getCurrentGlobalPreset("Dynamic");
  this.properties["Dynamic"].dynamicComboBox.currentValue = currentPreset;

  uiInitialization = false;
 };

 return QMUIPresetSelectionDlg;
 });
 


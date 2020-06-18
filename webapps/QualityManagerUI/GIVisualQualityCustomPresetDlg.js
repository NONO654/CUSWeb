/**
 * @fullreview KPE3 I2S 18:08:17
 */

define(//define - file Path
    'DS/QualityManagerUI/GIVisualQualityCustomPresetDlg',
     //define - Dependencies 
   ['UWA/Core',
    'DS/QualityManager/QMGIController',
    'DS/WebappsUtils/WebappsUtils',
    'DS/Controls/Button',
    'DS/Windows/Dialog',
    'DS/Controls/ButtonGroup',
    'DS/Controls/Expander',
	'DS/Controls/SpinBox',
	'DS/Controls/Toggle',
	'DS/Controls/ComboBox',
    'DS/Controls/Slider',
    'DS/QualityManagerUI/SliderSpinBox',
    'DS/Controls/TooltipModel',
    'DS/RuntimeView/NLSManager'
   ],
function (UWACore, QMController, WebappsUtils, WUXButton, WUXDialog, WUXButtonGroup, WUXExpander, WUXSpinBox, WUXToggle, WUXCombobox, WUXSlider, SliderSpinBox, WUXTooltipModel, NLSManager) {

 'use strict';
 var uiInitialization = false;
 var globalPrestButtonInteraction = false;
 var propertyPrestButtonInteraction = false;
 var attribElementInteraction = false;

 var GIVisualQualityCustomPresetDlg = function (options) {

  this.options = options;
  this.init(); 
 }

 GIVisualQualityCustomPresetDlg.prototype.init = function () {

  var frameWindow = this.options.frameWindow;
  this._webGLV6Viewer = frameWindow.getViewer();
  this._immersiveFrame = frameWindow.getImmersiveFrame();
  if (!QMController.isInitialized)
      QMController.init();

     // -- will load win_b64/webapps/FrameWindowUI/assets/catrsc/3DShare.CATRsc
  NLSManager.DEFAULT_LANGUAGE = widget.lang ? widget.lang : widget.getValue('lang');
  var self = this;
 
  NLSManager.loadResource({ resourceFile: 'QualityManagerUI/QualityManager' });
  NLSManager.onResourceLoaded({ resourceFile: 'QualityManagerUI/QualityManager' }, function () {  
      self.mbdResources = this;
  });
 
  this.currentPresetMode = QMController.getCurrentPreset();//"Static"/"Dynamic", "Batch"
  this.currentPreset = "Custom";
     
  this.properties = this.buildProperties(); // to hold all the UI data   
  this.buildDialog();
  this.initializedUIfromDB();

 };

 GIVisualQualityCustomPresetDlg.prototype.GetResString = function (iResKey) {
     var res = '';

     if (this.mbdResources) {
         res = this.mbdResources.getKey({ key: iResKey });
     }
     return res;
 };

 GIVisualQualityCustomPresetDlg.prototype.buildProperties = function () {

  var Global = { id: "Global" };
  var Accumulation = { id: "Accumulation" };
  var GlobalIllumination = { id: "GlobalIllumination" };
  var FinalGathering = { id: "FinalGathering" };
  var Caustics = { id: "Caustics" };
  var RayOffset = { id: "RayOffset" };
  var Shadows = { id: "Shadows" };
  var Reflections = { id: "Reflections" };
  var Bloom = { id: "Bloom" };
  var DepthOfField = { id: "DepthOfField" };
  var Downsampling = { id: "Downsampling" };

  var propertiesObj = {Global, Accumulation, GlobalIllumination, FinalGathering, Caustics,RayOffset,Shadows,
      Reflections,Bloom, DepthOfField,Downsampling};

  return propertiesObj;
 };

 GIVisualQualityCustomPresetDlg.prototype.buildDialog = function () {

  var me = this;
  var container = UWA.createElement('div', { 'class': 'wux-control-inline-container', style: { 'vertical-align': 'top' } });
  me.buildViewContent().inject(container);

  var okButton = new WUXButton({});
  var cancelButton = new WUXButton({});
  var resetButton = new WUXButton({});

  me.QualityManagerDialog = new WUXDialog({
  title: 'Raytracer Visual Quality',
  content: container,
  immersiveFrame: me._immersiveFrame,
  ResizableFlag: true,
  width: 700,
  height: 400,
  buttons: {
   Ok: okButton,
   Cancel: cancelButton
  },
  allowedDockAreas: WUXDockAreaEnum.TopDockArea | WUXDockAreaEnum.BottomDockArea | WUXDockAreaEnum.LeftDockArea | WUXDockAreaEnum.RightDockArea,
  resizableFlag: true
 });

 };


 GIVisualQualityCustomPresetDlg.prototype.buildViewContent = function () {

  var me = this;
  var container = UWACore.createElement('div', { 'class': 'wux-container', style: { 'vertical-align': 'top' } });
     
  me.buildRenderModeView().inject(container);
  me.buildGlobalPresetButtonView().inject(container);
  me.buildAccumulationView().inject(container);
  me.buildGlobalIlluminationView().inject(container);
  me.buildFinalGatheringView().inject(container);
  me.buildCausticsView().inject(container);
  me.buildRayOffsetView().inject(container);
  me.buildShadowsView().inject(container);
  me.buildReflectionsView().inject(container);
  me.buildBloomView().inject(container);
  me.buildDepthOfFieldView().inject(container);
  me.buildDownsamplingView().inject(container);
 
  return container;
 };

 GIVisualQualityCustomPresetDlg.prototype.buildRenderModeView = function () {

  var me = this;
  //Add Render mode buttons
  var renderModeContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container', style: { 'vertical-align': 'top' } });

  var label = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Render Mode:' }).inject(renderModeContainer);
  label.setStyles({ width: '80px' });
  me.staticButton = new WUXButton({ emphasize: 'primary', label: 'Static', value: 'Static' }).inject(renderModeContainer);
  me.batchButton = new WUXButton({emphasize: 'primary', label: 'Batch', value: 'Batch'}).inject(renderModeContainer);
  me.addEventListenerRenderMode(me.staticButton,this.properties);
  me.addEventListenerRenderMode(me.batchButton,this.properties);
  return renderModeContainer;
 };

 GIVisualQualityCustomPresetDlg.prototype.addEventListenerRenderMode = function (iRenderButton,iProperties) {
     var me = this;
     iRenderButton.addEventListener('buttonclick', function (){
         me.currentPresetMode = iRenderButton.label;
         QMController.setCurrentPreset(me.currentPresetMode);
         me.updateRenderButtonUI(me.currentPresetMode);
         me.updateGlobalPreset("Standard");
     }); 
     
 };

 GIVisualQualityCustomPresetDlg.prototype.buildGlobalPresetButtonView = function () {

     var me = this;
     var presetButtonsContainer = new UWA.Element('div', { 'class': 'wux-container' });
     presetButtonsContainer.setStyles({ position: 'relative', width: '450px', left: '250px' });
     var globalPresetButtons = me.getPresetButtons().inject(presetButtonsContainer);
     new UWA.Element('br').inject(presetButtonsContainer);
     // create global handals
     me.properties["Global"].presetButtonGroup = globalPresetButtons;

     // add callbacks 
     globalPresetButtons.addEventListener('buttonclick', function (e) {

         var currButton = globalPresetButtons.getButtonFromValue(e.dsModel.value.toString());
         me.currentPreset = currButton.recId;
         me.updateGlobalPreset(me.currentPreset);            
     });

     return presetButtonsContainer;
 };
         
    //Create Accumulation contents
 GIVisualQualityCustomPresetDlg.prototype.buildAccumulationView = function () {

  var me = this;
  var mainContainer = UWA.Element('div', { 'class': 'wux-container' });
  var propertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });
  me.properties["Accumulation"] = {};

  //Max Samples per Pixel
  var MaxSamplesLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('MaxSamplePerPixelLabel')["Text"] }).inject(propertiesContainer);
  MaxSamplesLabel.setStyles({ width: '290px', display: "inline-block" });
 
  var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
  
  var maxSamplesSliderSpinBox = new SliderSpinBox({
      minValue: 1,
      maxValue: 1048576,
      initialValue: 0,
      sliderMinValue: 0,
      sliderMaxValue: 14,
      sliderSoftLimitMax: 14,
      sliderHardLimitMax:20,
      sliderInitialValue: 0,
      spinSoftLimitMax: 16384,
      spinHardLimitMax: 1048576,
      stepValue: 1,
      decimals:0,
      isExponential: 1,
      recId: 'MaxSamples'
  }).inject(sliderSpinBoxContainer);

  maxSamplesSliderSpinBox.setTooltips(this.GetResString('MaxSamplePerPixelControl')["Tooltip"]);
  maxSamplesSliderSpinBox.setHide("inline-block");
  //Min Samples per Frame
  var MinSamplesLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('MinSamplePerPixelLabel')["Text"] }).inject(propertiesContainer);
  MinSamplesLabel.setStyles({ width: '290px', display: "inline-block" });
     
  var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
  var minSamplesSliderSpinBox = new SliderSpinBox({
      minValue: 1,
      maxValue: 256,
      initialValue: 0,
      sliderMinValue: 0,
      sliderMaxValue: 6,
      sliderSoftLimitMax: 6,
      sliderHardLimitMax: 8,
      sliderInitialValue: 0,
      spinSoftLimitMax: 64,
      spinHardLimitMax: 256,
      stepValue: 1,
      decimals: 0,
      isExponential: 1,
      recId: 'MinSamples'
  }).inject(sliderSpinBoxContainer);

  minSamplesSliderSpinBox.setTooltips(this.GetResString('MinSamplePerPixelControl')["Tooltip"]);
  minSamplesSliderSpinBox.setHide("inline-block");
  new UWA.Element('br').inject(propertiesContainer); 
  //Clamping / Max Luminance
  var clampingLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('ClammpingMaxLumLabel')["Text"] }).inject(propertiesContainer);
  clampingLabel.setStyles({ width: '290px' });
     
  var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
  var clampingSliderSpinBox = new SliderSpinBox({
      minValue: 0.1,
      maxValue: 100.0,
      sliderMinValue: 0,
      sliderMaxValue: 100,
      sliderInitialValue: 0,
      initialValue: 0.1,
      stepValue: 1,
      decimals: 2,
      isLogarithmic: 1,
      recId: 'Clamping'
  }).inject(sliderSpinBoxContainer);
  clampingSliderSpinBox.setTooltips(this.GetResString('ClammpingMaxLumControl')["Tooltip"]);

  new UWA.Element('br').inject(propertiesContainer);
  //Gauss Filter
  var gaussFilterLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('GaussFilterLabel')["Text"] }).inject(propertiesContainer);
  gaussFilterLabel.setStyles({ width: '300px' });

  var toggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
  var accumulationToggle = new WUXToggle({ label: '', recId: 'GaussFilter' }).inject(toggleContainer);
  accumulationToggle.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('GaussFilterControl')["Tooltip"] });

  new UWA.Element('br').inject(propertiesContainer);
  new UWA.Element('br').inject(propertiesContainer);
 
     //size
  var sizeLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('SizeLabel')["Text"] }).inject(propertiesContainer);
  sizeLabel.setStyles({ width: '290px' });
     
  var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
  var SizeSliderSpinBox = new SliderSpinBox({
      minValue: 1.0,
      maxValue: 6.0,
      initialValue:1.0,
      stepValue: 0.1,
      decimals: 1,
      recId: 'Size'
  }).inject(sliderSpinBoxContainer);
  SizeSliderSpinBox.setTooltips(this.GetResString('SizeControl')["Tooltip"]);
     //center weight
  var centerWeightLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('CenterWeightLabel')["Text"] }).inject(propertiesContainer);
  centerWeightLabel.setStyles({ width: '290px' });
     
  var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
  var CenterSliderSpinBox = new SliderSpinBox({
      minValue: 0.1,
      maxValue: 3.0,
      initialValue: 0,
      stepValue: 0.1,
      decimals: 1,
      recId: 'CenterWeight'
  }).inject(sliderSpinBoxContainer);
  CenterSliderSpinBox.setTooltips(this.GetResString('CenterWeightControl')["Tooltip"]);

  var accumulationExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
  accumulationExpanderContainer.setStyle('Width', '600px');

   var expander = new WUXExpander({
   style: 'filled-group',
   header: 'Accumulation',
   body: propertiesContainer
   }).inject(accumulationExpanderContainer);

  // create global handals
  
  me.properties["Accumulation"].minSamplesSliderSpinBox = minSamplesSliderSpinBox;
  me.properties["Accumulation"].MinSamplesLabel = MinSamplesLabel;
  me.properties["Accumulation"].clampingSliderSpinBox = clampingSliderSpinBox;
  me.properties["Accumulation"].clampingLabel = clampingLabel;
  me.properties["Accumulation"].accumulationToggle = accumulationToggle;
  me.properties["Accumulation"].SizeSliderSpinBox = SizeSliderSpinBox;
  me.properties["Accumulation"].CenterSliderSpinBox = CenterSliderSpinBox;
  me.properties["Accumulation"].gaussFilterLabel = gaussFilterLabel;
  me.properties["Accumulation"].sizeLabel = sizeLabel;
  me.properties["Accumulation"].centerWeightLabel = centerWeightLabel;
  me.properties["Accumulation"].maxSamplesSliderSpinBox = maxSamplesSliderSpinBox;
  me.properties["Accumulation"].MaxSamplesLabel = MaxSamplesLabel;
 

  // create callbacks 
  me.addEventListenerSliderSpinBox("Accumulation", maxSamplesSliderSpinBox);
  me.addEventListenerSliderSpinBox("Accumulation", minSamplesSliderSpinBox);
  me.addEventListenerSliderSpinBox("Accumulation", clampingSliderSpinBox);
  me.addEventListenerSliderSpinBox("Accumulation", SizeSliderSpinBox);
  me.addEventListenerSliderSpinBox("Accumulation", CenterSliderSpinBox);
  me.addEventListenerToggle("Accumulation", accumulationToggle);
  
  return mainContainer;
 };

    //Create Global Illumination contents
 GIVisualQualityCustomPresetDlg.prototype.buildGlobalIlluminationView = function () {

     var me = this;
     var mainContainer = UWA.Element('div', { 'class': 'wux-container' });
     var propertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });

     //Max Trace Depth
     var maxTraceLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('MaxTraceDepthLabel')["Text"] }).inject(propertiesContainer);
     maxTraceLabel.setStyles({ width: '290px' });
     
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var traceDepthSliderSpinBox = new SliderSpinBox({
         minValue: 1,
         maxValue: 1000,
         sliderMinValue: 0,
         sliderMaxValue: 100,
         sliderInitialValue: 0,
         spinSoftLimitMax: 100,
         spinHardLimitMax: 1000,
         initialValue: 1,
         stepValue: 1,
         decimals: 0,
         isLinear: 1,
         recId: 'MaxTraceDepth'
     }).inject(sliderSpinBoxContainer);
     traceDepthSliderSpinBox.setTooltips(this.GetResString('MaxTraceDepthControl')["Tooltip"]);
     //Glossy Threshold 
     var glossyLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('GlossyThresholdLabel')["Text"] }).inject(propertiesContainer);
     glossyLabel.setStyles({ width: '290px' });
     
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var glossyThresholdSliderSpinBox = new SliderSpinBox({
         minValue: 0.00,
         maxValue: 1.00,
         initialValue: 0.0,
         stepValue: 0.01,
         decimals: 2,
         recId: 'GlossyThreshold'
     }).inject(sliderSpinBoxContainer);
     glossyThresholdSliderSpinBox.setTooltips(this.GetResString('GlossyThresholdControl')["Tooltip"]);
     //Render Refractive Shadow
     var refractiveLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('RenderRefractiveShadowsLabel')["Text"] }).inject(propertiesContainer);
     refractiveLabel.setStyles({ width: '300px' });

     var toggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' });
     var refractiveShadowsToggle = new WUXToggle({ label: '', recId: 'RenderRefractiveShadow' }).inject(toggleContainer);
     refractiveShadowsToggle.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('RenderRefractiveShadowsControl')["Tooltip"] });
     toggleContainer.inject(propertiesContainer);

     //Advanced Expander
     var advancedPropertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });
     var advancedExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     advancedExpanderContainer.setStyle('Width', '580px');

     var expander = new WUXExpander({
         style: 'filled-group',
         header: 'Advanced',
         body: advancedPropertiesContainer
     }).inject(advancedExpanderContainer);

     var samplingLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('LocationBasedImportanceSamplingLabel')["Text"] }).inject(advancedPropertiesContainer);
     samplingLabel.setStyles({ width: '285px' });
     var toggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(advancedPropertiesContainer);;
     var samplingToggle = new WUXToggle({ label: '', recId: 'LocationBasedSampling' }).inject(toggleContainer);
     samplingToggle.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('LocationBasedImportanceSamplingControl')["Tooltip"] });
    
     new UWA.Element('br').inject(advancedPropertiesContainer);
     new UWA.Element('br').inject(advancedPropertiesContainer);
          
     var emissiveObjContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('EmissiveObjectsImportanceSamplingLabel')["Text"] }).inject(advancedPropertiesContainer);
    
     new UWA.Element('br').inject(emissiveObjContainer);
     new UWA.Element('br').inject(emissiveObjContainer);

     var distributionContainer = new UWA.Element('div', { 'class': 'wux-container' }).inject(emissiveObjContainer);
     var distributionLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('ImportanceDistributionMethodLabel')["Text"] }).inject(distributionContainer);
     distributionLabel.setStyles({ width: '280px' });
    
     var Elements = ['Equal', 'Propertional to Power'];
     var Values = ['Equal', 'Propertional to Power'];
     var listPair = [];
     for (var index = 0; index < Elements.length; index++) {
         listPair[index] = { labelItem: Elements[index], valueItem: Values[index] };
     }
     var distributionComboBox = new WUXCombobox({ elementsList: listPair, selectedIndex: 1, recId: 'Distribution', enableSearchFlag: false }).inject(distributionContainer);
     distributionComboBox.getContent().style.width = '130px';
     distributionComboBox.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('ImportanceDistributionMethodControl')["Tooltip"] });

     var factorLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('ImportanceSamplingFactorLabel')["Text"] }).inject(distributionContainer);
     factorLabel.setStyles({ width: '275px' });
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(distributionContainer);
     var factorSliderSpinBox = new SliderSpinBox({
         minValue:0.00,
         maxValue:1000.00,
         sliderMinValue: 0.00,
         sliderMaxValue: 100, 
         sliderInitialValue: 0.00,
         initialValue: 0.00,
         spinSoftLimitMax: 20.00,
         spinHardLimitMax: 1000.00,
         stepValue:1,
         decimals: 2,
         isLogarithmic: 1,
         recId: 'Factor'
     }).inject(sliderSpinBoxContainer);
     factorSliderSpinBox.setTooltips(this.GetResString('ImportanceSamplingFactorControl')["Tooltip"]);

     //Path Termination start depth
     var pathTerminationLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('PathTerminationStartDepthLabel')["Text"] }).inject(advancedPropertiesContainer);
     pathTerminationLabel.setStyles({ width: '280px' });
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(advancedPropertiesContainer);
     var pathTerminationSliderSpinBox = new SliderSpinBox({
         minValue: 0,
         maxValue: 1000,
         sliderMinValue: 0,
         sliderMaxValue: 100,
         sliderInitialValue: 0,
         spinSoftLimitMax: 32,
         spinHardLimitMax: 1000,
         initialValue: 0,
         stepValue: 1,
         decimals: 0,
         isLogarithmic: 1,
         recId: 'PathTerminationDepth'
     }).inject(sliderSpinBoxContainer);
     pathTerminationSliderSpinBox.setTooltips(this.GetResString('PathTerminationStartDepthControl')["Tooltip"]);

     var visualizationModeLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('PhotonMapVisualizationModeLabel')["Text"] }).inject(advancedPropertiesContainer);
     visualizationModeLabel.setStyles({ width: '285px' });
          
      var Elements = ['None', 'Final Gathering', 'Caustics'];
      var Values = ['None', 'Final Gathering', 'Caustics'];
      var listPair2 = [];
      for (var index = 0; index < Elements.length; index++) {
          listPair2[index] = { labelItem: Elements[index], valueItem: Values[index] };
      }
   
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(advancedPropertiesContainer);
     var visualizationModeComboBox = new WUXCombobox({ elementsList: listPair2, selectedIndex: 2, recId: 'VisualizationMode', enableSearchFlag: false }).inject(sliderSpinBoxContainer);
     visualizationModeComboBox.getContent().style.width = '130px';
     visualizationModeComboBox.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('PhotonMapVisualizationModeControl')["Tooltip"] });

     var GIExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
     GIExpanderContainer.setStyle('Width', '600px');

     var expander = new WUXExpander({
         style: 'filled-group',
         header: 'Global Illumination',
         body: propertiesContainer
     }).inject(GIExpanderContainer);

     // create global handals
     me.properties["GlobalIllumination"] = {};
     me.properties["GlobalIllumination"].traceDepthSliderSpinBox = traceDepthSliderSpinBox;
     me.properties["GlobalIllumination"].glossyThresholdSliderSpinBox = glossyThresholdSliderSpinBox;
     me.properties["GlobalIllumination"].refractiveShadowsToggle = refractiveShadowsToggle;
     me.properties["GlobalIllumination"].samplingToggle = samplingToggle;
     me.properties["GlobalIllumination"].distributionComboBox = distributionComboBox;
     me.properties["GlobalIllumination"].factorSliderSpinBox = factorSliderSpinBox;
     me.properties["GlobalIllumination"].pathTerminationSliderSpinBox = pathTerminationSliderSpinBox;
     me.properties["GlobalIllumination"].visualizationModeComboBox = visualizationModeComboBox;
     me.properties["GlobalIllumination"].visualizationModeLabel = visualizationModeLabel;
     me.properties["GlobalIllumination"].maxTraceLabel = maxTraceLabel;
     me.properties["GlobalIllumination"].glossyLabel = glossyLabel;
     me.properties["GlobalIllumination"].refractiveLabel = refractiveLabel;
     me.properties["GlobalIllumination"].samplingLabel = samplingLabel;
     me.properties["GlobalIllumination"].distributionLabel = distributionLabel;
     me.properties["GlobalIllumination"].factorLabel = factorLabel;
     me.properties["GlobalIllumination"].pathTerminationLabel = pathTerminationLabel;

    // create callbacks 
     me.addEventListenerSliderSpinBox("GlobalIllumination", traceDepthSliderSpinBox);
     me.addEventListenerSliderSpinBox("GlobalIllumination", glossyThresholdSliderSpinBox);
     me.addEventListenerToggle("GlobalIllumination", refractiveShadowsToggle);
     me.addEventListenerToggle("GlobalIllumination", samplingToggle);
     me.addEventListenerComboBox("GlobalIllumination", distributionComboBox);
     me.addEventListenerSliderSpinBox("GlobalIllumination", factorSliderSpinBox);
     me.addEventListenerSliderSpinBox("GlobalIllumination", pathTerminationSliderSpinBox);
     me.addEventListenerComboBox("GlobalIllumination", visualizationModeComboBox);

     return mainContainer;
 };

    //Create Final Gathering contents
 GIVisualQualityCustomPresetDlg.prototype.buildFinalGatheringView = function () {

     var me = this;
     var mainContainer = UWA.Element('div', { 'class': 'wux-container' });
     var propertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });

     //Final Gathering Value
     var EnableFinalGatheringLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('EnableFinalGatheringLabel')["Text"] }).inject(propertiesContainer);
     EnableFinalGatheringLabel.setStyles({ width: '300px' });
     var toggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var EnableFinalGatheringToggle = new WUXToggle({ label: '', recId: 'EnableFinalGathering' }).inject(toggleContainer);
     EnableFinalGatheringToggle.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('EnableFinalGatheringControl')["Tooltip"] });

     //Photon Number    
     var photonNoLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('PhotonNumberLabel')["Text"] }).inject(propertiesContainer);
     photonNoLabel.setStyles({ width: '290px' });
     
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var photonNoSliderSpinBox = new SliderSpinBox({
         minValue: 1000,
         maxValue: 100000000,
         sliderMinValue: 0,
         sliderMaxValue: 100,
         sliderInitialValue: 0,
         initialValue: 1,
         spinSoftLimitMax: 10000000,
         spinHardLimitMax: 100000000,
         stepValue: 1,
         decimals: 0,
         isLogarithmic: 1,
         recId: 'NoOfPhotons'
     }).inject(sliderSpinBoxContainer);
     photonNoSliderSpinBox.setTooltips(this.GetResString('PhotonNumberControl')["Tooltip"]);

     //Path Depth
     var pathDepthLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('PathDepthLabel')["Text"] }).inject(propertiesContainer);
     pathDepthLabel.setStyles({ width: '290px' });
     
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var pathDepthSliderSpinBox = new SliderSpinBox({
         minValue: 1,
         maxValue: 1000,
         sliderMinValue: 0,
         sliderMaxValue: 100,
         sliderInitialValue: 0,
         initialValue: 1,
         spinSoftLimitMax: 32,
         spinHardLimitMax: 1000,
         stepValue: 1,
         decimals: 0,
         isLogarithmic: 1,
         recId: 'PathDepth'
     }).inject(sliderSpinBoxContainer);
     pathDepthSliderSpinBox.setTooltips(this.GetResString('PathDepthControl')["Tooltip"]);

     //Photon Radius
     var photonRadiusLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('PhotonRadiusLabel')["Text"] }).inject(propertiesContainer);
     photonRadiusLabel.setStyles({ width: '290px' });
     
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var photonRadiusSliderSpinBox = new SliderSpinBox({
         minValue: 1.0,
         maxValue: 1000000.0,
         sliderMinValue: 0,
         sliderMaxValue: 100,
         sliderInitialValue: 0,
         initialValue: 1,
         spinSoftLimitMax: 1000.0,
         spinHardLimitMax: 1000000.0,
         stepValue: 1,
         decimals: 1,
         isLogarithmic: 1,
         recId: 'PhotonRadius'
     }).inject(sliderSpinBoxContainer);
     photonRadiusSliderSpinBox.setTooltips(this.GetResString('PhotonRadiusControl')["Tooltip"]);

     //Refine Final Gathering Map
     var refineFinalGatheringLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('RefineFinalGatheringMapLabel')["Text"] }).inject(propertiesContainer);
     refineFinalGatheringLabel.setStyles({ width: '300px' });
     var toggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var refineFinalGatheringToggle = new WUXToggle({ label: '', recId: 'RefineMap' }).inject(toggleContainer);
     refineFinalGatheringToggle.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('RefineFinalGatheringMapControl')["Tooltip"] });

     new UWA.Element('br').inject(propertiesContainer);
     new UWA.Element('br').inject(propertiesContainer);

     //Precalculate irradiance
     var irradianceLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('PrecalculateIrradianceLabel')["Text"] }).inject(propertiesContainer);
     irradianceLabel.setStyles({ width: '300px' });
     var toggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var irradianceToggle = new WUXToggle({ label: '', recId: 'PrecalculateIrradiance' }).inject(toggleContainer);
     irradianceToggle.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('PrecalculateIrradianceControl')["Tooltip"] });

     var ExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
     ExpanderContainer.setStyle('Width', '600px');

     var expander = new WUXExpander({
         style: 'filled-group',
         header: 'Final Gathering',
         body: propertiesContainer
     }).inject(ExpanderContainer);

     // create global handals
     me.properties["FinalGathering"] = {};
     me.properties["FinalGathering"].EnableFinalGatheringToggle = EnableFinalGatheringToggle;
     me.properties["FinalGathering"].photonNoSliderSpinBox = photonNoSliderSpinBox;
     me.properties["FinalGathering"].pathDepthSliderSpinBox = pathDepthSliderSpinBox;
     me.properties["FinalGathering"].photonRadiusSliderSpinBox = photonRadiusSliderSpinBox;
     me.properties["FinalGathering"].irradianceToggle = irradianceToggle;
     me.properties["FinalGathering"].refineFinalGatheringToggle = refineFinalGatheringToggle;
     me.properties["FinalGathering"].EnableFinalGatheringLabel = EnableFinalGatheringLabel;
     me.properties["FinalGathering"].photonNoLabel = photonNoLabel;
     me.properties["FinalGathering"].pathDepthLabel = pathDepthLabel;
     me.properties["FinalGathering"].photonRadiusLabel = photonRadiusLabel;
     me.properties["FinalGathering"].refineFinalGatheringLabel = refineFinalGatheringLabel;
     me.properties["FinalGathering"].irradianceLabel = irradianceLabel;

     // create callbacks 
     me.addEventListenerToggle("FinalGathering", EnableFinalGatheringToggle);
     me.addEventListenerSliderSpinBox("FinalGathering", photonNoSliderSpinBox);
     me.addEventListenerSliderSpinBox("FinalGathering", pathDepthSliderSpinBox);
     me.addEventListenerSliderSpinBox("FinalGathering", photonRadiusSliderSpinBox);
     me.addEventListenerToggle("FinalGathering", irradianceToggle);
     me.addEventListenerToggle("FinalGathering", refineFinalGatheringToggle);

     return mainContainer;
 };

    //Create Caustics contents
 GIVisualQualityCustomPresetDlg.prototype.buildCausticsView = function () {

     var me = this;
     var mainContainer = UWA.Element('div', { 'class': 'wux-container' });
     var propertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });

     //Caustics
     var causticsLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('CausticsLabel')["Text"] }).inject(propertiesContainer);
     causticsLabel.setStyles({ width: '300px' });
     var Elements = ['None', 'Pathtracer', 'Caustics Photons'];
     var Values = ['None', 'Pathtracer', 'Caustics Photons'];
     var listPair = [];
     for (var index = 0; index < Elements.length; index++) {
         listPair[index] = { labelItem: Elements[index], valueItem: Values[index] };
     }
     var causticsComboBox = new WUXCombobox({ elementsList: listPair, selectedIndex: 1, recId: 'Caustics', enableSearchFlag: false }).inject(propertiesContainer);
     causticsComboBox.getContent().style.width = '130px';
     causticsComboBox.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('CausticsControl')["Tooltip"] });
     //Photon Number
     var photonNoLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('CausticPhotonNumberLabel')["Text"] }).inject(propertiesContainer);
     photonNoLabel.setStyles({ width: '290px' });
     
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var photonNoSliderSpinBox = new SliderSpinBox({
         minValue: 1000,
         maxValue: 100000000,
         sliderMinValue: 0,
         sliderMaxValue: 100,
         sliderInitialValue: 0,
         initialValue: 1,
         spinSoftLimitMax: 10000000,
         spinHardLimitMax: 100000000,
         stepValue: 1,
         decimals: 0,
         isLogarithmic: 1,
         recId: 'PhotonNumber'
     }).inject(sliderSpinBoxContainer);
     photonNoSliderSpinBox.setTooltips(this.GetResString('CausticPhotonNumberControl')["Tooltip"]);

     //Path Depth
     var pathDepthLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('CausticPathDepthLabel')["Text"] }).inject(propertiesContainer);
     pathDepthLabel.setStyles({ width: '290px' });
     
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var pathDepthSliderSpinBox = new SliderSpinBox({
         minValue: 1,
         maxValue: 1000,
         sliderMinValue: 0,
         sliderMaxValue: 100,
         sliderInitialValue: 0,
         initialValue: 1,
         spinSoftLimitMax: 32,
         spinHardLimitMax: 1000,
         stepValue: 1,
         decimals: 0,
         isLogarithmic: 1,
         recId: 'PathDepth'
     }).inject(sliderSpinBoxContainer);
     pathDepthSliderSpinBox.setTooltips(this.GetResString('CausticPathDepthControl')["Tooltip"]);

     //Caustic Radius
     var photonRadiusLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('CausticRadiusLabel')["Text"] }).inject(propertiesContainer);
     photonRadiusLabel.setStyles({ width: '290px' });
     
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var photonRadiusSliderSpinBox = new SliderSpinBox({
         minValue: 0.1,
         maxValue: 100000.0,
         sliderMinValue: 0,
         sliderMaxValue: 100,
         sliderInitialValue: 0,
         initialValue: 1,
         spinSoftLimitMax: 1000.0,
         spinHardLimitMax: 1000000.0,
         stepValue: 1,
         decimals: 1,
         isLogarithmic: 1,
         recId: 'CausticRadius'
     }).inject(sliderSpinBoxContainer);
     photonRadiusSliderSpinBox.setTooltips(this.GetResString('CausticRadiusControl')["Tooltip"]);

     //Refine Caustic Photon Map
     var refineCausticLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('RefineCausticMapLabel')["Text"] }).inject(propertiesContainer);
     refineCausticLabel.setStyles({ width: '300px' });
     var toggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var refineCausticToggle = new WUXToggle({ label: '', recId: 'refinePhotonMap' }).inject(toggleContainer);
     refineCausticToggle.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('RefineCausticMapControl')["Tooltip"] });

     var GIExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
     GIExpanderContainer.setStyle('Width', '600px');

     var expander = new WUXExpander({
         style: 'filled-group',
         header: 'Caustics',
         body: propertiesContainer
     }).inject(GIExpanderContainer);

     // create global handals
     me.properties["Caustics"] = {};
     me.properties["Caustics"].causticsComboBox = causticsComboBox;
     me.properties["Caustics"].photonNoSliderSpinBox = photonNoSliderSpinBox;
     me.properties["Caustics"].pathDepthSliderSpinBox = pathDepthSliderSpinBox; 
     me.properties["Caustics"].photonRadiusSliderSpinBox = photonRadiusSliderSpinBox;
     me.properties["Caustics"].refineCausticToggle = refineCausticToggle;
     me.properties["Caustics"].causticsLabel = causticsLabel;
     me.properties["Caustics"].photonNoLabel = photonNoLabel;
     me.properties["Caustics"].pathDepthLabel = pathDepthLabel;
     me.properties["Caustics"].photonRadiusLabel = photonRadiusLabel;
     me.properties["Caustics"].refineCausticLabel = refineCausticLabel;

     // create callbacks 
     me.addEventListenerComboBox("Caustics", causticsComboBox);
     me.addEventListenerSliderSpinBox("Caustics", photonNoSliderSpinBox);
     me.addEventListenerSliderSpinBox("Caustics", pathDepthSliderSpinBox);
     me.addEventListenerSliderSpinBox("Caustics", photonRadiusSliderSpinBox);
     me.addEventListenerToggle("Caustics", refineCausticToggle);

     return mainContainer;
 };

    //Create Ray Offset contents
 GIVisualQualityCustomPresetDlg.prototype.buildRayOffsetView = function () {

     var me = this;
     var mainContainer = UWA.Element('div', { 'class': 'wux-container' });
     var propertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });
     
     var rayOffsetLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('RayOffsetLabel')["Text"] }).inject(propertiesContainer);
     rayOffsetLabel.setStyles({ width: '290px' });
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var rayOffsetSliderSpinBox = new SliderSpinBox({
         minValue: 0.001,
         maxValue: 10000.000,
         sliderMinValue: 0,
         sliderMaxValue: 100,
         initialValue: 0.01,
         spinSoftLimitMax: 1000.000,
         spinSoftLimitMin:0.01,
         spinHardLimitMax: 10000.000,
         spinHardLimitMin: 0.001,
         stepValue: 1,
         decimals: 3,
         isLogarithmic: 1,
         recId: 'RayOffset'
     }).inject(sliderSpinBoxContainer);
     rayOffsetSliderSpinBox.setTooltips(this.GetResString('RayOffsetControl')["Tooltip"]);

     var GIExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
     GIExpanderContainer.setStyle('Width', '600px');

     var expander = new WUXExpander({
         style: 'filled-group',
         header: 'Ray Offset',
         body: propertiesContainer
     }).inject(GIExpanderContainer);

     // create global handals
     me.properties["RayOffset"] = {};
     me.properties["RayOffset"].rayOffsetSliderSpinBox = rayOffsetSliderSpinBox;
     me.properties["RayOffset"].expander = expander;
    
     // create callbacks 
     me.addEventListenerSliderSpinBox("RayOffset", rayOffsetSliderSpinBox);

     return mainContainer;
 };
    
    //Create Shadows contents
 GIVisualQualityCustomPresetDlg.prototype.buildShadowsView = function () {

     var me = this;
     var mainContainer = UWA.Element('div', { 'class': 'wux-container' });
     var propertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });

     //Allow Ground Shadows
     var shadowsLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('GIAllowGroundShadowLabel')["Text"] }).inject(propertiesContainer);
     shadowsLabel.setStyles({ width: '300px' });
     var toggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);;
     var shadowsToggle = new WUXToggle({ label: '', recId: 'AllowGroundShadows' }).inject(toggleContainer);
     shadowsToggle.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('GIAllowGroundShadowControl')["Tooltip"] });

     var GIExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
     GIExpanderContainer.setStyle('Width', '600px');

     var expander = new WUXExpander({
         style: 'filled-group',
         header: 'Shadows',
         body: propertiesContainer
     }).inject(GIExpanderContainer);

     // create global handals
     me.properties["Shadows"] = {};
     me.properties["Shadows"].shadowsToggle = shadowsToggle;
     me.properties["Shadows"].expander = expander;
   
     // create callbacks 
     me.addEventListenerToggle("Shadows", shadowsToggle);
     
     return mainContainer;
 };
    
    //Create Reflections contents
 GIVisualQualityCustomPresetDlg.prototype.buildReflectionsView = function () {

     var me = this;
     var mainContainer = UWA.Element('div', { 'class': 'wux-container' });
     var propertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });

     //Allow Reflections On Ground 
     var reflectionsLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('GIAllowGroundReflLabel')["Text"] }).inject(propertiesContainer);
     reflectionsLabel.setStyles({ width: '300px' });
     var toggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);;
     var reflectionsToggle = new WUXToggle({ label: '', recId: 'AllowReflectionsOnGround' }).inject(toggleContainer);
     reflectionsToggle.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('GIAllowGroundReflControl')["Tooltip"] });

     var GIExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
     GIExpanderContainer.setStyle('Width', '600px');

     var expander = new WUXExpander({
         style: 'filled-group',
         header: 'Reflections',
         body: propertiesContainer
     }).inject(GIExpanderContainer);

     // create global handals
     me.properties["Reflections"] = {};
     me.properties["Reflections"].reflectionsToggle = reflectionsToggle;
     me.properties["Reflections"].expander = expander;
    
     // create callbacks 
     me.addEventListenerToggle("Reflections", reflectionsToggle);

     return mainContainer;
 };
    
    //Create Bloom contents
 GIVisualQualityCustomPresetDlg.prototype.buildBloomView = function () {

     var me = this;
     var mainContainer = UWA.Element('div', { 'class': 'wux-container' });
     var propertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });

     //Allow Bloom
     var bloomLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('GIAllowBloomLabel')["Text"] }).inject(propertiesContainer);
     bloomLabel.setStyles({ width: '300px' });
     var toggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);;
     var bloomToggle = new WUXToggle({ label: '', recId: 'AllowBloom' }).inject(toggleContainer);
     bloomToggle.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('GIAllowBloomControl')["Tooltip"] });

     var GIExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
     GIExpanderContainer.setStyle('Width', '600px');

     var expander = new WUXExpander({
         style: 'filled-group',
         header: 'Bloom',
         body: propertiesContainer
     }).inject(GIExpanderContainer);

     // create global handals
     me.properties["Bloom"] = {};
     me.properties["Bloom"].bloomToggle = bloomToggle;
     me.properties["Bloom"].expander = expander;
   
     // create callbacks 
     me.addEventListenerToggle("Bloom", bloomToggle);

     return mainContainer;
 };

    //Create Depth of field contents
 GIVisualQualityCustomPresetDlg.prototype.buildDepthOfFieldView = function () {

     var me = this;
     var mainContainer = UWA.Element('div', { 'class': 'wux-container' });
          
     var propertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });

     //Allow Depth Of Field
     var depthLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('GIAllowDoFLabel')["Text"] }).inject(propertiesContainer);
     depthLabel.setStyles({ width: '300px' });
     var toggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);;
     var depthToggle = new WUXToggle({ label: '', recId: 'AllowDepthOfField' }).inject(toggleContainer);
     depthToggle.tooltipInfos = new WUXTooltipModel({ shortHelp: this.GetResString('GIAllowDoFControl')["Tooltip"] });

     var GIExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
     GIExpanderContainer.setStyle('Width', '600px');

     var expander = new WUXExpander({
         style: 'filled-group',
         header: 'Depth Of Field',
         body: propertiesContainer
     }).inject(GIExpanderContainer);

     // create global handals
     me.properties["DepthOfField"] = {};
     me.properties["DepthOfField"].depthToggle = depthToggle;
     me.properties["DepthOfField"].expander = expander;
    
     // create callbacks 
     me.addEventListenerToggle("DepthOfField", depthToggle);

     return mainContainer;
 };

    //Create Downsampling contents
 GIVisualQualityCustomPresetDlg.prototype.buildDownsamplingView = function () {

     var me = this;
     var mainContainer = UWA.Element('div', { 'class': 'wux-container' });
          
     var propertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });

     //Downsampling Factor  
     var downsamplingLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: this.GetResString('GIDownsamplingFactorLabel')["Text"] }).inject(propertiesContainer);
     downsamplingLabel.setStyles({ width: '290px' });
     
     var sliderSpinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(propertiesContainer);
     var downsamplingSliderSpinBox = new SliderSpinBox({
         minValue: 0.4,
         maxValue: 1.0,
         initialValue: 0.4,
         stepValue: 0.1,
         decimals: 1,
         recId: 'DownsamplingFctor'
     }).inject(sliderSpinBoxContainer);
     downsamplingSliderSpinBox.setTooltips(this.GetResString('GIDownsamplingFactorControl')["Tooltip"]);

     var GIExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
     GIExpanderContainer.setStyle('Width', '600px');

     var expander = new WUXExpander({
         style: 'filled-group',
         header: 'Downsampling',
         body: propertiesContainer
     }).inject(GIExpanderContainer);

    // create global handals
     me.properties["Downsampling"] = {};
     me.properties["Downsampling"].downsamplingSliderSpinBox = downsamplingSliderSpinBox;
     me.properties["Downsampling"].expander = expander;

    // create callbacks 
     me.addEventListenerSliderSpinBox("Downsampling", downsamplingSliderSpinBox);

     return mainContainer;
 };

 // Get tab panel
 GIVisualQualityCustomPresetDlg.prototype.getPresetButtons = function () {

  var buttonGroup = new WUXButtonGroup();
  buttonGroup.addChild(new WUXButton({ checkFlag: false, value: 'Standard', displayStyle: 'lite-borders', emphasize: 'primary', icon: WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/CATRdgStellarConfig1.png', recId: 'Standard' }));
  buttonGroup.addChild(new WUXButton({ checkFlag: false, value: 'OptimizeInterior', emphasize: 'primary', displayStyle: 'lite-borders', icon: WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/CATRdgStellarConfig2.png', recId: 'OptimizeInterior' }));
  buttonGroup.addChild(new WUXButton({ checkFlag: false, value: 'OptimizeCaustics', emphasize: 'primary', displayStyle: 'lite-borders', icon: WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/CATRdgStellarConfig3.png', recId: 'OptimizeCaustics' }));

  var buttons = buttonGroup._getButtonList();
  for (var i = 0; i < buttons.length; i++) {

      var buttonContent = buttons[i].getContent();
      buttonContent.tooltipInfos = new WUXTooltipModel({ shortHelp: buttons[i].recId });
  }
  return buttonGroup;
 };

 // CallBack Handling

 GIVisualQualityCustomPresetDlg.prototype.DoUpdatePropertyCombo = function () {

  var retVal = false;
  if (!globalPrestButtonInteraction && !propertyPrestButtonInteraction && !uiInitialization)
   retVal = true;

  return retVal;
 }

 GIVisualQualityCustomPresetDlg.prototype.addEventListenerComboBox = function (iProperty, iAttribComboBox) {

  var me = this;

  iAttribComboBox.addEventListener('change', function () {

   var attrib = iAttribComboBox.recId;
   var value = iAttribComboBox.currentValue;

   if (me.DoUpdatePropertyCombo()) {
    attribElementInteraction = true;
    me.updateAttribute(iProperty, attrib, value);
    attribElementInteraction = false;
   }
      //Parameter dependencies
   if (attrib == "Caustics") {
       if (value == "None" || value == "Pathtracer") {
           me.properties["Caustics"].photonNoSliderSpinBox.setDisabled(true);
           me.properties["Caustics"].pathDepthSliderSpinBox.setDisabled(true);
           me.properties["Caustics"].photonRadiusSliderSpinBox.setDisabled(true);
           me.properties["Caustics"].refineCausticToggle.disabled = true;
       }
       else {
           me.properties["Caustics"].photonNoSliderSpinBox.setDisabled(false);
           me.properties["Caustics"].pathDepthSliderSpinBox.setDisabled(false);
           me.properties["Caustics"].photonRadiusSliderSpinBox.setDisabled(false);
           me.properties["Caustics"].refineCausticToggle.disabled = false;
       }
   }
  });

 };

 GIVisualQualityCustomPresetDlg.prototype.addEventListenerSliderSpinBox = function (iProperty, iAttribSliderSpinBox) {

  var me = this;
  iAttribSliderSpinBox.elements.slider.addEventListener('change', function (event) {

      iAttribSliderSpinBox._createEvents();    
  });

  iAttribSliderSpinBox.elements.spinBox.addEventListener('change', function (event) {
      iAttribSliderSpinBox._createEvents();
      var attrib = iAttribSliderSpinBox.options.recId;
      var value = iAttribSliderSpinBox.elements.spinBox.value;

       if (me.DoUpdatePropertyCombo()) {
        attribElementInteraction = true;
        me.updateAttribute(iProperty, attrib, value);
        attribElementInteraction = false;
       }
  });
    
 };   

 GIVisualQualityCustomPresetDlg.prototype.addEventListenerToggle = function (iProperty, iAttribToggle) {

  var me = this;

     iAttribToggle.addEventListener('change', function () {

         var attrib = iAttribToggle.recId;
         var value = iAttribToggle.checkFlag;

         if (me.DoUpdatePropertyCombo()) {
             attribElementInteraction = true;
             me.updateAttribute(iProperty, attrib, value);
             attribElementInteraction = false;
         }

         //Parameter dependencies
   switch (attrib) {
       case "GaussFilter":
           {
               if (!value) {

                   me.properties["Accumulation"].SizeSliderSpinBox.setDisabled(true);
                   me.properties["Accumulation"].CenterSliderSpinBox.setDisabled(true);
               }
               else {
                   me.properties["Accumulation"].SizeSliderSpinBox.setDisabled(false);
                   me.properties["Accumulation"].CenterSliderSpinBox.setDisabled(false);
               }
               break;
           }
       case "EnableFinalGathering":
           {
               if (!value) {

                   me.properties["FinalGathering"].photonNoSliderSpinBox.setDisabled(true);
                   me.properties["FinalGathering"].photonRadiusSliderSpinBox.setDisabled(true);
                   me.properties["FinalGathering"].pathDepthSliderSpinBox.setDisabled(true);
                   me.properties["FinalGathering"].refineFinalGatheringToggle.disabled = true;
                   me.properties["FinalGathering"].irradianceToggle.disabled = true;

               }
               else {
                   me.properties["FinalGathering"].photonNoSliderSpinBox.setDisabled(false);
                   me.properties["FinalGathering"].photonRadiusSliderSpinBox.setDisabled(false);
                   me.properties["FinalGathering"].pathDepthSliderSpinBox.setDisabled(false);
                   me.properties["FinalGathering"].refineFinalGatheringToggle.disabled = false;
                   me.properties["FinalGathering"].irradianceToggle.disabled = false;
               }
               break;
           }
     }

  });
 };

 // Interaction Handling
 GIVisualQualityCustomPresetDlg.prototype.initializedUIfromDB = function () {
  /*
  1. Update global preset buttons according to qualityPresets.currentGlobalPreset
  2. itertate each property and update property preset button according to qualityPresets.preset["Custom"].Preset
  3. update the property attribute
  */
  var me = this;
  uiInitialization = true;
  me.updateRenderButtonUI(this.currentPresetMode);

  var currentPreset = QMController.getCurrentGlobalPreset(this.currentPresetMode);
  //me.updateGlobalPresetButtonUI(currentPreset);

  propertyPrestButtonInteraction = true;
  for (var attrib in me.properties) {

   if (attrib == "Global")
    continue;
   me.updatePropertyUI(attrib, "Custom");
  }
  me.updateParameterDependencies();
  propertyPrestButtonInteraction = false;
  uiInitialization = false;
 };

 GIVisualQualityCustomPresetDlg.prototype.updateParameterDependencies = function () {

     var me = this;
     //Parameter dependencies
     if (!me.properties["Accumulation"].accumulationToggle.checkFlag) {
         me.properties["Accumulation"].SizeSliderSpinBox.setDisabled(true);
         me.properties["Accumulation"].CenterSliderSpinBox.setDisabled(true);
     }
     else {
         me.properties["Accumulation"].SizeSliderSpinBox.setDisabled(false);
         me.properties["Accumulation"].CenterSliderSpinBox.setDisabled(false);
     }

     if (!me.properties["FinalGathering"].EnableFinalGatheringToggle.checkFlag) {

         me.properties["FinalGathering"].photonNoSliderSpinBox.setDisabled(true);
         me.properties["FinalGathering"].photonRadiusSliderSpinBox.setDisabled(true);
         me.properties["FinalGathering"].pathDepthSliderSpinBox.setDisabled(true);
         me.properties["FinalGathering"].refineFinalGatheringToggle.disabled = true;
         me.properties["FinalGathering"].irradianceToggle.disabled = true;

     }
     else {
         me.properties["FinalGathering"].photonNoSliderSpinBox.setDisabled(false);
         me.properties["FinalGathering"].photonRadiusSliderSpinBox.setDisabled(false);
         me.properties["FinalGathering"].pathDepthSliderSpinBox.setDisabled(false);
         me.properties["FinalGathering"].refineFinalGatheringToggle.disabled = false;
         me.properties["FinalGathering"].irradianceToggle.disabled = false;
     }

     if (me.properties["Caustics"].causticsComboBox.currentValue == "None" || me.properties["Caustics"].causticsComboBox.currentValue == "Pathtracer") {
         me.properties["Caustics"].photonNoSliderSpinBox.setDisabled(true);
         me.properties["Caustics"].pathDepthSliderSpinBox.setDisabled(true);
         me.properties["Caustics"].photonRadiusSliderSpinBox.setDisabled(true);
         me.properties["Caustics"].refineCausticToggle.disabled = true;
     }
     else{
         me.properties["Caustics"].photonNoSliderSpinBox.setDisabled(false);
         me.properties["Caustics"].pathDepthSliderSpinBox.setDisabled(false);
         me.properties["Caustics"].photonRadiusSliderSpinBox.setDisabled(false);
         me.properties["Caustics"].refineCausticToggle.disabled = false;
     }
 };

 GIVisualQualityCustomPresetDlg.prototype.updateGlobalPreset = function (iPreset) {

  QMController.setGlobalPreset(this.currentPresetMode, iPreset,true);

  this.updatePropertyUI("Accumulation", iPreset);
  this.updatePropertyUI("GlobalIllumination", iPreset);
  this.updatePropertyUI("FinalGathering", iPreset);
  this.updatePropertyUI("Caustics", iPreset);
  this.updatePropertyUI("RayOffset", iPreset);
  this.updatePropertyUI("Shadows", iPreset);
  this.updatePropertyUI("Reflections", iPreset);
  this.updatePropertyUI("Bloom", iPreset);
  this.updatePropertyUI("DepthOfField", iPreset);
  this.updatePropertyUI("Downsampling", iPreset);

 };

 GIVisualQualityCustomPresetDlg.prototype.updatePropertyUI = function (iProperty, iPreset) {

  var properties = QMController.getPresetValue(this.currentPresetMode,iPreset);
  if (!UWACore.is(properties))
      return false;
  var currentProperty = properties[iProperty];
  if (!UWACore.is(currentProperty))
   return false;
  
  this.updatePropertyPresetButtonUI(iProperty, iPreset);
     
  switch (iProperty) {
    case "Accumulation":
    {
        this.properties[iProperty].maxSamplesSliderSpinBox.setValue(currentProperty.MaxSamples);
        this.properties[iProperty].minSamplesSliderSpinBox.setValue(currentProperty.MinSamples);
        this.properties[iProperty].clampingSliderSpinBox.setValue(currentProperty.Clamping);
        this.properties[iProperty].accumulationToggle.checkFlag = currentProperty.GaussFilter;
        this.properties[iProperty].SizeSliderSpinBox.setValue(currentProperty.Size);
        this.properties[iProperty].CenterSliderSpinBox.setValue(currentProperty.CenterWeight);

     break;
    }
    case "GlobalIllumination":
    {
        this.properties[iProperty].traceDepthSliderSpinBox.setValue(currentProperty.MaxTraceDepth);
        this.properties[iProperty].glossyThresholdSliderSpinBox.setValue(currentProperty.GlossyThreshold);
        this.properties[iProperty].refractiveShadowsToggle.checkFlag = currentProperty.RenderRefractiveShadow;
        this.properties[iProperty].samplingToggle.checkFlag = currentProperty.LocationBasedSampling;
        this.properties[iProperty].distributionComboBox.currentValue = currentProperty.Distribution;
        this.properties[iProperty].factorSliderSpinBox.setValue(currentProperty.Factor);
        this.properties[iProperty].pathTerminationSliderSpinBox.setValue(currentProperty.PathTerminationDepth);
        this.properties[iProperty].visualizationModeComboBox.currentValue = currentProperty.VisualizationMode;
   
     break;
    }
    case "FinalGathering":
    {
        this.properties[iProperty].EnableFinalGatheringToggle.checkFlag = currentProperty.EnableFinalGathering;
        this.properties[iProperty].photonNoSliderSpinBox.setValue(currentProperty.NoOfPhotons);
        this.properties[iProperty].pathDepthSliderSpinBox.setValue(currentProperty.PathDepth);
        this.properties[iProperty].photonRadiusSliderSpinBox.setValue(currentProperty.PhotonRadius);
        this.properties[iProperty].irradianceToggle.checkFlag = currentProperty.PrecalculateIrradiance;
        this.properties[iProperty].refineFinalGatheringToggle.checkFlag = currentProperty.RefineMap;

     break;
    }
    case "Caustics":
    {
        this.properties[iProperty].causticsComboBox.currentValue = currentProperty.Caustics;
        this.properties[iProperty].photonNoSliderSpinBox.setValue(currentProperty.PhotonNumber);
        this.properties[iProperty].pathDepthSliderSpinBox.setValue(currentProperty.PathDepth);
        this.properties[iProperty].photonRadiusSliderSpinBox.setValue(currentProperty.CausticRadius);
        this.properties[iProperty].refineCausticToggle.checkFlag = currentProperty.refinePhotonMap;

     break;
    }
    case "RayOffset":
    {
        this.properties[iProperty].rayOffsetSliderSpinBox.setValue(currentProperty.RayOffset);

     break;
    }
    case "Shadows":
    {
        this.properties[iProperty].shadowsToggle.checkFlag = currentProperty.AllowGroundShadows;

     break;
    }
    case "Reflections":
    {
        this.properties[iProperty].reflectionsToggle.checkFlag = currentProperty.AllowReflectionsOnGround;

     break;
    }
   case "Bloom":
    {
        this.properties[iProperty].bloomToggle.checkFlag = currentProperty.AllowBloom;

     break;
    }
   case "DepthOfField":
    {
        this.properties[iProperty].depthToggle.checkFlag = currentProperty.AllowDepthOfField;

     break;
    }
    case "Downsampling":
    {
         this.properties[iProperty].downsamplingSliderSpinBox.setValue(currentProperty.DownsamplingFctor);

     break;
    }
  }
 };
     
 GIVisualQualityCustomPresetDlg.prototype.updateRenderButtonUI = function (iRenderMode) {

     if (iRenderMode == "Static") {
         this.staticButton.checkFlag = true;
         this.batchButton.checkFlag = false;
     }
     else {
         this.staticButton.checkFlag = false;
         this.batchButton.checkFlag = true;
     }
     for (var attrib in QMController._QMSettings) {
         this.updateUI(attrib, iRenderMode);
     }
        
 };

 GIVisualQualityCustomPresetDlg.prototype.updateUI = function (iAttrib,iRenderMode) {


     var value = "inline-block";
     if (iAttrib == "RayOffset" || iAttrib == "AllowGroundShadows" || iAttrib == "AllowReflectionsOnGround" || iAttrib == "AllowBloom" || iAttrib == "AllowDepthOfField" || iAttrib == "DownsamplingFctor")
     {
         value = "block";
     }
     if (!QMController.getQMsetting(iAttrib, iRenderMode))
     {
         value = "none";
     }
     
     switch (iAttrib) {
         case "MaxSamples":
             {
                 this.properties["Accumulation"].MaxSamplesLabel.setStyles({ display:value });
                 this.properties["Accumulation"].maxSamplesSliderSpinBox.setHide(value);
                 break;
             }
         case "MinSamples":
             {
                 this.properties["Accumulation"].MinSamplesLabel.setStyles({ display: value });
                 this.properties["Accumulation"].minSamplesSliderSpinBox.setHide(value);
                 break;
             }
         case "Clamping":
             {
                 this.properties["Accumulation"].clampingLabel.setStyles({ display: value });
                 this.properties["Accumulation"].clampingSliderSpinBox.setHide(value);
                 break;
             }
         case "GaussFilter":
             {
                 this.properties["Accumulation"].gaussFilterLabel.setStyles({ display: value });
                 this.properties["Accumulation"].accumulationToggle.getContent().style.display=value;
                 break;
             }
         case "Size":
             {

                 this.properties["Accumulation"].sizeLabel.setStyles({ display: value });
                 this.properties["Accumulation"].SizeSliderSpinBox.setHide(value);
                 break;
             }
         case "CenterWeight":
             {
                 this.properties["Accumulation"].centerWeightLabel.setStyles({ display: value });
                 this.properties["Accumulation"].CenterSliderSpinBox.setHide(value);
                 break;
             }
         case "MAxTraceDepth":
             {
                 this.properties["GlobalIllumination"].maxTraceLabel.setStyles({ display: value });
                 this.properties["GlobalIllumination"].traceDepthSliderSpinBox.setHide(value);
                 break;
             }

         case "GlossyThreshold":
             {
                 this.properties["GlobalIllumination"].glossyLabel.setStyles({ display: value });
                 this.properties["GlobalIllumination"].glossyThresholdSliderSpinBox.setHide(value);
                 break;
             }
         case "RenderRefractiveShadow":
             {
                 this.properties["GlobalIllumination"].refractiveLabel.setStyles({ display: value });
                 this.properties["GlobalIllumination"].refractiveShadowsToggle.getContent().style.display=value;
                 break;
             }
         case "LocationBasedSampling":
             {
                 this.properties["GlobalIllumination"].samplingLabel.setStyles({ display: value });
                 this.properties["GlobalIllumination"].samplingToggle.getContent().style.display=value;
                 break;
             }
         case "Distribution":
             {
                 this.properties["GlobalIllumination"].distributionLabel.setStyles({ display: value });
                 this.properties["GlobalIllumination"].distributionComboBox.getContent().style.display=value;
                 break;
             }
         case "Factor":
             {
                 this.properties["GlobalIllumination"].factorLabel.setStyles({ display: value });
                 this.properties["GlobalIllumination"].factorSliderSpinBox.setHide(value);
                 break;
             }
         case "PathTerminationDepth":
             {
                 this.properties["GlobalIllumination"].pathTerminationLabel.setStyles({ display: value });
                 this.properties["GlobalIllumination"].pathTerminationSliderSpinBox.setHide(value);
                 break;
             }
         case "VisualizationMode":
             {

                 this.properties["GlobalIllumination"].visualizationModeLabel.setStyles({ display: value });
                 this.properties["GlobalIllumination"].visualizationModeComboBox.getContent().style.display = value;
                 break;
             }
         case "EnableFinalGathering":
             {
                 this.properties["FinalGathering"].EnableFinalGatheringLabel.setStyles({ display: value });
                 this.properties["FinalGathering"].EnableFinalGatheringToggle.getContent().style.display = value;
                 break;
             }
         case "NoOfPhotons":
             {
                 this.properties["FinalGathering"].photonNoLabel.setStyles({ display: value });
                 this.properties["FinalGathering"].photonNoSliderSpinBox.setHide(value);

                 break;
             }
         case "PathDepth":
             {
                 this.properties["FinalGathering"].pathDepthLabel.setStyles({ display: value });
                 this.properties["FinalGathering"].pathDepthSliderSpinBox.setHide(value);
                 break;
             }
         case "PhotonRadius":
             {
                 this.properties["FinalGathering"].photonRadiusLabel.setStyles({ display: value });
                 this.properties["FinalGathering"].photonRadiusSliderSpinBox.setHide(value);
                 break;
             }
         case "RefineMap":
             {
                 this.properties["FinalGathering"].refineFinalGatheringLabel.setStyles({ display: value });
                 this.properties["FinalGathering"].refineFinalGatheringToggle.getContent().style.display = value;
                 break;
             }
         case "PrecalculateIrradiance":
             {
                 this.properties["FinalGathering"].irradianceLabel.setStyles({ display: value });
                 this.properties["FinalGathering"].irradianceToggle.getContent().style.display = value;
                 break;
             }
         case "Caustics":
             {
                 this.properties["Caustics"].causticsLabel.setStyles({ display: value });
                 this.properties["Caustics"].causticsComboBox.getContent().style.display = value;
                 break;
             }
         case "CausticsPhotonNumber":
             {
                 this.properties["Caustics"].photonNoLabel.setStyles({ display: value });
                 this.properties["Caustics"].photonNoSliderSpinBox.setHide(value);
                 break;
             }
         case "CausticsPathDepth":
             {
                 this.properties["Caustics"].pathDepthLabel.setStyles({ display: value });
                 this.properties["Caustics"].pathDepthSliderSpinBox.setHide(value);
                 break;
             }
         case "CausticRadius":
             {
                 this.properties["Caustics"].photonRadiusLabel.setStyles({ display: value });
                 this.properties["Caustics"].photonRadiusSliderSpinBox.setHide(value);
                 break;
             }
         case "CausticRefinePhotonMap":
             {
                 this.properties["Caustics"].refineCausticLabel.setStyles({ display: value });
                 this.properties["Caustics"].refineCausticToggle.getContent().style.display = value;
                 break;
             }
         case "RayOffset":
             {
                 this.properties["RayOffset"].expander.getContent().style.display = value;
                 break;
             }
         case "AllowGroundShadows":
             {
                 this.properties["Shadows"].expander.getContent().style.display = value;
                 break;
             }
         case "AllowReflectionsOnGround":
             {
                 this.properties["Reflections"].expander.getContent().style.display = value;
                 break;
             }
         case "AllowBloom":
             {
                 this.properties["Bloom"].expander.getContent().style.display = value;
                 break;
             }
         case "AllowDepthOfField":
             {
                 this.properties["DepthOfField"].expander.getContent().style.display = value;
                 break;
             }
         case "DownsamplingFctor":
             {
                 this.properties["Downsampling"].expander.getContent().style.display = value;
                 break;
             }
       
     }

 };

 GIVisualQualityCustomPresetDlg.prototype.updatePropertyPresetButtonUI = function (iProperty, iPreset) {

  var property = this.properties[iProperty];
  if (UWACore.is(property)) {
      var presetButtonGroup = this.properties["Global"].presetButtonGroup;

   if (UWACore.is(presetButtonGroup)) {

       if (iPreset == "Custom") {

         for (var index = 0; index < presetButtonGroup.getButtonCount() ; index++) {
           presetButtonGroup.getButton(index).checkFlag = false;        
         }
        }
        else {
         presetButtonGroup.getButtonFromValue(iPreset).checkFlag = true;
        }
    }
  }
 };

 GIVisualQualityCustomPresetDlg.prototype.updateAttribute = function (iPropertyName, attrib, value) {

  QMController.setAttribute(this.currentPresetMode, "Custom", iPropertyName, attrib, value);
  this.updatePropertyPresetButtonUI(iPropertyName, "Custom");
 };

 return GIVisualQualityCustomPresetDlg;
});


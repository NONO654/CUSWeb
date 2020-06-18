/**
 * @fullreview XK7 I2S 17:01:20
 */

define(//define - file Path
    'DS/QualityManagerUI/QMUICustomPresetEditDlg',
     //define - Dependencies 
   ['UWA/Core',
    'DS/QualityManager/QMController',
    'DS/WebappsUtils/WebappsUtils',
    'DS/Controls/Button',
    'DS/Windows/Dialog',
    'DS/Controls/ButtonGroup',
    'DS/Controls/Expander',
	'DS/Controls/SpinBox',
	'DS/Controls/Toggle',
	'DS/Controls/ComboBox',
    'DS/QualityManagerUI/SliderSpinBox'
   ],
function (UWACore, QMController, WebappsUtils, WUXButton, WUXDialog, WUXButtonGroup, WUXExpander, WUXSpinBox, WUXToggle, WUXCombobox, SliderSpinBox) {

 'use strict';
 var uiInitialization = false;
 var globalPrestButtonInteraction = false;
 var propertyPrestButtonInteraction = false;
 var attribElementInteraction = false;

 var QMUICustomPresetEditDlg = function (options) {

  this.options = options;
  this.init(); // prototype query 
 }

 QMUICustomPresetEditDlg.prototype.init = function () {

  var frameWindow = this.options.frameWindow;
  this._webGLV6Viewer = frameWindow.getViewer();
  this._immersiveFrame = frameWindow.getImmersiveFrame();
  this.currentPresetMode = "Static"; // "Dynamic", "Linked"

  if (!QMController.isInitialized)
   QMController.init(this._webGLV6Viewer);

  this.properties = this.buildProperties(); // to hold all the UI data   
  this.buildDialog();
  this.initializedUIfromDB();

 };

 QMUICustomPresetEditDlg.prototype.buildProperties = function () {

  var Global = { id: "Global" };
  var AntiAliasing = { id: "AntiAliasing" };
  var PixelCulling = { id: "PixelCulling" };
  var Transparency = { id: "Transparency" };
  var Shadows = { id: "Shadows" };
  var Reflections = { id: "Reflections" };
  var AmbientOcclusion = { id: "AmbientOcclusion" };
  var OutlineViewMode = { id: "OutlineViewMode" };
  var Bloom = { id: "Bloom" };
  var DepthOfField = { id: "DepthOfField" };

  var propertiesObj = {
   Global, AntiAliasing, PixelCulling, Transparency, Shadows,
   Reflections, AmbientOcclusion, OutlineViewMode, Bloom, DepthOfField
  };

  return propertiesObj;
 };

 QMUICustomPresetEditDlg.prototype.buildDialog = function () {

  var me = this;
  var container = UWA.createElement('div', { 'class': 'wux-control-inline-container', style: { 'vertical-align': 'top' } });

  me.buildViewContent().inject(container);

  var okButton = new WUXButton({recId:'OKButton'});
  var cancelButton = new WUXButton({ recId: 'CancelButton' });
  var resetButton = new WUXButton({});

  me.QualityManagerDialog = new WUXDialog({
  title:'Rasterizer Visual Quality',
  content: container,
  immersiveFrame: me._immersiveFrame,
  ResizableFlag: true,
  width: 750,
  height: 450,
  recId:'Visual Quality',
  buttons: {
   Ok: okButton,
   Cancel: cancelButton
  },
  allowedDockAreas: WUXDockAreaEnum.TopDockArea | WUXDockAreaEnum.BottomDockArea | WUXDockAreaEnum.LeftDockArea | WUXDockAreaEnum.RightDockArea,
  resizableFlag: true
 });

 };


 QMUICustomPresetEditDlg.prototype.buildViewContent = function () {

  var me = this;
  var container = UWA.createElement('div', { 'class': 'wux-container', style: { 'vertical-align': 'top' } });

  me.buildRenderModeView().inject(container);
  me.buildGlobalPresetButtonView().inject(container);
  me.buildAntiAliasingView().inject(container);
  me.buildOutlineViewModeView().inject(container);
  me.buildPixelcullingView().inject(container);
  me.buildTransparencyView().inject(container);
  me.buildShadowView().inject(container);
  me.buildReflectionsView().inject(container);
  me.buildAmbientOcclusionView().inject(container);
  me.buildBloomView().inject(container);
  me.buildDepthOfFieldView().inject(container);

  return container;
 };

 QMUICustomPresetEditDlg.prototype.buildRenderModeView = function () {

  var me = this;

  var pathToModule = WebappsUtils.getWebappsBaseUrl();
  //Add Render mode buttons
  var renderModeContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container', style: { 'vertical-align': 'top' } });

  var label = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Render Mode:' }).inject(renderModeContainer);
  label.setStyles({ width: '80px' });
     //emphasize: 'info'
  var staticButton = new WUXButton({ type: 'radio', label: 'Static', value: 'Static' }).inject(renderModeContainer);
  me.linkButton = new WUXButton({disabled: true, displayStyle: 'lite', icon: pathToModule + 'QualityManagerUI/assets/icons/32/I_QEditorUnlinked.png' }).inject(renderModeContainer);
  me.dynamicButton = new WUXButton({type: 'radio', label: 'Dynamic', value: 'Dynamic' ,disabled: true}).inject(renderModeContainer);
  me.addEventListenerLinkButton(me.linkButton, me.dynamicButton);
  return renderModeContainer;
 };

 QMUICustomPresetEditDlg.prototype.addEventListenerLinkButton = function (iLinkButton,iDynamicButton) {

   iLinkButton.addEventListener('buttonclick', function (){
       if(iDynamicButton.disabled) {
           iLinkButton.icon = WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorUnlinked.png';
           iDynamicButton.disabled = false;
       }
       else {
           iLinkButton.icon = WebappsUtils.getWebappsBaseUrl() + 'QualityManagerUI/assets/icons/32/I_QEditorLinked.png';
           iDynamicButton.disabled = true;
       }
   }); 
 };

 QMUICustomPresetEditDlg.prototype.buildGlobalPresetButtonView = function () {

  var me = this;

  var presetButtonsContainer = new UWA.Element('div', { 'class': 'wux-container' });
  presetButtonsContainer.setStyles({ position: 'relative', width: '450px', left: '250px' });

  var globalPresetButtons = me.getPresetButtons().inject(presetButtonsContainer);

  // create global handals
  me.properties["Global"].presetButtonGroup = globalPresetButtons;

  // create callbacks 
  globalPresetButtons.addEventListener('change', function onChange(e) {

   var currPreset = e.dsModel.value.toString();
   if (!attribElementInteraction && !propertyPrestButtonInteraction && !uiInitialization) {
    globalPrestButtonInteraction = true;
    me.updateGlobalPreset(currPreset);
    globalPrestButtonInteraction = false;
	globalPresetButtons.getButtonFromValue(currPreset).checkFlag = false;

   }
  });

  return presetButtonsContainer;
 };

 QMUICustomPresetEditDlg.prototype.buildAntiAliasingView = function () {

  var me = this;
  var mainContainer = UWA.Element('div', { 'class': 'wux-container' });
  //Add Preset buttons to antialiasing
  var antialiasingPresetContainer = UWA.Element('div', { 'class': 'wux-container' });
  //antialiasingPresetContainer.setStyles({position: 'relative',width: '450px', height:'1px', top:'1px',left:'310px'});
  var antiAliasingPresetButtons = me.getPresetButtons();
  antiAliasingPresetButtons.inject(antialiasingPresetContainer);

  //Create antialising contents
  var propertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });
  //Post Process
  var postProcessElements = ['NoAA', 'FXAA', 'SMAA'];
  var postProcessValues = ['NoAA', 'FXAA', 'SMAA'];
  var antialiasingPostProcContainer = new UWA.Element('div', { 'class': 'wux-container' }).inject(propertiesContainer);
  var postProcessContLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Anti-aliasing post process' }).inject(antialiasingPostProcContainer);
  postProcessContLabel.setStyles({ width: '232px' });
  var listPair2 = [];
  for (var index = 0; index < postProcessElements.length; index++) {
   listPair2[index] = { labelItem: postProcessElements[index], valueItem: postProcessValues[index] };
  }
  var postProcCombo = new WUXCombobox({ elementsList: listPair2, selectedIndex: 1, recId: 'AntiAliasing', enableSearchFlag: false }).inject(antialiasingPostProcContainer);
  postProcCombo.getContent().style.width = '25%';

  //Iterative Anti-aliasing
  var iterativeAAElements = ['NoAA', 'MSAA', 'MSMAA'];
  var iterativeValues = ['NoAA', 'MSAA', 'MSMAA'];
  var iterativeAAContainer = new UWA.Element('div', { 'class': 'wux-container' }).inject(propertiesContainer);;
  var iterativeAAContLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'IterativeAntiAliasing' }).inject(iterativeAAContainer);
  iterativeAAContLabel.setStyles({ width: '232px' });
  var listPair = [];
  for (var index = 0; index < iterativeAAElements.length; index++) {
   listPair[index] = { labelItem: iterativeAAElements[index], valueItem: iterativeValues[index] };
  }
  var iterativeAACombo = new WUXCombobox({ elementsList: listPair, selectedIndex: 1, recId: 'IterativeAntiAliasing', enableSearchFlag: false }).inject(iterativeAAContainer);
  iterativeAACombo.getContent().style.width = '25%';

  var antiAliasingExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
  antiAliasingExpanderContainer.setStyle('Width', '600px');

   var expander = new WUXExpander({
   style: 'filled-group',
   header: 'Anti-aliasing',
   body: propertiesContainer,
   recId:'Anti-aliasing',
   customHeader: antialiasingPresetContainer
  }).inject(antiAliasingExpanderContainer);

  // create global handals
  me.properties["AntiAliasing"] = {};
  me.properties["AntiAliasing"].presetButtonGroup = antiAliasingPresetButtons;
  me.properties["AntiAliasing"].postProcCombo = postProcCombo;
  me.properties["AntiAliasing"].iterativeAACombo = iterativeAACombo;
  me.properties["AntiAliasing"].expander = expander;

  // create callbacks 
  me.addEventListenerComboBox("AntiAliasing", postProcCombo);
  me.addEventListenerComboBox("AntiAliasing", iterativeAACombo);
  me.addEventListenerButtonGroup("AntiAliasing", antiAliasingPresetButtons);
  me.addEventListenerExpander("AntiAliasing", expander);
  
  return mainContainer;
 };

 QMUICustomPresetEditDlg.prototype.buildOutlineViewModeView = function () {

  var me = this;
  var mainContainer = UWA.Element('div', { 'class': 'wux-container' });

  //Add Preset buttons to antialiasing
  var viewmodePresetContainer = UWA.createElement('div', { 'class': 'wux-container', style: { 'vertical-align': 'top' } });
  //viewmodePresetContainer.setStyles({position: 'relative',width: '450px', height:'1px', top:'0px',left:'310px'});
  var viewmodePresetButtons = me.getPresetButtons();
  viewmodePresetButtons.inject(viewmodePresetContainer);

  //build view mode contents
  var viewmodePropertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Allow outline viewmode' }).inject(viewmodePropertiesContainer);
  contLabel.setStyles({
   width: '240px',
  });
  var togglecontainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' });
  var viewmodeToggle = new WUXToggle({ label: '', recId: 'AllowOutline' }).inject(togglecontainer);
  togglecontainer.inject(viewmodePropertiesContainer);

  //
  var outlineViewmodeExpander = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
  outlineViewmodeExpander.setStyle('Width', '600px');
  var expander = new WUXExpander({
   style: 'filled-group',
   header: 'Allow outline viewmode',
   body: viewmodePropertiesContainer,
   recId: 'Allow outline viewmode',
   customHeader: viewmodePresetContainer
  }).inject(outlineViewmodeExpander);

  // create global handals
  me.properties["OutlineViewMode"] = {};
  me.properties["OutlineViewMode"].presetButtonGroup = viewmodePresetButtons;
  me.properties["OutlineViewMode"].viewmodeToggle = viewmodeToggle;
  me.properties["OutlineViewMode"].expander = expander;

  // create callbacks 
  me.addEventListenerToggle("OutlineViewMode", viewmodeToggle);
  me.addEventListenerButtonGroup("OutlineViewMode", viewmodePresetButtons);

  return mainContainer;
 };

 QMUICustomPresetEditDlg.prototype.buildPixelcullingView = function () {

  var me = this;
  var mainContainer = UWA.Element('div', { 'class': 'wux-container' });

  var pixelDetailsPresetContainer = UWA.createElement('div', { 'class': 'wux-container', style: { 'vertical-align': 'top' } });
  //pixelDetailsPresetContainer.setStyles({position: 'relative',width: '450px', height:'1px', top:'0px',left:'310px'});
  var pixelCullingPresetButtons = me.getPresetButtons();
  pixelCullingPresetButtons.inject(pixelDetailsPresetContainer);

  var pixelPropertiescontainer = new UWA.Element('div', { 'class': 'wux-container' });
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Minimum object size(in pixel)' }).inject(pixelPropertiescontainer);
  contLabel.setStyles({ width: '232px' });

  var sliderSpinBoxcontainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(pixelPropertiescontainer);
  var pixelCullingSpinBox = new SliderSpinBox({
   minValue: 0,
   maxValue: 400,
   stepValue: 1,
   initialValue: 8,
   recId: 'PixelCulling'
  }).inject(sliderSpinBoxcontainer);
 // pixelCullingSpinBox.getContent().style.width = '25%';

  var pixelExpanderConatiner = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
  pixelExpanderConatiner.setStyle('Width', '600px');
  var expander = new WUXExpander({
   style: 'filled-group',
   header: 'Pixel culling',
   body: pixelPropertiescontainer,
   recId: 'Pixel culling',
   customHeader: pixelDetailsPresetContainer
  }).inject(pixelExpanderConatiner);

  // create global handals
  me.properties["PixelCulling"] = {};
  me.properties["PixelCulling"].presetButtonGroup = pixelCullingPresetButtons;
  me.properties["PixelCulling"].pixelCullingSpinBox = pixelCullingSpinBox;
  me.properties["PixelCulling"].expander = expander;
  // create callbacks 
  me.addEventListenerSpinBox("PixelCulling", pixelCullingSpinBox);
  me.addEventListenerButtonGroup("PixelCulling", pixelCullingPresetButtons);
  return mainContainer;
 };

 QMUICustomPresetEditDlg.prototype.buildTransparencyView = function () {

  var me = this;
  var mainContainer = UWA.Element('div', { 'class': 'wux-container' });


  var transparencyPresetContainer = UWA.createElement('div', { 'class': 'wux-container', style: { 'vertical-align': 'top' } });
  //transparencyPresetContainer.setStyles({position: 'relative',width: '450px', height:'1px', top:'0px',left:'310px'});
  var transparencyPresetButtons = me.getPresetButtons();
  transparencyPresetButtons.inject(transparencyPresetContainer);

  var transparencyElements = ['Alpha Blending', 'Weighted Average'];
  var values = ['AlphaBlending', 'WeightedAverage'];

  var transparencyPropertiesContainer = new UWA.Element('div', { 'class': 'wux-container' });
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Transparency Mode ' }).inject(transparencyPropertiesContainer);
  contLabel.setStyles({
   width: '232px',
  });
  var listPair = [];
  for (var index = 0; index < transparencyElements.length; index++) {
   listPair[index] = { labelItem: transparencyElements[index], valueItem: values[index] };
  }
  var transparencyCombo = new WUXCombobox({ elementsList: listPair, selectedIndex: 1, recId: 'Transparency', enableSearchFlag: false }).inject(transparencyPropertiesContainer);
  transparencyCombo.getContent().style.width = '25%';

  var transparencyExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
  transparencyExpanderContainer.setStyle('Width', '600px');
  var expander = new WUXExpander({
   style: 'filled-group',
   header: 'Transparency',
   body: transparencyPropertiesContainer,
   recId: 'Transparency',
   customHeader: transparencyPresetContainer
  }).inject(transparencyExpanderContainer);

  // create global handals
  me.properties["Transparency"] = {};
  me.properties["Transparency"].presetButtonGroup = transparencyPresetButtons;
  me.properties["Transparency"].transparencyCombo = transparencyCombo;
  me.properties["Transparency"].expander = expander;

  // create callbacks 
  me.addEventListenerComboBox("Transparency", transparencyCombo);
  me.addEventListenerButtonGroup("Transparency", transparencyPresetButtons);

  return mainContainer;

 };

 QMUICustomPresetEditDlg.prototype.buildShadowView = function () {

  var me = this;
  var maincontainer = new UWA.Element('div', { 'class': 'wux-container' });

  var shadowsPresetContainer = UWA.createElement('div', { 'class': 'wux-container', style: { 'vertical-align': 'top' } });
  var shadowsPresetButtons = me.getPresetButtons();
  shadowsPresetButtons.inject(shadowsPresetContainer);

  var shadowPropertiescontainer = new UWA.Element('div', { 'class': 'wux-container' });

  //Allow ground shadows
  var groundShadowContainer = new UWA.Element('div', { 'class': 'wux-container' }).inject(shadowPropertiescontainer);
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Allow ground shadows ' }).inject(groundShadowContainer);
  contLabel.setStyles({
   width: '232px'
  });
  var groundShadowTogglecontainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(groundShadowContainer);
  var groundShadowsToggle = new WUXToggle({ label: '', recId: 'AllowGroundShadows' }).inject(groundShadowTogglecontainer);

  //Allow inter-object shadows
  var interObjShadowContainer = new UWA.Element('div', { 'class': 'wux-container' }).inject(shadowPropertiescontainer);
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Allow inter-object shadows ' }).inject(interObjShadowContainer);
  contLabel.setStyles({
   width: '232px'
  });
  var interObjShadowTogglecontainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(interObjShadowContainer);
  var interObjectShadowsToggle = new WUXToggle({ label: '', recId: 'AllowInterObjectShadows' }).inject(interObjShadowTogglecontainer);

  //Filtering to use
  var Elements = ['PCFOptimized', 'ESM', 'poisson'];
  var values = ['PCFOptimized', 'ESM', 'poisson'];
  var filteringTypeContainer = new UWA.Element('div', { 'class': 'wux-container' }).inject(shadowPropertiescontainer);;
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Filtering to use' }).inject(filteringTypeContainer);
  contLabel.setStyles({
   width: '232px',
  });
  var listPair = [];
  for (var index = 0; index < Elements.length; index++) {
   listPair[index] = { labelItem: Elements[index], valueItem: values[index] };
  }
  var filteringTypeCombo = new WUXCombobox({ elementsList: listPair, selectedIndex: 2, recId: 'ShadowFilter', enableSearchFlag: false }).inject(filteringTypeContainer);
  filteringTypeCombo.getContent().style.width = '25%';

  //Filtering quality
  var qualityElements = ['Low', 'Medium', 'High'];
  var qualityValues = ['Low', 'Medium', 'High'];
  var filteringQualityContainer = new UWA.Element('div', { 'class': 'wux-container' }).inject(shadowPropertiescontainer);
  var filteringQualityContLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Filtering quality' }).inject(filteringQualityContainer);
  filteringQualityContLabel.setStyles({
   width: '232px',
  });
  var listPair2 = [];
  for (var index = 0; index < qualityElements.length; index++) {
   listPair2[index] = { labelItem: qualityElements[index], valueItem: qualityValues[index] };
  }
  var filteringQualityCombo = new WUXCombobox({ elementsList: listPair2, selectedIndex: 2, recId: 'ShadowQuality', enableSearchFlag: false }).inject(filteringQualityContainer);
  filteringQualityCombo.getContent().style.width = '25%';

  var shadowsExpanderConatiner = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(maincontainer);
  shadowsExpanderConatiner.setStyle('Width', '600px');

  var expander = new WUXExpander({
   style: 'filled-group',
   header: 'Shadows',
   recId: 'Shadows',
   body: shadowPropertiescontainer,
   customHeader: shadowsPresetContainer
  }).inject(shadowsExpanderConatiner);

  // create global handals
  me.properties["Shadows"] = {};
  me.properties["Shadows"].presetButtonGroup = shadowsPresetButtons;
  me.properties["Shadows"].filteringTypeCombo = filteringTypeCombo;
  me.properties["Shadows"].filteringQualityCombo = filteringQualityCombo;
  me.properties["Shadows"].groundShadowsToggle = groundShadowsToggle;
  me.properties["Shadows"].interObjectShadowsToggle = interObjectShadowsToggle;
  me.properties["Shadows"].expander = expander;

  // create callbacks 
  me.addEventListenerToggle("Shadows", groundShadowsToggle);
  me.addEventListenerToggle("Shadows", interObjectShadowsToggle);
  me.addEventListenerComboBox("Shadows", filteringQualityCombo);
  me.addEventListenerComboBox("Shadows", filteringTypeCombo);
  me.addEventListenerButtonGroup("Shadows", shadowsPresetButtons);

  return maincontainer;
 };

 QMUICustomPresetEditDlg.prototype.buildReflectionsView = function () {

  var me = this;
  var mainContainer = UWA.Element('div', { 'class': 'wux-container' });

  //add preset
  var reflectionsPresetContainer = UWA.createElement('div', { 'class': 'wux-container', style: { 'vertical-align': 'top' } });
  var reflectionPresetButtons = me.getPresetButtons();
  reflectionPresetButtons.inject(reflectionsPresetContainer);

  var reflectionsPropertiescontainer = new UWA.Element('div', { 'class': 'wux-container' });

  //Allow reflections on ground
  var allowReflectioncontainer = new UWA.Element('div', { 'class': 'wux-container' }).inject(reflectionsPropertiescontainer);
  var reflectionsContLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Allow reflections on ground' }).inject(allowReflectioncontainer);
  reflectionsContLabel.setStyles({
   width: '232px'
  });
  var togglecontainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(allowReflectioncontainer);;
  var reflectionToggle = new WUXToggle({ label: '', recId: 'AllowGroundReflection' }).inject(togglecontainer);


  //Reflections on ground
  var Elements = ['None', 'Mirror'];
  var values = [1, 2];
  var reflectionsContainer = new UWA.Element('div', { 'class': 'wux-container' }).inject(reflectionsPropertiescontainer);;
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Reflections on ground' }).inject(reflectionsContainer);
  contLabel.setStyles({
   width: '232px',
  });
  var listPair = [];
  for (var index = 0; index < Elements.length; index++) {
   listPair[index] = { labelItem: Elements[index], valueItem: values[index] };
  }
  var reflectionsCombo = new WUXCombobox({ elementsList: listPair, selectedIndex: 1, recId: 'ReflectionsOnGround', enableSearchFlag: false }).inject(reflectionsContainer);
  reflectionsCombo.getContent().style.width = '25%';

  var reflectionsExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
  reflectionsExpanderContainer.setStyle('Width', '600px');
  var expander = new WUXExpander({
   style: 'filled-group',
   header: 'Reflections',
   body: reflectionsPropertiescontainer,
   recId: 'Reflections',
   customHeader: reflectionsPresetContainer
  }).inject(reflectionsExpanderContainer);

  // create global handals
  me.properties["Reflections"] = {};
  me.properties["Reflections"].presetButtonGroup = reflectionPresetButtons;
  me.properties["Reflections"].reflectionsCombo = reflectionsCombo;
  me.properties["Reflections"].reflectionToggle = reflectionToggle;
  me.properties["Reflections"].expander = expander;

  // create callbacks 
  me.addEventListenerComboBox("Reflections", reflectionsCombo);
  me.addEventListenerToggle("Reflections", reflectionToggle);
  me.addEventListenerButtonGroup("Reflections", reflectionPresetButtons);

  return mainContainer;

 };

 QMUICustomPresetEditDlg.prototype.buildAmbientOcclusionView = function () {

  var me = this;
  var mainContainer = UWA.Element('div', { 'class': 'wux-container' });

  var ambientOcclusionPresetContainer = UWA.createElement('div', { 'class': 'wux-container', style: { 'vertical-align': 'top' } });
  var ambientOcclusionPresetButtons = me.getPresetButtons();
  ambientOcclusionPresetButtons.inject(ambientOcclusionPresetContainer);

  //Ambient occlusion build content
  var AOPropertiescontainer = new UWA.Element('div', { 'class': 'wux-container' });
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Allow ambient occlusion' }).inject(AOPropertiescontainer);
  contLabel.setStyles({
   width: '232px'
  });
  var AOToggleContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' });
  var AOToggle = new WUXToggle({ label: '', recId: 'AllowSSAO' }).inject(AOToggleContainer);
  AOToggleContainer.inject(AOPropertiescontainer);

  var AOExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
  AOExpanderContainer.setStyle('Width', '600px');

  var expander = new WUXExpander({
   style: 'filled-group',
   header: 'Ambient Occlusion',
   body: AOPropertiescontainer,
   recId: 'Ambient Occlusion',
   customHeader: ambientOcclusionPresetContainer
  }).inject(AOExpanderContainer);

  // create global handals
  me.properties["AmbientOcclusion"] = {};
  me.properties["AmbientOcclusion"].presetButtonGroup = ambientOcclusionPresetButtons;
  me.properties["AmbientOcclusion"].AOToggle = AOToggle;
  me.properties["AmbientOcclusion"].expander = expander;

  // create callbacks 
  me.addEventListenerToggle("AmbientOcclusion", AOToggle);
  me.addEventListenerButtonGroup("AmbientOcclusion", ambientOcclusionPresetButtons);

  return mainContainer;
 };

 QMUICustomPresetEditDlg.prototype.buildBloomView = function () {

  var me = this;
  var mainContainer = UWA.Element('div', { 'class': 'wux-container' });

  var bloomPresetContainer = UWA.createElement('div', { 'class': 'wux-container', style: { 'vertical-align': 'top' } });
  var bloomPresetButtons = me.getPresetButtons();
  bloomPresetButtons.inject(bloomPresetContainer);

  //Allow bloom
  var bloomPropertiescontainer = new UWA.Element('div', { 'class': 'wux-container' });
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Allow Bloom' }).inject(bloomPropertiescontainer);
  contLabel.setStyles({
   width: '232px'
  });
  var bloomTogglecontainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' });
  var bloomToggle = new WUXToggle({ label: '', recId: 'AllowBloom' }).inject(bloomTogglecontainer);
  bloomTogglecontainer.inject(bloomPropertiescontainer);

  var bloomExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
  bloomExpanderContainer.setStyle('Width', '600px');

  var expander = new WUXExpander({
   style: 'filled-group',
   header: 'Bloom',
   body: bloomPropertiescontainer,
   recId: 'Bloom',
   customHeader: bloomPresetContainer
  }).inject(bloomExpanderContainer);

  // create global handals
  me.properties["Bloom"] = {};
  me.properties["Bloom"].presetButtonGroup = bloomPresetButtons;
  me.properties["Bloom"].bloomToggle = bloomToggle;
  me.properties["Bloom"].expander = expander;

  // create callbacks 
  me.addEventListenerToggle("Bloom", bloomToggle);
  me.addEventListenerButtonGroup("Bloom", bloomPresetButtons);

  return mainContainer;

 };

 QMUICustomPresetEditDlg.prototype.buildDepthOfFieldView = function () {

  var me = this;
  var mainContainer = UWA.Element('div', { 'class': 'wux-container' });

  var depthPresetContainer = UWA.createElement('div', { 'class': 'wux-container', style: { 'vertical-align': 'top' } });
  var depthPresetButtons = me.getPresetButtons();
  depthPresetButtons.inject(depthPresetContainer);

  //Allow Depth of field
  var depthPropertiescontainer = new UWA.Element('div', { 'class': 'wux-container' });
  var contLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', text: 'Allow depth of field' }).inject(depthPropertiescontainer);
  contLabel.setStyles({
   width: '232px'
  });
  var depthTogglecontainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' });
  var depthToggle = new WUXToggle({ label: '', recId: 'AllowDepthOfField' }).inject(depthTogglecontainer);
  depthTogglecontainer.inject(depthPropertiescontainer);

  var depthExpanderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
  depthExpanderContainer.setStyle('Width', '600px');

  var expander = new WUXExpander({
   style: 'filled-group',
   header: 'Depth of field',
   body: depthPropertiescontainer,
   recId: 'Depth of field',
   customHeader: depthPresetContainer
  }).inject(depthExpanderContainer);

  // create global handals
  me.properties["DepthOfField"] = {};
  me.properties["DepthOfField"].presetButtonGroup = depthPresetButtons;
  me.properties["DepthOfField"].depthToggle = depthToggle;
  me.properties["DepthOfField"].expander = expander;
  // create callbacks 
  me.addEventListenerToggle("DepthOfField", depthToggle);
  me.addEventListenerButtonGroup("DepthOfField", depthPresetButtons);

  return mainContainer;

 };

 // Get tab panel
 QMUICustomPresetEditDlg.prototype.getPresetButtons = function () {

  var buttonGroup = new WUXButtonGroup();
  buttonGroup.addChild(new WUXButton({ recId: 'Low', type: 'radio', label: 'Low', value: 'Low' }));
  buttonGroup.addChild(new WUXButton({ recId: 'Medium', type: 'radio', label: 'Medium', value: 'Medium' }));
  buttonGroup.addChild(new WUXButton({ recId: 'High', type: 'radio', label: 'High', value: 'High' }));
  buttonGroup.addChild(new WUXButton({ recId: 'Ultra', type: 'radio', label: 'Ultra', value: 'Ultra' }));
  buttonGroup.addChild(new WUXButton({ recId: 'Default', type: 'radio', label: 'Default', value: 'Default' }));

  return buttonGroup;
 };

 // CallBack Handling

 QMUICustomPresetEditDlg.prototype.DoUpdatePropertyCombo = function () {

  var retVal = false;

  if (!globalPrestButtonInteraction && !propertyPrestButtonInteraction && !uiInitialization)
   retVal = true;

  return retVal;
 }

 QMUICustomPresetEditDlg.prototype.DoUpdatePresetButtonGroup = function () {

  var retVal = false;

  if (!attribElementInteraction && !globalPrestButtonInteraction && !uiInitialization)
   retVal = true;

  return retVal;
 }

 QMUICustomPresetEditDlg.prototype.addEventListenerComboBox = function (iProperty, iAttribComboBox) {

  var me = this;

  iAttribComboBox.addEventListener('change', function () {
   var attrib = iAttribComboBox.recId;
   var value = iAttribComboBox.currentValue;

   if (me.DoUpdatePropertyCombo()) {
    attribElementInteraction = true;
    me.updateAttribute(iProperty, attrib, value);
    attribElementInteraction = false;
   }
  });

 };

 QMUICustomPresetEditDlg.prototype.addEventListenerSpinBox = function (iProperty, iAttribSliderSpinBox) {

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

 QMUICustomPresetEditDlg.prototype.addEventListenerToggle = function (iProperty, iAttribToggle) {

  var me = this;

  iAttribToggle.addEventListener('change', function () {
   var attrib = iAttribToggle.recId;
   var value = iAttribToggle.checkFlag;

   if (me.DoUpdatePropertyCombo()) {
    attribElementInteraction = true;
    me.updateAttribute(iProperty, attrib, value);
    attribElementInteraction = false;
   }
  });
 };

 QMUICustomPresetEditDlg.prototype.addEventListenerButtonGroup = function (iProperty, iPresetButtonGroup) {

  var me = this;

  iPresetButtonGroup.addEventListener('change', function onChange(e) {
   var currPreset = e.dsModel.value.toString();

   if (me.DoUpdatePresetButtonGroup()) {
    propertyPrestButtonInteraction = true;
    me.updateProperty(iProperty, currPreset);
    me.UpdateExpanderUI(iProperty, true);
    propertyPrestButtonInteraction = false;
  }
  });
 };

 QMUICustomPresetEditDlg.prototype.addEventListenerExpander = function (iProperty, iExpander) {

  var me = this;
  iExpander.addEventListener('expand', function () {
   if (me.DoUpdatePropertyCombo()) {
    // may be used in future
   }
  });
 };

 // Interaction Handling
 QMUICustomPresetEditDlg.prototype.initializedUIfromDB = function () {
  /*
  1. Update global preset buttons according to qualityPresets.currentGlobalPreset
  2. itertate each property and update property preset button according to qualityPresets.preset["Custom"].Preset
  3. update the property attribute
  */
  var me = this;
  uiInitialization = true;

  var currentPreset = QMController.getCurrentGlobalPreset(this.currentPresetMode);
  me.updateGlobalPresetButtonUI(currentPreset);

  propertyPrestButtonInteraction = true;
  for (var attrib in me.properties) {

   if (attrib == "Global")
    continue;

   me.updatePropertyUI(attrib, "Custom");
  }
  propertyPrestButtonInteraction = false;

  uiInitialization = false;
 };

 QMUICustomPresetEditDlg.prototype.updateGlobalPreset = function (iPreset) {

  QMController.setGlobalPreset(this.currentPresetMode, iPreset,true);

  this.updatePropertyUI("AntiAliasing", iPreset);
  this.updatePropertyUI("PixelCulling", iPreset);
  this.updatePropertyUI("Transparency", iPreset);
  this.updatePropertyUI("Shadows", iPreset);
  this.updatePropertyUI("Reflections", iPreset);
  this.updatePropertyUI("AmbientOcclusion", iPreset);
  this.updatePropertyUI("OutlineViewMode", iPreset);
  this.updatePropertyUI("Bloom", iPreset);
  this.updatePropertyUI("DepthOfField", iPreset);

 };

 QMUICustomPresetEditDlg.prototype.updateProperty = function (iProperty, iPreset) {

  QMController.setProperty(this.currentPresetMode,iPreset, iProperty);
  this.updatePropertyUI(iProperty, iPreset);
 };

 QMUICustomPresetEditDlg.prototype.updatePropertyUI = function (iProperty, iPreset) {
  var properties = QMController.getPresetValue(this.currentPresetMode,iPreset);
  if (!UWACore.is(properties))
   return false;

  var currentProperty = properties[iProperty];
  if (!UWACore.is(currentProperty))
   return false;

  if (iPreset == "Custom") {
   iPreset = currentProperty.Preset;
  }

  this.updatePropertyPresetButtonUI(iProperty, iPreset);

  switch (iProperty) {
   case "AntiAliasing":
    {
     var aaPP = this.properties[iProperty].postProcCombo;
     var aaIterativePP = this.properties[iProperty].iterativeAACombo;

     aaPP.currentValue = currentProperty.AntiAliasing;
     aaIterativePP.currentValue = currentProperty.IterativeAntiAliasing;
     break;
    }
   case "PixelCulling":
    {
     var pixelCullingP = this.properties[iProperty].pixelCullingSpinBox;
     pixelCullingP.value = currentProperty.PixelCulling;
     break;
    }
   case "Transparency":
    {
     var transparencyP = this.properties[iProperty].transparencyCombo;
     transparencyP.currentValue = currentProperty.Transparency;

     break;
    }
   case "Shadows":
    {
     var shadowsTypeP = this.properties[iProperty].filteringTypeCombo;
     var shadowsQualityP = this.properties[iProperty].filteringQualityCombo;
     var grndShadowsP = this.properties[iProperty].groundShadowsToggle;
     var interObjShadowsP = this.properties[iProperty].interObjectShadowsToggle;

     shadowsTypeP.currentValue = currentProperty.ShadowFilter;
     shadowsQualityP.currentValue = currentProperty.ShadowQuality;
     grndShadowsP.checkFlag = currentProperty.AllowGroundShadows;
     interObjShadowsP.checkFlag = currentProperty.AllowInterObjectShadows;
     break;
    }
   case "Reflections":
    {
     var reflectionGrndP = this.properties[iProperty].reflectionsCombo;
     var allowReflectionP = this.properties[iProperty].reflectionToggle;

     reflectionGrndP.currentValue = currentProperty.ReflectionsOnGround;
     allowReflectionP.checkFlag = currentProperty.AllowGroundReflection;
     break;
    }
   case "AmbientOcclusion":
    {
     var ambientOcclusionP = this.properties[iProperty].AOToggle;
     ambientOcclusionP.checkFlag = currentProperty.AllowSSAO;
     break;
    }
   case "OutlineViewMode":
    {
     var viewmodeP = this.properties[iProperty].viewmodeToggle;
     viewmodeP.checkFlag = currentProperty.AllowOutline;

     break;
    }
   case "Bloom":
    {
     var bloomP = this.properties[iProperty].bloomToggle;
     bloomP.checkFlag = currentProperty.AllowBloom;
     break;
    }
   case "DepthOfField":
    {
     var depthP = this.properties[iProperty].depthToggle;
     depthP.checkFlag = currentProperty.AllowDepthOfField;
     break;
    }
  }
 };

 QMUICustomPresetEditDlg.prototype.updateGlobalPresetButtonUI = function (iPreset) {

  var globalPresetButton = this.properties["Global"].presetButtonGroup;
 };

 QMUICustomPresetEditDlg.prototype.updatePropertyPresetButtonUI = function (iProperty, iPreset) {

  var property = this.properties[iProperty];
  if (UWACore.is(property)) {
   var presetButtonGroup = property.presetButtonGroup;

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

 QMUICustomPresetEditDlg.prototype.updateAttribute = function (iPropertyName, attrib, value) {

  QMController.setAttribute(this.currentPresetMode, "Custom", iPropertyName, attrib, value);
  this.updatePropertyPresetButtonUI(iPropertyName, "Custom");

 };

 QMUICustomPresetEditDlg.prototype.UpdateExpanderUI = function (iProperty, iExpand) {

  this.properties[iProperty].expander.expandedFlag = iExpand;
 };

 return QMUICustomPresetEditDlg;
});


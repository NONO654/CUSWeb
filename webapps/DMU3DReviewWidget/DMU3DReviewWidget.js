/*!  Copyright 2015 Dassault Systemes. All rights reserved. */
define("DS/DMU3DReviewWidget/DMU3DReviewWidgetOptions",["UWA/Core","UWA/Class","UWA/Class/Options","UWA/Utils"],function(c,b,d,a){var e=b.singleton(d,{init:function(){var f={};if(window.location.search!==""){c.extend(f,a.parseQuery(window.location.search));if(f.widgetDomain){c.extend(f,a.parseQuery(f.widgetDomain))}}if("debug_me" in f||window.debug){f.debug=true}if("testWkb" in f||window.testWkb){f.testWkb=true}this.setOptions(f)}});return e});
/*!  Copyright 2015 Dassault Systemes. All rights reserved. */
define("DS/DMU3DReviewWidget/DMU3DReviewAppTransition",["DS/WAfrContainer/App"],function(a){var b;return a.extend({setUp:function(c){if(!c.sourceApp){var e=this;require(["DS/DMU3DReviewWidget/DMU3DReviewWidgetMain"],function(f){b=new f({widget:window.widget,viewerAttachment:function(g){e.pad3DViewer=g.pad3DViewer;c.done(g.pad3DViewer.render())},modelerType:"DEC"})});return}if(!c.sourceApp.pad3DViewer){c.done();return}this.pad3DViewer=c.sourceApp.pad3DViewer;var d=function(f){if(f.sourceApp&&!f.sourceApp.isDisposeCalled()){f.sourceApp.dispose()}b.setUp(f)};if(!b){require(["DS/DMU3DReviewWidget/DMU3DReviewWidgetMain"],function(f){b=new f({widget:window.widget,pad3DViewer:c.sourceApp.pad3DViewer});d(c)})}else{d(c)}},dispose:function(c){b.dispose(c);this._parent(c)}})});
/*!  Copyright 2015 Dassault Systemes. All rights reserved. */
define("DS/DMU3DReviewWidget/DMU3DReviewAppInit",["DS/WAfrContainer/App"],function(a){var b;return a.extend({setUp:function(c){if(!c.sourceApp){var e=this;require(["DS/DMU3DReviewWidget/DMU3DReviewWidgetMain"],function(f){b=new f({widget:window.widget,viewerAttachment:function(g){e.pad3DViewer=g.pad3DViewer;c.done(g.pad3DViewer.render())},modelerType:"VPM"})});return}if(!c.sourceApp.pad3DViewer){c.done();return}this.pad3DViewer=c.sourceApp.pad3DViewer;var d=function(f){if(f.sourceApp&&!f.sourceApp.isDisposeCalled()){f.sourceApp.dispose()}b.setUp(f)};if(!b){require(["DS/DMU3DReviewWidget/DMU3DReviewWidgetMain"],function(f){b=new f({widget:window.widget,pad3DViewer:c.sourceApp.pad3DViewer});d(c)})}else{d(c)}},dispose:function(c){b.dispose(c);this._parent(c)}})});define("DS/DMU3DReview/DMU3DReviewWidget",[],function(){});define("DS/DMU3DReviewWidget/DMU3DReviewWidgetMain",["DS/DMU3DReviewWidget/DMU3DReviewWidgetOptions","DS/DMUBaseExperience/EXP3DReviewWidgetSingleton","DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices","DS/PADUtils/PADSettingsMgt","DS/DMUMeasurable/DMUToolsSceneGraph"],function(k,i,m,f,e){var d={widget:null,viewer:null,viewerAttachment:null};var s,y;var c=null;var a=false,h=false;var B="2DAfr",C;var g=k.getOption("testWkb");var o={wkb2D:{type:"2D",wkb:[{file:g?"DMU3DReviewWidget2D_TST.xml":"DMU3DReviewWidget2D.xml",module:g?"CAT3DReviewTestWidget":"DMU3DReviewWidget"}]},wkb3D:{type:"3D",wkb:[{file:"ENOPAD3DViewer.xml",module:"ENOPAD3DViewer"},{file:g?"DMU3DReviewWidget_TST.xml":"DMU3DReviewWidget.xml",module:g?"CAT3DReviewTestWidget":"DMU3DReviewWidget"}]}};var t=function(){d.viewer.getContentName({callbacks:{onComplete:function(D){d.widget.setTitle(D.contentName)},onFailure:function(){}}})};var l=[];var r=function(E){function D(I){var K={lastCommand:[],currentCommand:null,defaultCommand:null},F=d.viewer.getCommandContext?d.viewer.getCommandContext():null;if(F){y._commandsState[F]=K}else{y._commandsState=K}y.resetDefaultCommand(F);y._isCommandEnding=false;y._ignoreCommandBeginWhileEndingCommand=false;["_commands","_cmdCheckHeader"].forEach(function(M){var L=F?y[M][F]:y[M];Object.keys(L).forEach(function(N){var O=L[N];if(O&&O._destroy){O._destroy()}delete L[N]})});var H=0;var J=I.viewer.getFrameWindow().getActionBar();var G=J.onActionBarReady(function(){H++;if(H===1&&I.merge){for(var L=1;L<I.afr.wkb.length;L++){I.viewer.loadActionBar({merge:true,file:I.afr.wkb[L].file,module:I.afr.wkb[L].module})}}else{J.removeCallback(G);I.viewer.getFrameWindow().getContextualUIManager().activateContextualBarOnLeftClicAfterCSOChange();if(I.options){I.options.done()}if(I.actionBarReadyCb){I.actionBarReadyCb()}}if(!I.merge||H===I.afr.wkb.length){l.shift();if(l.length){D(l[0])}}});I.viewer.loadActionBar({merge:false,file:I.afr.wkb[0].file,module:I.afr.wkb[0].module})}l.push(E);if(!y){require(["DS/ApplicationFrame/CommandsManager"],function(F){y=F;if(l.length===1){D(l[0])}})}else{if(l.length===1){D(l[0])}}};function A(D){if(D){D.subscribe("onReviewContextModified",function(E){if(E.type==="RefreshAB"){r({merge:true,afr:d.widget.getValue(B)==="true"?o.wkb2D:o.wkb3D,viewer:d.viewer})}else{if(E.type==="2D"&&(!d.widget.getValue(B)||d.widget.getValue(B)==="false")){r({merge:false,afr:o.wkb2D,viewer:d.viewer});d.widget.setValue(B,JSON.stringify(true))}else{if(E.type!=="2D"&&d.widget.getValue(B)==="true"){r({merge:true,afr:o.wkb3D,viewer:d.viewer});d.widget.setValue(B,JSON.stringify(false))}}}});D.setActiveState(true)}}var b=function(G){if(d.viewer){window.log("Must not be called in this method");return}G.unsubscribe(C);C=null;G.getController()._model._modelLoader.setCGRWithSG(true);if(!d.widget.getValue(B)){d.widget.addPreference({name:B,type:"hidden"})}var D=false,F=function(){if(!D){D=true;return}A(s.get3DReviewController({context:G}));require(["DS/ENOPAD3DViewer/utils/PAD3DViewerRestoreSession"],function(H){var I=H.restoreSession();if(I&&I.objectsLoading){var J=G.subscribe({event:"onLoadingComplete"},function(){G.unsubscribe(J);var K=d.widget.getValue("reviewIdInSession");if(K&&s){s.give3DReviewController({context:d.viewer}).loadReview(JSON.parse(K))}})}})};var E=function(){if(d.widget.getValue("widgetForODTReplay")==="1"){d.widgetViewer3DReview._viewer3DReview=G}d.widget.dispatchEvent("onWidgetAndAppReady",d.widget.getValue("widgetForODTReplay")==="1"?[{pad3DViewer:d.viewer}]:undefined);F()};require(["DS/DMU3DReviewController/DMU3DReviewController"],function(H){s=H;F()});if(d.widget.getValue(B)==="true"){r({merge:false,afr:o.wkb2D,viewer:G,actionBarReadyCb:E});G.getViewer().set2DMode(true)}else{r({merge:true,afr:o.wkb3D,viewer:G,actionBarReadyCb:E});G.getViewer().set2DMode(false)}d.viewerAttachment({pad3DViewer:G});G.getFrameWindow().getContextualUIManager().activateContextualBarOnLeftClicAfterCSOChange();d.viewer=G};var j=function(E){if(h){return}h=true;var G,F,H=[],J=[],I=require("DS/PADUtils/PADCommandProxy"),D=["DS/DMUBaseExperience/EXPUnitManagement","DS/PADUtils/PADSharedSettings","i18n!DS/PADUtils/assets/nls/PADUtils","i18n!DS/DMU3DReviewWidget/assets/nls/DMU3DReviewWidget"];if(d.modelerType!=="DEC"){D.push("DS/CfgAuthoringContextUX/scripts/CfgAuthoringContext")}require(D,function(P,K,N,M,O){F=O;function L(){var T=K.listAvailableSharedSettings(),S=K.usedSharedSettings,R=[],Q;Q=T.indexOf("useIndexAccleration");if(Q!==-1){T.splice(Q,1);if(S.indexOf("useIndexAccleration")===-1&&!c){R.push("useIndexAccleration")}}K.addSharedSettings(d.widget,R);if(c){J.push("useIndexAccleration")}if(k.getOption("debug")){if(!d.widget.hasPreference("populateTags")){H.push({preference:{name:"populateTags",type:"boolean",label:N.activateFilter_label,defaultValue:"false"},fct:function(V){var W=E.getBIController();if(W){W.toggleBetweenStandaloneAndSlaveMode(V?"STANDALONE":"SLAVE")}}})}if(!d.widget.hasPreference("webapi_timeout")){H.push({preference:{name:"webapi_timeout",type:"text",label:"Query timeout",defaultValue:"60000"}})}}else{J.push("populateTags");J.push("webapi_timeout")}J.forEach(function(V){d.widget.deleteValue(V)});J.length=0;H.forEach(function(V){d.widget.mergePreferences([V.preference])});T.forEach(function(V){if(S.indexOf(V)===-1){R.push(V)}});K.addSharedSettings(d.widget,R);if(!d.widget.hasPreference(P.Types.Length.name)){d.widget.addPreference({name:P.Types.Length.name,type:"list",label:M.dmuUnitsLengthText,defaultValue:P.Types.Length.defaultValue,options:[{label:M.dmuMillimeter,value:P.Length.mm.name},{label:M.dmuCentimeter,value:P.Length.cm.name},{label:M.dmuMeter,value:P.Length.m.name},{label:M.dmuKilometer,value:P.Length.km.name},{label:M.dmuInch,value:P.Length.inch.name},{label:M.dmuFoot,value:P.Length.foot.name}]});d.widget.addPreference({name:P.Types.Angle.name,type:"list",label:M.dmuUnitsAngleText,defaultValue:P.Types.Angle.defaultValue,options:[{label:M.dmuDegree,value:P.Angle.deg.name},{label:M.dmuRadian,value:P.Angle.rad.name}]});d.widget.addPreference({name:P.Types.Area.name,type:"list",label:M.dmuUnitsAreaText,defaultValue:P.Types.Area.defaultValue,options:[{label:M.dmuSquareMillimeter,value:P.Area.mm2.name},{label:M.dmuSquareCentimeter,value:P.Area.cm2.name},{label:M.dmuSquareMeter,value:P.Area.m2.name},{label:M.dmuSquareKilometer,value:P.Area.km2.name},{label:M.dmuSquareInch,value:P.Area.inch2.name},{label:M.dmuSquareFoot,value:P.Area.foot2.name}]});d.widget.addPreference({name:P.Types.Volume.name,type:"list",label:M.dmuUnitsVolumeText,defaultValue:P.Types.Volume.defaultValue,options:[{label:M.dmuCubicMillimeter,value:P.Volume.mm3.name},{label:M.dmuCubicCentimeter,value:P.Volume.cm3.name},{label:M.dmuCubicMeter,value:P.Volume.m3.name},{label:M.dmuCubicKilometer,value:P.Volume.km3.name},{label:M.dmuCubicInch,value:P.Volume.inch3.name},{label:M.dmuCubicFoot,value:P.Volume.foot3.name}]})}if(H.length||R.length){var U=function(){H.forEach(function(V){var X=V.preference.name;var Y=d.widget.getValue(X),W=f.getSetting(X);Y=V.preference.type==="boolean"&&(typeof Y!=="boolean")?"true"===Y:Y;if(Y!==W){f.setSetting(X,Y)}if(V.fct){V.fct(Y)}});f.updateWidgetPreferences();if(!G&&H.length){G=I.create({events:{onPreferenceModification:function(V){H.some(function(W){if(V.name===W.preference.name){if(typeof V.value!=="boolean"&&typeof V.value!=="string"){throw new Error("Value must be a string or a boolean")}if(f.getSetting(V.name)!==V.value){if(W.preference.type==="boolean"&&typeof V.value!=="boolean"){throw new Error("Preference is a boolean type so value must be a boolean")}W.debounce=true;d.widget.setValue(V.name,W.preference.type==="boolean"?(V.value?"true":"false"):V.value);f.setSetting(V.name,V.value)}if(W.fct){W.fct(V.value)}return true}return false})}}});H.forEach(function(V){if(V.cb){f.addEvent(V.cb,function(W){if(!V.debounce){G.preferenceModification({name:V.preference.name,value:W})}else{V.debounce=false}})}})}};U();d.widget.addEvent("endEdit",U)}}if(F&&!d.widget.hasPreference("changeControlActivation")){F.initialize2(E.getFrameWindow().getViewerFrame(),I.appId(),"hide","top-right",function(Q){F=null;if(Q&&Q.isLicenseValid===true){F=O;H.push({preference:{name:"changeControlActivation",type:"boolean",label:N.changeControlActivation_label,defaultValue:"false"},fct:function(R){F[R?"show":"hide"]()},cb:"onChangeControlActivation",debounce:false});H.push({preference:{name:"changeControlPosition",type:"list",label:N.changeControlPosition_label,defaultValue:"top-right",options:[{label:N["top-right_label"],value:"top-right"},{label:N["top-left_label"],value:"top-left"},{label:N["bottom-left_label"],value:"bottom-left"},{label:N["bottom-right_label"],value:"bottom-right"}]},fct:function(R){F.setPosition(R)}});f.setSetting("authorizeChangeControl",true)}else{J.push("changeControlActivation");J.push("changeControlPosition")}L()})}else{L()}})};function v(D){var E=d.widget.getValue("reviewIdInSession");E=E?JSON.parse(E):undefined;if(!E){d.widget.addPreference({name:"reviewIdInSession",type:"hidden"})}d.widget.setValue("reviewIdInSession",JSON.stringify(D))}function n(){if(!d.viewer){if(c===null){if(d.modelerType!=="DEC"){c=false;setTimeout(function(){n()},0)}else{m.getGrantedRoles(function(D){for(var E=0;E<D.length;E++){if(D[E].id==="EXL"){c=true}else{if(D[E].id==="PAR"){c=false;break}}}c=c!==null?c:false;n()})}return}require(["DS/ENOPAD3DViewer/PAD3DViewer","DS/ENOPAD3DViewer/utils/PAD3DViewerRestoreSession","text!DS/DMU3DReviewWidget/assets/DMU3DReviewWidget.json"],function(D,F,E){var H=JSON.parse(E),G;H.context="Default";G=new D({widget:d.widget,windowOptions:H,actionbar_corrected:true,allowAuthoring:!c});f.setSetting("appModelerType",d.modelerType==="DEC"?"DEC":"VPM");d.widget.addPreference({name:"appModelerType",type:"hidden"});d.widget.setValue("appModelerType",d.modelerType);if(d.modelerType!=="DEC"){f.setSetting("settypes",true)}if(c){f.setSetting("authorized_root_types",["MCAD Assembly","MCAD Component","CATDrawing","VPMReference","VPMRepReference"]);f.setSetting("dynamic_authorized_types",true)}else{G.setAuthorizedRootTypes(f.getSetting(d.modelerType==="DEC"?"dec_authorized_root_types":"ups_authorized_root_types"))}C=G.subscribe({event:"onReady"},b);F.init({widget:d.widget,pad3DViewer:G});G.subscribe({event:"onRootAdded"},t);G.subscribe({event:"onRootRemoved"},function(){t();var I=d.widget.getValue("reviewIdInSession");I=I?JSON.parse(I):undefined;if(!I){d.widget.addPreference({name:"reviewIdInSession",type:"hidden"})}d.widget.setValue("reviewIdInSession","")});G.subscribe({event:"onRootAttached"},t);G.subscribe({event:"onRootDetached"},t);G.subscribe({event:"onContentNameModified"},t);j(G);i.set(d.widget)})}}function z(){if(a===false){if(d.viewer){var E=d.widget.getValue("reviewIdInSession");E=E?JSON.parse(E):undefined;d.viewer.refresh();var F=d.viewer.subscribe({event:"onLoadingComplete"},function(){d.viewer.unsubscribe(F);v(E);var G=d.widget.getValue("reviewIdInSession");if(G&&s){s.give3DReviewController({context:d.viewer}).loadReview(JSON.parse(G))}})}}var D=y.getCommandCheckHeader("slidePlayCmdHdr",d.viewer.getCommandContext?d.viewer.getCommandContext():null);if(D&&D.getState()){D.setState(false)}}function u(){a=true}function w(){if(s){var D=s.give3DReviewController({context:d.viewer});if(D){D.refreshContext()}}a=false}function q(){if(d.viewer){if(s){s.unreference3DReviewController({context:d.viewer})}d.viewer.destroy()}h=false;s=y=null}function x(D){if(d.viewer){d.viewer.search({searchQuery:D})}}var p=function(D){if(D.pad3DViewer){d.modelerType=require("DS/PADUtils/PADSettingsMgt").getSetting("appModelerType")}if(d.modelerType!=="DEC"||d.modelerType!=="VPM"){d.modelerType=D.modelerType==="DEC"?"DEC":"VPM";if(D.pad3DViewer){require("DS/PADUtils/PADSettingsMgt").setSetting("appModelerType",d.modelerType)}}if(!D.pad3DViewer){d.widget=D.widget;if(D.viewerAttachment){d.viewerAttachment=D.viewerAttachment;n()}else{d.viewerAttachment=function(E){d.widget.setBody(E.pad3DViewer.render())};d.widget.addEvent("onLoad",n)}d.widget.addEvent("onEdit",u);d.widget.addEvent("endEdit",w);d.widget.addEvent("onRefresh",z);d.widget.addEvent("onDestroy",q);d.widget.addEvent("onSearch",x);if(d.widget.getValue("widgetForODTReplay")==="1"){d.widgetViewer3DReview=this}d.widget.addEvent("onReviewLoaded",v);d.widget.setMetas({helpPath:"DMU3DReviewWidget/assets/help"})}else{d.widget=D.widget;d.viewer=D.pad3DViewer;j(D.pad3DViewer)}};p.prototype.setUp=function(D){if(D.sourceApp&&D.sourceApp.pad3DViewer!==d.viewer){d.viewer=D.sourceApp.pad3DViewer}function E(){require(["DS/DMU3DReviewController/DMU3DReviewController"],function(F){s=F;A(s.get3DReviewController({context:d.viewer}))})}d.widget.setMetas({helpPath:"DMU3DReviewWidget/assets/help"});if(!d.widget.getValue(B)||d.widget.getValue(B)==="false"||e.getRoots(d.viewer).length>0){r({options:D,merge:true,afr:o.wkb3D,actionBarReadyCb:E,viewer:d.viewer});d.viewer.getViewer().set2DMode(false)}else{r({options:D,merge:false,afr:o.wkb2D,actionBarReadyCb:E,viewer:d.viewer});d.viewer.getViewer().set2DMode(true)}f.setSetting("dynamic_authorized_types",true)};p.prototype.dispose=function(){f.setSetting("dynamic_authorized_types",false);if(d.viewer){if(s){s.unreference3DReviewController({context:d.viewer})}}s=y=null};return p});
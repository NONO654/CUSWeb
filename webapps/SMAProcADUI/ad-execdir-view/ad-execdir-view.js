/*!  Copyright 2016 Dassault Systemes. All rights reserved. */
(function(M){var V=M.Polymer,W=M.DS;var aa=null,x=null,S=null,P=null,g=null,e=null,E=null,n=null,t=null,u=null,z=null,H=null,O=null,l=null,D=null,c=null,f=null,h=null,k=null,J=null,a=null,Q=null,i=null,N=null,r=null,o=null,C=null,Z=null,B=null,Y=null,d=null,K=null,w=null,R=null,T=null,U="ManagedData",A="ExecDirs",y=30,m="execDirRefreshError",q="execFileTailError",s={select:"select",open:"open",appMessage:"appmessage"},F={variable:"sp-variable"},j={disabled:"disabled"},I="Downloading ",b="Failed downloading: ",v="Choose an execution directory.",p=null,L=null,X=null,G=null;aa=function(){x.call(this,false)};x=function(ad){var ae=null,ac={executionDirectories:[],loaded:false},ab;if(this.session){ae=this.$.stationManager.getExecDirs(null);for(ab=0;ab<ae.length;ab++){ae[ab].loaded=false;ae[ab].parent=ac;if(ad){if(ae[ab].station&&ae[ab].station.length>0&&ae[ab].path&&ae[ab].path.length>0){ae[ab].accessDisabled=false;ae[ab].notFound=false}}}if(this.$.executionDirectoryChooser.rootItem){this.$.executionDirectoryChooser.rootItem.executionDirectories=ae;this.$.executionDirectoryChooser.rootItem.loaded=false}else{this.$.executionDirectoryChooser.rootItem={executionDirectories:ae,loaded:false}}}};S=function(ac){var ab="",ad;if(ac){if(ac.modified){ad=this.formatDate(ac.modified);this.$.tailExecutionFileSidepanel.modelModified=ad;this.$.tailFilePanel.modelModified=ad}else{this.$.tailExecutionFileSidepanel.modelModified="N/A";this.$.tailFilePanel.modelModified="N/A"}if(ac.contents){ab=ac.contents}}this.$.tailExecutionFileSidepanel.refreshTail(ab,ac.continuous,ac.eof,false);this.$.tailFilePanel.refreshTail(ab,ac.continuous,ac.eof,false)};P=function(ab){var ac=[],ad=null;if(typeof ab.executionDirectories!=="undefined"){ab.executionDirectories.forEach(function(ae){ad=this.$.executionDirectoryChooser.createItem("ad-multiview-execdir");if(ae.creating){ad.viewState=W.SMAProcADUI.ADMultiviewItem.VIEWSTATE.initializing}else{if(ae.accessDisabled){ad.viewState=W.SMAProcADUI.ADMultiviewItem.VIEWSTATE.accessDisabled}else{ad.viewState=W.SMAProcADUI.ADMultiviewItem.VIEWSTATE.ready}}ad.model=ae;ad.modelSource=A;ad.model.parentInstance=ab;ac.push(ad)}.bind(this))}else{if(ab.folders){ab.folders.forEach(function(ae){ad=this.$.executionDirectoryChooser.createItem("ad-multiview-folder");ad.viewState=ae.accessDisabled?W.SMAProcADUI.ADMultiviewItem.VIEWSTATE.accessDisabled:W.SMAProcADUI.ADMultiviewItem.VIEWSTATE.ready;ad.model=ae;ad.modelSource=A;ad.model.parentInstance=ab;ac.push(ad)}.bind(this))}if(ab.files){ab.files.forEach(function(ae){ad=this.$.executionDirectoryChooser.createItem("ad-multiview-file");ad.viewState=ae.accessDisabled?W.SMAProcADUI.ADMultiviewItem.VIEWSTATE.accessDisabled:W.SMAProcADUI.ADMultiviewItem.VIEWSTATE.ready;ae.details={};ad.model=ae;ad.modelSource=A;ad.model.parentInstance=ab;ac.push(ad)}.bind(this))}}return ac};g=function(af,ae,aj){var ac=[],ab=ae,ah=ae,ag=null,ai,ad;if(af&&aj){if(typeof af.executionDirectories!=="undefined"){ah=false;this.currentExecDir=null;af.executionDirectories=[];ai=this.$.stationManager.getExecDirs(null);if(!af.loaded||(ai.length===0)||this._autoRefreshing){ab=false}for(ad=0;ad<ai.length;ad++){if(ae&&af.loaded&&ai[ad].station&&(ai[ad].station.length>0)&&ai[ad].path&&(ai[ad].path.length>0)&&(!ai[ad].notFound||!this._autoRefreshing)){ai[ad].accessDisabled=false;ai[ad].autoRefreshEnabled=true}af.executionDirectories.push(ai[ad])}af.loaded=true;ac=P.call(this,af)}else{ab=false;if(typeof af.cosJobID!=="undefined"){this.currentExecDir=af;ah=ah||!af.loaded}if(!ah){ac=P.call(this,af)}}if(!ab&&!ah){aj(true,af,ac);if(this._autoRefreshTimeout){M.clearTimeout(this._autoRefreshTimeout)}this._autoRefreshTimeout=M.setTimeout(O.bind(this),this.autoRefreshInterval*1000)}else{if(ab){ag=function(){aj(true,af,ac)}.bind(this);this.$.stationManager.refresh({onComplete:ag,onFailure:ag,refreshServers:true})}else{if(ah){e.call(this,af,aj)}}}this._autoRefreshing=false;this._refreshCalled=false}};e=function(ak,al){var aj=null,ah=null,ai,ad=null,ab=[],ac=[],ag,af,ae;if(this.currentExecDir.autoRefreshEnabled){this.currentExecDir.autoRefreshEnabled=false;ad=this.currentExecDir}aj=function(an,ao){if(ad){ad.autoRefreshEnabled=true}var am=null;ao.autoRefreshEnabled=true;am=P.call(this,ao);for(ag=0;ag<ab.length;ag++){ae=false;for(af=0;af<am.length;af++){if((ab[ag].model.type===am[af].model.type)&&(ab[ag].model.name===am[af].model.name)){ae=true;break}}if(!ae){ac.push(ab[ag])}}for(ag=0;ag<ac.length;ag++){am.push(ac[ag])}al(true,ak,am);if(this._autoRefreshTimeout){M.clearTimeout(this._autoRefreshTimeout)}this._autoRefreshTimeout=M.setTimeout(O.bind(this),this.autoRefreshInterval*1000)}.bind(this);ah=function(am){var an=false;if(ad){ad.autoRefreshEnabled=true}if(am.errorCode!==W.SMAProcADUI.ADStationManager.ERRORS.userCanceled){if(am.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.directoryAccess){if(ak.filemonURL&&ak.filemonURL.length>0){ai="This execution directory could not be accessed using "+ak.filemonURL+".  The station may be shut down or inaccessible."}else{an=true;ai="This execution directory could not be accessed.  The station may be shut down or inaccessible."}}else{if(am.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.directoryAccessHost){if(ak.filemonURL&&ak.filemonURL.length>0){ak.notFound=true;ai="This execution directory could not be found using "+ak.filemonURL+".  The directory may have been deleted."}else{an=true;if(typeof ak.credentials!=="undefined"&&ak.credentials){ai="This execution directory could not be found.  The station may be shut down, or you may have entered the wrong password."}else{ai="This execution directory could not be found.  The station may be shut down."}}}else{if(am.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.itemNotFound){if(ak.type==="execdir"){if(ak.filemonURL&&ak.filemonURL.length>0){ak.notFound=true;ak.accessDisabled=true;ai="This execution directory could not be found using "+ak.filemonURL+".  The directory may have been deleted."}else{an=true;if(typeof ak.credentials!=="undefined"&&ak.credentials){ai="This execution directory could not be found.  The station may be shut down, or you may have entered the wrong password."}else{ai="This execution directory could not be found.  The station may be shut down."}}}else{ai="The execution sub-directory could not be found.  This directory may have been deleted."}}else{if(am.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.notAuthorized){if(ak.filemonURL&&ak.filemonURL.length>0){ai="You are not authorized to view the contents of this execution directory using "+ak.filemonURL+"."}else{an=true;ai="You are not authorized to view the contents of this execution directory."}ak.accessDisabled=true}else{if(am.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.transientMonitorFinished){an=true;ai="The contents of this transient execution directory are no longer available.";ak.accessDisabled=true}else{if(am.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.possibleMixedContent){if(ak.filemonURL&&ak.filemonURL.length>0){ai="An error occurred attempting to view the contents of this execution directory using "+ak.filemonURL+".  This may be caused by Web browser security restrictions."}else{an=true;ai="An error occurred attempting to view the contents of this execution directory.  This may be caused by Web browser security restrictions."}}else{if(am.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.userStationMismatch){if(ak.filemonURL&&ak.filemonURL.length>0){ai="An error occurred attempting to view the contents of this execution directory using "+ak.filemonURL+".  Please check that you are using the same user for your local station."}else{an=true;ai="An error occurred attempting to view the contents of this execution directory.  Please check that you are using the same user for your local station."}}else{if(ak.filemonURL&&ak.filemonURL.length>0){ai="An unspecified error occurred trying to access this execution directory using "+ak.filemonURL+".  The station may be shut down or inaccessible."}else{an=true;ai="An unspecified error occurred trying to access this execution directory.  The station may be shut down or inaccessible."}}}}}}}}if(an){ak.filemonJobID=null;if(typeof ak.credentials!=="undefined"&&ak.credentials){ak.credentials.encryptedCredentials=null;ak.credentials.windowsPass=null;ak.credentials.linuxPass=null}}this.fire(s.appMessage,{level:"error",message:ai,category:m})}ak.loaded=false;ak.autoRefreshEnabled=false;al(false,ak,null);this._autoRefreshing=true;this.$.executionDirectoryChooser.back();if(this._autoRefreshTimeout){M.clearTimeout(this._autoRefreshTimeout)}this._autoRefreshTimeout=M.setTimeout(O.bind(this),this.autoRefreshInterval*1000)}.bind(this);this.$.executionDirectoryChooser.getItems().forEach(function(am){if(W.SMAProcADUI.ADMultiviewItem.VIEWSTATE.initializing===am.viewState){ab.push(am)}});this.$.stationManager.requestExecDirContents(this.currentExecDir,ak,aj,ah)};E=function(ad,ac){var ab=ad,af=null,ae=null;if(!localStorage["SMAProcAdhoc.preferences.hideRemoveExecDirsConfirm"]){localStorage["SMAProcAdhoc.preferences.hideRemoveExecDirsConfirm"]="false"}af=localStorage["SMAProcAdhoc.preferences.hideRemoveExecDirsConfirm"].toLowerCase()==="true";if(!af){if(!this._execDirRemoveDlg){this._execDirRemoveDlg=new W.SMAProcADUI.ADExecDirRemoveDialog();this._execDirRemoveDlg.viewMode=this.viewMode;V.dom(document.body).appendChild(this._execDirRemoveDlg)}else{ae=this._execDirRemoveDlg;this._execDirRemoveDlg=ae.cloneNode(true);document.body.replaceChild(this._execDirRemoveDlg,ae)}this._execDirRemoveDlg.addEventListener("accept",t.bind(this,ad,ac),false);this._execDirRemoveDlg.addEventListener("cancel",u.bind(this,ac),false);this._execDirRemoveDlg.hideConfirm=af;this._execDirRemoveDlg.selectedExecDirs=ab;this._execDirRemoveDlg.show()}else{t.call(this,ad,ac)}};n=function(ad,ab){var ae=((typeof ad.model.type!=="undefined")&&ad.model.type&&(ad.model.type==="folder")),ac=((typeof ab.model.type!=="undefined")&&ab.model.type&&(ab.model.type==="folder"));if(ae&&!ac){return -1}else{if(!ae&&ac){return 1}else{return ad.model.name.localeCompare(ab.model.name)}}};t=function(ac,ab){var ad;if(this._execDirRemoveDlg){localStorage["SMAProcAdhoc.preferences.hideRemoveExecDirsConfirm"]=this._execDirRemoveDlg.hideConfirm?"true":"false"}if(ac){for(ad=0;ad<ac.length;ad++){if(typeof ac[ad].filemonURL!=="undefined"){this.session.removeExecutionDirectory(ac[ad])}}}if(ab){ab(true)}};u=function(ab){if(ab){ab(false)}};z=function(ae){var ah,ad,ac,ag=false,ai,af=false;ai=this.$.currentDragObject.getValue();if(ai){af=true;if(Array.isArray(ai)){for(var ab=0;ab<ai.length;ab++){ah=ai[ab];ad=ah.modelSource;ac=ah.model;if((ad===U)&&ac){if(this.currentExecDir&&this.currentExecDir.station){ag=true}}}}else{if(ai.length>0){ah=JSON.parse(ai);ad=ah.modelSource;ac=ah.model;if((ad===U)&&ac){if(this.currentExecDir&&this.currentExecDir.station){ag=true}}}}}if(!this.$.dashboard.isInDashboard()){ae.dataTransfer.dropEffect=ag?"copy":"none"}else{if(af){ae.dataTransfer.dropEffect=ag?"copy":"none"}else{ae.dataTransfer.dropEffect="move"}}};H=function(ab){var aj,ag,ai,ac,al=null,ah=null,ad=[];if(typeof(ab.dataTransfer)!=="undefined"){var ae=ab.dataTransfer.getData("text");if(ae&&(typeof ae==="string")){try{ah=JSON.parse(ae)}catch(ak){console.log("Unexpected data format")}if(ah){al=ah.data.items[0]}}}if(al&&(al.objectType==="Simulation Process"||al.objectType==="Simulation")){}else{ab.stopPropagation();ab.cancelBubble=true;ab.preventDefault();aj=this.$.currentDragObject.getValue();if(aj&&Array.isArray(aj)){for(var af=0;af<aj.length;af++){ag=aj[af];ai=ag.modelSource;ac=ag.model;if((ai===U)&&ac){ad.push(ac)}}l.call(this,ad)}else{if(aj&&(aj.length>0)){ag=JSON.parse(aj);ai=ag.modelSource;ac=ag.model;ad.push(ac);if((ai===U)&&ac){l.call(this,ad)}}}}};O=function(){if(!this.currentExecDir||this.currentExecDir&&this.currentExecDir.autoRefreshEnabled){this._autoRefreshing=true;this.$.executionDirectoryChooser.refresh(true)}else{if(this._autoRefreshTimeout){M.clearTimeout(this._autoRefreshTimeout)}this._autoRefreshTimeout=M.setTimeout(O.bind(this),this.autoRefreshInterval*1000)}};l=function(ab){var af=this.$.executionDirectoryChooser.openItem,ag=af?af:undefined,aj=ag?ag.path:"",ae=null,ai=null,ac=null,ah=null;for(var ad=0;ad<ab.length;ad++){ai={};ac=new Date();ae=ab[ad];ai.modelID=ae.id;ai.name=ae.name;ai.lastModified=ac.toJSON();ai.details={};if(ae.type==="folder"){ai.type="folder";ah=this.$.executionDirectoryChooser.createItem("ad-multiview-folder")}else{ai.type="file";ah=this.$.executionDirectoryChooser.createItem("ad-multiview-file")}ah.model=ai;ah.viewState=W.SMAProcADUI.ADMultiviewItem.VIEWSTATE.initializing;ah.modelSource=A;ai.parentInstance=af;this.$.executionDirectoryChooser.$.contentPanel.addItem(ah,true)}if(aj.length>0){this.session.downloadManagedData(ag,ab,D.bind(this),c.bind(this));this.fire(s.appMessage,{level:"info",message:I+ae.name})}else{this.fire(s.appMessage,{level:"error",message:b+v})}};D=function(){this.$.executionDirectoryChooser.refresh(false)};c=function(ac,ab){this.fire(s.appMessage,{level:"error",message:b+ab});this.$.executionDirectoryChooser.refresh(false)};f=function(){var ad=this.getSelections(),ac,ab=false;this.DOM(this.$.tailExecutionFileButton).addClass("disabled");if(ad.length===1){if(typeof ad[0].model!=="undefined"&&ad[0] instanceof W.SMAProcADUI.ADMultiviewFile){this.DOM(this.$.tailExecutionFileButton).removeClass("disabled")}this.DOM(this.$.configureItem).removeClass("disabled")}else{this.DOM(this.$.configureItem).addClass("disabled")}if(ad.length>0){ab=true;for(ac=0;ac<ad.length;ac++){if((typeof ad[ac].model!=="undefined")&&ad[ac].model&&(typeof ad[ac].model.filemonURL==="undefined")){ab=false;break}}}if(ab){this.DOM(this.$.executionDirectoryChooser.$.remove).removeClass(j.disabled)}else{this.DOM(this.$.executionDirectoryChooser.$.remove).addClass(j.disabled)}};h=function(){var ad=this.getSelections(),ac=null,ab=null;if(ad&&(ad.length===1)){ac=ad[0];ab=ac.model;if(ac.tagName.toLowerCase()==="ad-multiview-execdir"){this.$.itemPropertiesPanel.showExecDir(ab);this.$.itemConfigView.open()}else{if(ac.tagName.toLowerCase()==="ad-multiview-folder"){this.$.itemPropertiesPanel.showExecFolder(ab);this.$.itemConfigView.open()}else{if(ac.tagName.toLowerCase()==="ad-multiview-file"){this.$.itemPropertiesPanel.showExecFile(ab);this.$.itemConfigView.open()}}}}else{this.$.itemConfigView.close()}};k=function(ab){ab.refresh(false)};a=function(ac){var ab,ad=function(af){af.preventDefault();ac.onComplete(true)},ae=function(){ac.onComplete(false)};if(!this._execDirLoginDlg){this._execDirLoginDlg=new W.SMAProcADUI.ADExecDirLoginDialog();V.dom(document.body).appendChild(this._execDirLoginDlg)}else{ab=this._execDirLoginDlg;this._execDirLoginDlg=ab.cloneNode(true);document.body.replaceChild(this._execDirLoginDlg,ab)}this._execDirLoginDlg.addEventListener(W.SMAProcADUI.ADExecDirLoginDialog.EVENTS.accept,ad);this._execDirLoginDlg.addEventListener(W.SMAProcADUI.ADExecDirLoginDialog.EVENTS.cancel,ae);this._execDirLoginDlg.execDir=ac.execDir;this._execDirLoginDlg.show()};Q=function(){this._autoRefreshTimeout=null;this._execDirRemoveDlg=null;this._autoRefreshing=false};i=function(){this.DOM(this).find(F.variable).forEach(function(ab){this.set("globals."+ab.name,ab.getValue())}.bind(this));this.$.executionDirectoryChooser.populateFunction=g.bind(this);this.$.executionDirectoryChooser.removeFunction=E.bind(this);this.$.executionDirectoryChooser.sortFunction=n.bind(this);this.$.tailExecutionFileSidepanel.onTailRefresh=w.bind(this);this.$.tailFilePanel.onTailRefresh=w.bind(this);this.$.stationManager.setCredentialsFunction(a.bind(this));f.call(this)};N=function(){this.async(function(){var ac=localStorage["SMAProcAdhoc.preferences.execdirViewMode"];if(ac&&ac.length>0){this.viewMode=ac}f.call(this);var ab=localStorage["SMAProcAdhoc.preferences.execdirAutoRefresh"];if(ab&&ab.length>0){this.autoRefreshInterval=parseInt(ab);if(isNaN(this.autoRefreshInterval)){this.autoRefreshInterval=y}}})};r=function(ab){this.set("globals."+ab.detail.name,ab.detail.value)};o=function(ab){ab.stopPropagation();ab.cancelBubble=true;if(this.$.itemConfigView.isOpen()){h.call(this)}f.call(this);this.fire(s.select,{items:ab.detail.items})};C=function(ab){ab.stopPropagation();ab.cancelBubble=true;if(typeof ab.detail.item.executionDirectories!=="undefined"&&this.$.itemConfigView.isOpen()){this.$.itemConfigView.close()}else{if(ab.detail.item.type==="file"){J.call(this,ab.detail.item)}}f.call(this);this.fire(s.open,{item:ab.detail.item})};Z=function(ab){ab.stopPropagation();ab.cancelBubble=true;ab.preventDefault();z.call(this,ab);return true};B=function(ab){if(this.$.access.write){H.call(this,ab);return true}else{return false}};Y=function(ab){ab.stopPropagation();ab.cancelBubble=true;var ac=this.getSelections();if(ac.length===1){if(typeof ac[0].model!=="undefined"){if(this.currentExecDir&&ac[0] instanceof W.SMAProcADUI.ADMultiviewFile){J.call(this,ac[0].model)}}}return true};J=function(ab){if(this.$.tailfileWS.isInDashboard()){this.$.tailFilePanel.directory=this.currentExecDir;this.$.tailExecutionFileSidepanel.directory=this.currentExecDir;this.$.tailFilePanel.model=ab;this.$.tailExecutionFileSidepanel.model=ab;if(!this.$.tailFilePanel.isOpen()){this.$.tailFilePanel.open()}}else{this.$.tailExecutionFileSidepanel.directory=this.currentExecDir;this.$.tailExecutionFileSidepanel.model=ab;if(!this.$.tailExecutionFileSidepanel.isOpen()){this.$.tailExecutionFileSidepanel.open()}else{this.$.tailExecutionFileSidepanel.expand()}}};d=function(ab){this.$.tailExecutionFileSidepanel.close();ab.stopPropagation();ab.cancelBubble=true;return true};K=function(ab){w.call(this);ab.stopPropagation();ab.cancelBubble=true;return true};w=function(ad,ae){var ac=function(af){S.call(this,af)}.bind(this),ab=function(af){var ag=null,ah="Could not display the contents of this file.";if(af.errorCode!==W.SMAProcADUI.ADStationManager.ERRORS.userCanceled){if(af.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.directoryAccess){ag="The file could not be accessed.  The station may be shut down."}else{if(af.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.directoryAccessHost){ag="The file could not be accessed.  The station may be shut down."}else{if(af.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.userStationMismatch){ag="The file could not be accessed.  Please check that you are using the same user for your local station."}else{if(af.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.notAuthorized){ag="You are not authorized to view the contents of this file."}else{if(af.errorCode===W.SMAProcADUI.ADStationManager.ERRORS.itemNotFound){ah="Could not display the contents of this file.  It may have been deleted."}else{ag="An unspecified error occurred trying to tail this file"}}}}}if(ag){this.fire(s.appMessage,{level:"error",message:ag,category:q})}this.$.tailExecutionFileSidepanel.modelModified="N/A";this.$.tailFilePanel.modelModified="N/A";this.$.tailExecutionFileSidepanel.refreshTail(ah,false,false,true);this.$.tailFilePanel.refreshTail(ah,false,false,true)}}.bind(this);if(this.$.tailfileWS.isInDashboard()){this.$.stationManager.tailExecDirFile(this.$.tailFilePanel.directory,this.$.tailFilePanel.model.relativePath,ae,ad,ac,ab)}else{this.$.stationManager.tailExecDirFile(this.$.tailExecutionFileSidepanel.directory,this.$.tailExecutionFileSidepanel.model.relativePath,ae,ad,ac,ab)}return true};R=function(){if(this.$.itemConfigView.isOpen()){this.$.itemConfigView.close()}else{h.call(this)}f.call(this)};T=function(){f.call(this)};p=function(){return this.$.executionDirectoryChooser.openItem};L=function(){return this.$.executionDirectoryChooser.selections};X=function(){x.call(this,true);this.$.executionDirectoryChooser.refresh(true)};G=function(ab){this.$.stationManager.setCredentialsFunction(ab)};W.SMAProcADUI=W.SMAProcADUI||{};W.SMAProcADUI.ADExecDirView=V({is:"ad-execdir-view",properties:{access:{type:String,value:"",reflectToAttribute:true},autoRefreshInterval:{type:Number,value:function(){return y}},currentExecDir:{type:Object,value:null},emptyMessage:{type:String,value:""},globals:{type:Object,value:function(){return{}}},rootTitle:{type:String,value:"Execution Directories"},session:{type:Object,value:null,observer:"sessionChanged"},showConfigureButton:{type:Boolean,value:false},showTailButton:{type:Boolean,value:false},showRemoveButton:{type:Boolean,value:false},viewMode:{type:String,value:function(){return W.SMAProcADUI.ADMultiviewPanel.VIEWMODE.icon}}},created:function(){return Q.apply(this,arguments)},ready:function(){return i.apply(this,arguments)},attached:function(){return i.apply(this,arguments)},onVariableValueChange:function(){return r.apply(this,arguments)},onSelect:function(){return o.apply(this,arguments)},onOpen:function(){return C.apply(this,arguments)},onDragOver:function(){return Z.apply(this,arguments)},onDrop:function(){return B.apply(this,arguments)},onTailExecutionFile:function(){return Y.apply(this,arguments)},onTailExecutionFileSidepanelCancel:function(){return d.apply(this,arguments)},onTailExecutionFileSidepanelRefresh:function(){return K.apply(this,arguments)},onTailExecutionFileSidepanelRefresh2:function(){return w.apply(this,arguments)},onConfigureItem:function(){return R.apply(this,arguments)},onConfigureItemClose:function(){return T.apply(this,arguments)},getOpenItem:function(){return p.apply(this,arguments)},getSelections:function(){return L.apply(this,arguments)},refresh:function(){return X.apply(this,arguments)},setCredentialsFunction:function(){return G.apply(this,arguments)},sessionChanged:function(){aa.call(this)},behaviors:[W.SMAProcSP.SPBase,W.SMAProcADUI.FormatUtilities],_computeTailButtonClass:function(ab){return this.tokenList({hidden:ab!==true})+"btn btn-xs btn-default "+this.tokenList({hidden:ab!==true})},_computeConfigureButtonClass:function(ab){return this.tokenList({hidden:ab!==true})+"btn btn-xs btn-default "+this.tokenList({hidden:ab!==true})},tokenList:function(ad){var ab,ac=[];for(var ab in ad){if(ad[ab]){ac.push(ab)}}return ac.join(" ")}})}(this));
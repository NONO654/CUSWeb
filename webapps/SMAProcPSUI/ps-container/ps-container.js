/*!  Copyright 2015 Dassault Systemes. All rights reserved. */
require(["UWA/Core","UWA/Class","UWA/Class/Options","UWA/Class/Events"],function(n,o,g,h){var p,j,m,d,b,a,k,i,f="SIMDISB_AP",l="com.ds.compass",e="compassEventSocket";i={variable:"sp-variable"};function c(){}c.prototype.createSimulation=function(q,r){this.configMap.context=q;if(r==="SysError"){r="System Error"}this.configMap.runInfo="<RunInfo logLevel='"+r+"' submissionHost=''></RunInfo>";return new this.Simulation(this.configMap)};c.prototype.configMap={jobXMLURL:null,cosPubkeyURL:null,encryptURL:null,mcsTicketURL:null,runInfo:null,context:null,timeout:150000};c.prototype.configureFactory=function(q){var r={eedBaseURL:q.eedBaseURL,runURL:q.eedBaseURL+"/execution/run/workflow",jobXMLURL:q.mcsWSBaseURL+"/jobs",cosPubkeyURL:q.eedBaseURL+"/execution/pubkey",encryptURL:q.mcsWSBaseURL+"/data/getEncryptedCreds",mcsTicketURL:q.mcsBaseURL+"/ticket/get",runInfo:"<RunInfo logLevel='Debug' submissionHost=''></RunInfo>",mcsURL:q.mcsBaseURL};n.extend(this.configMap,r)};c.prototype.Simulation=(function(){var q=o.extend(g,h,{init:function(r){this.setOptions(r);this.alive=false;this._runSimulation(this.options)},_runSimulation:function(r){var t=new window.DS.SMAProcSP.SPRun(),s=this;if(!t||!this.options){q.dispatchEvent("onError","error: Could not initialize sp-run.");return}t.runURL=r.runURL;t.jobXMLURL=r.jobXMLURL;t.cosPubkeyURL=r.cosPubkeyURL;t.encryptURL=r.encryptURL;t.mcsTicketURL=r.mcsTicketURL;t.runInfo=r.runInfo;t.mcsURL=this._computemcsURL();t.simOID=r.context.id;t.tenantID=this.getWUPlatform();t.timeout=r.timeout;t.addEventListener("success",function(u){s.dispatchEvent("onSuccess",u.detail)});t.addEventListener("error",function(u){s.dispatchEvent("onError",u.detail)});t.runSimulation(r.context,r.context.id,"",false)},onSuccess:function(s){var r=s.result;this.alive=true;this.id=r.EEDJobID;this.plmid=r.MCSJobID;this.ticket=r.EEDTicket;this.context=r.context;this.dispatchEvent("simulation:create",{id:this.id,context:this.context})},getWUPlatform:function(){return appData.WUPlatformId},_computemcsURL:function(){if(appData&&appData.environments&&appData.environments.length===1){return appData.environments[0].cstorage}return""},onError:function(r){this.alive=false;this.dispatchEvent("simulation:create:fail",{result:r,context:this.options.context})}});return q}());b=function(t){var s=Polymer.dom(t).event.currentTarget.objectId;if(this.activeSim&&this.activeSim.id===s){if(Object.keys(t.detail).length!==0){if(this.sidebarmode==="simList"){this.querySelector("#psSimulationList").updateJobDetails(t.detail)}else{this.querySelector("#psSearchedSimulation").updateJobDetails(t.detail);var q=this.querySelector("#psSimulationList");var u=q.simlist;for(var r=0;r<u.length;r++){if(u[r].oid===this.activeSim.oid){q.updateJobDetails(t.detail,r);break}}}}}};a=function(q){if(this.activeSim&&this.activeSim.id===q.target.objectId){if(Object.keys(q.detail).length!==0){if(this.sidebarmode==="simList"){this.querySelector("#psSimulationList").updateAttributes(q.detail)}else{this.querySelector("#psSearchedSimulation").updateAttributes(q.detail)}}}};p=function(){var r=this.querySelector("#simcontent");if(this.activeSim){if(r){Polymer.dom(r).classList.add("is-active");r.activesim=this.activeSim}if(this._compassEventSocket){var q={objectType:"",objectId:String(this.activeSim.id),envId:"",contextId:""};this._compassEventSocket.dispatchEvent("onSetObject",q)}this.querySelector(".noSimulationsSelected")&&this.querySelector(".noSimulationsSelected").classList.add("hide")}else{if(r){r.classList.remove("is-active")}if(this._compassEventSocket){this._compassEventSocket.dispatchEvent("onResetObject",{})}this.querySelector(".noSimulationsSelected")&&this.querySelector(".noSimulationsSelected").classList.remove("hide")}};j=function(){var r="license_ws1",q=window.getTopWindow?window.getTopWindow():window;if(this.$[r].hasPendingUpdates()){this.$[r].flushAll();return"Your changes are still being saved(this should only take a moment longer).\n\nIf you leave now, your recent changes may be lost."}var s=this.querySelector("#simcontent");if(s){s.stopJobMonitor()}if(q.bpsTagNavConnector&&q.bpsTagNavConnector.TagNavigator){q.bpsTagNavConnector.TagNavigator.get6WTagger("context1").clearFilters(true)}if(q.psProxy){q.psProxy.die()}if(this._compassEventSocket){this._compassEventSocket.dispatchEvent("onResetObject",{});this._compassEventSocket.disconnect();this._compassEventSocket=null}};d=function(){var q=window.getTopWindow?window.getTopWindow():window;window.onbeforeunload=j.bind(this);window.require(["UWA/Utils/InterCom"],function(r){this._compassEventSocket=new r.Socket(e);this._compassEventSocket.subscribeServer(l,q);this._compassEventSocket.addListener("compassPanelOnShow",function(){if(this.activeSim){var s={objectType:"",objectId:String(this.activeSim.id),envId:"",contextId:""};this._compassEventSocket.dispatchEvent("onSetObject",s)}else{this._compassEventSocket.dispatchEvent("onResetObject",{})}}.bind(this))}.bind(this))};m=function(){var x=this;if(this.activeitemid){this.sidebarmode="searchedSim"}var u=(window.Promise!==undefined);if(!u){require(["UWA/Class/Promise"],function(C){window.Promise=C})}var B,s,q,z=window.getTopWindow?window.getTopWindow():window;try{z.document.getElementById("panelToggle").click()}catch(y){window.console.log("unable to toggle left pane")}try{var v=z,r=window.findFrame(v,"content");if(!r){v=z.getWindowOpener().getTopWindow();r=window.findFrame(v,"content")}v.currentApp=f;var A=[];A[0]="SMAScenario_Definition_New";v.changeProduct("SIMULIA","Performance Study",f,A,f,null);v.showMyDesk()}catch(y){window.console.log("unable to set app name")}B=this.$.dashboard.getMcsUri();this.$.mcsBaseURL.setValue(B);s=B+"/resources/slmservices";this.$.mcsWSBaseURL.setValue(s);this.$.inDashBoard.setValue(this.$.dashboard.isInDashboard());q=this.DOM(this).find(i.variable).root;for(var t=0;t<q.length;t+=1){this.globals[q[t].name]=q[t].getValue()}this.simulationFactory=new c();this.compareSimulationData=[];var w=this.$.cosServer.getUrlForDefaultServer();this.simulationFactory.configureFactory({eedBaseURL:w,runURL:w+"/execution/run/workflow",jobXMLURL:this.$.mcsWSBaseURL.getValue()+"/jobs",cosPubkeyURL:w+"/execution/pubkey",encryptURL:this.$.mcsWSBaseURL.getValue()+"/data/getEncryptedCreds",mcsTicketURL:this.$.mcsBaseURL.getValue()+"/ticket/get"});this.addEventListener("showEmptyPlaceholder",k.bind(this));this.$.dashboard.getPlatforms().then(function(D){var C={environments:D};x.envList=C;x.envListReady()})};k=function(q){if(!this.activeitemid||q.detail){this.querySelector(".noSimulationsSelected")&&this.querySelector(".noSimulationsSelected").classList.remove("hide")}};window.Polymer({is:"ps-container",behaviors:[window.DS.SMAProcSP.SPBase],properties:{activeSim:{observer:"activeSimChanged"},activeitemid:{type:String,notify:true},globals:{type:Object,value:function(){return{eedBaseURL:""}}},session:{type:Object,value:function(){return{}}},compareItems:{type:Array,notify:true,value:function(){return[]}},sidebarmode:{type:String,value:"simList",notify:true},envList:{type:Object,notify:true}},ready:function(){return m.apply(this,arguments)},attached:function(){this.async(d.bind(this))},hideCompareView:function(){this.querySelector("#compareModal").hide()},onSimContentJobstatuschange:function(){return b.apply(this,arguments)},onSimAttributesChangechange:function(){return a.apply(this,arguments)},onSimlistCompare:function(q){this.compareItems=q.detail.slice(0);this.querySelector("#compareModal").show()},onOpenSimulationFromCompare:function(q){this.hideCompareView();this.activeSim=q.detail;this.querySelector("#psSimulationList").setItem(q.detail)},onSessionTimeout:function(){try{var q=window.getTopWindow?window.getTopWindow():window;q.document.location.search="?appName="+f}catch(r){if(window.console&&window.console.warn){window.console.warn("Failed to navigate to login page when session timed out",r)}}},activeSimChanged:function(){return p.apply(this,arguments)},licenseDataReady:function(){var q=this;if(this.licenseDataCmn.Performance_Study==="false"){this.DOM(this.$.licenseErrorMessage).removeClass("hidden")}else{if(this.activeitemid){require(["UWA/Drivers/Alone","DS/UIKIT/Spinner"],function(r,s){var t=q.querySelector("#loadingIndicator");if(t){q.spinner=new s({className:"large"}).inject(t);q.spinner.show()}})}}},onSimListReady:function(){var r=this,q=this.querySelector("#simdetail"),s=this.querySelector("#simcontent");if(q&&!s){Polymer.Base.importHref(["../../SMAProcPSUI/ps-simulation-contents/ps-simulation-contents.html"],function(){s=document.createElement("ps-simulation-contents");s.id="simcontent";Polymer.dom(s).classList.add("simcontent");s.eedBaseURL=r.globals.eedBaseURL;s.session=r.session;s.addEventListener("jobstatuschange",b.bind(r));s.addEventListener("jobfinished",b.bind(r));s.addEventListener("attributeschange",a.bind(r));Polymer.dom(q).appendChild(s);if(r.spinner){r.spinner.hide()}var t=r.querySelector("#loadingIndicator");if(t){t.parentNode.removeChild(t)}if(r.activeSim){Polymer.dom(s).classList.add("is-active");setTimeout(function(){s.activesim=r.activeSim},50)}r.$.licenseData.setValue(r.licenseDataCmn)},function(){window.alert("Error loading contents")},true)}},envListReady:function(){this.isOnPremise=false;for(var r=0;r<this.envList.environments.length;r++){if(this.envList.environments[r].id==="OnPremise"){this.isOnPremise=true;break}}var q=this.querySelector("#main");if(q&&q.classList.contains("hidden")){q.classList.remove("hidden")}appData.environments=this.envList.environments},_computeIf:function(q){return(q&&q.Performance_Study==="true")},_computeClass:function(q){if(q==="simList"){return"simList active"}else{return"simList"}},_computeClass2:function(q){if(q==="searchedSim"){return"simList active"}else{return"simList"}}})});
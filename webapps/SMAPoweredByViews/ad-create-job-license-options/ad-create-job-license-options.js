/*!  Copyright 2018 Dassault Systemes. All rights reserved. */
define("DS/SMAPoweredByViews/ad-create-job-license-options/ad-create-job-license-options",["DS/SMAProcSP/PolymerLoader","DS/SMAPoweredByViews/ad-redux-behaviour/ReduxBehaviour","DS/SMAPoweredByState/ad-state-cos/selectors","DS/SMAPoweredByState/ad-state-domain-jobs/actions","DS/SMAPoweredByState/ad-state-domain-jobs/selectors","text!DS/SMAPoweredByViews/ad-create-job-license-options/ad-create-job-license-options.html","i18n!DS/SMAPoweredByViews/assets/nls/ADCreateJobLicenseOptions","DS/SMAPoweredByViews/ad-popover/ad-popover","css!DS/UIKIT/UIKIT.css","css!DS/SMAPoweredByViews/ad-create-job-license-options/slider.css"],function(a,c,b,h,g,f,e){function d(l,j,i){var m=null;if(j&&j.Selectors&&j.Selectors.getUVMEstimates){var k=g.jobExecutionOptions(l,i);if(k){m=j.Selectors.getUVMEstimates({executionOptions:k})}}return m}a.register(f);return window.Polymer({is:"ad-create-job-license-options",properties:{jobId:{type:String,value:null},isCloudEnabled:{type:Boolean,value:null,stateSelector:function(j){var i=null;if(this.handler&&this.handler.Selectors&&this.handler.Selectors.isCloudEnabled){i=this.handler.Selectors.isCloudEnabled(j)}return i}},licenseType:{type:String,value:null,stateSelector:function(i){return g.jobLicenseType(i,this.jobId)}},drmMode:{type:String,value:null,stateSelector:function(i){return g.jobDRMMode(i,this.jobId)}},features:{type:String,value:null,stateSelector:function(i){return g.jobFeatures(i,this.jobId)}},modelSize:{type:String,value:null,stateSelector:function(i){return g.jobModelSize(i,this.jobId)}},performance:{type:String,value:null,stateSelector:function(i){return g.jobPerformance(i,this.jobId)}},softwareRate:{type:String,value:null,stateSelector:function(i){var j=d(i,this.handler,this.jobId);return j?j.softwareRate:null}},hardwareRate:{type:String,value:null,stateSelector:function(i){var j=d(i,this.handler,this.jobId);return j?j.hardwareRate:null}},cpus:{type:String,value:null,stateSelector:function(i){var j=d(i,this.handler,this.jobId);return j?j.cpus:null}},cpuLimit:{type:String,value:null,stateSelector:function(k){var i=null;if(this.handler&&this.handler.Selectors&&this.handler.Selectors.getCPULimit){var j=g.jobExecutionOptions(k,this.jobId);if(j){i=this.handler.Selectors.getCPULimit(k,{executionOptions:j})}}return i}},modelSizeLimit:{type:String,value:null,stateSelector:function(k){var i=null;if(this.handler&&this.handler.Selectors&&this.handler.Selectors.getSVMLimit){var j=g.jobExecutionOptions(k,this.jobId);if(j){i=this.handler.Selectors.getSVMLimit(k,{executionOptions:j})}}return i}}},ready:function(){this.NLS=e},_isUVMSectionHidden:function(i){var j=i===g.LicenseType.CREDITS||i===g.LicenseType.TOKENS;return !j},_isCloudCompute:function(i){return i===b.DRMMode.CLOUD},_isModelSizeOptionDisabled:function(i,j){return i&&parseInt(j)>parseInt(i)},_getSoftwareRateString:function(j,i){var k=(j===g.LicenseType.CREDITS)?e.Credits+" / "+e.Hour:e.Tokens;return i!==null&&k?i+" "+k:""},_getHardwareRateString:function(j){var i=e.Credits+" / "+e.Hour;return j!==null?j+" "+i:""},_getCpuLimitString:function(i){return i?e.get("ComputeCapacity",{context:i}):""},_onLicenseTypeChanged:function(i){i.stopPropagation();i.cancelBubble=true;this.store.dispatch(h.setJobExecutionSXALicenseType(this.jobId,i.target.value))},_onFeaturesChanged:function(i){i.stopPropagation();i.cancelBubble=true;this.store.dispatch(h.setJobExecutionSXALicenseFeatures(this.jobId,i.target.value))},_onModelSizeChanged:function(i){i.stopPropagation();i.cancelBubble=true;this.store.dispatch(h.setJobExecutionSXALicenseModelSize(this.jobId,i.target.value))},_onPerformanceChanged:function(i){i.stopPropagation();i.cancelBubble=true;this.store.dispatch(h.setJobExecutionSXALicensePerformance(this.jobId,i.target.value))},behaviors:[c]})});
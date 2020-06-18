define('DS/CfgEffectivityCommands/commands/CfgEvolutionCmd',
   [
	'DS/CfgEffectivityCommands/commands/CfgEffCmd',
	'DS/CfgBaseUX/scripts/CfgController',
    'DS/CfgBaseUX/scripts/CfgUtility',
	'DS/CfgBaseUX/scripts/CfgDialog',
	'DS/CfgEvolutionUX/CfgEditEvolutionLayout',
    'DS/CfgEvolutionUX/CfgEvolutionLayoutFactory',
	'DS/CfgAuthoringContextUX/scripts/CfgAuthoringContext',
	'i18n!DS/CfgEvolutionUX/assets/nls/CfgEvolutionUX',
    'text!DS/CfgBaseUX/assets/CfgUXEnvVariables.json'
   ], function (CfgEffCmd, CfgController, CfgUtility, CfgDialog, CfgEditEvolutionLayout, CfgEvolutionLayoutFactory, CfgAuthoringContext, cfgEvoNLS, CfgUXEnvVariables_text) {

       'use strict';

       var CfgEvolutionCmd = CfgEffCmd.extend({
           modelData: null,
           enabledCritData: null,
           cfgEvoDialog: null,

           destroy: function () {
               if (this.cfgEvoDialog)
                   this.cfgEvoDialog.closeDialog();
           },
           execute: function () {

               var that = this;
               that.disable();
               this.CfgUXEnvVariables = JSON.parse(CfgUXEnvVariables_text);
               var data = that.getData();

               if (data.selectedNodes && data.selectedNodes.length > 0) {

                   if (data.selectedNodes[0].isRoot == true) {
                       console.log('Cannot Open Edit Evolution Dialog for a root node');
                       that.enable();
                   }
                   else {

                       var createDialog_callback = function () {

                           var returnedPromise = new Promise(function (resolve, reject) {
                               var failure = function (response) {
                                   that.enable();
                                   reject(response);
                               };

                               var url = '/resources/modeler/configuration/navigationServices/getConfiguredObjectInfo/pid:' + data.selectedNodes[0].parentID + '?cfgCtxt=1&enabledCriteria=1';

                               var successfulModellist = function (response) {
                                   if (response == null || response == 'undefined') {
                                       CfgEvolutionCmd.modelData = null;
                                   }
                                   else if (response.version == "1.0") {
                                       CfgEvolutionCmd.modelData = response.Contexts.Content.results;
                                       CfgEvolutionCmd.enabledCritData = null;
                                   }
                                   else if (response.version == "1.1") {
                                       CfgEvolutionCmd.modelData = response.contexts.content.results;
                                       CfgEvolutionCmd.enabledCritData = response.enabledCriterias;
                                   }

                                   if (CfgEvolutionCmd.modelData == null || CfgEvolutionCmd.modelData.length == 0) {
                                       that.enable();
                                       CfgUtility.showwarning(cfgEvoNLS.No_Model_Title + ' ' + cfgEvoNLS.No_Model_Msg, 'error');
                                       return;
                                   }

                                   var modelCriteria = response.enabledCriterias;
                                   var criteriaCount = 0;
                                   for (var key in modelCriteria) {
                                       if (modelCriteria.hasOwnProperty(key)) {
                                           if (modelCriteria[key] == 'true' && key != 'feature') criteriaCount++;
                                       }
                                   }

                                   if (criteriaCount == 0) {
                                       that.enable();
                                       CfgUtility.showwarning(cfgEvoNLS.No_Evolution_Crit_Error, 'error');
                                       return;
                                   }

                                   resolve("Configured Objects/models loaded : " + CfgEvolutionCmd.modelData);
                               };

                               CfgEvolutionCmd.modelData = null;
                               CfgEvolutionCmd.enabledCritData = null;
                               CfgUtility.makeWSCall(url, 'GET', 'enovia', 'application/ds-json', '', successfulModellist, failure, true);
                           });

                           returnedPromise.then(function (response) {
                               console.log(response);
                               var CloseHandlar = function () {
                                   that.cfgEvoDialog.closeDialog();
                                   if (that.options.postCloseHandler)
                                       that.options.postCloseHandler();
                               };

                               var buttonArray = null;

                               var options = {
                                   'postCloseHandler': that.options.postCloseHandler,
                                   'tenant': enoviaServerFilterWidget.tenant,
                                   'environment': 'Dashboard',
                                   'parent': null,
                                   'parentElement': null,
                                   'objectid': data.selectedNodes[0].id,
                                   'mode': "EditEvolution",
                                   'iXml': null,
                                   'modelList': CfgEvolutionCmd.modelData,
                                   "enabledCritData": CfgEvolutionCmd.enabledCritData,
                                   'selectedNodes': data.padNodes,
                                   'PADContext': data.PADContext,
                                   "Access": { 'SetEvolutionEffectvity': 'true' },
                                   'dialogue': {
                                       'header': cfgEvoNLS.Edit_Evo_Title + data.selectedNodes[0].alias,
                                       'buttonArray': buttonArray,
                                       'target': widget.body,
                                       'ca': { 'headers': [] },
                                       'hasEffectivity': null,
                                       'effExpressionXml': null,
                                       'object': null
                                   }
                               };

                               var cfg = CfgAuthoringContext.get();
                               if (cfg && cfg.AuthoringContextHeader) {
                                   for (var key in cfg.AuthoringContextHeader) {
                                       options.dialogue.ca.headers.push({ 'key': key, 'value': cfg.AuthoringContextHeader[key] });
                                   }
                               }

                               CfgUtility.isChangeControlled(data.selectedNodes[0].parentID).then(function (change_response) {
                                   var hdr = "";
                                   for (var i = 0; i < options.dialogue.ca.headers.length; i++) {
                                       hdr = options.dialogue.ca.headers[i];
                                   }

                                   if (change_response == "any" || (hdr.key != undefined && hdr.key === 'DS-Change-Authoring-Context')) {
                                       that.enable();
                                       CfgUtility.showwarning(cfgEvoNLS.No_Model_Title + ' ' + cfgEvoNLS.Work_Under_Eff_Error, 'error');
                                       return;
                                   } else {

                                       var returnedPromise = new Promise(function (resolve, reject) {
                                           var failure = function (response) { that.enable(); console.log(response); reject(response); };
                                           var success = function (response) {

                                               var hasEffectivity = null;
                                               var effExpressionXml = null;

                                               var instanceID = options.objectid;
                                               var instObj = response.expressions;
                                               if (instObj[instanceID].status === 'ERROR' || instObj[instanceID].hasEffectivity === 'ERROR') {
                                                   that.enable();
                                                   console.log('getMultipleFilterableObjectInfo Service Failure');
                                                   CfgUtility.showwarning(cfgEvoNLS.Save_Fail_Evo_Effectivity, 'error');
                                                   return;
                                               }
                                               if (instObj[instanceID].hasEffectivity === 'NO') {
                                                   console.log('Has No Effectivity');
                                                   hasEffectivity = false;
                                               }
                                               else {
                                                   if (instObj[instanceID].content.ConfigChange != null && instObj[instanceID].content.ConfigChange != 'undefined') {
                                                       that.enable();
                                                       console.log('Non Decoupled/Legacy Effectivity');
                                                       CfgUtility.showwarning(cfgEvoNLS.No_Model_Title + ' ' + cfgEvoNLS.Legacy_Eff_Error, 'error');
                                                       return;
                                                   }
                                                   else if (instObj[instanceID].content.Evolution == null || instObj[instanceID].content.Evolution.Current == null || instObj[instanceID].content.Evolution.Current == '' || instObj[instanceID].content.Evolution.Current == 'undefined') {
                                                       console.log("Variant Effectivity might be set hence Evolution would be null or undefined");
                                                       hasEffectivity = false;
                                                   }
                                                   else if (instObj[instanceID].content.Evolution.Current.indexOf('OperationHandler') >= 0) {
                                                       that.enable();
                                                       console.log('Instance under Change Control');
                                                       CfgUtility.showwarning(cfgEvoNLS.No_Model_Title + ' ' + cfgEvoNLS.Work_Under_Eff_Error, 'error');
                                                       return;
                                                   }
                                                   else {
                                                       console.log('Decoupled Evolution Effectivity');
                                                       hasEffectivity = true;
                                                       effExpressionXml = instObj[instanceID].content.Evolution.Current;
                                                   }
                                               }

                                               options.dialogue.hasEffectivity = hasEffectivity;
                                               options.dialogue.effExpressionXml = effExpressionXml;

                                               resolve("Effectivity Loaded for :" + instanceID);
                                           };
                                           var jsonData = {
                                               "version": "1.0",
                                               "output": {
                                                   "targetFormat": "XML",
                                                   "withDescription": "YES",
                                                   "view": "Current",
                                                   "domains": "Evolution"
                                               },
                                               "pidList": "[" + options.objectid + "]"
                                           };
                                           var url = "/resources/modeler/configuration/navigationServices/getMultipleFilterableObjectInfo";
                                           var postdata = JSON.stringify(jsonData);
                                           CfgUtility.makeWSCall(url, 'POST', 'enovia', 'application/json', postdata, success, failure, true);
                                       });
                                       returnedPromise.then(function (response) {

                                           if (that.CfgUXEnvVariables.CFG_EditEvolutionEff_WebInWin == false) {
                                               if (options.modelList.length > 1) {
                                                   that.cfgEvoDialog = new CfgDialog(options);
                                                   options.parent = that.cfgEvoDialog.container;
                                                   options.parentElement = that.cfgEvoDialog.container;
                                                   options.dialogue.object = that.cfgEvoDialog;
                                                   that.cfgEvoDialog.render();
                                                   document.getElementsByClassName('CfgEditEvolutionDialog')[0].setAttribute('style', document.getElementsByClassName('CfgEditEvolutionDialog')[0].getAttribute('style') + 'min-height:210px !important;min-width:310px !important;');
                                               }
                                               else {
                                                   options.parent = widget.body;
                                               }
                                               CfgEvolutionLayoutFactory.create(options);
                                           }
                                           else {
                                               //if(options.modelList.length > 1){
                                               that.cfgEvoDialog = new CfgDialog(options);
                                               options.parent = that.cfgEvoDialog.container;
                                               options.parentElement = that.cfgEvoDialog.container;
                                               options.dialogue.object = that.cfgEvoDialog;
                                               that.cfgEvoDialog.render();
                                               document.getElementsByClassName('CfgEditEvolutionDialog')[0].setAttribute('style', document.getElementsByClassName('CfgEditEvolutionDialog')[0].getAttribute('style') + 'min-height:210px !important;min-width:310px !important;');
                                               //}
                                               //else{
                                               //	options.parent = widget.body;
                                               //}
                                               CfgEditEvolutionLayout.create(options);
                                           }
                                           that.enable();

                                       }, function (error_response) {
                                           that.enable();
                                           CfgUtility.showwarning(cfgEvoNLS.Save_Fail_Evo_Effectivity, 'error');
                                       });
                                   }
                               }, function (error_response) {
                                   that.enable();
                                   console.log("change controlled WS failed");
                               });																												

                           }, function (error_response) {
                               that.enable();
                               CfgUtility.showwarning(cfgEvoNLS.Save_Fail_Evo_Effectivity, 'error');
                           });
                       }

                       if (widget)
                           enoviaServerFilterWidget.tenant = widget.getValue('x3dPlatformId');
                       else
                           enoviaServerFilterWidget.tenant = 'OnPremise';

                       CfgUtility.populate3DSpaceURL().then(function () {
                           CfgUtility.populateSecurityContext().then(function () {
                               createDialog_callback();
                           });
                       });
                   }
               }
           }
       });

       return CfgEvolutionCmd;
   });


define('DS/CfgEffectivityCommands/commands/CfgVariantEffectivityCmd',
	[
		'DS/CfgEffectivityCommands/commands/CfgEffCmd',
		'DS/CfgBaseUX/scripts/CfgController',
		'DS/CfgBaseUX/scripts/CfgUtility',
		'DS/CfgAuthoringContextUX/scripts/CfgAuthoringContext',
		'i18n!DS/CfgVariantEffectivityDialog/assets/nls/CfgVariantEffectivityDialog',
        'i18n!DS/CfgMassVariantEffectivityEditor/assets/nls/CfgMassVariantEffectivityEditor'
	], function (CfgEffCmd, CfgController, CfgUtility, CfgAuthoringContext, AppNLS, CfgMassVariantEffectivityEditorNLS) {

	    'use strict';

	    var CfgVariantCmd = CfgEffCmd.extend({

	        destroy: function () {

	        },
	        execute: function () {
	            var self = this;
	            var data = this.getData();

	            if (data.selectedNodes && data.selectedNodes.length == 1) {
	                this.executeEditVariantEffectivity();
	            }
	            else {
	                //initialise controller object 
	                CfgController.init();
                    //take latest tenant for web service calls.
	                if (widget)
	                    enoviaServerFilterWidget.tenant = widget.getValue('x3dPlatformId');
	                else
	                    enoviaServerFilterWidget.tenant = 'OnPremise';

	                this.executeEditMassVariantEffectivity();
	            }
	        },
	        //method getListOfTypes
	        //list out all the unique types selected 
	        //output types object with keys as a types.
	        getListOfTypes: function () {
	            var types = {};
	            var data = this.getData();
	            if (data.selectedNodes && data.selectedNodes.length > 0) {
	                for (var count = 0; count < data.selectedNodes.length; count++) {
	                    types[data.selectedNodes[count].VPMRef] = "";
	                }
	            }
	            return types;
	        },
			
			processVariantEffectivityAndLaunchDialog: function(eff_response){
				var that = this;
				var hasEffectivity = null;
	            var effExpressionXml = '';

	            var instanceID = that.varOptions.instanceID;
	            var instObj = eff_response.expressions;
	        
	            if (instObj[instanceID].hasEffectivity === 'NO') {
	               console.log('Has No Effectivity');
	               hasEffectivity = false;
	            }
	            else {
					if (instObj[instanceID].content.ConfigChange != null && instObj[instanceID].content.ConfigChange != 'undefined') {
	                    that.enable();
	                    console.log('Non Decoupled/Legacy Effectivity');
	                    CfgUtility.showwarning(AppNLS.Legacy_Eff_Error, 'error');
	                    return;
	                }
	                else if (instObj[instanceID].content.Variant == null || instObj[instanceID].content.Variant == '' || instObj[instanceID].content.Variant == 'undefined') {
	                    console.log("Evolution Effectivity might be set hence Variant would be null or undefined");
	                    hasEffectivity = false;
	                }
	                else {
	                    console.log('Decoupled Variant Effectivity');
	                    hasEffectivity = true;
	                    effExpressionXml = instObj[instanceID].content.Variant;
	                }            	                	                
	            }

                that.varOptions.varEffXML = effExpressionXml;
	            that.varOptions.hasEffectivity = hasEffectivity;

	            console.log("Effectivity Loaded for :" + instanceID);                               

	            require(['DS/CfgVariantEffectivityDialog/scripts/CfgVariantInitDialog'], function (CfgVariantInitDialog) {
					CfgVariantInitDialog.init(that.varOptions);
                    document.getElementsByClassName('CfgDashboardDialog')[0].setAttribute('style', document.getElementsByClassName('CfgDashboardDialog')[0].getAttribute('style') + 'min-height:480px !important;min-width:320px !important;');
				});

	            that.enable();				
			},
			
	        executeEditVariantEffectivity: function () {
	            var that = this;
	            that.disable();

	            var data = that.getData();

	            if (data.selectedNodes && data.selectedNodes.length > 0) {

	                if (data.selectedNodes[0].isRoot == true) {
	                    console.log('Cannot Open Edit Variant Dialog for a root node');
	                    that.enable();
	                }
	                else {

	                    var createDialog_callback = function () {
	                        that.varOptions = {
	                            'postOKHandler': that.options.postOKHandler,
	                            'contextData': null,
	                            'hasEffectivity': null,
	                            'varEffXML': '',
	                            'parent': null,
	                            'parentElement': null,
	                            'parentID': data.selectedNodes[0].parentID,
	                            'instanceID': data.selectedNodes[0].id,
	                            'selectedNodes': data.padNodes,
	                            'PADContext': data.PADContext,
	                            'mode': "Dashboard",
	                            'ca': { 'headers': [] },
	                            'dialogue': {
	                                'header': AppNLS.Dialog_Header + " - " + data.selectedNodes[0].alias,
	                                'target': widget.body,
	                                'buttonArray': null
	                            }
	                        };

	                        var GCOI_Options = {
	                            "parentID": that.varOptions.parentID
	                        };

	                        that.varOptions.contextData = null;
	                        var getConfiguredObjectInfoPromise = CfgUtility.getConfiguredObjectInfo(GCOI_Options);

	                        getConfiguredObjectInfoPromise.then(function (response) {

	                            if (response == null || response == 'undefined') {
	                                that.varOptions.contextData = null;
	                            }
	                            else if (response.version == "1.0") {
	                                that.varOptions.contextData = response.Contexts.Content.results;
	                            }
	                            else if (response.version == "1.1") {
	                                that.varOptions.contextData = response.contexts.content.results;
	                            }

	                            if (that.varOptions.contextData == null || that.varOptions.contextData == 0) {
	                                that.enable();
	                                CfgUtility.showwarning(AppNLS.No_Model_Error, 'error');
	                                return;
	                            }
	                            if (response.version == "1.1" && response.enabledCriterias.feature == 'false') {
	                                that.enable();
	                                CfgUtility.showwarning(AppNLS.No_Variant_Crit_Error, 'error');
	                                return;
	                            }

	                            // Added for uses of CfgUtility.getDisplayExpressionUsingXSLT during displayName in Edit Variant/Option operation
	                            CfgUtility.populateDisplayExpressionXSLT();

	                            console.log("Configured Objects/models loaded");

	                            that.varOptions.evoEffXML = '';
	                            that.varOptions.varEffXML = '';
	                            that.varOptions.hasEffectivity = null;	 // hasEffectivity = has Variant Effectivity ?

	                            var GMFOI_Options = {
	                                "version": "1.0",
	                                "targetFormat": "XML",
	                                "withDescription": "YES",
	                                "view": "All",
	                                "domains": "All",
	                                "pidList": "[" + that.varOptions.instanceID + "]"
	                            };
	                            var getMultipleFilterableObjectInfoPromise = CfgUtility.getMultipleFilterableObjectInfo(GMFOI_Options);

	                            getMultipleFilterableObjectInfoPromise.then(function (eff_response) {
						
									if (eff_response.expressions[that.varOptions.instanceID].status === 'ERROR' || eff_response.expressions[that.varOptions.instanceID].hasEffectivity === 'ERROR') {
										that.enable();
										console.log('getMultipleFilterableObjectInfo Service Failure');
										CfgUtility.showwarning(AppNLS.Service_Fail, 'error');
										return;
									}
									
	                                //check whether change controlled 	
	                                var isChangePromise = CfgUtility.isChangeControlled(that.varOptions.parentID);

	                                isChangePromise.then(function (change_response) {
										
										var cfg_auth_ctx = CfgAuthoringContext.get();
	                                    if (cfg_auth_ctx && cfg_auth_ctx.AuthoringContextHeader) {
	                                        for (var key in cfg_auth_ctx.AuthoringContextHeader) {
	                                            that.varOptions.ca.headers.push({ 'key': key, 'value': cfg_auth_ctx.AuthoringContextHeader[key] });
	                                        }
											that.varOptions.cfg_auth_ctx = cfg_auth_ctx;
	                                    }
										
										if(change_response == 'any' || (that.varOptions.ca.headers.length > 0)){
											if(that.varOptions.ca.headers.length > 0){
												 
												if(that.varOptions.ca.headers[0].key == 'DS-Change-Authoring-Context'){
													//Applicability
													var applicabilityPromise = new Promise(function (resolve, reject) {
														var failure = function (tmp_response) { reject(tmp_response); };
														var success = function(tmp_response){ resolve(tmp_response);}; 														
														var url = '/resources/modeler/change/changeaction/pid:'+that.varOptions.cfg_auth_ctx.change.id+'?applicability=1';
														var inputJsonTxt ="";
														
														CfgUtility.makeWSCall(url, 'GET', 'enovia', 'application/json', inputJsonTxt, success, failure, true);
													});
													applicabilityPromise.then(function (applicability_response){
														that.varOptions.evoEffXML = applicability_response.changeaction.applicability.expressionXML;												
														that.processVariantEffectivityAndLaunchDialog(eff_response);
													},
													function(error_response){that.enable(); CfgUtility.showwarning(AppNLS.Service_Fail, 'error');});
													
													
												}
												else if(that.varOptions.ca.headers[0].key == 'DS-Configuration-Authoring-Context'){
													//Session Effectivity
													that.varOptions.evoEffXML = that.varOptions.cfg_auth_ctx.evolution.expression;													
													that.processVariantEffectivityAndLaunchDialog(eff_response);
												}										
											}
											else{											
												// ideally Edit Variant should not launch. need to confirm 
												that.varOptions.evoEffXML = "";											
												that.processVariantEffectivityAndLaunchDialog(eff_response);
											}
																												
										} 
										else if (change_response == 'none'){	
											// refer Current effectivity set on instance
											if(eff_response.expressions[that.varOptions.instanceID].hasEffectivity == 'YES' && eff_response.expressions[that.varOptions.instanceID].content.Evolution)
												that.varOptions.evoEffXML = eff_response.expressions[that.varOptions.instanceID].content.Evolution.Current;
											that.processVariantEffectivityAndLaunchDialog(eff_response);											
										}

	                                },
                                    function (error_response) { that.enable(); CfgUtility.showwarning(AppNLS.Service_Fail, 'error'); });

	                            }, function (error_response) { that.enable(); CfgUtility.showwarning(AppNLS.Service_Fail, 'error'); });

	                        }, function (error_response) { that.enable(); CfgUtility.showwarning(AppNLS.Service_Fail, 'error'); });

	                    }
						
						if (widget)
                           enoviaServerFilterWidget.tenant = widget.getValue('x3dPlatformId');
                        else
                           enoviaServerFilterWidget.tenant = 'OnPremise';

	                    CfgUtility.populate3DSpaceURL().then(
                            function () {
                                CfgUtility.populateSecurityContext().then(
                                 function () {
                                     createDialog_callback();
                                 }
                                );
                            }
                        );



	                }
	            }
	        }
            , executeEditMassVariantEffectivity: function () {

                //keep command disable after start of execution
                this.disable();
                //get parent of all selected instances
                var oParentId = this.getCommonParentId();

                //get all types of selected instances list
                var types = this.getListOfTypes();
                var typesArray = [];
                for (var key in types) {
                    if (types.hasOwnProperty(key)) {
                        typesArray.push(key);
                    }
                }
                var me = this;
                var data = this.getData();
				
				if (widget)
                    enoviaServerFilterWidget.tenant = widget.getValue('x3dPlatformId');
                else
                    enoviaServerFilterWidget.tenant = 'OnPremise';
				
                //populate 3dspace url for calling web services
                CfgUtility.populate3DSpaceURL().then(
                function () {
                    //get security context for user 
                    CfgUtility.populateSecurityContext().then(
                        function () {
                            CfgUtility.checkProperties(typesArray).then(function (iResponse) {
                                var selectedInstances = me.processSelectedNodes(iResponse);
                                if (selectedInstances.length === 0) {
                                    CfgUtility.showwarning(CfgMassVariantEffectivityEditorNLS.CFG_Invalid_All_Objects, 'error');
                                    return;
                                }

                                if (selectedInstances.length != data.selectedNodes.length) {
                                    CfgUtility.showwarning(CfgMassVariantEffectivityEditorNLS.CFG_Invalid_Objects, 'info');
                                }

                                CfgUtility.populateDisplayExpressionXSLT();
                                var options = { "parentID": oParentId };
                                    CfgUtility.getConfiguredObjectInfo(options).then(function (iResponse) {
                                        //web service output for error is switchng json format randomly in between index [0] and [1].
                                        if ((iResponse.contexts.content.results[0] != undefined && iResponse.contexts.content.results[0].notification != undefined && iResponse.contexts.content.results[0].notification.code == "unaccessible" && iResponse.contexts.content.results[0].notification.type == "ERROR") ||
                                        (iResponse.contexts.content.results[1] != undefined && iResponse.contexts.content.results[1].notification != undefined && iResponse.contexts.content.results[1].notification.code == "unaccessible" && iResponse.contexts.content.results[1].notification.type == "ERROR")) {
                                            CfgUtility.showwarning(CfgMassVariantEffectivityEditorNLS.CFG_Unaccessiblecode_Error, "error");
                                            me.enable();
                                            return;
                                        }
                                        if (iResponse.contexts.content.results.length == 0) {
                                            CfgUtility.showwarning(CfgMassVariantEffectivityEditorNLS.CFG_No_Model_Error, "error");
                                            me.enable();
                                            return;
                                        }

                                        if (iResponse.version == "1.1" && iResponse.enabledCriterias.feature == 'false') {
                                            CfgUtility.showwarning(CfgMassVariantEffectivityEditorNLS.CFG_No_Model_attached, "error");
                                            me.enable();
                                            return;
                                        }
                                        if (iResponse.contexts.content.results.length > 1)
                                        {
                                            CfgUtility.showwarning(CfgMassVariantEffectivityEditorNLS.CFG_Multiple_Models_Error, "error");
                                            me.enable();
                                            return;
                                        }

                                        require(['DS/CfgMassVariantEffectivityEditor/scripts/CfgMassVariantEffectivityEditorLayout'], function (CfgMassVariantEffectivityEditorLayout) {
                                            var options = {
                                                attachedModels: iResponse,
                                                selectedInstances: selectedInstances,
                                                PADContext: data.PADContext
                                            }
                                            CfgMassVariantEffectivityEditorLayout.render(options);
                                            me.enable();
                                        });
                                    }
                                , function () {
                                    CfgUtility.showwarning(CfgMassVariantEffectivityEditorNLS.CFG_Attach_Model_Fail, "error");
                                });
                            }, function () {
                                CfgUtility.showwarning(CfgMassVariantEffectivityEditorNLS.CFG_Authoring_context_Fail, "error");
                            });
                        });
                });
            },
	        processSelectedNodes: function (iIsFilterablesInformation) {
	            var data = this.getData();
	            var instances = [];
	            if (data.selectedNodes && data.selectedNodes.length > 0) {
	                for (var count = 0; count < data.selectedNodes.length; count++) {
	                    var instance = {};
	                    instance.instanceId = data.selectedNodes[count].id;
	                    instance.name = data.selectedNodes[count].alias;
	                    if (iIsFilterablesInformation[data.selectedNodes[count].VPMRef].filterable == "YES" || iIsFilterablesInformation[data.selectedNodes[count].VPMRef].configurable == "YES")
	                        instances.push(instance);
	                }
	                return instances;
	            }
	        },
	        _onResize: function () {
	            var data = this.getData();
	            if (this.CfgUXEnvVariables.isMassVariantEnabled === true && data.selectedNodes.length != 0 && data.selectedNodes.length != 1) {
	                this._checkSelection();
	                return;
	            }
	            this._setStateCmd();
	        },
	        _checkSelection: function () {
	            //-- Init the selection
	            this._SelectedID = '';
	            var data = this.getData();
	            if (this.CfgUXEnvVariables.isMassVariantEnabled === true && data.selectedNodes.length != 0 && data.selectedNodes.length != 1) {
	                this._SelectedID = data.selectedNodes[0].id || '';
	                this.isRoot = data.selectedNodes[0].isRoot;
	                this._setStateCmd();
	                if (this.isRootSelected() == true) { this.disable(); return; }
	                if (this.areInstancesFromSameLevel() == false) { this.disable(); return; }
	                if (this.isSelectionExceedUpperLimit() == false) { this.disable(); return; }

	                //check for screen size less than 768px
	                //Mass variant edit command will be disabled when window screen is less than 768px 
	              //  var mqMobile = window.matchMedia("(max-width: 768px)");
	               // if (mqMobile.matches) { this.disable(); return; }

	                return;
	            }
	            if (data.selectedNodes.length === 1) {
	                this._SelectedID = data.selectedNodes[0].id || '';
	                this.isRoot = data.selectedNodes[0].isRoot;
	            }
	            //-- State of the command
	            this._setStateCmd();

	        },
	        //check if all selected instances are from same level.//parent id of such instances should be same.
	        areInstancesFromSameLevel: function () {

	            var data = this.getData();
	            if (data.selectedNodes && data.selectedNodes.length > 0) {
	                var parentId = data.selectedNodes[0].parentID;
	                for (var count = 0; count < data.selectedNodes.length; count++) {
	                    if (parentId == data.selectedNodes[count].parentID) continue;
	                    else { parentId = ""; break; }
	                }
	                if (parentId == "") return false;
	                return true;
	            }
	        },
	        //get parent id of selected instances.
	        //return parent id
	        getCommonParentId: function () {
	            var data = this.getData();
	            if (data.selectedNodes && data.selectedNodes.length > 0) {
	                var parentId = data.selectedNodes[0].parentID;
	                for (var count = 0; count < data.selectedNodes.length; count++) {
	                    if (parentId == data.selectedNodes[count].parentID) continue;
	                    else parentId = "";
	                }
	                return parentId;
	            }

	        },
	        //check if root is selected.
	        //return true if root is selected           
	        isRootSelected: function () {
	            var data = this.getData();
	            if (data.selectedNodes && data.selectedNodes.length > 0) {
	                if (data.selectedNodes[0].isRoot == true) return true;
	            }
	        },
	        //check limit for selection of instances.
            //
	        isSelectionExceedUpperLimit: function () {
	            var data = this.getData();
	            if (data.selectedNodes && data.selectedNodes.length > 0) {
	                if (data.selectedNodes.length > 100) return false;
	                else return true;
	            }

	        }


	    });

	    return CfgVariantCmd;
	});



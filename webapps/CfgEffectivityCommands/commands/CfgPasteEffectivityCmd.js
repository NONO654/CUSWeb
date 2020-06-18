
define('DS/CfgEffectivityCommands/commands/CfgPasteEffectivityCmd', ['DS/PADUtils/PADContext', 'DS/CfgBaseUX/scripts/CfgController', 'DS/CfgBaseUX/scripts/CfgUtility',
    'DS/CfgBaseUX/scripts/CfgData', 'i18n!DS/CfgWebAppEffectivityUX/assets/nls/CfgEffectivityNLS', 'DS/CfgAuthoringContextUX/scripts/CfgAuthoringContext',
    'DS/CfgEffectivityCommands/commands/CfgEffCmd', 'DS/CfgWebAppEffectivityUX/scripts/CfgEffectivityUtility'
], function (PADContext, CfgController, CfgUtility, CfgData, EffectivityNLS, CfgAuthoringContext, CfgEffCmd, CfgEffectivityUtility
) {
    'use strict';
    var successfullList = [];
    var instanceList = [];
    var failedList = [];
    var warningList = [];
    var emptyVariantList = [];
    var configChageList = [];
    var availableVariantList = [];
    var availableVarAndEvolutionList = [];
    var featureNotEnabled = 'true';
    var copycount = 0;
    var totalNumberOfSelections = 0;
    var CfgPasteEffectivityCmd = CfgEffCmd.extend({

        /**
         * Override base class CfgEffCmd function for selectedNodes.length >= 1 because Paste Variant Effectivity functionality is supported for multuiple products           
         */
        _checkSelection: function () {

            //-- Init the selection
            var instanceLength;
            this._SelectedID = '';

            var data = this.getData();
            if (data.selectedNodes.length >= 1) {

                this._SelectedID = data.selectedNodes[0].id || '';
                this._SelectedAlias = data.selectedNodes[0].alias || '?';
                this.isRoot = data.selectedNodes[0].isRoot;
            }

            //-- State of the command
            this._setStateCmd();
        },

        /**
        * Set Variant Effectivity for selected multiple products using webservice pasteFilterableObjectInfo            
        */
        _setVariantEffectivity: function (instanceList, productName, variantXML, authHeaders, selectdData) {
            var that = this;
            var wsOptions = null;
            if (authHeaders.length > 0) {
                wsOptions = {
                    operationheader: {
                        key: authHeaders[0].key,
                        value: authHeaders[0].value
                    }
                };
            }
            var exppressionList = [{
                "domain": "Variant",
                "content": variantXML
            }];
            var options = {
                "version": "1.0",
                "domain": "Variant",
                "view": "Current",
                "targetFormat": "TXT",
                "withDescription": "YES",
                "expressionList": exppressionList,
                "instanceIdList": instanceList,
                "wsOptions": wsOptions
            };

            CfgUtility.pasteFilterableObjectInfo(options).then(function (response) {
                var i, selLength = selectdData.selectedNodes.length;
                for (i = 0; i < selLength; i++) {
                    var prodId = selectdData.selectedNodes[i].id;
                    if (configChageList.indexOf(prodId) == -1)
                        successfullList.push(selectdData.selectedNodes[i].alias);
                }
                //PADContext is not available in all scenario. If other context is null then use PADContext.
                if(!that.options.context)
                {
                  PADContext.get().getPADTreeDocument().withTransactionUpdate(function() {
                    that._refreshGridForSetEffectivity(response);
                    that._showMessage();
                  });
                }
                else {
                  that.options.context.withTransactionUpdate( function () { that._refreshGridForSetEffectivity(response); that._showMessage(); });
                }
            }, function (response) {
                failedList.push(productName);
                if (instanceList.length > 1)
                    failedList.push(productName);
                that._showMessage();
            });
        },

        /**
        * For PCS improvement, CfgUtility.refreshEffectvity which calls getMultipleFilterableObjectInfo is avoided for Set Variant Effectivity operation.             
        */
        _refreshGridForSetEffectivity: function (response) {
            //var nodeList = PADContext.get().getPADTreeDocument().getSelectedNodes();
            //PADContext is not available in all scenario. Data is retrieved which was set depending on each context
            var data = CfgData.SelectedDataForPasteOperation;
            var nodeList = data.padNodes;
            for (var counter = 0; counter < nodeList.length; counter++) {
                var instanceId = nodeList[counter].getRelationID();
                if (configChageList.indexOf(instanceId) >= 0)
                    continue;
                var hasEff = EffectivityNLS.CFG_EFFECTIVITY_YES;                
                var varEff = response.expressions[instanceId].content.Variant;               
                varEff = varEff == null || "" ? " " : varEff.replace(/[\r\n]+/g, " ");
                nodeList[counter].updateOptions({ grid: { "Effectivity": hasEff, "VariantEffectivity": varEff } });
            }            
        },

        /**
        * For PCS improvement, CfgUtility.refreshEffectvity which calls getMultipleFilterableObjectInfo is avoided for unset Variant Effectivity operation.             
        */
        _refreshGridForUnsetEffectivity: function () {
            //var nodeList = PADContext.get().getPADTreeDocument().getSelectedNodes();
            //PADContext is not available in all scenario. Data is retrieved which was set depending on each context
            var data = CfgData.SelectedDataForPasteOperation;
            var nodeList = data.padNodes;
            for (var counter = 0; counter < nodeList.length; counter++) {
                var hasEff = " ";                
                var instanceId = nodeList[counter].getRelationID();
                if (availableVariantList.indexOf(instanceId) >= 0)
                    hasEff = EffectivityNLS.CFG_EFFECTIVITY_NO;
                else if (availableVarAndEvolutionList.indexOf(instanceId) >= 0)
                    hasEff = EffectivityNLS.CFG_EFFECTIVITY_YES;

                nodeList[counter].updateOptions({ grid: { "Effectivity": hasEff, "VariantEffectivity": " " } });
            }
        },

        /**
        * Used to check model is attached to parent product. If Model is not attached to parent product then Error message is shown.
        */
        _getConfigurationFeature: function (parentID) {
            var returnedPromise = new Promise(function (resolve, reject) {
                var failure = function (response, error) {
                    CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_Operation_Failed, "error");
                    reject(error.errorMessage);
                };
                var url = '/resources/modeler/configuration/navigationServices/getConfiguredObjectInfo/pid:' + parentID + '?cfgCtxt=1&enabledCriteria=1';
                var successfulModellist = function (response) {
                    if (response.version == "1.1" && response.enabledCriterias.feature == 'false') {
                        if (featureNotEnabled != 'false') featureNotEnabled = response.enabledCriterias.feature;
                    }
                    resolve(response);
                };
                CfgUtility.makeWSCall(url, 'GET', 'enovia', 'application/ds-json', '', successfulModellist, failure, true);
            });
            return returnedPromise;
        },

        /**
        * Used to get Domain details before Paste Variant Effectivity operation. Forbidden types like 3DSpahe object is added to failedList and shown in error message.
        * When empty Effectivity is copied and user tries to Paste on products for which there is No Variant Effectivity then operation is useless message shown.
        * Only Valid products are sent for Paste Variant Effectivity operation. For PCS improvement lightweight _getAvailableDemainDetails is used.
        */
        _getAvailableDemainDetails: function (instanceList) {
            var that = this;
            var returnedPromise = new Promise(function (resolve, reject) {
                var success = function (response) {
                    var data = CfgData.SelectedDataForPasteOperation;
                    var selectednodes = data.padNodes;
                    //var selectednodes = PADContext.get().getPADTreeDocument().getSelectedNodes();
                    var counter, nodeLength = selectednodes.length;
                    for (counter = 0; counter < nodeLength; counter++) {
                        var instanceId = selectednodes[counter].getRelationID();
                        if (response[instanceId].length == 1 && (response[instanceId].toString() == "NoEff" || response[instanceId].toString() == "Evolution"))
                            emptyVariantList.push(instanceId);
                        if (response[instanceId].length == 1 && (response[instanceId].toString() == "ConfigChange" || response[instanceId].toString() == "UnsupportedType"))
                            configChageList.push(instanceId);
                        if (response[instanceId].length == 1 && (response[instanceId].toString() == "Variant" || response[instanceId].toString() == "NoEff"))
                            availableVariantList.push(instanceId);
                        if (response[instanceId].length == 2 || (response[instanceId].length == 1 && response[instanceId].toString() == "Evolution"))
                            availableVarAndEvolutionList.push(instanceId);
                    }
                    resolve(response);
                };
                var failure = function (response) {
                    reject(response);
                };
                var inputjson = ' ';
                inputjson =
                {
                    "version": "1.0",
                    "pidList": instanceList
                };

                var url = '/resources/modeler/configuration/expressionServices/getAvailableDomains';
                var inputjsonTxt = JSON.stringify(inputjson);

                CfgUtility.makeWSCall(url, 'POST', 'enovia', 'json', inputjsonTxt, success, failure, true);
            });
            return returnedPromise;
        },
       

        /**
        * Function used to clear Variant Effectivity for selected products. Here empty Variant Effecitvity needs to be copied and then perform Paster Variant Effectivity operation.
        */
        _unsetVariantEffectivity: function (instanceId, productName, authHeaders, instanceList) {
            var that = this;
            var wsOptions = null;
            if (authHeaders.length > 0) {
                wsOptions = {
                    operationheader: {
                        key: authHeaders[0].key,
                        value: authHeaders[0].value
                    }
                };
            }

            var options = {
                "instanceID": instanceId,
                "domain": "Variant",
                "wsOptions": wsOptions
            };

            CfgUtility.unsetEffectivity(options).then(function (response) {
                if (response.unset != undefined && response.unset.Variant != undefined && response.unset.Variant.status != undefined && response.unset.Variant.status == "Error") {
                    failedList.push(productName);
                    copycount++;
                    if (copycount == totalNumberOfSelections) {
                        that._showEmptyMessage();
                        copycount = 0;
                    }
                }
                else {
                    successfullList.push(productName);
                    copycount++;
                    if (copycount == totalNumberOfSelections) {
						if(!that.options.context) {							
							PADContext.get().getPADTreeDocument().withTransactionUpdate(function () { that._refreshGridForUnsetEffectivity(); that._showEmptyMessage(); });
							copycount = 0;
						}
						else {
							that.options.context.withTransactionUpdate(function () { that._refreshGridForUnsetEffectivity(); that._showEmptyMessage(); });
							copycount = 0;
						}
                    }
                }
            }, function (response) {
                failedList.push(productName);
                copycount++;
                if (copycount == totalNumberOfSelections) {
                    that._showEmptyMessage();
                    copycount = 0;
                }
            });
        },

        /**
        * Function used show error / successful messages after Paste Variant Effectivity operation.
        */
        _showMessage: function () {
            if (successfullList.length == 1 && failedList.length == 1) {
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_Successful + " " + successfullList.toString(), "success");
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_Failed + " " + failedList.toString(), "error");
            }
            else if (successfullList.length == 0 && failedList.length == 1) {
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_Failed + " " + failedList.toString(), "error");
            }
            else if (successfullList.length > 1 && failedList.length == 0) {
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_AllSuccessful, "success");
            }
            else if (successfullList.length > 1 && failedList.length == 1) {
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_PartialSuccessful, "success");
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_Failed + " " + failedList.toString(), "error");
            }
            else if (successfullList.length > 1 && failedList.length > 1) {
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_PartialSuccessful, "success");
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_Failed + " " + failedList.toString(), "error");
            }
            else if (successfullList.length == 1 && failedList.length > 1) {
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_Successful + " " + successfullList.toString(), "success");
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_Failed + " " + failedList.toString(), "error");
            }
            else if (successfullList.length == 1 && failedList.length == 0) {
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_Successful + " " + successfullList.toString(), "success");
            }
            else if (successfullList.length == 0 && failedList.length > 1) {
                CfgUtility.showwarning(EffectivityNLS.CFG_Paste_Effectivity_AllFailed, "error");
            }
        },

        /**
         * Function used show error / successful messages if Variant Effectivity for source product is Empty during Copy Variant Effectivity operation.
         */
        _showEmptyMessage: function () {
            if (successfullList.length > 1 && failedList.length == 0 && warningList.length == 0) {
                CfgUtility.showwarning(EffectivityNLS.CFG_Empty_Effectivity_AllSuccessful, "success");
                return;
            }
            else if (failedList.length > 1 && successfullList.length == 0 && warningList.length == 0) {
                CfgUtility.showwarning(EffectivityNLS.CFG_Empty_Effectivity_AllFailed, "error");
                return;
            }

            if (failedList.length != 0)
                CfgUtility.showwarning(EffectivityNLS.CFG_Empty_Effectivity_Failed + " " + failedList.toString(), "error");
            if (successfullList.length != 0)
                CfgUtility.showwarning(EffectivityNLS.CFG_Empty_Effectivity_Successful + " " + successfullList.toString(), "success");
            if (warningList.length != 0)
                CfgUtility.showwarning(EffectivityNLS.CFG_Empty_Effectivity_Warning + " " + warningList.toString(), "info");
        },

        /**
         * When user clicks on Action bar Paste Variant Effectivity command as well as Paste Variant Effectivity contextual menu then execute is called.  
         * Updated value for allowedLimitNo = 50 for 2018x FD08 function FUN085315.
         */
        execute: function () {
            featureNotEnabled = 'true';
            var that = this;
            that.disable();
            var data = that.getData();
            var allowedLimitNo = 50;
            console.log(data);
            if (data.selectedNodes && data.selectedNodes.length > 0) {
                if (data.selectedNodes.length > allowedLimitNo) {
                    var numberoflimitMessage = EffectivityNLS.CFG_LimitNo_Paste_Effectivity.split('5').join(allowedLimitNo);
                    CfgUtility.showwarning(numberoflimitMessage, "error");
                }
                else {
                    //PADContext is not available in all scenario. Data is kept which can be set depending on each context
                    CfgData.SelectedDataForPasteOperation = data;
                    var isVariantEffectivityAvailable = CfgData.isVariantEffAvailable;
                    var authHeaders = [];
                    var cfg = CfgAuthoringContext.get();
                    if (cfg && cfg.AuthoringContextHeader) {
                        for (var key in cfg.AuthoringContextHeader) {
                            authHeaders.push({ 'key': key, 'value': cfg.AuthoringContextHeader[key] });
                        }
                    }
                    var allPromises = [];
                    var i, length = data.selectedNodes.length;
                    totalNumberOfSelections = length;
                    successfullList = [];
                    failedList = [];
                    warningList = [];
                    emptyVariantList = [];
                    configChageList = [];
                    availableVariantList = [];
                    availableVarAndEvolutionList = [];
                    copycount = 0;

                    instanceList = [];
                    for (i = 0; i < length; i++) {
                        instanceList.push(data.selectedNodes[i].id);
                    }

                    if (isVariantEffectivityAvailable == "NO") {
                        var that = this;
                        //var returnPromise = that._getEmptyVariantEffectvity(instanceList);
                        // For PCS improvement lightweight _getAvailableDemainDetails is used.
                        var returnPromise = that._getAvailableDemainDetails(instanceList);
                        returnPromise.then(function () {
                            for (i = 0; i < length; i++) {
                                if (emptyVariantList.indexOf(data.selectedNodes[i].id) >= 0) {
                                    warningList.push(data.selectedNodes[i].alias);
                                    copycount++;
                                }
                                else if (configChageList.indexOf(data.selectedNodes[i].id) >= 0) {
                                    failedList.push(data.selectedNodes[i].alias);
                                    copycount++;
                                }
                                else {
                                    allPromises.push(that._unsetVariantEffectivity(data.selectedNodes[i].id, data.selectedNodes[i].alias, authHeaders, instanceList));
                                }
                            }
                            if (emptyVariantList.length + failedList.length == length) {
                                that._showEmptyMessage();
                                copycount = 0;
                            }
                        }, function (error) { });
                    }
                    else {
                        var uniqueParentIDs = [];
                        var featurePromices = [];
                        for (i = 0; i < length; i++) {
                            var parentId = data.selectedNodes[i].parentID;
                            if (uniqueParentIDs.indexOf(parentId) == -1)
                                uniqueParentIDs.push(parentId);
                        }

                        for (i = 0; i < uniqueParentIDs.length; i++) {
                            featurePromices.push(that._getConfigurationFeature(uniqueParentIDs[i]));
                        }

                        Promise.all(featurePromices).then(function (resp) {
                            if (featureNotEnabled == 'true') {
                                //var returnPromise = that._getEmptyVariantEffectvity(instanceList);
                                // For PCS improvement lightweight _getAvailableDemainDetails is used.
                                var returnPromise = that._getAvailableDemainDetails(instanceList);
                                returnPromise.then(function () {
                                    for (i = 0; i < length; i++) {
                                        if (configChageList.indexOf(data.selectedNodes[i].id) >= 0) {
                                            failedList.push(data.selectedNodes[i].alias);
                                            copycount++;
                                        }
                                    }
                                    if (failedList.length > 0) {
                                        for (i = 0; i < configChageList.length; i++) {
                                            var instId = configChageList[i];
                                            var index = instanceList.indexOf(instId);
                                            if (index > -1) {
                                                instanceList.splice(index, 1);
                                            }
                                        }
                                    }
                                    if (instanceList.length > 0) {
                                        var variantEffxml = CfgData.VariantEffectivity;
                                        if (variantEffxml != undefined && variantEffxml != null) {
                                            allPromises.push(that._setVariantEffectivity(instanceList, data.selectedNodes[0].alias, variantEffxml, authHeaders, data));
                                        }
                                    }
                                    else {
                                        that._showMessage();
                                        copycount = 0;
                                    }
                                }, function (error) { });
                            }
                            else {
                                failedList.push(data.selectedNodes[0].alias);
                                if (instanceList.length > 1)
                                    failedList.push(data.selectedNodes[0].alias);
                                that._showMessage();
                            }
                        }, function (error) { });
                    }
                }
            }
        }
    });
    return CfgPasteEffectivityCmd;
});


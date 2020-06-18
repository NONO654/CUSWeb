
define('DS/CfgEffectivityCommands/commands/CfgCopyEffectivityCmd', ['DS/CfgBaseUX/scripts/CfgController', 'DS/CfgBaseUX/scripts/CfgUtility', 'DS/CfgBaseUX/scripts/CfgData',
    'i18n!DS/CfgWebAppEffectivityUX/assets/nls/CfgEffectivityNLS', 'DS/CfgEffectivityCommands/commands/CfgEffCmd'
], function (CfgController, CfgUtility, CfgData, EffectivityNLS, CfgEffCmd
) {

    'use strict';

    var CfgCopyEffectivityCmd = CfgEffCmd.extend({

        _onRefresh: function () {
            CfgData.isVariantEffAvailable = ' ';
        },
        /**
         * Don't overload it
         */
        execute: function () {

            var that = this;
            that.disable();
            var data = that.getData();
            console.log('data');
            console.log(data);
            if (data.selectedNodes && data.selectedNodes.length > 0) {
                if (data.selectedNodes[0].isRoot == true) {
                    console.log('Cannot copy Variant Effectivity for a root node');
                    that.enable();
                }
                else {
                    var getEffectivity_callback = function () {                        
                        var returnedPromiseEff = new Promise(function (resolve, reject) {
                            var jsonData = {
                                "version": "1.0",
                                "output": {
                                    "targetFormat": "XML",
                                    "withDescription": "NO",
                                    "view": "Current",
                                    "domains": "ALL"
                                },
                                "pidList": "[" + data.selectedNodes[0].id + "]"
                            };
                            var url = "/resources/modeler/configuration/navigationServices/getMultipleFilterableObjectInfo";
                            var postdata = JSON.stringify(jsonData);
                            var onCompleteCallBack = function (getMultipleFilterableObjectInfo) {
                                resolve(getMultipleFilterableObjectInfo);
                            }
                            CfgUtility.makeWSCall(url, 'POST', 'enovia', 'application/json', postdata, onCompleteCallBack, reject, true);
                        });

                        returnedPromiseEff.then(function (response) {
                            that.enable();
                            for (var key in response.expressions) {
                                if (response.expressions.hasOwnProperty(key)) {
                                    if (response.expressions[key].status == "SUCCESS" && response.expressions[key].hasEffectivity == "YES" && (response.expressions[key].content.Variant != null && response.expressions[key].content.Variant != "")) {
                                        CfgData.isVariantEffAvailable = "YES";
                                        CfgData.VariantEffectivity = response.expressions[key].content.Variant;
                                        CfgUtility.showwarning(EffectivityNLS.CFG_Copy_Effectivity_Successful + " " + data.selectedNodes[0].alias, "success");
                                    }
                                    else if ((response.expressions[key].status == "SUCCESS" && response.expressions[key].hasEffectivity == "NO") || (response.expressions[key].status == "SUCCESS" && response.expressions[key].hasEffectivity == "YES" && (response.expressions[key].content.Evolution != null && response.expressions[key].content.Evolution != ""))) {
                                        CfgData.isVariantEffAvailable = 'NO';
                                        CfgUtility.showwarning(EffectivityNLS.CFG_Copy_NoEffectivity, "info");
                                    }
                                    else {
                                        CfgData.isVariantEffAvailable = ' ';                                        
                                        CfgUtility.showwarning(EffectivityNLS.CFG_Copy_Effectivity_Failed + " " + data.selectedNodes[0].alias, "error");
                                    }
                                }
                            }
                        }, function (error) { that.enable(); });
                    }

                    CfgController.init();

                    if (widget.getValue('x3dPlatformId'))
                        enoviaServerFilterWidget.tenant = widget.getValue('x3dPlatformId');
                    else
                        enoviaServerFilterWidget.tenant = 'OnPremise';


                    CfgUtility.populate3DSpaceURL().then(
                    function () {
                        CfgUtility.populateSecurityContext().then(
                         function () {
                             enoviaServerFilterWidget.InstanceId = data.selectedNodes[0].id;
                             getEffectivity_callback();
                         }
                        );
                    }
                    );
                }
            };
        }

    });

    return CfgCopyEffectivityCmd;
});



define('DS/CfgVariantEffectivityDialog/scripts/CfgVariantInitDialog', 
        ['UWA/Core',
        'UWA/Class/View', 
         'UWA/Drivers/Alone',
         'DS/WebappsUtils/WebappsUtils',
         'DS/UIKIT/Input/Button',
         'DS/ENOFloatingPanel/ENOFloatingPanel',
         'DS/PlatformAPI/PlatformAPI','DS/WAFData/WAFData',
         'DS/CfgVariantEffectivityDialog/scripts/CfgVariantDialogSkeleton',
         'DS/CfgVariantEffectivity/scripts/CfgVariantInit',
		 'DS/CfgVariantEffectivity/scripts/CfgVariantExpServices',         
		 'i18n!DS/CfgVariantEffectivityDialog/assets/nls/CfgVariantEffectivityDialog',
         'DS/CfgAuthoringContextUX/scripts/CfgAuthoringContext',
		 'DS/CfgBaseUX/scripts/CfgUtility',
         'css!DS/CfgVariantEffectivityDialog/assets/styles/styles.css'
		  

        ], function(UWA,View,
                    Alone, WebappsUtils, Button, ENOFloatingPanel, PlatformAPI, WAFData, mySkeleton, CfgVariantInit, CfgVariantExpServices, CfgVarEffDialogNLS, CfgAuthoringContext,CfgUtility) {
    'use strict';

        var CfgVariantInitDialog = {};

       CfgVariantInitDialog.init = function(productID,CurrentProductID, CurrentProductLabel){
        var component = null;
                            
     

        var target = UWA.Element('div', {
            'class': 'target-container',
            'id': 'target-container'
            });

        var MySkeleton = new mySkeleton(target,productID);
        console.log('SekeletonCreated');
        
        var okButton = new Button({
                      value: CfgVarEffDialogNLS.Apply,
                      className: 'primary',
                      events: {
                            onClick: function() {                              
                                var XMLExpression = CfgVariantExpServices.GetGlobalXMLExpression();                              
                                console.log('Variant XMLExpression : '+XMLExpression);
                                
                                var onCompleteCallBack = function(e) {
                                    console.log(e);                                    
                                    component.destroy();
									CfgUtility.showwarning(CfgVarEffDialogNLS.Save_Successful_Var_Effectivity, "success");
                                };
                       
                                var onFailureCallBack = function(e, backendresponse, response_hdrs) {                               
                                    console.log(e);                                  
                                    console.log(response_hdrs);
                                    component.destroy();
									CfgUtility.showwarning(CfgVarEffDialogNLS.Save_Fail_Var_Effectivity, "error");
                                };
                       
                                var url = null;
								var inputjson = null;

								if(XMLExpression == ''){
									url = '/resources/modeler/configuration/authoringServices/unsetFilterableObjectInfo';
								
									inputjson =         
									{
										"version": "1.0",
										"pid":CurrentProductID,
										"unset":['Variant'],											
									};								
								}
								else{
									url = '/resources/modeler/configuration/authoringServices/setFilterableObjectInfo?traces=0&perfo=0 HTTP/1.1';
									
									inputjson =         
									{
										"version": "1.0",
										"expression":
										{
											"output": {
												"domains": "Variant",
												"view": "All"
											},
											"contentFormat": "XML",
											"instanceId": CurrentProductID,
											"expressionList": [
												{
													"domain": "Variant",
													"content": XMLExpression
												}
											],
											"dictionary":
											{
												"version": "0.1",
												"idList": [{ "pid": "pid1" }, { "pid": "pid2" }],
												"format": "xml",
												"content": "< dictionary content for the effectivity definitions>"
											}
										}
									};
								}
                                                               
                                var inputjsonTxt = JSON.stringify(inputjson);  
								
								var options = null;                                							
								if (component.ca_headers.length > 0) {
									options = {
										operationheader : {
											key:component.ca_headers[0].key,
											value:component.ca_headers[0].value
										}
									};
								}
								
								CfgUtility.makeWSCall(url, 'POST', 'enovia', 'json', inputjsonTxt, onCompleteCallBack, onFailureCallBack, true,options);	                                
                            }
                      }
                });
                var cancelButton = new Button({
                      value: CfgVarEffDialogNLS.Cancel,
                      events: {
                            onClick: function() {                              
                                component.destroy();
                            }
                      }
                });
        var footerbtn = [okButton, cancelButton];

        component = new ENOFloatingPanel({
                className: 'cfgVariantENOFloatingPanelComponent',
                title: CfgVarEffDialogNLS.Dialog_Header + " - "+CurrentProductLabel,
                body: target,
                overlay: true,
                closable: true,
                animate: true, //
                resizable: true,
                footer: footerbtn,
                events: {
                    onShow: function() {
                        console.log('show panel');
                    },
                    onHide: function() {
                      console.log('hiding panel');
                    }
                }
            });

            component.inject(widget.body);
            component.show();
            component.centerIt();
			
            component.ca_headers = [];        
			var cfg = CfgAuthoringContext.get();
			if (cfg && cfg.AuthoringContextHeader) {
				for (var key in cfg.AuthoringContextHeader){
					component.ca_headers.push({'key':key,'value':cfg.AuthoringContextHeader[key]});
				}
			}

        return component;


       };   
    
    return CfgVariantInitDialog;
});

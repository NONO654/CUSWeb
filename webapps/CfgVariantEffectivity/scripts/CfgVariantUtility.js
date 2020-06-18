
define('DS/CfgVariantEffectivity/scripts/CfgVariantUtility',
        ['DS/WAFData/WAFData', 'DS/UIKIT/Alert', 'DS/PlatformAPI/PlatformAPI','DS/CfgBaseUX/scripts/CfgUtility'], function (WAFData, AlertUIKIT, PlatformAPI, CfgUtility) {
            'use strict';
            var CfgVariantUtility = {
			     //function for security context callback
                data :"",
				dictionary:[],
				parentID:"",
				id:"",
				alias:"",
                varEffXML:'',
				hasEffectivity:null,
				descriptionJson:null,
				
				getMultipleFilterableObjectInfo: function (jsonData) {                   
                    var returnedPromiseFilterWU = new Promise(function (resolve, reject) {
                        var url = "/resources/modeler/configuration/navigationServices/getMultipleFilterableObjectInfo";
                        var postdata =JSON.stringify(jsonData);
                        var onCompleteCallBack = function (getMultipleFilterableObjectInfo) {					
						resolve(getMultipleFilterableObjectInfo);						
						}
                        CfgUtility.makeWSCall(url, 'POST', 'enovia', 'application/json', postdata, onCompleteCallBack, reject, true);
                    });

                    return returnedPromiseFilterWU;
                },			
								
				getCachedModelDictionary: function(idModel){
					var data = null;
					this.dictionary.forEach(function(model){
							if(model.id == idModel){
								data = model.data;								
							}
						});
					return data;
				},
				
				getModelDictionary: function(idModel){
					var that =this;
					 var returnedPromise = new Promise(function (resolve, reject) {
						var failure = function(error){
							console.log(error);
							reject(error);							
						};
						var onCompleteCallBack = function (dictResponseData) {	
						   var optimized_features = [];
						   for(var i=0; i<dictResponseData.features.length; i++){
							   var ftr = dictResponseData.features[i];
							   if(ftr.current === 'Preliminary')
								   continue;
							   else
								   optimized_features.push(ftr);
						   }
						   dictResponseData.features=optimized_features;
						   that.dictionary.push({"id":idModel,"data":dictResponseData});
						   resolve(dictResponseData);
		                };										
					   
						var url = '/resources/modeler/browsing/browseservice/pid:' + idModel + '/configurationdictionary?features=1';
				
  		                var postdata = "";		               
						
						CfgUtility.makeWSCall(url, 'POST', 'enovia', 'json', postdata, onCompleteCallBack, failure, true);	
					 });
					 return returnedPromise;
				},
               /*
				getModelsDictionary : function(idModelList, resolve2, reject2){
					var that = this;			
					var allPromises = [];
					for(var i=0; i<idModelList.length;i++){
					    allPromises.push(CfgVariantUtility.getModelDictionary(idModelList[i].physicalID));
					}
					
					Promise.all(allPromises).then(					
								function(resp){									
									resp.forEach(
									function(respEach){	
										that.dictionary.push(respEach);
									}									
									);
									resolve2("Dictionary of "+that.dictionary.length+" models loaded");	
								},
								function(error){
									reject2(error);
								}
					);						
					
				},
				*/
				processEvolutionEffectivity: function (iInstanceId) {

				    var effectivityxml = CfgVariantUtility.evolutionEffectivity.expressions[iInstanceId].content.Evolution.Current
				    var parser = new DOMParser();
				    var xmlDocument = parser.parseFromString(effectivityxml, "text/xml");

				    var ExpressionsOut = [];
				    var Contexts = xmlDocument.getElementsByTagName("Context");
				    for (var count = 0; count < Contexts.length; count++) {
				        var modelname = Contexts[count].attributes["HolderName"].value;
				        var oSerializer = new XMLSerializer();
				        var xml = oSerializer.serializeToString(Contexts[count]);
				        ExpressionsOut[modelname] = xml;
				    }

				    CfgVariantUtility.evolutionExpressions = ExpressionsOut;
				},
			
			/*	FillModelsWithDisplayName : function(input_json){					//based on dictionary
						var json = input_json;
						var model_val = json.name;
						for( var col = 0; col < json.Combinations.length ; col++){
							//Combination iteration (column)
								for( var opt = 0; opt < json.Combinations[col].Combination.length; opt++){
									var feature_val = json.Combinations[col].Combination[opt].Feature.value;
									var ft_disp_val = this.GetDisplayNameOfFeature(model_val,feature_val);
									if(ft_disp_val != null)
										json.Combinations[col].Combination[opt].Feature.label=ft_disp_val;	
									
									for( var op = 0; op < json.Combinations[col].Combination[opt].Options.length; op++){					
									   var option_val = json.Combinations[col].Combination[opt].Options[op].Option.value;	
										var op_disp_val = this.GetDisplayNameOfOption(model_val,feature_val,option_val);
										if(op_disp_val !=null)
											json.Combinations[col].Combination[opt].Options[op].Option.label=op_disp_val;									                   
									}
										
								}
						}							
					return json;
				},
				
				GetDisplayNameOfFeature : function(model_name,feature_name){	//based on feature name			
					for(var i=0; i<this.dictionary.length; i++){
						var each_dict = this.dictionary[i];
						if(each_dict.name == model_name){
							for(var fi=0; fi<each_dict.features.length; fi++){
								var each_feature = each_dict.features[fi];
									if(each_feature.name == feature_name){									
										return each_feature.displayValue;																			
									}
							}
						}
					}					
					return null;
				},
				GetDisplayNameOfOption : function(model_name,feature_name, option_name){ //based on feature and option name					
					for(var i=0; i<this.dictionary.length; i++){
						var each_dict = this.dictionary[i];
						if(each_dict.name == model_name){
							for(var fi=0; fi<each_dict.features.length; fi++){
								var each_feature = each_dict.features[fi];
								if(each_feature.name == feature_name){
									for(var oi=0; oi<each_feature.options.length; oi++){
										var each_option = each_feature.options[oi];
										if(each_option.name == option_name){
											return each_option.displayValue;
											
										}
									}
								}
							}
						}
					}
					return null;
				}*/
				
				
				FillModelsWithDisplayName : function(input_json){	//based on Description in Get Effectivity xml				
						var json = input_json;
					
						for( var col = 0; col < json.Combinations.length ; col++){
							//Combination iteration (column)
								for( var opt = 0; opt < json.Combinations[col].Combination.length; opt++){
									var featureDescId = json.Combinations[col].Combination[opt].Feature.DescId;
									var ft_disp_val = this.GetDisplayNameOfFeatureOrOption(featureDescId);
									if(ft_disp_val != null)
										json.Combinations[col].Combination[opt].Feature.label=ft_disp_val;	
									
									for( var op = 0; op < json.Combinations[col].Combination[opt].Options.length; op++){					
									   var optionDescId = json.Combinations[col].Combination[opt].Options[op].Option.DescId;	
										var op_disp_val = this.GetDisplayNameOfFeatureOrOption(optionDescId);
										if(op_disp_val !=null)
											json.Combinations[col].Combination[opt].Options[op].Option.label=op_disp_val;									                   
									}
										
								}
						}							
					return json;
				},
							
				GetDisplayNameOfFeatureOrOption : function(DescId){	//based on Description 		
					for(var i=0; i<this.descriptionJson.length; i++){						
						if(this.descriptionJson[i].DescId == DescId){
							return this.descriptionJson[i].DisplayName;
						}
					}					
					return null;
				}
	
            };
            return CfgVariantUtility;
        });


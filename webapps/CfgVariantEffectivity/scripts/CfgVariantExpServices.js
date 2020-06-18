/**
 * @module DS/CfgVariantEffectivity/scripts/CfgVariantExpServices
 */

define('DS/CfgVariantEffectivity/scripts/CfgVariantExpServices', [
		'DS/CfgVariantEffectivity/scripts/CfgVariantUtility',
        'i18n!DS/CfgVariantEffectivity/assets/nls/CfgVariantEffectivity'
    ],
    function (CfgVariantUtility,CfgVarEffNLS) {
        "use strict";

        var CfgVariantExpServices = {};
        var jsonobjEffExpText = '{ "name" : "", "Combinations" : [] }';

		var model;
		var collection;
		
		CfgVariantExpServices.SetModel = function(modelInst){
			this.model = modelInst;
		};
	    
		CfgVariantExpServices.SetCollection = function(collectionInst){
			this.collection = collectionInst;
		};

       
        //Append ID to JSON expression context ID
        CfgVariantExpServices.SetJsonContextID = function(ContextID) {
            var jsonobjEffExp = JSON.parse(jsonobjEffExpText);
            jsonobjEffExp.name = ContextID;
            var ResultText = JSON.stringify(jsonobjEffExp);
            this.SetJSONText(ResultText);
        };
        
    /*  CfgVariantExpServices.ConvertJsonToXML = function() {
            var jsonobjEffExp = JSON.parse(jsonobjEffExpText);
            var Expression = '<CfgEffectivityExpression xs:schemaLocation = \"urn:com:dassault_systemes:config CfgEffectivityExpression.xsd\" xmlns:xs = \"http://www.w3.org/2001/XMLSchema-instance\" xmlns = \"urn:com:dassault_systemes:config\">';
            Expression = Expression + '<Expression><Context HolderType = \"Model\" HolderName = \"' + jsonobjEffExp.name + '\">';
            var key = 0;

            if (jsonobjEffExp.Combinations.length >= 2) {
                Expression = Expression + '<OR>';
            }

            while (key <= (jsonobjEffExp.Combinations.length - 1)) //For each combination
            {

                // Expression = Expression + '<Id>'+jsonobjEffExp.Combinations[key].Id+'</Id>';
                if (jsonobjEffExp.Combinations[key].Combination.length >= 2) {
                    Expression = Expression + '<AND>';
                }

                var subkey = 0;
                while (subkey <= (jsonobjEffExp.Combinations[key].Combination.length - 1)) {
                    // Expression = Expression + '<Combination>';

                    Expression = Expression + '<Feature Type = \"ConfigFeature\" Name = \"' + jsonobjEffExp.Combinations[key].Combination[subkey].Feature.value + '\">';

                    var subSubkey = 0;
                    while (subSubkey <= (jsonobjEffExp.Combinations[key].Combination[subkey].Options.length - 1)) {
                        // Expression = Expression + '<Options>';
                        Expression = Expression + '<Feature Type = \"ConfigFeature\" Name = \"' + jsonobjEffExp.Combinations[key].Combination[subkey].Options[subSubkey].Option.value + '\"/>';
                        // Expression = Expression + '</Options>';
                        subSubkey++;
                    }
                    Expression = Expression + '</Feature>';
                    subkey++;
                }

                if (jsonobjEffExp.Combinations[key].Combination.length >= 2) {
                    Expression = Expression + '</AND>';
                }

                key++;

            }

            if (jsonobjEffExp.Combinations.length >= 2) {
                Expression = Expression + '</OR>';
            }

            Expression = Expression + '</Context></Expression>';
            Expression = Expression + '</CfgEffectivityExpression>';
            return Expression;
        };
	*/
		CfgVariantExpServices.ConvertXMLToDescriptionJson = function(xmlDoc) {
			var description = xmlDoc.getElementsByTagName("Description");
			var descJSON = [];
			
			
			for(var descId=0; descId < description.length; descId++){
				var featureTags = description[descId].getElementsByTagName('Feature');
				for(var ftrId=0; ftrId < featureTags.length; ftrId++){
					var ftr = {"DescId":"","DisplayName":""};
					ftr.DescId = featureTags[ftrId].attributes['DescId'].value;
					ftr.DisplayName = featureTags[ftrId].attributes['DisplayName'].value;
					descJSON.push(ftr);
					
				}
				
				var optionTags = description[descId].getElementsByTagName('Option');
				for(var opId=0; opId < optionTags.length; opId++){
					var op = {"DescId":"","DisplayName":""};
					op.DescId = optionTags[opId].attributes['DescId'].value;
					op.DisplayName = optionTags[opId].attributes['DisplayName'].value;
					descJSON.push(op);
					
				}
				
			}
			return descJSON;
		},
		
		CfgVariantExpServices.ConvertXMLToJsonNew = function(xmlDoc) {		          
						
            var Context = xmlDoc.getElementsByTagName("Context");   
            var finalJSONMulti= new Array();       
			
        for( var ctx = 0; ctx < Context.length ; ctx++){
			
            var jsonText = '{ "name" : "", "Combinations" : [] }';
            var jsonObj = JSON.parse(jsonText);
			jsonObj.name = Context[ctx].attributes['HolderName'].value;
			
			if(Context[ctx].childNodes.length == 1 && Context[ctx].childNodes[0].tagName === 'Boolean')
			{  //Empty Model
			   //<Boolean>false</Boolean>					
			}
			else	
			{            
				var Id = 0;      
				
				var Combinations = Context[ctx].getElementsByTagName("OR");
					if( Combinations != null && (Combinations.length == undefined || Combinations.length == 0) ){
						Combinations = new Array();
						Combinations[0]=Context[ctx];
				}
                var DetailsCombination = [];
                var OptionsMembersArray = [];

                for (var i = 0; i < Combinations[0].childNodes.length; i++) {
                 
                    if (Combinations[0].childNodes[i].tagName == 'Feature') {
                        DetailsCombination = [];
                        OptionsMembersArray = [];
                        var SubParentFeature = Combinations[0].childNodes[i];
                       
                        var NumberOptions = SubParentFeature.getElementsByTagName('Feature').length;
                     
                      if (NumberOptions > 0) {

                            for (var j = 0; j < NumberOptions; j++) {
                                var optionJson1 = {};								
                                optionJson1.value = Combinations[0].childNodes[i].childNodes[j].getAttribute("Name");
								optionJson1.label = "NOT_SET";
								optionJson1.DescId = Combinations[0].childNodes[i].childNodes[j].getAttribute("DescId");
                                OptionsMembersArray.push({
                                    "Option": optionJson1
                                });
                             
                            }
							var featureJson1 = {};
							featureJson1.value = SubParentFeature.getAttribute("Name");
							featureJson1.label = "NOT_SET";
							featureJson1.DescId = SubParentFeature.getAttribute("DescId");
							DetailsCombination.push({
                            "Feature": featureJson1,
                            "Options": OptionsMembersArray
							});
                        }                    

                        jsonObj.Combinations.push({
                            "Id": Id,
                            "Combination": DetailsCombination
                        });

                    } else 
                    {
                        var SubDetailsCombination = [];
                        var DetailsCombination = [];

                        var features = [];
                        var ANDnode = Combinations[0].childNodes[i];
                      
                        var NumberFeatures = ANDnode.childNodes.length;

                        for (var cpt = 0; cpt < ANDnode.childNodes.length; cpt++) {
                            var SubOptionsMembersArray = [];

                            var SubParentFeature = ANDnode.childNodes[cpt];
                         
                            var NumberOptions = SubParentFeature.getElementsByTagName('Feature').length;
                      
                            if (NumberOptions > 0) {

                                for (var j = 0; j < NumberOptions; j++) {
									var optionJson2 = {};
									optionJson2.value = SubParentFeature.childNodes[j].getAttribute("Name");
									optionJson2.label = "NOT_SET";
									optionJson2.DescId = SubParentFeature.childNodes[j].getAttribute("DescId");
                                    SubOptionsMembersArray.push({
                                        "Option": optionJson2
                                    });
                                    
                                }
								var featureJson2 = {};
								featureJson2.value = SubParentFeature.getAttribute("Name");
								featureJson2.label = "NOT_SET";								
								featureJson2.DescId = SubParentFeature.getAttribute("DescId");
								SubDetailsCombination.push({
                                "Feature": featureJson2,
                                "Options": SubOptionsMembersArray
								});

                            }
                            
                        }

                        jsonObj.Combinations.push({
                            "Id": Id,
                            "Combination": SubDetailsCombination
                        });

                    }

                    Id++;


                }            
			}            
            finalJSONMulti.push(JSON.stringify(jsonObj));           
            }
            return finalJSONMulti;
        };

		CfgVariantExpServices.UpdateJsonOnAddColumn = function(){
			var jsonobjEffExp = JSON.parse(jsonobjEffExpText);
			jsonobjEffExp.Combinations.push({
                    "Id": jsonobjEffExp.Combinations.length,
                    "Combination": []
                });
			var ResultText = JSON.stringify(jsonobjEffExp);
			this.SetJSONText(ResultText);		
		};

		// QD9
		// Update model with JSON
		CfgVariantExpServices.UpdateModelJson = function (jsonText) {
		    //this.model.set('jsonAttr',jsonText);
		    //To avoid Glitch commented above code and set jsonAttr = jsonText
		    this.model._attributes.jsonAttr = jsonText;
		};
		
	CfgVariantExpServices.IsOptionInColumn = function(Col){
	
		for(var i=0; i<Col.Combination.length; i++){
			if(Col.Combination[i].Options.length > 0)
				return true;
		}
	
		return false;
	
	};
	
	CfgVariantExpServices.IsOptionInAnyNextColumn = function(startIndex, Cols){
	
		for( var colIndex=startIndex; colIndex<Cols.length; colIndex++){
	
			for(var i=0; i<Cols[colIndex].Combination.length; i++){
				if(Cols[colIndex].Combination[i].Options.length > 0)
					return true;
			}
		}
	
		return false;
	
	};
	CfgVariantExpServices.IsOptionInAnyNextFeatureInCol = function(startIndex, Col){
			
		for(var i=startIndex; i<Col.Combination.length; i++){
			if(Col.Combination[i].Options.length > 0)
				return true;
		}
		
		return false;
	
	};

	   //Get json function
        CfgVariantExpServices.GetJSONText = function() {
            return jsonobjEffExpText;
        };

        //Set json function
        CfgVariantExpServices.SetJSONText = function(jsonText) {
            jsonobjEffExpText = jsonText;
        };

        //Function to add an option to the effectivity Expression onCheck a checkbox
        CfgVariantExpServices.AddCheckBoxBehaviourOnSelect = function(ID, CF_in, CO_in) {
			var CF = {"label":CF_in.label,"value":CF_in.value};
			var CO = {"label":CO_in.label,"value":CO_in.value};
            var jsonobjEffExp = JSON.parse(jsonobjEffExpText);
            if (jsonobjEffExp.Combinations.length == 0) {

                var OptionsMembersArray = [];
                OptionsMembersArray.push({
                    "Option": CO
                });

                var DetailsCombination = [];
                DetailsCombination.push({
                    "Feature": CF,
                    "Options": OptionsMembersArray
                });

                jsonobjEffExp.Combinations.push({
                    "Id": ID,
                    "Combination": DetailsCombination
                });
            } else {
                var trouve = false;
                var key = 0;
                while ((trouve == false) && (key <= (jsonobjEffExp.Combinations.length - 1))) {
                    // console.log(jsonobjEffExp.items[key].idCombination);
                    if (jsonobjEffExp.Combinations[key].Id == ID) //On a trouvé la combinaison
                    {
                        trouve = true;
                        var touveCF = false;
                        var subkey = 0;

                        while ((touveCF == false) && (subkey <= (jsonobjEffExp.Combinations[key].Combination.length - 1))) {
                            if (jsonobjEffExp.Combinations[key].Combination[subkey].Feature.label == CF.label && jsonobjEffExp.Combinations[key].Combination[subkey].Feature.value == CF.value) {
                                touveCF = true;
                                //////////////////////
                                var touveCO = false;
                                var subSubkey = 0;
                               while ((touveCO == false) && (subSubkey <= (jsonobjEffExp.Combinations[key].Combination[subkey].Options.length - 1))) {
                                    var bizz = jsonobjEffExp.Combinations[key].Combination[subkey].Options[subSubkey];
                                    if (bizz.Option.label == CO.label && bizz.Option.value == CO.value) {
                                        touveCO = true;
                                    } else {
                                        subSubkey++;
                                    }
                                }
                                if (touveCO == false) {
                                    jsonobjEffExp.Combinations[key].Combination[subkey].Options.push({
                                        "Option": CO
                                    });
                                }
                                //////////////////////
                            } else {
                                subkey++;
                            }
                        }
                        if (touveCF == false) {
                            var OptionsMembersArray = [];
                            OptionsMembersArray.push({
                                "Option": CO
                            });

                            jsonobjEffExp.Combinations[key].Combination.push({
                                "Feature": CF,
                                "Options": OptionsMembersArray
                            });
                        }

                    } else {
                        key++;
                    }
                } //End While
                if (trouve == false) {
                    var OptionsMembersArray = [];
                    OptionsMembersArray.push({
                        "Option": CO
                    });
                    var DetailsCombination = [];
                    DetailsCombination.push({
                        "Feature": CF,
                        "Options": OptionsMembersArray
                    });
                    jsonobjEffExp.Combinations.push({
                        "Id": ID,
                        "Combination": DetailsCombination
                    });
                }
            }

            var ResultText = JSON.stringify(jsonobjEffExp);
            // console.log('ResultText');
            // console.log(ResultText);
            this.SetJSONText(ResultText);
        };

        //Function to delete an option from the effectivity Expression onUnCheck a checkbox
        CfgVariantExpServices.AddCheckBoxBehaviourOnUnSelect = function(ID, CF_in, CO_in) {
			var CF = {"label":CF_in.label,"value":CF_in.value};
			var CO = {"label":CO_in.label,"value":CO_in.value};

            var jsonobjEffExp = JSON.parse(jsonobjEffExpText);
            if (jsonobjEffExp.Combinations.length == 0) {

                var OptionsMembersArray = [];
                OptionsMembersArray.push({
                    "Option": CO
                });

                var DetailsCombination = [];
                DetailsCombination.push({
                    "Feature": CF,
                    "Options": OptionsMembersArray
                });

                jsonobjEffExp.Combinations.push({
                    "Id": ID,
                    "Combination": DetailsCombination
                });
            } else {
                var trouve = false;
                var key = 0;
                while ((trouve == false) && (key <= (jsonobjEffExp.Combinations.length - 1))) {
                    // console.log(jsonobjEffExp.items[key].idCombination);
                    if (jsonobjEffExp.Combinations[key].Id == ID) //On a trouvé la combinaison
                    {
                        trouve = true;
                        var touveCF = false;
                        var subkey = 0;

                        while ((touveCF == false) && (subkey <= (jsonobjEffExp.Combinations[key].Combination.length - 1))) {
                            if (jsonobjEffExp.Combinations[key].Combination[subkey].Feature.value == CF.value && jsonobjEffExp.Combinations[key].Combination[subkey].Feature.label == CF.label) {
                                touveCF = true;
                                //////////////////////
                                var touveCO = false;
                                var subSubkey = 0;
                               while ((touveCO == false) && (subSubkey <= (jsonobjEffExp.Combinations[key].Combination[subkey].Options.length - 1))) {
                                    var bizz = jsonobjEffExp.Combinations[key].Combination[subkey].Options[subSubkey];
                                    if (bizz.Option.value == CO.value && bizz.Option.label == CO.label) {
                                        touveCO = true;
                                    } else {
                                        subSubkey++;
                                    }
                                }
                                if (touveCO == true) {
                                    jsonobjEffExp.Combinations[key].Combination[subkey].Options.splice(subSubkey, 1);
                                   
                                }
                                //////////////////////
                            } else {
                                subkey++;
                            }
                        }
                        if (touveCF == false) {
                            
                        }

                    } else {
                        key++;
                    }
                } //End While
                if (trouve == false) {
                    
                }
            }

            var ResultText = JSON.stringify(jsonobjEffExp);
            this.SetJSONText(ResultText);
        };

        //Function to Update the combination if a column is deleted
        CfgVariantExpServices.UpdateCombinationsIfDeleteColumn = function(col_num) {

            var json = JSON.parse(jsonobjEffExpText);
			json.Combinations.splice(col_num, 1);			                        
			for(var i=0; i<json.Combinations.length; i++){
				if(json.Combinations[i].Id > col_num)
					json.Combinations[i].Id = json.Combinations[i].Id -1;
			} 
            var ResultText = JSON.stringify(json);
            this.SetJSONText(ResultText);
        }

        //Function to update the combination if an element is unselected
        CfgVariantExpServices.UpdateCombinationsIfUnselected = function(CO_in) {	
			var CO = {"label":CO_in.label,"value":CO_in.value};
            var jsonobjEffExp = JSON.parse(jsonobjEffExpText);
            if (jsonobjEffExp.Combinations.length == 0) {} else {
                var key = 0;
                while (key <= (jsonobjEffExp.Combinations.length - 1)) {
                    // console.log(jsonobjEffExp.items[key].idCombination);                     
                    var subkey = 0;
                    while (subkey <= (jsonobjEffExp.Combinations[key].Combination.length - 1)) {

                        var touveCO = false;
                        var subSubkey = 0;
                         while ((touveCO == false) && (subSubkey <= (jsonobjEffExp.Combinations[key].Combination[subkey].Options.length - 1))) {
                            var bizz = jsonobjEffExp.Combinations[key].Combination[subkey].Options[subSubkey];
                            if (bizz.Option.value == CO.value && bizz.Option.label == CO.label) {
                                touveCO = true;
                            } else {
                                subSubkey++;
                            }
                        }
                        if (touveCO == true) {
                            jsonobjEffExp.Combinations[key].Combination[subkey].Options.splice(subSubkey, 1);                         

                            if (jsonobjEffExp.Combinations[key].Combination[subkey].Options.length == 0) {
                                jsonobjEffExp.Combinations[key].Combination.splice(subkey, 1);
                            }


                        }
                        subkey++;
                    }

                    key++;

                } //End While   
            }


            var ResultText = JSON.stringify(jsonobjEffExp);
            jsonobjEffExpText = ResultText;           
        };
		
		CfgVariantExpServices.GetEffectivityExpression = function () {
	
		CfgVariantExpServices.UpdateModelJson(jsonobjEffExpText);   	
		
		var globalExpression = '';	
		
		for (var count = 0; count < this.collection.length; count++) {
			var model = this.collection.at(count);
			var modelJsonTxt = model.get("jsonAttr");
			
			if(modelJsonTxt == '') continue;
			
			var jsonobjEffExp = JSON.parse(modelJsonTxt);
			
			if(jsonobjEffExp.Combinations.length == 0) continue;
			
			var Expression = '';
			var key = 0;           
           		           
				while (key <= (jsonobjEffExp.Combinations.length - 1)) //For each combination
				{

					var subkey = 0;

					while (subkey <= (jsonobjEffExp.Combinations[key].Combination.length - 1)) {
						var subSubkey = 0;
						while (subSubkey <= (jsonobjEffExp.Combinations[key].Combination[subkey].Options.length - 1)) {
							var COtoDisplay = jsonobjEffExp.Combinations[key].Combination[subkey].Options[subSubkey].Option.label;
							Expression = Expression + COtoDisplay ;
							if((subSubkey+1) <= (jsonobjEffExp.Combinations[key].Combination[subkey].Options.length - 1))
								Expression = Expression + ' / ';

							subSubkey++;
						}
												
						if(subSubkey > 0 && ((subkey+1) <= (jsonobjEffExp.Combinations[key].Combination.length - 1)) && CfgVariantExpServices.IsOptionInAnyNextFeatureInCol(subkey+1,jsonobjEffExp.Combinations[key]) == true)
								Expression = Expression + ' + ';
						subkey++;
					}
					
					
					if(CfgVariantExpServices.IsOptionInColumn(jsonobjEffExp.Combinations[key]) == true && ((key+1) <= (jsonobjEffExp.Combinations.length - 1)) && CfgVariantExpServices.IsOptionInAnyNextColumn(key+1,jsonobjEffExp.Combinations) == true)
								Expression = Expression + ' OR ';
					key++;
				} //End While			
			
			globalExpression +=  '<p><span style=\"font-weight: bold\">' + jsonobjEffExp.name +'</span> : <span>'+ Expression + '</span></p>';
		}  
		
		if(globalExpression == '')	
			globalExpression = CfgVarEffNLS.No_Eff_Msg;
			
         return globalExpression;    
			      
	};
	
	//QD9
	// check whether model has features 
	CfgVariantExpServices.IsCFModel= function(model){
		var isCFModel = false;
		for(var i=0;i<CfgVariantUtility.dictionary.length;i++){
			if(model.get('subtitle') === CfgVariantUtility.dictionary[i].name && CfgVariantUtility.dictionary[i].features.length > 0 ){
			isCFModel = true; 
			break;
			}
		}
		return isCFModel;
		
	};

		
		//YUS
		//Get Global XML Expression using collection
		CfgVariantExpServices.GetGlobalXMLExpression = function () {

			var checkIf
            //create global xml expression
            var Expression = "";

            for (var count = 0; count < this.collection.length; count++) {

                var key = 0;
				var model = this.collection.at(count);
				var modelJsonTxt = model.get("jsonAttr");
				var jsonobjEffExp = JSON.parse(modelJsonTxt);
				
				if(jsonobjEffExp.Combinations.length == 0){ 
					/*if(CfgVariantExpServices.IsCFModel(model)){ // Unset Effectivity now supported by modeler
						Expression += '<Context HolderType = \"Model\" HolderName = \"' + jsonobjEffExp.name.replace("&","&amp;") + '\">';  
						Expression += '<Boolean>true</Boolean>';
						Expression = Expression + '</Context>';
					}*/
				 continue;				
				}
			
                Expression += '<Context HolderType = \"Model\" HolderName = \"' + jsonobjEffExp.name.replace(/&(?!amp;)/g,"&amp;") + '\">';             
				var tmpExp2='';
				var combnsCount = 0;
                while (key <= (jsonobjEffExp.Combinations.length - 1)) //For each combination
                {                   

                    var tmpExp1='';
					var featuresCount = 0;
					
                    for ( var subkey = 0; subkey < jsonobjEffExp.Combinations[key].Combination.length ; subkey++ ) {
                        
						if(jsonobjEffExp.Combinations[key].Combination[subkey].Options.length == 0)
							continue;
						
                        tmpExp1 = tmpExp1 + '<Feature Type = \"ConfigFeature\" Name = \"' + jsonobjEffExp.Combinations[key].Combination[subkey].Feature.value.replace(/&(?!amp;)/g,"&amp;") + '\">';

                        var subSubkey = 0;
                        while (subSubkey <= (jsonobjEffExp.Combinations[key].Combination[subkey].Options.length - 1)) {
                           
                            tmpExp1 = tmpExp1 + '<Feature Type = \"ConfigFeature\" Name = \"' + jsonobjEffExp.Combinations[key].Combination[subkey].Options[subSubkey].Option.value.replace(/&(?!amp;)/g,"&amp;") + '\"/>';
                            
                            subSubkey++;

                        }
                        tmpExp1 = tmpExp1 + '</Feature>';      
						featuresCount++;
                    }

                    if (featuresCount >= 2) {

                        tmpExp2 += '<AND>' + tmpExp1 + '</AND>';

                    }
					else{
						tmpExp2 += tmpExp1;
					}
                    key++;
					if(tmpExp1 !== '')
						combnsCount++;

                }
				
				if(combnsCount == 0){
					Expression = '';
				}
				else if (combnsCount >= 2) {
						Expression += '<OR>' + tmpExp2 + '</OR></Context>';
				}				
				else{
						Expression +=  tmpExp2 ;
						Expression += '</Context>';
				}								
                

            }
			
			if(Expression != ''){
					Expression = '<CfgEffectivityExpression xs:schemaLocation = \"urn:com:dassault_systemes:config CfgEffectivityExpression.xsd\" xmlns:xs = \"http://www.w3.org/2001/XMLSchema-instance\" xmlns = \"urn:com:dassault_systemes:config\"><Expression>' + Expression + "</Expression></CfgEffectivityExpression>";
			}
			
            return Expression;
        };
        return CfgVariantExpServices;
    });

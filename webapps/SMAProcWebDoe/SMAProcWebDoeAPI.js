define('DS/SMAProcWebDoe/SMAProcWebDoeAPI', [
  'DS/JSCMM/SMAJSCMMProperty',
  'DS/SMAProcWebCMMUtils/SMAJSCMMUtils'
], function (SMAJSCMMProperty, SMAJSCMMUtils) {
	
	'use strict';
	var SMAProcWebDoeAPI = {
			
			readConfiguration: function(stepConfig, JSONData){
				//throw 'DOE does not support reading step configuration';
			
				try{
                if (false == this.isValidAdapter(stepConfig)) {return;}
				} catch(err) {
                    console.warn('Unsupported DOE configuration');
                    throw(err);
            }
                
                var designAggregate = stepConfig.getPropertyByName('Design Parameters');
            if (designAggregate === undefined || designAggregate === null) {return;} //no design parameters property in extension config??
                //if(!('factors' in JSONData) && !('responses' in JSONData)) return; //DOE only supports factors and responses
                var variables = designAggregate.getProperties();
				if(!variables || variables.length < 2){
					throw 'Unable to read DOE configuration. \n \
					Not able to find factors and responses properties \n \
					Check your base DOE configuration and technique selection';

				}
				var factors, responses;
				for(var indx = 0; indx < variables.length; indx++){
					var variable = variables[indx];
					var n = variable.getName();
                if (n.toLowerCase() === 'factor') {factors = variable;}
                else if (n.toLowerCase() === 'response') {responses = variable;}
				}
				
				if(!factors || !responses){
					throw 'Unable to read DOE configuration. \n \
					Not able to find factors and responses properties \n \
					Check your base DOE configuration and technique selection';

				}
				
				var factProps = factors.getProperties();
				JSONData.factors = [];
				for(var factIndx = 0; factIndx < factProps.length; factIndx++){
					var factor = factProps[factIndx];
                if (!factor) {continue;}
					var nameProp = factor.findPropertyByName('Name', false);
                if (!nameProp) {continue;}
					var name = nameProp.getValue();
					JSONData.factors.push(name);
				}
				
				var resProps = responses.getProperties();
				JSONData.responses = [];
				for(var resIndx = 0; resIndx < resProps.length; resIndx++){
					var res = resProps[resIndx];
                if (!res) {continue;}
					var nameProp = res.findPropertyByName('Name', false);
                if (!nameProp) {continue;}
					var name = nameProp.getValue();
					JSONData.responses.push(name);
				}
				
				return JSONData;
			},
		
			modifyConfiguration: function(stepConfig, JSONData){
				
            if (stepConfig.getExtensionName() !== 'com.dassault_systemes.sma.adapter.Doe') {return;} //not a DOE adapter
				//now check for DOE plugins
				var plugins = stepConfig.getPluginConfigurations();
				var isLH = false, isAdaptiveDOE = false, isDOEDataFile = false, isFactorial = false;
				if(plugins && plugins.length){
                if (plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.Datafile') {isDOEDataFile = true;}
					else if(plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.LatinHypercube' ||
       plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.OptimalLatinHypercube') {isLH = true;}
                else if (plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.AdaptiveDOE') {isAdaptiveDOE = true;}
					else if(plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.FullFactorial' ||
							plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.FractionalFactorial' ||
							plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.OrthogonalArray' ||
       plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.ParameterStudy') {isFactorial = true;}
				}
				if(false === isLH && false === isAdaptiveDOE && false === isFactorial) {
					throw 'DOE API only supports below techniques: \nLatin Hypercube, Optimal Latin Hypercube, Full Factorial, Fractional Factorial, \n \
					Adaptive DOE, Orthogonal Array and Parameter Study \n \
					Please select one of supported technique';

				}
				var designAggregate = stepConfig.getPropertyByName('Design Parameters');
				if((designAggregate === undefined || designAggregate === null) && ('factors' in JSONData || 'responses' in JSONData)) { //create the properties
					
					designAggregate = new SMAJSCMMProperty();
					designAggregate.setName('Design Parameters');
					designAggregate.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);
					
					//create factors property
					var prop1 = new SMAJSCMMProperty();
					prop1.setName('Factor');
					prop1.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);
					designAggregate.addProperty(prop1);
					
					//create responses property
					var prop2 = new SMAJSCMMProperty();
					prop2.setName('Response');
					prop2.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);
					designAggregate.addProperty(prop2);
					
					stepConfig.properties.push(designAggregate);
				} 
            if (designAggregate === undefined || designAggregate === null) {return;} //no design parameters property in extension config??
            if (!('factors' in JSONData) && !('responses' in JSONData)) {return;} //DOE only supports factors and responses
				
				var variables = designAggregate.getProperties();
				if(!variables || variables.length < 2){
					throw 'Unable to modify DOE configuration. \n \
					Not able to find factors and responses properties \n \
					Check your base DOE configuration and technique selection';

				}
				var factors, responses;
				for(var indx = 0; indx < variables.length; indx++){
					var variable = variables[indx];
					var n = variable.getName();
                if (n.toLowerCase() === 'factor') {factors = variable;}
                else if (n.toLowerCase() === 'response') {responses = variable;}
				}
				
				if(!factors || !responses){
					throw 'Unable to modify DOE configuration. \n \
					Not able to find factors and responses properties \n \
					Check your base DOE configuration and technique selection';

				}
				
				if('factors' in JSONData){
					//var factors = variables[0];
					factors.getProperties(); //dummy call to initialize properties
					factors.removeAllProperties(); //remove old factors
					var nbFactors = JSONData.factors.length;
					for(var factIndx = 0; factIndx < JSONData.factors.length; factIndx++){
                    if (!JSONData.factors[factIndx] || null == JSONData.factors[factIndx]) {continue;}
                    if (JSONData.factors[factIndx].factor !== undefined && JSONData.factors[factIndx].factor === false) {continue;}
						var factor = new SMAJSCMMProperty();
						factor.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);
						factor.setName('Factor ' + factIndx);
						
						//create name variable
						var nameProp = new SMAJSCMMProperty();
						nameProp.setName('Name');
						nameProp.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
						nameProp.setDataType(SMAJSCMMUtils.DataType.String);
						nameProp.setValue(JSONData.factors[factIndx].name);
						
						//create attributes aggregate
						var attrAggregate = new SMAJSCMMProperty();
						attrAggregate.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);
						attrAggregate.setName('Attributes');
						
						if(isFactorial){ //need to create # Levels, Relation and baseline attributes
							var levels = new SMAJSCMMProperty();
							levels.setName('# Levels');
							levels.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
							levels.setDataType(SMAJSCMMUtils.DataType.Integer);
							var nbLevels = 5; //default for full factorial
							if(plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.FractionalFactorial'){
                            if (nbFactors < 5) {nbLevels = 2;} //hard-coded number of levels
                            else {nbLevels = 3;} //hard-coded number of levels
							}
							else if(plugins[0].getExtensionName() !== 'com.dassault_systemes.sma.plugin.doe.FullFactorial'){
                            if (nbFactors < 5) {nbLevels = nbFactors;} //for other fraction factorial based techniques hard-coded level = number of factors
                            else {nbLevels = 5;} //setting max 5 levels
                        }
                        if (nbLevels < 2) {nbLevels = 2;} //min limit is 2 levels
							levels.setValue(nbLevels); //hard-coded number of levels
							attrAggregate.addProperty(levels);
							
							//add actual levels and values
							var levels = [];
							var levelValue = '';
							var upper = parseFloat(JSONData.factors[factIndx].upper), lower = parseFloat(JSONData.factors[factIndx].lower);
							var diff = (upper - lower)/(nbLevels - 1);
							for(var lvlIndx = 0; lvlIndx < nbLevels; lvlIndx++){
								levels.push(JSONData.factors[factIndx].lower + (diff*lvlIndx));
							}
							var sp = ' ';
							for(var lvlIndx = 0; lvlIndx < levels.length; lvlIndx++){
								levelValue = levelValue.concat(levels[lvlIndx].toString(), sp);
							}
							
							var levelVal = new SMAJSCMMProperty();
							levelVal.setName('Levels');
							levelVal.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
							levelVal.setDataType(SMAJSCMMUtils.DataType.String);
							levelVal.setValue(levelValue.trim());
							attrAggregate.addProperty(levelVal);
							
							var ValuesProp = new SMAJSCMMProperty();
							ValuesProp.setName('Values');
							ValuesProp.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
							ValuesProp.setDataType(SMAJSCMMUtils.DataType.String);
							ValuesProp.setValue(levelValue.trim());
							attrAggregate.addProperty(ValuesProp);
						}
						//create baseline, lower and upper bounds
						if(isAdaptiveDOE){ //add cluster property with default value 1
							var clusters = new SMAJSCMMProperty();
							clusters.setName('Cluster');
							clusters.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
							clusters.setDataType(SMAJSCMMUtils.DataType.Integer);
							clusters.setValue(1); //hard-coded number of clusters
							attrAggregate.addProperty(clusters);
						} if(isDOEDataFile){
							var column = new SMAJSCMMProperty();
							column.setName('Column');
							column.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
							column.setDataType(SMAJSCMMUtils.DataType.Integer);
							column.setValue(factIndx); //hard-coded number for column
							attrAggregate.addProperty(column);
						} else {
							var baseline = new SMAJSCMMProperty();
							baseline.setName('Baseline');
							baseline.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
							baseline.setDataType(SMAJSCMMUtils.DataType.Real);
							baseline.setValue(JSONData.factors[factIndx].value);
							attrAggregate.addProperty(baseline);
						}
						
						if(JSONData.factors[factIndx].lower !== undefined){
							var lower = new SMAJSCMMProperty();
							lower.setName('Lower');
							lower.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
							lower.setDataType(SMAJSCMMUtils.DataType.Real);
							lower.setValue(JSONData.factors[factIndx].lower);
							attrAggregate.addProperty(lower);
						}

						if(JSONData.factors[factIndx].upper !== undefined){
							var upper = new SMAJSCMMProperty();
							upper.setName('Upper');
							upper.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
							upper.setDataType(SMAJSCMMUtils.DataType.Real);
							upper.setValue(JSONData.factors[factIndx].upper);
							attrAggregate.addProperty(upper);
						}
						
						var relation = new SMAJSCMMProperty();
						relation.setName('Relation');
						relation.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
						relation.setDataType(SMAJSCMMUtils.DataType.String);
						relation.setValue('values'); //hard-coded relation type as values
						attrAggregate.addProperty(relation);
						
						factor.addProperty(nameProp);
						factor.addProperty(attrAggregate);
						factors.addProperty(factor);
					}
				}
				
				if('responses' in JSONData){
					//var responses = variables[1];
					responses.getProperties(); //dummy call to initialize properties
					responses.removeAllProperties(); //remove old factors
					for(var resIndx = 0; resIndx < JSONData.responses.length; resIndx++){
                    if (!JSONData.responses[resIndx] || null == JSONData.responses[resIndx]) {continue;}
						var response = new SMAJSCMMProperty();
						response.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);
						response.setName('Response ' + resIndx);
						
						//create name variable
						var nameProp = new SMAJSCMMProperty();
						nameProp.setName('Name');
						nameProp.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
						nameProp.setDataType(SMAJSCMMUtils.DataType.String);
						nameProp.setValue(JSONData.responses[resIndx].name);
						
						//create attributes aggregate
						var attrAggregate = new SMAJSCMMProperty();
						attrAggregate.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);
						attrAggregate.setName('Attributes');
						
						//create child properties
						if(JSONData.responses[resIndx].objective !== undefined){
							var obj = new SMAJSCMMProperty();
							obj.setName('Objective');
							obj.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
							obj.setDataType(SMAJSCMMUtils.DataType.String);
							obj.setValue(JSONData.responses[resIndx].objective);
							attrAggregate.addProperty(obj);
							
							//create target property
							if(JSONData.responses[resIndx].objective.toLowerCase() === 'target'){
								var target = new SMAJSCMMProperty();
								target.setName('Target');
								target.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
								target.setDataType(SMAJSCMMUtils.DataType.Real);
								target.setValue(JSONData.responses[resIndx].value);
								attrAggregate.addProperty(target);
							}
						}
						
						if(JSONData.responses[resIndx].scale !== undefined){
							var scale = new SMAJSCMMProperty();
							scale.setName('Weight');
							scale.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
							scale.setDataType(SMAJSCMMUtils.DataType.Real);
							scale.setValue(JSONData.responses[resIndx].scale);
							attrAggregate.addProperty(scale);
						}
						
						response.addProperty(nameProp);
						response.addProperty(attrAggregate);
						responses.addProperty(response);
					}
				}
			},
			
			isValidAdapter: function(stepConfig){
            if (stepConfig.getExtensionName() !== 'com.dassault_systemes.sma.adapter.Doe') {return false;} //not a DOE adapter
				//now check for DOE plugins
				var plugins = stepConfig.getPluginConfigurations();
				var isLH = false, isAdaptiveDOE = false, isDOEDataFile = false, isFactorial = false;
				if(plugins && plugins.length){
                if (plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.Datafile') {isDOEDataFile = true;}
					else if(plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.LatinHypercube' ||
       plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.OptimalLatinHypercube') {isLH = true;}
                else if (plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.AdaptiveDOE') {isAdaptiveDOE = true;}
					else if(plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.FullFactorial' ||
							plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.FractionalFactorial' ||
							plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.OrthogonalArray' ||
       plugins[0].getExtensionName() === 'com.dassault_systemes.sma.plugin.doe.ParameterStudy') {isFactorial = true;}
				}
				if(false === isLH && false === isAdaptiveDOE && false === isDOEDataFile && false === isFactorial) {
					throw 'DOE API only supports below techniques: \nLatin Hypercube, Optimal Latin Hypercube, Full Factorial, Fractional Factorial, \n \
					Adaptive DOE, Orthogonal Array, Parameter Study and Data file \n \
					Please select one of supported technique';
					return false;
				}
				
				return true;
			}
	};
	
	return SMAProcWebDoeAPI;
});

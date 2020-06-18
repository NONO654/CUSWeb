/**
 * @exports DS/CAT3DExpModel/CAT3DXJSONReader
*/
define('DS/CAT3DExpModel/CAT3DXJSONReader',
    [
        'UWA/Core',
		'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject',
        'DS/VCXWebExperienceLoader/VCXExperienceLoaderBase'
    ],
	function (UWA, CATI3DExperienceObject, VCXExperienceLoaderBase) {
    	'use strict';

      /**
      * @name DS/CAT3DExpModel/CAT3DXJSONReader
      * @description 
      * Class to deserialize JSON Content
      * @constructor
      */

    	var CAT3DXJSONReader = UWA.Class.extend(
      /** @lends DS/CAT3DExpModel/CAT3DXJSONReader.prototype **/
      {

      	/**
        * Constructor
        * @public
        * @param {Object} iFactory Factory to use
		* @param {Object} iLinkManager Manager to use
        */
      	init: function (iFactory, iLinkManager) {
      		this._factory = iFactory;
      		this._linkManager = iLinkManager;
      		this._refToSolve = [];
      		this._expLoaderBase = new VCXExperienceLoaderBase();
      	},

      	/**
        * Read an experience and build components.
        * @public
        * @param {String} iJSON - the JSON string to parse
        * @param {Object} iLinkContext - the link context
        * @return {Promise} promise
        */
      	read: function (iJSON, iLinkContext) {
      	    // deserialize iJSON  
      	    var self = this;

            //init Context
      	    var endBuildDeferred = UWA.Promise.deferred();
      	    var context = {
      	        buildPromises: [],  //for async buildComponent
      	        endBuildPromise: endBuildDeferred.promise,  //call when all session object are built
      	        processPromises: [], //process promises must be resolved to end read function
      	        JSONContext: iJSON
      	    };
      	    context.processPromises.push(context.endBuildPromise.then(function(){
      	        return self.solveReferences();
      	    }));
      	    //

      	    var readDeferred = UWA.Promise.deferred();
      	    var deserializedObject;
      	    this._readComponent(iJSON, context, iLinkContext).done(function (iDeserializedObject) {
      	        deserializedObject = iDeserializedObject;
      	        return UWA.Promise.all(context.buildPromises);
      	    }).done(function () {
      	        endBuildDeferred.resolve();
      	        return UWA.Promise.all(context.processPromises);
      	    }).done(function () {
      	        readDeferred.resolve(deserializedObject);
      	    });
      	    return readDeferred.promise;
      	},

      	_readComponent: function (iJSON, iContext, iLinkContext) {
      		if (iJSON && iJSON.Prototype) {
      		    var component = this._factory.BuildComponent(iJSON.Prototype, iJSON.IDs.PathOfIds.toString());
      			if (!component) {
      				this.findPrototypeInLocalTemplate(iJSON, iContext);
      				component = this._factory.BuildComponent(iJSON.Prototype, iJSON.IDs.PathOfIds.toString());
      			}
      			if (!component) {
      				this.findPrototypeInUserTypes(iJSON, iContext);
      				component = this._factory.BuildComponent(iJSON.Prototype, iJSON.IDs.PathOfIds.toString());
      			}
      			if (!component) {
      			    console.error(iJSON.Prototype + ' unknown');
      			    return UWA.Promise.resolve();
      			}

      			if (component.QueryInterface('CATI3DXJSONProcessor')) {
      			    iContext.processPromises.push(iContext.endBuildPromise.then(function () {
      			        return component.QueryInterface('CATI3DXJSONProcessor').Process(iJSON);
      			    }));
      			} else {
      			    this.deserializeComponent(component, iJSON, iContext, iLinkContext);
      			}    			
      		}
      		var promise = UWA.Promise.resolve(component);
      		iContext.buildPromises.push(promise);
      		return promise;
      	},

      	solveReferences: function () {
      		var promises = [];
      		for (var i = 0; i < this._refToSolve.length; i++) {
      		    var object = this._refToSolve[i].object;
      		    var variableName = this._refToSolve[i].variableName;
      			var callback = this._refToSolve[i].callback;
      			var value = this._refToSolve[i].value;

      			if (object && variableName) {
      			    promises.push(this._solveReferenceVariable(value, object, variableName));
      			}
      			else if (callback) {
      				promises.push(this._solveReferenceCallback(value, callback));
      			}
      		}
      		return UWA.Promise.all(promises);
      	},

      	_solveReferenceVariable: function (iRefs, iObject, iVariableName) {
      	    return this._getComponentsByRefs(iRefs).done(function (iComponents) {
      	        iObject.QueryInterface('CATI3DExperienceObject').SetValueByName(iVariableName, iComponents, CATI3DExperienceObject.SetValueMode.NoCheck);
      	    });
      	},

		_solveReferenceCallback: function (iRefs, iCallback) {
		    return this._getComponentsByRefs(iRefs).done(function (iComponents) {
				iCallback(iComponents);
			});
      	},


		_getComponentsByRefs: function (iRefs) {
		    var deferred = UWA.Promise.deferred();
      		var promises = [];
      		var components = [];
      		for (var i = 0; i < iRefs.length; i++) {
      		    promises.push(this._getComponentByRef(iRefs[i]).done(function (iComponent) {
      		        components.push(iComponent);
      		    }));
      		}

      		UWA.Promise.all(promises).done(function () {
      		    if (components.length === 1) {
      		        deferred.resolve(components[0]);
      		    } else {
      		        deferred.resolve(components);
      		    }
      		});
      		return deferred.promise;
		},

		_getComponentByRef:function(iRef){
		    if (!iRef.PathOfIds) { //error -> old id for occurences
		        return this._solveOverrideChildren(iRef);
		    }
		    var deferred = UWA.Promise.deferred();
		    this._factory.GetComponentByPathOfIds(iRef.PathOfIds).then(function (iComponent) {
		        deferred.resolve(iComponent);
		    })['catch'](function (e) {
		        console.error(e.toString());
		        deferred.resolve();
		    });
		    return deferred.promise;
		},

      	_solveOverrideChildren: function (iRef) { //error -> old id for occurences
      		var componentTable = this._factory._componentMap.GetComponentTable();
      		for (var compIDs in componentTable) {
      			var ids = compIDs.split(',');
      			var id = ids[ids.length - 1];
      			if (id === iRef) {
      				return UWA.Promise.resolve(componentTable[compIDs]);
      			}
      		}
      		return undefined;
      	},

      	deserializeComponent: function (iObject, iJSON, iContext, iLinkContext) {       	
        	var newLinkContext;
        	var jsonAssetHolders = iJSON.AssetHolders;
        	if (jsonAssetHolders) {
        	    var assetHolder = iObject.QueryInterface('CATI3DXAssetHolder');
        	    if (assetHolder) {
        	        for (var i = 0; i < jsonAssetHolders.length; i++) {

        	            if (jsonAssetHolders[i].LinkContextDescription) {
        	                newLinkContext = this._linkManager.getLinkContextFromJSONDescription(jsonAssetHolders[i].LinkContextDescription);
        	                assetHolder.setLinkContext(newLinkContext);
        	            }
        	            else {
        	                assetHolder.setLinkContext(iLinkContext);
        	            }
        	            assetHolder.setLinkDescription(jsonAssetHolders[i].LinkDescription);

        	            if (jsonAssetHolders[i].Cache) {
        	                this._deserializeCache(jsonAssetHolders[i].Cache);
        	                assetHolder.setCache(jsonAssetHolders[i].Cache);
        	            }
        	        }
        	    } else {
        	        if (jsonAssetHolders.length > 0) {
        	            console.error(iObject.GetObject().GetType() + ' should have an asset holder');
        	        }
        	    }
        	}

        	var jsonVariables = iJSON.Variables;
        	if (jsonVariables) {
        	    var experienceObject = iObject.QueryInterface('CATI3DExperienceObject');
        	    if (experienceObject) {
        	        for (var i = 0; i < jsonVariables.length; i++) {     	            
        	            // si la variable n'existe pas, on la cree    	            
        	            if (!experienceObject.HasVariable(jsonVariables[i].Name)) {
        	                experienceObject.AddVariable(jsonVariables[i].Name, jsonVariables[i].VariableType, jsonVariables[i].MaxSize, jsonVariables[i].ValuationMode);
        	            }

        	            experienceObject.SetVariableID(jsonVariables[i].Name, jsonVariables[i].IDs.PathOfIds.toString());

        	            if (!jsonVariables[i].Value) {
        	                continue;
        	            }

        	            if (jsonVariables[i].VariableType === CATI3DExperienceObject.VarType.Integer ||
                            jsonVariables[i].VariableType === CATI3DExperienceObject.VarType.Double ||
                            jsonVariables[i].VariableType === CATI3DExperienceObject.VarType.String ||
                            jsonVariables[i].VariableType === CATI3DExperienceObject.VarType.Boolean) {
        	                if (jsonVariables[i].MaxSize === 1) {
        	                    experienceObject.SetValueByName(jsonVariables[i].Name, jsonVariables[i].Value[0], CATI3DExperienceObject.SetValueMode.NoCheck);
        	                }
        	                else {
        	                    experienceObject.SetValueByName(jsonVariables[i].Name, jsonVariables[i].Value, CATI3DExperienceObject.SetValueMode.NoCheck);
        	                }
        	            }
        	            else if (jsonVariables[i].VariableType === CATI3DExperienceObject.VarType.Color) {
        	                var array = jsonVariables[i].Value;
        	                var value = this._expLoaderBase.BuildVCXPropertyValue("VCXPropertyValueColor", array);
        	                experienceObject.SetValueByName(jsonVariables[i].Name, value, CATI3DExperienceObject.SetValueMode.NoCheck); // VCXPropertyValueColor type
        	            }
        	            else if (jsonVariables[i].VariableType === CATI3DExperienceObject.VarType.Object) {
        	                this.deserializeObjectVariable(jsonVariables[i], iObject, jsonVariables[i].Name, iContext, newLinkContext ? newLinkContext : iLinkContext);
        	            }
        	        }
        	    } else {
        	        if (jsonVariables.length > 0) {
        	            console.error(iObject.GetObject().GetType() + ' is not a CATI3DExperienceObject');
        	        }
        	    }
        	}
      	},


      	_deserializeCache: function (iCache) {
      		if (iCache.OverrideChildren) { //DEBUG Override id instead of path ids
      			for (var i = 0; i < iCache.OverrideChildren.length; i++) {
      				this._addCacheRefToSolve(iCache.OverrideChildren, i);
      			}
      		}

      		for (var key in iCache) {
      			if (iCache.hasOwnProperty(key)) {
      				if (typeof iCache[key] === 'object') {
      					if (iCache[key].hasOwnProperty('PathOfIds')) {
      						this._addCacheRefToSolve(iCache, key);
      					} else {
      						this._deserializeCache(iCache[key]);
      					}
      				}
      			}
      		}
      	},

      	_addCacheRefToSolve: function (iObject, iKey) {
      		var refToSolve = {};
      		refToSolve.callback = function (iValue) {
      			iObject[iKey] = iValue;
      		};
      		refToSolve.value = [iObject[iKey]];
      		this._refToSolve.push(refToSolve);
      	},

      	deserializeObjectVariable: function (iJsonVariable, iObject, iVariableName, iContext, iLinkContext) {
      		var jsonValue = iJsonVariable.Value;
        	if (!jsonValue) {
        		return;
        	}

        	var self = this;
        	if (iJsonVariable.ValuationMode === CATI3DExperienceObject.ValuationMode.AggregatingValue) {
        		//variable is an array       		
        		if (iJsonVariable.MaxSize !== 1) {
        			var promises = [];
        			var newArray = [];
        			for (var iVal = 0; iVal < jsonValue.length; iVal++) {
        				promises.push(
        					self._readComponent(jsonValue[iVal], iContext, iLinkContext).done(function (iObject) {
        						if (UWA.is(iObject)) {
        							newArray.push(iObject);
        						}
        					}));
        			}
        			iContext.buildPromises.push(UWA.Promise.all(promises).done(function () {
        			    iObject.QueryInterface('CATI3DExperienceObject').SetValueByName(iVariableName, newArray, CATI3DExperienceObject.SetValueMode.NoCheck);
        			}));
        		}
        			// variable is an object -> normalement, on ne tombe pas sur ce cas mais pour le moment, on y passe
        		else {
        		    iContext.buildPromises.push(
        				self._readComponent(jsonValue[0], iContext, iLinkContext).done(function (iSubObject) {
        				    iObject.QueryInterface('CATI3DExperienceObject').SetValueByName(iVariableName, iSubObject, CATI3DExperienceObject.SetValueMode.NoCheck);
        				})
					);
        		}
        	}
        	else if (iJsonVariable.ValuationMode === CATI3DExperienceObject.ValuationMode.ReferencingValue) {
        	    var refToSolve = {};
        	    refToSolve.object = iObject;
        		refToSolve.variableName = iVariableName;
        		refToSolve.value = iJsonVariable.Value;
        		this._refToSolve.push(refToSolve);
        	}
        	else if (iJsonVariable.ValuationMode === CATI3DExperienceObject.ValuationMode.PointingVariable) {
        		//pas gere
        	}

      	},

      	findPrototypeInLocalTemplate: function (iJSON, iContext) {
      	    var JSONContext = iContext.JSONContext;
      	    if (JSONContext.Prototype !== 'CXPExperience_Spec') {
        	    return;
        	}

      	    var idxVariableTemplates = JSONContext.Variables.map(function (el) { return el.Name; }).indexOf('localTemplates');
        	if (idxVariableTemplates < 0) {
        	    return;
        	}
        	var localTemplates = JSONContext.Variables[idxVariableTemplates].Value;
        	if (!UWA.is(localTemplates)) {
        	    return;
        	}
        	var idxTemplate = localTemplates.map(function (el) { return el.Name; }).indexOf(iJSON.Prototype);
        	if (idxTemplate < 0) {
        	    return;
        	}
        	var scriptTemplate = localTemplates[idxTemplate];
        	iJSON.Prototype = scriptTemplate.Prototype;

        	var idxNameJSON = iJSON.Variables.map(function (el) { return el.Name; }).indexOf('_varName');
        	var idxNameScriptTemplate = scriptTemplate.Variables.map(function (el) { return el.Name; }).indexOf('_varName');

        	if (idxNameJSON < 0 || idxNameScriptTemplate < 0) {
        		return;
        	}
        	iJSON.Variables[idxNameJSON].Value = scriptTemplate.Variables[idxNameScriptTemplate].Value;
        },

      	findPrototypeInUserTypes: function (iJSON, iContext) {
      	    var JSONContext = iContext.JSONContext;
      	    if (JSONContext.Prototype !== 'CXPExperience_Spec') {
        		return;
        	}

      	    var idxVariableUserTypes = JSONContext.Variables.map(function (el) { return el.Name; }).indexOf('userTypes');
        	if (idxVariableUserTypes < 0) {
        		return;
        	}

        	var userTypes = JSONContext.Variables[idxVariableUserTypes].Value;
        	if (!UWA.is(userTypes)) {
        		return;
        	}

        	var idxUserType = userTypes.map(function (el) { return el.Name; }).indexOf(iJSON.Prototype);
        	if (idxUserType < 0) {
        		return;
        	}
        	var userType = userTypes[idxUserType];
        	iJSON.Prototype = userType.Prototype;
        }

      });
    	return CAT3DXJSONReader;
    });

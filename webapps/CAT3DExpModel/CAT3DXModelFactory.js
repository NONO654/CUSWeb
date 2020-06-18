/**
 * @exports DS/CAT3DExpModel/CAT3DXModelFactory
*/
define('DS/CAT3DExpModel/CAT3DXModelFactory',
[
	'UWA/Core',
	'UWA/Promise',
	'DS/CAT3DExpModel/CAT3DXBaseImpl'
],
function (
	UWA,
	Promise,
	CAT3DXBaseImpl
	) {
	'use strict';


	/**
	* @name DS/CAT3DExpModel/CAT3DXModelFactory
	* @description 
	* Base Class of Factory to manage Experience, actors and variables.
	* @constructor
	*/

	var CAT3DXModelFactory = UWA.Class.extend(
	/** @lends DS/CAT3DExpModel/CAT3DXModelFactory.prototype **/
	{
	    /**
		* Factory constructor
		* @public
		* @param {object} iOptions - object containing at least the web object modeler factory
		* iOptions.factory {object} the object modeler factory
		*/
	    init: function (iOptions) {
	        this._factory = iOptions.factory;
	        if (UWA.is(iOptions.componentMap)) {
	            this._componentMap = iOptions.componentMap;
	        }
	        else {
	            this._componentMap = this._factory._experienceBase.ComponentsMap;
	        }

	        this._components = {};
	        this._componentsSymbols = {};
	    },

	    start: function () {

	    },

	    /**
		* clean Factory and web modeler factory reference
		* @public
        * @return {Promise} promise
		*/
	    clean: function () {
	        this._factory = null;
	        this._experience = null;
	        this._components = {};
	        this._componentsSymbols = {};
	        return UWA.Promise.resolve();
	    },

	    /**
		* Create an experience
		* @public
		* @param {string}	iExperienceName - name of the experience to create
        * @param {Array} iScenarioTypes - scenarioTypes of the experience
		* @return {Promise}	promise with created experience object
		*/
	    CreateExperience: function (iExperienceName, iScenarioTypes) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateExperience: Must be implemented by derived class.' + iExperienceName + iScenarioTypes));
	    },

	    /**
		* Load a Creative Experience from its source. To be derived, source is PhysicalId for CSI Factory.
		* @public
		* @param {object} iLinkContext - link context
		* @param {object} iLink - link
		* @param {object} iScenarioTypes - scenario types
        * @return {Promise} promise
		*/
	    LoadExperience: function (iLinkContext, iLink, iScenarioTypes) {
	        return Promise.reject(new Error('CAT3DXModelFactory.LoadExperience: Must be implemented by derived class.' + iLinkContext + iLink + iScenarioTypes));
	    },

	    /**
		* Check if an experience is started on server (when re-connect to the server with a new web session)
        * @public
        * @return {Promise} promise
		*/
	    IsExperienceStarted: function () {
	        return Promise.reject(new Error('CAT3DXModelFactory.IsExperienceStarted: Must be implemented by derived class.'));
	    },

	    /**
		* Close experience on server (when re-connect to the server with a new web session)
        * @public
        * @return {Promise} promise
		*/
	    CloseExperienceServer: function () {
	        return Promise.reject(new Error('CAT3DXModelFactory.CloseExperienceServer: Must be implemented by derived class.'));
	    },

	    /**
		* Load experience from server (when re-connect to the server with a new web session)
        * @public
        * @return {Promise} promise
		*/
	    RetrieveExperienceServer: function () {
	        return Promise.reject(new Error('CAT3DXModelFactory.RetrieveExperienceServer: Must be implemented by derived class.'));
	    },

	    /**
		* Save the current experience in the database
		* @public
        * @return {Promise} promise
		*/
	    SaveExperience: function () {
	        return Promise.reject(new Error('CAT3DXModelFactory.SaveExperience: Must be implemented by derived class.'));
	    },

	    /**
		* Destroy the Current creative Experience object
		* Warning : current experience reference will be cleared, methods such as createActor(), deleteActor(), etc won't work
		*			unless creating/loading a new experience.
		* @public
        * @return {Promise} promise
		*/
	    CloseExperience: function () {
	        return Promise.reject(new Error('CAT3DXModelFactory.CloseExperience: Must be implemented by derived class.'));
	    },

	    /**
        * set the current experience
		* @param {object} iExperience - the experience
        * @public
        */
	    SetExperience:function(iExperience){
	        this._experience = iExperience;
	    },

	    /**
        * return the current experience
        * @public
        * @return {Object} the experience
        */
	    GetExperience:function(){
	        return this._experience;
	    },

	    /**
		* Create an actor under the giver father
		* @public
		* @param {string}	iTypeName - type of actor to create
		* @param {string}	iActorName - name of the actor to create
		* @param {string}	iFather  - path of the father
        * @return {Promise} promise with the created actor
		*/
	    CreateActor: function (iTypeName, iActorName, iFather) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateActor: Must be implemented by derived class.' + iTypeName + iActorName + iFather));
	    },

	    DeleteActor: function (iActor) {
	        return Promise.reject(new Error('CAT3DXModelFactory.DeleteActor: Must be implemented by derived class.' + iActor));
	    },

	    CreateActorFromAsset: function (iTypeName, iActorName, iFather, iLinkContext, iLinkDescription) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateActorFromAsset: Must be implemented by derived class.' + iTypeName + iActorName + iFather + iLinkContext + iLinkDescription));
	    },

	    InsertProduct: function (iActorName, iFather, iLinkContext, iLinkDescription) {
	        return Promise.reject(new Error('CAT3DXModelFactory.InsertProduct: Must be implemented by derived class.' + iActorName  + iFather + iLinkContext + iLinkDescription));
	    },

	    CreateOverrideProduct: function (iPathOfInst, iOverrideName, iFather) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateOverrideProduct: Must be implemented by derived class.' + iPathOfInst + iOverrideName + iFather));
	    },

	    DeleteOverride: function (iOverride) {
	        return Promise.reject(new Error('CAT3DXModelFactory.DeleteOverride: Must be implemented by derived class.' + iOverride));
	    },

	    /**
		* Create a behavior under the given father
		* @public
		* @param {string}	iTypeName - type of the behavior to create
		* @param {string}	iBehaviorName - name of the behavior to create
		* @param {string}	iFather  - path of the father
		* @return {Promise} promise with created behavior object
		*/
	    CreateBehavior: function (iTypeName, iBehaviorName, iFather) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateBehavior: Must be implemented by derived class.'+ iTypeName + iBehaviorName + iFather));
	    },

	    DeleteBehavior: function (iBehavior) {
	        return Promise.reject(new Error('CAT3DXModelFactory.DeleteBehavior: Must be implemented by derived class.' + iBehavior));
	    },

	    /**
		* Create a scenario under the current experience
		* @public
		* @param {string}	iScenarioName - name of the scenario to create
		* @return {Promise}	promise with created scenario object
		*/
	    CreateScenario: function (iScenarioName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateScenario: Must be implemented by derived class.' + iScenarioName));
	    },

	    /**
       * Get scenario types of the current experience
	   * @param {string} iExperienceID - experience ID
       * @return {Promise} promise
       * @public
       */
	    GetScenarioTypes: function (iExperienceID) {
	        return Promise.reject(new Error('CAT3DXModelFactory.GetScenarioTypes: Must be implemented by derived class.' + iExperienceID));
	    },

	    /**
        * Set scenario types of the current experience
        * @protected
        * @param {Array} iScenarioTypes - scenario types to set
        * @return {Promise} promise
        */
	    SetScenarioTypes: function (iScenarioTypes) {
	        return Promise.reject(new Error('CAT3DXModelFactory.SetScenarioTypes: Must be implemented by derived class.' + iScenarioTypes));
	    },

	    /**
		* Create an act under the given father
		* @public
		* @param {string}	iActName - name of the act to create
		* @param {string}	iFather  - path of the father
		* @return {object}	created act object
		*/
	    CreateAct: function (iActName, iFather) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateAct: Must be implemented by derived class.' + iActName + iFather));
	    },

	    /**
        * Create a paragraph under the given father
        * @public
        * @param {string}	iParagraphName - paragraph of the act to create
        * @param {string}	iFather  - path of the father
        * @return {object}	created paragraph object
        */
	    CreateParagraph: function (iParagraphName, iFather) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateParagraph: Must be implemented by derived class.' + iParagraphName + iFather));
	    },

	    /**
        * Create a sentence under the given father
        * @public
        * @param {string}	iSentenceName - name of the sentence to create
        * @param {string}	iFather  - path of the father
        * @return {object}	created sentence object
        */
	    CreateSentence: function (iSentenceName, iFather) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateSentence: Must be implemented by derived class.' + iSentenceName + iFather));
	    },

	    /**
        * Create a block under the given father
        * @public
        * @param {string}	iBlockName - name of the block to create
        * @param {string}	iFather  - path of the father
        * @param {boolean}	iIsSensorBlocks  - true for sensorBlock, false for driver block
        * @return {object}	created block object
        */
	    CreateBlock: function (iBlockName, iFather, iIsSensorBlocks) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateBlock: Must be implemented by derived class.' + iBlockName + iFather + iIsSensorBlocks));
	    },

	    /**
		* Create a resource under the current experience
		* @public
		* @param {string}	iTypeName - type of the resource to create
		* @param {string}	iResourceName - name of the resource to create
		* @return {object}	created resource object
		*/
	    CreateResource: function (iTypeName, iResourceName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateResource: Must be implemented by derived class.' + iTypeName + iResourceName));
	    },

	    CreateResourceFromAsset: function (iTypeName, iResourceName, iLinkContext, iLinkDescription) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateResourceFromAsset: Must be implemented by derived class.' + iTypeName + iResourceName + iLinkContext + iLinkDescription));
	    },

	    /**
		* Create an environment under the current experience
		* @public
		* @param {string}	iTypeName - type of the environment to create
		* @param {string}	iEnvironmentName - name of the environment to create
		* @return {object}	created environment object
		*/
	    CreateEnvironment: function (iTypeName, iEnvironmentName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateEnvironment: Must be implemented by derived class.' + iTypeName + iEnvironmentName));
	    },

	    /**
        * Create an UIButton under the current experience
        * @public
        * @param {string}	iUIName - name of the UIButton to create
        * @return {object}	created UIButton object
        */
	    CreateUIButton: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUIButton: Must be implemented by derived class.' + iUIName));
	    },

	    /**
        * Create an UIText under the current experience
        * @public
        * @param {string}	iUIName - name of the UIText to create
        * @return {object}	created UIText object
        */
	    CreateUIText: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUIText: Must be implemented by derived class.' + iUIName));
	    },

	    /**
        * Create an UIImage under the current experience
        * @public
        * @param {string}	iUIName - name of the UIImage to create
        * @return {object}	created UIImage object
        */
	    CreateUIImage: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUIImage: Must be implemented by derived class.' + iUIName));
	    },

	    /**
        * Create an UITextField under the current experience
        * @public
        * @param {string}	iUIName - name of the UITextField to create
        * @return {object}	created UITextField object
        */
	    CreateUITextField: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUITextField: Must be implemented by derived class.' + iUIName));
	    },

	    /**
        * Create an UIColorPicke under the current experience
        * @public
        * @param {string}	iUIName - name of the UIColorPicke to create
        * @return {object}	created UIColorPicke object
        */
	    CreateUIColorPicker: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUIColorPicker: Must be implemented by derived class.' + iUIName));
	    },

	    /**
        * Create an UISlider under the current experience
        * @public
        * @param {string}	iUIName - name of the UISlider to create
        * @return {object}	created UISlider object
        */
	    CreateUISlider: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUISlider: Must be implemented by derived class.' + iUIName));
	    },

	    /**
        * Create an UICameraViewer under the current experience
        * @public
        * @param {string}	iUIName - name of the UICameraViewer to create
        * @return {object}	created UICameraViewer object
        */
	    CreateUICameraViewer: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUICameraViewer: Must be implemented by derived class.' + iUIName));
	    },

	    /**
        * Create an UIWebViewer under the current experience
        * @public
        * @param {string}	iUIName - name of the UIWebViewer to create
        * @return {object}	created UIWebViewer object
        */
	    CreateUIWebViewer: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUIWebViewer: Must be implemented by derived class.' + iUIName));
	    },

	    /**
        * Create an UIGalleryMenu under the current experience
        * @public
        * @param {string}	iUIName - name of the UIGalleryMenu to create
        * @return {object}	created UIGalleryMenu object
        */
	    CreateUIGalleryMenu: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUIGalleryMenu: Must be implemented by derived class.' + iUIName));
	    },

	    /**
        * Create an UIGalleryImage under the current experience
        * @public
        * @param {string}	iUIName - name of the UIGalleryImage to create
        * @return {object}	created UIGalleryImage object
        */
	    CreateUIGalleryImage: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUIGalleryImage: Must be implemented by derived class.' + iUIName));
	    },

	    /**
        * Create an UIGalleryProduct under the current experience
        * @public
        * @param {string}	iUIName - name of the UIGalleryProduct to create
        * @return {object}	created UIGalleryProduct object
        */
	    CreateUIGalleryProduct: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUIGalleryProduct: Must be implemented by derived class.' + iUIName));
	    },

	    /**
        * Create an UIGalleryViewpoint under the current experience
        * @public
        * @param {string}	iUIName - name of the UIGalleryViewpoint to create
        * @return {object}	created UIGalleryViewpoint object
        */
	    CreateUIGalleryViewpoint: function (iUIName) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateUIGalleryViewpoint: Must be implemented by derived class.' + iUIName));
	    },

	    CreateGalleryItem: function (iItemName, iFather) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CreateGalleryItem: Must be implemented by derived class.' + iItemName + iFather));
	    },

	    /**
        * copy an actor under the given father
        * @public
        * @param {object} iActor - Path ids of the component to copy
        * @param {object} iFather -Path ids of the father
        * @return {object} actor copy
		*/
	    CopyActor: function (iActor, iFather) {
	        return Promise.reject(new Error('CAT3DXModelFactory.CopyActor: Must be implemented by derived class.' + iActor + iFather));
	    },

		/**
		* Build a component using the web object modeler. Use this method to create session only components.
		* Warning : Method not async
		* @public
		* @param {string}	iSpec - type of component to create
		* @param {string}	iID - Id of the component to assign in the TOS
		* @return {Promise} promise created component
		*/
		BuildComponent: function (iSpec, iID) {
		    var component = this._factory.BuildComponent(iSpec);

			if (!component) {
				return undefined;
			}

			if (iID) {		    
			    if (this._componentMap.GetComponentFromID(iID)) {
					console.error('2 components share the same path IDs : ' + component.GetID());
				}
				component.SetID(iID);
				this._componentMap.AddComponent(component);
			}
			else {
			    console.error('BuildComponent must be call with ID');
			}
			return component;
		},

		GetComponentByPathOfIds: function (iPathOfIds) {
		    var id = Array.isArray(iPathOfIds) ? iPathOfIds.toString() : iPathOfIds;
		    var component = this._componentMap.GetComponentFromID(id);
		    if (component) {
		        return UWA.Promise.resolve(component);
		    } else {
		        return UWA.Promise.reject(new Error('Cant find component pathOfIds : ' + id));
		    }
		},

		RemoveComponentFromComponentMap: function (iComponent) {
		    this._componentMap.RemoveComponent(iComponent.GetID());
		},

		/**
		* Create a variable and sets its values under a given father
		* @public
		* @param {string}	iFatherPathOfId - Id of the father on which create a variable
		* @param {string}	iVariableName - name of the variable to create
		* @param {string}	iVariableType - type of the variable to create
		*	<p> variable <b>Types</b> are :</p>
			<ol start="0">
			<li>Integer</li>
			<li>Double</li>
			<li>String</li>
			<li>Object</li>
			<li>Boolean</li>
			<li>All</li>
			</ol>
		* @param {boolean}	iIsList - true is list, false otherwise
		* @param {string[]}	 iValues - values to set on the variable
		* @return {Promise} promise with created variable
		*/
		CreateVariable: function (iFatherPathOfId, iVariableName, iVariableType, iIsList, iValues) {
		    return Promise.reject(new Error('CAT3DXModelFactory.CreateVariable: Must be implemented by derived class.' + iFatherPathOfId + iVariableName + iVariableType + iIsList + iValues));
		},

		/**
		* Sets(modify) values of a variable under a given father
		* @public
		* @param {Object}	iComponent - component 
		* @param {string}	iVariableName - name of the variable to create
		* @param {string[]}	 iValues - values to set on the variable
		* @return {Promise} promise with created variable
		*/
		SetVariableValues: function (iComponent, iVariableName, iValues) {
		    return Promise.reject(new Error('CAT3DXModelFactory.SetVariableValues: Not implemented.' + iComponent + iVariableName + iValues));
		},

		/**
		* build component table according to extensions data
		* @public
		* @param {Object}	iWebExtensionServer - extension server 
        * @return {Array} built components
		**/
		BuildComponentTable: function (iWebExtensionServer) {
		    var buildComponents = [];
			for (var spec in this._componentsSymbols) {
				if (this._componentsSymbols.hasOwnProperty(spec)) {
				    iWebExtensionServer.AddComponent(spec, this._componentsSymbols[spec]);
				    buildComponents.push(this._componentsSymbols[spec]);
				}
			}
			return buildComponents;
		},

		_mergeObject: function (original, extension) {
			return UWA.extend(original, extension, true);
		},

		_mergeVariables: function (variableModel, variableExt) {
			for (var i = 0; i < variableExt.length; ++i) {
				var idx = variableModel.indexOf(variableExt[i].name);
				if (idx >= 0) {
					variableModel[idx] = this._mergeObject(variableModel[idx], variableExt[i]);
				} else {
					variableModel.push(variableExt[i]);
				}
			}
			return variableModel;
		},

	    /** 
		* Merge component data from multiple extensions
		* @private
        * @param {Object} iSpecData - data of a component Spec
		**/
		_mergeSpec: function (iSpecData) {
			var spec = this._components[iSpecData.name];

			for (var key in iSpecData) {
				if (iSpecData.hasOwnProperty(key)) {
					if (spec.hasOwnProperty(key)) {
						//Existing Spec: Merge Current Value of Item;
						if (key === 'localVariables') {
							spec[key] = this._mergeVariables(spec[key], iSpecData[key]);
						} else if (key === 'name') {
							// name is used as key, allready ==
						} else if (key === 'objectUI') {
							spec[key] = this._mergeObject(spec[key], iSpecData[key]);						
						} else {
							console.warn('attribute "' + key + '" in object "' + spec.name + '" has override and no override rule');
						}
					} else {
						spec[key] = iSpecData[key];
					}
				}
			}
		},

	    /** 
		* Store component data
		* @private
        * @param {Object} iSpecData - data of a component Spec
		**/
		_createSpec: function (iSpecData) {
			this._components[iSpecData.name] = iSpecData;
		},

	    /** 
		* Create component impl class according to component hierarchy
		* @private
        * @param {Object} iProtoChain - prototypal chain
        * @param {string} iIdx - ID
        * @return {Object} the component
		**/
		_buildImplsRec: function (iProtoChain, iIdx) {
			if (iProtoChain.length === iIdx) {
			    return CAT3DXBaseImpl;
			}
			var specName = iProtoChain[iIdx];
			if (this._componentsSymbols.hasOwnProperty(specName)) {
				return this._componentsSymbols[specName];
			}

			var parentImpl = this._buildImplsRec(iProtoChain, iIdx + 1);

			this._componentsSymbols[specName] = parentImpl.extend({
				GetType: function () {
					return iProtoChain[iIdx];
				}
			});
			return this._componentsSymbols[specName];
		},

		_buildImpls: function () {
			for (var componentName in this._components) {
				if (this._components.hasOwnProperty(componentName)) {
					var protoChain = this.GetPrototypalChain(componentName);
					this._buildImplsRec(protoChain, 0);
				}
			}
		},

	    /** 
		* Compute session component model
		* @public
        * @param {Object} iComponentsData - components data computed from extensions
		**/
		ComputeComponents: function (iComponentsData) {
		    var self = this;
		    iComponentsData.forEach(function (componentsExtension) {
		        componentsExtension.forEach(function (components) {
		            var specs = components.Types;
		            for (var j = 0; j < specs.length; ++j) {
		                var specsName = specs[j].name;
		                if (self._components.hasOwnProperty(specsName)) {
		                    self._mergeSpec(specs[j]);
		                } else {
		                    self._createSpec(specs[j]);
		                }
		            }
		        });
		    });
			this._buildImpls();
		},

	    /** 
        * Load async of Factory dependencies
        * @public
        * @return {Promise} promise
        **/
		LoadDependencies:function(){
		    return UWA.Promise.resolve();
		},

	    /** 
        * return prototypal Chain of a component
        * @public
        * @param {String} iSpecName - component name
        * @return {Array} prototypal Chain
        **/
		GetPrototypalChain: function (iSpecName) {
			if (!this._components.hasOwnProperty(iSpecName)) {
				return undefined;
			}
			var ret = [this._components[iSpecName].name];
			if (!this._components[iSpecName].prototypalChain || this._components[iSpecName].prototypalChain.length === 0) {
				return ret;
			}

			return ret.concat(this._components[iSpecName].prototypalChain.split(','));
		},

	    /** 
        * return component variables
        * @public
        * @param {String} iSpecName - component name
        * @return {Array} variables
        **/
		GetVariables: function (iSpecName) {
			if (!this._components.hasOwnProperty(iSpecName)) {
				return undefined;
			}
			return this._getComputedVariables(this._components[iSpecName]);
		},

		GetObjectUI: function (iSpecName, iPropName) {
			if (!this._components.hasOwnProperty(iSpecName)) {
			    return undefined;
			}
			var ancestors = this.GetPrototypalChain(iSpecName);
			while (ancestors.length) {
				var ancestorName = ancestors.shift();

				if (this._components.hasOwnProperty(ancestorName)) {
					var ancestor = this._components[ancestorName];

					if (ancestor.objectUI && ancestor.objectUI.hasOwnProperty(iPropName)) {
						return ancestor.objectUI[iPropName];
					}
				}
			}
			return undefined;
		},

		_getComputedVariables: function (obj) {
			var ret = [];

			var ancestors = this.GetPrototypalChain(obj.name);
			while (ancestors.length) {
				var ancestorName = ancestors.shift();

				if (this._components.hasOwnProperty(ancestorName)) {
					var ancestor = this._components[ancestorName];
					var symbols = ret.map(function (item) {
						return item.name;
					});
					var props = ancestor.localVariables.filter(function (item) {
						return (symbols.indexOf(item.name) === -1);
					});
					props.forEach(function (item) {
						if (ret.map(function (el) { return el.name; }).indexOf(item.name) < 0) {
							ret.push(item);
						}
					});

				}
			}
			return ret;
		}

	});
	return CAT3DXModelFactory;
}
);

/**
 * @exports DS/CAT3DExpModelLocal/CAT3DXModelFactoryLocal
*/
define('DS/CAT3DExpModelLocal/CAT3DXModelFactoryLocal',
[
	'UWA/Core',
	'UWA/Promise',
	'DS/CAT3DExpModel/CAT3DXModelFactory',
    'DS/CATCXPCIDModel/CXPUIFactory',
    'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject',
    'DS/CATCXPModel/interfaces/CATICXPVariablesInit',
    'DS/CAT3DExpModel/CAT3DXJSONReader'
],
function (
	UWA, Promise, CAT3DXModelFactory, CXPUIFactory, CATI3DExperienceObject, CATICXPVariablesInit, CAT3DXJSONReader
	) {
	'use strict';

	/**
	* @name DS/CAT3DExpModelLocal/CAT3DXModelFactoryLocal
	* @description 
	* Local Factory. Create actors and experience will use the web object modeler.
	* @augments DS/CAT3DExpModel/CAT3DXModelFactory
	* @constructor
	*/

	var CAT3DXModelFactoryLocal = CAT3DXModelFactory.extend(
	/** @lends DS/CAT3DExpModelLocal/CAT3DXModelFactoryLocal.prototype **/
	{
		init: function (iOptions) {
		    this._parent(iOptions);
		    this._JSONcapacities = iOptions.capacities;
		},

		clean: function () {
		    return this._parent().done(function () {
		        CATICXPVariablesInit.ClearNLXML();
		    });	   
		},

		// override : In local Factory, load NL capacities
		LoadDependencies: function () {
		    var self = this;
		    if (!self._JSONcapacities || self._JSONcapacities.length === 0) {
		        return Promise.resolve();
		    }

		    var dfd = UWA.Promise.deferred();
		    require(self._JSONcapacities, function () {
		        var dependencies = [];
		        for (var i = 0; i < arguments.length; i++) {
		            var parsedJSON = JSON.parse(arguments[i]);
		            for (var spec in parsedJSON) {
		                dependencies.push({
		                    spec: spec,
		                    path: 'text!' + parsedJSON[spec]
		                });
		            }
		        }

		        require(dependencies.map(function (el) { return el.path; }), function () {
		            var parser = new DOMParser();
		            for (var i = 0; i < dependencies.length; i++) {
		                CATICXPVariablesInit.AddNLXMLNodeBySpec(dependencies[i].spec, parser.parseFromString(arguments[i], 'text/xml'));
		            }
		            dfd.resolve();
		        });
		    });
		    return dfd.promise;
		},

		CreateExperience: function (iExperienceName) {
		    return this._CreateComponent('CXPExperience_Spec', iExperienceName).then(function (iExperience) {
		        return Promise.resolve(iExperience);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		LoadExperience: function (iLinkContext, iLink, iScenarioTypes) {
		    var self = this;
		    var deferred = Promise.deferred();

		    iLinkContext.resolveLinkAsStream(iLink).then(function (iStream) {
		        var reader = new FileReader();
		        reader.onloadend = function (e) {
		            var jsonReader = new CAT3DXJSONReader(self, self._factory._experienceBase.getManager('CAT3DXLinkManager'));
		            var json = JSON.parse(e.target.result);
		            if (!UWA.is(json)) {
		                deferred.reject('invalid string');
		            }
		            jsonReader.read(json, iLinkContext).then(function (iExperience) {
		                if (UWA.is(iExperience) && iExperience.GetType() === 'CXPExperience_Spec') {
		                    deferred.resolve(iExperience);
		                }
		                else {
		                    deferred.reject('Invalid JSON' + iScenarioTypes);
		                }
		            })['catch'](function (e) {
		                deferred.reject(e);
		            });
		        };
		        reader.readAsText(iStream);
		    })['catch'](function (e) {
		        deferred.reject(e);
		    });

		    return deferred.promise;
		},

		IsExperienceStarted: function () {
		    return UWA.Promise.reject();
		},

		CloseExperienceServer: function () {
		    return UWA.Promise.resolve();
		},

		RetrieveExperienceServer: function () {
		    return UWA.Promise.reject();
		},

		CloseExperience:function(){
		    var experience = this.GetExperience();
		    experience.destroy();
		    return UWA.Promise.resolve();
		},

		SetVariableValues: function (iComponent, iVariableName, iValues) {
		    iComponent.QueryInterface('CATI3DExperienceObject').SetValueByName(iVariableName, iValues, CATI3DExperienceObject.SetValueMode.NoCheck);
		    return UWA.Promise.resolve();
		},

		CreateActor: function (iTypeName, iActorName, iFather) {
		    return this._CreateComponent(iTypeName, iActorName, iFather, 'actors').then(function (iActor) {
		        var actors = iFather.QueryInterface('CATI3DExperienceObject').GetValueByName('actors');
		        actors.push(iActor);
		        iFather.QueryInterface('CATI3DExperienceObject').SetValueByName('actors', actors, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iActor);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		DeleteActor: function (iActor) {
		    var parent = iActor.QueryInterface('CATICXPObject').GetFatherObject();
		    var actors = parent.QueryInterface('CATI3DExperienceObject').GetValueByName('actors');
		    actors.splice(actors.indexOf(iActor), 1);
		    parent.QueryInterface('CATI3DExperienceObject').SetValueByName('actors', actors, CATI3DExperienceObject.SetValueMode.NoCheck);
		    iActor.destroy();
		    return UWA.Promise.resolve();
		},

		CreateActorFromAsset: function (iTypeName, iActorName, iFather, iLinkContext, iLinkDescription) {
		    return this._CreateComponent(iTypeName, iActorName, iFather, 'actors').then(function (iActor) {
		        iActor.QueryInterface('CATI3DXAssetHolder').setLinkContext(iLinkContext);
		        iActor.QueryInterface('CATI3DXAssetHolder').setLinkDescription(iLinkDescription);

		        var actors = iFather.QueryInterface('CATI3DExperienceObject').GetValueByName('actors');
		        actors.push(iActor);
		        iFather.QueryInterface('CATI3DExperienceObject').SetValueByName('actors', actors, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iActor);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		InsertProduct: function (iActorName, iFather, iLinkContext, iLinkDescription) {
		    return this.CreateActorFromAsset('Model_VPMReference_Spec', iActorName, iFather, iLinkContext, iLinkDescription);
		},

		CreateBehavior: function (iTypeName, iBehaviorName, iFather) {
		    return this._CreateComponent(iTypeName, iBehaviorName, iFather, 'behaviors').then(function (iBehavior) {
		        var behaviors = iFather.QueryInterface('CATI3DExperienceObject').GetValueByName('behaviors');
		        behaviors.push(iBehavior);
		        iFather.QueryInterface('CATI3DExperienceObject').SetValueByName('behaviors', behaviors, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iBehavior);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		DeleteBehavior:function(iBehavior){
		    var parent = iBehavior.QueryInterface('CATICXPObject').GetFatherObject();
		    var behaviors = parent.QueryInterface('CATI3DExperienceObject').GetValueByName('behaviors');
		    behaviors.splice(behaviors.indexOf(iBehavior), 1);
		    parent.QueryInterface('CATI3DExperienceObject').SetValueByName('behaviors', behaviors, CATI3DExperienceObject.SetValueMode.NoCheck);
		    iBehavior.destroy();
		    return UWA.Promise.resolve();
		},

		CreateScenario: function (iScenarioName) {
		    var experience = this.GetExperience();
		    return this._CreateComponent('CXPWizardedScenario_Spec', iScenarioName, experience, 'scenarios').then(function (iScenario) {
		        var scenarios = experience.QueryInterface('CATI3DExperienceObject').GetValueByName('scenarios');
		        scenarios.push(iScenario);
		        experience.QueryInterface('CATI3DExperienceObject').SetValueByName('scenarios', scenarios, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iScenario);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		CreateAct: function (iActName, iFather) {
		    return this._CreateComponent('CXPAct_Spec', iActName, iFather, 'acts').then(function (iAct) {
		        var acts = iFather.QueryInterface('CATI3DExperienceObject').GetValueByName('acts');
		        acts.push(iAct);
		        iFather.QueryInterface('CATI3DExperienceObject').SetValueByName('acts', acts, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iAct);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		CreateParagraph: function (iParagraphName, iFather) {
		    return this._CreateComponent('CXPParagraph_Spec', iParagraphName, iFather, 'paragraphs').then(function (iParagraph) {
		        var paragraphs = iFather.QueryInterface('CATI3DExperienceObject').GetValueByName('paragraphs');
		        paragraphs.push(iParagraph);
		        iFather.QueryInterface('CATI3DExperienceObject').SetValueByName('paragraphs', paragraphs, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iParagraph);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		CreateSentence: function (iSentenceName, iFather) {
		    return this._CreateComponent('CXPSentence_Spec', iSentenceName, iFather, 'sentences').then(function (iSentence) {
		        var sentences = iFather.QueryInterface('CATI3DExperienceObject').GetValueByName('sentences');
		        sentences.push(iSentence);
		        iFather.QueryInterface('CATI3DExperienceObject').SetValueByName('sentences', sentences, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iSentence);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		CreateBlock: function (iBlockName, iFather, iIsSensorBlocks) {
		    var variableName = iIsSensorBlocks ? 'sensorBlocks' : 'driverBlocks';
		    var blocks = iFather.QueryInterface('CATI3DExperienceObject').GetValueByName(variableName);

		    return this._CreateComponent('CXPBlock_Spec', iBlockName, iFather, variableName).then(function (iBlock) {
		        blocks.push(iBlock);
		        iFather.QueryInterface('CATI3DExperienceObject').SetValueByName(variableName, blocks, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iBlock);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		CreateResource: function (iTypeName, iResourceName) {
		    var experience = this.GetExperience();
		    return this._CreateComponent(iTypeName, iResourceName, experience, 'resources').then(function (iResource) {
		        var resources = experience.QueryInterface('CATI3DExperienceObject').GetValueByName('resources');
		        resources.push(iResource);
		        experience.QueryInterface('CATI3DExperienceObject').SetValueByName('resources', resources, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iResource);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		CreateResourceFromAsset: function (iTypeName, iResourceName, iLinkContext, iLinkDescription) {
		    var experience = this.GetExperience();
		    return this._CreateComponent(iTypeName, iResourceName, experience, 'resources').then(function (iResource) {
		        iResource.QueryInterface('CATI3DXAssetHolder').setLinkContext(iLinkContext);
		        iResource.QueryInterface('CATI3DXAssetHolder').setLinkDescription(iLinkDescription);
		        var resources = experience.QueryInterface('CATI3DExperienceObject').GetValueByName('resources');
		        resources.push(iResource);
		        experience.QueryInterface('CATI3DExperienceObject').SetValueByName('resources', resources, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iResource);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		CreateEnvironment: function (iTypeName, iEnvironmentName) {
		    var experience = this.GetExperience();
		    return this._CreateComponent(iTypeName, iEnvironmentName, experience, 'environments').then(function (iEnvironment) {
		        var environments = experience.QueryInterface('CATI3DExperienceObject').GetValueByName('environments');
		        environments.push(iEnvironment);
		        experience.QueryInterface('CATI3DExperienceObject').SetValueByName('environments', environments, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iEnvironment);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		CreateUIButton: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillButtonVariables(iUIActor);
		    });
		},

		CreateUIText: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillTextVariables(iUIActor);
		    });
		},

		CreateUIImage: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillImageVariables(iUIActor);
		    });
		},

		CreateUITextField: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillTextFieldVariables(iUIActor);
		    });
		},

		CreateUIColorPicker: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillColorPickerVariables(iUIActor);
		    });
		},

		CreateUISlider: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillSliderVariables(iUIActor);
		    });
		},

		CreateUICameraViewer: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillCameraViewerVariables(iUIActor);
		    });
		},

		CreateUIWebViewer: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillWebViewerVariables(iUIActor);
		    });
		},

		CreateUIGalleryMenu: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillGalleryMenuVariables(iUIActor);
		    });
		},

		CreateUIGalleryImage: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillGalleryImageVariables(iUIActor);
		    });
		},

		CreateUIGalleryProduct: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillGalleryProductVariables(iUIActor);
		    });
		},

		CreateUIGalleryViewpoint: function (iUIName) {
		    return this._CreateUIActor(iUIName, function (iUIActor) {
		        return CXPUIFactory.FillGalleryViewpointVariables(iUIActor);
		    });
		},

		CreateGalleryItem: function (iItemName, iFather) {
		    return this._CreateComponent('CXPDataItem_Spec', iItemName, iFather, 'items').then(function (iItem) {
		        var items = iFather.QueryInterface('CATI3DExperienceObject').GetValueByName('items');
		        items.push(iItem);
		        iFather.QueryInterface('CATI3DExperienceObject').SetValueByName('items', items, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(iItem);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		_CreateComponent: function (iTypeName, iComponentName, iFather, iVariableName) {
		    var id;
		    if(iFather && iFather.QueryInterface('CATI3DExperienceObject') && iVariableName){
		        id = iFather.QueryInterface('CATI3DExperienceObject').GetVariableID(iVariableName) + ',' + UWA.Utils.getUUID();
		    }else{
		        id = UWA.Utils.getUUID();
		    }

		    var component = this.BuildComponent(iTypeName, id);
		    if (!component) {
		        return Promise.reject(new Error('fail to build session component'));
		    }

		    var expObject = component.QueryInterface('CATI3DExperienceObject');
		    if (expObject) {
		        var variablesNames = [];
		        expObject.ListVariables(variablesNames);
		        for (var i = 0; i < variablesNames.length; i++) {
		            expObject.SetVariableID(variablesNames[i], id + ',' + variablesNames[i]);
		        }
		    }

		    if (UWA.is(iComponentName) && component.QueryInterface('CATIAlias')) {
		        component.QueryInterface('CATIAlias').SetAlias(iComponentName);
		    }

		    var variablesInit = component.QueryInterface('CATICXPVariablesInit');
		    if (UWA.is(variablesInit)) {
		        return variablesInit.Init().then(function () {
		            return Promise.resolve(component);
		        })['catch'](function (e) {
		            return Promise.reject(e);
		        });
		    }
		    return Promise.resolve(component);
		},

		_CreateUIActor: function (iUIActorName, iFillVariablesFunction) {
		    var self = this;
		    var experience = this.GetExperience();

		    var uiactor;
		    return self._CreateComponent('CXPUIActor_Spec', iUIActorName, experience, 'actors').then(function (iUIActor) {
		        uiactor = iUIActor;
		        return iFillVariablesFunction(uiactor);
		    }).then(function () {
		        var actors = experience.QueryInterface('CATI3DExperienceObject').GetValueByName('actors');
		        actors.push(uiactor);
		        experience.QueryInterface('CATI3DExperienceObject').SetValueByName('actors', actors, CATI3DExperienceObject.SetValueMode.NoCheck);
		        return Promise.resolve(uiactor);
		    })['catch'](function (e) {
		        return Promise.reject(e);
		    });
		},

		CopyActor: function (iActor, iFather) {
		    var copy = this._copyComponent(this.GetExperience(), iActor, iFather, 'actors');
		    var actors = iFather.QueryInterface('CATI3DExperienceObject').GetValueByName('actors');
		    actors.push(copy);
		    iFather.QueryInterface('CATI3DExperienceObject').SetValueByName('actors', actors, CATI3DExperienceObject.SetValueMode.NoCheck);
		    return Promise.resolve(copy);
		},

		_copyComponent: function (iTargetExperience, iComponent, iFather, iVariableName) {
		    var copy = this.BuildComponent(iComponent.GetType(), iFather.QueryInterface('CATI3DExperienceObject').GetVariableID(iVariableName) + ',' + UWA.Utils.getUUID());
		    var variablesNames = [];

		    // share icon name 
		    var icon = copy.QueryInterface('CATIIcon');
		    if (icon) {
		        icon.SetIconName(iComponent.QueryInterface('CATIIcon').GetIconName());
		    }
		    // copy asset holder information 
		    var assetHolder = copy.QueryInterface('CATI3DXAssetHolder');
		    if (assetHolder) {
		        assetHolder.copyFrom(iComponent.QueryInterface('CATI3DXAssetHolder'));
		    }

		    var expObject = iComponent.QueryInterface('CATI3DExperienceObject');
		    if (expObject) {
		        expObject.ListVariables(variablesNames);
		        for (var i = 0; i < variablesNames.length; i++) {
		            this._copyVariable(iTargetExperience, copy, iComponent, variablesNames[i]);
		        }
		    }

		    return copy;
		},

		_deepCopyObjectVariable: function (iTargetExperience, iSrcComponent, iTarget, iVariableName) {
		    var sourceValue = iSrcComponent.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName);
		    var targetValue = this._copyComponent(iTargetExperience, sourceValue, iTarget, iVariableName);

		    iTarget.QueryInterface('CATI3DExperienceObject').SetValueByName(iVariableName, targetValue, CATI3DExperienceObject.SetValueMode.NoCheck);
		},

		_copyObjectArray: function (iTargetExperience, iSrcComponent, iTarget, iVariableName) {
		    var instanceArray = iSrcComponent.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName);
		    var copyArray = [];

		    for (var iInstance = 0; iInstance < instanceArray.length; iInstance++) {
		        if (instanceArray[iInstance].QueryInterface) {
		            copyArray.push(this._copyComponent(iTargetExperience, instanceArray[iInstance], iTarget, iVariableName));
		        }
		        else {
		            copyArray.push(instanceArray[iInstance]);
		        }
		    }
		    iTarget.QueryInterface('CATI3DExperienceObject').SetValueByName(iVariableName, copyArray, CATI3DExperienceObject.SetValueMode.NoCheck);
		},

		_copyVariableObjectExec: function (iTargetExperience, iSrcComponent, iTarget, iVariableName) {
		    var srcValue = iSrcComponent.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName);
		    if (Array.isArray(srcValue)) {
		        this._copyObjectArray(iTargetExperience, iSrcComponent, iTarget, iVariableName);
		    } else if (UWA.is(srcValue.QueryInterface)) {
		        this._deepCopyObjectVariable(iTargetExperience, iSrcComponent, iTarget, iVariableName);
		    }
		    else {
		        //should be deep copy!
		        iTarget.QueryInterface('CATI3DExperienceObject').SetValueByName(iVariableName, srcValue, CATI3DExperienceObject.SetValueMode.NoCheck);
		    }
		},

		_copyVariableExec: function (iTargetExperience, iSrcComponent, iTarget, iVariableName) {
		    var scrValue = iSrcComponent.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName);
		    if (Array.isArray(scrValue)) {
		        iTarget.QueryInterface('CATI3DExperienceObject').SetValueByName(iVariableName, scrValue.slice(), CATI3DExperienceObject.SetValueMode.NoCheck);
		    }
		    else {
		        iTarget.QueryInterface('CATI3DExperienceObject').SetValueByName(iVariableName, scrValue, CATI3DExperienceObject.SetValueMode.NoCheck);
		    }
		},

		_copyVariableColorExec: function (iTargetExperience, iSrcComponent, iTarget, iVariableName) {
		    var value = iSrcComponent.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName);
		    if (value) {
		        var copyValue = value.Clone();
		        iTarget.QueryInterface('CATI3DExperienceObject').SetValueByName(iVariableName, copyValue, CATI3DExperienceObject.SetValueMode.NoCheck);
		    }
		},

		_copyVariable: function (iTargetExperience, iTarget, iSrcComponent, iVariableName) {
		    // check variable existence to handle late types.
		    var variableInfo = iSrcComponent.QueryInterface('CATI3DExperienceObject').GetVariableInfo(iVariableName);
		    if (!iTarget.QueryInterface('CATI3DExperienceObject').HasVariable(iVariableName)) {
		        iTarget.QueryInterface('CATI3DExperienceObject').AddVariable(iVariableName, variableInfo.type, variableInfo.maxNumberOfValues, variableInfo.valuationMode);
		    }

		    iTarget.QueryInterface('CATI3DExperienceObject').SetVariableID(iVariableName, iTarget.GetID() + ',' + iVariableName);

		    var srcValue = iSrcComponent.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName);

		    if (srcValue) {
		        if (variableInfo.type === CATI3DExperienceObject.VarType.Object &&
					variableInfo.valuationMode === CATI3DExperienceObject.ValuationMode.AggregatingValue) {
		            this._copyVariableObjectExec(iTargetExperience, iSrcComponent, iTarget, iVariableName);
		            if (srcValue.isKindOf && srcValue.isKindOf('CXPResource_Spec')) {
		                var resources = iTargetExperience.QueryInterface('CATI3DExperienceObject').GetValueByName('resources');
		                resources.push(iTarget.QueryInterface('CATI3DExperienceObject').GetValueByName(iVariableName));
		            }
		        }
		        else if (variableInfo.type === CATI3DExperienceObject.VarType.Color) {
		            this._copyVariableColorExec(iTargetExperience, iSrcComponent, iTarget, iVariableName);
		        }
		        else {
		            this._copyVariableExec(iTargetExperience, iSrcComponent, iTarget, iVariableName);
		        }
		    }
		}

	});
	return CAT3DXModelFactoryLocal;
});

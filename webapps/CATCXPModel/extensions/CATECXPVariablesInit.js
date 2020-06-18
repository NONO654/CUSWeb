/**
 * CATECXPVariablesInit
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPVariablesInit
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPVariablesInit CATICXPVariablesInit}
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATECXPVariablesInit', [
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXModel',
	'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
    'DS/CATCXPModel/interfaces/CATICXPVariablesInit'
],
	function (
		UWA,
		CAT3DXModel,
		CATI3DExperienceObject,
		CAT3DXInterfaceImpl,
        CATICXPVariablesInit
	) {
		'use strict';

		var CATECXPVariablesInit = UWA.Class.extend(CAT3DXInterfaceImpl,
			/** @lends DS/CATCXPModel/extensions/CATECXPVariablesInit.prototype **/
			{
				// Interface 
				/**
				 * @public
				 */
				Init: function () {
					return this.InitFromXML();
				},

				InitFromXML: function () {
					var promises = [];

					var protoChain = CAT3DXModel.GetPrototypalChain(this.GetObject().GetType());
					if (!protoChain) {
					    return UWA.Promise.reject(new Error('no PrototypalChain'));
					}

					for (var iType = 0; iType < protoChain.length; iType++) {
					    var xmlNode = CATICXPVariablesInit.GetNLXMLNodeBySpec(protoChain[iType]);
						if (!xmlNode) {
							continue;
						}
						var xmlExperienceObject = xmlNode.getElementsByTagName('ExperienceObject');
						if (xmlExperienceObject.length !== 1) {
							continue;
						}
                        //use childNodes instead of children for IE
						var nodeListExpObject = xmlNode.getElementsByTagName('ExperienceObject')[0].childNodes;

						for (var i = 0; i < nodeListExpObject.length; i++) {
						    //use childNodes instead of children for IE
						    if (nodeListExpObject[i].nodeType !== 1) {
						        continue;
						    }

							if (nodeListExpObject[i].nodeName === 'CXPFunction') {
								promises.push(this.CreateAndAddFunctionFromXMLNode(nodeListExpObject[i]));
							}
							else if (nodeListExpObject[i].nodeName === 'CXPService') {
								promises.push(this.CreateAndAddServiceFromXMLNode(nodeListExpObject[i]));
							}
							else if (nodeListExpObject[i].nodeName === 'CXPEvent') {
								promises.push(this.CreateAndAddEventFromXMLNode(nodeListExpObject[i]));
							}
							else {
								continue;
							}
						}
					}

					return UWA.Promise.all(promises);
				},

				CreateAndAddFunctionFromXMLNode: function (iXmlNode) {
				    var self = this;
				    this.addCapacityVariable('_functions');
					return this.CreateComponent('Function_Spec', '_functions').done(function (iFunction) {
					    iFunction.QueryInterface('CATI3DExperienceObject').SetValueByName('_varName', iXmlNode.attributes.id.textContent, CATI3DExperienceObject.SetValueMode.NoCheck);

						self.addCapacity(iFunction, '_functions');
						self.ParseXMLProcessVariables(iXmlNode, iFunction);
						return self.ParseXMLNaturalLanguageInfo(iXmlNode, iFunction);
					});
				},

				CreateAndAddServiceFromXMLNode: function (iXmlNode) {
				    var self = this;
				    this.addCapacityVariable('_services');
				    return this.CreateComponent('Service_Spec', '_services').done(function (iService) {
				        iService.QueryInterface('CATI3DExperienceObject').SetValueByName('_varName', iXmlNode.attributes.id.textContent, CATI3DExperienceObject.SetValueMode.NoCheck, CATI3DExperienceObject.SetValueMode.NoCheck);

						if (iXmlNode.attributes.fctStart) {
						    iService.QueryInterface('CATI3DExperienceObject').SetValueByName('_fctStart', iXmlNode.attributes.fctStart.textContent, CATI3DExperienceObject.SetValueMode.NoCheck, CATI3DExperienceObject.SetValueMode.NoCheck);
						}
						if (iXmlNode.attributes.fctExecute) {
						    iService.QueryInterface('CATI3DExperienceObject').SetValueByName('_fctExecute', iXmlNode.attributes.fctExecute.textContent, CATI3DExperienceObject.SetValueMode.NoCheck);
						}
						if (iXmlNode.attributes.fctEnd) {
						    iService.QueryInterface('CATI3DExperienceObject').SetValueByName('_fctEnd', iXmlNode.attributes.fctEnd.textContent, CATI3DExperienceObject.SetValueMode.NoCheck);
						}
						if (iXmlNode.attributes.mode) {
						    iService.QueryInterface('CATI3DExperienceObject').SetValueByName('_mode', iXmlNode.attributes.mode.textContent, CATI3DExperienceObject.SetValueMode.NoCheck);
						}
						if (iXmlNode.attributes.fctStop) {
						    iService.QueryInterface('CATI3DExperienceObject').SetValueByName('_fctStop', iXmlNode.attributes.fctStop.textContent, CATI3DExperienceObject.SetValueMode.NoCheck);
						}
						if (iXmlNode.attributes.fctIsPlaying) {
						    iService.QueryInterface('CATI3DExperienceObject').SetValueByName('_fctIsPlaying', iXmlNode.attributes.fctIsPlaying.textContent, CATI3DExperienceObject.SetValueMode.NoCheck);
						}
						if (iXmlNode.attributes.fctPause) {
						    iService.QueryInterface('CATI3DExperienceObject').SetValueByName('_fctPause', iXmlNode.attributes.fctPause.textContent, CATI3DExperienceObject.SetValueMode.NoCheck);
						}
						if (iXmlNode.attributes.fctResume) {
						    iService.QueryInterface('CATI3DExperienceObject').SetValueByName('_fctResume', iXmlNode.attributes.fctResume.textContent, CATI3DExperienceObject.SetValueMode.NoCheck);
						}

						self.addCapacity(iService, '_services');
						self.ParseXMLProcessVariables(iXmlNode, iService);
						return self.ParseXMLNaturalLanguageInfo(iXmlNode, iService);
					});
				},

				CreateAndAddEventFromXMLNode: function (iXmlNode) {
				    var self = this;
				    this.addCapacityVariable('_events');
				    return this.CreateComponent('Event_Spec', '_events').done(function (iEvent) {
				        iEvent.QueryInterface('CATI3DExperienceObject').SetValueByName('_varName', iXmlNode.attributes.id.textContent, CATI3DExperienceObject.SetValueMode.NoCheck);
						if (iXmlNode.attributes.targetParam) {
						    iEvent.QueryInterface('CATI3DExperienceObject').SetValueByName('_targetParam', iXmlNode.attributes.targetParam.textContent, CATI3DExperienceObject.SetValueMode.NoCheck);
						}

						self.addCapacity(iEvent, '_events');
						self.ParseXMLProcessVariables(iXmlNode, iEvent);
						return self.ParseXMLNaturalLanguageInfo(iXmlNode, iEvent);
					});
				},

				ParseXMLNaturalLanguageInfo: function (iXmlNode, iCapacity) {
					var xmlNaturalLanguageInfo = iXmlNode.getElementsByTagName('NaturalLanguageInfo')[0];

					return this.CreateComponent('NaturalLanguageInfo', '_naturalLanguageInfo', iCapacity).done(function (iNlInfo) {
						for (var i = 0; i < xmlNaturalLanguageInfo.attributes.length; i++) {
							var variableName = '_' + xmlNaturalLanguageInfo.attributes[i].localName;
							if (variableName === '_exposedVariable') {
								variableName += 'Name'; //YNE2 CHECK IF MODEL CHANGED
							}
							iNlInfo.QueryInterface('CATI3DExperienceObject').SetValueByName(variableName, xmlNaturalLanguageInfo.attributes[i].textContent, CATI3DExperienceObject.SetValueMode.NoCheck);
						}
						iCapacity.QueryInterface('CATI3DExperienceObject').SetValueByName('_naturalLanguageInfo', iNlInfo, CATI3DExperienceObject.SetValueMode.NoCheck);
					});
				},

				ParseXMLProcessVariables: function (iXmlNode, iCapacity) {
					var xmlVariables = iXmlNode.getElementsByTagName('Variable');

					for (var i = 0; i < xmlVariables.length; i++) {
						var restrictiveTypes = xmlVariables[i].attributes.restrictiveTypes.textContent.split(';');

						this.CreateVariable(iCapacity, xmlVariables[i].attributes.name.textContent,
															 CATI3DExperienceObject.VarType[xmlVariables[i].attributes.type.textContent],
															 1,
															 CATI3DExperienceObject.ValuationMode.AggregatingValue, restrictiveTypes);
					}
				},

				//FunctionsMgr?
				//ServicesMgr
				//EventsMgr
				addCapacity: function (iCapacity, iCapacityName) {
				    var capacities = this.QueryInterface('CATI3DExperienceObject').GetValueByName(iCapacityName);
					if (Array.isArray(capacities)) {
					    capacities.push(iCapacity);
					}
					else {
					    capacities = [iCapacity];
					}
					this.QueryInterface('CATI3DExperienceObject').SetValueByName(iCapacityName, capacities, CATI3DExperienceObject.SetValueMode.NoCheck);
				},

				addCapacityVariable: function (iCapacityName) {
				    if (!this.QueryInterface('CATI3DExperienceObject').HasVariable(iCapacityName)) {
				        console.warn('variable ' + iCapacityName + ' doesnt exist for ' + this.GetObject().GetType());
				        this.CreateVariable(null, iCapacityName,
							CATI3DExperienceObject.VarType.Object, 0, CATI3DExperienceObject.ValuationMode.AggregatingValue);
				    }
				},

			    //Create component or variable with path of ids
				CreateComponent: function (iSpec, iVariableName, iParent) {
				    //will not add component under parent;
				    var parent = iParent ? iParent : this.GetObject();
				    if (!parent.QueryInterface('CATI3DExperienceObject').HasVariable(iVariableName)) {
				        console.error(iVariableName + ' is not a variable of ' + this.GetObject().GetType());
				        return UWA.Promise.reject(new Error(iVariableName + ' is not a variable of ' + this.GetObject().GetType()));
				    }

				    var id = parent.QueryInterface('CATI3DExperienceObject').GetVariableID(iVariableName) + ',' + UWA.Utils.getUUID();
				    return CAT3DXModel.BuildComponent(iSpec, id).done(function (iComponent) {
				        var variablesNames = [];
				        iComponent.QueryInterface('CATI3DExperienceObject').ListVariables(variablesNames);
				        for (var i = 0; i < variablesNames.length; i++) {
				            iComponent.QueryInterface('CATI3DExperienceObject').SetVariableID(variablesNames[i], id + ',' + variablesNames[i]);
				        }
				        return UWA.Promise.resolve(iComponent);
				    });
				},

				CreateVariable: function (iParent, iVariableName, iType, iMaxNumberOfValues, iMode, iRestrictiveTypes) {
				    var parent = iParent ? iParent : this.GetObject();
				    parent.QueryInterface('CATI3DExperienceObject').AddVariable(iVariableName, iType, iMaxNumberOfValues, iMode, iRestrictiveTypes);
				    parent.QueryInterface('CATI3DExperienceObject').SetVariableID(iVariableName, parent.GetID() + ',' + iVariableName);
				}

			});

		return CATECXPVariablesInit;
	});

/*********************************************************************/
/*@fullReview XF3 21/05/2016
/*********************************************************************/

define('DS/ConfiguratorPanel/scripts/ConfiguratorSolverFunctions',
[   'UWA/Core',
'DS/ConfiguratorPanel/scripts/Utilities',
'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
'DS/UIKIT/Mask',
'DS/UIKIT/Alert',
'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json'
],
function (UWA, Utilities, ConfiguratorVariables, Mask, Alert, nlsConfiguratorKeys) {

	var ConfiguratorSolverFunctions = {
		solverCreated: false,
		solverKey: '',
		solverNode: null,
		solverId: '',
		configModel: null,
		modelEvents: null,
		//modelerCreated: false,
		//modelerKey: '',
		parentContainer: null,

		initSolver : function (modelId, configModel, modelEvents, configCriteria, parentContainer, options) {
			var myDico;
			var that = this;
			this.configModel = configModel;
			this.modelEvents = modelEvents;
			this.modelId = modelId;
			this.parentContainer = (parentContainer) ? parentContainer : document.body;
			if(options && options.tenant){
				this.tenant =options.tenant;
			}else {
				this.tenant = "OnPremise";
			}
			if(options && options.version){
				this.version =options.version;
			}else {
				this.version = "V1";
			}
			Mask.mask(this.parentContainer);
			this.modelEvents.subscribe({event:'ComputeConfigExpression'}, function(data) {
				var xmlComputed = configModel.getXMLExpression();
				that.modelEvents.publish({
					event: 'onConfigurationExpressionComputed',
					data: {
						xml: xmlComputed,
						binary: ""
					}
				});
				/*that.askBinary(function (binaryExpression) {
				console.log("--------- Callback of AskBinary function called !!!");

				var binaryExpressionFaked = "666C7403000302010200000000000508C84FB556A26A00004708BC572234060009C84FB556A26A00004708BC5722340600040100000000000000000000000000000005C84FB556A26A00007C08BC57C0D2040006C84FB556A26A00008C08BC5776440B0001000100000100000000010000000B1412010000010300017735940000017735940002020200000107B201010D01014E200D20183C3E030300000001041000000017120000010117130000001900000007000001020B00000008000001030A000000";
				//TODO : retrieve the binary in result variable

				that.modelEvents.publish({
						event: 'onConfigurationExpressionComputed',
						data: {
							xml: xmlComputed,
							binary: binaryExpressionFaked
						}
					});
				});*/
			});


			this.modelEvents.subscribe({ event: 'OnMultiSelectionChange' }, function (data) {
				that.SetMultiSelectionOnSolver(data.value, data.callsolve);
			});


			this.modelEvents.subscribe({ event: 'OnRuleAssistanceLevelChange' }, function (data) {
				if (data.value != ConfiguratorVariables.NoRuleApplied)
				that.setSelectionModeOnSolver(data.value, data.callsolve);
			});


			this.modelEvents.subscribe({ event: 'SolverFct_getResultingStatusOriginators' }, function (data) {
				that.getResultingStatusOriginators(data.value);
			});

			this.modelEvents.subscribe({ event: 'SolverFct_CallSolveMethodOnSolver' }, function (data) {
				that.abortSolverCall();
				that.CallSolveMethodOnSolver();
			});

			this.modelEvents.subscribe({ event: 'SolverFct_updateConfigurations' }, function () {
				that.updateConfigurations();
			});

			this.modelEvents.subscribe({ event: 'SolverFct_getConfigurations' }, function (pcid) {
				that.getConfigurationsOnPC(pcid);
			});



			// Utilities.sendRequest(
			// 	"/resources/cfg/configurator/solver/initialization/context/" + modelId + "?parentContextId=" + modelId + "&random=" + Math.random(),
			// 	'POST',
			// 	'json',
			// 	false,
			// 	setDictionaryForDashboard,
			// 	showFailureMessage,
			// 	{
			// 		"configurationCriteria":configCriteria
			// 	},
			// 	400);

				var initializationOptions = {
					url: '/resources/cfg/configurator/solver/initialization/context/' + modelId + '?parentContextId=' + modelId + '&random=' + Math.random(),
					method: 'POST',
					responseType: 'json',
					data: {
						"configurationCriteria":configCriteria
					},
					// timeout: '400',
					tenant : that.tenant
				};
			return Utilities.sendRequestPromise(initializationOptions).then(setDictionaryForDashboard, showFailureMessage);

			function setDictionaryForDashboard(dictionaryData)
			{
				that.solverCreated = true;

				myDico = dictionaryData;
				//console.log("Success getDictionary =" + myDico);

				//Manage the release solver
				window.addEventListener("unload", function (e) {
					that.releaseSolver();
				});

				window.top.addEventListener("unload", function (e) {
					that.releaseSolver();
				});

				/*
				widget.addEvent('onRefresh', function (e) {
				that.releaseSolver();

				widget.dispatchEvent("onLoad");
			});	*/


			//Always diagnose the features
			that.setAlwaysDiagnosed(myDico.dictionary);

			if(that.version !== "V2"){
				var multiSelState = (that.configModel.getMultiSelectionState() == "true")? true:false;
				 that.SetMultiSelectionOnSolver(multiSelState, false);
				 that.setSelectionModeOnSolver(that.configModel.getRulesMode());
			}else{
				if (that.configModel.getAppFunc().multiSelection === ConfiguratorVariables.str_yes || that.configModel.getAppFunc().selectionMode_Refine === ConfiguratorVariables.str_yes) {
					that.SetMultiSelectionOnSolver(multiSelState, false);
				}else{
					if(that.configModel.getAppRulesParam() && that.configModel.getAppRulesParam().completenessStatus === "Hybrid"){
						Utilities.displayNotification({eventID: 'warning',msg: nlsConfiguratorKeys.HybridWarningInRealistic});
					}
				}
				that.setSelectionModeOnSolver(that.configModel.getRulesMode());
				// that.CallSolveMethodOnSolver({firstCall : true});
			}

			//Check consistency of rules model
			that.CheckRulesConsistency();

			//Retrieve Hypervisor details
			// Utilities.sendRequest(
			// 	"/resources/cfg/configurator/solver/hypervisordetails"+ "?random=" + Math.random(),
			// 	'GET',
			// 	'json',
			// 	false,
			// 	function(HypervisorDetails) {
			// 		//that.connectToSolverNode(HypervisorDetails.hypervisorIp, HypervisorDetails.hypervisorPort, HypervisorDetails.solverKey);
			// 		that.solverKey = HypervisorDetails.solverKey;
			// 		console.log("************************** SolverKey : " + HypervisorDetails.solverKey);
			//
			// 		//that.createModeler(myDico.dictionary);
			//
			// 		callback(myDico.dictionary, HypervisorDetails.solverKey);
			//
			// 	},
			// 	function(msg) {
			// 		console.log("failed while getting Hypervisor details ="+msg);
			// 		//alert(arguments[1].message);
			// 	},
			// 	null,400);

				var hypervisorDetailOptions = {
					url: '/resources/cfg/configurator/solver/hypervisordetails'+ '?random=' + Math.random(),
					method: 'GET',
					responseType: 'json',
					data: null,
					// timeout: '400'
					tenant : that.tenant
				};
				return Utilities.sendRequestPromise(hypervisorDetailOptions).then(function success(HypervisorDetails) {
					//that.connectToSolverNode(HypervisorDetails.hypervisorIp, HypervisorDetails.hypervisorPort, HypervisorDetails.solverKey);
					that.solverKey = HypervisorDetails.solverKey;
					console.log("************************** SolverKey : " + HypervisorDetails.solverKey);
					Mask.unmask(that.parentContainer);
					return UWA.Promise.resolve({
						dictionary: myDico.dictionary,
						solverKey : HypervisorDetails.solverKey
					});

					// return UWA.Promise(function (resolve,) {
					// 	resolve([myDico.dictionary, HypervisorDetails.solverKey]);
					// });
				}, function fail() {
					Mask.unmask(that.parentContainer);
					console.log("failed while getting Hypervisor details ="+msg);
				});
			}

			function showFailureMessage(msg)
			{
				console.log("failed while getting initdata ="+msg);
			}

		},

		getConfigurationsOnPC : function(pcid){
			var that = this;
			if(this.solverCreated) {
				 Mask.mask(this.parentContainer);
				// Utilities.sendRequest(
				// 	"/resources/cfg/configurator/configuration/" + pcid,
				// 	'GET',
				// 	'json',
				// 	false,
				// 	function(e)
				// 	{
				// 		that.configModel.setAppRulesParam(e.appRuleParam);
				// 		that.configModel.setConfigurationCriteria(e.configurationCriteria);
				//
				// 		that.modelEvents.publish( {
				// 			event:	'saved_configurations',
				// 			data:	{
				// 				configurations : e,
				// 			}
				// 		});
				// 		Mask.unmask(that.parentContainer);
				// 	},
				// 	function(e)
				// 	{
				// 			Mask.unmask(that.parentContainer);
				// 		console.log("Failed in Releasing Solver");
				// 	},
				// 	null,
				// 	400
				// );
				var configurationOptions = {
					url: '/resources/cfg/configurator/configuration/' + pcid,
					method: 'GET',
					responseType: 'json',
					data: null,
					// timeout: 400
					tenant : that.tenant
				};
				Utilities.sendRequestPromise(configurationOptions).then(
					function success(e)
					{
						Mask.unmask(that.parentContainer);
						that.configModel.setAppRulesParam(e.appRuleParam);
						that.configModel.setConfigurationCriteria(e.configurationCriteria);

						that.modelEvents.publish( {
							event:	'saved_configurations',
							data:	{
								configurations : e,
							}
						});

					},
					function fail(e)
					{
						 Mask.unmask(that.parentContainer);
						console.log("Failed in Releasing Solver");
					}
				);
			}
		},

		getConfigurationRule : function(pid,success, failure){
			var configurationOptions = {
				url: "/resources/modeler/configurationrule/pid:" + pid + "?attributes=1&random=" + Math.random(),
				method: 'GET',
				responseType: 'json',
				data: null,
				tenant : this.tenant
			};
			Utilities.sendRequestPromise(configurationOptions).then(success,failure);
		},

		updateConfigurations : function(){
			var that = this;
			var configStr = JSON.stringify(this.configModel.getConfigurationCriteria());
			var appRuleParam = this.configModel.getAppRulesParam();
			if(this.configModel.getRulesActivation() === "false"){
				appRuleParam.rulesMode = "RulesMode_EnforceRequiredOptions"; //fails with "No rules mode" && blank quotes. Passing ruleActivation false is enough. This value is not referred.
			}
			var appRulesParamStr = JSON.stringify(appRuleParam);

			var productConfigDetails ={
				"contextid": this.modelId,
				"pcId": this.configModel.getPCId(),
				"strListPriceValue": this.configModel._totalPrice,
				"strAction":"edit"
			};

			var productConfigDetailsStr = JSON.stringify(productConfigDetails);

			if(that.solverCreated) {
				 Mask.mask(that.parentContainer);
				// Utilities.sendRequest(
				// 	"/resources/cfg/configurator/configuration"+ "?random=" + Math.random(),
				// 	'POST',
				// 	'json',
				// 	false,
				// 	function(e)
				// 	{
				// 		if(that.alert) that.alert.destroy();
				// 		Mask.unmask(that.parentContainer);
				// 		var notificationContainer = document.body.querySelector("#config-editor-notification-container");
				// 		if(notificationContainer){
				// 			that.alert = new Alert({
				// 				visible: true,
				// 				autoHide: true,
				// 				hideDelay: 3000
				// 			}).inject(notificationContainer);
				//
				// 			that.alert.elements.container.style.float = 'right';
				// 			that.alert.elements.container.style.top = '0px';
				// 			that.alert.elements.container.style.position = 'relative';
				// 			that.alert.add({
				// 				className: 'primary',
				// 				message: "Configurations saved successfully!"
				// 			});
				// 		}
				// 		console.log("Configurations saved successfully!");
				// 	},
				// 	function(e)
				// 	{
				// 		Mask.unmask(that.parentContainer);
				// 		if(that.alert) that.alert.destroy();
				// 		var notificationContainer = document.body.querySelector("#config-editor-notification-container");
				// 		if(notificationContainer){
				// 			that.alert = new Alert({
				// 				visible: true,
				// 				autoHide: true,
				// 				hideDelay: 3000,
				// 				className : "#config-alert"
				// 			}).inject(notificationContainer);
				//
				// 			that.alert.elements.container.style.float = 'right';
				// 			that.alert.elements.container.style.top = '0px';
				// 			that.alert.elements.container.style.position = 'relative';
				// 				that.alert.add({
				// 				className: 'error',
				// 				message: "Failed to save configurations!"
				// 			});
				// 		}
				// 		console.log("Failed to save configurations");
				// 	},
				// 	{
				// 		"productConfigDetails":productConfigDetailsStr,
				// 		"selectedCriteria" : configStr,
				// 		"appRuleParam" : appRulesParamStr
				// 	},
				// 	400
				// );

				var Options = {
					url: '/resources/cfg/configurator/configuration'+ '?random=' + Math.random(),
					method: 'POST',
					responseType: 'json',
					data: {
						"productConfigDetails":productConfigDetailsStr,
						"selectedCriteria" : configStr,
						"appRuleParam" : appRulesParamStr
					},
					timeout: 40000,
					tenant : that.tenant
				};
				Utilities.sendRequestPromise(Options).then(
					function success(e)
					{
						Mask.unmask(that.parentContainer);
						if(that.alert) that.alert.destroy();
						var notificationContainer = document.body.querySelector("#config-editor-notification-container");
						if(notificationContainer){
							that.alert = new Alert({
								visible: true,
								autoHide: true,
								hideDelay: 3000
							}).inject(notificationContainer);

							that.alert.elements.container.style.float = 'right';
							that.alert.elements.container.style.top = '0px';
							that.alert.elements.container.style.position = 'relative';
							that.alert.add({
								className: 'primary',
								message: nlsConfiguratorKeys.saved_configurations_msg
							});
						}
						console.log("Configurations saved successfully!");
					},
					function fail(e)
					{
						Mask.unmask(that.parentContainer);
						if(that.alert) that.alert.destroy();
						var notificationContainer = document.body.querySelector("#config-editor-notification-container");
						if(notificationContainer){
							that.alert = new Alert({
								visible: true,
								autoHide: true,
								hideDelay: 3000,
								className : "#config-alert"
							}).inject(notificationContainer);

							that.alert.elements.container.style.float = 'right';
							that.alert.elements.container.style.top = '0px';
							that.alert.elements.container.style.position = 'relative';
								that.alert.add({
								className: 'error',
								message: nlsConfiguratorKeys.failed_configurations_msg
							});
						}
						console.log("Failed to save configurations");
					}
				);

			}
		},

		releaseSolver: function () {
			var that = this;

			if(that.solverCreated) {
				Mask.mask(that.parentContainer);
				// Utilities.sendRequest(
				// 	"/resources/cfg/configurator/solver/release",
				// 	'POST',
				// 	null,
				// 	false,
				// 	function(e)
				// 	{
				// 		console.log("Solver Released");
				// 		that.solverCreated = false;
				// 		that.solverKey = '';
				// 		Mask.unmask(that.parentContainer);
				//
				// 	},
				// 	function(e)
				// 	{
				// 		console.log("Failed in Releasing Solver");
				// 	},
				// 	{ "solverKey": that.solverKey },
				// 	400
				// );
				var releaseSolverOptions = {
					url: '/resources/cfg/configurator/solver/release',
					method: 'POST',
					responseType: null,
					data: {'solverKey' : that.solverKey },
					// timeout: 400
					tenant : that.tenant
				}
				return Utilities.sendRequestPromise(releaseSolverOptions).then(
					function success(e)
					{
						console.log("Solver Released");
						Mask.unmask(that.parentContainer);
						that.solverCreated = false;
						that.solverKey = '';
						// Mask.unmask(that.parentContainer);
					},
					function fail(e)
					{
						Mask.unmask(that.parentContainer);
						console.log("Failed in Releasing Solver");
					}
				);
			}

			//that.deleteModeler();
		},

		/****************************************************************************************************/
		/*                                  connectToSolverNode()                                           */
		/****************************************************************************************************/

		/*connectToSolverNode: function (ipHypervisor, port, SolverNodeName) {
		var that = this;

		var nodeSolver = new EK.Node({
		hypervisorIp: ipHypervisor,
		webSocketPort: port,
		onText: onText,
		//onBinary: onBinary,
		//onClose: onClose,
		});

		that.solverNode = nodeSolver;

		/**********************************************************************/
		/*Callbacks for EK Communication                                      */
		/**********************************************************************/
		/*function onText(input) {
		console.log(input);
		}

		//Connect to solverNode
		that.solverKey = SolverNodeName;
		that.solverId = that.solverNode.connect(SolverNodeName).select();

		var sendDisconnection = {
		"_from": "configurator",
		"_to": "solver",
		"_request": "deleteNode",
		"_data": ""
		};

		that.solverNode.sendTextOnDisconnection(that.solverId, JSON.stringify(sendDisconnection));
		},*/


		/*createModeler: function (dictionary) {
		var that = this;

		Utilities.sendRequest(
		"/resources/cfg/configurator/modeler/create" + "?random=" + Math.random(),
		'GET',
		'json',
		false,
		function (result) {
		that.modelerCreated = true;
		that.modelerKey = result;

		console.log("Modeler successfully created !");

		that.initModeler(dictionary);
		},
		function (result) {
		console.log("failed while creating Modeler object : " + result);
		//alert(JSON.parse(arguments[1]).message);
		},
		null,
		null);
		},

		deleteModeler: function () {
		var that = this;

		if (that.modelerCreated) {
		Utilities.sendRequest(
		"/resources/cfg/configurator/modeler/delete",
		'POST',
		'json',
		false,
		function (e) {
		console.log("Modeler Deleted");
		that.modelerCreated = false;
		that.modelerKey = '';
		},
		function (e) {
		console.log("Failed in Deleting Modeler");
		},
		{ "modelerKey": that.modelerKey },
		null
		);
		}
		},

		initModeler: function (dictionary) {
		var that = this;

		if (that.modelerCreated) {
		Utilities.sendRequest(
		"/resources/cfg/configurator/modeler/initialize",
		'POST',
		'json',
		false,
		function (e) {
		console.log("Modeler Initialized !");
		},
		function (e) {
		console.log("Failed in Initializing Modeler");
		//alert(JSON.parse(e));
		},
		{
		"modelerKey": that.modelerKey,
		"jsonDico": dictionary
		},
		null
		);
		}
		},

		askBinary: function (callbackMethod) {
		var that = this;

		if (this.modelerCreated) {
		var xmlComputed = that.configModel.getXMLExpression();

		var jsonToSend = {
		"_from": "configurator",
		"_to": "modeler",
		"_request": "getBinaryEffectivity",
		"_data": xmlComputed
		};


		var message = JSON.stringify(jsonToSend);

		var completeMethod = function (result) {
		console.log(result);
		var binary = JSON.parse(result)._data.EffectivityBinary;

		callbackMethod(binary);
		};

		var failureMathod = function (result) {
		console.log("failed while getting computeAnswer result =" + result);
		//alert(JSON.parse(arguments[1]).message);
		};

		Utilities.sendRequest(
		"/resources/cfg/configurator/modeler/compute",
		'POST',
		'html',
		true,
		completeMethod,
		failureMathod,
		{
		"modelerKey": that.modelerKey,
		"jsonMsg": message
		},
		60000
		);
		}
		},	   */

		callSolveForRules : function(jsonModel, callback){
		if (this.solverCreated) {
			// Mask.mask(this.parentContainer);
			jsonModel._clientData = jsonModel._clientData || {};
			jsonModel._clientData.type = jsonModel.statesCauses ? "validityWithCause" : "validity";
		 	var requestData =  {
				"matrixDefinition": {
					"drivingCriteria": jsonModel.drivingCriteria,
				 	"constrainedCriteria": jsonModel.constrainedCriteria,
					"drivingCombinationValues": jsonModel.drivingCombinationValues,
					"constrainedValues":jsonModel.constrainedValues,
					"states": jsonModel.states
				},
				"buildtimeCheck": jsonModel._clientData.type,
				"runtimeCheck": jsonModel._clientData.type
			 };
			if(jsonModel._clientData.type === "validityWithCause")
			requestData.statesCauses = jsonModel.statesCauses;
			var jsonToSend = {
					"_from": "ruleEditor",
					"_to": "solverRule",
					"_version": jsonModel.version,
					"_request": "checkMatrixRuleValidity",
					"_data": requestData,
					"_clientData" : jsonModel._clientData
			};
			var returnFromWebService = this.sendTextToSolver(JSON.stringify(jsonToSend),callback);
			if (returnFromWebService != undefined) {
				this.ApplyAnswer(returnFromWebService);
			}
			// Mask.mask(this.parentContainer);
			}
		},

		abortComputation : function(columnID){
				var jsonToSend = 		{
				"_from": "ruleEditor",
				"_to": "solver",
				"_request": "abortRequest",
				"_data": {
					"requestIds": [columnID]
				}
			}
			var returnFromWebService = this.sendTextToSolver(JSON.stringify(jsonToSend));

			if (returnFromWebService != undefined) {
				this.ApplyAnswer(returnFromWebService);
			}
			// Mask.mask(this.parentContainer);
		},

		setRuleActivation : function(ruleId, flag, callback){
			var requestData =  {
				"ruleId": ruleId,
				 "ruleActivation": flag
			};
			var jsonToSend = {
				"_from": "ruleEditor",
				"_to": "solverRule",
				"_request": "ruleActivation",
				"_data": requestData
			};
			//this.keyForRules = solverKey;
			var returnFromWebService = this.sendTextToSolver(JSON.stringify(jsonToSend), callback);

			if (returnFromWebService != undefined) {
				this.ApplyAnswer(returnFromWebService);
			}
			// Mask.mask(this.parentContainer);
		},

		CallSolveMethodOnSolver: function (options) {
			if (this.solverCreated) {
				if (this.configModel.getRulesActivation() == "true") {

					var requestData = { "configurationCriteria": this.configModel.getConfigurationCriteria() };
					var jsonToSend = {
						"_from": "configurator",
						"_to": "solverConfiguration",
						"_request": "solveAndDiagnoseAll",
						"_data": requestData
					};

					this.sendTextToSolver(JSON.stringify(jsonToSend),options);
					// var returnFromWebService = this.sendTextToSolver(JSON.stringify(jsonToSend));
					//
					// if (returnFromWebService != undefined) {
					// 	this.ApplyAnswer(returnFromWebService);
					// }

					// Mask.mask(this.parentContainer);
				}
			}
		},


		setSelectionModeOnSolver: function (newMode, callSolveAfterSolverResult) {
			if (this.solverCreated) {
				if (newMode == ConfiguratorVariables.RulesMode_DisableIncompatibleOptions)
				newMode = "Select_None";
				else if (newMode == ConfiguratorVariables.RulesMode_EnforceRequiredOptions)
				newMode = "Select_RequiredAndDefault";
				else if (newMode == ConfiguratorVariables.RulesMode_SelectCompleteConfiguration)
				newMode = "Select_ProposedSelection";
				else if (newMode == ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration)
				newMode = "Select_OptimalSelection";

				var jsonToSend = {
					"_from": "configurator",
					"_to": "solverConfiguration",
					"_request": "setSelectionMode",
					"_data": newMode						//possible Modes : "Select_OptimalSelection", "Select_ProposedSelection", "Select_RequiredAndDefault" and "Select_None"
				};

				this.sendTextToSolver(JSON.stringify(jsonToSend), callSolveAfterSolverResult);
				// var returnFromWebService = this.sendTextToSolver(JSON.stringify(jsonToSend), callSolveAfterSolverResult);
				//
				// if (returnFromWebService != undefined) {
				// 	this.ApplyAnswer(returnFromWebService);
				// }
			}
		},

		/*setOptimizationFunctionOnSolver : function () {
		var configSingleton = new ConfigModel();
		var optimCoeff = [];
		var i=0;

		var idWithPrice = configSingleton.cacheIdWithPrice;

		for (id in idWithPrice) {
		if (configSingleton.isAnOption(id) && idWithPrice[id] != "0.0") {
		optimCoeff.push({ "id": id, "coefficient": idWithPrice[id] });
		}
		}

		var jsonToSend = {
		"_from": "configurator",
		"_to": "solverConfiguration",
		"_request": "setOptimizationFunction",
		"_data": {
		"optimizationMode": "min",     //configSingleton.getOptimModeSelected(),
		"optimizationCoefficients": optimCoeff
		}
		};

		returnFromWebService = this.sendTextToSolver(JSON.stringify(jsonToSend));

		if (returnFromWebService != undefined) {
		this.ApplyAnswer(returnFromWebService);
		}

		},*/



	getResultingStatusOriginators: function (optionId) {
		if (this.solverCreated) {
			var jsonToSend = {
				"_from": "configurator",
				"_to": "solverConfiguration",
				"_request": "getResultingStatusOriginators",
				"_data": optionId
			};

			this.sendTextToSolver(JSON.stringify(jsonToSend));
			// returnFromWebService = this.sendTextToSolver(JSON.stringify(jsonToSend));
			//
			// if (returnFromWebService != undefined) {
			// 	this.ApplyAnswer(returnFromWebService);
			// }

			//Mask.mask(this.parentContainer);//To allow user interaction while tooltip is calculated.
		}
	},
	abortSolverCall: function (optionId) {
		if (this.solverCreated) {

			var jsonToSend = {
				"_from": "configurator",
				"_to": "solver",
				"_request": "abortRequest",
				"_data": ""
			};

			this.sendTextToSolver(JSON.stringify(jsonToSend));
			// returnFromWebService = this.sendTextToSolver(JSON.stringify(jsonToSend));
			//
			// if (returnFromWebService != undefined) {
			// 	this.ApplyAnswer(returnFromWebService);
			// }
		}
	},


	sendTextToSolver: function (message, callSolveAfterSolverResult) {
		//callSolveAfterSolverResult is mainly used for setMultiSelection and setSelectionMode queries
		var that = this;
		if (this.solverCreated) {
			var solverKey = that.solverKey ? that.solverKey : "";
			Mask.mask(this.parentContainer);
			// Utilities.sendRequest(
			// 	"/resources/cfg/configurator/solver/computeAnswer",
			// 	'POST',
			// 	'text',
			// 	true,
			// 	function (result) {
			// 		that.ApplyAnswer(result, callSolveAfterSolverResult);
			// 	},
			// 	function (result) {
			// 		console.log("failed while getting computeAnswer result =" + result);
			// 		//alert(JSON.parse(arguments[1]).message);
			// 	},
			// 	{
			// 		"solverId": solverKey,
			// 		"selectedCriteria": message
			// 	},
			// 	0
			// );
			// var json = JSON.parse(message);
			// if(json._request === 'ruleActivation'){
			// 	solverKey = this.keyForRules || this.solverKey;
			// }
			var solverOptions = {
				url: '/resources/cfg/configurator/solver/computeAnswer',
				method: 'POST',
				responseType: 'text',
				data: {
					"solverId": solverKey,
					"selectedCriteria": message
				},
				timeout: 40000,
				tenant : that.tenant
			};
			return Utilities.sendRequestPromise(solverOptions).then(
				function success(result) {
					Mask.unmask(that.parentContainer);
					that.ApplyAnswer(result, callSolveAfterSolverResult);
					return result;
				},
				function fail(result) {
					console.log("failed while getting computeAnswer result =" + result);
						Mask.unmask(that.parentContainer);
					return result;
				}
			);
		}
	},


	CheckRulesConsistency : function () {
		if (this.solverCreated) {
			var jsonToSend = {
				"_from": "configurator",
				"_to": "solverConfiguration",
				"_request": "checkModelConsistency",
				"_data": ""
			};

			this.sendTextToSolver(JSON.stringify(jsonToSend));
			// returnFromWebService = this.sendTextToSolver(JSON.stringify(jsonToSend));

			// Mask.mask(this.parentContainer);

			// if (returnFromWebService != undefined) {
			// 	this.ApplyAnswer(returnFromWebService);
			// }
		}
	},

	SetMultiSelectionOnSolver: function (booleanValue, callSolveAfterSolverResult) {
		if (this.solverCreated) {
			var requestData = "false";
			if (booleanValue == true) requestData = "true";
			var jsonToSend = {
				"_from": "configurator",
				"_to": "solverConfiguration",
				"_request": "setMultiSelection",
				"_data": requestData
			};

			this.sendTextToSolver(JSON.stringify(jsonToSend), callSolveAfterSolverResult);
			// returnFromWebService = this.sendTextToSolver(JSON.stringify(jsonToSend), callSolveAfterSolverResult);
			//
			// if (returnFromWebService != undefined) {
			// 	this.ApplyAnswer(returnFromWebService);
			// }
		}
	},

	setAlwaysDiagnosed: function (dictionary) {
		if (this.solverCreated) {
			var features = [];

			var dictionaryFeatures = dictionary.features;

			for (var i = 0; i < dictionaryFeatures.length; i++) {
				features.push(dictionaryFeatures[i].ruleId);
			}

			var jsonToSend = {
				"_from": "configurator",
				"_to": "solverConfiguration",
				"_request": "setAlwaysDiagnosed",
				"_data": { "alwaysDiagnosedIds": features }
			};

			this.sendTextToSolver(JSON.stringify(jsonToSend));
			// returnFromWebService = this.sendTextToSolver(JSON.stringify(jsonToSend));
			//
			// if (returnFromWebService != undefined) {
			// 	this.ApplyAnswer(returnFromWebService);
			// }
		}
	},
	UpdateSelectedOptions: function()
	{
		/*getFeatureIdWithOptionId
		console.log("inside UpdateSelectedOptions");*/

	},

	ApplyAnswer: function (input, in_callSolveAfterSolverResult) {
		var ret = true;
		var callSolveAfterSolverResult = true;
		var firstCall = false;
		// Mask.unmask(this.parentContainer);
		if (in_callSolveAfterSolverResult != undefined) {
			callSolveAfterSolverResult = in_callSolveAfterSolverResult;
		}
		if(in_callSolveAfterSolverResult && in_callSolveAfterSolverResult.firstCall){
			firstCall = true;
			callSolveAfterSolverResult = true;
		}

		if (input != undefined && input != "" && UWA.typeOf(input) === "string") {
			var inputbis = JSON.parse(input);

			var answerMethod = inputbis._answer;
			var answerData = inputbis._data;
			var answerRC = inputbis._rc;

			if (answerMethod == "getResultingStatusOriginators") {

				var listIncompatibilities = answerData.listOfIncompatibilitiesIds;
				var optionSelected = answerData.optionSelected;

				this.modelEvents.publish( {
					event:	'getResultingStatusOriginators_SolverAnswer',
					data:	{
						listOfIncompatibilitiesIds : listIncompatibilities,
						optionSelected : optionSelected,
						answerRC : answerRC
					}
				});

				// Mask.unmask(this.parentContainer);
			}
			else if (answerMethod === "checkMatrixRuleValidity") {
				console.log(answerData);
				answerData.version = inputbis._version;
					answerData._clientData = inputbis._clientData;
					if(answerData._clientData.type === "validityWithCause"){
							this.modelEvents.publish( {
								event:	'checkMatrixRuleValidity_SolverReason',
								data:	{
									answerData : answerData,
								}
							});
					}else{
						if(in_callSolveAfterSolverResult){	//if callback provided then call the callback, else publish an event
						in_callSolveAfterSolverResult(answerData);
					}else{
						this.modelEvents.publish( {
							event:	'checkMatrixRuleValidity_SolverAnswer',
							data:	{
								answerData : answerData,
							}
						});
					}
					}

					// Mask.unmask(this.parentContainer);
			}else if(answerMethod == "ruleActivation"){
				if(in_callSolveAfterSolverResult){	//if callback provided then call the callback, else publish an event
				in_callSolveAfterSolverResult(inputbis._rc);
				}
				// Mask.unmask(this.parentContainer);
			}else if (answerMethod === "removeData") {
				if(in_callSolveAfterSolverResult){	//if callback provided then call the callback, else publish an event
				in_callSolveAfterSolverResult(inputbis._rc);
				}
				// Mask.unmask(this.parentContainer);
			}
			else if (answerMethod == "checkModelConsistency") {

				if (answerRC == "Rules_KO" || answerRC == "ERROR") {
					this.configModel.setRulesConsistency(false);
					if(this.configModel.setRulesActivation){
						this.configModel.setRulesActivation("false");

						var message = nlsConfiguratorKeys.InfoInconsistentRules;

						var listOfInconsistentRules = answerData.listOfInconsistentRulesIds;
						if (listOfInconsistentRules.length > 0) {
							message += "<br>" + nlsConfiguratorKeys.ImpliedRules + ":<br>";
							for (var i = 0; i < listOfInconsistentRules.length; i++) {
								message += "<blocquote style='padding-left:20px;'>" + listOfInconsistentRules[i] + "<br></blocquote>";
							}
						}
						if (answerRC == "ERROR") {
							message += "<br>" + nlsConfiguratorKeys.InfoComputationAborted;
						}

						Utilities.displayNotification({
							eventID: 'info',
							msg: message
						});
					}
					else this.configModel.setRulesConsistency(true);

					this.modelEvents.publish( {
						event:	'checkModelConsistency_SolverAnswer',
						data:	{
							answerRC : answerRC
						}
					});
					}


				// Mask.unmask(this.parentContainer);
			}

			else if (answerMethod == "solveAndDiagnoseAll") {

				var answerConfigCriteria = answerData.configurationCriteria;
				var answerModifiedAssumptions = answerData.modifiedAssumptions;
				var answerConflicts = answerData.conflicts;
				var answerDefaults = answerData.defaults;



				if (answerConflicts) {		// Conflicts found during resolution

					if (answerRC === "ERROR") {		// Error when computing conflicts (probably timeout)
						var message = nlsConfiguratorKeys.InfoComplexityOfRules;

						Utilities.displayNotification({
							eventID: 'info',
							msg: message
						});
					}

					var listOfListOfConflictingIds = answerConflicts.listOfListOfConflictingIds;
					var listOfListOfImpliedRules = answerConflicts.listOfListOfImpliedRules;
					var state;
					/*var conflictsToApply = new Object();

					for (var i = 0; i < listOfListOfConflictingIds.length; i++) {
					for (var j = 0; j < listOfListOfConflictingIds[i].length; j++) {
					state = this.configModel.getStateWithId(listOfListOfConflictingIds[i][j]);
					if (this.configModel.isAnOption(listOfListOfConflictingIds[i][j]) ) {
					if (state == "Chosen" || state == "ChosenInConflict")
					conflictsToApply[listOfListOfConflictingIds[i][j]] = "ChosenInConflict";
					else if (state == "Dismissed" || state == "DismissedInConflict")
					conflictsToApply[listOfListOfConflictingIds[i][j]] = "DismissedInConflict";
					else if (state == "Default" || state == "DefaultInConflict")
					conflictsToApply[listOfListOfConflictingIds[i][j]] = "DefaultInConflict";
							}
						}
						}
						*/
						this.configModel.setConfigurationCriteria(answerConfigCriteria);
						/*
						for (var id in conflictsToApply) {
						this.configModel.setStateWithId(id, conflictsToApply[id]);
					}*/

					this.configModel.setImpliedRules(listOfListOfImpliedRules);
					this.configModel.setConflictingFeatures(listOfListOfConflictingIds);

					this.configModel.setRulesCompliancyStatus("Invalid");
				}

				else if (answerConfigCriteria) {	// No conflict found during resolution
					this.configModel.setConfigurationCriteria(answerConfigCriteria);
					this.configModel.setConflictingFeatures(null);
					this.configModel.setRulesCompliancyStatus("Valid");
				}

				if (answerModifiedAssumptions.length > 0) {		// Some assumptions have been modified during resolution
					var message = nlsConfiguratorKeys.InfoIdsIncompatibles + "<br>";
					for (var i = 0; i < answerModifiedAssumptions.length; i++) {
						message += "<blocquote style='padding-left:20px;'>" + this.configModel.getFeatureDisplayNameWithId(answerModifiedAssumptions[i]) + "[" + this.configModel.getOptionDisplayNameWithId(answerModifiedAssumptions[i]) + "]<br></blocquote>";
					}

					Utilities.displayNotification({
						eventID: 'info',
						msg: message
					});
				}

				// Mask.unmask(this.parentContainer);
				if(firstCall){
					this.modelEvents.publish( {
						event:	'init_configurator',
						data:	{
							answerDefaults : answerDefaults,
							answerConflicts : answerConflicts,
							answerRC : answerRC
						}
					});
				}else{
					this.modelEvents.publish( {
						event:	'solveAndDiagnoseAll_SolverAnswer',
						data:	{
							answerDefaults : answerDefaults,
							answerConflicts : answerConflicts,
							answerRC : answerRC
						}
					});
				}
			}

			else if (answerMethod == "setSelectionMode" && callSolveAfterSolverResult === true) {
				if(in_callSolveAfterSolverResult && in_callSolveAfterSolverResult.firstCall)
					this.CallSolveMethodOnSolver(in_callSolveAfterSolverResult);
				else {
					this.CallSolveMethodOnSolver();
				}
			}

			else if (answerMethod == "setMultiSelection" && callSolveAfterSolverResult === true) {
				if(in_callSolveAfterSolverResult && in_callSolveAfterSolverResult.firstCall)
					this.CallSolveMethodOnSolver(in_callSolveAfterSolverResult);
				else {
					this.CallSolveMethodOnSolver();
				}
			}

			else if (answerRC == "ERROR") {
				// GENERIC ERROR MSG
				console.log("Error during solver resolution");
			}
		}

		return ret;
	}

	};


	return UWA.namespace('DS/ConfiguratorPanel/ConfiguratorSolverFunctions', ConfiguratorSolverFunctions);
});

/*********************************************************************/
/*@fullReview XF3 21/05/2016
/*********************************************************************/

define('DS/ConfiguratorPanel/scripts/Utilities',
		[   'UWA/Core',
		    'DS/i3DXCompassServices/i3DXCompassServices',
		    'DS/Notifications/NotificationsManagerUXMessages',
		    'DS/Notifications/NotificationsManagerViewOnScreen',
            'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
            'DS/WAFData/WAFData'
		    ],
		    function (UWA, i3DXCompassServices, NotificationsManagerUXMessages, NotificationsManagerViewOnScreen, ConfiguratorVariables, WAFData) {

	var Utilities = {
			_serviceUrl: null,_tenant : "",
			_notif_manager: null,


			sendRequestPromise : function (options) {
				var url = options.url;
				var method = options.method;
				var data = options.data;
				var timeout = options.timeout;
				var responseType = options.responseType;
				var tenant = options.tenant || "OnPremise";
				var that = this;
				return new UWA.Promise(function (resolve, reject) {
					that.sendRequest(url, method, responseType, true, resolve, reject, data, timeout, tenant);
				});
			},

			sendRequest : function (inputUrl, requestMethod, requestType, async, onCompleteCallback, onFailureCallback, data, timeout,tenant) {
				var that = this;
				if(tenant && tenant !== "OnPremise"){
					that._securityContext = null;
					that._serviceUrl = null;
					that.receivedTenant = tenant;
				}
				if(that._securityContext == null){
					that.setSecurityContext();
				}
				//var newTimeout = timeout ? timeout : 0;

				var request = function (in_inputUrl, in_requestMethod, in_requestType, in_async, in_onCompleteCallback, in_onFailureCallback, in_data, in_timeout) {
					var requestUrl =
						that.wafAuthenticatedRequest(that._serviceUrl + in_inputUrl, {
							method : in_requestMethod,
							type: 'json',
							async : in_async ,
							proxy:'passport',
							headers:{
								"SecurityContext": (that._securityContext) ? that._securityContext : "",
								"Content-Type":  'json'
							},
							onComplete : in_onCompleteCallback,
							onFailure : in_onFailureCallback,
							timeout: in_timeout? in_timeout : 0,
							data:in_data,
							responseType:in_requestType
						}/*, newTimeout*/);

				};

				if(that._serviceUrl != null) {
					request(inputUrl, requestMethod, requestType, async, onCompleteCallback, onFailureCallback, data, timeout);
				}
				else {
					var parameters = {
							serviceName : '3DSpace',
							platformId : "",    //widget.getValue('x3dPlatformId'),
							onComplete : function(URLResult) {
								if (typeof URLResult === "string") {
									that._serviceUrl = URLResult;
								} else {
									that._serviceUrl = URLResult[0].url;
								}
								that._tenant = URLResult[0]["platformId"];

								/** Added for multitenant issue **/
								if(that.receivedTenant !== "OnPremise"){
									var count, data = URLResult || [];
									for (count = 0; count < data.length; count++) {
	                  if (that.receivedTenant == data[count]["platformId"]) {
	                      that._serviceUrl  = data[count].url;
	                      that._tenant = data[count]["platformId"];
	                  }
	                }
								}
								request(inputUrl, requestMethod, requestType, async, onCompleteCallback, onFailureCallback, data, timeout);
							},
							onFailure : function() {
								console.log("Service initialization failed...");
							}
					};

					objCancel = i3DXCompassServices.getServiceUrl(parameters);
				}


			},

			displayNotification: function(options) {
				if (this._notif_manager === null) {
					this._notif_manager = NotificationsManagerUXMessages;
					NotificationsManagerViewOnScreen.setNotificationManager(this._notif_manager);
				}
				var level = 'info';
				if (UWA.is(options.eventID) && options.eventID !== 'primary') {
					level = options.eventID;
				}
				this._notif_manager.addNotif({
					level: level,
					message: options.msg,
					sticky: false
				});
			},

			setCookie: function(cname, cvalue, exdays) {
				var d = new Date();
				d.setTime(d.getTime() + (exdays*24*60*60*1000));
				var expires = "expires="+ d.toUTCString();
				document.cookie = cname + "=" + cvalue + "; " + expires;
			},

			getCookie: function(cname) {
				var name = cname + "=";
				var ca = document.cookie.split(';');
				for(var i = 0; i <ca.length; i++) {
					var c = ca[i];
					while (c.charAt(0)==' ') {
						c = c.substring(1);
					}
					if (c.indexOf(name) == 0) {
						return c.substring(name.length,c.length);
					}
				}
				return "";
			},

			convertStatesToPersistedStatesInConfigCriteria: function (configurationCriteria) {

			    for (var i = 0; i < configurationCriteria.length; i++) {

			        if (configurationCriteria[i].State == ConfiguratorVariables.Chosen)
			            configurationCriteria[i].State = ConfiguratorVariables.PersistenceStates_Chosen;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.Required)
			            configurationCriteria[i].State = ConfiguratorVariables.PersistenceStates_Required;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.Default)
			            configurationCriteria[i].State = ConfiguratorVariables.PersistenceStates_Default;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.Dismissed)
			            configurationCriteria[i].State = ConfiguratorVariables.PersistenceStates_Dismissed;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.Incompatible)
			            configurationCriteria[i].State = ConfiguratorVariables.PersistenceStates_Incompatible;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.Unselected)
			            configurationCriteria[i].State = ConfiguratorVariables.PersistenceStates_Unselected;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.Selected)
			            configurationCriteria[i].State = ConfiguratorVariables.PersistenceStates_Selected;
			    }

			    return configurationCriteria;
			},

			convertPersistedStatesToStatesInConfigCriteria: function (configurationCriteria) {

			    for (var i = 0; i < configurationCriteria.length; i++) {

			        if (configurationCriteria[i].State == ConfiguratorVariables.PersistenceStates_Chosen)
			            configurationCriteria[i].State = ConfiguratorVariables.Chosen;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.PersistenceStates_Required)
			            configurationCriteria[i].State = ConfiguratorVariables.Required;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.PersistenceStates_Default)
			            configurationCriteria[i].State = ConfiguratorVariables.Default;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.PersistenceStates_Dismissed)
			            configurationCriteria[i].State = ConfiguratorVariables.Dismissed;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.PersistenceStates_Incompatible)
			            configurationCriteria[i].State = ConfiguratorVariables.Incompatible;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.PersistenceStates_Unselected /*|| configurationCriteria[i].State == "included"*/)
			            configurationCriteria[i].State = ConfiguratorVariables.Unselected;
			        else if (configurationCriteria[i].State == ConfiguratorVariables.PersistenceStates_Selected)
			            configurationCriteria[i].State = ConfiguratorVariables.Selected;
			    }

			    return configurationCriteria;
			},

			getDefaultImage: function () {
			    var image = '';

			    if (this._serviceUrl != null) {
			        image = this._serviceUrl + "/snresources/images/icons/large/iconLargeDefault.png";
			    }

			    return image;
			},

			getServiceUrl: function() {
			    return this._serviceUrl;
			},

			setSecurityContext: function () {

				var that = this;
				var securityContextWSCall = function() {
				    var response = null;
				    var _securityCntxt = undefined;   //widget.getValue('SC');
				    if ((_securityCntxt != null) && (_securityCntxt != undefined) && (_securityCntxt != "")) {
					    response = "ctx::" + _securityCntxt;
					    that._securityContext = response;
				    }
				    else {
					    var getSecurityContextURL = "/resources/pno/person/getsecuritycontext";
					    var onCompleteCallBack = function (securityContextDetails) {
						    response = securityContextDetails.SecurityContext;
					        if (!response || response == null) {
					        }
					        else {
							        if (securityContextDetails != null && securityContextDetails != "" && securityContextDetails.hasOwnProperty("SecurityContext")) {
							          var prefix = "";
							          if (securityContextDetails.SecurityContext.indexOf("ctx::") != 0)  //ctx:: is mandatory. In some serveur, this ctx doesn't exist
							           prefix = 'ctx::';
							           response = prefix + securityContextDetails.SecurityContext;
							        }
							        console.log("Setting security Context: " + response);
							        that._securityContext = securityContextDetails.SecurityContext;
						        }
					    };
					    var onFailure = function (e) {console.log('getSecurityContext:Failure...' + e);};
						that.wafAuthenticatedRequest(that._serviceUrl + getSecurityContextURL, {
						    method : 'GET',
						    type:'json',
							async : true ,
						    proxy:'passport',
							header:{
								"Content-Type":  'json'
							},
						    onComplete : onCompleteCallBack,
						    onFailure : onFailure,
						    timeout: 5000
						    });

					    }
				}

				if(that._serviceUrl == null){
						var parameters = {
							serviceName : '3DSpace',
							platformId : "",    //widget.getValue('x3dPlatformId'),
							onComplete : function(URLResult) {
								if (typeof URLResult === "string") {
									that._serviceUrl = URLResult;
								} else {
									that._serviceUrl = URLResult[0].url;
								}

								that._tenant = URLResult[0]["platformId"];
								// if(that.receivedTenant && tenant !== "OnPremise"){
								// 	that._tenant = that.receivedTenant;
								// }
								/** Added for multitenant issue **/
								if(that.receivedTenant !== "OnPremise"){
									var count, data = URLResult || [];
									for (count = 0; count < data.length; count++) {
	                  if (that.receivedTenant == data[count]["platformId"]) {
	                      that._serviceUrl  = data[count].url;
	                      that._tenant = data[count]["platformId"];
	                  }
	                }
								}
								securityContextWSCall(that);

							},
							onFailure : function() {
								console.log("Service initialization failed...");
							}
					};

					objCancel = i3DXCompassServices.getServiceUrl(parameters);
				}else {
					securityContextWSCall(that);
				}

			},

			getSecurityContext: function () {
			    return this._securityContext;
			},

			wafAuthenticatedRequest: function (url, obj, timeout) {

				var timestamp = new Date().getTime();

				/**In case the url has attributes, append the tenant and timestamp accordingly*/
				if (url.indexOf("?") == -1) {
					url = url + "?tenant=" + this._tenant + "&timestamp=" + timestamp;
				}
				else {
					url = url + "&tenant=" + this._tenant + "&timestamp=" + timestamp;
				}
				//setTimeout(function(){
					WAFData.authenticatedRequest(url, obj);
				//},timeout);

			}


	};


	return UWA.namespace('DS/ConfiguratorPanel/Utilities', Utilities);
});

define(
    'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
    [
    ],
    function()
	{
		var ConfiguratorVariables =  {
			Unselected : 'Unselected',
			UnselectedMandatory : 'Unselected Mandatory',
			SelectionInConflict : 'Selection In Conflict',
			ChosenByTheUser : 'Chosen by the user',
			RequiredByRules : 'Required by rules',
			DefaultSelected : 'Default selected',
			ProposedByOptimization : 'Proposed by optimization',
			DismissedByTheUser : 'Dismissed by the user',
			NoFilter : 'No filter',
			
			BuildConfiguration : 'Build Configuration',
			RefineConfiguration : 'Refine Configuration',
			
			ProposeOptimizedConfiguration : 'Propose optimized configuration',
			SelectCompleteConfiguration : 'Select complete configuration',
			EnforceRequiredOptionsAndSelectDefault : 'Enforce required options and select default',
			DisableIncompatibleOptions : 'Disable incompatible options',
			NoRuleApplied : 'No rule applied',
			
			select : 'select',	
			reject : 'reject',
			
			str_yes : 'yes',
			str_no 	: 'no',
			
			str_true	: 'true',
			str_false	: 'false',
			
			Complete	: 'Complete',
			Hybrid 		: 'Hybrid',
			Partial 	: 'Partial',
			
			Invalid : 'Invalid',
			Valid : 'Valid',
			
			Unknown : 'Unknown',
			
			Unselected : 'Unselected',
			Chosen : 'Chosen',
			Default : 'Default',
			Required : 'Required',
			Selected : 'Selected',
			Dismissed : 'Dismissed',
			Incompatible : 'Incompatible',
			Conflict : 'Conflict',
			Range : 'range',
			Included : 'Included',
			
			selectionMode_Build : 'selectionMode_Build',
			selectionMode_Refine : 'selectionMode_Refine',
			
			RulesMode_ProposeOptimizedConfiguration : 'RulesMode_ProposeOptimizedConfiguration',
			RulesMode_SelectCompleteConfiguration : 'RulesMode_SelectCompleteConfiguration',
			RulesMode_EnforceRequiredOptions : 'RulesMode_EnforceRequiredOptions',
			RulesMode_DisableIncompatibleOptions : 'RulesMode_DisableIncompatibleOptions',
			
			
			cookie_Products : "DS_ConfiguratorCookie_AppStore_Products",
			cookie_PCs : "DS_ConfiguratorCookie_AppStore_PCs",
			cookie_PhyProducts : "DS_ConfiguratorCookie_AppStore_PhyProducts",
			
			type_HardwareProduct : "Hardware Product",
			type_ProductReference : "VPMReference",
			type_ProductConfiguration : "Product Configuration",
			
			str_create : 'create',
			str_delete : 'delete',
			str_list : 'list',
			str_plus : 'plus',
			str_trash : 'trash',
			str_help : 'help',
			str_star : 'star',
			str_user : 'user',
			str_none : 'none',
			str_ERROR : 'ERROR',
			
			
			
			PersistenceStates_Unselected: 'available',
			PersistenceStates_Chosen: 'chosen',
			PersistenceStates_Default: 'default',
			PersistenceStates_Required: 'required',
			PersistenceStates_Selected: 'recommanded',
			PersistenceStates_Dismissed: 'dismissed',
			PersistenceStates_Incompatible: 'incompatible',

			Single: "Single",
            Multiple: "Multiple",
			
            Filter_AllVariants  : 'topbar-allVariants',
            Filter_Conflicts : 'topbar-conflictingSelections',
            Filter_Rules : 'topbar-rulesDeduction',
            Filter_Unselected : 'topbar-unselectedFeatures',
            Filter_Mand : 'topbar-unselectedMandatory'
			
		};
		
		return ConfiguratorVariables;
	}
    
);


define('DS/ConfiguratorPanel/scripts/Presenters/SelectionStateTweaker',
  [
      'DS/Controls/Abstract',
      'DS/Handlebars/Handlebars',
      'DS/Tweakers/TweakerBase',
      'DS/Utilities/Utils',
      'DS/Controls/Button',
      'DS/Controls/SpinBox',
      'text!DS/ConfiguratorPanel/html/SelectionState.html',
      'css!DS/ConfiguratorPanel/css/SelectionStateTweaker.css'
  ], function(Abstract, Handlebars, TweakerBase, Utils, Button, SpinBox, html_selectionControl) {

    'use strict';

    var STATES = {
      AVAILABLE : 'Available',
      DEFAULT : 'Default',
      REQUIRED : 'Required',
      CHOSEN : 'Chosen',
      SELECTED : 'Selected',
      UNSELECTED : 'Unselected',
      INCOMPATIBLE : 'Incompatible',
      DISMISSED : 'Dismissed',
      USER_DISMISS : 'UserDismiss',
      CONFLICT : 'Conflict'
    };


    var SelectionStateTweaker = TweakerBase.inherit({

       name: 'contextualMenu',

       publishedProperties: {
        label: {
          defaultValue: '',
          type: 'string'
        },
        icon: {
          defaultValue: {
            iconName : '',
            fontIconFamily: WUXManagedFontIcons.Font3DS
          },
          type: 'string'
        },
        displayStyle: {
          defaultValue: 'editableState',
          type: 'string',
          category: 'Appearance'
        },
        contentType : {
          defaultValue: '',
          type: 'string'
        },
      },

      init : function () {
        this.STATE_ICONS = {};
        var iconOptions = {
          iconName : '',
          fontIconFamily : WUXManagedFontIcons.Font3DS,
        }
        this.STATE_ICONS[STATES.AVAILABLE] = UWA.merge({ iconName : 'check'}, iconOptions);
        this.STATE_ICONS[STATES.DEFAULT] = UWA.merge({ iconName : 'favorite-on'}, iconOptions);
        this.STATE_ICONS[STATES.REQUIRED] = UWA.merge({ iconName : 'lock'}, iconOptions);
        this.STATE_ICONS[STATES.CHOSEN] = UWA.merge({ iconName : 'check'}, iconOptions);
        this.STATE_ICONS[STATES.SELECTED] = UWA.merge({ iconName : 'lightbulb'}, iconOptions);
        this.STATE_ICONS[STATES.UNSELECTED] = UWA.merge({ iconName : 'check'}, iconOptions);
        this.STATE_ICONS[STATES.INCOMPATIBLE] = UWA.merge({ iconName : 'block'}, iconOptions);
        this.STATE_ICONS[STATES.DISMISSED] = UWA.merge({ iconName : 'user-delete'}, iconOptions);
        this.STATE_ICONS[STATES.USER_DISMISS] = UWA.merge({ iconName : 'user-delete'}, iconOptions);
        this.STATE_ICONS[STATES.CONFLICT] = UWA.merge({ iconName : 'alert'}, iconOptions);
        this._parent.apply(this, arguments);
      },

      // _applyReferenceValue : function () {
      //   console.log('referenceValue changes');
      //   if(this.contentType !='Parameter' && !UWA.equals(this.value, this.referenceValue)) {
      //       this.value = this.referenceValue;
      //   }
      // }

    });

    //build state control

    var SelectionStateControl = Abstract.inherit({
        publishedProperties: {
          value : {
            defaultValue: '',
            type: 'string',
          },
          contentType : {
            defaultValue: '',
            type: 'string',
          },
          context : {
            defaultValue: '',
            type: 'object',
          },
        },
        buildView : function () {
          var template = Handlebars.compile(html_selectionControl);
          this.getContent().addClassName('selection-state-control');
          this.getContent().innerHTML = template();

          this._iconButton = new Button({
            displayStyle : 'lite'
          });

          this._rejectButton = new Button({
            displayStyle : 'lite',
            icon : {
              iconName : 'close',
              fontIconFamily : WUXManagedFontIcons.Font3DS,
            }
          });

          this._actionDiv = this.getContent().getElement('.action-icon-content');
          this._stateDiv = this.getContent().getElement('.state-icon-content');
          this._iconButton.inject(this.getContent().getElement('.state-icon-content'));
          this._rejectButton.inject(this.getContent().getElement('.action-icon-content'));

          this._stateContainer = this.getContent().getElement('.selection-state-container');

          this._valueContent = new SpinBox({
            fireOnlyFromUIInteractionFlag : true
          });
          this._unitContent = this.getContent().getElement('.state-value-unit ')
          this._stateValueContainer = this.getContent().getElement('.state-value-content');
          this._valueContent.inject(this._stateValueContainer);
          // this.elements.container = UWA.createElement('div', { 'class' : 'selection-state-container'});
        },

        _applyValue : function () {
          this._iconButton.icon = this.value;
          this._valueContent.value = this.value;
        },

        _applyContentType : function () {
          if(this.contentType == 'Parameter') {
            this._stateContainer.addClassName('value-content');
          } else {
            this._stateContainer.removeClassName('value-content');
          }
        },
        _applyContext : function () {
          this._updateView();
        },

        _updateView : function () {
          if(this.context.nodeModel.getAttributeValue('type') == 'Parameter') {
            this._stateContainer.addClassName('value-content');
            this._valueContent.value = this.value;
            this._valueContent.minValue = this.context.nodeModel.getAttributeValue('minValue');
            this._valueContent.maxValue = this.context.nodeModel.getAttributeValue('maxValue');
            this._valueContent.stepValue = this.context.nodeModel.getAttributeValue('stepValue');
            this._unitContent.setContent(this.context.nodeModel.getAttributeValue('nlsUnit') || '');
          } else {
            this._stateContainer.removeClassName('value-content');
          }

        }

    });

    var BaseViewModuleTweaker = function(tweaker, options) {
  	  TweakerBase.prototype.baseViewModule.call(this, tweaker, options);
  	};
  	Utils.applyMixin(BaseViewModuleTweaker, TweakerBase.prototype.baseViewModule);

    var ReadOnlyStateViewModule = function(tweaker, options) {
  		BaseViewModuleTweaker.call(this, tweaker, options);
  	};
  	Utils.applyMixin(ReadOnlyStateViewModule, BaseViewModuleTweaker);

    ReadOnlyStateViewModule.prototype.buildView = function() {
  		if (!this._tweaker.elements.container) {
  			return;
  		}

      var options = UWA.merge({}, this._options.viewOptions);
      options.touchMode = this._tweaker._getCurrentTouchMode();
      options.displayStyle = 'lite';
      // options.icon = 'check';
      options.icon = '';
      // options.disabled = true;
      if(this._tweaker.value) {
        options.icon = this._tweaker.STATE_ICONS[this._tweaker.value];
      }
      this._iconButton = new Button(options);
      this._view = UWA.createElement('div', { 'class' : 'selection-state-control read-only', html: this._iconButton});
      //this._view = new Button(options);

      this.setValue(this._tweaker.value);
  	};

    ReadOnlyStateViewModule.prototype.setValue = function() {
      if (!this._view && !this._iconButton) {
        return;
      }
      if(this._tweaker.value) {
        this._iconButton.icon = this._tweaker.STATE_ICONS[this._tweaker.value];
      } else {
        this._iconButton.icon = '';
      }
  	}


    var EditableStateViewModule = function(tweaker, options) {
  		BaseViewModuleTweaker.call(this, tweaker, options);
  	};
  	Utils.applyMixin(EditableStateViewModule, BaseViewModuleTweaker);

    EditableStateViewModule.prototype.buildView = function() {
  		if (!this._tweaker.elements.container) {
  			return;
  		}

      var options = UWA.merge({}, this._options.viewOptions);
      options.touchMode = this._tweaker._getCurrentTouchMode();
      options.displayStyle = 'lite';
      options.icon = '';
      if(this._tweaker.value) {
        options.icon = this._tweaker.STATE_ICONS[this._tweaker.value];
      }
      this._iconButton = new Button(options);
      this._rejectButton = new Button({
        displayStyle : 'lite',
        touchMode : this._tweaker._getCurrentTouchMode(),
        icon : 'close'
      });
      this._stateDiv = UWA.createElement('div', {
        'class' : 'state-icon-content',
        html: this._iconButton
      });
      this._actionDiv = UWA.createElement('div',{ 'class' : 'action-icon-content', html: this._rejectButton } );
      this._spinBox = new SpinBox({touchMode : this._tweaker._getCurrentTouchMode()});
      this._stateView = UWA.createElement('div', {
        'class' : 'editable-state-tweaker',
        html: [this._stateDiv, this._actionDiv]
      });
      this._view = this._stateView;
      this._view = new SelectionStateControl({value :this._tweaker.value});
      this.setValue(this._tweaker.value);
  	};

    EditableStateViewModule.prototype.handleEvents = function() {
      var that = this;
      var view = this._view;

      var context = this._tweaker.context;

      if(view) {
        this._view._iconButton.addEventListener('buttonclick', function (e) {
          console.log(that);
          // that._tweaker.value = STATES.CHOSEN;
          if(that._tweaker.context) {
            that._tweaker.context.nodeModel.getModelEvents().publish({
              'event' : 'state-change-action',
              data : { referenceValue : that._tweaker.value },
              context : that._tweaker.context
            });
          }
        });

        this._view._rejectButton.addEventListener('buttonclick', function (e) {
          if(that._tweaker.context) {
            that._tweaker.context.nodeModel.getModelEvents().publish({
              'event' : 'state-remove-action',
              data : { referenceValue : that._tweaker.value },
              context : that._tweaker.context
            });
          }
        });

        if(this._view._valueContent) {
          this._view._valueContent.addEventListener('change', function (evtData) {
            evtData.stopPropagation();
          });
          this._view._valueContent.addEventListener('endEdit', function(evtData) {
            evtData.stopPropagation();
            console.log('valueChange');
            if(that._tweaker.context) {
              that._tweaker.context.nodeModel.getModelEvents().publish({
                'event' : 'value-change-action',
                data : { referenceValue : that._tweaker.value, value : evtData.dsModel.value },
                context : that._tweaker.context
              });
            }
          });
        }
      }
    };

    EditableStateViewModule.prototype.setValue = function() {
      if (!this._view) {
        return;
      }

      this._view.contentType = this._tweaker.contentType;

      this._view.context = this._tweaker.context;

      this._view.value = this._tweaker.value;

      if(this._tweaker.value) {
        this._view._iconButton.icon = this._tweaker.STATE_ICONS[this._tweaker.value];
        this._view._iconButton.disabled = false;

        if(this._tweaker.value == STATES.AVAILABLE || this._tweaker.value == STATES.UNSELECTED) {
          this._view._actionDiv.setStyle('visibility', 'hidden');
          this._view._stateDiv.addClassName('available-state');
          this._view._stateDiv.removeClassName('disable-state-change');
        } else {
          if(this._tweaker.value == STATES.REQUIRED) {
            this._view._actionDiv.setStyle('visibility', 'hidden');
          } else if(this._tweaker.value == STATES.INCOMPATIBLE) {
            this._view._actionDiv.setStyle('visibility', 'hidden');
            this._view._iconButton.disabled = true;
          } else if(this._tweaker.value == STATES.DISMISSED) {
            this._view._iconButton.disabled = true;
            this._view._actionDiv.setStyle('visibility', 'visible');
          } else {
            this._view._actionDiv.setStyle('visibility', 'visible');
          }

          if(this._tweaker.value == STATES.CHOSEN || this._tweaker.value == STATES.SELECTED ) {
            this._view._stateDiv.addClassName('disable-state-change');
          } else {
            this._view._stateDiv.removeClassName('disable-state-change');
          }

          if(this._tweaker.value == STATES.CONFLICT) {
            this._view._stateDiv.addClassName('conflict-state');
          } else {
            this._view._stateDiv.removeClassName('conflict-state');
          }
          this._view._stateDiv.removeClassName('available-state');
        }
      } else {
        this._view._actionDiv.setStyle('visibility', 'hidden');
        this._view._iconButton.disabled = true;
      }
    };

    EditableStateViewModule.prototype._applyContentType = function () {
      if(this._tweaker.contentType == 'Parameter') {
        this._view = this._spinBox;
      } else {
        this._view = this._stateView;
      }
    };

    EditableStateViewModule.prototype._updateView = function () {
      console.log('updateView');
    };

    EditableStateViewModule.prototype.removeEvents = function () {
      if (!this._view) {
        return;
      }
      this._view._iconButton.removeEventListener('buttonclick');
      this._view._rejectButton.removeEventListener('buttonclick');

      if(this._view._valueContent) {
        this._view._valueContent.removeEventListener('change');
        this._view._valueContent.removeEventListener('endEdit');
      }
    };

    SelectionStateTweaker.prototype.baseViewModule = BaseViewModuleTweaker;

    SelectionStateTweaker.prototype.VIEW_MODULES = {
      'editableState' : {classObject: EditableStateViewModule, options: {viewOptions: {}, displayStyle : 'editableState' }},
      'readOnly': { classObject: ReadOnlyStateViewModule, options: {viewOptions: {}}}
  	};

  	return SelectionStateTweaker;
});

/*********************************************************************/
/*@fullReview XF3 21/05/2016
/*********************************************************************/

define('DS/ConfiguratorPanel/scripts/ConfiguratorSolverFunctionsV2',
['UWA/Core',
'DS/CfgSolver/CfgSolverServices',
'DS/CfgSolver/CfgSolverDebug',
// 'DS/xPortfolioQueryServices/js/xPortfolioModel',
'DS/ConfiguratorPanel/scripts/Utilities',
'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
'DS/UIKIT/Mask',
'DS/UIKIT/Alert',
'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json'
],
function (UWA,  CfgSolverServices,CfgSolverDebug,
  // xPortfolioModel,
  Utilities, ConfiguratorVariables, Mask, Alert, nlsConfiguratorKeys) {

    var ConfiguratorSolverFunctions = {
        solverCreated: false,
        solverKey: '',
        solverNode: null,
        solverId: '',
        configModel: null,
        modelEvents: null,
        parentContainer: null,

        initSolver: function (modelId, configModel, modelEvents, configCriteria, parentContainer, options) {
            var myDico;
            var that = this;
            this.configModel = configModel;
            this.modelEvents = modelEvents;
            this.modelId = modelId;
            this.parentContainer = (parentContainer) ? parentContainer : document.body;
            this.dictionary = options.dictionary;
            if(options && options.tenant){
      				this.tenant =options.tenant;
      			}else {
      				this.tenant = "OnPremise";
      			}
      			if(options && options.version){
      				this.version =options.version;
      			}else {
      				this.version = "V1";
      			}

            this.modelEvents.subscribe({ event: 'OnMultiSelectionChange' }, function (data) {
                that.SetMultiSelectionOnSolver(data.value);
            });

            this.modelEvents.subscribe({ event: 'OnRuleAssistanceLevelChange' }, function (data) {
                if (data.value != ConfiguratorVariables.NoRuleApplied)
                    that.setSelectionModeOnSolver(data.value, true);
            });

            this.modelEvents.subscribe({ event: 'SolverFct_getResultingStatusOriginators' }, function (data) {
                that.getResultingStatusOriginators(data.value);
            });

            this.modelEvents.subscribe({ event: 'SolverFct_CallSolveMethodOnSolver' }, function (data) {
                that.abortSolverCall();
                that.CallSolveMethodOnSolver();
            });

            if(this.version !== "V4"){
              return CfgSolverServices.initSolver({modelId: modelId, data: {"configurationCriteria":configCriteria
            }, tenant : that.tenant}).then(function(data){
                return CfgSolverServices.hypervisordetails().then(function(HypervisorDetails){
                  that.solverKey = HypervisorDetails.solverKey;
                  that.activateSolverDebug();
                  setDictionaryForDashboard(data);
                });
              });
            }else{
              return CfgSolverServices.create({tenant : that.tenant}).then(function (data) {
                  that.solverKey = data.solverKey;
                  that.activateSolverDebug();
                  return CfgSolverServices.initialize({ solverKey: data.solverKey, jsonData: that.dictionary }).then(function () {
                      setDictionaryForDashboard({ dictionary: that.dictionary });
                  })
              });
            }

            function setDictionaryForDashboard(dictionaryData) {
                console.log("*********SolverKey:" + that.solverKey);
                that.configModel.setDictionary(dictionaryData.dictionary);
                that.solverCreated = true;
                var dictionary = that.configModel.getDictionary();

                window.addEventListener("unload", function (e) {
                    that.releaseSolver();
                });
                window.top.addEventListener("unload", function (e) {
                    that.releaseSolver();
                });

                that.setAlwaysDiagnosed(dictionary);
                that.CheckRulesConsistency();
                that.setSelectionModeOnSolver(that.configModel.getRulesMode());

                if(that.version === "V1" || that.version === "V2"){
                   var multiSelState = (that.configModel.getMultiSelectionState() == "true")? "true":"false";
                   that.SetMultiSelectionOnSolver(multiSelState, {firstCall : true});
                }else if(that.version === "V3" || that.version === "V4"){
                  if (that.configModel.getAppFunc().multiSelection === ConfiguratorVariables.str_yes || that.configModel.getAppFunc().selectionMode_Refine === ConfiguratorVariables.str_yes) {
                    that.SetMultiSelectionOnSolver("true", {firstCall : true});
                  }else{
                    that.SetMultiSelectionOnSolver("false", {firstCall : true});
                    if(that.configModel.getAppRulesParam() && that.configModel.getAppRulesParam().completenessStatus === "Hybrid"){
                      Utilities.displayNotification({eventID: 'warning',msg: nlsConfiguratorKeys.HybridWarningInRealistic});
                    }
                  }
                }


                that.defaultImage = CfgSolverServices.getDefaultImage();
                return UWA.Promise.resolve({
                    dictionary: dictionary,
                    solverKey: that.solverKey
                });
            }

            function showFailureMessage(msg) {
                console.log("failed while getting initdata =" + msg);
            }
        },

        getDefaultImage : function(){
          return this.defaultImage;
        },

        activateSolverDebug : function(){
            var solverTraces = window.sessionStorage['solver-activate-traces'];//false; // true to activate solver traces.. may need to be a local storage ot smtg
            if (solverTraces) {
                this._CfgSolverDebug = new CfgSolverDebug();
                this._CfgSolverDebug.init2('configurator', this.solverKey);
                this._CfgSolverDebug.injectIn(document.body);
            }
        },

        releaseSolver: function () {
            var that = this;
            CfgSolverServices.release(this.solverKey);
        },

        CallSolveMethodOnSolver: function (options) {
            var that = this;
            if (this.solverCreated) {
                if (this.configModel.getRulesActivation() == "true") {
                    //Mask.mask(this.parentContainer);

                    var requestData = { "configurationCriteria": this.configModel.getConfigurationCriteria() };

                    CfgSolverServices.CallSolveMethodOnSolver(requestData, that.solverKey).then(function (data) {
                        that.ApplyAnswer(data,options);
                    }, function () { });
                }else {
                  if(options.firstCall){
                    this.modelEvents.publish({event:'solver_init_complete', data:{}});
                  }
                }
            }
        },

        setSelectionModeOnSolver: function (newMode, callSolveAfterSolverResult) {
            var that = this;
            if (this.solverCreated) {
              if (newMode != ConfiguratorVariables.NoRuleApplied){
                if (newMode == ConfiguratorVariables.RulesMode_DisableIncompatibleOptions)
                    newMode = "Select_None";
                else if (newMode == ConfiguratorVariables.RulesMode_EnforceRequiredOptions)
                    newMode = "Select_RequiredAndDefault";
                else if (newMode == ConfiguratorVariables.RulesMode_SelectCompleteConfiguration)
                    newMode = "Select_ProposedSelection";
                else if (newMode == ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration)
                    newMode = "Select_OptimalSelection";

                CfgSolverServices.setSelectionModeOnSolver(newMode, that.solverKey).then(function (data) {
                that.ApplyAnswer(data, callSolveAfterSolverResult);
                }, function () { });
              }
          }
        },

        getResultingStatusOriginators: function (optionId) {
            var that = this;
            CfgSolverServices.getResultingStatusOriginators(optionId, this.solverKey).then(function (data) {
                that.ApplyAnswer(data);
            }, function () { });
        },

        abortSolverCall: function (optionId) {
            CfgSolverServices.abortSolverCall(this.solverKey);
        },

        CheckRulesConsistency: function () {
            var that = this;
            if (this.solverCreated) {
                CfgSolverServices.CheckRulesConsistency(this.solverKey).then(function (data) {
                    that.ApplyAnswer(data);
                }, function () { });
            }
        },

        SetMultiSelectionOnSolver: function (booleanValue, callSolveAfterSolverResult) {
            var that = this;
            if (this.solverCreated) {
                CfgSolverServices.SetMultiSelectionOnSolver(booleanValue, this.solverKey).then(function (data) {
                    that.ApplyAnswer(data, callSolveAfterSolverResult)
                });
            }
        },

        setAlwaysDiagnosed: function (dictionary) {
            if (this.solverCreated) {
                var features = [];
                var dictionary = this.configModel.getDictionary() || { features: [] };
                var dictionaryFeatures = dictionary.features;

                for (var i = 0; i < dictionaryFeatures.length; i++) {
                    features.push(dictionaryFeatures[i].ruleId);
                }
                return CfgSolverServices.setAlwaysDiagnosed(features, this.solverKey);
            }
        },


        ApplyAnswer: function (input, in_callSolveAfterSolverResult) {
          var ret = true;
          var callSolveAfterSolverResult;
          var firstCall = false;
          // Mask.unmask(this.parentContainer);
          if (in_callSolveAfterSolverResult != undefined) {
            callSolveAfterSolverResult = in_callSolveAfterSolverResult;
          }
          if(in_callSolveAfterSolverResult && in_callSolveAfterSolverResult.firstCall){
            firstCall = true;
          }

            if (input != undefined && input != "" && UWA.typeOf(input) === "string") {
                var inputbis = JSON.parse(input);

                var answerMethod = inputbis._answer;
                var answerData = inputbis._data;
                var answerRC = inputbis._rc;

                if (answerMethod == "getResultingStatusOriginators") {

                    var listIncompatibilities = answerData.listOfIncompatibilitiesIds;
                    var optionSelected = answerData.optionSelected;

                    this.modelEvents.publish({
                        event: 'getResultingStatusOriginators_SolverAnswer',
                        data: {
                            listOfIncompatibilitiesIds: listIncompatibilities,
                            optionSelected: optionSelected,
                            answerRC: answerRC
                        }
                    });

                    //Mask.unmask(this.parentContainer);
                }
                else if (answerMethod === "checkMatrixRuleValidity") {
                    console.log(answerData);
                    answerData.version = inputbis._version;
                    answerData._clientData = inputbis._clientData;
                    if (answerData._clientData.type === "validityWithCause") {
                        this.modelEvents.publish({
                            event: 'checkMatrixRuleValidity_SolverReason',
                            data: {
                                answerData: answerData,
                            }
                        });
                    } else {
                        if (in_callSolveAfterSolverResult) {	//if callback provided then call the callback, else publish an event
                            in_callSolveAfterSolverResult(answerData);
                        } else {
                            this.modelEvents.publish({
                                event: 'checkMatrixRuleValidity_SolverAnswer',
                                data: {
                                    answerData: answerData,
                                }
                            });
                        }
                    }

                    //Mask.unmask(this.parentContainer);
                } else if (answerMethod == "ruleActivation") {
                    if (in_callSolveAfterSolverResult) {	//if callback provided then call the callback, else publish an event
                        in_callSolveAfterSolverResult(inputbis._rc);
                    }
                    //Mask.unmask(this.parentContainer);
                } else if (answerMethod === "removeData") {
                    if (in_callSolveAfterSolverResult) {	//if callback provided then call the callback, else publish an event
                        in_callSolveAfterSolverResult(inputbis._rc);
                    }
                    //Mask.unmask(this.parentContainer);
                }

                else if (answerMethod == "checkModelConsistency") {

                    if (answerRC == "Rules_KO" || answerRC == "ERROR") {
                        this.configModel.setRulesConsistency(false);
                        if (this.configModel.setRulesActivation) {
                            this.configModel.setRulesActivation("false");

                            var message = nlsConfiguratorKeys.InfoInconsistentRules;

                            var listOfInconsistentRules = answerData.listOfInconsistentRulesIds;
                            if (listOfInconsistentRules.length > 0) {
                                message += "<br>" + nlsConfiguratorKeys.ImpliedRules + ":<br>";
                                for (var i = 0; i < listOfInconsistentRules.length; i++) {
                                    message += "<blocquote style='padding-left:20px;'>" + listOfInconsistentRules[i] + "<br></blocquote>";
                                }
                            }
                            if (answerRC == "ERROR") {
                                message += "<br>" + nlsConfiguratorKeys.InfoComputationAborted;
                            }
                            Utilities.displayNotification({eventID: 'info',msg: message});
                        }
                        else this.configModel.setRulesConsistency(true);

                        this.modelEvents.publish({
                            event: 'checkModelConsistency_SolverAnswer',
                            data: {answerRC: answerRC}
                        });
                    }
                }

                else if (answerMethod == "solveAndDiagnoseAll") {

                    var answerConfigCriteria = answerData.configurationCriteria;
                    var answerModifiedAssumptions = answerData.modifiedAssumptions;
                    var answerConflicts = answerData.conflicts;
                    var answerDefaults = answerData.defaults;

                    if (answerConflicts) {
                        if (answerRC === "ERROR") {
                            Utilities.displayNotification({eventID: 'info',msg: nlsConfiguratorKeys.InfoComplexityOfRules});
                        }
                        var listOfListOfConflictingIds = answerConflicts.listOfListOfConflictingIds;
                        var listOfListOfImpliedRules = answerConflicts.listOfListOfImpliedRules;
                        this.configModel.setConfigurationCriteria(answerConfigCriteria);
                        this.configModel.setImpliedRules(listOfListOfImpliedRules);
                        this.configModel.setConflictingFeatures(listOfListOfConflictingIds);
                        this.configModel.setRulesCompliancyStatus("Invalid");
                    }

                    else if (answerConfigCriteria) {	// No conflict found during resolution
                        this.configModel.setConfigurationCriteria(answerConfigCriteria);
                        this.configModel.setConflictingFeatures(null);
                        this.configModel.setRulesCompliancyStatus("Valid");
                    }

                    else if (answerDefaults) {
                      this.configModel.setDefaultCriteria(answerDefaults);
                    }

                    if (answerModifiedAssumptions.length > 0) {		// Some assumptions have been modified during resolution
                        var message = nlsConfiguratorKeys.InfoIdsIncompatibles + "<br>";
                        for (var i = 0; i < answerModifiedAssumptions.length; i++) {
                            message += "<blocquote style='padding-left:20px;'>" + this.configModel.getFeatureDisplayNameWithId(answerModifiedAssumptions[i]) + "[" + this.configModel.getOptionDisplayNameWithId(answerModifiedAssumptions[i]) + "]<br></blocquote>";
                        }
                        Utilities.displayNotification({eventID: 'info',msg: message});
                    }
                    var dataToShate = {
                      answerDefaults : answerDefaults,
                      answerConflicts : answerConflicts,
                      answerRC : answerRC
                    }
                    if(firstCall){
                      this.modelEvents.publish({event:'solver_init_complete', data:dataToShate});
                    }else{
                      this.modelEvents.publish({event:'solveAndDiagnoseAll_SolverAnswer', data:	dataToShate});
                    }
                }

                else if (answerMethod == "setSelectionMode" && callSolveAfterSolverResult) {
                  this.CallSolveMethodOnSolver();
                }

                else if (answerMethod == "setMultiSelection" && callSolveAfterSolverResult) {
                  if(callSolveAfterSolverResult.firstCall)
                    this.CallSolveMethodOnSolver(callSolveAfterSolverResult);
                  else
                    this.CallSolveMethodOnSolver();
                }

                else if (answerRC == "ERROR") {// GENERIC ERROR MSG
                    console.log("Error during solver resolution");
                }
            }

            return ret;
        }
    };


    return UWA.namespace('DS/ConfiguratorPanel/ConfiguratorSolverFunctionsV2', ConfiguratorSolverFunctions);
});

/*
	FilterExpressionXMLServices.js
	To convert configurator json to xml for binary creation

*/

define('DS/ConfiguratorPanel/scripts/Models/FilterExpressionXMLServicesWithDisplayName',
[
	'UWA/Core',
	'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables'
],
function (UWA, ConfiguratorVariables) {

    function FilterExpressionXMLServicesWithDisplayName(xmlType)
    {
	    var AppRulesParamObj = new Object();
	    var AppFuncObj =  new Object();
	    var DictionaryObj = new Object();
	    var ConfigCriteriaObj =  new Object();
	    var XML_FILE_TYPE = new Object();
	    var EvolutionCriteriaObj = new Object();
	    var ModelVersionInfoObj = new Object();
	    var FILTER_SELECTION_MODE = '';
	    var listOfRejectedOptionsForEachSingleFeature = new Object();     //XF3
	    var listOfRejectedOptionsStateForEachSingleFeature = new Object();     //XF3

	    var XML_TAG_NAMES = {
		    FilterSelection : 'FilterSelection',
		    Context : 'Context',
		    CfgFilterExpression : 'CfgFilterExpression',
		    Feature : 'Feature'
	    };

	    var ATTR_VALUE_MAP = {
		    selectionMode	 : "SelectionMode",
		    selectionMode_Build: "Strict",
		    selectionMode_Refine: "150%"

	    }
	    var ATTRNAMES = ['selectionMode'];
	    var CONFIGURATOR_FIELDS = {
		    ConfigurationCriteria :'configurationCriteria',
		    ApplicationState :'applicationState',
		    AppRulesParam : 'app_RulesParam',
		    AppFunc : 'app_Func',
		    Dictionary : 'dictionary',
		    Rules:'rules',
		    EvolutionCriteria: 'evolutionCriteria',
	        ModelVersionInfo:'modelVersionInfo'
	    };

	    var XML_DECLARE = {
		    Schema : "xmlns:xs",
		    Namespace : "xmlns",
		    SchemaLocation : "xs:schemaLocation"
	    };

	    var FILTER_EXPRESSION = {
		    ROOT : "CfgFilterExpression",
		    TAG1 : "FilterSelection",
		    Schema: "http://www.w3.org/2001/XMLSchema-instance",
		    Namespace : "urn:com:dassault_systemes:config",
		    SchemaLocation : "urn:com:dassault_systemes:config CfgFilterExpression.xsd"
	    };
	    initXMLType();
	    function initXMLType(){
		    if(xmlType == 'FilterExpression')
			    XML_FILE_TYPE = FILTER_EXPRESSION;
	    }
	    function initParamObjects(jsonObj)
	    {
		    AppRulesParamObj = jsonObj[CONFIGURATOR_FIELDS.AppRulesParam];
		    AppFuncObj =  jsonObj[CONFIGURATOR_FIELDS.AppFunc];
		    DictionaryObj = jsonObj[CONFIGURATOR_FIELDS.Dictionary];
		    ConfigCriteriaObj =  jsonObj[CONFIGURATOR_FIELDS.ConfigurationCriteria];
		    EvolutionCriteriaObj = jsonObj[CONFIGURATOR_FIELDS.EvolutionCriteria];
		    FILTER_SELECTION_MODE = AppRulesParamObj['selectionMode'];
		    ModelVersionInfoObj = jsonObj[CONFIGURATOR_FIELDS.ModelVersionInfo];
	    }

	    function getXMLDeclaration()
	    {
		    var initXml = '<?xml version="1.0" encoding="UTF-8"?>';
		    var attrList = [];
		    for(var elem in XML_DECLARE)
		    {
			    attrList.push(elem);
		    }
		    initXml += "<"+ XML_FILE_TYPE.ROOT;
		    if(attrList!=null) {
			    for(var item = 0; item < attrList.length; item++) {
				    var key = attrList[item]
				    var attrName = XML_DECLARE[key];
				    var attrVal = FILTER_EXPRESSION[key];
				    //attrVal=escapeXmlChars(attrVal);
				    initXml+=" "+attrName+"='"+attrVal+"'";
			    }
		    }
		    initXml+=">";
		    return initXml;
	    }

	    function jsonXmlElemCount () {
		    var elementsCnt = 0;
		    for( var it in ConfigCriteriaObj  ) {
			    if(ConfigCriteriaObj[it] instanceof Object)
			    {
			        if (ConfigCriteriaObj[it].State == ConfiguratorVariables.Chosen || ConfigCriteriaObj[it].State == ConfiguratorVariables.Required || ConfigCriteriaObj[it].State == ConfiguratorVariables.Default || ConfigCriteriaObj[it].State == ConfiguratorVariables.Selected
					    || ConfigCriteriaObj[it].State == ConfiguratorVariables.Dismissed || ConfigCriteriaObj[it].State == ConfiguratorVariables.Incompatible)
						    elementsCnt++;
				    }
			    }

		    return elementsCnt;
	    }
	    function addAttributes(rulesParamObj,element, attrList, closed) {
		    var resultStr = "<"+ element;
		    if(attrList!=null) {
			    for(var aidx = 0; aidx < attrList.length; aidx++) {
				    var attrName = attrList[aidx];
				    if(ATTR_VALUE_MAP[attrName] != undefined)
				    {
					    var tAttrName = ATTR_VALUE_MAP[attrName];
					    attrVal = ATTR_VALUE_MAP[rulesParamObj[attrName]];
					    attrVal=escapeXmlChars(attrVal);
					    resultStr+=" "+tAttrName+"='"+attrVal+"'";

				    }else
				    {
					    attrVal = rulesParamObj[attrName];
					    attrVal=escapeXmlChars(attrVal);
					    resultStr+=" "+attrName+"='"+attrVal+"'";
				    }

			    }
		    }
		    if(!closed)
			    resultStr+=">";
		    else
			    resultStr+="/>";
		    return resultStr;
	    }

	    function endTag(elementName) {
		    return "</"+ elementName+">";
	    }

	    function escapeXmlChars(str) {
	    if(typeof(str) == "string")
		    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#x27;').replace(/\//g, '&#x2F;');
	    else
		    return str;
	    }

        //XF3 : If selection and reject are present in the same feature, we cannot add the reject in the XML or it will lead to XML parsing issues
	    /*function checkIfSelectionIsPresentInSameFeature(optionId) {
	        var config_features = DictionaryObj.features;
	        for (var itx in config_features) {
	            var cfElem = config_features[itx];
	            var coElem = cfElem['options'];
	            var optionFound = false;

	            if (coElem instanceof Object) {
	                for (var itr in coElem) {
	                    var coid = coElem[itr].ruleId;

	                    if (coid != undefined && coid.toString().trim() == optionId) {
	                        optionFound = true;
	                        break;
	                    }
	                }

	                if (optionFound) {
	                    for (var itr in coElem) {
	                        var coid = coElem[itr].ruleId;

	                        if (coid != undefined) {
	                            for (var it in ConfigCriteriaObj) {
	                                if (ConfigCriteriaObj[it] instanceof Object) {
	                                    var criteriaId = ConfigCriteriaObj[it].Id;
	                                    var state = ConfigCriteriaObj[it].State;

	                                    if (criteriaId == coid && (state == ConfiguratorVariables.Chosen || state == ConfiguratorVariables.Required || state == ConfiguratorVariables.Default || ConfigCriteriaObj[it].State == ConfiguratorVariables.Selected)) {
	                                        return true;
	                                    }
	                                }
	                            }
	                        }
	                    }
	                    break;
	                }
	            }
	        }
	        return false;
	    }*/


	    function checkLevelOfSelectionsInFeature(optionId) {
	        var selectionLevel = 'NoSelection';
	        var config_features = DictionaryObj.features;

	        for (var itx in config_features) {
	            var cfElem = config_features[itx];
	            var coElem = cfElem['options'];
	            var optionFound = false;

	            if (coElem instanceof Object) {
	                for (var itr in coElem) {
	                    var coid = coElem[itr].ruleId;

	                    if (coid != undefined && coid.toString().trim() == optionId) {
	                        optionFound = true;
	                        break;
	                    }
	                }

	                if (optionFound) {
	                    for (var itr in coElem) {
	                        var coid = coElem[itr].ruleId;

	                        if (coid != undefined) {
	                            for (var it in ConfigCriteriaObj) {
	                                if (ConfigCriteriaObj[it] instanceof Object) {
	                                    var criteriaId = ConfigCriteriaObj[it].Id;
	                                    var state = ConfigCriteriaObj[it].State;

	                                    if (criteriaId == coid) {
	                                        if (state == ConfiguratorVariables.Chosen) {
	                                            if (selectionLevel == 'NoSelection' || selectionLevel == 'ruleSelection') {
	                                                selectionLevel = 'userSelection';
	                                            }
	                                            else if (selectionLevel == 'userReject' || selectionLevel == 'userRejectAndRuleSelection') {
	                                                selectionLevel = 'userSelectionAndUserReject';
	                                            }
	                                            else if (selectionLevel == 'ruleReject' || selectionLevel == 'ruleSelectionAndRuleReject') {
	                                                selectionLevel = 'userSelectionAndRuleReject';
	                                            }
	                                        }
	                                        else if (state == ConfiguratorVariables.Required || state == ConfiguratorVariables.Default || state == ConfiguratorVariables.Selected) {
	                                            if (selectionLevel == 'NoSelection') {
	                                                selectionLevel = 'ruleSelection';
	                                            }
	                                            else if (selectionLevel == 'userReject') {
	                                                selectionLevel = 'userRejectAndRuleSelection';
	                                            }
	                                            else if (selectionLevel == 'ruleReject') {
	                                                selectionLevel = 'ruleSelectionAndRuleReject';
	                                            }
	                                        }
	                                        else if (state == ConfiguratorVariables.Dismissed) {
	                                            if (selectionLevel == 'NoSelection' || selectionLevel == 'ruleReject') {
	                                                selectionLevel = 'userReject';
	                                            }
	                                            else if (selectionLevel == 'userSelection' || selectionLevel == 'userSelectionAndRuleReject') {
	                                                selectionLevel = 'userSelectionAndUserReject';
	                                            }
	                                            else if (selectionLevel == 'ruleSelection' || selectionLevel == 'ruleSelectionAndRuleReject') {
	                                                selectionLevel = 'userRejectAndRuleSelection';
	                                            }
	                                        }
	                                        else if (state == ConfiguratorVariables.Incompatible) {
	                                            if (selectionLevel == 'NoSelection') {
	                                                selectionLevel = 'ruleReject';
	                                            }
	                                            else if (selectionLevel == 'userSelection') {
	                                                selectionLevel = 'userSelectionAndRuleReject';
	                                            }
	                                            else if (selectionLevel == 'ruleSelection') {
	                                                selectionLevel = 'ruleSelectionAndRuleReject';
	                                            }
	                                        }
	                                    }
	                                }
	                            }
	                        }
	                    }
	                    break;
	                }
	            }
	        }
	        return selectionLevel;
	    }


        //End XF3

	    function generateFilterXML (){
		    var result = "";
		    result += getXMLDeclaration();
		    result += addAttributes(AppRulesParamObj,XML_FILE_TYPE.TAG1,ATTRNAMES,false);
		    var elementsCnt = jsonXmlElemCount();

	        if (ModelVersionInfoObj != undefined)
		        result += getProdStateXML();

		    if (elementsCnt > 0) {
//		        result += addContext(DictionaryObj.model.label); // Removing optional context because it does not support empty selection (temporary?)
		        //if (EvolutionCriteriaObj != undefined)
		          //  result += getProdStateXML();

		        for (var it in ConfigCriteriaObj) {
		            if (ConfigCriteriaObj[it] instanceof Object) {
		                var criteriaId = ConfigCriteriaObj[it].Id;
		                var state = ConfigCriteriaObj[it].State;

		                /*if (state == ConfiguratorVariables.Chosen || state == ConfiguratorVariables.Required || state == ConfiguratorVariables.Default || ConfigCriteriaObj[it].State == ConfiguratorVariables.Selected) {
		                    result += addFeatureOption(criteriaId, false, state);
		                } else if (state == ConfiguratorVariables.Dismissed || state == ConfiguratorVariables.Incompatible) {
		                    if (!checkIfSelectionIsPresentInSameFeature(criteriaId)) {
		                        result += addFeatureOption(criteriaId, true, state);
		                    }
		                }*/

		                var selectionlevel = checkLevelOfSelectionsInFeature(criteriaId);

		                if (state == ConfiguratorVariables.Chosen || state == ConfiguratorVariables.Required || state == ConfiguratorVariables.Default || ConfigCriteriaObj[it].State == ConfiguratorVariables.Selected) {
		                    if (selectionlevel == 'userSelection' || selectionlevel == 'userSelectionAndUserReject' || selectionlevel == 'userSelectionAndRuleReject' || selectionlevel == 'ruleSelection' || selectionlevel == 'ruleSelectionAndRuleReject' || selectionlevel == 'userRejectAndRuleSelection') {
		                        result += addFeatureOption(criteriaId, false, state);
		                    }
		                } else if (state == ConfiguratorVariables.Dismissed || state == ConfiguratorVariables.Incompatible) {
		                    if (selectionlevel == 'userReject' || selectionlevel == 'ruleReject') {
		                        result += addFeatureOption(criteriaId, true, state);
		                    }
		                }
		            }
		        }
//		        result += endTag('Context');
		    }

		    var empty = true;

		    for (var prop in listOfRejectedOptionsForEachSingleFeature) {
		        if (listOfRejectedOptionsForEachSingleFeature.hasOwnProperty(prop))
		            empty = false;
		    }

		    if (!empty)
		        result += addListOfRejectedOptionsForSingleFeaturesInTheXML();

			    result += endTag(XML_FILE_TYPE.TAG1);
			    result += endTag(XML_FILE_TYPE.ROOT);
			    return result;

	    }
	    function getProdStateXML()
	    {
	        var prodStateXml = '';

	        if (ModelVersionInfoObj.modelName && ModelVersionInfoObj.modelVersionName && ModelVersionInfoObj.modelVersionRevision) {
	            var prodName = ModelVersionInfoObj.modelVersionName;
	            var prodRevsion = ModelVersionInfoObj.modelVersionRevision;
	            var modelName = ModelVersionInfoObj.modelName;

	            prodStateXml += '<TreeSeries Type="ProductState" Name="' + modelName + '">';
	            prodStateXml += '<Single Name="' + prodName + '" Revision="' + prodRevsion + '" />';
	            prodStateXml += '</TreeSeries>';
	        }

		    return prodStateXml;
	    }

        //XF3
	    function addOptionToTheListOfRejectedOptionsForSingleFeatures(cfid, coName, optionState) {
	        if (listOfRejectedOptionsForEachSingleFeature[cfid] == undefined)
	            listOfRejectedOptionsForEachSingleFeature[cfid] = [];

	        if (listOfRejectedOptionsStateForEachSingleFeature[cfid] == undefined)
	            listOfRejectedOptionsStateForEachSingleFeature[cfid] = [];

	        listOfRejectedOptionsForEachSingleFeature[cfid].push(coName);
	        listOfRejectedOptionsStateForEachSingleFeature[cfid].push(optionState);
	    }


	    function addListOfRejectedOptionsForSingleFeaturesInTheXML(){
	        var resXml='';

	        for (var itr in listOfRejectedOptionsForEachSingleFeature) {

	            var config_features = DictionaryObj.features;
	            for (var itx in config_features) {
	                var cfid = config_features[itx].ruleId;
	                if (cfid != undefined && cfid.toString().trim() == itr) {
	                    var cfName = config_features[itx].displayName;
	                    resXml += "<NOT>";
	                    resXml += featureTag(cfName, false, false);
	                    for (var i = 0; i < listOfRejectedOptionsForEachSingleFeature[itr].length; i++) {
	                        coName = listOfRejectedOptionsForEachSingleFeature[itr][i];
	                        optionState = listOfRejectedOptionsStateForEachSingleFeature[itr][i];
	                        resXml += featureTag(coName, true, true, optionState);
	                    }
	                    resXml += endTag('Feature');
	                    resXml += endTag('NOT');

	                    break;
	                }

	            }

	        }

            return resXml
	    }

        //End XF3

	    function addFeatureOption(criteriaId,isRejected, optionState)
	    {
		    var resXml = "";
		    var config_features = DictionaryObj.features;
		    for (var itx in config_features)
		    {
			    var cfElem = config_features[itx];
			    var cfName = cfElem.displayName;
			    var coElem = cfElem['options'];
			    if(coElem instanceof Object)
			    {
			     for(var itr in coElem)
			     {
				    var coName = coElem[itr].displayName;
				    if(coName != undefined && coName != null)
				    {
					    var coid = coElem[itr].ruleId;

					    if (coid != undefined && coid.toString().trim() == criteriaId)
					    {
					        if (isRejected) {
					            if (cfElem.selectionType == "Multiple") {       //XF3
					                resXml += "<NOT>";
					                resXml += featureTag(cfName, false, false);
					                resXml += featureTag(coName, true, true, optionState);
					                resXml += endTag('Feature');
					                resXml += endTag('NOT');
					            }                                               //XF3
					            else {                                          //XF3
					                addOptionToTheListOfRejectedOptionsForSingleFeatures(cfElem.ruleId, coName, optionState);
					                return resXml;                              //XF3
					            }                                               //XF3
						    }else
						    {
							    resXml += featureTag(cfName,false, false);
							    resXml += featureTag(coName,true, true, optionState);
							    resXml += endTag('Feature');
						    }
					    }

				    }

			     }
		      }
	       }

	    return resXml;
	    }


	    function featureTag(elemName,closed, addSelectedByAttribut, optionState){
	     var resXml = '';

	     resXml += '<Feature Type="ConfigFeature" Name="' + elemName + '"';
			 if (addSelectedByAttribut && optionState) {

	         if (optionState == ConfiguratorVariables.Default)
                 resXml += ' SelectedBy="Default"';
	         else if (optionState == ConfiguratorVariables.Required || optionState == ConfiguratorVariables.Incompatible)
                 resXml += ' SelectedBy="Rule"';
             else
                 resXml += ' SelectedBy="User"';

	     }

	     if(!closed)
		    resXml+=">";
	     else
		    resXml+="/>";
	     return resXml;
	    }

	    this.json2xml_str =  function (jsonobj){
		    initParamObjects(jsonobj);
		    return generateFilterXML();
	    };

        /*
	    this.parseXml = function(xml) {
	        var dom = null;
	        if (window.DOMParser) {
	            try {
	                dom = (new DOMParser()).parseFromString(xml, "text/xml");
	            }
	            catch (e) { dom = null; }
	        }
	        else if (window.ActiveXObject) {
	            try {
	                dom = new ActiveXObject('Microsoft.XMLDOM');
	                dom.async = false;
	                if (!dom.loadXML(xml)) // parse error ..

	                    window.alert(dom.parseError.reason + dom.parseError.srcText);
	            }
	            catch (e) { dom = null; }
	        }
	        else
	            alert("cannot parse xml string!");
	        return dom;
	    }



        // Changes XML to JSON
	    this.xmlToJson = function(xml) {

	        var js_obj = {};
	        if (xml.nodeType == 1) {
	            if (xml.attributes.length > 0) {
	                js_obj["attributes"] = {};
	                for (var j = 0; j < xml.attributes.length; j++) {
	                    var attribute = xml.attributes.item(j);
	                    js_obj["attributes"][attribute.nodeName] = attribute.value;
	                }
	            }
	        } else if (xml.nodeType == 3) {
	            js_obj = xml.nodeValue;
	        }
	        if (xml.hasChildNodes()) {
	            for (var i = 0; i < xml.childNodes.length; i++) {
	                var item = xml.childNodes.item(i);
	                var nodeName = item.nodeName;
	                if (typeof (js_obj[nodeName]) == "undefined") {
	                    js_obj[nodeName] = setJsonObj(item);
	                } else {
	                    if (typeof (js_obj[nodeName].push) == "undefined") {
	                        var old = js_obj[nodeName];
	                        js_obj[nodeName] = [];
	                        js_obj[nodeName].push(old);
	                    }
	                    js_obj[nodeName].push(setJsonObj(item));
	                }
	            }
	        }
	        return js_obj;
	    }

        // receives XML DOM object, returns converted JSON object
	    var setJsonObj = function (xml) {
	        var js_obj = {};
	        if (xml.nodeType == 1) {
	            if (xml.attributes.length > 0) {
	                js_obj["attributes"] = {};
	                for (var j = 0; j < xml.attributes.length; j++) {
	                    var attribute = xml.attributes.item(j);
	                    js_obj["attributes"][attribute.nodeName] = attribute.value;
	                }
	            }
	        } else if (xml.nodeType == 3) {
	            js_obj = xml.nodeValue;
	        }
	        if (xml.hasChildNodes()) {
	            for (var i = 0; i < xml.childNodes.length; i++) {
	                var item = xml.childNodes.item(i);
	                var nodeName = item.nodeName;
	                if (typeof (js_obj[nodeName]) == "undefined") {
	                    js_obj[nodeName] = setJsonObj(item);
	                } else {
	                    if (typeof (js_obj[nodeName].push) == "undefined") {
	                        var old = js_obj[nodeName];
	                        js_obj[nodeName] = [];
	                        js_obj[nodeName].push(old);
	                    }
	                    js_obj[nodeName].push(setJsonObj(item));
	                }
	            }
	        }
	        return js_obj;
	    }*/
    }



    return UWA.namespace('DS/ConfiguratorPanel/scripts/Models/FilterExpressionXMLServicesWithDisplayName', FilterExpressionXMLServicesWithDisplayName);
}
);

define(
    'DS/ConfiguratorPanel/scripts/Presenters/ParameterPresenter',
    [
        'UWA/Core',
        'UWA/Event',
        "DS/Controls/Slider",
        "DS/Controls/SpinBox",
        'DS/Handlebars/Handlebars',
        'DS/UIKIT/Mask',
        'DS/UIKIT/Tooltip',
        'DS/Controls/Popup',
        'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
        'DS/ConfiguratorPanel/scripts/Utilities',
        'DS/ConfiguratorPanel/scripts/ConfiguratorSolverFunctions',
        'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json',
        'i18n!DS/xDimensionManager/assets/nls/xUnitLabelLong.json',
        'text!DS/ConfiguratorPanel/html/ParameterPresenter.html',
        'css!DS/UIKIT/UIKIT.css',
        "css!DS/ConfiguratorPanel/css/ParameterPresenter.css"
    ],
    function(UWA, Event, Slider, SpinBox, Handlebars, Mask, Tooltip, WUXPopup, ConfiguratorVariables, Utilities, ConfiguratorSolverFunctions, nlsConfiguratorKeys, nlsUnitLabelLongKeys, html_ParameterPresenter) {

        'use strict';

        var template = Handlebars.compile(html_ParameterPresenter);

        var ParameterPresenter = function(options) {
            this._init(options);
        };


        /******************************* INITIALIZATION METHODS**************************************************/

        ParameterPresenter.prototype._init = function(options) {
            var _options = options ? UWA.clone(options, false) : {};
            UWA.merge(this, _options);

            this._initDivs();
            this._render();
            this.inject(_options.parentContainer);
        };

        ParameterPresenter.prototype._initDivs = function() {
            this._container = document.createElement('div');
            this._container.innerHTML = template();

            this._container = this._container.querySelector('.config-editor-parameter-container');
            this._spinboxContainer = this._container.querySelector('.config-editor-spinbox-container');
            this._sliderContainer = this._container.querySelector('.config-editor-slider-container');
        };

        ParameterPresenter.prototype.inject = function(parentcontainer) {
            parentcontainer.appendChild(this._container);
        };

        /*******************************AUTOCOMPLETE CREATION***************************************************/

        ParameterPresenter.prototype._render = function() {
            var that = this;
            this._currentValue = this.configModel.getValueWithId(this.variant.ruleId) || this.variant.defaultValue;
            this.parameterSpinbox = this.getSpinbox();
            this.parameterSlider = this.getSlider();
            this.updateFilters();
        };

        ParameterPresenter.prototype.enforceRequired = function(data) {
            var _currentValue = this.configModel.getValueWithId(this.variant.ruleId) || this.variant.defaultValue;
            this._currentValue = this.getParsedValue(_currentValue);
            if(this._currentValue){
              if(this._currentValue < this.variant.minValue || this._currentValue > this.variant.maxValue){
                // this._currentValue = this.variant.defaultValue;
                var msgStr1 = nlsConfiguratorKeys.ParameterValueOutOfRange;
                msgStr1 = msgStr1.replace("#PARAMETER#", this.variant.name);
                var msgStr2 = msgStr1.replace("#PARAMETER_VALUE#", this._currentValue);
                Utilities.displayNotification({eventID: 'warning',msg: msgStr2});
              }
            }
            this.updateFilters();
        };

        ParameterPresenter.prototype.getParsedValue = function(value) {
          var parsedValue = value;
          if (UWA.is(value, "string") && value !== "") {
            parsedValue = JSON.parse(value.replace(/\D/g,''));
          }
          return parsedValue;
        };

        ParameterPresenter.prototype.getSpinbox = function(data) {
            var that = this;
            var parameterSpinbox = new SpinBox({
                value: this._currentValue,
                minValue: this.variant.minValue,
                maxValue: this.variant.maxValue,
                // units: this.variant.unit,
                stepValue: this.variant.stepValue
            });
            parameterSpinbox.elements.container.style.width = "100%";
            parameterSpinbox.elements.container.style.minWidth = "100%";
            parameterSpinbox.elements.container.style.lineHeight = "32px";
            parameterSpinbox.elements.container.style.height = "34px";
            parameterSpinbox.addEventListener('endEdit', function() {
                that._currentValue = that.parameterSpinbox.value;
                that.updateFilters();
            });
            parameterSpinbox.inject(this._spinboxContainer);
            return parameterSpinbox;
        };

        ParameterPresenter.prototype.getSlider = function(data) {
            var that = this;
            var parameterSlider = new Slider({
                value: this._currentValue,
                minValue: this.variant.minValue,
                maxValue: this.variant.maxValue,
                stepValue: this.variant.stepValue
            });
            parameterSlider.getTextFromValue = function() {
                var unit = nlsUnitLabelLongKeys[that.variant.unit] || that.variant.unit;
               if(unit){
                 return this.value + " " + unit;
               }
               else
                 return this.value;
            }

            parameterSlider.getContent().addEventListener('endEdit', function(data) {
                that._currentValue = that.parameterSlider.value;
                that.updateFilters();
            });
            parameterSlider.inject(this._sliderContainer);
            return parameterSlider;
        };


        /*******************************UPDATE VIEW : HANDLE MUST/MAY FEATURES AND INCLUSION RULES***************************/

        ParameterPresenter.prototype.updateFilters = function() {
            var valueToBeUpdated;
            //if(this._currentValue && UWA.is(this._currentValue, "string") && this._currentValue.includes(this.variant.unit))
            if (this._currentValue) {
                valueToBeUpdated = this._currentValue.toString();
                // valueToBeUpdated = JSON.stringify(this._currentValue);
                if (UWA.is(valueToBeUpdated, "string")) {
                    if (this.variant.unit && this.variant.unit != "" && valueToBeUpdated.indexOf(this.variant.unit) === -1) {
                        valueToBeUpdated = valueToBeUpdated + " " + this.variant.unit;
                    }
                }
                if (valueToBeUpdated) {
                    this.configModel.setValueWithId(this.variant.ruleId, valueToBeUpdated);
                }
                this.imageContainer.classList.add('cfg-image-selected');
            }else{
              this.imageContainer.classList.remove('cfg-image-selected');
            }
            this.parameterSlider.value = this._currentValue;
            this.parameterSpinbox.value = this._currentValue;
            var mandatory = (this.variant.selectionCriteria == 'Must' || this.variant.selectionCriteria == true) ? true : false;
            //required states on parameter ?
            // var mandStatus = (mandatory || this.configModel.getStateWithId(this.variant.ruleId) === ConfiguratorVariables.Required) ? true : false;
            var mandStatus = mandatory; //for now.
            var selectedFeature;
            if (this._currentValue !== undefined) {
                mandStatus = false;
                selectedFeature = true;
            } else {
                selectedFeature = false;
            }

            if (this._container.offsetParent && this._container.offsetParent.style.display === "none") {
                selectedFeature = false;
            }
            this.configModel.setFeatureIdWithMandStatus(this.variant.ruleId, mandStatus);
            this.configModel.setFeatureIdWithStatus(this.variant.ruleId, selectedFeature);
            this.configModel.setFeatureIdWithChosenStatus(this.variant.ruleId, selectedFeature);

            this.modelEvents.publish({event: "updateAllFilters"});

        };

        /******************************************UTILITIES**********************************************************/

        ParameterPresenter.prototype._find = function(array, id) {
            if (array) {
                array.forEach(function(item) {
                    if (item === id) {
                        return item;
                    }
                });
            }
        };
        /********************************END OF MULTIVALUEPRESENTER*************************************************************/
        return ParameterPresenter;
    });


define(
	'DS/ConfiguratorPanel/scripts/Presenters/ToolbarPresenter', 
	[
		'UWA/Core',
		'UWA/Controls/Abstract',
		'DS/W3DXComponents/Views/Item/ActionView',
		'DS/W3DXComponents/Views/Layout/ActionsView',
     	'DS/W3DXComponents/Collections/ActionsCollection',
		'DS/UIKIT/Input/Button',
		'DS/UIKIT/Input/Text',
		'DS/UIKIT/DropdownMenu',
		'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
		'DS/ConfiguratorPanel/scripts/Utilities',
	
		'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json',
		
		'css!DS/UIKIT/UIKIT.css',
		"css!DS/ConfiguratorPanel/scripts/Presenters/ToolbarPresenter.css"
	],	
	function (UWA, Abstract, ActionView, ActionsView, ActionsCollection, Button, InputText, DropdownMenu, ConfiguratorVariables, /*ConfiguratorSolverFunctions,*/ Utilities, nlsConfiguratorKeys) {

		'use strict';

		var ToolbarPresenter = Abstract.extend({
				 /**
				 * @description
				 * <blockquote>
				 * <p>Initialiaze the ToolbarPresenter component with the required options</p>
				 * <p>This component shows all tools on top of the Configurator panel. It will show :
				 * <ul>
				 * <li>Count of the mandatory Variant classes not valuated.</li>
				 * <li>Count of the conflicting Variant classes</li>
				 * <li>The current Status of the configuration (if it is "Partial", "Complete" or "Hybrid")</li>
				 * <li>The selection mode ("Build" or "Refine"). By clicking on the icon you will be able to switch the mode</li>
				 * <li>The multi-selection state. By clicking on the icon you will be able to switch the state</li>
				 * <li>The rule assistance level. By clicking the icon you will be able to select one of them</li>
				 * <li>A magnifier icon that will allow you to filter the list of Variant classes. By clicking on the icon some tools will appear :</li>
				 *   <ul>
				 *   <li>A dropdown to filter by states</li>
				 *   <li>A search to filter with a string. The search can be applied on different attributes</li>
				 *   </ul>
				 * </ul>
				 * </p>
				 * </blockquote>
				 *
				 * @memberof module:DS/ConfiguratorPanel/ConfiguratorPanel#
				 *
				 * @param {Object} options - Available options.
				 * @param {Object} options.parentContainer - The parent container where the ToolbarPresenter will be injected
				 * @param {Object} options.modelEvents - The modelEvents object
				 * @param {Object} options.configModel - The configModel object
                 * @param {Object} options.attributesList - The List of attributes that will be displayed in the attributes filter
                 * @param {Object} options.defaultAttributeSelected - Default attribute selected in the list of attributes
                 * @param {Object} options.add3DButton - {OPTIONNAL} option to create a "3D" button in the toolbar. Added for Enovia Demo. Should be used in Model Editor integration
				 *
				 */				 
				 
				 currentAttributeForSearch: '',
				 currentValueForSearch: '',
				 
				 init: function (options) {
					 
				     var that = this;
				     that.currentAttributeForSearch = options.defaultAttributeSelected;

				     that._attributesList = (options.attributesList) ? options.attributesList : [];
					 that._dropdownObjectForRules = new Object();
					 that.actionsList = null;
					 
					 
					 var CustomActionsView = ActionsView.extend({
						itemView : ActionView.extend({
							onRender : function() {
								this._parent();
								if(this.model.get('style')) {
									var style = this.model.get('style');
									if(UWA.is(this.model.get('style'), 'function')) {
										style = style();
									}
									this.container.setStyles(style);
									
								}
								if(this.model.get('id')) {
									this.container.id = this.model.get('id');
								}
								
								if(this.model.get('dropdown')) {
									
									var optionsDropdown = this.model.get('dropdown');
									var params = {};
									
									params.target = this.container;
									if(optionsDropdown.multiSelect) 
										params.multiSelect = optionsDropdown.multiSelect;
									if(optionsDropdown.closeOnClick)
										params.closeOnClick = optionsDropdown.closeOnClick;
									if(optionsDropdown.items)
										params.items = optionsDropdown.items;
									if(optionsDropdown.events)
										params.events = optionsDropdown.events;
									
                                    params.renderTo = options.parentContainer;

									var dropdownObj = new DropdownMenu(params);
									
									if(this.model.get('dropdownObject'))
										that[this.model.get('dropdownObject')] = dropdownObj;
								}
								if(this.model.get('associatedText')) {
									this.container.addContent(this.model.get('associatedText'));
								}

								if(this.model.get('tooltip')) {
								    this.container.title = this.model.get('tooltip');
								}
							}
						})
					});
					 
					 //Create the Main div of the Configurator
					var ToolbarDiv = document.createElement('div');
					ToolbarDiv.id = "ConfiguratorToolbar";					
					
					var extendedToolbarDiv = UWA.extendElement(ToolbarDiv);
					
					
					//Create the div for the Mandatory and the Conflicts icons on the left of configurator toolbar
					var leftToolbarDiv = document.createElement('div');
					leftToolbarDiv.id = "leftToolbarDiv";					
					
					var extendedLeftToolbarDiv = UWA.extendElement(leftToolbarDiv);
					
					extendedLeftToolbarDiv.inject(extendedToolbarDiv);
					
					//Actions for Mand and Conflicts icons
					
					var mandVarClassesNumberSpan = document.createElement('span');
					mandVarClassesNumberSpan.innerHTML = "(" + options.configModel.getNumberOfMandFeaturesNotValuated() + ")";
					mandVarClassesNumberSpan.id = "mandVarClassesNumberSpan";					
					var extendedMandVarClassesNumberSpan = UWA.extendElement(mandVarClassesNumberSpan);
					
					options.modelEvents.subscribe({event:'OnMandFeatureNumberChange'}, function(data) {
						 mandVarClassesNumberSpan.innerHTML = "(" + data.value + ")";
					});
					
					var conflictingVarClassesNumberSpan = document.createElement('span');
					conflictingVarClassesNumberSpan.innerHTML = "(" + options.configModel.getNumberOfConflictingFeatures() + ")";
					conflictingVarClassesNumberSpan.id = "conflictingVarClassesNumberSpan";					
					var extendedConflictingVarClassesNumberSpan = UWA.extendElement(conflictingVarClassesNumberSpan);
					
					options.modelEvents.subscribe({event:'OnConflictFeatureNumberChange'}, function(data) {
						
						document.getElementById("ConflictingFeaturesContainer").style.opacity = (options.configModel.getNumberOfConflictingFeatures() == 0)? 0:1;
						document.getElementById("ConflictingFeaturesContainer").style.cursor = (options.configModel.getNumberOfConflictingFeatures() == 0)? 'initial':'pointer';
						 
						conflictingVarClassesNumberSpan.innerHTML = "(" + data.value + ")";
					});
					
					var actionsList = [{
							text : "Mandatory icon",
							icon: 'attention',
							actionId: 'MandatoryIcon',
							tooltip: nlsConfiguratorKeys[ConfiguratorVariables.UnselectedMandatory],
							handler: function(e) {
								if( !extendedToolbarDiv.style.height) {
									extendedToolbarDiv.style.height = extendedToolbarDiv.offsetHeight + "px";
								}
								
								if(!searchIconActivated){
									searchIconActivated = true;
									extendedFilteringToolsDiv.style.display = "block";
                                    									
									extendedToolbarDiv.style.height = extendedRightToolbarDiv.offsetHeight + extendedFilteringToolsDiv.offsetHeight + "px";
									
									options.modelEvents.publish({
									    event: 'OnToolbarHeightChange',
									    data: { value: getToolbarHeight() }
									});

									document.getElementById('searchIcon').style.color = 'rgb(54, 142, 196)';
								} 
								
								var selectedStatusList = FilterStatusDDMenu.getSelectedItems();
								
								for(var i=0; i<selectedStatusList.length; i++) {
									FilterStatusDDMenu.toggleSelection(selectedStatusList[i]);
									FilterStatusDDMenu.enableItem(selectedStatusList[i].name);
								}
								
								FilterStatusDDMenu.toggleSelection(FilterStatusDDMenu.getItem(ConfiguratorVariables.UnselectedMandatory));
								FilterStatusDDMenu.disableItem(FilterStatusDDMenu.getItem(ConfiguratorVariables.UnselectedMandatory).name);
								
								iconFilterStatusSpan.set('class', "fonticon fonticon-attention");
								
								options.modelEvents.publish( {
									event:	'OnFilterStatusChange',
									data:	{value : ConfiguratorVariables.UnselectedMandatory}
								});
							},
							style : function() {
							    var iconColor = '#5b5d5e';
    							var iconContWidth = '50%';
								
    							return { color: iconColor, width: iconContWidth};
    						},
							associatedText: extendedMandVarClassesNumberSpan
					},
					{
							text : "Conflicts icon",
							icon: 'alert',
							id: 'ConflictingFeaturesContainer',
							actionId: 'ConflictsIcon',
							tooltip: nlsConfiguratorKeys[ConfiguratorVariables.SelectionInConflict],
							handler: function(e) {
								if(options.configModel.getNumberOfConflictingFeatures() > 0) {
									if( !extendedToolbarDiv.style.height) {
										extendedToolbarDiv.style.height = extendedToolbarDiv.offsetHeight + "px";
									}
									
									if(!searchIconActivated){
										searchIconActivated = true;
										extendedFilteringToolsDiv.style.display = "block";

										extendedToolbarDiv.style.height = extendedRightToolbarDiv.offsetHeight + extendedFilteringToolsDiv.offsetHeight + "px";
										
										options.modelEvents.publish({
										    event: 'OnToolbarHeightChange',
										    data: { value: getToolbarHeight() }
										});

										document.getElementById('searchIcon').style.color = 'rgb(54, 142, 196)';
									} 
									
									var selectedStatusList = FilterStatusDDMenu.getSelectedItems();
									
									for(var i=0; i<selectedStatusList.length; i++) {
										FilterStatusDDMenu.toggleSelection(selectedStatusList[i]);
										FilterStatusDDMenu.enableItem(selectedStatusList[i].name);
									}
									
									FilterStatusDDMenu.toggleSelection(FilterStatusDDMenu.getItem(ConfiguratorVariables.SelectionInConflict));
									FilterStatusDDMenu.disableItem(FilterStatusDDMenu.getItem(ConfiguratorVariables.SelectionInConflict).name);
									
									iconFilterStatusSpan.set('class', "fonticon fonticon-alert");
									
									options.modelEvents.publish( {
										event:	'OnFilterStatusChange',
										data:	{value : ConfiguratorVariables.SelectionInConflict}
									});
								}
							},
							style : function() {
    							var iconColor = 'red';
    							var iconContWidth = '50%';
								
    							return { color: iconColor, width: iconContWidth, opacity:0, cursor: 'initial'};
    						},
							associatedText: extendedConflictingVarClassesNumberSpan
					}];
					
					
					
					var actionView = new CustomActionsView(getActionObj(actionsList));
					actionView = actionView.render();
					actionView.container.setStyles({ verticalAlign: 'middle', justifyContent: 'flex-start'});
					
					actionView.inject(extendedLeftToolbarDiv);
					
					//Create the div for configuration mode, Multi-sel, rules assistance level and search icons
					var rightToolbarDiv = document.createElement('div');
					rightToolbarDiv.id = "rightToolbarDiv";					
					
					var extendedRightToolbarDiv = UWA.extendElement(rightToolbarDiv);
					
					extendedRightToolbarDiv.inject(extendedToolbarDiv);
					
					//create a span for completeness status text
					var completenessStatusSpan = document.createElement('span');
					completenessStatusSpan.id = "completenessStatus";					
					completenessStatusSpan.innerHTML = nlsConfiguratorKeys[options.configModel.getCompletenessStatus()];
					
					var extendedCompStatusSpan = UWA.extendElement(completenessStatusSpan);					
					
					extendedCompStatusSpan.inject(extendedRightToolbarDiv);
					
					var searchIconActivated = false;
					
					function getIcon(options)
					{
						var IconDiv = UWA.createElement('span',{
							'class': 'fonticon fonticon-2x fonticon-' + options.icon ,				
						});
						if(options.id && options.id !='') IconDiv.id = options.id;
						IconDiv.changeIcon = function(icon )
						{
							this.set('class', 'fonticon fonticon-2x fonticon-' + icon);
						};
						return IconDiv;
					}					
					
					var itemsForSelectionMode;
					var iconForSelectionMode;
					var tooltipForSelectionMode;
					
					if(options.configModel.getSelectionMode() == ConfiguratorVariables.selectionMode_Build) {
						itemsForSelectionMode = [
							{ name: ConfiguratorVariables.selectionMode_Build, text: nlsConfiguratorKeys[ConfiguratorVariables.BuildConfiguration], fonticon: 'up-dir', selected: true, disabled: true },
							{ name: ConfiguratorVariables.selectionMode_Refine, text: nlsConfiguratorKeys[ConfiguratorVariables.RefineConfiguration], fonticon: 'down-dir', selectable: true, disabled: (options.configModel.getReadOnlyFlag()) ? true:false }									
						];
						iconForSelectionMode = 'up-dir';
						tooltipForSelectionMode = nlsConfiguratorKeys[ConfiguratorVariables.BuildConfiguration];
					}
					else {
						itemsForSelectionMode = [
							{ name: ConfiguratorVariables.selectionMode_Build, text: nlsConfiguratorKeys[ConfiguratorVariables.BuildConfiguration], fonticon: 'up-dir', selectable: true, disabled: (options.configModel.getReadOnlyFlag()) ? true : false },
							{ name: ConfiguratorVariables.selectionMode_Refine, text: nlsConfiguratorKeys[ConfiguratorVariables.RefineConfiguration], fonticon: 'down-dir', selected: true, disabled: true }									
						];
						iconForSelectionMode = 'down-dir';
						tooltipForSelectionMode = nlsConfiguratorKeys[ConfiguratorVariables.RefineConfiguration];
					}
					
					var iconCompletenessStatus;
					if(options.configModel.getCompletenessStatus() == ConfiguratorVariables.Hybrid)
						iconCompletenessStatus = 'high';
					else if(options.configModel.getCompletenessStatus() == ConfiguratorVariables.Complete)
						iconCompletenessStatus = 'medium';
					else 
						iconCompletenessStatus = 'low';
						
					var txtIcon = getIcon({	id: 'optIcon' ,	icon: iconCompletenessStatus});
					txtIcon.inject(extendedRightToolbarDiv);

					
					var iconForRulesAssistanceLevel = 'block';
					var tooltipForRulesAssistanceLevel = nlsConfiguratorKeys[ConfiguratorVariables.NoRuleApplied];
					var itemsForRulesAssistanceLevel = [];
					var selectedState = false;
					var rulesMode = options.configModel.getRulesMode();
					var rulesActivation = options.configModel.getRulesActivation();
					
					options.modelEvents.subscribe({event:'checkModelConsistency_SolverAnswer'}, function(data) {
						 
						 if(that._dropdownObjectForRules != null) {
							 var ddown = that._dropdownObjectForRules;
							 
							 if(options.configModel.getRulesActivation() == 'false') {
								if(ddown.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration)) ddown.enableItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration);
								if(ddown.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration)) ddown.enableItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration);
								if(ddown.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions)) ddown.enableItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions);
								if(ddown.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions)) ddown.enableItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions);
								ddown.enableItem(ConfiguratorVariables.NoRuleApplied);
								 
								if(ddown.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration) && ddown.isSelected(ddown.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration).name)) 
									ddown.toggleSelection(ddown.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration));
								if(ddown.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration) && ddown.isSelected(ddown.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration).name)) 
									ddown.toggleSelection(ddown.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration));
								if(ddown.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions) && ddown.isSelected(ddown.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions).name)) 
									ddown.toggleSelection(ddown.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions));
								if(ddown.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions) && ddown.isSelected(ddown.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions).name)) 
									ddown.toggleSelection(ddown.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions));
								
								if(ddown.getItem(ConfiguratorVariables.NoRuleApplied) && !ddown.isSelected(ddown.getItem(ConfiguratorVariables.NoRuleApplied).name))
									ddown.toggleSelection(ddown.getItem(ConfiguratorVariables.NoRuleApplied));
									
								ddown.disableItem(ConfiguratorVariables.NoRuleApplied);
								
								document.getElementById('ruleAssistanceLevelIcon').getElementsByTagName('span')[0].className='fonticon fonticon-block fonticon-2x';
							}
							 
							 
						 }
							console.log(that._dropdownObjectForRules.getSelectedItems());
						 
					});
					
					if(options.configModel.getMultiSelectionState() == "true" && rulesActivation == 'true') {
						Utilities.displayNotification({
							eventID: 'info',
							msg: nlsConfiguratorKeys.InfoMultiSelAndRules
						});
					}
					
						if(options.configModel.getAppFunc().rulesMode_ProposeOptimizedConfiguration == "yes") {
							selectedState=false;
							if(rulesMode == ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration && rulesActivation == 'true') {
								selectedState=true;
								iconForRulesAssistanceLevel = 'chart-area';
								tooltipForRulesAssistanceLevel = nlsConfiguratorKeys[ConfiguratorVariables.ProposeOptimizedConfiguration];
							}
							itemsForRulesAssistanceLevel.push({ name: ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration, text: nlsConfiguratorKeys[ConfiguratorVariables.ProposeOptimizedConfiguration], fonticon: 'chart-area', selectable: true, selected: selectedState, disabled: (options.configModel.getReadOnlyFlag() == true || rulesMode == ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration) ? true : false });
						}
						if(options.configModel.getAppFunc().rulesMode_SelectCompleteConfiguration == "yes") 	{
							selectedState=false;
							if(rulesMode == ConfiguratorVariables.RulesMode_SelectCompleteConfiguration && rulesActivation == 'true') {
								selectedState=true;
								iconForRulesAssistanceLevel = 'cube';
								tooltipForRulesAssistanceLevel = nlsConfiguratorKeys[ConfiguratorVariables.SelectCompleteConfiguration];
							}
							itemsForRulesAssistanceLevel.push({ name: ConfiguratorVariables.RulesMode_SelectCompleteConfiguration, text: nlsConfiguratorKeys[ConfiguratorVariables.SelectCompleteConfiguration], fonticon: 'cube', selectable: true, selected: selectedState, disabled: (options.configModel.getReadOnlyFlag() == true || rulesMode == ConfiguratorVariables.RulesMode_SelectCompleteConfiguration) ? true : false });
						}
						if(options.configModel.getAppFunc().rulesMode_EnforceRequiredOptions == "yes") {
							selectedState=false;
							if(rulesMode == ConfiguratorVariables.RulesMode_EnforceRequiredOptions && rulesActivation == 'true') {
								selectedState=true;
								iconForRulesAssistanceLevel = '3ds-how';
								tooltipForRulesAssistanceLevel = nlsConfiguratorKeys[ConfiguratorVariables.EnforceRequiredOptionsAndSelectDefault];
							}
							itemsForRulesAssistanceLevel.push({ name: ConfiguratorVariables.RulesMode_EnforceRequiredOptions, text: nlsConfiguratorKeys[ConfiguratorVariables.EnforceRequiredOptionsAndSelectDefault], fonticon: '3ds-how', selectable: true, selected: selectedState, disabled: (options.configModel.getReadOnlyFlag() == true || rulesMode == ConfiguratorVariables.RulesMode_EnforceRequiredOptions) ? true : false });
						}
						if(options.configModel.getAppFunc().rulesMode_DisableIncompatibleOptions == "yes") {
							selectedState=false;
							if(rulesMode == ConfiguratorVariables.RulesMode_DisableIncompatibleOptions && rulesActivation == 'true') {
								selectedState=true;
								iconForRulesAssistanceLevel = 'list-times';
								tooltipForRulesAssistanceLevel = nlsConfiguratorKeys[ConfiguratorVariables.DisableIncompatibleOptions];
							}
							itemsForRulesAssistanceLevel.push({ name: ConfiguratorVariables.RulesMode_DisableIncompatibleOptions, text: nlsConfiguratorKeys[ConfiguratorVariables.DisableIncompatibleOptions], fonticon: 'list-times', selectable: true, selected: selectedState, disabled: (options.configModel.getReadOnlyFlag() == true || rulesMode == ConfiguratorVariables.RulesMode_DisableIncompatibleOptions) ? true : false });
						}
						itemsForRulesAssistanceLevel.push({ className: "divider" });
						itemsForRulesAssistanceLevel.push({ name: ConfiguratorVariables.NoRuleApplied, text: nlsConfiguratorKeys[ConfiguratorVariables.NoRuleApplied], fonticon: 'block', selectable: true, selected: (rulesActivation == "false") ? true : false, disabled: (options.configModel.getReadOnlyFlag() == true || rulesActivation == "false") ? true : false });
									
					//Actions list creation
					that.actionsList = [
						//iconCompletenessStatus kept seperately , to solve update issue
							{
							text : "Configuration mode icon",
							icon: iconForSelectionMode,
							id: 'configurationModeIcon',
							actionId: 'ConfigurationModeIcon',
							tooltip: nlsConfiguratorKeys["Selection mode"] + ' : ' + tooltipForSelectionMode,
							handler: function(e) {
							},
							style : function() {
    							var iconColor = '#5b5d5e';
    							
    							return { color: iconColor};
    						},
							dropdown : {
								multiSelect: false,
								closeOnClick: true,
								items: itemsForSelectionMode,
								events: {
									onClick: function (e, item) { 
										if(item.elements.icon)
											document.getElementById('configurationModeIcon').getElementsByTagName('span')[0].className =  item.elements.icon.className + ' fonticon-2x';
										
										if (item.elements.icon) {
										    var nlsConfigurationMode;

										    if (item.name == ConfiguratorVariables.selectionMode_Build)
										        nlsConfigurationMode = nlsConfiguratorKeys[ConfiguratorVariables.BuildConfiguration];
										    else if (item.name == ConfiguratorVariables.selectionMode_Refine)
										        nlsConfigurationMode = nlsConfiguratorKeys[ConfiguratorVariables.RefineConfiguration];
										    
										    document.getElementById('configurationModeIcon').getElementsByTagName('span')[0].title = nlsConfiguratorKeys["Selection mode"] + ' : ' + nlsConfigurationMode;
										}

										this.enableItem(ConfiguratorVariables.selectionMode_Build);
										this.enableItem(ConfiguratorVariables.selectionMode_Refine);
										
										this.disableItem(item.name);
										
										options.configModel.setSelectionMode(item.name);
										
										options.modelEvents.publish( {
											event:	'OnConfigurationModeChange',
											data:	{value : item.name}
										});
									}
								}
							}
					},
					{
							text : "Multi Selection icon",
							icon: 'popup',
							actionId: 'MultiSelIcon',
							tooltip: (options.configModel.getMultiSelectionState() == "true") ? (nlsConfiguratorKeys["Multi-Selection"] + " : " + nlsConfiguratorKeys["Enabled"]) : (nlsConfiguratorKeys["Multi-Selection"] + " : " + nlsConfiguratorKeys["Disabled"]),
							handler: function (e) {
							    if (options.configModel.getReadOnlyFlag() == false) {
							        var multiSelActivated = (options.configModel.getMultiSelectionState() == "true") ? true : false;

							        if (multiSelActivated) {
							            options.configModel.setMultiSelectionState("false");
							            e.currentTarget.style.color = '';
							            e.currentTarget.title = (nlsConfiguratorKeys["Multi-Selection"] + " : " + nlsConfiguratorKeys["Disabled"]);
							            multiSelActivated = false;
							        }
							        else {
							            options.configModel.setMultiSelectionState("true");
							            e.currentTarget.style.color = 'rgb(54, 142, 196)';
							            e.currentTarget.title = (nlsConfiguratorKeys["Multi-Selection"] + " : " + nlsConfiguratorKeys["Enabled"]);
							            multiSelActivated = true;

							            if (options.configModel.getRulesActivation() == 'true') {
							                Utilities.displayNotification({
							                    eventID: 'info',
							                    msg: nlsConfiguratorKeys.InfoMultiSelAndRules
							                });
							            }
							        }



							        options.modelEvents.publish({
							            event: 'OnMultiSelectionChange',
							            data: { value: multiSelActivated }
							        });

							        //ConfiguratorSolverFunctions.SetMultiSelectionOnSolver(multiSelActivated);
							    }
							},
							style : function() {
								var multiSelActivated = (options.configModel.getMultiSelectionState() == "true") ? true:false;
								
								var iconColor = multiSelActivated ? 'rgb(54, 142, 196)' : '';
    							
    							return { color: iconColor};
    						}
					},
					{
							text : "Rules assistance level icon",
							icon: iconForRulesAssistanceLevel,
							id: 'ruleAssistanceLevelIcon',
							tooltip: nlsConfiguratorKeys["Rules assistance level"] + ' : ' + tooltipForRulesAssistanceLevel,
							actionId: 'RulesAssistanceLevelIcon',
							handler: function(e) {
							},
							style : function() {
    							var iconColor = '#5b5d5e';
    							
    							return { color: iconColor};
    						},
							dropdown : {
								multiSelect: false,
								closeOnClick: true,
								items: itemsForRulesAssistanceLevel,
								events: {
									onClick: function (e, item) { 
										var newRulesActivation;
										var newRulesMode;
									
										if(item.elements.icon)
										    document.getElementById('ruleAssistanceLevelIcon').getElementsByTagName('span')[0].className = item.elements.icon.className + ' fonticon-2x';
										
										if (item.elements.icon){
										    var nlsRulesAssistanceLevel = nlsConfiguratorKeys[ConfiguratorVariables.NoRuleApplied];

										    if (item.name == ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration)
										        nlsRulesAssistanceLevel = nlsConfiguratorKeys[ConfiguratorVariables.ProposeOptimizedConfiguration];
										    else if (item.name == ConfiguratorVariables.RulesMode_SelectCompleteConfiguration)
										        nlsRulesAssistanceLevel = nlsConfiguratorKeys[ConfiguratorVariables.SelectCompleteConfiguration];
										    else if (item.name == ConfiguratorVariables.RulesMode_EnforceRequiredOptions)
										        nlsRulesAssistanceLevel = nlsConfiguratorKeys[ConfiguratorVariables.EnforceRequiredOptionsAndSelectDefault];
										    else if (item.name == ConfiguratorVariables.RulesMode_DisableIncompatibleOptions)
                                                nlsRulesAssistanceLevel = nlsConfiguratorKeys[ConfiguratorVariables.DisableIncompatibleOptions];

										    document.getElementById('ruleAssistanceLevelIcon').getElementsByTagName('span')[0].title = nlsConfiguratorKeys["Rules assistance level"] + ' : ' + nlsRulesAssistanceLevel;
										}

										if(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration)) this.enableItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration);
										if(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration)) this.enableItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration);
										if(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions)) this.enableItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions);
										if(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions)) this.enableItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions);
										this.enableItem(ConfiguratorVariables.NoRuleApplied);
										
										if(item.name == ConfiguratorVariables.NoRuleApplied) {
											if(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration) && this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration));
											if(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration) && this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration));
											if(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions) && this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions));
											if(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions) && this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions));
											
											this.disableItem(ConfiguratorVariables.NoRuleApplied);
											
											newRulesActivation = "false";

										    //remove Conflicts Icon if any
											if (document.getElementById("ConflictingFeaturesContainer")) {
											    document.getElementById("ConflictingFeaturesContainer").style.opacity = 0;
											    document.getElementById("ConflictingFeaturesContainer").style.cursor = 'initial';
										    }
										}
										else if(item.name == ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration) {
											if( this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration) && !this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration));
											if( this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration) && !this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration));
											if( this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions) && !this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions));
											if( this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions) && !this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions));
											if(this.isSelected(this.getItem(ConfiguratorVariables.NoRuleApplied).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.NoRuleApplied));
											
											this.disableItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration);
											
											newRulesActivation = "true";
											newRulesMode = ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration;
											
										}
										else if(item.name == ConfiguratorVariables.RulesMode_SelectCompleteConfiguration) {
											if(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration) && this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration));
											if( this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration) && !this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration));
											if( this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions) && !this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions));
											if( this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions) && !this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions));
											if(this.isSelected(this.getItem(ConfiguratorVariables.NoRuleApplied).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.NoRuleApplied));
											
											this.disableItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration);
											
											newRulesActivation = "true";
											newRulesMode = ConfiguratorVariables.RulesMode_SelectCompleteConfiguration;
										}
										else if(item.name == ConfiguratorVariables.RulesMode_EnforceRequiredOptions) {
											if(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration) && this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration));
											if(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration) && this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration));
											if( this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions) && !this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions));
											if( this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions) && this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions));
											if(this.isSelected(this.getItem(ConfiguratorVariables.NoRuleApplied).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.NoRuleApplied));
											
											this.disableItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions);
											
											newRulesActivation = "true";
											newRulesMode = ConfiguratorVariables.RulesMode_EnforceRequiredOptions;
										}
										else if(item.name == ConfiguratorVariables.RulesMode_DisableIncompatibleOptions) {
											if(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration) && this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_ProposeOptimizedConfiguration));
											if(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration) && this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_SelectCompleteConfiguration));
											if(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions) && this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_EnforceRequiredOptions));
											if( this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions) && !this.isSelected(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions));
											if(this.isSelected(this.getItem(ConfiguratorVariables.NoRuleApplied).name)) 
												this.toggleSelection(this.getItem(ConfiguratorVariables.NoRuleApplied));
											
											this.disableItem(ConfiguratorVariables.RulesMode_DisableIncompatibleOptions);
											
											newRulesActivation = "true";
											newRulesMode = ConfiguratorVariables.RulesMode_DisableIncompatibleOptions;
										}
										
										options.configModel.setRulesActivation(newRulesActivation);
										
										if(newRulesActivation == "true") {
											options.configModel.setRulesMode(newRulesMode);
											
											if(options.configModel.getMultiSelectionState() == "true") {
												Utilities.displayNotification({
													eventID: 'info',
													msg: nlsConfiguratorKeys.InfoMultiSelAndRules
												});
											}
										}
										
										options.modelEvents.publish( {
											event:	'OnRuleAssistanceLevelChange',
											data:	{value : item.name}
										});
										
										//if(newRulesActivation == "true")
											//ConfiguratorSolverFunctions.setSelectionModeOnSolver(newRulesMode);
										
									}
								}
							},
							dropdownObject: "_dropdownObjectForRules"
					},{
							text : "Search icon",
							icon: 'search',
							id: 'searchIcon',
							actionId: 'SearchIcon',
							handler: function(e) {								
								if( !extendedToolbarDiv.style.height) {
									extendedToolbarDiv.style.height = extendedToolbarDiv.offsetHeight + "px";
								}
								
								if(searchIconActivated){
									searchIconActivated = false;
									extendedFilteringToolsDiv.style.display = "none";
									
									if (document.getElementById("searchInput")) {
									    document.getElementById("searchInput").value = "";

									    options.modelEvents.publish({
									        event: 'OnSearchValueChange',
									        data: {
									            value: document.getElementById("searchInput").value,
									            attribute: that.currentAttributeForSearch
									        }
									    });
									}

									extendedToolbarDiv.style.height = extendedRightToolbarDiv.offsetHeight + extendedFilteringToolsDiv.offsetHeight + "px";
									e.currentTarget.style.color = '';
								}
								else{
									searchIconActivated = true;
									extendedFilteringToolsDiv.style.display = "block";
									
									extendedToolbarDiv.style.height = extendedRightToolbarDiv.offsetHeight + extendedFilteringToolsDiv.offsetHeight + "px";
									e.currentTarget.style.color = 'rgb(54, 142, 196)';
								}

								
								options.modelEvents.publish({
								    event: 'OnToolbarHeightChange',
								    data: { value: getToolbarHeight() }
								});
							}
					}];
					
					options.modelEvents.subscribe({event:'OnCompletenessStatusChange'}, function(data) {
						 var oldValue = completenessStatusSpan.textContent;
						 completenessStatusSpan.innerHTML = nlsConfiguratorKeys[data.value];
						 
						 var iconName;
						 switch(data.value)
						 {
							case ConfiguratorVariables.Complete: iconName = "medium";
																break;
							case ConfiguratorVariables.Partial: iconName = "low";
																break;
							case ConfiguratorVariables.Hybrid: iconName = "high";
																break;						 
						 }
						 txtIcon.changeIcon(iconName);
					});
					
					var actionView = new CustomActionsView(getActionObj(that.actionsList));
					actionView = actionView.render();
					actionView.container.setStyles({ /*verticalAlign: 'middle',*/ justifyContent: 'flex-start', display: 'inline-flex'});
					
					actionView.inject(extendedRightToolbarDiv);
					
					
				     //create a span for 3DButton
					if (options.add3DButton && options.add3DButton === "yes") {
					    var _3DButtonSpan = document.createElement('span');
					    _3DButtonSpan.id = "3DButtonSpan";

					    var extended3DButtonSpan = UWA.extendElement(_3DButtonSpan);

					    extended3DButtonSpan.inject(extendedRightToolbarDiv);

					    var activatedState = "false";

					    var _3DButton = new Button({ value: '3D', className: 'info', id: 'my3DButton', }).inject(extended3DButtonSpan);
					    _3DButton.addEvent("onClick", function () {
					        if (activatedState === "true") {
					            activatedState = "false";
					            this.elements.input.className = 'btn-info btn btn-root';
					        }
					        else {
					            activatedState = "true";
					            this.elements.input.className = 'btn-primary btn btn-root';
					        }

					        options.modelEvents.publish({
					            event: 'Request3DFromConfigPanel',
					            data: { value: (activatedState === "true") ? "show" : "hide" }
					        });
					    });

					}

					//Create the div of filtering tools
					var filteringToolsDiv = document.createElement('div');
					filteringToolsDiv.id = "filteringToolsDiv";
					
					var extendedFilteringToolsDiv = UWA.extendElement(filteringToolsDiv);
					
					extendedFilteringToolsDiv.inject(extendedToolbarDiv);
					
					//Create the dropdown to filter the Variant Classes with their status
					var selectStatusDiv = document.createElement('div');
					selectStatusDiv.id = 'selectFilterOnStatusDiv';
					
					var extendedSelectStatusDiv = UWA.extendElement(selectStatusDiv);
					
					extendedSelectStatusDiv.inject(extendedFilteringToolsDiv);

					var buttonFilterStatus = new Button({
						 icon: 'down-dir right',
						 id:'FilterStatusButton'
					}).inject(selectStatusDiv);
										
					var iconFilterStatusSpan = document.createElement('span');
					iconFilterStatusSpan.id = 'iconFilterStatusSpan';
									
					var extendedIconFilterStatusSpan = UWA.extendElement(iconFilterStatusSpan);
					extendedIconFilterStatusSpan.inject(buttonFilterStatus.getContent());
					
					var statusItems = [];

					statusItems.push({ text: nlsConfiguratorKeys["Filter on status"], className: 'header' });
					statusItems.push({ className: "divider" });
					statusItems.push({ name: ConfiguratorVariables.Unselected, text: nlsConfiguratorKeys[ConfiguratorVariables.Unselected], fonticon: 'mouse-pointer-square', selectable: true });
					statusItems.push({ name: ConfiguratorVariables.UnselectedMandatory, text: nlsConfiguratorKeys[ConfiguratorVariables.UnselectedMandatory], fonticon: 'attention', selectable: true });
					statusItems.push({ name: ConfiguratorVariables.ChosenByTheUser, text: nlsConfiguratorKeys[ConfiguratorVariables.ChosenByTheUser], fonticon: 'user-check', selectable: true });
					statusItems.push({ name: ConfiguratorVariables.RequiredByRules, text: nlsConfiguratorKeys[ConfiguratorVariables.RequiredByRules], fonticon: '3ds-how', selectable: true });
					statusItems.push({ name: ConfiguratorVariables.DefaultSelected, text: nlsConfiguratorKeys[ConfiguratorVariables.DefaultSelected], fonticon: 'star', selectable: true });
					if (options.configModel.getAppFunc().rulesMode_ProposeOptimizedConfiguration == "yes")
					    statusItems.push({ name: ConfiguratorVariables.ProposedByOptimization, text: nlsConfiguratorKeys[ConfiguratorVariables.ProposedByOptimization], fonticon: 'chart-area', selectable: true });
					statusItems.push({ name: ConfiguratorVariables.DismissedByTheUser, text: nlsConfiguratorKeys[ConfiguratorVariables.DismissedByTheUser], fonticon: 'user-times', selectable: true });
					statusItems.push({ name: ConfiguratorVariables.SelectionInConflict, text: nlsConfiguratorKeys[ConfiguratorVariables.SelectionInConflict], fonticon: 'alert', selectable: true });
					statusItems.push({ name: ConfiguratorVariables.NoFilter, text: nlsConfiguratorKeys[ConfiguratorVariables.NoFilter], fonticon: '', selected: true, disabled: true });
					
					var params = {
						target: buttonFilterStatus.getContent(),
						multiSelect: false,
						closeOnClick: true,
						id: 'FilterStatusDDMenu',
						items: statusItems,
                        renderTo: options.parentContainer,
						events: {
							onClick: function (e, item) { 
								if(item.elements.icon)
									iconFilterStatusSpan.set('class', item.elements.icon.className);
								else 
									iconFilterStatusSpan.set('class', '');
								
								this.enableItem(this.getItem(ConfiguratorVariables.Unselected).name);
								this.enableItem(this.getItem(ConfiguratorVariables.UnselectedMandatory).name);
								this.enableItem(this.getItem(ConfiguratorVariables.ChosenByTheUser).name);
								this.enableItem(this.getItem(ConfiguratorVariables.RequiredByRules).name);
								this.enableItem(this.getItem(ConfiguratorVariables.DefaultSelected).name);
								this.enableItem(this.getItem(ConfiguratorVariables.ProposedByOptimization).name);
								this.enableItem(this.getItem(ConfiguratorVariables.DismissedByTheUser).name);
								this.enableItem(this.getItem(ConfiguratorVariables.SelectionInConflict).name);
								this.enableItem(this.getItem(ConfiguratorVariables.NoFilter).name);								
								
								this.disableItem(item.name);
								
								options.modelEvents.publish( {
									event:	'OnFilterStatusChange',
									data:	{value : item.name}
								});
							}
						}
					};
					
					var FilterStatusDDMenu = new DropdownMenu(params);
					
					
										
					buttonFilterStatus.inject(selectStatusDiv);
					
					//Create the input to Search on the Variant Classes
					var inputSearchVariantClasses = new InputText({
					    placeholder: nlsConfiguratorKeys["Search"] +' (' + that.currentAttributeForSearch + ')',
						id: 'searchInput'						
					});

					inputSearchVariantClasses.elements.input.ondrop = function (e) {
					    return false;
					};
					
					inputSearchVariantClasses.elements.input.onkeyup = function(e) {
						that.currentValueForSearch = e.target.value;
						if(e.key == "Enter") {						
						    if (e.target.value == '') return;

							addSavedFilter(e.target.value, that.currentAttributeForSearch);
														
							options.modelEvents.publish( {
								event:	'OnFilterStringSaved',
								data:	{
											value : e.target.value,
											attribute : that.currentAttributeForSearch
										}
							});
							
							inputSearchVariantClasses.elements.input.value = '';
							that.currentValueForSearch = '';

							options.modelEvents.publish({
							    event: 'OnToolbarHeightChange',
							    data: { value: getToolbarHeight() }
							});
						}
						else {
						    if (e.key == "Escape") {
						        e.target.value = "";
						    }
							options.modelEvents.publish( {
								event:	'OnSearchValueChange',
								data:	{
										value : e.target.value,
										attribute : that.currentAttributeForSearch
										}	
							});
						}
					}
					
					inputSearchVariantClasses.inject(extendedFilteringToolsDiv);
					
					//Create the dropdown to filter on attributes
					var AttributesMenuDiv = document.createElement('div');
					AttributesMenuDiv.id = 'attributesMenuDiv';
					
					var extendedAttributesMenuDiv = UWA.extendElement(AttributesMenuDiv);
					extendedAttributesMenuDiv.inject(extendedFilteringToolsDiv);
					
					
					var itemListForAttributesDropDown = [
                        { text: nlsConfiguratorKeys["Filter on attributes"], className: 'header' },
                        { className: "divider" }
					];

					for (var m = 0; m < that._attributesList.length; m++) {
					    if (that._attributesList[m] == that.currentAttributeForSearch)
					        itemListForAttributesDropDown.push({ name: that._attributesList[m], text: that._attributesList[m], selected: true, disabled: true });
                        else
					        itemListForAttributesDropDown.push({ name: that._attributesList[m], text: that._attributesList[m], selectable: true });
					}

					//Actions for Attributes Menu icon
					var actionsList = [{
							text : "Attributes menu icon",
							icon: 'menu-dot',
							id: "attributesMenuIcon",
							actionId: 'AttributesMenuIcon',
							tooltip: nlsConfiguratorKeys["Filter on attributes"],
							handler: function(e) {
							},
							style : function() {
    							var iconColor = '#5b5d5e';
    							
    							return { color: iconColor};
    						},
							dropdown : {
								multiSelect: false,
								closeOnClick: true,
								items: itemListForAttributesDropDown,
								events: {
									onClick: function (e, item) {
										that.currentAttributeForSearch = item.name;
										inputSearchVariantClasses.elements.input.placeholder = nlsConfiguratorKeys["Search"] +' (' + item.text + ')';
										
										for (var n = 0; n < that._attributesList.length; n++) {
										    this.enableItem(this.getItem(that._attributesList[n]).name);
										}

										this.disableItem(item.name);
										
										options.modelEvents.publish( {
											event:	'OnFilterAttributeChange',
											data:	{ attribute: item.name,
													value: that.currentValueForSearch
													}
										});
									}
								}
							}
					}];
					
					var actionView = new CustomActionsView(getActionObj(actionsList));
					actionView = actionView.render();
					actionView.container.setStyles({ verticalAlign: 'middle', justifyContent: 'flex-start'});
					
					actionView.inject(AttributesMenuDiv);
					
					
					
					function getActionObj(actionsList) {
						var actionObj = {
						collection : new ActionsCollection(actionsList),
						events : {
							'onActionClick' : function(actionView, event) {
								var actionFunction = actionView.model.get('handler');

									if (UWA.is(actionFunction, 'function')) {
										actionFunction.call(undefined, event);
									}
								}
							}
						};
						
						return actionObj;	
					};
					
					
					//Create the div that will show the saved filters
					var SavedFiltersDiv = document.createElement('div');
					SavedFiltersDiv.id = "savedFiltersDiv";
					
					var extendedSavedFiltersDiv = UWA.extendElement(SavedFiltersDiv);
					
					function addSavedFilter(FilterString, FilterAttribute) {
						var tempDiv = document.createElement('div');
						
						var tempSpan = document.createElement('span');
						tempSpan.innerHTML = FilterString + " (" + FilterAttribute + ")";
						var extendedTempSpan = UWA.extendElement(tempSpan);
						var extendedTempDiv = UWA.extendElement(tempDiv);
						
						extendedTempSpan.inject(tempDiv);
						extendedTempDiv.inject(extendedSavedFiltersDiv);
						
						var actionsList = [{
							text : "Erase icon",
							icon: 'erase',
							actionId: 'EraseIcon',
							handler: function(e) {
								removeSavedFilter(tempDiv, FilterString, FilterAttribute);
							}
						}];
						
						var actionView = new CustomActionsView(getActionObj(actionsList));
						actionView = actionView.render();
						actionView.container.setStyles({ verticalAlign: 'middle', justifyContent: 'flex-start', display: 'inline-flex', float: 'right'});
						
						actionView.inject(tempDiv);
						
						var spans = tempDiv.getElementsByTagName('span');
						if(spans[1].className == "fonticon fonticon-2x fonticon-erase") {
							spans[1].className = "fonticon fonticon-erase";							
						}
					};
					
					function removeSavedFilter(tempDiv, FilterString, FilterAttribute) {
						 tempDiv.parentNode.removeChild(tempDiv);
						 
						 options.modelEvents.publish( {
							event:	'OnFilterStringRemoved',
							data:	{
										value : FilterString,
										attribute : FilterAttribute
									}
						 });

						 options.modelEvents.publish({
						     event: 'OnToolbarHeightChange',
						     data: { value: getToolbarHeight() }
						 });
					};

					function getToolbarHeight() {
					    return extendedSavedFiltersDiv.offsetHeight + parseInt(extendedToolbarDiv.style.height.split("px")[0]) + 10;     //10 is for the marginTop added on savedFiltersDiv
					};
					
					options.parentContainer.addContent(extendedToolbarDiv);
					options.parentContainer.addContent(extendedSavedFiltersDiv);
				 },

				 getToolbarHeight: function () {
				     return document.getElementById("ConfiguratorToolbar").offsetHeight + document.getElementById("savedFiltersDiv").offsetHeight + 10;     //10 is for the marginTop added on savedFiltersDiv

				 }
				 
			 });
			 
			 
		return ToolbarPresenter;
	});
	


define(
		'DS/ConfiguratorPanel/scripts/Presenters/VariantPresenter', 
		[
		 'UWA/Core',
		 'UWA/Controls/Abstract',		 		 		 		 
		 'DS/UIKIT/Input/Text',
		 'DS/UIKIT/Input/Button',		
		 'DS/UIKIT/DropdownMenu',
         'DS/UIKIT/Dropdown',
		
		 'DS/W3DXComponents/Views/Layout/ActionsView',
		 'DS/W3DXComponents/Collections/ActionsCollection',
		 'DS/UIKIT/Iconbar',
		 'DS/UIKIT/Tooltip',
		 'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
         'DS/ConfiguratorPanel/scripts/Utilities',
         'DS/ResizeSensor/js/ResizeSensor',

         'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json',

		 'css!DS/UIKIT/UIKIT.css',
		"css!DS/ConfiguratorPanel/scripts/Presenters/VariantPresenter.css"
		 
		 ],	
		 function (UWA, Abstract, Text, Button, DropdownMenu, Dropdown, ActionsView, ActionsCollection, Iconbar, Tooltip, ConfiguratorVariables, Utilities, ResizeSensor, nlsConfiguratorKeys) {

			'use strict';

			var VariantPresenter = Abstract.extend({
				/**
				 * @description
				 * <blockquote>
				 * <p>Initialiaze the VariantClassesPresenter component with the required options</p>
				 * <p>This component shows all the Features from Dictionary along with
				 * <ul>
				 * <li>Its Image.</li>
				 * <li>Label for Name</li>
				 * <li>Below the Name label , other attribute label is shown if that attribute is used to search feature</li>
				 * <li>Text box for selected Options with drop down to select options </li>
				 * <li>a small info icon to see other attributes </li>				 
				 * <li>Options selected by Rules are shown with a select icon, if clicked , the option will become user selected</li>
				 * </ul>
				 * </p>
				 * </blockquote>
				 *
				 * @memberof module:DS/ConfiguratorPanel/ConfiguratorPanel#
				 *
				 * @param {Object} options - Available options.
				 * @param {Object} options.parentContainer - The parent container where the VariantClassesPresenter will be injected
                 * @param {Object} options.ddRenderTo - Optionnal - To temporary fix the UIKit issue on dropdown display
				 *
				 */
				
				init: function (options) {
					var that = this;
					that.options = options;
					var OneFeatureDiv;
					var optDropDwn;
					var OptRulesDiv;
					var model = options.configModel;
					var psTxtObj;
					this.modelEvents = options.modelEvents;
					var mandNotValuatedBoolValue = false;
					var featureRuleID;
					var mandatory;
					var txtIcon;
					var optionToolTip = new Object();
					var conflictingFeature = false;
					var conflictingOptions = [];
					var selectionMode = ConfiguratorVariables.str_none;
					var requiredByRules = false;
					var RulesRows = [];		
					var selMode_Build = model.getSelectionMode() == ConfiguratorVariables.selectionMode_Build ? true : false;
					var multiSelect;
					var readOnly = model.getReadOnlyFlag();
					var imagesDropdown;
					var feature = options.feature;
					var variantOptions = feature.options;

					var savedFilters = [];
					var selectedFilterStatus = ConfiguratorVariables.NoFilter;
					var currentAttributeSelected = '';
					var displayNameAttr = '';
					var currentSearchValue = "";

                    //Get the attribut which correspond to the display name :
					for (var attr in feature.attributes) {
					    if (feature.attributes[attr] === feature.displayName) {
					        currentAttributeSelected = attr;
					        displayNameAttr = attr;
					        break;
					    }
					}

					//Subscribe to the modelEvents coming from the toolbar
					options.modelEvents.subscribe({ event: 'OnFilterStatusChange' }, function (data) {
					    selectedFilterStatus = data.value;

					    applyFilters();
					});

					options.modelEvents.subscribe({ event: 'OnFilterAttributeChange' }, function (data) {
					    var oldAttributeSelected = currentAttributeSelected;

					    currentAttributeSelected = data.attribute;

					    //Remove previous attribute row
					    removeFilterRow(oldAttributeSelected);

						if(data.value != '')
						{
						    applyFilters();
						}

					    //Add attribute row (if not 'Display Name')
						if (currentAttributeSelected !== displayNameAttr) {
						    var ftrAttrib = OneFeatureDiv.attributes[currentAttributeSelected.replace(/\s+/g, '')];

						    addFilterRow(currentAttributeSelected, ftrAttrib);
						}

					});
					options.modelEvents.subscribe({event:'OnConfigurationModeChange'}, function(data) {
						updateView();
					});
					options.modelEvents.subscribe({event:'OnMultiSelectionChange'}, function(data) {
					    
					    if (data.value === false) {     //if multiSelection is set to false
					        var result = false;

					        if (DetectMultiSelOnSingleVariant()) {
					            
					            result = ResetMultiSelOnSingleVariant();
					            
					            
					            if (model.getRulesActivation() === "false") {
					                updateView();
					            }
					        }

					        options.modelEvents.publish({
					            event: 'displayMessageFeatureReseted',
					            data: {
					                featureId: feature.ruleId,
					                hasBeenReseted: result
					            }
					        });     //a message will be displayed by the VariantClassesPresenter and then the solver will be called
					    }
					});
					options.modelEvents.subscribe({event:'OnRuleAssistanceLevelChange'}, function(data) {
						var rulesMode = model.getRulesActivation();
						if(rulesMode == "false" )
						    refreshViewForNoRuleMode();
					});
					options.modelEvents.subscribe({ event: 'OnSearchValueChange' }, function (data) {
					    currentSearchValue = data.value;

					    applyFilters();
					});


					options.modelEvents.subscribe({ event: 'OnFeaturesDivScrolled' }, function (data) {
					    //if (optDropDwn) optDropDwn.destroy();
				    });

					options.modelEvents.subscribe({event:'OnFilterStringSaved'}, function(data) {
						    
					    savedFilters.push(data);
					    currentSearchValue = '';

						applyFilters();

					    //Add attribute row (if not 'Display Name')
						if (currentAttributeSelected !== displayNameAttr) {
						    var ftrAttrib = OneFeatureDiv.attributes[currentAttributeSelected.replace(/\s+/g, '')];

						    addFilterRow(currentAttributeSelected, ftrAttrib);
						}
					    
					});

					options.modelEvents.subscribe({event:'OnFilterStringRemoved'}, function(data) {
						for(var k=0; k < savedFilters.length; k++)
						{
						    if (savedFilters[k].attribute == data.attribute && savedFilters[k].value == data.value) {
						        savedFilters.splice(k, 1);
							    break;
							}
						}

					    //Remove attribute row
						removeFilterRow(data.attribute);

						applyFilters();
					});
					options.modelEvents.subscribe({
					    event: 'getResultingStatusOriginators_SolverAnswer'
					}, function(data) {

					    var listIncompatibilities = data.listOfIncompatibilitiesIds;
					    var optionSelected = data.optionSelected;
					    var rc = data.answerRC;

					    var message;

					    if (listIncompatibilities.length == 0) {

					        if (rc !== ConfiguratorVariables.str_ERROR) {
					            if (model.getStateWithId(optionSelected) == ConfiguratorVariables.Incompatible)
					                message = UWA.i18n("Option") + " " + model.getOptionDisplayNameWithId(optionSelected) + " " + UWA.i18n("is never valid");
					            else if (model.getStateWithId(optionSelected) == ConfiguratorVariables.Required)
					                message = UWA.i18n("Option") + " " + model.getOptionDisplayNameWithId(optionSelected) + " " + UWA.i18n("is always required");
					        }
					    } else {
					        var msgStr1 = UWA.i18n("Option #OPTION# is #STATUS# because") + ":";
					        msgStr1 = msgStr1.replace("#OPTION#", model.getOptionDisplayNameWithId(optionSelected));
					        msgStr1 = msgStr1.replace("#STATUS#", UWA.i18n(model.getStateWithId(optionSelected)));
					        message = msgStr1;

					        for (var i = 0; i < listIncompatibilities.length; i++) {

					            if (i > 0)
					                message += "<br>" + UWA.i18n("and because") + ":";

					            for (var j = 0; j < listIncompatibilities[i].length; j++) {

					                state = model.getStateWithId(listIncompatibilities[i][j]);

					                var msgStr2 = UWA.i18n("#OPTION# is #STATUS#");
					                msgStr2 = msgStr2.replace("#OPTION#", model.getFeatureDisplayNameWithId(listIncompatibilities[i][j]) + "[" + model.getOptionDisplayNameWithId(listIncompatibilities[i][j]) + "]");
					                msgStr2 = msgStr2.replace("#STATUS#", UWA.i18n(state));
					                message += "<br><blocquote style='padding-left:20px;'>" + msgStr2 + "</blocquote>";
					            }

					        }

					        if (rc === ConfiguratorVariables.str_ERROR)
					            message += "<br>" + UWA.i18n("InfoComputationAborted");;
					    }

					    if (rc === ConfiguratorVariables.str_ERROR) {
					        message += UWA.i18n("InfoComputationAborted");
					    }
						
						if(optionToolTip[optionSelected]) optionToolTip[optionSelected].setBody(message);
					});
					
					options.modelEvents.subscribe({event:'solveAndDiagnoseAll_SolverAnswer'},function(data) {
					    if (!readOnly)
					        updateView()
					});


					function updateView()
					{
					    var featureIconState;
					    var conflicting = false;
					    var listOfStates = [];
					    cleanTextBox(psTxtObj.getContent());
					   
					    for(var i=0; i < RulesRows.length; i++) {
					        RulesRows[i].destroy();
					    }
					    RulesRows = [];

					    selMode_Build = model.getSelectionMode() == ConfiguratorVariables.selectionMode_Build ? true : false;
					    selectionMode = ConfiguratorVariables.str_none;
					    conflictingFeature = false;
					    conflictingOptions = [];
					    					    
					    for (var j = 0; j < variantOptions.length; j++) {
					        //once conflicting option found for the feature, set it , and no need to check it for other options
					        if(model.getRulesActivation() === "true") {
					            conflicting = model.isConflictingOption(variantOptions[j].ruleId);
					            if (conflictingFeature == false) conflictingFeature = conflicting;

					            if (conflicting)
					                conflictingOptions.push(variantOptions[j].ruleId);
					        }

					        var optionState = model.getStateWithId(variantOptions[j].ruleId);
					        if (!optionState) optionState = ConfiguratorVariables.Unselected;
					        listOfStates.push(optionState);

					        if (optionState == ConfiguratorVariables.Chosen || optionState == ConfiguratorVariables.Default || optionState == ConfiguratorVariables.Required)
					            selectionMode = optionState;

					        //to set the icon for the Feature
					        if (conflicting == true) {
					            featureIconState = ConfiguratorVariables.Conflict;
					        }
					        else {
					            if (optionState == ConfiguratorVariables.Chosen || (optionState == ConfiguratorVariables.Dismissed && featureIconState != ConfiguratorVariables.Chosen) || (optionState == ConfiguratorVariables.Default && (featureIconState != ConfiguratorVariables.Chosen && featureIconState != ConfiguratorVariables.Dismissed)))
					                featureIconState = optionState;					            
					        }

					        switch (optionState) {
					            case ConfiguratorVariables.Required:
					                addRulesRow("component", variantOptions[j].displayName, OptRulesDiv, variantOptions[j].ruleId);
					                break;
					            case ConfiguratorVariables.Incompatible:
					                break;
					            case ConfiguratorVariables.Chosen:
					                var dontCheck = true; //dont remove the value if already there, just add if not there
					                updateTextBox(psTxtObj.getContent(), variantOptions[j].displayName, dontCheck);
					                break;
					            case ConfiguratorVariables.Default:
					                addRulesRow("star", variantOptions[j].displayName, OptRulesDiv, variantOptions[j].ruleId);
					                break;
					            case ConfiguratorVariables.Dismissed:
					                if (selMode_Build == false) {
					                    updateTextBox(psTxtObj.getContent(), UWA.i18n("Except") + " " + variantOptions[j].displayName);
                                    }
					                break;
					            case ConfiguratorVariables.Unselected:
					                break;
					        }
					    }
					    
					    var selected = (selectionMode == ConfiguratorVariables.str_none) ? false : true;
					    updateMand(selected);
					    updateSelectedOptionsNumberAndImagesDropdownContent();
					    txtIcon.changeIcon(featureIconState);

					    if (selMode_Build == false && listOfStates.indexOf(ConfiguratorVariables.Chosen) == -1 &&
                            listOfStates.indexOf(ConfiguratorVariables.Default) == -1 &&
                            listOfStates.indexOf(ConfiguratorVariables.Required) == -1 /*&& 
                            listOfStates.indexOf("recommanded") == -1*/) {

					        psTxtObj.getContent().placeholder = nlsConfiguratorKeys["All compatibles"];
					    }
					    else
					        psTxtObj.getContent().placeholder = nlsConfiguratorKeys["No user selection"];

					    applyFilters();

					}
					
					function refreshViewForNoRuleMode()
					{
                        //Set all states to Unselected (except user selections)
                        for(var j=0; j< variantOptions.length; j++) {
                            if (model.getStateWithId(variantOptions[j].ruleId) === ConfiguratorVariables.Default ||
                                model.getStateWithId(variantOptions[j].ruleId) === ConfiguratorVariables.Incompatible ||
                                model.getStateWithId(variantOptions[j].ruleId) === ConfiguratorVariables.Required /*|| 
                                model.getStateWithId(variantOptions[j].ruleId) === ConfiguratorVariables.Recommanded*/) {
                                    model.setStateWithId(variantOptions[j].ruleId, ConfiguratorVariables.Unselected);
                            }
                        }

						updateView();
					
					}
					/*function removeInfoIcon(itemContainer, optionId)
					{					
					    if (itemContainer.lastChild && itemContainer.lastChild.id && itemContainer.lastChild.id == 'itemInfoIcon' + optionId)
						itemContainer.lastChild.destroy();
						
						if(optionToolTip[optionId])
						optionToolTip[optionId] = null;
					}*/				
					
					function addInfoIcon(itemContainer, optionId, conflicting)
					{									
						var color = '#42a2da';
						var icon = ConfiguratorVariables.str_help;
						var message = '';
						if (conflicting && conflicting == true) {
						    color = 'red';
						    icon = 'alert';
						    var addAlso;
						    message = UWA.i18n("Option") + " " + model.getOptionDisplayNameWithId(optionId) + " " + UWA.i18n("is conflicting with") + ":";
						    var listOfListOfConflictingIds = model.getConflictingFeatures();
						    var listOfListOfRulesImplied = model.getImpliedRules();
						    //need to traverse the list again, to generate the text for tooltip

						    for (var i = 0; i < listOfListOfConflictingIds.length; i++) {

						        if (listOfListOfConflictingIds[i].indexOf(optionId) != -1) {

						            if (addAlso)
						                message += UWA.i18n("and also conflicting with") + ":";

						            for (var j = 0 ; j < listOfListOfConflictingIds[i].length; j++) {
						                if (optionId != listOfListOfConflictingIds[i][j]) {
						                    message += "<br><blocquote style='padding-left:20px;'>" + model.getFeatureDisplayNameWithId(listOfListOfConflictingIds[i][j]) + "[" + model.getOptionDisplayNameWithId(listOfListOfConflictingIds[i][j]) + "] </blocquote>";
						                    addAlso = true;
						                }
						            }

						            if (listOfListOfRulesImplied.length > 0) {
						                for (var j = 0 ; j < listOfListOfRulesImplied[i].length; j++) {
						                    if (j == 0) {
						                        message += "<br><blocquote style='padding-left:20px;'> " + UWA.i18n("Implied Rules") + ":</blocquote>";
						                    }
						                    message += "<br><blocquote style='padding-left:40px;'>" + listOfListOfRulesImplied[i][j] + "</blocquote>";
						                }
						            }
						            message += "<br>";

						            break;
						        }

						    }

						    var itemInfoIcon = getIcon({ id: 'itemInfoIcon' + optionId, icon: icon, color: color });


						    optionToolTip[optionId] = new Tooltip({
						        target: itemInfoIcon,
						        //position: 'right',
						        body: message
						    });
						    itemInfoIcon.inject(itemContainer);

						}
						else {
						    //ConfiguratorSolverFunctions.getResultingStatusOriginators(optionId);

						    var itemInfoIcon = getIcon({ id: 'itemInfoIcon' + optionId, icon: icon, color: color });


						    optionToolTip[optionId] = new Tooltip({
						        target: itemInfoIcon,
						        //position: 'right',
						        body: message
						    });
						    itemInfoIcon.inject(itemContainer);

						    that.modelEvents.publish({
						        event: 'SolverFct_getResultingStatusOriginators',
						        data: { value: optionId }
						    });
						}
						
											
					}
					function addDefaultIcon(itemContainer, optionId)
					{									
						var color = '#42a2da';
						var icon = 'star';

						var defaultIcon = getIcon({ id: 'defaultIcon' + optionId,	icon: icon, color: color});						
					
						defaultIcon.inject(itemContainer);						
					}

					function showOptionSelected(optionRuleId)
					{															
					    model.setStateWithId(optionRuleId, ConfiguratorVariables.Chosen);
							
						that.modelEvents.publish({
							event: 'SolverFct_CallSolveMethodOnSolver',
							data: {}
						});																			
					}
                    
					function addFilterRow(attribute, ftrAttrib)
					{
					    var ftrFlt = document.getElementById('FtrFiltersDiv' + featureRuleID);

						var fltRow = document.getElementById(featureRuleID + attribute );
						if(fltRow) return;

						var showString = ftrAttrib;
						if(ftrAttrib.length > 28) 
							showString = ftrAttrib.substring(0,24) + '...';

						fltRow = UWA.createElement( 'tr',{ styles: {width: '100%'} , 'class' : 'unsavedFilter', id: featureRuleID + attribute, 
							html: [{ tag: 'td', 
								html: [ getLabelField(attribute + ':' + showString, 'font-style:italic; font-weight:normal;')]
							}]
						});
						fltRow.inject(ftrFlt);					
					}

					function removeFilterRow(attribute) {
					    //Remove attribute row (if attribute is not present in one of the saved filters or in the current attribute selected)
					    var ftrFlt = document.getElementById('FtrFiltersDiv' + featureRuleID);
					    var removeAttribute = true;

					    if (attribute === displayNameAttr)
					        return;

					    for (var k = 0; k < savedFilters.length; k++) {
					        if (savedFilters[k].attribute == attribute) {
					            removeAttribute = false;

					            break;
					        }
					    }

					    if (removeAttribute && currentAttributeSelected !== attribute) {
					        var attrRow = document.getElementById(featureRuleID + attribute);

					        if (attrRow)
					            attrRow.parentNode.removeChild(attrRow);
					    }
					}

					/*function getActionObj(actionsList) {
						var actionObj = {
						collection : new ActionsCollection(actionsList),
						events : {
							'onActionClick' : function(actionView, event) {
								var actionFunction = actionView.model.get('handler');

									if (UWA.is(actionFunction, 'function')) {
										actionFunction.call(undefined, event);
									}
								}
							}
						};
						
						return actionObj;	
					};*/
					function addRulesRow(icon, optionVal, rulesDiv, optionRuleId)
					{							
						var ruleinfoIcon = '';
						if (!readOnly) {
						    ruleinfoIcon = getIcon({ id: 'ruleinfoIcon' + optionRuleId, icon: 'check', color: ' #42a2da' });
						    ruleinfoIcon.onclick = function () {
						        showOptionSelected(optionRuleId);
						        //RulesRows.destroy(); 
						    };
						}

						var tempLine = UWA.createElement('tr', {
						    styles: { width: '100%' },
						    id: 'OptRuleType' + optionRuleId,
						    html: [{
						        tag: 'td', styles: { width: "20px" },
						        html: [getIcon({ id: 'OptRuleIcon' + optionRuleId, icon: icon })]
						    },
                            {
                                tag: 'td',
                                html: [optionVal]
                            },
                            {
                                tag: 'td', styles: { width: '50%', 'text-align': 'right' },
                                //html: [ getIcon({	id: 'OptRuleChk' + optionRuleId,	icon: 'check'})]
                                html: [ruleinfoIcon]
                            }]
						});

						RulesRows.push(tempLine);
						tempLine.inject(rulesDiv);
					}

					function applyFilters()
					{
					    OneFeatureDiv.style.display = 'inline-block';

						if ( (currentSearchValue !== '' || savedFilters.length !== 0)) {
						    //Apply saved filters
						    for(var j=0; j< savedFilters.length; j++ )
						    {
						        var ftrAttrib = OneFeatureDiv.attributes[savedFilters[j].attribute.replace(/\s+/g, '')];
													 
						        if (!ftrAttrib.toUpperCase().contains(savedFilters[j].value.toUpperCase())) {
						            OneFeatureDiv.style.display = 'none';					 
						        }							
						    }

						    //Apply search filter
						    var ftrAttribValue = OneFeatureDiv.attributes[currentAttributeSelected.replace(/\s+/g, '')];
                        
							if (!ftrAttribValue.toUpperCase().contains(currentSearchValue.toUpperCase())) {
							    OneFeatureDiv.style.display = 'none';
							}
						}
						
                        //Apply Status Filter
						if (selectedFilterStatus !== ConfiguratorVariables.NoFilter) {
						    var listOfStates = [];
						    //get all status in the feature
						    for (var j = 0; j < variantOptions.length; j++) {
						        var optionState = model.getStateWithId(variantOptions[j].ruleId);
						        if (!optionState) optionState = ConfiguratorVariables.Unselected;
						        listOfStates.push(optionState);
						    }

						    if (selectedFilterStatus === ConfiguratorVariables.SelectionInConflict && !conflictingFeature) {
						        OneFeatureDiv.style.display = 'none';
						    }

						    else if (selectedFilterStatus === ConfiguratorVariables.UnselectedMandatory && !mandNotValuatedBoolValue) {
						        OneFeatureDiv.style.display = 'none';
						    }

						    else if (selectedFilterStatus === ConfiguratorVariables.ChosenByTheUser && listOfStates.indexOf(ConfiguratorVariables.Chosen) === -1) {
						        OneFeatureDiv.style.display = 'none';
						    }
						    else if (selectedFilterStatus === ConfiguratorVariables.DefaultSelected && listOfStates.indexOf(ConfiguratorVariables.Default) === -1) {
						        OneFeatureDiv.style.display = 'none';
						    }
						    else if (selectedFilterStatus === ConfiguratorVariables.DismissedByTheUser && listOfStates.indexOf(ConfiguratorVariables.Dismissed) === -1) {
						        OneFeatureDiv.style.display = 'none';
						    }
						    else if (selectedFilterStatus === ConfiguratorVariables.Unselected
							             && (listOfStates.indexOf(ConfiguratorVariables.Chosen) >= 0
							             || listOfStates.indexOf(ConfiguratorVariables.Default) >= 0
										 || listOfStates.indexOf(ConfiguratorVariables.Required) >= 0)) {
						        OneFeatureDiv.style.display = 'none';
						    }
						    else if (selectedFilterStatus === ConfiguratorVariables.RequiredByRules && listOfStates.indexOf(ConfiguratorVariables.Required) === -1) {
						        OneFeatureDiv.style.display = 'none';
						    }
						    /*else if (selectedFilterStatus === ConfiguratorVariables.ProposedByOptimization && listOfStates.indexOf(ConfiguratorVariables.ProposedByOptimization) === -1) {
						        OneFeatureDiv.style.display = 'none';
						    }*/ //todo later
						}
                        						
						options.modelEvents.publish( {
							event:	'OnFilterResultChange',
							data:	{
								featureId : featureRuleID, 
								resultBoolValue: (OneFeatureDiv.style.display === 'inline-block') ? true : false,
								show: (savedFilters.length > 0 || selectedFilterStatus != ConfiguratorVariables.NoFilter || currentSearchValue != '') ? true : false
							}
						});
					}
					function getLabelField(value , style, display, className) {
						var labeltag = ' <label style=\"display: '

						if (!display) display = 'block';

						labeltag = labeltag.concat(display);
						labeltag = labeltag.concat(';padding: 5px 5px 0px 0px;font-family: sans-serif;');
						if(style && style!="") labeltag = labeltag.concat(style);
						labeltag = labeltag.concat('\" ');
						if (className) labeltag = labeltag.concat(" class=featureLabel ");
						labeltag = labeltag.concat(' >' + value + '</label>');

						return labeltag;
					}					

					function getIcon(options)
					{
						var IconDiv = UWA.createElement('span',{
							'class': 'fonticon fonticon-' + options.icon ,
							id: options.id,
							styles : {color: options.color},													
						});
						if(options.id && options.id !='') IconDiv.id = options.id;
						IconDiv.changeIcon = function(state)
						{
							
							var icon = ConfiguratorVariables.str_user;
							this.style.opacity = 1;
							if( mandNotValuatedBoolValue == true)
							{
								this.set('class', "fonticon fonticon-attention");										
								this.style.color ='black';								
							}								
							else
							{
								if(state == ConfiguratorVariables.Conflict )
								{
									this.set('class', "fonticon fonticon-alert");
									this.style.color = 'red';						
								}
								else if(state == ConfiguratorVariables.Chosen)
								{
									this.set('class', "fonticon fonticon-user-check");
									this.style.color = '#42a2da';								
								}
								else if(state == ConfiguratorVariables.Dismissed)
								{
									this.set('class', "fonticon fonticon-user-times");
									this.style.color = 'rgb(91, 93, 94)';								
								}
								else
								{this.set('class', "fonticon fonticon-user");
								this.style.opacity = 0;
								}
							
							}

						};
						return IconDiv;
					}
					function getOptDropDown(options)
					{
					    if (optDropDwn) optDropDwn.destroy();

						var myOptDropDwn = new DropdownMenu({
						    target: options.target,
						    renderTo: options.renderTo,
							//id: options.id,
							multiSelect: options.multiSelect,	
							multiline: 	options.multiline	,							
							mand : options.mand,
							firstShow: true,
							className : 'OptionsDD',
							closeOnClick: true,
							position : 'bottom',
							items: [],
							
						});			

						myOptDropDwn.addEvents({
							onShow: function(){
								if(!this.options.firstShow) return;
								this.options.firstShow = false;
								for(var i=0; i< this.items.length; i++)
								{	
								    this.items[i].elements.icon.style.color = '#42a2da';
									if(this.items[i].fonticon == 'user')
									{
										this.items[i].fonticon = '';
										this.items[i].elements.icon.removeClassName('fonticon-user');
									}

									if (this.items[i].elements.icon.className == 'fonticon fonticon-user-times') {
									    this.items[i].elements.icon.style.color = 'rgb(91, 93, 94)';
									}
								}
							},
							onClick: function (e, item) {
								var status;
								var itemState = model.getStateWithId(item.name);
								var rulesMode = model.getRulesActivation();

								var curThis = this;

								function CheckIfDismissedIsPossible() {
								    var rc = false;
                                    
                                    //Prevent the reject if we already have a selection in same feature
								    for (var i = 0; i < curThis.items.length; i++) {
								        if (curThis.items[i] == item) continue;

								        var optionState = model.getStateWithId(curThis.items[i].name);
								        if (optionState === ConfiguratorVariables.Chosen || optionState === ConfiguratorVariables.Required || optionState === ConfiguratorVariables.Default) {
								            rc = false;
								            return rc;
								        }
								    }

								    if (feature.selectionCriteria === "May") {
								        rc = true
								        return rc;
								    }
								    else {
								        for (var i = 0; i < curThis.items.length; i++) {
								            if (curThis.items[i] == item) continue;

								            var optionState = model.getStateWithId(curThis.items[i].name);
								            if (optionState !== ConfiguratorVariables.Dismissed && optionState !== ConfiguratorVariables.Incompatible) {
								                rc = true;
								                return rc;
								            }
								        }

								    }								        

								    return rc;
								};

								if(rulesMode == "false" )
								{

								    if (selMode_Build == false) {
								        if (itemState && (itemState == ConfiguratorVariables.Dismissed)) {
								            itemState = ConfiguratorVariables.Chosen;
								            status = true;

								            //TODO : Remove all the user Rejects if any
								            for (var i = 0; i < this.items.length; i++) {
								                if (this.items[i] == item) continue;

								                if (model.getStateWithId(this.items[i].name) === ConfiguratorVariables.Dismissed)
								                    model.setStateWithId(this.items[i].name, ConfiguratorVariables.Unselected);
								            }
								        }
								        else if (itemState && (itemState == ConfiguratorVariables.Chosen)){
								            itemState = ConfiguratorVariables.Unselected;
								            status = false;
								        }
								        else {
								            if (!CheckIfDismissedIsPossible()) {
								                if (itemState == ConfiguratorVariables.Unselected) {
								                    itemState = ConfiguratorVariables.Chosen;
								                    status = true;
								                }
                                                else {
								                    return;
								                }
								            }
								            else {
								                itemState = ConfiguratorVariables.Dismissed;
								                status = false;
								            }
								        }

								    }
                                    else {
								        if(itemState && ( itemState == ConfiguratorVariables.Chosen))
								        {
								            itemState = ConfiguratorVariables.Unselected;
									        status = false;
									    }
								        else
								        {
									        status = true;
									        itemState = ConfiguratorVariables.Chosen;
								        }
								    }

								    model.setStateWithId(item.name, itemState);

                                    //if we are in Single selection mode, remove all the other selections done in the variant class (if any...)
								    if (!(feature.selectionType === "Multiple" || model.getMultiSelectionState() === "true") && status == true)
								    {								
									    for(var i=0; i< this.items.length; i++)
									    {
										    if(this.items[i] == item) continue;
										    if (model.getStateWithId(this.items[i].name) === ConfiguratorVariables.Chosen)
										    {			
											    model.setStateWithId(this.items[i].name, ConfiguratorVariables.Unselected);
										    }
									    }										
								    }

								    updateView();

								    /*updateMand(status , false)
								    updateSelectedOptionsNumberAndImagesDropdownContent();*/
								}
								else //if calling solver, then no need to update UI here itself, to be done after rules results
								{
								    if(selMode_Build == false)
								    {
								        if (itemState == ConfiguratorVariables.Dismissed || itemState == ConfiguratorVariables.Required) {
								            itemState = ConfiguratorVariables.Chosen;
								            status = true;

								            //TODO : Remove all the user Rejects if any
								            for (var i = 0; i < this.items.length; i++) {
								                if (this.items[i] == item) continue;

								                if (model.getStateWithId(this.items[i].name) === ConfiguratorVariables.Dismissed)
								                    model.setStateWithId(this.items[i].name, ConfiguratorVariables.Unselected);
								            }
								        }
									    else if(itemState == ConfiguratorVariables.Chosen) {
									        itemState = ConfiguratorVariables.Unselected;	
									        status = false;
									    }
									    else {
									        if (!CheckIfDismissedIsPossible()) {
									            if (itemState == ConfiguratorVariables.Unselected) {
									                itemState = ConfiguratorVariables.Chosen;
									                status = true;
									            }
									            else if (itemState == ConfiguratorVariables.Default) {
									                itemState = ConfiguratorVariables.Dismissed;
									                status = false;
									            }
									            else {
									                return;
									            }
									        }
									        else {
									            itemState = ConfiguratorVariables.Dismissed;
									            status = false;
									        }
									    }
								
								    }
								    else
								    {
								        if(itemState && ( itemState == ConfiguratorVariables.Chosen)) {
								            itemState = ConfiguratorVariables.Unselected;
									        status = false;
									    }
								        
									    else if(itemState == ConfiguratorVariables.Default) {
									        itemState = ConfiguratorVariables.Dismissed;
									        status = false;
									    }
									    else if (itemState == ConfiguratorVariables.Dismissed) {
									        itemState = ConfiguratorVariables.Unselected;
									        status = false;
									    }
									    else {
									        itemState = ConfiguratorVariables.Chosen;
									        status = true;

									        //TODO : Remove all the user Rejects if any (Reject of Default in same feature)
									        for (var i = 0; i < this.items.length; i++) {
									            if (this.items[i] == item) continue;

									            if (model.getStateWithId(this.items[i].name) === ConfiguratorVariables.Dismissed)
									                model.setStateWithId(this.items[i].name, ConfiguratorVariables.Unselected);
									        }
									    }
								        
								        
								    }

								    model.setStateWithId(item.name, itemState);

								    //if we are in Single selection mode, remove all the other selections done in the variant class (if any...)
								    if (status == true && !(feature.selectionType === "Multiple" || model.getMultiSelectionState() === "true")) {
								        for (var i = 0; i < this.items.length; i++) {
								            if (this.items[i] == item) continue;

								            if (model.getStateWithId(this.items[i].name) === ConfiguratorVariables.Chosen)
								                model.setStateWithId(this.items[i].name, ConfiguratorVariables.Unselected);
								        }
								    }

								    that.modelEvents.publish({
								        event: 'SolverFct_CallSolveMethodOnSolver',
								        data: {}
								    });
								}

								if (myOptDropDwn) myOptDropDwn.destroy();
							},
							onHide: function ()
							{
							    this.options.target.blur();
							},
							onClickOutside: function () {
							    if (myOptDropDwn) myOptDropDwn.destroy();
							}
						});

						return myOptDropDwn;
					}
					function updateMand(status /*true if selected*/)
					{
						var oldMandNotValuatedBoolValue = model.getFeatureIdWithMandStatus(featureRuleID);
						mandNotValuatedBoolValue = (mandatory || model.getStateWithId(feature.ruleId) === ConfiguratorVariables.Required)? !status : false;
						options.modelEvents.publish({
							event :	'updateMANDNumberAndRefresh3D',
							data :{
							featureId : featureRuleID, 
							mandNotValuatedBoolValue : mandNotValuatedBoolValue, 
							waitForAllFeatures: (model.getRulesActivation() == "true") ? true : false, // right now setting for no-rule mode
							oldMandNotValuatedBoolValue: oldMandNotValuatedBoolValue //just for testing for now
							}
						});					
					}

					function updateSelectedOptionsNumberAndImagesDropdownContent() {
					    var listOfSelectedOptions = [];
					    //var variantOptions = feature.options;
					    var variantImage = document.getElementById("variantImage" + feature.ruleId);
					    var variantImageDiv = document.getElementById("variantImageDiv" + feature.ruleId);
					    var numberOfSelectedOptions = document.getElementById("numberOfSelectedOptions_" + feature.ruleId);

					    //Get options selected
					    for (var j = 0; j < variantOptions.length; j++) {
					        var optionState = model.getStateWithId(variantOptions[j].ruleId);

					        if (optionState === ConfiguratorVariables.Chosen || optionState === ConfiguratorVariables.Required || optionState === ConfiguratorVariables.Default)
                                listOfSelectedOptions.push(variantOptions[j].ruleId);
					    }
					    
					    
					    if (listOfSelectedOptions.length > 0) {
					        if (listOfSelectedOptions.length === 1) {
					            //Set feature icon & feature icon border
					            variantImageDiv.style.border = "1px solid #42a2da";

					            for (var i = 0; i < feature.options.length; i++) {
					                if (feature.options[i].ruleId === listOfSelectedOptions[0]) {
					                    if (feature.options[i].image)
					                        variantImage.src = feature.options[i].image;
					                    else
					                        variantImage.src = feature.image;
					                    break;
					                }
					            }
					            
					            //Set imagesDropdown visibility
					            numberOfSelectedOptions.innerHTML = 1;
					            numberOfSelectedOptions.style.display = "none";
					            //Set imagesDropdown content
					            imagesDropdown.getBody().innerHTML = "";
					        }
					        else if (listOfSelectedOptions.length > 1) {
					            //Set feature icon & feature icon border
					            if (feature.image)
					                variantImage.src = feature.image;
					            variantImageDiv.style.border = "1px solid #42a2da";

					            numberOfSelectedOptions.innerHTML = 0;

					            //Set imagesDropdown content
					            imagesDropdown.setBody({});

					            for (var i = 0; i < listOfSelectedOptions.length; i++) {
					                for (var k = 0; k < feature.options.length; k++) {
					                    if (feature.options[k].image) {
					                        numberOfSelectedOptions.innerHTML = numberOfSelectedOptions.innerHTML++;
					                        imagesDropdown.setBody(UWA.createElement('img', { src: feature.options[k].image, 'class': 'img-thumbnail', styles: { width: '80px', height: '80px', marginRight: '5px', marginTop: '5px' } }));
					                    }
					                }
					            }

					            //Set imagesDropdown visibility
					            if (numberOfSelectedOptions.innerHTML > 1)
					                numberOfSelectedOptions.style.display = "block";
					        }
					        
					    }
					    else {
					        //Set feature icon & feature icon border
					        if (feature.image)
					            variantImage.src = feature.image;
					        variantImageDiv.style.border = "1px solid #b1b1b1";

					        //Set imagesDropdown visibility
					        numberOfSelectedOptions.innerHTML = 0;
					        numberOfSelectedOptions.style.display = "none";

					        //Set imagesDropdown content
                            imagesDropdown.getBody().innerHTML = "";
					    }
					}

					function cleanTextBox(myText)
					{
					    var data = myText.value;        //myText.getText();
						 myText.value = '';      //myText.setText('');
					}

					function updateTextBox(myText, val, dontCheck)	{
					    var data = myText.value;        //myText.getText();

					    if (!(feature.selectionType === "Multiple" || selMode_Build === false || model.getMultiSelectionState() === "true"))
						{								
					        if (data == val) myText.value = '';      //myText.setText('');									
					        else myText.value = val;      //myText.setText(val);		
							myText.rows = 1;							
						}
						else
						{									
							var dArray = [];									
							if(data != "")
							{										
								dArray = data.split("\n");										
							}
							var i = dArray.indexOf(val);
							if(i != -1) //if value already there , remove it
							{	if(dontCheck) dArray.splice(i, 1);	}									
							else
								dArray.push(val);									

							myText.value = dArray.join("\n");      //myText.setText(dArray.join("\n"));	
							myText.rows = dArray.length <= 5? dArray.length :5;
						}
					}

					function DetectMultiSelOnSingleVariant() {
					    var nbChosenInFeature = 0;
					    var multiSelDetected = false;

					    
					    if (feature.selectionType == "Single") {
					        for (var j = 0; j < feature.options.length; j++) {
					            if (model.getStateWithId(feature.options[j].ruleId) == ConfiguratorVariables.Chosen  || model.getStateWithId(feature.options[j].ruleId) == ConfiguratorVariables.Default) {
					                nbChosenInFeature++;
					            }
					        }

					        if (nbChosenInFeature > 1) {
					            multiSelDetected = true;
					        }

					    }

					    return multiSelDetected;

					}
					            
					function ResetMultiSelOnSingleVariant() {
					    var reset = false;

					    for (var j = 0; j < feature.options.length; j++) {
					        if (model.getStateWithId(feature.options[j].ruleId) == ConfiguratorVariables.Chosen || model.getStateWithId(feature.options[j].ruleId) == ConfiguratorVariables.Default) {
					            model.setStateWithId(feature.options[j].ruleId, ConfiguratorVariables.Unselected);
					            reset = true;
					        }
					    }

					    return reset;
					}
					            


                    //init starts here
					var image = Utilities.getDefaultImage();    //"https://iam.3ds.com/fileadmin/img/3dexperience/3DEXLoginCompass.png";
					var imageStyle = { border: '0px'};
					var imageDivStyle = { width: '80px', height: '80px', marginRight: '5px', marginTop: '10px', verticalAlign: 'middle', lineHeight: '80px', borderRadius: '4px'};
					
					if (feature.image)
					    image = feature.image;
					
					var psTxt = Text.extend({
						defaultOptions: {
							className: 'psTxt',						
							placeholder: nlsConfiguratorKeys["No user selection"],
							rows:1,						
						},
						init: function(options)
						{
							this._parent(options);
						},
					});


					psTxtObj = new Text({ id: 'psTxt' + feature.ruleId, multiline: true, rows: 1, placeholder: nlsConfiguratorKeys["No user selection"] });
					    psTxtObj.getContent().style.minHeight = "38px";         //to prevent IE to create scrollbar even if the textarea is empty
						multiSelect = (feature.selectionType == "Multiple" || model.getMultiSelectionState() === "true" || selMode_Build === false) ? true : false;
						psTxtObj.multiline = multiSelect;
						psTxtObj.elements.input.ondrop = function (e) {
						    return false;
						};

						psTxtObj.addEvents({
						    onClick: function () {
						        
						        optDropDwn = getOptDropDown({
						            target: psTxtObj.getContent(),
						            renderTo: (options.ddRenderTo) ? options.ddRenderTo : options.parentContainer,
						            multiSelect: (feature.selectionType == "Multiple" || selMode_Build === false || model.getMultiSelectionState() === "true") ? true : false,
						            multiline: (feature.selectionType == "Multiple" || selMode_Build === false || model.getMultiSelectionState() === "true") ? true : false,
						            mand: (feature.selectionCriteria == 'Must') ? true : false
						        });

						        for(var j=0; j< variantOptions.length; j++) {
						            //var fonticon = items[j].selected ? 'user-check' : 'user';
						            optDropDwn.addItem({ name: variantOptions[j].ruleId, text: variantOptions[j].displayName, fonticon: 'user', selectable: true, selected: false });

						            if (variantOptions[j].defaultSelection == 'Yes') {
						                addDefaultIcon(optDropDwn.items[optDropDwn.items.length - 1].elements.container, variantOptions[j].ruleId);
						            }
						        }

						        var items = optDropDwn.items;
						        var listOfStates = [];

						        for (var k = 0; k < items.length; k++) {
						            //disable items in readOnly !!!
						            if (readOnly)
						                optDropDwn.disableItem(items[k].id);
						            else
						                optDropDwn.enableItem(items[k].id);

						            var optionState = model.getStateWithId(items[k].name);
						            if (!optionState) optionState = ConfiguratorVariables.Unselected;

						            listOfStates.push(optionState);

                                    //add Conflicts icon on options if needed
						            if (conflictingOptions.indexOf(items[k].name) !== -1) {
						                addInfoIcon(items[k].elements.container, items[k].name, true);
						            }

						            switch (optionState) {
						                case ConfiguratorVariables.Required:
						                    items[k].elements.icon.set('class', "fonticon fonticon-component");
						                    if (!readOnly) addInfoIcon(items[k].elements.container, items[k].name);
						                    if (items[k].selected == false) items[k].toggleSelection();
						                    break;
						                case ConfiguratorVariables.Incompatible:
						                    optDropDwn.disableItem(items[k].id);
						                    items[k].elements.icon.set('class', "fonticon");//left icon
						                    if (!readOnly) addInfoIcon(items[k].elements.container, items[k].name);//right icon			
						                    break;
						                case ConfiguratorVariables.Chosen:
						                    if (items[k].selected == false) items[k].toggleSelection();
						                    items[k].elements.icon.set('class', "fonticon fonticon-user-check");
						                    break;
						                case ConfiguratorVariables.Default:
						                    items[k].elements.icon.set('class', "fonticon");
						                    if (items[k].selected == false) items[k].toggleSelection();
						                    break;
						                case ConfiguratorVariables.Dismissed:
						                    items[k].elements.icon.set('class', "fonticon fonticon-user-times");
						                    //if (items[k].selected == false) items[k].toggleSelection();
						                    items[k].elements.icon.style.color = 'rgb(91, 93, 94)';
						                    break;
						                case ConfiguratorVariables.Unselected:
						                    items[k].elements.icon.set('class', "fonticon");
						                    break;
						            }
						        }

                                //Select the Unselected states in refine mode
						        if (selMode_Build === false) {
						            if (listOfStates.indexOf(ConfiguratorVariables.Chosen) == -1 &&
                                        listOfStates.indexOf(ConfiguratorVariables.Default) == -1 &&
                                        listOfStates.indexOf(ConfiguratorVariables.Required) == -1 /*&& 
                                        listOfStates.indexOf("recommanded") == -1*/) {    //recommanded to be added later

						                for (var k = 0; k < items.length; k++) {
						                    var optionState = model.getStateWithId(items[k].name);

						                    if (optionState === ConfiguratorVariables.Unselected) {
						                        if (items[k].selected == false) items[k].toggleSelection();
						                    }
						                }
						            }
						        }

                                //TODO : Move incompatibles to the bottom


						        optDropDwn.show();

						    }
						});

						txtIcon = getIcon({	id: 'optIcon' + feature.ruleId,	icon: 'attention', color:'black'});
						//var infoButton = new Button({ icon: "info",	id: 'infoButton' + feature.ruleId, className: "link" });
						//var infoButton = getIcon({	id: 'infoButton' + feature.ruleId,	icon: 'info', color:'#42a2da'});

						mandatory = (feature.selectionCriteria == 'Must')? true : false;						

						/*new DropdownMenu({
						    target: infoButton,
						    renderTo: (options.ddRenderTo) ? options.ddRenderTo : options.parentContainer,
							id: 'InfosDD'+feature.ruleId,
							items: [
							        { text: 'Maturity : \t\t ' + feature.attributes.Current, className: 'header'},
							        { text: 'Mandatory : \t ' + mandatory, className: 'header'},
							        { text: 'Creator : \t ' + feature.attributes.Originator , className: 'header'},						
							        { text: 'List Price : ' + feature.listPrice, className: 'header'},
							        { text: 'Description : ' + feature.attributes['Display Text'], className: 'header'},
							        ]
						});*/		
						featureRuleID = feature.ruleId;

								
						/*this.modelEvents.publish({
							event:	'updateMANDNumberAndRefresh3D',
							data:	{
								featureId : feature.ruleId, 
								mandNotValuatedBoolValue : mandNotValuatedBoolValue, 
								waitForAllFeatures : true,
								oldMandNotValuatedBoolValue: mandatory,
							}
						});
						*/
						var OptDiv = UWA.createElement('table', { id: 'OptDiv'+feature.ruleId , styles : { width: '100%' },
							html: [{ tag: 'tr',  							
								html: [{ tag: 'td', styles: {width: "20px"},
									html: [ txtIcon]
								},							 
								{ tag: 'td',
									html: [ psTxtObj ]
								}]
							}]
						});
						OptRulesDiv = UWA.createElement('table', { id: 'OptRulesDiv'+feature.ruleId , styles: {width: '100%'},
							html: [""]
						});
						//OptRulesDiv.style.display = ConfiguratorVariables.str_none;
						var FtrFiltersDiv = UWA.createElement('table', { id: 'FtrFiltersDiv'+feature.ruleId , className : 'FtrFiltersDiv', styles: {width: '100%', display: 'block'},

						});						

						OneFeatureDiv = UWA.createElement('div', { id: 'divFeature'+feature.ruleId , 'class' : 'OneFeatureDiv', 'filteredOut': 'No',  
							
						    html: [{
						        tag: 'div', styles: { display: 'inline-block', position: 'relative' },
						        html: [{
						            tag: 'div', id: 'variantImageDiv' + feature.ruleId, styles: imageDivStyle, html: [
                                        { tag: 'img', id: 'variantImage' + feature.ruleId, src: image, 'class': 'img-thumbnail', styles: imageStyle }
						            ]
						        },
						        {
						            tag: 'a', id: 'numberOfSelectedOptions_' + feature.ruleId, styles: { position: 'absolute', top: '13px', right: '8px', cursor: 'pointer' }, html: ["0"]
						        }]
						    },
							       { tag: 'div', styles : { display: 'inline-block', verticalAlign: 'top' , width: 'calc(100% - 90px)' },
							       html: [{
							           tag: 'div', styles: {display: 'flex', flexDirection: 'row'}, html: [
                                                getLabelField(feature.displayName, 'overflow: hidden; white-space: nowrap; text-overflow: ellipsis; display: flex;', null, "featureLabel"),
							               ]}, 
									       FtrFiltersDiv,
									       OptDiv,
									       OptRulesDiv
									       ]
								       }/*,
								       { tag: 'div', styles : { top: '5px', position: 'absolute', right: '3px' },
								    	   html: [infoButton]
								    }*/     //Removed the info icon due to FD01 issue (no go on UPS function due to NLS missing)
								]							
						});

						if(feature.attributes['Display Text']) {
						    new Tooltip({
						        target: OneFeatureDiv.querySelector(".featureLabel"),
						        body: '<b>' + feature.displayName + '</b><BR>' + feature.attributes['Display Text']
						    });
						}

                        for(var featureAttr in feature.attributes) {
                            OneFeatureDiv.attributes[featureAttr.replace(/\s+/g, '')] = feature.attributes[featureAttr];
                        }
					
						OneFeatureDiv.inject(options.parentContainer);
						
						var containerWidth = options.parentContainer.offsetWidth;

						if (containerWidth >= 1400) {
						    OneFeatureDiv.addClassName('largeContainer');
						}
						else if (containerWidth < 1400 && containerWidth >= 700) {
						    OneFeatureDiv.addClassName('mediumContainer');
						}
						else if (containerWidth < 700) {
						    OneFeatureDiv.addClassName('smallContainer');
						}

						new ResizeSensor(options.parentContainer, function () {
						    var width = options.parentContainer.offsetWidth;

						    if (width >= 1400) {
						        OneFeatureDiv.removeClassName('smallContainer');
						        OneFeatureDiv.removeClassName('mediumContainer');
						        OneFeatureDiv.addClassName('largeContainer');
						    }
						    else if (width < 1400 && width >= 750) {
						        OneFeatureDiv.removeClassName('smallContainer');
						        OneFeatureDiv.removeClassName('largeContainer');
						        OneFeatureDiv.addClassName('mediumContainer');
						    }
						    else if (width < 750) {
						        OneFeatureDiv.removeClassName('largeContainer');
						        OneFeatureDiv.removeClassName('mediumContainer');
						        OneFeatureDiv.addClassName('smallContainer');
						    }
						});


						imagesDropdown = new Dropdown({
						    body: '',
						    renderTo: (options.ddRenderTo) ? options.ddRenderTo : options.parentContainer,
						    target: document.getElementById('numberOfSelectedOptions_' + feature.ruleId),
						    className: "imagesDropdown",
                            name: "imagesDropdown" + feature.ruleId
						});

						mandNotValuatedBoolValue = mandatory;
						for(var j=0; j< variantOptions.length; j++)
						{							
							//var selected = false;
							//var fonticon = 'user';
							
							var state = model.getStateWithId(variantOptions[j].ruleId);
							//var defaultValue = false;
							if (state == ConfiguratorVariables.Default)
							{ 
							    addRulesRow('star', variantOptions[j].displayName, OptRulesDiv, variantOptions[j].ruleId); 
							    if (mandNotValuatedBoolValue == true)
							        mandNotValuatedBoolValue = false;
							}
							
							if(  state == ConfiguratorVariables.Chosen )
							{	
							    if (mandNotValuatedBoolValue == true)
							        mandNotValuatedBoolValue = false;

							}
							else
							if(  state == ConfiguratorVariables.Required )
							{	
							    if (mandNotValuatedBoolValue == true)
							        mandNotValuatedBoolValue = false;
								addRulesRow('star', variantOptions[j].displayName, OptRulesDiv, variantOptions[j].ruleId);

							}
						}
						model.setFeatureIdWithMandStatus(feature.ruleId, mandNotValuatedBoolValue);
						updateView();

						if (!mandNotValuatedBoolValue || mandNotValuatedBoolValue == false)
						{
							var optElem = document.getElementById('optIcon' + feature.ruleId);
							optElem.removeClassName("fonticon-attention");						
						}							
				}
			});

			return VariantPresenter;
		});

define(
		'DS/ConfiguratorPanel/scripts/Presenters/MultipleValueAutocompletePresenter',
		[
			'UWA/Core',
			'DS/Handlebars/Handlebars',
			'DS/UIKIT/Autocomplete',
			'DS/UIKIT/Mask',
			'DS/UIKIT/Tooltip',
			'DS/Controls/Popup',
			'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
			'DS/ConfiguratorPanel/scripts/Utilities',
			'DS/ConfiguratorPanel/scripts/ConfiguratorSolverFunctions',

			'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json',
			'text!DS/ConfiguratorPanel/html/MultipleValueAutocompletePresenter.html',

			'css!DS/UIKIT/UIKIT.css',
			"css!DS/ConfiguratorPanel/css/MultipleValueAutocompletePresenter.css"


			],
			function (UWA, Handlebars, Autocomplete, Mask, Tooltip,WUXPopup, ConfiguratorVariables, Utilities,ConfiguratorSolverFunctions, nlsConfiguratorKeys, html_MultipleValueAutocompletePresenter) {

			'use strict';

			var template = Handlebars.compile(html_MultipleValueAutocompletePresenter);
			var badgeTooltip = [];
			var optionToolTip = [];
			var popup =[];
			var countConfigurations = 0;

			var MultipleValueAutocompletePresenter = function (options) {
				this._init(options);
			};

			/******************************* INITIALIZATION METHODS**************************************************/

			MultipleValueAutocompletePresenter.prototype._init = function(options){
				var _options = options ? UWA.clone(options, false) : {};
				this._updateForBadge = false;
				this._updateForSuggestion = false;

				UWA.merge(this, _options);
				this._subscribeEvents();
				this._initDivs();
				this.inject(_options.parentContainer);
				this._render();
			};

			MultipleValueAutocompletePresenter.prototype._subscribeEvents =function(){
				var that = this;
				this.modelEvents.subscribe({ event: 'OnSortResult'}, function(data){
					that._sortAttribute = data.sortAttribute;
					that._sortOrder = data.sortOrder;
					var dataset = that._autocomplete.getDataset("_autocomplete");
					dataset.items = dataset.items.sort(function(a, b) {
						var nameA,nameB;
						if(that._sortAttribute === "displayName"){
							nameA = a.displayName.toUpperCase();
							nameB = b.displayName.toUpperCase();
						}
						if(that._sortAttribute === "sequenceNumber"){
							nameA = parseInt(a.sequenceNumber);
							nameB = parseInt(b.sequenceNumber);
						}
						if (that._sortOrder === "DESC") {
							var temp = nameA;
							nameA = nameB;
							nameB = temp;
						}
						if (nameA < nameB) {
							return -1;
						}
						if (nameA > nameB) {
							return 1;
						}
						return 0;
					});
				});
			};

			MultipleValueAutocompletePresenter.prototype._initDivs = function () {
				this._container = document.createElement('div');
				this._container.innerHTML = template({nls : nlsConfiguratorKeys, items : this.variant.optionPhysicalIds, context:this});

				this._container = this._container.querySelector('.config-editor-multivalue-autocomplete');
				this.image = this.imageContainer.querySelector(".configurator-img-thumbnail");
				this._validateCheckContainer = this._container.querySelector('.config-editor-validate-badge-check');


			};

			MultipleValueAutocompletePresenter.prototype.inject= function(parentcontainer) {
				this._parentcontainer = parentcontainer;
				parentcontainer.appendChild(this._container);
			};

			/*******************************AUTOCOMPLETE CREATION***************************************************/

			MultipleValueAutocompletePresenter.prototype._render= function() {
				var that = this;
				this._autocomplete = new Autocomplete({
					multiSelect: true,
					showSuggestsOnFocus: true,
					placeholder : nlsConfiguratorKeys.type,
					events : {
						onSelect : function(item){
							that._onSelect(item);
						},
						onUnselect : function(item){
							that._onUnselect(item);
						},
						onShowSuggests : function(item, dataset){
							that._onShowSuggests(item);
						},
						onFocus : function(){
							var variantName = that.configModel.getFeatureDisplayNameWithId(that.variant.ruleId);
							var searchBox = document.querySelector('.autocomplete-input');
							var value = searchBox ? searchBox.value : "";
							var text = that.searchValue || value;
							if(variantName.toUpperCase().contains(text.toUpperCase())){
								this.showAll();	//show all in case variant has match
							}else{
								if(text && text !== "")
									that._autocomplete.getSuggestions(text);
								else {
									this.showAll();
								}
							}
						}
					}
				}).inject(this._container);
				var _variantDataset = this._createDataset();
				var _datasetConfiguration = this._createConfigurations();
				this._autocomplete.addDataset(_variantDataset, _datasetConfiguration);

				if(this.variant && this.variant.options && this.variant.options.length > 5){
					this._showMore = this._container.querySelector('.config-editor-autocomplete-show-more');
					this._showLess = this._container.querySelector('.config-editor-autocomplete-show-less');

				this._autocomplete.elements.inputContainer.appendChild(this._showMore);
				this._autocomplete.elements.inputContainer.appendChild(this._showLess);
				this._showMore.onclick = function(){
					that._showBadges();
					that._showLess.style.display = "inline-block";
					that._showMore.style.display = "none";
				}
				this._showLess.onclick = function(){
					that._hideBadges();
					that._showLess.style.display = "none";
					that._showMore.style.display = "inline-block";
				}
				}
			};

			/*******************************AUTOCOMPLETE INITIALIZATION - ADD DATA************************************/

			MultipleValueAutocompletePresenter.prototype._createDataset= function() {
				var dataset= {name: "_autocomplete", items : []};
				if(this.variant && this.variant.options && this.variant.options.length > 0){
					//sort by seq number
					this.variant.options = this.variant.options.sort(function(a, b) {
							var nameA = parseInt(a.sequenceNo); //a.displayName.toUpperCase();
							var nameB = parseInt(b.sequenceNo);//b.displayName.toUpperCase();
							if (nameA < nameB) {
								return -1;
							}
							if (nameA > nameB) {
								return 1;
							}
							return 0;
						});
					for(var i=0; i < this.variant.options.length; i++) {
						var state = this.configModel.getStateWithId(this.variant.options[i].id) || this.configModel.getStateWithId(this.variant.optionPhysicalIds[i]);
						var selectedFromStart = false;
						if(state == "Chosen" || state == "Default" || state == "Required"){
							selectedFromStart = true;
						}

						dataset.items.push({
							mainId : this.variant.options[i].id,
							// value: this.variant.optionPhysicalIds[i],
							value: this.variant.options[i].ruleId,
							label : this.variant.options[i].displayName,
							disabled: false,
							selected : selectedFromStart,
							selectable:true,
							icon:"",
							state: state,
							conflicting: false,
							included : "",
							ruleId : this.variant.options[i].ruleId,
							// optionId : this.variant.optionPhysicalIds[i],
							optionId : this.variant.options[i].ruleId,
							tooltip : "",
							selectionCriteria : this.variant.selectionCriteria,
							variantId : this.variant.ruleId,
							image : this.variant.options[i].image,
							displayName : this.variant.options[i].displayName,
							sequenceNumber : this.variant.options[i].sequenceNumber
						});
					}
				}
				return dataset;
			};

			/*******************************AUTOCOMPLETE INITIALIZATION - UPDATE DISPLAY FORMAT************************************/

			MultipleValueAutocompletePresenter.prototype._createConfigurations= function() {
				return {
					templateEngine: function (itemContainer, itemDataset, item) {
						itemContainer.addClassName('default-template');
						var icon = "fonticon";
						if(item.icon && item.icon!=='') icon = "suggestion-icon fonticon fonticon-" + item.icon;
						if(item.icon === 'alert') icon = icon + " conflict-icon";
						var content = UWA.createElement('span', {id: "DD-item-" + item.value ,'class': "suggestion-icon " +icon});
						var contentForDefault = UWA.createElement('span', {id: "Default-DD-item-" + item.value ,'class': "contentForDefault fonticon fonticon-star"});
						contentForDefault.hide();
						itemContainer.setHTML(content.outerHTML + '<div class="item-label">' + item.label + '</div>' + contentForDefault.outerHTML);
					}.bind(this)
				}
			},

			/*******************************AUTOCOMPLETE EVENTS HANDLING - SELECTION***********************************************/

			MultipleValueAutocompletePresenter.prototype._onSelect= function(item) {
				this.imageContainer.classList.add('cfg-image-selected');
				if(this.configModel.getLoading(this.variant.ruleId) === "Loaded"){

					var newItemState = item.state ;
					if(item.included){
						if (item.state === ConfiguratorVariables.Dismissed){
							newItemState = ConfiguratorVariables.Unselected; //virtually selected
							this.configModel.setUpdateRequiredOption(item.value, true);
							this.configModel.setStateWithId(item.value, newItemState);
						}
					}else{
						if (item.state === ConfiguratorVariables.Unselected){
							var defaultItem = this._find(this.defaults, item.value);
							newItemState = defaultItem ? ConfiguratorVariables.Unselected : ConfiguratorVariables.Chosen;
						}
						if(item.state === ConfiguratorVariables.Dismissed){
							newItemState = ConfiguratorVariables.Default;
						}
						this.configModel.setUpdateRequiredOption(item.value, true);
						this.configModel.setStateWithId(item.value, newItemState);
					}
					this.callSolver(item);
				}
			};

			/*******************************AUTOCOMPLETE EVENTS HANDLING - UNSELECTION*********************************************/

			MultipleValueAutocompletePresenter.prototype._onUnselect= function(item) {
				var selections = this._autocomplete.selectedItems ? this._autocomplete.selectedItems : [];
				if(selections.length == 0){
					this.imageContainer.classList.remove('cfg-image-selected');
				}
				if(this.configModel.getLoading(this.variant.ruleId) === "Loaded"){
					var newItemState = item.state ;
					var build_mode = this.configModel.getSelectionMode() === ConfiguratorVariables.selectionMode_Build ? true : false;

					if(build_mode || (!build_mode && selections.length > 0)){
						if(item.state === ConfiguratorVariables.Default || (item.included && item.state === ConfiguratorVariables.Unselected) || item.state === ConfiguratorVariables.Selected){
							newItemState = ConfiguratorVariables.Dismissed; //Reject Default
						}else{
							newItemState = ConfiguratorVariables.Unselected;
						}
					}else{
						newItemState = item.included ? ConfiguratorVariables.Dismissed : ConfiguratorVariables.Unselected;
						if(!item.included){
						for(var k=0;k<this.variant.options.length;k++){
								this.configModel.setStateWithId(this.variant.optionPhysicalIds[k], ConfiguratorVariables.Unselected);
							this.configModel.setIncludedState(this.variant.optionPhysicalIds[k], 'Included');
							this.configModel.setIncludedState(this.variant.ruleId, 'Included');
						}
					}
					}
					this.configModel.setUpdateRequiredOption(item.value, true);
					this.configModel.setStateWithId(item.value, newItemState);
					this.callSolver(item);
				}
			};

			/*******************************AUTOCOMPLETE EVENTS HANDLING - UPDATE SUGGESTIONS**************************************/

			MultipleValueAutocompletePresenter.prototype._onShowSuggests= function() {
				this.configModel.setLoading(this.variant.ruleId, "Loaded");
				// this.modelEvents.publish({event:'hideUnreferencedDD', data : {currentAutocomplete : this}});
				var items = this._autocomplete.getItems();
				for(var i=0; i<items.length; i++){
					this._updateIconInDD(items[i]);
				}
			};

			/********************************FUNCTIONALITIES - CALL SOLVER BASED ON RULES SELECTION******************************/

			MultipleValueAutocompletePresenter.prototype.callSolver = function(item){
				this.modelEvents.publish({event:'pc-interaction-started', data : {}});
				if(this.configModel.getRulesActivation() === ConfiguratorVariables.str_true) {
					if(this.configModel.getLoading(this.variant.ruleId) === "Loaded"){
						this.modelEvents.publish({event:'SolverFct_CallSolveMethodOnSolver', data : {}});
					}
				}else{
					this.updateFilters();
					this.modelEvents.publish({event: 'solveAndDiagnoseAll_SolverAnswer'});
					if(this.configModel.getSelectionMode() === "selectionMode_Refine"){
						this.enforceRequired();
					}
				}
			};

			/********************************FUNCTIONALITIES - UPDATE VIEW - MAIN METHOD******************************************/

			MultipleValueAutocompletePresenter.prototype.enforceRequired= function(data) {
				var that = this, variantSelectedByRule = false, variantSelectedByUser = false,conflictingOption=false;
				var length = this.variant.options.length;
				this.defaults = data ? data.answerDefaults : [];

				this.configModel.setFeatureIdWithRulesStatus(this.variant.ruleId, false);
				this.configModel.setFeatureIdWithChosenStatus(that.variant.ruleId, false);
				this.configModel.setUserSelectVariantIDs(that.variant.ruleId, false);

				for(var i =0; i<length;i++){
					var _updateRequired = true; // this.configModel.getUpdateRequiredOption(this.variant.optionPhysicalIds[i]);
					var _refineMode = (this.configModel.getSelectionMode() !== "selectionMode_Build") ? true : false;
					// var _xor = (_updateRequired || _refineMode) && !(_updateRequired && _refineMode);
					if(_updateRequired || _refineMode){

					var item = this._getRequiredData(i);

					this._loadData(item);
					this._updateIcons(item);
					this._updateBadge(item);
					this._updateIconInDD(item); //Required here for the scenarios when selection in same DD - show suggests not triggered when suggests are already shown.
						// this._updateImage(this.variant.options[i], item.selected);
					this._updateItem(item);
					conflictingOption = conflictingOption || item.conflicting;
					if(item.selectedByRules) variantSelectedByRule = true;
					if(item.selectedByUser) variantSelectedByUser = true;
					this.configModel.setUIUpdated(this.variant.optionPhysicalIds[i], true);
				}
				}

				var _cntSelections = this._autocomplete.selectedItems ? this._autocomplete.selectedItems.length : 0;

				if(_cntSelections == 1){
					if(this._autocomplete.selectedItems[0].image && this.image)
						this.image.src = this._autocomplete.selectedItems[0].image;
				}else{
					if(this.variant.image && this.image)
					this.image.src = this.variant.image;
				}
				if(conflictingOption && this.configModel.getRulesActivation() === "true"){
					this.image.parentElement.style.borderColor = "red";
					this._autocomplete.elements.inputContainer.addClassName("config-editor-multi-input-parent-conflict");
				}else{
					this.image.parentElement.style.borderColor = "#b1b1b1";
					this._autocomplete.elements.inputContainer.removeClassName("config-editor-multi-input-parent-conflict");
				}

				this.configModel.setFeatureIdWithRulesStatus(this.variant.ruleId, variantSelectedByRule);
				this.configModel.setFeatureIdWithChosenStatus(that.variant.ruleId, variantSelectedByUser);
				if(item && (item.state === "Chosen" || item.state === "Dismissed" || item.state === "Required" || item.state === "Default")){
					this.configModel.setUserSelectVariantIDs(item.variantId, true);
				}

				this.updateFilters();
				if(length > 5)this._updateBadgeInitialVisibility();

				/**Special case : when earlier non-refined variant becomes eligible for refined variant on deselection**/
				if(this.configModel.getSelectionMode() !== "selectionMode_Build" && !this.configModel.getIncludedState(this.variant.ruleId)){
					var selectedVariant = this.configModel.getFeatureIdWithStatus(this.variant.ruleId);
					if(!selectedVariant){
						this._setIncludedState();
						for (var i = 0; i < this.variant.optionPhysicalIds.length; i++) {
							this.configModel.setUpdateRequiredOption(this.variant.optionPhysicalIds[i], true);
						}
						this.enforceRequired();
					}
				}
			};

			/********************************FUNCTIONALITIES - APPLY REFINE VIEW**************************************************/

			MultipleValueAutocompletePresenter.prototype.refineView = function(enable){
				var selectedVariant = this.configModel.getFeatureIdWithStatus(this.variant.ruleId);
				var allVariants = this.configModel.getVariants();
				if(countConfigurations >= allVariants){
					countConfigurations = 0;
				}

				if(enable){
					selectedVariant ? this.configModel.setFeatureIdWithUserSelection(this.variant.ruleId, true) : this._setIncludedState();
				}else{
					this._unsetIncludedState();
					this.configModel.setConfigurationCriteria(this.configModel.getCriteriaBuildMode());
				}
				countConfigurations++ ; //increase count for each variant

				this._BuildModeCriteria = JSON.parse(JSON.stringify( this.configModel.getConfigurationCriteria() ));
				if(countConfigurations === allVariants) {
					if(enable){
						this.configModel.setCriteriaBuildMode(this._BuildModeCriteria);
					}
					if(this.configModel.getRulesActivation() === ConfiguratorVariables.str_true){
						this.modelEvents.publish({event:'SolverFct_CallSolveMethodOnSolver', data : {}});
					}else{
						this.modelEvents.publish({event:'solveAndDiagnoseAll_SolverAnswer', data:	this.configModel.getConfigurationCriteria()});
					}
				}

				// if(this.configModel.getRulesActivation() === ConfiguratorVariables.str_true){
				// 	if(countConfigurations === allVariants) {
				// 		if(enable){
				// 			this.configModel.setCriteriaBuildMode(this.configModel.getConfigurationCriteria());
				// 		}
				// 		this.modelEvents.publish({event:'SolverFct_CallSolveMethodOnSolver', data : {}});
				// 	}
				// }else{
				// 	this._BuildModeCriteria = JSON.parse(JSON.stringify( this.configModel.getConfigurationCriteria() ));
				// 	if(countConfigurations === allVariants) {
				// 		if(enable){
				// 			this.configModel.setCriteriaBuildMode(this._BuildModeCriteria);
				// 		}
				// 		this.modelEvents.publish({event:'solveAndDiagnoseAll_SolverAnswer', data:	this.configModel.getConfigurationCriteria()});
				// 	}
				// 	// this.enforceRequired();
				// 	// this.modelEvents.publish({event:'updateAllFilters', data : {}});
				// }
			};

			/*******************************UPDATE VIEW RELATED HELPER METHODS******************************************/

			MultipleValueAutocompletePresenter.prototype._getRequiredData= function(i) {
				var item = this._autocomplete.getItem(this.variant.optionPhysicalIds[i]);
				var state = this.configModel.getStateWithId(item.value) || this.configModel.getStateWithId(item.mainId);
				item.state = state || "Unselected";
				item.conflicting = this.configModel.isConflictingOption(item.ruleId);
				item.included = this.configModel.getIncludedState(item.value);

				this._updateItem(item);
				return item;
			};

			/*******************************UPDATE VIEW : LOAD DATA****************************************************/

			MultipleValueAutocompletePresenter.prototype._loadData= function(item) {
				this.configModel.setLoading(this.variant.ruleId);
				var selectedState;
				this._autocomplete.enableItem(item.id);
				var rules = this.configModel.getRulesActivation() === ConfiguratorVariables.str_true ? true : false;

				// switch (item.state) {
				// case ConfiguratorVariables.Default: case ConfiguratorVariables.Required: case ConfiguratorVariables.Selected:
				// 	selectedState = rules ? true : false;
				// 	break;
				// case ConfiguratorVariables.Chosen:
				// 	selectedState = rules ? true : item.conflicting ? false : true;
				// 	break;
				// case ConfiguratorVariables.Unselected:
				// 	selectedState = item.included ? true : false;
				// 	break;
				// default :
				// 	selectedState = rules ? item.conflicting ? true : false : false;
				// break;
				// }

				switch (item.state) {
				case ConfiguratorVariables.Default: case ConfiguratorVariables.Required: case ConfiguratorVariables.Selected:
					selectedState = rules ? true : false;
					break;
				case ConfiguratorVariables.Chosen:
					selectedState = true;
					break;
				case ConfiguratorVariables.Unselected:
					selectedState = item.included ? true : false;
					break;
				default :
					selectedState = false;
					break;
				}

				selectedState = !item.state ? item.included ? true : false : selectedState
				// if(item.conflicting && rules) selectedState = true;
				// (item.selected && selectedState) ? "" : this._autocomplete.toggleSelect(item,"",selectedState);
				if((item.selected || selectedState) && !(item.selected && selectedState)){
					this._autocomplete.toggleSelect(item);
				}
				if(item.disable){
					this._autocomplete.disableItem(item.id);
				}
				// item.disable ? this._autocomplete.disableItem(item.id) : this._autocomplete.enableItem(item.id);
				this.configModel.setLoading(this.variant.ruleId,"Loaded");
			};

			/*******************************UPDATE VIEW : MODIFY ICONS***********************************************/

			MultipleValueAutocompletePresenter.prototype._updateIcons= function(item) {
				var rules = this.configModel.getRulesActivation() === ConfiguratorVariables.str_true ? true : false;
				var icon;
				switch (item.state) {
				case ConfiguratorVariables.Default:
					icon = rules ? "star" : "";
					break;
				case ConfiguratorVariables.Required:
					icon = rules ? "lock" : "";
					break;
				case ConfiguratorVariables.Incompatible:
					icon = rules ? "block" : "";
					break;
				case ConfiguratorVariables.Dismissed:
					icon = "user-delete";
					break;
				case ConfiguratorVariables.Selected:
					icon = "lightbulb";
					break;
				default :
					icon = "";
				break;
				}
				if(item.conflicting && rules) icon = "alert";
				this._updateItem(item, {icon:icon});
			};

			/****************************************UPDATE VIEW : GENERATE TOOLTIP MESSAGE****************************************/

			MultipleValueAutocompletePresenter.prototype._updateTooltipMessages= function(item) {
				var message = "";
				if (item.conflicting && item.conflicting == true) {
					message = this.getConflictingMessage(item.value);
				}else{
					message = nlsConfiguratorKeys.Loading;
					this.modelEvents.publish({event:'SolverFct_getResultingStatusOriginators', data : {value : item.optionId}});

					// switch (item.state) {
					// case ConfiguratorVariables.Incompatible: case ConfiguratorVariables.Required:
					// 	message = nlsConfiguratorKeys.Loading;
					// 	this.modelEvents.publish({event:'SolverFct_getResultingStatusOriginators', data : {value : item.ruleId}});
					// 	break;
					// case ConfiguratorVariables.Default:
					// 	message = item.label + " " + nlsConfiguratorKeys.is + " " + nlsConfiguratorKeys["Default selected"];
					// 	break;
					// case ConfiguratorVariables.Dismissed:
					// 	message = item.label + " " + nlsConfiguratorKeys.is + " " + nlsConfiguratorKeys["Dismissed by the user"];
					// 	break;
					// default :
					// 	break;
					// }
					// /**Default in compatible mode, seen as chosen but star is present**/
					// if(this.defaults && this.configModel.getRulesMode() === "RulesMode_DisableIncompatibleOptions"){
					// 	if(this.defaults.indexOf(item.ruleId) !== -1){
					// 		message = item.label + " " + nlsConfiguratorKeys.is + " " + nlsConfiguratorKeys.Default;
					// 	}
					// }
				}
				this.setTooltipMessage(item.value, message);
			};

			/****************************************UPDATE VIEW : CACHE TOOLTIP MESSAGE******************************************/

			MultipleValueAutocompletePresenter.prototype.setTooltipMessage= function(option, message) {
				var item = this._autocomplete.getItem(option);
				this._updateItem(item, {tooltip : message});
				this._updateSuggestionPopup(item);
				this._updateBadgePopup(item);
			};

			/****************************************UPDATE VIEW : CREATE TOOLTIP AND SET MESSAGE*********************************/

			MultipleValueAutocompletePresenter.prototype._updateSuggestionPopup= function(item) {
				if(this._updateForSuggestion){
						popup[item.value].setBody(item.tooltip);
						popup[item.value].getContent().addClassName('cfg-custom-popup');
						setTimeout(function(){
							if(popup[item.value].elements.container.offsetWidth === 0){
								popup[item.value].toggle();
							}
						},100);
						// popup[item.value].toggle(); //Added due to autoposition issue on content change in webux/pop
						// popup[item.value].toggle(); //To be removed once it is handled by component itself;
					}
			};

			MultipleValueAutocompletePresenter.prototype._updateBadgePopup= function(item) {
				if(this._updateForBadge){
						badgeTooltip[item.value].setBody(item.tooltip);
						badgeTooltip[item.value].getContent().addClassName('cfg-custom-popup');
						setTimeout(function(){
							if(badgeTooltip[item.value].elements.container.offsetWidth === 0){
								badgeTooltip[item.value].toggle();
							}
						},100);
						// badgeTooltip[item.value].toggle(); //Added due to autoposition issue on content change in webux/pop
						// badgeTooltip[item.value].toggle(); //To be removed once it is handled by component itself;
					}
			};

			/*******************************UPDATE VIEW : SET ICON IN BADGE AND SUGGESTIONS**************************************/

			MultipleValueAutocompletePresenter.prototype._updateBadge= function(item) {
				var currentBadge, badges = this._autocomplete.badges, that = this;
				for(var i =0; i< badges.length; i++){
					if(badges[i].options.id === ("selected-" + item.id)){
						currentBadge = badges[i];
						currentBadge.setClosable(item.closable);
						currentBadge.setIcon(item.icon);

						if(this.configModel.isValidationEnabled()){
							var checkIcon = currentBadge.elements.container.querySelector(".config-editor-validate-badge-check");
							if(item.state === "Default" || item.state === "Required"){
								if(!checkIcon){
									var _validateCheckContainer = UWA.createElement('span', {'class': "wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-check config-editor-validate-badge-check"});
									currentBadge.elements.container.insertBefore(_validateCheckContainer,currentBadge.elements.cross);
									_validateCheckContainer.onclick = function(item,event){
										this.style.display = "none";
										that.configModel.setFeatureIdWithChosenStatus(that.variant.ruleId, true);
										that.configModel.setValidateVariant(that.variant.ruleId, true);
										that.configModel.setStateWithId(item.optionId, ConfiguratorVariables.Chosen);
										that.callSolver();
									}.bind(_validateCheckContainer,item);
								}
							}else {
								if(checkIcon){
									checkIcon.remove();
								}
							}
						}

						if(currentBadge.elements.icon)
							item.icon === "alert" ? currentBadge.elements.icon.addClassName('conflict-icon') : currentBadge.elements.icon.removeClassName('conflict-icon');

						if(!badgeTooltip[item.value] || (badgeTooltip[item.value] && !badgeTooltip[item.value].target.isInjected()) ) {
							badgeTooltip[item.value] = new WUXPopup({target: currentBadge.elements.icon,trigger: 'click', position:'top'});
						}

						currentBadge.elements.icon.onclick = function(){
							that._updateForBadge = true;//To be removed on receiving udpates from webux
							that._updateForSuggestion = false;//To be removed on receiving udpates from webux
							that._updateTooltipMessages(this);
						}.bind(item);
						break;
					}
				}
			};

			MultipleValueAutocompletePresenter.prototype._updateIconInDD= function(item) {
				var message = '', suggestion, iconDiv, that = this, contentForDefault;
				if(item.elements){
					suggestion = this._autocomplete.elements.container.getElement('#autocomplete-item-'+ item.id);
					if(suggestion){
						if(suggestion.hasClassName('disabled')){
							suggestion.removeClassName('disabled');
						}
						if(suggestion.hasClassName('conflict-icon')){
							suggestion.removeClassName('conflict-icon');
						}
						iconDiv = suggestion.getElementsByClassName('fonticon')[0];
						contentForDefault = suggestion.getElements('#Default-DD-item-' + item.value)[0];
						if(contentForDefault) contentForDefault.hide();
						// /**Handling default in compatible mode.**/
						// if(this.defaults && this.configModel.getRulesMode() === "RulesMode_DisableIncompatibleOptions"){
						// 	if(this.defaults.indexOf(item.ruleId) !== -1){
						// 		item.icon = "star";
						// 	}
						// }
						/**showing star on right side in dismissed/required state or in compatible mode*/
						if(this.defaults && contentForDefault && item.state !== ConfiguratorVariables.Default){
							if(this.defaults.indexOf(item.ruleId) !== -1){
								contentForDefault.show();
							}
						}
						if(iconDiv && item.icon){
							popup[item.value] = new WUXPopup({ target: iconDiv,trigger: 'click', position:'top'});
							iconDiv.onclick = function(e){
								e.stopPropagation();	//Prevent trigger from item selection
								that._updateForBadge = false;//To be removed on receiving udpates from webux
								that._updateForSuggestion = true;//To be removed on receiving udpates from webux
								that._updateTooltipMessages(this);
							}.bind(item);
							iconDiv.className =  "suggestion-icon fonticon fonticon-" + item.icon;
							if(item.icon === 'block'){
								suggestion.addClassName('disabled');
							}
							if(item.icon === 'alert'){
								suggestion.addClassName('conflict-icon');
							}
						}else{
							if(iconDiv){
								iconDiv.className =  "suggestion-icon fonticon";
								if(popup[item.value]){
									popup[item.value].elements.container.destroy();
									//popup[item.value].destroy();
									//delete popup[item.value];
								}
							}
						}
					}
				}
			};

			/****************************************UPDATE VIEW : UPDATE IMAGE AS PER CF/CO************************************/

			MultipleValueAutocompletePresenter.prototype._updateImage = function (optionObj, selected) {
				var variantImage;
				if(this._autocomplete.selectedItems && this._autocomplete.selectedItems.length > 0){
					variantImage = this._autocomplete.selectedItems.length > 1 ? true : false;
				}else{
					variantImage = true;
				}
				var image = this.image;
				if(image && image[0]){
					if(variantImage){
						if(this.variant.image !== "")
							image[0].src = this.variant.image;
					}else if(variantImage == false){
						if(selected && optionObj && optionObj.image !== "")
							image[0].src = optionObj.image;
					}
				}
			};

			/*******************************UPDATE VIEW : HANDLE MUST/MAY FEATURES AND INCLUSION RULES***************************/

			MultipleValueAutocompletePresenter.prototype.updateFilters = function(){
				var variantState = this.configModel.getStateWithId(this.variant.ruleId);
				var mandatory = (this.variant.selectionCriteria == 'Must' || this.variant.selectionCriteria == true)? true : false;
				var mandStatus = (mandatory || variantState === ConfiguratorVariables.Required) ? true : false;
				var selectedFeature;
				if(this._autocomplete.selectedItems && this._autocomplete.selectedItems.length > 0){
					mandStatus = false;
					selectedFeature = true;
				}else{
					selectedFeature = false;
				}

				if(variantState=== "Incompatible"){
							if(!this.configModel.getUserSelectVariantIDs(this.variant.ruleId))
					selectedFeature = false;
				}

				// if(this._container.offsetParent && this._container.offsetParent.style.display === "none"){
				// 	selectedFeature = false;
				// }

				this.configModel.setFeatureIdWithMandStatus(this.variant.ruleId, mandStatus);
				this.configModel.setFeatureIdWithStatus(this.variant.ruleId, selectedFeature);
				// this.modelEvents.publish({event:'updateAllFilters', data : {}});
			};

			/********************************REFINE MODE - INCLUDED STATE GETTER SETTER***********************************/

			MultipleValueAutocompletePresenter.prototype._setIncludedState = function(){
				for(var i=0; i < this.variant.options.length; i++) {
					var item = this._getRequiredData(i);
					this.configModel.setIncludedState(item.value, 'Included');
					this.configModel.setIncludedState(item.variantId, 'Included');
					this._loadData(item);
				}
			};

			MultipleValueAutocompletePresenter.prototype._unsetIncludedState = function(){
				for(var i=0; i < this.variant.options.length; i++) {
					var item = this._getRequiredData(i);
					if(item.included === 'Included'){
						this.configModel.setIncludedState(item.value);
						this.configModel.setIncludedState(item.variantId);
					}
					this._loadData(item);
				}
			}

			/******************************************UTILITIES**********************************************************/

			MultipleValueAutocompletePresenter.prototype._find = function (array, id) {
				if(array){
					array.forEach(function(item){
						if(item === id){ return item; }
					});
				}
			};

			MultipleValueAutocompletePresenter.prototype._showBadges = function () {
				var selections = this._autocomplete.selectedItems ? this._autocomplete.selectedItems.length : 0;
				for(var i = 0 ;i< selections;i++){
					this._autocomplete.badges[i].show();
					this._autocomplete.innerInputs[i].show();
				}
			}

			MultipleValueAutocompletePresenter.prototype._hideBadges = function () {
				var selections = this._autocomplete.selectedItems ? this._autocomplete.selectedItems.length : 0;
				if(selections > 3){
					for(var i = 0 ;i < selections ; i++){
						var criteria = i < selections - 3 ? true : false;
						if(criteria){
							this._autocomplete.badges[i].hide();
							this._autocomplete.innerInputs[i+1].hide();
						}else{
							this._autocomplete.badges[i].show();
							if(this._autocomplete.innerInputs[i+1])
								this._autocomplete.innerInputs[i+1].show();
						}
					}
				}
			}

			MultipleValueAutocompletePresenter.prototype._updateBadgeInitialVisibility = function () {
				var selections = this._autocomplete.selectedItems ? this._autocomplete.selectedItems.length : 0;
				if(selections > 3){
					if(this._showMore.style.display !== "inline-block" && this._showLess.style.display !== "inline-block"){
						this._hideBadges();
						this._showLess.style.display = "none";
						this._showMore.style.display = "inline-block";
					}else if(this._showMore.style.display === "inline-block"){
						this._hideBadges();
					}else if (this._showLess.style.display = "inline-block") {
						this._showBadges();
					}
				}else{
					this._showBadges();
					this._showMore.style.display = "none";
					this._showLess.style.display = "none";
				}
			}


			MultipleValueAutocompletePresenter.prototype._updateItem= function(item,object) {
				if(item){
					var rules = this.configModel.getRulesActivation() === ConfiguratorVariables.str_true ? true : false;
					// object = object ? object : {};
					if(object){
						item.icon = (object.icon || object.icon === "") ? object.icon : item.icon;
						item.tooltip = (object.tooltip || object.tooltip === "") ? object.tooltip : item.tooltip;
					}
					item.closable = item.selected ? item.state === "Required" ? false : true : true;
					item.selectedByRules = rules ? item.icon ? true : false : false;
					item.disable =  rules ? (item.state === "Required" || item.state === "Incompatible") ? true : false : false;
					item.selectedByUser = item.state === "Chosen" ? true : false;
				}
				return item;
			};

			MultipleValueAutocompletePresenter.prototype.getConflictingMessage = function(optionId){
				var addAlso, message='';
				var model = this.configModel;
				message = UWA.i18n("Option") + " " + model.getOptionDisplayNameWithId(optionId) + " " + UWA.i18n("is conflicting with") + ":";
				var listOfListOfConflictingIds = model.getConflictingFeatures();
				var listOfListOfRulesImplied = model.getImpliedRules();
				//need to traverse the list again, to generate the text for tooltip

				for (var i = 0; i < listOfListOfConflictingIds.length; i++) {
					if (listOfListOfConflictingIds[i].indexOf(optionId) != -1) {
						if (addAlso)message += UWA.i18n("and also conflicting with ");
						for (var j = 0 ; j < listOfListOfConflictingIds[i].length; j++) {
							if (optionId != listOfListOfConflictingIds[i][j]) {
								message += model.getFeatureDisplayNameWithId(listOfListOfConflictingIds[i][j]) + "[" + model.getOptionDisplayNameWithId(listOfListOfConflictingIds[i][j]) + "]";
								addAlso = true;
							}
						}
						if (listOfListOfRulesImplied.length > 0) {
							for (var j = 0 ; j < listOfListOfRulesImplied[i].length; j++) {
								if (j == 0) {message += UWA.i18n("Implied Rules") + ":";}
								var ruleName = model.getRuleDisplayNameWithId(listOfListOfRulesImplied[i][j]) || listOfListOfRulesImplied[i][j];
								message += ruleName;
							}
						}
						break;
					}
				}
				return message;
			};


			/********************************END OF MULTIVALUEPRESENTER*****************************************************/


			return MultipleValueAutocompletePresenter;
		});


define(
		'DS/ConfiguratorPanel/scripts/Presenters/VariantClassesPresenter', 
		[
		 'UWA/Core',
		 'UWA/Controls/Abstract',
		 'DS/ConfiguratorPanel/scripts/Presenters/VariantPresenter',
         'DS/ConfiguratorPanel/scripts/Utilities',
	     'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json',
        
		 'css!DS/UIKIT/UIKIT.css'
		 
		 ],	
		 function (UWA, Abstract, VariantPresenter, Utilities, nlsConfiguratorKeys) {

			'use strict';

			var VariantClassesPresenter = Abstract.extend({
				/**
				 * @description
				 * <blockquote>
				 * <p>Initialiaze the VariantClassesPresenter component with the required options</p>
				 * <p>This component shows all the Features from Dictionary along with
				 * <ul>
				 * <li>Its Image.</li>
				 * <li>Label for Name</li>
				 * <li>Below the Name label , other attribute label is shown if that attribute is used to search feature</li>
				 * <li>Text box for selected Options with drop down to select options </li>
				 * <li>a small info icon to see other attributes </li>				 
				 * <li>Options selected by Rules are shown with a select icon, if clicked , the option will become user selected</li>
				 * </ul>
				 * </p>
				 * </blockquote>
				 *
				 * @memberof module:DS/ConfiguratorPanel/ConfiguratorPanel#
				 *
				 * @param {Object} options - Available options.
				 * @param {Object} options.parentContainer - The parent container where the VariantClassesPresenter will be injected
				 *
				 */
				listFilterStatusForFeatures : [],
				listMandStatusForFeatures: [],
				listResetStatusForFeatures: [],
				numberOfVariantClassesOnDictionary : 0,
				
				init: function (options) {
					var that = this;
					var model = options.configModel;
					
					that.listFilterStatusForFeatures = [];
					that.listMandStatusForFeatures = [];
					that.listResetStatusForFeatures = [];

					var FtrResultsDiv = UWA.createElement('div');
					FtrResultsDiv.id = "FtrResultsDiv";	
					FtrResultsDiv.style.display = 'none';					
					options.parentContainer.addContent(FtrResultsDiv);

					//Create the Main div of the VariantClassesPresenter
					var FeaturesDiv = UWA.createElement('div');
					FeaturesDiv.id = "FeaturesDiv";		
					FeaturesDiv.style.height = "calc(100% - " + FtrResultsDiv.offsetHeight + "px)";
					FeaturesDiv.style.overflow = "auto";
					FeaturesDiv.style.width = "100%";

					var extendedFeaturesDiv = UWA.extendElement(FeaturesDiv);
					options.parentContainer.addContent(extendedFeaturesDiv);

					var dico = options.configModel.getDictionary();
					var featureList = dico.features;	
					that.numberOfVariantClassesOnDictionary = featureList.length;

					var modelEvents = options.modelEvents;
					
					modelEvents.subscribe({ event: 'OnFilterResultChange' }, function (data) {

					    updateFilterResultNumber(data.featureId, data.resultBoolValue, data.show);
					});

					modelEvents.subscribe({ event: 'updateMANDNumberAndRefresh3D' }, function (data) {
					    updateMANDNumberAndRefresh3D(data.featureId, data.mandNotValuatedBoolValue, data.waitForAllFeatures, data.oldMandNotValuatedBoolValue);
					});

					modelEvents.subscribe({ event: 'displayMessageFeatureReseted' }, function (data) {
					    displayMessageFeatureReseted(data.featureId, data.hasBeenReseted);
					});

					extendedFeaturesDiv.addEvent('scroll', function () {
					    modelEvents.publish({
					        event: 'OnFeaturesDivScrolled'
					    });
					});

					var numberOfMandFeaturesNotValuated = 0;
					for(var i=0; i< featureList.length; i++)
					{
						var optVariants = {
							feature: featureList[i],
							parentContainer: extendedFeaturesDiv,
							configModel: model,
							modelEvents: modelEvents,
							ddRenderTo: options.ddRenderTo
						};
						var variantView = new VariantPresenter(optVariants);
						//if rules mode is not set
						var mandNotValuatedBoolValue = model.getFeatureIdWithMandStatus(featureList[i].ruleId);
						if(mandNotValuatedBoolValue == true) numberOfMandFeaturesNotValuated++;
						
					}			
					model.setNumberOfMandFeaturesNotValuated(numberOfMandFeaturesNotValuated);
					
					//@param resultBoolValue : true if the feature matches with the filter
					function updateFilterResultNumber(featureId, resultBoolValue, show) {
						var FtrResultsDiv = document.getElementById("FtrResultsDiv");
						
						if(show == false) {
							FtrResultsDiv.setContent("");
							FtrResultsDiv.style.display = 'none';
						}
						else {
							that.listFilterStatusForFeatures[featureId] = resultBoolValue;
							
							if(Object.keys(that.listFilterStatusForFeatures).length == that.numberOfVariantClassesOnDictionary) {
								
								var count = 0;
							
								for(var key in that.listFilterStatusForFeatures) {
									if(that.listFilterStatusForFeatures[key] == true)
										count++;
								}
								
								var myLabel = getLabelField(count + " " + nlsConfiguratorKeys.results ,"right: '0px'");						
								FtrResultsDiv.setContent(myLabel);
								FtrResultsDiv.style.display = 'block';
															
								that.listFilterStatusForFeatures = [];
							}
						}

						FeaturesDiv.style.height = "calc(100% - " + FtrResultsDiv.offsetHeight + "px)";
						
						function getLabelField(value , style, display) {
							var labeltag = ' <label style=\"display: '

								if(!display) display = 'block';
							labeltag = labeltag.concat(display); 
							labeltag = labeltag.concat(';padding: 5px 5px 0px 5px;font-family: sans-serif;');
							if(style && style!="") labeltag = labeltag.concat(style);
							labeltag = labeltag.concat('\" >'+value+'</label>');
							return labeltag;
						};		
					};
					
					//@param mandNotValuatedBoolValue : true if the feature is mandatory and not yet valuated
					function updateMANDNumberAndRefresh3D (featureId, mandNotValuatedBoolValue, waitForAllFeatures, oldMandNotValuatedBoolValue) {
						if(waitForAllFeatures) {
							that.listMandStatusForFeatures[featureId] = mandNotValuatedBoolValue;
								
							if(Object.keys(that.listMandStatusForFeatures).length == that.numberOfVariantClassesOnDictionary) {
								var count = 0;
								
								for(var key in that.listMandStatusForFeatures) {
									
									if(that.listMandStatusForFeatures[key] == true)
										count++;
									
									model.setFeatureIdWithMandStatus(key, that.listMandStatusForFeatures[key]);
								}
									
								//update the number of Mand not valuated
								model.setNumberOfMandFeaturesNotValuated(count);
								
								//update 3D
								modelEvents.publish( {
									event:	'ComputeConfigExpression'
								});

								that.listMandStatusForFeatures = [];
							}
						}
						else {
							if(oldMandNotValuatedBoolValue == true && mandNotValuatedBoolValue == false) {
								//update the number of Mand not valuated
								model.setNumberOfMandFeaturesNotValuated(model.getNumberOfMandFeaturesNotValuated() - 1);
								model.setFeatureIdWithMandStatus(featureId, false);
							}
							else if(oldMandNotValuatedBoolValue == false && mandNotValuatedBoolValue == true) {
								//update the number of Mand not valuated
								model.setNumberOfMandFeaturesNotValuated(model.getNumberOfMandFeaturesNotValuated() + 1);
								model.setFeatureIdWithMandStatus(featureId, true);
							}
							
							//update 3D
							modelEvents.publish( {
								event:	'ComputeConfigExpression'
							});
						}
					};

					function displayMessageFeatureReseted(featureId, hasBeenReseted) {
					    
					    var message;

					    that.listResetStatusForFeatures[featureId] = hasBeenReseted;

					    if (Object.keys(that.listResetStatusForFeatures).length == that.numberOfVariantClassesOnDictionary) {

					        var listOfFeaturesReset = [];

					        for (var key in that.listResetStatusForFeatures) {
					            if (that.listResetStatusForFeatures[key] == true)
					                listOfFeaturesReset.push(key);
					        }

					        if (listOfFeaturesReset.length > 0) {
					            message = nlsConfiguratorKeys.InfoUnsettingMultiSelection + "<br>";
					            for (var i = 0; i < listOfFeaturesReset.length; i++) {
					                message += "<blocquote style='padding-left:20px;'>" + model.getFeatureDisplayNameWithId(listOfFeaturesReset[i]) + "<br></blocquote>";
					            }
					            
					            Utilities.displayNotification({
					                eventID: 'info',
					                msg: message
					            });
					        }
                            
					        that.listResetStatusForFeatures = [];

					        modelEvents.publish({
					            event: 'SolverFct_CallSolveMethodOnSolver',
					            data: {}
					        });
					    }					    
					};
				}
			});

			return VariantClassesPresenter;
		});


define(
		'DS/ConfiguratorPanel/scripts/Presenters/SingleValueAutocompletePresenter',
		[
			'UWA/Core',
			'UWA/Event',
			'DS/Handlebars/Handlebars',
			'DS/UIKIT/Autocomplete',
			'DS/UIKIT/Mask',
			'DS/UIKIT/Tooltip',
			'DS/Controls/Popup',
			'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
			'DS/ConfiguratorPanel/scripts/Utilities',
			'DS/ConfiguratorPanel/scripts/ConfiguratorSolverFunctions',

			'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json',
			'text!DS/ConfiguratorPanel/html/SingleValueAutocompletePresenter.html',


			'css!DS/UIKIT/UIKIT.css',
			"css!DS/ConfiguratorPanel/css/SingleValueAutocompletePresenter.css"

			],
			function (UWA,Event, Handlebars, Autocomplete, Mask, Tooltip,WUXPopup, ConfiguratorVariables, Utilities,ConfiguratorSolverFunctions, nlsConfiguratorKeys, html_SingleValueAutocompletePresenter) {

			'use strict';

			var template = Handlebars.compile(html_SingleValueAutocompletePresenter);
			var badgeTooltip = [];
			var optionToolTip = [];
			var countConfigurations = 0;
			var rules = [];

			var SingleValueAutocompletePresenter = function (options) {
				this._init(options);
			};


			/******************************* INITIALIZATION METHODS**************************************************/

			SingleValueAutocompletePresenter.prototype._init = function(options){
				var _options = options ? UWA.clone(options, false) : {};
				UWA.merge(this, _options);
				this._subscribeEvents();
				this._initDivs();
				this.inject(_options.parentContainer);
				this._render();
			};

			SingleValueAutocompletePresenter.prototype._subscribeEvents = function(){
				var that = this;
				this.modelEvents.subscribe({ event: 'OnSortResult'}, function(data){
					that._sortAttribute = data.sortAttribute;
					that._sortOrder = data.sortOrder;
					var dataset = that._autocomplete.getDataset("_autocomplete");
				 	dataset.items = dataset.items.sort(function(a, b) {
						var nameA,nameB;
						if(that._sortAttribute === "displayName"){
							nameA = a.displayName.toUpperCase();
							nameB = b.displayName.toUpperCase();
						}
						if(that._sortAttribute === "sequenceNumber"){
							nameA = parseInt(a.sequenceNumber);
							nameB = parseInt(b.sequenceNumber);
						}
						if (that._sortOrder === "DESC") {
							var temp = nameA;
							nameA = nameB;
							nameB = temp;
						}
						if (nameA < nameB) {
							return -1;
						}
						if (nameA > nameB) {
							return 1;
						}
						return 0;
					});
				});
			};

			SingleValueAutocompletePresenter.prototype._initDivs = function () {
				this._container = document.createElement('div');
				this._container.innerHTML = template(this);
				this.image = this.imageContainer.getElementsByClassName("configurator-img-thumbnail");
				this.imageValidateDefault = this.imageContainer.querySelector("#config-editor-validate-default");
				this.imageValidateRequired = this.imageContainer.querySelector("#config-editor-validate-required");

				this._container = this._container.querySelector('.config-editor-singlevalue-autocomplete');
				this._iconGapContainer = this._container.querySelector('.iconGapContainer');
				this.rulesIconContainer = this._container.querySelector('#rulesIcon_' + this.variant.ruleId);
				this._validateCheckContainer = this._container.querySelector('.config-editor-validate-check');

			};

			SingleValueAutocompletePresenter.prototype.inject= function(parentcontainer) {
				parentcontainer.appendChild(this._container);
			};

			/*******************************AUTOCOMPLETE CREATION***************************************************/

			SingleValueAutocompletePresenter.prototype._render= function() {
				var that = this;
				this._autocomplete = new Autocomplete({
					multiSelect: false,
					showSuggestsOnFocus: true,
					allowFreeInput : true,
					placeholder : nlsConfiguratorKeys.type,
					events : {
						onSelect : function(item){
							that._onSelect(item);
						},
						onUnselect : function(item){
							that._onUnselect(item);
						},
						onShowSuggests : function(item, dataset){
							that._onShowSuggests(item, this);
						},
						onFocus : function(){
							var variantName = that.configModel.getFeatureDisplayNameWithId(that.variant.ruleId);
							var searchBox = document.querySelector('.autocomplete-input');
							var value = searchBox ? searchBox.value : "";
							var text = that.searchValue || value;
							if(variantName.toUpperCase().contains(text.toUpperCase())){
								this.showAll();	//show all in case variant has match
							}else{
								if(text && text !== "")
									that._autocomplete.getSuggestions(text);
								else {
									this.showAll();
								}
							}
						},
						onKeyDown : function(event){
							//Disabling free input
							if(Event.preventDefault){
								Event.preventDefault(event);
							}
							// && that._autocomplete.currentSuggestions && that._autocomplete.currentSuggestions.length > 0
							if(event.code.contains("Enter") && that._autocomplete.currentSuggestions && that._autocomplete.currentSuggestions.length === 0){
									that._autocomplete.elements.input.value = "";
									that.rulesIconContainer.className = "fonticon";
							}
							UWA.extendElement(that.rulesIconContainer); //disabling for rule selected items
							if(that.rulesIconContainer && that.rulesIconContainer.hasClassName("fonticon-lock"))
								Event.preventDefault(event);
						},
						onKeyUp : function(event){
							//Disabling free input
							if(Event.preventDefault){
								Event.preventDefault(event);
							}
						}
					}
				}).inject(this._container);

				this._autocomplete.elements.inputContainer.addContent(this._iconGapContainer);
				this._autocomplete.elements.inputContainer.addContent(this._validateCheckContainer);
				this._autocomplete.elements.inputContainer.addClassName("config-editor-single-input-parent");
				this._autocomplete.elements.input.addClassName("config-editor-single-input");
				// this._validateCheckContainer.style.display = "none";

				var _variantDataset = this._createDataset();
				var _datasetConfiguration = this._createConfigurations();
				this._autocomplete.addDataset(_variantDataset, _datasetConfiguration);
				this._autocomplete.elements.clear.className = "autocomplete-reset fonticon fonticon-wrong";
				var resetIcon = this._autocomplete.elements.clear.addEvent('click', function(e){
					var item;
					if(that._autocomplete.selectedItems && that._autocomplete.selectedItems[0]){
						item = that._autocomplete.selectedItems[0];
					}
					that.configModel.setValidateVariant(that.variant.ruleId, false);
					that.configModel.setLoading(that.variant.ruleId,"Loaded");
					that._autocomplete.dispatchEvent('onUnselect', item);
				});

				this._validateCheckContainer.onclick = function(e){
					this.style.display = "none";
					that.configModel.setFeatureIdWithChosenStatus(that.variant.ruleId, true);
					that.configModel.setValidateVariant(that.variant.ruleId, true);
					that.configModel.setStateWithId(that._autocomplete.selectedItems[0].optionId, ConfiguratorVariables.Chosen);
					that.callSolver();
				}
			};

			/*******************************AUTOCOMPLETE INITIALIZATION - ADD DATA************************************/

			SingleValueAutocompletePresenter.prototype._createDataset= function() {
				var dataset= {name: "_autocomplete", items : []};
				if(this.variant && this.variant.options && this.variant.options.length > 0){
					//sort by seq number
					this.variant.options = this.variant.options.sort(function(a, b) {
							var nameA = parseInt(a.sequenceNo); //a.displayName.toUpperCase();
							var nameB = parseInt(b.sequenceNo);//b.displayName.toUpperCase();
							if (nameA < nameB) {
								return -1;
							}
							if (nameA > nameB) {
								return 1;
							}
							return 0;
						});
					for(var i=0; i < this.variant.options.length; i++) {
						var state = this.configModel.getStateWithId(this.variant.options[i].id) || this.configModel.getStateWithId(this.variant.optionPhysicalIds[i]) || ConfiguratorVariables.Unselected;
						var selectedFromStart = false;
						if(state == "Chosen" || state == "Default" || state == "Required"){
							selectedFromStart = true;
						}
						dataset.items.push({
							mainId : this.variant.options[i].id,
							// value: this.variant.optionPhysicalIds[i],
							value: this.variant.options[i].ruleId,
							label : this.variant.options[i].displayName,
							disabled: false,
							selected : selectedFromStart,
							selectable:true,
							icon:"",
							state:state,
							conflicting: false,
							included : "",
							ruleId : this.variant.options[i].ruleId,
							// optionId : this.variant.optionPhysicalIds[i],
							optionId : this.variant.options[i].ruleId,
							tooltip : "",
							selectionCriteria : this.variant.selectionCriteria,
							variantId : this.variant.ruleId,
							optionRuleId : this.variant.options[i].ruleId,
							image : this.variant.options[i].image,
							displayName : this.variant.options[i].displayName,
							sequenceNumber : this.variant.options[i].sequenceNumber
						});
					}
				}
				return dataset;
			};

			/*******************************AUTOCOMPLETE INITIALIZATION - UPDATE DISPLAY FORMAT************************************/

			SingleValueAutocompletePresenter.prototype._createConfigurations= function() {
				return {
					templateEngine: function (itemContainer, itemDataset, item) {
						itemContainer.addClassName('default-template');
						var icon = "fonticon";
						if(item.icon && item.icon!=='') icon = "fonticon fonticon-" + item.icon;
						if(item.icon === 'alert') icon = icon + " conflict-icon";
						var content = UWA.createElement('span', {id: "DD-item-" + item.value ,'class': "suggestion-icon " +icon});
						var contentForDefault = UWA.createElement('span', {id: "Default-DD-item-" + item.value ,'class': "contentForDefault fonticon fonticon-star"});
						contentForDefault.hide();
						itemContainer.setHTML(content.outerHTML + '<div class="item-label">' + item.label + '</div>' + contentForDefault.outerHTML);
					}.bind(this)
				}
			};

			/*******************************AUTOCOMPLETE EVENTS HANDLING - SELECTION**************************************************/

			SingleValueAutocompletePresenter.prototype._onSelect= function(item) {
				this.imageContainer.classList.add('cfg-image-selected');
				// this._autocomplete.elements.input.style.width = (item.label.length + 1)*8 + "px";
				if(this.configModel.getLoading(this.variant.ruleId) === "Loaded"){
					var newItemState = item.state ;
					var allSuggestions = this._autocomplete.getItems() || [];
					for(var i =0; i< (allSuggestions.length); i++){
						var suggestionState = this.configModel.getStateWithId(allSuggestions[i].value);
						if(allSuggestions[i].id !== item.id){
							if(suggestionState === ConfiguratorVariables.Chosen || suggestionState === ConfiguratorVariables.Selected){
								this.configModel.setStateWithId(allSuggestions[i].value, ConfiguratorVariables.Unselected);
							}
						}
					}
					var newItemState = item.state ;
					var defaultItem = this._find(this.defaults, item.value);
					newItemState = defaultItem ? ConfiguratorVariables.Unselected : ConfiguratorVariables.Chosen;
					this.configModel.setStateWithId(item.value, newItemState);
					this.callSolver(item);
				}
			};

			/*******************************AUTOCOMPLETE EVENTS HANDLING - UNSELECTION************************************************/

			SingleValueAutocompletePresenter.prototype._onUnselect= function(item) {
				this.imageContainer.classList.remove('cfg-image-selected');
				if(this.configModel.getLoading(this.variant.ruleId) === "Loaded"){
					var newItemState = item.state ;
					if(this.configModel.getSelectionMode() === ConfiguratorVariables.selectionMode_Build){
						if(item.state === ConfiguratorVariables.Chosen){
							newItemState = ConfiguratorVariables.Unselected;
						}
						if(item.state === ConfiguratorVariables.Default || item.state === ConfiguratorVariables.Selected){
							newItemState = ConfiguratorVariables.Dismissed;
						}
					}
					this.configModel.setStateWithId(item.value, newItemState);
					this.callSolver(item);
				}
			};

			/*******************************AUTOCOMPLETE EVENTS HANDLING - UPDATE SUGGESTIONS****************************************/

			SingleValueAutocompletePresenter.prototype._onShowSuggests= function(item) {
				this.configModel.setLoading(this.variant.ruleId, "Loaded");
				// this.modelEvents.publish({event:'hideUnreferencedDD', data : {currentAutocomplete : this}});
				var items = this._autocomplete.getItems();
				for(var i=0; i<items.length; i++){
					this._updateIconInDD(items[i]);
				}
			};

			/********************************FUNCTIONALITIES - CALL SOLVER BASED ON RULES SELECTION**********************************/

			SingleValueAutocompletePresenter.prototype.callSolver = function(item){
				this.modelEvents.publish({event:'pc-interaction-started', data : {}});
				if(this.configModel.getRulesActivation() === ConfiguratorVariables.str_true) {
					if(this.configModel.getLoading(this.variant.ruleId) === "Loaded"){
						this.modelEvents.publish({event:'SolverFct_CallSolveMethodOnSolver', data : {}});
					}
				}else{
					this.updateFilters();
					this.modelEvents.publish({event: 'solveAndDiagnoseAll_SolverAnswer'});
				}
			};

			/********************************FUNCTIONALITIES - UPDATE VIEW - MAIN METHOD******************************************/

			SingleValueAutocompletePresenter.prototype.enforceRequired= function(data) {
				var that = this, variantSelectedByRule = false, variantSelectedByUser = false,conflictingOption=false;
				this.enabled = false;
				this.defaults = data ? data.answerDefaults : [];
				this.configModel.setFeatureIdWithRulesStatus(this.variant.ruleId, false);
				this.configModel.setFeatureIdWithChosenStatus(that.variant.ruleId, false);
				this.configModel.setUserSelectVariantIDs(that.variant.ruleId, false);
				for(var i =0; i<this.variant.options.length;i++){
					if(this.configModel.getUpdateRequiredOption(this.variant.optionPhysicalIds[i])){
					var item = this._getRequiredData(i);
					this._loadData(item);
					this._enableValidation(item);
					this._updateIcons(item);
					this._updateBadge(item);
					this._updateIconInDD(item);
					conflictingOption = conflictingOption || item.conflicting;
					this._updateImage(this.variant.options[i], item.selected, conflictingOption);
					this._updateItem(item);
					if(item.selectedByRules) variantSelectedByRule = true;
					if(item.selectedByUser) variantSelectedByUser = true;
					if(item && (item.state === "Chosen" || item.state === "Dismissed" || item.state === "Required" || item.state === "Default")){
						this.configModel.setUserSelectVariantIDs(item.variantId, true);
					}
				}
				}
				this.configModel.setFeatureIdWithRulesStatus(this.variant.ruleId, variantSelectedByRule);
				this.configModel.setFeatureIdWithChosenStatus(that.variant.ruleId, variantSelectedByUser);
				this.updateFilters();
			};

			SingleValueAutocompletePresenter.prototype._enableValidation= function(item) {
				if(this.configModel.isValidationEnabled()){
					var validate = false;
					if(item && item.state){
							if(item.state === ConfiguratorVariables.Default){
								this._validateCheckContainer.style.display = "inline-block";
								this._validateCheckContainer.classList.remove("config-editor-validate-rule-check");
								this._validateCheckContainer.classList.add("config-editor-validate-default-check");
								this.enabled = true;
							}else if(item.state === ConfiguratorVariables.Required){
								this._validateCheckContainer.style.display = "inline-block";
								this._validateCheckContainer.classList.add("config-editor-validate-rule-check");
								this._validateCheckContainer.classList.remove("config-editor-validate-default-check");
								this.enabled = true;
							}else if(!this.enabled){
								this._validateCheckContainer.style.display = "none";
							}
					}
				}
			};

			/*******************************UPDATE VIEW RELATED HELPER METHODS******************************************/

			SingleValueAutocompletePresenter.prototype._getRequiredData= function(i) {
				var item = this._autocomplete.getItem(this.variant.optionPhysicalIds[i]);
				var state = this.configModel.getStateWithId(item.value) || this.configModel.getStateWithId(item.mainId);
				item.state = state || "Unselected";
				item.variantState = this.configModel.getStateWithId(item.variantId);
				item.conflicting = this.configModel.isConflictingOption(item.ruleId);

				this._updateItem(item);
				return item;
			};

			/*******************************UPDATE VIEW : LOAD DATA****************************************************/

			SingleValueAutocompletePresenter.prototype._loadData= function(item) {
				this.configModel.setLoading(this.variant.ruleId);
				var selectedState;
				this._autocomplete.enable();
				this._autocomplete.enableItem(item.id);
				var rules = this.configModel.getRulesActivation() === ConfiguratorVariables.str_true ? true : false;

				// switch (item.state) {
				// case ConfiguratorVariables.Default: case ConfiguratorVariables.Required: case ConfiguratorVariables.Selected:
				// 	selectedState = rules ? true : false;
				// 	break;
				// case ConfiguratorVariables.Chosen:
				// 	selectedState = rules ? true : item.conflicting ? false : true;
				// 	break;
				// case ConfiguratorVariables.Unselected:
				// 	selectedState = item.included ? true : false;
				// 	break;
				// default :
				// 	selectedState = rules ? item.conflicting ? true : false : false;
				// 	break;
				// }

				switch (item.state) {
				case ConfiguratorVariables.Default: case ConfiguratorVariables.Required: case ConfiguratorVariables.Selected:
					selectedState = rules ? true : false;
					break;
				case ConfiguratorVariables.Chosen:
					selectedState = true;
					break;
				case ConfiguratorVariables.Unselected:
					selectedState = item.included ? true : false;
					break;
				default :
					selectedState = false;
					break;
				}

				// if(item.conflicting && rules) selectedState = true;
				// (item.selected && selectedState) ? "" : this._autocomplete.toggleSelect(item,"",selectedState);
				if((item.selected || selectedState) && !(item.selected && selectedState)){
					this._autocomplete.toggleSelect(item);
				}
				if(item.disable){
					this._autocomplete.disableItem(item.id);
				}
				// item.disable ? this._autocomplete.disableItem(item.id) : this._autocomplete.enableItem(item.id);
				this.configModel.setLoading(this.variant.ruleId,"Loaded");
			};

			/*******************************UPDATE VIEW : MODIFY ICONS***********************************************/

			SingleValueAutocompletePresenter.prototype._updateIcons= function(item) {
				var rules = this.configModel.getRulesActivation() === ConfiguratorVariables.str_true ? true : false;
				var icon;
				switch (item.state) {
				case ConfiguratorVariables.Default:
					icon = rules ? "star" : "";
					break;
				case ConfiguratorVariables.Required:
					icon = rules ? "lock" : "";
					break;
				case ConfiguratorVariables.Incompatible:
					icon = rules ? "block" : "";
					break;
				case ConfiguratorVariables.Dismissed:
					icon = "user-delete";
					break;
				case ConfiguratorVariables.Selected:
					icon = "lightbulb";
					break;
				default :
					icon = "";
				break;
				}
				if(item.conflicting && rules) icon = "alert";
				this._updateItem(item, {icon:icon});
			};

			/****************************************UPDATE VIEW : GENERATE TOOLTIP MESSAGE****************************************/

			SingleValueAutocompletePresenter.prototype._updateTooltipMessages= function(item) {
				var message = "";
				if (item.conflicting && item.conflicting == true) {
					message = this.getConflictingMessage(item.value);
				}else{
					message = nlsConfiguratorKeys.Loading;
					this.modelEvents.publish({event:'SolverFct_getResultingStatusOriginators', data : {value : item.optionId}});
				}
				this.setTooltipMessage(item.value, message);
			};

			/****************************************UPDATE VIEW : CACHE TOOLTIP MESSAGE**********************************************/

			SingleValueAutocompletePresenter.prototype.setTooltipMessage= function(option, message) {
				var item = this._autocomplete.getItem(option);
				this._updateItem(item, {tooltip : message});
				this._updateSuggestionPopup(item);
				this._updateBadgePopup(item);
			};

			/****************************************UPDATE VIEW : CREATE TOOLTIP AND SET MESSAGE**************************************/

			SingleValueAutocompletePresenter.prototype._updateSuggestionPopup= function(item) {
				if(this._updateForSuggestion){
						optionToolTip[item.value].setBody(item.tooltip);
						optionToolTip[item.value].getContent().addClassName('cfg-custom-popup');
						setTimeout(function(){
							if(optionToolTip[item.value].elements.container.offsetWidth === 0){
								optionToolTip[item.value].toggle();
							}
						},100);
						// optionToolTip[item.value].toggle(); //Added due to autoposition issue on content change in webux/pop
						// optionToolTip[item.value].toggle(); //To be removed once it is handled by component itself;
					}
			};

			SingleValueAutocompletePresenter.prototype._updateBadgePopup= function(item) {
				if(this._updateForBadge){
						badgeTooltip[item.variantId].setBody(item.tooltip);
						badgeTooltip[item.variantId].getContent().addClassName('cfg-custom-popup');
						setTimeout(function(){
							if(badgeTooltip[item.variantId].elements.container.offsetWidth === 0){
								badgeTooltip[item.variantId].toggle();
							}
						},100);
					}
			};

			/*******************************UPDATE VIEW : SET ICON IN BADGE AND SUGGESTIONS********************************************/

			SingleValueAutocompletePresenter.prototype._updateBadge= function(item) {
				var that= this;
				var selection = this._autocomplete.selectedItems ? this._autocomplete.selectedItems : [];
				this.rulesIconContainer.className = selection.length === 0 ? item.icon : this.rulesIconContainer.className;
				for(var j =0; j < selection.length; j++){
					if(selection[j].id === item.id){
						item.closable ? item.selected ? this._autocomplete.elements.clear.show() : "" : this._autocomplete.elements.clear.hide();
						this.rulesIconContainer.className = "fonticon fonticon-" + item.icon;
						// if(item.icon && item.icon !== ""){	//To show the icon before Type...
						// 	this._iconGapContainer.style.display = "inline-block";
						// }
						this.rulesIconContainer.className = !item.conflicting ? this.rulesIconContainer.className : this.rulesIconContainer.className + " conflict-icon";
						if(!badgeTooltip[item.variantId] || (badgeTooltip[item.variantId] && badgeTooltip[item.variantId].target && !badgeTooltip[item.variantId].target.isConnected) ) {
							badgeTooltip[item.variantId] = new WUXPopup({ target: this.rulesIconContainer,trigger: 'click', position:'top'});
						}
						this.rulesIconContainer.onclick = function(){
							that._updateForBadge = true;
							that._updateForSuggestion = false;
							that._updateTooltipMessages(this);
						}.bind(item);
						break;
					}
				}
			};

			SingleValueAutocompletePresenter.prototype._updateIconInDD= function(item) {
				var message = '', suggestion, iconDiv, that = this, contentForDefault;
				/** Suggestions are not available by default. They are created onShowSuggests **/
				if(item.elements){
					suggestion = this._autocomplete.elements.container.getElement('#autocomplete-item-'+ item.id);
					if(suggestion){
						if(suggestion.hasClassName('disabled')){
							suggestion.removeClassName('disabled');
						}
						if(suggestion.hasClassName('conflict-icon')){
							suggestion.removeClassName('conflict-icon');
						}
						iconDiv = suggestion.getElementsByClassName('fonticon')[0];
						contentForDefault = suggestion.getElements('#Default-DD-item-' + item.value)[0];
						if(contentForDefault)contentForDefault.hide();
						// /**Handling default in compatible mode.**/
						// if(this.defaults && this.configModel.getRulesMode() === "RulesMode_DisableIncompatibleOptions"){
						// 	if(this.defaults.indexOf(item.ruleId) !== -1){
						// 		item.icon = "star";
						// 	}
						// }
						/**showing star on right side in dismissed/required state or in compatible mode*/
						if(this.defaults && contentForDefault && item.state !== ConfiguratorVariables.Default){
							if(this.defaults.indexOf(item.ruleId) !== -1){
								contentForDefault.show();
							}
						}
						if(iconDiv && item.icon){
							if(optionToolTip[item.optionId] && optionToolTip[item.optionId].elements){
								optionToolTip[item.optionId] = null;
							}
							optionToolTip[item.optionId] = new WUXPopup({ target: iconDiv,trigger: 'click', position:'top'});
							iconDiv.onclick = function(e){
								e.stopPropagation();	//Prevent trigger from item selection
								that._updateForBadge = false;//To be removed on receiving udpates from webux
								that._updateForSuggestion = true;//To be removed on receiving udpates from webux
								that._updateTooltipMessages(this);
							}.bind(item);
							iconDiv.className =  "suggestion-icon fonticon fonticon-" + item.icon;
							if(item.icon === 'block'){
								suggestion.addClassName('disabled');
							}
							if(item.icon === 'alert'){
								suggestion.addClassName('conflict-icon');
							}
						}else{
							if(iconDiv)
								iconDiv.className =  "suggestion-icon fonticon";
						}
					}

				}
			};

			/****************************************UPDATE VIEW : UPDATE IMAGE AS PER CF/CO************************************/

			SingleValueAutocompletePresenter.prototype._updateImage = function (optionObj, selected, conflicting) {
				var image = this.image;
				if(image && image[0]){
					if(this._autocomplete.selectedItems.length === 0){
						if(this.variant.image !== "")
							image[0].src = this.variant.image;
					}else{
						if(selected && optionObj && optionObj.image !== "")
							image[0].src = optionObj.image;
					}
					if(conflicting && this.configModel.getRulesActivation() === "true"){
						image[0].parentElement.style.borderColor = "red";
						this._autocomplete.elements.inputContainer.addClassName("config-editor-single-input-parent-conflict");
					}else{
						image[0].parentElement.style.borderColor = "#b1b1b1";
						this._autocomplete.elements.inputContainer.removeClassName("config-editor-single-input-parent-conflict");
					}
				}
			};

			/*******************************UPDATE VIEW : HANDLE MUST/MAY FEATURES AND INCLUSION RULES***************************/

			SingleValueAutocompletePresenter.prototype.updateFilters = function(){
				var variantState = this.configModel.getStateWithId(this.variant.ruleId);
				var mandatory = (this.variant.selectionCriteria == 'Must' || this.variant.selectionCriteria == true)? true : false;
				var mandStatus = (mandatory || variantState === ConfiguratorVariables.Required) ? true : false;
				var selectedFeature;
				if(this._autocomplete.selectedItems && this._autocomplete.selectedItems.length > 0){
					mandStatus = false;
					selectedFeature = true;
				}else{
					selectedFeature = false;
				}

				if(variantState=== "Incompatible"){
							if(!this.configModel.getUserSelectVariantIDs(this.variant.ruleId))
								selectedFeature = false;
				}

				// if(this._container.offsetParent && this._container.offsetParent.style.display === "none"){
				// 	selectedFeature = false;
				// }

				this.configModel.setFeatureIdWithMandStatus(this.variant.ruleId, mandStatus);
				this.configModel.setFeatureIdWithStatus(this.variant.ruleId, selectedFeature);
				// this.modelEvents.publish({event:'updateAllFilters', data : {}});

			};

			/******************************************UTILITIES**********************************************************/

			SingleValueAutocompletePresenter.prototype._find = function (array, id) {
				var flag = false;
				if(array){
					array.forEach(function(item){
						if(item === id){ flag = true; }
					});
				}
				return flag;
			};

			SingleValueAutocompletePresenter.prototype._updateItem= function(item,object) {
				if(item){
					var rules = this.configModel.getRulesActivation() === ConfiguratorVariables.str_true ? true : false;
					if(object){
						item.icon = (object.icon || object.icon === "") ? object.icon : item.icon;
						item.tooltip = (object.tooltip || object.tooltip === "") ? object.tooltip : item.tooltip;
					}
					item.closable = item.selected ? item.state === "Required" ? false : true : true;
					item.selectedByRules = rules ? item.icon ? true : false : false;
					item.disable =  rules ? (item.state === "Required" || item.state === "Incompatible") ? true : false : false;
					item.selectedByUser = item.state === "Chosen" ? true : false;

				}
				return item;
			};

			SingleValueAutocompletePresenter.prototype.getConflictingMessage = function(optionId){
				var addAlso, message='';
				var model = this.configModel;
				message = UWA.i18n("Option") + " " + model.getOptionDisplayNameWithId(optionId) + " " + UWA.i18n("is conflicting with") + ":";
				var listOfListOfConflictingIds = model.getConflictingFeatures();
				var listOfListOfRulesImplied = model.getImpliedRules();
				//need to traverse the list again, to generate the text for tooltip

				for (var i = 0; i < listOfListOfConflictingIds.length; i++) {
					if (listOfListOfConflictingIds[i].indexOf(optionId) != -1) {
						if (addAlso)message += UWA.i18n("and also conflicting with ");
						for (var j = 0 ; j < listOfListOfConflictingIds[i].length; j++) {
							if (optionId != listOfListOfConflictingIds[i][j]) {
								message += model.getFeatureDisplayNameWithId(listOfListOfConflictingIds[i][j]) + "[" + model.getOptionDisplayNameWithId(listOfListOfConflictingIds[i][j]) + "]";
								addAlso = true;
							}
						}
						if (listOfListOfRulesImplied.length > 0) {
							for (var j = 0 ; j < listOfListOfRulesImplied[i].length; j++) {
								if (j == 0) {message += UWA.i18n("Implied Rules") + ":";}
								var ruleName = model.getRuleDisplayNameWithId(listOfListOfRulesImplied[i][j]) || listOfListOfRulesImplied[i][j];
								message += ruleName;
							}
						}
						break;
					}
				}
				return message;
			};

			/********************************END OF MULTIVALUEPRESENTER*************************************************************/

			return SingleValueAutocompletePresenter;
});


define(
	'DS/ConfiguratorPanel/scripts/Presenters/ConfiguratorPanelPresenter',
	[
		'UWA/Core',
		'UWA/Controls/Abstract',
		'DS/W3DXComponents/Views/Layout/ActionsView',
     	'DS/W3DXComponents/Collections/ActionsCollection',
		'DS/ConfiguratorPanel/scripts/Presenters/ToolbarPresenter',
		'DS/ConfiguratorPanel/scripts/Presenters/VariantClassesPresenter',
		//'DS/Core/ModelEvents',
		//'DS/Windows/ImmersiveFrame',
		//'DS/Windows/Panel',
				
		'css!DS/UIKIT/UIKIT.css',
		"css!DS/ConfiguratorPanel/scripts/Presenters/ConfiguratorPanelPresenter.css"
	],	
	function (UWA, Abstract, ActionsView, ActionsCollection, ToolbarPresenter, VariantClassesPresenter/*, ModelEvents,*/ /*WUXImmersiveFrame, WUXPanel,*/ /*ConfiguratorModel, ConfiguratorSolverFunctions*/) {

		'use strict';

		var ConfiguratorPanelPresenter = Abstract.extend({
				_panelShown: true,
				_modelEvents: null,
				_configModel: null,
				
				 /**
				 * @description
				 * <blockquote>
				 * <p>Initialiaze the ConfiguratorPanelPresenter component with the required options</p>
				 * <p>This component allows you to create a panel where you can create/edit a configuration.
				 * </p>
				 * </blockquote>
				 *
				 * @memberof module:DS/ConfiguratorPanel/ConfiguratorPanel#
				 *
				 * @param {Object} options - Available options.
				 * @param {Object} options.parentContainer - The parent container where the ConfiguratorPanelPresenter will be injected
				 * @param {Object} options._configModel - The configurator model that will be used
                 * @param {Object} options.modelEvents - ModelEvents that will be used to handle all the events in the component
                 * @param {Object} options.hideSlider - {OPTIONNAL} option to chose if we want the slider to be displayed or not. Values being true/false. By default, the slider is displayed
                 * @param {Object} options.add3DButton - {OPTIONNAL} option to create a "3D" button in the toolbar. Added for Enovia Demo. Should be used in Model Editor integration
				 *
				 */
				 init: function (options) {
					
				     var that = this;
				     this.hideSlider = (options.hideSlider) ? true : false;
				     this.add3DButton = (options.add3DButton) ? true : false;

					 //Create the modelEvents
					this._modelEvents = options.modelEvents; //new ModelEvents();
					
					 //Create an instance of the Configurator model
					this._configModel = options.configModel; /*new ConfiguratorModel({
						configuration: options.configuration,
						appRulesParams : options.appRulesParams,
						appFunc : options.appFunc,
						modelEvents : this._modelEvents
					 });*/
					 
					 //initialize a Solver
					 //once the solver is initialized, call the panel creation
					 /*if(options.productId && options.productId!= "")
					 {
					     ConfiguratorSolverFunctions.initSolver(options.productId, this._configModel, this._modelEvents, function(dictionary){
							    console.log("Solver Initialized !!");
							
							    that._configModel.setDictionary(dictionary);
							
							    that._initConfiguratorPanel(options);
						     }
					     );
					 }*/

					 this._initConfiguratorPanel(options);
					 
					 
				 },
				 
				 _initConfiguratorPanel : function (options) {
					var that = this;
					
					//Create the Main div of the Configurator
					var configuratorDiv = UWA.createElement('div');
					configuratorDiv.id = "ConfiguratorPanel";					
					
					var extendedConfigPanelDiv = UWA.extendElement(configuratorDiv);	
					
					//Create the div for the Expand/Collapse icon on the left of Configurator panel
					if (!this.hideSlider) {
					    var expandCollapseDiv = UWA.createElement('div');
					    expandCollapseDiv.id = "expandCollapseConfigPanelDiv";					
					
					    var extendedExpandCollapseDiv = UWA.extendElement(expandCollapseDiv);
					
					    extendedExpandCollapseDiv.inject(configuratorDiv);
					
					
					    //Add Expand/Collapse icon in expandCollapseConfigPanelDiv
					    var actionsList = [{
							    text : "Expand Configuration Panel",
							    icon: that._panelShown ? 'left-open':'right-open',
							    actionId: 'ExpandConfigurationPanel',
							    handler: function(e) {
								    if(!that._panelShown) {
									    configuratorContentDiv.style.left = "0px";
									    that._panelShown = true;
								    }
								    else{
									    configuratorContentDiv.style.left = - configuratorContentDiv.offsetWidth + "px";
									    that._panelShown = false;
								    }			
								
								    e.currentTarget.getElement('span').className = that._panelShown ? 'fonticon fonticon-2x fonticon-left-open':'fonticon fonticon-2x fonticon-right-open';
							    }
					    }];
					
					    var actionObj = {
					    collection : new ActionsCollection(actionsList),
					    events : {
						    'onActionClick' : function(actionView, event) {
							    var actionFunction = actionView.model.get('handler');

								    if (UWA.is(actionFunction, 'function')) {
									    actionFunction.call(undefined, event);
								    }
							    }
						    }
					    };
					    var actionView = new ActionsView(actionObj);
					    actionView = actionView.render();
					    actionView.container.setStyles({ verticalAlign: 'middle', justifyContent: 'flex-start'});
					
					
					    actionView.inject(extendedExpandCollapseDiv);
					}
					
					//Create the div that will contain the div that contains all the features, toolbar, variants... (Not sure that this comment is clear :D )
					var configuratorContentDivParent = UWA.createElement('div');
					configuratorContentDivParent.id = "configContentDivParent";	
					
					var extendedConfiguratorContentDivParent = UWA.extendElement(configuratorContentDivParent);
					
					extendedConfiguratorContentDivParent.inject(configuratorDiv);
					
					//Create the div that contains all the features, toolbar, variants...
					var configuratorContentDiv = UWA.createElement('div');
					configuratorContentDiv.id = "configContentDiv";	
					configuratorContentDiv.style.width = "500px"; 
					//configuratorContentDiv.style.left = "0px";						
					//configuratorContentDiv.style.backgroundColor = "yellow";
					//configuratorContentDiv.style.opacity = 0.2;
					
					var extendedConfiguratorContentDiv = UWA.extendElement(configuratorContentDiv);	
					
					
					extendedConfiguratorContentDiv.inject(configuratorContentDivParent);
					
					options.parentContainer.addContent(extendedConfigPanelDiv);
					

					var dico = options.configModel.getDictionary();
					var featureAttrList = [];
					var displayNameAttr = '';

					if(dico.features && dico.features.length > 0){
					for (var featureAttr in dico.features[0].attributes) {
					    featureAttrList.push(featureAttr);
					    if (dico.features[0].attributes[featureAttr] === dico.features[0].displayName) {
                            displayNameAttr = featureAttr;
					    }
					}

					var configuratorToolbar = new ToolbarPresenter({
						parentContainer : extendedConfiguratorContentDiv,
						modelEvents : that._modelEvents,
						configModel : that._configModel,
						attributesList: featureAttrList,
						defaultAttributeSelected: displayNameAttr,
						add3DButton: (this.add3DButton) ? "yes":"no"
					});
					
					
					var variantClassesDiv = UWA.createElement('div');
					variantClassesDiv.id = "variantClassesListDiv";	
					//variantClassesDiv.style.maxHeight = "calc(100% - " + configuratorToolbar.getToolbarHeight() + "px)";
					variantClassesDiv.style.height = "calc(100% - " + configuratorToolbar.getToolbarHeight() + "px)";					//configuratorContentDiv.offsetHeight - configuratorToolbar.offsetHeight;
					variantClassesDiv.style.top = "0px";				
					
					var extendedVariantClassesDiv = UWA.extendElement(variantClassesDiv);
					extendedVariantClassesDiv.inject(extendedConfiguratorContentDiv);
					
					var VCPresenter = new VariantClassesPresenter({
						parentContainer : extendedVariantClassesDiv,
						configModel : that._configModel,
						modelEvents : that._modelEvents,
						ddRenderTo: extendedConfiguratorContentDiv
					});
					
					that._modelEvents.subscribe({ event: 'OnToolbarHeightChange' }, function (data) {
					    variantClassesDiv.style.height = "calc(100% - " + data.value + "px)";
					});
					}else{
						options.parentContainer.setContent("No configurations features");
						options.parentContainer.addClassName("empty-configuration");
						this._modelEvents.publish({event: 'onEmptyConfigurations', data : dico});
						console.log("Empty dictionary. Event Returned");
					}
				},
				
				/*releaseSolver: function() {		//release the solver if any
					ConfiguratorSolverFunctions.releaseSolver();
				},*/
				
				subscribe: function(parameters, callback) {		//returns a token
					return this._modelEvents.subscribe(parameters, callback);
				},

				unsubscribe: function(token) {
					this._modelEvents.unsubscribe(token);
				}
				 
			 });
			 
			 
		return ConfiguratorPanelPresenter;
	});
	

/*
	FilterExpressionXMLServices.js
	To convert configurator json to xml for binary creation

*/

define('DS/ConfiguratorPanel/scripts/Models/FilterExpressionXMLServices',
[
	'UWA/Core',
	'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables'
],
function (UWA, ConfiguratorVariables) {

    function FilterExpressionXMLServices(xmlType)
    {
	    var AppRulesParamObj = new Object();
	    var AppFuncObj =  new Object();
	    var DictionaryObj = new Object();
	    var ConfigCriteriaObj =  new Object();
	    var XML_FILE_TYPE = new Object();
	    var EvolutionCriteriaObj = new Object();
	    var ModelVersionInfoObj = new Object();
	    var FILTER_SELECTION_MODE = '';
	    var listOfRejectedOptionsForEachSingleFeature = new Object();     //XF3
	    var listOfRejectedOptionsStateForEachSingleFeature = new Object();     //XF3
		var listOfRejectedOptionsDNForEachSingleFeature = new Object();

	    var XML_TAG_NAMES = {
		    FilterSelection : 'FilterSelection',
		    Context : 'Context',
		    CfgFilterExpression : 'CfgFilterExpression',
		    Feature : 'Feature'
	    };

	    var ATTR_VALUE_MAP = {
		    selectionMode	 : "SelectionMode",
		    selectionMode_Build: "Strict",
		    selectionMode_Refine: "150%"

	    }
	    var ATTRNAMES = ['selectionMode'];
	    var CONFIGURATOR_FIELDS = {
		    ConfigurationCriteria :'configurationCriteria',
		    ApplicationState :'applicationState',
		    AppRulesParam : 'app_RulesParam',
		    AppFunc : 'app_Func',
		    Dictionary : 'dictionary',
		    Rules:'rules',
		    EvolutionCriteria: 'evolutionCriteria',
	        ModelVersionInfo:'modelVersionInfo'
	    };

	    var XML_DECLARE = {
		    Schema : "xmlns:xs",
		    Namespace : "xmlns",
		    SchemaLocation : "xs:schemaLocation"
	    };

	    var FILTER_EXPRESSION = {
		    ROOT : "CfgFilterExpression",
		    TAG1 : "FilterSelection",
		    Schema: "http://www.w3.org/2001/XMLSchema-instance",
		    Namespace : "urn:com:dassault_systemes:config",
		    SchemaLocation : "urn:com:dassault_systemes:config CfgFilterExpression.xsd"
	    };
	    initXMLType();
	    function initXMLType(){
		    if(xmlType == 'FilterExpression')
			    XML_FILE_TYPE = FILTER_EXPRESSION;
	    }
	    function initParamObjects(jsonObj)
	    {
		    AppRulesParamObj = jsonObj[CONFIGURATOR_FIELDS.AppRulesParam];
		    AppFuncObj =  jsonObj[CONFIGURATOR_FIELDS.AppFunc];
		    DictionaryObj = jsonObj[CONFIGURATOR_FIELDS.Dictionary];
		    ConfigCriteriaObj =  jsonObj[CONFIGURATOR_FIELDS.ConfigurationCriteria];
		    EvolutionCriteriaObj = jsonObj[CONFIGURATOR_FIELDS.EvolutionCriteria];
		    FILTER_SELECTION_MODE = AppRulesParamObj['selectionMode'];
		    ModelVersionInfoObj = jsonObj[CONFIGURATOR_FIELDS.ModelVersionInfo];
	    }

	    function getXMLDeclaration()
	    {
		    var initXml = '<?xml version="1.0" encoding="UTF-8"?>';
		    var attrList = [];
		    for(var elem in XML_DECLARE)
		    {
			    attrList.push(elem);
		    }
		    initXml += "<"+ XML_FILE_TYPE.ROOT;
		    if(attrList!=null) {
			    for(var item = 0; item < attrList.length; item++) {
				    var key = attrList[item]
				    var attrName = XML_DECLARE[key];
				    var attrVal = FILTER_EXPRESSION[key];
				    //attrVal=escapeXmlChars(attrVal);
				    initXml+=" "+attrName+"='"+attrVal+"'";
			    }
		    }
		    initXml+=">";
		    return initXml;
	    }

	    function jsonXmlElemCount () {
		    var elementsCnt = 0;
		    for( var it in ConfigCriteriaObj  ) {
			    if(ConfigCriteriaObj[it] instanceof Object)
			    {
			        if (ConfigCriteriaObj[it].State == ConfiguratorVariables.Chosen || ConfigCriteriaObj[it].State == ConfiguratorVariables.Required || ConfigCriteriaObj[it].State == ConfiguratorVariables.Default || ConfigCriteriaObj[it].State == ConfiguratorVariables.Selected
					    || ConfigCriteriaObj[it].State == ConfiguratorVariables.Dismissed || ConfigCriteriaObj[it].State == ConfiguratorVariables.Incompatible)
						    elementsCnt++;
				    }
			    }

		    return elementsCnt;
	    }
	    function addAttributes(rulesParamObj,element, attrList, closed) {
		    var resultStr = "<"+ element;
		    if(attrList!=null) {
			    for(var aidx = 0; aidx < attrList.length; aidx++) {
				    var attrName = attrList[aidx];
				    if(ATTR_VALUE_MAP[attrName] != undefined)
				    {
					    var tAttrName = ATTR_VALUE_MAP[attrName];
					    attrVal = ATTR_VALUE_MAP[rulesParamObj[attrName]];
					    attrVal=escapeXmlChars(attrVal);
					    resultStr+=" "+tAttrName+"='"+attrVal+"'";

				    }else
				    {
					    attrVal = rulesParamObj[attrName];
					    attrVal=escapeXmlChars(attrVal);
					    resultStr+=" "+attrName+"='"+attrVal+"'";
				    }

			    }
		    }
		    if(!closed)
			    resultStr+=">";
		    else
			    resultStr+="/>";
		    return resultStr;
	    }

	    function endTag(elementName) {
		    return "</"+ elementName+">";
	    }

	    function escapeXmlChars(str) {
	    if(typeof(str) == "string")
		    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#x27;').replace(/\//g, '&#x2F;');
	    else
		    return str;
	    }

        //XF3 : If selection and reject are present in the same feature, we cannot add the reject in the XML or it will lead to XML parsing issues
	    /*function checkIfSelectionIsPresentInSameFeature(optionId) {
	        var config_features = DictionaryObj.features;
	        for (var itx in config_features) {
	            var cfElem = config_features[itx];
	            var coElem = cfElem['options'];
	            var optionFound = false;

	            if (coElem instanceof Object) {
	                for (var itr in coElem) {
	                    var coid = coElem[itr].ruleId;

	                    if (coid != undefined && coid.toString().trim() == optionId) {
	                        optionFound = true;
	                        break;
	                    }
	                }

	                if (optionFound) {
	                    for (var itr in coElem) {
	                        var coid = coElem[itr].ruleId;

	                        if (coid != undefined) {
	                            for (var it in ConfigCriteriaObj) {
	                                if (ConfigCriteriaObj[it] instanceof Object) {
	                                    var criteriaId = ConfigCriteriaObj[it].Id;
	                                    var state = ConfigCriteriaObj[it].State;

	                                    if (criteriaId == coid && (state == ConfiguratorVariables.Chosen || state == ConfiguratorVariables.Required || state == ConfiguratorVariables.Default || ConfigCriteriaObj[it].State == ConfiguratorVariables.Selected)) {
	                                        return true;
	                                    }
	                                }
	                            }
	                        }
	                    }
	                    break;
	                }
	            }
	        }
	        return false;
	    }*/


	    function checkLevelOfSelectionsInFeature(optionId) {
	        var selectionLevel = 'NoSelection';
	        var config_features = DictionaryObj.features;

	        for (var itx in config_features) {
	            var cfElem = config_features[itx];
	            var coElem = cfElem['options'];
	            var optionFound = false;

	            if (coElem instanceof Object) {
	                for (var itr in coElem) {
	                    var coid = coElem[itr].ruleId;

	                    if (coid != undefined && coid.toString().trim() == optionId) {
	                        optionFound = true;
	                        break;
	                    }
	                }

	                if (optionFound) {
	                    for (var itr in coElem) {
	                        var coid = coElem[itr].ruleId;

	                        if (coid != undefined) {
	                            for (var it in ConfigCriteriaObj) {
	                                if (ConfigCriteriaObj[it] instanceof Object) {
	                                    var criteriaId = ConfigCriteriaObj[it].Id;
	                                    var state = ConfigCriteriaObj[it].State;

	                                    if (criteriaId == coid) {
	                                        if (state == ConfiguratorVariables.Chosen) {
	                                            if (selectionLevel == 'NoSelection' || selectionLevel == 'ruleSelection') {
	                                                selectionLevel = 'userSelection';
	                                            }
	                                            else if (selectionLevel == 'userReject' || selectionLevel == 'userRejectAndRuleSelection') {
	                                                selectionLevel = 'userSelectionAndUserReject';
	                                            }
	                                            else if (selectionLevel == 'ruleReject' || selectionLevel == 'ruleSelectionAndRuleReject') {
	                                                selectionLevel = 'userSelectionAndRuleReject';
	                                            }
	                                        }
	                                        else if (state == ConfiguratorVariables.Required || state == ConfiguratorVariables.Default || state == ConfiguratorVariables.Selected) {
	                                            if (selectionLevel == 'NoSelection') {
	                                                selectionLevel = 'ruleSelection';
	                                            }
	                                            else if (selectionLevel == 'userReject') {
	                                                selectionLevel = 'userRejectAndRuleSelection';
	                                            }
	                                            else if (selectionLevel == 'ruleReject') {
	                                                selectionLevel = 'ruleSelectionAndRuleReject';
	                                            }
	                                        }
	                                        else if (state == ConfiguratorVariables.Dismissed) {
	                                            if (selectionLevel == 'NoSelection' || selectionLevel == 'ruleReject') {
	                                                selectionLevel = 'userReject';
	                                            }
	                                            else if (selectionLevel == 'userSelection' || selectionLevel == 'userSelectionAndRuleReject') {
	                                                selectionLevel = 'userSelectionAndUserReject';
	                                            }
	                                            else if (selectionLevel == 'ruleSelection' || selectionLevel == 'ruleSelectionAndRuleReject') {
	                                                selectionLevel = 'userRejectAndRuleSelection';
	                                            }
	                                        }
	                                        else if (state == ConfiguratorVariables.Incompatible) {
	                                            if (selectionLevel == 'NoSelection') {
	                                                selectionLevel = 'ruleReject';
	                                            }
	                                            else if (selectionLevel == 'userSelection') {
	                                                selectionLevel = 'userSelectionAndRuleReject';
	                                            }
	                                            else if (selectionLevel == 'ruleSelection') {
	                                                selectionLevel = 'ruleSelectionAndRuleReject';
	                                            }
	                                        }
	                                    }
	                                }
	                            }
	                        }
	                    }
	                    break;
	                }
	            }
	        }
	        return selectionLevel;
	    }


        //End XF3

	    function generateFilterXML (){
		    var result = "";
		    result += getXMLDeclaration();
		    result += addAttributes(AppRulesParamObj,XML_FILE_TYPE.TAG1,ATTRNAMES,false);
		    var elementsCnt = jsonXmlElemCount();

	        if (ModelVersionInfoObj != undefined)
		        result += getProdStateXML();

		    if (elementsCnt > 0) {
//		        result += addContext(DictionaryObj.model.label); // Removing optional context because it does not support empty selection (temporary?)
		        //if (EvolutionCriteriaObj != undefined)
		          //  result += getProdStateXML();

		        for (var it in ConfigCriteriaObj) {
		            if (ConfigCriteriaObj[it] instanceof Object) {
		                var criteriaId = ConfigCriteriaObj[it].Id;
		                var state = ConfigCriteriaObj[it].State;

		                /*if (state == ConfiguratorVariables.Chosen || state == ConfiguratorVariables.Required || state == ConfiguratorVariables.Default || ConfigCriteriaObj[it].State == ConfiguratorVariables.Selected) {
		                    result += addFeatureOption(criteriaId, false, state);
		                } else if (state == ConfiguratorVariables.Dismissed || state == ConfiguratorVariables.Incompatible) {
		                    if (!checkIfSelectionIsPresentInSameFeature(criteriaId)) {
		                        result += addFeatureOption(criteriaId, true, state);
		                    }
		                }*/

						if (state == ConfiguratorVariables.Chosen || state == ConfiguratorVariables.Required || state == ConfiguratorVariables.Default || ConfigCriteriaObj[it].State == ConfiguratorVariables.Selected) {
		                        result += addFeatureOption(criteriaId, false, state);
		                } else if (state == ConfiguratorVariables.Dismissed || state == ConfiguratorVariables.Incompatible) {
		                        result += addFeatureOption(criteriaId, true, state);
		                }

		                /*var selectionlevel = checkLevelOfSelectionsInFeature(criteriaId);

		                if (state == ConfiguratorVariables.Chosen || state == ConfiguratorVariables.Required || state == ConfiguratorVariables.Default || ConfigCriteriaObj[it].State == ConfiguratorVariables.Selected) {
		                    if (selectionlevel == 'userSelection' || selectionlevel == 'userSelectionAndUserReject' || selectionlevel == 'userSelectionAndRuleReject' || selectionlevel == 'ruleSelection' || selectionlevel == 'ruleSelectionAndRuleReject' || selectionlevel == 'userRejectAndRuleSelection') {
		                        result += addFeatureOption(criteriaId, false, state);
		                    }
		                } else if (state == ConfiguratorVariables.Dismissed || state == ConfiguratorVariables.Incompatible) {
		                    if (selectionlevel == 'userReject' || selectionlevel == 'ruleReject') {
		                        result += addFeatureOption(criteriaId, true, state);
		                }
		                }*/
		            }
		        }
//		        result += endTag('Context');
		    }

		    var empty = true;

		    for (var prop in listOfRejectedOptionsForEachSingleFeature) {
		        if (listOfRejectedOptionsForEachSingleFeature.hasOwnProperty(prop))
		            empty = false;
		    }

		    if (!empty)
		        result += addListOfRejectedOptionsForSingleFeaturesInTheXML();

			    result += endTag(XML_FILE_TYPE.TAG1);
			    result += endTag(XML_FILE_TYPE.ROOT);
			    return result;

	    }
	    function getProdStateXML()
	    {
	        var prodStateXml = '';

	        if (ModelVersionInfoObj.modelName && ModelVersionInfoObj.modelVersionName && ModelVersionInfoObj.modelVersionRevision) {
	            var prodName = ModelVersionInfoObj.modelVersionName;
	            var prodRevsion = ModelVersionInfoObj.modelVersionRevision;
	            var modelName = ModelVersionInfoObj.modelName;

	            prodStateXml += '<TreeSeries Type="ProductState" Name="' + modelName + '">';
	            prodStateXml += '<Single Name="' + prodName + '" Revision="' + prodRevsion + '" />';
	            prodStateXml += '</TreeSeries>';
	        }

		    return prodStateXml;
	    }

        //XF3
	    function addOptionToTheListOfRejectedOptionsForSingleFeatures(cfid, coName, coDisplayName, optionState) {
	        if (listOfRejectedOptionsForEachSingleFeature[cfid] == undefined)
	            listOfRejectedOptionsForEachSingleFeature[cfid] = [];

	        if (listOfRejectedOptionsStateForEachSingleFeature[cfid] == undefined)
	            listOfRejectedOptionsStateForEachSingleFeature[cfid] = [];

			if (listOfRejectedOptionsDNForEachSingleFeature[cfid] == undefined)
	            listOfRejectedOptionsDNForEachSingleFeature[cfid] = [];


	        listOfRejectedOptionsForEachSingleFeature[cfid].push(coName);
			listOfRejectedOptionsDNForEachSingleFeature[cfid].push(coDisplayName);
	        listOfRejectedOptionsStateForEachSingleFeature[cfid].push(optionState);
	    }


	    function addListOfRejectedOptionsForSingleFeaturesInTheXML(){
	        var resXml='';

	        for (var itr in listOfRejectedOptionsForEachSingleFeature) {

	            var config_features = DictionaryObj.features;
	            for (var itx in config_features) {
	                var cfid = config_features[itx].ruleId;
	                if (cfid != undefined && cfid.toString().trim() == itr) {
	                    var cfName = config_features[itx].name;
											var cfDisplayName = config_features[itx].displayName;
	                    resXml += "<NOT>";
	                    resXml += featureTag(cfName, cfDisplayName, false, false);
	                    for (var i = 0; i < listOfRejectedOptionsForEachSingleFeature[itr].length; i++) {
	                        coName = listOfRejectedOptionsForEachSingleFeature[itr][i];
	                        var coDisplayName = listOfRejectedOptionsDNForEachSingleFeature[itr][i];
	                        optionState = listOfRejectedOptionsStateForEachSingleFeature[itr][i];
	                        resXml += featureTag(coName, coDisplayName, true, true, optionState);
	                    }
	                    resXml += endTag('Feature');
	                    resXml += endTag('NOT');

	                    break;
	                }

	            }

	        }

            return resXml
	    }

        //End XF3

	    function addFeatureOption(criteriaId,isRejected, optionState)
	    {
		    var resXml = "";
		    var config_features = DictionaryObj.features;
		    for (var itx in config_features)
		    {
			    var cfElem = config_features[itx];
			    var cfName = cfElem.name;
					var cfDisplayName = cfElem.displayName;
			    var coElem = cfElem['options'];
			    if(coElem instanceof Object)
			    {
			     for(var itr in coElem)
			     {
				    var coName = coElem[itr].name;
						var coDisplayName = coElem[itr].displayName;
				    if(coName != undefined && coName != null)
				    {
					    var coid = coElem[itr].ruleId;

					    if (coid != undefined && coid.toString().trim() == criteriaId)
					    {
					        if (isRejected) {
					            if (cfElem.selectionType == "Multiple") {       //XF3
					                resXml += "<NOT>";
					                resXml += featureTag(cfName,cfDisplayName, false, false);
					                resXml += featureTag(coName, coDisplayName, true, true, optionState);
					                resXml += endTag('Feature');
					                resXml += endTag('NOT');
					            }                                               //XF3
					            else {                                          //XF3
					                addOptionToTheListOfRejectedOptionsForSingleFeatures(cfElem.ruleId, coName, coDisplayName, optionState);
					                return resXml;                              //XF3
					            }                                               //XF3
						    }else
						    {
							    resXml += featureTag(cfName,cfDisplayName,false, false);
							    resXml += featureTag(coName,coDisplayName,true, true, optionState);
							    resXml += endTag('Feature');
						    }
					    }

				    }

			     }
		      }
	       }

	    return resXml;
	    }


	    function featureTag(elemName, elemDisplayName, closed, addSelectedByAttribut, optionState){
	     var resXml = '';

	     resXml += '<Feature Type="ConfigFeature" Name="' + elemName + '" DisplayName="' + elemDisplayName + '"';
	     if (addSelectedByAttribut && optionState) {

	         if (optionState == ConfiguratorVariables.Default)
                 resXml += ' SelectedBy="Default"';
	         else if (optionState == ConfiguratorVariables.Required || optionState == ConfiguratorVariables.Incompatible)
                 resXml += ' SelectedBy="Rule"';
             else
                 resXml += ' SelectedBy="User"';

	     }

	     if(!closed)
		    resXml+=">";
	     else
		    resXml+="/>";
	     return resXml;
	    }

	    this.json2xml_str =  function (jsonobj){
		    initParamObjects(jsonobj);
		    return generateFilterXML();
	    };

        /*
	    this.parseXml = function(xml) {
	        var dom = null;
	        if (window.DOMParser) {
	            try {
	                dom = (new DOMParser()).parseFromString(xml, "text/xml");
	            }
	            catch (e) { dom = null; }
	        }
	        else if (window.ActiveXObject) {
	            try {
	                dom = new ActiveXObject('Microsoft.XMLDOM');
	                dom.async = false;
	                if (!dom.loadXML(xml)) // parse error ..

	                    window.alert(dom.parseError.reason + dom.parseError.srcText);
	            }
	            catch (e) { dom = null; }
	        }
	        else
	            alert("cannot parse xml string!");
	        return dom;
	    }



        // Changes XML to JSON
	    this.xmlToJson = function(xml) {

	        var js_obj = {};
	        if (xml.nodeType == 1) {
	            if (xml.attributes.length > 0) {
	                js_obj["attributes"] = {};
	                for (var j = 0; j < xml.attributes.length; j++) {
	                    var attribute = xml.attributes.item(j);
	                    js_obj["attributes"][attribute.nodeName] = attribute.value;
	                }
	            }
	        } else if (xml.nodeType == 3) {
	            js_obj = xml.nodeValue;
	        }
	        if (xml.hasChildNodes()) {
	            for (var i = 0; i < xml.childNodes.length; i++) {
	                var item = xml.childNodes.item(i);
	                var nodeName = item.nodeName;
	                if (typeof (js_obj[nodeName]) == "undefined") {
	                    js_obj[nodeName] = setJsonObj(item);
	                } else {
	                    if (typeof (js_obj[nodeName].push) == "undefined") {
	                        var old = js_obj[nodeName];
	                        js_obj[nodeName] = [];
	                        js_obj[nodeName].push(old);
	                    }
	                    js_obj[nodeName].push(setJsonObj(item));
	                }
	            }
	        }
	        return js_obj;
	    }

        // receives XML DOM object, returns converted JSON object
	    var setJsonObj = function (xml) {
	        var js_obj = {};
	        if (xml.nodeType == 1) {
	            if (xml.attributes.length > 0) {
	                js_obj["attributes"] = {};
	                for (var j = 0; j < xml.attributes.length; j++) {
	                    var attribute = xml.attributes.item(j);
	                    js_obj["attributes"][attribute.nodeName] = attribute.value;
	                }
	            }
	        } else if (xml.nodeType == 3) {
	            js_obj = xml.nodeValue;
	        }
	        if (xml.hasChildNodes()) {
	            for (var i = 0; i < xml.childNodes.length; i++) {
	                var item = xml.childNodes.item(i);
	                var nodeName = item.nodeName;
	                if (typeof (js_obj[nodeName]) == "undefined") {
	                    js_obj[nodeName] = setJsonObj(item);
	                } else {
	                    if (typeof (js_obj[nodeName].push) == "undefined") {
	                        var old = js_obj[nodeName];
	                        js_obj[nodeName] = [];
	                        js_obj[nodeName].push(old);
	                    }
	                    js_obj[nodeName].push(setJsonObj(item));
	                }
	            }
	        }
	        return js_obj;
	    }*/
    }



    return UWA.namespace('DS/ConfiguratorPanel/scripts/Models/FilterExpressionXMLServices', FilterExpressionXMLServices);
}
);


define(
		'DS/ConfiguratorPanel/scripts/Models/ConfiguratorModel',
		[
			'UWA/Core',
			'UWA/Controls/Abstract',
			'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
			'DS/ConfiguratorPanel/scripts/Models/FilterExpressionXMLServices',
			'DS/ConfiguratorPanel/scripts/Models/FilterExpressionXMLServicesWithDisplayName',
			'DS/ConfiguratorPanel/scripts/Utilities'
			],
			function (UWA, Abstract, ConfiguratorVariables, FilterExpressionXMLServices, FilterExpressionXMLServicesWithDisplayName, Utilities) {

			'use strict';

			var ConfiguratorModel = Abstract.extend({
				// Members
				_appFunc : {
					multiSelection: ConfiguratorVariables.str_yes,
					selectionMode_Build: ConfiguratorVariables.str_yes,
					selectionMode_Refine:	ConfiguratorVariables.str_yes,
					rulesMode_ProposeOptimizedConfiguration:	ConfiguratorVariables.str_no,
					rulesMode_SelectCompleteConfiguration:	ConfiguratorVariables.str_no,
					rulesMode_EnforceRequiredOptions:	ConfiguratorVariables.str_yes,
					rulesMode_DisableIncompatibleOptions:	ConfiguratorVariables.str_yes
				},

				_appRulesParams : {
					multiSelection: ConfiguratorVariables.str_false,
					selectionMode: ConfiguratorVariables.selectionMode_Build,
					rulesMode: ConfiguratorVariables.RulesMode_EnforceRequiredOptions,
					rulesActivation: ConfiguratorVariables.str_true,
					completenessStatus: ConfiguratorVariables.Unknown,
					rulesCompliancyStatus: ConfiguratorVariables.Unknown
				},

				_dictionaryJson : '',   //contain all datas (features, options, attributs...)
				_configurationCriteria : [],
				_parameterCriteria : [],
				_tempconfigurationCriteria : [],
				_variantVisibilty : [],

				_allVariants :0,
				_mustSelectFeatureNumber : 0,
				_unSelectFeatureNumber : 0,
				_conflictingFeaturesNumber : 0,
				_rulesDeductionFeatureNumber : 0,

				_listOfListOfConflictingImpliedRules : [],
				_listOfRefineSelectionMode : new Object(),
				_listOfListOfConflictingIds : [],
				_defaults : [],
				_rulesConsistency : true,

				_cacheIdWithState : new Object(),
				_cachePreviousCriteria : new Object(),
				_cacheIdWithValue : new Object(),
				_cacheUpdateView : {},
				_cacheUpdateViewOption : {},
				_cacheUIUpdated : {},
				_cacheRuleIdWithName : {},
				_tempcacheIdWithState : new Object(),
				_cacheIdWithPrice : new Object(),
				_cacheValidate : new Object(),
				_totalPrice : '0.0',
				_cacheFeatures: null,
				_cacheOption: null,

				_cacheOptionIdWithFeatureId : new Object(),
				_cacheFeatureIdWithMandStatus : new Object(),
				_cacheFeatureIdWithChosenStatus : new Object(),
				_cacheFeatureIdWithStatus: new Object(),
				_cacheFeatureIdWithRulesStatus :new Object(),
				_cacheFeatureIdWithUserSelection:new Object(),
				_cacheSelectionID:new Object(),
				_modelEvents: null,
				_readOnly: false,
				_isSearchActive : false,
				_enableValidation : false,
				_initialLoadStatus : false,
				_initialLoad:[],
				_BuildModeCriteria: [],
        _modelVersionInfo: {},
				_pcId : "",

				/**
				 * @description
				 * <blockquote>
				 * <p>Initialize the ConfiguratorModel with some options</p>
				 * </blockquote>
				 *
				 * @memberof module:DS/ENOXConfiguratorUX/ConfiguratorPanel#
				 *
				 * @param {Object} options - Available options.
				 * @param {Object} options.appFunc - JSON that shows what is allowed on the panel
				 * @param {Object} options.appRulesParams - JSON to initialize the panel
				 * @param {Object} options.configuration - JSON of a configuration
				 * @param {Object} options.modelEvents
				 *
				 */
				init: function (options) {
					var that = this;

					this._dictionaryJson = '';   //contain all datas (features, options, attributs...)
					this._configurationCriteria = [];
					this._parameterCriteria = [];
					this._tempconfigurationCriteria = [];
					this._variantVisibilty = [];
					this._allConfigCriteria = [];

					this._allVariants =0;
					this._mustSelectFeatureNumber = 0;
					this._unSelectFeatureNumber = 0;
					this._conflictingFeaturesNumber = 0;
					this._rulesDeductionFeatureNumber = 0;

					this._listOfListOfConflictingImpliedRules = [];
					this._listOfRefineSelectionMode = new Object();
					this._listOfListOfConflictingIds = [];
					this._defaults = [];
					this._rulesConsistency = true;

					this._cacheIdWithState = new Object();
					this._cachePreviousCriteria = new Object();
					this._cacheIdWithValue = new Object();
					this._cacheUpdateView = {};
					this._cacheUpdateViewOption = {};
					this._cacheUIUpdated = {};
					this._cacheRuleIdWithName = {};
					this._tempcacheIdWithState = new Object();
					this._cacheIdWithPrice = new Object();
					this._cacheValidate = new Object();
					this._totalPrice = '0.0';
					this._cacheFeatures= null;
					this._cacheOption= null;

					this._cacheOptionIdWithFeatureId = new Object();
					this._cacheFeatureIdWithMandStatus = new Object();
					this._cacheFeatureIdWithChosenStatus = new Object();
					this._cacheFeatureIdWithStatus= new Object();
					this._cacheFeatureIdWithRulesStatus =new Object();
					this._cacheFeatureIdWithUserSelection=new Object();
					this._cacheSelectionID=new Object();
					this._modelEvents= null;
					this._readOnly= false;
					this._isSearchActive = false;
					this._enableValidation = false;
					this._initialLoadStatus = false;
					this._initialLoad=[];
					this._BuildModeCriteria= [];
					this._modelVersionInfo= {};
					this._pcId = "";





					//TODO : initialize appFunc and appRulesParams with the ones given as parameters

					if(options.appFunc) {
						if(options.appFunc.multiSelection)
							this._appFunc.multiSelection = options.appFunc.multiSelection;
						if(options.appFunc.selectionMode_Build)
							this._appFunc.selectionMode_Build = options.appFunc.selectionMode_Build;
						if(options.appFunc.selectionMode_Refine)
							this._appFunc.selectionMode_Refine = options.appFunc.selectionMode_Refine;
						if(options.appFunc.rulesMode_ProposeOptimizedConfiguration)
							this._appFunc.rulesMode_ProposeOptimizedConfiguration = options.appFunc.rulesMode_ProposeOptimizedConfiguration;
						if(options.appFunc.rulesMode_SelectCompleteConfiguration)
							this._appFunc.rulesMode_SelectCompleteConfiguration = options.appFunc.rulesMode_SelectCompleteConfiguration;
						if(options.appFunc.rulesMode_EnforceRequiredOptions)
							this._appFunc.rulesMode_EnforceRequiredOptions = options.appFunc.rulesMode_EnforceRequiredOptions;
						if(options.appFunc.rulesMode_DisableIncompatibleOptions)
							this._appFunc.rulesMode_DisableIncompatibleOptions = options.appFunc.rulesMode_DisableIncompatibleOptions;
					}
					if(options.appRulesParams){
						if(options.appRulesParams.multiSelection)
							this._appRulesParams.multiSelection = options.appRulesParams.multiSelection;
						if(options.appRulesParams.selectionMode)
							this._appRulesParams.selectionMode = options.appRulesParams.selectionMode;
						if(options.appRulesParams.rulesMode)
							this._appRulesParams.rulesMode = options.appRulesParams.rulesMode;
						if(options.appRulesParams.rulesActivation)
							this._appRulesParams.rulesActivation = options.appRulesParams.rulesActivation;
						if(options.appRulesParams.completenessStatus)
							this._appRulesParams.completenessStatus = options.appRulesParams.completenessStatus;
							else{
								this._appRulesParams.completenessStatus = "Partial";
							}
						if(options.appRulesParams.rulesCompliancyStatus)
							this._appRulesParams.rulesCompliancyStatus = options.appRulesParams.rulesCompliancyStatus;
					}
					if (options.modelEvents)
						this._modelEvents = options.modelEvents;
					//this.setAppRulesParam(options.appRulesParams);

					if (options.configuration) {
						//Remove all the KeyIn selections from the configuration...
						for (var t = 0; t < options.configuration.length; t++) {
							if (options.configuration[t].Id && options.configuration[t].Id.indexOf("KeyIn_") !== -1) {
								options.configuration.splice(t, 1);
								t--;
							}
						}

						//...Then, set the ConfigCriteria
						this._parameterCriteria = [];
						this.setConfigurationCriteria(Utilities.convertPersistedStatesToStatesInConfigCriteria(options.configuration));
					}
					if(options.pcId)
						this._pcId = options.pcId;

					this.setValidationFlag(options.enableValidation);

					if(options.readOnly)
						this.setReadOnlyFlag(options.readOnly);
				},

				/**
				 * Getters/Setters
				 *
				 */
				getAppFunc: function() {
					return this._appFunc;
				},

				getMultiSelectionState: function () {
					return this._appRulesParams.multiSelection;
				},
				setMultiSelectionState: function (newState) {	//newState needs to be "true" or "false" strings
					this._appRulesParams.multiSelection = newState;
				},

				getAllConfigCriteria : function () {
					return this.getParameterCriteria().concat(this.getConfigurationCriteria());
				},

				getParameterCriteria: function () {
					return this._parameterCriteria;
				},
				resetCriteria: function () {
					this._cacheIdWithState = {};
					this._cacheIdWithValue = {};
				},
				getConfigurationCriteria: function () {
					return this._configurationCriteria;
				},
				setConfigurationCriteria: function (newConfigCriteria, updateCritriaWithCompare) {
					var _previousCriteria = JSON.parse(JSON.stringify(this._cachePreviousCriteria));
					// var _previousRefineCriteria = JSON.parse(JSON.stringify(this._tempcacheIdWithState));
					this._allConfigCriteria = newConfigCriteria;
					this._configurationCriteria = [];
					this._featureUpdateView = [];
					// this._parameterCriteria = []; //Add it here when solver will handle parameters
					for (var i = 0; i < this._allConfigCriteria.length; i++) {
						if(this._allConfigCriteria[i].State){
							this._cacheIdWithState[this._allConfigCriteria[i].Id] = this._allConfigCriteria[i].State;
							this._configurationCriteria.push(this._allConfigCriteria[i]);
								var updateFlag = false;
								var featureID = this.getFeatureIdWithOptionId(this._allConfigCriteria[i].Id) || this._allConfigCriteria[i].Id;

								if(_previousCriteria && Object.keys(_previousCriteria).length > 0){
									if(this._cacheIdWithState[this._allConfigCriteria[i].Id] !== _previousCriteria[this._allConfigCriteria[i].Id]){
										updateFlag = true;
									}else{
										if(!this.getUIUpdated(this._allConfigCriteria[i].Id)){
											updateFlag = true;
										}
									}
								}else {
									if(this._cacheIdWithState[this._allConfigCriteria[i].Id] !== "Unselected"){
										updateFlag = true;
									}
								}
								this.setUpdateRequiredOption(this._allConfigCriteria[i].Id,updateFlag);
								if(!this.getUpdateRequired(featureID)){
									this.setUpdateRequired(featureID, updateFlag);
								}
						}else if(this._allConfigCriteria[i].Value) {
							this._cacheIdWithValue[this._allConfigCriteria[i].Id] = this._allConfigCriteria[i].Value;
							if(!this._cacheIdWithValue[this._allConfigCriteria[i].Id]){
								this._parameterCriteria.push(this._allConfigCriteria[i]);
						 }
						}
					}
					this._cachePreviousCriteria = this._cacheIdWithState;
				},

				setUIUpdated: function(id, flag){
					this._cacheUIUpdated[id] = flag;
				},
				getUIUpdated: function(id){
					return this._cacheUIUpdated[id];
				},
				setUpdateRequired : function(id, flag){
					this._cacheUpdateView[id] = flag;
				},

				getUpdateRequired : function(id){
					return this._cacheUpdateView[id];
				},
				setUpdateRequiredOption : function(id, flag){
					this._cacheUpdateViewOption[id] = flag;
					if(!flag){
						this.setUIUpdated(id, flag);
					}
				},

				getUpdateRequiredOption : function(id){
					return this._cacheUpdateViewOption[id];
				},
				getPCId : function(){
					return this._pcId;
				},

				getConflictingFeatures: function () {
					return this._listOfListOfConflictingIds;
				},
				isAnOption : function(id) {

					if(this._cacheOption == undefined)
					{
						//populate cache first
						this._cacheOption = new Object();
						var dictionary = this.getDictionary().features;

						for (var i = 0; i < dictionary.length; i++) {
							for (var j = 0; j < dictionary[i].options.length; j++) {
								//if (dictionary[i].options[j].ruleId == id)
								//    return true;
								this._cacheOption[dictionary[i].options[j].ruleId] = true;
							}
						}
					}

					if(this._cacheOption[id] != undefined)
						return true;
					else
						return false;

					//return false;
				},

				isPresent : function(id, array){
					var flag = false;
					if(array && array.length > 0){
						for (var i = 0; i < array.length; i++) {
							if(array[i] === id){
								flag = true; break;
							}
						}
					}
					return flag;
				},

				setConflictingFeatures: function (conflictingFeatures) {
					var _uniqueListOfConflictingIds = [];
					this._listOfListOfConflictingIds = conflictingFeatures;

					var numConflictingFeatures = 0;
					if(this._listOfListOfConflictingIds && this._listOfListOfConflictingIds.length != 0)
					{
						for(var i=0; i< this._listOfListOfConflictingIds.length; i++)
						{
							//pci3 - commented below line for IR-613091 and added loop
							// numConflictingFeatures += this._listOfListOfConflictingIds[i].length;
							for (var j = 0; j < this._listOfListOfConflictingIds[i].length; j++) {
								if(!this.isPresent(this._listOfListOfConflictingIds[i][j], _uniqueListOfConflictingIds)){
									_uniqueListOfConflictingIds.push(this._listOfListOfConflictingIds[i][j]);
									numConflictingFeatures++;
								}
							}
						}
					}
					this.setNumberOfConflictingFeatures(numConflictingFeatures);
				},
				isConflictingOption: function(optionId)
				{
					if(!this._listOfListOfConflictingIds) return false;
					var numLists = this._listOfListOfConflictingIds.length;
					for(var i=0; i< numLists; i++)
					{
						if (this._listOfListOfConflictingIds[i].indexOf(optionId) != -1)
							return true;
					}
					return false;

				},
				getImpliedRules: function () {
					return this._listOfListOfConflictingImpliedRules;
				},

				setImpliedRules: function (impliedRules) {
					this._listOfListOfConflictingImpliedRules = impliedRules;
				},
				getRulesConsistency: function () {
					return this._rulesConsistency;
				},
				setRulesConsistency: function (newRulesConsistency) {
					this._rulesConsistency = newRulesConsistency;
				},

				getSelectionMode: function () {
					return this._appRulesParams.selectionMode;
				},
				setSelectionMode: function (newMode) {
					this._appRulesParams.selectionMode = newMode;

					if (this.getCompletenessStatus() == ConfiguratorVariables.Hybrid && this._appRulesParams.selectionMode == ConfiguratorVariables.selectionMode_Build)
						this.setCompletenessStatus(ConfiguratorVariables.Partial);
					else
						if (this.getCompletenessStatus() == ConfiguratorVariables.Partial && this._appRulesParams.selectionMode == ConfiguratorVariables.selectionMode_Refine)
							this.setCompletenessStatus(ConfiguratorVariables.Hybrid);


					this._modelEvents.publish( {
						event:	'ComputeConfigExpression'
					});
				},

				getRulesMode: function () {
					return this._appRulesParams.rulesMode;
				},
				setRulesMode: function (newMode) {
					this._appRulesParams.rulesMode = newMode;
				},

				getRulesActivation: function () {
					return this._appRulesParams.rulesActivation;
				},
				setRulesActivation: function (newMode) {
					if (newMode == ConfiguratorVariables.str_false) {

						for (var i = 0; i < this._configurationCriteria.length; i++) {
							if(this._configurationCriteria[i].State != ConfiguratorVariables.Chosen && this._configurationCriteria[i].State != ConfiguratorVariables.Unselected)
								this._configurationCriteria[i].State = ConfiguratorVariables.Unselected;
							this._cacheIdWithState[this._configurationCriteria[i].Id] = this._configurationCriteria[i].State;
						}
					}
					this._appRulesParams.rulesActivation = newMode;
				},

				getCompletenessStatus: function () {
					return this._appRulesParams.completenessStatus;
				},
				setCompletenessStatus: function (newStatus) {
					this._appRulesParams.completenessStatus = newStatus;

					this._modelEvents.publish( {
						event:	'OnCompletenessStatusChange',
						data:	{value : newStatus}
					});
				},
				setFeatureIdWithMandStatus: function(id, status)
				{
					this._cacheFeatureIdWithMandStatus[id] = status;
				},
				getFeatureIdWithMandStatus: function(id)
				{
					return this._cacheFeatureIdWithMandStatus[id];
				},

				setFeatureIdWithChosenStatus: function(id, status){
					this._cacheFeatureIdWithChosenStatus[id] = status;
				},
				getFeatureIdWithChosenStatus: function(id){
					return this._cacheFeatureIdWithChosenStatus[id];
				},

				getRulesCompliancyStatus: function () {
					return this._appRulesParams.rulesCompliancyStatus;
				},
				setRulesCompliancyStatus: function (newStatus) {
					this._appRulesParams.rulesCompliancyStatus = newStatus;
				},

				getDictionary: function () {
					return this._dictionaryJson;
				},
				setDictionary: function (newDictionary) {
					if(newDictionary){
						if(newDictionary._version === "3.0"){
							this._dictionaryJson = this._getCompatibleDicoInV1(newDictionary);
						}else{
					this._dictionaryJson = newDictionary;
						}
						this._dictionaryJson._version = "1.0";
					var Features = this._dictionaryJson.features;

					for (var i = 0; i < Features.length; i++) {
						this._cacheOptionIdWithFeatureId[Features[i].ruleId] = Features[i].ruleId;

						//to check if needed or not
						if (this.getSelectionMode() == ConfiguratorVariables.selectionMode_Build)
							this.setRefineSelectionModeForSpecifiedFeature(Features[i].ruleId, ConfiguratorVariables.select);
						else if (this.getSelectionMode() == ConfiguratorVariables.selectionMode_Refine)
							this.setRefineSelectionModeForSpecifiedFeature(Features[i].ruleId, ConfiguratorVariables.reject);

						for (var j = 0; j < Features[i].options.length; j++) {
							this._cacheOptionIdWithFeatureId[Features[i].options[j].ruleId] = Features[i].ruleId;
						}
					}
					}
				},

				_getCompatibleDicoInV1 : function(dictionary){
					var newDictionary = {};
					var features = [];
					var dico_inside = (dictionary.portfolioClasses) ? dictionary.portfolioClasses.member[0].portfolioComponents.member[0] : [];
					this._modelID = dico_inside.id;
	        var flatVariants = (dico_inside.variants && dico_inside.variants.member) ? dico_inside.variants.member : [];
	        var flatVGs = (dico_inside.variabilityGroups && dico_inside.variabilityGroups.member) ? dico_inside.variabilityGroups.member : [];
					var flatParamaters = (dico_inside.parameters && dico_inside.parameters.member) ? dico_inside.parameters.member : [];
					var flatRules = (dico_inside.rules && dico_inside.rules.member) ? dico_inside.rules.member : [];

					for (var i = 0; i < flatVariants.length; i++) {
							this.addMinifiedVariantAndValueInRes(features, flatVariants[i], "Single");
					}
					for (var i = 0; i < flatVGs.length; i++) {
							this.addMinifiedVGInRes(features, flatVGs[i], "Multiple");
					}
					for (var i = 0; i < flatParamaters.length; i++) {
							this.addMinifiedParametersInRes(features, flatParamaters[i]);
					}
					for (var i = 0; i < flatRules.length; i++) {
						this._cacheRuleIdWithName[flatRules[i].id] = flatRules[i].attributes._name || "";
					}
					newDictionary.features = features;
					return newDictionary;
				},

				getRuleDisplayNameWithId : function(id){
					return this._cacheRuleIdWithName[id];
				},

				addMinifiedParametersInRes : function(features, parameter){
					if(parameter.kind === "instance"){
						var feature = {};
						feature.ruleId = parameter.id;  //variant.lid;
						feature.sequenceNumber = parameter.attributes._sequenceNumber ? parameter.attributes._sequenceNumber : 1;
						feature.options = [];
						feature.displayName =  parameter.attributes._name || "";
						feature.name =  parameter.attributes._name || "";
						feature.selectionCriteria = parameter.attributes._mandatory || "false";
						feature.selectionType = "Parameter";
						feature.type = "Parameter";
						feature.image = parameter.attributes._image || "";

						//FD02
						feature.minValue = parameter.attributes._minValue ? parameter.attributes._minValue.inputvalue : 0;
						feature.minUnit = parameter.attributes._minValue ? parameter.attributes._minValue.inputunit : "";
						feature.maxValue = parameter.attributes._maxValue ? parameter.attributes._maxValue.inputvalue : 0;
						feature.maxUnit = parameter.attributes._maxValue? parameter.attributes._maxValue.inputunit : "";

						//FD03
						if(feature.minUnit !== feature.maxUnit){
							feature.minValue = parameter.attributes._minValue ? parameter.attributes._minValue.dbvalue : 0;
							feature.minUnit = parameter.attributes._minValue ? parameter.attributes._minValue.dbunit : "";
							feature.maxValue = parameter.attributes._maxValue ? parameter.attributes._maxValue.dbvalue : 0;
							feature.maxUnit = parameter.attributes._maxValue? parameter.attributes._maxValue.dbunit : "";
						}

						feature.stepValue = parameter.attributes._step ? parameter.attributes._step.inputvalue : 1;
						feature.unit = parameter.attributes._unit || feature.minUnit || "";

						feature.defaultValue = parameter.attributes._defaultValue ? parameter.attributes._defaultValue.inputvalue : undefined;
						feature.defaultUnit = parameter.attributes._defaultValue ? parameter.attributes._defaultValue.inputunit : "";

						features.push(feature);
					}
				},

				addMinifiedVariantAndValueInRes : function(features, variant, defaultSelectionType){
					if(variant.kind === "instance"){
						var feature = {};
						// feature.ruleId = variant.id;  //variant.lid;
						feature.ruleId = variant.idref;  // physical id of variant
						feature.sequenceNumber = variant.attributes._sequenceNumber ? variant.attributes._sequenceNumber : 1;
						feature.options = [];
						feature.displayName =  variant.attributes._name || "";
						feature.name =  variant.attributes._name || "";
						feature.selectionCriteria = variant.attributes._mandatory || "false";
						feature.type = "Variant";
						feature.selectionType = variant.attributes._selectionType || defaultSelectionType;
						feature.image = variant.attributes._image || "";

						var values = variant.values.member;
						for (var i = 0; i < values.length; i += 1) {
									var option = {};
									// option.ruleId = values[i].id; //values[j].rel_lid;
									option.ruleId = values[i].idref;
									// option.ruleId = values[i].rel_lid;
									option.displayName = values[i].attributes._name ? values[i].attributes._name : "";
									option.name = values[i].attributes._name ? values[i].attributes._name : "";
									option.sequenceNumber = values[i].attributes._sequenceNumber ? values[i].attributes._sequenceNumber : 1;
									option.image = values[i].attributes._image ? values[i].attributes._image : "";
									option.selectionCriteria = values[i].attributes._mandatory ? values[i].attributes._mandatory : "false";
									option.type = "Value";
									feature.optionPhysicalIds = [];
									for (var j = 0; j < values.length; j += 1) {
										// feature.optionPhysicalIds.push(values[j].id);
										feature.optionPhysicalIds.push(values[j].idref);
										// feature.optionPhysicalIds.push(values[j].rel_lid);
									}
									feature.options.push(option);
							}
						features.push(feature);
					}
				},

				addMinifiedVGInRes : function(features, variant, defaultSelectionType){
						var feature = {};
						feature.ruleId = variant.id;
						// feature.ruleId = variant.lid;
						feature.sequenceNumber = variant.attributes._sequenceNumber ? variant.attributes._sequenceNumber : 1;
						feature.options = [];
						feature.displayName =  variant.attributes._name || "";
						feature.name =  variant.attributes._name || "";
						feature.selectionCriteria = variant.attributes._mandatory || "false";
						feature.type = "VariabilityGroup";
						feature.selectionType = variant.attributes._selectionType || defaultSelectionType;
						feature.image = variant.attributes._image || "";

						var values = variant.options.member ;
						for (var i = 0; i < values.length; i += 1) {
								if(values[i].kind === "instance"){
									var option = {};
									// option.ruleId = values[i].id;
									option.ruleId = values[i].idref;
									// option.ruleId = values[i].rel_lid;
									option.displayName = values[i].attributes._name ? values[i].attributes._name : "";
									option.name = values[i].attributes._name ? values[i].attributes._name : "";
									option.sequenceNumber = values[i].attributes._sequenceNumber ? values[i].attributes._sequenceNumber : 1;
									option.image = values[i].attributes._image ? values[i].attributes._image : "";
									option.selectionCriteria = values[i].attributes._mandatory ? values[i].attributes._mandatory : "false";
									option.type = "Option";
									feature.optionPhysicalIds = [];
									for (var j = 0; j < values.length; j += 1) {
										if(values[j].kind === "instance"){
											// feature.optionPhysicalIds.push(values[j].id);
											feature.optionPhysicalIds.push(values[j].idref);
											// feature.optionPhysicalIds.push(values[j].rel_lid);
										}
									}
									feature.options.push(option);
								}
							}
							features.push(feature);
				},

				setReadOnlyFlag: function (booleanValue) {
					if (booleanValue == true)
						this._readOnly = true;
					else if (booleanValue == false)
						this._readOnly = false;
				},

				getReadOnlyFlag : function() {
					return this._readOnly;
				},

				setAppRulesParam : function (newAppRulesParam) {
					this._appRulesParams = newAppRulesParam;

					if (this._appRulesParams.selectionMode == ConfiguratorVariables.selectionMode_Build)
						this.setRefineSelectionModeForAllFeatures(ConfiguratorVariables.select);
					if (this._appRulesParams.selectionMode == ConfiguratorVariables.selectionMode_Refine)
						this.setRefineSelectionModeForAllFeatures(ConfiguratorVariables.reject);
				},

				getAppRulesParam : function () { return this._appRulesParams; },

				getFeatureIdWithOptionId : function (Id) { return this._cacheOptionIdWithFeatureId[Id]; },
				getCacheOptionsIdWithFeatureId : function () { return this._cacheOptionIdWithFeatureId; },

				setRefineSelectionModeForSpecifiedFeature : function (id, newMode) { this._listOfRefineSelectionMode[id] = newMode; },
				getRefineSelectionModeForSpecifiedFeature : function (id) { return this._listOfRefineSelectionMode[id]; },

				setRefineSelectionModeForAllFeatures : function (newMode) {
					for (var key in this._listOfRefineSelectionMode)
						this._listOfRefineSelectionMode[key] = newMode;
				},
				/**********************************************************************/
				/*function to update the state of options (available, chosen,
				required...)                                                          */
				/**********************************************************************/
				getStateWithId : function (Id) {
					/*for (var i = 0; i < this._configurationCriteriaInJson.length; i++) {
					if (this._configurationCriteriaInJson[i].Id == Id)
                    return this._configurationCriteriaInJson[i].State;
				}*/

					return this._cacheIdWithState[Id];
				},

				setStateWithId : function (Id, NewState) {
					this._cachePreviousCriteria = JSON.parse(JSON.stringify(this._cacheIdWithState));
					if (NewState == ConfiguratorVariables.Range)
						return 0;

					var set = false;
					for (var i = 0; i < this._configurationCriteria.length; i++) {
						if (this._configurationCriteria[i].Id == Id) {

							this._configurationCriteria[i].State = NewState;
							set = true;
							break;
						}
					}
					if (!set) {
						this._configurationCriteria.push({ Id: Id, State: NewState });
					}

					this._cacheIdWithState[Id] = NewState;

				},

				getValueWithId : function (Id) {
					return this._cacheIdWithValue[Id];
				},

				setValueWithId : function (Id, value) {
					var set = false;
					for (var i = 0; i < this._parameterCriteria.length; i++) {
						if (this._parameterCriteria[i].Id == Id) {
							this._parameterCriteria[i].Value = value;
							set = true;
							break;
						}
					}
					if (!set) {
						this._parameterCriteria.push({ Id: Id, Value: value });
					}
					this._cacheIdWithValue[Id] = value;
				},


				getNumberOfMandFeaturesNotValuated: function () {
					return this._mustSelectFeatureNumber;
				},
				setNumberOfMandFeaturesNotValuated: function (newValue) {
				    var oldValue = this._mustSelectFeatureNumber;
				    this._mustSelectFeatureNumber = newValue;

				    //Event for old ConfiguratorPanel component (the one integrated in PSE)
				    this._modelEvents.publish({
				        event: 'OnMandFeatureNumberChange',
				        data: { value: newValue }
				    });

				    //Event for new ConfigEditor component
				    this._modelEvents.publish({
				        event: 'OnMandVariantNumberChange',
				        data: { value: newValue }
				    });

				    //for now only Partial and Complete events thrown
					/*if(!FirstTime)
					{
						if(newValue == 0) {
							this.setCompletenessStatus(ConfiguratorVariables.Complete);

						} else //if(oldValue == 0)
						{
							if (this._appRulesParams.selectionMode == ConfiguratorVariables.selectionMode_Build)
								this.setCompletenessStatus(ConfiguratorVariables.Partial);
							else
								this.setCompletenessStatus(ConfiguratorVariables.Hybrid);
						}
					}*/

					 this.setCompletenessStatus(this.CalculateCompletenessStatus());
				},

				CalculateCompletenessStatus : function () {
					var features = this._dictionaryJson.features;
					var mustNotValuated = 0;
					var hybrid = false;
					var cacheFeaturesIdWithSelections = new Object();
					var cacheFeatureTypes = new Object();
					var cacheConfigCriteria = new Object();

					for (var i = 0; i < this._configurationCriteria.length; i++) {

						//Create a cache of the configCriteria
						//	{ IDcriteria : State, ...}

						cacheConfigCriteria[this._configurationCriteria[i].Id] = this._configurationCriteria[i].State;
					}

					for (var i = 0; i < features.length; i++) {

					    if (features[i].selectionCriteria === "Must" || this.getFeatureIdWithMandStatus(features[i].ruleId)) {  //Only consider the Must features

					        //Cache for the Features type :
					        // {
					        //  IDFeature: "Single"/"Multiple", ...
					        // }
					        cacheFeatureTypes[features[i].ruleId] = features[i].selectionType;

					        //One for the Features Selections/rejections number :
					        // {
					        //  IDFeature: {SelectionsNb:0,  UserRejectNb:0}, ...
					        // }
					        cacheFeaturesIdWithSelections[features[i].ruleId] = {
					            SelectionsNb: 0,
					            UserRejectNb: 0
					        };

					        for (var j = 0; j < features[i].options.length; j++) {
					            if (cacheConfigCriteria[features[i].options[j].ruleId] == ConfiguratorVariables.Chosen || cacheConfigCriteria[features[i].options[j].ruleId] == ConfiguratorVariables.Default || cacheConfigCriteria[features[i].options[j].ruleId] == ConfiguratorVariables.Required || cacheConfigCriteria[features[i].options[j].ruleId] == ConfiguratorVariables.Selected) {
					                cacheFeaturesIdWithSelections[features[i].ruleId].SelectionsNb++;
					            }
					            else if (cacheConfigCriteria[features[i].options[j].ruleId] == ConfiguratorVariables.Dismissed) {
					                cacheFeaturesIdWithSelections[features[i].ruleId].UserRejectNb++;
					            }
					        }

					        //If we are on refine, consider the available states as included. Then, we need to count them as selections
					        if (this._appRulesParams.selectionMode == ConfiguratorVariables.selectionMode_Refine && cacheFeaturesIdWithSelections[features[i].ruleId].SelectionsNb == 0) {
					            cacheFeaturesIdWithSelections[features[i].ruleId].SelectionsNb = features[i].options.length - cacheFeaturesIdWithSelections[features[i].ruleId].UserRejectNb;
					        }
					    }

					}

					for (var feature in cacheFeaturesIdWithSelections) {
						if (!hybrid && cacheFeaturesIdWithSelections[feature].SelectionsNb > 1 && cacheFeatureTypes[feature] == "Single") {
							hybrid = true;
						}
						if (cacheFeaturesIdWithSelections[feature].SelectionsNb == 0 /*&& cacheFeaturesIdWithSelections[feature].UserRejectNb == 0*/) {
							mustNotValuated++;
						}
					}

					if(mustNotValuated == 0) {
						if (!hybrid)
							return ConfiguratorVariables.Complete;
						else
							return ConfiguratorVariables.Hybrid;
					}
					else {
						if (hybrid)
							return ConfiguratorVariables.Hybrid;
						else
							return ConfiguratorVariables.Partial;

					}
				},

				getNumberOfConflictingFeatures: function () {
					return this._conflictingFeaturesNumber;
				},
				setNumberOfConflictingFeatures: function (newValue) {
					this._conflictingFeaturesNumber = newValue;

				    //Event for old ConfiguratorPanel component (the one integrated in PSE)
					this._modelEvents.publish({
					    event: 'OnConflictFeatureNumberChange',
					    data: { value: newValue }
					});

				    //Event for new ConfigEditor component

					this._modelEvents.publish( {
						event:	'OnConflictVariantNumberChange',
						data:	{value : newValue}
					});
				},

				getNumberOfFeaturesChosen: function () {
					return this._chosenFeaturesNumber;
				},
				setNumberOfFeaturesChosen: function (newValue) {
					this._chosenFeaturesNumber = newValue;
					this._modelEvents.publish({
					    event: 'OnChosenVariantNumberChange',
					    data: { value: newValue }
					});
				},

				getFeatureDisplayNameWithId : function(id) {
					var features = this.getDictionary().features;

					for (var i = 0; i < features.length; i++) {
						if (features[i].ruleId == id)
							return features[i].displayName;
						for (var j = 0; j < features[i].options.length; j++) {
							if (features[i].options[j].ruleId == id)
								return features[i].displayName;
						}
					}

					return;
				},

				getOptionDisplayNameWithId : function(id) {
					var features = this.getDictionary().features;

					for (var i = 0; i < features.length; i++) {
						for (var j = 0; j < features[i].options.length; j++) {
							if (features[i].options[j].ruleId == id)
								return features[i].options[j].displayName;
						}
					}

					return;
				},

				getXMLExpression : function(){

					var jsTranObj = new FilterExpressionXMLServices('FilterExpression');

					var json = {
							"configurationCriteria": this.getConfigurationCriteria(),
							"dictionary": this.getDictionary(),
							"app_RulesParam": this.getAppRulesParam(),
							"app_Func": this.getAppFunc(),
					        //"evolutionCriteria":this.getEvolutionCriteria()
                            "modelVersionInfo": this.getModelVersionInfo()
					};

					var xml = jsTranObj.json2xml_str(json);

					return xml;
				},

				getXMLExpressionWithDisplayName : function(){

					var jsTranObj = new FilterExpressionXMLServicesWithDisplayName('FilterExpression');

					var json = {
							"configurationCriteria": this.getConfigurationCriteria(),
							"dictionary": this.getDictionary(),
							"app_RulesParam": this.getAppRulesParam(),
							"app_Func": this.getAppFunc(),
					        //"evolutionCriteria":this.getEvolutionCriteria()
              "modelVersionInfo": this.getModelVersionInfo()
					};

					var xml = jsTranObj.json2xml_str(json);

					return xml;
				},

			    /*** Added newly **/

				getModelVersionInfo : function() {
				    return this._modelVersionInfo;
				},

				setModelVersionInfo: function (newModelVersionInfo) {
				    //newModelVersionInfo should contain following entries:
				    //  modelName
				    //  modelVersionName
				    //  modelVersionRevision
                    //It is used to add the modelVersion informations in the XML (filter expression XML that is used for 3DRendering and for PC save)
				    this._modelVersionInfo = newModelVersionInfo;
				},

				setCurrentFilter : function(value){
					this._currentFilter = value;
				},
				getCurrentFilter : function(){
					return this._currentFilter;
				},

				setFeatureIdWithStatus: function(id, status)
				{
					this._cacheFeatureIdWithStatus[id] = status;
				},
				getFeatureIdWithStatus: function(id)
				{
					return this._cacheFeatureIdWithStatus[id];
				},

				getNumberOfFeaturesNotValuated: function () {
					return this._unSelectFeatureNumber;
				},
				setNumberOfFeaturesNotValuated: function (newValue) {
					var oldValue = this._unSelectFeatureNumber;
					this._unSelectFeatureNumber = newValue;

					this._modelEvents.publish( {
						event:	'OnUnselectedVariantNumberChange',
						data:	{value : newValue}
					});
				},

				setFeatureIdWithRulesStatus: function(id, status)
				{
					this._cacheFeatureIdWithRulesStatus[id] = status;
				},
				getFeatureIdWithRulesStatus: function(id)
				{
					return this._cacheFeatureIdWithRulesStatus[id];
				},

				setFeatureIdWithUserSelection: function(id, status)
				{
					this._cacheFeatureIdWithUserSelection[id] = status;
				},
				getFeatureIdWithUserSelection: function(id)
				{
					return this._cacheFeatureIdWithUserSelection[id];
				},




				getNumberOfFeaturesByRules: function () {
					return this._rulesDeductionFeatureNumber;
				},
				setNumberOfFeaturesByRules: function (newValue) {
					var oldValue = this._rulesDeductionFeatureNumber;
					this._rulesDeductionFeatureNumber = newValue;

					this._modelEvents.publish( {
						event:	'OnRuleNotValidatedNumberChange',
						data:	{value : newValue}
					});
				},

				setSearchStatus: function(value){
					this._isSearchActive = value;
				},
				getSearchStatus : function(){
					return this._isSearchActive;
				},

				setVariantVisibility : function(id,value){
					this._variantVisibilty[id] = value;
				},
				getVariantVisibility : function(id){
					return this._variantVisibilty[id];
				},

				setCurrentSearchData: function(data){
					this._data = data;
				},
				getCurrentSearchData : function(){
					return this._data
				},

				setIncludedState : function(Id, NewState){
					if (NewState == ConfiguratorVariables.Range)
						return 0;
					this._tempcacheIdWithState[Id] = NewState;
				},

				getIncludedState : function (Id) {
					return this._tempcacheIdWithState[Id];
				},

				setInitialLoadStatus:function(data){
					this._initialLoadStatus = data;
				},

				getInitialLoadStatus:function(){
					return this._initialLoadStatus;
				},

				setLoading:function(id,data){
					this._initialLoad[id] = data;
				},

				getLoading:function(id){
					return this._initialLoad[id];
				},

				setCriteriaBuildMode:function(newConfigCriteria){
					this._BuildModeCriteria = newConfigCriteria;
				},

				getCriteriaBuildMode:function(){
					return this._BuildModeCriteria;
				},

				getVariants : function(){
					return this._allVariants
				},

				setVariants : function(count){
					this._allVariants = count ? count  : 0;
					this._modelEvents.publish({ event: "OnAllVariantNumberChange", data:{value : this._allVariants}});
				},

				setUserSelectVariantIDs : function(id, flag){
					var flag1 = UWA.typeOf(flag) === "boolean" ? flag : false;
					this._cacheSelectionID[id] = flag1;
				},

				getUserSelectVariantIDs : function(id){
					return this._cacheSelectionID[id];
				},

				setValidateVariant : function(id, flag){
					var flag1 = UWA.typeOf(flag) === "boolean" ? flag : false;
					this._cacheValidate[id] = flag1;
				},

				getValidateVariant : function(id, flag){
					return this._cacheValidate[id];
				},

				isValidationEnabled : function () {
					return this._enableValidation;
				},

				setValidationFlag : function(flag){
					this._enableValidation = flag ? flag : false;
				},

				setDefaultCriteria : function(data){
					this._defaults = data;
				},
				getDefaultCriteria : function(data){
					return this._defaults;
				}

			});


			return ConfiguratorModel;
		});


define('DS/ConfiguratorPanel/scripts/Presenters/VariantComponentPresenter',[
	'UWA/Core',
	'DS/ConfiguratorPanel/scripts/ConfiguratorSolverFunctionsV2',
	'DS/Handlebars/Handlebars',
	'DS/WebappsUtils/WebappsUtils',
	'DS/UIKIT/Tooltip',
	'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
	'DS/ResizeSensor/js/ResizeSensor',
	'DS/ConfiguratorPanel/scripts/Presenters/SingleValueAutocompletePresenter',
	'DS/ConfiguratorPanel/scripts/Presenters/MultipleValueAutocompletePresenter',
	'DS/ConfiguratorPanel/scripts/Presenters/ParameterPresenter',
	'DS/ConfiguratorPanel/scripts/Utilities',
	'i18n!DS/xDimensionManager/assets/nls/xUnitLabelLong.json',
	'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json',
	'text!DS/ConfiguratorPanel/html/VariantComponentPresenter.html',
	"css!DS/ConfiguratorPanel/css/VariantComponentPresenter.css",
	'css!DS/UIKIT/UIKIT.css',
	],
	function (UWA, ConfiguratorSolverFunctionsV2, Handlebars, WebappsUtils, Tooltip, ConfiguratorVariables, ResizeSensor, SingleValueAutocompletePresenter, MultipleValueAutocompletePresenter,ParameterPresenter, Utilities,xUnitLabelLong, nlsConfiguratorKeys, html_VariantComponentPresenter) {

	'use strict';

	var template = Handlebars.compile(html_VariantComponentPresenter);

	var listAutcompletePresenters = [];

	var VariantComponentPresenter = function (options) {
		this._init(options);
	};

	VariantComponentPresenter.prototype._init = function(options){
		var _options = options ? UWA.clone(options, false) : {};
		UWA.merge(this, _options);
		this.variantId = this.variant.ruleId;
		if(this.variant.unit)
			this.variant.nlsUnit = xUnitLabelLong[this.variant.unit];
		this.image = this.variant.image ? this.variant.image : ConfiguratorSolverFunctionsV2.getDefaultImage();

		this._subscribeToEvents();
		this._initDivs();
		this.inject(_options.parentContainer);
		this._getAutocomplete();
	};

	VariantComponentPresenter.prototype.getDefaultImage = function() {
			return WebappsUtils.getWebappsAssetUrl("ENOXConfiguratorUX", "icons/iconLargeDefault.png");
	};

	VariantComponentPresenter.prototype._initDivs = function () {
		this._container = document.createElement('div');
		this._container.innerHTML = template(this);

		this._container = this._container.querySelector('#divFeature' + this.variant.ruleId);
		this._autocompleteContainer = this._container.querySelector('#autocompleteContainer_' + this.variant.ruleId);
		this._imageContainer = this._container.querySelector('.variantImgContainer');
		this._contentContainer = this._container.querySelector('.contentContainer');
		this._iconGapContainer = this._container.querySelector('.iconGapContainer');
		this._rulesIcon = this._container.querySelector('#rulesIcon_' + this.variant.ruleId);

		this.mandIcon = this._container.querySelector('variantRightIcon_' + this.variant.ruleId);
		this.refinedIcon = this._container.querySelector('variantRefinedIcon_' + this.variant.ruleId);
		UWA.extendElement(this.mandIcon);
		UWA.extendElement(this.refinedIcon);
	};

	VariantComponentPresenter.prototype._subscribeToEvents = function () {
		var that = this;
		/** Since this is independent of solver calls, it can be subscribed here. **/
		this.modelEvents.subscribe({event: 'OnConfigurationModeChange'}, function (data) {
			var enable = data.mode === ConfiguratorVariables.selectionMode_Refine ? true : false;
			that.autocompletePresenter.refineView(enable);
		});

		this.modelEvents.subscribe({event: 'OnAllVariantFilterIconClick'}, function (data) {
			// var includeValriant = that.configModel.getStateWithId(that.variant.ruleId) === "Incompatible" ? false : true;
			var includeValriant = true;
			if(that.configModel.getStateWithId(that.variant.ruleId)=== "Incompatible"){
				if(!that.configModel.getUserSelectVariantIDs(that.variant.ruleId))
					includeValriant = false;
			}
			that._setVisibility(includeValriant);
		});

		this.modelEvents.subscribe({event: 'onMandVariantIconClick'}, function (data) {
			var isMand = that.configModel.getFeatureIdWithMandStatus(that.variant.ruleId), flag;
			// var includeValriant = that.configModel.getStateWithId(that.variant.ruleId) === "Incompatible" ? false : isMand;
			var includeValriant = true;
			if(that.configModel.getStateWithId(that.variant.ruleId)=== "Incompatible"){
				if(!that.configModel.getUserSelectVariantIDs(that.variant.ruleId))
					includeValriant = false;
			}else{
				includeValriant = isMand;
			}
			if(includeValriant === true && data.activated === "updateAddition"){flag=true;}
			if(includeValriant === false && data.activated === "updateAddition"){} // case when auto updates removes variant
			else that._setVisibility(includeValriant,flag);
		});

		this.modelEvents.subscribe({event: 'OnUnselectedVariantIconClick'}, function (data) {
			var isSelcted = that.configModel.getFeatureIdWithStatus(that.variant.ruleId),flag;
			// var includeValriant = that.configModel.getStateWithId(that.variant.ruleId) === "Incompatible" ? false : !isSelcted;
			var includeValriant = true;
			if(that.variant.selectionType === "Parameter"){
				if(that.configModel.getValueWithId(that.variant.ruleId)){
					includeValriant = false;
				}
			}else{
			if(that.configModel.getStateWithId(that.variant.ruleId)=== "Incompatible"){
				if(!that.configModel.getUserSelectVariantIDs(that.variant.ruleId))
					includeValriant = false;
			}else{
				includeValriant = !isSelcted;
			}
			}

			if(includeValriant === true && data.activated === "updateAddition"){flag=true;}
			if(includeValriant === false && data.activated === "updateAddition"){} // case when auto updates removes variant
			else that._setVisibility(includeValriant,flag);
		});

		this.modelEvents.subscribe({event: 'OnRuleNotValidatedIconClick'}, function (data) {
			var isSelcted = that.configModel.getFeatureIdWithRulesStatus(that.variant.ruleId),flag, includeValriant = true;
			if(that.variant.selectionType === "Parameter"){
				includeValriant = false;
			}else{
				if(that.configModel.getStateWithId(that.variant.ruleId)=== "Incompatible"){
					if(!that.configModel.getUserSelectVariantIDs(that.variant.ruleId))
						includeValriant = false;
				}else{
					includeValriant = isSelcted;
				}
			}
				if(includeValriant === true && data.activated === "updateAddition"){flag=true;}
				if(includeValriant === false && data.activated === "updateAddition"){} // case when auto updates removes variant
				else that._setVisibility(includeValriant,flag);
		});

		this.modelEvents.subscribe({event: 'onChosenVariantIconClick'}, function (data) {
			var isChosen = that.configModel.getFeatureIdWithChosenStatus(that.variant.ruleId),flag;
			var includeValriant = isChosen;
			if(that.variant.selectionType === "Parameter"){
				if(that.configModel.getValueWithId(that.variant.ruleId)){
					includeValriant = true;
				}
			}else{
			if(that.configModel.getStateWithId(that.variant.ruleId)=== "Incompatible"){
				if(!that.configModel.getUserSelectVariantIDs(that.variant.ruleId))
					includeValriant = false;
			}}

			if(includeValriant === true && data.activated === "updateAddition"){flag=true;}
			if(includeValriant === false && data.activated === "updateAddition"){} // case when auto updates removes variant
			else that._setVisibility(includeValriant,flag);
		});

		this.modelEvents.subscribe({event: 'OnConflictIconClick'}, function (data) {
			var conflictOptions = that.configModel.getConflictingFeatures(), conflictingFeatures = [], flag;
			var rulesActivationStatus = that.configModel.getRulesActivation();
			if(that.configModel.getNumberOfConflictingFeatures() > 0){
				for (var i = 0; i < conflictOptions.length; i++) {
					for (var j = 0; j < conflictOptions[i].length; j++) {
						conflictingFeatures.push(that.configModel.getFeatureIdWithOptionId(conflictOptions[i][j]));
					}
				}
			}
			var includeValriant = conflictingFeatures.indexOf(that.variant.ruleId) === -1 ? false : rulesActivationStatus;
			if(includeValriant === true && data.activated === "updateAddition"){flag=true;}
			if(includeValriant === false && data.activated === "updateAddition"){} // case when auto updates removes variant
			else that._setVisibility(includeValriant,flag);
		});

		this.modelEvents.subscribe({event: 'updateExclusions'}, function (data) {
				var includeValriant = true;
				if(that.configModel.getStateWithId(that.variant.ruleId)=== "Incompatible"){
					if(!that.configModel.getUserSelectVariantIDs(that.variant.ruleId))
						includeValriant = false;
				}
				if(!includeValriant){
					that._setVisibility(includeValriant);
					that.excludedVariant = true;
				}else if(includeValriant && that.excludedVariant){
					that._setVisibility(includeValriant);
					that.excludedVariant = false;
				}
		});


		this.modelEvents.subscribe({event: 'applyDefaultSearch'}, function (data) {
			var attributesList = that.variant.attributes;
			for (var i = 0; i < that.variant.options.length; i++) {
				attributesList["value_" + that.variant.options[i].ruleId + "_DisplayName"] = that.variant.options[i].displayName;
			}
			var searchValue = (data && data.searchValue) ? data.searchValue : [];
			var matchFound = false;
			that.configModel.setCurrentSearchData(data);
			if (that.configModel.getVariantVisibility(that.variant.ruleId)) {
				that._container.style.display = 'inline-block';
				if (searchValue.length > 0) {
					for (var attr in attributesList) {
						var AttribValue = attributesList[attr].replace(/\s+/g, '');
						for (var i = 0; i < searchValue.length; i++) {
							if (AttribValue.toUpperCase().contains(searchValue[i].toUpperCase()) || searchValue[i] === '') {
								matchFound = true;
								break;
							}
						}
						if (matchFound)break;
					}
					if (!matchFound) {
						that._container.style.display = 'none';
					}
				}
			}
		});

		// L3B : filter Event
		this.modelEvents.subscribe({event: 'OnFilterResult'}, function (data) {
			var searchBox = document.querySelector('.autocomplete-input');
			var value = searchBox ? searchBox.value : "";
			var text = data.searchValue || value;
			that.configModel.setCurrentSearchData({searchValue : [text]});

			if (that.configModel.getVariantVisibility(that.variant.ruleId)) {
				if(!that.variant.xFiltersMerge){
					that.variant.xFiltersMerge = {};
				}
				if (data.filterValues.indexOf(that.variant.ruleId) != -1) {
					that.variant.xFiltersMerge[data.filterType] = true;
				}else{
					that.variant.xFiltersMerge[data.filterType] = false;
					//IR-607240 - Search
					if(that.variant && that.variant.optionPhysicalIds){
						for (var i = 0; i < that.variant.optionPhysicalIds.length; i++) {
							if(data.filterValues.indexOf(that.variant.optionPhysicalIds[i]) != -1){
								that.variant.xFiltersMerge[data.filterType] = true;
								break;
							}
						}
					}
				}
					that._applyAllFilters();
			}else{
				that._container.style.display = 'none';
			}
		});

	};

	VariantComponentPresenter.prototype._applyAllFilters= function() {
		var that = this;
		if(that.variant.xFiltersMerge){
			var isFiltered = true;
			Object.keys(that.variant.xFiltersMerge).forEach(function(key) {
				if(that.variant.xFiltersMerge[key] == false){
					isFiltered = false;
				}
			});
			if (isFiltered){
				that._container.style.display = 'inline-block';
			}else{
				that._container.style.display = 'none';
			}
		}
	};

	VariantComponentPresenter.prototype._setVisibility= function(criteria,flag) {
		if(criteria){
			if(this._container.style.display !== 'inline-block'){
				flag ? this._container.classList.add("animated-variant") : this._container.classList.remove("animated-variant");
				this.configModel.setVariantVisibility(this.variant.ruleId, true);
			}
		}else{
			this.configModel.setVariantVisibility(this.variant.ruleId, false);
		}
		var values = this.configModel.getCurrentSearchData();
		if (this.configModel.getSearchStatus() && values && values.searchValue && values.searchValue.length > 0 && values.searchValue[0] !== "") {
			this.modelEvents.publish({event: 'OnSearchResult',data: values});
		}else{
			if(criteria){
				if(this._container.style.display !== 'inline-block'){
					flag ? this._container.classList.add("animated-variant") : this._container.classList.remove("animated-variant");
					this._container.style.display = 'inline-block';
					this.configModel.setVariantVisibility(this.variant.ruleId, true);
				}
			}else{
				this._container.style.display = 'none';
				this.configModel.setVariantVisibility(this.variant.ruleId, false);
			}
		}
	};

	VariantComponentPresenter.prototype.inject= function(parentcontainer) {
		parentcontainer.appendChild(this._container);
	};

	VariantComponentPresenter.prototype._getAutocomplete= function() {
		var options = {
				variant: this.variant,
				parentContainer: this._autocompleteContainer,
				imageContainer : this._imageContainer,
				configModel: this.configModel,
				modelEvents: this.modelEvents
		}
		if(this.variant.selectionType === "Parameter"){
			this._contentContainer.classList.add("contentContainerForRealistic");
			this.parameterPresenter = new ParameterPresenter(options);
		}else{
		//Unconstrained mode
		if (this.configModel.getAppFunc().multiSelection === ConfiguratorVariables.str_yes || this.configModel.getAppFunc().selectionMode_Refine === ConfiguratorVariables.str_yes) {
			this.autocompletePresenter = new MultipleValueAutocompletePresenter(options);
		}else{
			this._contentContainer.classList.add("contentContainerForRealistic");
			this.autocompletePresenter = this.variant.selectionType === ConfiguratorVariables.Single ?
					new SingleValueAutocompletePresenter(options) : new MultipleValueAutocompletePresenter(options);
		}
		listAutcompletePresenters.push(this.autocompletePresenter);
		}
		this.updateView();
	};

	VariantComponentPresenter.prototype.getListAutocomplete= function(){
		return listAutcompletePresenters;
	};

	VariantComponentPresenter.prototype.updateView=function (data) {
		if (this.autocompletePresenter) {
				this.autocompletePresenter.enforceRequired(data);
			}else if(this.parameterPresenter){
				this.parameterPresenter.enforceRequired(data);
			}
	};

	VariantComponentPresenter.prototype._resize= function (currentWidth) {
		var width = currentWidth || 0;
		this._container.classList.remove('smallerContainer');
		this._container.classList.remove('smallContainer');
		this._container.classList.remove('mediumContainer');
		this._container.classList.remove('largeContainer');
		if (width >= 1600) {
			this._container.classList.add('xlargeContainer');
		} else if (width < 1600 && width >= 1400) {
			this._container.classList.add('largeContainer');
		}else if (width < 1400 && width > 800) {
			this._container.classList.add('mediumContainer');
		}else if (width <= 800) {
			this._container.classList.add('smallContainer');
		}
	};

	return VariantComponentPresenter;
});


/**
 * @module DS/ENOXModelApp/PCDefinition/ConfigGridPresenter
 * @description Module-Presenter to display a resume of a PC. This presenter also support multi-selection of PC. All the selected PCs will be displayed in a single tab
 */

define(
	'DS/ConfiguratorPanel/scripts/Presenters/ConfigGridPresenter',
	[
		'DS/CoreEvents/ModelEvents',
		'DS/Tree/TreeNodeModel',
    'DS/DataGridView/DataGridView',
		'DS/Tree/TreeDocument',
		'DS/UIKIT/Mask',
		'DS/xModelEventManager/xModelEventManager',
		'DS/ConfiguratorPanel/scripts/Models/ConfiguratorModel',
		'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
		'i18n!DS/ConfiguratorPanel/assets/nls/ConfigGridPresenter.json',
		'css!DS/ConfiguratorPanel/css/ConfigGridPresenter.css'
	],
	function (
		ModelEvents,
		TreeNodeModel,
		DataGridView,
		TreeDocument,
		Mask,
		xModelEventManager,
		ConfiguratorModel,
		ConfiguratorVariables,
		NLS) {

    'use strict';

	var ConfigGridPresenter = function () {};

	ConfigGridPresenter.prototype.init = function (modelEvents, applicationChannel, options) {
		this.modelEvents = modelEvents || new ModelEvents();
		this._applicationChannel = applicationChannel;
		this._configModelMap = {};
		this._modelEventMap = {};
		if(options.id && options.configModel) {
			this._configModelMap[options.id] = options.configModel;
		}
		if(options.id && modelEvents) {
			this._modelEventMap[options.id] = modelEvents;
			this._eventManager = new xModelEventManager(modelEvents);
		} else {
			this._eventManager = new xModelEventManager();
		}
    this._modeExpandAll = (options.expandAll && (typeof(options.expandAll) === 'boolean' || options.expandAll === 'true')) ? options.expandAll : false;
		this._modelVariabilityDico = {};
		this._dictionary = options.dictionary ? options.dictionary : options.configModel ?  options.configModel.getDictionary() || {features : []} : undefined;
    this.previewOnly = options.previewMode != undefined ? options.previewMode : true;
		this._pcList = (options.pcList && Array.isArray(options.pcList)) ? options.pcList.slice() : [];
		var typeLabelMap = {
			'Variant' : NLS.variantType,
			'Value' : NLS.valueType,
			'VariabilityGroup' : NLS.variabilityGroupType,
			'Option' : NLS.optionType,
			'Parameter' : NLS.parameterType
		};
		this.options = {
			'_columns': [{
					text: NLS.titleLabel,
					dataIndex: 'tree',
					minWidth : 150,
				},
        {
					text: NLS.typeLabel,
					dataIndex: 'type',
					width: 'auto',
					getCellValue : function (cellInfos) {
						return typeLabelMap[cellInfos.nodeModel.options.grid.type];
					}
  			},
        {
					text: NLS.sequenceNoLabel,
					dataIndex: 'sequenceNumber',
					'width': '150',
					typeRepresentation : 'integer'
				}
			]
		};
		//To keep track of loaded PCs. Note that pc id is attribute of this object.
		this._currentlyLoadedPCs = {};
		this._FILTER_MODE = {
			ALL : 0,
			CHOSEN : 1,
			UNSELECTED : 2,
			RULED : 3,
			MAND : 4,
			CONFLICTED : 5
		};
		this._filterData = {
			ids : false, //[],
			mode : this._FILTER_MODE.ALL
		};
		this._initDivs();
		this._initializeDataGridView();
		this._subscribeEvents();
		this._loadModel();
	};

		ConfigGridPresenter.prototype._subscribeEvents = function () {
			var that = this;

			for (var pcId in that._modelEventMap) {
				if (that._modelEventMap.hasOwnProperty(pcId)) {
					that._eventManager.subscribe(that._modelEventMap[pcId], 'updateAllFilters', function (data) {
						that.updateFilters(pcId, data);
					});
					that._eventManager.subscribe(that._modelEventMap[pcId], 'updateVariantList' , function (data) {
						that.updateVariantList(pcId);
					});

					that._eventManager.subscribe(that._modelEventMap[pcId], 'solveAndDiagnoseAll_SolverAnswer', function (data) {
							if(data) {
								data.updateView = true;
							}
							that.updateFilters(pcId, data);
							that.refresh();
					});

					that._eventManager.subscribe(that._modelEventMap[pcId], 'OnAllVariantFilterIconClick', function (data) {
							that._filterData.mode = that._FILTER_MODE.ALL;
							that._applyFilter(pcId);
					});

					that._eventManager.subscribe(that._modelEventMap[pcId], 'onChosenVariantIconClick', function (data) {
							that._filterData.mode = that._FILTER_MODE.CHOSEN;
							that._applyFilter(pcId);
					});

					that._eventManager.subscribe(that._modelEventMap[pcId], 'OnUnselectedVariantIconClick', function (data) {
							that._filterData.mode = that._FILTER_MODE.UNSELECTED;
							that._applyFilter(pcId);
					});

					that._eventManager.subscribe(that._modelEventMap[pcId], 'OnRuleNotValidatedIconClick', function (data) {
							that._filterData.mode = that._FILTER_MODE.RULED;
							that._applyFilter(pcId);
					});

					that._eventManager.subscribe(that._modelEventMap[pcId], 'onMandVariantIconClick', function (data) {
							that._filterData.mode = that._FILTER_MODE.MAND;
							that._applyFilter(pcId);
					});

					that._eventManager.subscribe(that._modelEventMap[pcId], 'OnConflictIconClick', function (data) {
							that._filterData.mode = that._FILTER_MODE.CONFLICTED;
							that._applyFilter(pcId);
					});
				}
			}

			// this.modelEvents.subscribe({ event: 'updateAllFilters' }, function (data) {
			// 	that.updateFilters(data);
			// });
			//
			// this.modelEvents.subscribe({ event: 'updateVariantList' }, function (data) {
			// 	that.updateVariantList();
			// });
			//
			// this.modelEvents.subscribe({event: 'solveAndDiagnoseAll_SolverAnswer'}, function (data) {
			// 		if(data){
			// 			data.updateView = true;
			// 		}
			// 		that.updateFilters(data);
			// 		that.refresh();
			// });

			// sortChildren event
			this.modelEvents.subscribe({event: 'OnSortResult' }, function (data) {
				var dataIndex = data.sortAttribute == 'displayName' ? 'tree' : data.sortAttribute;
				var order = data.sortOrder;

				if(dataIndex && order) {
					var sortOptions = {
						dataIndex : dataIndex,
						sort : order.toLowerCase()
					};
					that._dataGridView.sortModel = [sortOptions];
				}
			});

			this.modelEvents.subscribe({event: 'applyVariantListFilters' }, function (data) {
				if(data && data.filterValues) {
					var requireFiltering = true;
					if(that._filterData.ids && that._filterData.ids.length == data.filterValues.length ) {
						if(JSON.stringify(that._filterData.ids) === JSON.stringify(data.filterValues)) {
								requireFiltering = false;
						}
					}
					if(requireFiltering) {
						that._filterData.ids = data.filterValues || [];
						var pcIds = that._configModelMap ? Object.keys(that._configModelMap) : [];
						if(pcIds.length == 1) {
							that._applyFilter(pcIds[0]);
						} else {
							that._applyFilter();
						}
					}
				}
			});
		};

		ConfigGridPresenter.prototype.updateFilters= function(pcId, data){
			var that = this;
			this.defaults = data ? data.answerDefaults : [];

			var configModel = this._configModelMap[pcId];
			if(configModel) {
				var variantNodes = that._treeDocument.getChildren();
				if(variantNodes) {

					variantNodes.forEach(function (variantNode) {
						// variantNode.options.id;
						if(data && data.updateView && configModel.getUpdateRequired(variantNode.options.id)){
							that._updateView(variantNode, data, pcId);
						}

					});
				}
			}

			that.updateVariantList(pcId);
		};

		ConfigGridPresenter.prototype._applyFilter = function(pcId) {
			var data = this._filterData.ids;
			var mode = this._filterData.mode;
			var that = this;
			var configModel = pcId ? that._configModelMap[pcId] : undefined;
			var children = this._treeDocument.getChildren();
			if(!children) {
				children = [];
			}

			// this._FILTER_MODE = {
			// 	ALL : 0,
			// 	CHOSEN : 1,
			// 	UNSELECTED : 2,
			// 	RULED : 3,
			// 	CONFLICTED : 4
			// }
			children.forEach(function (nodeModel) {

				var visibility = false;
				var isFiltered = false;
				// APPLYING FILTER
				if(configModel) {
					var featureId = nodeModel.options.id;
					if(configModel.getStateWithId(featureId)=== "Incompatible") {
						if(!configModel.getUserSelectVariantIDs(featureId)) {
							visibility = false;
						}
					} else {
						visibility = true;
					}
					if(mode == undefined || mode != that._FILTER_MODE.ALL) {
						isFiltered = true;
					}
					if(visibility) {
						switch (mode) {
							// case that._FILTER_MODE.ALL:
							// 		visibility = true;
							case that._FILTER_MODE.CHOSEN:
									var isChosen = configModel.getFeatureIdWithChosenStatus(featureId);
									if(nodeModel.getAttributeValue('type') === "Parameter") {
										if(configModel.getValueWithId(featureId)) {
											isChosen = true;
										}
									}
									visibility = isChosen;
								break;
							case that._FILTER_MODE.UNSELECTED:
									var isSelcted = true;
									if(nodeModel.getAttributeValue('type') === "Parameter") {
										if(configModel.getValueWithId(featureId)){
											isSelcted = false;
										}
									} else {
										isSelcted = configModel.getFeatureIdWithStatus(featureId);
									}
									visibility = !isSelcted;
								break;
							case that._FILTER_MODE.RULED:
									var isSelected = configModel.getFeatureIdWithRulesStatus(featureId);
									if(nodeModel.getAttributeValue('type') === "Parameter") {
										isSelcted = false;
									}
									visibility = isSelected;
								break;
							case that._FILTER_MODE.MAND:
									var isMand = configModel.getFeatureIdWithMandStatus(featureId);
									visibility = isMand;
								break;
							case that._FILTER_MODE.CONFLICTED:
								var conflictOptions = configModel.getConflictingFeatures();
								var conflictingFeatures = [];
								var rulesActivationStatus = configModel.getRulesActivation();
								if(configModel.getNumberOfConflictingFeatures() > 0){
									for (var i = 0; i < conflictOptions.length; i++) {
										for (var j = 0; j < conflictOptions[i].length; j++) {
											conflictingFeatures.push(configModel.getFeatureIdWithOptionId(conflictOptions[i][j]));
										}
									}
								}
								var visibility = conflictingFeatures.indexOf(featureId) === -1 ? false : rulesActivationStatus;
								break;
							default :
								visibility = true;
						}

					}
				}

				if(isFiltered && visibility == false) {
					nodeModel.hide();
				} else {
					// APPLYING SEARCH
					if(data) {
						if(data.indexOf(nodeModel.options.id) != -1) {
							visibility = true;
						} else {
							visibility = false;
						}
					} else {
						visibility = true;
					}

					if(visibility) {
						nodeModel.show();
						nodeModel.showChildNodes();
					} else {
					var visibleNodes = nodeModel.search({
							match : function (cellInfos) {
								if(data.indexOf(cellInfos.nodeModel.options.id) != -1) {
									cellInfos.nodeModel.show();
									return true;
								} else {
									cellInfos.nodeModel.hide();
									return false;
								}
							}
						});
						if(visibleNodes.length > 0) {
							nodeModel.show();
						} else {
							nodeModel.hide();
						}
					}
				}
			});
			if(this._modeExpandAll) {
				this._treeDocument.expandAll();
			}
			this.refresh();
		};

		ConfigGridPresenter.prototype._updateView= function(node, data, pcId) {
			// TODO: update nodes
			var configModel = this._configModelMap[pcId];
			var mandatory = (node.getAttributeValue('selectionCriteria') == 'Must' || node.getAttributeValue('selectionCriteria') == true)? true : false;
				var mandStatus = (mandatory || configModel.getStateWithId(node.options.id) === ConfiguratorVariables.Required) ? true : false;
				// var selectedFeature;
				// if(this._autocomplete.selectedItems && this._autocomplete.selectedItems.length > 0){
				// 	mandStatus = false;
				// 	selectedFeature = true;
				// }else{
				// 	selectedFeature = false;
				// }
				//
				// if(variantState=== "Incompatible"){
				// 			if(!configModel.getUserSelectVariantIDs(this.variant.ruleId))
				// 				selectedFeature = false;
				// }

				var children = node.getChildren();
				if(children) {
					children.forEach(function (nodeModel) {
						var state = configModel.getStateWithId(nodeModel.options.id);
						if(state === ConfiguratorVariables.Chosen || state === ConfiguratorVariables.Required || state == ConfiguratorVariables.Default) {
							mandStatus = false;
						}
					});
				}
				var icons = node.options.icons;
				if(mandStatus) {
					while(icons.length > 1) {
						icons.pop();
					}
					icons.push({
						iconName : 'attention',
						fontIconFamily: WUXManagedFontIcons.Font3DS
					});
					node.options.icons = icons;
				} else {
					while(icons.length > 1) {
						icons.pop();
						node.options.icons = icons;
					}
				}

		};

		ConfigGridPresenter.prototype.updateVariantList = function(){
			// TODO: update
		};

    ConfigGridPresenter.prototype._initDivs = function () {
			this._container = UWA.createElement('div');
			this._container.classList.add('pc-summary');
			this._contentDiv = UWA.createElement('div');
			this._contentDiv.classList.add('contentDiv');
			this._contentDiv.innerHTML = '';
			this._container.appendChild(this._contentDiv);
		};


    ConfigGridPresenter.prototype._initializeDataGridView = function () {
		var that = this;
    this._treeDocument = new TreeDocument();

		this._dataGridView = new DataGridView({
        treeDocument: that._treeDocument,
				columns: that.options._columns,
				resize: {
					rows: false,
					columns: true,
				},
				enableDragAndDrop: false,
				showSelectionCheckBoxesFlag : false,
				rowSelection : 'none',
				columnSelection : 'none',
			}).inject(this._contentDiv);

	    this._dataGridView.elements.container.style.height = '100%';

        //this._registerReusableCellContentForStates();

        if(this._modeExpandAll) {
            this._dataGridView.onReady(function(){
                    that._treeDocument.expandAll();
            });
        }
        //Create and register Type Representations//
        // register custom representations
        var selectionStateTypeRep = {
            'selectionStateType' : {
                stdTemplate: 'selectionStateTemplate'
            }
        };
        // register custom template
        var selectionStateType = {
          'selectionStateTemplate' : {
            'path' : 'DS/ConfiguratorPanel/scripts/Presenters/SelectionStateTweaker'
          }
        };

        this._typeRepresentationFactory = this._dataGridView.getTypeRepresentationFactory();
        this._typeRepresentationFactory.registerTypeTemplates(selectionStateType);
        this._typeRepresentationFactory.registerTypeRepresentations(selectionStateTypeRep);

				this._treeDocument.addEventListener('state-change-action', function (evtData) {
					var referenceValue = evtData.data.referenceValue;
					var dataIndex = that._dataGridView.layout.getDataIndexFromColumnIndex(this.columnID);
					var context = this;
					UWA.merge(context, {dataIndex : dataIndex});
					that._onSelect(referenceValue, context);
				});

				this._treeDocument.addEventListener('value-change-action', function (evtData) {
					var referenceValue = evtData.data.referenceValue;
					var value = evtData.data.value;
					var dataIndex = that._dataGridView.layout.getDataIndexFromColumnIndex(this.columnID);
					var context = this;
					UWA.merge(context, {dataIndex : dataIndex});
					that._onValueUpdate(value, context);
				});

				this._treeDocument.addEventListener('state-remove-action', function (evtData) {
					console.log('state-remove');
					var referenceValue = evtData.data.referenceValue;
					var currentNode = evtData.target;
					var dataIndex = that._dataGridView.layout.getDataIndexFromColumnIndex(this.columnID);
					var context = this;
					UWA.merge(context, {dataIndex : dataIndex});
					that._onUnselect(referenceValue, context);
				});
	};

		ConfigGridPresenter.prototype._onSelect = function (referenceValue , context) {
			var currentNode = context.nodeModel;
			var dataIndex = context.dataIndex;
			var adjacentNodes = currentNode.getBrothers();
			var parentNode = currentNode.getParent();
			var selectionType = parentNode.getAttributeValue('selectionType');

			var configModel = this._configModelMap[dataIndex];
			var newItemState = ConfiguratorVariables.Chosen;
			if(selectionType == 'Single') {
				// ConfiguratorVariables.
				adjacentNodes.forEach(function (nodeModel) {
					var nodeId = nodeModel.options.id;
					var nodeState = configModel.getStateWithId(nodeId);
					if(nodeState === ConfiguratorVariables.Chosen){
						configModel.setStateWithId(nodeId, ConfiguratorVariables.Unselected);
						nodeModel.prepareUpdate();
						nodeModel.setAttribute(dataIndex, ConfiguratorVariables.Unselected);
						nodeModel.pushUpdate();
					}
				});

				if (referenceValue === ConfiguratorVariables.Unselected){
					var defaultItem = this.default ? this.default.indexOf(currentNode.options.id) != -1 : false;
					newItemState = defaultItem ? ConfiguratorVariables.Unselected : ConfiguratorVariables.Chosen;
				}
				if(referenceValue === ConfiguratorVariables.Dismissed){
					newItemState = ConfiguratorVariables.Default;
				}
			} else if(selectionType == 'Multiple') {

				if (referenceValue === ConfiguratorVariables.Unselected){
					var defaultItem = this.default ? this.default.indexOf(currentNode.options.id) != -1 : false;
					newItemState = defaultItem ? ConfiguratorVariables.Unselected : ConfiguratorVariables.Chosen;
				}
				if(referenceValue === ConfiguratorVariables.Dismissed){
					newItemState = ConfiguratorVariables.Default;
				}

			}

			configModel.setStateWithId(currentNode.options.id, newItemState);
			currentNode.prepareUpdate();
			currentNode.setAttribute(dataIndex, newItemState);
			currentNode.pushUpdate();

			this.callSolver(dataIndex);
		};

		ConfigGridPresenter.prototype._onUnselect = function (referenceValue , context) {
			var currentNode = context.nodeModel;
			var dataIndex = context.dataIndex;
			var adjacentNodes = currentNode.getBrothers();
			var parentNode = currentNode.getParent();
			var selectionType = parentNode.getAttributeValue('selectionType');

			var configModel = this._configModelMap[dataIndex];
			var newItemState = ConfiguratorVariables.Unselected;
			var build_mode = configModel.getSelectionMode() === ConfiguratorVariables.selectionMode_Build ? true : false;

			if(selectionType == 'Single') {
				if(build_mode) {
					if (referenceValue === ConfiguratorVariables.Chosen){
						newItemState = ConfiguratorVariables.Unselected;
					}
					if(referenceValue === ConfiguratorVariables.Default || referenceValue === ConfiguratorVariables.Selected){
						newItemState = ConfiguratorVariables.Dismissed;
					}
				}
			} else if(selectionType == 'Multiple') {

				var children = parentNode.getChildren();
				var selectionCount = 0;
				if(children) {
					selectionCount = children.reduce(function (count, nodeModel) {
						if(nodeModel.getAttributeValue(dataIndex) ==  ConfiguratorVariables.Chosen) {
							return ++count;
						}
					}, 0);
				}

				// var build_mode = configModel.getSelectionMode() === ConfiguratorVariables.selectionMode_Build ? true : false;
				if(build_mode || (!build_mode && selectionCount > 0)) {
					if(referenceValue === ConfiguratorVariables.Default || referenceValue === ConfiguratorVariables.Selected) {
						newItemState = ConfiguratorVariables.Dismissed; //Reject Default
					} else if (referenceValue === ConfiguratorVariables.Selected) {
						newItemState = ConfiguratorVariables.Dismissed;
					} else {
						newItemState = ConfiguratorVariables.Unselected;
					}
				}
			}

			configModel.setStateWithId(currentNode.options.id, newItemState);
			currentNode.prepareUpdate();
			currentNode.setAttribute(dataIndex, newItemState);
			currentNode.pushUpdate();

			this.callSolver(dataIndex);
		};

		ConfigGridPresenter.prototype._onValueUpdate = function (changedValue, context) {
			var currentNode = context.nodeModel;
			var dataIndex = context.dataIndex;

			var configModel = this._configModelMap[dataIndex];

			var valueToBeUpdated = JSON.stringify(changedValue);
			if (UWA.is(valueToBeUpdated, "string")) {
					if (currentNode.getAttributeValue('unit') && currentNode.getAttributeValue('unit') != "" && valueToBeUpdated.indexOf(currentNode.getAttributeValue('unit')) === -1) {
							valueToBeUpdated = valueToBeUpdated + " " + currentNode.getAttributeValue('unit');
					}
			}
			if (valueToBeUpdated) {
				configModel.setValueWithId(currentNode.options.id, valueToBeUpdated);
			}
			currentNode.prepareUpdate();
			currentNode.setAttribute(dataIndex, changedValue);
			currentNode.pushUpdate();
		};

		ConfigGridPresenter.prototype.callSolver = function (pcId) {
			var configModel = this._configModelMap[pcId];
			var modelEvent = this._modelEventMap[pcId];
			if(configModel && modelEvent) {
				if(configModel.getRulesActivation() === ConfiguratorVariables.str_true) {
					modelEvent.publish({event:'SolverFct_CallSolveMethodOnSolver', data : {}});
				}else{
					this.updateFilters(pcId);
					modelEvent.publish({event: 'solveAndDiagnoseAll_SolverAnswer'});
				}
			}
		};

		ConfigGridPresenter.prototype._loadModel = function () {
        // this._dictionary
				// this._treeDocument
				var that = this;
				if(this._dictionary) {
					if(UWA.is(this._dictionary.features,'array')) {
						this._treeDocument.prepareUpdate();
						this._dictionary.features.forEach(function (feature) {
							var featureNode = that._createTreeNode(feature);
							if(featureNode) {
								if(UWA.is(feature.options, 'array')) {
									feature.options.forEach(function (option) {
										var optionNode = that._createTreeNode(option);
										if(optionNode) {
											featureNode.addChild(optionNode);
										}
									});
								}
								that._treeDocument.addChild(featureNode);
							}
						});
						this._treeDocument.pushUpdate();

						if(that._modeExpandAll) {
							that._treeDocument.expandAll();
		        }
					}
				}
    };

		ConfigGridPresenter.prototype._createTreeNode = function (contentOptions) {
			if(contentOptions) {
				var id = contentOptions.ruleId;
				var label = contentOptions.displayName;
				if(id && label) {
					var image = contentOptions.image;
					var gridValue = {};
					for (var optionKey in contentOptions) {
						if (contentOptions.hasOwnProperty(optionKey)) {
							if(optionKey == 'options') {
								continue;
							}
							gridValue[optionKey] = contentOptions[optionKey];
						}
					}
					var tmpTreeNode = new TreeNodeModel({
						id: id,
						label: label,
						icons: image ? [image] : [],
						grid: gridValue,
					});
				}
				return tmpTreeNode;
			}
		};

		ConfigGridPresenter.prototype.refresh = function () {
			if(this._dataGridView) {
				this._dataGridView.invalidateLayout({
					updateCellContent: true,
					updateCellLayout: false,
					updateCellAttributes: false
				});

			}
		};

		ConfigGridPresenter.prototype.loadVariabilityDictionary = function (dictionary) {
			this._variabilityDictionary = dictionary;
		};

		ConfigGridPresenter.prototype.inject = function (parentContainer) {
        this._container.inject(parentContainer);
    };

		ConfigGridPresenter.prototype.clear = function () {
			this._container.innerHTML = '';
		};

    ConfigGridPresenter.prototype.destroy = function () {
			this._eventManager.cleanup();
			this._container.innerHTML = '';
		};


		//Product Configuration management as a columns//
		ConfigGridPresenter.prototype.loadConfigurationInfo = function (pcDetails, configurations) {
			var that = this;

			if(pcDetails && pcDetails.id) {
				var pcId = pcDetails.id;

				if(!this._configModelMap.hasOwnProperty(pcId)) {
					if(!configurations) {
						configuration = {};
					}
					var configModel = new ConfiguratorModel({
						configuration: configurations,
						pcId: pcId,
						appRulesParams: {
							multiSelection: 'true',
							selectionMode: 'selectionMode_Build',
							rulesMode: '',
							rulesActivation: 'true',
							completenessStatus: 'Unknown',
							rulesCompliancyStatus: 'Unknown'
						},
						appFunc: {
							multiSelection: "yes",
							selectionMode_Build: "yes",
							selectionMode_Refine: "yes",
							rulesMode_ProposeOptimizedConfiguration:  "no",
							rulesMode_SelectCompleteConfiguration: "no",
							rulesMode_EnforceRequiredOptions: "yes",
							rulesMode_DisableIncompatibleOptions: "yes",
						},
						modelEvents: new ModelEvents(),
						readOnly: true,
						enableValidation : false
					});

					if(!this._dictionary && this._variabilityDictionary) {
						configModel.setDictionary(this._variabilityDictionary);
						this._dictionary = configModel.getDictionary();
						this._loadModel();
					}
					this._configModelMap[pcId] = configModel;
				}

				var configurationCriteria = {};
				this._loadColumnForPC(pcDetails, configurationCriteria);
			}
		};


		ConfigGridPresenter.prototype.loadedPCsCount = function () {
			var pcCount = 0;
			if (this._currentlyLoadedPCs != undefined) {
				var keysSet = Object.keys(this._currentlyLoadedPCs);
				pcCount = UWA.is(keysSet, 'array') ? keysSet.length : 0;
			}
			return pcCount;
		};

		ConfigGridPresenter.prototype.unloadConfigurationInfo = function (pcData) {
			var that = this;
			if (pcData != undefined) {
				var pcsArr = pcData;
				if (UWA.is(pcData, 'array') == false) {
					pcsArr = [pcData]
				}
				var pcsToRemove = [];
				pcsArr.forEach(function (pcObj) {
					var currPCId = pcObj.id;
					if (that._currentlyLoadedPCs.hasOwnProperty(currPCId)) {
						that._unloadColumnForPC(currPCId);
						// if(that._configModelMap.hasOwnProperty(currPCId)) {
						// 	delete that._configModelMap[currPCId];
						// }
						// delete that._currentlyLoadedPCs[currPCId]; //remove pcid from objects properties.
					}
				});
			}
		};

		ConfigGridPresenter.prototype._loadColumnForPC = function (pcObj, pcStatusInfo) {
			var that = this;
			if (pcObj && pcStatusInfo) {
				if (this._currentlyLoadedPCs[pcObj.id] == undefined) {
					this._createColumnForPC(pcObj, pcStatusInfo);
				} else {
					console.log("PC with id : " + pcObj.id + " is already loaded in the view...");
				}
			}
		};

		ConfigGridPresenter.prototype._unloadColumnForPC = function (pcId) {
			// var that = this;
			if (pcId != undefined) {
				//var colId = this._dataGridView.layout.getColumnIDFromDataIndex(pcId);
        //IMP: whenever we have some row/cell selected in the tree and then we try to remove column it will fail.
        // that._dataGridView.unselectAll();
				this._dataGridView.removeColumnOrGroup(pcId); //TODO: to remove or hide? decide later.
				if(this._configModelMap.hasOwnProperty(pcId)) {
					delete this._configModelMap[pcId];
				}
				delete this._currentlyLoadedPCs[pcId]; //remove pcid from objects properties.
        //console.log('Removing column: ' + pcId + ' dataIndex: ' + colId );
			}
		};

		ConfigGridPresenter.prototype._createColumnForPC = function (pcObj, pcStatusInfo) {
			var that = this;
			this._currentlyLoadedPCs[pcObj.id] = pcStatusInfo;

			var columnOptions = {
				'dataIndex': pcObj.id,
				'text': pcObj['title'] ? pcObj['title'] : NLS.configurationLabel,
			 	'width': 'auto',
			  'typeRepresentation' : 'selectionStateType',
				sortableFlag : false,
			   getCellValue : function(cellInfos) {
					 	var state = '';
						var configModel = that._configModelMap[pcObj.id];
						if(!configModel) {
							return;
						}
						if(cellInfos.nodeModel.options.grid.type == 'Variant' ||
								cellInfos.nodeModel.options.grid.type == 'VariabilityGroup') {
									return '';
						} else if(cellInfos.nodeModel.options.grid.type == 'Parameter') {
							var value = configModel.getValueWithId(cellInfos.nodeModel.options.id);
							if(UWA.is(value, 'string')) {
								var valueSplit = value.split(' ');
								if(valueSplit.length > 0) {
									try {
										value = eval(valueSplit[0]);
									} catch (e) {
										value = 0;
									}
								}
							}
							return value;
						}
						state = configModel.getStateWithId(cellInfos.nodeModel.options.id);
						if(configModel.getRulesActivation() === ConfiguratorVariables.str_true && configModel.isConflictingOption(cellInfos.nodeModel.options.id)) {
							state = ConfiguratorVariables.Conflict;
						}
			      return state;
			   },
				 editionPolicy : 'EditionInPlace',
				 getCellEditableState : function (cellInfos) {
					 	if(cellInfos.nodeModel.getAttributeValue('type') == 'Variant' || cellInfos.nodeModel.getAttributeValue('type') == 'VariabilityGroup') {
							return false;
						}
				 		return !that.previewOnly;
				 },
				 getCellSemantics : function (cellInfos) {
					 return {
						 contentType : cellInfos.nodeModel.getAttributeValue('type')
					 }
				 },
				 setCellValue : function (cellInfos) {
				 	console.log('value changed');
				 }
			};
			that._dataGridView.prepareUpdateView();
      that._dataGridView.addColumnOrGroup(columnOptions);  //where to show PC information. in edit mode it would be col 2 else its just last column
			that._dataGridView.pushUpdateView();
			that.refresh();
		};

		//Remove All Columns//
		ConfigGridPresenter.prototype.removeAllPCColumns = function (pcObj, pcStatusInfo) {
			var that = this;
			if (this.loadedPCsCount() > 0) {
				// Mask.mask(that._contentDiv);
				that._contentDiv.hide();
				that._dataGridView.prepareUpdateView();
				for (var pcId in this._currentlyLoadedPCs) {
					that._unloadColumnForPC(pcId);
					// if (pcId != undefined) {
					// 	//var colId = that._dataGridView.layout.getColumnIDFromDataIndex(pcId);
          //   //IMP: whenever we have some row/cell selected in the tree and then we try to remove column it will fail.
          //   that._dataGridView.unselectAll();
					// 	that._dataGridView.removeColumnOrGroup(pcId); //TODO: to remove or hide? decide later.
          //   //console.log('Removing column: ' + pcId + ' dataIndex: ' + colId );
					// 	delete that._currentlyLoadedPCs[pcId];
					//
					// }
				}
				that._dataGridView.pushUpdateView();
				// Mask.unmask(that._contentDiv);
				that._contentDiv.show();
			}
		};

		return ConfigGridPresenter;
});

/*
TODO:
1. When we have multiple pcs displayed and one or more rows selected in the tree, unselecting one pc removes all selection from tree.
This is required because we can not delete column without removing selection on its cells.
OR? Can we disable the row selection totally?

2. Can we Hide column instead of removing?

3. And delete columns/tree only when we have fresh summary preview Initialization

4. how to track addition of new variability and new pc?

//Steps:
//We have list of PC Id and names<PC Name will be a column in the table>
//We have dictionary corresponding to Parent model for which PC would be created.
//We have to pass this information to CfgVCSMainContainer
//Show and hide columns for PC's depending on the selection on the PC list presenter.
//Eye/Preview Icon Management
//    1. No selection : should be disabled.
//    2. Single selection : load preview display showing model variability in first column and pc in the next.
//    3. Single selection removed: remove the preview area and disable the preview icon.
//    4. On multiple selection show corresponding column with values against the rows of variability.
//Possible:
// A> Fixed Variability Column.
// B> Show and hide columns as per PC selection<
//            1. load tree with all columns at the start with cols for pcs as hidden.
//            2. show/hide as per selection.
//        OR load columns on demand and remove as per un-select of PCs
//            >
// C> Column edition.
// D> Full dico at start ? Later on only selected one and then on edit show full dico present for given model.
// E> Save capability.
*/


define(
		'DS/ConfiguratorPanel/scripts/Presenters/VariantListPresenter',
		[
			'UWA/Core',
			'DS/Handlebars/Handlebars',
			'DS/UIKIT/Mask',
			'DS/UIKIT/Scroller',
			'DS/ConfiguratorPanel/scripts/Presenters/VariantComponentPresenter',
			'DS/ConfiguratorPanel/scripts/Utilities',
			'DS/ConfiguratorPanel/scripts/ConfiguratorSolverFunctions',
			'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',

			'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json',
			'text!DS/ConfiguratorPanel/html/VariantListPresenter.html',
			"css!DS/ConfiguratorPanel/css/VariantListPresenter.css",
			'css!DS/UIKIT/UIKIT.css'

			],
			function (UWA, Handlebars,Mask, Scroller, variantComponentPresenter, Utilities,ConfiguratorSolverFunctions,ConfiguratorVariables, nlsConfiguratorKeys, html_VariantListPresenter) {

			'use strict';

			var template = Handlebars.compile(html_VariantListPresenter);

			var VariantListPresenter = function (options) {
				this._init(options);
			};

			VariantListPresenter.prototype._init = function(options){
				var _options = options ? UWA.clone(options, false) : {};
				UWA.merge(this, _options);

				this._subscribeToEvents();
				this._initDivs();
				this._render();
				this.inject(_options.parentContainer);
				// new Scroller({element: this._container}).inject(this._scrollContainer);
			};

			VariantListPresenter.prototype._initDivs = function () {
				this._container = document.createElement('div');
				this._container.innerHTML = template({nls : nlsConfiguratorKeys});

				this._container = this._container.querySelector('#config-editor-variant-list');
				this._extendedVariantList = this._container.querySelector('#config-editor-extended-variant-list');
				this._scrollContainer = this._container.querySelector('#config-editor-scroll-container');
				//this._container.style.height = "calc(100% - 63px)";
				// this._container.style.height = "100%";
			};

			VariantListPresenter.prototype.inject= function(parentcontainer) {
				if(parentcontainer){
					parentcontainer.appendChild(this._container);
					parentcontainer.appendChild(this._scrollContainer);
				}
			};

			VariantListPresenter.prototype._render= function(parentcontainer) {
				var dico = this.configModel.getDictionary();
				var featureList = dico.features ? dico.features : [];
				this.configModel.setVariants(featureList.length);
				this.variantCompList = [];
				this.listAutocomplete = [];

				// var featureList = featureList.sort(function(a, b) {
				// 		var nameA = parseInt(a.sequenceNo); //a.displayName.toUpperCase();
				// 		var nameB = parseInt(b.sequenceNo);//b.displayName.toUpperCase();
				// 		if (nameA < nameB) {
				// 			return -1;
				// 		}
				// 		if (nameA > nameB) {
				// 			return 1;
				// 		}
				// 		return 0;
				// 	});

				for(var i=0; i< featureList.length; i++){
					this.variantCompList.push(new variantComponentPresenter({
						variant: featureList[i],
						parentContainer: this._extendedVariantList,
						configModel: this.configModel,
						modelEvents	: this.modelEvents
					}));
					this.listAutocomplete = this.variantCompList[0].getListAutocomplete();
					this.mandIcon = document.getElementById('variantRightIcon_' + featureList[i].ruleId);
					this.refinedIcon = document.getElementById('variantRefinedIcon_' + featureList[i].ruleId);
				}

				/** Filter list based on the topbar filter selection**/
				var currentFilter = this.configModel.getCurrentFilter();
				if(currentFilter === ConfiguratorVariables.Filter_AllVariants){
					this.configModel.setVariants(featureList.length);
					this.modelEvents.publish({ event: "OnAllVariantFilterIconClick", data:{activated:'true'} });
				}
			};

			VariantListPresenter.prototype._subscribeToEvents = function() {
				var that = this;

				this.modelEvents.subscribe({ event: 'updateAllFilters' }, function (data) {
					that.updateFilters(data);
				});

				this.modelEvents.subscribe({ event: 'updateVariantList' }, function (data) {
					that.updateVariantList();
				});

				this.modelEvents.subscribe({ event: 'applyVariantListFilters' }, function (data) {
					that.applyVariantListFilters(data);
				});

				this.modelEvents.subscribe({ event: 'OnSortResult'}, function(data){
					that._sortAttribute = data.sortAttribute;
					that._sortOrder = data.sortOrder;
					 	that.variantCompList = that.variantCompList.sort(function(a, b) {
							var nameA,nameB;
							if(that._sortAttribute === "displayName"){
								nameA = a.variant.displayName.toUpperCase();
								nameB = b.variant.displayName.toUpperCase();
							}
							if(that._sortAttribute === "sequenceNumber"){
								nameA = parseInt(a.variant.sequenceNumber);
								nameB = parseInt(b.variant.sequenceNumber);
							}
							if (that._sortOrder === "DESC") {
								var temp = nameA;
								nameA = nameB;
								nameB = temp;
							}
							if (nameA < nameB) {
								return -1;
							}
							if (nameA > nameB) {
								return 1;
							}
							return 0;
						});
						that.variantCompList.forEach(function (p) {
	        		that._extendedVariantList.appendChild(p._container);
	    			});
				});


				this.modelEvents.subscribe({event: 'solveAndDiagnoseAll_SolverAnswer'}, function (data) {
						if(data){
							data.updateView = true;
							data.answerDefaults = that.configModel.getDefaultCriteria();
						}
						that.updateFilters(data);
						that.modelEvents.publish({event:"pc-interaction-complete"});
				});

				this.modelEvents.subscribe({event: 'getResultingStatusOriginators_SolverAnswer'}, function (data) {
					if(data){
						var message = that.computeMessage(data);
						if(data.optionSelected && message){
							var variantId = that.configModel.getFeatureIdWithOptionId(data.optionSelected);
							for(var i=0;i < that.listAutocomplete.length; i++){
								if(variantId === that.listAutocomplete[i].variant.ruleId){
									that.listAutocomplete[i].setTooltipMessage(data.optionSelected, message);
								}
							}
						}
					}
				});

				this.modelEvents.subscribe({event: 'OnRuleAssistanceLevelChange'}, function (data){
					if (data.value === ConfiguratorVariables.NoRuleApplied) {
						that.modelEvents.publish({event : "solveAndDiagnoseAll_SolverAnswer", data : data});
					}
				});
			};

			VariantListPresenter.prototype.computeMessage = function (data) {
				var state = this.configModel.getStateWithId(data.optionSelected);
				var listIncompatibilities = data.listOfIncompatibilitiesIds ? data.listOfIncompatibilitiesIds : [];
				var optionName = this.configModel.getOptionDisplayNameWithId(data.optionSelected);
				var message = "";
				if (data.answerRC !== ConfiguratorVariables.str_ERROR) {
					message = UWA.i18n("Option") + " " + optionName + " " + UWA.i18n("is") + " " + UWA.i18n(state);
					if (listIncompatibilities.length > 0) {
						message += " because ";
						for (var i = 0; i < listIncompatibilities.length; i++) {
							if(i > 0) message += ",";
							for (var j = 0; j < listIncompatibilities[i].length; j++) {
								state = this.configModel.getStateWithId(listIncompatibilities[i][j]);
								var variant = this.configModel.getFeatureDisplayNameWithId(listIncompatibilities[i][j]) + "[" + this.configModel.getOptionDisplayNameWithId(listIncompatibilities[i][j]) + "]"
								message += " " + UWA.i18n("Option") + " " + variant + " " + "is" + " " + 	UWA.i18n(state);
							}
						}
					}
				}else{
					message += UWA.i18n("InfoComputationAborted");
				}
				return message;
			};

			VariantListPresenter.prototype.updateFilters= function(data){
				var that =this;
				if(that.variantCompList && that.variantCompList.length > 0){
					var mandVariants = 0, unselectedVariants = 0, rulesVariants= 0, chosenVariant = 0;
					var mandvariant,conflicts, includedState, selected, ruleSelected, mandIcon, refinedIcon;
					var rules = that.configModel.getRulesActivation() === ConfiguratorVariables.str_true ? true : false;
					var countVariants =0;

					//Added here for IR - New implementation
					that._allvariants = that.configModel.getVariants() || 0;
					that._conflicts = that.configModel.getNumberOfConflictingFeatures() || 0;
					that._rules = that.configModel.getNumberOfFeaturesByRules() || 0;
					that._unselectedVariants = that.configModel.getNumberOfFeaturesNotValuated() || 0;
					that._mandatory = that.configModel.getNumberOfMandFeaturesNotValuated() || 0;

					for(var i=0;i < that.variantCompList.length; i++){
						if((data && data.updateView && that.configModel.getUpdateRequired(that.variantCompList[i].variantId)) || (data && data.refresh)){
							that.variantCompList[i].updateView(data);
						}
							var variantRuleId = that.variantCompList[i].variantId;
							// var variantIncompatible = that.configModel.getStateWithId(variantRuleId)=== "Incompatible" ? true : false;
							var variantIncompatible = false;
							if(that.configModel.getStateWithId(variantRuleId)=== "Incompatible"){
								if(!that.configModel.getUserSelectVariantIDs(variantRuleId))
									variantIncompatible = true;
							}

							var mandIcon = UWA.extendElement(document.getElementById('variantRightIcon_' + variantRuleId));
							var refinedIcon = UWA.extendElement(document.getElementById('variantRefinedIcon_' + variantRuleId));

							that.configModel.getFeatureIdWithStatus(variantRuleId) ? unselectedVariants : variantIncompatible ? unselectedVariants : unselectedVariants++;
							if(rules){
								that.configModel.getFeatureIdWithRulesStatus(variantRuleId) && !variantIncompatible ? rulesVariants++ : rulesVariants;
							}
							that.configModel.getFeatureIdWithChosenStatus(variantRuleId) ? chosenVariant++ : chosenVariant;

							var mandvariant = that.configModel.getFeatureIdWithMandStatus(variantRuleId);
							var includedState = that.configModel.getIncludedState(variantRuleId);
							mandvariant && !variantIncompatible ? mandVariants++ : mandVariants;

							if(mandIcon){
								mandvariant ? mandIcon.addClassName("fonticon-attention") : mandIcon.removeClassName("fonticon-attention");
							}
							if(refinedIcon){
								var includedState = that.configModel.getIncludedState(variantRuleId);
								includedState ?  refinedIcon.show() : refinedIcon.hide();
							}
							if(that.variantCompList[i] && !variantIncompatible)countVariants++;
					}
				}
				var conflicts = rules ? that.configModel.getNumberOfConflictingFeatures() : 0;
				that.configModel.setVariants(countVariants);
				that.configModel.setNumberOfConflictingFeatures(conflicts);
				that.configModel.setNumberOfMandFeaturesNotValuated(mandVariants);
				that.configModel.setNumberOfFeaturesNotValuated(unselectedVariants);
				that.configModel.setNumberOfFeaturesByRules(rulesVariants);
				that.configModel.setNumberOfFeaturesChosen(chosenVariant);

				that.updateVariantList();
			};

			VariantListPresenter.prototype.updateVariantList = function(){
				this.modelEvents.publish({ event: "updateExclusions", data:{activated:'true'} });

				var currentFilter = this.configModel.getCurrentFilter(),event;
				switch (currentFilter) {
					case ConfiguratorVariables.Filter_AllVariants:
						event = "OnAllVariantFilterIconClick";
						break;
					case ConfiguratorVariables.Filter_Conflicts:
						event = "OnConflictIconClick";
						break;
					case ConfiguratorVariables.Filter_Rules:
							event = "OnRuleNotValidatedIconClick";
							break;
					case ConfiguratorVariables.Filter_Mand:
							if(this._mandatory < this.configModel.getNumberOfMandFeaturesNotValuated())
							event = "onMandVariantIconClick";
							break;
					case ConfiguratorVariables.Filter_Unselected:
							event = "OnUnselectedVariantIconClick";
							break;
					case ConfiguratorVariables.Filter_Chosen:
							event = "onChosenVariantIconClick";
							break;
					default:
				}
				this.modelEvents.publish({ event: event, data:{activated:'updateAddition'} });
			};

			VariantListPresenter.prototype.applyVariantListFilters = function(data){
				this.modelEvents.publish({ event: "OnFilterResult", data:data });
			};

			return VariantListPresenter;
		});

define(
		'DS/ConfiguratorPanel/scripts/Presenters/TopbarPresenter',
		[
			'UWA/Core',
			'DS/Handlebars/Handlebars',
			'DS/UIKIT/Iconbar',
			'DS/UIKIT/Tooltip',
			'DS/Core/ModelEvents',
			'DS/ResizeSensor/js/ResizeSensor',
			'DS/ENOXViewFilter/js/ENOXViewFilter',
			'DS/UIKIT/Input/Button',
			'DS/UIKIT/DropdownMenu',
			'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
			'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json',
			'text!DS/ConfiguratorPanel/html/TopbarPresenter.html',
			"css!DS/ConfiguratorPanel/css/TopbarPresenter.css"
			],
			function (UWA,Handlebars,Iconbar, Tooltip, ModelEvents,ResizeSensor,
				ENOXViewFilter,Button,DropdownMenu,ConfigVariables, NLS_ConfiguratorPanel, html_TopbarPresenter)
			{
			'use strict';

			Handlebars.registerHelper('check_3D', function(currentType, opts) {
				if(currentType == 'yes')
					return opts.fn(this);
				else
					return opts.inverse(this);
			});

			Handlebars.registerHelper('topbar_sort_type_check', function(currentType, compareToType, opts) {
				if(currentType == compareToType)
					return opts.fn(this);
				else
					return opts.inverse(this);
			});

			var template = Handlebars.compile(html_TopbarPresenter);

			var TopbarPresenter = function (options) {
				this._init(options);
			};

			/*********************************************INITIALIZATION************************************************************************/

			TopbarPresenter.prototype._init = function(options){
				var _options = options ? UWA.clone(options, false) : {};
				_options.add3DButton = _options.add3DButton ? _options.add3DButton : "no";
				UWA.merge(this, _options);
				this.allowRefine = this.configModel._appFunc.selectionMode_Refine;
				this.sort = [{id : "displayName", type : "string"}, {id : "sequenceNumber", type : "number"}];
				if(this.configModel.getSelectionMode() === "selectionMode_Refine"){
					this._unselectedBaseClassName = "wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-option-infinite";
				}else{
					this._unselectedBaseClassName = "wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-option-empty";
				}
				this._subscribeToEvents();
				this._initDivs();
				this.inject(_options.parentContainer);
				this._updateFilterIcon(this._allVariants);
				this.configModel.setCurrentFilter(ConfigVariables.Filter_AllVariants);
				this.modelEvents.publish({ event: "OnAllVariantFilterIconClick", data:{activated:true} });

				this._filterAllVariants();
				this._filterUnselectedVariants();
				this._filterRuleVariants();
				this._filterMandVariants();
				this._filterChosenVariants();
				this._filterConflictingVariants();

				this._searchVariants();
        if(this.enableSwitchView) {
          this._addSwitchViewHandler();
        }
				this._sortVariants();
				this._findRuleAssistanceLevels({callsolve : false});
				this._render3DVariants();
			};

			TopbarPresenter.prototype._initDivs = function(){
				this._container = document.createElement('div');
				this._container.innerHTML = template(this);

				this._container = this._container.querySelector('.topbar-wrapperContainer');

				this._allVariants = this._container.querySelector('#topbar-all-variants');
				this._unselectedVariants = this._container.querySelector('#topbar-unselected-variant');
				this._refineEnabled = this._container.querySelector('.topbar-refine-enabled');
				this._ruleVariants = this._container.querySelector('#topbar-rule-variants');
				this._mandVariants = this._container.querySelector('#topbar-mand-variants');
				this._chosenVariants = this._container.querySelector('#topbar-chosen-variants');
				this._conflictingVariants = this._container.querySelector('#topbar-conflicting-variants');
				this._conflictingVariants.style.display = "none";
				this._searchVariant = this._container.querySelector('#topbar-search-variants');
        if(this.enableSwitchView === true) {
            this._switchView = this._container.querySelector('#topbar-toggle-view');
						this._switchViewTooltip = new Tooltip({target: this._switchView, body: NLS_ConfiguratorPanel.Switch_DataGridView, trigger: 'touch'});
        } else {
            this._container.querySelector('#topbar-toggle-view').remove();
        }
				this._sortVariant = this._container.querySelector('#topbar-sort-variants-base');

				this._rulesAssistance = this._container.querySelector('#topbar-rules-assistance');
				// this._currentRuleAssistanceIcon = this._container.querySelector('#topbar-rule-assistance-level-icon');
				this._currentRuleAssistanceIcon = this._container.querySelector('.topbar-sup-span');
				this._searchContainer = this._container.querySelector('.topbar-MidMenu-Container');
				this._3DVariants = this._container.querySelector('#topbar-3D-button');
				this._unselectedBase = this._container.querySelector('#topbar-unselected-base');
				this._allVariantsSub = this._container.querySelector('#topbar-all-variants-sub');
				this._unselectedvariantSub = this._container.querySelector('#topbar-unselected-variant-sub');
				this._rulevariantSub = this._container.querySelector('#topbar-rule-variants-sub');
				this._mandVariantSub = this._container.querySelector('#topbar-mand-variants-sub');
				this._chosenVariantSub = this._container.querySelector('#topbar-chosen-variants-sub');
				this._conflictVariantSub = this._container.querySelector('#topbar-conflicting-variants-sub');

				new Tooltip({target: this._allVariants,body: NLS_ConfiguratorPanel.Filter_AllVariants, trigger: 'touch'});
				new Tooltip({target: this._unselectedVariants,body: NLS_ConfiguratorPanel.Filter_Unselected, trigger: 'touch'});
				new Tooltip({target: this._ruleVariants,body: NLS_ConfiguratorPanel.Filter_Rules, trigger: 'touch'});
				new Tooltip({target: this._mandVariants,body: NLS_ConfiguratorPanel.Filter_Mand, trigger: 'touch'});
				new Tooltip({target: this._conflictingVariants,body: NLS_ConfiguratorPanel.Filter_Conflicts, trigger: 'touch'});
				new Tooltip({target: this._chosenVariants, body: NLS_ConfiguratorPanel.Filter_Chosen, trigger: 'touch'});
				new Tooltip({target: this._sortVariant, body: NLS_ConfiguratorPanel.Filter_Sort, trigger: 'touch'});
				new Tooltip({target: this._searchVariant, body: NLS_ConfiguratorPanel.Filter_Search, trigger: 'touch'});

			};

			TopbarPresenter.prototype.inject= function(parentcontainer) {
				var that = this;
				parentcontainer.appendChild(this._container);
				new ResizeSensor(this._container, function () {
					that._resize();
				});
			};

			/*********************************************EVENT HANDLING - UPDATE COUNTER*******************************************************/

			TopbarPresenter.prototype._subscribeToEvents = function() {
				var that = this;
				this.modelEvents.subscribe({event:'checkModelConsistency_SolverAnswer'},function(data){
					if(data.answerRC === "Rules_KO"){
						var ruleLevel = that._find(that._ruleLevels, ConfigVariables.NoRuleApplied);
						that._currentRuleAssistanceLevel = ConfigVariables.NoRuleApplied;
						that._currentRuleAssistanceIcon.className = ruleLevel.icon;
						that._setRulesAssistanceLevel();
						that._ruleAssistanceDD.items.forEach(function(item){
							if(item.id !== ConfigVariables.NoRuleApplied){
								that._ruleAssistanceDD.disableItem(item.id);
							}else{
								that._ruleAssistanceDD.toggleSelection(item);
							}
						});
					}
				});
			};

			/*********************************************ALL VARIANTS IN TOPBAR************************************************************/
			TopbarPresenter.prototype._filterAllVariants = function() {
				var that = this;
				this.modelEvents.subscribe({event:'OnAllVariantNumberChange'},function(data){
					that._allVariantsSub.innerHTML = data.value;
					that._allVariants.style.display = data.value === 0 ? "none" : "inline-block";
				});
				this._allVariants.onclick = function(){
					that._updateFilterIcon(that._allVariants);
					that.configModel.setCurrentFilter(ConfigVariables.Filter_AllVariants);
					that.modelEvents.publish({ event: "OnAllVariantFilterIconClick", data:{activated:true} });
				}
			}

			/*********************************************UNSELECTED VARIANTS IN TOPBAR*****************************************************/
			TopbarPresenter.prototype._filterUnselectedVariants = function() {
				var that = this;
				this.modelEvents.subscribe({event:'OnUnselectedVariantNumberChange'},function(data){
					that._unselectedvariantSub.innerHTML = data.value;
				});
				var refineAllowed = this._container.querySelector('.topbar-refine-mode');
				if(refineAllowed){
					this._refineModeDD = new DropdownMenu({
						target: refineAllowed,
						renderTo:this.parentContainer,
						items : [{id : "refine",text : "150%",icon : "fonticon fonticon-infinity"}],
						events: {
							onClick: function(e, item){
								if(that.configModel.getSelectionMode() === "selectionMode_Refine"){
									that._unselectedBase.className = "wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-option-empty";
									that.configModel.setSelectionMode(ConfigVariables.selectionMode_Build);
								}else{
									that._unselectedBase.className = "wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-option-infinite";
									that.configModel.setSelectionMode(ConfigVariables.selectionMode_Refine);
								}
								that.modelEvents.publish({
									event: "OnConfigurationModeChange",
									data : {mode : that.configModel.getSelectionMode()}
								});
							}
						}
					});
					this._refineModeDD.getItem(0).elements.container.addClassName("topbar-drpdown-item");
					this._refineModeDD.getItem(0).elements.container.children[1].addContent("<p class='topbar-drpdown-content'>" + NLS_ConfiguratorPanel.Refine_mode_description +"</p>");
				}
				this._unselectedVariants.onclick = function(){
						that._updateFilterIcon(that._unselectedVariants);
						that.configModel.setCurrentFilter(ConfigVariables.Filter_Unselected);
						that.modelEvents.publish({ event: "OnUnselectedVariantIconClick", data:{activated:true} });
				}
			};

			/*********************************************RULE VARIANTS IN TOPBAR*****************************************************/
			TopbarPresenter.prototype._filterRuleVariants = function() {
				var that = this;
				this.modelEvents.subscribe({event:'OnRuleNotValidatedNumberChange'},function(data){
					that._rulevariantSub.innerHTML = 	data.value;
					// that._ruleVariants.style.display = data.value === 0 ? "none" : "inline-block";
				});
				this._ruleVariants.onclick = function(e){
					if(e.target !== that._rulesAssistance){
					that._updateFilterIcon(that._ruleVariants);
					that.configModel.setCurrentFilter(ConfigVariables.Filter_Rules);
					that.modelEvents.publish({ event: "OnRuleNotValidatedIconClick", data:{activated:true} });
					}
				}
			}

			/*********************************************MAND VARIANTS IN TOPBAR*****************************************************/
			TopbarPresenter.prototype._filterMandVariants = function() {
				var that = this;
				this.modelEvents.subscribe({event:'OnMandVariantNumberChange'},function(data){
					that._mandVariantSub.innerHTML = data.value;
					that._mandVariants.style.display = data.value === 0 ? "none" : "inline-block";
				});
				this._mandVariants.onclick = function(){
					that._updateFilterIcon(that._mandVariants);
					that.configModel.setCurrentFilter(ConfigVariables.Filter_Mand);
					that.modelEvents.publish({ event: "onMandVariantIconClick", data:{activated:true} });
				}
			}

			/*********************************************CHOSEN VARIANTS IN TOPBAR*****************************************************/
			TopbarPresenter.prototype._filterChosenVariants = function() {
				var that = this;
				this.modelEvents.subscribe({event:'OnChosenVariantNumberChange'},function(data){
					that._chosenVariantSub.innerHTML = data.value;
					that._chosenVariants.style.display = data.value === 0 ? "none" : "inline-block";
				});
				this._chosenVariants.onclick = function(){
					that._updateFilterIcon(that._chosenVariants);
					that.configModel.setCurrentFilter(ConfigVariables.Filter_Chosen);
					that.modelEvents.publish({ event: "onChosenVariantIconClick", data:{activated:true} });
				}
			}

			/*********************************************CONFLICTING VARIANTS IN TOPBAR*************************************************/
			TopbarPresenter.prototype._filterConflictingVariants = function() {
				var that = this;
				this.modelEvents.subscribe({event:'OnConflictVariantNumberChange'},function(data){
					that._conflictVariantSub.innerHTML = data.value;
					that._conflictingVariants.style.display = data.value === 0 ? "none" : "inline-block";
				});
				this._conflictingVariants.onclick = function(){
					that._updateFilterIcon(that._conflictingVariants);
					that.configModel.setCurrentFilter(ConfigVariables.Filter_Conflicts);
					that.modelEvents.publish({ event: "OnConflictIconClick", data:{activated:true} });
				}
			}

			/*********************************************SEARCH IN TOPBAR*****************************************************************/
			TopbarPresenter.prototype._searchVariants = function() {
				var that = this;
				if(!this.searchComponent){
					var filterOptions = {
							allowMultipleSearch:true,
							parentContainer : this._searchContainer,
							onSearch: function(values){
								that.modelEvents.publish({ event: 'OnSearchResult', data:values});
							}
					};
					this.searchComponent = new ENOXViewFilter(filterOptions);
				}

				this._searchVariant.onclick = function(){
					that._searchContainer.style.display = that._searchContainer.style.display !== "inline-block" ? "inline-block" : "none";
					that._resize();
					var activeSearch = that._searchContainer.style.display === "none" ? false: true;
					activeSearch ? that._searchVariant.classList.add('topbar-icon-selected') : that._searchVariant.classList.remove('topbar-icon-selected');
					that.configModel.setSearchStatus(activeSearch);
					if(!activeSearch){
						that.searchComponent.reset();
					}
				}
			}

			/*********************************************SORT IN TOPBAR*****************************************************************/

			TopbarPresenter.prototype._sortVariants = function() {
				var that = this;
				this._sortVariant.className = "fonticon fonticon-fonticon fonticon-sorting";
				this._sortDropdown = new DropdownMenu({
					target: this._sortVariant,
					// renderTo : this.parentContainer,
					items: [{id : "displayName",className:"topbar-sort-item", text: NLS_ConfiguratorPanel.Sort_DisplayName },
									{id : "sequenceNumber",className:"topbar-sort-item", text: NLS_ConfiguratorPanel.Sort_SequenceNo }],
					events : {
						onClick : function(e, i){
							var sortOrder = "", sortAttribute = i.id;
							var target = UWA.extendElement(e.target);
							if(target.hasClassName('fonticon')){
								that._sortVariant.set('class', target.className);
								if(target.hasClassName('order-desc')) sortOrder = "DESC";
								else if(target.hasClassName('order-asc')) sortOrder = "ASC";
							}
							that.modelEvents.publish({event: 'OnSortResult', data : {sortOrder : sortOrder, sortAttribute: sortAttribute}});
						}
					}
				});
				for(var i = 0; i < this._sortDropdown.items.length ; i++){
					var _sortRow = this._container.querySelector('#topbar-sort-item-' + this._sortDropdown.items[i].id);
					this._sortDropdown.items[i].elements.container.appendChild(_sortRow);
				}

			}

			/*********************************************RULE ASSISTANCE IN TOPBAR************************************************************/

			TopbarPresenter.prototype._findRuleAssistanceLevels = function(options) {
				this._ruleLevels = [];
				var appFunc = this.configModel.getAppFunc();
				var ruleActivation = this.configModel.getRulesActivation();

				this._ruleLevels.push({id : ConfigVariables.NoRuleApplied,text : " " + NLS_ConfiguratorPanel["No rule applied"],icon : "wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-shield-empty",desc : ""});

				if(appFunc["rulesMode_DisableIncompatibleOptions"] === "yes"){
					this._ruleLevels.push({id : "RulesMode_DisableIncompatibleOptions", text : " " + NLS_ConfiguratorPanel["Compatible"], icon : "wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-shield-1",desc : NLS_ConfiguratorPanel.descCompatible});

					if(appFunc["rulesMode_EnforceRequiredOptions"] === "yes"){
						this._ruleLevels.push({id : "RulesMode_EnforceRequiredOptions",text : " " + NLS_ConfiguratorPanel["Enforced/Infilled"],icon : "wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-shield-2",desc : NLS_ConfiguratorPanel.descEnforced});

						if(appFunc["rulesMode_SelectCompleteConfiguration"] === "yes"){
							this._ruleLevels.push({id : "RulesMode_SelectCompleteConfiguration",text : " " + NLS_ConfiguratorPanel["Complete/Fulfilled"],icon : "wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-shield-3",desc : NLS_ConfiguratorPanel.descComplete});

							if(appFunc["rulesMode_ProposeOptimizedConfiguration"] === "yes"){
								this._ruleLevels.push({id : "RulesMode_ProposeOptimizedConfiguration",text : " " + NLS_ConfiguratorPanel["Optimized"],icon : "wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-shield-full",desc : NLS_ConfiguratorPanel.descOptimized});
							}
						}
					}
				}
				var ruleLevel = this._find(this._ruleLevels, this.configModel.getRulesMode());
				this._currentRuleObj = (ruleActivation === "true" && ruleLevel) ? ruleLevel : this._ruleLevels[0];
				this._currentRuleAssistanceIcon.className = this._currentRuleObj.icon;
				this._currentRuleAssistanceLevel = this._currentRuleObj.id;
				this._createRulesAssistanceDD();
				this._setRulesAssistanceLevel(options);
			};

			TopbarPresenter.prototype._createRulesAssistanceDD = function(icon, iconClass, selectedIconClass, itemsMap, handler){
				var that = this;
				if((!this._ruleAssistanceDD) && (this._ruleLevels.length > 1)){
					this._ruleAssistanceDD = new DropdownMenu({
						target: this._container.querySelector('#topbar-rules-assistance'),
						renderTo:this.parentContainer,
						items : [],
						events: {
							onClick: function(e, item){
								that._currentRuleAssistanceLevel = item.id;
								that._currentRuleAssistanceIcon.className = item.icon;
								that._setRulesAssistanceLevel();
							}
						}
					});
					for(var i = 0; i < this._ruleLevels.length ; i++){
						var j = this._ruleLevels.length - 1 - i; //to enter highest level first in DD
						this._ruleAssistanceDD.addItem(this._ruleLevels[j]);
						this._ruleAssistanceDD.getItem(i).elements.container.addClassName("topbar-drpdown-item");
						this._ruleAssistanceDD.getItem(i).elements.container.children[1].addContent("<p class='topbar-drpdown-content'>"+this._ruleLevels[j].desc+"</p>");
					}
				}
			};

			TopbarPresenter.prototype._setRulesAssistanceLevel = function(options){
				var solveCallback = options ? options.callsolve : true;
				var ruleActivation = (this._currentRuleAssistanceLevel === ConfigVariables.NoRuleApplied) ? ConfigVariables.str_false : ConfigVariables.str_true;
				// ruleActivation === ConfigVariables.str_true ? this._rulesAssistance.classList.add('topbar-icon-selected') : this._rulesAssistance.classList.remove('topbar-icon-selected');
				this.configModel.setRulesActivation(ruleActivation);
				this.configModel.setRulesMode(this._currentRuleAssistanceLevel);
				if(solveCallback){
					this.modelEvents.publish({ event: "OnRuleAssistanceLevelChange", data:	{value : this._currentRuleAssistanceLevel, callsolve :solveCallback} });
				}
			}

			/*********************************************3D IN TOPBAR*****************************************************************/
			TopbarPresenter.prototype._render3DVariants = function() {
				var that = this;
				if(this._3DVariants){
				this._3DVariants.onclick = function(){
					UWA.extendElement(that._3DVariants);
					that._3DVariants.hasClassName("topbar-icon-selected") ? that._3DVariants.classList.remove('topbar-icon-selected') : that._3DVariants.classList.add('topbar-icon-selected');
					var activeStatus = that._3DVariants.hasClassName("topbar-icon-selected") ? true : false;
					that.modelEvents.publish({ event: "Request3DFromConfigPanel", data:{ value: (activeStatus === true) ? "show" : "hide" } });
					}
				}
			}

			/*******************************************************UILITIES IN TOPBAR*************************************************************/

			TopbarPresenter.prototype._find = function (array, id) {
				if(array){
					var match;
					array.forEach(function(item){
						if(item.id === id){ match = item; return;}
					});
					return match ? match : array[0];
				}
			};

			TopbarPresenter.prototype._updateFilterIcon = function (currentFilter) {
				this.filters = this._container.querySelectorAll('.topbar-filter') ? this._container.querySelectorAll('.topbar-filter') : [];
				for(var i =0 ;i<this.filters.length ; i++){
					this.filters[i].classList.remove('topbar-filter-selected');
					//Commented due modified requirement - icon should be colored by default and not on click.
					// this.filters[i].classList.remove('topbar-filter-mand-selected');
					// this.filters[i].classList.remove('topbar-filter-conflicts-selected');
				}
				currentFilter.classList.add('topbar-filter-selected');
				//Commented due modified requirement - icon should be colored by default and not on click.
				// if(currentFilter === this._mandVariants)currentFilter.classList.add('topbar-filter-mand-selected');
				// if(currentFilter === this._conflictingVariants)currentFilter.classList.add('topbar-filter-conflicts-selected');
			};

			TopbarPresenter.prototype._resize = function () {
				if(this.searchComponent){
					this.searchComponent.container.removeClassName('topbar-maximize-searchtext');
					this.searchComponent.inject(this._searchContainer);

					if(this._container.offsetHeight > 70){
						this.searchComponent.inject(this._container);
						this.searchComponent.container.addClassName('topbar-maximize-searchtext');
					}
				}
				this.modelEvents.publish({event:"onTopbarHeightChange", data: this._container.offsetHeight })
			};

      TopbarPresenter.prototype._addSwitchViewHandler = function () {
          var that = this;
          if(this._switchView){
              this._switchView.onclick = function(event){
                  if(event) {
                      //"wux-ui-3ds-1x wux-ui-3ds-view-list"
                      var targetBtnSpan = UWA.extendElement(that._switchView.firstElementChild);
                      if(targetBtnSpan.hasClassName("wux-ui-3ds-view-list")){
                          targetBtnSpan.removeClassName("wux-ui-3ds-view-list");
                          targetBtnSpan.addClassName("wux-ui-3ds-view-small-tile");
                          that.modelEvents.publish({ event: "onTopbarSwitchView", data:{ "view": "grid"} });
													that._switchViewTooltip.setBody(NLS_ConfiguratorPanel.Switch_TileView);
                      } else {
                          targetBtnSpan.removeClassName("wux-ui-3ds-view-small-tile");
                          targetBtnSpan.addClassName("wux-ui-3ds-view-list");
                          that.modelEvents.publish({ event: "onTopbarSwitchView", data:{"view": "classic"} });
													that._switchViewTooltip.setBody(NLS_ConfiguratorPanel.Switch_DataGridView);
                      }
                  }
              }
          }
      };
			return TopbarPresenter;
			});


define(
		'DS/ConfiguratorPanel/scripts/Presenters/ConfigEditorPresenter',
		[
			'DS/ConfiguratorPanel/scripts/ConfiguratorSolverFunctionsV2',
			'DS/ResizeSensor/js/ResizeSensor',
			'DS/UIKIT/Mask',
			'DS/UIKIT/Spinner',
			'DS/UIKIT/Scroller',
			'UWA/Core',
			'DS/Handlebars/Handlebars',
			'DS/Core/ModelEvents',
			'DS/UIKIT/Input/Button',
			'DS/UIKIT/Alert',
			'DS/ConfiguratorPanel/scripts/Presenters/VariantListPresenter',
      'DS/ConfiguratorPanel/scripts/Presenters/ConfigGridPresenter',
			'DS/ConfiguratorPanel/scripts/Presenters/TopbarPresenter',
			'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
			'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json',
			'text!DS/ConfiguratorPanel/html/ConfigEditorPresenter.html',
			"css!DS/ConfiguratorPanel/css/ConfigEditorPresenter.css",
			'css!DS/UIKIT/UIKIT.css'
			],
			function (ConfiguratorSolverFunctions, ResizeSensor, Mask,Spinner, Scroller, UWA, Handlebars, ModelEvents, Button, Alert, VariantListPresenter, ConfigGridPresenter, TopbarPresenter, ConfiguratorVariables, NLS_Configurator, html_ConfigEditorPresenter) {
			'use strict';

			var template = Handlebars.compile(html_ConfigEditorPresenter);

			var ConfigEditorPresenter = function (options) {
				this._init(options);
			};

			ConfigEditorPresenter.prototype._init = function(options){
				var that = this;
				var _options = options ? UWA.clone(options, false) : {};
				var defaults = {modelEvents : new ModelEvents(), add3DButton : "no"};	//Default values if not provided by options
				UWA.merge(_options, defaults);
				UWA.merge(this, _options);
				this.dictionary = this.configModel.getDictionary() || {features : []};
				this.modelEvents.unsubscribeAll({event : "onTopbarHeightChange"});
				this.modelEvents.unsubscribeAll({event : "pc-interaction-started"});
				this.modelEvents.unsubscribeAll({event : "pc-interaction-complete"});
				this.modelEvents.unsubscribeAll({event : "init_configurator"});
				this._subscribeEvents();
				that._initDivs();
			};

			ConfigEditorPresenter.prototype._subscribeEvents = function () {
				var that = this;
				this.modelEvents.subscribe({event : "onTopbarHeightChange"}, function(modHeight){
					if(modHeight > 0){
						// modHeight = that.allowSave ? modHeight + that._savePCContainer.offsetHeight + 40 : modHeight;
						that._variantListContainer.style.height = "calc(100% - "+ modHeight + "px)";
                        that._dataGridContainer.style.height = "calc(100% - "+ modHeight + "px)";
					}
				});

				this.modelEvents.subscribe({event:"pc-interaction-started"}, function() {
					Mask.mask(that._container);
					that._maskContainer.style.opacity = 0.5;
				});
				this.modelEvents.subscribe({event:"pc-interaction-complete"}, function() {
					Mask.unmask(that._container);
					that._maskContainer.style.opacity = 1;
					that.modelEvents.publish({event : "pc-changed"});
				});

				this.modelEvents.subscribe({event: 'init_configurator'}, function (data) {
					that.defaultData = data || [];
					that.defaultData.updateView = true;
					if(that.dictionary.features.length > 0) {
                        that._initConfigEditor();
                    }
					that.modelEvents.publish({event:'pc-loaded', data : {}});
				});
                //Switch View handler//
                this.modelEvents.subscribe({event : "onTopbarSwitchView"}, function(evtData) {
                    if(evtData && evtData.view) {
                        if(evtData.view === "classic") {
                            that._variantListContainer.removeClassName('config-editor-display-none');
                            that._variantListContainer.addClassName('config-editor-display-block');
                            that._dataGridContainer.addClassName('config-editor-display-none');
														that.modelEvents.publish({event : "solveAndDiagnoseAll_SolverAnswer" , data : {
															refresh : true
														}});
                        } else if(evtData.view === "grid") {
                            that._dataGridContainer.removeClassName('config-editor-display-none');
                            that._dataGridContainer.addClassName('config-editor-display-block');
														that._cfgGridPresenter.refresh();
                            that._variantListContainer.addClassName('config-editor-display-none');
                        }
                    }
                });
			};

			ConfigEditorPresenter.prototype._initDivs = function () {
				var previous = document.querySelector('#config-editor-container');
				if(previous) previous.parentNode.removeChild(previous);
				this._container = document.createElement('div');
				this._container.innerHTML = template();

				this._container = this._container.querySelector('#config-editor-container');
				UWA.extendElement(this._container);
				this._maskContainer = this._container.children[0];
				this._topbarContainer = this._container.querySelector('#config-editor-topbar');
				this._variantListContainer = this._container.querySelector('#config-editor-variant-list-container');
                this._dataGridContainer =  this._container.querySelector('#config-editor-grid-view-container');
                UWA.extendElement(this._variantListContainer);
                this._variantListContainer.addClassName('config-editor-display-block');
                UWA.extendElement(this._dataGridContainer);
                this._dataGridContainer.addClassName('config-editor-display-none');
				this._savePCContainer = this._container.querySelector('#config-editor-save-configuration');
				this._cancelPCContainer = this._container.querySelector('#config-editor-cancel-configuration');
				this._notificationContainer = this._container.querySelector('#config-editor-notification-container');
			};

			ConfigEditorPresenter.prototype.inject= function(parentcontainer) {
				var that = this;
				if(parentcontainer)parentcontainer.appendChild(this._container);
				if(this.dictionary.features.length > 0){
					this._variantList = this._variantListContainer.querySelector('#config-editor-variant-list');
					this._extendedVariantList = this._container.querySelector('#config-editor-extended-variant-list');
					this._scrollContainer = this._variantListContainer.querySelector('#config-editor-scroll-container');
					new Scroller({element: this._variantList}).inject(this._scrollContainer);
					this._resize();
					that.configuratorToolbar._resize();
					new ResizeSensor(this._container, function () {
						that._resize();
						that.configuratorToolbar._resize();
					});
					that.modelEvents.publish({event:'updateAllFilters', data : that.defaultData});
				}else{
					UWA.extendElement(this._container);
					this._container.setContent(NLS_Configurator.onEmptyConfigurations);
					this._container.addClassName("empty-configuration");
				}
			};

			ConfigEditorPresenter.prototype._resize = function(){
				var components = this.VLPresenter  ? this.VLPresenter.variantCompList : undefined;
				var width = this._extendedVariantList.offsetWidth;
				if(components && components.length > 0){
					for(var i=0;i < components.length; i++){
						components[i]._resize(width);
					}
				}
			}

			ConfigEditorPresenter.prototype._setMultiselection = function(options){
				//set multiselection in case of Unconstrained mode
				if (this.configModel.getAppFunc().multiSelection === ConfiguratorVariables.str_yes || this.configModel.getAppFunc().selectionMode_Refine === ConfiguratorVariables.str_yes) {
					this.modelEvents.publish({event: 'OnMultiSelectionChange',data: {value: true, callsolve : false}});
					this.configModel.setMultiSelectionState("true");
				}else{
					if(this.configModel.getAppRulesParam() && this.configModel.getAppRulesParam().completenessStatus === "Hybrid"){
						var notificationContainer = document.body.querySelector("#config-editor-notification-container");
						if(notificationContainer){
							this.alert = new Alert({
								visible: true,
								autoHide: true,
								hideDelay: 3000
							}).inject(notificationContainer);

							this.alert.elements.container.style.float = 'right';
							this.alert.elements.container.style.top = '0px';
							this.alert.elements.container.style.position = 'relative';
							this.alert.elements.container.style.maxWidth = '350px';
							this.alert.add({
								className: 'warning',
								message: NLS_Configurator.HybridWarningInRealistic
							});
						}
					}
				}
			};

			ConfigEditorPresenter.prototype._initConfigEditor = function(options){
				var that = this;
				var configuratorToolbar = new TopbarPresenter({
					parentContainer : this._topbarContainer,
					modelEvents : this.modelEvents,
					configModel : this.configModel,
					add3DButton: this.add3DButton,
          enableSwitchView : this.enableTableView
				});
				this.configuratorToolbar = configuratorToolbar;

				this.VLPresenter = new VariantListPresenter({
					parentContainer : this._variantListContainer,
					configModel : this.configModel,
					modelEvents : this.modelEvents,
					maskContainer : this.maskContainer
				});
        //GridPresenter init//
        if(this.enableTableView) {
            this._cfgGridPresenter = new ConfigGridPresenter();
            this._cfgGridPresenter.init(this.modelEvents, undefined, {id: this.configModel._pcId, expandAll: true, configModel: this.configModel, previewMode : false });
            // this._cfgGridPresenter.loadModelVariabilityInformation(UWA.clone(this.variabilityDictionary));
            that._cfgGridPresenter.loadConfigurationInfo({'id' : this.configModel._pcId });
            this._cfgGridPresenter.inject(this._dataGridContainer);
        }

				if(this.allowSave === "yes"){
					this._saveBtn = new Button({ value: NLS_Configurator.save, className: 'primary' }).inject(this._savePCContainer);
					this._CancelBtn = new Button({ value: NLS_Configurator.cancel}).inject(this._cancelPCContainer);
					this._saveBtn.addEvent('onClick', function () {
						var configurations = that.configModel.getConfigurationCriteria();
						this.setFocus(false);
						that.modelEvents.publish({event: "onSaveClick", data : configurations});
					});
					this._CancelBtn.addEvent('onClick', function () {
						that.modelEvents.publish({event: "onResetClick"});
						this.setFocus(false);
					});
				}else{
					var persistencyContainer = this._container.querySelector('#config-editor-persistency-container');
					if(persistencyContainer){
						persistencyContainer.style.display = "none";
					}
				}
			};

			ConfigEditorPresenter.prototype.resetProductConfiguration = function(content) {
				this.configModel.setAppRulesParam(content.appRulesParams);
				this.configModel.resetCriteria();
				this.configModel.setConfigurationCriteria(content.configurationCriteria);
				this.configuratorToolbar._findRuleAssistanceLevels();
				this.modelEvents.publish({event : "solveAndDiagnoseAll_SolverAnswer" , data : {refresh : true}});
			};

			ConfigEditorPresenter.prototype.subscribe = function(parameters, callback){
				return this.modelEvents.subscribe(parameters, callback);
			};

			ConfigEditorPresenter.prototype.unsubscribe = function(token){
				this.modelEvents.unsubscribe(token);
			};


			ConfigEditorPresenter.prototype.destroy = function() {
				if(this._cfgGridPresenter && UWA.is(this._cfgGridPresenter.destroy, 'function')) {
					this._cfgGridPresenter.destroy();
				}
			};


			return ConfigEditorPresenter;
		});


define(
	'DS/ConfiguratorPanel/scripts/Presenters/PCPanel',
	[
		'DS/ConfiguratorPanel/scripts/ConfiguratorSolverFunctions',
    'DS/ConfiguratorPanel/scripts/ConfiguratorSolverFunctionsV2',
		'DS/ConfiguratorPanel/scripts/Models/ConfiguratorModel',
    'DS/ConfiguratorPanel/scripts/Presenters/ConfigEditorPresenter',
    'DS/ConfiguratorPanel/scripts/Presenters/ConfiguratorPanelPresenter',
  	'DS/UIKIT/Mask',
		'DS/Handlebars/Handlebars',
		'DS/Core/ModelEvents',
		'DS/ConfiguratorPanel/scripts/Models/ConfiguratorVariables',
		'i18n!DS/ConfiguratorPanel/assets/nls/ConfiguratorPanel.json',
		'text!DS/ConfiguratorPanel/html/PCPanel.html',
		'text!DS/ConfiguratorPanel/assets/ParamatersSampleDico.json',
		"css!DS/ConfiguratorPanel/css/PCPanel.css",
		'css!DS/UIKIT/UIKIT.css'
	],
	function (ConfiguratorSolverFunctions,
    ConfiguratorSolverFunctionsV2,
		ConfiguratorModel,
    ConfigEditorPresenter,
    ConfiguratorPanelPresenter,
    Mask,
		Handlebars,
		ModelEvents,
		ConfiguratorVariables,
		NLS_Configurator,
		html_PCPanel,
		sampleDico) {
	'use strict';

	var template = Handlebars.compile(html_PCPanel);

	var PCPanel = function (configurations, dictionary, modelEvents, options) {
		this._init(configurations, dictionary, modelEvents, options);
	};

	PCPanel.prototype._init = function (configurations, dictionary, modelEvents, options) {
		var that = this;
		this._configurations = configurations || [];
		// this._dictionary = JSON.parse(sampleDico); //dictionary || undefined;
		// this._sampleDictionary = JSON.parse(sampleDico); //dictionary || undefined;
		this._dictionary = dictionary || undefined;
		// this._dictionary.portfolioClasses.member[0].portfolioComponents.member[0].parameters = this._sampleDictionary.portfolioClasses.member[0].portfolioComponents.member[0].parameters;

		var _options = options ? UWA.clone(options, false) : {};
		var defaults = {
			modelEvents: modelEvents || new ModelEvents(),
			add3DButton: "no",
			withTagger: false,
			version: "V4",
			realistic: false,
			rulesActivation : "true",
			ruleLevels: {
				"RulesMode_ProposeOptimizedConfiguration": false,
				"RulesMode_SelectCompleteConfiguration": false,
				"RulesMode_EnforceRequiredOptions": true,
        "RulesMode_DisableIncompatibleOptions" : true,
			},
			tabs: [],
			pCId: "",
			mvId: "",
			initalOptions: {
				initialRuleLevel: '', //'RulesMode_EnforceRequiredOptions'
				initialTab: "all",
				initialMode: "selectionMode_Build"
			},
			tenant: "",
			configCriteria : "{}",
      'enableTableView' : false,
			enableValidation : false
		};
    UWA.merge(_options, defaults);
		UWA.merge(this, _options);
    this._initDivs();
		this._initSolver();
	};

	PCPanel.prototype._initDivs = function () {
		var previous = document.querySelector('#PC-panel-container');
		if (previous)
			previous.parentNode.removeChild(previous);
		this._container = document.createElement('div');
		this._container.innerHTML = template();
		this._container = this._container.querySelector('#PC-panel-container');
	};

	PCPanel.prototype.inject = function (parentcontainer) {
		this.parentcontainer = parentcontainer;
    if (parentcontainer)parentcontainer.appendChild(this._container);
    if(this.myConfigEditor) this.myConfigEditor.inject(this._container);
	};

	PCPanel.prototype.getParent = function () {
		return this.parentcontainer;
	};


	PCPanel.prototype._initSolver = function (options) {
    var that = this;
		this._configModel = this._getConfigModel();
		this.registerSearch();
		var tempOptions = { version: this.version, dictionary: this._dictionary, tenant: this.tenant, parentContainer: this._container};
    this.modelEvents.subscribe({event: 'solver_init_complete'}, function (dataReceived) {
			if(!that.myConfigEditor){
				setTimeout(function(){
					if(that.myConfigEditor){
						clearTimeout() ;
						that.modelEvents.publish({event: 'init_configurator', data : dataReceived});
					}
				},100);
			}else{
				that.modelEvents.publish({event: 'init_configurator', data : dataReceived})
			}
    });

		ConfiguratorSolverFunctionsV2.initSolver(this.mvId, this._configModel, this.modelEvents, this.configCriteria, "", tempOptions).then(
			function (solverData) {
				that._loadConfigEditor();
				// ConfiguratorSolverFunctionsV2.CallSolveMethodOnSolver({firstCall : true})
		});
	};

  PCPanel.prototype._loadConfigEditor = function () {
    this.myConfigEditor = new ConfigEditorPresenter({
        // parentContainer: this._container,
        configModel: this._configModel,
        modelEvents: this.modelEvents,
        add3DButton: this.add3DButton || "no",
        allowSave: this.allowSave || 'no',
        variabilityDictionary: this._dictionary || {},
        'enableTableView' : this.enableTableView
      });
  };

  PCPanel.prototype.getXMLProductConfigurationDefinition = function(){
    return this.myConfigEditor.configModel.getXMLExpression();
  };

	PCPanel.prototype.getConfigmodel = function(){
    return this.myConfigEditor.configModel;
  };

	PCPanel.prototype.resetProductConfiguration = function(content){
		this._content = UWA.merge(this,content);
		this._configurations = content.configurationCriteria;
		this.initalOptions.initialMode = content.selectionMode;
		this.initalOptions.initialRuleLevel = content.rulesMode;
		this.rulesActivation = content.rulesActivation;

		var tempConfigModel = this._getConfigModel();
		content.appRulesParams = tempConfigModel._appRulesParams;
    this.myConfigEditor.resetProductConfiguration(content);
  };



	PCPanel.prototype._getConfigModel = function () {
		return new ConfiguratorModel({
				configuration: this._configurations,
				pcId: this.pCId,
				appRulesParams: {
					multiSelection: this.realistic ? 'false' : 'true',
					selectionMode: this.initalOptions.initialMode,
					rulesMode: this.initalOptions.initialRuleLevel,
					rulesActivation: this.rulesActivation,
					completenessStatus: this.initalOptions.completenessStatus || 'Unknown',
					rulesCompliancyStatus: this.initalOptions.rulesCompliancyStatus || 'Unknown'
				},
				appFunc: {
					multiSelection: this.realistic ? "no" : "yes",
					selectionMode_Build: "yes",
					selectionMode_Refine: this.realistic ? "no" : "yes",
					rulesMode_ProposeOptimizedConfiguration: this.ruleLevels["RulesMode_ProposeOptimizedConfiguration"] ? "yes" : "no",
					rulesMode_SelectCompleteConfiguration: this.ruleLevels["RulesMode_SelectCompleteConfiguration"] ? "yes" : "no",
					rulesMode_EnforceRequiredOptions: this.ruleLevels["RulesMode_EnforceRequiredOptions"] ? "yes" : "no",
					rulesMode_DisableIncompatibleOptions: this.ruleLevels["RulesMode_DisableIncompatibleOptions"] ? "yes" : "no",
				},
				modelEvents: this.modelEvents,
				readOnly: false,
				enableValidation : this.enableValidation
			});
	};

	PCPanel.prototype.registerSearch = function () {
		var that = this;
		if(that.version !== "V4"){
			this.modelEvents.subscribe({event: 'OnSearchResult'}, function (data) {
					that.modelEvents.publish({event : "applyDefaultSearch", data : data});
			});
		}
	};

	PCPanel.prototype.destroy = function () {
		if(this.myConfigEditor && UWA.is(this.myConfigEditor.destroy, 'function')) {
			this.myConfigEditor.destroy();
		}
		ConfiguratorSolverFunctionsV2.releaseSolver();
		delete this._configModel;
		delete this.modelEvents;
	};

	return PCPanel;
});


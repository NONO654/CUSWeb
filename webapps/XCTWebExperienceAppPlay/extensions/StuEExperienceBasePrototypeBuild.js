/**
 * @exports DS/XCTWebExperienceAppPlay/extensions/StuEExperienceBasePrototypeBuild
 **/
define('DS/XCTWebExperienceAppPlay/extensions/StuEExperienceBasePrototypeBuild',
[
	'UWA/Class/Listener',
	'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuCATI3DExperienceObject'
],

// Declaration
function (
	Listener,
	CATI3DExperienceObject,
    StuCATI3DExperienceObject
	) {
	'use strict';

	/**
	 * StuEExperienceBasePrototypeBuild
	 * Base class for play builds. It is a mapping of model objects with Creative SDK instances.
	 * @name DS/XCTWebExperienceAppPlay/extensions/StuEExperienceBasePrototypeBuild
	 * @constructor
	 **/

	var StuEExperienceBasePrototypeBuild = UWA.Class.Listener.extend(
	/** @lends DS/XCTWebExperienceAppPlay/extensions/StuEExperienceBasePrototypeBuild.prototype **/
	{
		init: function () {
			this._instance = null;
			this._creationPromise = null;
		},

		destroy: function () {
		    this._instance = null;
		    this._creationPromise = null;
		},

		Get: function () {
			if (!UWA.is(this._instance)) {
				return this._Create();
			}
			return UWA.Promise.resolve(this._instance);
		},

		GetSync: function () {
			return this._instance;
		},

		_Create: function () {
			var component = this.GetObject();
			var self = this;
			if (!this._creationPromise) {
			    this._creationPromise = UWA.Promise.deferred();
			    component._experienceBase.getManager('CXPWebPlayManager').GetProtobuildFromComponent(component).then(function (iStu) {
			        self._instance = iStu;
			        return self._Fill(iStu);
			    }).then(function () {
			        self._creationPromise.resolve(self._instance);
			        self._creationPromise = null;
			    }).catch(function () {
			        self._creationPromise.resolve(self._instance);
			        self._creationPromise = null;		        
			    });
			}
			return this._creationPromise.promise;
		},

		_Fill: function (iInstance) {
		    iInstance.CATI3DExperienceObject = new StuCATI3DExperienceObject(this.GetObject(), iInstance);
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');

			var self = this;
			return this._setParent(iInstance).done(function () {
			    return self._Project(iInstance, experienceObject, '_varName', 'name');
			}).done(function () {
			    var promises = [];
			    var allVariablesNames = [];
			    experienceObject.ListVariables(allVariablesNames, CATI3DExperienceObject.VarType.All);
			    for (var i = 0; i < allVariablesNames.length; i++) {
			        promises.push(self._Project(iInstance, experienceObject, allVariablesNames[i], allVariablesNames[i]));
			    }
			    return UWA.Promise.all(promises);
			});
		},

		_setParent: function (iInstance) {
		    var cxpObject = this.QueryInterface('CATICXPObject');
		    if (cxpObject) {
		        var parent = cxpObject.GetFatherObject();
		        if (parent) {
		            return parent.QueryInterface('StuIPrototypeBuild').Get().done(function (parentSdk) {
		                if (parentSdk && iInstance.parent !== parentSdk && iInstance.setParent) {
		                    iInstance.setParent(parentSdk);
		                }
		            });
		        }
		    }
		    return UWA.Promise.resolve();
		},

		_Project: function (iInstance, iExperienceObject, iComponentVarName, iSdkVarName) {
		    var self = this;
			return this._BuildProjectValue(iExperienceObject, iComponentVarName).done(function (value) {
			    var projectValue = iInstance.CATI3DExperienceObject.GetValueByName(iComponentVarName);
			    if (UWA.is(projectValue)) {
			        iInstance[iSdkVarName] = projectValue;
			    }

			    //self._DefineProperty(iExperienceObject, iInstance, iComponentVarName, iSdkVarName);
			});			
		},

		_BuildProjectValue: function (iExperienceObject, iComponentVarName) {
		    if (iExperienceObject.GetVariableType(iComponentVarName) === CATI3DExperienceObject.VarType.Object) {
		        var value = iExperienceObject.GetValueByName(iComponentVarName);
		        if (Array.isArray(value)) {
		            var promises = [];
		            for (var i = 0; i < value.length; ++i) {
		                if (value[i].QueryInterface && value[i].QueryInterface('StuIPrototypeBuild')) {
		                    promises.push(value[i].QueryInterface('StuIPrototypeBuild').Get());
		                }
		            }
		            return UWA.Promise.all(promises)
		        } else {
		            if (value && value.QueryInterface && value.QueryInterface('StuIPrototypeBuild')) {
		                return value.QueryInterface('StuIPrototypeBuild').Get();
		            }
		        }
		    }
		    return UWA.Promise.resolve();		   
		},

		//_DefineProperty: function (iExperienceObject, iInstance, iComponentVarName, iSdkVarName) {
		//    var propertyDescriptor = Object.getOwnPropertyDescriptor(iInstance, iSdkVarName);
		//    var sdkSetter, sdkGetter;
		//    if (propertyDescriptor) {
		//        if (propertyDescriptor.set) {
		//            sdkSetter = propertyDescriptor.set;
		//        }
		//        if (propertyDescriptor.get) {
		//            sdkGetter = propertyDescriptor.get;
		//        }
		//    }
        //
		//    var self = this;
		//    Object.defineProperty(iInstance, iSdkVarName, {
		//        enumerable: true,
		//        configurable: true,
		//        get: function () {
		//            if (sdkGetter) {//call sdk getters
		//                return sdkGetter.call(this);
		//            }
		//            return iInstance.CATI3DExperienceObject.GetValueByName(iComponentVarName);
		//        },
		//        set: function (value) {
		//            if (sdkSetter) { //call sdk setters
		//                sdkSetter.call(this, value);
		//                return;
		//            }
		//            iInstance.CATI3DExperienceObject.SetValueByName(iComponentVarName, value)		            
		//        }
		//    });
		//},

		/** 
		 * destroy _instance object and listener
		 * This method is called recursively on all children	
		 * @public
		 **/
		Free: function () {
		    this._instance = null;
		    this._creationPromise = null;
			this.stopListening();
			var variablesObject = [];
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');
			experienceObject.ListVariables(variablesObject, CATI3DExperienceObject.VarType.Object);
			for (var i = 0; i < variablesObject.length; i++) {
			    var variableInfo = experienceObject.GetVariableInfo(variablesObject[i]);
			    if (variableInfo.valuationMode === CATI3DExperienceObject.ValuationMode.AggregatingValue) {
			        var value = experienceObject.GetValueByName(variablesObject[i]);
					if (value) {
						if (Array.isArray(value)) {
							for (var indexValue = 0; indexValue < value.length; indexValue++) {
								if ((value[indexValue].QueryInterface) && (value[indexValue].QueryInterface('StuIPrototypeBuild'))) {
									value[indexValue].QueryInterface('StuIPrototypeBuild').Free();
								}
							}
						} else {
							if ((value.QueryInterface) && (value.QueryInterface('StuIPrototypeBuild'))) {
								value.QueryInterface('StuIPrototypeBuild').Free();
							}
						}
					}
				}
			}
		}
	});
	return StuEExperienceBasePrototypeBuild;
});

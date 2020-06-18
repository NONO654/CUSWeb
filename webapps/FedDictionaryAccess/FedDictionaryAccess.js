/*global define*/
/*jslint nomen: true */
/*jslint plusplus: true*/
define('DS/FedDictionaryAccess/FedDicoUtils',
  ['DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
    'text!DS/FedDictionaryAccess/assets/FedDicoSettings.json'],

  function (PlatformServices, DicoSettings) {

    "use strict";

    // private data
    var _3DExpPatformServices = [];
    var _RDFPilar = "";
    var _RDFPPVersion = "v0";
    var _hardcodedURL = "";
    var _myAppsConfig = {};

    var dicoUtils = {

      /* getPlatformServices() Returns:
       [{ "platformId": "R1132100081733",
        "displayName": " R1132100081733-US-West",
        "3DSpace": "https://R1132100081733-eu1-417nbl0718-3dspace.3dexperience.3ds.com/3DSpace",
        "3DPassport": "https://iam.ppd.3ds.com",
        "usersgroup": "https://R1132100081733-eu1-417nbl0718-usersgroup.3dexperience.3ds.com/3drdfpersist"
        }, ... ]
       */
      dicoElemsBaseKey: "dicoElements_", 

      dicoPropValuesBaseKey: "dicoPropValues_",

      initSrvRequest: function () {
        var dicoSettings = JSON.parse(DicoSettings);
        var ontoService = dicoSettings.CloudOntologyService;
        _RDFPilar = dicoSettings.RDFPilar;
        _RDFPPVersion = dicoSettings.RDFPPVersion;
        _hardcodedURL = dicoSettings.RDFServerURL;

        if (!_RDFPilar){
          _RDFPilar = "3drdfpersist";
        }
        if (!_RDFPPVersion){
          _RDFPPVersion = "v0";
        }
        PlatformServices.getPlatformServices(
          {
            config: _myAppsConfig,

            onComplete: function (data) {
              // dicoUtils.setPatformServices(data); //
              _3DExpPatformServices = data;
              console.info('Call to PlatformServices.getPlatformServices completed successfully.');
              if (data && data.length === 1 && data[0].platformId === 'OnPremise' && !_hardcodedURL) {
                console.info('  >>> Environment is On Premise.');
                ontoService = "3DSpace";
              }
            },

            onFailure: function (data) {
              console.error('Call to PlatformServices.getPlatformServices failed : ' + data);
            }
          });
        return ontoService;
      },

      setMyAppsConfig: function(options){ 
        _myAppsConfig = {}; 
        _myAppsConfig.myAppsBaseUrl = options.myAppsBaseUrl;
        _myAppsConfig.userId = options.userId;
        _myAppsConfig.lang = options.lang;
      }, 

      isWithoutAuth: function(){
        var dicoSettings = JSON.parse(DicoSettings);
        if (dicoSettings.isRDFWithAuth && dicoSettings.isRDFWithAuth === "false"){
          return true;
        }
        return false;
      },

      isRDFOn3DSpace: function (options) {
        var dicoSettings = JSON.parse(DicoSettings);
        if (options.tenantId === "OnPremise" && options.OnPremiseWith3DRDF === "true"){
          //console.log('*** INFO: E4All Environment: RDF on RDFKernel!');
          return false;
        }

        if (options.tenantId && options.tenantId.startsWith("ODTService@") && options.OnPremiseWith3DRDF === "true"){
          //console.log('*** INFO: ODT Environment: RDF on RDFKernel!');
          return false;
        }

        if (dicoSettings.RDFFedVocabulariesOn3DSpace === "true" || options.tenantId === "OnPremise") {
            //console.log('*** INFO: RDF on 3DSpace.');
            return true;
        }
        return false;
      },

      getServiceBaseURLPromise: function(service, tenantId, option) {
        var that = this;
        return new Promise(function(resolve, reject){       
          var url;
          if (option && option.startsWith("ODTService@")) {
            if (service === "3DSpace"){
              resolve(option.substring(11) + "/resources/6WVocab/access/");
            } else {
              resolve(option.substring(11) + 'v0/invoke/');
            }
          }
          else if (!_3DExpPatformServices || _3DExpPatformServices.length === 0){
            PlatformServices.getPlatformServices(
              {
                config: _myAppsConfig,

                onComplete: function (data) {
                  _3DExpPatformServices = data;
                  console.info('Call to PlatformServices.getPlatformServices completed successfully.');
                  if (data && data.length === 1 && data[0].platformId === 'OnPremise' && !_hardcodedURL) {
                    console.info('  >>> Environment is On Premise.');
                  }
                  url = that.getServiceBaseURL(service, tenantId, option);
                  return resolve(url);
                },
    
                onFailure: function (data) {
                  console.error('Call to PlatformServices.getPlatformServices failed: ' + data);
                  return reject(data);
                }
              });
          } else {
            url = that.getServiceBaseURL(service, tenantId, option);
            return resolve(url);
          }
        });
      },

      getServiceBaseURL: function (service, tenantId, option) {
        if (option && option.startsWith("ODTService@")) {
          if (service === "3DSpace"){
            return option.substring(11) + "/resources/6WVocab/access/";
          }
          return option.substring(11) + 'v0/invoke/';
        }
        if (tenantId === null){
          console.warn('*** Warning: tenant id not specified by caller!');
        }
        var srvURL;
        for (var i = 0; i < _3DExpPatformServices.length; i++) {
          if (_3DExpPatformServices[i].platformId === tenantId) {
            srvURL = _3DExpPatformServices[i][service];
            if (typeof srvURL === "undefined" && service === "3DSpace") {
              console.warn('*** Warning: Service 3DSpace not available, consider 6WTag for BI.');
              // if 3DSpace URL not returned, on cloud use 3DDrive and onpremise 6WTags
              if (tenantId === 'OnPremise'){
                srvURL = _3DExpPatformServices[i]["6WTags"];
              }
              else {
                srvURL = _3DExpPatformServices[i]["3DDrive"];
              }
            }
            // SGA5: check if RDF service, in this case return srvURL with pilar
            else if (tenantId !== 'OnPremise' && this.isRDFService(service)){
              return srvURL + "/" + _RDFPilar + "/" + _RDFPPVersion + "/invoke/";
            }
            if (typeof srvURL === "undefined"){
              console.warn('*** Warning: Service not available: ' + service);
            }
            break;
          }
        }
        if (srvURL === null || (typeof srvURL === "undefined")) {
          console.warn('*** Warning: Tenant or service not recognized by 3DCompass: ' + tenantId + '|' + service);
          // Workaround for OnPremise (E4A env.)
          for (var p in _3DExpPatformServices) {
            if (_3DExpPatformServices[p].platformId === 'OnPremise') {
              if (option) {
                srvURL = option;
                _3DExpPatformServices[p][service] = option;
              }
              else if (_hardcodedURL){
                srvURL = _hardcodedURL;
                _3DExpPatformServices[p][service] = _hardcodedURL;
              }
              // 3DSpace URL should be retrieved
              else if (service !== "3DSpace") {
                srvURL = _3DExpPatformServices[p]["3DSpace"];
                _3DExpPatformServices[p][service] = srvURL;
              }
              break;
            }
          }
        }
        if (service === "3DSpace"){
          srvURL = srvURL + "/resources/6WVocab/access/";
        }
        return srvURL;
      },

      get3DSpaceBaseURLPromise: function (tenantId) {
        if (tenantId && tenantId.startsWith("ODTService@")){
          return this.getServiceBaseURLPromise("3DSpace", "", tenantId);
        }

        return this.getServiceBaseURLPromise("3DSpace", tenantId);
        //return this.getServiceBaseURL("3DSpace", tenantId) + "/resources/6WVocab/access/";
      },
      
      isRDFService: function (iService){
        var nonRDFServices = ["3DSpace", "3DSwym", "3DDrive", "3DDashboard"];
        if (nonRDFServices.indexOf(iService) === -1){
          return true;
        }
        return false;
      }, 

      /************************************************************
      *   Below are conversion functions for backward compatibility
      ************************************************************/

      /*
        to
         {"vocabularyInfo":[
        {
        "name":"ds6w",
        "namespace":"http://www.3ds.com/vocabularies/ds6w/",
        "description":"This ontology defines the DS Corporate vocabulary for 6W tags",
        "prereqs":[],
        "nlsName":"6W Vocabulary"
        }
       */
      convertToR420Vocabularies: function (data) {
        var retData = { vocabularyInfo: [] };
        if (data === null){
          return retData;
        }
        var vocInfoList = [], vocInfo;
        for (var i in data) {
          vocInfo = {
            name: i,
            namespace: data[i].uri,
            description: data[i].description,
            nlsName: data[i].label
          };
          vocInfoList.push(vocInfo);
        }
        retData.vocabularyInfo = vocInfoList;
        //console.info('*** Conversion result: ' + JSON.stringify(retData));
        return retData;
      },

      /*
        to
        {
          "ds6w":{
            "curi": "ds6w:",
            "uri": "http://www.3ds.com/vocabularies/ds6w/",
            "label": "6W Vocabulary",
            "description": "This ontology defines the DS Corporate vocabulary for 6W tags."
          },
          "swym":{
            "curi": "swym:",
            "uri": "http://www.3ds.com/vocabularies/swym/",
            "label": "3DSwym Vocabulary",
            "description": "This ontology defines 3DSwym vocabulary for 6W tags."
          }, ...
        }
       */
      convertToR421Vocabularies: function (data) {
        var retData = {};
        if (!data || !data.vocabularyInfo){
          return data;
        }
        data.vocabularyInfo.forEach(function (element){
          retData[element.name] =
            { curi: element.name + ":",
              uri: element.namespace,
              label: element.nlsName,
              description: element.description
            };
        });
        
        return retData;
      },

      /*
       * From
       * { "vocabularyElementNLSInfo":[
        { "uri":"ds6w:classification",
        "type":"Predicate",
        "nlsName":"Classification",
        "lang":"en",
        "dataType":"string"
        },
         ]
        }
       */
      convertToR420ElementsNls: function (data) {
        var retData = { vocabularyElementNLSInfo: null };
        if (data === null){
           return retData;
        }
        var elemInfoList = [], elemInfo;
        for (var i in data) {
          elemInfo = {
            uri: data[i].curi,
            type: data[i].metaType,
            nlsName: data[i].label
          };
          if (data[i].metaType === "Property"){
            data[i].metaType == "Predicate";
          }
          if (data[i].metaType === "Predicate"){
            elemInfo.dataType = data[i].dataType;
          }
          elemInfoList.push(elemInfo);
        }
        retData.vocabularyElementNLSInfo = elemInfoList;
        return retData;
      },

      /*
      {"classPredicates":[
        {
        "className":"ds6wg:PLMEntity",
        "vocabularyPredicateInfo":[
        { "name":"owner",
        "uri":"ds6w:responsible",
        "nlsName":"Responsible",
        "lang":"en",
        "lineage":"ds6w:who/ds6w:responsible",
        "range":
          { "scope":"Range",
          "operator":"Union",
          "classes":[],
          "dataTypes":["http://www.w3.org/2001/XMLSchema#string"]
          },
          "dimension":"",
          "manipulationUnit":""
        },
        ]
        }
        ]
      }
      */
      convertToR420ClassProperties: function (data) {
        var retData = {classPredicates: [] };
        if (data === null){
          return retData;
        }
        var classInfoList = [], classInfo = {};
        
        data.forEach(function(element){
          // data comes from 3DSpace
          if (element.classPredicates){
            classInfoList = classInfoList.concat(element.classPredicates);
          }
          // data comes from RDF
          else if (Array.isArray(element.member)){
            element.member.forEach(function(info){
              var propInfoList = [];
              for (var i = 0; i < info.properties.totalItems; i++) {
                propInfo = {
                  // name: info.properties[i].originalName,
                  uri: info.properties.member[i].curi,
                  nlsName: info.properties.member[i].label,
                  description: info.properties.member[i].description,
                  dataType: info.properties.member[i].dataType
                };
                propInfoList.push(propInfo);
              }
              classInfo = {
                className: info.classInfo.curi,
                vocabularyPredicateInfo: propInfoList
              };
              classInfoList.push(classInfo);
            });
          }
        });
        retData.classPredicates = classInfoList;
        return retData;
      },

      /* to
       * {"classInfo":
          {
            curi":"ds6w:Part",
            "uri":"http://www.3ds.com/vocabularies/ds6w/Part",
            "label":"Part"
          },
          "properties":[
            {"curi":"ds6w:status",
            "uri":"http://www.3ds.com/vocabularies/ds6w/status",
            "label":"Etat de maturité",
            "description":"Etat de maturité de l'objet",
            "dataType":"xsd:string",
            "lineage":"ds6w:what"}, --> lineage cannot be retrieved
            ...
          ]
        }
        */
       convertToR421ClassProperties: function (data) {
        if (!data){
          return data;
        }
        var result = [];
        var that = this;

        data.forEach(function(element){
          // data comes from RDF
          if (Array.isArray(element.member)){
            element = that.formatRDFResponse(element);
            element.forEach(function(info){
              if (info.properties) {
                if (info.properties.originCuri){
                  info.properties.originCuri = that.formatRDFResponse(info.properties.originCuri);
                }
                info.properties = that.formatRDFResponse(info.properties);
              }
              result.push(info);
            });
          }
          // data comes from 3DSpace
          else if (element.classPredicates) {
            element.classPredicates.forEach(function(classPredicates){
              var retData = {classInfo: {}, properties:[]};
              if (classPredicates.className){
                retData.classInfo = {
                  curi: classPredicates.className,
                  uri: "http://www.3ds.com/vocabularies/" + classPredicates.className.replace(":", "/")
                };
              }
              if (classPredicates.vocabularyPredicateInfo){
                classPredicates.vocabularyPredicateInfo.forEach(function (info){                
                  var retObj = {
                    curi : info.uri,
                    uri : "http://www.3ds.com/vocabularies/" + info.uri.replace(":","/"),
                    label : info.nlsName,
                    description : info.nlsName,
                    dataType: info.range.dataTypes[0],
                    dimension: info.dimension,
                    manipulationUnit: info.manipulationUnit,
                    lineage: info.lineage
                  };
                  //IR-671556 rangeValues are used by AdvancedSearch and should be returned
                  if (info.rangeValues && info.rangeValues.literalInfo){
                    retObj.rangeValues = info.rangeValues.literalInfo;
                  }
                  retData.properties.push(retObj);
                });
              }
              result.push(retData);
            });
          }
        });     
        return result;
      },

      /* From
      {"vocabularyInfo":
         { "name":"ds6w",
         "prereqs":[]
         },
         "vocabularyClassInfo":[
         { "name":"http://www.3ds.com/vocabularies/ds6w/Change",
         "type":"Class",
         "description":"Change",
         "uri":"ds6w:Change",
         "parentUri":"",
         "nlsName":"Change",
         "abstract":false
        }
        ]
       */
      convertToR420VocClasses: function (data) {
        var retData = null;
        if (data === null){
          return retData;
        }
        var vocInfo = {};
        var classInfoList = [], classInfo;
        for (var i = 0; i < data.classes.totalItems; i++) {
          classInfo = {
            name: data.classes.member[i].uri,
            uri: data.classes.member[i].curi,
            nlsName: data.classes.member[i].label,
            description: data.classes.member[i].description
          };
          classInfoList[i] = classInfo;
        }
        vocInfo = {
          name: data.vocabularyInfo.curi.split(":")[0],
          uri: data.vocabularyInfo.curi,
          namespace: data.vocabularyInfo.uri
        };

        retData = {
          vocabularyInfo: vocInfo,
          vocabularyClassInfo: classInfoList
        };
        //console.info('*** Conversion result: ' + JSON.stringify(retData));
        return retData;
      },

      /* to
       * {"vocabularyInfo":
          {
            "curi":"ds6w:",
            "uri":"http://www.3ds.com/vocabularies/ds6w/"
          },
          "classes":[
            {
            "curi":"ds6w:Classification",
            "uri":"http://www.3ds.com/vocabularies/ds6w/Classification",
            "label":"Classification",
            "description":"Classification"
            },
            ...
          ]
        }
        */
       convertToR421VocClasses: function (data) {
        if (!data || !data.vocabularyInfo){
         return data;
        }
        var retData = {vocabularyInfo : {}, classes: []};

        retData.vocabularyInfo = {
          curi: data.vocabularyInfo.name + ":",
          uri: "http://www.3ds.com/vocabularies/" + data.vocabularyInfo.name + "/"
        };

        if (data.vocabularyClassInfo){
          data.vocabularyClassInfo.forEach(function (element){
            retData.classes.push({
              curi : element.uri,
              uri : "http://www.3ds.com/vocabularies/" + element.uri.replace(":", "/"),
              label : element.nlsName,
              description : element.description
            });
          });
        }
       
       return retData;
     },

      /* to
       * {"vocabularyInfo":
        {
        "name":"ds6w",
        "prereqs":[]
        },
        "vocabularyElementNLSInfo":[
          {
          "uri":"ds6w:releaseType","
          type":"Predicate",
          "nlsName":"Release Type",
          "lang":"en"
          }
          ...
        ]
        }
        */
      convertToR420VocProperties: function (data) {
        var retData = {};
        if (data === null){
          return retData;
        }
        var vocInfo = {};
        var propInfoList = [], propInfo;
        for (var i = 0; i < data.properties.totalItems; i++) {
          propInfo = {
            uri: data.properties.member[i].curi,
            nlsName: data.properties.member[i].label
          };
          propInfoList[i] = propInfo;
        }
        vocInfo = {
          name: data.vocabularyInfo.curi.split(":")[0],
          uri: data.vocabularyInfo.curi,
          namespace: data.vocabularyInfo.uri
        };

        retData = {
          vocabularyInfo: vocInfo,
          vocabularyElementNLSInfo: propInfoList
        };
        //console.info('*** Conversion result: ' + JSON.stringify(retData));
        return retData;
      },

      /* to
       * {"vocabularyInfo":
          {
            "curi":"ds6w:",
            "uri":"http://www.3ds.com/vocabularies/ds6w/"
          },
          "properties":[
            {
            "curi":"ds6w:constituent",
            "uri":"http://www.3ds.com/vocabularies/ds6w/constituent",
            "label":"Constituent",
            "description":"Constituent"
            },
            ...
          ]
        }
        */
      convertToR421VocProperties: function (data) {
        if (!data || !data.vocabularyInfo){
          return data;
        }
        var retData = { vocabularyInfo : {}, properties: []};

        retData.vocabularyInfo = {
          curi: data.vocabularyInfo.name + ":",
          uri: "http://www.3ds.com/vocabularies/" + data.vocabularyInfo.name + "/"
        };

        if (data.vocabularyElementNLSInfo){
          data.vocabularyElementNLSInfo.forEach(function (element){
            retData.properties.push({
              curi : element.uri,
              uri : "http://www.3ds.com/vocabularies/" + element.uri.replace(":", "/"),
              label : element.nlsName,
              description : element.nlsName
            });
          });
        }
        
        return retData;
      },

      /* from
        { "literalInfo": [
        {
         "value": "FR",
         "nlsvalue": "France"
        },
        {
         "value": "GR",
         "nlsvalue": "Greece"
        }
        ]
        "individualInfo": []
        }
        */
      convertToR420RangeValues: function (data) {
        var retData = {};
        if (data === null){
          return retData;
        }
        var valList = [], val;
        for (var i = 0; i < data.values.totalItems; i++) {
          val = {
            value: data.values.member[i].value,
            nlsvalue: data.values.member[i].nlsValue
          };
          valList[i] = val;
        }

        retData.literalInfo = valList;
        //console.info('*** Conversion result: ' + JSON.stringify(retData));
        return retData;
      },
 
      /* to
        {
          "propertyInfo":
            {"curi":"ds6w:jobStatus","uri":"http://www.3ds.com/vocabularies/ds6w/jobStatus","label":"Statut d'une tâche planifiée"},
          "values":[
            {"value":"swym_media_error","nlsValue":"Erreur"},
            {"value":"swym_media_non_processed","nlsValue":"Non traite"},
            {"value":"swym_media_processed","nlsValue":"Traite"},
            {"value":"swym_media_processing","nlsValue":"En cours de traitement"},
            {"value":"swym_media_ready_to_process","nlsValue":"Pret pour traitement"}
          ]
        }
        */
      convertToR421RangeValues: function (data) {
        var retData = {propertyInfo : {}, values: []};

        if (!data || !data.literalInfo){
          return retData;
        }
        retData.values = data.literalInfo;
        return retData;
      },

      formatRDFResponse : function(arrayToFormat) {
        if (arrayToFormat.member){
          return arrayToFormat.member;
        }
        return arrayToFormat;
      },

      formatRDFInput : function(stringToFormat, toArray) {
        try {
          stringToFormat = JSON.parse(stringToFormat);
          if (toArray){
            return JSON.stringify([stringToFormat]);
          }
          return JSON.stringify(stringToFormat);
        } 
        catch (e) {
          var inArray = stringToFormat.split(",");
          if (toArray){
            return JSON.stringify([inArray]);
          }
          return JSON.stringify(inArray);
        }
      }
    };

    return dicoUtils;
  });

define('DS/FedDictionaryAccess/RequestUtils',
      ['DS/WAFData/WAFData'],
function (WAFData){
  'use strict';

  var requestUtils = {

    sendRequest: function(iURL, iOptions, iWithoutAuth){
      if (!iURL){
        return;
      }
      if (!iOptions){
        iOptions = {};
      }
      if (iWithoutAuth){
        WAFData.proxifiedRequest(iURL, iOptions);
      }
      else {
        WAFData.authenticatedRequest(iURL, iOptions);
      }
    }
  };
  return requestUtils;
});

define('DS/FedDictionaryAccess/FedDictionaryAccessRDF',
  ['UWA/Core',
    'DS/FedDictionaryAccess/FedDicoUtils',
    'DS/FedDictionaryAccess/RequestUtils'],

  function (Core, DicoUtils, RequestUtils) {

    "use strict";

    var dicoReadAPI = {
      
      // SGA5: no need to ping RDF as Ontology datamodel will be removed from E/R on Cloud starting 2020x
      /*ping: function (iService, cbFuncs) {
        return new Promise(function(resolve, reject){
          var cachedValue = sessionStorage.getItem("RDF_SERVICE_UP");
          if (cachedValue) {
            if (cachedValue === "true") {
              resolve();      
            }
            else {
              reject("RDF down: cache");
            }
          }
          // check if RDF service is pingable
          else {
            DicoUtils.getServiceBaseURLPromise(iService, cbFuncs.tenantId, cbFuncs.RDFServiceURL).then(function(url){
              var fullURL = url + "dsbase:ping?tenantId=" + cbFuncs.tenantId;
              RequestUtils.sendRequest(fullURL, {
                method: 'POST',
                headers: {},
                timeout: 10000,
                onComplete: function() {
                  // service pingable
                  sessionStorage.setItem("RDF_SERVICE_UP", "true");
                  resolve();
                },
                onFailure: function() {
                  // service not pingable
                  sessionStorage.setItem("RDF_SERVICE_UP", "false");
                  reject("RDF down");
                }
              }, DicoUtils.isWithoutAuth());
            });
          }
        });
      },*/

      getVocabularies: function (iService, cbFuncs) {
        return new Promise(function(resolve, reject){
          DicoUtils.getServiceBaseURLPromise(iService, cbFuncs.tenantId, cbFuncs.RDFServiceURL).then(function(url){
            var fullURL = url +  "dsbase:getFedVocabularies?tenantId="+cbFuncs.tenantId;       
            RequestUtils.sendRequest(fullURL, {
              headers : {
                Accept : "application/json"
              },
              method : "POST",
              proxy : "passport",
              onComplete : function(data) {
                var jsRes = JSON.parse(data);
                var result = jsRes["@result"];
                if (cbFuncs.apiVersion!=="R2019x"){
                  result = DicoUtils.convertToR420Vocabularies(result);
                }
                resolve(result);
              },
              onFailure : function(data) {
                reject(data);
              }
            }, DicoUtils.isWithoutAuth());
          });
        });
      },

      getResourcesInfo: function(iService, cbFuncs, iElements){
        return new Promise(function(resolve, reject){
          DicoUtils.getServiceBaseURLPromise(iService, cbFuncs.tenantId, cbFuncs.RDFServiceURL).then(function(url){
            var fullURL = url +  "dsbase:getResourcesInfo?tenantId=" + cbFuncs.tenantId;
            var headers = {};
            headers.Accept = 'application/json';
            headers['Accept-Language'] = cbFuncs.lang;
            headers['Content-Type'] = 'application/json';
    
            var language = cbFuncs.lang;
            var storageName = DicoUtils.dicoElemsBaseKey + language;
            var localValues = sessionStorage.getItem(storageName);
            if (!localValues){
              localValues = {};
            }
            else {
              localValues = JSON.parse(localValues);
            }
    
            RequestUtils.sendRequest(fullURL, {
              method: 'POST',
              headers: headers,
              timeout: 6000,
              data: DicoUtils.formatRDFInput(iElements.toString(), true),
              onComplete: function (response) {
                try {
                  var jsResp = JSON.parse(response);
                  var result = jsResp["@result"].member;
                  var i = 0;
                  for (; result[i];) {
                    localValues[result[i].curi] = result[i];
                    i++;
                  }
                  i = 0;

                  sessionStorage.setItem(storageName, JSON.stringify(localValues));

                  if (cbFuncs.apiVersion !== "R2019x"){
                    result = DicoUtils.convertToR420ElementsNls(result);
                  }
                  
                  resolve(result);
                  
                }
                catch (e) {
                  console.warn('*** Warning: server returned empty result ***');
                  resolve();
                }
              },
              onFailure: function (data) {
                reject(data);
              }
            }, DicoUtils.isWithoutAuth());
          });
        });
      },

      getPropertiesForClasses: function(iService, cbFuncs, iClasses){
        return new Promise(function(resolve, reject){
        //console.log("### Retrieving properties of RDF class... ");
        DicoUtils.getServiceBaseURLPromise(iService, cbFuncs.tenantId, cbFuncs.RDFServiceURL).then(function(url){
          var language = '';
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
            language = cbFuncs.lang;
          }
          var fullURL = url + "dsbase:getPropertiesForClass?tenantId=" + cbFuncs.tenantId;
          var headers = {};
          headers.Accept = 'application/json';
          headers['Accept-Language'] = language;
          headers['Content-Type'] = 'application/json';

          RequestUtils.sendRequest(fullURL, {
            method: 'POST',
            headers: headers,
            timeout: 30000,
            data: DicoUtils.formatRDFInput(iClasses.toString(), true),
            onComplete: function (response) {
              try{
                var jsResp = JSON.parse(response);
                var result = jsResp["@result"];
                resolve(result);
              }
              catch (e) {
                console.warn('*** Warning: server returned empty or incorrect result *** ' + e);
                resolve();
              }
            },
            onFailure: function (data) {
                reject(data);
            }
          }, DicoUtils.isWithoutAuth());
        });
      });
      },

      getVocabularyProperties: function (iService, cbFuncs, iVocUri) {
        return new Promise(function(resolve, reject){
          var language = '';
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
            language = cbFuncs.lang;
          }
          else {
            language = widget.lang;
          }

          DicoUtils.getServiceBaseURLPromise(iService, cbFuncs.tenantId, cbFuncs.RDFServiceURL).then(function(url){
            var fullURL = url + "dsbase:getVocabularyProperties?tenantId=" + cbFuncs.tenantId;
            var headers = {};
            headers.Accept = 'application/json';
            headers['Accept-Language'] = language;
            headers['Content-Type'] = 'application/json';

            RequestUtils.sendRequest(fullURL, {
              method: 'POST',
              headers: headers,
              timeout: 6000,
              data: DicoUtils.formatRDFInput(iVocUri),
              onComplete: function (response) {
                try {
                  var jsResp = JSON.parse(response);
                  var result = jsResp["@result"];
                  if (cbFuncs.apiVersion !== "R2019x"){
                    result = DicoUtils.convertToR420VocProperties(result);
                  }
                  else{
                    if (result.properties){
                      if (result.properties.originCuri){
                        result.properties.originCuri = DicoUtils.formatRDFResponse(result.properties.originCuri);
                      }
                      result.properties = DicoUtils.formatRDFResponse(result.properties);
                    }
                  }          
                  resolve(result);
                }
                catch (e) {
                  console.warn('*** Warning: server returned empty result ***');
                  resolve();
                }
              },
              onFailure: function (data) {
                reject(data);
              }
            }, DicoUtils.isWithoutAuth());
          });
        });
      },

      getVocabularyClasses: function (iService, cbFuncs, iVocUri) {
        var language = '';
        if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
          language = cbFuncs.lang;
        }
        else {
          language = widget.lang;
        }

        if (!iVocUri || iVocUri.startsWith("ds6wg")){
          return; 
        }

        return new Promise(function(resolve, reject){
          //console.log("### Retrieving RDF classes of: "+iVocUri)
          DicoUtils.getServiceBaseURLPromise(iService, cbFuncs.tenantId, cbFuncs.RDFServiceURL).then(function(url){
            var fullURL = url + "dsbase:getVocabularyClasses?tenantId=" + cbFuncs.tenantId;
            var headers = {};
            headers.Accept = 'application/json';
            headers['Accept-Language'] = language;
            headers['Content-Type'] = 'application/json';
            RequestUtils.sendRequest(fullURL, {
              method: 'POST',
              data: DicoUtils.formatRDFInput(iVocUri),
              headers: headers,
              timeout: 40000,
              onComplete: function (response) {
                try {
                  var jsResp = JSON.parse(response);
                  var result = jsResp["@result"];
                  if (cbFuncs.apiVersion !== "R2019x") {
                    result = DicoUtils.convertToR420VocClasses(result);
                  }
                  else {
                    if (result.classes){
                      result.classes = DicoUtils.formatRDFResponse(result.classes);
                    }
                  }
                  resolve(result);
                }
                catch (e) {
                  console.warn('*** Warning: server returned empty result *** ' + e);
                  resolve();
                }
              },
              onFailure: function (data) {
                reject(data);
              }
            }, DicoUtils.isWithoutAuth());
          });
        });
      },

      getNlsOfPropertyValues: function (iService, cbFuncs, iElements) {
        return new Promise(function(resolve, reject){
          var language = '';
          if (Core.is(cbFuncs.lang, 'string')){
            language = cbFuncs.lang;
          }
          else{
            language = widget.lang;
          }
          var storageName = DicoUtils.dicoPropValuesBaseKey + language;
    
          DicoUtils.getServiceBaseURLPromise(iService, cbFuncs.tenantId, cbFuncs.RDFServiceURL).then(function(url){
            var fullURL = url +  "dsbase:getNlsOfPropertyValues?tenantId=" + cbFuncs.tenantId;
            var headers = {};
            headers.Accept = 'application/json';
            headers['Content-Type'] = 'application/json';
            headers['Accept-Language'] = language;
            var input = JSON.stringify(iElements);
            RequestUtils.sendRequest(fullURL,
            {
              method: 'POST',
              headers: headers,
              timeout: 30000,
              data: JSON.stringify([input]),
              onComplete: function (response) {
                var jsRes;
                try {
                  jsRes = JSON.parse(response);
                }
                catch (e){
                  console.warn('*** Warning: server returned empty result ***');
                  return resolve();
                }
                var result = jsRes["@result"];
                if (!window.sessionStorage){
                  return resolve(result);
                }
                var localValues = sessionStorage.getItem(storageName);
                if (!localValues){
                  localValues = {};
                }
                else {
                  localValues = JSON.parse(localValues);
                }
                var dwnlded_props = result;
  
                for (var propId in dwnlded_props) {
                  for (var val in dwnlded_props[propId]) {
                    if (!localValues.hasOwnProperty(propId)){
                      localValues[propId] = dwnlded_props[propId];
                    }
                    localValues[propId][val] = dwnlded_props[propId][val];
                  }
                }
                sessionStorage.setItem(storageName, JSON.stringify(localValues));
                
                return resolve(jsRes["@result"]);            
              },
              onFailure: function (data) {
                return reject(data);         
              }
            }, DicoUtils.isWithoutAuth());
          });
        });
      },

      getRangeValues: function (iService, cbFuncs, iPropUri) {
        return new Promise(function(resolve, reject){
          var language = '';
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
            language = cbFuncs.lang;
          }
          else {
            language = widget.lang;
          }
          DicoUtils.getServiceBaseURLPromise(iService, cbFuncs.tenantId, cbFuncs.RDFServiceURL).then(function(url){
            var fullURL = url +  "dsbase:getRangeValues?tenantId=" + cbFuncs.tenantId;
            var headers = {};
            headers.Accept = 'application/json';
            headers['Accept-Language'] = language;
            headers['Content-Type'] = 'application/json';

            RequestUtils.sendRequest(fullURL, {
              method: 'POST',
              headers: headers,
              timeout: 12000,
              data: DicoUtils.formatRDFInput(iPropUri),
              onComplete: function (response) {
                try {
                  var jsResp = JSON.parse(response);
                  var result = jsResp["@result"];
                  if (cbFuncs.apiVersion !== "R2019x") {
                    result = DicoUtils.convertToR420RangeValues(result);
                  }
                  if (result.values){
                    result.values = DicoUtils.formatRDFResponse(result.values);
                  }
                  resolve(result);
                }  
                catch (e) {
                  console.warn('*** Warning: server returned empty result *** ' + e);
                  resolve();
                }
              },
              onFailure: function (data) {
                reject(data);
              }
            }, DicoUtils.isWithoutAuth());
          });
        });
      },

      getFedProperties: function (iService, cbFuncs) {
        return new Promise(function(resolve, reject){
          var language = '';
          var params = [];
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
            language = cbFuncs.lang;
          }
          else{
            language = widget.lang;
          }
          // SGA5: IR-619053 Add new parameter mappable to get only mappable properties
          if(cbFuncs.onlyMappable){
            params = ["{\"mappable\": true}"];
          }
          DicoUtils.getServiceBaseURLPromise(iService, cbFuncs.tenantId, cbFuncs.RDFServiceURL).then(function(url){
            var fullURL = url +  "dsbase:getFedProperties?tenantId=" + cbFuncs.tenantId;
            var headers = {};
            headers.Accept = 'application/json';
            headers['Accept-Language'] = language;
            headers['Content-Type'] = 'application/json';

            RequestUtils.sendRequest(fullURL, {
              method: 'POST',
              headers: headers,
              timeout: 6000,
              data: JSON.stringify(params),
              onComplete: function (response) {
                try {
                  var jsResp = JSON.parse(response);
                  var result = jsResp["@result"];
                  for (var element in result){
                    var val = result[element];
                    if (val.properties){
                      result[element].properties = DicoUtils.formatRDFResponse(val.properties);
                    }              
                  }
                  resolve(result);         
                }catch (e) {
                  console.warn('*** Warning: server returned empty result *** ' + e);
                  resolve();
                }
              },
              onFailure: function (data) {
                reject(data);
              }
            }, DicoUtils.isWithoutAuth());
          });
        });
      },

      getServiceClasses: function(iService, cbFuncs){
        return new Promise(function(resolve, reject){
          var language = '';
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
            language = cbFuncs.lang;
          }
          else {
            language = widget.lang;
          }

          DicoUtils.getServiceBaseURLPromise(iService, cbFuncs.tenantId, cbFuncs.RDFServiceURL).then(function(url){
            var fullURL = url +  "dsbase:getServiceClasses?tenantId=" + cbFuncs.tenantId;
            var headers = {};
            headers.Accept = 'application/json';
            headers['Accept-Language'] = language;
            headers['Content-Type'] = 'application/json';

            RequestUtils.sendRequest(fullURL, {
              method: 'POST',
              headers: headers,
              timeout: 6000,
              data: DicoUtils.formatRDFInput("[]"),
              onComplete: function (response) {
                try {
                  var jsResp = JSON.parse(response);
                  var result = jsResp["@result"];
                  result =  DicoUtils.formatRDFResponse(result);
                  result.forEach(function(element){
                    if (element.classes){
                      element.classes = DicoUtils.formatRDFResponse(element.classes);
                    }
                  });
                  /*if (result.vocabularies)
                    result.vocabularies = DicoUtils.formatRDFResponse(result.vocabularies);
                  if (result.classes)
                    result.classes = DicoUtils.formatRDFResponse(result.classes);     */     
                  resolve(result);
                }
                catch (e) {
                  console.warn('*** Warning: server returned empty result *** ' +e);
                  resolve();
                }
              },
              onFailure: function (data) {
                reject(data);
              }
            }, DicoUtils.isWithoutAuth());
          });
        });
      }
    };
    return dicoReadAPI;
});

define('DS/FedDictionaryAccess/FedDictionaryAccess3DSpace',
  ['UWA/Core',
    'DS/FedDictionaryAccess/FedDicoUtils',
    'DS/FedDictionaryAccess/RequestUtils'],

  function (Core, DicoUtils, RequestUtils) {

    "use strict";

    var dicoReadAPI = {

      getVocabularies: function(cbFuncs){
        return new Promise(function(resolve, reject){ 
          var language = '';
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
            language = cbFuncs.lang;
          }
          else{
            language = widget.lang;
          }
          if (cbFuncs.RDFServiceURL && cbFuncs.RDFServiceURL.startsWith("ODTService@")){
            cbFuncs.tenantId = "ODTService@" + cbFuncs.tenantId;
          }

          DicoUtils.get3DSpaceBaseURLPromise(cbFuncs.tenantId).then(function(url){
            var fullURL = url + "Vocabularies?filter=ALL&tenant=" + cbFuncs.tenantId;    
            var headers = {};
    
            headers['Accept-Language'] = language;
            headers.Accept = 'application/json';
    
            RequestUtils.sendRequest(fullURL, {
              method: 'GET',
              headers: headers,
              timeout: 30000,
              onComplete: function (response) {
                var jsResponse = JSON.parse(response);
                if (cbFuncs.apiVersion === "R2019x"){
                  jsResponse = DicoUtils.convertToR421Vocabularies(jsResponse);
                }
                resolve(jsResponse);
              },
              onFailure: function (data) {
                reject(data);
              }
            });
          });
        });
      },
      
      getTypeAttributes: function(cbFuncs, iClasses){
        return new Promise(function(resolve, reject){ 
          //console.log("### Retrieving attributes of V6 type... ");
          var language = '';
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
            language = cbFuncs.lang;
          }
          else{
            language = widget.lang;
          }
          if (cbFuncs.RDFServiceURL && cbFuncs.RDFServiceURL.startsWith("ODTService@")){
            cbFuncs.tenantId = "ODTService@" + cbFuncs.tenantId;
          }
          DicoUtils.get3DSpaceBaseURLPromise(cbFuncs.tenantId).then(function(url){
            var fullURL = url + "TypeAttributes?tenant=" + cbFuncs.tenantId;
            var headers = {};
            headers.Accept = 'application/json';
            headers['Accept-Language'] = language;
            headers['Content-Type'] = "text/plain";

            RequestUtils.sendRequest(fullURL, {
              method: 'POST',
              headers: headers,
              data: iClasses.toString(),
              timeout: 6000,
              onComplete: function (response) {
                try {
                  var jsResp = JSON.parse(response);
                  resolve(jsResp);
                }
                catch (e) {
                  console.warn('*** Warning: server returned empty result ***');
                  resolve();
                }
              },
              onFailure: function (data) {
                reject(data);
              }
            });
          });
        });
      },

      getPredicates: function (cbFuncs, iClasses) {
        var language = '';
        if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
          language = cbFuncs.lang;
        }
        else{
          language = widget.lang;
        }
        if (cbFuncs.RDFServiceURL && cbFuncs.RDFServiceURL.startsWith("ODTService@")){
          cbFuncs.tenantId = "ODTService@" + cbFuncs.tenantId;
        }
        
        return new Promise(function(resolve, reject){ 
          var addExtensions = "&extensions=true";
          if (typeof cbFuncs.extensions !== "undefined" && cbFuncs.extensions === false) {
            addExtensions = "";
          }
          DicoUtils.get3DSpaceBaseURLPromise(cbFuncs.tenantId).then(function(url){
          var fullURL = url + "Predicates?tenant=" + cbFuncs.tenantId + addExtensions;
          var headers = {};
          headers.Accept = 'application/json';
          headers['Accept-Language'] = language;
          headers['Content-Type'] = "text/plain";

          RequestUtils.sendRequest(fullURL, { 
            method: 'POST',
            headers: headers,
            timeout: 30000,
            data: iClasses.toString(),
            onComplete: function (response) {
              var jsResponse;
              try {
                jsResponse = JSON.parse(response);
                if (cbFuncs.apiVersion === "R2019x") {
                  jsResponse = DicoUtils.convertToR421ClassProperties([jsResponse]);
                }
              }
              catch (e){
                console.warn('*** Warning: 3DSpace returned empty result ***');
              }
              finally{
                resolve(jsResponse);  
              }
            },
            onFailure: function (data) {
              reject(data);
            }
          });
        });
      });
      },

      getElementsNLSNames: function (cbFuncs, iElements, has6WPredicates) {
        if (cbFuncs.RDFServiceURL && cbFuncs.RDFServiceURL.startsWith("ODTService@")){
          cbFuncs.tenantId = "ODTService@" + cbFuncs.tenantId;
        }
        var webservice = "TermsNls";
        if (has6WPredicates){
          webservice = "ElementsNLSNames";
        }

        return new Promise(function(resolve, reject){ 
          DicoUtils.get3DSpaceBaseURLPromise(cbFuncs.tenantId).then(function(url){
            var fullURL = url + webservice + "?tenant=" + cbFuncs.tenantId;
            var headers = {};
            headers['Accept-Language'] = cbFuncs.lang;
            headers['Content-Type'] = "text/plain";
    
            var language = cbFuncs.lang;
            var storageName = DicoUtils.dicoElemsBaseKey + language;
    
            var localValues = sessionStorage.getItem(storageName);
            if (!localValues){
              localValues = {};
            }
            else{
              localValues = JSON.parse(localValues);
            }
    
            var result = [];
            RequestUtils.sendRequest(fullURL, {
              method: 'POST',
              headers: headers,
              timeout: 30000,
              data: iElements.toString(),
              onComplete: function (response) {
                try {
                  var responseParse = JSON.parse(response);
                  var i = 0, elt, termInfo;
                  for (; responseParse.vocabularyElementNLSInfo[i];) {
                    elt = responseParse.vocabularyElementNLSInfo[i];
                    // convert in new format
                    termInfo = {
                      curi: elt.uri,
                      label: elt.nlsName,
                      metaType: elt.type
                    };
                    if (elt.type === "Predicate"){
                      termInfo.dataType = elt.dataType;
                    }
                    localValues[elt.uri] = termInfo;
                    // feed result based on new format
                    result.push(termInfo);
                    i++;
                  }
                  sessionStorage.setItem(storageName, JSON.stringify(localValues));
                  if (cbFuncs.apiVersion !== "R2019x"){
                    result = DicoUtils.convertToR420ElementsNls(result);
                  }
                  resolve(result);
                }
                catch (e) {
                  console.warn('*** Warning: server returned empty result ***');
                  resolve();
                }
              },
              onFailure: function (data) {
                reject(data);
              }
            });
        });
      });
      },

      getPredicatesNLSNames: function (cbFuncs, iVocUri) {
        return new Promise(function(resolve, reject){ 
          var language = '';
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
            language = cbFuncs.lang;
          }
          else{
            language = widget.lang;
          }
          var vocName = iVocUri;
          if (iVocUri.endsWith(":")){
            vocName = iVocUri.slice(0, iVocUri.length - 1);
          }

          if (cbFuncs.RDFServiceURL && cbFuncs.RDFServiceURL.startsWith("ODTService@")){
            cbFuncs.tenantId = "ODTService@" + cbFuncs.tenantId;
          }

          DicoUtils.get3DSpaceBaseURLPromise(cbFuncs.tenantId).then(function(url){
            var fullURL = url + "PredicatesNLSNames?name=" + vocName + "&tenant=" + cbFuncs.tenantId;
            var headers = {};
            headers['Accept-Language'] = language;
    
            RequestUtils.sendRequest(fullURL, {
              method: 'GET',
              headers: headers,
              timeout: 30000,
              onComplete: function (response) {
                var jsResponse;
                try {
                  jsResponse = JSON.parse(response);
                  if (cbFuncs.apiVersion === "R2019x") {
                    jsResponse = DicoUtils.convertToR421VocProperties(jsResponse);
                  }
                }
                catch (e){
                  console.warn('*** Warning: 3DSpace returned empty result ***');
                }       
                resolve(jsResponse);
              },
              onFailure: function (data) {
                reject(data);
              }
            });
          });
        });
      },

      getVocabularyClasses: function (cbFuncs, iVocUri) {
        return new Promise(function(resolve, reject){ 
          var language = '';
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
            language = cbFuncs.lang;
          }
          else{
            language = widget.lang;
          }
          var vocName = iVocUri;
          if (iVocUri.endsWith(":")){
            vocName = iVocUri.slice(0, iVocUri.length - 1);
          }
          if (cbFuncs.RDFServiceURL && cbFuncs.RDFServiceURL.startsWith("ODTService@")){
            cbFuncs.tenantId = "ODTService@" + cbFuncs.tenantId;
          }

          DicoUtils.get3DSpaceBaseURLPromise(cbFuncs.tenantId).then(function(url){
            var fullURL = url + "VocabularyClasses?name=" + vocName + "&tenant=" + cbFuncs.tenantId;
            var headers = {};
            headers['Accept-Language'] = language;
            RequestUtils.sendRequest(fullURL, {
              method: 'GET',
              headers: headers,
              timeout: 30000,
              onComplete: function (response) {
                var jsResponse;
                try {
                  jsResponse = JSON.parse(response);
                  if (cbFuncs.apiVersion === "R2019x") {
                    jsResponse = DicoUtils.convertToR421VocClasses(jsResponse);
                  }
                }
                catch (e){
                  console.warn('*** Warning: 3DSpace returned empty result ***');
                } finally{
                  resolve(jsResponse);
                }
              },
              onFailure: function (data) {
                reject(data);             
              }
            });
          });
        });
      },

      get3DSpaceTypes: function(cbFuncs){
        return new Promise(function(resolve, reject){ 
          //console.log("### Retrieving 3DSpace classes... ");
          var withInst = "false";
          if (cbFuncs.withInstances === true){
            withInst = "true";
          }
          if (cbFuncs.RDFServiceURL && cbFuncs.RDFServiceURL.startsWith("ODTService@")){
            cbFuncs.tenantId = "ODTService@" + cbFuncs.tenantId;
          }
          var language = '';
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0) {
            language = cbFuncs.lang;
          }
          else {
            language = widget.lang;
          }

          DicoUtils.get3DSpaceBaseURLPromise(cbFuncs.tenantId).then(function(url){
            var fullURL = url + "3DSpaceTypes?withInstances=" + withInst + "&tenant=" + cbFuncs.tenantId;
            var headers = {};
            headers.Accept = 'application/json';
            headers['Accept-Language'] = language;

            RequestUtils.sendRequest(fullURL, {
              method: 'GET',
              headers: headers,
              timeout: 60000,
              onComplete: function (response) {
                try {
                  var jsResp = JSON.parse(response);
                  var result = {
                    vocabularyInfo: {
                      curi: jsResp.vocabularyInfo.name + ":",
                      uri: ''
                    },
                    classes: {
                      totalItems: jsResp.vocabularyClassInfo.length,
                      member: []
                    }
                  };
                  var i = 0, elt, classInfo;
                  for (; jsResp.vocabularyClassInfo[i];) {
                    elt = jsResp.vocabularyClassInfo[i];
                    // convert in new format
                    classInfo = {
                      curi: elt.uri,
                      uri: elt.name,
                      label: elt.nlsName,
                      description: elt.description,
                      metaType: elt.type,
                      subClassOf: elt.parentUri
                    };
                    // feed result based on new format
                    result.classes.member.push(classInfo);
                    i++;
                  }
                  if (cbFuncs.apiVersion !== "R2019x"){ //result = DicoUtils.convertToR420VocClasses(result);
                    resolve(jsResp);
                  }
                  else { 
                    resolve(result);
                  }
                }
                catch (e) {
                  console.warn('*** Warning: server returned empty result *** ' + e);
                  resolve();
                }
              },
              onFailure: function (data) {
                reject(data);             
              }
            });
          });
        });
      },

      getAttributesNlsValues: function (cbFuncs, iElements, has6WPredicates) {
        return new Promise(function(resolve, reject){ 
          var language = '';
          var result = {};
          if (Core.is(cbFuncs.lang, 'string')){
            language = cbFuncs.lang;
          }
          else{
            language = widget.lang;
          }
          var storageName = DicoUtils.dicoPropValuesBaseKey + language;
          if (cbFuncs.RDFServiceURL && cbFuncs.RDFServiceURL.startsWith("ODTService@")){
            cbFuncs.tenantId = "ODTService@" + cbFuncs.tenantId;
          }

          DicoUtils.get3DSpaceBaseURLPromise(cbFuncs.tenantId).then(function(url){
            var fullURL = "";
    
            if (has6WPredicates) {
              fullURL = url + "PredicateValue?tenant=" + cbFuncs.tenantId;
            }
            else {
              fullURL = url + "AttributeNlsValues?tenant=" + cbFuncs.tenantId;
            }
            var headers = {};
            headers['Accept-Language'] = language;
            headers['Content-Type'] = 'application/json';
    
            var localValues = sessionStorage.getItem(storageName);
            if (!localValues){
              localValues = {};
            }
            else{
              localValues = JSON.parse(localValues);
            }
    
            RequestUtils.sendRequest(fullURL, {
              method: 'POST',
              headers: headers,
              timeout: 30000,
              data: JSON.stringify(iElements),
              onComplete: function (response) {
                var jsResponse;
                try{
                  jsResponse = JSON.parse(response);
                  var respKeys = Object.keys(jsResponse);
                  var i = 0, uri;
                  for (i = 0; i < respKeys.length; i++) {
                    uri = respKeys[i];
                    localValues[uri] = jsResponse[uri];
                    result[uri] = jsResponse[uri];
                  }
                  sessionStorage.setItem(storageName, JSON.stringify(localValues));
                  resolve(result);
                } 
                catch (e) {
                  console.warn('*** Warning: server returned empty result *** ' + e);
                  resolve(jsResponse);
                }      
              },
              onFailure: function (data) {
                reject(data);            
              }
            });
          });
        });
      },

      getPredicateRangeValues: function (cbFuncs, iPropUri) {
        return new Promise(function(resolve, reject){ 
          var language = '';
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
            language = cbFuncs.lang;
          }
          else{
            language = widget.lang;
          }
          if (cbFuncs.RDFServiceURL && cbFuncs.RDFServiceURL.startsWith("ODTService@")){
            cbFuncs.tenantId = "ODTService@" + cbFuncs.tenantId;
          }

          DicoUtils.get3DSpaceBaseURLPromise(cbFuncs.tenantId).then(function(url){
            var fullURL = url + "PredicateRangeValues?uri=" + iPropUri + "&tenant=" + cbFuncs.tenantId;
            var headers = {};
            headers['Accept-Language'] = language;
            RequestUtils.sendRequest(fullURL, {
              method: 'GET',
              headers: headers,
              timeout: 30000,
              onComplete: function (response) {
                var jsResponse;
                try {
                  jsResponse = JSON.parse(response);
                  if (cbFuncs.apiVersion === "R2019x") {
                    jsResponse = DicoUtils.convertToR421RangeValues(jsResponse);
                  }  
                }
                catch (e){
                  console.warn('*** Warning: server returned empty result *** ' + e);
                }
                finally {
                  return resolve(jsResponse);
                }
              },
              onFailure: function (data) {
                return reject(data);              
              }
            });
          });
        });
      },

      get6WPredicates: function (cbFuncs) {
        return new Promise(function(resolve, reject){ 
          var language = '';
          var param = "";
          if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
            language = cbFuncs.lang;
          }
          else{
            language = widget.lang;
          }
          if (cbFuncs.RDFServiceURL && cbFuncs.RDFServiceURL.startsWith("ODTService@")){
            cbFuncs.tenantId = "ODTService@" + cbFuncs.tenantId;
          }
          
          // SGA5: IR-619053 Add new parameter mappable to WS URL
          if (cbFuncs.onlyMappable){
            param = "&mappable=true";
          }
          DicoUtils.get3DSpaceBaseURLPromise(cbFuncs.tenantId).then(function(url){
            var fullURL = url + "6WPredicates?tenant=" + cbFuncs.tenantId + param;
            var headers = {};
            headers['Accept-Language'] = language;
    
            RequestUtils.sendRequest(fullURL, {
              method: 'GET',
              headers: headers,
              timeout: 30000,
              onComplete: function (response) {
                try {
                  var jsResponse = JSON.parse(response);
                  resolve(jsResponse);
                }
                catch (e) {
                  console.warn('*** Warning: server returned empty result *** ' + e);
                  resolve();
                }
              },
              onFailure: function (data) {
                reject(data);
              }
            });
          });
        });
      }
    };

    return dicoReadAPI;
  });

/**
 * @overview Provide seamless access to all dictionaries of 3DExperience data-sources
 * @file FedDictionaryAccessAPI.js provides functions for apps to
 *       access federated and data-source specific  dictionaries
 * @licence Copyright 2017 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 */

/*global define, document*/
/*jslint plusplus: true*/

define('DS/FedDictionaryAccess/FedDictionaryAccessAPI',
  ['UWA/Core',
    'DS/FedDictionaryAccess/FedDicoUtils',
    'DS/FedDictionaryAccess/FedDictionaryAccess3DSpace',
    'DS/FedDictionaryAccess/FedDictionaryAccessRDF'],

  /**
   * <p>
   * This module aims at providing APIs to access dictionaries of various
   * 3DExperience services (6WTags, 3DSpace, 3DSwym, RDF,...)
   * <p>
   * The exposed APIs return their output asynchronously as data may
   * require a back-end request to be retrieved.
   * </p>
   *
   * @module DS/FedDictionaryAccess/FedDictionaryAccessAPI
   */
  function (Core, DicoUtils, FedDictionaryAccess3DSpace, FedDictionaryAccessRDF) {

    "use strict";

    var _OntoService = DicoUtils.initSrvRequest();

    var retrievePropValuesFromCache = function (propValsElems, cbFuncs) {
      var jsPropValues = JSON.parse(propValsElems);

      var to_dwnld = {}, propValsCached = {}, cacheMissVals = [];
      var propId, propVals, vals = [];
      if (!jsPropValues){
        return;
      }

      //SGA5: if error, still return array of 2
      if (!window.sessionStorage) {
        cacheMissVals[0] = {};
        cacheMissVals[1] = jsPropValues;
        return cacheMissVals;
      }

      //SGA5: if error, still return array of 2
      if (!Core.is(cbFuncs, 'object')) {
        cacheMissVals[0] = {};
        cacheMissVals[1] = jsPropValues;
        return cacheMissVals;
      }

      var language = '';
      if (Core.is(cbFuncs.lang, 'string')){
        language = cbFuncs.lang;
      }
      else{
        language = widget.lang;
      }

      var storageName = DicoUtils.dicoPropValuesBaseKey + language;

      var localValues = sessionStorage.getItem(storageName);
      //SGA5: if no NLS found, still return array of 2
      if (!localValues) {
        cacheMissVals[0] = {};
        cacheMissVals[1] = jsPropValues;
        return cacheMissVals;
      } else {
        localValues = JSON.parse(localValues);
      }

      var propIds = Object.keys(jsPropValues);

      for (var i = 0; i < propIds.length; i++) {
        propId = propIds[i];
        // console.log("*** retrieve propId.: " + propId);
        propVals = localValues[propId];
        if (!propVals) {
          /*
           * console.log(" > Property not retrieved from cache, hence need to call WS: " + propId);
           */
          to_dwnld[propId] = jsPropValues[propId];
        } else {
          // console.log(" > Property found in cache: " + propId);
          var searchedVals = jsPropValues[propId];
          var nbSearchedVals = searchedVals.length;
          var objVals = {};
          for (var j = 0; j < nbSearchedVals; j++) {
            var v = searchedVals[j];
            // console.log("looking for value: " + v);
            if (propVals[v]) {
              // console.log(" > Found local value: " + nlsV);
              objVals[v] = propVals[v];
            } else {
              // console.log(" > Value not found in cache: " + v + " adding it to to_dwnld");
              vals.push(searchedVals[j]);
            }
          }
          if (Object.keys(objVals).length > 0){
            propValsCached[propId] = objVals;
          }
          if (vals.length) {
            to_dwnld[propId] = vals;
          }
        }
      }
      cacheMissVals[0] = propValsCached;
      cacheMissVals[1] = to_dwnld;
      return cacheMissVals;
    };

    /**
     * @exports DS/FedDictionaryAccess/FedDictionaryAccessAPI Module
     *          for dictionary read API. This file is to be used by
     *          App's which needs to access dictionary information
     *          from any data-source.
     *
     */
    var dicoReadAPI = {

      /** 
       * Sets myApps config objects that contains myAppsBaseUrl, userId and lang 
       * Required for use cases where the compass is not initiated: in web pop-ups and in web-in-win 
       * @param {object} config - JSON Object containing: 
       *                           myAppsBaseUrl: myApps url that can be retrieved from myAppsURL global variable in web (if compass is initiated) 
       *                                          or dscef.getMyAppsURL() in web-in-win 
       *                           userId: connected user's Id 
       *                           lang: connected user's language 
       *  
       */ 
      setConfigForMyApps: function(config) { 
        DicoUtils.setMyAppsConfig(config); 
      }, 

      /**
       * Retrieves the list of vocabularies intended for federation
       * @param {object} cbFuncs - Object containing at least onComplete and onFailure function that are
       *                           called when response is returned or failure has occured respectively.
       * @returns {object} The Json object representing the ontology.
       * @author SGA5
       */
      getFedVocabularies: function (cbFuncs) {
        if (DicoUtils.isRDFOn3DSpace(cbFuncs)) {
          FedDictionaryAccess3DSpace.getVocabularies(cbFuncs).then(function(result){
            cbFuncs.onComplete(result);
          }).catch(function(data){
            if (cbFuncs.onFailure) {
              cbFuncs.onFailure(data);
            }
          });
        }
        else {
          FedDictionaryAccessRDF.getVocabularies(_OntoService, cbFuncs)
          .then(function(result){
            cbFuncs.onComplete(result);
          }).catch(function(data){
            if (cbFuncs.onFailure) {
              cbFuncs.onFailure(data);
            }
          });
        }
      },

      /**
       * Function getResourcesInfo To get the NLS translation of a set
       * of vocabularies elements
       *
       * @param {string} elemNames: URI's of required elements,
       *            separated by a comma.
       * @param  {object} cbFuncs: object containing at
       *            least onComplete and onFailure function that are
       *            called when the elements are retrieved or when an
       *            error occurs
       * @returns {object} NLS name of the property as string.
       * @author SGA5
       */
      getResourcesInfo: function (elemNames, cbFuncs) {
        var language = '';
        if (Core.is(cbFuncs.lang, 'string') && cbFuncs.lang.length > 0){
          language = cbFuncs.lang;
        }
        else{
          language = widget.lang;
        }

        var storageName = DicoUtils.dicoElemsBaseKey + language;
        var localValues = sessionStorage.getItem(storageName);
        if (!localValues){
          localValues = {};
        }
        else {
          localValues = JSON.parse(localValues);
        }

        var reqElts = elemNames.split(",");
        var missingVals = [];
        var locRes = [];
        // get local values that are jsReqElems, if any
        var uri, i;
        if (localValues && Object.keys(localValues).length > 0) {
          for (i = 0; i < reqElts.length; i++) {
            uri = reqElts[i];
            if (localValues[uri]){
              locRes.push(localValues[uri]);
            }
            else{
              missingVals.push(uri);
            }
          }
        }
        else {
          missingVals = reqElts;
          sessionStorage.setItem(storageName, "");
        }

        if (missingVals.length > 0) {
          var result; 
          if (cbFuncs.apiVersion === "R2019x") {
            result = [];
            if (locRes.length > 0){
              result = locRes;
            }
          }
          else {
            result = {vocabularyElementNLSInfo: []};
            if (locRes.length > 0){
              result = DicoUtils.convertToR420ElementsNls(locRes);
            }
          }
          // now, load missing elements from data-sources
          if (DicoUtils.isRDFOn3DSpace(cbFuncs)) {
            // load all from 3DSpace, old infra
            FedDictionaryAccess3DSpace.getElementsNLSNames(cbFuncs, missingVals, true).then(function(data){
              if (cbFuncs.apiVersion === "R2019x") {
                result = result.concat(data);
              }
              else if (data.vocabularyElementNLSInfo){
                result.vocabularyElementNLSInfo = result.vocabularyElementNLSInfo.concat(data.vocabularyElementNLSInfo);
              }
              cbFuncs.onComplete(result);
            }).catch(function(data){
              console.error(data);
              if (cbFuncs.onFailure) {
                cbFuncs.onFailure(result);
              }
            });
          }
          else {
            // use RDF
            var cspaceElems = [], rdfElems = [];
            var promises = [];
            for (i = 0; i < missingVals.length; i++) {
              uri = missingVals[i];
              if (uri.startsWith("ds6wg:")) {
                cspaceElems.push(uri);
              }
              else {
                rdfElems.push(uri);
              }
            }
            if (rdfElems.length > 0) {
              // Call WS for RDF elements
              promises.push(FedDictionaryAccessRDF.getResourcesInfo(_OntoService, cbFuncs, rdfElems));
            }
            if (cspaceElems.length > 0) {
              // Call WS for 3DSpace elements
              promises.push(FedDictionaryAccess3DSpace.getElementsNLSNames(cbFuncs, cspaceElems));
            }
            // wait till both calls are finished
            Promise.all(promises).then(function(data){
              data.forEach(function(element){
                if (cbFuncs.apiVersion === "R2019x") {
                  result = result.concat(element);
                }
                else if (element.vocabularyElementNLSInfo){
                  result.vocabularyElementNLSInfo = result.vocabularyElementNLSInfo.concat(element.vocabularyElementNLSInfo);
                }
              });
              cbFuncs.onComplete(result);
            }).catch(function(data){
              console.error(data);
              if (cbFuncs.onFailure){
                cbFuncs.onFailure(result);
              }
            });
          }
        } else {
          console.log("### NLS retrieved from local cache.");
          if (cbFuncs.apiVersion !== "R2019x"){
            locRes = DicoUtils.convertToR420ElementsNls(locRes);
          }
          cbFuncs.onComplete(locRes);
        }
      },

      /**
       * Function getVocabularyProperties to get searchable properties of a gven vocabulary
       *
       * @param {string} iVocUri - The short URI of the vocabulary (e.g. "ds6w:")
       * @param {object} cbFuncs - Object containing at least onComplete and onFailure function that are
       *            called when response is returned or failure has occured respectively.
       * @returns {object} Array containing properties of the vocabulary including NLS translation.
       * @author SGA5
       */
      getVocabularyProperties: function (iVocUri, cbFuncs) {
        if (!iVocUri){
          console.error("Vocabulary name not provided");
          if (cbFuncs.onFailure){
            cbFuncs.onFailure();
          }
          return;
        }

        if (DicoUtils.isRDFOn3DSpace(cbFuncs)) {
          FedDictionaryAccess3DSpace.getPredicatesNLSNames(cbFuncs, iVocUri).then(function(result){
            cbFuncs.onComplete(result);
          }).catch(function(data){
            if (cbFuncs.onFailure) {
              cbFuncs.onFailure(data);
            }
          });
        }
        else {
          FedDictionaryAccessRDF.getVocabularyProperties(_OntoService, cbFuncs, iVocUri).then(function(result){
            cbFuncs.onComplete(result);
          }).catch(function(data){
            if (cbFuncs.onFailure) {
              cbFuncs.onFailure(data);
            }
          });      
        }
      },

      /**
       * Function getVocabularyClasses to get searchable classes of a given vocabulary
       *
       * @param {string} iVocUri - The short URI of the vocabulary (e.g. "ds6w:")
       * @param {object} cbFuncs - Object containing at least onComplete and onFailure function that are
       *            called when the classes are returned or when an error occurs
       * @returns {object} Array containing classes of the vocabulary including NLS translation.
       * @author SGA5
       */
      getVocabularyClasses: function (iVocUri, cbFuncs) {
        if (!iVocUri){
          console.error("Vocabulary name not provided");
          if (cbFuncs.onFailure){
            cbFuncs.onFailure();
          }
          return;
        }

        if (DicoUtils.isRDFOn3DSpace(cbFuncs)) {
          //console.log("### Retrieving RDF resources from 3DSpace...");
          FedDictionaryAccess3DSpace.getVocabularyClasses(cbFuncs, iVocUri).then(function(result){
            cbFuncs.onComplete(result);
          }).catch(function(data){
            if (cbFuncs.onFailure) {
              cbFuncs.onFailure(data);
            }
          });
        }
        else {
          if (iVocUri.startsWith("ds6wg")){
            return FedDictionaryAccess3DSpace.get3DSpaceTypes(cbFuncs, iVocUri).then(function(result){
              cbFuncs.onComplete(result);
            }).catch(function(data){
              if (cbFuncs.onFailure) {
                cbFuncs.onFailure(data);
              }
            });
          }
          else{  
            return FedDictionaryAccessRDF.getVocabularyClasses(_OntoService, cbFuncs, iVocUri).then(function(result){
              cbFuncs.onComplete(result);
            }).catch(function(data){
              if (cbFuncs.onFailure) {
                cbFuncs.onFailure(data);
              }
            });
          }
        }
      },

      /**
       * Function getPropertiesForClass to get searchable properties relevant for a class
       *
       * @param {object} iClassUri - A list of short URI classes/ interfaces (e.g. "ds6w:Document or ds6wg:VPMReference")
       * @param {object} cbFuncs - Object containing at least onComplete and onFailure function that are
       *            called when response is returned or failure has occured respectively.
       * @returns {object} Array containing properties of the vocabulary including NLS translation.
       * @author SGA5
       */
      getPropertiesForClass: function (iClassUri, cbFuncs){
        if (!iClassUri){
          console.error("getPropertiesForClass: no iClassUri");
          if (cbFuncs && cbFuncs.onFailure) {
            cbFuncs.onFailure(data);
          }
          return;
        }
        // if RDF service is not used, call old 3DSpace web service 
        if (DicoUtils.isRDFOn3DSpace(cbFuncs)) {
          //console.log("### Retrieving RDF resources from 3DSpace...");
          FedDictionaryAccess3DSpace.getPredicates(cbFuncs, iClassUri).then(function(data){
            cbFuncs.onComplete(data);
          }).catch(function(data){
            console.error(data);
            if (cbFuncs.onFailure){
              cbFuncs.onFailure(data);
            }
          });
        }
        else {
          var types = [];
          var classes = [];
          var elements = iClassUri.split(",");
          var result;

          for (var i=0; i<elements.length; i++){
            var element = elements[i];
            if (element.startsWith("ds6wg:")){
              types.push(element);
            }
            else{
              classes.push(element);
            }
          }
          var promises = [];
          // call new 3DSpace service for 3DSpace types
          if (types.length > 0) {
            promises.push(FedDictionaryAccess3DSpace.getTypeAttributes(cbFuncs, types));
          }
          // call RDF service for RDF classes
          if (classes.length > 0) {
            promises.push(FedDictionaryAccessRDF.getPropertiesForClasses(_OntoService, cbFuncs, classes));
          }
          // wait till both calls are finished
          Promise.all(promises).then(function(data){
            if (cbFuncs.apiVersion === "R2019x") {
              result = DicoUtils.convertToR421ClassProperties(data);
            }
            else{
              result = DicoUtils.convertToR420ClassProperties(data);
            }
            cbFuncs.onComplete(result);
          }).catch(function(data){
            console.error(data);
            if (cbFuncs.onFailure){
              cbFuncs.onFailure(data);
            }
          });
        }
      },

      /**
       * Function getNlsOfPropertiesValues To get the NLS translation of a list of property values
       *
       * @param {object} propValsElems - Object with keys as property URI and value a list of values to translate
       * @returns {String} NLS name of the property as string.
       * @author SGA5
       */
      getNlsOfPropertiesValues: function (propValsElems, cbFuncs){
        if (!Core.is(cbFuncs, 'object') || !Core.is(cbFuncs.onComplete, 'function')){
          return;
        }
        if (!propValsElems) {
          return cbFuncs.onComplete();
        }
        var cacheMissValues = retrievePropValuesFromCache(propValsElems, cbFuncs);
        if (!cacheMissValues || cacheMissValues.length < 2) {
          return cbFuncs.onComplete();
        }

        var cachedValues = cacheMissValues[0];
        var missingValues = cacheMissValues[1];
        
        // nothing's missing
        if (Object.keys(missingValues).length === 0) {
          return cbFuncs.onComplete(cachedValues);
        }
        else {
          var result = cachedValues;

          // Some data are missing in cache, try to load from data-sources         
          if (DicoUtils.isRDFOn3DSpace(cbFuncs)) {
            //console.log("### Retrieving RDF resources from 3DSpace...");
            FedDictionaryAccess3DSpace.getAttributesNlsValues(cbFuncs, missingValues, true).then(function(data){
              if (!data || !Object.keys(data)){
                return cbFuncs.onComplete(result);
              }
              for (var propId in data) {
                for (var val in data[propId]) {
                  if (!result.hasOwnProperty(propId)){
                    result[propId] = data[propId];
                  }
                  result[propId][val] = data[propId][val];
                }
              }
              return cbFuncs.onComplete(result);
            }).catch(function(data){
              console.error(data);
              if (cbFuncs.onFailure){
                return cbFuncs.onFailure(result);
              }
            });
          }
          else {  
            var cspaceElems = {}, rdfElems = {};
            var propIds = Object.keys(missingValues);
            var promises = [];
            var uri;
            for (var i = 0; i < propIds.length; i++) {
              uri = propIds[i];
              if (uri.startsWith("ds6wg:")) {
                cspaceElems[uri] = missingValues[uri];
              }
              else {
                rdfElems[uri] = missingValues[uri];
              }
            }
            // call RDF for RDF elements
            if (Object.keys(rdfElems).length > 0) {
              promises.push(FedDictionaryAccessRDF.getNlsOfPropertyValues(_OntoService, cbFuncs, rdfElems));
            }
            // call 3DSpace for ds6wg elements
            if (Object.keys(cspaceElems).length > 0) {
              promises.push(FedDictionaryAccess3DSpace.getAttributesNlsValues(cbFuncs, cspaceElems));
            }
            // wait till both calls are finished
            Promise.all(promises).then(function(data){
              if (!data || !Array.isArray(data)){
                return cbFuncs.onComplete(result);
              }

              data.forEach(function(element){
                if (element && Object.keys(element)){
                  for (var propId in element) {
                    for (var val in element[propId]) {
                      if (!result.hasOwnProperty(propId)){
                        result[propId] = element[propId];
                      }
                      result[propId][val] = element[propId][val];
                    }
                  }
                }
              });
              return cbFuncs.onComplete(result);
            }).catch(function(data){
              console.error(data);
              if (cbFuncs.onFailure){
                return cbFuncs.onFailure(result);
              }
            });
          }
        }
      },

      /**
       * Function getRangeValues to get range enumerated values of a data-type property
       *
       * @param {string} iClassUri iPropUri - The short URI of the property (e.g. "ds6w:country or ds6wg:PLMEntity.V_usage")
       * @param {object} cbFuncs - Object containing at least onComplete and onFailure function that are
       *            called when response is returned or failure has occured respectively.
       * @returns {object} - Object containing property range values including NLS.
       * @author SGA5
       */
      getRangeValues: function (iPropUri, cbFuncs){
        if (DicoUtils.isRDFOn3DSpace(cbFuncs)) {
          //console.log("### Retrieving RDF resources from 3DSPace...");
          FedDictionaryAccess3DSpace.getPredicateRangeValues(cbFuncs, iPropUri).then(function(result){
            cbFuncs.onComplete(result);
          }).catch(function(data){
            if (cbFuncs.onFailure) {
              cbFuncs.onFailure(data);
            }
          });
        }
        else {
            FedDictionaryAccessRDF.getRangeValues(_OntoService, cbFuncs, iPropUri).then(function(result){
            cbFuncs.onComplete(result);
          }).catch(function(data){
            if (cbFuncs.onFailure) {
              cbFuncs.onFailure(data);
            }
          });      
        }        
      },

      /**
       * Function getFedProperties to get all searchable properties intended for FedSearch
       *
       * @param {object} cbFuncs - Object containing at least onComplete and onFailure function that are
       *            called when response is returned or failure has occurred respectively.
       * @returns {object} - Object with vocabulary prefix keys having array value
       *                     with properties and NLS pertaining to the vovabulary .
       * @author SGA5
       */
      getFedProperties: function (cbFuncs) {
        if (DicoUtils.isRDFOn3DSpace(cbFuncs)) {
          //console.log("### Retrieving RDF resources from 3DSPace...");
          FedDictionaryAccess3DSpace.get6WPredicates(cbFuncs).then(function(result){
            cbFuncs.onComplete(result);
          }).catch(function(data){
            if (cbFuncs.onFailure) {
              cbFuncs.onFailure(data);
            }
          });
        }
        else {
            FedDictionaryAccessRDF.getFedProperties(_OntoService, cbFuncs).then(function(result){
            cbFuncs.onComplete(result);
          }).catch(function(data){
            if (cbFuncs.onFailure) {
              cbFuncs.onFailure(data);
            }
          });
        }
      },
    
      /**
       * Function getServiceClasses to get all classes of the given service
       * @param {string} iService - The name of the service as returned by MyApps (e.g. "3DSpace", "3DSwym" etc.)
       * @param {object} cbFuncs - Object containing at least onComplete and onFailure function that are
       *            called when response is returned or failure has occured respectively
       * @returns {object} - A list of classes for a given service. This object is passed to onComplete function from cbFuncs.
       * @author SGA5
       */
      getServiceClasses: function (iService, cbFuncs){
        var serviceCode = iService;

        if (iService === "3DSpace") {
          serviceCode = "ds6wg:";
        }
        
        if (iService === "3DSwym"){
          serviceCode = "swym:";
        }

        if (iService === "3DSpace" || iService === "3DSwym"){
          var callBack = cbFuncs.onComplete;

          cbFuncs.onComplete = function(result){
            var newResult = [];
            newResult.push(result);
            callBack(newResult);
          };
          return this.getVocabularyClasses(serviceCode, cbFuncs); 
        }

        FedDictionaryAccessRDF.getServiceClasses(serviceCode, cbFuncs).then(function(result){
          return cbFuncs.onComplete(result);
        }).catch(function(data){
          console.error(data);
          if (cbFuncs.onFailure){
            cbFuncs.onFailure(data);
          }
        });
      }
    };

    return dicoReadAPI;
  });


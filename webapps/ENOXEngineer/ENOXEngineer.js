// define('DS/ENOXEngineer/componentsHelpers/UserSummaryView/CustomTooltip',
//   [
//     'DS/UIKIT/Tooltip',
//     'UWA/Controls/Abstract',
//   ],
//   function(Tooltip,Abstract) {
//
//     'use strict';
//
//
//     var isMutationObserverAvailable = 'MutationObserver' in window;
//
//
//     var CustomTooltip = Tooltip.extend({
//       /**
//  * Main function for handling events.
//  * @private
//  */
// handleEvents: function () {
//
//     var that = this,
//         options = this.options,
//         isTouch = UWA.Utils.Client.Features.touchEvents,
//         triggers = options.trigger.split(' ');
//
//     function enter (_show, touch) {
//         return function (mouseEvent) {
//             if (that._shouldStopEventChain) {
//                 // event coming from a touchstart event chain + tooltips disabled on touch : prevent any action.
//                 // touchmove -> touchend -> mouseover -> mousemove -> mousedown -> mouseup
//                 // Reset the semaphore if click event (end of the touchstart event chain)
//                 if (mouseEvent && mouseEvent.type === 'click') that._shouldStopEventChain = false;
//                 return;
//             }
//             var show = (_show === undefined) ? !that.isVisible : _show;
//
//             if (show && touch) {
//                 // Hide the tooltip on touch devices when the body is clicked.
//                 that._touchstart = Element.addEvent.call(document.body, 'touchstart', function (evt) {
//                     Element.removeEvent.call(document.body, 'touchstart', that._touchstart);
//                     if (that.elements.container.isInjected() && Event.getElement(evt) !== options.target) {
//                         enter(false)();
//                     }
//                 });
//             }
//             if (options.delay) {
//               clearTimeout(that.timeout);
//                 that.timeout = setTimeout(function () {
//                     if (show && that.options.target && that.options.target.isInjected()) that.show();
//                     else if (!show) that.hide();
//                 }, show ? options.delay.show : options.delay.hide);
//             } else {
//                 that[show ? 'show' : 'hide']();
//             }
//         };
//     }
//
//     // Add events
//     if (!this.events && options.target) {
//         this.events = {};
//
//         if (isTouch) {
//             this.events.touchstart = function (evt) {
//                 // this will prevent the tooltip from showing when the trigger is touched
//                 // by "canceling" the click, focus... events that follow the touchstart.
//                 // the event chain is as follows:
//                 // touchstart -> touchmove -> touchend -> mouseover -> mousemove -> mousedown -> mouseup -> click
//                 if (this.options.trigger.indexOf('touch') === -1) {
//                     this._shouldStopEventChain = true;
//                     evt.stopPropagation();
//                 }
//             }.bind(this);
//         }
//
//         triggers.forEach(function (trigger) {
//             if (trigger === 'hover') {
//                 this.events.mouseover = enter(true);
//                 this.events.mouseout =  enter(false);
//             }
//
//             if (trigger === 'focus') {
//                 if (isTouch) {
//                     this.events.click = enter(undefined, isTouch);
//                 } else {
//                     this.events.focus = enter(true);
//                     this.events.blur = enter(false);
//                 }
//             }
//
//             if (trigger === 'click') {
//                 this.shouldListenForScroll = true;
//                 this.events.click = enter();
//             }
//         }, this);
//
//         if (options.closeOnClick && !this.events.click) {
//             this.events.click = enter();
//         }
//
//         if (!options.target.addEvents) {
//             UWA.extendElement(options.target);
//         }
//
//         if (!that.elements.container.addEvents) {
//             UWA.extendElement(that.elements.container);
//
//         }
//
//         that.elements.container.addEvents({
//           mouseover:function(ev){
//             clearTimeout(that.timeout);
//           },
//           mouseleave: function(ev){
//             that.hide();
//           }
//         })
//
//         options.target.addEvents(this.events,false,0,true);
//
//     }
// },
//
//     });
//
//     return CustomTooltip;
//
// });

// define('DS/ENOXEngineer/componentsHelpers/UserSummaryView/userSummaryView',
//   [
//     'UWA/Core',
//     'DS/W3DXComponents/Views/Temp/TempItemView',
//     'text!DS/ENOXEngineer/components/UserSummaryView/userSummaryView.html',
//     'css!DS/ENOXEngineer/components/UserSummaryView/userSummaryView.css',
//   ],
//    function(Core, ItemView,userSummaryViewTemplate) {
//
//     'use strict';
//
//     var UserSummaryView = ItemView.extend({
//       name:'xEng-user-box',
//       tagName:'div',
//       template: function () {
//             return userSummaryViewTemplate;
//         },
//       domEvents: {
//       },
//       setup: function () {
//             this.container.addClassName('xEng-user-box-container');
//         },
//       onRender: function (){
//       }
//
//     });
//
//     return UserSummaryView;
//
// });

define('DS/ENOXEngineer/components/Triptych/TriptychWrapper',
    [
      'DS/ENOXTriptych/js/ENOXTriptych',
      'DS/CfgAuthoringContextUX/scripts/CfgAuthoringContext',
      'css!DS/ENOXEngineer/components/Triptych/ENOXTriptych.css',
    ], function(ENOXTriptych,CfgAuthoringContext) {

    'use strict';

    function TriptychWrapper(sandbox){
      this.sandbox = sandbox;

      var options = {
                   left:{
                       resizable:false,
                       originalSize: 300,
                       originalState: 'close', // true for open, false for close
                       pushOnMobile: true
                   },
                   right:{
                       resizable:true,
                       originalSize: 400,
                       originalState: 'close', // true for open, false for close
                       pushOnMobile: true
                   },
                   container: sandbox.getContainer(),
                   withtransition: true,
                   modelEvents: sandbox.getApplicationBroker()
               };
               this.leftSideDiv = document.createElement('div');
               this.leftSideDiv.classList.add('triptych-panel-wrapper');

               this.centerDiv = document.createElement('div');
               this.centerDiv.classList.add('triptych-panel-wrapper');

               this.rightDiv = document.createElement('div');
               this.rightDiv.classList.add('triptych-panel-wrapper');
               this.rightDiv.classList.add('triptych-right-panel-wrapper');


               this.triptych = new ENOXTriptych();

               this.triptych.init(options, this.leftSideDiv, this.centerDiv, this.rightDiv);

               this.mainDiv = document.createElement('div');
               this.mainDiv.classList.add('xen-main-panel-wrapper');
               this.centerDiv.appendChild(this.mainDiv);

    }

    TriptychWrapper.prototype.start = function (){
          // The change bubble
          //Work under Change
          var that = this;
   
            var options = {
                          'isEditable': true,
                          'isEvolution':true,
                          'isChange':true,
                          'isMovable':true,
                          'resetDefault':true                       
                      };
              var initializeCallabck = function (opt){
                  console.warn(opt);
              };
              CfgAuthoringContext.initialize2(/*that.container*/that.centerDiv, 
                  that.sandbox.core.settingManager.getAppId(),
              'show', 
              'top-left',initializeCallabck, options);                     
           

    }


    return TriptychWrapper;

});

/**
 * @module DS/ENOXEngineer/services/XEngLocalStorage
 */
define('DS/ENOXEngineer/services/XEngLocalStorage', ['UWA/Core', 'UWA/Class'], function(UWA, Class) {

    'use strict';

     /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/services/XEngLocalStorage
     * @param {Object} options options hash or a option/value pair.
     */
    var XEngLocalStorage = Class.singleton(
    /**
     * @lends module:DS/ENOXEngineer/services/XEngLocalStorage
     */
    {
        init: function(options) {
          if (!UWA.is(localStorage)) {   return; }

          var  xEngRawData = localStorage.getItem('xEngineerData');
          if (UWA.is(xEngRawData)) {
              try {
                this.xEngData = JSON.parse(xEngRawData)
              } catch (e) {  console.error('error during parsing !'); }
          }

          if (!UWA.is(this.xEngData)) {
            this.xEngData = {};
            this._commit();
          }

          if(!UWA.is(this.xEngData.xEng_mode)){
            this.xEngData.xEng_mode = 'index';
            this._commit();
          }
          //call settingservice to get the right mode
          this.xEngData.xEng_mode = 'index';
          this._commit();

        },
        setItem : function(key, value) {
          if (!UWA.is(localStorage)) {   return; }

          this.xEngData[key] = UWA.clone(value);
          this._commit();

        },
        getItem : function(key) {
          if (!UWA.is(localStorage)) { return; }
          return this.xEngData[key];
        },
        _commit : function(){
          localStorage.setItem('xEngineerData', JSON.stringify(this.xEngData));
        },
        removeItem : function(key) {
          if (!UWA.is(localStorage)) { return; }
          delete this.xEngData[key];

          this._commit();
        },
        consumeItem : function(key) {
          if (!UWA.is(localStorage)) { return; }
          var returnable = this.getItem(key);
          this.removeItem(key);
          return returnable;
        }

    });

    return XEngLocalStorage;
});

define('DS/ENOXEngineer/utils/ResponseParser',[
	'UWA/Core',
	'WebappsUtils/WebappsUtils'
],function (Core, WebappsUtils) {

	var ResponseParser = {
		getListOfVersionsFromRoot:function(node, result /*array*/){
			if(!node) return null;

			var that = this;
			//collect current version
			result.push(that._readVersionData(node));

			if(Array.isArray(node.Derived)  && node.Derived.length >0){
				for (var i = 0; i < node.Derived.length; i++) {
					that.getListOfVersionsFromRoot(node.Derived[i], result);
				}
			}

			if(node["Main Derived"] && node["Main Derived"].id){
				that.getListOfVersionsFromRoot(node["Main Derived"], result);
			}

		},
		_readVersionData: function(nodeData){
			if(!nodeData) return null;
			var result = {
				type: nodeData.type,
				revision: nodeData.revision,
				state: nodeData.current,
				physicalid: this._getPidWithoutPrefix( nodeData.id),
				icons : ["product"],
				name: nodeData.name,
				thumbnail: (nodeData.image && nodeData.image.trim().length >0) ? nodeData.image : null
			};
			if(nodeData.attributes){
				result.MarketingName = nodeData.attributes.MarketingName || null;
			}

			result["label"] = (result.MarketingName) ? result.MarketingName : result.name;
			result["label"] += ' - '+result.revision;
			result["subLabel"] = result.type;
			result["description"] = result.state;

			return result;

		},
		retrieveProdConfsInfo : function(getPCResponse){
			if(!getPCResponse || !Array.isArray(getPCResponse.productconfigurations) )
				throw new Error("Ouups ! invalid response structure");
			var result = [], that = this;

			getPCResponse.productconfigurations.forEach(function(prodConf){
				result.push({
					name : prodConf.name,
					id : that._getPidWithoutPrefix(prodConf.id),
					marketingName : prodConf.marketingName,
					FilterCompiledForm : prodConf.attributes ? prodConf.attributes.FilterCompiledForm : null
				});
			});
			return result;
		},
		parseSetConfContext :function(serverResponse){

			var KOStatus = ["ERROR", "WARNING", "notProcessed" ];
			var report = [];

			if(!serverResponse || !serverResponse.contexts || !Array.isArray(serverResponse.contexts.content)){
				report.push({
					status : false,
					message :"UNKNOWN Response"
				});
				return report;
			}
			serverResponse.contexts.content.forEach(function(modelStatus){
				if(KOStatus.indexOf(modelStatus.status) !== -1 ){
					report.push({
						status : false,
						message :modelStatus.errorMessage,
						modelId : modelStatus.modelId
					});
				}else{
					report.push({
						status : true,
						message :modelStatus.errorMessage,
						modelId : modelStatus.modelId
					});
				}

			});

			return report;

		},
		configInfoParser : function(response){
			if(!response || !response.contexts || !response.contexts.content || !Array.isArray(response.contexts.content.results))
				throw new Error("Ouups ! invalid response structure");

			var parsedObjects = [], that = this;

			var results = response.contexts.content.results;

			for (var i = 0; i < results.length; i++) {
				if(!results[i].success)
					continue;
				var tempObj  = that.maskBasedAttributesParser(results[i]);
				parsedObjects.push(tempObj);
			}
			return parsedObjects;

		},
		_getPidWithoutPrefix : function(prefixedUrl){
				return prefixedUrl.startsWith("pid:") ? prefixedUrl.substr(4) : prefixedUrl;
		},
		modelVersionsParser : function(res){
			if(!res || !res.products)
			return null;

			 var current =res.products;
			return current;
		},
		maskBasedAttributesParser: function(attributes){
			var that = this;
			if(!Array.isArray(attributes.basicData)) return null;
			var result = {};
			attributes.basicData.forEach(function(attr){
				switch (attr.name) {
				  case "owner":
				    result["subLabel"] = result["ds6w:responsible"] = that._getDBAttributeValue(attr);
				    break;
				  case "description":
				    result["description"] = result["ds6w:description"] = that._getDBAttributeValue(attr);
				    break;
				  case "type":
				    result["type"] = that._getDBAttributeValue(attr);
				    break;
				  case "originated":
				    result["ds6w:created"] = that._getDBAttributeValue(attr);
				    break;
				  case "modified":
				    result["ds6w:modified"] = that._getDBAttributeValue(attr);
				    break;
				  case "revision":
				    result["ds6wg:revision"] = that._getDBAttributeValue(attr);
				    break;
				  case "current":
				    result["ds6w:status"] = that._getDBAttributeValue(attr);
				    break;
				  case "name":
				    result["label"] = result["ds6w:label"] = that._getDBAttributeValue(attr,'');
				    break;
				  default:

				}
			});
			// result.thumbnail = attributes["type_icon_large_url"];
			result["description"] = "State : " + result["ds6w:status"];
			result.icons = ["product"];//[attributes["type_icon_url"]];
			result.physicalid = attributes["physicalID"];
			return result;
		},
		_getDBAttributeValue: function(attr,defaultValue){
			return  Array.isArray(attr.value) ? attr.value[0] : defaultValue;
		},
	  attributesParser : function(attributesFromServer, nlsTracker){
			if (!Array.isArray(attributesFromServer))
			throw new Error("Ouups ! invalid input");

			var jsonNode = {};
			var attributes = attributesFromServer;
			for (var i = 0; i < attributes.length; i++) {
			  var attr = attributes[i];
				var attrName = attr.name;
				if(attr.format && attr.format === 'ds6w_facet'){
					attrName = attr.name.split('/').pop();
				}
				//nls tracking
				if ( nlsTracker && attrName.startsWith("ds6w")&& Array.isArray(nlsTracker.classes) && nlsTracker.properties) {
					if (nlsTracker.classes.indexOf(attrName)===-1) {
						nlsTracker.classes.push(attrName);
					}
					if (Array.isArray(nlsTracker.withNlsProp) && nlsTracker.withNlsProp.indexOf(attrName)!==-1) {
						if (!nlsTracker.properties[attrName]) {
							 nlsTracker.properties[attrName] = []
						}

						if (nlsTracker.properties[attrName].indexOf(attr.value)===-1) {
							nlsTracker.properties[attrName].push(attr.value);
						}
					}
				} //end of nls tracking

			  switch (attrName) {
			    case 'resourceid':
			      jsonNode.resourceid = attr.value;
						jsonNode.physicalid = attr.value;
			      break;
			    case 'type_icon_url':
			      if (!jsonNode.icons) jsonNode.icons = [];
			      jsonNode.icons.push(attr.value);
			      break;
			    case 'preview_url':
			      jsonNode.thumbnail = attr.value;
			      break;
					case 'thumbnail_2d':
						jsonNode.thumbnail = attr.value;
						break;
					case 'ds6w:type':
						jsonNode.type = attr.value;
						break;
					case 'ds6wg:PLMReference.V_isLastVersion':
						jsonNode.isLastVersion = (typeof attr.value === "boolean") ? (attr.value) : ((attr.value.toUpperCase() === "TRUE") ? true : false)
						jsonNode['ds6wg:PLMReference.V_isLastVersion'] = attr.value;
						break;
					case 'bo.PLMReference.v_versionid':
						jsonNode.versionid = attr.value;
						break;
			    default:
			      	jsonNode[attrName] = attr.value;
			      break;
			  }
			}

			return jsonNode;

		},
		parseFetchResult : function(serverResponse, classesWithNlsProp){
			var inputs = serverResponse.results || [];
			var results = [];
			var that = this;
			var nlsTracker = null;
			if (classesWithNlsProp) {
				nlsTracker = {
								withNlsProp : classesWithNlsProp,
								classes : [],
								properties: {}
							};
			}

			inputs.forEach(function(item){
				if(item.attributes.length === 0 || (item.sort && item.sort.sortType ==="#DELETE#")){
					results.push({deleted:true});
				}else{
					results.push(that.attributesParser(item.attributes, nlsTracker));
				}

			});

			return {
				results : results,
				nlsTracker : nlsTracker
			};
		},
		cleanExpandParsedData: function(parsedData){
			if (parsedData) {
				parsedData.root = undefined;
				if (parsedData.nodes) {
					for (var did in parsedData.nodes) {
						if (parsedData.nodes.hasOwnProperty(did)) {
							parsedData.nodes[did]= undefined;
						}
					}
					parsedData.nodes = undefined;
				}

				if (parsedData.iconsSet) {
					parsedData.iconsSet = undefined;
				}
				if (Array.isArray(parsedData.paths)) {
					for (var i = 0; i < parsedData.paths.length; i++) {
						parsedData.paths[i] = undefined;
					}
					parsedData.paths = undefined;
				}
				parsedData = undefined;
			}
		},
		parseAndBuildIRPCStructure: function(serverResponse, classesWithNlsProp, parsingOptions){
			var that = this;

			var preParsedData = that.parseExpandResult(serverResponse, classesWithNlsProp);
			var rootdid;
			var pathHolder = preParsedData.paths;
			var indexForRootId = null;

			if(parsingOptions && parsingOptions.pathLength){
				var keys = Object.keys(preParsedData.nodes);

			for(var j=0; j<keys.length; j++){
					if(preParsedData.nodes.hasOwnProperty(keys[j])){
					if(preParsedData.nodes[keys[j]].physicalid === parsingOptions.physicalId){
						rootdid = preParsedData.nodes[keys[j]].did;
						break;
					}
				}
			}
			 for(var i=0; i<preParsedData.paths[0].length; i++){
				 if(preParsedData.paths[0][i] == rootdid){
					indexForRootId  = i;
					break;
				 }
			 }
			}

			if (!preParsedData || !preParsedData.nodes || !Array.isArray(preParsedData.paths))
			throw new Error("Ouups ! invalid input");

			//set the icons and thumbnails
			preParsedData.iconsSet = preParsedData.iconsSet || [];
			for (var i = 0; i < preParsedData.iconsSet.length; i++) {
				var defaultIconSet = preParsedData.iconsSet[i];
				for (var j = 0; j < defaultIconSet.did.length; j++) {
					var currentNodeDid = defaultIconSet.did[j];
					var node_to_mod = preParsedData.nodes[currentNodeDid];
					if (!node_to_mod.icons || !Array.isArray(node_to_mod.icons)) {
					  node_to_mod.icons = [];
					}
					node_to_mod.icons.push(defaultIconSet.icon);
					if (!node_to_mod.thumbnail) {
					  node_to_mod.thumbnail = defaultIconSet.thumbnail_2d;
					}
				}
			}

			//build the IRPC Structure

			var idx = (indexForRootId == null) ? 0: indexForRootId;
			preParsedData.paths.forEach(function(path){
					var pathLength = path.length;
					if (Math.abs(pathLength % 2) === 1){

						for (var i = idx; i < path.length; i++) {

							var currentNode = preParsedData.nodes[path[i]];
							//var hasNextNode = (i+1)<pathLength;
							var nextNode = (i+1)<pathLength ? preParsedData.nodes[path[i+1]]:null;
							if (Math.abs(i % 2) === 0 /*  is reference node*/) {

								if (!currentNode.children) {
									currentNode.children = [];
								}

								if (nextNode) {

									var found = false;
									for(var j = 0; j < currentNode.children.length; j++) {
									    if (currentNode.children[j].did === nextNode.did) {
									        found = true;
									        break;
									    }
									}
               //TO Do
									if (!found)
										currentNode.children.push(nextNode);
								}

							}else {/*  is instance node*/

								if (nextNode) {
									currentNode.instanceOf = nextNode;
								}
							}
						}
					}else {
						console.error("incomplete path");
					}
			});

			//set the root
			if(Array.isArray(preParsedData.paths[0]) && preParsedData.paths[0].length>0 )
			preParsedData.root =(idx> 0 && rootdid >= 0) ?preParsedData.nodes[rootdid] :preParsedData.nodes[preParsedData.paths[0][0]];

			return preParsedData;

		},
		parseExpandResult : function(serverResponse, classesWithNlsProp){
			if (!serverResponse || !Array.isArray(serverResponse.results))
			throw new Error("Ouups ! invalid input");

			var parsed_expand = {
            nodes: {},
						root:null,
            paths: [],
						nlsTracker : {
							withNlsProp : classesWithNlsProp,
							classes : [],
							properties: {}
						},
						iconsSet: []
        };
			var that = this;
			 serverResponse.results.forEach(function(result){

				 if (result.hasOwnProperty('attributes')){
					 var node = that.attributesParser(result.attributes, parsed_expand.nlsTracker);
					 if (Core.is(node.did)) parsed_expand.nodes[node.did] = node;

				 } else if (result.hasOwnProperty('path')){
					 parsed_expand.paths.push(result.path);
				 }else if (result.hasOwnProperty('icon__default_thumbnail_2d')){
					 parsed_expand.iconsSet = result.icon__default_thumbnail_2d
				 }

			 });
			 return parsed_expand;
		},
		getInstanceName : function(serverResponse){
			if (!Array.isArray(serverResponse.results)) {
				throw "wrong server response";
			}
			var names = [];

			serverResponse.results.forEach(function(instance){

				for (var i = 0; i < instance.data.length; i++) {

					if (instance.data[i].name === "PLM_ExternalID") {
						names.push({name : instance.data[i].value[0], instanceId :instance.physicalID});
						break;
					}
				}

			});

			return names;
		},
};

	return ResponseParser;
});

define('DS/ENOXEngineer/utils/xEngPnOSCChoiceMngt',  ['DS/WAFData/WAFData'] ,
        function (WAFData) {
    	
	'use strict';
	
	var _SCPreferred ;
	var CREDENTIALS_SEPARATOR = " ● ";
    var exports;
    
	exports =  function (options) {
	    //Local 
	    var _the3DSpaceUrl     = options.url ;	
		var _platformInstance  = options.platforminstance
		var _theListSC = [] ;
		var _theListSC_NLS = [] ;
		var _SCPreferredDB ;
		var _callback ;
		
		// Function checking if a SC is one among the list coming
		// the backend.
		// Check called when the backend does not contain a preferred SC
		function checkValiditySC( compare ) {
			var find=false ;
			var i = 0 ;
			while ( ( !find  ) && (i < _theListSC.length) ) {
				if ( compare === _theListSC[i] ) {
					find = true ;
				}
				i++ ;
			}
			return find ;
	    }; 
		
		function ComputeList (elt) {
		    var NoIssue = false ;
			
			var TheCBPreferred , TheRolePreferred, TheOrgPreferred ;
            var ThePreferredJson=elt.preferredcredentials;
			if ( ThePreferredJson.collabspace && 
			     ThePreferredJson.role && 
				 ThePreferredJson.organization ) {
				var TheCBPreferredJson=ThePreferredJson.collabspace;
				var TheRolePreferredJson=ThePreferredJson.role;
				var TheOrgPreferredJson=ThePreferredJson.organization;
				TheCBPreferred = TheCBPreferredJson.name;
				TheRolePreferred = TheRolePreferredJson.name;
				TheOrgPreferred = TheOrgPreferredJson.name;
				
				_SCPreferredDB = TheRolePreferred +"."+TheOrgPreferred+"."+TheCBPreferred; 
			}
			
		    var TheCollabSpacesArray = elt.collabspaces;
			if ( TheCollabSpacesArray && TheCollabSpacesArray.length > 0 ) {
				//check if multiorgaization
				var bMultiOrgnizationPresent = false;
				var currOrgName = undefined;
				for (var i = 0; i < TheCollabSpacesArray.length; i++) {
					var TheCurrentCSJson = TheCollabSpacesArray[i];
					var TheCouples = TheCurrentCSJson.couples || [];
					for (var j = 0; j < TheCouples.length; j++){
						var couple = TheCouples[j];
						if(currOrgName === undefined)
						currOrgName = couple.organization.name;
						if(currOrgName !== couple.organization.name) {
							bMultiOrgnizationPresent = true;
							break;
						}
					}

					if(bMultiOrgnizationPresent) break; //optimization
				}
				for (var i = 0; i < TheCollabSpacesArray.length; i++) {
					var TheCurrentCSJson = TheCollabSpacesArray[i];
					var TheCurrentCS=TheCurrentCSJson.name;
					var TheCouples = TheCurrentCSJson.couples;
					for (var j = 0; j < TheCouples.length; j++) {
						var  TheCurrentCoupleJson = TheCouples[j] ;
						var TheOrganization=TheCurrentCoupleJson.organization;
						var TheRole=TheCurrentCoupleJson.role;
						var TheCurrentOrg = TheOrganization.name;
						var TheCurrentRole = TheRole.name;
					    var TheCurrentRoleNLS = TheRole.nls;
						
						
						var SCCurrent=TheCurrentRole+"."+TheCurrentOrg+"."+TheCurrentCS ;
						// var SCCurrent_NLS= TheCurrentOrg+" - "+TheCurrentCS+" - "+TheCurrentRoleNLS ;
						var SCCurrent_NLS=  bMultiOrgnizationPresent ? TheCurrentCS+ CREDENTIALS_SEPARATOR + TheCurrentOrg + CREDENTIALS_SEPARATOR + TheCurrentRoleNLS :  TheCurrentCS+  CREDENTIALS_SEPARATOR + TheCurrentRoleNLS  ;
						
						_theListSC.push(SCCurrent);
						_theListSC_NLS.push(SCCurrent_NLS);
						if ( _SCPreferredDB ) {
						    // at least one must be the preferred SC
							if ( (TheOrgPreferred === TheCurrentOrg)  && 
								 (TheRolePreferred === TheCurrentRole)  && 
								 (TheCBPreferred === TheCurrentCS)  ) {
								 NoIssue=true;
							}
						}else NoIssue=true;
					}
				}
			}
			_callback(NoIssue) ;
		};
		
		return {
			//
			// HTTP request to retrieve on 3DSpace the list of SC and its preferred one
			// for the connected user
			//
			RetrieveSCListAndPrefered : function ( option ) {
			    if ( option &&  option.callback ) {
					var pathWS=_the3DSpaceUrl + "/resources/modeler/pno/person?current=true";
                    pathWS += "&select=preferredcredentials&select=collabspaces" ;
                    // pathWS += "&select=collabspaces" ;
					pathWS +="&tenant=" + _platformInstance ;
					
					_callback = option.callback ;
				
					WAFData.authenticatedRequest(pathWS, {
						'method'    :'GET',	
						'type'     : 'json' ,
						'onComplete': ComputeList,	 					
						'onFailure' : function() { 
							_callback(false) ;
						}
					});	
                }					
			},
		
			//
			// Defines the current SC 
			//   The preferred from DB is choosen first ( implementative choice)
			//   otherwise if a previous one exist and still valid it is taken
			//   last choice : no SC, the end user will have to choose one before
			//   starting the application
			getSCPreference  : function ( NlsForPreference ) {
				
				var structure = {
					name: "SC",
					type: "list",
					label : NlsForPreference ,
					options: [] 
				} ;
				
				for ( var i=0 ; i < _theListSC.length ; i++ ) {
					// {value,label} both mandatory
					structure.options.push( { value : _theListSC[i] , label : _theListSC_NLS[i] } );
				}
				
				return structure ; 
			},
			
			//
			// Returns a valid current SC or undefined
			//
			getSCPreferred  : function ( theCurrentSC ) {
			    var returnValue;
				if ( _SCPreferredDB ) {
				    //The value from the db  is the first choice
					returnValue = _SCPreferredDB
				} else { // no preferred SC in DB
					// is the previous current SC still valid ?
					if ( checkValiditySC(theCurrentSC) ) {
						returnValue = theCurrentSC ;
					}else {
						console.error("no security context available ! ");
						// returnValue =  _theListSC[0];
						// request to choose a security context
						returnValue = null ;
					}
				}
				return returnValue ;
			}
		}
	} ;
    
    return exports;
});

define('DS/ENOXEngineer/componentsHelpers/XEngAutoComplete/XEngAutoComplete', [
  'UWA/Core',
  'DS/UIKIT/Autocomplete',
  'WebappsUtils/WebappsUtils'
], function(Core, Autocomplete, WebappsUtils) {

    'use strict';

    var  XEngAutoComplete = Autocomplete.extend({
      defaultOptions: {
                placeholder : 'Search ...',
                minLengthBeforeSearch : 3,
                multiSelect: true,
                closableItems: true,
                floatingSuggestions: true,
                nbResultsToShow : 20,
                targetTypes : [],
                sources : [],
                precondition : null,
                datasetName : 'xeng_data',
                typeDelayBeforeSearch: 500,
                objectMapper : null
             },
      /*
      *options.appCore
      *
      */
      init : function(options){
        this._parent(options);
        this.appCore = options.appCore;
        this.initXEngAutocomplete();
      },
      autocompleteDataParser : function(dataset, data){
        var that = this;
        if(!Core.is(that.options.objectMapper, "function"))
          throw new Error("options.objectMapper is a mandatory parameter");

        return  data.map(function(item){
           return that.options.objectMapper(item);
         })
      },
      initXEngAutocomplete : function(){
         var self = this;

         this.addDataset({
           name : self.options.datasetName,
           items : [],
           remoteSearchEngine : function(dataset, text){
              var that = this, results;
            return new Promise(function (resolve, reject){
              self.appCore.dataService.fireAutocompleteSearch({
                   criteria: text,
                   targetTypes : self.options.targetTypes,
                   nresults : self.options.nbResultsToShow,
                   sources : self.options.sources,
                   precond: self.options.precondition
                 }).then(function (data){
                   results = {};
                   results.matchingItems = [];
                   if (data) {
                       results.matchingItems = (Core.is(dataset.dataParser, 'function')) ? (dataset.dataParser.call(that, dataset, data)) : (that.defaultDataParser(data));
                   }
                   results.dataset = dataset;
                   resolve(results);
                 }).catch(function (errors){
                    errors.type = 'error';
                    errors.dataset = dataset;
                    reject(errors);
                 });

              }); //end of promise
            }, //end of remoteSearchEngine

           dataParser: function(dataset, data) {
               return self.autocompleteDataParser(dataset, data);
            }
         },{
           templateEngine: function (element, dataset, item) {
                        var xEngNameElt;

                        element.addClassName('xeng-template');

                        xEngNameElt = Core.createElement('span', { 'class': 'item-label' });
                        xEngNameElt.setText(item.label);
                        element.setContent([
                            Core.createElement('img', { 'src': item.icon  || WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'img/defaultIcon.png') }),
                            xEngNameElt
                        ]);
            },
           onError: function() {
             console.error(arguments);
            // that.hide();
           }
         }
       )
     },
     _addSearchButton : function(){

       var searBtn = UWA.createElement('span', {
                        'class': ' fonticon fonticon-search'
                    });
      return  searBtn;
     },
     setSelection : function(items){
       if(Array.isArray(items)){
         this.dispatchEvent('onSelect', items);
       }
     },
     onSelect : function (item, position){
    	 var that = this;
         this._parent(item, position);
         this.onSelectXeng && this.onSelectXeng(item);
     },
     onUnselect: function (item, position, newPosition, resetInput){
    	 var that = this;
         this._parent(item, position, newPosition, resetInput);
         this.onUnselectXeng && this.onUnselectXeng(item);
     },
     buildSkeleton : function(){
       var that = this;
       this._parent();
       var elements = this.elements,
                  className = this.name;

       elements.inputWrapper =  UWA.createElement('div', {
                    'class': className + '-searchbox-wrapper xEng-autocomplete'
                }).inject(elements.container, 'top');

       elements.inputContainer.remove();
       elements.inputContainer.inject(elements.inputWrapper);

       elements.xengSearch = this._addSearchButton();
       elements.xengSearch.removeEvent('click');
       elements.xengSearch.addEvent('click', function(){
         var inputField = elements.inputContainer.getElement('input');
         if (inputField) {
           that.onSearchClick(inputField.value);
         }

       });

       elements.xengSearch.inject(elements.inputWrapper);
     },
     onSearchClick : function(event){
       UWA.Event.stop(event);

     }
    });

    return XEngAutoComplete;

});

define('DS/ENOXEngineer/utils/XEngineerConstants', [
  'UWA/Core',
  'DS/ENOXEngineerCommonUtils/XENCommonConstants',
], function(UWA,XENCommonConstants) {

    'use strict';


      var  _contants = {
      /** events names */
      EVENT_REFRESH_APP_CONTENT : 'refresh-app-content',
      EVENT_REFRESH_WIDGETS : 'refresh-widgets',
      EVENT_CLEAR_WIDGETS_CLIPBOARD : 'clear-widgets-clipboard',
      EVENT_TRIPTYCH_PANEL_VISIBLE : 'triptych-panel-visible',
      EVENT_TRIPTYCH_PANEL_HIDDEN : 'triptych-panel-hidden',
      EVENT_TRIPTYCH_HIDE_PANEL : 'triptych-hide-panel',
      EVENT_TRIPTYCH_SHOW_PANEL : 'triptych-show-panel',
      EVENT_TRIPTYCH_RESIZE : 'resizing-triptych-container',
      EVENT_TRIPTYCH_TOGGLE_PANEL : 'triptych-toggle-panel',
      EVENT_TRIPTYCH_SET_SIZE : 'triptych-set-size',
      EVENT_SHOW_PROPERTIES : 'show-properties',
      EVENT_WELCOME_PANEL_ACTION_SELECTED : 'welcome-panel-action-selected',
      EVENT_WELCOME_PANEL_COLLAPSE : 'welcome-panel-collapse',
      EVENT_WELCOME_PANEL_EXPAND : 'welcome-panel-expand',
      EVENT_INFO_PANEL_CLOSE : 'information-panel-close',
      EVENT_INFO_PANEL_OPEN : 'information-panel-open',
      EVENT_INFO_PANEL_VISIBLE : 'information-panel-visible',
      EVENT_INFO_PANEL_HIDDEN : 'information-panel-hidden',
      EVENT_GO_BACK : 'go-back-event',
      EVENT_REFRESH_ITEMVIEW : 'xEngineer-refresh-itemView',
      EVENT_REFRESH_LANDING_DATA : 'xEngineer-refresh-landing-data',
      EVENT_IDCARD_READY : 'idCard-ready',
      EVENT_LIST_READY : 'list-view-ready',
      EVENT_LIST_SELECT_ITEM : 'item-selected',
      EVENT_REFRESH_LISTVIEW : 'refresh-listview',
      EVENT_RELOAD_ENGINEERING_DEFINITION : 'reload-list-content',
      EVENT_MY_EN_ITEM_READY : 'myEngItem-view-ready',
      EVENT_IDCARD_ATTRIBUTES_CLICKED : 'idcard-attributes-clicked',
      EVENT_IDCARD_CUSTOM_SHOW_LANDING : 'custom-show-landing-page-event',
      EVENT_IDCARD_CUSTOM_WP_TOGGLE_EVENT : 'custom-welcome-panel-toggle-event',
      EVENT_IDCARD_CUSTOM_INFORMATION_ICON : 'custom-information-icon-event',
      EVENT_IDCARD_CUSTOM_SHOW_CONFIGURATION : 'custom-show-configuration-event',
      EVENT_IDCARD_CUSTOM_SHOW_VERSION_EXPLORER : 'custom-show-version-explorer-event',
      EVENT_IDCARD_CUSTOM_OPEN_ACTIONS_MENU : 'custom-open-actions-menu-event',
      EVENT_IDCARD_CUSTOM_OPEN_BACK_BUTTON : 'idcard-back',
      EVENT_UPDATE_IDCARD_RENDERING: 'event-update-idcard-rendering',
      EVENT_INDEX_MODE_DISABLE: 'event_index_mode_disable',

      EVENT_COLLECTION_ACTION_UPDATE_COUNT : 'enox-collection-toolbar-items-count-update',
      EVENT_COLLECTION_SELECTALL_CHECKBOX_STATUS_PARTIAL : 'enox-collection-toolbar-select-all-checkbox-partial',
      EVENT_COLLECTION_TOOLBAR_CHECKBOX_HIDE : 'enox-collection-toolbar-hide-checkbox',
      EVENT_COLLECTION_TOOLBAR_CHECKBOX_SHOW : 'enox-collection-toolbar-show-checkbox',
      EVENT_COLLECTION_SELECTALL_CHECKBOX_STATUS_CHECKED : 'enox-collection-toolbar-select-all-checkbox-checked',
      EVENT_COLLECTION_SELECTALL_CHECKBOX_STATUS_UNCHECKED : 'enox-collection-toolbar-select-all-checkbox-uncheck',
      EVENT_COLLECTION_SELECTALL : 'enox-collection-toolbar-all-selected',
      EVENT_COLLECTION_UNSELECTALL : 'enox-collection-toolbar-all-unselected',
      EVENT_TOOLBAR_MULTISEL_COUNT :'enox-collection-toolbar-selections-count-update',
      EVENT_TOOLBAR_SORT  : 'enox-collection-toolbar-sort-activated',
      EVENT_TOOLBAR_DISABLE : 'enox-collection-toolbar-disable-action',
      EVENT_TOOLBAR_ENABLE : 'enox-collection-toolbar-enable-action',
      EVENT_TOOLBAR_SEARCH : 'enox-collection-toolbar-filter-search-value',
      EVENT_NOTIFY_CONTENT_SIZE_CHANGE: 'notify-content-size-change',
      EVENT_UPDATE_NODES_EFFECTIVITIES: 'event-update-nodes-effectivities',
      EVENT_COLORIZATION_UPDATED:'color-updated',

      EVENT_NEW_ENG_ITEM_CREATED : 'new-eng-item-created',
      EVENT_DELETED_ENG_ITEM : 'eng-item-deleted',
      EVENT_NEW_INSERTED_ENG_ITEM : 'inserted-eng-item',
      EVENT_NEW_ATTACHED_DOCUMENT:'new-attachement',
      EVENT_SET_ACTIVE_ENG_ITEM : 'set-active-eng-item',
      EVENT_RESET_SELECTION : 'reset-selection',
      EVENT_REPLACED_ENG_ITEM : 'replaced-eng-item',
      EVENT_DOWNLOAD_ITEM : 'download-item',
      EVENT_REMOVE_DOCUMENT : 'remove-item',
      EVENT_DELETE_DOCUMENT : 'delete-document',
      EVENT_REMOVED_INSTANCE : 'removed-instance',
      EVENT_CONF_MODEL_UPDATED : 'conf_model_updated',
      EVENT_UPDATE_NODES_WITH_CHANGESETS: 'event-update-nodes-with-changesets',
      EVENT_QUALIFIED_AS_FINAL_ITEM : 'event-qualified-as-final',
      EVENT_SYNC_VIEW_WITH_EI_MODEL: 'sync-view-with-model',
      EVENT_COLUMNS_CHANGED: 'columns-changed',
      EVENT_REMOVE_CUT_INSTANCES : 'remove_selected_cut_items_from_parent',

      /*  multisel events */
      MULTISEL_ACTIVATED : 'multisel-activated',
      MULTISEL_DEACTIVATED : 'multisel-deactivated',
      MULTISEL_ADD_ITEM : 'multisel-add-item',
      MULTISEL_REMOVE_ITEM: 'multisel-remove-item',

      /*
      view
       */
       MY_ENG_ITEMS_VIEW : 'my_engItem',
       ENG_ITEM_VIEW : 'eng_item_view',
       RECENT_ENG_ITEM_VIEW : 'recent_eng_item_view',

      /**  command events **/
      EVENT_LAUNCH_COMMAND : 'show-light-component',
      EVENT_SET_PARTNUMBER_COMPLETED : 'set-part-number-completed',
      EVENT_EDIT_MATERIAL_QTY_COMPLETED: 'edit-material-quantity-completed',
      EVENT_SET_WORKUNDER_EVOLUTION_COMPLETED: 'set-workunder-evolution-completed',
      EVENT_NEVER_SHOW_WORKUNDER_DLG: 'never-show-dialog-checkbox-checked',
      EVENT_NEW_VERSION_COMPLETED: 'new_version_created',

      /** welcome panel actions id  */
      WP_ADD_ENG_ITEM_ACTION : 'add_engItem',
      WP_ADD_NEW_PART_ACTION : 'add_newPart',
      WP_OPEN_ENG_ITEM_ACTION : 'open_engItem',
      WP_MY_ENG_ITEMS_ACTION : 'my_eng_items',
      WP_RECENTS_ITEMS_ACTION : 'recent_items',
      EVENT_SELECT_ACTION_WP : 'welcome-panel-select-action',
      WP_IMPORT_ENG_ITEM_ACTION : 'import_items',




      /** components name  */
      TRIPTYCH_CMP : "triptych",
      PROPERTY_CMP : "propertyView",
      ITEM_VIEW_CMP : 'itemView',
      IDCARD_CMP : 'IdCard',
      LIST_VIEW_CMP : 'ListView',
      LIST_VIEW_NEW_CMP : 'XEngListView',
      WELCOME_PANEL_CMP : "welcomePanel",
      MY_ENG_ITEM_CMP : "XEngGridView",
      CROSS_APP_SELECTION_EVENT: 'DS/PADUtils/PADCommandProxy/select',

      /**  Command name **/
      DUPLICATE_CMD : "DuplicateHdr",
      COMPARE_CMD  : 'CompareHdr',
      MATURITY_GRAPH_CMD : 'MaturityHdr',
      MATURITY_BULK_CMD : "maturity-bulk",
      CHANGE_OWNER_CMD : 'ActionBar_ChangeOwner',
      DELETE_CMD : 'DeleteHdr',
      REPLACE_BY_LATEST_REVISION : 'UPSReplaceByLatestRevision',
      REPLACE_BY_EXISTING : 'UPSAuthReplaceByExisting',
      REPLACE_BY_VERSION : 'replaUPSAuthReplaceByRevisionceByVersion',
      REPLACE_BY_LATEST_VERSION:'UPSAuthReplaceByRevision',
      UPDATE_VERSION : 'UPSAuthRevisionUpdate',
      UPDATE_WIDGET_TITLE : 'XENG_UPDATE_WIDGET_TITLE',
      CREATE_NEW_ENG_ITEM :'ActionBar_NewProductCmd',
      CREATE_NEW_PART :'ActionBar_NewPartCmd',
      VERSION_GRAPH_CMD : 'Show_Version_Graph',
      DETACH_ENG_ITEMS_CMD : 'UPSAuthUnparent',
      ADD_EXISTING : 'addExisting',
      ITEM_CUT_CMD : 'UPSAuthCut',
      ITEM_COPY_CMD : 'UPSAuthCopy',
      ITEM_PASTE_CMD : 'UPSAuthPaste',
      ADD_TO_CLIPBOARD : 'DS/UPSCommands/commands/UPSAuthCmdCutCopyPaste/clipboard',
      SET_PART_NUMBER_CMD : 'SetThePartNumber',
      ADD_MATERIAL_QUANTITY_CMD : 'addNewMaterialQuantity',
      CHANGE_QUANTITY_CMD : 'ChangeTheQuantity',
      CHANGE_MAT_QUANTITY_CMD : 'ChangeTheMaterialQuantity',
      SHOW_HISTORY_CMD :'HistoryHdr',
      ADD_EXISTING_DOC_CMD : 'XENG_ADD_EXISTING_DOC',
      ADD_NEW_DOC_CMD : 'XENG_ADD_NEW_DOC',
      RELATEDOBJECTS_CMD :'RelatedObjectsHdr',
      REVISE_CMD : 'RevisionHdr',
      REVISE_FROM_CMD : 'ReviseFromHdr',
      NEW_BRANCH_CMD : 'NewBranchHdr',
      EDIT_CONF_CONTEXT_CMD : 'XENG_EDIT_CONF_CONTEXT',
      EDIT_VARIANT_EFFECTIVITY_CMD : 'EditVariant',
      SET_EVOLUTION_EFFECTIVITY_CMD : 'EditEvolution',
      SET_PROD_CONF_CMD : "XENG_SET_PROD_CONF",
      EXPORT_ITEMS_CMD : 'Export',
      IMPORT_ITEMS_CMD : 'Import',
      SET_WORKUNDER_EVOLUTION_CMD : "SetWorkunderEvolution",
      MANAGE_PERSONALIZATION_CMD: 'ManagePersonalization',
      OPEN_ENG_ITEM : "XENG_OPEN_ENG_ITEM",
      LAUNCH_NG_FILTER_CMD :"DefineFilter",
      QUALIFIED_AS_FINAL_CMD :"QualifiedAsFinal",
      DIRECT_CMD :"Direct",
      PROPERTIES_CMD :"edit-properties",
      DOWNLOAD_DOCUMENT_CMD: "download-document",
      DETACH_DOCUMENT_CMD: "detach-document",
      DELETE_DOCUMENT_CMD: "delete-document",

      USER_RECENTS_ENG_ITEMS : 'xEngUserRecents',
      USER_CONF_PREFERENCES : 'xEngineerUserConfPref',
      NLS_STORAGE_NAME : 'xAppsElementsNLSNames',
      PREDICATE_NLS_STORAGE_NAME : 'xAppsPredsValue',
      RDF_CLASSES_TO_LOAD: 'rdfClassToLoad',
      MOST_USED_PROP_VALUE : 'mostUsedPropValue',
      DS6W_CLASSES_WITH_NLS_PROP : 'rdfClassWithNslProp',

      PREFERENCE_MAX_SIZE : "preferenceMaxSize",
      USER_EVOLUTION_PREF : 'evol_filter_pref',
      USER_CUSTO_VIEW_PREF : 'custo_view_saved_data',
      USER_WORKUNDER_EVOL_PREF : 'evol_workunder_pref',
      CONF_OFFICIAL_VIEW : 'Current',
      CONF_PROJECTED_VIEW : 'Projected',

      PC_FILTER_MODE_PREF : 'pc_filter_mode',
      CONF_STRICT_MODE : 'Strict',
      CONF_150_MODE : '150%',
      TITLE_COLUMN_NO: '0',
      TITLE_PATH_OF_REFERENCE:"PLMEntity.V_Name",
      INSTANCE_PATH:"PLMInstance.PLM_ExternalID",
      DESCRIPTION_PATH_OF_REFERENCE:"PLMEntity.V_description",
      TITLE_PATH_OF_DOCUMENT:"Title",
      DESCRIPTION_PATH_OF_DOCUMENT:"description",
      TITLE_PATH_OF_3DSHAPE:"PLMEntity.V_Name",
      DESCRIPTION_PATH_OF_3DSHAPE:"PLMEntity.V_description",


      XENGINEER_APP_NAME : 'ENXENG_AP',
      ENORIPE_APP_NAME : 'ENORIPE_AP',
      NAME_3DXCONTEXT : '3DXContent',

      VALUE_ASK_WORKUNDER_EVERYTIME : 'ask_workunder_everytime',
      VALUE_SET_WORKUNDER_ALWAYS : 'always_workunder_never_ask',
      VALUE_SET_WORKUNDER_NEVER : 'never_workunder_never_ask',
      VALUE_QUALIFIED_AS_FINAL_COMPONENT : "value_qualified_as_final_component",
      FINAL_ITEMS_PREF: 'Final Item',
      FINAL_ITEMS_DEFAULT: 'Not Selected(Leaf Item)',
      USER_EXPORT_HEADER_TEMPLATE : "xEngineer_Export_HeaderTemplate",
      NOT_GROUPED: "Not Grouped",
      REFERENCE: "Reference",
      PART_NUMBER: "Part Number",
      DATA_LIMIT_FOR_FINAL : 10000,
      TYPE_VPMREFERENCE : "VPMReference"
    };


    UWA.extend(_contants, XENCommonConstants); //merging common and XEN app

    return  Object.freeze(_contants); //object is freezed to prevent edition

});

// /**
//  * @module DS/ENOXEngineer/services/XEngItemsStore
//  */
// define('DS/ENOXEngineer/services/XEngItemsStore', [
//   'UWA/Core',
//   'UWA/Class',
//
//  ], function(UWA, Class) {
//
//     'use strict';
//
//
//      /**
//      *
//      * Component description here ...
//      *
//      * @constructor
//      * @alias module:DS/ENOXEngineer/services/XEngItemsStore
//      * @param {Object} options options hash or a option/value pair.
//      */
//     var XEngItemsStore = Class.singleton(
//     /**
//      * @lends module:DS/ENOXEngineer/services/XEngItemsStore
//      */
//     {
//         _allEngItems : [],
//         _myFavoritesEngItemsIds : [],
//         _myRecentEngItemsIds : [],
//         init: function(options) {
//             this._parent(options);
//         },
//         initialize : function(app){
//           var that=this;
//           this.app = app;
//           app.engItemsStore = this;
//         },
//         fetchMyEngItems : function(){
//           this.app.sandboxBase.dataService.getCurrentUserRootEng().then(function(myRoots) {
//             console.log(myRoots);
//           });
//
//         }
//
//
//     });
//
//     return XEngItemsStore;
// });


/**
 * @module DS/ENOXEngineer/components/NavigationTopBar/NavigationTopBar.js
 * @description
 */

define(
		'DS/ENOXEngineer/components/NavigationTopBar/NavigationTopBar',
		[
			'DS/ENOXPageToolBar/js/PageToolBar',
			'css!DS/ENOXEngineer/components/NavigationTopBar/NavigationTopBar.css'
			],
			function (
					PageToolBar
			) {
			'use strict';

			var ApplicationTopBarWrapper = function () { };

			ApplicationTopBarWrapper.prototype.init = function (sandbox, parentContainer) {

				this._sandbox = sandbox;
				this._modelEvent = sandbox.getApplicationBroker();
				this._subscribeList = [];
				// init toolbar
				var topbarOptions = {
						withInformationButton: true,
						withWelcomePanelButton: true,
						//isWelcomePanelCollapsed: false,
						modelEvents: this._modelEvent,
						parentContainer: parentContainer
				};

				this._pageToolBar = new PageToolBar(topbarOptions);
				this._pageToolBar.render().inject(parentContainer);

				this._subscribeToEvents();
			};

			ApplicationTopBarWrapper.prototype._subscribeToEvents = function () {
				var that = this;

				// when trying to reduce the welcome panel container (click on the little arrow in the TopToolBar)
				this._subscribeList.push(this._modelEvent.subscribe({ event: 'welcome-panel-collapse' }, function () {
				            that._modelEvent.publish({ event: 'triptych-set-size', data: { size: 40, side: 'left' } });
				            that._modelEvent.publish({ event: 'triptych-show-panel', data: 'left' });
				        }));
				
				
				        // same for expand of the welcome panel
				this._subscribeList.push(this._modelEvent.subscribe({ event: 'welcome-panel-expand' }, function () {
				            that._modelEvent.publish({ event: 'triptych-set-size', data: { size: 300, side: 'left' } });
				            that._modelEvent.publish({ event: 'triptych-show-panel', data: 'left' });
				        }));
				
				        // when clicking on the 'I' of Information while it's opened
				this._subscribeList.push(this._modelEvent.subscribe({ event: 'information-panel-close' }, function () {
				            that._modelEvent.publish({ event: 'triptych-hide-panel', data: 'right' });
				        }));
				
				        // when clicking on the 'I' of Information while it's closed
				this._subscribeList.push(this._modelEvent.subscribe({ event: 'information-panel-open' }, function () {
				            that._modelEvent.publish({ event: 'triptych-show-panel', data: 'right' });
				            that._modelEvent.publish({ event: 'information-panel-visible', data: null });
				        }));
				
				        // if something closed the right panel, update the 'I' color
				this._subscribeList.push(this._modelEvent.subscribe({ event: 'triptych-panel-hidden' }, function (data) {
				            if (data === 'right') {
				                that._modelEvent.publish({ event: 'information-panel-hidden', data: null });
				            }
				        }));

			};

			ApplicationTopBarWrapper.prototype.setTitle = function(title) {
				this._pageToolBar.getBodyContent().innerHTML = title;
			};
			
			ApplicationTopBarWrapper.prototype.destroy = function(title) {
		        var i = 0;
		        var len = this._subscribeList.length;
		        for (i = 0; i < len; i++) {
		            this._modelEvents.unsubscribe(this._subscribeList[i]);
		        }
			};

			return ApplicationTopBarWrapper;
		});

/**
 * @overview CustomizeView
 * @licence Copyright 2018 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOXEngineer/componentsHelpers/ENOXCustomizeView/js/CustomizeView', [
    'UWA/Class/View',
    'DS/Handlebars/Handlebars',
    'DS/UIKIT/Alert',
    'DS/UIKIT/Modal',
    'DS/UIKIT/Input/Text',
    'DS/UIKIT/Input/Button',
    'DS/UIKIT/Scroller',
    'DS/UIKIT/Input/Select',
    'DS/Tree/TreeListView',
    'DS/Tree/TreeNodeModel',
    'DS/ENOXEngineerCommonUtils/xEngAlertManager',
    'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json',
    'text!DS/ENOXEngineer/componentsHelpers/ENOXCustomizeView/html/CustomizeView.html',
    'css!DS/ENOXEngineer/componentsHelpers/ENOXCustomizeView/css/CustomizeView.css'
  ],
  function(UWAView, Handlebars, Alert, Modal, Text, Button, Scroller, Select, TreeListView, TreeNodeModel, xEngAlertManager, nlsKeys, CustomizeViewTemplate) {

    'use strict';

    UWA.debug = true;
    var CustomizeViewTemplate = Handlebars.compile(CustomizeViewTemplate);
    var ENOXCustomizeView = UWAView.extend({

      name: 'xapp-cutomize-view',
      _dialog: null,

      className: function() {
        return this.getClassNames('-container');
      },

      setup: function(options) {
        var that = this;
        that._parent(options);
        that.contentSection = that._buildContent();
        that.footerSection = that._buildFooter();
        // that.alert = new Alert({
        //   visible: true
        // }).inject(that.contentSection);
      },

      render: function() {
        var that = this;
        that.custoModal = new Modal({
          className: 'customize-view-dialog',
          closable: true,
          header: that.options.header,
          body: that.contentSection,
          footer: that.footerSection
        }).inject(widget.body).show();
        return that;
      },

      _buildFooter: function() {
        var that = this;
        var arrFooter = [];
        that.visibleViews = [];
        that.flag = 0;
        for (var i = 0; i < that.options.views.length; i++) {
          that.visibleViews.push({
            text: that.options.views[i]
          });
        }

        var okButton = new Button({
          name: 'okButton',
          value: that.options.buttons[1],
          className: 'primary',
          events: {
            onClick: that._savingChanges.bind(that)
          }
        });

        arrFooter.push(okButton);

        // var deleteButton = new Button({
        //   name: 'deleteButton',
        //   value: that.options.buttons[0],
        //   className: 'default delete',
        //   events: {
        //     onClick: that._deletingView.bind(that)
        //   }
        // });
      //  arrFooter.push(deleteButton);

        arrFooter.push(new Button({
          name: 'cancelButton',
          value: that.options.buttons[0],
          className: 'default cancel',
          events: {
            onClick: function() {
              that.custoModal.destroy();
            }
          }
        }));
        return arrFooter;
      },

      _savingChanges: function() {
        var that = this;
          var finalSet = {};
          var savedSettings = that.options.customizedViews,
            viewPair = {}; //value from get preference
          var ctxView = that.currentView.getValue();
          if (that.flag === 1) {
            that.visibleViews.push({
              text: ctxView
            });
          }
          var visibleList = [], visibleEIList = [], visibleDocList = [];
          if(that.selectType.getValue()[0] === "Engineering Item") {
            for(var i = 0; i < that.tree1.getRoots().length; i++){
              visibleEIList.push(that.mappingObj[that.tree1.getNthRoot(i).options.label]);
              viewPair[that.setType] = {
                visibleAttr: visibleEIList
              };
            }
            if (that.options.customizedViews.Untitled && that.setType === "VPMReference") {
                visibleDocList = that.options.customizedViews.Untitled.Document ? that.options.customizedViews.Untitled.Document.visibleAttr : that.options.defaultAttributesDoc;
              } else {
                  visibleDocList = that.options.defaultAttributesDoc;
              }
              viewPair["Document"] = {
              visibleAttr: visibleDocList
            };

          } else {
            for(var i = 0; i < that.tree1.getRoots().length; i++){
              visibleDocList.push(that.mappingObj[that.tree1.getNthRoot(i).options.label]);
              viewPair[that.setType] = {
                visibleAttr: visibleDocList
              };
            }
              if (that.options.customizedViews.Untitled && that.setType === "Document") {
                visibleEIList = that.options.customizedViews.Untitled.VPMReference ? that.options.customizedViews.Untitled.VPMReference.visibleAttr : that.options.defaultAttributesEI;
              }
              else {
                visibleEIList = that.options.defaultAttributesEI;
              }
            viewPair["VPMReference"] = {
              visibleAttr: visibleEIList
            };
          }

          savedSettings[ctxView] = viewPair;
          savedSettings["type"] = that.setType;
          finalSet.savedSettings = savedSettings;
          finalSet.ctxView = ctxView;
          that.options.onSubmitCallBack(finalSet);
          that.custoModal.destroy();
        },

      // _deletingView: function() {
      //     var that = this;
      //     var ctxView = that.currentView.getValue();
      //     if (ctxView === 'Create new view') {
      //       that.alert.add({
      //         className: 'error',
      //         message: 'The current view cannot be deleted'
      //       }).show();
      //       return;
      //     }
      //     var customizedViews = that.options.customizedViews;
      //     console.log(that.visibleViews);
      //     if (customizedViews.hasOwnProperty(ctxView)) {
      //       delete customizedViews[ctxView];
      //       var filteredViews = [];
      //       for (var i = 0; i < that.visibleViews.length; i++) {
      //         if (that.visibleViews[i].text !== ctxView) {
      //           filteredViews.push(that.visibleViews[i]);
      //         }
      //       }
      //       that.visibleViews = filteredViews;
      //       that.button.dropdown.removeItem(ctxView);
      //       console.log("filtered views ----" + that.visibleViews);
      //       that.currentView.setValue('Untitled');
      //       that.currentView.enable();
      //       that.attributes.visible = [];
      //       that._buildVisibleList();
      //       that._buildAvailableList();
      //     }
      //     var finalSet = {};
      //     var savedSettings = that.options.customizedViews,
      //       viewPair = {}; //value from get preference
      //     var ctxView = that.currentView.getValue();
      //     if (that.flag === 1) {
      //       that.visibleViews.push({
      //         text: ctxView
      //       });
      //     }
      //
      //     for (var j = 0; j < that.availableTypes.length; j++) {
      //       viewPair[that.availableTypes[j]] = {
      //         visibleAttr: that.attributes.visible
      //       };
      //     }
      //     savedSettings[ctxView] = viewPair;
      //     finalSet.savedSettings = savedSettings;
      //     finalSet.ctxView = ctxView;
      //     that.options.onSubmitCallBack(finalSet);
      //     that.custoModal.destroy();
      //   },

      _buildContent: function() {
        var that = this;
        that.check = 0;
        that.mainAttrObj = {};
        that.mappingObj = {};
          for(var i = 0;i< that.attributes.availableEI.length; i++){
            that.mainAttrObj[that.attributes.availableEI[i].sixWTag] =that.attributes.availableEI[i].attrNls;
            that.mappingObj[that.attributes.availableEI[i].attrNls] = that.attributes.availableEI[i].sixWTag;
          }
        var contentElement = UWA.createElement('div', {
          'class': 'customise-view-body'
        });

      //  create views div - text to add new view, dropdown to list views, delete view
        var viewsContainer = UWA.createElement('div', {
          'class': 'customized-views'
        }).inject(contentElement);
        that._buildText();//.inject(viewsContainer);

        var visibleViews = [];
        for (var i = 0; i < that.options.views.length; i++) {
          visibleViews.push({
            text: that.options.views[i],
            id: that.options.views[i]
          });
        }

        // that.button = new Button({
        //   className: 'default button-view-menu',
        //   dropdown: {
        //     items: visibleViews
        //   }
        // }).inject(viewsContainer);

        // that.button.addEvent('onDropdownClick', function(e, item) {
        //   that.check = 1;
        //   that.view = item.name;
        //   that.currentView.setValue(item.name);
        //   if (that.currentView.getValue() !== "Create new view" && that.currentView.getValue() !== "Untitled") {
        //     that.currentView.disable();
        //   } else {
        //     that.flag = 1;
        //     that.currentView.enable();
        //   }
        //   that.attributes.visible = [];
        //   that._buildVisibleList();
        //   that._buildAvailableList();
        // });


        that.availableTypes = [];
        that.displayTypes = [];
        for (var i = 0; i < that.options.types.length; i++) {
          that.availableTypes.push(that.options.types[i].typeName);
        }
          if (that.options.customizedViews.type === "Document") {
            that.setType = "Document";
            that.displayTypes.push({
              value: that.options.types[1].typeNls,
              selected: true
            });
            that.displayTypes.push({
              value: that.options.types[0].typeNls
            });
          } else {
            that.setType = "VPMReference";
            that.displayTypes.push({
              value: that.options.types[1].typeNls
            });
            that.displayTypes.push({
              value: that.options.types[0].typeNls,
              selected: true
            });
          }

        that.typeCountContainer = UWA.createElement('div', {
          'class': 'type-selection-display-container'
        }).inject(contentElement);
        var typeSection = UWA.createElement('div', {
          'class': 'type-selection-display'
        }).inject(that.typeCountContainer);
        var typeText = UWA.createElement('h5', {
          'class': 'type-text',
          'text': that.options.titles["viewType"]
        }).inject(typeSection);
        var comboSection = UWA.createElement('div', {
          'class': 'combo-box'
        }).inject(typeSection);

        that.selectType = new Select({
          custom: false,
          className: 'combo-box',
          placeholder: false,
          options: that.displayTypes
        });
        that.selectType.inject(comboSection);
        console.log(that.selectType);

        that.selectType.addEvent('onChange', function(e, item) {

          if (that.selectType.getValue()[0] === "Engineering Item") {
            that.select = true;
            that.setType = "VPMReference";
            that._buildVisibleList();
            that._buildAvailableList(that.attributes.availableEI);
          } else {
            that.select = false;
            that.setType = "Document";
            that._buildVisibleList();
            that._buildAvailableList(that.attributes.availableDoc);
          }
        });

        //build attributeSection
        this.attributeSection = UWA.createElement('div', {
          'class': 'attribute-display'
        }).inject(contentElement);
        that._buildVisibleList().inject(this.attributeSection);
        that._updateLimitCount(that.tree1.getRoots().length).inject(that.typeCountContainer);
        that._buildButtons().inject(this.attributeSection);
        if (that.selectType.getValue()[0] === "Engineering Item") {
          that._buildAvailableList(that.attributes.availableEI).inject(this.attributeSection);
        } else {
          that._buildAvailableList(that.attributes.availableDoc).inject(this.attributeSection);
        }

        return contentElement;
      },

      _buildButtons: function() {
        var that = this;

      that.buttonSection = UWA.createElement('div', {
          'class': 'button-section'
        });


        that.buttonInput1 = new Button({
          name: 'moveup',
          icon: 'expand-up',
          className: 'default button-move-up',
          events: {
            onClick: function(args){
              var availableAttrCount = that.tree2.getRoots().length;
              for (var i = 0; i < availableAttrCount; i++) {
                if (that.tree2.getManager().getDocument()._trueRoot.options.children[i] && that.tree2.getManager().getDocument()._trueRoot.options.children[i]._isSelected === true) {
                  if (that.tree1.getRoots().length < that.options.maxAttributes) {
                    this.enable();
                    that.attributes.visible.push(that.tree2.getNthRoot(i).options.id);
                    that.tree1.addRoot(that.tree2.getNthRoot(i));
                    availableAttrCount--;
                    i--;
                    if (that.tree1.getRoots().length === that.options.maxAttributes) {
                      this.disable();
                    }
                    that._updateLimitCount(that.tree1.getRoots().length);
                  } else {
                    xEngAlertManager.errorAlert(nlsKeys.get("error.maxAttributesReached"));
                    return;
                  }
                }
              }
            }
          }
        }).inject(that.buttonSection);

        var buttonInput2 = new Button({
          name: 'movedown',
          icon: 'expand-down',
          className: 'default button-move-down',
          events: {
            onClick: function(){
              for (var i = 0; i < that.attributes.visible.length; i++) {
                if (that.tree1.getManager().getDocument()._trueRoot.options.children[i] && that.tree1.getManager().getDocument()._trueRoot.options.children[i]._isSelected === true) {
                  (that.attributes.visible).splice(i, 1);
                  that.tree2.addRoot(that.tree1.getNthRoot(i));
                  i--;
                  if (that.tree1.getRoots().length < that.options.maxAttributes) {
                    that.buttonInput1.enable();
                    that._updateLimitCount(that.tree1.getRoots().length);
                  }
                }
              }
            }
          }
        }).inject(that.buttonSection);

        return that.buttonSection;
      },

      _updateLimitCount: function(visibleCount) {
        var that = this , viewText;
        var visibleAttrCount = nlsKeys.get("no_of_visible_count_display").replace("{no}",visibleCount).replace("{limit}",that.options.maxAttributes);
        if (UWA.extendElement(that.typeCountContainer).getElement('.count-display')) {
           var viewTextCount = UWA.extendElement(that.typeCountContainer).getElement('.count-display');
          viewTextCount.setText(visibleAttrCount);
        } else {
          var viewText = UWA.createElement('div', {
            'class': 'count-display',
            'text': visibleAttrCount,
          });
        }
       return viewText;
     },

      _buildText: function() {
        var that = this;
       that.textSection = UWA.createElement('div', {
         'class': 'text-section'
       });
       var viewText = UWA.createElement('h5', {
         'class': 'view-text',
         'text': that.options.titles["viewName"]
       }).inject(that.textSection);

       var viewContainer = UWA.createElement('div', {
         'class': 'view-input-text-container'
       }).inject(that.textSection);

       var ctxView = that.options.ctxView ? that.options.ctxView : 'Untitled';
       this.currentView = new Text({
         className: 'view-input-text',
         value: ctxView
       }).inject(viewContainer);
       this.currentView.disable();
       return that.textSection;
      },

      _buildVisibleList: function() {
        var that = this,
          visibleSection;
        if (UWA.extendElement(that.attributeSection).getElement('.visible-attributes')) {
          visibleSection = UWA.extendElement(that.attributeSection).getElement('.visible-attributes');
          visibleSection.empty();
        } else {
          visibleSection = UWA.createElement('div', {
            'class': 'visible-attributes'
          });
        }

        var ctxView = that.currentView.getValue();
        if (!that.options.customizedViews.type && !that.setType) {
          that.setType = "VPMReference";
        }
        var visibleAttributes = [];
        if (that.options.customizedViews[ctxView] && that.options.customizedViews[ctxView][that.setType]) {
          if(that.setType === "VPMReference") {
        var existingAttr = (that.options.customizedViews[ctxView][that.setType].visibleAttr.length !== 0) ? that.options.customizedViews[ctxView][that.setType].visibleAttr : that.options.defaultAttributesEI;
      } else {
        if (that.setType === "Document") {
          var existingAttr = (that.options.customizedViews[ctxView][that.setType].visibleAttr.length !== 0) ? that.options.customizedViews[ctxView][that.setType].visibleAttr : that.options.defaultAttributesDoc;
        }
      }
    } else {
      if(that.setType === "VPMReference") {
      var existingAttr = that.options.defaultAttributesEI;
    } else {
      var existingAttr = that.options.defaultAttributesDoc;
    }
    }
        that.visibleAttrs = [];
        for (var i = 0; i < existingAttr.length; i++) {
          that.visibleAttrs.push(existingAttr[i]);
          that.attributes.visible.push(existingAttr[i]);
          visibleAttributes.push({
            id: existingAttr[i],
            label: that.mainAttrObj[existingAttr[i]]
          });
        }
        that._updateLimitCount(visibleAttributes.length);

        that.tree1 = new TreeListView({
          columns: [{
            dataIndex: 'selection',
            type: 'selection',
            isHidden: false
          }, {
            dataIndex: 'tree',
            text: that.options.titles["vTitle"],
            height: 'auto',
            width: "auto",
            isEditable: true,
            isSortable: true
          }],
          selection: {
            unselectAllOnEmptyArea: true,
            canMultiSelect: true
          },
          //  onDropCellDefault: function(e,dropInfo){
          //    //this._parent(e,dropInfo);
          // //that.dragInfo = dropIn
          // console.log(that);
          // console.warn("Here at drop");
          // },
          roots: visibleAttributes
        }).inject(visibleSection);

        return visibleSection;
      },

      _buildAvailableList: function(available) {
        var that = this,
          availableSection;
        if (UWA.extendElement(that.attributeSection).getElement('.available-attributes')) {
          availableSection = UWA.extendElement(that.attributeSection).getElement('.available-attributes');
          availableSection.empty();
        } else {
          availableSection = UWA.createElement('div', {
            'class': 'available-attributes'
          });
        }

        var availableAttributes = [];
        var availableAttrs = [];

        for (var i = 0; i < available.length; i++) {
          availableAttrs[i] = available[i];
        }
        var len = that.visibleAttrs.length;
        availableAttrs = availableAttrs.filter(function(attinfo, idx) {
          var isVisible = that.visibleAttrs.indexOf(attinfo.sixWTag) !== -1;
          //isVisible && availableAttrs.splice(idx, 1);
          return !isVisible;
        });

        for (var i = 0; i < availableAttrs.length; i++) {
          availableAttributes.push({
            id: availableAttrs[i].sixWTag,
            label: availableAttrs[i].attrNls
          });
        }

        that.tree2 = new TreeListView({
          columns: [{
            dataIndex: 'selection',
            type: 'selection',
            isHidden: false
          }, {
            dataIndex: "tree",
            text: that.options.titles["aTitle"],
            width: "auto",
            isEditable: true,
            isSortable: true
          }],
          selection: {
            unselectAllOnEmptyArea: true,
            canMultiSelect: true
          },
          roots: availableAttributes
        }).inject(availableSection);
        return availableSection;
      }

    });

    return ENOXCustomizeView;
  });

define('DS/ENOXEngineer/componentsHelpers/InviteDnD/DnDInvite', [
    'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json',
    'DS/Core/Core',
    'UWA/Controls/Abstract',
    'UWA/Class/Options',
    'UWA/Class/Events',
    'UWA/Utils/Client',
    'DS/UIKIT/Spinner',
    'css!DS/ENOXEngineer/componentsHelpers/InviteDnD/DnDInvite.css',
    'css!DS/UIKIT/UIKIT.css'
], function (
    nlsUtils,
    WUXCore,
    Abstract,
    Options,
    Events,
    Client,
    Spinner
  ) {
    'use strict';

    var DnDInvite = Abstract.extend(Options, Events, {
        name: 'dnd_invite',
        defaultOptions: {
            mode: 'dynamic',
            invites: {
                drop: {
                    nls: 'drop',
                    icon: 'drag-drop'
                },
                insert: {
                    icon: 'plus',
                    nls: 'insert'
                }
            },
            active_invite: 'drop',
            isTouchActivated: false
        },
        init: function (options) {
            this._parent(options);
            this.options.isTouchActivated = (Client.Features.touchEvents && !Client.Features.pointerEvents);
            if (this.options.isTouchActivated) {
                this.options.invites.drop = {
                    nls: 'drop',
                    icon: 'touch'
                };
            }

            this._createDynamicInvite();
           
        },

        _createDynamicInvite: function () {
            this.elements.container = UWA.createElement('div', {
                'class': this.getClassNames('_container')
            });
            if (this.options.isTouchActivated) {
                var touchCB = function (e) {

                };
                this.elements.container.className += ' touch_look';
                this.elements.container.style.pointerEvents = 'auto';
                this.elements.container.addEventListener('touchend', touchCB);
            }
            var invites_keys = Object.getOwnPropertyNames(this.options.invites);
            for (var idx = 0; idx < invites_keys.length; idx++) {
                var key = invites_keys[idx];
                this.elements.container[key] = UWA.createElement('div', {
                    'class': this.getClassNames('_display ' + key),
                    draggable: false
                });
                if(key==='add_in_context'){

                   new Spinner({className: 'large' }).inject(this.elements.container[key]).show();

                  UWA.createElement('h5', {
                      'class': this.getClassNames('_txt font-3dsregular ' + key),
                      'text': nlsUtils['DropInvit_' + this.options.invites[key].nls]
                  }).inject(this.elements.container[key]);
                }else{
                  UWA.createElement('i', {
                      'class': this.getClassNames('_img wux-ui-3ds wux-ui-3ds-5x wux-ui-3ds-' + this.options.invites[key].icon)
                  }).inject(this.elements.container[key]);
                  UWA.createElement('h5', {
                      'class': this.getClassNames('_txt font-3dsregular ' + key),
                      'text': nlsUtils['DropInvit_' + this.options.invites[key].nls]
                  }).inject(this.elements.container[key]);
                }


                this.elements.container[key].inject(this.elements.container);
                if (this.options.active_invite !== key) {
                    this.elements.container[key].hide();
                }
            }

            if (this.getOption('renderTo')) {
                this.elements.container.inject(this.getOption('renderTo'));
            }
        },
        removeBorder:function() {
          this.elements.container.addClassName("no-border");
        },
        addBorder:function(){
          this.elements.container.removeClassName("no-border");
        },

        show: function (active_view) {
           
            if (this.options.active_invite !== active_view) {
                if (!UWA.is(active_view, 'string')) {
                    this.options.active_invite = 'drop';
                } else {
                    if (this.options.active_invite !== active_view && this.options.active_invite !== '') {
                        this.elements.container[this.options.active_invite].hide();
                    }
                    this.options.active_invite = active_view;
                }
                this.elements.container[this.options.active_invite].show();
                this.elements.container.show();
                this.dispatchEvent('toggleInvite', true);
            }
        },

        hide: function (active_view) {
           
            if (UWA.is(active_view, 'string')) {
                if (this.options.active_invite !== '' && this.options.active_invite === active_view) {
                    this.elements.container[this.options.active_invite].hide();
                    this.elements.container.hide();
                }
            } else if (this.options.active_invite !== '') {
                this.elements.container[this.options.active_invite].hide();
                this.elements.container.hide();
            }
            this.options.active_invite = '';
            this.dispatchEvent('toggleInvite', false);
        }
    });

    return DnDInvite;
});

/**
 * @module DS/ENOXEngineer/componentsHelpers/UploadViewer/UploadViewer
 */
define('DS/ENOXEngineer/componentsHelpers/UploadViewer/UploadViewer', [
    'UWA/Core',
    'UWA/Controls/Abstract',
    'DS/Handlebars/Handlebars',
    'DS/Windows/Dialog',
    'DS/Controls/ProgressBar',
    'text!DS/ENOXEngineer/componentsHelpers/UploadViewer/UploadTemplate.html',
    'css!DS/ENOXEngineer/componentsHelpers/UploadViewer/XENUploadViewer.css'
], function(UWA, Abstract, Handlebars, WUXDialog, WUXProgressBar, Html_fileTemplate) {

    'use strict';

    function getUuid(){
        return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
    }

    /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/componentsHelpers/UploadViewer/UploadViewer
     * @augments module:UWA/Controls/Abstract
     * @param {Object} options options hash or a option/value pair.
     */
    var UploadViewer = Abstract.extend(
     /**
     * @lends module:DS/ENOXEngineer/componentsHelpers/UploadViewer/UploadViewer.prototype
     */
    {

        defaultOptions: {

        },
        /**
         *
         * @example
         * var newViewer = new  UploadViewer({
         * mediator:{pub/sub},
         * nlsManager:{
         * get:
         * replace:
         * }
         *
         * });
         */
        init: function(options) {
            this._parent(options);

            this.nls = options.nlsManager;
            if(!options.immersiveFrame){
                throw new Error("missing immersiveFrame");
            }
            this.immersiveFrame = options.immersiveFrame;
            if(!this.nls){ //place holder
                this.nls = {
                    get: function(key){
                        return key;
                    },
                    replace: function(key){
                        return key;
                    }
                }
            }
            this._viewCounter= 0;
            this._trackers = [];
            this.buildSkeleton();

        },
        _onProgressGenerator: function(_trackerId){
            var that = this;
            return function(options){
                that._onProgressUpdater(_trackerId, options);
            }
        },
        _onCompleteGenerator: function(_trackerId){
            var that = this;
            return function(status){
                that._onCompleteUpdater(_trackerId, status);
            }
        },
        _onCompleteUpdater: function(_trackerId, status){
            console.warn(' --> '+_trackerId);
            console.warn(status);
            var tracker = this._getTracker(_trackerId);
            var that = this;
            if(tracker){
                tracker.progressbar.destroy();
                tracker.progressbar = null;
                tracker.state = 'done';
                var msg = (status) ? that.nls.get("job.complete.sucessful") : that.nls.get("job.complete.failed");
                that.panelContent.getElement(".xen-file-tile"+tracker.trackerId+" .status-name").setContent(msg);
                tracker.progressbar =  new WUXProgressBar({
                    displayStyle: 'lite',
                    value: 100,
                    emphasize : status ? 'success' : 'high-attention'
                }).inject( that.panelContent.getElement(".xen-file-tile"+tracker.trackerId+" .progress-bar"));

                setTimeout(function(){
                        that._removeTrackerView(tracker);
                        var idx = that._trackers.findIndex(function(elem){
                            return elem.trackerId === tracker.trackerId;
                        });
                        that._trackers.splice(idx,1);
                        delete tracker.onProgress;
                        delete tracker.onComplete;
                        delete tracker.trackerId;
                        delete tracker.state;
                        delete tracker.progressbar;
                        if(that._trackers.length===0){
                            that._displayEmptyView();
                        }

                },2000);

            }
        },

        _onProgressUpdater: function(_trackerId, options){
            var tracker = this._getTracker(_trackerId);
            if(tracker && options){
                tracker.progressbar.value = (Math.round((options.loaded/ options.total) *100)/100)*100;
                this._updateAllTrackers();
            }

        },
        _updateAllTrackers: function(){
            var  that = this;
                that._trackers.forEach(function(tracker){
                    if(tracker.state !== 'inifinite' && tracker.progressbar.value===100){
                        that.changeStateToInfinte(tracker);
                    }
                });
        },
        changeStateToInfinte: function(tracker){
            if(tracker){
                tracker.progressbar.destroy();
                tracker.progressbar = null;
                tracker.state = 'inifinite';
                this.panelContent.getElement(".xen-file-tile"+tracker.trackerId+" .status-name").setContent(this.nls.get("processing"));
                tracker.progressbar =  new WUXProgressBar({
                    displayStyle: 'lite',
                    infiniteFlag: true
                }).inject( this.panelContent.getElement(".xen-file-tile"+tracker.trackerId+" .progress-bar"));
            }
        },
        _displayEmptyView: function(){
            if(this.panelContent){
                var that =this;
                this.panelContent.empty();
                this.panelContent.setContent("<center> "+this.nls.get("notFileToUpload")+"</center>");
                this.hideToken = setTimeout(function(){
                    that.panel.hide();
                }, 1000);
            }
        },
        _getTracker: function(_trackerId){
            if(!Array.isArray(this._trackers) || !_trackerId) return null;
            return this._trackers.find(function(elem){
                return elem.trackerId === _trackerId;
            });
        },
        getUploadTracker: function(fileInfos){
            if(!fileInfos || !fileInfos.fileName) return ;

            var trackerId = getUuid();
            var infos = UWA.extend({},fileInfos, true);
            var trackerInfos =  {
                trackerId: trackerId,
                onProgress: this._onProgressGenerator(trackerId),
                onComplete: this._onCompleteGenerator(trackerId)
            };
            if(this.hideToken) clearTimeout(this.hideToken);

          if(!this.panel.visibleFlag) this.panel.show();
            this.panel.show();

            this._addNewUploadingViewer(infos,trackerInfos);
            this._trackers.push(trackerInfos);
            return trackerInfos;

        },
        _getDisplaySize: function(bytesLength){
            if(bytesLength<1024*1024){
                var _size = bytesLength /1024;
                return (Math.round(_size*100)/100)+' '+'KB';
            }
            var _size = bytesLength /(1024*1024);
            return (Math.round(_size*100)/100)+' '+'MB';
        },
        _removeTrackerView: function(_tracker){
            if(_tracker){
                _tracker.progressbar.destroy();
                delete _tracker.progressbar;
                var cont = this.panelContent.getElement(".xen-file-tile"+_tracker.trackerId);
                if(cont){
                    cont.destroy();
                    cont = null;
                }
            }
        },
        _addNewUploadingViewer: function(fileInfos, _trackerInfos){
            if(!fileInfos || !fileInfos.fileName) return ;

            if(this._trackers.length === 0){
                this.panelContent.empty();
            }

            fileInfos.displaySize = this._getDisplaySize(fileInfos.fileSize);
            fileInfos.statusName =  this.nls.get("uploading");
            var _content = new UWA.Element('div', {
                html: this.template(fileInfos),
                'class': 'xen-file-upload-wrapper xen-file-tile' + _trackerInfos.trackerId
            });
            this.panelContent.appendChild(_content);
            _trackerInfos.progressbar = new WUXProgressBar({
                displayStyle: 'lite',
                // infiniteFlag: true,
                value: 0
            }).inject(_content.getElement(".progress-bar"));
        },
        buildSkeleton: function(){
            this.template = Handlebars.compile(Html_fileTemplate);
            this.elements.container = UWA.createElement('div', {
                'class': 'XEN-upload-Viewer'
            });
            // Create a Panel
            this.panelContent = new UWA.Element('div', { html: "" });

            this.panel = new WUXDialog({
                title: this.nls.get("uploadFileTitle"),
                identifier: 'Uploader',
                resizableFlag: true,
                content: this.panelContent,
                immersiveFrame: this.immersiveFrame,
                minWidth: '400px',
                position: {
                    my: 'bottom right',
                    at: 'bottom right'
                }
              });

          this.panel.hide();
          //this dialog should be destroyed then the close is a hidden
          this.panel.close = this.panel.hide.bind(this.panel);
            this._displayEmptyView();

        },
        isInjected: function(){
            return (this.getContent()) ? this.getContent().isInjected() : false;
        }

    });

    return UploadViewer;
});

define('DS/ENOXEngineer/utils/SizedMap', [], function() {

    'use strict';

    /**
     *
     * @param {maxSize} options.maxSize
     * @param {initialContent} options.initialContent
     */
    function SizedMap(options){
        this.maxSize = options.maxSize || 10;
        this.content = options.initialContent || {};

    }

    SizedMap.prototype.put = function(key, obj){
        if(!key || !(obj instanceof Object) )
            return;
        obj.LU = Date.now();    
        this.content[key] = obj;
        while ((this.getSize() > this.maxSize)) {
         this.removeOldest();   
        }
        
    }
    SizedMap.prototype.removeOldest = function(){
        var oldestKey = this.getOldestKey();
        if(oldestKey)
            this.delete(oldestKey);
    };
    SizedMap.prototype.getOldestKey = function(){
        if(!(this.content instanceof Object))
            return null;
        var keys = this.keys();
        var result = keys[0];
        var minTime = this.get(result).LU || 0;
        for (var index = 1; index < keys.length; index++) {
            const key = keys[index];
            if(minTime>this.get(key).LU){
                minTime = this.get(key).LU;
                result = key;
            }
        }
        return result;
    };

    SizedMap.prototype.delete = function(key){
        if(this.content)
            delete this.content[key];
    }

    SizedMap.prototype.has = function(key){
        return (this.content && this.content[key]) ? true :false;
    }

    SizedMap.prototype.keys = function(){
        return (this.content instanceof Object) ? Object.keys(this.content) : [];
    };

    SizedMap.prototype.get = function(key){
        return (this.content instanceof Object) ? this.content[key] : null;
    }

    SizedMap.prototype.values = function(){
        var that = this;
       return this.keys().map(function(key){
                return that.get(key);
        });
    }

    SizedMap.prototype.clear = function(){
        this.content = {};
    }

    SizedMap.prototype.getContent = function(){
        return this.content;
    }

    SizedMap.prototype.getSize =  function(){
        if(!(this.content instanceof Object)) 
            return 0;
        var _json  = "";
        try {
            var _json = JSON.stringify(this.content);
        } catch (error) {
            _json  = "";
        }
        console.warn(_json.length);
    return _json.length;
    }

    return SizedMap;

});

define('DS/ENOXEngineer/routerConfig/RouterConfig', [], function() {

    'use strict';

    //official doc https://router5.js.org/
    // main routes definition
    const routes = [
        {name: 'myEngItems', path: '/myEngItems'},
        {name: 'engItem_View', path: '/engItem/:pid'},
        {name: 'recents_items', path: '/recents'}
    ];
    var routerOptions = {
                defaultRoute: 'recents_items',
                defaultParams: {},
                trailingSlash: false,
                useTrailingSlash: undefined,
                autoCleanUp: true,
                strictQueryParams: true,
                allowNotFound: false
            };

    return {
        routes : routes,
        options : routerOptions
    };

});

define('DS/ENOXEngineer/utils/PlatformDataProvider', [
    'UWA/Core',
    'UWA/Class/Promise',
    /*PlatformAPI*/
    'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices'
], function (
    UWACore,
    Promise,
    i3DXCompassPlatformServices
) {
    'use strict';

    function platformResponseParser (respServices) {
        // ensure that we retrieve data from myApp
        if (UWACore.is(respServices,"array") && respServices.length>0) {

          var platforms = {};

           respServices.forEach(function(platform){
             platforms[platform.platformId] = platform;
           });

           return platforms;
        } else {
          return null;
        }
    }


    var Platform = {

        getAllPlatforms: function() {
            return new Promise(function (resolve, reject) {
                i3DXCompassPlatformServices.getPlatformServices({
                    onComplete: function (respServices) {
                        var platformUrls = platformResponseParser(respServices);

                        if (platformUrls===null) {
                          return reject("cannot retrieve platform data");
                        }

                        resolve(platformUrls);
                    },
                    onFailure: reject
                });
            });
        },
        getCurrentUser:function(){
          return new Promise(function(resolve, reject){
              i3DXCompassPlatformServices.getUser({
                  onComplete:function(data){
                        resolve({
                          id:data.id,
                          email:data.email,
                          firstName:data.firstname,
                          lastName:data.lastname
                        });
                  },
                  onFailure:reject
              });
          });
        },
        loadCurrentUserRoles : function(){
          return new Promise(function(resolve, reject){
            i3DXCompassPlatformServices.getGrantedRoles(function (userGrantedRoles) {
              resolve(userGrantedRoles);
             });
          });

        },
    };

    return Platform;
});

define('DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
[
  // 'DS/ENOFloatingPanel/ENOFloatingPanel',
  'DS/UIKIT/Modal',
  'UWA/Core',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(Modal, UWA, nlsKeys) {

    'use strict';

    function _getDefaultFooter(){
      return "<button type='button' name='okButton' class='btn btn-primary'>"+nlsKeys.get('eng.ui.button.ok')+"</button> " +
      "<button type='button' name='cancelButton' class='btn btn-default'>"+nlsKeys.get('eng.ui.button.cancel')+"</button>";
    }

    function _createModal(options){
      var modal = new Modal({
        className: options.className || '',
        closable: true,
        header: '<h4>'+options.title+'</h4>',
        body:'',
        footer: ''
        // ,
        // animate: true,
        // resizable: true,
        // autocenter: true,
        // visible: true,
        // limitParent: true,
        // overlay: true
      });
      return modal;
    }



    /*
    *options.title
    *options.withFooter
    *options.className
    */
    function XEngineerModal(options){
        this.options = {
          title : 'Dialog',
          className : '',
          withFooter : true
        };
        this.options = UWA.extend(this.options, options);

        this.modal = _createModal(this.options);
        this.modal.inject(widget.body);
        if(this.options.withFooter){
            if(this.options.customFooter){
              this.modal.setFooter( this.options.customFooter() );
            }else{
              this.modal.setFooter( _getDefaultFooter() );
            }
            this._bindFooterEvent();
        }

    }


    XEngineerModal.prototype.show = function () {
        this.modal.show();
    };
    XEngineerModal.prototype.dispose = function(){
      this.modal.hide();
    };
    XEngineerModal.prototype.injectBody = function(content){
      this.modal.setBody(content);
    };

    XEngineerModal.prototype.getBody = function(){
      return this.modal.getBody();
    };

    XEngineerModal.prototype.injectHeader = function(content){
      this.modal.setHeader(content);
    };

    XEngineerModal.prototype.injectFooter = function(content){
      this.modal.setFooter(content);
    };

    XEngineerModal.prototype.onClose = function(callBack, context){
      this.modal.addEvent("onHide", function(ev) {
          callBack.call(context, ev);
        }, this);
    };
    XEngineerModal.prototype.onValidate = function(callBack, context){
      var that = this;
      if (this.options.withFooter) {
        this.modal.addEvent("onValidate", function(ev) {
            callBack.call(context, /* calls when command is ok */ function(){
              that.destroy();
            });
          }, this);
      }
    };

    XEngineerModal.prototype._bindFooterEvent = function(){
      var that = this;

      this.modal.getFooter().getElements('.btn').forEach(function (element){
        if(element.name === 'cancelButton'){
          element.addEvent('click', function () {
            that.modal.hide();
          });
        }

        if(element.name === 'okButton'){
          element.addEvent('click', function () {
              that.modal.dispatchEvent('onValidate');
          });

        }
      });

    };

    XEngineerModal.prototype.getContent = function(){
      return this.modal.getContent();
    }

    XEngineerModal.prototype.destroy = function(){
      this.modal.destroy();
      var keys = Object.keys(this);
      for (var i = 0; i < keys.length; i++) {
        console.log(keys[i]);
          this[keys[i]] = undefined;
      }
    }

    return XEngineerModal;

});

define('DS/ENOXEngineer/components/EngItemViewer/EngItemViewer', [
  'UWA/Core',
  'DS/ENOXEngineerCommonUtils/XENMask',
  'DS/ENOXSplitViewVertical/js/ENOXSplitViewVertical',
  'text!DS/ENOXEngineer/components/EngItemViewer/EngItemViewer.html',
  'text!DS/ENOXEngineer/components/EngItemViewer/EngListWrapper.html',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/Controls/ProgressBar',
  'css!DS/ENOXEngineer/components/EngItemViewer/EngItemViewer.css'
], function(
  UWACore,
  Mask,
  ENOXSplitViewVertical,
  EngItemViewerTemplate,
  listWrapper,
  XEngineerConstants,
  ProgressBar
) {

    'use strict';
    var IDCARD_MAX_HEIGHT = 110;
    var IDCARD_MIN_HEIGHT = 38;

    function EngItemViewer(sandbox){
      return {
        container: sandbox.getContainer(),
        start:function(){
          var that = this;
          this.isStarted=true;
          this._modelEvents = sandbox.getApplicationBroker()
          sandbox.emptyContainer();

          sandbox.addContent(EngItemViewerTemplate);
          this._itemViewerWrapper = this.container.firstChild;

          this._initDivs();
          this._initDataLoaderIndicator();
          this._subscribeToEvents();
          this._progressBarContainer = this.listViewContainer.getElement('.data-loader-progress-bar');

          Mask.mask(UWA.extendElement(this.container));

          var amITheLast = false;

          sandbox.subscribe(XEngineerConstants.EVENT_LIST_READY,function(){
            Mask.unmask(that.listViewContainer);
            Mask.unmask(that.container);
            if (!amITheLast) {
              Mask.mask(UWA.extendElement(that.idCardContainer));
              amITheLast = true;
            }
          });

          sandbox.subscribe(XEngineerConstants.EVENT_IDCARD_READY,function(){
            Mask.unmask(UWA.extendElement(that.container));
            Mask.unmask(UWA.extendElement(that.idCardContainer));
            if (!amITheLast) {
              Mask.mask(UWA.extendElement(that.listViewContainer));
              amITheLast = true;
            }
          });
        },
        _initDataLoaderIndicator: function(){
            this.dataProgressBar = new ProgressBar({
                displayStyle: 'lite'
            });
            this.dataProgressBar.__isInjected = false;
        },
        _subscribeToEvents : function () {
            var that = this;
            sandbox.subscribe('content-loader-indicator-start' , function () {
                that.dataProgressBar.value = 10;
                if(!that.dataProgressBar.__isInjected){
                    that.dataProgressBar.__isInjected = true;
                    that._progressBarContainer.setStyles({
                        'margin-top': '-6px',
                        height: '5px'
                    });
                    
                    that.dataProgressBar.inject(that._progressBarContainer);
                }
                    
            });

            sandbox.subscribe('content-loader-indicator-progress' , function (status) {
                that.dataProgressBar.value += Math.ceil(status);
            });

            sandbox.subscribe('content-loader-indicator-completed' , function () {
                that.dataProgressBar.value = 99;
                setTimeout(function(){
                    if(that.dataProgressBar.__isInjected){
                        that.dataProgressBar.__isInjected = false;
                        that.dataProgressBar.remove();
                        that._progressBarContainer.setStyles({
                            'margin-top': '0',
                            height: '0'
                        });
                    }
                },100);
            });

            sandbox.subscribe('idcard-container-minimize-idcard' , function () {
                sandbox.publish('splitview-vertical-set-top-size', IDCARD_MIN_HEIGHT );
                sandbox.publish('idcard-minify');
            });
            sandbox.subscribe('idcard-container-maximize-idcard' , function () {
                sandbox.publish('splitview-vertical-set-top-size',  IDCARD_MAX_HEIGHT );
                sandbox.publish('idcard-expand');
            });

            sandbox.subscribe('idcard-minified', function () {
                sandbox.publish('splitview-vertical-set-top-size', IDCARD_MIN_HEIGHT );
                sandbox.publish('idcard-minify');
            });

            sandbox.subscribe('idcard-expanded' , function () {
                sandbox.publish('splitview-vertical-set-top-size', IDCARD_MAX_HEIGHT);
                sandbox.publish('idcard-expand');
            });

            sandbox.subscribe('splitview-vertical-resized' , function (data) {
                if (data === IDCARD_MIN_HEIGHT) {
                    sandbox.publish('idcard-container-minified');
                }
                else if (data === IDCARD_MAX_HEIGHT) {
                    sandbox.publish('idcard-container-maximized');
                }
            });
        },
        _initDivs : function () {

            var ENOXSplitViewVertical_options = {};
            ENOXSplitViewVertical_options.withtransition = true;
            ENOXSplitViewVertical_options.withoverflowhidden = true;
            ENOXSplitViewVertical_options.sizeType = 'px';
            ENOXSplitViewVertical_options.originalTop = IDCARD_MAX_HEIGHT ;
            ENOXSplitViewVertical_options.modelEvents = this._modelEvents;
            this._ENOXSplitViewVertical = new ENOXSplitViewVertical();
            this._ENOXSplitViewVertical.init(ENOXSplitViewVertical_options);

            this._itemViewerWrapper.appendChild(this._ENOXSplitViewVertical.getContent());

            this.idCardContainer = UWA.extendElement(this._ENOXSplitViewVertical.getContent().querySelector('.top-container'));
            this.listViewContainer = UWA.extendElement(this._ENOXSplitViewVertical.getContent().querySelector('.bot-container'));
            this.listViewContainer.innerHTML = listWrapper;


        },
        stop:function(){
          this._ENOXSplitViewVertical.destroy();
          sandbox.emptyContainer();
          sandbox.stop(this);
        }
      }

    }

    return EngItemViewer;

});

/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview :
 *
 * @author SBM2
 */

define('DS/ENOXEngineer/components/XEngWelcomePanel/XEngWelcomePanel',
   [
       'UWA/Core',
       'DS/ENOXWelcomePanel/js/ENOXWelcomePanel',
       'DS/ENOXEngineer/utils/XEngineerConstants',
       'css!DS/ENOXEngineer/components/XEngWelcomePanel/XEngWelcomePanel.css',
   ],

   function (
            Core,
            WelcomePanelNew,
            XEngineerConstants
            ) {
       'use strict';


       var landingPageDashboardModule = function (sandbox) {
          var list=null, invite,rootContainer, mainContainer,topContainer ;
          var container =sandbox.getContainer();

          function activitiesBuilder(){

            return  [{
                id: 'activity_creation',
                title: sandbox.i18nManager.get("start-activity"),
                actions: [{
                    id: 'add_engItem',
                    text: sandbox.i18nManager.get("add_engItem"),
                    fonticon: 'fonticon fonticon-plus',
                    className: 'action-new',
                    isNotHighlightable : true
                },
                {
                    id: 'add_newPart',
                    text: sandbox.i18nManager.get("add_new_part"),
                    fonticon: 'fonticon fonticon-part-add',
                    className: 'action-new',
                    isNotHighlightable : true
                },
                {
                    id: 'import_items',
                    text: sandbox.i18nManager.get("eng.import.label"),
                    fonticon: 'fonticon fonticon-import',
                    className: 'action-new'
                },
                {
                    id: 'open_engItem',
                    text: sandbox.i18nManager.get("open_engItem"),
                    fonticon: 'folder-open',
                    className: 'action-new',
                    isNotHighlightable : true
                }]
            },{
                id: 'activity_browsing',
                title: sandbox.i18nManager.get("quick-access"),
                actions: [{
                    id: 'my_eng_items',
                    text: sandbox.i18nManager.get("my_eng_items"),
                    fonticon: 'component',
                    className: 'action-new',
                    isDefault: true
                },
                  {
                    id: 'recent_items',
                    text: sandbox.i18nManager.get("recent_items"),
                    fonticon: 'clock',
                    className: 'action-new'
                }]
            }];
          }
           function footerBuilder(){
            return [{
                id: 'setting_pref',
                text: sandbox.i18nManager.get("setting_pref"),
                fonticon: 'tools',
                actions:[]
            }];
          }
          // public interface
           return {
              isFirstDrop:true,
              mainContainer:null,
              myWelcomePanel:null,
              isStarted:false,
              start: function () {

            	  var that = this;

                var wPanelOptions = {
                    collapsed: false,
                    title:  sandbox.i18nManager.get("APP_NAME"),
                    subtitle: sandbox.i18nManager.get("APP_SUBTITLE"),
                    notifications: [],
                    activities: activitiesBuilder(),
                    selectedItem: 'my_eng_items',
                    parentContainer: container,
                    footer: footerBuilder(),
                    modelEvents: sandbox.getApplicationBroker()
                };

               this.myWelcomePanel = new WelcomePanelNew(wPanelOptions) ;
               this.myWelcomePanel.render();

               // console.log(container);
               sandbox.subscribe(XEngineerConstants.EVENT_TRIPTYCH_PANEL_VISIBLE, function(side) {
                   if (side === "left") {
                      container.style.visibility = "visible";
                   }
               });

               sandbox.subscribe(XEngineerConstants.EVENT_TRIPTYCH_PANEL_HIDDEN, function(side) {
                   if (side === "left") {
                      container.style.visibility = "hidden";
                   }
               });


               },
               reRender : function(){
                 // FIXME: ask evolution to support rendering
                 // this.myWelcomePanel.container.inject(this.myWelcomePanel.parentContainer);
               },
               stop: function () {
                 sandbox.publish('triptych-hide-panel','left'); //move to controller
                 // sandbox.emptyContainer();
               }
           };
       }

       return landingPageDashboardModule;
   });

define('DS/ENOXEngineer/services/CommandsService', [
  'UWA/Class',
  'UWA/Core',
  'UWA/Class/Promise',
  'DS/PlatformAPI/PlatformAPI',
  'DS/Menu/Menu',
  'DS/ApplicationFrame/CommandsManager',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'text!DS/ENOXEngineer/assets/config/Commands.json',
  'text!DS/ENOXEngineer/assets/config/MenuInfos.json',
], function(
  Class,
  UWA,
  Promise,
  PlatformAPI,
  Menu,
  CommandsManager,
  XEngConstants,
  PromiseUtils,
  command_text,
  menuInfos_text

) {

  'use strict';



  var CommandsService = Class.singleton({
    init: function(options) {
      var that = this;
      this._commandConfig = JSON.parse(command_text);
      this._menuInfos =  JSON.parse(menuInfos_text);
      // LifecycleServicesSettings.app_initialization(function() {
      //   console.log('LifecycleCmd infra ready !!');
      // });

    },

    initialize: function(app, isODTMode) {
      var that = this;
      that.app = app;
      that.app.core.commandManager = that;

      that._refreshedSubscription = PlatformAPI.subscribe('DS/PADUtils/PADCommandProxy/authored', function(data) {
        app.core.sessionManager.setAuthoringMode('authoring');
      });


      this._eventToken = app.mediator.subscribe(XEngConstants.EVENT_LAUNCH_COMMAND, function(options) {
        that._commandsListener(options);
      }); ///end of command listener
      if(!isODTMode)
      app.mandatoryStartupPromises.push( that.loadAllCommands() );

      app.optionalStartupPromises.push( that._getCommandSettings() );


    },
    _getCommandSettings: function(){
    	var that = this;
    	return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
    		that.app.core.dataService.getCommandSettings().then(function(res){
    			var settings = JSON.parse(res);
    			that._isMaterialQuantityAuthorized = settings.materialUsageAuthorization;
                            return resolve(res);
                        }).catch(function(errors) {
                        	that._isMaterialQuantityAuthorized = false;
                        	return reject(errors);
                        });
          });
    },
    _getObjectAdditionnalData : function(obj){
      if(!Array.isArray(obj)){

            return {
              revision: obj.getReferenceVersion(),
              type: obj.getType()
            }

      }else{
        return {};
      }
    },
    showMenu: function(rect, actions){
      if(!rect || !Array.isArray(actions))
        throw new Error("unable to build the menu");
        Menu.show(actions, {
            position: {
                x: rect.left,
                y: rect.bottom
            },
            submenu:'outside'
        });
  },
  renderMenu: function(rect, context){
    if(!rect || !context) return ;
    this.showMenu(rect, this.getMenu(context));
  },

  isMaterialQuantityAuthorized: function(){
	  return this._isMaterialQuantityAuthorized?  this._isMaterialQuantityAuthorized : false;
  },
    getMenu: function(context){
      var that = this;

      var nodes = that.app.core.contextManager.getXENTreeDocument().getSelectedNodes(context);
      var selectionInfos = that.getSelectionInfos(nodes);
      var actions = that.getAllActionIds(selectionInfos);
      var template = this._getTemplateMenu(context);
      var menu = that.buildMenu(actions, template, context);

      return menu;
    },

    getAllActionIds: function(selectionInfo){
      var that = this;
      var actions = [];
      var _actions = that.getCommandRepo();
      for (var actionsId in _actions){
        var actionInfo = that.getCommandMetaData(actionsId);

        var isFiltered = selectionInfo["filteredCommands"].indexOf(actionInfo["commandHdr"]) !== -1;


        var areTypesAuthorized = true;

        var selectedTypes = selectionInfo["types"];
        var authorizedTypes = actionInfo["authorizedTypes"];
        if (typeof authorizedTypes !== "undefined"){
            selectedTypes.forEach(function(selectedType){
              if (authorizedTypes.indexOf(selectedType) === -1)
                areTypesAuthorized = false;
            });
        } else
          authorizedTypes = true;


        var editabilityCondition = typeof actionInfo["edit"] !== "undefined" && actionInfo["edit"] === false ? true : selectionInfo["editable"];
        var countSelected = typeof actionInfo["nbSelectedMax"] === "undefined" || actionInfo["nbSelectedMax"] >= selectionInfo["nbSelected"] ? true:false;
        var countRefSelected = typeof actionInfo["nbSelectedRefMax"] === "undefined" || actionInfo["nbSelectedRefMax"] >= selectionInfo["nbRefSelected"] ? true:false;
    var countCondition = countSelected && countRefSelected ? true:false;
    var multiTypeCondition = (actionInfo["multiType"] === true || selectionInfo["types"].length === 1) ? true : false;

    if (areTypesAuthorized && editabilityCondition && countCondition && multiTypeCondition && !isFiltered)
      actions.push(actionInfo);
      }



      return actions;
    },
    buildMenu:function(actions, template, context){
        var that =this;
      var actionMenu = [];

      template.forEach(function(menuItem){
        if (menuItem["type"] === "group"){
          var commands = menuItem["commands"];
          var a = that.buildMenu(actions, commands, context);
          if (a.length > 0){
              actionMenu.push(that._buildMenuGroup(that.getGroupMetaData(menuItem["ID"]),'PushItem', a));
          }
        } else if (menuItem["type"] === "separator"){

          actionMenu.push({
            'type': 'TitleItem',
            'title': that.app.core.i18nManager.get(menuItem["ID"]),
            'state': 'enabled'
        });
        }else if (menuItem["type"] === "command"){
          actions.forEach(function(action){
            if (action["commandHdr"] === menuItem["ID"]){
              actionMenu.push(that._buildMenuEnty(action,'PushItem', [], context));
              return;
            }

          });

        }
      });

      return actionMenu;

    },
    _buildMenuEnty: function(action, type,args, context){
      var that = this;
      return {
                    'title': that.app.core.i18nManager.get(action.nls_key),
                    'type': type,
                    icon : that.app.core.settingManager.getIconUrl(action.icon),
                    action: {
                        'this': this,
                        'callback': function(d) {
                            that.commandHandler(action,args, context);
                        }
                    }
                };
    },
    _buildMenuGroup: function(action, type, submenu){
      var that = this;
      return {
                    'title':that.app.core.i18nManager.get(action.nls_key),
                    'type': type,
                    'icon' : that.app.core.settingManager.getIconUrl(action.icon),
                    'submenu': submenu
                };
    },
    getGenericMenuEnty:  function(menuInfo){
      var that = this;
      if(!(menuInfo.callback instanceof Function) || !menuInfo.nls_key){
        throw new Error("invalid menu input");
      }
      var option =  {
                    'title': that.app.core.i18nManager.get(menuInfo.nls_key),
                    'type': menuInfo.type ? menuInfo.type :'PushItem',
                    'state': menuInfo.state ? menuInfo.state : 'unselected',
                    action: {
                        'this': this,
                        'callback': function(){
                          menuInfo.callback.apply(null, menuInfo.args);
                        }
                    }
                };

    if(menuInfo.fonticon){
      option.fonticon ={
                      family: 'DSFontIcon',
                      content : 'wux-ui-3ds wux-ui-3ds-2x wux-ui-3ds-'+ menuInfo.fonticon
                    } ;
    }

    if(menuInfo.icon){
      option.icon = that.app.core.settingManager.getIconUrl(menuInfo.icon);
      delete option.fonticon;
    }
    return option;
    },
    getSelectionInfos:function(nodes){

      var types = [];
      var editable = true;
      var nbSelected = nodes.length;
      var nbRefSelected = 1;
      var filteredCommands = [];


      var root = this.app.core.contextManager.getActiveEngItem();
        if( !root ||  !this.app.core.settingManager.shoulAutorizedConfig()  || !root.isConfigured()){
          filteredCommands.push("EditVariant");
          filteredCommands.push("EditEvolution");
          filteredCommands.push("CopyVariantEffectivity");
          filteredCommands.push("PasteVariantEffectivity");
        }
        if (!this.isMaterialQuantityAuthorized()){
        	filteredCommands.push("addNewMaterialQuantity");
        }


        var nodesNoGroup = nodes.filter(function(node){
        	return node._isFromOriginalModel() ? true : false;
        });

        if (nodesNoGroup.length > 0){
        	if (nodesNoGroup[0].isMaterialQuantity()){
        		filteredCommands.push("ChangeTheQuantity");
        	} else {
        		filteredCommands.push("ChangeTheMaterialQuantity");
        	}
        }

        var selectedNodeType = [];
        nodes.forEach(function(node){
          var type = typeof node.getGlobalType === "function" ? node.getGlobalType() : node.getType()
          if (selectedNodeType.indexOf(type) === -1)
            selectedNodeType.push(type);
        });

    var selectedReferences = [];

    nodes.forEach(function(node){
      if (selectedReferences.indexOf(node.getID()) === -1)
        selectedReferences.push(node.getID());
    });

    nbRefSelected = selectedReferences.length;

    var selectionInfo = {
          "types":selectedNodeType,
          "editable":editable,
          "nbSelected":nbSelected,
          "nbRefSelected":nbRefSelected,
          "filteredCommands": filteredCommands
      };


      return selectionInfo;
    },
    getCommandMetaData: function(commandId){
      return this._commandConfig[commandId];
    },
    getCommandRepo: function(){
      return this._commandConfig;
    },
    getGroupMetaData: function(groupId){
      return this._menuInfos.groupsInfos[groupId] || null;
    },
    _getTemplateMenu: function(context){
      return this._menuInfos.templates[context] || [];
    },
    _commandsListener: function(options) {
      var that = this;

      that.executeCommand(options.commandId, function(){
         that.prepareCmdInput(that._commandConfig[options.commandId], options.context);
      });
    },
    _getReferenceNodeLength: function(nodes){

    	if (nodes && nodes.length <= 0) return 0;

    	var firstNodeID = nodes[0].getID();
    	var refNodes = [];
    	nodes.forEach(function(node){
    		var nodeID = node.getID();
    		if (refNodes.indexOf(nodeID) === -1){
    			refNodes.push(nodeID);
    		}
    	});

    	return refNodes.length;
    },
    commandHandler : function(action,args, context){
      if (UWA.is(action)) {
        this.executeCommand(action.commandHdr, function(){
          var nodes = this.app.core.contextManager.getXENTreeDocument().getSelectedNodes(context);
          if(action.commandHdr !== 'XENG_OPEN_ENG_ITEM'){

              var selectedItems = nodes.filter(function(node){
                  return (!node.getChildren());
              });


            this.app.core.contextManager.addSelection(selectedItems, true);
          }else if(this._getReferenceNodeLength(nodes) === 1){
              this.app.core.sessionManager.setNextOpenContext({
                  objectId: nodes[0].getID(),
                  objectType: nodes[0].getType(),
                  itemListModel: nodes[0]
                });
          }

        }.bind(this));

      }
      return null;

    },
    executeCommand: function(commandId, beforeExecution){
      var that = this;

      if (!commandId) {
        throw new Error("commandId is a mandatory parameter");
      } else if (!that._commandConfig[commandId]) {
        throw new Error("inexistant command");
      }

      var currentCommand = that._commandConfig[commandId];
      that.commandLoaderStatus.then(function(){
        if(beforeExecution) beforeExecution();

        var cmd = CommandsManager.getCommand(currentCommand.commandHdr, widget);
        that.app.core.contextManager.setCurrentRunningCmd(currentCommand.commandHdr);

        if(["EditVariant","EditEvolution"].indexOf(currentCommand.commandHdr)>=0){//IR-642070-3DEXPERIENCER2018x fix
            cmd.begin(false);
          }else{
            cmd.begin();
          }
      });
    },
    loadAllCommands : function(){
      var that = this;
      var promises = [];

      for (var commandName in this._commandConfig) {
        if (this._commandConfig.hasOwnProperty(commandName)) {
          var currentCommand = that._commandConfig[commandName];
          var prom = new Promise(function(resolve,reject){
            that.loadCommand(currentCommand, resolve, reject);
          })
          promises.push(prom);
        }
      }
      that.commandLoaderStatus = Promise.allSettled(promises);
      return that.commandLoaderStatus;
    },

    loadCommand: function(command,resolve, reject){
      if (!command || !command.commandHdr ||  !command.AmdLoader) {
        console.error("Oups ! no valid command description");
        reject("Oups ! no valid command description");
        return ;
      }
      var that = this;
      return require([command.AmdLoader], function(CmdConstructor) {
        var cmdOptions = {
         context: that.app.core.contextManager.getContext(),
         ID: command.commandHdr
       };

       if (command.isInternalCmd) {
         cmdOptions.appCore = that.app.core;
       }
         new CmdConstructor(cmdOptions);
         resolve();

      }, function(error){
        reject(error);
      });
    },

    prepareCmdInput : function(command, context){
      var that = this;
      switch (command.commandHdr) {
        case 'ActionBar_NewProductCmd':
            if (context && context.isInsert) {

              if (!that.app.core.contextManager.getActiveEngItem()) {
                console.error('you should select a parent');
                return;
              }

            }else {
              // that.app.mediator.publish(XEngConstants.EVENT_SELECT_ACTION_WP,{id: 'my_eng_items' });
              that.app.core.contextManager.resetSelection();
            }
          break;
        case 'XENG_UPDATE_WIDGET_TITLE' :
          break;
        case 'XENG_OPEN_ENG_ITEM' :
          that.app.core.sessionManager.setNextOpenContext(context.item);
          break;
        case 'Import' :
            break;
        case 'ActionBar_NewPartCmd':
            break;
        case 'addNewMaterialQuantity' :
        	that.app.core.sessionManager.setMaterialForInsertContext(context.item);
            break;
        // case 'CompareHdr' :
        //   break;
        default:
          if (context.item) {
            var targetNodes = context.item;
            if (!Array.isArray(targetNodes)) {
              targetNodes = [context.item];
            }

            for (var i = 0; i < targetNodes.length; i++) {
              targetNodes[i].object = that._getObjectAdditionnalData(targetNodes[i]);
            }
            that.app.core.contextManager.addSelection(targetNodes, true);

          }

      }
    },

  });

  return CommandsService;

});

define('DS/ENOXEngineer/sessionBuilders/NextGenFilterSessionBuilder', [
    'DS/ENOXEngineerCommonUtils/PromiseUtils',
    'DS/ENOXEngineer/utils/XEngineerConstants'
], function(PromiseUtils, XEngineerConstants) {

    'use strict';

    function NextGenFilterSessionBuilder(options){
        if(!options || !options.appCore || !options.models){
            console.error('missing options for SessionBuildersManager');
            throw new Error("");
        }
        this.appCore = options.appCore;
        this.models = options.models;
        this.engItem = this.models.getEngineeringItem();
    }
    NextGenFilterSessionBuilder.prototype.registerContentfetcher = function(){
        var that = this;
        if(!that.appCore.sessionManager.shouldShowFinalItems()){
            that.appCore.localStorage.setItem(XEngineerConstants.VALUE_QUALIFIED_AS_FINAL_COMPONENT,XEngineerConstants.DIRECT_CMD);
            that.models.registerContentFetcher(that.engItem.nextGenFilterMultiExpand(), 'nextGenFilterMultiExpand() [multiexpand] -->')
            .registerContentFetcher(that.engItem.getRelatedDocument(), ' getRelatedDocument -->')
            .registerContentFetcher(that.engItem.getRelatedDocument("PLMDocConnection"), ' getRelatedDocument -->')
            .fetchHolisticContentDefiniton();
        }else{
            that.models.registerContentFetcher(that.engItem.getQualifiedAsFinalChildren(), 'getQualifiedAsFinalChildren() -->')
            .registerContentFetcher(that.engItem.getRelatedDocument(), ' getRelatedDocument -->')
            .registerContentFetcher(that.engItem.getRelatedDocument("PLMDocConnection"), ' getRelatedDocument -->')
            .fetchHolisticContentDefiniton();

        }
       
        delete that.appCore;
        delete that.models;
        delete that.engItem;
    };

    NextGenFilterSessionBuilder.prototype.resolveFilteringContext = function(){
        var that = this;
        return PromiseUtils.wrappedWithPromise(function(resolve, reject){
            if (that.engItem.hasValidTransientNextGenFilter()|| that.engItem.hasValidPersistedNextGenFilter()){
                return resolve(true);
            }
            var prefFilter = that.engItem.hasPreferredNGFilterId();
            if(!prefFilter){
                return reject(new Error("no filter context found"));
            }
            that.models.retrievePreferreedNGFilter()
            .then(function(filtersData){
              var firstFilter = filtersData[0] || null;
              if(firstFilter){
                  //Hack : for FD02 fix
                firstFilter.filterId  = prefFilter.filterId;
                that.engItem.setPersistedNGFilterContext(firstFilter);
                return resolve(true);
              }else{
                  return reject(new Error('no filter found'));
              }

            }).catch(function(error){
                console.error(error);
                reject(error);
            });
        });
    };

    NextGenFilterSessionBuilder.prototype.retrieveCurrentFilterInfo = function(){
       var that = this;
        return {
          rootId : that.engItem.getID(),
          label: that.engItem.getNGFilterName(),
          CVQuery: that.engItem.getNextGenFilterExpandOptions().CVQuery,
          filterId: that.engItem.getNGFilterId()
        };

    };

    /**
     * mandatory function 
     */
    NextGenFilterSessionBuilder.prototype.retrieveAdditionalColumnProviders = function(){
      var that = this;
      return PromiseUtils.wrappedWithPromise(function(resolve, reject){
        return resolve(true); // not specific columns for this session builder
      });
    }

    NextGenFilterSessionBuilder.prototype.buildSession = function(){
        var that = this;
        return PromiseUtils.wrappedWithPromise(function(resolve, reject){
            that.resolveFilteringContext().then(function(){
              var filterInfos = that.retrieveCurrentFilterInfo();
              that.appCore.sessionManager.saveCurrentOpenContext({
                rootId : filterInfos.rootId,
                filteringContext: 'nextGenFilter',
                filterData: {
                  CVQuery: filterInfos.CVQuery,
                  label: filterInfos.label,
                  filterId: filterInfos.filterId
                }
              });
                that.registerContentfetcher();
                resolve(true);
            }).catch(function(error){
                console.error(error);
                delete that.appCore;
                delete that.models;
                delete that.engItem;
                reject(error);
            });

        });
    }


    return NextGenFilterSessionBuilder;

});

/**
 * @module DS/ENOXEngineer/services/I18nManager
 */
define('DS/ENOXEngineer/services/I18nManager', [
  'UWA/Core',
  'UWA/Class',
  'UWA/Class/Promise',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(UWA, Class, Promise, XEngineerConstants, nlsKeys) {

    'use strict';

     /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/services/I18nManager
     * @param {Object} options options hash or a option/value pair.
     */
    var I18nManager = Class.singleton(
    /**
     * @lends module:DS/ENOXEngineer/services/I18nManager
     */
    {

        init: function(options) {
            this._parent(options);
        },
        initialize:function(app){
          this.logger=app.core.logger.get("I18nManager manager initializing");
    			var that=this;
          app.core.i18nManager = that;
          app.sandboxBase.i18nManager = that;
          this.app = app;

          app.optionalStartupPromises.push( that.warmupNLS() );

        },
        resolveMissingNls : function(nlsTracker){
          if (!Array.isArray(nlsTracker.classes) || !nlsTracker.properties) {
            throw new Error("Ouups ! invalid input");
          }
          var promises = [];

          promises.push( this.getElementsNls(nlsTracker.classes.join(',')) );
          promises.push( this.getNlsOfPropertiesValues(nlsTracker.properties) );

         return   Promise.allSettled(promises);

        },
        _isPropertyKey : function(key){
          var subKeys = key.split('/');
          if (subKeys.length>1) {
            return true;
          }
          return false;
        },
        replace : nlsKeys.replace,
        get: function(key){
          if (!UWA.is(key, 'string')) {
            return null;
          }
          
          //TODO: hardcoded until prefered unit and good nls is delivered in metadata
          if (key === "ds6wg:MaterialUsageExtension.DeclaredQuantity") return nlsKeys.get("MaterialUsageExtension.DeclaredQuantity");

          if (key.startsWith("ds6w")) { // test prefix:value
            if (this._isPropertyKey(key)) {
              var subKeys = key.split('/') ;
              var propName = subKeys[0];
              var propValue = subKeys[1];

              if (!this.ds6wClassPropNls) {
                this.ds6wClassPropNls = JSON.parse(
                  sessionStorage.getItem(this.app.core.settingManager.getPredicatesNlsStorageName())
                );

              }

              if (!this.ds6wClassPropNls || !this.ds6wClassPropNls[propName]) {
                return propValue;
              }

              return this.ds6wClassPropNls[propName][propValue] || propValue;
            }

            if (!this.ds6wClassNls) {
              this.ds6wClassNls = JSON.parse(
                sessionStorage.getItem(this.app.core.settingManager.getNlsStorageName())
              );
            }
            if (!this.ds6wClassNls || !this.ds6wClassNls[key]) return key;

            return this.ds6wClassNls[key].nlsName || key;

          }else {
            return nlsKeys.get(key);
          }
        },
        warmupNLS : function(){
          var nls_classes =  this.app.core.settingManager.getSetting(XEngineerConstants.RDF_CLASSES_TO_LOAD);
          var promises = [];
          /*we should also load the nls of param attribute:
          theses attributes are automatically load  during the expand if there are present
          */
         var stringSixws = this.app.core.dataService.getParametricalAttributesOf("VPMReference").map(function(attrInfo){
          return attrInfo.sixWTag;
          }).join(',');
          if(stringSixws && stringSixws.length>0)
            nls_classes = nls_classes+','+stringSixws;

          promises.push(this.getElementsNls(nls_classes));


          var mostUsedPropValue =  this.app.core.settingManager.getSetting(XEngineerConstants.MOST_USED_PROP_VALUE);
          promises.push(this.getNlsOfPropertiesValues(mostUsedPropValue));

          return Promise.allSettled(promises);
        },
        /**
				 * Function getElementsNls To get the NLS translation of a set
				 * of vocabularies elements
				 *
				 * @param {JSONObject}
				 *            elementsNames URI's of required elements,
				 *            separated by a comma. options: object containing at
				 *            least onComplete and onFailure function that are
				 *            called when the elements are retrieved or when an
				 *            error occurs
&         {
           "ds6w:description": {
             "uri": "ds6w:description",
             "type": "Predicate",
             "nlsName": "Description",
             "lang": "en",
             "dataType": "string"
           },
           "ds6w:type": {
             "uri": "ds6w:type",
             "type": "Predicate",
             "nlsName": "Type",
             "lang": "en",
             "dataType": "string"
           }
         }
				 * @author
				 */
				getElementsNls : function(elementsNames) {
          var that = this;
          return new Promise(function(resolve,reject){
            var storageName = that.app.core.settingManager.getNlsStorageName();
            var localValues = sessionStorage.getItem(storageName);
            if (!localValues)
              localValues = {};
            else
              localValues = JSON.parse(localValues);

            var missingVals = "";
            var reqElts = elementsNames.split(",");
            // get local values that are asked, if any
            if (localValues != null) {
              for (var i = 0; i < reqElts.length; i++) {
                var uri = reqElts[i];
                if (!UWA.is(localValues[uri]))
                  missingVals += (uri + ",");

              }
            } else {
              missingVals = elementsNames;
              sessionStorage.setItem(storageName, "");
            }

            // now, we get the missingValues from WS call
            if (missingVals != "") {
              // remove last ","
              missingVals = missingVals.substring(0,missingVals.length - 1);

              that.app.core.dataService.loadElementsNLS(missingVals)
                      .then(function(result){
                        sessionStorage.setItem(storageName, JSON.stringify(result));
                        that.ds6wClassNls = result;
                        resolve(result);
                      })
                      .catch(function(error){   console.error(error); reject(error);
                      });
            } else
                resolve(localValues);
          });

				},
        /**
         * Function getNlsOfPropertiesValues To get the NLS translation
         * of a set of properties values
         *
         * @param {JSONObject}
         *            propsValsKeys the id format depends on
         *            meta-language and type of the resource. - For RDF
         *            class: it must look like
         *            rdf/prop/{ontoName}/{propName} - For ER class: it
         *            must look like rdf/prop/{propName}
         * @returns {String} NLS name of the property as string.
         {
           "ds6w:status": {
             "RELEASED": "Released",
             "FROZEN": "Frozen",
             "OBSOLETE": "Obsolete",
             "IN_WORK": "In Work",
             "PRIVATE": "Private"
           },
           "ds6w:type": {
             "VPMReference": "Physical Product",
             "Document": "Document"
           }
         }
         * @author
         */
        getNlsOfPropertiesValues : function(propsValsKeys){
          var that = this;

          return new Promise(function(resolve,reject){
            var missingValues = that._getMissingPredicateValue(propsValsKeys);
            var storageName = that.app.core.settingManager.getPredicatesNlsStorageName();

            // nothing's missing
            if (Object.keys(missingValues).length == 0) {
              var localValues = JSON.parse(sessionStorage.getItem(storageName));
              resolve(localValues);
              return;
            }

            // some things are missing
            that.app.core.dataService.loadPredicateValues(missingValues)
                      .then(function(nlsValues){
                        sessionStorage.setItem(storageName,JSON.stringify(nlsValues));
                        that.ds6wClassPropNls = nlsValues;
                        return resolve(nlsValues);
                      })
                      .catch(function(error){ reject(error);
                      });

          });

        },
        _getMissingPredicateValue: function(predsKeys) {

        if (!window.sessionStorage) {
          return predsKeys;
        }

        var that = this;

        var storageName = that.app.core.settingManager.getPredicatesNlsStorageName();

        var localValues = sessionStorage.getItem(storageName);
        if (!localValues) {
          return predsKeys;
        }

        localValues = JSON.parse(localValues);

        var predicatesValues = predsKeys;

        var to_dwnld = {};

        if (predicatesValues === undefined)
          return;

        for (var pred in predicatesValues) {
          if (predicatesValues.hasOwnProperty(pred)) {
            // console.log("ask for predicate: " + pred);
            var localPred = localValues[pred];
            if (!localPred) {
              /*
               * console .log("predicate not retrieved in local ->
               * need to call WS: " + pred);
               */
              to_dwnld[pred] = predicatesValues[pred];
            } else {
              // console.log("predicat found in local: " + pred);
              var searchedVals = predicatesValues[pred];
              var nbSearchedVals = searchedVals.length;
              var obj = {};
              var vals = [];
              for (var j = 0; j < nbSearchedVals; j++) {
                var tmp = searchedVals[j];
                // console.log("looking for value: " + tmp);
                var loc = localPred[tmp];
                if (!loc){
                  /*
                   * console.log("value not retrieved: " + tmp + "
                   * adding it to to_dwnld");
                   */
                  vals.push(searchedVals[j]);
                }
              }
              if (vals.length) {
                to_dwnld[pred] = vals;
              }
            }
          }
        }

        return to_dwnld;
      }
    });

    return I18nManager;
});

define('DS/ENOXEngineer/componentsHelpers/ModelChooser/XEngModelChooser', [
  // 'DS/CollectionView/ResponsiveTilesCollectionView',
  'DS/CollectionView/ResponsiveLargeTilesCollectionView',
  'DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
  'DS/Tree/TreeDocument',
  'DS/ENOXEngineerCommonUtils/XENMask',
  'css!DS/ENOXEngineer/componentsHelpers/ModelChooser/XEngModelChooser.css'
], function(
  ResponsiveTilesCollectionView,
  XEngineerModal,
  TreeDocument,
  XENMask
) {
    'use strict';

    function XEngModelChooser(options){
      var that = this;
      this.appCore = options.appCore;
      this.resolve = options.resolve;
      this.reject =  options.reject;
      this.preferredId = options.preferred;
      this.modelsPromises =  options.modelsPromises;
      this.grid = new ResponsiveTilesCollectionView({
                useDragAndDrop: false
            });
      this.grid.selectionBehavior = {
                       unselectAllOnEmptyArea: false,
                       toggle: true,
                       canMultiSelect: false,//For Ctrl + click behavior, Ctrl + kayboard arrow.
                       enableShiftSelection: false,//for shift+click behavior, shift + keyboard arrow.
                       enableFeedbackForActiveCell: true
                   };

      this.modelsDocument = new TreeDocument({
          shouldBeSelected: function(node) {
            if(that.isDisableFooter()){
              that.enableValidateBtn();
            }
            var treeDoc = node.getTreeDocument();
              if(treeDoc.getXSO().get().length > 1){
                treeDoc.unselectAll();
              }
              return true; //!node.isRoot();
          }
      });
      var completed = 0;

      that.modelsPromises.forEach(function(versionLoader){
        versionLoader.then(function(models){
          completed++;
          if((models.length>0 || completed== that.modelsPromises.length) && XENMask.isMasked(that.modal.modal.elements.body)){
            XENMask.unmask(that.modal.modal.elements.body);
          }
          that.modelsDocument.addRoot(models);
          models.forEach(function(model){
            if(that.preferredId && model.options.physicalid ===that.preferredId)
                model.select();
          })

        });
      });
      // options.models.forEach(function(model){
      //   model._unsetParent();
      //   that.modelsDocument.addChild(model);
      //   if(that.preferredId && model.getID() ===that.preferredId)
      //     model.select();
      // });

      this.grid.model = this.modelsDocument;

      this.buildView();
    }

    XEngModelChooser.prototype._buildModal  = function(){
      this.modal = new  XEngineerModal({
        title : this.appCore.i18nManager.get("eng.ui.dialog.chooseModel"),
        className : 'xeng-model-chooser',
        withFooter : true
      });

      return this.modal;
    };

    XEngModelChooser.prototype.destroyView = function(){
      var that = this;
      this.modelsDocument = undefined;
      this.grid && this.grid.destroy();
      that.modal && that.modal.destroy();
      that.modal = undefined;
    };

    XEngModelChooser.prototype._getModalContent = function(){
      return this.grid.getContent();
    };
    XEngModelChooser.prototype.disableValidateBtn = function(){
      var okBtn = document.body.querySelector("button[name=\"okButton\"]");
      okBtn &&(okBtn.disabled = true);
    };

    XEngModelChooser.prototype.isDisableFooter = function(){
      var okBtn = document.body.querySelector("button[name=\"okButton\"]");
      return okBtn ? okBtn.disabled : false;
    };


    XEngModelChooser.prototype.enableValidateBtn = function(){
      var okBtn = document.body.querySelector("button[name=\"okButton\"]");
      okBtn &&(okBtn.disabled = false);
    };

    XEngModelChooser.prototype.buildView = function(){
      var that = this;
      this._getModalContent().inject(this._buildModal().getBody());
      this.modal.onValidate(function(finish){
        that.resolve && that.resolve(that.modelsDocument.getSelectedNodes()[0]);
        finish();
      }, this);

      this.modal.onClose(function(){
        that.destroyView();
        that.reject&&that.reject();
      }, this);

      this.modal.show();
      XENMask.mask(that.modal.modal.elements.body);

      this.disableValidateBtn();

    };

    return XEngModelChooser;

});

define('DS/ENOXEngineer/sessionBuilders/ConfigSessionBuilder', [
    'DS/ENOXEngineerCommonUtils/PromiseUtils',
    'DS/ENOXEngineer/componentsHelpers/ModelChooser/XEngModelChooser',
    'DS/ENOXEngineer/utils/XEngineerConstants'
], function(PromiseUtils, XEngModelChooser,XEngineerConstants) {

    'use strict';

    /**
     *
     * @param {appCore} options
     * @param {models} options
     */
    function ConfigSessionBuilder(options){
        if(!options || !options.appCore || !options.models){
            console.error('missing options for SessionBuildersManager');
            throw new Error("");
        }
        this.appCore = options.appCore;
        this.models = options.models;
        this.engItem = this.models.getEngineeringItem();
        this.chooseModelPromise = function (options) {
            return PromiseUtils.wrappedWithPromise(function (resolve, reject) {
              options.resolve = resolve;
              options.reject = reject;
              new XEngModelChooser(options);
            });
          };

    }

    ConfigSessionBuilder.prototype.retrieveOpenInfos = function(){
      var that = this;
      if(!that.engItem.isConfigured()){
        return {
          rootId : that.engItem.getID(),
          filteringContext: 'none'
        }
      }else{ //under config
        var currentModel = that.engItem.getPreferedAttachedConfigModel();
        if(!currentModel.getPreferredConfiguration()){ //filter on evolution
          return {
            rootId : that.engItem.getID(),
            filteringContext: 'evolution',
            filterData:{
              filterId: currentModel.getCurrentVersionID(),
              label: currentModel.getCurrentVersionDisplayName(),
              filterBinary: null
            }
          }
        }else{
          return {
            rootId : that.engItem.getID(),
            filteringContext: 'prodConf',
            filterData:{
              filterId: currentModel.getPreferredConfiguration().id,
              label: currentModel.getPreferredConfiguration().marketingName,
              filterBinary: currentModel.getPreferredConfiguration().FilterCompiledForm
            }
          }
        }

      }

    };

    ConfigSessionBuilder.prototype.registerContentfetcher = function(){
        var that = this;



        if(that.appCore.sessionManager){
          that.appCore.sessionManager.saveCurrentOpenContext(that.retrieveOpenInfos());

          if(!that.appCore.sessionManager.shouldShowFinalItems()){
            var options = that.appCore.sessionManager.getStaticForMappingAsOpenContext(that.engItem.getID());
            that.appCore.localStorage.setItem(XEngineerConstants.VALUE_QUALIFIED_AS_FINAL_COMPONENT,XEngineerConstants.DIRECT_CMD);
            that.models.registerContentFetcher(that.engItem.expandWithConfig(true, options), 'expandWithConfig(true) -->')
            .registerContentFetcher(that.engItem.getRelatedDocument(), ' getRelatedDocument -->')
            .registerContentFetcher(that.engItem.getRelatedDocument("PLMDocConnection"), ' getRelatedDocument -->')
            .fetchHolisticContentDefiniton();
          }else{
            that.models.registerContentFetcher(that.engItem.getQualifiedAsFinalChildren(), 'getQualifiedAsFinalChildren() -->')
            .registerContentFetcher(that.engItem.getRelatedDocument(), ' getRelatedDocument -->')
            .registerContentFetcher(that.engItem.getRelatedDocument("PLMDocConnection"), ' getRelatedDocument -->')
            .fetchHolisticContentDefiniton();
          }

        }
        delete that.appCore;
        delete that.models;
        delete that.engItem;
    };
    ConfigSessionBuilder.prototype.retrieveAdditionalColumnProviders = function(){
      var that = this;
        return PromiseUtils.wrappedWithPromise(function(resolve, reject){
          return resolve(true); // not specific columns for this session builder
        });
    }
    ConfigSessionBuilder.prototype.buildSession = function(){
        var that = this;
        return PromiseUtils.wrappedWithPromise(function(resolve, reject){

            if (that.engItem.isConfigured() && !that.engItem.getPreferedAttachedConfigModel()) {
                that.chooseModelPromise({
                    appCore: that.appCore,
                    modelsPromises: that.engItem.getAllAvailableVersionsPromises(),
                    engItem: that.engItem
                  })
                  .then(function (version) {

                    var currentEngItem = that.engItem;
                    //important step
                    currentEngItem.setPreferredModelById(version.options.modelId);
                    if(currentEngItem.getPreferedAttachedConfigModel()){
                        currentEngItem.getPreferedAttachedConfigModel()._synchronizeModelVersions({
                            id: version.options.physicalid
                        }).finally(function () {
                            that.registerContentfetcher();
                        resolve(true);
                        });
                    }
                  }).catch(function (error) {
                    delete that.appCore;
                    delete that.models;
                    delete that.engItem;
                    reject(error)
                  }); //error in the choice of model
              } else {
                that.appCore.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                    commandId: XEngineerConstants.SET_WORKUNDER_EVOLUTION_CMD,
                    context: {
                      item: that.engItem
                    }
                  });
                that.registerContentfetcher();
                resolve(true);
              }


        });
    }

    return ConfigSessionBuilder;

});

/**
 * @module DS/ENOXEngineer/services/PreferencesManager
 */
define('DS/ENOXEngineer/services/PreferencesManager', [
    'UWA/Core',
    'UWA/Class',
    'UWA/Class/Promise',
    'DS/ENOXEngineer/utils/XEngineerConstants'
], function (UWA, Class, Promise, XEngineerConstants) {

    'use strict';

    /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/services/PreferencesManager
     * @param {Object} options options hash or a option/value pair.
     */
    var PreferencesManager = Class.singleton(
        /**
         * @lends module:DS/ENOXEngineer/services/PreferencesManager
         */
        {

            init: function (options) {
                this._parent(options);
            },
            initialize: function (app) {
                this.logger = app.core.logger.get("PreferencesManager manager initializing");
                var that = this;
                app.core.PreferencesManager = app.sandboxBase.PreferencesManager = that;
                this.app = app;
                this.setPreferenceOnstartup();
                  this.viewPref = null;
                this.loadViewPreferences();

            },
            loadViewPreferences: function(){
              var that = this;
              var data = widget.getValue(XEngineerConstants.USER_CUSTO_VIEW_PREF);
              that.viewPref =  data ? JSON.parse(data) : null;
              that.logger.warn(that.viewPref);
            },
            getViewPreference: function(){
              if (widget.getValue(XEngineerConstants.USER_CUSTO_VIEW_PREF)) {
                return JSON.parse(widget.getValue(XEngineerConstants.USER_CUSTO_VIEW_PREF));
              } else {
                return;
              }
            },
            updateViewPreference: function(newViewPref){
              var that = this;
              that.viewPref = newViewPref;
              widget.setValue(XEngineerConstants.USER_CUSTO_VIEW_PREF, JSON.stringify(newViewPref));
            },
            saveEngItemOpenPreferences: function(engItem){
                if(!this.app.core.Factories.ListItemFactory.getReferenceClass(engItem))
                    return ;
                var preference = null;

                if(engItem.isConfigured()){
                    var preferredModel = engItem.getPreferedAttachedConfigModel();
                    if(preferredModel){
                        preference = {
                            model: preferredModel.getID()
                        };
                        if(preferredModel.getPreferredVersion()){
                            var preferredVersion = preferredModel.getPreferredVersion();
                            preference.modelVersion  = preferredVersion.id || undefined;

                            var preferredPC = preferredModel.getPreferredConfiguration();
                            if(preferredPC){
                                preference.prodConf = preferredPC.id
                            }
                        }
                    }
                }

                if(engItem.hasValidPersistedNextGenFilter()){
                    if(!preference) preference = {};

                    preference.filterId = engItem.getNGFilterId();
                    preference.filterName = engItem.getNGFilterName();
                }

               return  this.app.core.dataService.saveEngItemOpenPref(engItem.getID(), preference);


            },

           //to get getStatticMappingPreference
            getStaticMappingPreference: function(pid){
              var option = this.app.core.sessionManager.getStaticForMappingAsOpenContext(pid);
              return (option && option.pcInfo) ?  option.pcInfo: null ;
            },
            getEngItemOpenPreferences: function(pid){
              //if staticMapping preference is there return that or else last opened item preference
               if(this.getStaticMappingPreference(pid)){
                 return this.getStaticMappingPreference(pid);
               }

                var prefMap = this.app.core.dataService.getOpenPrefMap();
                if(prefMap){
                    return prefMap.get(pid);
                }
                return null;
            },
            catchUserPreference: function () {

                // to refactor the 'Show work under evolution' dialog preference from widget->settings
                var showWorkUnderEvol = widget.getValue(XEngineerConstants.USER_WORKUNDER_EVOL_PREF);
                widget.setValue(XEngineerConstants.USER_WORKUNDER_EVOL_PREF, showWorkUnderEvol);

            },
            setPreferenceOnstartup: function () {


                if(!widget.getValue("x3dAppId")){ //only for
                    widget.setValue("x3dAppId","ENXENG_AP");
                }

                //    widget.addPreference({
                //                         "name": "changeControlPosition",
                //                         "defaultValue": "top-right",
                //                         "type": "list",
                //                         "label": "changeControlPosition_label",
                //                         "options": [{
                //                             "label": "bottom-right_label",
                //                             "value": "bottom-right"
                //                         }, {
                //                             "label": "bottom-left_label",
                //                             "value": "bottom-left"
                //                         }, {
                //                             "label": "top-right_label",
                //                             "value": "top-right"
                //                         }]
                //                     });
                widget.addPreference({
                    "name": "CADAuthoring",
                    "defaultValue": 'false',
                    "type": "boolean",
                    "label": "Ask_Me_CADAuthoring"
                });
                if(!this.app.core.settingManager.isCloud()) {
                  widget.addPreference({
          						"name": "ShowNotInBOM",
          						"defaultValue": 'false',
          						"type": "boolean",
          						"label": "show_excludefrombom"
          				});
                }
                widget.addPreference({
                    "name": "UseOnlyDB",
                    "defaultValue": 'false',
                    "type": "boolean",
                    "label": "use_only_db"
                });

                if (!widget.getValue(XEngineerConstants.USER_WORKUNDER_EVOL_PREF)) {
                    widget.setValue(XEngineerConstants.USER_WORKUNDER_EVOL_PREF, XEngineerConstants.VALUE_ASK_WORKUNDER_EVERYTIME);
                }

                widget.addPreference({
                    "name": "intervalToSwitch",
                    "defaultValue": "180",// time unit second
                    "type": "list",
                    "label": "interval_to_switch",
                    "options": [{
                        "label": "zero_min",
                        "value": "0"
                    },{
                        "label": "one_min",
                        "value": "60"
                    },{
                        "label": "three_mins",
                        "value": "180"
                    }, {
                        "label": "five_mins",
                        "value": "300"
                    }, {
                        "label": "ten_min",
                        "value": "600"
                    }]
                });

                widget.addPreference({
                    "name": XEngineerConstants.USER_WORKUNDER_EVOL_PREF,
                    "defaultValue": XEngineerConstants.VALUE_ASK_WORKUNDER_EVERYTIME,
                    "type": "list",
                    "label": "evol_workunder_pref",
                    "options": [{
                        "label": "evol_workunder_combochoice_alwaysask",
                        "value": XEngineerConstants.VALUE_ASK_WORKUNDER_EVERYTIME
                    }, {
                        "label": "evol_workunder_combochoice_alwaysset",
                        "value": XEngineerConstants.VALUE_SET_WORKUNDER_ALWAYS
                    }, {
                        "label": "evol_workunder_combochoice_never",
                        "value": XEngineerConstants.VALUE_SET_WORKUNDER_NEVER
                    }]
                });

                var attributeList = this.app.core.dataService.getAttributesForFinalItems("VPMReference");
            	var finalItemPreferences = {
      				 name: XEngineerConstants.FINAL_ITEMS_PREF,
       				 type: "list",
       				 label: "final_items_pref",
       				 options: [],
       				 defaultValue: attributeList[XEngineerConstants.FINAL_ITEMS_DEFAULT],
            	};

            	for (var key in attributeList) {
	  				  finalItemPreferences.options.push({
						  value :  key,
						  label : attributeList[key]
					  });
                }
            	widget.addPreference(finalItemPreferences);
            }
        });

    return PreferencesManager;
});

define('DS/ENOXEngineer/componentsHelpers/GridViewConfigurator/GridViewConfigurator', ['DS/ENOXEngineer/services/I18nManager'], function(I18nManager) {

    'use strict';

    var  GridViewConfigurator = {

      myEngItemsConfigurator : function(){
        return {
          getComponentData : function(dataService){
            return dataService.getCurrentUserRootEng();
          },
          getTitle : function(){
            return I18nManager.get("my_eng_items");
          },
          getViewName : function(){
            return "my_eng_items";
          },
          getPreferredView : function(localStorage){
            return localStorage.getItem("my_eng_items_view");
          }
        }
      },
      recentsEngItemsConfigurator : function(){
        return {
          getComponentData : function(dataService){
            return dataService.getCurrentUserRecentsItems();
          },
          getTitle : function(){
            return I18nManager.get("recent_items");
          },
          getViewName : function(){
            return "recent_items";
          },
          getPreferredView : function(localStorage){
            return localStorage.getItem("recent_items_view");
          }
        }
      }
    };

    return GridViewConfigurator;

});

/**
 * @module DS/ENOXEngineer/componentsHelpers/CollectionView/DragAndDropRejectionView
 */
define('DS/ENOXEngineer/componentsHelpers/CollectionView/DragAndDropRejectionView', [
    'UWA/Core', 
    'UWA/Controls/Abstract',
    'DS/UIKIT/Scroller',
    'DS/Handlebars/Handlebars',
    'DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
    'text!DS/ENOXEngineer/componentsHelpers/CollectionView/ENOXENIssuesList.html'
], function(UWA, Abstract, Scroller, Handlebars, XEngineerModal,  Html_Issues) {

    'use strict';
    var issuesTemplate = Handlebars.compile(Html_Issues);
    Handlebars.registerHelper("inc", function(value, options){
                                            return parseInt(value) + 1;
                                        });

    /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/componentsHelpers/CollectionView/DragAndDropRejectionView
     * @augments module:UWA/Controls/Abstract
     * @param {Object} options options hash or a option/value pair.
     */
    var DragAndDropRejectionView = Abstract.extend(
     /**
     * @lends module:DS/ENOXEngineer/componentsHelpers/CollectionView/DragAndDropRejectionView.prototype
     */
    {

        defaultOptions: {

        },

        init: function(options) {
            this._parent(options);
            var that = this;
            this.onAcceptAndIgnore = options.onAcceptAndIgnore;
            this.onCancel =  options.onCancel;
            this.issues =  options.issues;
            this.allFailed = options.allFailed;
            this.isResolved = false;
            this.nlsService = options.nlsService || {
                get: function(key){
                    return key;
                }
            };
            

            this.buildView()
        },
        _isGlobalRendering: function(){
            if(!Array.isArray(this.issues)) return true;

            for (var i = 0; i < this.issues.length; i++) {
                const issue = this.issues[i];
                if(issue.isGlobal)
                    return true;
            }
            return false;

        },
        buildView: function(){
            var that = this;
            var isGlobal = this._isGlobalRendering();
            this._buildModal().getBody().setHTML(issuesTemplate({
                items: this.issues,
                isGlobal: isGlobal,
                notGlobal: !isGlobal,
                nls_object_info: this.nlsService.get("object.description"),
                nls_reason: this.nlsService.get("issuse.description")
            }));
            this.modal.onValidate(function(finish){
                that.onAcceptAndIgnore();
                that.isResolved = true;
              finish();
              that.destroyView();
            }, this);
      
            this.modal.onClose(function(){
              (!that.isResolved) && that.onCancel();
              that.destroyView();
              console.warn('onClose');
            }, this);

      
            this.modal.show();
      
        },
        _getModalTitle: function(){
            if(this._isGlobalRendering()){
                return this.nlsService.get("eng.ui.dialog.inValidDrop");
            }
            return this.allFailed ? this.nlsService.get("eng.ui.dialog.allDropContentInvalidData"):this.nlsService.get("eng.ui.dialog.dropContentInvalidData");
        },
        _buildModal: function(){
            var that = this;
            this.modal = new  XEngineerModal({
                title : this._getModalTitle(),
                className : 'xeng-dnd-rejection',
                withFooter : true,
                customFooter: function(){
                    if(that.allFailed || that._isGlobalRendering()){
                        return "<button type='button' name='cancelButton' class='btn btn-default'>"+that.nlsService.get('eng.ui.button.cancel')+"</button>";
                    }
                   return  "<button type='button' name='okButton' class='btn btn-primary'>"+that.nlsService.get('eng.ui.button.continueAndIgnore')+"</button> " +
                    "<button type='button' name='cancelButton' class='btn btn-default'>"+that.nlsService.get('eng.ui.button.cancel')+"</button>";
                }
              });
        
              return this.modal;
        },
        destroyView: function(){
            var that = this;
            this.onAcceptAndIgnore = null;
            this.onCancel = null;
            this.issues = null;
            that.modal && that.modal.destroy();
            that.modal = undefined;
        }

    });

    return DragAndDropRejectionView;
});

define('DS/ENOXEngineer/controllers/LandingPageController',
    [
      'DS/ENOXEngineerCommonUtils/XENMask',
      'DS/ENOXEngineer/componentsHelpers/GridViewConfigurator/GridViewConfigurator',
      'DS/ENOXEngineer/utils/XEngineerConstants',
    ],
     function(
       Mask,
       GridViewConfigurator,
       XEngConstants
     ) {

    'use strict';

    /**
    * @param {object} options.app  application reference
    * @param {object} options.parentController parent controller ref
    **/
    function LandingPageController(options){
      this.myEngCmp =null;
      var that = this;
      that.isFirstRendering = true;
      if (!options) {
        throw new Error("options are mandatory");
      }

      if (!options.app || !options.parentController) {
        throw new Error("app and parentController are mandatory");
      }

      var parentController = options.parentController;
      var app = options.app;

      return {
        activate : function () {
          // app.engItemsStore.fetchMyEngItems();
          app.mediator.publish(XEngConstants.EVENT_TRIPTYCH_SHOW_PANEL,'left');
          app.mediator.publish(XEngConstants.EVENT_SELECT_ACTION_WP,{id: 'my_eng_items' });
          if (that.isFirstRendering) {
            that.isFirstRendering = false;
            // put loading in main container
            Mask.mask(UWA.extendElement(parentController.triptychCmp.mainDiv));

            that.myEngCmp = app.componentsMgt.startNewInstance(XEngConstants.MY_ENG_ITEM_CMP, parentController.triptychCmp.mainDiv, GridViewConfigurator.myEngItemsConfigurator());


          }else{ // caching the view
            that.myEngCmp.reRender();
            // that.welcomePanelCmp.reRender();
            app.mediator.publish(XEngConstants.EVENT_REFRESH_LANDING_DATA);
          }

        },
        deactivate : function () {
          that.myEngCmp.stop();
          // that.welcomePanelCmp.stop();
          // app.componentsMgt.deleteInstance(XEngConstants.WELCOME_PANEL_CMP, that.welcomePanelCmp.ref);
          // app.componentsMgt.deleteInstance(XEngConstants.MY_ENG_ITEM_CMP, that.myEngCmp.ref);
        }
      }

    }

    return LandingPageController;

});

define('DS/ENOXEngineer/controllers/RecentsEngItemsController', [
  'DS/ENOXEngineerCommonUtils/XENMask',
  'DS/ENOXEngineer/componentsHelpers/GridViewConfigurator/GridViewConfigurator',
  'DS/ENOXEngineer/utils/XEngineerConstants',
], function(
  Mask,
  GridViewConfigurator,
  XEngConstants
) {

    'use strict';
    /**
    * @param {object} options.app  application reference
    * @param {object} options.parentController parent controller ref
    **/
    function RecentsEngItemsController(options){
      var that = this;
      this.recentsCmp = null;
      that.isFirstRendering = true;
      if (!options) {
        throw new Error("options are mandatory");
      }

      if (!options.app || !options.parentController) {
        throw new Error("app and parentController are mandatory");
      }

      var parentController = options.parentController;
      var app = options.app;

      return {
        activate : function () {
          app.mediator.publish(XEngConstants.EVENT_SELECT_ACTION_WP,{id: 'recent_items' });
          app.mediator.publish(XEngConstants.EVENT_TRIPTYCH_SHOW_PANEL,'left');
          if (that.isFirstRendering) {
            that.isFirstRendering = false;
            // put loading in main container
            Mask.mask(UWA.extendElement(parentController.triptychCmp.mainDiv));

            that.recentsCmp = app.componentsMgt.startNewInstance(XEngConstants.MY_ENG_ITEM_CMP,
                                                                parentController.triptychCmp.mainDiv,
                                                                GridViewConfigurator.recentsEngItemsConfigurator());


          }else{ // caching the view
            that.recentsCmp.reRender();
            app.mediator.publish(XEngConstants.EVENT_REFRESH_LANDING_DATA);
          }

        },
        deactivate : function () {
          that.recentsCmp.stop();
        }
      }



    }

    return RecentsEngItemsController;

});

define('DS/ENOXEngineer/componentsHelpers/SecurityContextChooser/SCChooser', [
  'DS/UIKIT/Input/Select',
  'DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json',
  'css!DS/ENOXEngineer/componentsHelpers/SecurityContextChooser/SCChooser.css'
], function(
  Select,
  XEngineerModal,
  nlsKeys
) {
    'use strict';

    function SCChooser(options){
      var that = this;
      this.SCManager = options.SCManager;
      this.resolve = options.resolve;
      this.reject =  options.reject;

      this.buildView();
    }

    SCChooser.prototype._buildModal  = function(){
      this.modal = new  XEngineerModal({
        title : nlsKeys.get("eng.ui.dialog.chooseSC"),
        className : 'xeng-sc-chooser',
        withFooter : true
      });

      return this.modal;
    };


    SCChooser.prototype._getModalContent = function(){
      var prefs = this.SCManager.getSCPreference();
      var sc_list = (prefs && Array.isArray(prefs.options)) ? prefs.options  : [];
      var that = this;
      this.selector = new Select({
        placeholder: nlsKeys.get("eng.ui.dialog.SC.list"),
        options: sc_list,
        events : {
          onChange : that.onChange.bind(that)
        }
        });
      return this.selector;
    };
    SCChooser.prototype.onChange = function(){
      console.log(this.selector.getValue());
      var selected = this.selector.getValue()[0];
      if(selected.trim().length ===0){
        this.disableValidateBtn();
      }else if(this.isDisableFooter()){
        this.enableValidateBtn();
      }
        
    };
    SCChooser.prototype.removeCancelBtn = function(){
      var cancelBtn = document.body.querySelector("button[name=\"cancelButton\"]");
      if (cancelBtn.parentNode !== null){
        cancelBtn.parentNode.removeChild(cancelBtn);
      }
    };

    SCChooser.prototype.disableValidateBtn = function(){
      var okBtn = document.body.querySelector("button[name=\"okButton\"]");
      okBtn &&(okBtn.disabled = true);
    };

    SCChooser.prototype.isDisableFooter = function(){
      var okBtn = document.body.querySelector("button[name=\"okButton\"]");
      return okBtn ? okBtn.disabled : false;
    };


    SCChooser.prototype.enableValidateBtn = function(){
      var okBtn = document.body.querySelector("button[name=\"okButton\"]");
      okBtn &&(okBtn.disabled = false);
    };


    SCChooser.prototype.buildView = function(){
      var that = this;
      this._getModalContent().inject(this._buildModal().getBody());
      this.modal.onValidate(function(finish){
        var selectedSC = this.selector.getValue()[0];
        widget.setValue('SC', selectedSC );
        that.resolve && that.resolve(selectedSC);
        finish();
      }, this);

      this.modal.onClose(function(){
        that.modal.show();
        return ; // to force user to make a choice
      }, this);

      this.modal.show();

      this.removeCancelBtn();
      this.disableValidateBtn();

    };

    return SCChooser;

});

define('DS/ENOXEngineer/services/EngineeringSettings', [
  'UWA/Core',
  'UWA/Class',
  'UWA/Class/Debug',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineerCommonUtils/XENPlatform3DXSettings',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/CfgAuthoringContextUX/scripts/CfgAuthoringContext',
  'DS/ENOXEngineer/utils/xEngPnOSCChoiceMngt',
  'DS/ENOXEngineer/componentsHelpers/SecurityContextChooser/SCChooser',
  'DS/WebappsUtils/WebappsUtils',
  'DS/ENOXEngineer/componentsHelpers/CollectionView/DragAndDropRejectionView',
  'text!DS/ENOXEngineer/assets/config/xEngineer.conf.json'
], function(
	UWACore,
	UWAClass,
	UWADebug,
  XEngineerConstants,
  XENPlatform3DXSettings,
  xEngAlertManager,
  PromiseUtils,
  CfgAuthoringContext,
  xEngPnOSCChoiceMngt,
  SCChooser,
  WebappsUtils,
  DragAndDropRejectionView,
	xEngineerConf
) {

	'use strict';
  
  var _confSetting=JSON.parse(xEngineerConf);

	var EngineeringSettings = UWAClass.singleton(UWADebug,XENPlatform3DXSettings, {

		/*
		 * @param  entry name
		 * return setting value if the key exist and null otherwise
		 */
		getSetting: function(key){
			if (UWACore.is(key,'string') && UWACore.is(_confSetting[key])) {
				return _confSetting[key];
			}
			return null;
    },
    getIconUrl: function(iconKey){
      return this.getIconPath(iconKey);
    },
    getIconPath: function(iconKey){
      return  WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'icons/32/'+iconKey+'.png');
    },
    getLoadingIcon: function(){
      return this.getImagePath('loading22x22.gif');
    },
    getImagePath: function(img){
      return WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'img/'+img);
    },
    getNlsStorageName: function(){
      return XEngineerConstants.NLS_STORAGE_NAME +'_'+ this.getLanguage();
    },
    getPredicatesNlsStorageName: function(){
      return XEngineerConstants.PREDICATE_NLS_STORAGE_NAME + this.getPlatformId() +'_'+ this.getLanguage();
    },
    get3DXContentFromDrop : function(dropData){
      if (!dropData || !dropData.data || !Array.isArray(dropData.data.items) ) {
        throw "Dopped data are not valid";
      }
      return dropData.data.items;
    },
    getAppConfigLabel : function(withSeparator){
      var that =this;
      var suffix = "";
      var dash  = withSeparator ? '-' : '';
      if(that._platforms && Object.keys(that._platforms).length>1){
        suffix = dash+that.getPlatformId();
      }
      if(that.app.core.isInExperimentalLabMode()){
        suffix += ' '+that.app.core.i18nManager.get("eng.app.in.experimentalLab")
      }
      return suffix;
    },
    isWorkingUnderEvolution: function(){
      if(!CfgAuthoringContext) return false;

      var wuData = CfgAuthoringContext.get();
      return (wuData && wuData.evolution && wuData.evolution.id && wuData.evolution.id.length>1);
    },
    resetWorkUnderBubble: function(){
      CfgAuthoringContext && CfgAuthoringContext.cleanAuthDetails();
    },
/*
    shouldAcceptSearchResults : function(results, rootType){
    	var that = this;
      var dataService = this.app.core.dataService;
      var subTypes = [];
      if (Array.isArray(searchResults)) {
       subTypes = results.map(function(node){
         return node["ds6w:type"];
       });
      }

      return new Promise(function(resolve, reject){
        if(subTypes.length ===0){
          return reject('no subtypes');
        }
        dataService.asyncAreA(rootType, subTypes).then(function(result){
          if(result){
            return resolve('ok');
          }
          reject('not autorized');
        }).catch(function(){
          reject('type not found');
        });
      });



        // if (searchResults[i]["ds6w:type"]!==rootType) {
        //   throw searchResults[i]["ds6w:type"]+" are not supported for this operation";
        // }
    	// } catch (e) {
    	// 	xEngAlertManager.errorAlert(e.message|| e);
    	// 	return false;
    	// }
    	return false;
    },*/
    droppedDataFilter: function(droppedData, checkers, _intent){
      var that = this;
      return PromiseUtils.wrappedWithPromise(function (resolve, reject){
        if(!Array.isArray(checkers)){
          return  reject(that.app.core.i18nManager.get("error.expect.array.checker"));
         }

         var intent = (_intent) ? _intent : 'OPEN';

         for (var i = 0; i < checkers.length; i++) {
           var checker = checkers[i];
           if (typeof checker !=='function' ) {
             return  reject(that.app.core.i18nManager.get("error.expect.array.ofFunction.checker"));
           }
         }
         if (!droppedData.data || !Array.isArray(droppedData.data.items)) {
          return  reject(that.app.core.i18nManager.get("error.dropped.not.inright.format"));
        }
        var promises = [];
        var result ={
          invalids : [],
          valids : droppedData.data.items
        }
        for (var i = 0; i < checkers.length; i++) {
          var checker = checkers[i];
          promises.push(checker.call(that ,droppedData.data.items, intent, result));
        }

        PromiseUtils.all(promises).then(function(){

          if(result.invalids.length>0){

            var _onAcceptAndIgnore = function(){
              resolve(result.valids);
            };
            var _onCancel = function(){
              reject();
            };
            new DragAndDropRejectionView({
              issues: result.invalids,
              allFailed: result.valids.length ===0,
              nlsService: that.app.core.i18nManager,
              onAcceptAndIgnore: _onAcceptAndIgnore,
              onCancel: _onCancel
             });
          }else{
            resolve(result.valids);
          }
        }).catch(function(err){
          reject(err);
        });



      });
    },
    isSetValidSelectionForOpen: function (selectionForOpenText) {
      var that = this;
      return PromiseUtils.wrappedWithPromise(function (resolve, reject) {

        if (!selectionForOpenText) {
          return reject("no_selection");
        }

        try {
          var selectionForOpen = JSON.parse(selectionForOpenText)
          var selection = that.get3DXContentFromDrop(selectionForOpen);
          if (!Array.isArray(selection) || selection.length !== 1) {
            xEngAlertManager.errorAlert(that.app.core.i18nManager.get("error.tooMany.items.selected.forOpen"));
            return   reject("error.tooMany.items.selected.forOpen");
          }

          that.retrieveValidItemsForOpenFromDrop(selectionForOpen).then(function(data){
            resolve(data[0])
          }).catch(function(e){
            reject("unmanaged_type_for_open");
          });

        } catch (e) {
          xEngAlertManager.errorAlert(that.app.core.i18nManager.get("error.parse.3DXContent.failed"));
          return  reject("error.parse.3DXContent.failed");
        }

      });

    },
    retrieveAllValidContentForXENFromDrop: function(droppedData){
      return this.droppedDataFilter(droppedData,[this._tenantChekerV2, this._typeComplianceChecker ],'BOM');
    },
    retrieveValidItemsForOpenFromDrop: function(droppedData){
      return this.droppedDataFilter(droppedData,[this._tenantChekerV2, this._typeComplianceChecker, this._nbDroppedItemsChecker ],'OPEN');
    },
    retrieveAllValidDocumentsFromDrop: function(droppedData){
      return this.droppedDataFilter(droppedData,[this._tenantChekerV2, this._typeComplianceChecker ],'DOC');
    },
    _buildIssueEntry: function(droppedItem, message){
      var that = this;
      var _info ="";
      if(!droppedItem.isGlobal){
        _info = this.app.core.i18nManager.replace(that.app.core.i18nManager.get("error.objectDescription"),{
          displayName : droppedItem.displayName,
          type : droppedItem.displayType
        });
      }

      return {
        reason: message,
        isGlobal: droppedItem.isGlobal,
        source : droppedItem.serviceId,
        type: droppedItem.objectType,
        infos : _info
      };
    },
    _nbDroppedItemsChecker: function(dropped, intent, resultHolder){
      var that =this;
      return PromiseUtils.wrappedWithPromise(function(resolve, reject){
        if(intent === 'OPEN' && dropped.length!==1){
          resultHolder.invalids.push(that._buildIssueEntry({
            isGlobal: true
          }, that.app.core.i18nManager.get("error.drop.for.open.dont.support.multi")));
          dropped.splice(0,dropped.length);
        }

        resolve(true);
      });

    },
    _tenantChekerV2: function(dropped, intent, resultHolder){
      var that =this;
      var currentTenant = that.getPlatformId();
      return PromiseUtils.wrappedWithPromise(function(resolve, reject){
        for(var i=0; i<dropped.length; i++){
          if(dropped[i].envId !== currentTenant){
            let message = that.app.core.i18nManager.replace(that.app.core.i18nManager.get("error.not.belong.toThePlatform"),{
              displayName : dropped[i].displayName,
              tenant : currentTenant
            });
            resultHolder.invalids.push(that._buildIssueEntry(dropped[i], message));
            //remove from the checkable
            dropped.splice(i,1);
            i--;
          }
        }

        resolve(true);
      });
    },
    _getBOMContentTypes: function(dropped, resultHolder, intent){
      var that = this;
      var checker = function(obj){
        return that.app.core.dataService.syncIsAnEngineeringItem(obj.objectType) || that.app.core.dataService.syncIsADocument(obj.objectType) || that.app.core.dataService.syncIsAMaterial(obj.objectType);
      }
      return this._genericDropTypeChecker(dropped, resultHolder, intent, checker);
    },
    _getAllOpenableItem: function(dropped, resultHolder, intent){
      var that = this;
      var checker = function(obj){
        return that.app.core.dataService.syncIsAnEngineeringItem(obj.objectType) ||
         that.app.core.dataService.isSavedFilter(obj.objectType) ;
      }
      return this._genericDropTypeChecker(dropped, resultHolder, intent, checker);
    },
    _getAllDocuments: function(dropped, resultHolder, intent){
      var that = this;
      var checker = function(obj){
        return that.app.core.dataService.syncIsADocument(obj.objectType);
      }
      return this._genericDropTypeChecker(dropped, resultHolder, intent, checker);
    },
    _genericDropTypeChecker: function(dropped, resultHolder, intent, checker){
      var that = this;
      var dataService = this.app.core.dataService;
      return PromiseUtils.wrappedWithPromise(function(resolve, reject){
        if(!Array.isArray(dropped) || typeof checker !=='function') throw new Errow('invalid inputs');

        var types  = dropped.map(function(item){
              return item.objectType;
            });
        //resolve all eventually unkown types
        dataService.getRootTypes(types).finally(function(){
          for (var i = 0; i < dropped.length; i++) {
            const element = dropped[i];
            if(!checker(element)){
                 var errorOP = that.app.core.i18nManager.replace(that.app.core.i18nManager.get("error.not.supported.type"),{
                  type : element.displayType,
                  operation : that.app.core.i18nManager.get("eng."+intent)
                });
                resultHolder.invalids.push(that._buildIssueEntry(element, errorOP));
                //remove from the checkable
                dropped.splice(i,1);
                i--;
            }
          }

          resolve(true);

        });
      });
    },

    _typeComplianceChecker: function(dropped, intent, resultHolder){
      var that = this;
      switch (intent) {
        case 'BOM':
          return that._getBOMContentTypes(dropped, resultHolder, intent);
          break;
        case 'OPEN':
          return that._getAllOpenableItem(dropped, resultHolder, intent);
          break;
        case 'DOC':
          return that._getAllDocuments(dropped, resultHolder, intent);
          break;
        default:
          return that._getAllOpenableItem(dropped, resultHolder, intent);
      }
    },
    shoulAutorizedConfig : function(){
      if( this.isConfigRoleGranted() && this.isDecouplingActivated()){
        return true;
      }
      //disable config on cloud env and not granted users
      return false;
    },
    isDecouplingActivated: function(){
      var settings = this.app.core.dataService.getConfigSettings();
      var setting = null;
      for (var i = 0; i < settings.length; i++) {
        if(settings[i].settingName === "decoupleVariantEvolution"){
          setting = settings[i];
          break;
        }
      }

      return (setting && setting.value =="enabled") ? true : false;
    },
    isAuthorizedTypeOnDrop : function(types, intent, typesNlsMapping){
      var that = this;
      var dataService = this.app.core.dataService;
      switch (intent) {
        case 'BOM':
          return dataService.areBOMContentTypes(types, typesNlsMapping);
          break;
        case 'OPEN':
          return dataService.areEngeeringItems(types, typesNlsMapping);
          break;
        case 'DOC':
          return dataService.areDocuments(types, typesNlsMapping);
          break;
        default:
          return dataService.areEngeeringItems(types, typesNlsMapping);
      }
    },
		getAppId: function() {
      try{
          return widget.getValue('x3dAppId') ? widget.getValue('x3dAppId') : 'ENXENG_AP';
        } catch(ex){
          //we are in ODT mode
          return 'ENXENG_AP';
        }
		},
		getCommand: function(command){
			if (UWACore.is(command,'string') && UWACore.is(_confSetting['commands'][command])) {
				return _confSetting['commands'][command];
			}
			return null;
    },
    getCVRequestLabel: function(){
      return this.app.core.i18nManager.get('APP_NAME')+'-'+this.getCurrentUser().id+'-'+(new Date()).getTime();
    },
		getUserImage : function(userId){
			return this.getServiceURL(XEngineerConstants.SERVICE_3DSWYM_NAME)+"/api/user/getpicture/login/"+userId+"/format/normal";
		},
		getSecurityContext : function() {
			return widget.getValue('SC');
    },
    // getSecurityToken: function(){
    //   var user = this.getCurrentUser() || {};
    //   return user.id + '|' + 'ctx::'+this.getSecurityContext() + '|preferred';
    // },
    securityContextPromise : null,
    retrieveSecurityContextAndFillWidgetPref : function(options){
      var that = this;
      this.scChooserHelper = new xEngPnOSCChoiceMngt(options);

      return PromiseUtils.wrappedWithPromise(function(resolve, reject){
        that.scChooserHelper.RetrieveSCListAndPrefered({
          callback : function(isOk){

            if(isOk){
              var NlsPreference = "eng.user.credentials.chooser";
              var SCPreference = that.scChooserHelper.getSCPreference( NlsPreference );
              widget.addPreference(SCPreference);
              var _PreviousSC = widget.getValue('SC');
              if(!_PreviousSC){
                var _CurrentSC  = that.scChooserHelper.getSCPreferred(_PreviousSC);
                if(_CurrentSC){
                  _CurrentSC && widget.setValue('SC', _CurrentSC );
                  return resolve(true);
                } else{
                  //ask user to choose a security context
                var scChooser=  new SCChooser({
                    SCManager : that.scChooserHelper,
                    resolve : resolve,
                    reject : reject,
                  });

                }

              }else{
                return resolve(true);
              }

            }else{
              reject(false);
            }
          }
        });
      });

    },
		initialize:function(app){
      this.logger=app.core.logger.get("Setting manager");
			var that=this;
      this.app = app;
			app.core.shoulAutorizedConfig = app.sandboxBase.shoulAutorizedConfig = that.shoulAutorizedConfig.bind(that);
      app.core.settingManager = that;
       
      return PromiseUtils.wrappedWithPromise(function (resolve, reject) {
        that.discoverRelated3DXPlatform().then(function () {
          that.securityContextPromise = that.retrieveSecurityContextAndFillWidgetPref({
            url: that.getDefault3DSpaceUrl(),
            platforminstance: that.getPlatformId()
          });
          app.mandatoryStartupPromises.push(that.securityContextPromise);

          that.securityContextPromise.then(function () {
            return resolve();
          }).catch(function (reason) {
            that.logger.error('unable to retrieve SecurityContext');
            reject(reason);
          });

        }).catch(function (errors) {
          reject(errors); throw new Error(errors);
        });
      });
		}
	});

	return EngineeringSettings;

});

define('DS/ENOXEngineer/utils/Utils', [
	'UWA/Core',
	'UWA/Utils',
	'DS/ENOXEngineerCommonUtils/PromiseUtils',
	'DS/DataDragAndDrop/DataDragAndDrop',
	'DS/ENOXEngineer/services/EngineeringSettings',
	'DS/ENOXEngineer/utils/XEngineerConstants',
	'DS/ENOFilterBIUX/FilterBIComponentProxy'
], function (Core, UWAUtils, PromiseUtils, DataDragAndDrop, EngineeringSettings, XEngineerConstants, FilterBIComponentProxy) {

	var taggerProxy = null;
	var Utils = {
		//IR-598945-3DEXPERIENCER2018x
		getVersionByIdFromVersionGraph: function (root, pid) {
			if (!root || !root.Derived || !root["Main Derived"]) return null;

			pid = (pid && pid.startsWith("pid:")) ? pid : 'pid:' + pid;

			return this._searchMatch(root, pid);
		},

		_searchMatch: function (node, pid) {
			var that = this;
			if (node.id === pid) {
				return node;
			}
			if (node["Main Derived"] && node["Main Derived"].id === pid) {
				return node["Main Derived"];
			}

			if (Array.isArray(node.Derived) && node.Derived.length > 0) {
				for (var i = 0; i < node.Derived.length; i++) {
					if (node.Derived[i].id === pid) {
						return node.Derived[i];
					}
				}
			}

			if (Array.isArray(node.Derived) && node.Derived.length > 0) {
				var result = [];
				for (var i = 0; i < node.Derived.length; i++) {
					result.push(that._searchMatch(node.Derived[i], pid));
				}

				for (var i = 0; i < result.length; i++) {
					if (result[i]) return result[i];
				}
			}

			if (Array.isArray(node["Main Derived"].Derived) && node["Main Derived"].Derived.length > 0) {
				var result = [];
				for (var i = 0; i < node["Main Derived"].Derived.length; i++) {
					result.push(that._searchMatch(node["Main Derived"].Derived[i], pid));
				}
				for (var i = 0; i < result.length; i++) {
					if (result[i]) return result[i];
				}
			}

			if (node["Main Derived"] && node["Main Derived"]["Main Derived"] && node["Main Derived"]["Main Derived"].id) {
				return that._searchMatch(node["Main Derived"]["Main Derived"], pid);
			}

			return null;
		},
		loadFiles: function (loaders, context) {
			var dfd = new Promise(function (resolve, reject) {

				var resol = function () {
					resolve(arguments);

				};

				var rej = function (err) {
					reject(err);
				};

				if (Array.isArray(loaders)) {
					require(loaders, resol, rej);
				} else {
					rej(loaders);
				}

			});


			return dfd;
		},
		getTaggerColorMap: function (colorizeOptions) {
			var nodes = colorizeOptions.nodes, coloredNodes = {};

			colorizeOptions.coloredSubjects.map(function (element) {
				coloredNodes[nodes[element.path[0]]] = element.color;
			});
			return coloredNodes;
		},
		getAugmenttedQueryForSearch: function (query) {
			if (Core.is(query, "string") && query.trim().length > 0) {
				var augQuery = query;
				if (query.charAt(0) !== '*') augQuery = '*' + query;

				if (query.charAt(query.length - 1) !== '*') augQuery = augQuery + "*";

				return augQuery;
			}
			return null;
		},
		initFilterBIProxy: function (options, widgetID) {
			//Instanciate BIProxy
			var options_FilterBI = {
				tenant: EngineeringSettings.getPlatformId(),
				processingMode: 'appProcessing',
				colorize: true,
				appId: EngineeringSettings.getAppId(),
				widgetId: widgetID,
				appQueryParam: {
					'q.iterative_filter_query_bo': '[ds6w:globalType]:\"ds6w:Document\" OR [ds6w:globalType]:\"ds6w:Part\"',
					'no_type_filter_rel': ["XCADBaseDependency"]
				}
			};
			this.taggerProxy = new FilterBIComponentProxy(options_FilterBI);
			return this.taggerProxy;
		},
		createNodePathJson: function (data) {
			var jsonObj = {
				nodes: [],
				paths: []
			};
			var instances = data;
			var instSubjectTags = new Object();
			for (var inst in instances) {
				var instance = instances[inst];
				var instArr = [];
				jsonObj.nodes.push(instance.options ? instance.options.referenceId : null);
				instArr.push(inst);
				jsonObj.paths.push(instArr);
			}
			return jsonObj;
		},
		createNodePathJsonFromArray: function (engItems) {
			var jsonObj = {
				nodes: [],
				paths: []
			};
			engItems.forEach(function (item, idx) {
				jsonObj.nodes.push(item.getID());
				var instArr = [];
				instArr.push(idx);
				jsonObj.paths.push(instArr);
			});
			return jsonObj;
		},
		getDateFormater: function(){
			if (!this.dataFormatter2) {
				this.dataFormatter2 = new Intl.DateTimeFormat(EngineeringSettings.getLanguage(), {
					year: 'numeric', month: 'numeric', day: 'numeric'
				});
			}
			return this.dataFormatter2;
		},
		getformatedDate: function (stringDate) {
			if (!this.dataFormatter) {
				this.dataFormatter = new Intl.DateTimeFormat(EngineeringSettings.getLanguage(), {
					year: 'numeric', month: 'numeric', day: 'numeric',
					hour: 'numeric', minute: 'numeric', second: 'numeric'
				});
			}

			try {
				return this.dataFormatter.format(new Date(stringDate)).replace(',', '');
			} catch (error) {
				return stringDate;
			}

		},
		dateFormatFromDsToIso: function(_date, strictMode){
			if(!_date || _date.length===0) return null;

			var result = _date; 
			if(result.indexOf('@')>-1 && result.indexOf(':GMT')>-1){
				result = result.replace('@','T').replace(/\//g, '-').replace(':GMT','Z');
			}else if(strictMode && (result.indexOf('T')===-1 ||  result.indexOf('Z')===-1)){ //light test of iso format
				result = null;
			}
			return result;
		},
		/**
		 * only for display purpose
		 * @param {*} rawDate 
		 */
		formatCustomDateAttribute: function(rawDate){
			if(!rawDate || !Core.is(rawDate,'string') || rawDate.length===0) return null;

			try {
				var isoFormat = this.dateFormatFromDsToIso(rawDate);
				return isoFormat ? this.getDateFormater().format(new Date(isoFormat)) : null;
			} catch (error) {
				return rawDate;
			}
		},

		getArrayWithoutDuplicate: function (arr) {
			if (!Array.isArray(arr) || arr.length === 0) {
				return [];
			}
			var result = [arr[0]];
			for (var i = 1; i < arr.length; i++) {
				if (result.indexOf(arr[i]) === -1) {
					result.push(arr[i]);
				}
			}

			return result;
		},

		prepareDragData: function (draggedItemModels) {
			var data = {
				protocol: "3DXContent",
				version: "1.1",
				source: EngineeringSettings.getAppId(),
				widgetId: EngineeringSettings.getWidgetId(),
				data: {
					items: []
				}
			};
			var draggedItems = [], that = this;

			draggedItemModels.forEach(function (itemModel) {

				var object = {
					'envId': EngineeringSettings.getPlatformId(),
					'serviceId': XEngineerConstants.SERVICE_3DSPACE_NAME,
					'contextId': '' /* Cannot retrieve it in the 3DDashboard */,
					'objectId': itemModel.getID(),
					'objectType': itemModel.getType(),
					'displayName': itemModel.getLabel(),
					'displayType': itemModel.getType()
				}
				draggedItems.push(object);
			});

			data.data.items = draggedItems;

			return JSON.stringify(data);

		},
		get3DXContentFromDrop: function (dropData) {
			if (!dropData || !dropData.data || !Array.isArray(dropData.data.items)) {
				throw "Dopped data are not valid";
			}
			return dropData.data.items;
		},
		_getItemsByTypeFromDroppedData: function (droppedData) {
			if (!Array.isArray(droppedData)) return {};
			var results = {};
			droppedData.forEach(function (item) {
				if (!results[item.objectType]) results[item.objectType] = [];

				results[item.objectType].push(item);
			});

			return results;
		},
		getCurrentTimeStamp: function () {
			return (new Date()).getTime();

		},
		cleanDroppable: function (element) {
			DataDragAndDrop.clean(element);
		},
		makeDroppable: function (option) {

			var dragEvent = {
				enter: function (el, event) {
					if (Core.typeOf(option.onDragEnter) === 'function') {
						option.onDragEnter.apply(option.context, [el, event]);
					}

				},
				leave: function (el, event) {

					if (Core.typeOf(option.onDragLeave) === 'function') {
						option.onDragLeave && option.onDragLeave.apply(option.context, [el, event]);
					}

				},
				over: function (el, event) {
					if (Core.typeOf(option.onDragOver) === 'function') {
						option.onDragOver && option.onDragOver.apply(option.context, [el, event]);
					}

				},
				drop: function (data, el, event) {
					if (Core.typeOf(option.onDrop) === 'function') {
						option.onDrop.apply(option.context, [data, el, event]);

					}
				}
			};

			DataDragAndDrop.droppable(option.element, dragEvent);
		},
		makeDraggable: function (element, dragEvent) {
			DataDragAndDrop.draggable(element, dragEvent);
		},

		uid: function () {
			return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
		},

		createEvent: function (originUid, data) {
			return {
				metadata: {
					uid: Utils.uid(),
					originUid: originUid,
					timestamp: Date.now(),
					appid: EngineeringSettings.getAppId() + '_' + EngineeringSettings.getWidgetId()
				},
				data: data
			};
		},
		isTouchDevice: function () {
			return ("ontouchstart" in document.documentElement);
		},
		getFileInput: function (isMono) {
			var fileExplorer = UWA.extendElement(widget.body).getElement('#fileExplorer');
			if (!fileExplorer) {
				fileExplorer = new UWA.createElement('input', {
					id: 'fileExplorer',
					multiple: (isMono) ? undefined : 'multiple',
					type: 'file',
					styles: {
						'display': 'none'
					}
				}).inject(widget.body);
				if (this.isTouchDevice()) {
					fileExplorer.accept = 'image/*;capture=camera';
				}
			}

			fileExplorer.removeEvents();
			return fileExplorer;
		},
		_downloadFromFCS: function (url, filename) {
			// // 1. Decompose the URL
			// var parsedUrl = UWAUtils.parseUrl(url);
			// // 2. Parse query part of the url
			// var params = parsedUrl.query.length ? UWAUtils.parseQuery(parsedUrl.query) : {};

			// params.__fcs__attachment = true;

			// // 4. Reconstruct post URL by removing the query part
			// delete parsedUrl.query;
			// var postUrl = UWAUtils.composeUrl(parsedUrl);
			// // 5. Create a temporary form and prepare inputs
			// var tempForm = document.createElement('form');
			// tempForm.style.display = 'none';
			// tempForm.method = 'POST';
			// tempForm.action = postUrl;

			// Object.keys(params).forEach(function (key) {
			// 	var newInput = document.createElement('input');
			// 	newInput.setAttribute('name', key);
			// 	newInput.setAttribute('value', params[key]);
			// 	tempForm.appendChild(newInput);
			// });

			// // 6. Attach temporary form to current document
			// document.body.appendChild(tempForm);
			// // 7. Submit it
			// tempForm.submit(); //so we can skip the submin in the case of an odt
			// console.warn("download launched !!!");


			// // 8. We're done, remove the temporary form
			// document.body.removeChild(tempForm);

			var div = document.createElement('div');
			div.style.display = "none";
			url = url+"&__fcs__attachment=true";
			div.innerHTML = '<a href="'+url+'" download></a>';
			var a = div.querySelector('a');
			document.body.appendChild(div);
			setTimeout(function () {
				a.click();
				document.body.removeChild(div);
			}, 66);
		},
		launchDownloadfromURLs: function(docsUrls) {
			var that = this;
			
			docsUrls.reduce(function(prevDownload, urlInfo ){
				return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){
					prevDownload.then(function(){
						that._downloadFromFCS(urlInfo.downloadUrl);
						setTimeout(function () {
							resolve();
						}, 106);

					});
				})
			}, PromiseUtils.wrappedWithCancellablePromise(function(resol, reje){
				resol();
			 }) );


		},
		
		convertVolumeInIUForDisplay: function(f_quantityInternational){
			var f_quantityLiter = f_quantityInternational / 0.001;
			
			// display of volumes in application is in Liter
			var unitOfMeasure = "L";
			
			return this.convertVolumeInIUTo(f_quantityInternational, unitOfMeasure).toString() + " " + unitOfMeasure; 
			
		},
		
		convertVolumeInIUTo: function(f_quantityInternational, unitOfMeasure){
			var factor = this._getVolumeConversionFactor(unitOfMeasure);
			var f_quantity = f_quantityInternational * factor;
			// necessary to round value else '0' appears, best solution would be to use BigDecimal...
			var roundedValue = Math.round(f_quantity*10000000)/10000000
			return roundedValue;
		},
		
		convertVolumeToInternationalUnit: function(f_quantity, unitOfMeasure){  
	    	  var factor = this._getVolumeConversionFactor(unitOfMeasure);
	    	  var f_quantityInternational = f_quantity / factor;  	  
	    	  return f_quantityInternational; 
		},
		_getVolumeConversionFactor: function(unitOfMeasure){
			var volumeUnitOfMeasure = EngineeringSettings.getSetting("volumeUnitOfMeasure");
			return volumeUnitOfMeasure[unitOfMeasure].factor;
		}
	};

	return Utils;
});

/**
 * @module DS/ENOXEngineer/services/XENUserSessionManager
 */
define('DS/ENOXEngineer/services/XENUserSessionManager', [
  'UWA/Core',
  'UWA/Class',
  'require',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'DS/ENOXEngineer/componentsHelpers/UploadViewer/UploadViewer',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineer/utils/Utils'
], function(UWA, Class, localRequire, PromiseUtils, xEngAlertManager,UploadViewer, XEngineerConstants, Utils) {

    'use strict';

        var indexSwitcherTimeout = null;

        function areNotSameColumnSet(_prev, _curr){
            if(!Array.isArray(_prev) || !Array.isArray(_curr))
              return true;
      
            if(_prev.length !== _curr.length) return true;
      
            for (var index = 0; index < _prev.length; index++) {
             if(_prev[index].dataIndex !== _curr[index].dataIndex) return true;
              
            }
            return false;
          }
     /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/services/XENUserSessionManager
     * @param {Object} options options hash or a option/value pair.
     */
    var XENUserSessionManager = Class.singleton(
    /**
     * @lends module:DS/ENOXEngineer/services/XENUserSessionManager
     */
    {

        init: function(options) {
            this._parent(options);
        },
        initialize: function (app) {
            this.logger = app.core.logger.get("XENUserSessionManager manager initializing");
            var that = this;
            app.core.sessionManager = app.sandboxBase.sessionManager = that;
            this.sessionBuilderIds = app.core.settingManager.getSetting("engItemOpenSessionBuilder");
            this.app = app;
            this._nextOpenFilter=null;
            this._openContext = null;
            this._insertMaterialContext = null;
            this._uploadViewer = new UploadViewer({
                nlsManager: app.core.i18nManager,
                immersiveFrame: app.core.moduleHelper.viewsService.getApplicationImmersiveFrame()
            });
            that.loadedProviders = null;
            that._loadColumnsProviders();
            that._currentStatticMapping = {};

            that.app.core.mediator.subscribe(XEngineerConstants.EVENT_CONF_MODEL_UPDATED, function(updatedEIPid){
                try {
                    var currentEI = that.app.core.contextManager.getActiveEngItem();
                    if(currentEI && currentEI.getID() === updatedEIPid){
                        currentEI.updateUserConfigPreferences();
                        that.app.core.mediator.publish(XEngineerConstants.EVENT_SYNC_VIEW_WITH_EI_MODEL);
                        that.buildCurrentSession();
                    }
                    
                } catch (error) {
                    console.error(error);
                }
               
              });
            this._showQualifiedAsFinal = false;
            that.app.core.mediator.subscribe(XEngineerConstants.EVENT_QUALIFIED_AS_FINAL_ITEM, function(options){
                    console.warn('XEngineerConstants.EVENT_QUALIFIED_AS_FINAL_ITEM %s',options);
                    if((options.commandId === XEngineerConstants.QUALIFIED_AS_FINAL_CMD) && that.isUsingDB()){
                        xEngAlertManager.warningAlert(that.app.core.i18nManager.get("eng.warning.qualifiedAsFinal.onDb"));
                    }
                    that.app.core.localStorage.setItem(XEngineerConstants.VALUE_QUALIFIED_AS_FINAL_COMPONENT,options.commandId);
                    that._showQualifiedAsFinal= (options.commandId === XEngineerConstants.QUALIFIED_AS_FINAL_CMD);
                    that.buildCurrentSession();
            });
        },
        getUploadTracker: function(fileInfo){
            if(this._uploadViewer){
                if(!this._uploadViewer.isInjected())
                    this._uploadViewer.inject(widget.body);
                    
                 return this._uploadViewer.getUploadTracker(fileInfo);
                 
            }
        },
        /**
         * return {
         * meta:{
         * },
         * name:"engItem_View",
         * params:{pid: "08B25643A86F4CC8B8DE0556D3031934"},
         * path:"/engItem/08B25643A86F4CC8B8DE0556D3031934"
         * }
         */
        getRouterCurrentState: function(){
            if(!this.app || !this.app.router) return null;
            
            var _state = this.app.router.getState();
            if(!_state) return null;

            return UWA.extend({}, _state, true);
        },
        isWorkingAnEngItem: function(){
            let _currentState = this.getRouterCurrentState();
            return (_currentState && _currentState.name ==='engItem_View');             
        },
        buildCurrentSession: function(){
            var currentRoot = this.app.core.contextManager.getActiveEngItem();
            if(currentRoot){
                currentRoot.getContentModels().buildUserWorkingSession();
            }
        },
        shouldShowFinalItems: function(){
            return this._showQualifiedAsFinal;
        },
        refreshWithDroppedFilter: function(droppedFilters){
            var firstFilter = droppedFilters[0] || null;
            if(!firstFilter || !firstFilter.rootType || !firstFilter.rootId)
                return ;
            var that =this;
            that.setNGFilterContextForNextOpen(firstFilter);

            if(that.hasValidNGFilterContext()){

                that.buildCurrentSession();
                that.app.core.mediator.publish(XEngineerConstants.EVENT_UPDATE_IDCARD_RENDERING, false);
                
            }else{
                that.consumeAvailableNGFilterContext();
            }



        },
        openSessionFromDroppedFilter: function(droppedFilters){
            console.warn(droppedFilters);
            var firstFilter = droppedFilters[0] || null;
            if(!firstFilter || !firstFilter.rootType || !firstFilter.rootId)
                return ;
            var that =this;
            if(firstFilter){
                that.app.core.dataService.areEngeeringItems([firstFilter.rootType],[firstFilter.rootType /*nls*/])
                                        .then(function(){

                                            that.setNGFilterContextForNextOpen(firstFilter);
                                            if(that.hasValidNGFilterContext()){
                                                that.app.core.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND,{
                                                    commandId: XEngineerConstants.OPEN_ENG_ITEM,
                                                    context: {
                                                        item: {
                                                          objectId: firstFilter.rootId,
                                                          objectType: firstFilter.rootType
                                                        }
                                                      }
                                                  });
                                            }else{
                                                that.consumeAvailableNGFilterContext();
                                            }

                                        }).catch(function(reason){
                                         console.error(reason);
                                         var message =   that.app.core.i18nManager.replace(that.app.core.i18nManager.get("error.not.supported.type"),{
                                                type : firstFilter.rootType,
                                                operation : that.app.core.i18nManager.get("eng.OPEN")
                                              });
                                         xEngAlertManager.errorAlert(message);
                                        });
            }
        },
        getCurrentOpenContext: function(){
          return this._lastOpenContext;
        },
        saveCurrentOpenContext: function(ctx){
          this._lastOpenContext = ctx;
        },
        /**
         * 
         * @param {
         * searchForOpen: true, OR 
         * objectId:'',
         * objectType:''
         * } _context
         */
        
       
        setMaterialForInsertContext: function(_context){
            this._insertMaterialContext = _context;
        },
        consummeAvailableMaterialForInsert: function(){
            var tmp = this._insertMaterialContext;
            this._insertMaterialContext = null;
            return tmp;
        },
        
        setNextOpenContext: function(_context){
            this._openContext = _context;
        },
        consummeAvailableOpencontext: function(){
            var tmp = this._openContext;
            this._openContext = null;
            return tmp;
        },
        setStaticMappingAsOpenContext:function(pid, options){
          if(pid && options){
            this._currentStatticMapping[pid] = options;

         }
        },
        getStaticForMappingAsOpenContext:function(pid){
            return this._currentStatticMapping[pid];
        },
        cleanStaticMappingContext:function(){
          this._currentStatticMapping = {};
        },
        setNGFilterContextForNextOpen: function(filterOptions){
            this._nextOpenFilter = filterOptions
        },
        consumeAvailableNGFilterContext: function(){
            //we should retrieve from pref
            var filter = this._nextOpenFilter;
            this._nextOpenFilter = null;
            return filter;
        },
        hasValidNGFilterContext: function(){
            if(!this._nextOpenFilter||
               !this._nextOpenFilter.filterId ||
               !this._nextOpenFilter.rootId ||
               !this._nextOpenFilter.filterName ||
               !this._nextOpenFilter.filter ||
               !this._nextOpenFilter.filter.CVQuery)
                return false;
            return true;
        },
        isUsingIndex: function(){
            return (this.determineAuthoringMode()==='index');
        },
        isUsingDB: function(){
            return (this.determineAuthoringMode()==='authoring');
        },
        _getWaitingTimeBeforeSwitchToIndexMode: function(){
            return parseInt(widget.getValue('intervalToSwitch'));//time unit second
        },
        determineAuthoringMode: function(){
            if(widget.getValue('UseOnlyDB') ==="true")
                return 'authoring';
            var modeInfo = widget.getValue('xEng_mode') || {};
            var currentTime = new Date().getTime();

            if(UWA.is(modeInfo.state,'string') && UWA.is(modeInfo.last_editing,'number')){
                var waiting_time = this._getWaitingTimeBeforeSwitchToIndexMode();

              if ( modeInfo.state ==='authoring' &&((modeInfo.last_editing +waiting_time*1000) < currentTime)) {
                return 'index';
              }
              return 'authoring';

            }

            return 'index';

        },
        setAuthoringMode: function(_newMode){
            var that = this;
            if(this.isUsingIndex() && _newMode ==="authoring" && this._getWaitingTimeBeforeSwitchToIndexMode()){
                xEngAlertManager.notifyAlert(this.app.core.i18nManager.get("disabling.index.acceleration"));
                that.app.core.mediator.publish(XEngineerConstants.EVENT_INDEX_MODE_DISABLE);
            }
            var modeInfo = {
                state : _newMode,
                last_editing : new Date().getTime()
              }
            widget.setValue('xEng_mode', modeInfo);
            if(_newMode ==="authoring" && this._getWaitingTimeBeforeSwitchToIndexMode()){
                if(indexSwitcherTimeout)
                    clearTimeout(indexSwitcherTimeout);

                var timeout = this._getWaitingTimeBeforeSwitchToIndexMode() || 0.02;

                indexSwitcherTimeout = setTimeout(function(){
                    xEngAlertManager.notifyAlert(that.app.core.i18nManager.get("enabling.index.acceleration"));
                    indexSwitcherTimeout = null;
                },timeout*1000);
            }

        },
        buildAppropriateSession: function(models) {
            var that = this;
            return PromiseUtils.wrappedWithPromise(function(resolve, reject){
                models.getEngineeringItem().setPersistedNGFilterContext(that.consumeAvailableNGFilterContext());
                if(!that.app.core.Factories.CollectionsFactory.isInstanceContentModels(models))
                    throw new Error("invalid parameter for buildAppropriateSession ");

                that.app.core.dataService.addRecentsEngItem(models.getEngineeringItem().getID());
                that.getAppropriateSessionBuilder(models)
                    .then(function(sessionBuilder){
                        that._processSessionBuilder(sessionBuilder, models)
                                    .then(resolve)
                                    .catch(function(reason){
                                        that._buildFallbackSession(models).then(resolve)
                                                          .catch(reject);
                                    });
                    }).catch(function(error){///failed to build appropriate session then build the default session
                        console.error(error);
                        that._buildFallbackSession(models).then(resolve)
                                                          .catch(reject);
                        
                    });
            });

        },
        _buildFallbackSession: function(_models){
            var that = this;
            return PromiseUtils.wrappedWithPromise(function(resolve, reject){
                
                that.getDefaultSessionBuilder(_models)
                    .then(function(sessionBuilder){
                        that._processSessionBuilder(sessionBuilder, _models)
                            .then(function(_data){
                                xEngAlertManager.warningAlert(that.app.core.i18nManager.get("warning.failed.toBuildAppropriate.session"));
                                resolve(_data);
                            })
                            .catch(function(error){
                                console.error(error);
                                reject(new Error(that.app.core.i18nManager.get("eng.failed.to.open.EI")));
                            });
                }).catch(function(error){
                    console.error(error);
                    reject(new Error(that.app.core.i18nManager.get("eng.failed.to.open.EI")));
                });
            });
        },
        retrieveCommonColumnProviders: function(models){
            var that = this;
            return PromiseUtils.wrappedWithPromise(function(resolve, reject){
                if(!models) return reject("models not found :( !!");
              that._loadColumnsProviders().finally(function(){
                try {
                    
                  var _previousColumns = models.getAdditionalColumns();
                  if(models.getEngineeringItem().isConfigured() && !that.shouldShowFinalItems()){
                    
                	  var columnsProviders = [that.getColumnsProviderWithMetas("configColumnsProvider")];
                     columnsProviders.push(that.getColumnsProviderWithMetas("configurationColumnsProvider"));
                	  if (that.app.core.commandManager.isMaterialQuantityAuthorized())
                		  columnsProviders.push(that.getColumnsProviderWithMetas("materialColumnsProvider"));
                	  
                    models.registerColumnsProviders(columnsProviders);
                    var _currentColumns = models.getAdditionalColumns();
                    if( models.hasBeenHandledByASessionManager() && areNotSameColumnSet(_previousColumns, _currentColumns)){
                        that.app.core.mediator.publish(XEngineerConstants.EVENT_COLUMNS_CHANGED);
                    }
                    models._bypassForConfigColumns();
                  }else{ //cleanup of configured columns
                	  
                	  var columnsProviders = [];
                	  if (that.app.core.commandManager.isMaterialQuantityAuthorized())
                		  columnsProviders.push(that.getColumnsProviderWithMetas("materialColumnsProvider"));
                       columnsProviders.push(that.getColumnsProviderWithMetas("configurationColumnsProvider"));

                    models.setColumnsProviders(columnsProviders);
                    if(Array.isArray(_previousColumns) && _previousColumns.length>0){
                        that.app.core.mediator.publish(XEngineerConstants.EVENT_COLUMNS_CHANGED);
                    }
                   
                  }
                  resolve(true);
                } catch (error) {
                  reject(error);
                }
                
            });
            });

        },
        _processSessionBuilder: function(_sessionBuilder, models){
            var that = this;
            return PromiseUtils.wrappedWithPromise(function(resolve, reject){
                if(!_sessionBuilder || typeof _sessionBuilder.buildSession !=="function"
                || typeof _sessionBuilder.retrieveAdditionalColumnProviders !=="function" )
                throw new Error("appropriate sessionBuilder not found");
                that.retrieveCommonColumnProviders(models).finally(function(){

                    _sessionBuilder.retrieveAdditionalColumnProviders().finally(function(){
                        _sessionBuilder.buildSession()//
                            .then(resolve)
                            .catch(function(error){
                                console.error(error);
                                reject("failed to build appropriate sessionBuilder");
                            });
                        });

                });
            });
        },
        getAppropriateSessionBuilder: function(models){
            var that = this;
            return PromiseUtils.wrappedWithPromise(function(resolve, reject){
                if(!that.app.core.Factories.CollectionsFactory.isInstanceContentModels(models))
                    throw new Error("invalid parameter for buildAppropriateSession ");

                var sessionBuilderId=  models.getAppropriateSessionBuilder();
                if(sessionBuilderId){

                    if(!that.sessionBuilderIds[sessionBuilderId])
                        throw new Error(" sessionBuilderId not valid");

                        localRequire([that.sessionBuilderIds[sessionBuilderId]], function(SessionBuildersClass){

                        resolve(new SessionBuildersClass({
                            appCore: that.app.core,
                            models : models
                        }));

                        }, reject);

                }else{
                    throw new Error("failed to retrieve sessionBuilderId");
                }

            });
        },
        getDefaultSessionBuilder: function(models){
            var that = this;
            return PromiseUtils.wrappedWithPromise(function(resolve, reject){
                localRequire([that.sessionBuilderIds.default], function(SessionBuildersClass){

                    resolve(new SessionBuildersClass({
                        appCore: that.app.core,
                        models : models
                    }));

                }, reject);
            });
        },
        _getColumnsProvidersDefinitions: function(){
            var that = this;
            return  this.app.core.settingManager.getSetting("columnsProviders");
        },
        getColumnsProviderWithMetas: function(providerID){
            var result = this._getColumnsProvidersDefinitions().find(function(prov){
               return  prov.ID === providerID;
            });
            if(result && this.loadedProviders){
                result.instance = this.loadedProviders[providerID];
                return result;

            }
            return null;
        },
        _providerValidateAndRegister: function(provider, ID, resultHolder){
            var that = this;
            return PromiseUtils.wrappedWithPromise(function(resolve, reject){
                provider.isAdditionalColumnsAvailable(function(isAvailable) {
                    if (isAvailable === true) {
                        resultHolder[ID || provider.getName()] = provider;
                    }
                    resolve();
                });
            });
        },
        _loadColumnsProviders: function(){
            var that = this;
            return PromiseUtils.wrappedWithPromise(function(resolve, reject){
                if(that.loadedProviders){
                    return resolve();
                }
               
                Utils.loadFiles(that._getColumnsProvidersDefinitions().map(function(prov){
                    return prov.loader;
                })).then(function(){
                var providers = arguments[0]; 
                var promises = [];
                var result = {};
                for (var i = 0; i < providers.length; i++) {
                    promises.push( that._providerValidateAndRegister(providers[i], that._getColumnsProvidersDefinitions()[i].ID, result) );
                }
                PromiseUtils.allSettled(promises).then(function(){
                    //to avoid race condition
                    that.loadedProviders = result;
                    resolve(true);
                });
               
                }).catch(function(reason){
                    reject(reason);
                })
            });
        }

    });

    return XENUserSessionManager;
});

define('DS/ENOXEngineer/components/IdCard/IdCard',
        [
         'UWA/Class/Model',
         'DS/ENOXIDCard/js/IDCard',
         'DS/ENOXEngineer/utils/Utils',
         'DS/Utilities/Utils',
         'DS/PlatformAPI/PlatformAPI',
         'DS/ENOXEngineer/utils/XEngineerConstants',
         'DS/ENOXEngineerCommonUtils/xEngAlertManager',
         'DS/UIKIT/Tooltip',
         'css!DS/ENOXEngineer/components/IdCard/idCard.css'],//TODO to be remove
         function (
           UWAModel,
           IDCard,
           Utils,
           WebUtils,
           PlatformAPI,
           XEngineerConstants,
           xEngAlertManager,
           Tooltip
          ) {
    var idCardView=function(sandbox){
      var _container=sandbox.getContainer();
      return {
        _refreshSubscription : null,
        start:function(){

          var that=this;
          this._buildUI(sandbox.options.models.getEngineeringItem());


        },
        _buildUI : function(engItem){
          var that=this;
          var pid = sandbox.options.physicalId;

          sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND,{
            commandId: XEngineerConstants.UPDATE_WIDGET_TITLE,
            context: {
                label : engItem.getLabel()
            }
          });
          var getAttributeNLS = {
             "Responsible": sandbox.i18nManager.get("ds6w:responsible"),
             "Maturity State":sandbox.i18nManager.get("ds6w:status"),
             "Part Number": sandbox.i18nManager.get("ds6wg:EnterpriseExtension.V_PartNumber"),
             "Config. context" : sandbox.i18nManager.get("eng.attached.model")

          };

          var description = engItem.getDescription() && engItem.getDescription().length>1 ? engItem.getDescription() : sandbox.i18nManager.get("no_description_text");
          var mdlOptions = {
            name: engItem.getTitleForIdcard(),
            model: null,
            id: pid,
            label: engItem.getTitleForIdcard(),
            version: engItem.getDisplayVersionForIdcard(),
            configuration: engItem.getConfigurationDisplayName(),
            thumbnail:engItem.getThumbnail(),
            modelEvents: sandbox.getApplicationBroker(),
            titleText: engItem.getTitleForIdcard() + engItem.getDisplayVersionForIdcard(),
            withHomeButton: true,    /** Add home button (false by default) */
            // withExpandCollapseButton: true,    /** Add expand / collapse button (false by default) */
            withActionsButton: true,    /** Add actions menu button (true by default) */
            withInformationButton: true,    /** Add information button (false by default) */
            withToggleMinifiedButton: true,
            showBackButton: sandbox.core.viewState.isChildView(),
            freezones: ["<p>"+description+"</p>"],
            attributes: [
                {name: sandbox.i18nManager.get("eng.attached.model"), editable:engItem.getContextDisplayType().indexOf('hyperlink') ===-1 ? false : true,
                 multivalued :true, value: engItem.getPreferedAttachedConfigModel()!==null ? engItem.getPreferedAttachedConfigModel().getCurrentVersionMarketingName() :  sandbox.i18nManager.get("eng.model_placeholder") , type: engItem.getContextDisplayType() },

                {name: sandbox.i18nManager.get("ds6w:responsible"), displayWhenMinified: true, editable:true, value: engItem.getOwner(), type: 'type-hyperlink'},
                {name: sandbox.i18nManager.get("ds6w:status"),  displayWhenMinified: true, editable:true, value: sandbox.i18nManager.get("ds6w:status/"+engItem.getMaturity() ), type: 'type-hyperlink'},
                {name: sandbox.i18nManager.get("ds6w:created"),  value: engItem.getCreatedDate(), type: 'type-text'},
                {name: sandbox.i18nManager.get("ds6w:modified"), displayWhenMinified: true, value: engItem.getModifedDate(), type: 'type-text'},
                {name: sandbox.i18nManager.get("ds6wg:EnterpriseExtension.V_PartNumber"), editable:true, value: engItem.getPartNumber() ||  sandbox.i18nManager.get("None"), type: 'type-hyperlink'},
                ],
            customEvents: {
                homeIconClick: {event: XEngineerConstants.EVENT_IDCARD_CUSTOM_SHOW_LANDING},
                expandCollapseIconClick: {event: XEngineerConstants.EVENT_IDCARD_CUSTOM_WP_TOGGLE_EVENT},
                informationIconClick: {event: XEngineerConstants.EVENT_IDCARD_CUSTOM_INFORMATION_ICON},
                configurationLabelClick: {event: XEngineerConstants.EVENT_IDCARD_CUSTOM_SHOW_CONFIGURATION},
                versionLabelClick: {event: XEngineerConstants.EVENT_IDCARD_CUSTOM_SHOW_VERSION_EXPLORER},
                actionsMenuClick: {event: XEngineerConstants.EVENT_IDCARD_CUSTOM_OPEN_ACTIONS_MENU},
                backIconClick: {event: XEngineerConstants.EVENT_GO_BACK},
            }


          };

          that.myModel = new UWAModel(mdlOptions);

          //TODO to be reviwed
          // Action after part number update
          sandbox.subscribe(XEngineerConstants.EVENT_SET_PARTNUMBER_COMPLETED, function(data){
            if(!data || !Array.isArray(data.references)) return ;//unknown format

            var idx = data.references.findIndex(function(item){
                return item.physicalid === pid;
            });
            if(idx>-1)
              that._refreshIdCardModelUpdate(true);
          });

          sandbox.subscribe(XEngineerConstants.EVENT_UPDATE_IDCARD_RENDERING, function(forceServerSync){
            that._refreshIdCardModelUpdate(forceServerSync);
        });

          that._refreshSubscription = PlatformAPI.subscribe('DS/PADUtils/PADCommandProxy/refresh', function(refresedData){
            var shouldUpdate = false;
            if (refresedData.data.authored && refresedData.data.authored.modified) {
              refresedData.data.authored.modified.forEach(function(itemPid){
                if(pid === itemPid || pid === itemPid.physicalid) {
                    shouldUpdate = true;
                }
              });
              if (shouldUpdate) {
                that._refreshIdCardModelUpdate(true);
              }
            }
          });

          sandbox.emptyContainer();
          that.idcard = new IDCard({
            model : that.myModel
          });

          that.idcard.render().inject(_container);
          that.idcard.attachResizeSensor(); /// take it as option in idcard

          /*
           * managed in IDCard
          new Tooltip({
            target: UWA.extendElement(widget.body).getElement('.xapp-id-card-container .name'),
            trigger: 'hover touch',
            body: mdlOptions.titleText
          });
           */
          sandbox.publish(XEngineerConstants.EVENT_IDCARD_READY);

          sandbox.registerDnDManager({
            sandbox : sandbox,
            container: _container,
            draggable:true,
            getSerializedContent: that.getSerializedContent.bind(that),
            droppable: true,
            dropStrategy:"OPEN",
            onDrop: that.onValidDrop.bind(that)
          });


          var actionButton = _container.querySelector('.xapp-id-card-container .fonticon-open-down');
          sandbox.subscribe(XEngineerConstants.EVENT_IDCARD_CUSTOM_OPEN_ACTIONS_MENU, function(){
            	  sandbox.core.commandManager.renderMenu(actionButton.getBoundingClientRect(), "root");
          });

          sandbox.subscribe(XEngineerConstants.EVENT_SYNC_VIEW_WITH_EI_MODEL, function(){
              that._refreshIdCardModelUpdate();
          });


          sandbox.subscribe(XEngineerConstants.EVENT_IDCARD_CUSTOM_INFORMATION_ICON, function(){
            if(!sandbox.core.isPropertyPanelVisibilty){
              sandbox.publish(XEngineerConstants.EVENT_INFO_PANEL_VISIBLE);
              }
              sandbox.publish(XEngineerConstants.EVENT_TRIPTYCH_TOGGLE_PANEL,'right');

          });

          sandbox.subscribe(XEngineerConstants.EVENT_IDCARD_CUSTOM_SHOW_CONFIGURATION, function(){
            if(engItem.isConfigured() && !engItem.hasValidConfigContext() ){
              xEngAlertManager.errorAlert(sandbox.i18nManager.get("error.detachOrAddVersion.toModel"));
              return ;
            }
            engItem.launchFilteringCommand();

          });


          //sandbox.subscribe("onSetPartNumberComplete", function(data){
          //console.log("data");
          //});

          sandbox.subscribe(XEngineerConstants.EVENT_IDCARD_ATTRIBUTES_CLICKED, WebUtils.debounce(function(attr) {
             switch(attr.attributeName){
              case getAttributeNLS["Responsible"]:
               sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                commandId: XEngineerConstants.CHANGE_OWNER_CMD,
                context: {
                    item : engItem
                }
              });
              break;
            case getAttributeNLS["Maturity State"]:
            sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                 commandId: XEngineerConstants.MATURITY_GRAPH_CMD,
                 context: {
                     item : engItem
                 }
             });
             break;
            case getAttributeNLS["Part Number"]:
            sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                  commandId: XEngineerConstants.SET_PART_NUMBER_CMD,
                  context: {
                      item : engItem
                  }
              });
              break;
           case getAttributeNLS["Config. context"]:
           sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
               commandId: XEngineerConstants.EDIT_CONF_CONTEXT_CMD,
               context: {
                   item : engItem
               }
           });
           break;

              }

          },10));

          sandbox.subscribe(XEngineerConstants.EVENT_IDCARD_CUSTOM_SHOW_VERSION_EXPLORER, function(){
              if(engItem.isConfigured() && !engItem.hasValidConfigContext() ){
                xEngAlertManager.errorAlert(sandbox.i18nManager.get("error.detachOrAddVersion.toModel"));
                return ;
              }
                sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                    commandId: XEngineerConstants.VERSION_GRAPH_CMD,
                    context: {
                        item : engItem
                    }
                });
          });

          that.freezoneTooltip = new Tooltip({
            target: _container.getElement('.lower-main-section').getChildren()[1],
            trigger: 'hover touch',
            body: engItem.getDescription()
         });



        },
        getSerializedContent: function(){
          var engItem =  (sandbox && sandbox.options && sandbox.options.models) ?  sandbox.options.models.getEngineeringItem() : null;

          return engItem ? Utils.prepareDragData([engItem]) : "";
        },
        onValidDrop : function(valids){

          if(Array.isArray(valids) && valids.length>0){
            var physicalId = valids[0].objectId;
            //if it is a filter
            if(sandbox.options.physicalId !== physicalId){
              sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND,{
                commandId: XEngineerConstants.OPEN_ENG_ITEM,
                context: {
                    item: {
                      objectId: valids[0].objectId,
                      objectType: valids[0].objectType
                    }
                  }
              });
           }else{//IR-642558-3DEXPERIENCER2018x in this case it will be a simple refresh
             sandbox.publish(XEngineerConstants.EVENT_REFRESH_APP_CONTENT);
             xEngAlertManager.notifyAlert(sandbox.i18nManager.get("eng.ui.refreshing.engItem"));
           }

          }
          },

        _refreshIdCardModelUpdate : function(withFetch){
          var that = this;
          if(withFetch){
            sandbox.options.models.getEngineeringItem().syncModel().then(function(){
              that._applyUpdateFromEngItem(sandbox.options.models.getEngineeringItem());
            }).catch(function(reason){
              console.error(reason);
            });
          }else{
            that._applyUpdateFromEngItem(sandbox.options.models.getEngineeringItem());
          }



        },
        _applyUpdateFromEngItem : function(updatedEngItem){
          var that = this;
          sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND,{
            commandId: XEngineerConstants.UPDATE_WIDGET_TITLE,
            context: {
                label : updatedEngItem.getTitleForIdcard()
            }
          });

          that.myModel.set('name',updatedEngItem.getTitleForIdcard());
          that.myModel.set('label',updatedEngItem.getTitleForIdcard());
          that.myModel.set('version',updatedEngItem.getDisplayVersionForIdcard());
          that.myModel.set('configuration', updatedEngItem.getConfigurationDisplayName());
          that.myModel.set('thumbnail',updatedEngItem.getThumbnail());
          var desc = updatedEngItem.getDescription() && updatedEngItem.getDescription().length>1 ? updatedEngItem.getDescription() : sandbox.i18nManager.get("no_description_text");
          that.myModel.set('freezones',["<p>"+desc+"</p>"]);

          var updatedAttr =  [
              {name: sandbox.i18nManager.get("eng.attached.model"), value: updatedEngItem.getPreferedAttachedConfigModel()!==null ? updatedEngItem.getPreferedAttachedConfigModel().getCurrentVersionMarketingName() :  sandbox.i18nManager.get("eng.model_placeholder") ,
               editable: true,multivalued :true,  type: updatedEngItem.getContextDisplayType()},

              {name: sandbox.i18nManager.get("ds6w:responsible"), displayWhenMinified: true, value: updatedEngItem.getOwner(), editable: true, type: 'type-hyperlink'},
              {name: sandbox.i18nManager.get("ds6w:status"), displayWhenMinified: true, value: sandbox.i18nManager.get("ds6w:status/"+updatedEngItem.getMaturity() ), editable: true, type: 'type-hyperlink'},
              {name: sandbox.i18nManager.get("ds6w:created"), value: updatedEngItem.getCreatedDate(), type: 'type-text'},
              {name: sandbox.i18nManager.get("ds6w:modified"), displayWhenMinified: true, value: updatedEngItem.getModifedDate(), type: 'type-text'},
              {name: sandbox.i18nManager.get("ds6wg:EnterpriseExtension.V_PartNumber"), value: updatedEngItem.getPartNumber() || sandbox.i18nManager.get("None"), editable: true, type: 'type-hyperlink'},
            ];
          that.myModel.set('attributes',updatedAttr);
          that.freezoneTooltip.setBody(updatedEngItem.getDescription());
        },
        stop:function(){
          PlatformAPI.unsubscribe(this._refreshSubscription);

          this.idcard && this.idcard.destroy();
          sandbox.emptyContainer();
          sandbox.publish(XEngineerConstants.EVENT_SET_ACTIVE_ENG_ITEM, null);
          sandbox.stop(this);
        }
      }
    }

    return idCardView;
});

define('DS/ENOXEngineer/services/XEngContextManager', [
  'UWA/Core',
  'UWA/Class',
  'DS/ENOXEngineerCommonUtils/XENMask',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/ResponseParser',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json',
], function(UWA, Class, Mask, xEngAlertManager, XEngineerConstants, Utils, ResponseParser, nlsKeys) {

    'use strict';


    var XEngContextManager = Class.singleton(
    {
      _selectedItems : [],
      _is_XENG_widget : true,
      _isMultiSelectMode : false,
      _currentCommandContext: null,
      _app: null,
      _activeEngItem :null,
      dragStartedInXENG:false,
      _expectSingleCreation: false,
      _modelsRawData : null,
      _currentRunningCmd : null,
      name : 'pad_component',
      _activeList:null,
      _viewContext : {},
      _postProcess: false,
      elements:{},
      initialize:function(xEngApp){
        this._app = xEngApp;
        xEngApp.core.contextManager = this;
        var that = this;
        this._XENContentProxy = xEngApp.core.Factories.CollectionsFactory.getXENProxyContentTreeDocument();
        this._app.mediator.subscribe(XEngineerConstants.EVENT_RESET_SELECTION, function(){
                that.resetSelection();
        });
      },
        init: function(options) {
            this._parent(options);
        },
        getXENTreeDocument: function(){
          return this._XENContentProxy;
        },
        setExpectSingleCreation: function(new_val){
          this._expectSingleCreation = new_val;
        },
        expectSingleCreation: function(){
          return this._expectSingleCreation;
        },
        /**
         * use by recent and myengitem page
         */
        setActiveDocument: function(_newDocument){
          this._activeDocument = _newDocument;
        },
        // used for copy/paste effectivity only (implemetation from the IP team)
        withTransactionUpdate : function (updates) {
          if(this.getActiveEngItem() && this.getActiveEngItem().getContentModels())
          {
            return this.getActiveEngItem().getContentModels().withTransactionUpdate(updates);
          }
        },
        getActiveDocument: function(){
          return this._activeDocument;
        },
        getActiveEngItem : function(){
          return this._activeEngItem;
        },
        setActiveEngItem : function(newEngItem){
          this._activeEngItem = newEngItem;
        },
        getNodesById: function(nodeId) {
          return (this.getXENTreeDocument()) ? this.getXENTreeDocument().getNodesById(nodeId) : [];
        },
        getContext : function(){
          var that = this;
          return that;
        },
        get : function(){
          return this;
        },
        getEditMode : function(){
          return true;
        },
        getAvailableAttributes : function(types){
        return(this.getActiveEngItem())? this.getActiveEngItem().getContentModels().getAvailableAttributes(types) : [];
        },
        updateSelectedNodesEffectivities: function(columns){
          this._app.mediator.publish(XEngineerConstants.EVENT_UPDATE_NODES_EFFECTIVITIES, {
            nodes: this.getSelectedNodes(),
            columns: columns
          });
        },
        getSecurityContext : function () {
          var that = this;
          return {
            SecurityContext : "ctx::"+ that._app.core.settingManager.getSecurityContext(),
            tenant : that._app.core.settingManager.getPlatformId()
          }
        },
        /***
         return {
            rootId: '', //engItem id
            filteringContext:' evolution OR prodConf OR nextGenFilter OR none',
            filterData:{ //null if filteringContext===none
                filterId: 'versionId | prodConfId | presistedNGFilter | undefined (for transient filter)',
                label: 'filterName | versionName | prodConfName ',
                filterBinary:'form evolution OR prodconf (not supported for evolution)',
                CVQuery: 'for nextGenFilter context'
            }
          }
        ***/
        getActiveEngItemOpenContext: function(){
           return (this.getActiveEngItem()) ? this._app.core.sessionManager.getCurrentOpenContext() : null;
        },
        getPreferredConfigModel : function(){
          var engItem = this.getActiveEngItem();
          if(engItem.isConfigured() && engItem.getPreferedAttachedConfigModel() &&  engItem.getPreferedAttachedConfigModel().getID()){
            return [{
              physicalID : engItem.getPreferedAttachedConfigModel().getID()
            }];
          }else if(engItem.isConfigured() && engItem.getAttachedConfigModels() && engItem.getAttachedConfigModels().length > 0){
            return engItem.getAttachedConfigModels().map(function(model){
              return model.getID();
            });
          }
          return null;
        },
        refreshView : function(options){
        	var that = this;
        	if(options.created){
            // not used now
        		// if (options.created.length > 0){
        		// 	this._app.mediator.publish( XEngineerConstants.EVENT_NEW_ENG_ITEM_CREATED , options.created[0]);
        		// }

        	}else if(options.deleted){

        	} else if (options.modified) {

        	}
        },
        getChildren : function(parentNode){

        if (this.getActiveEngItem() && this.getActiveEngItem().getID() === parentNode.getID() ) {
            var contentTree = this.getActiveEngItem().getContentModels();

            var allChildren = contentTree ? contentTree.getChildrenWithoutGroupingNodes() : null;
            return Array.isArray(allChildren) ? allChildren.filter(function(child){
              return !child.isDocument();
            }) :[];
        }
        return [];
      },
      getOrdering : function(){
          return {};
        },

        insertNodes : function(options){
           var that =this;
          if (options.created) {
            var createdObj = ResponseParser.attributesParser(options.created[0].attributes);
            this._app.mediator.publish( XEngineerConstants.EVENT_NEW_ENG_ITEM_CREATED , createdObj );
          }else if (options.inserted) {
            var instanceNamePromise =  that._app.core.dataService.fetchInstanceData([options.inserted[0].children[0].relationid]);
            var nodesPromise = this._app.core.Factories.ListItemFactory.getNlsedListNodes([options.inserted[0].children[0].attributes]);
            nodesPromise.then(function(nodes){
                        var listNode = nodes[0];
                        listNode.options.instanceId =  options.inserted[0].children[0].relationid;
                        if (!listNode.getThumbnail().startsWith("http")) {
                          listNode.options.thumbnail = that._app.core.Factories.ListItemFactory.getDefaultProductThumbnail()
                        }
                        var result = {
                          nodes : [listNode],
                          parentId : options.inserted[0].parent_id,
                          postProcess : that._postProcess
                        }
                        that._app.mediator.publish(XEngineerConstants.EVENT_NEW_INSERTED_ENG_ITEM, result);
                        instanceNamePromise.then(function(instancesName){
                          listNode.options.instanceName = instancesName[0].name;
                          that._app.mediator.publish(XEngineerConstants.EVENT_REFRESH_LISTVIEW);
                        });

                      });
          }else if (Array.isArray(options.insertedV2)) {
            var that = this;
            that._app.core.dataService.getListNodesFromEngItemsAndInstanceIds(options.insertedV2.filter(function(mapping){
              return (mapping.parentId === that.getActiveEngItem().getID()) && mapping.instance && mapping.isInstanceOf;
            })).then(function(nodes) {
              if(Array.isArray(nodes))
                that.getActiveEngItem().getContentModels().withTransactionUpdate(function(){
                  that._app.mediator.publish(XEngineerConstants.EVENT_NEW_INSERTED_ENG_ITEM,{
                    nodes : nodes,
                    parentId : that.getActiveEngItem().getID()
                });
                });
            });
          }

        },
        getpreferredCAD: function() {
           return (!this.isRunningCmd(XEngineerConstants.CREATE_NEW_PART) && widget.getValue('CADAuthoring') === 'false') ? "3DExperience" : null;
        },
        setCurrentRunningCmd: function(cmd) {
           this._currentRunningCmd = cmd;
        },
        isRunningCmd : function (cmdName) {
           return (this._currentRunningCmd === cmdName) ? true : false;
        },
        author : function(bool){
          this._app.core.sessionManager.setAuthoringMode('authoring');
          return true;
        },
        getSelectedNodes : function(){
          if (this._selectedItems && this._selectedItems.length ===0 && this.getActiveEngItem() !=null) {
            return [this.getActiveEngItem()];
          }
          return this._selectedItems;
        },

        resetSelection : function(){
          this._selectedItems = [];
        },
        addSelection: function(items,reset){
          (true) ? this._selectedItems = [] : null;
          var that = this;

          if (UWA.is(items,'array')) {
            items.forEach(function(item){
              that._selectedItems.push(item);
            })
          }else {
            this._selectedItems.push(items);
          }

        },
        setViewContext : function(view, options){
          if(typeof view ==="string" && view != "") {
            this._viewContext.viewName = view;
          }
          this._viewContext.options = options;
        },
        getViewContext : function(){
          return this._viewContext;
        },
        modalChooser : function(options) {
          var that  = this;
          this._app.core.dataService.searchManager.launchASearch({
            title: this._app.core.i18nManager.get("eng.searchResult.InsertEngItem"),
        	  allowedTypes:['VPMReference'],
            role : '',
            criteria : '',
            in_apps_callback : options.in_apps_callback
          });


        },
        beginBlockingTransaction: function(cmd_name) {
           Mask.mask(document.body, cmd_name);
       },
       //for catia commands
       isThereARootSelected: function(){
         var selectedNodes =this.getSelectedNodes();
         for (var i = 0; i < selectedNodes.length; i++) {
           if (selectedNodes[i] === this.getActiveEngItem()) {
             return true;
           }
         }
         return false;
       },

       //@for catia commands
       getInstance : function(node){
         return node.getID();
       },
       /***@ for catia commands*/
       getRelationID : function(node){
    	   if (typeof node.getRelationID === "function"){
    		   return node.getRelationID();
    	   } else {
    		   return "";
    	   }
       },
       getReference :function(node){
         return node.getID();
       },
       getParent : function(node){
         return node.getParent();
       },
       getRoot : function(node){
         return this.getActiveEngItem();
       },
       getRoots :function(){
         return this.getActiveEngItem();
       },
       getType : function(node){
         return node.getType();
       },
       getName : function(node){
         return (node) ? node.getLabel() : null;
       },
      canInstantiate: function(futureParentID, futureChildrenID, errorMsg){
        for (var i = 0; i < futureChildrenID.length; i++) {
          if (futureChildrenID[i] === futureParentID) {
            xEngAlertManager.errorAlert(nlsKeys.replace(nlsKeys.get("error.operation.failed"),{
                    operation:'Insert existing ',
                    error: errorMsg
                  }));
            return false;
          }
        }
        return true;
      },
       refresh : function(options){

    	   if (!options) return;

         if (options.action === "replace") {
           var ops = Array.isArray(options.operations) ? options.operations : [];
           var that = this;
           ops.forEach(function (replaceDetail) {
            var eventPayload = {
              parentId : replaceDetail.parent,
              replacedId : replaceDetail.old,
              new : replaceDetail.new
            };
            that._app.mediator.publish(XEngineerConstants.EVENT_REPLACED_ENG_ITEM,eventPayload);
           });

         } else if (options.action === "unparent") {
           var eventPayload = {
             instances : options.instances
           };
           this._app.mediator.publish(XEngineerConstants.EVENT_REMOVED_INSTANCE,eventPayload);
         }else if (options.action === "insert") {
           var that = this;
           var instaceRefMap = [];

           for (var i = 0; i < options.instances.length; i++) {
             instaceRefMap.push({
               instance : options.instances[i],
               isInstanceOf : options.references[i]
             });
           }

           this._app.core.dataService.getListNodesFromEngItemsAndInstanceIds(instaceRefMap)
                                .then(function(listNodes){
                                  var result = {
                                    nodes : listNodes,
                                    parentId : options.parent
                                  }
                                  that._app.mediator.publish(XEngineerConstants.EVENT_NEW_INSERTED_ENG_ITEM, result);
                                })
                                .catch(function(error){ console.error(error);});

         }


       },
       addRoot : function(inputs, callback, broadcast){ },
       getSetting : function(setting){
         var ret = null, that = this;
         switch (setting) {
           case 'tenant':
             ret = that._app.core.settingManager.getPlatformId();
           break;

           case 'lang':
             ret = that._app.core.settingManager.getLanguage();
           break;

           case 'securityContext':
             ret = that._app.core.settingManager.getSecurityContext();
           break;
           default:
         }
         return ret;

       },

       endBlockingTransaction: function() {
           Mask.unmask(document.body);
       },
       /**
       * function displayNotification is a callback handler used in the case of command "DS/UPSCommands/commands/UPSAuthCmdRevisionUpdate".
       */
        displayNotification : function(reasons) {
          if(reasons.eventID === "error"){
            xEngAlertManager.errorAlert(nlsKeys.replace(nlsKeys.get("error.operation.failed"),{
                    operation:'Replace by latest revision',
                    error: reasons.msg || reasons
                  }));
          } else if(reasons.eventID === "warning") {
            xEngAlertManager.warningAlert(nlsKeys.replace(nlsKeys.get("error.operation.failed"),{
                    operation:'Replace by latest revision',
                    error: reasons.msg || reasons
                  }));
          } else {
            xEngAlertManager.sucessAlert(nlsKeys.replace(nlsKeys.get("error.operation.failed"),{
                    operation:'Replace by latest revision',
                    error: reasons.msg || reasons
                  }));
          }

        },
        getSelectedRoots:function(){
        	return [];
        }


    });

    return XEngContextManager;
});

define('DS/ENOXEngineer/commands/EditVariantEffectivityCmd', [
  'DS/CfgEffectivityCommands/commands/CfgVariantEffectivityCmd',
  'DS/ENOXEngineer/services/XEngContextManager'
], function (
  CfgVariantEffectivityCmd,
  xEngContext
) {

  'use strict';


  var EditVariantEffectivityCmd = CfgVariantEffectivityCmd.extend({
    init: function(_options){
      var options = _options ? _options : {};
      options.postOKHandler = this.updateSelectedNodesEffectivities.bind(this);
      this._parent(options, {
        mode: 'exclusive',
        isAsynchronous:  true
    });
    },
    updateSelectedNodesEffectivities: function(response){
      xEngContext.updateSelectedNodesEffectivities(['VariantEffectivity']);
    },
    getData: function () {
      var selectedNodes = xEngContext.getSelectedNodes();
      var firstNode = selectedNodes[0];
      if(!firstNode ||  typeof firstNode.getRelationID !== "function") return null;
      this.end();
      var data = {
        "selectedNodes": [{
          id: firstNode.getRelationID(),
          alias: firstNode.getLabel(),
          isRoot: false,
          VPMRef: firstNode.getType(),
          parentID: firstNode.getTreeDocument().getEngineeringItem().getID(),
          parentalias: firstNode.getTreeDocument().getEngineeringItem().getLabel()
        }],
        "nodes": firstNode
      };
      return data;
    }

  });


  return EditVariantEffectivityCmd;

});

define('DS/ENOXEngineer/commands/PasteVariantEffectivityCmd', [
  'DS/CfgEffectivityCommands/commands/CfgPasteEffectivityCmd',
  'DS/ENOXEngineer/services/XEngContextManager'
], function (
  CfgPasteEffectivityCmd,
  xEngContext
) {

  'use strict';

  var pasteVariantEffectivityCmd = CfgPasteEffectivityCmd.extend({
    getData: function () {
      var selectedNodes = xEngContext.getSelectedNodes();
      var firstNode = selectedNodes[0];
      this.end();
      var data = {
        "selectedNodes": [{
          id: firstNode.getRelationID(),
          alias: firstNode.getLabel(),
          isRoot: false,
          VPMRef: firstNode.getType(),
          parentID: firstNode.getTreeDocument().getEngineeringItem().getID(),
          parentalias: firstNode.getTreeDocument().getEngineeringItem().getLabel()
        }],
        "nodes": firstNode,
        "padNodes" : [ firstNode ]
      };
      return data;
    }

  });
  return pasteVariantEffectivityCmd;

});

define('DS/ENOXEngineer/commands/CopyVariantEffectivityCmd', [
  'DS/CfgEffectivityCommands/commands/CfgCopyEffectivityCmd',
  'DS/ENOXEngineer/services/XEngContextManager'
], function (
  CfgCopyEffectivityCmd,
  xEngContext
) {

  'use strict';

  var copyVariantEffectivityCmd = CfgCopyEffectivityCmd.extend({
    getData: function () {
      var selectedNodes = xEngContext.getSelectedNodes();
      var firstNode = selectedNodes[0];
      this.end();
      var data = {
        "selectedNodes": [{
          id: firstNode.getRelationID(),
          alias: firstNode.getLabel(),
          isRoot: false,
          VPMRef: firstNode.getType(),
          parentID: firstNode.getTreeDocument().getEngineeringItem().getID(),
          parentalias: firstNode.getTreeDocument().getEngineeringItem().getLabel()
        }],
        "nodes": firstNode
      };
      return data;
    }

  });
  return copyVariantEffectivityCmd;

});

define('DS/ENOXEngineer/commands/XEngineerCutCopyPaste', [
  'UWA/Class',
  'DS/ApplicationFrame/Command',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/PlatformAPI/PlatformAPI',
  'DS/ENOXEngineer/services/XEngLocalStorage',
  'DS/ENOXEngineer/services/XEngContextManager',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(
  Class,
  AFRCommand,
  xEngAlertManager,
  XEngineerConstants,
  PlatformAPI,
  XEngLocalStorage,
  XEngContextManager,
  nlsKeys
) {

    'use strict';

    var XEngineerCutCopyPaste =  AFRCommand.extend({
      init: function(options) {
        this._parent(options);
        console.info("#XEngineerCutCopyPaste: initialized...");
      },
      execute: function(params) {
        var that = this;

        if(that.options.ID === 'UPSAuthCut') {
          this.cutEngItem(that.options.context);
        } else if(that.options.ID === 'UPSAuthCopy'){
          this.copyEngItem(that.options.context);
        } else if(that.options.ID === 'UPSAuthPaste'){
          this.pasteEngItems(that.options.context);
        }
        console.info("#XEngineerCutCopyPaste: "+that.options.ID +" execute called");
      },
      cutEngItem: function(context){
        var clipItems = ["CX"];
        this._setItemsInClipboard(context, clipItems);
      },
      copyEngItem: function(context){
        var clipItems = ["CP"];
        this._setItemsInClipboard(context, clipItems);
      },
      pasteEngItems: function(context) {
        //XEngLocalStorage items contains: "clipboard":"CX,A0CE1F3D015FF6A204090A59CEA7AA77|2F5A9912015FEC5404090A59CEA7AA77|9A9E9CC7015FFFAA04090A59CEA7AA77"
        var pastables = XEngLocalStorage.getItem('clipboard');
        if(!pastables || pastables.length == 0) {
            xEngAlertManager.errorAlert(nlsKeys.get('clipboard_empty'));
            return;
        }

        var pasteMode = pastables.startsWith("CX") ? "CutPaste" : "CopyPaste";
            pastables = pastables.substring(3);

        var childrenData = [];
        var pastableData = [];
        var children = pastables.split(',');
        for(var idx = 0; idx < children.length; idx++){
      	  pastableData.push(children[idx].split('|'));
        }

        for (var i=0; i<pastableData.length ; i++){
      	  var pastable = pastableData[i];
      	  childrenData.push(pastable);
        }

        var instanceIds = childrenData.map(function(el){
          if(Array.isArray(el) && el.length > 2) return el[1];
          return null;
        }).filter(function(elm){
          return elm !== null;
        });

        if(pastableData[0] == "") {
          XEngLocalStorage.removeItem('clipboard');
          xEngAlertManager.errorAlert(nlsKeys.get('clipboard_empty'));
          return;
        }

        var pasteData = {
          children: childrenData,
          parents: [[context.getActiveEngItem().getID()]],
          mode: pasteMode,
          commit: true
        };

        //API responsible: cui, hqo
        require(['DS/UPSCommands/commands/UPSAuthCmdCutCopyPaste'], function(UPSAuthCmdCutCopyPaste) {
          var pasteFn = new UPSAuthCmdCutCopyPaste({
            context: XEngContextManager.getContext(),
            ID: "InsertExisting"
          });
          pasteFn.execute({
              'mode': pasteMode,
              'internal_call': true,
              'data': pasteData,
              'onSuccess': function(successData){
                              if(pasteMode === "CutPaste") {
                                PlatformAPI.publish(XEngineerConstants.EVENT_REMOVE_CUT_INSTANCES, instanceIds);
                                XEngLocalStorage.removeItem('clipboard');
                              }
                              if(Array.isArray(successData)){

                                context.insertNodes({
                                  insertedV2: successData.map(function(item){
                                     return {
                                      instance: item.relationid,
                                      isInstanceOf: item.resourceid,
                                      parentId: item.hasParent
                                    }
                                  })
                                });
                              }
                              //we loss the selection
                              // PlatformAPI.publish(XEngineerConstants.EVENT_REFRESH_WIDGETS);
                            },
              'onFailure': function(error){
                              console.warn("Error trace:" + error.messages.toString());
                              xEngAlertManager.errorAlert(nlsKeys.get('paste_error'));
                            }
          });

        });

      },
      _setItemsInClipboard: function(context, clipItems) {
        var items = context.getSelectedNodes();
        var parentID = context.getActiveEngItem().getID();

        if(Array.isArray(items)) {
          var unSupportedItemsCnt = 0;
          for (var idx = 0; idx < items.length; idx++) {
            if(items[idx].getType() == "VPMReference") {
              clipItems.push(parentID+"|"+items[idx].getRelationID()+"|"+items[idx].getID());
            } else {
              unSupportedItemsCnt++;
              //PlatformAPI.publish(XEngineerConstants.EVENT_CLEAR_WIDGETS_CLIPBOARD);
              //xEngAlertManager.errorAlert(nlsKeys.get('paste_error'));
            }

          }
          if(unSupportedItemsCnt > 0) {
            xEngAlertManager.errorAlert(nlsKeys.get('eng.operation.ccp.unSupportedOperation'));
          }
        } else {
          clipItems.push(items.getParent().getID()+"|"+items.getRelationID()+"|"+items.getID());
        }
        PlatformAPI.publish(XEngineerConstants.ADD_TO_CLIPBOARD, clipItems.toString());
      }
    });
    return XEngineerCutCopyPaste;

});

define('DS/ENOXEngineer/commands/XenNextGenFilterCmd', [
    'DS/ENONextGenFilterCmd/commands/ENONextGenFilterCmd',
    'DS/ENOXEngineer/services/XEngContextManager',
    'DS/ENOXEngineer/utils/Utils',
    'DS/ENOXEngineer/utils/XEngineerConstants'
], function (
    FilterCmd,
    XEngContextManager,
    Utils,
    XEngineerConstants
) {

        'use strict';

        var XENFilterCmd = FilterCmd.extend({

            init: function (options) {
                var that = this;
                this.name = name;
                this.appCore = options.appCore;

                if (options.context === null)
                    this.context = XEngContextManager.getContext();
                else {
                    this.context = options.context;
                }

                this._parent(options);

                that.context.getXENTreeDocument().getModelEvents().subscribe({
                    event: 'empty'
                }, function (params) {
                    var currentEngItem = that.appCore.contextManager.getActiveEngItem();
                    if (UWA.is(that.removeFilter, 'function') && currentEngItem && UWA.is(currentEngItem.getID, 'function')) {
                        if(that.context.getXENTreeDocument().getXENBIFilterProxy()){
                            that.context.getXENTreeDocument().getXENBIFilterProxy().resetNGFilterUI({
                                widgetId : that.appCore.settingManager.getWidgetId(),
                                rootIds: [currentEngItem.getID()]
                              });
                        }
                    }
                });
            },
            getWidgetId: function() {
                return this.options.appCore.settingManager.getWidgetId();
            },
            getAppParams: function () {
                var that = this;
                return {
                    widgetId: that.getWidgetId(),
                    appId: that.options.appCore.settingManager.getAppId()
                };
            },
            getSelectorManager: function () {
                return this.context.getXENTreeDocument().getXSO() || null;
            },
            getRoots: function(){
                var selection = [];
                if(this.appCore.contextManager.getActiveEngItem()) {
                  selection = [this.appCore.contextManager.getActiveEngItem()];
                }
                return selection.map(function(root){
                    return {
                        id: root.getID(),
                        filtered :0,
                        Label: root.getLabel()
                    }
                });
            },
            getSelection: function(){
                var converted = {
                    path: [],
                    label: []
                  };
                  var selection = [];
                  if(this.appCore.contextManager.getActiveEngItem()) {
                    selection = [this.appCore.contextManager.getActiveEngItem()];
                  }
                  selection.forEach(function(item){
                    converted.path.push([item.getID()]);
                    converted.label.push([item.getLabel()]);
                });
                return converted;
            }

        });

        return XENFilterCmd;

    });

define('DS/ENOXEngineer/commands/ENOXCfgEvolutionCmd', [
  'DS/CfgEffectivityCommands/commands/CfgEvolutionCmd',
  'DS/ENOXEngineer/services/XEngContextManager'
], function(
  CfgEvolutionCmd,
  xEngContext
) {
  'use strict';

  var CfgEvolutionCmd = CfgEvolutionCmd.extend({
    init: function(_options){
      var options = _options ? _options : {};
      options.postCloseHandler  = this.updateSelectedNodesEffectivities.bind(this);
      this._parent(options, {
        mode: 'exclusive',
        isAsynchronous:  true
    });
    },
    updateSelectedNodesEffectivities: function(resp1,resp2){
      
      xEngContext.updateSelectedNodesEffectivities(['CurrentEvolutionEffectivity']);
    },
    getData: function () {
      var selectedNodes = xEngContext.getSelectedNodes();
      var firstNode = selectedNodes[0];
      var data = {
        "selectedNodes": [{
          id: firstNode.getRelationID(),
          alias: firstNode.getLabel(),
          isRoot: false,
          VPMRef: firstNode.getType(),
          parentID: firstNode.getTreeDocument().getEngineeringItem().getID(),
          parentalias: firstNode.getTreeDocument().getEngineeringItem().getLabel()
        }],
        "nodes": firstNode
      };
      return data;
    }

  });

  return CfgEvolutionCmd;
});

define('DS/ENOXEngineer/commands/XEngineerCommandBase', [
  'DS/ApplicationFrame/Command',
  'DS/ENOXEngineer/services/XEngContextManager',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager'
], function(
  AFRCommand,
  XEngContextManager,
  xEngAlertManager
) {

    'use strict';

    var XEngineerCommandBase =  AFRCommand.extend({
      init: function(options, name){

                this.name = name;
                this.appCore = options.appCore;
                this.alertManager = xEngAlertManager;

                // set default if not supplied
                options = options ||
                    {
                        ID: 'NO_ID'
                    };

                if (options.context === null)
                    this.context = XEngContextManager.getContext();
                else
                {
                    this.context = options.context;
                }

                this._parent(options, {
                    mode: 'exclusive',
                    isAsynchronous: UWA.is(options.isAsynchronous) ? options.isAsynchronous : true
                });
      },
      endExecute: function () {
        console.error("end of command execution");
      },
      execute : function(selectedNode){
        
      }
    });

    return XEngineerCommandBase;

});

define('DS/ENOXEngineer/commands/RelatedObjectsCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'UWA/Utils/InterCom',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineer/utils/Utils'
], function(
  XEngineerCommandBase,
  InterCom,
  XEngineerConstants,
  Utils
) {
  'use strict';
  var RelatedObjectsView = XEngineerCommandBase.extend({
    init: function(options) {
      this._parent(options);
      console.log("#RelatedObjectsCmd: init called");
    },

    execute: function(params) {
      var that = this;
      
      console.log("#RelatedObjectsCmd: execute called");
            var selectedItems = that.context.getSelectedNodes();
            var selectedItem = null;
            if(selectedItems.length >= 1){
            selectedItem = selectedItems[0];
            var physicalid = selectedItem.getID();                                
            var type = selectedItem.getType();
            var name = selectedItem.getDisplayName();

            var objectIds = [];
            objectIds.push({
            envId: that.appCore.settingManager.getPlatformId(),
            serviceId: XEngineerConstants.SERVICE_3DSPACE_NAME,
            contextId: that.appCore.settingManager.getSecurityContext(),
            objectId: physicalid,
            objectType: type,
            displayName: name
            });
            var contentObj = {
            protocol: XEngineerConstants.NAME_3DXCONTEXT,
            version: "1.0",
            source: XEngineerConstants.XENGINEER_APP_NAME,
            data: {
            items: objectIds
            }
            };

            var contentObj1 = {
            protocol: XEngineerConstants.NAME_3DXCONTEXT,
            version: "1.0",
            source: XEngineerConstants.XENGINEER_APP_NAME,
            appId: XEngineerConstants.ENORIPE_APP_NAME,
            data: {
            items: objectIds
            }
            };
            
            // Set the X3DContent that the CompareWidget will use
            var compassPageSocket = new InterCom.Socket('compassPageSocket');
            compassPageSocket.subscribeServer('com.ds.compass', window.parent);
            compassPageSocket.dispatchEvent('onSetX3DContent', contentObj, 'compassPageSocket');
            var data = contentObj.data;
            compassPageSocket.addListener('launchApp', function(data) {
            var uuid = selectedItem.getUuid();
            var event = Utils.createEvent(uuid, data);
            that.appCore.mediator.publishPlatformEvent(XEngineerConstants.CROSS_APP_SELECTION_EVENT,event);
            console.log('Response = ' + JSON.stringify(data));
            });
            compassPageSocket.dispatchEvent('onLaunchApp', contentObj1/*{appId: XEngineerConstants.ENORIPE_APP_NAME}*/, 'compassPageSocket');
            }
            that.end();
    },
  });
  return RelatedObjectsView;
});

define('DS/ENOXEngineer/commands/UpdateWidgetTitleCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase'
], function(
  XEngCommandBase
) {

    'use strict';

    var UpdateWidgetTitleCmd =  XEngCommandBase.extend({

      init: function(options){
        options = UWA.extend(options, {isAsynchronous : false});
        this._parent(options);
      },
      execute : function(){
        var that = this;
        var obj = this.context.getActiveEngItem();
        if (obj && UWA.is(obj.getLabel,'function')) {
          widget.setTitle(that.appCore.i18nManager.replace(that.appCore.i18nManager.get("item_view_title"), {
            objectName: obj.getLabel()
          }) + that.appCore.settingManager.getAppConfigLabel(true));
          return ;
        }
        widget.setTitle(""+that.appCore.settingManager.getAppConfigLabel());
      }
    });

    return UpdateWidgetTitleCmd;

});

define('DS/ENOXEngineer/commands/ChangeQuantityCmd',
[
	'UWA/Class', 
	'DS/ENOXEngineer/commands/XEngineerCommandBase',
	'DS/UIKIT/Modal', 
	'DS/UIKIT/Input/Number', 
	'UWA/Class/View',
	'DS/ENOXEngineerInfra/ENOXEngineerCore',
	'DS/ENOXEngineer/utils/XEngineerConstants',
	'DS/ENOXEngineer/services/XEngContextManager',
	'DS/CollectionView/ResponsiveTilesCollectionView',
	'DS/Tree/TreeDocument', 
	'DS/UIKIT/Input/Toggle',
	'DS/UIKIT/Input/Button',
	'DS/UIKIT/Scroller'],
	
function(Class, XEngineerCommandBase, Modal, Number, UWAView,
		ENOXEngineerCore, XEngineerConstants, XEngContextManager,
		ResponsiveTilesCollectionView, TreeDocument, Toggle, Button, Scroller) {
	'use strict';
	var _chgQtyDlgView = null;
	var _numberboxElement = null;
	var _nodes = [];
	var _group = null;
	var _currentQuantity = null;
	var _confirmationText = null;
	var parent = null;
	var ChangeQuantity = XEngineerCommandBase.extend({
		
		init : function(options) {
			this._parent(options);
			console.warn("#ChangeQuantity: init called");
		},

		execute : function(params) {
			var that = this;
			console.warn("#ChangeQuantity: execute called");
			var selectedItems = this.options.context.getSelectedNodes();
			var selectedItem = null;
			if (selectedItems.length >= 1) {
				selectedItem = selectedItems[0];
			}
			parent = that.options.context.getActiveEngItem();
			
			_group = parent.getContentModels().buildReferenceList(selectedItem);
			_currentQuantity = _group.length;
			this._buildChangeQuantityDialog();

			// bypass for running command
			this.end();
		},

		_buildChangeQuantityDialog : function(options) {
			var that = this;
			this.modal = new Modal({
				className : 'change-quantity-dlg',
				closable : true,
				header : '<h4>Title</h4>',
				body : '',
				footer : "<button type='button' name='okButton' class='btn btn-primary'>OK</button> "
						+ "<button type='button' name='cancelButton' class='btn btn-default'>Cancel</button>"
			}).inject(widget.body);

			this.modal.addEvent('onHide', function() {
				that.destroyView();
			});

			// Adding the onclick handler to buttons inside the
			// modal
			this.modal.getContent().getElements('.btn').forEach(function(element) {
				
				if (element.name === 'cancelButton') {
					element.addEvent('click',function() {
						that.destroyView();
					});
				}
				
				if (element.name === 'okButton') {
					element.disabled = true;
					element.addEvent('click',function() {

						var selectedItems = that.options.context.getSelectedNodes();
						var selectedItem = null;

						if (selectedItems.length >= 1) {
							selectedItem = selectedItems[0];
						}
						var physicalid = null;
						physicalid = selectedItem.getID();

						var elems = that.modal.getContent().getElements('.form-control');
						var elem = elems[0];
						var quantity = parseInt(elem.value);
						var nbInstanceToCreate = quantity - _currentQuantity;
						if (nbInstanceToCreate > 0) {
							that.options.context._app.sandboxBase.dataService.insertBulkItem(_group[0],parent, nbInstanceToCreate, _group)
							.then(function(data) {
								if (null != data) {
									
									var results = {
										nodes : data,
										parentId : parent.getID()
									};
									that.options.context._app.mediator.publish(XEngineerConstants.EVENT_NEW_INSERTED_ENG_ITEM, results);
								}
							});

						} else if (nbInstanceToCreate < 0) {
							var listInstanceToRemove = [];
							

							
							_group.forEach(function(instance) {


								for (var i = 0; i < _nodes.length; i++) {
									
									if (_nodes[i].btn.isActive() && _nodes[i].instID ===instance.getRelationID()){
										listInstanceToRemove.push(instance);
										break;
									}

								}
								
							});

							that.options.context._app.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND,{
								commandId : XEngineerConstants.DETACH_ENG_ITEMS_CMD,
								context : {
									item : listInstanceToRemove
								}
							});
						}

						that.destroyView();
					});
				}
			});

			this.modal.setHeader("<h4>"+ this.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity").replace("{engItem}",_group[0].getDisplayName()).replace("{mat}", _currentQuantity)+ "</h4>");
			var view = new (this.getView());
			view.render().inject(this.modal.elements.body);
			this.modal.show();
			

			var instanceDiv = document.querySelector("div.instance-list");
			

			var instanceTable = document.createElement("div");
			instanceTable.style.height = "300px";
			

			var instanceTable2 = document.createElement("table");
			instanceTable.appendChild(instanceTable2);
			instanceTable2.className = "table table-reset table-hover";
			var instances = _group;
			
			var thead = document.createElement("thead");
			instanceTable2.appendChild(thead);
			
			var trh = document.createElement("tr");
			thead.appendChild(trh);
			
			var th0 = document.createElement("th");
			th0.innerHTML = "#";
			trh.appendChild(th0);
			
			var th1 = document.createElement("th");
			th1.innerHTML = this.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity.headerInst");
			trh.appendChild(th1);
			
			var th2 = document.createElement("th");
			th2.innerHTML = this.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity.headerStatus");
			trh.appendChild(th2);
			
			var th3 = document.createElement("th");
			th3.innerHTML = "";
			trh.appendChild(th3);
			
			
			var tbody = document.createElement("tbody");
			instanceTable2.appendChild(tbody);
			
			new Scroller({
				   element: instanceTable
				}).inject(instanceDiv);
			
			for (var i = 0; i < _currentQuantity; i++) {
				
				var node = this._addNode("false", i+1, instances[i].getInstanceName(), this.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity.statusKept"), instances[i].getRelationID());
				
				_nodes.push(node);

			}

			
			var leftButton = document.querySelector(".change-quantity-input button.input-number-button-left");
			leftButton.removeClassName("input-number-button-left");
			leftButton.addClassName("fonticon-minus");
			
			var leftButton = document.querySelector(".change-quantity-input button.input-number-button-right");
			leftButton.removeClassName("input-number-button-right");
			leftButton.addClassName("fonticon-plus");


			_confirmationText = document.querySelector(".confirmationText");
			_confirmationText.style.display = "none";


			_numberboxElement.addEvent('onChange',function() {
				

				var nbInstanceToCreate = that._getNumberInstancesToCreate();
				
				var newQuantity = this.getValue();
				var previousQuantity = document.querySelectorAll("div.instance-list tbody tr.false,tr.info").length;
				
				for (var i=0 ; i<_nodes.length ; i++){
					_nodes[i].btn.show();
				}
				
				that.modal.getContent().getElements('.btn').forEach(function(element) {
				if (element.name === 'okButton') {
					element.disabled = false;
				}
			});
				
				if (nbInstanceToCreate >= 0) {

					// deactivate selection of
					// instances to remove
									
					

					if (nbInstanceToCreate > 0) {

						_confirmationText.innerHTML = that.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity.create").replace("{nb}",nbInstanceToCreate);
						_confirmationText.style.display = "block";
						

						
						if (newQuantity > previousQuantity){
							
							if (previousQuantity < _currentQuantity){
								for (var i=0 ; i<_currentQuantity-previousQuantity ; i++){
									that.autoAddNode();
								}
								
								previousQuantity = _currentQuantity;
							}
							
							for (var i=0 ; i< newQuantity-previousQuantity ; i++){
								that._addNode("info", "*", that.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity.NewInst"), that.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity.statusNew"), "");
							}
							
						} else if (previousQuantity > newQuantity){
							
							for (var i=0 ; i< previousQuantity-newQuantity ; i++){
								that._removeLastNode();;
							}
							
						}

						for (var i=0 ; i<_nodes.length ; i++){
							_nodes[i].btn.hide();
						}

					} else {
						
						if (previousQuantity > newQuantity){
							
							for (var i=0 ; i< previousQuantity-newQuantity ; i++){
								that._removeLastNode();
							}
						} else if (newQuantity > previousQuantity){
							for (var i=0 ; i< newQuantity-previousQuantity ; i++){
								that.autoAddNode();
							}
							
						}
						_confirmationText.style.display = "none";

						that.modal.getContent().getElements('.btn').forEach(function(element) {
							if (element.name === 'okButton') {
								element.disabled = true;
							}
						});
					}

				} else {
					
					if (previousQuantity > newQuantity){

						for (var i=0 ; i< previousQuantity-newQuantity ; i++){
							that._removeLastNode();
						}
	
					} else if (newQuantity > previousQuantity){
						
						for (var i=0 ; i< newQuantity-previousQuantity ; i++){
							that.autoAddNode();
						}
						
					}
					
					var nbInstToRemove = that._getNumberInstancesToCreate()* (-1);
					_confirmationText.innerHTML = that.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity.remove").replace("{nb}", nbInstToRemove);
					_confirmationText.style.display = "block";
					
				}
			});

		},
		
		
		autoAddNode: function(){
			var body = document.querySelector("div.instance-list tbody");
			
			var done = false;

			for (var i=0 ; i<_nodes.length && done == false ; i++){
				if (_nodes[i].rawElt.className === "error"){
						
					_nodes[i].rawElt.className = "false";
					_nodes[i].rawElt.childNodes[2].innerHTML = this.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity.statusKept");
					_nodes[i].btn.setIcon('minus');
					_nodes[i].btn.setActive(false);

					done = true;
				}
				
			}
			
		},
		
		_removeLastNode: function(){
			var body = document.querySelector("div.instance-list tbody");
			var lastNode = body.childNodes[body.childNodes.length - 1];
			if (lastNode.className === "info"){
				body.removeChild(lastNode);
			} else {
				var done = false;
				for (var i=_nodes.length - 1 ; i>=0 && done == false ; i--){
					if (_nodes[i].rawElt.className === "false"){
							
						_nodes[i].rawElt.className = "error";
						_nodes[i].rawElt.childNodes[2].innerHTML = this.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity.statusRemoved");
						_nodes[i].btn.setIcon('plus');
						_nodes[i].btn.setActive();

						done = true;
					}
					
				}
			}
			
		},
		
		_addNode: function(type, id, name, status, instID){
			
			var that = this;
			
			var tr = document.createElement("tr");
			tr.className = type;
			document.querySelector("div.instance-list tbody").appendChild(tr);
			
			var td0 = document.createElement("td");
			td0.innerHTML = id;
			tr.appendChild(td0);
			
			var td1 = document.createElement("td");
			td1.innerHTML = name;
			tr.appendChild(td1);
			
			var td3 = document.createElement("td");
			td3.innerHTML = status;
			tr.appendChild(td3);
			
			var td2 = document.createElement("td");
			tr.appendChild(td2);
			
			var addRemButton = new Button({
				className: "btn-sm",
				type : 'button',
				icon : "minus"
			});
			
			addRemButton.inject(td2);
			
			addRemButton.addEvent('onClick',function(e, f) {
				
				var rowElement = e.currentTarget.getParent().getParent();
				
				if (rowElement.className === "false"){
					
					rowElement.className = "error";
					rowElement.childNodes[2].innerHTML = that.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity.statusRemoved");
					this.setIcon('plus');
					this.setActive();
					
					
					_numberboxElement.setValue(parseInt(_numberboxElement.getValue()) - 1);
				} else if (rowElement.className === "error"){
					
					rowElement.className = "false";
					rowElement.childNodes[2].innerHTML = that.options.appCore.i18nManager.get("eng.ui.dialog.changeQuantity.statusKept");
					this.setIcon('minus');
					this.setActive(false);
					
					_numberboxElement.setValue(parseInt(_numberboxElement.getValue()) + 1);
				} else if (rowElement.className === "info"){
					
					rowElement.getParent().removeChild(rowElement);
					
					_numberboxElement.setValue(parseInt(_numberboxElement.getValue()) - 1);
				} 
			});
			
			return {id:id, btn:addRemButton, instID:instID, rawElt:tr};
		},

		_getNumberInstancesToCreate : function() {
			var newQuantity = _numberboxElement.getValue();
			return newQuantity - _currentQuantity;
		},

		getView : function() {

			var that = this;

			

			this._chgQtyDlgView = UWAView.extend({
				name : 'change-the-quantity',
				render : function() {
					var content = [];
					_numberboxElement = new Number({
						
						className: "change-quantity-input",
						placeholder : 'Pick a number...',
						min : _currentQuantity - 30 < 0 ? 0:_currentQuantity - 30,
						max : _currentQuantity + 30,
						step : 1,
						value : _currentQuantity
					});

					content.push(_numberboxElement);

								
					content.push({
						tag : 'div',
						'class' : 'instance-list container-scroll',
						text : ''
					});

					content.push({
						tag : 'span',
						'class' : 'confirmationText uk-text-bold',
						text : ''
					});

					this.container.setContent(content);
					return this;
				}
			});
			return this._chgQtyDlgView;
		},
		destroyView : function() {
			var that = this;

			that._chgQtyDlgVie && that._chgQtyDlgView.destroy();
			that._chgQtyDlgVie = undefined;
			that._numberboxElement && that._numberboxElement.destroy();
			that._numberboxElement = undefined;


			_nodes = [];
			
			that._confirmationText	&& that._confirmationText.destroy();
			that._confirmationText = undefined;
			
			var myNode = document.querySelector("div.instance-list");
			while (myNode.firstChild) {
			    myNode.removeChild(myNode.firstChild);
			}

			that.modal.destroy();
			that.modal = undefined;
		},
	});
	return ChangeQuantity;
});

 define('DS/ENOXEngineer/commands/SetWorkUnderEvolutionPrefCmd', [
   'UWA/Core',
   'DS/UIKIT/Input/Toggle',
   'UWA/Class/View',
   'DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
   'DS/ENOXEngineer/commands/XEngineerCommandBase',
   'DS/ENOXEngineerCommonUtils/xEngAlertManager',
   'DS/ENOXEngineer/utils/XEngineerConstants',
 ], function (
   UWA,
   Toggle,
   UWAView,
   XEngineerModal,
   XEngCommandBase,
   xEngAlertManager,
   XEngineerConstants
 ) {
   'use strict';
   var setWorkUnderPrefCmd = XEngCommandBase.extend({
     init: function (options) {
       options = UWA.extend(options, {
         isAsynchronous: false
       });
       this._parent(options);
     },

     execute: function (params) {
       var that = this;
       var currentEngItem = that.options.context.getActiveEngItem();

       if (!currentEngItem || !currentEngItem.hasValidConfigContext() ||
            that.options.context._app.core.dataService.getUserWorkUnderEvolDlgPref() === XEngineerConstants.VALUE_SET_WORKUNDER_NEVER) {
         // Never show dialog, never set work under
         that.end();
         return;
       }
       that.activeEngItem = currentEngItem;

       that.activeModel = that.activeEngItem.getPreferedAttachedConfigModel();
       that.modelId = that.activeModel.getID();
       that.modelName = that.activeModel.getLabel();
       that.productId = that.activeModel.getCurrentVersionID();
       that.productName = that.activeModel.getCurrentVersionName();
       that.productTitle = that.activeModel.getCurrentVersionMarketingName();
       that.productRevision = that.activeModel.getCurrentVersionRevision();
       that.modelTitle = that.activeModel.getMarketingName();
       if (that.options.context._app.core.dataService.getUserWorkUnderEvolDlgPref() === XEngineerConstants.VALUE_SET_WORKUNDER_ALWAYS) {
         // Apply direct work under, no dialog showing
         that.end();
         that.options.context._app.core.dataService.applyWorkUnderEvolution(that.modelId,
           that.modelName,
           that.productId,
           that.productName,
           that.productRevision,
           that.modelTitle,
           that.productTitle).then(function (data) {
           if (null != data) {
             that.options.context._app.mediator.publish(XEngineerConstants.EVENT_SET_WORKUNDER_EVOLUTION_COMPLETED, data);
           }
         });
       } else {
         that._buildEvolutionPrefDialog();
       }
     },

     _buildEvolutionPrefDialog: function () {
       var that = this;
       that.end();
       that.workunderPrefmodal = new XEngineerModal({
         title: that.options.appCore.i18nManager.get("workunder_evolution_pref"),
         className: 'xeng-workunder-preference',
         withFooter: true
       });
       var view = new(that._getEvolutionPrefView());
       view.render().inject(that.workunderPrefmodal.modal.elements.body);

       that.dontAskCheckbox = new Toggle({
         type: 'checkbox',
         value: that.options.appCore.i18nManager.get('checkbox_dontaskagain'),
         className: 'primary',
         label: that.options.appCore.i18nManager.get('checkbox_dontaskagain'),
         events: {}
       });
       that.dontAskCheckbox.inject(that.workunderPrefmodal.modal.elements.body);
       that.workunderPrefmodal.modal.getContent().getElements('.btn').forEach(function (element) {
         if (element.name === 'okButton') {
           element.setText(that.options.appCore.i18nManager.get('label_yes'));
           element.addEvent('click', function () {
             if (that.dontAskCheckbox.isChecked()) {
               that.options.context._app.core.dataService.setUserWorkUnderEvolDlgPref(XEngineerConstants.VALUE_SET_WORKUNDER_ALWAYS);
               xEngAlertManager.sucessAlert(that.options.appCore.i18nManager.get("eng.operation.setNoShowWorkUnderDlg.sucess"));
               that.options.context._app.mediator.publish(XEngineerConstants.EVENT_NEVER_SHOW_WORKUNDER_DLG, XEngineerConstants.VALUE_SET_WORKUNDER_ALWAYS);
             }
             that.options.context._app.core.dataService.applyWorkUnderEvolution(that.modelId,
               that.modelName,
               that.productId,
               that.productName,
               that.productRevision,
               that.modelTitle,
               that.productTitle).then(function (data) {
               if (null != data) {
                 that.options.context._app.mediator.publish(XEngineerConstants.EVENT_SET_WORKUNDER_EVOLUTION_COMPLETED, data);
               }
               that.destroy();
             });
           });
         } else if (element.name === 'cancelButton') {
           // Check the 'Don't ask' checkbox status.If it is checked and 'No'(Cancel) is selected, then set the option to 'Never ask, never set work under'.
           element.setText(that.options.appCore.i18nManager.get('label_no'));
           element.addEvent('click', function () {
            if (that.dontAskCheckbox.isChecked()) {
              that.options.context._app.core.dataService.setUserWorkUnderEvolDlgPref(XEngineerConstants.VALUE_SET_WORKUNDER_NEVER);
              xEngAlertManager.sucessAlert(that.options.appCore.i18nManager.get("eng.operation.setNoShowWorkUnderDlg.sucess"));
              that.options.context._app.mediator.publish(XEngineerConstants.EVENT_NEVER_SHOW_WORKUNDER_DLG, XEngineerConstants.VALUE_SET_WORKUNDER_NEVER);
            }
            that.destroy();
           });
         }
       });
       if (that.options.context._app.core.dataService.getUserWorkUnderEvolDlgPref() === XEngineerConstants.VALUE_ASK_WORKUNDER_EVERYTIME) {
         that.workunderPrefmodal.show();
       }
     },
     destroy :function(){
    	 if (this.workunderPrefmodal)
    		 this.workunderPrefmodal.destroy();
     },

     _getEvolutionPrefView: function () {
       var that = this;
       //
       var myElement = UWA.createElement('div', {
         html: 'test',
         'styles': {
           'height': '600px',
           'position': 'relative'
         }
       });
       //
       that.workunderEvolDlgView = UWAView.extend({
         name: 'set-workunder-pref',
         render: function () {
           var content = [];
           that.textboxElement = UWA.createElement('div', {
             html: that.options.appCore.i18nManager.get("evolutionprefdlg.prefquestion").replace("{model}", that.productTitle).replace("{version}", that.productRevision),
             'styles': {
               'height': 'auto',
               'position': 'relative',
               'padding': '5px'
             }
           });
           /*
                     new Text({ multiline: true,
                     rows: 4,
                     disabled: true,
                     value : that.options.appCore.i18nManager.get("evolutionprefdlg.prefquestion")
                     });
                     */
           this.container.setContent(that.textboxElement);
           return this;
         }
       });
       return that.workunderEvolDlgView;
     }
   });
   return setWorkUnderPrefCmd;
 });

define('DS/ENOXEngineer/commands/ExportEngineeringItems', [
    'DS/ENOXEngineer/commands/XEngineerCommandBase',
    'DS/Handlebars/Handlebars',
    'DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
    'DS/Windows/Dialog',
    'DS/Windows/ImmersiveFrame',
    'DS/UIKIT/Input/Text',
    'DS/Controls/LineEditor',
    'DS/Controls/ComboBox',
    'DS/Controls/Toggle',
    'DS/Controls/Button',
    'DS/DataGridView/DataGridView',
    'DS/ENOXEngineerCommonUtils/xEngAlertManager',
    'DS/ENOXEngineer/utils/XEngineerConstants',
    'text!DS/ENOXEngineer/componentsHelpers/xEngExport/html/ExportEngineeringItems.html',
    'text!DS/ENOXEngineer/componentsHelpers/xEngExport/html/ExportEngineeringEditHeader.html',
    'text!DS/ENOXEngineer/componentsHelpers/xEngExport/html/ExportEngineeringPreviewFormat.html',
    'css!DS/ENOXEngineer/componentsHelpers/xEngExport/css/ExportEngineeringItems.css',
    'css!DS/ENOXEngineer/componentsHelpers/xEngExport/css/ExportEngineeringEditHeader.css'
], function(
    XEngineerCommandBase,
    Handlebars,
    Modal,
    Dialog,
    ImmersiveFrame,
    Text,
    LineEditor,
    ComboBox,
    Toggle,
    Button,
    DataGridView,
    xEngAlertManager,
    XEngineerConstants,
    html_ExportEngineeringItems,
    html_ExportEngineeringEditHeader,
    html_ExportEngineeringPreviewFormat) {
    'use strict';
    var CONSTANT_WIDGET_DIV = "div";
    var CONSTANT_WIDGET_UL = "ul";
    var CONSTANT_WIDGET_LI = "li";
    var CONSTANT_WIDGET_SPAN = "span";
    var CONSTANT_SUPPORTED_FILE_FORMAT = ".csv";
    var CONSTANT_ATTRIBUTE_QUANTITY = "Quantity";
    var CONSTANT_ATTRIBUTE_VARITANT = "Variant";
    var CONSTANT_ATTRIBUTE_EVOLUTION = "Evolution";
    var CONSTANT_ATTRIBUTE_CORE_MATERIAL = "CoreMaterialName";
    var CONSTANT_ATTRIBUTE_DECLARE_QUANTITY = "ds6wg:MaterialUsageExtension.DeclaredQuantity";
    var CONSTANT_ATTRIBUTE_INSTANCE_NAME = "InstanceName";
    var CONSTANT_LABEL_SIXW_TAG = "ds6w:label";
    var EDIT_HEADER_TEMPLATE_CODE = "<span>&#9998;</span>";
    var CONSTANT_DRAG_DROP_COLUMN = 3;


    var enoXExportOptions, that, userPreferedOptions = {},
        previewFormatOptions = {},
        previousSelectedOptions = {},
        columnOrderClone = null,
        consolidationElementsActual;

    function ENOXExportOptions() {


        var options = {
            editHeaderTemplate: true,
            components: true,
            groupBy: true,
            advancedFilter: true,
            columnsTable: true,
            fileName: true
        };

        this._columnsOrder = [];
        this._columnsOrderNlsJson = {};

        this.modalOptions = {
            title: that.options.appCore.i18nManager.get("eng.export.label"),
            className: 'set-exportCommand-modal',
            withFooter: false
        };
        this.modal = new Modal(this.modalOptions);

        this.modal.injectFooter(_getFooter());

        function _getFooter() {
            return "<button type='button'  name='exportButton' id='export-button' class='btn btn-primary'>" + that.options.appCore.i18nManager.get("eng.export.button.export") + "</button> " + "<button type='button' name='previewButton' id='preview-format-button' class='btn btn-default'>" + that.options.appCore.i18nManager.get("eng.export.button.previewFormat") + "</button>" + "<button type='button' name='cancelButton' id='cancel-button' class='btn btn-default'>" + that.options.appCore.i18nManager.get("eng.ui.button.cancel") + "</button>";
        }


        var template = Handlebars.compile(html_ExportEngineeringItems);
        this._options = options ? UWA.clone(options, false) : {};

        this._container = this.modal.getBody();
        this._container.innerHTML = template(this._options);

        this._container = this._container.querySelector('.enox-export');
        this._editHeaderTemplateContainer = this._container.querySelector('.enox-export-edit-header-template');
        this._componentsHeader = this._container.querySelector('.enox-export-components-header');
        this._directComponent = this._container.querySelector('.enox-export-components-direct');
        this._finalItem = this._container.querySelector('.enox-export-components-qualified-as-final');
        this._inculdeIntermediate = this._container.querySelector('.enox-export-components-include-intermediate');
        this._groupByHeader = this._container.querySelector('.enox-export-groupby-header');
        this._groupByCombobox = this._container.querySelector('.enox-export-groupby-combobox');
        this._advancedFilterContainer = this._container.querySelector('.enox-export-advanced-apply-filter');
        this._exportTableContainer = this._container.querySelector('.enox-export-columns-table');
        this._fileHeader = this._container.querySelector('.enox-export-file-name-header');
        this._fileComponent = this._container.querySelector('.enox-export-file-name-component');
        this._fileFormat = this._container.querySelector('.enox-export-file-format');

        this.createEditHeaders();
        this.createLevelComponents();
        this.createGroupBy();
        this.createApplyFilters();
        this.createCustomHeaderColumnSelections();
        this.createFileName();
    }

    ENOXExportOptions.prototype = {

        constructor: ENOXExportOptions,

        createEditHeaders: function() {
            this._editHeaderTemplateContainer.innerHTML = EDIT_HEADER_TEMPLATE_CODE + that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate");
        },

        createLevelComponents: function() {
            var _self = this;
            this._componentsHeader.innerHTML = "<b>" + that.options.appCore.i18nManager.get("eng.export.components.label") + "&nbsp;:</b>";

            this._COMPONENT_DIRECT = new Toggle({
                type: "radio",
                label: that.options.appCore.i18nManager.get("eng.export.components.direct"),
                value: "Direct", //that.options.appCore.i18nManager.get("eng.export.components.direct"),
                checkFlag: true,
                domId: "direct-component"
            }).inject(this._directComponent);

            this._COMPONENT_FINALITEM = new Toggle({
                type: "radio",
                label: that.options.appCore.i18nManager.get("eng.export.components.qualifiedAsFinal"),
                value: "QualifiedAsFinal", //that.options.appCore.i18nManager.get("eng.export.components.qualifiedAsFinal"),
                domId: "final-component"
            }).inject(this._finalItem);

            this._INCLUDE_INTERMEDIATE = new Toggle({
                type: "checkbox",
                label: that.options.appCore.i18nManager.get("eng.export.components.includeIntermmediate"),
                value: "IncludeIntermediate",
                disabled: true,
                domId: "include-intermediate-component"
            }).inject(this._inculdeIntermediate);

            this._COMPONENT_FINALITEM.addEventListener('click', function() {
                enoXExportOptions._COMPONENT_DIRECT.checkFlag = false;

                enoXExportOptions._INCLUDE_INTERMEDIATE.disabled = false;

                _self.hideConfigurationAttributeFromView();
            });

            this._COMPONENT_DIRECT.addEventListener('click', function() {
                enoXExportOptions._INCLUDE_INTERMEDIATE.checkFlag = false;
                enoXExportOptions._INCLUDE_INTERMEDIATE.disabled = true;
                _self.showConfigurationAttributeFromView();

                enoXExportOptions._COMPONENT_FINALITEM.checkFlag = false;
            });

        },

        createGroupBy: function() {

            this._groupByHeader.innerHTML = "<b>" + that.options.appCore.i18nManager.get("eng.export.consolidation.label") + "&nbsp;:</b>";

            var maxWidth = 150;

            this._GroupByOptionsList = new ComboBox({
                elementsList: consolidationElementsActual,
                enableSearchFlag: false,
                domId: "groupBy",
                width: maxWidth
            });

            this._GroupByOptionsList.inject(this._groupByCombobox);
            this._GroupByOptionsList.elements.container.style.width = maxWidth + "px";
        },

        createApplyFilters: function() {


            var advancedFilterExpr = (that.context && that.context.getActiveEngItemOpenContext() && that.context.getActiveEngItemOpenContext().filteringContext) ? that.context.getActiveEngItemOpenContext().filteringContext : "";


            var disableApplyFilter = true;
            var checkFlagApplyFilter = false;

            if (advancedFilterExpr != "" && advancedFilterExpr != "none") {
                disableApplyFilter = false;
                checkFlagApplyFilter = true;
            }

            this._persistentFilterCheckbox = new Toggle({
                type: "checkbox",
                label: that.options.appCore.i18nManager.get("eng.export.applyFilter.label"),
                value: advancedFilterExpr,
                checkFlag: checkFlagApplyFilter,
                disabled: disableApplyFilter,
                domId: "advanced-filter"
            }).inject(this._advancedFilterContainer);

        },
        hideAColumnBySixw: function(sixw){
            if(!sixw) return ;
            
            var relatedHamber = document.querySelector('.set-exportCommand-modal div#'+sixw.replace(':','\\3A'));
            if(relatedHamber){
                var row  = relatedHamber.getParent() ;
                if(row){
                    row.style.display = 'none';
                }
            }
        },
        hideConfigurationAttributeFromView : function(){
            if(!Array.isArray(this._columnsOrder)) return ;
            var _self = this;
            var sixwTags = [CONSTANT_ATTRIBUTE_VARITANT, CONSTANT_ATTRIBUTE_EVOLUTION];
            columnOrderClone = _self._columnsOrder.slice();
            _self._columnsOrder = _self._columnsOrder.filter(function(sixw){
                 return sixwTags.indexOf(sixw) ===-1;   
            });
            /**
             * hide configuration attributes
             */
            sixwTags.forEach(function(sixw){
                _self.hideAColumnBySixw(sixw);
            });


        },
        showAColumnBySixw: function(sixw){
            if(!sixw) return ;
            var relatedHamber = document.querySelector('.set-exportCommand-modal div#'+sixw.replace(':','\\3A'));
            if(relatedHamber){
                var row  = relatedHamber.getParent() ;
                if(row){
                    row.style.display = '';
                }
            }
        },
        showConfigurationAttributeFromView: function(){
            var _self = this;
            var sixwTags = [CONSTANT_ATTRIBUTE_VARITANT, CONSTANT_ATTRIBUTE_EVOLUTION];
            if(columnOrderClone){
                _self._columnsOrder =   columnOrderClone;
            }
            
            sixwTags.forEach(function(sixw){
                _self.showAColumnBySixw(sixw);
            });
        },
        createCustomHeaderColumnSelections: function() {

            var attributes = that.appCore.dataService.getAvailableAttributesByType(["VPMReference"]);

            var instanceLabelArray = [];

            instanceLabelArray.push(that.appCore.i18nManager.get("label_Instance_Name"));

            attributes.sort(function(attrInfo1, attrInfo2) {

                return attrInfo1.attrNls.localeCompare(attrInfo2.attrNls);
            });


            var instanceName = {
                "type": "string",
                "attrName": CONSTANT_ATTRIBUTE_INSTANCE_NAME,
                "sixWTag": CONSTANT_ATTRIBUTE_INSTANCE_NAME,
                "attrNls": that.appCore.i18nManager.get("label_Instance_Name")
            };

            attributes.unshift(instanceName);
            if (that.context.getActiveEngItem().getPreferedAttachedConfigModel()) {
                var variant = {
                    "type": "string",
                    "attrName": CONSTANT_ATTRIBUTE_VARITANT,
                    "sixWTag": CONSTANT_ATTRIBUTE_VARITANT,
                    "attrNls": that.appCore.i18nManager.get("label_Variant")
                };
                var evolution = {
                    "type": "string",
                    "attrName": CONSTANT_ATTRIBUTE_EVOLUTION,
                    "sixWTag": CONSTANT_ATTRIBUTE_EVOLUTION,
                    "attrNls": that.appCore.i18nManager.get("label_Evolution")
                };
                attributes.push(variant);
                attributes.push(evolution);
            }

            var coreMaterial = {
		"type": "string",
		"attrName": CONSTANT_ATTRIBUTE_CORE_MATERIAL,
		"sixWTag": CONSTANT_ATTRIBUTE_CORE_MATERIAL,
		"attrNls": that.appCore.i18nManager.get("CoreMaterial")
            };

            attributes.push(coreMaterial);
            var quantity = {
                "type": "string",
                "attrName": CONSTANT_ATTRIBUTE_QUANTITY,
                "sixWTag": CONSTANT_ATTRIBUTE_QUANTITY,
                "attrNls": that.appCore.i18nManager.get("eng.export.quantity")
            };
            attributes.push(quantity);

		var indexOfDeclaredQuantity;
		var indexOfQuantity;
		var indexOfCoreMaterial;

		attributes.find(function (item, i) {
				if (item.attrName === CONSTANT_ATTRIBUTE_DECLARE_QUANTITY) {
					indexOfDeclaredQuantity = i;
				}else if (item.attrName === CONSTANT_ATTRIBUTE_QUANTITY) {
					indexOfQuantity = i;
				}else if (item.attrName === CONSTANT_ATTRIBUTE_CORE_MATERIAL) {
					indexOfCoreMaterial = i;
				}
		});

		var quantityValue = attributes[indexOfQuantity];
		attributes[indexOfQuantity] = attributes[indexOfDeclaredQuantity];
		attributes[indexOfQuantity + 1] = quantityValue;
		attributes.splice(indexOfDeclaredQuantity, 1);

            var index = -1;
            var searchingElement = that.appCore.i18nManager.get("Title");
            attributes.find(function(item, i) {
                if (item.attrNls === searchingElement) {
                    index = i;
                    return i;
                }
            });
            attributes.unshift(attributes[index]);
            attributes.splice(index + 1, 1);


            this.actualAttributeNames = {};

            for(var i=0; i<attributes.length; i++){
              this.actualAttributeNames[attributes[i].attrName] = attributes[i].sixWTag;
            }

            var liTagForExportTableRows = UWA.createElement(CONSTANT_WIDGET_DIV);
            liTagForExportTableRows.id = 'columns_with_list';

            var divTagForAllColumns = UWA.createElement(CONSTANT_WIDGET_DIV);
            divTagForAllColumns.className = "divTagForAllColumns";

            liTagForExportTableRows.className = 'columnsHeader';

            var checkboxDiv = UWA.createElement(CONSTANT_WIDGET_DIV);
            checkboxDiv.className = 'listitem_checkbox';
            liTagForExportTableRows.appendChild(checkboxDiv);

            var headerNameDiv = UWA.createElement(CONSTANT_WIDGET_DIV);
            headerNameDiv.className = 'listitem_header_name';
            liTagForExportTableRows.appendChild(headerNameDiv);

            var customNameDiv = UWA.createElement(CONSTANT_WIDGET_DIV);
            customNameDiv.className = 'listitem_custom_name';
            liTagForExportTableRows.appendChild(customNameDiv);

            var dragDropDiv = UWA.createElement(CONSTANT_WIDGET_DIV);
            dragDropDiv.className = 'column_header_drag_drop';


            liTagForExportTableRows.appendChild(dragDropDiv);

            this._selectAllCheckbox = new Toggle({
                type: "checkbox",
                checkFlag: true
            });

            this._selectAllCheckbox.inject(checkboxDiv);

            headerNameDiv.innerHTML = "<b>" + that.appCore.i18nManager.get("eng.export.column.header") + "</b>";
            customNameDiv.innerHTML = "<b>" + that.appCore.i18nManager.get("eng.export.column.customheader") + "</b>";
            this._exportTableContainer.appendChild(liTagForExportTableRows);
            this._exportTableContainer.appendChild(divTagForAllColumns);

            var columnsCheckboxJson = {};

            for (var i = 0; i < attributes.length; i++) {
                var divTag = UWA.createElement(CONSTANT_WIDGET_DIV);

                divTag.className = "columns";

                var columnRows = new Toggle({
                    type: "checkbox",
                    checkFlag: true,
                    domId: "domId_" + attributes[i].sixWTag
                });

                columnsCheckboxJson[attributes[i].sixWTag] = columnRows;

                var checkboxForRows = UWA.createElement(CONSTANT_WIDGET_DIV);
                checkboxForRows.className = 'listitem_checkbox';


                if(attributes[i].sixWTag == CONSTANT_LABEL_SIXW_TAG){
                	checkboxForRows.innerHTML = "<span class=\"fonticon fonticon-block\" title="+"\""+that.options.appCore.i18nManager.get("eng.import.CkeckboxImageTooltip") +"\""+"></span>";
                }else{
                	columnRows.inject(checkboxForRows);
                }

                var headerNameDivForRows = UWA.createElement(CONSTANT_WIDGET_DIV);
                headerNameDivForRows.className = 'listitem_header_name hover_info';
                headerNameDivForRows.setText(attributes[i].attrNls);


                var customNameDivForRows = UWA.createElement(CONSTANT_WIDGET_DIV);
                customNameDivForRows.className = 'listitem_custom_name display_text enable_textbox';
                customNameDivForRows.id = attributes[i].sixWTag + "_displayValue";


                customNameDivForRows.setText(attributes[i].attrNls);


                var dragDropDivForRows = UWA.createElement(CONSTANT_WIDGET_DIV);
                dragDropDivForRows.className = 'listitem_drag_drop wux-ui-hamburgers';
                dragDropDivForRows.id = attributes[i].sixWTag;
                dragDropDivForRows.draggable = true;




                divTag.appendChild(checkboxForRows);
                divTag.appendChild(headerNameDivForRows);
                divTag.appendChild(customNameDivForRows);
                divTag.appendChild(dragDropDivForRows);
                divTagForAllColumns.appendChild(divTag);

                this._columnsOrder.push(attributes[i].sixWTag);
                this._columnsOrderNlsJson[attributes[i].sixWTag + "_displayValue"] = attributes[i].attrNls;
            }

            this._columnsCheckboxJson = columnsCheckboxJson;
        },

        createFileName: function() {

            this._fileFormat.innerHTML = CONSTANT_SUPPORTED_FILE_FORMAT;

            this._fileHeader.innerHTML = "<b>" + that.options.appCore.i18nManager.get("eng.export.fileName.label") + "&nbsp;:</b>";

            this._fileName = new Text().inject(this._fileComponent);


            this._fileName.elements.container.value = that.context.getActiveEngItem()._options.label;
        },

        getActualAndCustomHeaderForSelectedColumns: function() {

            var selectedUserActualAndDisplayColumns = {};
            for (var j = 0; j < this._columnsOrder.length; j++) {
                if (this._columnsCheckboxJson[this._columnsOrder[j]].checkFlag && !(this._columnsCheckboxJson[this._columnsOrder[j]].disabled)) {
                    selectedUserActualAndDisplayColumns[this._columnsOrder[j]] = document.getElementById(this._columnsOrder[j] + "_displayValue").getText();
                }
            }

            return selectedUserActualAndDisplayColumns;
        },

        selectAllColumns: function() {
            for (var property in this._columnsCheckboxJson) {
              if(!this._columnsCheckboxJson[property].disabled){
                this._columnsCheckboxJson[property].checkFlag = true;
              }

            }

            this.enableExportAndPreviewFormatButtons();
        },

        unselectAllColumns: function() {
            for (var property in this._columnsCheckboxJson) {
              if(!(this._columnsCheckboxJson[property].disabled) && (property != CONSTANT_LABEL_SIXW_TAG)){
                this._columnsCheckboxJson[property].checkFlag = false;
              }
            }

            this.disableExportAndPreviewFormatButtons();
        },

        selectQuantityColumn: function() {
             var allColumnsSelected = true;

             this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_QUANTITY].checkFlag = true;
             this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_QUANTITY].disabled = false;

             for (var property in this._columnsCheckboxJson) {
                 if ((!this._columnsCheckboxJson[property].checkFlag) && (!this._columnsCheckboxJson[property].disabled)) {
                     allColumnsSelected = false;
                     break;
                 }
             }

             this.enableExportAndPreviewFormatButtons();

             this._selectAllCheckbox.checkFlag = allColumnsSelected;
         },

         unselectQuantityColumn: function() {


             this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_QUANTITY].checkFlag = false;
             this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_QUANTITY].disabled = true;

             var allColumnsUnselected = true;


             for (var property in this._columnsCheckboxJson ) {
                 if ((this._columnsCheckboxJson[property].checkFlag) && (!this._columnsCheckboxJson[property].disabled)) {
                     allColumnsUnselected = false;
                     break;
                 }
             }

             if (allColumnsUnselected) {
                 this.disableExportAndPreviewFormatButtons();
             }
         },

	selectInstanceName: function () {
		this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_INSTANCE_NAME].checkFlag = true;
		this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_INSTANCE_NAME].disabled = false;
	},
	unselectInstanceName: function () {
		this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_INSTANCE_NAME].checkFlag = false;
		this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_INSTANCE_NAME].disabled = true;
	},
        disableDeclaredQuantity: function(){
         this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_DECLARE_QUANTITY].disabled = true;
         this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_DECLARE_QUANTITY].checkFlag = false;
        },

        enableDeclaredQuantity: function(){
          this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_DECLARE_QUANTITY].disabled = false;
          this._columnsCheckboxJson[CONSTANT_ATTRIBUTE_DECLARE_QUANTITY].checkFlag = true;
        },
        disableExportAndPreviewFormatButtons: function() {
            document.getElementById('export-button').disabled = true;
            document.getElementById('preview-format-button').disabled = true;
        },

        enableExportAndPreviewFormatButtons: function() {
            document.getElementById('export-button').disabled = false;
            document.getElementById('preview-format-button').disabled = false;
        },

        isAllColumnsSelected: function() {
            var allColumnsSelected = true;
            for (var property in this._columnsCheckboxJson) {
                if ((!this._columnsCheckboxJson[property].checkFlag) && (!this._columnsCheckboxJson[property].disabled)) {
                    allColumnsSelected = false;
                    break;
                }
            }

            return allColumnsSelected;
        },

        anyColumnSelected: function() {
            var anyColumnSelected = false;

            for (var property in this._columnsCheckboxJson) {
                if ((this._columnsCheckboxJson[property].checkFlag) && (!this._columnsCheckboxJson[property].disabled) && (property != CONSTANT_LABEL_SIXW_TAG)) {
                    anyColumnSelected = true;
                    break;
                }
            }

            return anyColumnSelected;
        },

        validateSelectAllCheckBox: function() {
            if (this.isAllColumnsSelected()) {
                this._selectAllCheckbox.checkFlag = true;
            } else {
                this._selectAllCheckbox.checkFlag = false;
            }

            if (this.anyColumnSelected()) {
                this.enableExportAndPreviewFormatButtons();
            } else {
                this.disableExportAndPreviewFormatButtons();
            }
        },

        validateExportOptions: function() {

            var toCompleteExport = true;
            if (this._GroupByOptionsList.value == XEngineerConstants.PART_NUMBER && this._INCLUDE_INTERMEDIATE.checkFlag == true) {
                alert(that.appCore.i18nManager.get("eng.export.components.groupby.invalidselectionmessage"));
                toCompleteExport = false;
            }
            return toCompleteExport;
        },

        getUserSelectedExportOptions: function() {
            var fileName = this._fileName.elements.container.value;
            userPreferedOptions.physicalid = that.context.getSelectedNodes()[0].getID();

            userPreferedOptions.Components = (this._COMPONENT_DIRECT.checkFlag) ? this._COMPONENT_DIRECT.value :
                this._COMPONENT_FINALITEM.value;

            userPreferedOptions.IncludeIntermediateComponent = this._INCLUDE_INTERMEDIATE.checkFlag;

            userPreferedOptions.GroupingConsolidatedQuantity = this._GroupByOptionsList.value;
            
            userPreferedOptions.Authored = (this._COMPONENT_DIRECT.checkFlag) ? that.appCore.sessionManager.isUsingDB() : false;

            userPreferedOptions.PersistentFilter = this._persistentFilterCheckbox.checkFlag;

            userPreferedOptions.PersistentFilterCriteria = (that.context.getActiveEngItemOpenContext()) ? that.context.getActiveEngItemOpenContext() : ""


            userPreferedOptions.ExportFileName = (fileName == null || fileName == "") ? that.context.getActiveEngItem()._options.label : this._fileName.elements.container.value;
            var selectedUserActualAndDisplayColumns = this.getActualAndCustomHeaderForSelectedColumns();


            var finalItemPref = widget.getPreferences();
            for (var i = 0; i < finalItemPref.length; i++) {
                if (finalItemPref[i].name == XEngineerConstants.FINAL_ITEMS_PREF) {
                    userPreferedOptions.PreferredFinalItem = widget.getPreferences()[i].value;
                    userPreferedOptions.PreferredFinalItemNLS = (that.appCore.dataService.getAttributesForFinalItems("VPMReference"))
                    											?	that.appCore.dataService.getAttributesForFinalItems("VPMReference")[widget.getPreferences()[i].value]
                    											:	"";
                }if (finalItemPref[i].name == "ShowNotInBOM") {
                    userPreferedOptions.ShowNotInBOM = widget.getPreferences()[i].value;
                }
            }


            userPreferedOptions.SelectedColumns = JSON.stringify(selectedUserActualAndDisplayColumns);

            userPreferedOptions.ParametricAttributes = that.appCore.exportService.getParametricalAttributesForExport("VPMReference");

            var previousSelectedOptions = that.appCore.exportService.getExportOptions();
            if (previousSelectedOptions != null) {
                userPreferedOptions.FileName = previousSelectedOptions.FileName;
                userPreferedOptions.ExportedOn = previousSelectedOptions.ExportedOn;
                userPreferedOptions.ExportedBy = previousSelectedOptions.ExportedBy;
                userPreferedOptions.NoOfExportedItems = previousSelectedOptions.NoOfExportedItems;
                userPreferedOptions.ExportSettings = previousSelectedOptions.ExportSettings;
            }

            userPreferedOptions.ds6wAttributeMapping = this.actualAttributeNames;

            return userPreferedOptions;
        },

        getPreviewFormatSelectedOptions: function() {

            var toDisplayPreviousSelectedOptions = that.appCore.exportService.getExportOptions();

            if (toDisplayPreviousSelectedOptions == null || toDisplayPreviousSelectedOptions == '' || toDisplayPreviousSelectedOptions == "undefined") {
                toDisplayPreviousSelectedOptions = userPreferedOptions;
            }




            if (toDisplayPreviousSelectedOptions.ExportSettings) {
                previewFormatOptions[that.options.appCore.i18nManager.get("eng.export.components.label")] = (this._COMPONENT_DIRECT.checkFlag) ? this._COMPONENT_DIRECT.label : this._COMPONENT_FINALITEM.label;
                if (userPreferedOptions.IncludeIntermediateComponent) {
                    previewFormatOptions[that.options.appCore.i18nManager.get("eng.export.components.includeIntermmediate")] = this._INCLUDE_INTERMEDIATE.checkFlag;
                }
                previewFormatOptions[that.options.appCore.i18nManager.get("eng.export.consolidation.label")] = this._GroupByOptionsList.label;
                //                    if (userPreferedOptions.PersistentFilter) {
                previewFormatOptions[that.options.appCore.i18nManager.get("eng.export.applyFilter.label")] = this._persistentFilterCheckbox.checkFlag;
                //                    }
            }

            if (toDisplayPreviousSelectedOptions.FileName) {
                previewFormatOptions[that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.fileName")] = ((this._fileName.elements.container.value) ? this._fileName.elements.container.value : that.context.getActiveEngItem()._options.label) + CONSTANT_SUPPORTED_FILE_FORMAT;
            }

            if (toDisplayPreviousSelectedOptions.ExportedOn) {
                previewFormatOptions[that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.exportedOnDate")] = new Date().toLocaleString().replace(",", " ");
            }

            if (toDisplayPreviousSelectedOptions.ExportedBy) {
                previewFormatOptions[that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.exportedByUser")] = that.appCore.settingManager.getCurrentUser().firstName + " " + that.appCore.settingManager.getCurrentUser().lastName;
            }
        }

    }


    var exportEngineeringItems = XEngineerCommandBase.extend({

        init: function(options) {
            options = UWA.extend(options, {
                isAsynchronous: false
            });
            this._parent(options);
        },

        execute: function() {
            that = this;
            //TODO not aallow for command :(
            this.context._app.optionalStartupPromises.push(that.appCore.exportService.loadExportOptions());
            that._exportFileDialog();

        },

        _exportFileDialog: function(options) {
            consolidationElementsActual = [{
                labelItem: that.options.appCore.i18nManager.get("eng.export.notGrouped"),
                valueItem: XEngineerConstants.NOT_GROUPED
            }, {
                labelItem: that.options.appCore.i18nManager.get("eng.export.reference"),
                valueItem: XEngineerConstants.REFERENCE
            }, {
                labelItem: that.options.appCore.i18nManager.get("eng.export.partNumber"),
                valueItem: XEngineerConstants.PART_NUMBER
            }];


            enoXExportOptions = new ENOXExportOptions();

            userPreferedOptions = {
                "ExportedOn": true,
                "ExportedBy": true,
                "FileName": true,
                "NoOfExportedItems": true,
                "ExportSettings": true,
            };



            enoXExportOptions.modal.getContent().getElements('.btn').forEach(function(element) {

                if (element.name === 'cancelButton') {
                    element.addEvent('click', function() {
                        userPreferedOptions = {};
                        enoXExportOptions.modal.destroy();

                    });
                } else if (element.name === 'previewButton') {
                    element.addEvent('click', function() {
                        if (enoXExportOptions.validateExportOptions()) {
                            enoXExportOptions.getUserSelectedExportOptions();
                            enoXExportOptions.getPreviewFormatSelectedOptions();
                            getPreviewFormat();
                            previewFormatOptions = {};
                        }

                    });
                } else if (element.name === 'exportButton') {

                    element.addEvent('click', function() {
                        if (enoXExportOptions.validateExportOptions()) {
                            userPreferedOptions = enoXExportOptions.getUserSelectedExportOptions();
                            var level = (userPreferedOptions.Components === "Direct") ? "1" : "-1";
                            document.getElementById('export-button').disabled = true;
                            document.getElementById('preview-format-button').disabled = true;
                            that.appCore.contextManager.getActiveEngItem().isValidForExpandLevel(level).then(function() {
                            	that.appCore.exportService.downloadExportFile(userPreferedOptions, 'export_fetch');
                                userPreferedOptions = {};
                                enoXExportOptions.modal.destroy();
                            }).catch(function(errors) {
                            	xEngAlertManager.errorAlert(that.appCore.i18nManager.get("eng.export.alert.largeExportdata"));
                            	enoXExportOptions.enableExportAndPreviewFormatButtons();
              	          });
                        }

                    });
                }
            });

            enoXExportOptions._selectAllCheckbox.addEventListener('click', function() {
                var selectAllChecked = enoXExportOptions._selectAllCheckbox.checkFlag;

                if (selectAllChecked) {
                    enoXExportOptions.selectAllColumns();
                } else {
                    enoXExportOptions.unselectAllColumns();
                }
            });

            enoXExportOptions.modal.getContent().getElements('.listitem_checkbox').forEach(function(element) {
                element.addEvent('click', function(event) {
                    enoXExportOptions.validateSelectAllCheckBox();
                })
            });



            enoXExportOptions.modal.getContent().getElements('.columns').forEach(function(element) {
                element.addEvent('dragstart', function(event) {
                    event.dataTransfer.setData("Text", event.target.id);
                })
            });

            enoXExportOptions.modal.getContent().getElements('.columns').forEach(function(element) {
                element.addEvent('dragover', function(event) {
                    event.preventDefault();
                    event.stopPropagation();
                    element.getChildren()[CONSTANT_DRAG_DROP_COLUMN].addClassName('listitem_drag_drop_highlight');
                })
            });


            enoXExportOptions.modal.getContent().getElements('.columns').forEach(function(element) {
                element.addEvent('dragleave', function(event) {
                    event.preventDefault();
                    event.stopPropagation();
                      element.getChildren()[CONSTANT_DRAG_DROP_COLUMN].removeClassName('listitem_drag_drop_highlight');
                })
            });


            enoXExportOptions.modal.getContent().getElements('.columns').forEach(function(element) {

                element.addEvent('drop', function(event) {
                    event.preventDefault();

                    var draggedData = event.dataTransfer.getData("Text");

                    var dropElementParent = document.getElementById(event.target.id)?document.getElementById(event.target.id).parentNode:'';
                    var draggedElementParent = document.getElementById(draggedData).parentNode;

                    var toDisableDropOnOtherDivs = event.target.id;
                    if (toDisableDropOnOtherDivs.indexOf("_displayValue") < 0  && toDisableDropOnOtherDivs != "") {
	                    var insertAfter = false;

	                    var indexOfDragElement = _indexOf(draggedData, enoXExportOptions._columnsOrder);
	                    var indexOfDropElement = _indexOf(event.target.id, enoXExportOptions._columnsOrder);

	                    if (indexOfDropElement - indexOfDragElement == 1) {
	                        insertAfter = true;
	                    }

	                    if (insertAfter) {
	                        draggedElementParent.parentNode.insertBefore(dropElementParent, draggedElementParent);
	                    } else {
	                        draggedElementParent.parentNode.insertBefore(draggedElementParent, dropElementParent);
	                    }


	                    var reArrangedArray = [];

	                    for (var i = 0; i < enoXExportOptions._columnsOrder.length; i++) {
	                        if (enoXExportOptions._columnsOrder[i] != draggedData) {
	                            if (enoXExportOptions._columnsOrder[i] != event.target.id) {
	                                reArrangedArray.push(enoXExportOptions._columnsOrder[i]);
	                            } else {
	                                if (insertAfter) {
	                                    reArrangedArray.push(enoXExportOptions._columnsOrder[i]);
	                                    reArrangedArray.push(draggedData);
	                                } else {
	                                    reArrangedArray.push(draggedData);
	                                    reArrangedArray.push(enoXExportOptions._columnsOrder[i]);
	                                }
	                            }
	                        }
	                    }
	                    enoXExportOptions._columnsOrder = reArrangedArray;
                    }
                    event.stopPropagation();
                    element.getChildren()[CONSTANT_DRAG_DROP_COLUMN].removeClassName('listitem_drag_drop_highlight');
                })
            });


            enoXExportOptions.modal.getContent().getElement('.enox-export-edit-header-template').addEvent('click', function(element) {
                createEditHeaderDialogBox();
            });


            function _indexOf(value, columnsOrder) {
                var valueIndex = 0;

                for (var i = 0; i < columnsOrder.length; i++) {
                    if (columnsOrder[i] == value) {
                        valueIndex = i;
                        break;
                    }
                }

                return valueIndex;
            }


            function createEditHeaderDialogBox() {
                var immersiveFrame = new ImmersiveFrame();
                immersiveFrame.inject(enoXExportOptions.modal.modal.elements.container);

                var editHeaderTemplateOptions = {
                    ediTHeaderExportOptions: true,
                    editHeaderNote: true
                };

                var templateEditHeader = Handlebars.compile(html_ExportEngineeringEditHeader);
                var _editHeaderTemplateOptions = editHeaderTemplateOptions ? UWA.clone(editHeaderTemplateOptions, false) : {};

                var _editHeaderTemplate = document.createElement(CONSTANT_WIDGET_DIV);
                _editHeaderTemplate.innerHTML = templateEditHeader(_editHeaderTemplateOptions);


                var _editHeaderExportLabel = _editHeaderTemplate.querySelector('.enox-export-edit-header-export-label');
                var _editHeaderExportOptions = _editHeaderTemplate.querySelector('.enox-export-edit-header-export-options');
                var _editHeaderNote = _editHeaderTemplate.querySelector('.enox-export-edit-header-note');

                _editHeaderExportLabel.innerHTML = "<b>" + that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader") + "&nbsp;:</b>";
                _editHeaderNote.innerHTML = "<br> <br> <br>" + that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.description");


                var fileNameCheckbox = new Toggle({
                    type: "checkbox",
                    label: that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.fileName"),
                    value: that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.fileName"),
                    domId: "fileNameCheckbox",
                }).inject(_editHeaderExportOptions);

                var exportedOnCheckbox = new Toggle({
                    type: "checkbox",
                    label: that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.exportedOnDate"),
                    value: that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.exportedOnDate"),
                    domId: "exportedOnCheckbox"
                }).inject(_editHeaderExportOptions);

                var exportedByCheckbox = new Toggle({
                    type: "checkbox",
                    label: that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.exportedByUser"),
                    value: that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.exportedByUser"),
                    domId: "exportedByCheckbox"
                }).inject(_editHeaderExportOptions);

                var noOfExportedItemsCheckbox = new Toggle({
                    type: "checkbox",
                    label: that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.numberOfExportedItems"),
                    value: that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.numberOfExportedItems"),
                    domId: "noOfItemsCheckbox"
                }).inject(_editHeaderExportOptions);

                var exportSettingsCheckbox = new Toggle({
                    type: "checkbox",
                    label: that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.exportSettings"),
                    value: that.options.appCore.i18nManager.get("eng.export.editHeaderTemplate.optionsHeader.exportSettings"),
                    domId: "exportedSettingsCheckbox"
                }).inject(_editHeaderExportOptions);

                previousSelectedOptions = that.appCore.exportService.getExportOptions();

                if (previousSelectedOptions != null) {
                    exportedOnCheckbox.checkFlag = previousSelectedOptions.ExportedOn;
                    exportedByCheckbox.checkFlag = previousSelectedOptions.ExportedBy;
                    noOfExportedItemsCheckbox.checkFlag = previousSelectedOptions.NoOfExportedItems;
                    fileNameCheckbox.checkFlag = previousSelectedOptions.FileName;
                    exportSettingsCheckbox.checkFlag = previousSelectedOptions.ExportSettings
                } else {
                    exportedOnCheckbox.checkFlag = userPreferedOptions.ExportedOn;
                    exportedByCheckbox.checkFlag = userPreferedOptions.ExportedBy;
                    noOfExportedItemsCheckbox.checkFlag = userPreferedOptions.NoOfExportedItems;
                    fileNameCheckbox.checkFlag = userPreferedOptions.FileName;
                    exportSettingsCheckbox.checkFlag = userPreferedOptions.ExportSettings;

                }



                var editTemplateDialogbox = new Dialog({
                    title: that.options.appCore.i18nManager.get("eng.export.editTemplateDialogboxTitle"),
                    content: _editHeaderTemplate,
                    immersiveFrame: immersiveFrame,

                    buttons: {

                        Cancel: new Button({
                            label: that.options.appCore.i18nManager.get("eng.ui.button.cancel"),
                            onClick: function(e) {
                                editTemplateDialogbox.immersiveFrame.getModel().elements.container.destroy();
                            }
                        }),

                        Ok: new Button({
                            label: that.options.appCore.i18nManager.get("eng.ui.button.save"),
                            onClick: function(e) {
                                var button = e.dsModel;
                                var myDialog = button.editTemplateDialogbox;

                                userPreferedOptions.FileName = fileNameCheckbox.checkFlag;
                                userPreferedOptions.ExportedOn = exportedOnCheckbox.checkFlag;
                                userPreferedOptions.ExportedBy = exportedByCheckbox.checkFlag;
                                userPreferedOptions.NoOfExportedItems = noOfExportedItemsCheckbox.checkFlag;
                                userPreferedOptions.ExportSettings = exportSettingsCheckbox.checkFlag;
                                var exportoptionsToSave = {};
                                exportoptionsToSave.FileName = userPreferedOptions.FileName;
                                exportoptionsToSave.ExportedOn = userPreferedOptions.ExportedOn;
                                exportoptionsToSave.ExportedBy = userPreferedOptions.ExportedBy;
                                exportoptionsToSave.NoOfExportedItems = userPreferedOptions.NoOfExportedItems;
                                exportoptionsToSave.ExportSettings = userPreferedOptions.ExportSettings;
                                that.appCore.exportService.saveExportOptions(exportoptionsToSave);

                                editTemplateDialogbox.immersiveFrame.getModel().elements.container.destroy();
                            }
                        })
                    }
                });

                editTemplateDialogbox.addEventListener("close", function(e) {
                    editTemplateDialogbox.immersiveFrame.getModel().elements.container.destroy();
                });
            }


            function getPreviewFormat() {

                var immersiveFrame = new ImmersiveFrame();
                immersiveFrame.inject(enoXExportOptions.modal.modal.elements.container);

                var previewFormatTemplateOptions = {
                    exportSettings: true,
                    exportTable: true
                };

                var previewFormatTemplate = Handlebars.compile(html_ExportEngineeringPreviewFormat);
                var _previewFormatTemplateOptions = previewFormatTemplateOptions ? UWA.clone(previewFormatTemplateOptions, false) : {};

                var _previewFormatTemplate = document.createElement(CONSTANT_WIDGET_DIV);
                _previewFormatTemplate.innerHTML = previewFormatTemplate(_previewFormatTemplateOptions);

                var _previewFormatContainer = _previewFormatTemplate.querySelector('.enox-export-preview-format');
                var _exportSettings = _previewFormatTemplate.querySelector('.enox-export-preview-format-export-settings');
                var _exportSettingsExportTable = _previewFormatTemplate.querySelector('.enox-export-preview-format-export-table');


                var ulTagForExportSettings = UWA.createElement(CONSTANT_WIDGET_UL);

                for (var property in previewFormatOptions) {
                    var liTagForExportSettings = UWA.createElement(CONSTANT_WIDGET_LI);
                    var spanTagForBoldHeader = UWA.createElement(CONSTANT_WIDGET_SPAN);
                    spanTagForBoldHeader.style.fontWeight = 'bold';
                    spanTagForBoldHeader.setText(property + ' : ')


                    var spanTagForNormalHeader = UWA.createElement(CONSTANT_WIDGET_SPAN);
                    spanTagForNormalHeader.setText(previewFormatOptions[property])

                    liTagForExportSettings.appendChild(spanTagForBoldHeader);
                    liTagForExportSettings.appendChild(spanTagForNormalHeader);


                    ulTagForExportSettings.appendChild(liTagForExportSettings);
                }
                _exportSettings.appendChild(ulTagForExportSettings);



                var parsedColumnsData = JSON.parse(userPreferedOptions.SelectedColumns);
                var selectedHeaderColumns = [];

                for (var property in parsedColumnsData) {
                    var jsonForSelectedHeaderColumns = {};
                    jsonForSelectedHeaderColumns.text = parsedColumnsData[property];
                    jsonForSelectedHeaderColumns.dataIndex = parsedColumnsData[property];
                    selectedHeaderColumns.push(jsonForSelectedHeaderColumns);
                }
                var dataGridView = new DataGridView({
                    columns: selectedHeaderColumns,
                    defaultColumnDef: { //Set default settings for columns
                        "width": "auto",
                        "typeRepresentation": "string"
                    }
                }).inject(_exportSettingsExportTable);
                dataGridView.elements.container.children[0].children[0].remove();
                var previewFormatDialogbox = new Dialog({
                    title: that.options.appCore.i18nManager.get("eng.export.previewFormat.dialogbox.title"),
                    content: _previewFormatTemplate,
                    width: 1100,
                    height: 350,
                    position: {
                        at: "center",
                        my: "center"
                    },
                    immersiveFrame: immersiveFrame,
                    resizableFlag: true,
                    buttons: {
                        Cancel: new Button({
                            label: that.options.appCore.i18nManager.get("eng.ui.button.cancel"),
                            onClick: function(e) {
                                previewFormatDialogbox.immersiveFrame.getModel().elements.container.destroy();
                            }
                        })
                    }
                });
                previewFormatDialogbox.elements._contentDiv.style.background = "white";
                previewFormatDialogbox.elements._contentDiv.style.display = "block";
                if (_exportSettings.children[0].childElementCount > 0) {
                    _exportSettingsExportTable.style.position = "absolute";
                    _exportSettingsExportTable.style.width = "calc(100% - 0.5em)";
                    _exportSettingsExportTable.style.height = "calc(100% - 10.2em)";
                    _exportSettingsExportTable.style.left = "-10px"
                    _exportSettingsExportTable.style.bottom = "0px"
                } else {
                    _exportSettingsExportTable.style.position = "absolute";
                    _exportSettingsExportTable.style.width = "calc(100% - 0.5em)";
                    _exportSettingsExportTable.style.height = "calc(100% - 1.7em)";
                    _exportSettingsExportTable.style.left = "-10px"
                }
                previewFormatDialogbox.addEventListener("close", function(e) {

                    previewFormatDialogbox.immersiveFrame.getModel().elements.container.destroy();

                });


            }


            enoXExportOptions.modal.getContent().getElements('.hover_info').forEach(function(element) {
                element.addEvent('mouseover', function(event) {

                    var title = this.title;

                    this.title = event.target.getText();
                    this.setAttribute("tooltip", title);
                })
            });


            var lineEditorPattern;
            enoXExportOptions.modal.getContent().getElements('.display_text').forEach(function(element) {
                element.addEvent('mouseenter', function(event) {

                    var textboxContainer = document.body.getElementsByClassName('enable_textbox')[event.target.id];
                    var existingValue = textboxContainer.getText();
                    textboxContainer.empty();
                    lineEditorPattern = new LineEditor({
                        value: existingValue,
                        sizeInCharNumber: 34,
                        selectAllOnFocus: true
                    }).inject(textboxContainer);
                })
            });

            enoXExportOptions.modal.getContent().getElements('.display_text').forEach(function(element) {
                element.addEvent('mouseleave', function(event) {

                    var textboxContainer = document.body.getElementsByClassName('enable_textbox')[event.target.id];
                    var containerWithLineEditor = textboxContainer.children;
                    if (containerWithLineEditor.length > 0) {
                        textboxContainer.empty(containerWithLineEditor);
                        if (lineEditorPattern.valueToCommit == "" || lineEditorPattern.valueToCommit == null) {
                            textboxContainer.setText(enoXExportOptions._columnsOrderNlsJson[event.target.id]);
                        } else {
                            lineEditorPattern.value = lineEditorPattern.valueToCommit;
                            textboxContainer.setText(lineEditorPattern.value);
                        }
                    };
                })
            });

            enoXExportOptions.modal.modal.elements.header.getChildren()[0].addEvent('click', function() {
                userPreferedOptions = {};
                enoXExportOptions.modal.destroy()
            });

            enoXExportOptions.unselectQuantityColumn();

            enoXExportOptions._GroupByOptionsList.addEventListener("change", checkCombobox);

            function checkCombobox(options) {
                if (enoXExportOptions._GroupByOptionsList.value == XEngineerConstants.NOT_GROUPED) {
                    enoXExportOptions.unselectQuantityColumn();
                    enoXExportOptions.enableDeclaredQuantity();
		    enoXExportOptions.selectInstanceName();
                } else {
                    enoXExportOptions.selectQuantityColumn();
                    enoXExportOptions.disableDeclaredQuantity();
		    enoXExportOptions.unselectInstanceName();
                }
            }
            enoXExportOptions.modal.show();
        }
    });

    return exportEngineeringItems;
});



define('DS/ENOXEngineer/commands/OpenEngineeringItemCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/ENOXEngineer/utils/XEngineerConstants'
], function(
  XEngCommandBase,
  xEngAlertManager,
  PromiseUtils,
  XEngineerConstants
) {

    'use strict';

    var OpenEngineeringItemCmd =  XEngCommandBase.extend({

      init: function(options){
        this._parent(options);
      },
      execute : function(options){
        var that = this;
        this.end();
        function isvalidContext(ctx){
          if(!ctx) return false;

          return (ctx.searchForOpen  || (ctx.objectId && ctx.objectType))

          return false;
        }

        var openContext = this.appCore.sessionManager.consummeAvailableOpencontext();
        if(isvalidContext(openContext)){

          if(openContext.searchForOpen){
            this.appCore.dataService.searchManager.launchASearch({
            	title: that.appCore.i18nManager.get("eng.searchResult.OpenEngItem"),
              allowedTypes:['VPMReference'],
              role : '',
              criteria : '',
              multiSel : false,
              in_apps_callback : that.onSelectedFromSearch.bind(that)
            });
          } else if(openContext.objectId && openContext.objectType){
            that.launchOpenItem(openContext);
          }

        }else{ // invalid context
          xEngAlertManager.errorAlert(this.appCore.i18nManager.get('error.invalid.input.forOpen'))
        }

      },
      onSelectedFromSearch : function(selectedObj){
        var that = this;
        that.launchOpenItem({
          objectId: selectedObj[0]["id"],
          objectType: selectedObj[0]["ds6w:type_value"]
        });
        

      },
      launchOpenItem: function(ctx){
        if(!ctx) return ;
        switch (ctx.objectType) {
          case "ENOStrRefinementSpecification":
            this.openAdvancedFilter(ctx);
            break;
        
          default:

            if(ctx.itemListModel && ctx.itemListModel.hasStaticMapping()){
              var that = this;

               ctx.path = [this.appCore.contextManager.getActiveEngItem().getID(),
                           ctx.itemListModel.getRelationID(),
                            ctx.objectId ];
               this.appCore.dataService.getModelVersionInformationFromPCID([ctx.itemListModel.getConfigurationID()])
                              .then(function(result){
                                console.warn(result);
                                //openProductConf
                                //write a method to getMapping information as requested in preferencemanager
                                result = that._getStaticMappingInfo(result);
                                ctx.pcInfo = result;

                              that.genericOpen(ctx);
              });

              break;
            }else{
              this.genericOpen(ctx);
              break;

            }

        }

      },
      _getStaticMappingInfo: function(pcInfo){
        if(Array.isArray(pcInfo) && !pcInfo.length>0){
          return null;
        }

         var pcInfoResult ={
           model:pcInfo[0].BASED_ON_MODEL_PID,
           modelVersion: pcInfo[0].BASED_ON_MODEL_VERSION_PID,
           prodConf:pcInfo[0].physicalid,
           confLabel:pcInfo[0]["ds6w:label"],
           type:pcInfo[0].type,
           resourceid:pcInfo[0].resourceid,
           revision:pcInfo[0]["ds6wg:revision"]
         }
        return pcInfoResult;
      },
      _getBIFilterProxy: function(){
          var collection  = this.appCore.contextManager.getXENTreeDocument();
          return (collection) ? collection.getXENBIFilterProxy() : null;
      },
      _previousFilterCleanup: function(){
        var that = this;
        var filterBI = this._getBIFilterProxy();
        return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){

          if(that.appCore.sessionManager.isWorkingAnEngItem()){
            try {
                var currentEngItem = that.context.getActiveEngItem();

                if(currentEngItem &&(currentEngItem.hasValidPersistedNextGenFilter() ||
                                    currentEngItem.hasValidTransientNextGenFilter()
                                    )){

                  filterBI.resetNGFilterUI({
                    widgetId : that.appCore.settingManager.getWidgetId(),
                    rootIds:(that.context.getActiveEngItem() ) ? [that.context.getActiveEngItem().getID()] : []
                  });
                  setTimeout(function(){
                    resolve(true);
                  },100); //give the time for filter to be cleanedUp

                }else{
                  return resolve(false);
                }
            } catch (error) {
              console.error(error);
              reject(false);
            }
            
        }else{
          resolve(true);
        }

        });
      },
      openAdvancedFilter: function(ctx){
        var filterBI = this._getBIFilterProxy();
        var that = this;
        if(filterBI){
          
          that._previousFilterCleanup().finally(function(){
                that.context.beginBlockingTransaction(that.appCore.i18nManager.get("processing.ngFilter"));
                filterBI.retrieveFilters({
                  filterObjects:[{envId: that.appCore.settingManager.getPlatformId()}],
                  filterIds:[ctx.objectId],
                  droppedEnvId: that.appCore.settingManager.getPlatformId(),
                  doNotFillTheTagger: false,
                  callback: function(data){
                    that.context.endBlockingTransaction()
                    if(data && Array.isArray(data.success)&& data.success.length>0){
                      if(that.appCore.sessionManager.isWorkingAnEngItem()){
                        var currentEngItem = that.context.getActiveEngItem();
                        //when dropping the same filter or filter of same root
                        if(currentEngItem && currentEngItem.getID()=== data.success[0].rootId){

                          return that.appCore.sessionManager.refreshWithDroppedFilter(data.success);
                        }
                      }
                      that.appCore.sessionManager.openSessionFromDroppedFilter(data.success);
                    }
                  }
                });

          });


        }else{
          console.error('nextNenFilter proxy not found');
          
        }
      },
      genericOpen: function(ctx){
        var that = this;
        this.appCore.dataService.areEngeeringItems([ctx.objectType])
                    .then(function(){

                      if(ctx.path && ctx.pcInfo){
                         that.navigateToConfiguredEngItemViewer(ctx);
                      }else{
                         that.navigateToEngItemViewer(ctx.objectId);
                      }

                    }).catch(function(reason){
                      xEngAlertManager.errorAlert(this.appCore.i18nManager.get("trying.toopen.not.engineering.item"))
                    });
      },
      //move it to sessionManager
      navigateToEngItemViewer: function(pid){
        this.appCore.navigate('engItem_View',{pid:pid},{replace: false,reload: true});
      },
      navigateToConfiguredEngItemViewer: function(ctx){
        this.appCore.navigate('engItem_View',{pid:ctx.objectId, path:ctx.path, pcInfo:ctx.pcInfo},{replace: false,reload: true});
      }
    });

    return OpenEngineeringItemCmd;

});

 define('DS/ENOXEngineer/commands/ChangeMaturityBulkCmd', [
   'UWA/Core',
   'DS/ENOXEngineer/commands/XEngineerCommandBase',
   'DS/ENOXEngineer/utils/XEngineerConstants',
 ], function (
   UWA,
   XEngCommandBase,
   XEngineerConstants
 ) {
   'use strict';
   var launchChangeMaturityBulkCmd = XEngCommandBase.extend({
     init: function (options) {
    	 /*
       options = UWA.extend(options, {
         isAsynchronous: false
       });
       */
       this._parent(options);
     },

     execute: function (params) {
       var that = this;
       
       
		var selectedItems = this.options.context.getSelectedNodes();
		var selectedItem = null;
		if (selectedItems.length >= 1) {
			selectedItem = selectedItems[0];
		}
       
       that.options.expandPromise = new Promise(function(resolve, reject) {
    	          that.options.appCore.dataService.getEngItemStructure(selectedItem.getID(), null)
    	            .then(function(instances) {
    	            	
    	            	var nodes = [];
    	            	nodes.push(selectedItem);
    	            	instances.forEach(function(instance){
    	            		nodes.push(instance);
    	            	});
    	            	
    	            	
    	            	that.options.context._app.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
    	                    commandId: XEngineerConstants.MATURITY_GRAPH_CMD,
    	                    context: {
    	                        item : nodes
    	                    }
    	                });
    	                
    	             // that.setInstances(instances);
    	              resolve(instances);
    	            }).catch(function(error) {
    	              console.error(error);
    	              reject(error);
    	            });
    	    });

     },

     destroy :function(){

     },

   });
   return launchChangeMaturityBulkCmd;
 });

/**
 * @module DS/ENOXEngineer/commands/AddNewDocumentsCmd
 */
define('DS/ENOXEngineer/commands/AddNewDocumentsCmd', [
  'UWA/Core',
  'DS/ENOXEngineer/commands/XEngineerCommandBase'
], function(UWA, XEngCommandBase) {

    'use strict';

   /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/commands/AddNewDocumentsCmd
     * @param {Object} options options hash or a option/value pair.
     */
     var AddNewDocumentsCmd = XEngCommandBase.extend(
        /**
         * @lends module:DS/ENOXEngineer/commands/AddNewDocumentsCmd.prototype
         */
        {

        execute: function(){
          var nodes = this.context.getSelectedNodes();
          if(Array.isArray(nodes) && nodes.length===1){
            this.appCore.dataService.addNewDocumentToEngItem({
              targetObjID: nodes[0].getID()
            });
          }

          this.end();
          
        }

    });

    return AddNewDocumentsCmd;
});

/**
 * @overview Search provides the ability to search using Universal Search widget and adapt it to the context of our App widget.
 * @licence Copyright 2017 Dassault Systèmes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOXEngineer/utils/Search',
   [
      'UWA/Core',
      'UWA/Utils/InterCom',
      'DS/ENOXEngineer/utils/Utils',
      'DS/ENOXEngineer/services/EngineeringSettings'
   ],

   function (Core, InterCom, Utils, EngineeringSettings)
   {
      'use strict';

      var Search = function (options) {
         this.socketName = 'search_socket_' + (new Date()).getTime();
         this.socket = new InterCom.Socket(this.socketName, { dispatchRetryInterval: 5 });
         this.socket.subscribeServer('SearchComServer');
         this.listener = this.objectsSelected.bind(this);
         this.socket.addListener('Selected_Objects_search', this.listener);
         this.defaultOptions = options;

           this.defaultOptions  ={
             multiSel : true,
             source : ["3dspace"]
           };
        Core.extend(this.defaultOptions, options||{});


         //var options = this.options("");
         //this.socket.dispatchEvent('RegisterContext', options);
      };

      Search.prototype.options = function (title, types, role, defaultSearchCriteria, multiSel, precondition) {
         var opts = {};
         opts.title = title;
         opts.mode = "furtive"; // furtive means with an OK & Cancel buttons
         opts.app_socket_id = this.socketName; // name of the socket for communication
         opts.widget_id = widget.id; // our widget id
         opts.default_with_precond = true; // will use a precondition
         opts.multiSel =  multiSel ;
         opts.source = this.defaultOptions.source || [];
         opts.tenant = EngineeringSettings.getPlatformId();
         opts.role = role; // role used when performing the query
         if (Array.isArray(types)) {
            opts.precond = "";
            types.forEach(function (item, index) {
               if (index !== 0) {
                  opts.precond += ' OR ';
               }
               opts.precond += 'flattenedtaxonomies:"types/' + item + '"';
            });
         }

         if(opts.precond && opts.precond!==""){
           opts.precond = '('+opts.precond+')';

         }
         if(precondition && opts.precond){
           opts.precond ='('+opts.precond+' AND '+precondition+')';
         }
         if (defaultSearchCriteria && defaultSearchCriteria.trim()!=="") {
            opts.default_search_criteria = defaultSearchCriteria;
         }
         // else if (opts.precond) {
         //
         //   console.warn(opts.precond);
         //   opts.default_search_criteria = opts.precond;
         // }

         return (opts);
      };

      Search.prototype.destroy = function () {
         var optionsUnregister = {};
         optionsUnregister["widget_id"] = widget.id;
         this.socket.dispatchEvent('unregisterSearchContext', optionsUnregister);
         this.socket.unsubscribeServer('SearchComServer');
         this.socket.removeListener('Selected_Objects_search', this.listener);
         this.socket.disconnect();
         delete this.socket;
      };

      Search.prototype.activate = function (title, types, role, defaultSearchCriteria, multiSel, precondition, callback) {
         var options = this.options(title, types, role, defaultSearchCriteria, multiSel, precondition);
         if (!UWA.is(callback, 'function')) {
            options.mode = 'default';
         }
         this.callback = callback;
         this.socket.dispatchEvent('unregisterSearchContext', { widget_id: widget.id });
         this.socket.dispatchEvent('RegisterContext', options);
         this.socket.dispatchEvent('InContextSearch', options);
      };

      Search.prototype.isAvailable = function () {
         return (UWA.is(this.socket));
      };

      Search.prototype.launchASearch = function(options){
        var that =this;
        if (that.isAvailable()) {
          if(options.multiSel ===undefined || options.multiSel ===null) options.multiSel = this.defaultOptions.multiSel || true;
            that.activate(options.title|| "", options.allowedTypes|| "VPMReference", options.role || ''/*role*/, Utils.getAugmenttedQueryForSearch(options.criteria), options.multiSel, options.precondition  , function (results) {
               options.in_apps_callback(results);
            });
        }
      }

      Search.prototype.objectsSelected = function (parameters) {
         if (this.callback) {
            this.callback(parameters);
         }
      };

      return Search;

   });

define('DS/ENOXEngineer/commands/DownloadDocumentCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'DS/ENOXEngineer/utils/Search',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'UWA/Class/Promise',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(
  XEngCommandBase,
  Search,
  Utils,
  XEngineerConstants,
  Promise,
  nlsKeys
) {

    'use strict';

    var Command =  XEngCommandBase.extend({

      init: function(options){
        this._parent(options);
      },
      execute : function(options){
        var that = this;
        this.end();
        
        var nodes = this.appCore.contextManager.getSelectedNodes();
        
        
    	this.appCore.mediator.publish(XEngineerConstants.EVENT_DOWNLOAD_ITEM, {
			nodes : nodes
		});
    	
    	
    	/*
        if (nodes.length === 1){
        	this.appCore.mediator.publish(XEngineerConstants.EVENT_DOWNLOAD_ITEM, {
    			cellModel : nodes[0]
    		});
        }
        */
      }
    });

    return Command;

});

define('DS/ENOXEngineer/commands/SetProdConfCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'DS/ENOXEngineer/utils/Search',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/ResponseParser',
  'DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
  'DS/ENOXEngineer/componentsHelpers/XEngAutoComplete/XEngAutoComplete',
  'DS/ENOXEngineer/componentsHelpers/ModelChooser/XEngModelChooser',
  'DS/UIKIT/Input/Text',
  'DS/UIKIT/Input/Toggle',
  'UWA/Class/Promise',
  'DS/UIKIT/Spinner',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(
  XEngCommandBase,
  Search,
  Utils,
  ResponseParser,
  XEngineerModal,
  XEngAutoComplete,
  XEngModelChooser,
  Text,
  Toggle,
  Promise,
  Spinner,
  XEngineerConstants,
  nlsKeys
) {

    'use strict';

    var SetProdConfCmd =  XEngCommandBase.extend({

      init: function(options){
        var that = this;
        this._parent(options);
        this.search = new Search({multiSel : false});
      },

      _buildModal : function(){
        this.modal = new  XEngineerModal({
          title : this.options.appCore.i18nManager.get("eng.ui.dialog.selectProdConf"),
          className : 'xeng-auto-complete',
          withFooter : true
        });

        return this.modal;
      },
      _configModelMapper : function(confFromSearch){
        return {
          label : confFromSearch["ds6w:label"],
          value : confFromSearch.physicalid || confFromSearch.resourceid  ,
          icon : Array.isArray(confFromSearch.icons) ? confFromSearch.icons[0] : confFromSearch.type_icon_url
        };
      },
      _updateConfigurationContext : function(){
        var that = this;
        var selecteds = that.autocomplete.selectedItems;
        var selectedConf = selecteds[0] ? selecteds[0].value : null;
        var currentModel = that.context.getActiveEngItem().getPreferedAttachedConfigModel() && that.context.getActiveEngItem().getPreferedAttachedConfigModel() ? that.context.getActiveEngItem().getPreferedAttachedConfigModel() : null;
        var currentProdConfID = currentModel.getPreferredConfiguration() ? currentModel.getPreferredConfiguration().id  : null;
        if(selectedConf === currentProdConfID){
          that.destroyView();
          return null;
        }
        if(currentModel){
        	
          currentModel.setPreferredConfiguration(selectedConf|| 'N/A')
                    .then(function(){
                      //update of user preference after switch of prod conf
                      that.options.appCore.mediator.publish(XEngineerConstants.EVENT_CONF_MODEL_UPDATED, that.context.getActiveEngItem().getID());
                      that.alertManager.sucessAlert(nlsKeys.get("eng.operation.prodConfUpdated.sucess"));
                      that.destroyView();
                    }).catch(function(reason){
                      console.error(reason);
                      that.alertManager.errorAlert(nlsKeys.replace(nlsKeys.get("error.operation.failed"),{
                        operation: that.options.appCore.i18nManager.get("eng.operation.editConfCxt"),
                        error: JSON.stringify(reason)
                      }));
                      that.destroyView();
                    });
        }




      },
      destroyView : function(){
        var that = this;
        that.autocomplete && that.autocomplete.destroy();
        that.autocomplete = undefined;
        that.modal.destroy();
        that.modal = undefined;
      },
      buildView : function(){
        var that = this;
        this._getConfView().inject(this._buildModal().getBody());
        this.modal.onValidate(function(finish){
          that._updateConfigurationContext(finish);
          that.end();
        }, this);

        this.modal.onClose(function(){
          that.destroyView();
          that.end();
        }, this);

      },
      _getConfView : function(){
    	  var that = this;
        this.autocomplete = new XEngAutoComplete({
          placeholder : this.options.appCore.i18nManager.get("eng.ui.autocomplete.conf.placeholder"),
          multiSelect : false,
          datasetName : 'xeng_prodConf',
          precondition : this.getPrecondition() ? this.getPrecondition() : null ,
          targetTypes : ["Product Configuration"],
          appCore : this.options.appCore,
          objectMapper : this._configModelMapper.bind(this)
        });

        this.autocomplete.onSearchClick = this.launchASearch.bind(this);

        return this.autocomplete;
      },
      execute : function(options){
        var that = this;
        if(!this.modal){
          this.buildView();
        }
        var currentModel = that.context.getActiveEngItem().getPreferedAttachedConfigModel() && that.context.getActiveEngItem().getPreferedAttachedConfigModel() ? that.context.getActiveEngItem().getPreferedAttachedConfigModel() : null;
        var currentProdConf = currentModel.getPreferredConfiguration() ? currentModel.getPreferredConfiguration()  : null;
        if(currentProdConf){

          var defaultSelected = {
            label : currentProdConf.name,
            value : currentProdConf.id ,
            icon : []
          };
          that.autocomplete.setSelection([defaultSelected]);

        }

        this.modal.show();


      },
      getPrecondition : function(){
        var that =this;
        var currentModel = that.context.getActiveEngItem() && that.context.getActiveEngItem().getPreferedAttachedConfigModel()  ? that.context.getActiveEngItem().getPreferedAttachedConfigModel() : null;
        if(!currentModel) return null;

        var modelID = currentModel.getID();
		var modelVersionID = currentModel.getCurrentVersionID();


        return " [BASED_ON_MODEL_VERSION_PID]:\"" + modelVersionID + "\" " ;

      },
      launchASearch :  function(criteria){
        var query = criteria;
        var that = this;
        var precondition = that.getPrecondition() ;
        if(criteria.trim()==="")
          query = null;

        this.options.appCore.dataService.searchManager.launchASearch({
        	title: this.options.appCore.i18nManager.get("eng.searchResult.ConfigurationFilter"),
        	allowedTypes:['Product Configuration'],
          role : '',
          criteria : query,
          precondition : precondition,
          multiSel : false,
          in_apps_callback : this.onSelectedFromSearch.bind(this)
        });

      },
      onSelectedFromSearch : function(selectedObj){
      
        if(!this.context.getActiveEngItem()){
            this.alertManager.errorAlert(this.options.appCore.i18nManager.get("error.noActiveEngineeringItem"));
            throw new Error("this command should be launch in context of active engineering Item");
        }

        var  that = this;
        var mappedItem = this._configModelMapper(selectedObj[0]);
        that.autocomplete.setSelection([mappedItem]);
      }
    });

    return SetProdConfCmd;

});

define('DS/ENOXEngineer/commands/DeleteDocumentCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'DS/ENOXEngineer/utils/Search',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'UWA/Class/Promise',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(
  XEngCommandBase,
  Search,
  Utils,
  XEngineerConstants,
  Promise,
  nlsKeys
) {

    'use strict';

    var Command =  XEngCommandBase.extend({

      init: function(options){
        this._parent(options);
      },
      execute : function(options){
        var that = this;
        this.end();
        
        var nodes = this.appCore.contextManager.getSelectedNodes();
        
        /*
        if (nodes.length === 1){
        	this.appCore.mediator.publish(XEngineerConstants.EVENT_DELETE_DOCUMENT, {
				cellModel : nodes[0]
			});
        }
        */
        
    	that.appCore.mediator.publish(XEngineerConstants.EVENT_DELETE_DOCUMENT, {
			nodes : nodes
		});
      }
    });

    return Command;

});

define('DS/ENOXEngineer/commands/ChangeMaterialQuantityCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'DS/ENOXEngineer/utils/Search',
  'DS/ENOXEngineer/utils/Utils',
  'UWA/Class/Promise',
  'DS/UIKIT/Input/Number',
  'DS/UIKIT/Input/Select',
  'DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineer/services/EngineeringSettings',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/UIKIT/Input/Button',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(
  XEngCommandBase,
  Search,
  Utils,
  Promise,
  Number,
  Select,
  XEngineerModal,
  XEngineerConstants,
  EngineeringSettings,
  PromiseUtils,
  Button,
  xEngAlertManager,
  nlsKeys
) {

    'use strict';

    var AddNewMaterialQuantityCmd =  XEngCommandBase.extend({

      init: function(options){
        this._parent(options);
        this.selectedItem = null;

      },
      _buildModal : function(){
    	  
    	  var quantityInLiter = Utils.convertVolumeInIUForDisplay(this.quantity);
    	  var materialName = this.selectedItem.getAttributeValue("CoreMaterial");
    	  var engItemName = this.selectedItem.getDisplayName();

    	  
          this.modal = new  XEngineerModal({
            title : this.options.appCore.i18nManager.replace( this.options.appCore.i18nManager.get("eng.ui.dialog.changeMaterialQuantity"),{
            	EngItem:engItemName,
            	mat:materialName + " : " + quantityInLiter
            }),
            className : 'change-material-quantity-dlg',
            withFooter : true
          });

          return this.modal;
        },
        
        destroyView : function(){
            var that = this;
            that.modal.destroy();
            that.modal = undefined;
          },
          
      execute : function(options){
        var that = this;
        
		var selectedItems = this.options.context.getSelectedNodes();
		
		if (selectedItems.length !== 1){
			xEngAlertManager.notifyAlert(that.appCore.i18nManager.get("eng.materialQuantity.notif.multiselection"));
			this.end();
			return;
		}
			
		if (selectedItems.length >= 1) {
			 this.selectedItem = selectedItems[0];
		}
		
		
		
		if (this.selectedItem.isMaterialQuantity()){
			
			this.quantity = parseFloat(this.selectedItem.options.grid["ds6wg:MaterialUsageExtension.DeclaredQuantity"]);
			
	        if(!this.modal){
	            this.buildView();
	          }
	        this.modal.show();
		}


      },
      buildView: function(){
    	  var that = this;
    	  this._buildModal();
    	  var defaultUoM = "L";
    	  
    	  var quantityInLiter = Utils.convertVolumeInIUTo(this.quantity, defaultUoM).toString();

    	  
    	  var group = document.createElement("div");     
    	  group.className = "input-group";
    	  
    	  var addon = document.createElement("span");     
    	  addon.className = "input-group-btn";
    	  
    	  var options1 = [];
			var volumeUnitOfMeasure = this.appCore.settingManager.getSetting("volumeUnitOfMeasure");
			for (var key in volumeUnitOfMeasure){
				options1.push({ text: volumeUnitOfMeasure[key].nls, selected: key === defaultUoM ? true : false});
			}
    	  
			this.unitInput = new Button({
  		    value: defaultUoM,
  		    dropdown: {
  		        items: options1
  		    }
			}).inject(addon);
    	  
    	  
			this.unitInput.addEvent('onDropdownClick', function (e, item) {
    		  this.setValue(item.text);
    		});

    	  this.quantityInput = document.createElement("input");   
    	  this.quantityInput.className = "form-control";
    	  this.quantityInput.type = "number";
    	  this.quantityInput.placeholder = "Enter a number...";
    	  this.quantityInput.value = quantityInLiter;
    	  this.quantityInput.min = 0;
    	  
    	  
    	  group.appendChild(this.quantityInput);
    	  group.appendChild(addon);
    	  
    	  this.modal.getBody().appendChild(group); 
    	  

          this.modal.onValidate(function(finish){
        	  
              that.value = this.quantityInput.valueAsNumber;
              
              
              if (isNaN(that.value) || that.value < 0){
              	
              } else {
                  that.unit = this.unitInput.getValue();
                  
                  that._modifyQuantity(finish);
                  
                  that.destroyView();
                  that.end();
              }

          }, this);

          this.modal.onClose(function(){
            that.destroyView();
            that.end();
          }, this);

      },
      _modifyQuantity: function(value){
    	  
    	  var that = this;
    	  that._setQuantityOfMaterial();
  
      },
      _getQuantityInInternationalUnit: function(){
    	  var f_quantity = parseFloat(this.value);   
    	  var f_quantityInternational = Utils.convertVolumeToInternationalUnit(f_quantity, this.unit)
    	  return f_quantityInternational.toString();
      },

      _setQuantityOfMaterial: function(){
var that = this;

              var nodeCellFake = {nodeModel:this.selectedItem};
              this.appCore.dataService.updateAttr(nodeCellFake, this._getQuantityInInternationalUnit(), "MaterialUsageExtension.DeclaredQuantity", "MaterialUsageExtension.DeclaredQuantity").then(function(res){
            	  that.appCore.sessionManager.setAuthoringMode('authoring');
                  that.appCore.mediator.publish(XEngineerConstants.EVENT_EDIT_MATERIAL_QTY_COMPLETED, res);
              }).catch(function(errors){
              });

      }
    });

    return AddNewMaterialQuantityCmd;

});

define('DS/ENOXEngineer/commands/EditConfigurationContextCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'DS/ENOXEngineer/utils/Search',
  'DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
  'DS/ENOXEngineer/componentsHelpers/XEngAutoComplete/XEngAutoComplete',
  'DS/ENOXEngineer/componentsHelpers/ModelChooser/XEngModelChooser',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/UIKIT/Spinner',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function (
  XEngCommandBase,
  Search,
  XEngineerModal,
  XEngAutoComplete,
  XEngModelChooser,
  XEngineerConstants,
  Spinner,
  nlsKeys
) {

  'use strict';

  var SetAttachedModelCmd = XEngCommandBase.extend({

    init: function (options) {
      var that = this;
      this._parent(options);
      this.search = new Search({
        multiSel: false
      });
    },

    _buildModal: function () {
      this.modal = new XEngineerModal({
        title: this.options.appCore.i18nManager.get("eng.ui.dialog.attachModel"),
        className: 'xeng-auto-complete',
        withFooter: true
      });

      return this.modal;
    },

    _configModelVersionMapper: function (modelFromSearch) {
        return {
          label: modelFromSearch["ds6w:label"] + " " + modelFromSearch["ds6wg:revision"],
          id: modelFromSearch.physicalid || modelFromSearch.resourceid,
          value: modelFromSearch.physicalid || modelFromSearch.resourceid,
          revision: modelFromSearch["ds6wg:revision"],
          name: modelFromSearch["ds6w:identifier"],
          attributes: {MarketingName: modelFromSearch["ds6w:label"] + " " + modelFromSearch["ds6wg:revision"]},
          icon: Array.isArray(modelFromSearch.icons) ? modelFromSearch.icons[0] : modelFromSearch["type_icon_url"]
        }
      },

    _configModelMapper: function (modelFromSearch) {
      return {
        label: modelFromSearch["ds6w:label"] + " " + modelFromSearch["ds6wg:revision"],
        value: modelFromSearch.physicalid || modelFromSearch.resourceid,
        icon: Array.isArray(modelFromSearch.icons) ? modelFromSearch.icons[0] : modelFromSearch["type_icon_url"]
      }
    },
    _updateConfigurationContext: function () {
      var okBtn = document.body.querySelector("button[name=\"okButton\"]");
      this.spinner = new Spinner().inject(okBtn).show();
      okBtn.disabled = true;
      var that = this;
      var selectedModelVersion = that.autocomplete.selectedItems;
      var selectedModelVersionID = selectedModelVersion[0] ? selectedModelVersion[0].value : null;
      // var currentModelId = that.context.getActiveEngItem().getPreferedAttachedConfigModel() && that.context.getActiveEngItem().getPreferedAttachedConfigModel().getID() ? that.context.getActiveEngItem().getPreferedAttachedConfigModel().getID() : null;

      if (that.context.getActiveEngItem().hasValidConfigContext() === true){
    	  var currentModelVersionID = that.context.getActiveEngItem().getPreferedAttachedConfigModel().getPreferredVersion().id;
    	  if (selectedModelVersionID === currentModelVersionID) {
    	        that.destroyView();
    	        return null;
    	        }
    	  }





      that.options.appCore.dataService.getModelItemFromAVersion(selectedModelVersionID)
      .then(function (response) {

    	  var selectedModelID = null;
    	  if (response && response.member && response.member.length > 0)
    		  selectedModelID = response.member[0].modelID;


    	  var parameters = {
    		        activeEngItem: that.context.getActiveEngItem(),
    		        selectedModel: selectedModelID,
    		        selectedModelVersion: selectedModelVersionID
    		      };

    		      that.options.appCore.dataService.updateEngineeringItemConfigContext(parameters)
    		        .then(function (response) {
                  var payload = {
                    id:selectedModelVersionID
                  };
    		          if (!selectedModelVersionID) { //to update the preferences
                    payload = null;
    		          }
    		          okBtn.disabled = false;
    		          that.context.getActiveEngItem()._syncWithAttachedModelAndVersion(payload).finally(function () {
                    that.options.appCore.mediator.publish(XEngineerConstants.EVENT_CONF_MODEL_UPDATED, that.context.getActiveEngItem().getID());
    		          });
    		          that.spinner.destroy();
    		          that.destroyView();
    		          //update IDcard view
    		        }).catch(function (error) {that._cancelWithError(error);});


      }).catch(function (error) {that._cancelWithError(error);});
    },
    _cancelWithError: function(error){
    	document.body.querySelector("button[name=\"okButton\"]").disabled = false;
    	console.error(error);
    	if (this.spinner) this.spinner.destroy();
    	this.alertManager.errorAlert(nlsKeys.replace(nlsKeys.get("error.operation.failed"), {
            error: error,
            operation: this.options.appCore.i18nManager.get("eng.operation.editConfCxt")
          }));
    	this.destroyView();
    },
    destroyView: function () {
      var that = this;
      that.autocomplete && that.autocomplete.destroy();
      that.autocomplete = undefined;
      that.modal.destroy();
      that.modal = undefined;
    },
    buildView: function () {
      var that = this;
      this._editionView().inject(this._buildModal().getBody());
      this.modal.onValidate(function (finish) {
        that._updateConfigurationContext(finish);
        that.end();
      }, this);

      this.modal.onClose(function () {
        that.end();
      }, this);

    },
    _editionView: function () {
      this.autocomplete = new XEngAutoComplete({
        placeholder: this.options.appCore.i18nManager.get("eng.ui.autocomplete.placeholder"),
        multiSelect: false,
        datasetName: 'xeng_model',
        targetTypes: ["Products"],
        appCore: this.options.appCore,
        objectMapper: this._configModelMapper.bind(this)
      });

      this.autocomplete.onSearchClick = this.launchASearch.bind(this);

      return this.autocomplete;
    },

    _setCommandMode: function () {
      var targetObj = this.context.getActiveEngItem();
      if (targetObj.isConfigured() && targetObj.getAttachedConfigModels().length > 1) {
        this.editMode = false;
      } else {
        this.editMode = true;
      }

    },
    buildEditionView: function () {
      var that = this;
      if (!this.modal) {
        this.buildView();
      }
      var currentModel = that.context.getActiveEngItem() && that.context.getActiveEngItem().getPreferedAttachedConfigModel() ? that.context.getActiveEngItem().getPreferedAttachedConfigModel() : null;
      var currentVersion = (currentModel) ?  currentModel.getPreferredVersion() : null;
      if (currentModel && currentVersion && currentVersion.id) {

        var defaultSelected = {
          label: currentModel.getCurrentVersionDisplayMarketingName(),
          value: currentVersion.id,
          icon: currentModel.getIcon() //to change
        };
        that.autocomplete.setSelection([defaultSelected]);
      } else {
    	  that.autocomplete.reset();
      }
      this.modal.show();
    },
    buildSelectionView: function () {
      var that = this;
      var currentModel = that.context.getActiveEngItem() && that.context.getActiveEngItem().getPreferedAttachedConfigModel() ? that.context.getActiveEngItem().getPreferedAttachedConfigModel() : null;

      var preferredVersion = undefined;
      if (currentModel) {
        preferredVersion = (currentModel.getPreferredVersion()) ? currentModel.getPreferredVersion().id : undefined;
      }
      var options = {
        appCore: this.options.appCore,
        preferred: preferredVersion,
        modelsPromises: that.context.getActiveEngItem().getAllAvailableVersionsPromises(),
        resolve: this._onModelChoosen.bind(this),
        reject: this._onModelUnChoosen.bind(this)
      };

      this.modelChooser = new XEngModelChooser(options);
    },
    _onModelChoosen: function (version) {
      var that = this;
      that.end();
      var currentEngItem = this.context.getActiveEngItem();
      //important step
      currentEngItem.setPreferredModelById(version.options.modelId);
      if(currentEngItem.getPreferedAttachedConfigModel()){
        currentEngItem.getPreferedAttachedConfigModel()._synchronizeModelVersions({
          id: version.options.physicalid
        }).finally(function () {
          that.options.appCore.mediator.publish(XEngineerConstants.EVENT_CONF_MODEL_UPDATED, that.context.getActiveEngItem().getID());
        });
      }
    },
    _onModelUnChoosen: function (reason) {
      var that = this;
      that.end();
    },
    execute: function (options) {
      var that = this;
      this._setCommandMode();

      if (this.editMode) {
        return this.buildEditionView();
      }

      return this.buildSelectionView();

    },
    launchASearch: function (criteria) {
      var query = criteria;
      if (criteria.trim() === "")
        query = null;

      this.options.appCore.dataService.searchManager.launchASearch({
    	  title: this.options.appCore.i18nManager.get("eng.searchResult.configurationContext"),
    	  allowedTypes: ['Products'],
        role: '',
        criteria: query,
        multiSel: false,
        in_apps_callback: this.onSelectedFromSearch.bind(this)
      });

    },
    onSelectedFromSearch: function (selectedObj) {
      if (!this.context.getActiveEngItem()) {
        this.alertManager.errorAlert(this.options.appCore.i18nManager.get("error.noActiveEngineeringItem"));
        throw new Error("this command should be launch in context of active engineering Item");
      }

      var that = this;
      var mappedItem = this._configModelVersionMapper(selectedObj[0]);
      that.autocomplete.setSelection([mappedItem]);
    }
  });

  return SetAttachedModelCmd;

});

define('DS/ENOXEngineer/commands/DetachDocumentCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'DS/ENOXEngineer/utils/Search',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'UWA/Class/Promise',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(
  XEngCommandBase,
  Search,
  Utils,
  XEngineerConstants,
  Promise,
  nlsKeys
) {

    'use strict';

    var Command =  XEngCommandBase.extend({

      init: function(options){
        this._parent(options);
      },
      execute : function(options){
        var that = this;
        this.end();
        
        var nodes = this.appCore.contextManager.getSelectedNodes();
        
        /*
        nodes.forEach(function(node){
        	that.appCore.mediator.publish(XEngineerConstants.EVENT_REMOVE_DOCUMENT, {
				cellModel : node
			});
        });
        
        
        if (nodes.length === 1){
        	this.appCore.mediator.publish(XEngineerConstants.EVENT_REMOVE_DOCUMENT, {
				cellModel : nodes[0]
			});
        }
        */
        
        
    	that.appCore.mediator.publish(XEngineerConstants.EVENT_REMOVE_DOCUMENT, {
			nodes : nodes
		});
    	
      }
    });

    return Command;

});

define('DS/ENOXEngineer/commands/EditPropertiesCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'DS/ENOXEngineer/utils/Search',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'UWA/Class/Promise',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(
  XEngCommandBase,
  Search,
  Utils,
  XEngineerConstants,
  Promise,
  nlsKeys
) {

    'use strict';

    var Command =  XEngCommandBase.extend({

      init: function(options){
        this._parent(options);
      },
      execute : function(options){
        var that = this;
        this.end();
        
        var nodes = this.appCore.contextManager.getSelectedNodes();

        var selectedItems = nodes.filter(function(node){
            return (!node.getChildren());
        });
        
        
        var types = selectedItems.map(function(selectedObj){
            return selectedObj.getType();
        });

        this.appCore.dataService.getMetaTypes(types, selectedItems[0] instanceof this.appCore.Factories.ListItemFactory.getListInstanceClass())
        .then(function(metaTypes){
          var nodesForEditProp = [];
          for (var i = 0; i < selectedItems.length; i++) {
            var node = selectedItems[i];
            nodesForEditProp.push({
              id: metaTypes[i] === 'businessobject' ? node.getID() : node.getRelationID(),
              metatype: metaTypes[i]
            });
          }
          that.appCore.mediator.publish(XEngineerConstants.EVENT_SHOW_PROPERTIES, nodesForEditProp);
          that.appCore.mediator.publish(XEngineerConstants.EVENT_TRIPTYCH_SHOW_PANEL,'right');
        });
        

      }
    });

    return Command;

});

define('DS/ENOXEngineer/commands/AddExistingDocumentCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'DS/ENOXEngineer/utils/Search',
  'DS/ENOXEngineer/utils/Utils',
  'UWA/Class/Promise',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(
  XEngCommandBase,
  Search,
  Utils,
  Promise,
  nlsKeys
) {

    'use strict';

    var AddExistingDocumentCmd =  XEngCommandBase.extend({

      init: function(options){
        this._parent(options);
      },
      execute : function(options){
        var that = this;
		this.end();
        if(options && options.mode ==="dropped"){

        }else {
          this.appCore.dataService.searchManager.launchASearch({
           title: that.appCore.i18nManager.get("eng.searchResult.InsertDocument"),
        	  allowedTypes:['Document'],
            role : '',
            criteria : '',
            multiSel : true,
            in_apps_callback : that.onSelectedFromSearch.bind(that)
          });
        }

      },
      onSelectedFromSearch : function(selectedObj){
        var that = this;
  
        if(!that.context.getSelectedNodes() || that.context.getSelectedNodes().length === 0)
          that.alertManager.errorAlert(nlsKeys.get("error.noSelection"));

        if(that.context.getSelectedNodes().length > 1)
          that.alertManager.errorAlert(nlsKeys.get("error.notSupport.multisel"));

          for (var i = 0; i < selectedObj.length; i++) {
            //TODO the be rewrite in bulk
            that.appCore.dataService.attachDocumentToEngItem(that.context.getSelectedNodes()[0], selectedObj[i]["id"], true);
          }


      }
    });

    return AddExistingDocumentCmd;

});

define('DS/ENOXEngineer/utils/XENHttpClient', [
    'UWA/Core',
    'DS/ENOXEngineerCommonUtils/XENGenericHttpClient',
    'DS/ENOXEngineer/services/EngineeringSettings',
    'DS/ENOXEngineer/utils/XEngineerConstants'
], function(UWA, XENGenericHttpClient, EngineeringSettings, XEngineerConstants) {

    'use strict';

    /**
     * overwritting options for XEN webapp.
     */
    //clone to avoid to overwrite the orriginal object
    var XENHttpClient = Object.assign(UWA.clone(XENGenericHttpClient, true),{
        decorateWithAddtionnaloptions: function(fetchOpts, cmd){

            if (!cmd.noSecurityContextNeeded && cmd.targetService === XEngineerConstants.SERVICE_3DSPACE_NAME) {
                            
                fetchOpts.headers.SecurityContext = encodeURIComponent('ctx::'+EngineeringSettings.getSecurityContext());
                // IR-642113-3DEXPERIENCER2018x: encode the Security context for Double byte characters
                fetchOpts.headers.SecurityToken = encodeURIComponent(EngineeringSettings.getSecurityToken());
            }
        },
        buildUrl : function(cmd){
            var rootUrl = EngineeringSettings.getServiceURL(cmd.targetService);
            if(EngineeringSettings.isTenantBasedService(cmd.targetService)){
                rootUrl = this.decorateUrlWithTenant(rootUrl+cmd.url);
            }else{
                rootUrl = rootUrl+cmd.url;
            }
            return rootUrl;
        },
        decorateUrlWithTenant: function(url){
            var currentUrl = url || '';
            var containParam = currentUrl.indexOf('?');
            if (containParam > -1) {
              currentUrl = currentUrl + "&tenant="+EngineeringSettings.getPlatformId();
            } else {
              currentUrl = currentUrl + "?tenant="+EngineeringSettings.getPlatformId();
            }
            return currentUrl;
        }

    });



    return XENHttpClient;

});

/*eslint comma-style: ["error", "last"]*/
define('DS/ENOXEngineer/columnsProviders/ConfigurationDataProvider', [ 'UWA/Core','UWA/Class',
	'DS/ENOXEngineer/services/EngineeringSettings',
	'DS/DocumentManagement/DocumentManagement',
	'DS/ENOXEngineerCommonUtils/PromiseUtils',
	'DS/ENOXEngineer/services/I18nManager',
	'DS/ENOXEngineer/services/XEngContextManager',
	'DS/ENOXEngineer/utils/XENHttpClient'],
function (UWA, Class, EngineeringSettings, DocumentManagement, PromiseUtils, I18nManager,XEngContextManager, xAppWSCalls) {
    'use strict';
    var ConfigurationColumns = Class.singleton({

        init: function (options) {
            this._parent(options);
        },

        // Decide column Visibility depending on License available
        isAdditionalColumnsAvailable: function (callback) {
            if (UWA.is(callback, 'function') === false) { throw new Error('A callback function should be defined'); }
            //setColumnsForDisplay();
            setTimeout(function () { callback(true); }, 500);
        },


        getName: function () {
            return 'Configuration';
        },


        getManagedColumnNames: function () {
         return ["Configuration"];
        },

        toBeUpdated: function (values) {
            var update = true;
            if(values && values.Configuration)
                update = false;

            return update;
        },

        getAdditionalColumnsUX: function (currentColumns) {
            var matIdx = currentColumns.findIndex(function(col){
                return col.dataIndex === "Configuration";
            });
            if(matIdx>=0){
                currentColumns.splice(matIdx, 1, {
                    "text": I18nManager.get("Configuration"),
                    "dataIndex": "Configuration",
                    "maxWidth": 800,
                    "minWidth": 20,
                    "width": 200
                  });
            }
        },

				/*

        _fetchData : function(engItemIDs){
            var that = this;
            if (!Array.isArray(engItemIDs) && !engItemIDs.length>=1) {
              xEngAlertManager.errorAlert("fetchData need an array as input");
              return ;
            }

            var payload= {
                    "version":"1.0",
                    "instanceIdList": engItemIDs
              };

            return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
                xAppWSCalls.perform(EngineeringSettings.getCommand('get_configuration'), payload).then(function(DBObject){
                    resolve(DBObject);
                }).catch(function (errors){   return reject(errors);});});
          },
					*/

        // Input Param nodesToUpdate contains list of pids and relids.
        // Result updatedAttributes consists pids and relids with Effectivity information.
          updateAttributes: function (nodesToUpdate, callback) {
            if(!Array.isArray(nodesToUpdate.relids) || nodesToUpdate.relids.length ===0) return callback({relids: {}});
						var localContext = XEngContextManager.getContext();
              if (UWA.is(nodesToUpdate, 'object') === false) { throw new Error('The object ids to modify must be specify'); }
              if (UWA.is(callback, 'function') === false) { throw new Error('A callback function should be defined'); }
//rel id
               var pid;
              localContext._XENContentProxy.core.dataService.getStatticMappingPCInfo(nodesToUpdate.relids).then(function(data){
              	console.log(data);
                //keep one
              	var relids = {};
                 pid = nodesToUpdate.relids[0];
              	nodesToUpdate.relids.forEach(function(pid){
									pid = pid;
              		relids[pid] = {'Configuration': " ", 'ConfigurationID':" ", 'hasStaticMapping':" "}

              	});

              	if (data){
									console.log(pid);

								 nodesToUpdate.relids.forEach(function(pid){

									if(pid) {
									 if(data[pid].hasStaticMapping == "true"){
										 data[pid].content.results[0].data.some(function(data){
										 if(data.name === "Marketing Name"){
											 relids[pid]['Configuration'] = data.value[0];
										 }
									  });
										relids[pid]['ConfigurationID'] = data[pid].content.results[0].physicalID;
									  relids[pid]['hasStaticMapping'] = true;


									 }
								 }

								 });
              	}

              	callback({relids: relids});
              });
          }
    });
    return ConfigurationColumns;
});

define('DS/ENOXEngineer/commands/AddNewMaterialQuantityCmd', [
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'DS/ENOXEngineer/utils/Search',
  'DS/ENOXEngineer/utils/Utils',
  'UWA/Class/Promise',
  'DS/UIKIT/Input/Number',
  'DS/UIKIT/Input/Select',
  'DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineer/services/EngineeringSettings',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/UIKIT/Input/Button',
  'DS/ENOXEngineer/utils/XENHttpClient',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(
  XEngCommandBase,
  Search,
  Utils,
  Promise,
  Number,
  Select,
  XEngineerModal,
  XEngineerConstants,
  EngineeringSettings,
  PromiseUtils,
  Button,
  xAppWSCalls,
  nlsKeys
) {

    'use strict';

    var AddNewMaterialQuantityCmd =  XEngCommandBase.extend({

      init: function(options){
        this._parent(options);
        //this._addMaterialInWork = false;

      },
      _buildModal : function(){
    	  
    	  var material = this._getMaterialName();
          this.modal = new  XEngineerModal({
            title : this.options.appCore.i18nManager.get("eng.ui.dialog.selectMaterialQuantity").replace("{mat}", material),
            className : 'new-material-quantity-dlg',
            withFooter : true
          });

          return this.modal;
        },
        
        destroyView : function(){
            var that = this;
            that.modal.destroy();
            that.modal = undefined;
          },
          
      execute : function(options){
        var that = this;
        this.end();
        var insertMaterialContext = this.appCore.sessionManager.consummeAvailableMaterialForInsert();
        
        
        if(insertMaterialContext){
        	this.material = insertMaterialContext;
        	this._displayView();
        }else {
          this.appCore.dataService.searchManager.launchASearch({
        	  title: that.appCore.i18nManager.get("eng.searchResult.InsertMaterial"),
        	  allowedTypes:['dsc_matref_ref_Core'],
            role : '',
            criteria : '',
            multiSel : true,
            in_apps_callback : that.onSelectedFromSearch.bind(that)
          });
        }

      },
      onSelectedFromSearch : function(selectedObj){
        var that = this;
  
        if(!that.context.getSelectedNodes() || that.context.getSelectedNodes().length === 0)
          that.alertManager.errorAlert(nlsKeys.get("error.noSelection"));

        if(that.context.getSelectedNodes().length > 1)
          that.alertManager.errorAlert(nlsKeys.get("error.notSupport.multisel"));
        
        this.material = selectedObj[0];
        this._displayView();
      },
      _displayView: function(){
          if(!this.modal){
              this.buildView();
            }
          this.modal.show();
      },
      _getMaterialName: function(){
    	  return this.material["ds6w:label"] + " " + this.material["ds6wg:revision"] ; 
      },
      buildView: function(){
    	  var that = this;	  
    	  this._buildModal();

    	  var defaultUoM = "L";
    	  
    	  var group = document.createElement("div");     
    	  group.className = "input-group";
    	  
    	  var addon = document.createElement("span");     
    	  addon.className = "input-group-btn";
    	  
    	  var options1 = [];
			var volumeUnitOfMeasure = this.appCore.settingManager.getSetting("volumeUnitOfMeasure");
			for (var key in volumeUnitOfMeasure){
				options1.push({ text: volumeUnitOfMeasure[key].nls, selected: key === defaultUoM ? true : false});
			}
    	  
			this.unitInput = new Button({
  		    value: defaultUoM,
  		    dropdown: {
  		        items: options1
  		    }
  		}).inject(addon);
    	  
    	  
			this.unitInput.addEvent('onDropdownClick', function (e, item) {
    		  this.setValue(item.text);
    		});

    	  this.quantityInput = document.createElement("input");   
    	  this.quantityInput.className = "form-control";
    	  this.quantityInput.type = "number";
    	  this.quantityInput.placeholder = "Enter a number...";
    	  this.quantityInput.min = 0;
    	  
    	  group.appendChild(this.quantityInput);
    	  group.appendChild(addon);
    	  
    	  this.modal.getBody().appendChild(group); 
          
          this.modal.onValidate(function(finish){
            that.value = this.quantityInput.valueAsNumber;
            
            if (isNaN(that.value) || that.value < 0){
            	
            } else {
                that._createEngineeringItem(finish);
                that.unit = this.unitInput.getValue();
                that.destroyView();
                that.end();
            }

          }, this);

          this.modal.onClose(function(){
            that.destroyView();
            that.end();
          }, this);

      },
      _createEngineeringItem: function(){
    	  
    	  var that = this;
    	  
    	  
    	  this.appCore.contextManager._postProcess = true;
    	  that.appCore.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND,{
              commandId: XEngineerConstants.CREATE_NEW_ENG_ITEM
            });
    	  
    	  // setter variable sur le contexte
          
    	  var currentToken = that.appCore.mediator.subscribe(XEngineerConstants.EVENT_NEW_INSERTED_ENG_ITEM, function(data) {
    		  if (data.postProcess === true){
    			  that.newEngItem = data.nodes[0];
            var promises = [];
            promises.push(that._associateCoreMaterial(data));
            promises.push(that._setQuantityOfMaterial());
            return PromiseUtils.allSettled(promises).then(function(res) {
              that.appCore.contextManager._postProcess = false;
              data.postProcess = false;
              if (res[1].state === "fullfilled" && res[1].value && res[1].value.references && res[1].value.references.length > 0 && res[1].value.references[0].quantity){
            	  data.nodes[0].options.grid["ds6wg:MaterialUsageExtension.DeclaredQuantity"] = res[1].value.references[0].quantity;
              }
              
              that.appCore.mediator.publish(XEngineerConstants.EVENT_NEW_INSERTED_ENG_ITEM, data);
              if(currentToken)
                that.appCore.mediator.unsubscribe(currentToken);
            });
    		  }

        	  });
    	  
    	  
      },
      _getQuantityInInternationalUnit: function(){
    	  var f_quantity = parseFloat(this.value);   
    	  var f_quantityInternational = Utils.convertVolumeToInternationalUnit(f_quantity, this.unit)
    	  return f_quantityInternational.toString();
      },
      _associateCoreMaterial: function(data){
        var that = this;
        return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {
          that.appCore.dataService.applyCoreMaterialToEngItem(that.newEngItem, that.material["id"]).finally(function(res){
            resolve(true);
          });
        });
    	  
      },
      _setQuantityOfMaterial: function(){

              var payload = {
            		  references: [{physicalid: this.newEngItem.getID()}],
                  quantity: this._getQuantityInInternationalUnit()
              };
              return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {
                  xAppWSCalls.perform(EngineeringSettings.getCommand('add_quantity_of_material'), JSON.stringify(payload)).then(function(res) {
                      //app.core.settingManager.setApplicationMode('authoring');
                      return resolve(res);
                  }).catch(function(errors) {
                      reject(errors);
                  });
              });

      }
    });

    return AddNewMaterialQuantityCmd;

});

define('DS/ENOXEngineer/services/EngineeringDataProvider', [
  'UWA/Core',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/ENOXEngineer/utils/XENHttpClient',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/Search',
  'DS/ENOXEngineer/services/XEngLocalStorage',
  'DS/ENOXEngineer/utils/ResponseParser',
  'DS/DocumentManagement/DocumentManagement',
  'DS/PlatformAPI/PlatformAPI',
  'DS/CfgAuthoringContextUX/scripts/CfgAuthoringContext',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'DS/ENOXEngineer/utils/SizedMap',
  'DS/ENOXEngineer/utils/XEngineerConstants'
], function(
            UWACore,
            PromiseUtils,
            xAppWSCalls,
            Utils,
            Search,
            XEngLocalStorage,
            ResponseParser,
            DocumentManagement,
            PlatformAPI,
            CfgAuthoringContext,
            xEngAlertManager,
            SizedMap,
            XEngineerConstants
          ) {

    'use strict';

    var app =null;
    function EngineeringDataProvider(){

      return {
        initialize:function(xEngApp){
          app = xEngApp;
          var that = this;
          this.localDico = {

          };
          this.DOC_REL_NAME ='SpecificationDocument';// 'PLMDocConnection';"DOCUMENTS"
          this.logger=app.core.logger.get("EngineeringDataProvider");
          this.logger.info(" initializing Xeng Data provider");
          // EngineeringDataProvider facade builder EngineeringSettings
          xEngApp.sandboxBase.dataService = this;
          xEngApp.core.dataService = this;
          xEngApp.core.dataService.searchManager = new Search({multiSel : false});

          xEngApp.sandboxBase.localStorage = xEngApp.core.localStorage = XEngLocalStorage;
          var _attrPromise = this.loadListOfParametricalAttributes();
          app.optionalStartupPromises.push( _attrPromise );

          app.optionalStartupPromises.push( this.loadOpenPreference() );

          //init local dico
          that.localDico = {
            kindOfEngItem : {},
            kindOfDocument : {},
            kindOfMaterial : {},
            unsupportedTypes: {}
          };
          that.paramAttributes = {};
          var engItemsRoots = app.core.settingManager.getSetting("acceptedTypeOnDropForOpen");
          engItemsRoots.forEach(function(root){
            that.localDico.kindOfEngItem[root] = [root];
          });

          var documentsRoots = app.core.settingManager.getSetting("acceptedDocumentsRoots");
          documentsRoots.forEach(function(root){
            that.localDico.kindOfDocument[root] = [root];
          });


          var materialRoots = app.core.settingManager.getSetting("acceptedMaterialRoots");
          materialRoots.forEach(function(root){
            that.localDico.kindOfMaterial[root] = [root];
          });
	  return _attrPromise;
        },
        _getUserPrefKey : function(key){
          return app.core.settingManager.getPlatformId()+'_'+key;
        },
        _updateRecentsList : function(pidsList,recentId){
          if (!UWACore.is(recentId)) {
            this.logger.error(" call of _updateRecentsList with missing parameter");
            return null;
          }
          var pids =null;
          if (!pidsList || pidsList.trim() ==='') {
            pids =[];
          }else{
            pids = pidsList.trim().split(',');
          }

          while(pids.indexOf(recentId) !==-1){
            var idx = pids.indexOf(recentId);
            pids.splice(idx, 1);
          }


          if (pids.length >= app.core.settingManager.getSetting('recentsEngItemsSize')) {
            pids.pop();
            pids.unshift(recentId);
            return pids.join();
          }
          pids.unshift(recentId);
          return pids.join();

        },
        setPreference: function(name, value){
          this.logger.info(" call of setPreference");
          if (!UWACore.is(name) || !UWACore.is(value)) {
            this.logger.error(" call of setPreference with missing parameter");
            return null;
          }
          var setPrefCmd = app.core.settingManager.getCommand('my_app_setPreference');
          var cmdClone = Object.assign({}, setPrefCmd);
          cmdClone.url = cmdClone.url + '?name='+this._getUserPrefKey(name)+'&value='+UWA.Utils.encodeUrl(value);

          return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
            xAppWSCalls.perform(cmdClone).then(function(res){
                            cmdClone = null;
                            return resolve(res);
                        }).catch(function(errors) {  reject(errors);
                        });
          });

        },
        getCommandSettings: function(){
        	  var that = this;

              var fetchonDB = app.core.settingManager.getCommand('get_command_settings');
              return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
                xAppWSCalls.perform(fetchonDB)
                          .then(function(DBObject){
                            resolve(DBObject);
                          }).catch(function (errors){   return reject(errors);
                          });

              });

        },
        getPreference: function(name){
          this.logger.info(" call of getPreference");
          if (!UWACore.is(name)) {
            this.logger.error(" call of getPreference with missing parameter");
            return null;
          }
          var getPrefCmd = app.core.settingManager.getCommand('my_app_getPreference');
          var cmdClone = Object.assign({}, getPrefCmd);
          cmdClone.url = cmdClone.url + '?name='+this._getUserPrefKey(name);

          return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
            xAppWSCalls.perform(cmdClone).then(function(res){
                          cmdClone = null;
                          if(res && res.trim()==='')
                            return resolve(null);

                            return resolve(res);
                        }).catch(function(errors) {  reject(errors);
                        });
          });

        },
        addRecentsEngItem : function(physicalid){
          var that = this;
          return   this.getRecentsEngItems()
                .then(function(_pidsStr){
                  var pidsStr =_pidsStr.replace(new RegExp('"', 'g'),'');
                  if(!physicalid  || physicalid.length<3) return ;

                  //if the engItem is already the latest opened
                  if(pidsStr.indexOf(physicalid) ===0) return ;
                  var updatedList = that._updateRecentsList(pidsStr,physicalid);
                  if (updatedList) {
                    that.setPreference(XEngineerConstants.USER_RECENTS_ENG_ITEMS, updatedList);
                  }
                });
        },
        removedRecentEngItem : function(physicalid){
          var that = this;
          return   this.getRecentsEngItems()
                .then(function(pidsStr){
                  var pids =null;
                  if (!pidsStr || pidsStr.trim() ==='') {
                    pids =[];
                  }else{
                    pids = pidsStr.split(',');
                  }

                  for (var i = 0; i < pids.length; i++) {
                    if (pids[i] === physicalid) {
                      pids.splice(i, 1);
                      break;
                    }
                  }
                  that.setPreference(XEngineerConstants.USER_RECENTS_ENG_ITEMS, pids.join());
                });
        },
        dimensionsUnitsConverter: function(valuesToConvert){
          var that = this;
          return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {
            if(!Array.isArray(valuesToConvert)) throw new Error('invalid  input');

            var convertCmd = app.core.settingManager.getCommand('convertValues');

            xAppWSCalls.perform(convertCmd, valuesToConvert)
              .then(function(res) {
                resolve(res);
              }).catch(function(errors) { //launch an alert
                console.error(errors);
                reject(errors);
              });
          });
        },
        _fillRootsFromDico : function(subtypes, result){
          var that = this;
          var kindOfs =   Object.keys(that.localDico);

          for(var j = 0; j<subtypes.length; j++){
            var found = false;
            for (var i = 0; i < kindOfs.length; i++) {
              var kindOf = kindOfs[i];
              if(!kindOf.startsWith("kindOf"))
                continue;
              var root = that._getBelongingRootFromKindOf(subtypes[j], that.localDico[kindOf]);
              if(root){
                result[j] = root;
                var found = true;
                break;
              }
            }
            if(!found)
              result[j] = null;
          }
        },
        retrieveXENColumns: function() {
          var that = this;
          return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {
            var confInfoCmd = app.core.settingManager.getCommand('get_xen_columns');
            var cmdClone = Object.assign({}, confInfoCmd);
            cmdClone.url = cmdClone.url.replace("{lang}", app.core.settingManager.getLanguage());

            xAppWSCalls.perform(cmdClone)
              .then(function(res) {
                that._storeTypeParamAttributes(res);
                resolve(res);
              }).catch(function(errors) { //launch an alert
                console.error(errors);
                reject(errors);
              });
          });
        },
        loadListOfParametricalAttributes: function(){
          var that =this;

          return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){

            that.retrieveXENColumns().finally(function () {
              resolve(true);
            });
          });

        },
         _storeTypeParamAttributes: function(_attrDes){
          this.paramAttributes = _attrDes;
        },

	      getAttributesForFinalItems: function(type) {
            	var attributes = this.getParametricalAttributesOf(type);
            	var attrList = {};
            	attrList[XEngineerConstants.FINAL_ITEMS_DEFAULT] = app.core.i18nManager.get("eng.export.NotSelectedFinalItem");
            	for(var i=0;i<attributes.length;i++){
            		var paramAttr = attributes[i];
            		if(paramAttr.type == "Boolean" && !paramAttr.isReadOnly){
            			attrList[paramAttr.sixWTag] = paramAttr.attrNls;
            		}
            	}
                return attrList;
        },
        getParametricalAttributesOf: function(type){
          var parametricAttributes = this.paramAttributes[type];
          parametricAttributes = Array.isArray(parametricAttributes) ? parametricAttributes : [];
          return parametricAttributes;
        },
        getBasicsAttributes : function(type){
          var basicAttrs = app.core.settingManager.getSetting("basicsAttributes");
          var attrs = basicAttrs[type];
        return   attrs.map(function(att){
                      return {
                        type: att.type,
                        attrName : att.name,
                        sixWTag: att.name,
                        attrNls : app.core.i18nManager.get(att.name)
                      };
              });
        },
        getAttributeDefinition: function(globalType, dsSixW){
          if(!globalType || !dsSixW) return null;
          return this.getAvailableAttributesByGlobalType(globalType)
                      .find(function(attrDef){
                        return attrDef.sixWTag === dsSixW;
                      });
        },
        getAvailableAttributesByGlobalType: function (globalType){

        	switch (globalType) {
	            case "ds6w:Part":
		            return this.getAvailableAttributesByType("VPMReference");
		            break;
	            case "ds6w:Document":
		            return this.getAvailableAttributesByType("VPMReference");
		            break;
	            case "ds6w:FileDocument" :
		            return this.getAvailableAttributesByType("Document");
		            break;
        	}

        },
        getAvailableAttributesForCVQueries: function(){
          var refAttributesSixw = this.getAvailableAttributesByType("VPMReference").map(function(attInfo){
            return attInfo.sixWTag;
          });
          // attributes not used for display
          refAttributesSixw.push("ds6w:globalType");
          refAttributesSixw.push("physicalid");
          return  refAttributesSixw;
        },
        getAvailableAttributesByType: function(type){
          var basics = this.getBasicsAttributes(type);
          basics = Array.isArray(basics) ? basics : [];
          var paramAttr = this.getParametricalAttributesOf(type);
          var result = basics.concat(Array.isArray(paramAttr) ? paramAttr : []);
          result.sort(function(attrInfo1, attrInfo2){
            return attrInfo1.attrNls.localeCompare(attrInfo2.attrNls);
          });
          return result;
        },
        _getAvailableAttributesMap: function(){
          if(this.availableAttributesMap && this.availableAttributesMap["ds6w:label"]) //caching quick test
            return this.availableAttributesMap;

          this.availableAttributesMap = {};
          var that = this;
          this.getAvailableAttributesByType("VPMReference")
                          .forEach(function(attrInfo){
                              that.availableAttributesMap[attrInfo.sixWTag] = attrInfo;
                          });
          return this.availableAttributesMap || {};
        },
        isAKnownAttribute:function(attrName){
          return (this._getAvailableAttributesMap()[attrName]);
        },
        getMetaTypes : function(subtypes, forInstances){
          var that = this;
          return PromiseUtils.wrappedWithPromise(function(resolve, reject){
            if(!Array.isArray(subtypes))
              throw new Error("invalid input");

            var engItemsRoots = app.core.settingManager.getSetting("acceptedTypeOnDropForOpen");
            var result = new Array(subtypes.length);
            that.getRootTypes(subtypes).then(function (rootTypes) {
                for (var i = 0; i < rootTypes.length; i++) {
                  var rootType = rootTypes[i];
                  if (engItemsRoots.indexOf(rootType) !== -1){
                    result[i] = forInstances ? 'relationship':'businessobject';
                  }else{
                    result[i] = 'businessobject';
                  }
                }
                return resolve(result);
            });
        });
        },
        getRootTypes : function(subtypes){
          var that = this;
          return PromiseUtils.wrappedWithPromise(function(resolve, reject){
            if(!Array.isArray(subtypes))
              throw new Error("invalid input");

            var unknownTypes = that._getUnknownTypes(subtypes);
            var result = new Array(subtypes.length);

            if(unknownTypes.length === 0){

              that._fillRootsFromDico(subtypes, result);
              return resolve(result);
            }

            //load unknowntypes
            that.getUnknownTypesHierarchy(unknownTypes).finally(function(){
              that._fillRootsFromDico(subtypes, result);
              return resolve(result);
            });
          });
        },
        areBOMContentTypes : function(types, typesNlsMapping){
          var that = this;
          return PromiseUtils.wrappedWithPromise(function(resolve, reject){
            if(!Array.isArray(types))
            throw new Error("invalid input");

            var unknownTypes = that._getUnknownTypes(types);

            if(unknownTypes.length === 0){
              for(var i =0 ; i<types.length; i++){
                if(that._isInUnsupportedTypes(types[i])){
                  var nls = typesNlsMapping ? typesNlsMapping[types[i]] : types[i];
                  return reject([nls]);
                }
              }
              return resolve(true);
            }

            //load unknowntypes
            that.getUnknownTypesHierarchy(unknownTypes).finally(function(){
              for(var i =0 ; i<types.length; i++){
                if(that._isInUnsupportedTypes(types[i])){
                  var nls = typesNlsMapping ? typesNlsMapping[types[i]] : types[i];
                  return reject([nls]);
                }
              }
              return resolve(true);
            });


          });
        },
        isSavedFilter: function(type){
          if(!type)
            return false;
         var nextGenFilters=   app.core.settingManager.getSetting('NextGenFilterTypes');
         return (nextGenFilters.indexOf(type)!==-1);
        },
        //synchro check
        syncIsAnEngineeringItem: function(type){
          return (this._getBelongingRootFromKindOf(type,this.localDico.kindOfEngItem));
        },
        syncIsADocument: function(type){
          return (this._getBelongingRootFromKindOf(type,this.localDico.kindOfDocument));
        },
        syncIsAMaterial: function(type){
            return (this._getBelongingRootFromKindOf(type,this.localDico.kindOfMaterial));
          },
        //async checks
        areEngeeringItems : function(types, typesNlsMapping){
          return this.areA(types, this.localDico.kindOfEngItem, typesNlsMapping);
        },
        areDocuments : function(types, typesNlsMapping){
          return this.areA(types, this.localDico.kindOfDocument, typesNlsMapping);
        },
        areA : function(types, famillyInfo, typesNlsMapping){
          var that = this;
          return PromiseUtils.wrappedWithPromise(function(resolve, reject){
            if(!Array.isArray(types)){
              throw new Error("invalid input")
            }

            var allAreBelonging = true;
            var notValids = [];
            for (var i = 0; i < types.length; i++) {
              var type = types[i];
              if(!that._getBelongingRootFromKindOf(type, famillyInfo) ||
                   that._isInUnsupportedTypes(type)){
                allAreBelonging = false;
                var nls = typesNlsMapping ? typesNlsMapping[type] : type;
                notValids.push(nls);
                break;
              }
            }
            if(allAreBelonging)
              return resolve(true);

            var unknownTypes = that._getUnknownTypes(types);
            if(unknownTypes.length === 0) //it should be another known type
              return reject(notValids); //to build error message

            that.getUnknownTypesHierarchy(unknownTypes).finally(function(){

              for (var j = 0; j < unknownTypes.length; j++) {
                var loadedType = unknownTypes[j];
                if(!that._getBelongingRootFromKindOf(loadedType, famillyInfo)){
                  var nls = typesNlsMapping ? typesNlsMapping[loadedType] : loadedType;
                  return reject([nls]);
                }
              }
              resolve(true);
            });
          });

        },
        _getUnknownTypes: function(types){
          var result = [];
          var that = this;
          types.forEach(function(type){
            if(!that._getBelongingRootFromKindOf(type,that.localDico.kindOfEngItem) &&
            !that._getBelongingRootFromKindOf(type,that.localDico.kindOfDocument) &&
            !that._isInUnsupportedTypes(type) ){
              result.push(type);
            }
          });

          return result;
        },
        _isInUnsupportedTypes: function(type){
          return (this.localDico.unsupportedTypes[type]) ? true : false;
        },
        _applyTypeClassif : function(typesWithHierarchy){
          if(!Array.isArray(typesWithHierarchy)){
            this.logger.error(" _applyTypeClassif called with invalid input");
            return ;
          }
          var that =this;

          for (var i = 0; i < typesWithHierarchy.length; i++) {
            var typeInfo = typesWithHierarchy[i];

            var engRootMatch = that._findMatchInHierarchy(that.localDico.kindOfEngItem, typeInfo);
            if(engRootMatch){
              that.localDico.kindOfEngItem[engRootMatch].push(typeInfo.type);
              continue;
            }
            var docRootMatch = that._findMatchInHierarchy(that.localDico.kindOfDocument, typeInfo);
            if(docRootMatch){
              that.localDico.kindOfDocument[docRootMatch].push(typeInfo.type);
              continue;
            }

            that.localDico.unsupportedTypes[typeInfo.type]  = true;

          }
        },
        _findMatchInHierarchy: function(famillyInfo, typeHierarchy){
          var roots =   Object.keys(famillyInfo);
          for(var i =0; i<roots.length; i++){
            if(typeHierarchy.hierarchy.indexOf(roots[i])!==-1)
              return roots[i];
          }
          return null;
        },
        _getBelongingRootFromKindOf : function(type, famillyInfo){
          var roots =   Object.keys(famillyInfo);
          for (var i = 0; i < roots.length; i++) {
           if(famillyInfo[roots[i]].indexOf(type)!==-1){
             return roots[i];
           }
          }
          return null;

        },
        getUnknownTypesHierarchy: function(types){
          var that =this;

          return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){
            if(!Array.isArray(types))
               throw new Error("invalid input");
               var input = {
                types: types
              }

               var gettypeshierarchyCmd = app.core.settingManager.getCommand('gettypeshierarchy');
               xAppWSCalls.perform(gettypeshierarchyCmd, input)
                        .then(function(res){
                          that._applyTypeClassif(res.types_hierarchies);
                          resolve(res);
                        }).catch(function(errors) {  reject(errors);
                        });
          });

        },
        getConfigSettings : function(){
          return Array.isArray(this.configSettings) ? this.configSettings : [];
        },
        loadConfigurationSettings : function(){
          var that =this;
          return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){

            if(!app.core.settingManager.isConfigRoleGranted())
              return  reject("user.not.granted.config");

            if(that.configSettingsIsLoaded)
              return resolve(that.getConfigSettings());
            var payload = {
              "version": "1.0",
              "settings": ["DecoupleVariantEvolution"]
            };

            var configSeetingCmd = app.core.settingManager.getCommand('getConfigSettings');
            xAppWSCalls.perform(configSeetingCmd,payload)
                        .then(function(res){
                          that.configSettingsIsLoaded = true;
                          if(Array.isArray(res.settings)){
                            that.configSettings = res.settings;
                          }
                          resolve(res);
                        }).catch(function(errors) {  reject(errors);
                        });

          });

        },
        getRecentsEngItems : function(){
          return this.getPreference(XEngineerConstants.USER_RECENTS_ENG_ITEMS);
        },
        getCurrentUserRecentsItems : function(){
          this.logger.info(" call of getCurrentUserRecentsItems");
          var that = this;
          return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){

              that.getRecentsEngItems()
                    .then(function(stringPids){
                      that.logger.info(" stringPids : "+stringPids);
                      if (stringPids && stringPids.length>0) {
                        that.getEngItemsData(stringPids.split(',').filter(function(id){
                           return (id && id.trim().length>0);
                        }))
                            .then(function(data){
                              resolve(data);
                            })
                            .catch(function(error){
                              reject(error);
                            })
                      }else{
                        resolve(null);
                      }
                    })
                    .catch(function(error){
                      reject(error);
                    })
          });
        },
        loadOpenPreference : function(){
          var that = this;

          that.openPrefPromise  =  this.getPreference(XEngineerConstants.USER_CONF_PREFERENCES)
                        .then(function(prefMapping){
                        that.openPrefMap = new SizedMap({
                          maxSize: app.core.settingManager.getSetting(XEngineerConstants.PREFERENCE_MAX_SIZE),
                          initialContent: prefMapping ? JSON.parse(prefMapping) : {}
                        });
                        console.log(that.openPrefMap);

                        }).catch(function(error){
                          console.error(error);
                        });
          return that.openPrefPromise;
        },
        getOpenPrefMap: function(){
          return this.openPrefMap;
        },
        saveEngItemOpenPref: function(key, pref){
          if(!key)
            throw new Error(" missing parameter");

          var that = this;
          if(!pref){
            this.getOpenPrefMap().delete(key);
          }else{
            this.getOpenPrefMap().put(key, pref);
          }

          var content = that.getOpenPrefMap() ? that.getOpenPrefMap().getContent() : {}
          return that.setPreference(XEngineerConstants.USER_CONF_PREFERENCES , JSON.stringify(content))
                    .then(function(){
                      return true
                    }).catch(function(error){
                      console.error(error);
                      throw new Error(error);
                    });

        },
        getEngItemConfigurationInfo : function(options){
          this.logger.info(" call of getEngItemConfigurationInfo ");
          if(! options.pid) throw new Error("pid is a mandatory parameter");

          var that =this;
          var confInfoCmd = app.core.settingManager.getCommand('getConfiguredObjectInfo');
          var cmdClone = Object.assign({}, confInfoCmd);
          cmdClone.url = cmdClone.url.replace("{pid}", options.pid);

          return PromiseUtils.wrappedWithCancellablePromise( function( resolve, reject){
            xAppWSCalls.perform(cmdClone)
                        .then(function(res){
                          cmdClone =null;
                            resolve(app.core.Factories.configItemsFactory.getModelsFromConfigInfo(res));
                        }).catch(function(errors) { console.log(errors); reject(errors);
                        });
          });

        },
        getUserEvolutionViewPref : function(){
          try{
              return widget.getValue(XEngineerConstants.USER_EVOLUTION_PREF) || XEngineerConstants.CONF_OFFICIAL_VIEW;
            } catch(ex){
              return XEngineerConstants.CONF_OFFICIAL_VIEW;
            }
        },
        setUserEvolutionViewPref : function(newValue){
          var that =this;
          try{
               widget.setValue(XEngineerConstants.USER_EVOLUTION_PREF, newValue);
            } catch(ex){
              that.logger.error(" fail to set evolution filter preference ");
            }
        },

        getUserWorkUnderEvolDlgPref : function(){
          try{
              return widget.getValue(XEngineerConstants.USER_WORKUNDER_EVOL_PREF);
            } catch(ex){
              return null;
            }
        },

        setUserWorkUnderEvolDlgPref : function(newValue){
          var that =this;
          try{
               widget.setValue(XEngineerConstants.USER_WORKUNDER_EVOL_PREF, newValue);
            } catch(ex){
              that.logger.error(" fail to set work under evolution preference ");
            }
        },
      getModelVersionsFromModel: function(modelId){
        var that = this;
        return PromiseUtils.wrappedWithCancellablePromise( function(resolve, reject){
          if(!modelId){
            throw new Error("bad inputs");
          }
          var modelInfoCmd = app.core.settingManager.getCommand('modelInfo');
          var cmdClone = Object.assign({}, modelInfoCmd);
          cmdClone.url = cmdClone.url.replace("{pid}", modelId);

          xAppWSCalls.perform(cmdClone)
                      .then(function(res){
                        cmdClone = null;
                          resolve(app.core.Factories.configItemsFactory.getModelVersionsFromModelInfo(res));
                      }).catch(function(errors) { console.log(errors); reject(errors);
                      });


        });

      },
      getModelItemFromAVersion: function(modelVersionId){
          var that = this;
          return PromiseUtils.wrappedWithCancellablePromise( function(resolve, reject){
            if(!modelVersionId){
              resolve(modelVersionId);
            }
            var modelInfoCmd = app.core.settingManager.getCommand('modelFromVersion');
            var cmdClone = Object.assign({}, modelInfoCmd);
            cmdClone.url = cmdClone.url.replace("{pid}", modelVersionId);

            xAppWSCalls.perform(cmdClone)
                        .then(function(res){
                        	resolve(res);
                        }).catch(function(errors) { console.log(errors); reject(errors);
                        });


          });

        },
      updateEngineeringItemConfigContext: function(parameters){
        var that = this;
        return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){
          if (!parameters.activeEngItem || parameters.selectedModel  === undefined) {
            throw new Error("bad inputs");
          }

          var setConfCxtCmd =  app.core.settingManager.getCommand('setConfContext');
          var toAttach = [];
          var toDettach = [];
          if (parameters.activeEngItem.getPreferedAttachedConfigModel() && parameters.activeEngItem.getPreferedAttachedConfigModel().getID() && parameters.selectedModel){
        	  if (parameters.activeEngItem.getPreferedAttachedConfigModel().getID() === parameters.selectedModel)
        		  return resolve(true);
          }
          if(parameters.activeEngItem.getPreferedAttachedConfigModel() && parameters.activeEngItem.getPreferedAttachedConfigModel().getID()){
            toDettach.push( parameters.activeEngItem.getPreferedAttachedConfigModel().getID() );
          }
          if(parameters.selectedModel){
            toAttach.push(parameters.selectedModel);
          }

          var requestData = {
            version : setConfCxtCmd.inputVersion,
            pid : parameters.activeEngItem.getID(),
            content : {
              attachCfgCtxt : toAttach,
              detachCfgCtxt : toDettach,
              enabledCriteria :toAttach.length >0 ? setConfCxtCmd.enabledCriteria : undefined //nos s
            },

          };

          xAppWSCalls.perform(setConfCxtCmd, requestData)
                    .then(function(serverResponse){
                    var report =  ResponseParser.parseSetConfContext(serverResponse);
                    // IR-598251-3DEXPERIENCER2018x
                    for (var i = 0; i < report.length; i++) {
                      if(!report[i].status){
                        return reject(report[i].message);
                      }
                    }
                      xEngAlertManager.sucessAlert(app.core.i18nManager.get("eng.operation.confContextUpdate.sucess"));
                      resolve(true);
                    }).catch(function (errors){
                       return reject(app.core.i18nManager.get("error.cannotUpdate.config.model"));
                    });
        });
      },
        federadedSearch : function(options){
          this.logger.info(" call of federadedSearch ");

          if(! options.query) throw new Error("query is a mandatory parameter");
          var that = this;
          var fedserachCmd = app.core.settingManager.getCommand('fed_myEng');

          var payload={
            label: app.core.settingManager.getCVRequestLabel(),
            nresults: options.nresults || 100,
            order_by:"desc",
            order_field:"ds6w:modified",
            query: options.query,
            select_predicate: options.predicates || app.core.settingManager.getSetting("select_predicate"),
            select_file:["icon","thumbnail_2d"],
            start:"0",
            tenant: app.core.settingManager.getPlatformId(),
            with_indexing_date:true,
            with_nls:true,
            source: options.source || fedserachCmd.source
          };


          return   xAppWSCalls.perform(fedserachCmd, JSON.stringify(payload));
        },
        fireAutocompleteSearch : function(options){
          var that = this;
          var requestOptions = {
            predicates : ["ds6w:label","physicalid", "ds6wg:revision"],
            nresults : options.nresults
          };
          if( Array.isArray(options.sources) && options.sources.length >0)
            requestOptions.sources = options.sources;

            var augmentedQuery = Utils.getAugmenttedQueryForSearch(options.criteria);
          //apply type filtering
          if( Array.isArray(options.targetTypes) && options.targetTypes.length >0){

            var typesQuery = 'flattenedtaxonomies:"types/'+options.targetTypes[0]+'"';
            // var typesQuery = "[ds6w:type]:"+ options.targetTypes.join(" OR [ds6w:type]:"); don't support subtypes
            //build the query
            for (var i = 1; i < options.targetTypes.length; i++) {
              const type = options.targetTypes[i];
              typesQuery+= ' OR flattenedtaxonomies:"types/'+type+'"';
            }


            requestOptions.query = '('+typesQuery+')' + " AND " + augmentedQuery;
          }else{
            requestOptions.query = augmentedQuery;
          }
          if(options.precond){
            requestOptions.query  = options.precond + ' AND '+requestOptions.query;
          }
          return PromiseUtils.wrappedWithPromise(function(resolve, reject){
              that.federadedSearch(requestOptions).then(function(res){
                  var parsed = ResponseParser.parseFetchResult(res);
                  resolve(parsed.results);
              }).catch(function(error){  reject(error);
              });
          });
        },
        loadModelVersionProdConf : function(modelID, versionId){
          var that = this;
          return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {
            if(!modelID || !versionId)
              reject(new Error("invalid input"));

            var prodConfCmd = app.core.settingManager.getCommand('getModelPCInfos');
            var cmdClone = Object.assign({}, prodConfCmd);
            cmdClone.url = cmdClone.url.replace("{pid}", modelID);
            cmdClone.param = cmdClone.param.replace("{prodIds}", 'pid:'+versionId);
            cmdClone.url = cmdClone.url+"?filteringCriteria="+UWA.Utils.encodeUrl(cmdClone.param);
            xAppWSCalls.perform(cmdClone)
              .then(function(res) {
                cmdClone = null;
                return resolve(res);
              }).catch(function(errors) {
                console.error(errors);
                reject(errors);
              });


          });
        },
        createVolatileFilter: function (engItem) {
          this.logger.info(" call of createVolatileFilter");
          var that = this;
          return PromiseUtils.wrappedWithCancellablePromise(function (resolve, reject) {

            if (!engItem.isConfigured()) {
              return resolve(null);
            }

            var selectedPC = engItem.getPreferedAttachedConfigModel().getPreferredConfiguration();
            if (selectedPC && selectedPC.id) {
              if(!selectedPC.FilterCompiledForm){
                xEngAlertManager.warningAlert(app.core.i18nManager.get("eng.missing.filterinfo.onPC"));
              }
              resolve({
                FilterBinaryforExpand: selectedPC.FilterCompiledForm
              });
            } else { //generate filter binary for preferred evolution
              var volatileFilterCommand = app.core.settingManager.getCommand('createVolatileFilter');

              var contextXml = engItem.getPreferedAttachedConfigModel().buildFilterXML();

              var requestInput = {
                version: volatileFilterCommand.version,
                output: volatileFilterCommand.output,
                dictionary: {
                  version: "0.1",
                  id: {
                    pid: engItem.getPreferedAttachedConfigModel().getID()
                  }
                },
                expression: {
                  version: "0.1",
                  format: "xml",
                  content: contextXml
                }
              };
              xAppWSCalls.perform(volatileFilterCommand, JSON.stringify(requestInput))
                .then(function (res) {
                  return resolve(res);
                }).catch(function (errors) {
                  console.error(errors);
                  reject(errors);
                });

            }

          });

        },

        //[ds6w:contentStructure]:Root AND
        getCurrentUserRootEng:function(){
          this.logger.info(" call of getCurrentUserRootEng on index");
          var that = this;
          var searchOptions = {
            query:"[ds6w:type]:VPMReference AND [owner]:"+app.core.settingManager.getCurrentUser().id,
            nresults: 40,
          };

          return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {

            that.federadedSearch(searchOptions).then(function(res) {
                var options = {
                  serverResponse: res
                };
                if (res.infos && res.infos.nhits === 0) return resolve([]);

                that._indexFormatFetchManager(options, resolve, reject);
              })
              .catch(function(errors) {  reject(errors);
              });
          });
        },
        getUserRecentEditedEngineeringItems:  function(){
          this.logger.info(" call of getUserRecentEditedEngineeringItems");
          var that = this;
          return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
            that._getRecentAuthoredItems().then(function(data){
              if(Array.isArray(data)){
                var avaiTypes = data.map(function(node){
                  return node.getType() || '##unknown##'; //for those which don't have type
                });
                var  seen = {
                  '##unknown##': true
                };
                var  availableTypes = avaiTypes.filter(function(type){
                  return (seen.hasOwnProperty(type)) ? false: (seen[type] = true) ;
                });

                that.areEngeeringItems(availableTypes,availableTypes)//load types classification in XEN cache
                                   .finally(function(){
                                    var updatedNodes = data.filter(function(node){
                                      return that.syncIsAnEngineeringItem(node.getType());
                                    });
                                    resolve(Array.isArray(updatedNodes) ? updatedNodes : []);
                                   });
              }

            }).catch(reject);
          });
        },
        _getRecentAuthoredItems: function(){
          this.logger.info(" call of _getRecentAuthoredItems");
          var that = this;
          return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
            var recentAuthoredCommand= app.core.settingManager.getCommand('fed_myEng_on_Recent');
            var payload = {
              delta_time_interval: recentAuthoredCommand.deltaTime,
              version: 2,
              with_nls: false,
              label: app.core.settingManager.getCVRequestLabel(),
              locale: app.core.settingManager.getLanguage(),
              select_predicate: app.core.settingManager.getSetting("select_predicate"),
              select_file: ["icon", "thumbnail_2d"],
              source: recentAuthoredCommand.source ,
              specific_source_parameter: {},
              tenant: app.core.settingManager.getPlatformId(),
              nresults: recentAuthoredCommand.nresults || 40
            };
            xAppWSCalls.perform(recentAuthoredCommand,JSON.stringify(payload))
                        .then(function(res){
                          if (res.infos && res.infos.nhits === 0) return resolve([]);

                          that._indexFormatFetchManager({serverResponse: res}, resolve, reject);
                        }).catch(function(errors) {  reject(errors);
                        });
          });
        },
        addInstanceWithExisting: function(option){
          this.logger.info("call of addInstanceWithExisting");
          if(!option || !Array.isArray(option.instances))  throw "invalid input";

          var addExistingCommand=app.core.settingManager.getCommand('powerBy_addExisting');
          var that =this;

          for (var  i = 0; i < option.instances.length; i++) {
            if (option.componentId === option.instances[i].referenceId) {
              throw "Operation aborted as it creates cycle(s).";
            }
          }



          var existingInstances = [];
          if (typeof option.existingInstances !== "undefined" ){
        	  option.existingInstances.forEach(function(instance){
        		  existingInstances.push(instance.getRelationID());
        	  });
          }

          var children = option.instances || [];

         var payload=  {
            version: "1.0",
            bAllOrNothing: true,
            operations:[]
         };


         // maintain list of reference to add
         var referencesCached = [];
         var parentCached = false;

         children.forEach(function(instance){

        	 // build child
        	 var child = {};
        	 var indexOfRef = referencesCached.indexOf(instance.referenceId);
        	 if (indexOfRef === -1){
        		 child = {
        				 isInstanceOf: instance.referenceId,
        				 cacheId: referencesCached.length
        				 };

        		 referencesCached.push(instance.referenceId);

        		 } else {
        			 child = {cacheId: indexOfRef };
        			 }

        	// build parent
        	 var parent = {};
        	 if (parentCached){
        		 parent = {cacheId: 0};
        	 } else {
        		 parent = {
     	       			isInstanceOf: option.componentId,
     	     			children: existingInstances,
     	     			cacheId: 0
     	     			};
        		 parentCached = true;
        	 }

			 payload.operations.push({
				 parent: parent,
				 child: child
				 });
        	 });


          return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
            xAppWSCalls.perform(addExistingCommand,JSON.stringify(payload))
.then(function(response){

                        	if (response.status !== "failure"){
                                // change application state
                                app.core.sessionManager.setAuthoringMode('authoring');

                                xEngAlertManager.sucessAlert(app.core.i18nManager.get('eng.operation.addInstance.sucess'));
                              // we are not performing multi parent insert

                               var temp= (Array.isArray(response.results) && Array.isArray(response.results))  ? response.results : [];
                               var mapping = temp.map(function(record){
                                return {
                                  instance : record.instance,
                                  isInstanceOf : record.child
                                }
                               });
                                that.getListNodesFromEngItemsAndInstanceIds(mapping)
                                  .then(function(listNodes){
                                    return resolve(listNodes);
                                  }).catch(function(error){   console.error(error); reject(error);
                                  });
                        	} else {

                        		response.results.forEach(function(subResponse){
                        			subResponse.results.forEach(function(result){
                        					xEngAlertManager.errorAlert(result.messages[2]);
                        			});
                        		});

                        	}


                        })
                        .catch(function(errors){that.logger.error(errors);  reject(errors); });
          });
        },

        getListNodesFromEngItemsAndInstanceIds : function(instRefMap){
          var that = this;
          // var currentParent = app.core.contextManager.getActiveEngItem(); //to avoid Race Condition
          return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
                  var listFactory = app.core.Factories.ListItemFactory;
                  // var parentID = currentParent ? currentParent.getID() : null;
                  var createdInstances =[];
                  var linkedReference = [];
                  if(!Array.isArray(instRefMap)) throw new Error("invalid input to retrieveobject data ") ;
                    instRefMap.forEach(function(result){
                    createdInstances.push(result.instance);
                    linkedReference.push(result.isInstanceOf);
                  });
                  var engItemsLoader = that.getEngItemsData(linkedReference, true);
                  var instancesLoader = that.fetchInstanceData(createdInstances);

                  engItemsLoader.then(function(engItems){
                    that._mapEngItemsToInstance(engItems, instRefMap);
                    resolve(listFactory.convertEngItemToListNode(instRefMap, true ));

                    // timeout necessary to make code asynchroneous (instance name should be updated after node is added)
                    setTimeout(function(){
                    	instancesLoader.then(function(instNames){
                            var msg = instNames.map(function(inst){
                              return {
                                instanceId: inst.instanceId,
                                options: {
                                    grid: {
                                      instanceName: inst.name
                                    }
                                }
                              }
                            });

                            app.mediator.publish(XEngineerConstants.EVENT_UPDATE_NODES_WITH_CHANGESETS, msg);
                          });
                    }, 10);




                  }).catch(function(err){ that.logger.error(err); return reject(err);
                  });
          });

        },
        _mapEngItemsToInstance : function(engItems, instancesMap){
          if(!Array.isArray(engItems) || !Array.isArray(instancesMap))  throw "invalid inputs";
          instancesMap.forEach(function(entry){
            for (var i = 0; i < engItems.length; i++) {
              if(engItems[i].getID() === entry.isInstanceOf){
                entry.engItem = engItems[i];
                break;
              }
            }
            if(!entry.engItem ) throw Error("missing engineering item from fetch");

          });
        },
        multiExpand: function(parameters){
          var multiExpandCmd = app.core.settingManager.getCommand('multiexpand');
          var that = this;
            return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
              xAppWSCalls.perform(multiExpandCmd,JSON.stringify(parameters))
                          .then(function(res){
                            that._processExpandResponse(res, resolve, reject);

                          }).catch(function(errors) {  reject(errors);
                          });
            });

        },
        getEngItemInstances: function(physicalId, configBinary, incParamAttr, options){
        	return this.expand(physicalId, configBinary, "1", incParamAttr, options);
        },
        getEngItemStructure: function(physicalId, configBinary, incParamAttr){
        	return this.expand(physicalId, configBinary, "-1", incParamAttr);
        },
        multiexpandBI: function(physicalId,level){
        	var expandCommand = null;
        	var expandPayload = null;
            if (UWACore.is(physicalId)){
                 expandCommand = app.core.settingManager.getCommand('multiexpand');
                 expandPayload = {
                  label:app.core.settingManager.getCVRequestLabel(),
                  synthesis_mode: "flat",
                  max_count_path: "1",
              	  union: {
              		expand: [
              					{
              						expand_iter: level,
              						root_physicalid: physicalId,
              						"q.iterative_filter_query_bo": "[ds6w:globalType]:\"ds6w:Document\" OR [ds6w:globalType]:\"ds6w:Part\"",
              						no_type_filter_rel: ["XCADBaseDependency"]
              					}
              				]
              			}
                };

              var that = this;
              return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
                xAppWSCalls.perform(expandCommand,JSON.stringify(expandPayload))
                            .then(function(res){
                            	resolve((res && res.facets) ? res.facets : null);
                            }).catch(function(errors) {
                            	reject(errors);
                            });
              });
            }
          },

        getExpandPayload : function(physicalId, configBinary, level, incParamAttr,authored, options){
        	var expandPayload = null;
        	 if (UWACore.is(physicalId)){


                   this.logger.info("call of getEngItemInstances on authoring mode = "+authored);
                    expandPayload = {
                     authored : authored,
                     include_param_Attributes : (incParamAttr === undefined || incParamAttr) ?  true : false,
                     no_type_filter_rel :["XCADBaseDependency"],
                     "q.iterative_filter_query_bo" :"[ds6w:globalType]:\"ds6w:Document\" OR [ds6w:globalType]:\"ds6w:Part\"",
                     level : level,
                     intent : "XEN_attributes",
                     source : "cstorage"
                   };
                   if(options && Array.isArray(options.path) ){
                     expandPayload.paths = [options.path];

                   }else{
                     expandPayload.roots = [{ id : physicalId}];
                   }

                   //Hide NotInBOM function FUN083579 in R2019x.FD03 is delivered only on OnPremise environment and is not applicable on Cloud since it involves an MQL GCO configuration.
                   //GCO configuration is a mandatory step and on Cloud env. it is not feasible due to the unknown impacts.
                   if(!app.core.settingManager.isCloud() && widget.getValue("ShowNotInBOM") == "false") {
                     expandPayload["sequence_filter"] = [{
                                                       		 "definition": [{
                                                       			"type_filter_rel": ["PLMInstance"],
                                                       			"q.query": "NOT ([ds6wg:SynchroEBOMExt.V_InEBOMUser]:\"FALSE\" )"
                                                       		}]
                                                       	}]
                   }

                   if(configBinary && !authored){
                     expandPayload.config_filter = configBinary;
                   }else if(configBinary && authored){
                     console.log("cannot filter in authoring mode");
                   }
        	 }
        	 return expandPayload;
        },

        expand: function(physicalId, configBinary, level, incParamAttr, options){

          if (UWACore.is(physicalId)){
        	  var expandCommand = app.core.settingManager.getCommand('db_expand');
        	  var authored = app.core.sessionManager.isUsingDB();
        	  var expandPayload = this.getExpandPayload(physicalId, configBinary, level, incParamAttr,authored, options);
            var parsingOptions;

            if(Array.isArray(expandPayload.paths)){
              parsingOptions= {pathLength:expandPayload.paths.length,
                              physicalId: physicalId
              }


            }
            var that = this;
            return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
              xAppWSCalls.perform(expandCommand,JSON.stringify(expandPayload))
                          .then(function(res){
                            that._processExpandResponse(res, resolve, reject/*, options*/, parsingOptions);

                          }).catch(function(errors) {  reject(errors);
                          });
            });


          } //end if
        },
        _processExpandResponse: function(res, resolve, reject, parsingOptions){
          var that = this;
            if(!Array.isArray(res.results) || res.results.length ===0){//avoid useless resquest
              return resolve([]);
            }

            app.core.Factories.ListItemFactory.getListNodesFromServerExpand(res, parsingOptions)
                      .then(function(nlsedNodes){
                        return resolve(nlsedNodes);
                      })
                      .catch(function(error){ reject(error);
                      });
        },
        /*
        * only use for treenode submodel not uwa
        */
        getEngItemData:function(physicalId, includeParamAttr, withconfig){
          if (UWACore.is(physicalId))
          return this.getEngItemsData([physicalId], includeParamAttr, withconfig);

          return null;
        },

        getEngItemsData : function(pids, includeParamAttr, withconfig ){
          var that = this;
          if (Array.isArray(pids)) {
            var authored = app.core.sessionManager.isUsingDB();

              this.logger.info("call of getEngItemData on authoring mode = "+ authored);
              var requestData = {
                    label: app.core.settingManager.getCVRequestLabel(),
                    query: 'physicalid:' + pids.join(' OR physicalid:'),
                    tenant: app.core.settingManager.getPlatformId(),
                    nresults: pids.length,
                    intent : "XEN_attributes",
                    authored: authored,
                    include_param_Attributes : includeParamAttr ===true ? true : false,
                    authoringTime: undefined
              };

              return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
                      var fetchCommand = app.core.settingManager.getCommand('pb_fetch');
                      xAppWSCalls.perform(fetchCommand, requestData)
                                .then(function(searchData){
                                  var options = {
                                    serverResponse : searchData,
                                    withconfig : withconfig
                                  };
                                  if(searchData.infos && searchData.infos.nhits === 0) return resolve([]);
                                  that._indexFormatFetchManager(options, resolve, reject);
                                }).catch(function (errors){ return reject(errors);
                                });
              });

          } else {
            throw new Error("pad inputs");
          }
        },

        getStatticMappingPCInfo : function(engItemIDs){
            var that = this;
            if (!Array.isArray(engItemIDs) && !engItemIDs.length>=1) {
              xEngAlertManager.errorAlert("fetchData need an array as input");
              return ;
            }

            var payload= {
                    "version":"1.0",
                    "instanceIdList": engItemIDs
              };

            return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
                xAppWSCalls.perform(app.core.settingManager.getCommand('get_configuration'), payload).then(function(DBObject){
                    resolve(DBObject);
                }).catch(function (errors){   return reject(errors);});});
          },

        //getModelVersionInformationFromPCID
        getModelVersionInformationFromPCID: function(pid){
          var that = this;
            if (Array.isArray(pid)) {
            var authored = app.core.sessionManager.isUsingDB();

              this.logger.info("call of getEngItemData on authoring mode = "+ authored);
              var requestData = {
                    "select_file":["icon", "thumbnail_2d"],
                    "fcs_url_mode":"REDIRECT",
                    "label": app.core.settingManager.getCVRequestLabel(),
                    "physicalid": pid,
                    "locale":app.core.settingManager.getLanguage(),
                    "tenant": app.core.settingManager.getPlatformId(),
                    "select_predicate": app.core.settingManager.getSetting("select_predicate_for_pc")

              };

              return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
                      var fetchCommand = app.core.settingManager.getCommand('cv_fetch');
                      xAppWSCalls.perform(fetchCommand, requestData)
                                .then(function(res){
                                //  resolve(res);
                                  //res.result is array length check genericfetchparser
                                //resolve(app.core.Factories.configItemsFactory.getModelsFromConfigInfo(res));
                                var parsed = ResponseParser.parseFetchResult(res);
                                resolve(parsed.results);
                               }).catch(function (errors){ return reject(errors);
                                });
              });
            } else {
              throw new Error("pad inputs");
            }
        },
        _indexFormatFetchManager : function(options, resolve, reject){
          if (!options || !options.serverResponse || !Array.isArray(options.serverResponse.results)) {
            if(reject) return reject("invalid input : missing serverResponse");
            return null;
          }
          var that = this;
          app.core.Factories.ListItemFactory.getEngItemsListFromServerFetch(options.serverResponse, options.uwaModel, options.withconfig)
                    .then(function(nlsedNodes){
                      for (var i = 0; i < nlsedNodes.length; i++) {
                        if (nlsedNodes[i].deleted) {
                          that.removedRecentEngItem(pids[i]);
                          nlsedNodes.splice(i, 1);
                          i--;
                        }
                      }
                      return resolve(nlsedNodes);
                    })
                    .catch(function(error){   reject(error);
                    });
     },

      fetchInstanceData : function(InstanceIds){
        var that = this;
        if (!Array.isArray(InstanceIds)) {
          xEngAlertManager.errorAlert("fetchInstanceData need an array as input");
          return ;
        }

        var fetchonDB = app.core.settingManager.getCommand('mcs_attributes');

        var requestData= {
              lIds: InstanceIds,
              attributes: "true",
              debug_properties: "",
              plmparameters: "false",
              navigateToMain: "false"
        };

        return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
          xAppWSCalls.perform(fetchonDB, requestData)
                    .then(function(DBObject){
                      resolve(ResponseParser.getInstanceName(DBObject));
                    }).catch(function (errors){   return reject(errors);
                    });

        });

      },


      insertBulkItem : function(item, parent, number, existingInstances) {
          var that = this;
            return PromiseUtils.wrappedWithPromise(function(resolve,reject){

                        var physicalId = item.getID();
                        var instance = {
                            referenceId:physicalId,
                            instanceName : ""
                        };
                        var instances = [];
                        for (var i=0 ; i<number ; i++){
                        	instances.push(instance);
                        }
                        that.addInstanceWithExisting({
                            componentId : parent.getID(),
                            instances : instances,
                            existingInstances: existingInstances
                        }).then(function(nodeList){

                              resolve(nodeList);

                        }).catch(function(error){ reject(error);
                        });

            });

        },
      insertContentsInBOMFromDrop : function(items, parent){
        var classifiedItems = Utils._getItemsByTypeFromDroppedData(items);
        var that = this;
        var promises = [];
          return PromiseUtils.wrappedWithPromise(function(resolve,reject){

        	  if (classifiedItems.VPMReference != undefined || classifiedItems.Document != undefined){

        		  if(Array.isArray(classifiedItems.dsc_matref_ref_Core)){
        			  var materials = [];
        			  classifiedItems.dsc_matref_ref_Core.forEach(function(mat){
        				  materials.push(mat.displayName);
        			  });
        			  var s_materials = materials.join(", ");
        			  xEngAlertManager.warningAlert(app.core.i18nManager.replace( app.core.i18nManager.get("eng.ui.dialog.multisel.drop.material.ignored"),{materials:s_materials}));
        		  }

                  if(Array.isArray(classifiedItems.VPMReference)){
                      var instances = classifiedItems.VPMReference.map(function(item){
                        return  {
                            referenceId : item.objectId,
                            instanceName : item.displayName
                        }
                      });

                  var engItemsPromise =     that.addInstanceWithExisting({
                          componentId : parent.getID(),
                          instances : instances
                      });

                  promises.push(engItemsPromise);

                }

                if(Array.isArray(classifiedItems.Document)){
                  classifiedItems.Document.forEach(function(item){
                      promises.push(that.attachDocumentToEngItem(parent, item.objectId, false) );
                  }); //end foreach
                }

        	  } else {
                  if(Array.isArray(classifiedItems.dsc_matref_ref_Core) && classifiedItems.dsc_matref_ref_Core.length === 1){

                  	var item = classifiedItems.dsc_matref_ref_Core[0];
                  	var data = {
                  			id: item.objectId,
                  			"ds6w:label":  item.displayName,
                  			"ds6wg:revision": "",
                  			"ds6w:type": item.displayType,
                  			"ds6w:type_value": item.objectType
                  	};

                  	app.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
  	                    commandId: XEngineerConstants.ADD_MATERIAL_QUANTITY_CMD,
  	                    context: {
  	                        item : data
  	                    }
  	                });

                }
        	  }




            PromiseUtils.allSettled(promises).then(function(promisesResult){
              var results = [];
              promisesResult.forEach(function(item){
                if(Array.isArray(item.value)){
                  item.value.forEach(function(engItem){
                    results.push({ obj : engItem, status : item.state});
                  });
                }else{
                  results.push({obj :item.value, status :  item.state});
                }
              });
              return resolve(results);
            });

          });

      },
      getEngItemRelatedDocuments : function(engItemPid, relationName){
        var that = this, isCancelled = false;
        var _promise =  PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
          var optionsDoc = {
                  getVersions: true,
                  relInfo: {
                      parentId: engItemPid,
                      parentRelName: relationName || that.DOC_REL_NAME,
                      parentDirection: 'from'
                  },
                  tenant: app.core.settingManager.getPlatformId(),
                  securityContext: app.core.settingManager.getSecurityContext(),
                  tenantUrl: app.core.settingManager.getDefault3DSpaceUrl(),
                  onComplete: function(response){
                    if (!Array.isArray(response.data)) {
                      return ;
                    }
                    if(isCancelled) return resolve([]);
                    resolve(app.core.Factories.ListItemFactory.createListNodes(response.data,'fromDocAPI'));
                  },
                  onFailure: function(reason){
                    if(isCancelled) return resolve([]);
                    reject(reason);
                  }
              };

              DocumentManagement.getDocumentsFromParent(optionsDoc);

        });

        _promise.cancelEmbeddedRequest = function(){
          isCancelled = true;
        };
        return _promise;
      },
      fetchDocumentsData : function(docIds,relationName){
        if (!Array.isArray(docIds)) {
          xEngAlertManager.errorAlert("fetchDocumentsData need an array as input");
          return ;
        }
        var that = this;
        return PromiseUtils.wrappedWithPromise(function(resolve,reject){
          DocumentManagement.getDocuments(docIds,
            {
              relInfo: {
                  parentRelName: relationName || that.DOC_REL_NAME,
                  parentDirection: 'from'
              },
              tenant: app.core.settingManager.getPlatformId(),
              securityContext: app.core.settingManager.getSecurityContext(),
              tenantUrl: app.core.settingManager.getDefault3DSpaceUrl(),
              onComplete : function(response){
                resolve(app.core.Factories.ListItemFactory.createListNodes(response.data,'fromDocAPI'))
              },
              onFailure : function(error){   xEngAlertManager.errorAlert(error);   reject(error);
              }
            }
          );

        });
      },

      applyCoreMaterialToEngItem: function(engItem,matid){
          var that = this;
          return PromiseUtils.wrappedWithPromise(function(resolve,reject){




              var payload = {
                      references: [{
                          engItem: engItem.getID(),
                          material: matid
                      }]
                  };

                        var fetchCommand = app.core.settingManager.getCommand('apply_material');
                        xAppWSCalls.perform(fetchCommand, JSON.stringify(payload))
                                  .then(function(result){
                                	  return resolve(result);
                                  }).catch(function (errors){ return reject(errors);
                                  });
          });
      },

      getCoreMaterialToEngItem: function(engItemIDs){
          var that = this;
          return PromiseUtils.wrappedWithPromise(function(resolve,reject){




              var payload = {
                      references: engItemIDs
                  };

                        var fetchCommand = app.core.settingManager.getCommand('get_material');
                        xAppWSCalls.perform(fetchCommand, JSON.stringify(payload))
                                  .then(function(result){
                                	  return resolve(result);
                                  }).catch(function (errors){ return reject(errors);
                                  });
          });
      },
      //could take the data from search
      attachDocumentToEngItem : function(engItem,docId,isCmd,relationName){
        var that = this;
        return PromiseUtils.wrappedWithPromise(function(resolve,reject){
            that.fetchDocumentsData([docId],relationName)
                  .then(function(listNodes){
                    var doc = listNodes[0];
                    var options = {
                        relInfo: {
                                   parentId: engItem.getID(),
                                   parentRelName: relationName || that.DOC_REL_NAME,
                                   parentDirection: 'from'
                               },
                       tenant: app.core.settingManager.getPlatformId(),
                       additionalHeaders:  app.core.settingManager.getWorkUnderHeaders(),
                       securityContext: app.core.settingManager.getSecurityContext(),
                       tenantUrl: app.core.settingManager.getDefault3DSpaceUrl(),
                       onComplete: function(options){

                         xEngAlertManager.sucessAlert(app.core.i18nManager.get("eng.operation.insertDocument.sucess"));
                         if (isCmd) {
                             var result = {
                               nodes : [doc],
                               parentId : engItem.getID()
                             };
                            app.mediator.publish(XEngineerConstants.EVENT_NEW_INSERTED_ENG_ITEM, result);
                         }

                        resolve(doc);

                       },
                       onFailure: function(err){
                         xEngAlertManager.errorAlert(err.error || JSON.stringify(err));
                         reject(err);
                       }
                    };

                    DocumentManagement.connectDocumentToParent(doc.getID(), options);


                  });

        });
      },
      _createDocument: function(documentInfo, parentID){
        var that = this;
        return PromiseUtils.wrappedWithPromise(function(resolve,reject){
          var tracker =  app.core.sessionManager.getUploadTracker({
            fileName: documentInfo.title,
            fileSize: documentInfo.fileInfo.file.size
          });
          var lOptions = {
            tenant: app.core.settingManager.getPlatformId(),
            securityContext: app.core.settingManager.getSecurityContext(),
            additionalHeaders:  app.core.settingManager.getWorkUnderHeaders(),
            tenantUrl: app.core.settingManager.getDefault3DSpaceUrl(),
            onFailure: function(response) {
              tracker.onComplete(false);
              xEngAlertManager.errorAlert(response.error || JSON.stringify(response));
              reject(false);
            },
            onProgress: tracker.onProgress,
            onComplete: function(response) {
              response = response.data;
              for(var i=0; i< response.length; i++){
                var docInfo =  response[i];
                var docNode = app.core.Factories.ListItemFactory.createListNode(docInfo, 'fromDocAPI');
                var result = {
                  nodes : [docNode],
                  parentId : parentID
                }
              }
              tracker.onComplete(true);
              resolve(result);
              xEngAlertManager.sucessAlert(app.core.i18nManager.get("eng.operation.addDocument.sucess"));
            }
        };

        DocumentManagement.createDocument(documentInfo, lOptions);

        });
      },
      addNewDocumentToEngItem : function(docOptions){
        var that = this;
        var relName = docOptions.relationName || that.DOC_REL_NAME;

        if(!docOptions.files){
          that._launchFileChooser( function(files){
            that._createDocumentsFromFiles(files, docOptions.targetObjID, relName);
          });
        }else{
          that._createDocumentsFromFiles(docOptions.files, docOptions.targetObjID, relName);
        }

      },
      _createDocumentsFromFiles: function(files, parentID, relName){
        if(!files || !parentID || !relName)  return ;
        var that =this;

        for (var index = 0; index < files.length; index++) {
          const file = files[index];
          var documentInfo = {
            title: file.name || 'unNamed',
            fileInfo: {
              comments: '',
              file: file
            },
            relInfo: {
              parentId: parentID,
              parentRelName: relName,
              parentDirection: 'from'
            }
          };

          that._createDocument(documentInfo, parentID)
              .then(function(payload){
                if(relName === that.DOC_REL_NAME){
                  app.core.mediator.publish(XEngineerConstants.EVENT_NEW_INSERTED_ENG_ITEM, payload);
                }else{
                  app.core.mediator.publish(XEngineerConstants.EVENT_NEW_ATTACHED_DOCUMENT, payload);
                }

              });

        }


      },
      _launchFileChooser: function(onSelectFiles,onMono){
        var fileExpl = Utils.getFileInput(onMono);

        fileExpl.addEventListener('change', function(event) {
          event.preventDefault();
          event.stopImmediatePropagation();
          var files = event.target.files.length>0 ? event.target.files :event.dataTransfer.files; // FileList object
          fileExpl.removeEvent('change');
          fileExpl.destroy();

          if(onSelectFiles) onSelectFiles(files);

        });
        fileExpl.click();
      },
      checkinDocument: function(parameters){
        this._launchFileChooser(function(files){
          var file = files[0];
          var filename = file ? file.name : '';
          // IR-557724-3DEXPERIENCER2017x: Remove extension if any
          filename = filename.replace(/\.[^/.]+$/, '');
          var docOptions = {
                  tenant: app.core.settingManager.getPlatformId(),
                  securityContext: app.core.settingManager.getSecurityContext(),
                  additionalHeaders:  app.core.settingManager.getWorkUnderHeaders(),
                  tenantUrl: app.core.settingManager.getDefault3DSpaceUrl(),
                  onComplete: parameters.onComplete,
                  onFailure: parameters.onFailure
              },
          documentInfo = {
              id: parameters.docId,
              title: filename,
              fileInfo: {
                  file: file
              }
          };

          DocumentManagement.modifyDocument(documentInfo, docOptions);
        }, true);
      },
      /*
      downloadDocument: function(docModel, onComplete, onFailure){
        this._downloadDocument(docModel,function(response){
          xEngAlertManager.sucessAlert(app.core.i18nManager.get("eng.operation.downloadDocument.sucess"));
          if(onComplete) onComplete(response);
        },function(reason){
          if(onFailure) onFailure(reason);
        },false);
      },
      */
      downloadDocuments: function(docs, onComplete, onFailure){
          this._downloadDocuments(docs,function(response){
            xEngAlertManager.sucessAlert(app.core.i18nManager.get("eng.operation.downloadDocument.sucess"));
            Utils.launchDownloadfromURLs(response);
            if(onComplete) onComplete(response);
          },function(reason){
            if(onFailure) onFailure(reason);
          },false);
        },
      /*checkoutDocument: function(docModel, onComplete, onFailure){

        this._downloadDocument(docModel,function(response){
          xEngAlertManager.sucessAlert(app.core.i18nManager.get("eng.operation.checkoutDocument.sucess"));
          if(onComplete) onComplete(response);
        },function(reason){
          if(onFailure) onFailure(reason);
        },true);
      },
      _downloadDocument: function(docModel,onCompleteCB, onFailureCB ,checkout){

          var options = {
            tenant: app.core.settingManager.getPlatformId(),
            securityContext: app.core.settingManager.getSecurityContext(),
            tenantUrl: app.core.settingManager.getDefault3DSpaceUrl(),
            additionalHeaders:  app.core.settingManager.getWorkUnderHeaders(),
            autoDownload: true,
            onFailure: function(response) {
              onFailureCB(response);
              xEngAlertManager.errorAlert(app.core.i18nManager.replace(app.core.i18nManager.get("error.operation.failed"),{
                operation:'download document ',
                error: response.data && response.data[0] ? response.data[0].updateMessage : response
              }));
            },
            onComplete: onCompleteCB
        };
        DocumentManagement.downloadDocument(docModel.getID(), undefined, checkout, options);
      },*/
      _downloadDocuments: function(docs,onCompleteCB, onFailureCB){

    	  if (!Array.isArray(docs)) return;

    	  var docIds = docs.map(function(doc){
    		  return doc.getID();
    	  });

          var options = {
            tenant: app.core.settingManager.getPlatformId(),
            securityContext: app.core.settingManager.getSecurityContext(),
            tenantUrl: app.core.settingManager.getDefault3DSpaceUrl(),
            additionalHeaders:  app.core.settingManager.getWorkUnderHeaders(),
            onFailure: function(response) {
              onFailureCB(response);
              xEngAlertManager.errorAlert(app.core.i18nManager.replace(app.core.i18nManager.get("error.operation.failed"),{
                operation:'download document ',
                error: response.data && response.data[0] ? response.data[0].updateMessage : response
              }));
            },
            onComplete: onCompleteCB
        };
        DocumentManagement.downloadDocuments(docIds, options);
      },
      deleteDocuments: function(documentsToDelete, notifyCB){

    	  var that = this;
    	  if (documentsToDelete.length && documentsToDelete.length > 0){
    		  documentsToDelete.forEach(function(documentToDelete){
    			  that.deleteDocument(documentToDelete, notifyCB);
    		  });
    	  }
      },
      deleteDocument: function(docId, notifyCB){
        var documentId = docId.options.referenceId;
        if(documentId){
          var options = {
              tenant: app.core.settingManager.getPlatformId(),
              securityContext: app.core.settingManager.getSecurityContext(),
              additionalHeaders:  app.core.settingManager.getWorkUnderHeaders(),
              tenantUrl: app.core.settingManager.getDefault3DSpaceUrl(),
              onComplete: function(response) {
                xEngAlertManager.sucessAlert(app.core.i18nManager.get("eng.operation.deleteDocument.sucess"));

                if(notifyCB){
                  notifyCB(true);
                }else{
                  app.core.contextManager.getContext().refresh({
                    action: "unparent",
                    instances: [docId.options.instanceId]
                  });
                }



              },
              onFailure: function(response) {
                if(notifyCB){
                  notifyCB(false);
                }
              var errJson = {
                  operation:'delete document ',
                  error:response.error
                };
                xEngAlertManager.errorAlert(app.core.i18nManager.replace((app.core.i18nManager.get("error.operation.failed")),errJson));
              }
          };
          DocumentManagement.deleteDocument(documentId, options);
        }
      },
      detachDocuments: function(documentsToDetach, parent, relationName, notifyCB){

    	  var that = this;
    	  if (documentsToDetach.length && documentsToDetach.length > 0){
    		  documentsToDetach.forEach(function(documentToDetach){
    			  that.removeDocument(documentToDetach, parent, relationName, notifyCB);
    		  });
    	  }
      },
      removeDocument: function(docId,parent, relationName, notifyCB){
        var documentId = docId.options.referenceId;
        var that = this;
        if(documentId){
          var options = {
            relInfo: {
                       parentId: parent.getID(),
                       parentRelName: relationName || that.DOC_REL_NAME,
                       parentDirection: 'from'
                   },
              tenant: app.core.settingManager.getPlatformId(),
              securityContext: app.core.settingManager.getSecurityContext(),
              additionalHeaders:  app.core.settingManager.getWorkUnderHeaders(),
              tenantUrl: app.core.settingManager.getDefault3DSpaceUrl(),
              onComplete: function(response) {
                xEngAlertManager.sucessAlert(app.core.i18nManager.get("eng.operation.removeDocument.sucess"));
                if(notifyCB){
                  notifyCB(true);
                }
                if(!relationName || (relationName === that.DOC_REL_NAME))
                app.core.contextManager.getContext().refresh({
                    action: "unparent",
                    instances: [docId.options.instanceId]
                  });


              },
              onFailure: function(response) {
                if(notifyCB){
                  notifyCB(false);
                }

                xEngAlertManager.errorAlert((app.core.i18nManager).replace(app.core.i18nManager.get("error.operation.failed"),{
                  operation:'remove document ',
                  error:response.error
                }));
              }
          };
          DocumentManagement.disconnectDocumentFromParent(documentId, options);
        }
      },
        loadElementsNLS: function (elementsNames) {
          this.logger.info("call of loadElementsNLS");
          var that = this;
          var elementsNlsCmd = app.core.settingManager.getCommand('dico_elements');

          return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
            xAppWSCalls.perform( elementsNlsCmd,elementsNames,{})
                        .then(function(res){
                					var localValues = sessionStorage.getItem(app.core.settingManager.getNlsStorageName());
                					if (!localValues)
                					  localValues = {};
                					else
                					  localValues = JSON.parse(localValues);

                					var responseParse = res.vocabularyElementNLSInfo;

                          for (var i = 0; i < responseParse.length; i++) {
                            var elemName = responseParse[i].uri;
                            localValues[elemName] = responseParse[i];
                          }
                					return resolve(localValues);
                        }).catch(function(errors) {   reject(errors);
                        });
          });

			},
      loadPredicateValues : function(missingValues){
        this.logger.info(" call of loadPredicateValues");
        var that = this;
        var predicatePropNlsCmd = app.core.settingManager.getCommand('dico_predicate_value');

        return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
          xAppWSCalls.perform(predicatePropNlsCmd, missingValues)
                      .then(function(res){
                        var storageName = app.core.settingManager.getPredicatesNlsStorageName();
                        var localValues = sessionStorage.getItem(storageName);
                        if (!localValues)
                          localValues = {};
                        else
                          localValues = JSON.parse(localValues);

                        var dwnlded_preds = res;

                        for ( var pred in dwnlded_preds) {
                          if (!localValues.hasOwnProperty(pred)){
                             localValues[pred] = dwnlded_preds[pred];
                          }else {
                            for ( var val in dwnlded_preds[pred]) {
                              localValues[pred][val] = dwnlded_preds[pred][val];
                            }
                          }
                        }
                        return resolve(localValues);
                      }).catch(function(errors) {   reject(errors);
                      });
        });
      },

        applyWorkUnderEvolution: function (modelId, modelName, productId, productName, productRevision, modelTitle, productTitle) {
          var that = this;
          return PromiseUtils.wrappedWithPromise(function (resolve, reject) {
            if ((!modelId) || (!productId))
              reject(new Error("invalid input"));
            var evolutionCmd = app.core.settingManager.getCommand('workUnderEvolution');
            var evolutionXMLExpression = evolutionCmd.evolutionExpression;
            evolutionXMLExpression = evolutionXMLExpression.replace(new RegExp("{modelName}", 'g'), modelName);
            evolutionXMLExpression = evolutionXMLExpression.replace(new RegExp("{productName}", 'g'), productName);
            evolutionXMLExpression = evolutionXMLExpression.replace(new RegExp("{productRevision}", 'g'), productRevision);

            evolutionXMLExpression = evolutionXMLExpression.replace(new RegExp("{productTitle}", 'g'), productTitle);
            evolutionXMLExpression = evolutionXMLExpression.replace(new RegExp("{modelTitle}", 'g'), modelTitle);

            var payload = {
              'Dictionary Contexts': modelId,
              'Evolution Expression': evolutionXMLExpression
            };

            xAppWSCalls.perform(evolutionCmd, JSON.stringify(payload))
              .then(function (res) {
                    // In case of successful work under, publish the event that will synchronize the bubble.
                    if ((null != res.ACId) && ('' != res.ACId) && (null != res.XSLTExpr) && ('' != res.XSLTExpr)) {
                      // Set the effectivity
                      var dataJson = CfgAuthoringContext.get();
                      dataJson.evolution.id = res.ACId;
                      dataJson.evolution.displayExpression = res.XSLTExpr;

                      CfgAuthoringContext.setEffectivity(dataJson);
                      app.core.mediator.publishPlatformEvent("sessionEff", dataJson);
                      app.core.mediator.publishPlatformEvent("toggleActiveSE");
                      return resolve(res);

                    } else {
                      return reject(true);
                    }

              }).catch(function (errors) {
                console.error(errors);
                reject(errors);
              });
          });
        },
        // getEffectivityInstanceInfo: function ( physicalIdList ) {
        //   var that = this;
        //   this.logger.info("Call of getEffectivityInstanceInfo");
        //   return PromiseUtils.wrappedWithPromise(function (resolve, reject) {
        //     var effectivityCmd = app.core.settingManager.getCommand('getEffectivityInfo');
        //    physicalIdList = physicalIdList.replace(/"/g,"");
        //     var payload = {
        //        'version':'1.0',
        //         "pidList":physicalIdList,
        //         "output":{"targetFormat":"TXT","view":"ALL","domains":"ALL"}
        //     };
        //   xAppWSCalls.perform(effectivityCmd, JSON.stringify(payload))
        //       .then(function (res) {
        //                resolve(res);
        //             }
        //       ).catch(function (errors) {
        //         console.error(errors);
        //         reject(errors);
        //       });
        //   });
        // },
        updateAttr : function(cellInfos, newValue, attrDataIndex, custoAttribute){
          var that = this;
          var path;
          var prefixDim = "DSDim_";
          var referenceId = cellInfos.nodeModel.options.referenceId;
          var instanceId = cellInfos.nodeModel.options.instanceId;
          var pathURI = "model/bus/"+referenceId;
          if(custoAttribute !== undefined){
              path = custoAttribute;
          }
          var attrInfo = that.getAttributeDefinition(cellInfos.nodeModel.getGlobalType(),attrDataIndex);

          if(cellInfos.nodeModel.isEngineeringItem()){
             if(attrDataIndex === "tree"){
               path = XEngineerConstants.TITLE_PATH_OF_REFERENCE;
            }else if(attrDataIndex === "instanceName"){
               path = XEngineerConstants.INSTANCE_PATH;
               pathURI= "model/rel/"+instanceId;
            }else if(attrDataIndex === "ds6w:description"){
               path = XEngineerConstants.DESCRIPTION_PATH_OF_REFERENCE;
            }
          } else if(cellInfos.nodeModel.isDocument()) {
             if(attrDataIndex === "tree"){
               path = XEngineerConstants.TITLE_PATH_OF_DOCUMENT;
             }else if(attrDataIndex === "ds6w:description"){
               path = XEngineerConstants.DESCRIPTION_PATH_OF_DOCUMENT;
             }
          } else { //if(cellInfos.nodeModel.options.type === "3DShape")
            if(attrDataIndex === "tree") {
              path = XEngineerConstants.TITLE_PATH_OF_3DSHAPE;
            }else if(attrDataIndex === "ds6w:description"){
              path = XEngineerConstants.DESCRIPTION_PATH_OF_3DSHAPE;
            }
          }
          newValue = newValue.replace("\r","");
          var mySetTitleCommand = app.core.settingManager.getCommand('mcs_setTitle');
               var payload = {
                 "requests":[{
                   "path":pathURI,
                   "method":"PATCH",
                   "body":[{
                     "op":"replace",
                     "path":path,
                     "value":newValue
                   }],
                   "queryParams":{
                     "select":["physicalid","modified","attribute["+path+"]"]
                   }
                 }]
               };
               if(  attrInfo && attrInfo.type && attrInfo.type.toLowerCase()=== "double" &&
                    attrInfo.dimension &&
                    attrInfo.preferredunit){ //enrich the payload
                var req = payload.requests[0].body[0];
                req.dimensionType = prefixDim+attrInfo.dimension;
                req.unitName = attrInfo.preferredunit;
               }

               function retrieveErrors(resSet){
                 if(!resSet || !Array.isArray(resSet.results)) return null;

                 var errorsSet = resSet.results.filter(function(res){
                      return res && res.body && Array.isArray(res.body.errors) && res.body.errors.length>0;
                 }).map(function(result){
                   return (result.body && result.body && result.body.errors) ? result.body.errors : [];
                 });
                return errorsSet.length>0 ? errorsSet : null;
               }

               function displayIssues(errorsSet){
                 if(!Array.isArray(errorsSet)) return ;
                 errorsSet.forEach(function(errors){
                          if(Array.isArray(errors)){
                            errors.forEach(displayIssue);
                          }else{
                            displayIssue(errors);
                          }
                 });
               }

               function displayIssue(issue){

                if(issue && issue.code && issue.message)
                xEngAlertManager.errorAlert(app.core.i18nManager.replace(app.core.i18nManager.get("error.operation.failed"),{
                  code:issue.code,
                  error:issue.message
                }));
               }

               return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
                 xAppWSCalls.perform(mySetTitleCommand,JSON.stringify(payload))
                             .then(function(res){
                               var issues = retrieveErrors(res);
                               if(issues){
                                displayIssues(issues);
                                 return reject(issues);
                               }
                               app.core.sessionManager.setAuthoringMode('authoring');
                               return resolve(res);
                             }).catch(function(errors) {   reject(errors);
                             });
               });
             }

        };
    }
    return EngineeringDataProvider;
});

/*eslint comma-style: ["error", "last"]*/
define('DS/ENOXEngineer/columnsProviders/MaterialDataProvider', [ 'UWA/Core','UWA/Class', 
	'DS/ENOXEngineer/services/EngineeringSettings', 
	'DS/DocumentManagement/DocumentManagement',
	'DS/ENOXEngineerCommonUtils/PromiseUtils',
	'DS/ENOXEngineer/services/I18nManager',
	'DS/ENOXEngineer/utils/XENHttpClient'],
function (UWA, Class, EngineeringSettings, DocumentManagement, PromiseUtils, I18nManager, xAppWSCalls) {
    'use strict';
    var MaterialColumns = Class.singleton({

        init: function (options) {
            this._parent(options);
        },

        // Decide column Visibility depending on License available
        isAdditionalColumnsAvailable: function (callback) {
            if (UWA.is(callback, 'function') === false) { throw new Error('A callback function should be defined'); }
            //setColumnsForDisplay();
            setTimeout(function () { callback(true); }, 200);
        },

        // Used by Product Structure Editor code
        getName: function () {
            return 'MaterialColumns';
        },

        // Used by Product Structure Editor code
        getManagedColumnNames: function () {
         return ["CoreMaterial"];
        },

        toBeUpdated: function (values) {
            var update = true;
            if(values && values.CoreMaterial) 
                update = false;

            return update;
        },
        
        getAdditionalColumnsUX: function (currentColumns) {
            var matIdx = currentColumns.findIndex(function(col){
                return col.dataIndex === "CoreMaterial";
            });
            if(matIdx>=0){
                currentColumns.splice(matIdx, 1, {
                    "text": I18nManager.get("CoreMaterial"),
                    "dataIndex": "CoreMaterial",
                    "maxWidth": 800,
                    "minWidth": 20,
                    "width": 200
                  });
            }
        },
        
        _fetchData : function(engItemIDs){
            var that = this;
            if (!Array.isArray(engItemIDs)) {
              xEngAlertManager.errorAlert("fetchData need an array as input");
              return ;
            }

            var fetchonDB = EngineeringSettings.getCommand('mcs_attributes');

            var requestData= {
                  lIds: engItemIDs,
                  attributes: "true",
                  debug_properties: "",
                  plmparameters: "false",
                  navigateToMain: "false"
            };

            var payload= {
                    references: engItemIDs,
              };
            
            return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
                xAppWSCalls.perform(EngineeringSettings.getCommand('get_material'), payload).then(function(DBObject){
                    resolve(DBObject);
                }).catch(function (errors){   return reject(errors);});});
          },

        // Input Param nodesToUpdate contains list of pids and relids.
        // Result updatedAttributes consists pids and relids with Effectivity information.
          updateAttributes: function (nodesToUpdate, callback) {
              if (UWA.is(nodesToUpdate, 'object') === false) { throw new Error('The object ids to modify must be specify'); }
              if (UWA.is(callback, 'function') === false) { throw new Error('A callback function should be defined'); }

              this._fetchData(nodesToUpdate.pids).then(function(data){
              	console.log(data);
              	var pids = {};
              	     		
              	nodesToUpdate.pids.forEach(function(pid){
              		pids[pid] = {'CoreMaterial': " ", 'CoreMaterialID': " ", 'CoreMaterialInfo': " "}
              	});

              	if (data.references){
              		data.references.forEach(function(matResult){
              			var engItemID = matResult.engItem;
              			if (pids[engItemID] == undefined)  pids[engItemID]= {};
              			pids[engItemID]['CoreMaterial'] = matResult.material["V_Name"] + " " + matResult.material["revision"];
              			pids[engItemID]['CoreMaterialID'] = matResult.material.physicalid;
              			pids[engItemID]['CoreMaterialInfo'] = matResult.material;
              		});
              	}

              	callback({pids: pids});
              });
          }
    });
    return MaterialColumns;
});

define('DS/ENOXEngineer/services/ExportService', [
        'UWA/Class',
        'UWA/Core',
        'DS/ENOXEngineerCommonUtils/PromiseUtils',
        'DS/ENOXEngineer/utils/XENHttpClient',
        'DS/ENOXEngineerCommonUtils/xEngAlertManager',
        'DS/ENOXEngineer/utils/XEngineerConstants'
    ],
    function(UWAClass,
        UWACore,
        PromiseUtils,
        xAppWSCalls,
        xEngAlertManager,
        XEngineerConstants) {
        'use strict';
        var exportHandler = UWAClass.singleton({

            initialize: function(xEngApp) {
                this.app = xEngApp;
                xEngApp.core.exportService = this;
            },
            _completePayload: function(payload){
                var that = this;
                return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){
                    if(!payload)
                        throw new Error('invalid input');
                    
                    var isFiltered = (payload.PersistentFilterCriteria && payload.PersistentFilterCriteria.filterData) ;

                    if(!isFiltered){
                        return resolve(); 
                     } else {
                    	 var  multiExpand_data = (payload.PersistentFilterCriteria.filterData && payload.PersistentFilterCriteria.filterData.CVQuery) ? payload.PersistentFilterCriteria.filterData.CVQuery : false;
                    	 if(multiExpand_data && multiExpand_data.union && multiExpand_data.union.expand)
                    	 for (var i = 0; i < multiExpand_data.union.expand.length; i++) {
	                		 payload.PersistentFilterCriteria.filterData.CVQuery.union.expand[i].expand_iter = (payload.Components == "Direct") ? "1" : "-1";
                    	 }
                     }

                    var filter_Binary =   isFiltered ?payload.PersistentFilterCriteria.filterData.filterBinary: null;
                    if(filter_Binary){
                        return  resolve();
                    }

                    that.app.core.dataService.createVolatileFilter(that.app.core.contextManager.getActiveEngItem())
                                            .then(function(res){
                                                payload.PersistentFilterCriteria.filterData.filterBinary = res ? res.FilterBinaryforExpand : null;
                                                resolve();
                                            }).catch(function(reason){
                                                console.error(reason);
                                                resolve(null);
                                            });
                    
                });

            },
            
	expandForQualifiedAsFinal: function(physicalId){
	    if (UWACore.is(physicalId)){
	      var that = this;
	      
	      var engItem = this.app.core.contextManager.getActiveEngItem();
	      
	      if(!engItem){
	    	  return;
	      }
	      
	      var PreferredFinalItem =  widget.getValue(XEngineerConstants.FINAL_ITEMS_PREF);
			      
	      var PersistentFilter = (this.app.core.contextManager && this.app.core.contextManager.getActiveEngItemOpenContext()!=null) ? this.app.core.contextManager.getActiveEngItemOpenContext().filteringContext : "";
	      
	      PersistentFilter = (PersistentFilter != "" && PersistentFilter != "none")? true: false;
			      
	      var  ConfiguredMode = (engItem.getPreferedAttachedConfigModel())?true:false;
			      
	      var expandCommand = this.app.core.settingManager.getCommand('qualifiedAsFinal');
	      
	      var showNotInBOMField = widget.getValue("ShowNotInBOM");
	      
	      var ShowNotInBOM = (showNotInBOMField == null || showNotInBOMField == undefined) ? "true" :  showNotInBOMField ;
			      
	      if(!expandCommand.url.contains("?root3DSpaceUrl"))
	      {		
	    	  expandCommand.url = expandCommand.url+"?root3DSpaceUrl="+this.app.core.settingManager.getDefault3DSpaceUrl();	
	      }
	      var expandPayload = {
	            "physicalid": physicalId,
	            "Authored" : false,
	            "PersistentFilter": PersistentFilter,
	            "PersistentFilterCriteria": this.app.core.contextManager.getActiveEngItemOpenContext(),
	            "PreferredFinalItem": PreferredFinalItem,
	            "ShowNotInBOM" : ShowNotInBOM,
	            "ConfiguredMode":ConfiguredMode
	      };
	      var filter_Binary =  ( expandPayload.PersistentFilterCriteria.filterData &&  expandPayload.PersistentFilterCriteria.filterData.filterBinary)? expandPayload.PersistentFilterCriteria.filterData.filterBinary:"";
	      return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
	    		  that._completePayload(expandPayload).then(function(){
	    			  if(expandPayload.PersistentFilter && expandPayload.PersistentFilterCriteria.filteringContext == "nextGenFilter"){
	    				  resolve(that.expandForQualifiedAsFinalItemsUsingMultiExpand(physicalId,filter_Binary,"-1",expandPayload))
	    			  }
	    			  else{
	    				  resolve(that.expandForQualifiedAsFinalItems(physicalId,filter_Binary,"-1",true));
	    			  }
			      	});
			
	      });
			
	    }
	},
	expandForQualifiedAsFinalItemsUsingMultiExpand : function(physicalId, configBinary, level, expandPayload){
		var that = this;
		var multiExpand_data =  expandPayload.PersistentFilterCriteria.filterData.CVQuery;
		var refAttributesSixw  = that.app.core.dataService.getAvailableAttributesByType("VPMReference")
		.map(function(attInfo){
			return attInfo.sixWTag;
		});

		refAttributesSixw.push("ds6w:globalType"); //mandatory to have super type info
		var instanceAttributesSixw = that.app.core.settingManager.getSetting("select_rel");
		multiExpand_data.select_bo = refAttributesSixw;
	        multiExpand_data.select_rel = instanceAttributesSixw;
	        multiExpand_data.compute_select_bo = that.app.core.settingManager.getSetting("compute_select_bo");
	        multiExpand_data.label= that.app.core.settingManager.getCVRequestLabel();
	        var expandCommand = this.app.core.settingManager.getCommand('multiexpand');
	        return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
	            xAppWSCalls.perform(expandCommand,JSON.stringify(multiExpand_data))
                        .then(function(res){
                        	that._processQualifiedAsFinalExpandResponse(res, resolve, reject);

                   	}).catch(function(errors) {  reject(errors);
                   });
          }	);
	},
	
	expandForQualifiedAsFinalItems: function(physicalId, configBinary, level, incParamAttr){

        if (UWACore.is(physicalId)){
      	  var expandCommand = this.app.core.settingManager.getCommand('db_expand');
      	  var expandPayload = this.app.core.dataService.getExpandPayload(physicalId, configBinary, level, incParamAttr,false);
          var that = this;
          return PromiseUtils.wrappedWithCancellablePromise(function(resolve,reject){
            xAppWSCalls.perform(expandCommand,JSON.stringify(expandPayload))
                        .then(function(res){
                        	that._processQualifiedAsFinalExpandResponse(res, resolve, reject);

                        }).catch(function(errors) {  reject(errors);
                        });
          });
        } //end if
      },
      
      _processQualifiedAsFinalExpandResponse: function(res, resolve, reject){
          var that = this;
            if(!Array.isArray(res.results) || res.results.length ===0){//avoid useless resquest
              return resolve([]);
            }

            that.app.core.Factories.ListItemFactory.getQualifiedAsFinalListNodesFromServerExpand(res)
                      .then(function(nlsedNodes){
                        return resolve(nlsedNodes);
                      })
                      .catch(function(error){ reject(error);
                      });
        },
  
            downloadExportFile: function(export_data,commandName) {
                var that = this;
                var payLoadPartService = {
                    data: export_data
                }
                var exportFileName = payLoadPartService.data.ExportFileName;
                var setCSRFCmd = this.app.core.settingManager.getCommand('csrf_tocken_validation');
                PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {
                    xAppWSCalls.perform(setCSRFCmd, "").then(function(res) {
                        var setExportCmd = that.app.core.settingManager.getCommand(commandName);
                        that._completePayload(payLoadPartService.data).then(function(){

                        	if(!setExportCmd.url.contains("?root3DSpaceUrl"))
                        	{	setExportCmd.url = setExportCmd.url+"?root3DSpaceUrl="+that.app.core.settingManager.getDefault3DSpaceUrl() +"&timezoneOffset="+ new Date().getTimezoneOffset();	}
                        	
	                        xAppWSCalls.perform(setExportCmd, JSON.stringify(payLoadPartService.data)).then(function(response) {
	                        	that.downloadFile(exportFileName,response, '.csv',true);
	                        }).catch(function(errors) {
		                    	console.error(errors);
	                            xEngAlertManager.errorAlert(errors.response);
	                            resolve();
	                        });
                        });
                    }).catch(function(errors) {
                        reject(errors);
                    });
                });
            },
            
            downloadFile : function (fileName,fileContent,fileType,isExportFile) {
		        var that = this;
		        var csvString = '';
		        var fileName = fileName + fileType;
		        var content="";
		        
		        if(isExportFile && that.app.core.settingManager.getLanguage() != "en") 
		        	content ="\uFEFF";
		        
		        content=content+fileContent;
		
		        var link = document.createElement('a');
		        var mimeType = 'text/csv;charset:utf-8';
		
		        if (navigator.msSaveBlob) { // IE10
		            navigator.msSaveBlob(new Blob([content], {
		                type: mimeType
		            }), fileName);
		        } else if (URL && 'download' in link) { //html5 A[download]
		            link.href = URL.createObjectURL(new Blob([content], {
		                type: mimeType
		            }));
		            link.style.visibility = 'hidden';
		            link.setAttribute('download', fileName);
		            document.body.appendChild(link);
		            link.click();
		            document.body.removeChild(link);
		        } else {
		            location.href = 'data:application/octet-stream,' + encodeURIComponent(content); // only this mime type is supported
		        }
            },
            
            getdefaultColumnsToExportEntireStructure : function(activeENGItemObjectId){
            	var that = this;

				var defaultColumnsToExport = {};
            	var attributes = that.app.core.dataService.getAvailableAttributesByType(["VPMReference"]);
            	var instanceName = {
                     "type": "string",
                     "attrName": "InstanceName",
                     "sixWTag": "InstanceName",
                     "attrNls": that.app.core.i18nManager.get("label_Instance_Name")
                 };

                 attributes.unshift(instanceName);
                 
                var editableColumns = ["InstanceName", "ds6w:description", "ds6w:identifier", "ds6wg:EnterpriseExtension.V_PartNumber", "ds6wg:revision", "ds6w:label", "ds6w:type"];

                for (var i = 0; i < attributes.length; i++) {
					if(editableColumns.indexOf(attributes[i].sixWTag) > -1) {
						   defaultColumnsToExport[attributes[i].sixWTag]=attributes[i].attrNls;				
					}
				}
				
               return defaultColumnsToExport;
            },
            
			/*generatePayloadForDownloadEntireTemplate: function(activeENGItemObjectId,filename){
            	
            	var userPreferedOptions = {};
            	
            	userPreferedOptions.physicalid = activeENGItemObjectId;

                userPreferedOptions.ExportFileName =filename;
                
                var selectedUserActualAndDisplayColumns = this.getdefaultColumnsToExportEntireStructure(activeENGItemObjectId);
                
                userPreferedOptions.SelectedColumns = JSON.stringify(selectedUserActualAndDisplayColumns);
                
                return userPreferedOptions;
            	
            },*/

            getParametricalAttributesForExport: function(type){
            	var attributeList = this.app.core.dataService.getParametricalAttributesOf(type);
            	var attributeArray = [];
            	for(var i=0;i<attributeList.length;i++){
            		attributeArray[i]=attributeList[i].sixWTag;
            	}
            	return attributeArray;
            	
            },

            getPreviousExportOptions: function(name) {
                this.app.logger.info(" call of getPreference");
                if (!UWACore.is(name)) {
                    this.app.logger.error(" call of getPreference with missing parameter");
                    return null;
                }
                var getPrefCmd = this.app.core.settingManager.getCommand('my_app_getPreference');
                var cmdClone = Object.assign({}, getPrefCmd);
                cmdClone.url = cmdClone.url + '?name=' + this.app.core.dataService._getUserPrefKey(name);

                return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {
                    xAppWSCalls.perform(cmdClone).then(function(res) {
                        cmdClone = null;
                        if (res && res.trim() === '')
                            return resolve(null);

                        return resolve(res);
                    }).catch(function(errors) {
                        reject(errors);
                    });
                });

            },

            loadExportOptions: function() {
                var that = this;
                return PromiseUtils.wrappedWithPromise(function(resolve,reject) {
                    that.getPreviousExportOptions(XEngineerConstants.USER_EXPORT_HEADER_TEMPLATE).then(function(data) {
                        // console.log(data);
                        that.newSettings = data ? JSON.parse(data) : null;
                        that.app.logger.warn(that.newSettings);
                        resolve(that.newSettings)
                    }).catch(function(error) {
                        reject(error);
                    });
                });

            },

            setExportOptions: function(name, value) {
                this.app.logger.info(" call of setPreference");
                if (!UWACore.is(name) || !UWACore.is(value)) {
                    this.app.logger.error(" call of setPreference with missing parameter");
                    return null;
                }
                var setPrefCmd = this.app.core.settingManager.getCommand('my_app_setPreference');
                var cmdClone = Object.assign({}, setPrefCmd);
                cmdClone.url = cmdClone.url + '?name=' + this.app.core.dataService._getUserPrefKey(name) + '&value=' + UWA.Utils.encodeUrl(value);

                return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {
                    xAppWSCalls.perform(cmdClone).then(function(res) {
                        cmdClone = null;
                        return resolve(res);
                    }).catch(function(errors) {
                        reject(errors);
                    });
                });

            },

            saveExportOptions: function(settings) {
                var that = this;
                return PromiseUtils.wrappedWithPromise(function(resolve, reject) {
                    that.setExportOptions(XEngineerConstants.USER_EXPORT_HEADER_TEMPLATE, JSON.stringify(settings)).then(function(data) {
                        that.newSettings = settings;
                        resolve(that.newSettings);
                    }).catch(function(error) {
                        reject(error);
                    });
                });

            },
            getExportOptions: function() {
                return this.newSettings;
            }
        });
        return exportHandler;
    });

/**
 * @author SBM2
 */
define('DS/ENOXEngineer/models/EngItemModel', [
  'DS/Tree/TreeNodeModel',
  'UWA/Core',
  'UWA/Class/Promise',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/XEngineerConstants'
], function(
  TreeNodeModel,
  Core,
  Promise,
  PromiseUtils,
  Utils,
  XEngineerConstants
) {

  'use strict';

  function EngItemModel(options){
      this._parentNode = {
        _nodeDepth : 1
      },
      this.pathElement = {
        externalPath : []
      },
      this.options = {
        contextualMenu : [null],
        _relatedContent: null,
        _transientFilter:null,
        emptyStatusbarVisibleFlag: true,
        _attributesAreConvertedToPreferred:false,
        _isAttributeConvertionStarted: false,
        type : '',
        color : '',
        isCut :false,
        // isExpanded : false,
        shading : null,
        referenceId : '',
        quantity : 1,
        models : [],
        preferedModel : null,
        attributes : [],
        custtomAttributes : [],
        thumbnail: '',
        viewType : 'reference',
        instances : [],
        filteringContext : {
          isFilterOutByTagger : false,
          isFilterOutBySearch : false
        },
        isLastVersion : null
      };
      this.options = Core.extend(this.options, options);
      TreeNodeModel.call(this, this.options);
      this.options.i18nManager = this.options.appCore ? this.options.appCore.i18nManager : null;
  }

  EngItemModel.prototype = Object.create(TreeNodeModel.prototype);

  EngItemModel.prototype.getType = function(){
    return this.options.type;
  };

  EngItemModel.prototype.isAttributeConvertionStarted =  function(){
    
    return this.options._isAttributeConvertionStarted;
  };

  EngItemModel.prototype.setAttributeConvertionStarted =  function(state){
    
    this.options._isAttributeConvertionStarted = state;
  };

  EngItemModel.prototype.isRealAttributesConverted = function(){
    return this.options._attributesAreConvertedToPreferred;
  };


  EngItemModel.prototype.setRealAttributesConvertState= function(val){
    this.options._attributesAreConvertedToPreferred = (val);
  }

  //only used by datagridview
  //override permit to getrid of rich icon in datagridview
  EngItemModel.prototype.getIcons = function(){
    return [];
  };

  EngItemModel.prototype.getTypeIcon = function(){
    switch (this.getGlobalType()) {
      case "ds6w:Part":
        return 'product';
      case "ds6w:Document": //for drawings and 3Dshapes
        if(this.getType()==='Drawing')
          return 'drawing';
        return   '3dpart';
      case "ds6w:FileDocument":
        return 'doc';
      default:
         return '';
    }
  }

  EngItemModel.prototype.completePath = function(rootPath){
    if(!Array.isArray(rootPath)) return [this.getID()];
    rootPath.push(this.getID());
    return rootPath;
  };

  EngItemModel.prototype.getTypeName = function(){
	    return this.options.grid["ds6w:type"];
	  };

  EngItemModel.prototype.getIdForEditProperty = function(){
    if(this.options.appCore.Factories.ListItemFactory.isInstanceOfListNodeModel(this)){
      return this.getRelationID();
    }
    return this.getID();
  };

  EngItemModel.prototype.getRealParent = function(){
    var that = this;
    var active = this.options.appCore.contextManager.getActiveEngItem();
    if(active !== null){
      var isFound = active.getContentModels().getChildrenWithoutGroupingNodes().some(function(node){
       return node.getID() == that.getID();
     })
    }

   if(isFound){
       return active;
   }else{
      return this._parentNode;
   }

  };

  // Same implementation between Node and FakeNode
  EngItemModel.prototype._groupChild = function(childNode, groupingOptions, propertiesToGroup) {
    if (!propertiesToGroup || propertiesToGroup.length === 0) {
      // Last fakeNode was reach, add it to this.
      // Safety check about having at least one FakeNode
      if (childNode.getParent() !== this) {
        this.moveChild(childNode);
      }
      return;
    }

    // Find the proper entry in the current node table
    var rootIdentifier;
    if(propertiesToGroup[0] === 'reference'){

    	// items that are not instances don't have reference
    	if (childNode.isInstance() === true){
    		if (childNode.isMaterialQuantity()){
    			rootIdentifier = childNode.options.grid['CoreMaterialID'];
    		} else {
    			rootIdentifier = childNode.getID();
    		}

    	}

    } else {
      if (groupingOptions.getNodeGroupingKey) {
        rootIdentifier = groupingOptions.getNodeGroupingKey(childNode, propertiesToGroup[0]);
      } else {
        rootIdentifier = childNode.getAttributeValue(propertiesToGroup[0]);
      }
    }

    //because 0 is also false
    if (rootIdentifier === undefined || rootIdentifier ===null || rootIdentifier === '' || rootIdentifier === 'NULL') {
      // This case means that for the given property, no proper value
      // is defined for this node. As no unbalanced is authorized, we
      // create a identifier that will contains all these nodes
      rootIdentifier = 'NA';
    }

    // Retrieve table for the current path of propertiesToGroup
    var currentTable = this._getFakeNodesTable();
    // Retrieve fakeNode in that table for the correct identifier or create it
    // if it does not exist
    var newFakeNode = currentTable[rootIdentifier];
    if (!newFakeNode) {
      newFakeNode =  this.options.appCore.Factories.ListItemFactory.buildGroupNode({
       property: propertiesToGroup[0],
       identifier: rootIdentifier,
       firstmember: childNode,
       fakeNodesTable: {},
       numberOfOriginalChildren: {
         total: 0,
         notHidden : 0
       }
     });
      // Create new entry in the current table
      currentTable[rootIdentifier] = newFakeNode;

      // Add it to the current node
      this.addChild(newFakeNode);
    }

    // Make sur the node is not hidden (if it is reuse from a previous grouping)
    if (newFakeNode.isHidden()) {
      newFakeNode.show();
    }

    // Go to next property to group
    propertiesToGroup.shift();

    // Add in found or created FakeNode the child
    newFakeNode._groupChild(childNode, propertiesToGroup);
  };

  EngItemModel.prototype.attachContentModels = function(_models){
    if(!this.options.appCore.Factories.CollectionsFactory.isInstanceContentModels(_models)){
      console.warn(" attachContentModel function expect a valid EngItemContentTreeDocument parameter");
      throw new Error(" attachContentModel function expect a validEngItemContentTreeDocument parameter");
    }
    this.options._relatedContent = _models;
  };

  EngItemModel.prototype.getContentModels = function(){
    return this.options._relatedContent;
  };

  EngItemModel.prototype.isValidEngItem = function(){
    return this.options.appCore.dataService.areEngeeringItems([this.getType()]);
  };

  EngItemModel.prototype.retrieveBIs = function(level){
	    var that = this;
	    return PromiseUtils.wrappedWithPromise(function(resolve, reject){
	    	if(that.options._BIs && (that.options.level == level)){
	    		return resolve(that.options._BIs);
	    	}

	    	that.options.appCore.dataService.multiexpandBI(that.getID(),level).then(function(_BIs){
	    		that.options._BIs = _BIs;
	    		that.options.level = level;
	    		resolve(_BIs);
	    	}).catch(function(errors){
	    		that.options._BIs = null;
	    		that.options.level = "1";
	    		resolve(null);
	    	});
	    });
  };

  EngItemModel.prototype.isValidForExpandLevel = function(level){
	    var that = this;
	    return PromiseUtils.wrappedWithPromise(function(resolve, reject){
	    	that.retrieveBIs(level).then(function(){
	    		if(that.options._BIs){
	    			var biKeys = that.options.appCore.settingManager.getSetting("BIsKey");
	    			for (var key in that.options._BIs){
	            		if( that.options._BIs[key].sixw === biKeys.type && that.options._BIs[key].object == "VPMInstance"){
	            			if(that.options._BIs[key].count > XEngineerConstants.DATA_LIMIT_FOR_FINAL){
	            				return reject();
	            			}
	            			return resolve(true);
	            		}
            		}
	    			resolve(true);
	    		}else{
	    			resolve(true);
	    		}
	    	}).catch(function(errors){
	    		reject(errors);
	    	});
	    });
  };

  EngItemModel.prototype.getPartNumber = function(){
    return this.options.grid['ds6wg:EnterpriseExtension.V_PartNumber'];
  };
  EngItemModel.prototype.getEngineeringMenu  = function(view){

	  if (view === "my_engItem" || this.options.appCore.sessionManager.shouldShowFinalItems()){
		  return this.options.appCore.commandManager.getMenu("standalone");
	  } else if (view === "eng_item_view")
		  return this.options.appCore.commandManager.getMenu("content");

  };
  EngItemModel.prototype.getCreatedDate = function(){
    return this.options.grid["ds6w:created"];;
  };

  EngItemModel.prototype.getModifedDate = function(){
    return this.options.grid["ds6w:modified"];;
  };

  EngItemModel.prototype.getDescription = function(){
    return this.options.grid["ds6w:description"];
  };

  EngItemModel.prototype.setColor = function(color){
    this.updateOptions({
      color:color
    });
  };


  EngItemModel.prototype.addInstance = function(node){
          this.options.instances.push(node);
  };

  EngItemModel.prototype.setInstances = function(nodes){
          this.options.instances = nodes;

  };

  EngItemModel.prototype.getInstances = function(){
        return this.options.instances;
  };

  EngItemModel.prototype.refreshByModel = function(newModel, freeInput){
    var updatedOptions = this.options.appCore.Factories.ListItemFactory.extractOptionsFromNode(newModel);
    if(updatedOptions){
        this.updateOptions( updatedOptions );
        this.setRealAttributesConvertState(false);
        this.setAttributeConvertionStarted(false);
        if(freeInput){
          newModel.destroy();
          newModel= null;
        }
    }

  };

  //only attributes not config
  EngItemModel.prototype.syncModel = function(){
    var that =this;
    return new Promise(function(resolve, reject){
      that.options.appCore.dataService.getEngItemData(that.getID(),true /*for paramAttr*/)
                          .then(function(items){
                            that.refreshByModel(items[0],true);
                            resolve(true);
                          }).catch(function(reason){
                            reject(reason);
                          });
    });
  };

  EngItemModel.prototype.getRelatedDocument = function(docRelName){
    var that = this;
    return that.options.appCore.dataService.getEngItemRelatedDocuments(that.getID(), docRelName);
  };

  EngItemModel.prototype.getRootType = function(){
    return this.options.appCore.dataService.getRootTypes([this.getType()]);
  };

  EngItemModel.prototype.getMetaType = function(){
    return PromiseUtils.wrappedWithPromise(function(resolve, reject){
        return resolve('businessobject');
    });
  };
  EngItemModel.prototype.launchFilteringCommand = function(){
    var that = this;
    if(that.hasPreferredNGFilterId() || that.hasValidTransientNextGenFilter()){

      that.options.appCore.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
        commandId: XEngineerConstants.LAUNCH_NG_FILTER_CMD,
        context: {}
       });

    }else if(that.isConfigured()){

      that.options.appCore.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
        commandId: XEngineerConstants.SET_PROD_CONF_CMD,
        context: {
            item : that
        }
       });
    }

  };

  EngItemModel.prototype.setPersistedNGFilterContext = function(_filterInfos){
    var that = this;
    if(_filterInfos){
      this.options._NGFilterId = _filterInfos.filterId;
      this.options._NGFilterName = _filterInfos.filterName;
      delete _filterInfos.filter.CVQuery3D;
      this.options._persistedFilter = _filterInfos.filter;
      that.options.appCore.PreferencesManager.saveEngItemOpenPreferences(that);

    }

  };
  EngItemModel.prototype.detachPersistedFilter = function(){
    if(!this.options._NGFilterId && !this.options._NGFilterName) return ;
    this.options._NGFilterId = undefined;
    this.options._NGFilterName = undefined;
    this.options._persistedFilter = undefined;
    this.options.appCore.PreferencesManager.saveEngItemOpenPreferences(this);
  };

  EngItemModel.prototype.hasPreferredNGFilterId = function(){
    var filter = this.getPreferredNGFilter();
    return (filter);
  };

  EngItemModel.prototype.getPreferredNGFilter = function(){
    var that =this;
    var pref = that.options.appCore.PreferencesManager.getEngItemOpenPreferences(that.getID());
    return (pref && pref.filterId && pref.filterName)? pref : null;
  }

  EngItemModel.prototype.getPersistedNGFilterContext = function(){
    return this.options._persistedFilter;
  };
  EngItemModel.prototype.hasValidPersistedNextGenFilter= function(){
    if(!this.getNGFilterId() ||
      !this.getNGFilterName())
      return false;

      return true;
  };
  EngItemModel.prototype.getNGFilterId = function(){
    return this.options._NGFilterId;
  };
  EngItemModel.prototype.getNGFilterName = function(){
    return this.options._NGFilterName;
  };

  EngItemModel.prototype.setTransientNGFilteringContext = function(_nextGenFilterOptions){
      this.options._transientFilter = _nextGenFilterOptions;
      this.options._NGFilterName = (_nextGenFilterOptions) ? _nextGenFilterOptions.filterName || this.options.i18nManager.get("transient.filter") : null;
  };

  EngItemModel.prototype.getTransientNGFilteringContext = function(){
    return (this.hasValidTransientNextGenFilter()) ? this.options._transientFilter : null;
};

  EngItemModel.prototype.hasValidTransientNextGenFilter = function(){
      var filterOptions = this.options._transientFilter;
      if(!filterOptions || !filterOptions.CVQuery || !filterOptions.CVQuery.union)
        return false;

        return true;
  };
  EngItemModel.prototype.getNextGenFilterExpandOptions = function(){
    if(this.hasValidTransientNextGenFilter())
      return this.getTransientNGFilteringContext();
    return this.getPersistedNGFilterContext()
  }

  EngItemModel.prototype.nextGenFilterMultiExpand = function(){
    var that =this, isCancelled = false;
    var parameters = this.getNextGenFilterExpandOptions();
    var _promise = PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){
      if (parameters) {
        var multiExpand_data = UWA.clone(parameters.CVQuery);
        // IR-638639 Do NOT send volume_query in expand.
        if (multiExpand_data.union.expand && multiExpand_data.union.expand.length >= 1) {
           var toremove = [];
           for (var i = 0; i < multiExpand_data.union.expand.length; i++) {
               var entry = multiExpand_data.union.expand[i];
               if (entry.volume_filter) {
                   toremove.push(i);
                }else{
                  entry.expand_iter = "1";//we are only on a level
                }
            }
            for (var j = 0; j < toremove.length; j++) {
                multiExpand_data.union.expand.splice(toremove[j], 1);
            }
        }
        var refAttributesSixw  = that.options.appCore.dataService.getAvailableAttributesForCVQueries();

        var instanceAttributesSixw = that.options.appCore.settingManager.getSetting("select_rel");
        //if no cloud
        // instanceAttributesSixw.push("ds6wg:SynchroEBOMExt.V_InEBOMUser");
        multiExpand_data.select_bo = refAttributesSixw;
        multiExpand_data.select_rel = instanceAttributesSixw;
        multiExpand_data.compute_select_bo = that.options.appCore.settingManager.getSetting("compute_select_bo");
        multiExpand_data.label= that.options.appCore.settingManager.getCVRequestLabel()

        that.options.appCore.dataService.multiExpand(multiExpand_data)
                          .then(function(instances) {
                            if(isCancelled) return resolve([]);
                            resolve(instances);
                          }).catch(function(error) {
                            if(isCancelled) return resolve([]);
                            console.error(error);
                            reject(error);
                          });

      }else{
        reject( new Error("invalid filtering context"));
      }


  });
  _promise.cancelEmbeddedRequest = function(){ ///to remove the race condition
    isCancelled = true;
  };

  return _promise;

  };

  EngItemModel.prototype.getQualifiedAsFinalChildren = function(){
    var that = this, isCancelled = false;
    var _promise = PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){
      that.options.appCore.exportService.expandForQualifiedAsFinal(that.getID())
                          .then(function(nodes){
                            if(isCancelled) return resolve([]);
                            resolve(nodes);
                          }).catch(function(reason){
                            if(isCancelled) return resolve([]);
                            console.error(reason);
                            reject(reason);
                          });
    });

    _promise.cancelEmbeddedRequest = function(){///to remove the race condition
      isCancelled = true;
    };

    return _promise;

  },
/**
*@Param force to force refresh
**/
  EngItemModel.prototype.expandWithConfig = function (force, options){
    var that = this;

    if(that.options.expandPromise && !force)
      return that.options.expandPromise;
    var isCancelled = false;

    that.options.expandPromise = PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {
      that.retrieveFilteringBinary().then(function(res) {
          that.options.appCore.dataService.getEngItemInstances(that.getID(), res ? res.FilterCompiledForm : null, undefined, options)
            .then(function(instances) {
              if(isCancelled) return resolve([]);
              that.setInstances(instances);
              resolve(instances);
            }).catch(function(error) {
              console.error(error);
              reject(error);
            });

        })
        .catch(function(error) {
          if(isCancelled) return resolve([]);
          console.error(error);
          reject(error);
        });
    });

    that.options.expandPromise.cancelEmbeddedRequest = function(){///to remove the race condition
      isCancelled = true;
    };

    return that.options.expandPromise;

  };

  EngItemModel.prototype.retrieveFilteringBinary = function(){
    var that = this;
    return new Promise(function(resolve, reject){
      if(!that.isConfigured() || !that.hasValidConfigContext()){
        return resolve(null);
      }
//      var preferedModel = that.getPreferedAttachedConfigModel();
//      if(!preferedModel.getPreferredConfiguration()){
        that.options.appCore.dataService.createVolatileFilter(that)
          .then(function(res){
            resolve({
              FilterCompiledForm : res ? res.FilterBinaryforExpand : null
            });
          }).catch(function(reason){
            reject(reason);
          });
//      } else{
//
//        resolve({
//          FilterCompiledForm : preferedModel.getPreferredConfiguration().FilterCompiledForm || null
//        });
//      }

    });
  };

  EngItemModel.prototype.getID = function(){
    return this.options.referenceId;
  };

  EngItemModel.prototype.getUuid =  function(){
    return this.getID();
  };

  EngItemModel.prototype.getReferenceVersion = function(){
    return this.options.grid['ds6wg:revision'];
  };

  EngItemModel.prototype.isLastVersion  = function(){
	    if (!this.options.isLastVersion) return true;

	    if(this.options.isLastVersion.toLowerCase() == "true"){
	        return true;
	      }else{
	        return false;
	      }
  };

  EngItemModel.prototype.isConfigured = function(){
    if(Array.isArray(this.getAttachedConfigModels()) && this.getAttachedConfigModels().length>0)
      return true;
    return false;
  };
  EngItemModel.prototype.hasValidConfigContext = function(){
    if(this.getPreferedAttachedConfigModel() && this.getPreferedAttachedConfigModel().getModelVersion() &&
    this.getPreferedAttachedConfigModel().getModelVersion().id ){
      return true;
    }
    return false;
  };


  EngItemModel.prototype.shouldAcceptConfiguration = function(){
    return this.options.appCore.settingManager.shoulAutorizedConfig();
  };

  EngItemModel.prototype.getContextDisplayType  = function(){
    var that = this;
    if(that.options.appCore.settingManager.shoulAutorizedConfig()){
      return 'type-hyperlink';
    }
    return 'type-text';
  };

/*interface for confgured context */
EngItemModel.prototype.getPreferedAttachedConfigModel = function(){
  return this.options.preferedModel;
};

EngItemModel.prototype.attachPreferedConfigModel  = function(preferedModel){

  this.options.preferedModel = preferedModel;
  preferedModel && preferedModel.setRelatedEngItem(this);
};


EngItemModel.prototype.updateUserConfigPreferences = function(){

  return   this.options.appCore.PreferencesManager.saveEngItemOpenPreferences(this);
};

EngItemModel.prototype.attachConfigModels  = function(models){
  this.options.models = models;
};

EngItemModel.prototype.getAttachedConfigModels = function(){
  return this.options.models;
};

EngItemModel.prototype.getAllAvailableVersionsPromises= function(){
  if(!Array.isArray(this.getAttachedConfigModels())) return [];

  var that = this;
  var modelsPromises = [];
  that.getAttachedConfigModels().forEach(function(model){
    modelsPromises.push( model.getListOfVersionsPromise() );
  });
  return modelsPromises;
};

EngItemModel.prototype.unMatch = function(crit){
  var that = this;
  if(!crit)
    return false;
  var criteria =  crit.toLowerCase();
  if((this.getPartNumber() || '').toLowerCase().includes(criteria) ||
  (this.getCreatedDate() || '').toLowerCase().includes(criteria) ||
  (this.getModifedDate() || '').toLowerCase().includes(criteria) ||
  (this.getDescription() || '').toLowerCase().includes(criteria) ||
  (this.getLabel() || '').toLowerCase().includes(criteria) ||
  (this.getOwner() || '').toLowerCase().includes(criteria) ||
  (this.getMaturity() || '').toLowerCase().includes(criteria) ||
  (this.getReferenceVersion() || '').toLowerCase().includes(criteria)
    ){
    return false;
  }
    var result = true;
    (this.getAttributes() || []).forEach(function(attr){
        if(attr.value.toLowerCase().includes(criteria)){
          result = false;
        }
    });

  return result;

};

EngItemModel.prototype.applyFilters = function(){
  this.shouldBeVisible() ? this.show() : this.hide();
};
EngItemModel.prototype.shouldBeVisible = function (params) {
  return (this.isHiddenBySearch() || this.isHiddenByTagger()) ?  false : true;
};
EngItemModel.prototype.isHiddenByTagger = function(){
  return this.options.filteringContext.isFilterOutByTagger;
};
EngItemModel.prototype.isHiddenBySearch = function(){
  return this.options.filteringContext.isFilterOutBySearch;
};

EngItemModel.prototype.setTaggerFilterState = function(state){
  this.options.filteringContext.isFilterOutByTagger = state;
};

EngItemModel.prototype.setSearchFilterState = function(state){
  this.options.filteringContext.isFilterOutBySearch = state;
};

EngItemModel.prototype.hasStaticMapping = function(){
  return false;
};

//use when there are several model
EngItemModel.prototype.setPreferredModelById = function(modelId){
if(modelId && Array.isArray(this.getAttachedConfigModels())){
  var targetedModel = this.getAttachedConfigModels().find(function(model){
    return model.getID() === modelId;
  });
  if(targetedModel)
    this.attachPreferedConfigModel(targetedModel, false);

}
};

EngItemModel.prototype._syncWithAttachedModel = function(){
	return this._syncWithAttachedModelAndVersion(null);
};

EngItemModel.prototype._syncWithAttachedModelAndVersion = function(modelversion){
  var that = this;
  this.options.configInitPromise = new Promise(function(resolve, reject) {
    if (!that.getID()) {
      return reject("not valid Object");
    }
    var pid = that.getID();
    var parameter = {
      pid: pid
    };
    that.options.appCore.dataService.getEngItemConfigurationInfo(parameter)
      .then(function(relatedModels) {
        if (relatedModels.length > 0) {
          that.attachConfigModels(relatedModels);
          (relatedModels.length===1) && (that.attachPreferedConfigModel(relatedModels[0], false /*no synch*/));
          if(relatedModels.length >1 && that.options.appCore.PreferencesManager.getEngItemOpenPreferences(pid)){
            var confPref = that.options.appCore.PreferencesManager.getEngItemOpenPreferences(pid);
            for (var i = 0; i < relatedModels.length; i++) {
              if(relatedModels[i].getID() === confPref.model){
                that.attachPreferedConfigModel(relatedModels[i]);
                break;
              }
            }
          }

          if(that.getPreferedAttachedConfigModel()){


        		  that.getPreferedAttachedConfigModel()._synchronizeModelVersions(modelversion).finally(function(){
                      resolve(true);
                    });


          }else{
            resolve(true);
          }

        } else {
          that.attachConfigModels([]);
          that.attachPreferedConfigModel(null);
          resolve(true);
        }

      })  .catch(function(error) {
        console.error(error);
        that.attachConfigModels([]);
        that.attachPreferedConfigModel(null);
        reject(error);
      });

  });

  return this.options.configInitPromise;

};

  EngItemModel.prototype.getConfigInitPromise = function(){
    if(this.options.configInitPromise)
      return this.options.configInitPromise;

    return this._syncWithAttachedModel();
  };
  EngItemModel.prototype.getTypeForVersionGraph = function(){
    if(this.isConfigured()){
      return "Model";
    }
    return this.getType();
  };
  EngItemModel.prototype.getIdForVersionGraph = function(){
    if(this.isConfigured()){
      var version = this.getPreferedAttachedConfigModel().getPreferredVersion();
      return  version ? this.getPreferedAttachedConfigModel().getCurrentVersionID() : null;
    }
    return this.getID();
  };
  EngItemModel.prototype.getDisplayVersionForIdcard = function(){
    // version shoudn't be displayed when it's filtered
    if(this.isConfigured() && (this.hasValidTransientNextGenFilter() || this.hasValidPersistedNextGenFilter()))
      return null;
    if(this.isConfigured()){
      var version = this.getPreferedAttachedConfigModel().getPreferredVersion();
      return version ? this.getPreferedAttachedConfigModel().getCurrentVersionRevision() : "N/A";
    }
    return this.getReferenceVersion();
  };

  EngItemModel.prototype.getTitleForIdcard = function(){
    // if(this.isConfigured()){
    //   return this.getLabel() + ' '+ this.getReferenceVersion();
    // }
    return this.getLabel() ;
  };

  EngItemModel.prototype.getConfigurationDisplayName = function(){
    if(this.hasValidTransientNextGenFilter() || this.hasValidPersistedNextGenFilter())
      return '['+this.getNGFilterName()+ ']' ;
    if(this.isConfigured()){
      var conf = this.getPreferedAttachedConfigModel().getPreferredConfiguration();
      return conf ? ' ['+conf.marketingName+ ']' : ' ['+this.options.appCore.i18nManager.get("eng.conf_placeholder")+ ']' ;
    }
    return null;
  };


  EngItemModel.prototype.getThumbnail = function(){
    return this.options.thumbnail;
  };


  EngItemModel.prototype.getViewType = function(){
    return this.options.viewType;
  };

  EngItemModel.prototype.toggleSelection = function(){

    return this.isSelected() ? this.unselect() : this.select();
  };

  EngItemModel.prototype.getQuantity =  function(){
    return this.getInstances().length;
  };


  EngItemModel.prototype.getAttributes = function(){
    return this.options.attributes;
  };
/*
EngItemModel.prototype.getAttribute = function(name){
    switch (name) {
      default:
          var attrs = this.getAttributes();
          for(var idx=0; idx < attrs.length; idx++){
            if(attrs[idx].name === name){
              return attrs[idx];
            }
          }

    }

  };
  */
    EngItemModel.prototype.isAttributePending =  function(attrName){
      if(!Core.is(attrName , 'string')) return false;//because unknown
      var pendingValue = ['#loading#','#queued#'];

      return pendingValue.indexOf(this.getAttributeValue(attrName)) !== -1;
    };

    EngItemModel.prototype.attributeRemoteLoadingNotStart =  function(attrName){
      if(!Core.is(attrName , 'string')) return false;//because unknown
      var value = this.getAttributeValue(attrName);

      return value === '#queued#' || value === undefined ;
    };

    EngItemModel.prototype.isAttributeLoadFailed = function(attrName){
      return this.getAttributeValue(attrName) === '#failed#';
    };
    EngItemModel.prototype.getSortableAttributeValue = function(name){
    switch (name) {
      default:
          var attrs = this.getSortableAttributes();
          for(var idx=0; idx < attrs.length; idx++){
            if(attrs[idx].name === name){
              return attrs[idx].value;
            }
          }

    }
  };
    EngItemModel.prototype.getSortableAttributes = function(){
      var that = this;
      var attribute = [];
      if(!this.options){
        console.error(' you need to call basic method before !');
             return attribute;
      }

      attribute.push({ name:'Title', value:this.options.grid['ds6w:label']});
      attribute.push({ name:'Maturity', value: this.options.grid['ds6w:status'] });
      attribute.push({ name:'Owner', value: this.options.grid['ds6w:responsible'] });
      attribute.push({ name:'CreationDate', value: this.options.grid['ds6w:created']});
      attribute.push({ name:'ModifiedDate',  value: this.options.grid['ds6w:modified']});
      attribute.push({ name:'PartNumber',  value: this.options.grid['ds6wg:EnterpriseExtension.V_PartNumber']});

     return attribute;
    };

    EngItemModel.prototype.getOrderedAttribute = function(){
      var prefViewDetail = this.getPrefereredViewDetails();
      var priorAttrList = [];
      if(prefViewDetail && prefViewDetail[this.getType()]) {
        priorAttrList = prefViewDetail[this.getType()].visibleAttr ;

      } else{

        var defaultAttrList = [];
        defaultAttrList.push("ds6w:status");
        defaultAttrList.push("ds6w:responsible");
        defaultAttrList.push("ds6wg:EnterpriseExtension.V_PartNumber");
        defaultAttrList.push("ds6w:modified");
        defaultAttrList.push("ds6w:created");

        priorAttrList = defaultAttrList;
      }
      var that = this;
      var result = [];
      priorAttrList.forEach(function(attr){
    	  var attributeValue = that.options.grid[attr];
      //  if (attributeValue != undefined) {
          if (attr === "ds6wg:MaterialUsageExtension.DeclaredQuantity") {
            var f_attributeValue = parseFloat(attributeValue);
            if (!isNaN(f_attributeValue)) {
              attributeValue = Utils.convertVolumeInIUForDisplay(f_attributeValue);
              result.push({
                name: that.options.appCore.i18nManager.get("MaterialUsageExtension.DeclaredQuantity"),
                value: attributeValue
              });
            }

          } else if (attr === "ds6wg:EnterpriseExtension.V_PartNumber") {
            if (attributeValue === null) {
              attributeValue = that.options.appCore.i18nManager.get("None");
            }
            result.push({
              name: that.options.appCore.i18nManager.get(attr),
              value: attributeValue
            });
          } else {
            if (that.getParamDateAttributes().indexOf(attr) > -1) { //it is a param date attribute
              attributeValue = Utils.formatCustomDateAttribute(attributeValue) || '';
            }
            result.push({
              name: that.options.appCore.i18nManager.get(attr),
              value: attributeValue
            });
          }

  //      }

        });

      return result;
    };

  EngItemModel.prototype.getParamDateAttributes = function(){
    if(!this.customDateAttrs){
      this.customDateAttrs = this.options.appCore.dataService.getParametricalAttributesOf("VPMReference") || [];
      this.customDateAttrs = this.customDateAttrs.filter(function(attr){
        return (attr.type.toLowerCase() ==="date");
      }).map(function(attr){
        return attr.sixWTag;
      });
    }
    return this.customDateAttrs;
  };

  EngItemModel.prototype.getPrefereredViewDetails = function(){
    var prefData = (this.options.appCore) ? this.options.appCore.PreferencesManager.getViewPreference() : null;
    return (prefData && prefData.savedSettings) ? prefData.savedSettings[prefData.ctxView] : {};
  //  console.log();
  };


  EngItemModel.prototype.getOwner = function(){
    return this.options.grid['ds6w:responsible'];
  };

//previously getMaturity but in collission with native API
  EngItemModel.prototype.getMaturity = function(){
    return this.options.grid['ds6w:status'];
  };

  EngItemModel.prototype.setMaturity = function(newStatus){
    if(newStatus && newStatus.length >0)
      this.options.grid['ds6w:status'] = newStatus;
  };

  EngItemModel.prototype.getLabel = function(){
    return this.options.grid['ds6w:label'];
  };


  EngItemModel.prototype.getDisplayName = function(){
    return this.getLabel() + " " + this.getReferenceVersion();
  };

  EngItemModel.prototype.getShading =  function(){
    return this.options.shading;
  };

  EngItemModel.prototype.isCut = function(){
    return this.options.isCut;
  };
/*
  EngItemModel.prototype.setCut = function(selection){
    if (selection  === undefined) {
      this.options.isCut = ! this.options.isCut;
    } else {
      this.options.isCut = selection;
    }
  };
  */


/*

  EngItemModel.prototype.resolveAttributeValue = function(attr){
    switch (attr) {
      case 'type':
          return this.options.i18nManager.get("ds6w:type/"+this.getType());
        break;
      default:
        return this.options.grid[attr];
    }
    return null;
  };
  */
  /*

  EngItemModel.prototype.compareTo = function(node, compareOn){
    return this.resolveAttributeValue(compareOn).localeCompare(node.resolveAttributeValue(compareOn));
};
*/

EngItemModel.prototype.getNodesByRelId = function(instanceID){
	  var childrenInstByID = [];
	  var childrenInst = this.getInstances();
	  for (var i = 0; i < childrenInst.length; i++) {
        if (childrenInst[i].getRelationID() === instanceID)
      	  childrenInstByID.push(childrenInst[i]);
    }

	  return childrenInstByID;
}

EngItemModel.prototype.getGlobalType = function(){
    return this.options.padgrid["ds6w:globalType"];
  };

  EngItemModel.prototype.isRepresentation = function(){
   	  var isRepresentation = false;

   	  if (this.getGlobalType() === "ds6w:Document")
   		isRepresentation = true;

      return isRepresentation;
    };

    EngItemModel.prototype.isEngineeringItem = function(){
     	  var isRepresentation = false;

     	  if (this.getGlobalType() === "ds6w:Part")
     		isRepresentation = true;

        return isRepresentation;
      };

      EngItemModel.prototype.isDocument = function(){
     	  var isRepresentation = false;

     	  if (this.getGlobalType() === "ds6w:FileDocument")
     		isRepresentation = true;

        return isRepresentation;
      };

      EngItemModel.prototype.isCoreMaterialGroupNode =  function(){
        return false;
      }
      EngItemModel.prototype.isMaterialQuantity = function(){
          if(this.isAttributePending('CoreMaterial') || this.isAttributePending('ds6wg:MaterialUsageExtension.DeclaredQuantity') )
            return false;
            if(this.isAttributeLoadFailed('CoreMaterial') || this.isAttributeLoadFailed('ds6wg:MaterialUsageExtension.DeclaredQuantity') )
            return false;


       	  if (this.options.grid.hasOwnProperty('CoreMaterial') && this.options.grid['CoreMaterial'].trim().length!==0
       			  && this.options.grid.hasOwnProperty('ds6wg:MaterialUsageExtension.DeclaredQuantity')&& this.options.grid['ds6wg:MaterialUsageExtension.DeclaredQuantity'].trim().length!==0)
       		    return true;

             return false;
        };


  EngItemModel.prototype.getTenant = function(){
    return this.options.tenant; //to be fix in factory
  };


  EngItemModel.prototype.getDisplayedGridViewAttribute = function(){

      var priorAttrList = [];

    priorAttrList.push("ds6w:status");
    priorAttrList.push("ds6w:responsible");
    priorAttrList.push("ds6wg:EnterpriseExtension.V_PartNumber");
    priorAttrList.push("ds6w:created");
    priorAttrList.push("ds6w:modified");
    priorAttrList.push("ds6w:cadMaster");
    priorAttrList.push("ds6w:description");
    priorAttrList.push("ds6wg:MaterialUsageExtension.DeclaredQuantity");
    priorAttrList.push("ds6w:reservedBy");


      var that = this;
      var result = [];
      priorAttrList.forEach(function(attr){
    	  var attributeValue = that.options.grid[attr];
        if (attributeValue != undefined && attributeValue !== "" ){
        		result.push({name: that.options.appCore.i18nManager.get(attr), value: attributeValue});
        }

        });

      return result;
    };

    EngItemModel.prototype.getAllGridViewAttribute = function(){

        var priorAttrList = [];

      priorAttrList.push("ds6w:label");
      priorAttrList.push("ds6wg:revision");
      priorAttrList.push("ds6w:type");
      priorAttrList.push("ds6w:cadMaster");
      priorAttrList.push("ds6w:status");
      priorAttrList.push("ds6w:responsible");
      priorAttrList.push("ds6wg:EnterpriseExtension.V_PartNumber");
      priorAttrList.push("ds6w:modified");
      priorAttrList.push("ds6w:created");
      priorAttrList.push("ds6w:description");
      priorAttrList.push("ds6wg:MaterialUsageExtension.DeclaredQuantity");
      priorAttrList.push("ds6w:reservedBy");

        var that = this;
        var result = [];
        priorAttrList.forEach(function(attr){
      	  var attributeValue = that.options.grid[attr];
          if (attributeValue != undefined && attributeValue !=""){
          		result.push({name: that.options.appCore.i18nManager.get(attr), value: attributeValue});
          }

          });

        return result;
      };

return EngItemModel;


});

/**
 * @module DS/ENOXEngineer/components/XEngListView/js/mixins/EngItemViewsManager
 */
define('DS/ENOXEngineer/components/XEngListView/js/mixins/EngItemViewsManager', [
  'UWA/Core',
  'UWA/Class',
  'UWA/Class/Promise',
  'DS/ENOXEngineer/utils/Utils',
  'DS/Utilities/Utils',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'DS/ENOXEngineer/services/XEngContextManager',
  'DS/Core/PointerEvents',
  'css!DS/ENOXEngineer/components/XEngListView/css/EngItemContentView.css'
], function(UWA, Class, Promise, Utils, WebUtils, XEngineerConstants, xEngAlertManager, XEngContextManager,PointerEvents) {

    'use strict';

//private variable
    const EVENT_PERSIST_VIEW = 'event-persist-view';
   /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/components/XEngListView/js/mixins/EngItemViewsManager
     * @param {Object} options options hash or a option/value pair.
     */
     var EngItemViewsManager = Class.extend(
        /**
         * @lends module:DS/ENOXEngineer/components/XEngListView/js/mixins/EngItemViewsManager.prototype
         */
        {
        init: function(options) {
            throw new Error("this is an abstract class it shouldn't be instanciated");
        },
        instanciedViews : {

        },
        switchView : function(viewId){
          var that = this;
          this.hidePreviousView();
          this.preferredView = viewId;
          this.toggleToolbarItems();
          //need to be perform before the view rendering
          try {
            if(that.preferredView === 'XENTile'&& that.getModels() ){
              var _children= that.getModels().getChildren();
              if(Array.isArray(_children) && _children.length>0){ //
                this.renderPreferredView();

              }
              _children = undefined;
            }else if(that.getModels()){ //on datagridview
              that.renderPreferredView();
            }
          } catch (error) {
            console.error(error);
            that.renderPreferredView();
          }
          this._persistPreferredView(viewId);

         },
        _persistPreferredView: function(_viewId){
          this.sandbox.core.localStorage.setItem(this.sandbox.getComponentName()+"_PrefView",_viewId);
        },
        _getPersistedPrefView: function(){
          return this.sandbox.core.localStorage.getItem(this.sandbox.getComponentName()+"_PrefView");
        },
        hidePreviousView : function(){
          var that =this;
          Object.keys(this.instanciedViews).forEach(function(instanceId){
            that.instanciedViews[instanceId].elements.container.classList.remove('visible');
          });

        },
        renderPreferredView : function(){
          var that = this;
          var currentView = this.getPreferredViewInstance();
          currentView.elements.container.classList.add('visible');
        },
        getPreferredViewInstance : function(){
          var that = this;
          var _preferredView  = that.getPreferredView();
          if(!this.instanciedViews[_preferredView]){
            var Clazz = that._getViewClass(_preferredView);

            this.instanciedViews[_preferredView] = new Clazz(that.getViewOptions(_preferredView));
            this.activeView = this.instanciedViews[_preferredView] ;
            that.activeView.getContent().inject(that.getContent());
            that.configureViewInstance(that.activeView);
          }
         return this.instanciedViews[_preferredView];
        },
        onCellDoubleClick: function(params){
          var that = this;
          that.openItem(params);
        },
        openItem : function(params){
          var that = this;
          var node = params.cellModel;

          if(!node || typeof node !== Object) {
            node = params.nodeModel;
          }
          //use an API like is Engineering Item
          if(node) {
            if(node.isEngineeringItem()) {
              that.sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND,{
                commandId: XEngineerConstants.OPEN_ENG_ITEM,
                context: {
                    item: {
                      objectId: node.getID(),
                      objectType: node.getType(),
                      itemListModel: node
                    }
                  }
              });
            } else {
              if (!node.isSelected()) {
               that.getModels().unselectAll();
                    node.select();
                }
              that.sandbox.core.mediator.publish(XEngineerConstants.EVENT_TRIPTYCH_SHOW_PANEL, 'right');
            }
          }
        },
        getDefauftView : function(){
          return (this._getPersistedPrefView()) ? this._getPersistedPrefView() : 'DataGridView';//'XENTile';
        },
        getPreferredView : function(){
          var that = this;
          if(this.preferredView)
            return this.preferredView;

          var _defaultView = this.getDefauftView();
          if(_defaultView){
            that.views = that.views || [];
            for (var i = 0; i < that.views.length; i++) {
              if(that.views[i].id === _defaultView){
                this.preferredView = that.views[i].id;
                return that.views[i].id;
              }

            }
          }
          this.preferredView = that.views[0].id;
          return that.views[0].id;
        },

        configureViewInstance : function(view){
           var that =this;

           view.onDelayedModelDataRequest = WebUtils.debounce(function(params) {
            if(params && params.collectionView && params.collectionView.model && that.getModels()){
              var dataGridView = params.collectionView;
              var visibleNodes = dataGridView.model.slice(params.startNodeIndex, params.endNodeIndex);
              if(Array.isArray(visibleNodes) && visibleNodes.length>0){
                //don't specify a policy and the default will be applied

                that.getModels().fillAttributesAsync4VisibleNodes(visibleNodes);
              }
            }
          }, 200);

           if(this.getPreferredView() === 'DataGridView'){
               that.eventHandlerOnGridView(view);
               view.buildDefaultContextualMenu = function(params, options){
                      var node = ( params.cellInfos && params.cellInfos.nodeModel) ? params.cellInfos.nodeModel : null;
                      var rowID = ( params.cellInfos)  ? params.cellInfos.rowID : null;
                      if(rowID ===-1 || !node){
                         return this._contextualMenuBuilder ? this._contextualMenuBuilder.buildMenu(params, options) : [];
                      }
                      //get selected cell : this.getCellsXSO().get()
                   //Right Click (open contextual menu) row should select
                      if (!node.isSelected()){
                  this.unselectAll();
                  node &&node.select();
              }
                    return (node)  ? node.getEngineeringMenu(XEngineerConstants.ENG_ITEM_VIEW) : [];
                 };

          }else{

            view.selectionBehavior = {
              canInteractiveMultiselectWithCheckboxClick : true,
              canMultiSelect : true,
              enableFeedbackForActiveCell : true,
              enableShiftSelection : true,
              toggle : true,
              unselectAllOnEmptyArea : true
            };
            //override the default behavior
             view.onDragStartCellDefault = function(event){
               return true;
             };
             view.onCellDoubleClick(that.onCellDoubleClick.bind(that));

             //Method in tile view on title click
             view._onCellTitleClick= function(cellInfos){
                var params = cellInfos;
                that.openItem(params);

             };

             view._onPostRequestCellCB = function(cellInfos){
              //if big image
               cellInfos.cellView.contentView.elements.picture.setStyle('background-size', 'contain');
              //else
              //cellInfos.cellView.contentView.elements.picture.setStyle('background-size', 'auto');

             };



            view.onContextualEvent = {
              'callback': function (params) {
                  var menu = [];
                  if (params && params.cellInfos) {
                     if (params.cellInfos.cellModel) {
                       var model = params.cellInfos.cellModel;
                       menu = model.getEngineeringMenu(XEngineerConstants.ENG_ITEM_VIEW);
                     }
                   }
                  return menu;
              }
          };
          view.model = that.getModels();
          }

        },

        eventHandlerOnGridView: function(view){
            var that = this;
            var timer = 0;
            var delay = 500;
            var prevent = false;

            view.addEventListener('change', function(e, cellInfos) {
              if (cellInfos && cellInfos.nodeModel) {
                if (cellInfos.nodeModel.isSelected()) {
                  cellInfos.nodeModel.unselect();
                } else {
                  cellInfos.nodeModel.select();
                }
              }
            });

            view.addEventListener('dragstart', function(e, cellInfos) {
              XEngContextManager.dragStartedInXENG = true;
            });

            view.addEventListener('dragend', function(e, cellInfos) {
               XEngContextManager.dragStartedInXENG = false;
            });

            view.addEventListener(PointerEvents.POINTERHIT, function(evt, cellInfos){

               if(cellInfos !== undefined && cellInfos.columnID == XEngineerConstants.TITLE_COLUMN_NO){
                 if(evt.multipleHitCount === 1){
                   timer = setTimeout(function(){
                  if(!prevent && evt.target.hasClassName("wux-tweakers-string-label")){
                    var params = cellInfos;
                    that.openItem(params);
                  }
                  prevent = false;

                },delay);


              }else if(evt.multipleHitCount >= 2){
                 clearTimeout(timer);
                 prevent = true;
              }


            }

           });

          view.addEventListener('click', function(evt, cellInfos){
            if(cellInfos !== undefined && cellInfos.rowID !== -1){

              var hasClickedOnLink = evt.target.hasClassName("wux-tweakers-string-label");

              if(!hasClickedOnLink) return ; // usr has not clicked on  the link

              var columnKey = evt.dsModel.layout.getDataIndexFromColumnIndex(cellInfos.columnID);

              if(columnKey === XEngineerConstants.TITLE_COLUMN_NO){
                if(evt.multipleHitCount === 1){
                  timer = setTimeout(function(){
                 if(!prevent && evt.target.hasClassName("wux-tweakers-string-label")){
                   var params = cellInfos;
                   that.openItem(params);
                 }
                 prevent = false;

               },delay)


             }else if(evt.multipleHitCount >= 2){
                clearTimeout(timer);
                prevent = true;
             }


           }else if(columnKey === "ds6w:status"){
                 that.selectSingleInstance(cellInfos);
                that.sandbox.core.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                commandId: XEngineerConstants.MATURITY_GRAPH_CMD,
                context: {
                    item: that.getModels().getSelectedNodes()
                }
              });

            }else if(columnKey === "ds6w:responsible"){
                 that.selectSingleInstance(cellInfos);
                that.sandbox.core.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                commandId: XEngineerConstants.CHANGE_OWNER_CMD,
                context: {
                  item: that.getModels().getSelectedNodes()
                }
                });
            }else if(columnKey === "ds6wg:EnterpriseExtension.V_PartNumber"){
                that.selectSingleInstance(cellInfos);
               that.sandbox.core.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
               commandId: XEngineerConstants.SET_PART_NUMBER_CMD,
               context: {
                 item: that.getModels().getSelectedNodes()
               }
             });
          }else if(columnKey === "ds6wg:revision"){
               that.selectSingleInstance(cellInfos);
              that.sandbox.core.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
              commandId: XEngineerConstants.VERSION_GRAPH_CMD,
              context: {
                item: that.getModels().getSelectedNodes()
              }
            });
          }else if(columnKey === "VariantEffectivity"){
               that.selectSingleInstance(cellInfos);
              that.sandbox.core.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
              commandId: XEngineerConstants.EDIT_VARIANT_EFFECTIVITY_CMD,
              context: {
                item: that.getModels().getSelectedNodes()
              }
            });
          }else if(columnKey === "CurrentEvolutionEffectivity"){
                that.selectSingleInstance(cellInfos);
              that.sandbox.core.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
              commandId: XEngineerConstants.SET_EVOLUTION_EFFECTIVITY_CMD,
              context: {
                item: that.getModels().getSelectedNodes()
              }
            });
          } else if (columnKey === "ds6wg:MaterialUsageExtension.DeclaredQuantity"){
              that.selectSingleInstance(cellInfos);
              that.sandbox.core.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
              commandId: XEngineerConstants.CHANGE_MAT_QUANTITY_CMD,
              context: {
                item: that.getModels().getSelectedNodes()
              }
            });
          }
         }
        });
        },
        selectSingleInstance : function(cellInfos){
          var that = this;
          if(that.getModels().getSelectedNodes().length >= 1){
              that.unSelectAll();
          }
          cellInfos.nodeModel.select();
        },

        getViewOptions: function(viewId){
          var options = {};
          var that = this;
        //  widget.addPreference({name: 'columnHeaders', type: 'text', label:'columnHeaders', value: that.getColOrder() , defaultValue:that._getTableViewColumnConfiguration()});
          // if default is not equal to new then take new
          if(viewId == "DataGridView"){

                options = {
                  treeDocument: that.getModels(),
                  columns: that._getTableViewColumnConfiguration(),
                  showNodeKPIColorFlag: that.getModels().isColorizeEnabled(),
                  rowSelection: 'multiple',
                  cellSelection:'multiple',
                  identifier:'XEN-DatagridView_'+that.sandbox.core.settingManager.getWidgetId(),
                  defaultColumnDef: {//Set default settings for columns
                      "width": "auto",
                      "typeRepresentation": "string",
                      "editionPolicy": "EditionOnDoubleClick"
                  }
                };

         } else {

              options = {
                  height: 'inherit',
                  displayedOptionalCellProperties: ['contextualMenu', 'statusbarIcons','description', 'activeFlag'],
                  useDragAndDrop: true,
                  sandbox:   this.sandbox,
                  onDragStartCell : function (e, dndInfos){
                      var model;
                      var Nodemodel = dndInfos.nodeModel;
                      if (Nodemodel) {
                          model = Nodemodel.getTreeDocument();
                      }
                    e.dataTransfer.effectAllowed = 'all';
                    XEngContextManager.dragStartedInXENG = true;
                    var dragData = Utils.prepareDragData(model.getSelectedNodes());
                    e.dataTransfer.setData('Text', dragData);
                    return true;
                  },
                  onDragEndCell: function (e, dndInfos){
                	  XEngContextManager.dragStartedInXENG = false;
                    return true;
                  }
                };


        }
          return options;

        },
        _getViewClass : function(viewId){
          var that = this;
          for (var i = 0; i < this.views.length; i++) {
            if(this.views[i].id === viewId)
              return this.views[i].Clazz;
          }

          return null;
        },
        _getTableViewColumnConfiguration: function() {
          var that = this;
          var parametricalAttributes = that.sandbox.core.dataService.getParametricalAttributesOf("VPMReference");
          var attrsInfo = that.getModels().getAvailableAttributesForDisplay();
          var cols =  [];

          var basicAttrDisplayOrder = [
            "ds6w:label",
            "ds6wg:revision",
            "ds6w:status",
            "ds6wg:EnterpriseExtension.V_PartNumber",
            "ds6w:responsible",
            "ds6w:description",
            "ds6w:type",
            "ds6w:cadMaster",
            "ds6w:identifier",
            "ds6wg:PLMReference.V_isLastVersion",
            "ds6w:modified",
            "ds6w:created",
            "ds6wg:MaterialUsageExtension.DeclaredQuantity",
            "ds6w:reserved",
            "ds6w:reservedBy"

          ];

          //Basic attributes column configuration to be displayed first.
          basicAttrDisplayOrder.forEach(function(attrName) {
              attrsInfo.forEach(function(attrInfo){
                if(attrInfo.sixWTag === attrName) {
                  that.getColumnConfiguration(attrInfo, cols);
                }
              })
          });

          // //Effectivity column configuration is made only if configuration is set.
          // if(that.sandbox.core.contextManager.getActiveEngItem().getPreferedAttachedConfigModel()) {
          //    cols.push({
          //      "text": that.sandbox.i18nManager.get("label_Variant"),
          //      "dataIndex": "variant"
          //    });
          //    cols.push({
          //      "text": that.sandbox.i18nManager.get("label_Evolution"),
          //      "dataIndex": "evolution"
          //    });
          // }
          that.getModels().getAdditionalColumns().forEach(function(col){
            var colDef = {
              "text": col.text,
              "dataIndex": col.dataIndex,
              "maxWidth": col.maxWidth,
              "minWidth": col.minWidth,
              "width": col.width,
            };
            if(['Effectivity','ProjectedEvolutionEffectivity','CoreMaterial', 'Configuration'].indexOf(col.dataIndex) === -1){
              colDef = UWA.extend(colDef, {
              "typeRepresentation": "url",
              "hyperlinkTarget": "_self",
              getCellValue: function(cellInfos){
            	  if (!cellInfos || !cellInfos.nodeModel) return {};
                if(!cellInfos.nodeModel.isEngineeringItem()) return {
                    label: '',
                    url: '#UNEXISTANT_ID'
                  };
                var value = cellInfos.nodeModel.options.grid[col.dataIndex];
                if(!value || cellInfos.nodeModel.isAttributePending(col.dataIndex)){
                	if (cellInfos.nodeModel.getViewType() === "reference"){
                		value = "";
                	} else{
                    // display loading as place holder
                    value = that.sandbox.i18nManager.get("loading");
                  }

                }else if( value.trim().length===0){
                  value = that.sandbox.i18nManager.get("None");
                }
                return {
                  label: value,
                  url: '#UNEXISTANT_ID'
                };
              },
              getCellValueForCopy: function(cellInfos){
                     return cellInfos.cellModel.label;
              }
              } );

            }else{
              colDef = UWA.extend(colDef,{
                getCellValue: function(cellInfos){
                	 if (!cellInfos || !cellInfos.nodeModel) return ;
                  if(!cellInfos.nodeModel.isEngineeringItem()) return '';
                  var value = cellInfos.nodeModel.options.grid[col.dataIndex];
                  if(!value || cellInfos.nodeModel.isAttributePending(col.dataIndex)){
                  	if (cellInfos.nodeModel.getViewType() === "reference"){
                  		value = "";
                  	} else{
                      // display loading as place holder
                      value = that.sandbox.i18nManager.get("loading");
                    }
                  }else if(col.dataIndex == 'Configuration' && value.trim().length===0){
                      value = '';
                  }else if(typeof value.trim ==="function" && value.trim().length===0){
                    value = that.sandbox.i18nManager.get("None");
                  }
                  return value;
              }
            });
            }
            cols.push(colDef);
          });

          //Display every parametric attribute at the end of table.
          that._getParametricalAttribute(parametricalAttributes, cols);
          return cols;
        },
        getColumnConfiguration: function(attrInfo, cols){
          var that = this;
          switch (attrInfo.sixWTag) {
            case "ds6w:label":
                    cols.push({
                      "text": that.sandbox.i18nManager.get("ds6w:label"),
                      // "dataIndex": "ds6w:label",
                      "editableFlag":"true",
                      "editionPolicy": "EditionOnDoubleClick",
                      "typeRepresentation": "url",
                      "hyperlinkTarget": "_self",
                      "dataIndex": "tree",
                      "alwaysVisibleFlag": "true",
                      "pinned": "left",
                      "width": "250",
                      getCellValue: function(cellInfos){
                    	  if (!cellInfos || !cellInfos.nodeModel) return {};

                        return {
                          icon: cellInfos.nodeModel.getTypeIcon(),
                          label: cellInfos.nodeModel.options.label,
                          url: '#UNEXISTANT_ID'
                        };
                      },

                      setCellValue: function(cellInfos, value){
                        //TODO once the validation of title as mandatory attribute is handled by DataGridView team remove the below validation
                        if(value.label.length == 0 || value.label.trim() === ""){
                           that.updateContent([cellInfos.nodeModel.getID()]);
                           return xEngAlertManager.warningAlert(that.sandbox.i18nManager.get('Title_empty'));
                        }
                        var attrDataIndex = that.activeView.layout.getDataIndexFromColumnIndex(cellInfos.columnID);
                        that.sandbox.core.dataService.updateAttr(cellInfos,value.label,attrDataIndex).then(function(data) {
                             if(null!=data){
                               that.updateContent([cellInfos.nodeModel._options.referenceId]);
                             }
                        });
                      },

                      getCellValueForCopy: function(cellInfos){
                         return cellInfos.cellModel.label;
                      },
                      processCellValueFromPaste: function(cellInfos, textToPaste){
                        return {
                          label:textToPaste
                        };
                      }



                    });

                    break;
                    case "ds6wg:revision" :
                       cols.push({
                             "text": attrInfo.attrNls,
                             "dataIndex": attrInfo.sixWTag,
                             "typeRepresentation": "url",
                             "hyperlinkTarget":"_self",
                             getCellValue: function(cellInfos){

                            	 if (!cellInfos || !cellInfos.nodeModel) return {};

                                return {

                                //icon: (cellInfos.nodeModel.getReferenceVersion() == undefined || cellInfos.nodeModel.isLastVersion()) ? "":"attention",
                                  label: (!cellInfos.nodeModel.options.grid[attrInfo.sixWTag]) ? '' : cellInfos.nodeModel.options.grid[attrInfo.sixWTag],
                                  url: '#UNEXISTANT_ID'
                                };
                              },
                              getCellValueForCopy: function(cellInfos){
                                 return cellInfos.cellModel.label;
                              }

                           });

                           cols.push({
                              "text": that.sandbox.i18nManager.get("label_Instance_Name"),
                              "dataIndex": "instanceName",
                              "editableFlag":"true",
                              "editionPolicy": "EditionOnDoubleClick",
                              getCellEditableState: function(cellInfos){
                                return cellInfos && cellInfos.nodeModel && cellInfos.nodeModel.isEngineeringItem();
                              },
                               setCellValue: function(cellInfos, value){
                               var attrDataIndex = that.activeView.layout.getDataIndexFromColumnIndex(cellInfos.columnID);
                               that.sandbox.core.dataService.updateAttr(cellInfos,value,attrDataIndex).then(function(data) {
                                    if(null!=data){
                                      that.updateContent([cellInfos.nodeModel.getID()]);
                                    }
                               });
                             }

                           });
                         break;
            case "ds6w:status":
            case "ds6w:responsible":
                    cols.push({
                      "text": attrInfo.attrNls,
                      "dataIndex": attrInfo.sixWTag,
                      "typeRepresentation": "url",
                      "hyperlinkTarget":"_self",
                      getCellValue: function(cellInfos){
                    	  if (!cellInfos || !cellInfos.nodeModel) return {};

                          return {
                            label: cellInfos.nodeModel.options.grid[attrInfo.sixWTag] === undefined ? '' : cellInfos.nodeModel.options.grid[attrInfo.sixWTag],
                            url: '#UNEXISTANT_ID'
                          };
                        },
                      getCellValueForCopy: function(cellInfos){
                           return cellInfos.cellModel.label;
                      }


                    });
                  break;
            case "ds6wg:EnterpriseExtension.V_PartNumber":
                      cols.push({
                          "text": attrInfo.attrNls,
                          "dataIndex": attrInfo.sixWTag,
                          "typeRepresentation": "url",
                          "hyperlinkTarget":"_self",
                           getCellValue: function(cellInfos){
                        	   if (!cellInfos || !cellInfos.nodeModel) return {};

                            if(!cellInfos.nodeModel.isEngineeringItem() || (cellInfos.nodeModel._isFromOriginalModel() === false && cellInfos.nodeModel.isMaterialQuantity())) return {
                              label: '',
                              url: '#UNEXISTANT_ID'
                            };

                              return {
                                label: (!cellInfos.nodeModel.options.grid[attrInfo.sixWTag]) ? that.sandbox.i18nManager.get("None") : cellInfos.nodeModel.options.grid[attrInfo.sixWTag],
                                url: '#UNEXISTANT_ID'
                              };
                            },
                            getCellValueForCopy: function(cellInfos){
                                 return cellInfos.cellModel.label;
                            }

                        });
                      break;

            case "ds6w:type":
            case "ds6w:identifier":
            case "ds6w:modified":
            case "ds6w:created":
                    cols.push({
                      "text": attrInfo.attrNls,
                      "dataIndex": attrInfo.sixWTag
                    });
                  break;
            case "ds6w:reserved":
                          cols.push({
                            "text": attrInfo.attrNls,
                            "dataIndex": attrInfo.sixWTag,
                            "typeRepresentation": "image",
                            getCellValue: function(cellInfos){

                              if (!cellInfos || !cellInfos.nodeModel) return;
                              //for group node except reference
                              if(!cellInfos.nodeModel._isFromOriginalModel() && !cellInfos.nodeModel.isEngineeringItem()) return 'N/A';

							               var user = that.sandbox.core.settingManager.getUserName();
                              if(!cellInfos.nodeModel.isDocument()){
                                if(cellInfos.nodeModel.options.grid[attrInfo.sixWTag] === "FALSE"){
                                   return that.sandbox.core.settingManager.getIconPath("I_"+"CheckIn");
                                }else if(cellInfos.nodeModel.options.grid["ds6w:reservedBy"] == user){
                                   return that.sandbox.core.settingManager.getIconPath("I_lock");
                                }else{
                                  return that.sandbox.core.settingManager.getIconPath("I_ReservedByOthers");
                                }
                              }
                              return 'N/A';
                            }
                          });
                         break;
            case "ds6w:reservedBy":
                          cols.push({
                            "text": attrInfo.attrNls,
                            "dataIndex": attrInfo.sixWTag
                           });
                         break;

            case "ds6wg:PLMReference.V_isLastVersion":
                cols.push({
                    "text": attrInfo.attrNls,
                    "dataIndex": attrInfo.sixWTag,
                    "typeRepresentation": "boolean",

                   getCellValue: function(cellInfos){
                	   if (!cellInfos || !cellInfos.nodeModel) return null;
                      var attrValue = cellInfos.nodeModel.options.grid[attrInfo.sixWTag];
                       if(attrValue !=="" && attrValue !== undefined){
                         if(attrValue.toLowerCase() == "true"){
                           return true;
                         }else{
                           return false;
                         }
                       }
                     }
                  });

            	break;
            case "ds6w:description":
                    cols.push({
                      "text": attrInfo.attrNls,
                      "dataIndex": attrInfo.sixWTag,
                      "editableFlag":"true",
                      "editionPolicy": "EditionOnDoubleClick",
                      setCellValue: function(cellInfos, value){
                        var attrDataIndex = that.activeView.layout.getDataIndexFromColumnIndex(cellInfos.columnID);
                        that.sandbox.core.dataService.updateAttr(cellInfos,value,attrDataIndex).then(function(data) {
                            if(null!=data){
                             that.updateContent([cellInfos.nodeModel.getID()]);
                            }
                        });
                      }
                    });
                 break;

              case "ds6w:cadMaster":
              cols.push({
                "text": attrInfo.attrNls,
                "dataIndex": attrInfo.sixWTag,
                "typeRepresentation": "image",
                getCellValue: function(cellInfos){
                	 if (!cellInfos || !cellInfos.nodeModel) return ;
                  if((!cellInfos.nodeModel.isEngineeringItem() && !cellInfos.nodeModel.isRepresentation())|| cellInfos.nodeModel.isCoreMaterialGroupNode()) return 'N/A';

                  return that.sandbox.core.Factories.ListItemFactory.getCADIcon(cellInfos.nodeModel.options.grid[attrInfo.sixWTag]);
                }
              });
              break;

              case "ds6wg:MaterialUsageExtension.DeclaredQuantity":


            	  cols.push({
            		  	  "text": attrInfo.attrNls,
            		  	  "dataIndex": attrInfo.sixWTag,
                          "typeRepresentation": "url",
                          "hyperlinkTarget": "_self",
                          getCellValue: function(cellInfos){

                        	  if (!cellInfos || !cellInfos.nodeModel) return {};

                              if(!cellInfos.nodeModel.isEngineeringItem()) return {
                                  label: '',
                                  url: '#UNEXISTANT_ID'
                                };
                            var value = cellInfos.nodeModel.options.grid[attrInfo.sixWTag];

                             if( !value || value.trim().length===0){
                                value = "";
                              } else {
                              	value = Utils.convertVolumeInIUForDisplay(parseFloat(value));
                              }


                            return {
                                label: value,
                                url: '#UNEXISTANT_ID'
                              };
                        },
                        getCellValueForCopy: function(cellInfos){
                             return cellInfos.cellModel.label;
                        }
                      });




            	  break;

            default:

          }


        },

        _getParametricalAttribute: function(_getParametricalAttribute, cols){
          var that = this;
          _getParametricalAttribute.forEach(function(custoAttr){
             var typeRepresentation = custoAttr.type.toLowerCase();
              if(custoAttr.isReadOnly){
                cols.push({
                  "text": custoAttr.attrNls,
                  "dataIndex": custoAttr.sixWTag
                })
              }else if(typeRepresentation === "date" ){
                cols.push({
                  "text": custoAttr.attrNls,
                  "dataIndex": custoAttr.sixWTag,
                  "editableFlag":true,
                  "typeRepresentation": typeRepresentation,
                 "editionPolicy": "EditionOnDoubleClick",
                 getCellEditableState: function(cellInfos){
                  return cellInfos && cellInfos.nodeModel && cellInfos.nodeModel.isEngineeringItem();
                 },
                 getCellValue:function(cellInfos){
                	 if (!cellInfos || !cellInfos.nodeModel) return;

                   var custoDate = cellInfos.nodeModel.options.grid[custoAttr.sixWTag];
                   if(custoDate && custoDate !== "NULL"){
                      if(!isNaN(custoDate)){
                        custoDate = parseInt(custoDate);
                        custoDate = custoDate*1000;
                      }
                       return new Date(custoDate);
                   }else{
                        return null;
                   }

                 },

                  setCellValue: function(cellInfos, value){
                    if(value !== null){
                      value = new Date(value);
                      value = value.toGMTString();
                      that._setCellValue(cellInfos, value);

                    }
                  }
                })

              }
              else if(typeRepresentation === "boolean" ){
                cols.push({
                  "text": custoAttr.attrNls,
                  "dataIndex": custoAttr.sixWTag,
                  "editableFlag":true,
                  "typeRepresentation": typeRepresentation,
                //  "editionPolicy": "EditionInPlace"
                 "editionPolicy": "EditionOnDoubleClick",

                 getCellEditableState: function(cellInfos){
                  return cellInfos && cellInfos.nodeModel && cellInfos.nodeModel.isEngineeringItem();
                 },
                 getCellValue: function(cellInfos){
                	 if (!cellInfos || !cellInfos.nodeModel) return null;
                    var custoBoolean = cellInfos.nodeModel.options.grid[custoAttr.sixWTag];
                     if(custoBoolean !=="" && custoBoolean !== undefined){
                       if(custoBoolean.toLowerCase() == "true"){
                         return true;
                       }else{
                         return false;
                       }
                     }
                   },

                  setCellValue: function(cellInfos, value){
                    value =  value.toString();
                    that._setCellValue(cellInfos, value);
                  }
                })

              }  else if(typeRepresentation === "integer" ){
                  cols.push({
                    "text": custoAttr.attrNls,
                    "dataIndex": custoAttr.sixWTag,
                    "editableFlag":true,
                    "typeRepresentation": typeRepresentation,
                  //  "editionPolicy": "EditionInPlace"
                   "editionPolicy": "EditionOnDoubleClick",
                   getCellEditableState: function(cellInfos){
                    return cellInfos && cellInfos.nodeModel && cellInfos.nodeModel.isEngineeringItem();
                   },
                   getCellValue: function(cellInfos){
                	   if (!cellInfos || !cellInfos.nodeModel) return ;
                      var custoInteger = cellInfos.nodeModel.options.grid[custoAttr.sixWTag];
                       if(custoInteger!==""  && custoInteger !== undefined){
                          return parseInt(custoInteger);
                       }
                     },

                    setCellValue: function(cellInfos, value){
                      value =  value.toString();
                      that._setCellValue(cellInfos, value);
                    }
                  })
                }else if(typeRepresentation === "double" ){
                  var hasPreferredUnit = (custoAttr.preferredunitNls && custoAttr.preferredunitNls.length>0);
                  cols.push({
                    "text": custoAttr.attrNls+ (hasPreferredUnit ? ' ('+custoAttr.preferredunitNls+')': ''),
                    "dataIndex": custoAttr.sixWTag,
                    "editableFlag":true,
                    "typeRepresentation": 'float',
                  //  "editionPolicy": "EditionInPlace"
                   "editionPolicy": "EditionOnDoubleClick",
                   getCellEditableState: function(cellInfos){
                    return cellInfos && cellInfos.nodeModel && cellInfos.nodeModel.isEngineeringItem();
                   },
                   getCellValue: function(cellInfos){
                	   if (!cellInfos || !cellInfos.nodeModel || !cellInfos.nodeModel.isEngineeringItem()) return;

                     var custoReal = cellInfos.nodeModel.options.grid[custoAttr.sixWTag];
                     if(custoReal==""  || custoReal == undefined || custoReal ==null) return ;
                     // return custoReal;
                     if((!custoAttr.preferredunit || custoAttr.preferredunit.trim().length==0) ){
                             return cellInfos.nodeModel.getAttributeValue(custoAttr.sixWTag);
                    }
                    // if(cellInfos.nodeModel.isRealAttributesConverted()){
                    //   return cellInfos.nodeModel.getAttributeValue(custoAttr.sixWTag+"_converted");
                    // }

                    return cellInfos.nodeModel.getAttributeValue(custoAttr.sixWTag+"_converted");
                     },

                    setCellValue: function(cellInfos, value){
                      value =  value.toString();
                      //to avoid seeing during the conversion in the view
                      cellInfos.nodeModel.options.grid[custoAttr.sixWTag+"_converted"] = value;
                      that._setCellValue(cellInfos, value);
                    }
                  })
              // else part is for parametrical attribute of type string and real
                }else{
                cols.push({
                  "text": custoAttr.attrNls,
                  "dataIndex": custoAttr.sixWTag,
                  "editableFlag":true,
                  "editionPolicy": "EditionOnDoubleClick",
                 getCellEditableState: function(cellInfos){
                  return cellInfos && cellInfos.nodeModel && cellInfos.nodeModel.isEngineeringItem();
                 },
                  setCellValue: function(cellInfos, value){
                    that._setCellValue(cellInfos, value);
                  },
                  getCellValue: function(cellInfos){
                	  if (!cellInfos || !cellInfos.nodeModel) return;

                      return cellInfos.nodeModel.options.grid[custoAttr.sixWTag];
                    }
                })
              }
            })
        },
        _setCellValue :function(cellInfos, value){
          var that = this;
          var attrDataIndex = that.activeView.layout.getDataIndexFromColumnIndex(cellInfos.columnID);
          var attrName =  that.sandbox.core.dataService.getParametricalAttributesOf("VPMReference").find(function(node){return node.sixWTag === attrDataIndex}).attrName ;

          that.sandbox.core.dataService.updateAttr(cellInfos,value,attrDataIndex,attrName).then(function(data) {
              if(null!=data){
               that.updateContent([cellInfos.nodeModel.getID()]);
              }
          }).catch(function(){
            //rollback user typed value for converted columns
            cellInfos.nodeModel.setRealAttributesConvertState(false);
            cellInfos.nodeModel.setAttributeConvertionStarted(false);
            that.getModels() && that.getModels().fillAttributesAsync4VisibleNodes([cellInfos.nodeModel]);
          });

        },

        loadViewsClass: function() {
          var that = this;
          if (this.classLoaderPromise)
            return this.classLoaderPromise;
          this.classLoaderPromise = new Promise(function(resolve, reject) {
            Utils.loadFiles(that.views.map(function(view) {
              return view.loader;
            })).then(function(Clazzes) {

              for (var i = 0; i < that.views.length; i++) {
                that.views[i].Clazz = Clazzes[i];
              }
              //freeze view definition to avoid mismatch
              that.views = Object.freeze(that.views);
              resolve(that.views);
            }).catch(function(err) {
              reject(err);
            });


          });

        return this.classLoaderPromise;

      },
      initializeViews: function(){
          var that = this;
          this.views = this._views;
          // Create two container who will be in position absolute
        	  this.containerInstance = document.createElement('div');

          this.loadViewsClass().then(function(views){
            that.renderPreferredView();
            // that.updateSelectedItemsCount();
            that.sandbox.subscribe(XEngineerConstants.EVENT_COLORIZATION_UPDATED, function(state) {
              var datagrid = that.instanciedViews['DataGridView'];
              if(!datagrid) return ;
              datagrid.showNodeKPIColorFlag = state;
      	  });
          }).catch(function(err){
            console.error(err);
          });
       },
       reDrawColumns: function(){
         if(this.instanciedViews['DataGridView']){
           var that = this;
           var datagrid = this.instanciedViews['DataGridView'];
           if(!datagrid) return ;

           var newColumns = that._getTableViewColumnConfiguration();
           if((Array.isArray(newColumns) && newColumns.length>0)){
             var currentColsDataIndex = (datagrid.columns || []).map(function(col){
               return col.dataIndex;
             });
             datagrid.prepareUpdateView();
             //add new columns
             newColumns.forEach(function(col){
               var isColExist = currentColsDataIndex.find(function(dataIndex){
                  return col.dataIndex === dataIndex;
               });
                if(!isColExist){
                  datagrid.addColumnOrGroup(col);
                }
             });
             // clean removed columns
             currentColsDataIndex.forEach(function(dataIndex){
              var isColExist = newColumns.find(function(c){
                 return c.dataIndex === dataIndex;
              });
               if(!isColExist){
                datagrid.removeColumnOrGroup(dataIndex);
               }

               datagrid.pushUpdateView({
                        updateCellContent: true,
                        updateCellLayout: true,
                        updateCellAttributes: true
                        }, true);
            });
           }
         }

       },
        launchGroupBy: function(groupOptions){
          this.getModels().groupRoots(groupOptions);
        },
        destroyLoadedViews: function(){
          var that = this;
          //BYPASS: datagridview subscribe to this event and not unsubscribe to it !
          if(this.getModels()&& this.getModels().getModelEvents())
           this.getModels().getModelEvents().unsubscribeAll({
            event: "modelUpdate"
          });
          var instancedViews =   Object.keys(this.instanciedViews);
          for (var i = 0; i < instancedViews.length; i++) {
            var currentView  = this.instanciedViews[instancedViews[i]];
            if(typeof currentView.destroy   === 'function'){
              try {

                currentView.destroy();
                var attrs = Object.keys(currentView || {});
                for (var j = 0; j < attrs.length; j++) {
                    currentView[attrs[j]] = undefined;
                }
              } catch (error) {
                console.error(error);
              }
            }
            delete this.instanciedViews[instancedViews[i]];
          }
          this.activeView = null;
        },
        destroyViews : function(){
          this.destroyLoadedViews();
          this.classLoaderPromise =null;
          this.views = null;
          this._views =null;

        },
        getAvailableViews: function(){
          var that =this;
          return that._views.map(function(view){
            return {
              id : view.id,
              text: view.text,
              fonticon : view.fonticon
            };
          });
        }

    });

    return EngItemViewsManager;
});

/**
 * @module DS/ENOXEngineer/componentsHelpers/CollectionView/ENOXResponsiveSetView
 */
define('DS/ENOXEngineer/componentsHelpers/CollectionView/ENOXResponsiveSetView', [
  'UWA/Core',
  'UWA/Class/Options',
  'UWA/Controls/Abstract',
  'UWA/Class/Promise',
  'DS/Core/ModelEvents',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXCollectionToolBar/js/ENOXCollectionToolBar',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json',
  'css!DS/ENOXEngineer/componentsHelpers/CollectionView/ENOXResponsiveSetView.css'
],
   function(UWA, Options, Abstract, Promise, ModelEvents, Utils, XEngineerConstants, ENOXCollectionToolBar,nlsKeys) {

    'use strict';


    function requireFiles(loaders, context) {
      var dfd = new Promise(function( resolve, reject){

              var resol = function () {
                resolve(arguments);

              };

              var rej = function (err) {
                reject(err);
              };

              if (Array.isArray(loaders)) {
                require(loaders, resol, rej);
              } else {
                rej(loaders);
              }

      });


      return dfd;
    }

    function getViewIndx(viewId, views){
        return   views.find(function(element){
            return element.id === viewId;
          });
    }
    const TOOLBAR_SWITCH_VIEW ='enox-collection-toolbar-switch-view-activated';
    const TOOLBAR_SEARCH = 'enox-collection-toolbar-filter-search-value';
    const TOOLBAR_SORT  = 'enox-collection-toolbar-sort-activated';
    const TOOLBAR_UPDATE_COUNT = 'enox-collection-toolbar-items-count-update';
    const EVENT_PERSIST_VIEW = 'event-persist-view';
    const EVENT_SELECTALL = 'enox-collection-toolbar-all-selected';
    const EVENT_UNSELECTALL = 'enox-collection-toolbar-all-unselected';
    const TOOLBAR_MULTISEL_COUNT = 'enox-collection-toolbar-selections-count-update';


    /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/componentsHelpers/CollectionView/ENOXResponsiveSetView
     * @augments module:UWA/Controls/Abstract
     * @param {Object} options options hash or a option/value pair.
     */
    var ENOXResponsiveSetView = Abstract.extend(Options,
     /**
     * @lends module:DS/ENOXEngineer/componentsHelpers/CollectionView/ENOXResponsiveSetView.prototype
     */
    {
        name: 'ENOXResponsiveSetView',
        _views : [{
          id : 'Tile',
          loader : 'DS/CollectionView/ResponsiveTilesCollectionView',
          text : nlsKeys.get("Tile"),
          fonticon: 'view-small-tile'
        },{
          id : 'Thumbnail',
          text : nlsKeys.get("Thumbnail"),
          loader : 'DS/CollectionView/ResponsiveThumbnailsCollectionView',
          fonticon: 'view-big-thb'
        }
        ,{
          id : 'bigTile',
          text : nlsKeys.get("big_tiles_view"),
          loader : 'DS/CollectionView/ResponsiveLargeTilesCollectionView',
          fonticon: 'view-big-tile'
        }
        ],
        defaultOptions: {
          models : null
        },
        instanciedViews : {

        },
        buildAvailableViewsList : function(){
          var that = this;
          this.views = [];

          if(that.options.keepDefaultViews){
            this.views = this._views;
          }

          if(Array.isArray(that.options.views)){
            that.options.views.forEach(function(view){
              if(view.id && view.loader && view.fonticon){
                  var overridenView = getViewIndx(view.id, that.views);
                  if(overridenView){
                    overridenView.loader  = view.loader;
                    overridenView.fonticon = view.fonticon;
                  }else {
                    that.views.push(view);
                  }
              }

            });
          }
        },
        init: function(options) {
            var that = this;

            this._parent(options);

            this.options.models = options.models;
            delete options.models;
            this.options.models.pushToTagger();
            this.options.models.onPostENOXFiltering = this.afterFiltering.bind(this);
            this.options.models.onSelectionUpdated = this.updateSelectedItemsCount.bind(this);
            if(typeof this.options.onCellDoubleClick === "function")
              this.onCellDoubleClick = this.options.onCellDoubleClick;

            this.options = UWA.extend(this.options, options, true);
            this._modelEvents  =  this.options.modelEvents ? this.options.modelEvents :   new ModelEvents();
            this.buildAvailableViewsList();
            this.elements.container = UWA.createElement('div', {
                'class': this.getClassNames()
            });

            this.loadViewsClass().then(function(views){
              that.buildView();
              // that.updateSelectedItemsCount();
            }).catch(function(err){
              console.error(err);
            });



        },
        updateSelectedItemsCount : function(nb){
          var count = nb === undefined ? this.options.models.getSelectedNodes().length : nb;
          this._modelEvents.publish({ event: TOOLBAR_MULTISEL_COUNT, data: count}) ;
        },
        selectAll : function(){
          this.options.models.selectAll();
          // that.updateCount();
        },
        unSelectAll : function(){
          this.options.models.unselectAll();
          // that.updateCount();
        },
        buildView : function(){
          var that = this;
          this.elements.container = UWA.createElement('div', {
              'class': this.getClassNames()
          });

          this.elements.gridviewContainer = UWA.createElement('div', {
              'class': this.getClassNames()+'-gridview'
          });

          if(this.options.toolbar){
            this.elements.toolbarContainer = UWA.createElement('div', {
                'class': this.getClassNames()+'-toolbar'
            });

            this.elements.toolbarContainer.inject(this.elements.container, 'top');

            this.toolbar = this.buildToolbar();
            this.toolbar.inject(this.elements.toolbarContainer);
          }

          this.elements.gridviewContainer.inject(this.elements.container);
          this._listenToToolbarEvents();

          that.renderPreferredView();

          that.elements.container.inject(that.options.container);

          that.updateCount();
        },
        afterFiltering : function(){
          this.updateCount();
        },
        buildToolbar : function(){
          var that = this;
          var toolbarOptions = that.options.toolbar || {};
           var options = {
             modelEvents : that._modelEvents,
             withmultisel : true,
             showItemCount : true,
             multiselActions : toolbarOptions.multiselActions,
             actions : toolbarOptions.actions,
             sort : toolbarOptions.sort,
             views : that.views.map(function(view){
               return {
                 id : view.id,
                 text: view.text,
                 fonticon : view.fonticon
               }
             }),
             filter : {
               enableCache : true
             },
             currentView :that.getPreferredView(),
             currentSort : {
               id : "Title",
               order : "ASC"//CollectionToolbarVariables.ASC
             },
             currentNbitems : 0,
						 currentNbSelections : 0
           };
           return new  ENOXCollectionToolBar(options);
        },
        search: function(criteria){
          this.fileredDocuemnt =null;
        },
        _listenToToolbarEvents : function(){
          this.eventsTokens = [];
          var that = this;
          this.eventsTokens.push(that._modelEvents.subscribe({ event: TOOLBAR_SWITCH_VIEW},function(viewId){
            that.switchView(viewId);
          }));

          this.eventsTokens.push(that._modelEvents.subscribe({ event: TOOLBAR_SEARCH},function(searchOpt){
            var searchCrit = Array.isArray(searchOpt.searchValue) ? searchOpt.searchValue[0] : '';
            var start = (new Date()).getTime();
            that.options.models.prepareUpdate();
            that.options.models.getChildren().forEach(function(node){
               node.unMatch(searchCrit) ? node.setSearchFilterState(true) : node.setSearchFilterState(false);
               node.applyFilters();
            });
            that.options.models.pushUpdate();

            that.updateCount();

            console.warn('ending search in '+((new Date()).getTime() - start)+'ms');

          }));

          this.eventsTokens.push(that._modelEvents.subscribe({ event: EVENT_SELECTALL}, function () {
            that.selectAll();
          }));

          this.eventsTokens.push(that._modelEvents.subscribe({ event: EVENT_UNSELECTALL}, function () {
            that.unSelectAll();
          }));


          this.eventsTokens.push(that._modelEvents.subscribe({ event: TOOLBAR_SORT},function(sortOptions){
            var start = (new Date()).getTime();
            that.options.models.prepareUpdate();
            console.warn(sortOptions);
            var reverseFactor = (sortOptions.sortOrder || '').toLowerCase() === 'asc' ? 1 : -1;
            that.options.models._getTrueRoot().sortChildren({
                            isRecursive: true,
                            sortFunction: function(treeNodeModelA, treeNodeModelB) {
                                return  reverseFactor*(treeNodeModelA.getSortableAttributeValue(sortOptions.sortAttribute) < treeNodeModelB.getSortableAttributeValue(sortOptions.sortAttribute) ? -1 : 1);
                            }
                        });
            that.options.models.pushUpdate();

            console.warn('ending search in '+((new Date()).getTime() - start)+'ms');
          }));


        },
        updateCount : function(){
          var trueNode = this.options.models ? this.options.models._getTrueRoot() :null;
          var count = trueNode ? trueNode.getNumberOfVisibleDescendants() : 0;
          this._modelEvents.publish({ event: TOOLBAR_UPDATE_COUNT, data: count});
        },
        applyFilter : function(){

        },
        switchView : function(viewId){
          this.hidePreviousView();
          this.preferredView = viewId;
          this._modelEvents.publish({ event: EVENT_PERSIST_VIEW, data: viewId});
          this.renderPreferredView();
        },
        hidePreviousView : function(){
          var that =this;
          Object.keys(this.instanciedViews).forEach(function(instanceId){
            that.instanciedViews[instanceId].elements.container.classList.remove('visible');
          });

        },
        renderPreferredView : function(){
          var that = this;
          var currentView = this.getPreferredViewInstance();
          currentView.elements.container.classList.add('visible');
        },
        onCellDoubleClick : function(){
          console.log('doubleclick observed ! ');

        },
        getViewOptions : function(){
          var responsiveTilesOptions = UWA.extend({}, {
            height: 'inherit',
            displayedOptionalCellProperties: ['contextualMenu', 'activeFlag'],
            useDragAndDrop: true,
            // _observeDoubleClickEvent
            onDragStartCell : function (e, dndInfos){
                var model;
                var Nodemodel = dndInfos.nodeModel;
                if (Nodemodel) {
                    model = Nodemodel.getTreeDocument();
                }
              e.dataTransfer.effectAllowed = 'all';
//TODO move for a callback provide by  specialized component
              var dragData = Utils.prepareDragData(model.getSelectedNodes());
              e.dataTransfer.setData('Text', dragData);
              return true;
            }
        }, true);
        return responsiveTilesOptions;
        },
        getSubLabel: function(node){
            var tableHTML = Handlebars.compile('<div>{{#each attributesInfo}} <span>{{value}} | </span>{{/each}}</div>');
			var content = tableHTML({attributesInfo:node.getDisplayedGridViewAttribute()});
            return content;
          },
          getTooltip: function(node){
              var tableHTML = Handlebars.compile('<div>{{#each attributesInfo}} <div><span>{{name}} : </span><span>{{value}}</span></div>{{/each}}</div>');
  			var content = tableHTML({attributesInfo:node.getAllGridViewAttribute()});
              return content;
            },
        configureViewInstance : function(view){
          var that =this;
          view.selectionBehavior = {
            canInteractiveMultiselectWithCheckboxClick : true,
            canMultiSelect : true,
            enableFeedbackForActiveCell : true,
            enableShiftSelection : true,
            toggle : true,
            unselectAllOnEmptyArea : true
          };
          //override the default behavior
           view.onDragStartCellDefault = function(event){
             return true;
           };
           view.onCellDoubleClick(that.onCellDoubleClick.bind(that));
           view.getLabel = function(node){
             return node.getLabel()  +' - '+ node.getReferenceVersion();
           };

             view.getSubLabel = function(node){
                 return that.getSubLabel(node);
               };


               view.getCustomTooltip = function(node){
            	   return that.getTooltip(node);
               };
          view.onContextualEvent = {
            'callback': function (params) {
                var menu = [];
                if (params && params.cellInfos) {
                   if (params.cellInfos.cellModel) {
                     var model = params.cellInfos.cellModel;
                     menu = model.getEngineeringMenu(XEngineerConstants.MY_ENG_ITEMS_VIEW);
                   }
                 }
                return menu;
            }
        };
        view.model = that.options.models;
        },
        getPreferredViewInstance : function(){
          var that = this;
          if(!this.instanciedViews[that.getPreferredView()]){
            var Clazz = that._getViewClass(that.getPreferredView());

            this.instanciedViews[that.getPreferredView()] = new Clazz(that.getViewOptions());
            this.activeView = this.instanciedViews[that.getPreferredView()] ;
            that.activeView.getContent().inject(that.elements.gridviewContainer);
            that.configureViewInstance(that.activeView)
          }
         return this.instanciedViews[that.getPreferredView()];
        },
        getPreferredView : function(){
          var that = this;
          if(this.preferredView)
            return this.preferredView;

          if(this.options.defaultView){
            that.views = that.views || [];
            for (var i = 0; i < that.views.length; i++) {
              if(that.views[i].id === this.options.defaultView){
                this.preferredView = that.views[i].id;
                return that.views[i].id;
              }

            }
          }
          this.preferredView = that.views[0].id;
          return that.views[0].id;
        },
        _getViewClass : function(viewId){
          var that = this;
          for (var i = 0; i < this.views.length; i++) {
            if(this.views[i].id === viewId)
              return this.views[i].Clazz;
          }

          return null;
        },
        loadViewsClass: function() {
          var that = this;
          if (this.classLoaderPromise)
            return this.classLoaderPromise;
          this.classLoaderPromise = new Promise(function(resolve, reject) {
            requireFiles(that.views.map(function(view) {
              return view.loader;
            })).then(function(Clazzes) {

              for (var i = 0; i < that.views.length; i++) {
                that.views[i].Clazz = Clazzes[i];
              }
              //freeze view definition to avoid mismatch
              that.views = Object.freeze(that.views);
              resolve(that.views);
            }).catch(function(err) {
              reject(err);
            });


          });

        return this.classLoaderPromise;

      },
      destroy : function(){
        var that = this;
        var instancedViews =   Object.keys(this.instanciedViews);
        for (var i = 0; i < instancedViews.length; i++) {
          if(typeof this.instanciedViews[instancedViews[i]].destroy   === 'function'){
            try {
              this.instanciedViews[instancedViews[i]].destroy();
            } catch (error) {
              console.error(error);
            }
          }
          delete this.instanciedViews[instancedViews[i]];
        }
        this.options.models.getChildren().forEach(function(node){
          node._unsetParent();
        });

      // this.options.models.empty();
        this.options.models.removeFromTagger();
        this.eventsTokens.forEach(function(token){
          that._modelEvents.unsubscribe(token);
        });
      }


    });

    return ENOXResponsiveSetView;
});

define('DS/ENOXEngineer/models/EngItemGroupModel',
[
  'DS/ENOXEngineer/models/EngItemModel',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/ENOXEngineer/utils/Utils',
  'UWA/Core'
],
 function(
   EngItemModel,
   PromiseUtils,
   Utils,
   Core
 ) {

    'use strict';

    function EngItemGroupModel(options){

        this.options = {
        };

        this.options = Core.extend(this.options, options);
        EngItemModel.call(this, this.options);
    }

    EngItemGroupModel.prototype = Object.create(EngItemModel.prototype);

    EngItemGroupModel.prototype.getViewType = function(){
      return this.options.viewType;
    };


    //override getLabel
    
    EngItemGroupModel.prototype.getGlobalType = function(){
      return (this.options.padgrid) ? this.options.padgrid["ds6w:globalType"] : null;
    };

    EngItemGroupModel.prototype.getLabel = function(){
      return this.options.label;
    };

    EngItemGroupModel.prototype.isCoreMaterialGroupNode =  function(){
      return this.getAttributeValue('isCoreMaterialGroupNode') === true;
    }

    // Remap the constructor
    EngItemGroupModel.prototype.constructor = EngItemGroupModel;

    EngItemGroupModel.prototype.getIdentifier = function() {
      return this._options.identifier;
    };

    EngItemGroupModel.prototype._getFakeNodesTable = function() {
      return this._options.fakeNodesTable;
    };
    EngItemGroupModel.prototype.getInstanceType= function() {
      return "";
    };

    EngItemGroupModel.prototype.getProperty = function() {
              return this._options.property;
    };

    EngItemGroupModel.prototype.getNumberOfOriginalChildren = function() {
      return Object.assign({}, this._options.numberOfOriginalChildren);
    };

    // TODO : As we use label column, it is not possible to have the fakeNode represented
    // by a Tweaker although the original value is from a typed column that may have a Tweaker.
    // We need to add on TreeNodeView a wzy for fakesNode to retrieve and use the typeRep
    // of the column it represents
    
    EngItemGroupModel.prototype._setNumberOfOriginalChildren = function(newValue) {
      if (newValue.total !== this._options.numberOfOriginalChildren.total ||
        newValue.notHidden !== this._options.numberOfOriginalChildren.notHidden) {
      this._options.numberOfOriginalChildren = Object.assign({}, newValue);
    }


      if (newValue.notHidden > 0) {
        if (this.isHidden()) {
          this.show();
        }
        if (!this.isExpanded()) {
        	if (this.getProperty() !== "reference")
        		this.expand();
        }
      } else {
        if (!this.isHidden()) {
          this.hide();
        }
      }

      if (newValue.total === 0) {
        this.remove();
      }
    };
    

    EngItemGroupModel.prototype.getGroupingNodeOptions= function(options){
          var newOptions = {};
          var groupingProperty = this.getProperty();
          var identifier = this.getIdentifier();
          var quantity = options.count;
          var children = this.getChildren();
          
          if (Array.isArray(children) && children.length > 0){
            
            var firstChild = children[0];
            
              if (groupingProperty ==='reference'){
                
                  if (firstChild.isMaterialQuantity()){
                    identifier = firstChild.options.grid["CoreMaterial"];
                    
                    // update material quantity
                    var quantityOfMaterial = 0.0;
                      children.forEach(function(child){
                        quantityOfMaterial = quantityOfMaterial + parseFloat(child.options.grid["ds6wg:MaterialUsageExtension.DeclaredQuantity"]);
                      });
                      newOptions.grid = {"ds6wg:MaterialUsageExtension.DeclaredQuantity": quantityOfMaterial.toString()};
                      
                  } else {
                    identifier = firstChild.options.grid["ds6w:label"];
                  }
                  
                  
              } 
              
          }

          
          var displayedIdentifier = identifier;
          if(this._options.patch_isCustoDate){
              
                  if(displayedIdentifier  && displayedIdentifier !== "NULL" && displayedIdentifier !== "NA"){
                    if (!isNaN(displayedIdentifier)){
                    displayedIdentifier = parseInt(displayedIdentifier);
                    displayedIdentifier = displayedIdentifier*1000;
                    }
                    
                    var dateFormatter = Utils.getDateFormater();
                    try {
                      displayedIdentifier = dateFormatter.format(new Date(displayedIdentifier)).replace(',', '');
                } catch (error) {
                  displayedIdentifier =   new Date(displayedIdentifier);
                }

                  }
                  
          }
          
          newOptions.label = groupingProperty + ': ' + displayedIdentifier + ' (' + quantity + ')';

        return newOptions;
    };

    EngItemGroupModel.prototype._updateNumberOfDirectOriginalChildren  = function() {
      var numberOfChildren = 0;
      var numberOfNotHiddenChildren = 0;

      // Recursive computation
      var children = this.getChildren();
      if (children) {
        // Loop backwards as children is modify when removing a child.
        // It prevents the algorithm from missing some entries
        for (var idx = children.length; idx > 0; idx--) {
          var child = children[idx - 1];
          var res = child._updateNumberOfDirectOriginalChildren();
          numberOfChildren += res.total;
          numberOfNotHiddenChildren += res.notHidden;

          // If the node was removed, do not keep it in the table any longer
          // so that it will be disposed
          if (res.total === 0) {
            delete this._getFakeNodesTable()[child.getIdentifier()];
          }
        }
      }

      // Post order treatment to update the current fake node
      this._setNumberOfOriginalChildren({
        total: numberOfChildren,
        notHidden: numberOfNotHiddenChildren
      });

      return {
        total: numberOfChildren,
        notHidden: numberOfNotHiddenChildren
      };
    };

    EngItemGroupModel.prototype._updateGroupingNodeOptions = function(groupingOptions) {
      var children = this.getChildren();
      var directOriginalChildren = [];
      if (children) {
        children.forEach(function(child) {
          directOriginalChildren = directOriginalChildren.concat(child._updateGroupingNodeOptions(groupingOptions));
        });
      }

      // Retrieve the number of not hidden children
      // note that numberOfOriginalChildren.total should equal directOriginalChildren.length
      var numberOfOriginalChildren = this.getNumberOfOriginalChildren();

      // Check if the user set a specific method to fill the grouping nodes
      // Otherwise just use the property and the identifier
      if (groupingOptions.updateGroupingNodeOptions) {
        groupingOptions.updateGroupingNodeOptions.call(this, directOriginalChildren);
      } else {
        
        this.updateOptions(this.getGroupingNodeOptions({
          count:numberOfOriginalChildren.notHidden 
        }));
      }

      return directOriginalChildren;
    };
    
    EngItemGroupModel.prototype._isFromOriginalModel = function() {
      return false;
    };


    EngItemGroupModel.prototype._groupChildren = function(groupingOptions) {
      // Do not allow grouping on fakeNode as it would create unbalanced
      // and would mess with the current grouping that created this node
      return;
    };

    EngItemGroupModel.prototype.groupChildren = function(options) {
      // Do not allow grouping on fakeNode as it would create unbalanced
      // and would mess with the current grouping that created this node
      return;
    };

    EngItemGroupModel.prototype._removeGrouping = function(originalParent, newPropertiesToGroup, depth, forceFakeNodeRemoval) {
      var children = this.getChildren();
      if (children && children.length > 0) {

        // Do not remove fakeNode if it still have to be used for the next grouping
        var isGonnaBeRemoved = forceFakeNodeRemoval || !newPropertiesToGroup ||
                               newPropertiesToGroup.length <= depth ||
                               newPropertiesToGroup[depth] !== this.getProperty();

        // Loop backwards as children is modify when removing a child.
        // It prevents the algorithm from missing some entries
        for (var idx = children.length; idx > 0; idx--) {
          var child = children[idx - 1];
          var childToRemove = child._removeGrouping(originalParent, newPropertiesToGroup, depth + 1, isGonnaBeRemoved);
          if (childToRemove) {
            delete this._getFakeNodesTable()[child.getIdentifier()];
          }
        }

        if (isGonnaBeRemoved) {
          this.remove();
        } else {
          this.hide();
        }

        return isGonnaBeRemoved;
      }
    };

    EngItemGroupModel.prototype.ungroupChildren = function(newPropertiesToGroup) {
      // Do not allow grouping on fakeNode as it would create unbalanced
      // and would mess with the current grouping that created this node
      return;
    };



    return EngItemGroupModel;

});

/**
 * @author SBM2
 */
define('DS/ENOXEngineer/collections/XEngGridTreeDocument', [
  'DS/Tree/TreeDocument',
  'DS/ENOXEngineer/models/EngItemModel',
  'DS/ENOXEngineer/models/EngItemGroupModel',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineer/utils/Utils',
  'DS/Utilities/Utils',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager'
], function(
  TreeDocument,
  EngItemModel,
  EngItemGroupModel,
  XEngineerConstants,
  Utils,
  WebUtils,
  xEngAlertManager
) {

  'use strict';
  var XEngGridTreeDocument  = TreeDocument.extend({
    defaultOptions: {
      nodeModelClass: EngItemModel
    },
    init: function(options){

      var local_options = options || {}, that = this;
      this.core = local_options.core || {};
      delete local_options.core;
      this._parent(local_options);
      this._getTrueRoot().options.appCore = this.core;
      this.getXSO().onPostAdd(this.selectionUpdated.bind(this));
      this.getXSO().onPostRemove(this.selectionUpdated.bind(this));
      this._xEngGroupedBy = [];
      var that =this;
      if(local_options.enableTagger){}
      that._FilterBI = (that.core.contextManager.getXENTreeDocument()) ? that.core.contextManager.getXENTreeDocument().getXENBIFilterProxy() : null;
      if(that._FilterBI){
        // that._FilterBI.activate();
        that._FilterBI.addEvent('FilterBIFilteringEvent', that.onFilterBIFilteringEvent.bind(that));
        that._FilterBI.addEvent('FilterBIColorize', that.onFilterBIColorize.bind(that));
        that._FilterBI.addEvent('FilterBIUnColorize', that.onFilterBIUnColorize.bind(that));

      }else{
        console.warn('no filter proxy found');


      }

      this.xHighlightToken = this.core.mediator.subscribePlatformEvent(XEngineerConstants.CROSS_APP_SELECTION_EVENT,this.applyCrossHighlight.bind(this))

    },
    onApplyNGFilter:function(){
      console.warn(" ########### from grid onApplyNGFilter");

    },
    getSelectedItemsCommonMenu: function(rect){
      if(!rect) return ;

	  if (this.core.sessionManager.shouldShowFinalItems()){
		  return this.core.commandManager.showMenu(rect, this.core.commandManager.getMenu("standalone"));
	  } else
		  return this.core.commandManager.showMenu(rect, this.core.commandManager.getMenu("content"));

    },

    _buildFilteredContent: function(options){
      console.error("_buildFilteredSession need to be overriden" );
    },
    onSelectionUpdated : function(){

    },
    getBIFilter: function(){
      return this._FilterBI;
    },
    mergeContent: function(nodes){
      var that = this;
      if(Array.isArray(nodes) && nodes.length>0){
        //merge existing nodes
        var BreakException = {};
        try {
              that.getChildren().forEach(function(_node, currentidx){

                var isRefInt = (nodes[0] instanceof that.core.Factories.ListItemFactory.getListInstanceClass());

                var idx = nodes.findIndex(function(elem){
                  return isRefInt ? (elem.getRelationID() === _node.getRelationID()) : (elem.getID() === _node.getID());
                });

                if(idx !== -1){
                  console.warn('merging the element at '+currentidx);
                  that.addChild(nodes[idx], currentidx);
                  _node.remove();
                  nodes.splice(idx,1); // remove merged node
                }
                if(nodes.length ===0) throw BreakException;
              });
              nodes.forEach(function(node) {
                console.warn('###########" adding content ');
                that.addChild(node, 0); //add the remaining at first position
              });

        } catch (error) {
          console.warn('no need to go throught all the element');

          if(error !== BreakException) throw error;

        }


      }
    },
    getNodesById : function(nodeId) {
      return this.getChildren().filter(function(node){
    		return node.getID() === nodeId;
    	});
    },
    buildReferenceList : function(instance){
    	var firstLevelList = [];
    	firstLevelList = this.getChildren().filter(function(node){
    		return node.getID() === instance.getID();
    	});

    	if (firstLevelList.length == 0){

    		this.getChildren().forEach(function(firstLevelChild){
    			var children = firstLevelChild.getChildren().filter(function(node){
    	    		return node.getID() === instance.getID();
    	    	});

    			firstLevelList = firstLevelList.concat(children);
    		});
    	} else if (firstLevelList.length == 1 && firstLevelList[0] instanceof EngItemGroupModel){
    		firstLevelList = firstLevelList[0].getChildren();
    	}



    	return firstLevelList;

    },
    syncContent : function(nodes){
      var previousLength = this.getChildren().length;
      this.empty();
      this.addChild(nodes);
      (previousLength !== nodes.length) && this.refreshTagger();
    },
    selectionUpdated : function(nodes){
    	var that = this;
        var selectedNodes = this.getSelectedNodes() || [];
        var isSelectionToBeUpdated = false;

        nodes.forEach(function(updatedNode){
      	  if ((updatedNode.getChildren()) && updatedNode.getChildren().length >0){
      		  if (updatedNode.isSelected()){
      			  if (!updatedNode.areAllChildrenSelected()){
      				  isSelectionToBeUpdated = true;
      				  updatedNode.selectAll();
      			  }
      		  } else {
      			  if (!updatedNode.areAllChildrenUnselected()){
      				  isSelectionToBeUpdated = true;
      				  updatedNode.unselectAll();
      			  }
      		  }
      	  }
        });

        if (isSelectionToBeUpdated === false){
      	 // this.core.mediator.publish(XEngineerConstants.EVENT_LIST_SELECT_ITEM, selectedNodes);

            var selectedItems = selectedNodes.filter(function(node){
                return (!node.getChildren());
            });

            typeof this.onSelectionUpdated ==="function" ? this.onSelectionUpdated(selectedItems.length) : null;


            if(selectedItems.length === 0 && this.core.contextManager.getActiveEngItem()){
              var activeItem = this.core.contextManager.getActiveEngItem();
              selectedItems.push(activeItem);
              this.updateXHighlight(null);
            }else{
              this.updateXHighlight(selectedItems);
            }

            this.pushNodesToEditProperties(selectedItems);

        }
    },
    applyCrossHighlight: function(options){
      if(!options || !options.data || !Array.isArray(options.data.paths) ||!this.getChildren()) return ;

      //reject XEN events
      if(options.metadata &&
         options.metadata.appid===this.core.settingManager.getAppId()+'_'+this.core.settingManager.getWidgetId()) return ;

      var selectableMap = {};
      options.data.paths.forEach(function(path){
          path.forEach(function(id){
            selectableMap[id] =true;
          });
      });
      var that = this;
      var hasUnselected = false;
      this.prepareUpdate();
      that.notApplyXhightlight = true;
      this.getChildren().forEach(function(node){
        if(selectableMap[node.getID()]){
          if(!hasUnselected){
            that.unselectAll();
            hasUnselected=true;
          }
          node.select();
        }
      });
      this.pushUpdate();
      this.notApplyXhightlight = false;

    },
    updateXHighlight: function(selectedNodes){
      if(!Array.isArray(selectedNodes)) return ;
      if(this.notApplyXhightlight){
        return ;
      }
          var attrs = {};
          var activeItem = null;
          if(this.core && this.core.contextManager.getActiveEngItem()){
            activeItem = this.core.contextManager.getActiveEngItem();
            attrs[activeItem.getID()] = {type: activeItem.getType(),label : activeItem.getLabel()};
          }
          var data = {
              attributes : selectedNodes.reduce(function(prev, current){
                prev[current.getID()] = {
                  type : current.getType(),
                  label : current.getLabel()
              };
              return prev;
              },attrs),
              paths : selectedNodes.map(function(node){
                return node.completePath((activeItem) ? [activeItem.getID()] : []);
              }),
              version : '1.1'
          };
          var event = Utils.createEvent((((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1), data);
          this.core.mediator.publishPlatformEvent(XEngineerConstants.CROSS_APP_SELECTION_EVENT,event);
    },
    pushNodesToEditProperties : function(targetNodes){
      var nodes = targetNodes || this.getSelectedNodes();

      var types = nodes.map(function(selectedObj){
          return selectedObj.getType();
      });
      var that = this;
      if(!this.core) return ;

      this.core.dataService.getMetaTypes(types, nodes[0] instanceof this.core.Factories.ListItemFactory.getListInstanceClass())
      .then(function(metaTypes){

        if(!that.core) return ;
        var nodesForEditProp = [];
        for (var i = 0; i < nodes.length; i++) {
          var node = nodes[i];
          nodesForEditProp.push({
            id: metaTypes[i] === 'businessobject' ? node.getID() : node.getRelationID(),
            metatype: metaTypes[i]
          });
        }
        that.core.mediator.publish(XEngineerConstants.EVENT_SHOW_PROPERTIES, nodesForEditProp);


      });



    },
    getAvailableAttributesForGrouping: function(){
      var that = this;
      var attrByType = that.getAvailableAttributes(["VPMReference"]);
      var notGroupableAttr = that.core.settingManager.getSetting('notGroupableAttributes');
      var result = [];
      Object.keys(attrByType)
                    .forEach(function(type){
                      if(attrByType.hasOwnProperty(type) && Array.isArray(attrByType[type])){

                        result =  result.concat(attrByType[type].filter(function(attrInfo){
                                             return notGroupableAttr.indexOf(attrInfo.sixWTag) ===-1;
                                      }));
                      }
                    });
      return result;
    },
    getAvailableAttributesForDisplay: function(){
      var that = this;
      var attrByType = that.getAvailableAttributes(["VPMReference"]);
      var result = [];
      Object.keys(attrByType)
                    .forEach(function(type){
                      if(attrByType.hasOwnProperty(type) && Array.isArray(attrByType[type])){

                        result =  result.concat(attrByType[type]);
                      }
                    });
      return result;
    },
    // getAvailableAttributesForSorting: function(){
    //   var that = this;
    //   var attrByType = that.getAvailableAttributes(["VPMReference"]);
    //   var notSortableAttr = that.core.settingManager.getSetting('notSortableAttributes');
    //   var result = [];

    //   Object.keys(attrByType)
    //                 .forEach(function(type){
    //                   if(attrByType.hasOwnProperty(type) && Array.isArray(attrByType[type])){

    //                     result =  result.concat(attrByType[type].filter(function(attrInfo){
    //                                          return (notSortableAttr.indexOf(attrInfo.sixWTag) ===-1) && ["string","integer"].indexOf(attrInfo.type) !==-1;
    //                                   }).map(function(attr,idx){
    //                                     return {
    //                                       id: "aaa"+idx,
    //                                       text: attr.attrNls,
    //                                       type : attr.type
    //                                      }
    //                                   }));
    //                   }
    //                 });
    //   return result;
    // },
    getAvailableAttributes: function(types){
      var that = this;
      if(!Array.isArray(types))
        throw new Error("invalid parameter for getAvailableAttributes");
      //not support bulk for now
      var response = {};

      types.forEach( function(type) {
        response[type] = that.core.dataService.getAvailableAttributesByType(type);
      });
      return response;
    },
    _shouldAcceptDrop: function() {
    return  true;
    },

    _shouldAcceptDrag: function(node, dropInfos) {
      console.error('drag');

      return true;
    },
    getNoTFilteredNodes : function(){
      return this.getChildren().filter(function(node){
        return node.shouldBeVisible();
      });
    },
    refreshTagger : function(){
      this.removeFromTagger();
      this.pushToTagger();
    },
    removeFromTagger : function(rootIds){
      var that = this;
      //hack
      this.core.mediator.unsubscribePlatformEvent(this.xHighlightToken);

      if(this._FilterBI){
         //We unsubscribe to proxy events
        // this._FilterBI.removeEvent('FilterBIColorize', that.onFilterBIColorize.bind(that));
        // this._FilterBI.removeEvent('FilterBIUnColorize', that.onFilterBIUnColorize.bind(that));
        // this._FilterBI.removeEvent('FilterBIFilteringEvent', that.onFilterBIFilteringEvent.bind(that));
        // this._FilterBI.removeEvent('ApplyNGFilter', that.onApplyNGFilter.bind(that));
        this._FilterBI.removeEvent(undefined, undefined);
        // this._FilterBI.deactivate();
        // this._FilterBI._dispatchers= {};
        this._FilterBI.resetNGFilterUI({
          widgetId : that.core.settingManager.getWidgetId(),
          rootIds: Array.isArray(rootIds) ? rootIds :undefined
        });
        this._FilterBI.cleanProxy();

      }
    },
    pushToTagger: function(){
      var that = this;
      that.nodePathsJson = Utils.createNodePathJsonFromArray(this.getChildren());
      if(that._FilterBI)
        that._FilterBI.setPathTags(that.nodePathsJson);
    },
    onFilterBIColorize : function(colorizeOptions){
      var that =this;
      that.withTransactionUpdate(function(){
            var colorsMap = Utils.getTaggerColorMap(colorizeOptions);
            that.getChildren().forEach( function(node){
            if(colorsMap[node.getID()]){
              node.setColor( colorsMap[node.getID()] );
            }
          });
      });
      that._colorizeState =true;
      that.core.mediator.publish(XEngineerConstants.EVENT_COLORIZATION_UPDATED, that._colorizeState);
    },
    isColorizeEnabled: function(){
      return (this._colorizeState);
    },
    onFilterBIUnColorize : function(colorizeOptions){
      var that =this;
      that.withTransactionUpdate(function(){
        that.getChildren().forEach( function(node){
          node.setColor(null);
        });
      });
      that._colorizeState =false;
      that.core.mediator.publish(XEngineerConstants.EVENT_COLORIZATION_UPDATED, that._colorizeState);
    },
    onFilterBIFilteringEvent : function(taggerData){
      var isFilterExist =  Object.keys(taggerData.allfilters).length > 0;
      var that = this;

      if (isFilterExist) {
        this.prepareUpdate();
        this.getChildren().forEach( function(node){
          if(taggerData.filteredPathIDList.indexOf(node.getID()) === -1){
            node.setTaggerFilterState(true);
          }else{
            node.setTaggerFilterState(false);
          }
          node.applyFilters();
        });
        this.pushUpdate();
        this.onPostENOXFiltering();

      }
      that._updateFilterProxy(taggerData);
    },
    onPostENOXFiltering : function(){

    },
    _updateFilterProxy: function(taggerData){
      var that = this, activeFilter = false, nodesArray = [], pathsArray = [];

      if(taggerData){
        if (Object.keys(taggerData.allfilters).length > 0) {
                  activeFilter = true;
              }
      }

      if(activeFilter){
        for (var i = 0; i < taggerData.filteredPathIDList.length; i++) {
            if (taggerData.filteredPathIDList[i].slice(-2, -1) !== "_") {
                nodesArray.push(taggerData.filteredPathIDList[i]);
                pathsArray.push([i]);
            }
        }

        that._FilterBI.setPathTags({
                  nodes: nodesArray,
                  paths: pathsArray
              });
      } else {
        that.nodePathsJson = Utils.createNodePathJsonFromArray(this.getChildren());
        that._FilterBI.setPathTags(that.nodePathsJson);
        that.prepareUpdate();
        that.getChildren().forEach(function(node){
          node.setTaggerFilterState(false);
            node.applyFilters();
        });
        that.pushUpdate();
        this.onPostENOXFiltering();

      }


    },
    //get Available types
    getAvailableAttributesToSort: function(){
      var that =this;

      return [{
         					    	id: "Title",
   								    	text : that.core.i18nManager.get("ds6w:label"),
   									    type : "string"//CollectionToolbarVariables.STR
         				  	},{
                        id: "Maturity",
                        text: that.core.i18nManager.get("ds6w:status"),
                        type :"string"
                    },{
                        id: "Owner",
                        text: that.core.i18nManager.get("ds6w:responsible"),
                        type :"string"
                    },{
                        id: "CreationDate",
                        text: that.core.i18nManager.get("ds6w:created"),
                        type :"string"
                    },{
                        id: "PartNumber",
                        text: that.core.i18nManager.get("ds6wg:EnterpriseExtension.V_PartNumber"),
                        type :"string"
                    }
             ];
    },
    _isProvided: function(providerColumn){
    	return true;
    },
    groupRoots: function(options) {
      if (options.propertiesToGroup.length === 1 || options.propertiesToGroup.length === 0) {
    	  var groupId = options.propertiesToGroup[0];
    	  if (groupId === "reference"){
    		  if (!this.isNotWaitingForAttributes()){
    			  options = {propertiesToGroup:[]}
    			  groupId = undefined;
    			  xEngAlertManager.notifyAlert(this.core.i18nManager.get("error.grouping.notProvided"));
    		  }
    	  }
        this._parent(options);
        this._xEngGroupedBy = options.propertiesToGroup;
        widget.setValue('groupBy', groupId);
      } else {
        this._parent({
          propertiesToGroup: [options.propertiesToGroup[0]]
        });
        this._xEngGroupedBy = [options.propertiesToGroup[0]];
        var groupId = options.propertiesToGroup[0];
        widget.setValue('groupBy', groupId);
        xEngAlertManager.errorAlert(this.core.i18nManager.get("error.single.level.grouping"));
      }
      },
    isViewGrouped: function(){
      if(Array.isArray(this._xEngGroupedBy) && this._xEngGroupedBy.length != 0)
        return true;
      else
        return false;
    },
    getViewGroupedByAttributes: function(attribute) {
      return this._xEngGroupedBy;
    }

  });

return XEngGridTreeDocument;


});

define('DS/ENOXEngineer/components/XEngGridView/js/XEngGridViewV2',
  [
    'DS/ENOXEngineerCommonUtils/XENMask',
    'DS/ResizeSensor/js/ResizeSensor',
    'DS/ENOXEngineer/utils/Utils',
    'DS/ENOXEngineer/utils/XEngineerConstants',
    'DS/ENOXEngineer/componentsHelpers/InviteDnD/DnDInvite',
    'DS/ENOXEngineerCommonUtils/xEngAlertManager',
    'DS/ENOXEngineer/components/NavigationTopBar/NavigationTopBar',
    'DS/ENOXEngineer/collections/XEngGridTreeDocument',
    'DS/ENOXEngineer/componentsHelpers/CollectionView/ENOXResponsiveSetView',
    'css!DS/ENOXEngineer/components/XEngGridView/css/XEngGridView.css',
    'css!DS/UIKIT/UIKIT.css'
  ],
  function (
    Mask,
    ResizeSensor,
    Utils,
    XEngineerConstants,
    DnDInvite,
    xEngAlertManager,
    NavigationTopBar,
    XEngGridTreeDocument,
    ENOXResponsiveSetView
  ) {
    'use strict';
    const EVENT_PERSIST_VIEW = 'event-persist-view';

    var MyEngineeringItems = function (sandbox) {
      var _container = sandbox.getContainer();

      var _navTopBarContainer = document.createElement("div");
      _navTopBarContainer.classList.add("xen-landingpage-topbar");

      var _listContainer = document.createElement("div");
      _listContainer.classList.add("xen-landingpage-list");


      function initDnDView(container) {
        var invite = new DnDInvite({
          renderTo: container
        });
        invite.hide();
        return invite;
      }

      return {
        _authoredDataPromise: null,
        start: function () {
          var that = this;
          this.preloadLatestUpdates();
          sandbox.options.getComponentData(sandbox.dataService)
            .then(function (nodes) {
              that.nodesCache = nodes || [];
              that._buildUI(nodes || []);
              that.reflectUpdates();
              sandbox.publish(XEngineerConstants.EVENT_MY_EN_ITEM_READY);
            }).catch(function (errors) {
              that._buildUI([]);
              sandbox.publish(XEngineerConstants.EVENT_MY_EN_ITEM_READY);
              xEngAlertManager.errorAlert(sandbox.i18nManager.get("error.dataNotRetrieved"));
            });

          that._navigationTopBar = new NavigationTopBar();
          that._navigationTopBar.init(sandbox, _navTopBarContainer);
          that._navigationTopBar.setTitle(sandbox.options.getTitle());


        },
        shouldUseDBRefreseh: function () {
          return (sandbox.options.getViewName() === 'my_eng_items' && sandbox.core.sessionManager.isUsingDB());
        },
        preloadLatestUpdates: function () {
          if (this.shouldUseDBRefreseh())
            this._authoredDataPromise = sandbox.dataService.getUserRecentEditedEngineeringItems();
        },
        reflectUpdates: function () {
          var that = this;
          if (this._authoredDataPromise && this.shouldUseDBRefreseh()) {
            Mask.mask(_container, sandbox.i18nManager.get("processing.synchronization.with.server"));
            this._authoredDataPromise.then(function (updatedNodes) {
              if (Array.isArray(updatedNodes)) {
                that.models.mergeContent(updatedNodes);
                that.nodesCache = that.models.getChildren();
                that.models.pushToTagger();
                if (that.myResponsiveSetView)
                  that.myResponsiveSetView.updateCount();
                Mask.unmask(_container);
                that.switchView();
              }
            }).catch(function (reason) {
              console.error(reason);
            });
          } else {
            that.switchView();
          }
        },
        reRender: function () {
          this._buildUI(this.nodesCache);
        },
        stop: function () {
          this.resizor && this.resizor.detach(_container);
          this.resizor = undefined;
          sandbox.publish(XEngineerConstants.EVENT_SHOW_PROPERTIES, []);

          this.destroyCurrentView();
          if (this._navigationTopBar) {
            // this._navigationTopBar.destroy();
            this._navigationTopBar = undefined;
          }
          this.models = null;
          sandbox.core && sandbox.core.contextManager.setActiveDocument(null);


          Utils.cleanDroppable(_container);
          sandbox.emptyContainer();
          sandbox.unsubscribeAll();
        },
        destroyCurrentView: function(){
          if (this.myResponsiveSetView) {
            this.myResponsiveSetView.unSelectAll();
            this.myResponsiveSetView._modelEvents && this.myResponsiveSetView._modelEvents.unsubscribe(this.PersistToken);
            try {
              this.myResponsiveSetView.destroy();
            } catch (error) {
              console.error(error);
            }
            
            this.myResponsiveSetView = null;
          }
          if(this.emptyView){
            try {
              this.emptyView.destroy();
            } catch (error) {
              console.error(error);
            }
            this.emptyView = null;
          }
          _listContainer.innerHTML = "";
        },
        switchView: function () {
          
          if (!this.myResponsiveSetView && !this.emptyView) {
            if (this.isEmpty()) {
              this.renderEmptyView()
            } else {
              this.RenderSetView();
            }

          } else {
            if (this.myResponsiveSetView && this.isEmpty()) {
              this.destroyCurrentView();
              this.renderEmptyView();
            } else if (this.emptyView && !this.isEmpty()) {
              this.destroyCurrentView();
              this.RenderSetView();
            }

          }

        },
        isEmpty: function () {
          return (!this.models || this.models.getChildren().length === 0);
        },
        renderEmptyView: function () {
          this.emptyView = sandbox.core.moduleHelper.viewsService.getGridEmptyView(sandbox.options.getViewName());
          if (this.emptyView) {
            this.emptyView.inject(_listContainer);
          }
        },
        _buildUI: function (nodes) {
          var that = this;
          var models = new XEngGridTreeDocument({
            core: sandbox.core,
            shouldAcceptDrag: function () {
              return true;
            },
            shouldAcceptDrop: function (options) {
              return true;
            }
          });
          models.addChild(nodes);
          Mask.unmask(_container);
          this.models = models;

          sandbox.core.contextManager.setActiveDocument(models);
          
          this.switchView(); //first rendering

          //IR-576207 33DEXPERIENCER2019x
          sandbox.subscribe(XEngineerConstants.EVENT_DELETED_ENG_ITEM, function (options) {
            var ids = options.ids;
            var result = [];
            var children = models.getChildren();
            for (var i = 0; i < children.length; i++) {

              if (ids.indexOf(children[i].getID()) != -1) {
                result.push(children[i])
              }
            }
            models.prepareUpdate();
            result.forEach(function (node) {
              models.removeRoot(node);
            });
            models.pushUpdate();
            that.myResponsiveSetView.updateCount();
          });

          that._makeDroppable();

          _container.appendChild(_navTopBarContainer);
          _container.appendChild(_listContainer);

          sandbox.subscribe(XEngineerConstants.EVENT_REFRESH_LANDING_DATA, function () {
            that.preloadLatestUpdates();
            sandbox.options.getComponentData(sandbox.dataService)
              .then(function (nodes) {
                that.nodesCache = nodes || [];
                that.models && that.models.syncContent(nodes || []);
                if (that.myResponsiveSetView)
                  that.myResponsiveSetView.updateCount();

                that.reflectUpdates();
              }).catch(function (errors) {
                console.error(errors);
                xEngAlertManager.errorAlert(sandbox.i18nManager.get("error.dataNotRetrieved"));
              });
          })


          that.resizor = new ResizeSensor(_container, function () {
            // that.resize();
          });
        },
        _makeDroppable: function () {
          var invite = initDnDView(_container);
          var timeout;
          var that = this;
          Utils.makeDroppable({
            element: _container, //DOM element to make droppable
            context: this,
            onDragEnter: function () {
              clearTimeout(timeout);
              if (!that.isEmpty()) {
                invite.addBorder();
                invite.show('drop');
              }

              if (!_container.hasClassName("dragging")) {
                _container.addClassName("dragging");
              }
            },
            onDragLeave: function () {

              timeout = setTimeout(function () {
                if (!that.isEmpty())
                  invite.hide();
                if (_container.hasClassName("dragging")) {
                  _container.removeClassName("dragging");
                }
              }, 200);

            },
            onDragOver: function () {
              if (!that.isEmpty())
                invite.show('drop');
              if (!_container.hasClassName("dragging")) {
                _container.addClassName("dragging");
              }
            },
            onDrop: function (data, context) {
              var parsedData = null;
              if (!that.isEmpty())
                invite.hide();
              _container.removeClassName("dragging");

              try {
                parsedData = JSON.parse(data);
              } catch (e) {
                xEngAlertManager.errorAlert(sandbox.i18nManager.get("error.parse.droppeddata.failed"));
                return;
              }

              sandbox.core.settingManager.retrieveValidItemsForOpenFromDrop(parsedData).then(function (validItems) {
                if (Array.isArray(validItems) && validItems.length > 0) {
                  sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                    commandId: XEngineerConstants.OPEN_ENG_ITEM,
                    context: {
                      item: {
                        objectId: validItems[0].objectId,
                        objectType: validItems[0].objectType
                      }
                    }
                  });
                }

              }).catch(function (e) {
                let message = e.message ? e.message : e;
                xEngAlertManager.errorAlert(sandbox.i18nManager.get(message));
              });
            }
          });
        },
        onFilterBIFilteringEvent: function () {

        },
        RenderSetView: function () {
          var that = this;
          var options = {
            views: [],
            keepDefaultViews: true,
            models: that.models,
            withmultisel: true,
            container: _listContainer,
            modelEvents: null,
            onCellDoubleClick: function (cellinfos) {
              var node = cellinfos.cellModel;
              if (node) {
                sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                  commandId: XEngineerConstants.OPEN_ENG_ITEM,
                  context: {
                    item: {
                      objectId: node.getID(),
                      objectType: node.getType()
                    }
                  }
                });
              }

            },
            defaultView: sandbox.options.getPreferredView(sandbox.core.localStorage) || 'Thumbnail',
            toolbar: {
              showItemCount: true,
              multiselActions: [{
                id: "compare",
                text: sandbox.i18nManager.get("compare"),
                fonticon: "copy",
                handler: function (e) {
                  sandbox.core.contextManager.addSelection(that.models.getSelectedNodes(), true);
                  sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                    commandId: XEngineerConstants.COMPARE_CMD,
                    context: {}
                  });
                }
              }, {
                id: "Maturity",
                text: sandbox.i18nManager.get("Maturity"),
                fonticon: "promote",
                handler: function (e) {
                  var multi = that.models.getSelectedNodes();
                  sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                    commandId: XEngineerConstants.MATURITY_GRAPH_CMD,
                    context: {
                      item: multi
                    }
                  });
                }
              }, {
                id: "change_ownership",
                text: sandbox.i18nManager.get("change_ownership"),
                fonticon: "user",
                handler: function (e) {
                  sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
                    commandId: XEngineerConstants.CHANGE_OWNER_CMD,
                    context: {
                      item: that.models.getSelectedNodes()
                    }
                  });

                }
              }],
              actions: [],
              sort: [{
                id: "Title",
                text: sandbox.i18nManager.get("ds6w:label"),
                type: "string"
              }, {
                id: "Maturity",
                text: sandbox.i18nManager.get("ds6w:status"),
                type: "string"
              }, {
                id: "Owner",
                text: sandbox.i18nManager.get("ds6w:responsible"),
                type: "string"
              }, {
                id: "CreationDate",
                text: sandbox.i18nManager.get("ds6w:created"),
                type: "string"
              }, {
                id: "ModifiedDate",
                text: sandbox.i18nManager.get("ds6w:modified"),
                type: "string"
              }]

            }
          };

          this.myResponsiveSetView = new ENOXResponsiveSetView(options);
          this.PersistToken = this.myResponsiveSetView._modelEvents.subscribe({
            event: EVENT_PERSIST_VIEW
          }, function (viewId) {
            sandbox.core.localStorage.setItem(sandbox.options.getViewName() + "_view", viewId);
          });
        }
      };

    };

    return MyEngineeringItems;

  });

define('DS/ENOXEngineer/componentsHelpers/mixins/XEngDnDManager', [
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'DS/ENOXEngineer/services/XEngContextManager',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(Utils, PromiseUtils, xEngAlertManager,XEngContextManager, nlsKeys) {

    'use strict';



    /**
    * @options.container
    * @options.context
    * @options.onDrop
    **/
    function XEngDnDManager(options){
      this.container = options.container;
      var that = this;

      if(!options.sandbox ||(options.droppable && (!options.onDrop || !options.dropStrategy )) || (options.draggable && !options.getSerializedContent))
        throw new Error("invalid parameter for XEngDnDManager constructor");


      this.sandbox = options.sandbox;
      if(options.droppable){
        this.onDrop = options.onDrop;
        this.dropStrategy = options.dropStrategy;
        this.invite= this.sandbox.core.moduleHelper.viewsService.getDnDInvite();
        this.invite && this.invite.hide();
        this._makeDroppable();

      }

      if(options.draggable){
        this.getSerializedContent = options.getSerializedContent;
        this._makeDraggable();
      }



    }

    XEngDnDManager.prototype.dropValidator = function (parsedData) {
      var that = this;
      try { //check dropped data format
        Utils.get3DXContentFromDrop(parsedData);
      } catch (e) {
        xEngAlertManager.errorAlert(that.sandbox.i18nManager.get("error.parse.droppeddata.failed"));
        return;
      }
      that.validateByStrategy(parsedData).then(function (result) {
        that.onDrop(result);

      }).catch(function (reason) {
        if(reason && reason.globalIssue)
          xEngAlertManager.errorAlert(that.sandbox.i18nManager.get("error.drop.failed"));
        console.error(reason);
      });

    }

    XEngDnDManager.prototype.validateByStrategy = function(parsedData){
      var that = this;
      return PromiseUtils.wrappedWithPromise(function(resolve, reject){
        if(!parsedData) return reject({
          globalIssue: true,
          msg:'invalid input'
        });

        var promise = null;
        switch (that.dropStrategy) {
          case "OPEN":
            promise = that.sandbox.core.settingManager.retrieveValidItemsForOpenFromDrop(parsedData);
            break;
          case "BOM":
            promise = that.sandbox.core.settingManager.retrieveAllValidContentForXENFromDrop(parsedData);
            break;
          case "DOC":
            promise = that.sandbox.core.settingManager.retrieveAllValidDocumentsFromDrop(parsedData);
            break;
          default:
            break;
        }
        if(!promise) return reject({
          globalIssue: true,
          msg:'inexistant or invalid drop itent'
        });

        promise.then(function(result){
            resolve(result);
        }).catch(function(reason) {
          reject(reason);
        })

      });
    }

    XEngDnDManager.prototype.getOnDropLabel= function(){
      switch (this.dropStrategy) {
        case "OPEN":
          return 'drop';
        default:
          return 'insert';
      }
    };

    XEngDnDManager.prototype.destroy = function(){
      Utils.cleanDroppable(this.container);
      this.container =null;
      this.sandbox = null;
      this.invite = null;

    }

    XEngDnDManager.prototype._makeDraggable = function(){
      var that = this;
      Utils.makeDraggable(that.container, //DOM element to make draggable,
        {
        data : that.getSerializedContent(),
        start :function (element, mouseEvent){
          XEngContextManager.dragStartedInXENG = true;
          console.log('##drag start');
        },
        stop : function(event){
          XEngContextManager.dragStartedInXENG = false;
          console.log('###drag end');
        }

      });

    };

    XEngDnDManager.prototype._makeDroppable = function () {
      var timeout , that = this;
      Utils.makeDroppable({
          element: that.container, //DOM element to make droppable
          context:this,
          onDragEnter: function () {
        	  if (XEngContextManager.dragStartedInXENG===true){
              that.container.removeClassName('dragging');
              return;
            }
        		  
              that.invite.addBorder();
              that.invite.show(that.getOnDropLabel());
              if (!that.container.hasClassName('dragging')) {
                  that.container.addClassName('dragging');
              }
          },
          onDragLeave: function () {

                  that.invite.hide();
                  if (that.container.hasClassName('dragging')) {
                      that.container.removeClassName('dragging');
                  }

          },
          onDragOver:function(){
        	  if (XEngContextManager.dragStartedInXENG===true)
        		  return;
              that.invite.show(that.getOnDropLabel());
              if (!that.container.hasClassName('dragging')) {
                  that.container.addClassName('dragging');
              }
          },
          onDrop:function(dropData, context){
        	  if (XEngContextManager.dragStartedInXENG===true) return;
        		  
              that.invite.hide();
              that.container.removeClassName('dragging');
              try {
                that.dropValidator(JSON.parse(dropData));
              } catch (e) {
                xEngAlertManager.errorAlert(nlsKeys.get("error.parse.droppeddata.failed"));
                return;
              }


          }
      });

    };

    return XEngDnDManager;

});

/**
 * @module DS/ENOXEngineer/services/ViewsService
 */
define('DS/ENOXEngineer/services/ViewsService', [
    'UWA/Core', 
    'UWA/Class',
    // 'DS/ENOXEmptyContent/js/ENOXEmptyContent',
    'DS/ENOXEngineerCommonUtils/PromiseUtils',
    'DS/UIKIT/Input/Button',
    'DS/Windows/ImmersiveFrame',
    'DS/ENOXEngineer/componentsHelpers/InviteDnD/DnDInvite',
    'DS/ENOXEngineer/componentsHelpers/mixins/XEngDnDManager',
    'DS/ENOXEngineer/utils/XEngineerConstants',
    'require'
], function(UWA, Class, /*ENOXEmptyContent,*/ PromiseUtils , UIKITButton, WUXImmersiveFrame, 
    DnDInvite, XEngDnDManager, XEngineerConstants, localRequire) {

    'use strict';

    var ENOXEmptyContent = null;

    function uid() {
        return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
    }

    function decorateSandBoxBase(sandboxBase){

       sandboxBase.registerDnDManager = function(options){
           if(!options ) return ;
                var token = uid();
                if(!Array.isArray(this._DnDManagers)){
                this._DnDManagers = [];
                }
                this._DnDManagers.push({
                token: token,
                manager: new XEngDnDManager(options)
                });

            return token;
       }
    }

     /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/services/ViewsService
     * @param {Object} options options hash or a option/value pair.
     */
    var ViewsService = Class.singleton(
    /**
     * @lends module:DS/ENOXEngineer/services/ViewsService
     */
    {

        init: function(options) {
            this._parent(options);
        },
        initialize:function(app){
            this.logger=app.core.logger.get("emptyview manager");
            this.app = app;
            app.core.moduleHelper.viewsService = this;
            this.immersiveFrame = null;
            app.optionalStartupPromises.push( this._temporaryLoadEmptyView() );

            decorateSandBoxBase(app.sandboxBase);

        },
        _temporaryLoadEmptyView: function(){
            return PromiseUtils.wrappedWithPromise(function(resolve, reject){
                localRequire(['DS/ENOXEmptyContent/js/ENOXEmptyContent'], function(_ENOXEmptyContent){
                    ENOXEmptyContent = _ENOXEmptyContent;
                    resolve(true);
                }, function(reason){
                    reject(reason);
                });
            });
        },
        getApplicationImmersiveFrame: function(){
            if(!this.immersiveFrame){
                this.immersiveFrame = new WUXImmersiveFrame({
                    identifier: 'XENImmersiveFrame'
                });
            }
            return this.immersiveFrame;
        },
        getGridOptions: function(_viewName){
            var  options = null;
            var that = this;
            switch (_viewName) {
                case "my_eng_items":
                
                    // break;
            
                default:
                    var addButton = new UIKITButton({ value: this.app.core.i18nManager.get('eng.ui.start.byCreate.content'), className: 'primary' });
                        options = {
                            sentences: [{
                            type: 'dom',
                            DOMelement: addButton.getContent(),
                            events: { 
                                onclick: function () {
                                    that.app.core.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND,{
                                        commandId: XEngineerConstants.CREATE_NEW_ENG_ITEM
                                      });
                                }
                             }
                            },{
                                type: 'drop',
                                text: this.app.core.i18nManager.get('DropInvit_drop'),
                            }],
                            fontSize: '16px',
                            orderedListType: 'none',
                            modelEvents: this.app.core.mediator.getApplicationBroker()
                        }
                    break;
            }
            return options;
        },
        getGridEmptyView: function(_viewName){
            return this._instanciateEmptyViewer( this.getGridOptions(_viewName));
        },
        _instanciateEmptyViewer: function(param){
            return new ENOXEmptyContent(param);
        },
        getDnDInvite: function(){
            if(!this.invite){
                this.invite = new DnDInvite({
                    renderTo: widget.body
                });
            }
            return this.invite;
        }

    });

    return ViewsService;
});

/*eslint comma-style: ["error", "last"]*/
define('DS/ENOXEngineer/columnsFormatter/PreferredUnitColumnProvider', [
    'UWA/Core',
    'UWA/Class',
	'DS/ENOXEngineer/services/EngineeringSettings',
	'DS/ENOXEngineerCommonUtils/PromiseUtils',
	'DS/ENOXEngineer/services/I18nManager',
	'DS/ENOXEngineer/utils/XENHttpClient'],
function (UWA, Class, EngineeringSettings, PromiseUtils, I18nManager, xAppWSCalls) {
    'use strict';
    var PreferredUnitColumnProvider = Class.singleton({

        init: function (options) {
            this._parent(options);
        },        // Used by Product Structure Editor code
        initialize: function(options){
          if(options)
          this.appCore = options.appCore || {};
        },
        getName: function () {
            return 'convertingColumns';
        },
        buildServerInput: function(nodesInput){
          if(!Array.isArray(nodesInput))  return null;

          var mapping = {};
          nodesInput.forEach(function(input){
            if(!mapping[input.dimension])
                  mapping[input.dimension] = {};
            if(!mapping[input.dimension][input.toUnit]){
              mapping[input.dimension][input.toUnit] = {
                values: []
              }
            }

            mapping[input.dimension][input.toUnit].values.push(input.value);
          });

          return {
            mapping : mapping,
            inputs: this._fromMappingToInput(mapping)
          };
        },
        _fromMappingToInput: function(mapping){
          var dims = Object.keys(mapping);
          var result = [];
          dims.forEach(function(dim){
            var toUnits = Object.keys(mapping[dim]);
            toUnits.forEach(function(toUnit) {
              var obj = mapping[dim][toUnit] ;
              result.push({
                values: obj.values,
                dimension: dim,
                toUnit:toUnit
              });
            });
          });
          return result;
        },
        /**
        {
          pid:val,
          attrs : {
            attr1:val1
          }
        }
        */
        parseAndMapResponse: function(intiVal, response){
            var mapping ={};
            response.forEach(function(resolved){
              var key = resolved.dimension+resolved.toUnit;
              if(!mapping[key]){
                mapping[key] = {};
              }
              resolved.values.forEach(function(pair){
                mapping[key][pair.from] = pair.to;
              });
            });
            console.warn(mapping);
            var result = {};
            intiVal.forEach(function(entry){
              if(!result[entry.pid]) result[entry.pid]={};
              var key = entry.dimension + entry.toUnit;
              result[entry.pid][entry.sixw+"_converted"] = mapping[key][entry.value] || null;
            });
            console.warn(result);
            return {pids: result} ;
        },
        // Input Param nodesToUpdate contains list of pids and relids.
        // Result updatedAttributes consists pids and relids with Effectivity information.
        // [{
        //   value:21,
        //   dimension:'VOLUME',
        //   toUnit:'LITER',
        //   pid:'54551515151'
        // }]
          updateAttributes: function (valuesToConvert, callback) {
            if(!Array.isArray(valuesToConvert)) return callback([]);
            var that = this;
            var infos = this.buildServerInput(valuesToConvert);
            this.appCore.dataService.dimensionsUnitsConverter( infos.inputs )
                                    .then(function(response){
                                      callback(that.parseAndMapResponse(valuesToConvert, response));
                                    }).catch(function(reason){
                                      console.error(reason);
                                    });
          }
    });
    return PreferredUnitColumnProvider;
});

define('DS/ENOXEngineer/models/EngItemListModel',
[
  'DS/ENOXEngineer/models/EngItemModel',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'UWA/Core'
],
 function(
   EngItemModel,
   PromiseUtils,
   Core
 ) {

    'use strict';

    function EngItemListModel(options){

        this.options = {
          instanceId : '',
          instanceName : '',
          instanceMainAttribute : {
		                        name: 'Effectivity',
		                        value: ''
		                    },
          viewType : 'instance',
          group: null
        };

        this.options = Core.extend(this.options, options);
        EngItemModel.call(this, this.options);
    }

    EngItemListModel.prototype = Object.create(EngItemModel.prototype);

    EngItemListModel.prototype.getEffectivity =  function(){
      return this.options.instanceMainAttribute.value;
    };

    EngItemListModel.prototype.completePath = function(rootPath){
          if(!Array.isArray(rootPath)) return [];
          rootPath.push(this.getRelationID());
          rootPath.push(this.getID());
          return rootPath;
    };

    EngItemListModel.prototype.getViewType = function(){
      return this.options.viewType;
    };

    EngItemListModel.prototype.getUuid =  function(){
      return this.getRelationID();
    };

    EngItemListModel.prototype.getRelationID = function(){
      return this.options.instanceId;
    };

    EngItemListModel.prototype.setGroup = function(group){
      this.options.group = group;
    };

    EngItemListModel.prototype.getGroup = function(){
      return this.options.group;
    };
    /*

    EngItemListModel.prototype.getReferenceQuantity = function(){

      if (Core.is(this.getGroup()) && this.getGroup().getInstances()[0] === this) {
        return this.getGroup().getInstances().length;
      } else {
        return null;
      }

    };
    */
    EngItemListModel.prototype.syncModel = function(){
      var that =this;
      return new Promise(function(resolve, reject){
        that.options.appCore.dataService.getListNodesFromEngItemsAndInstanceIds([{
                              instance: that.getRelationID(),
                              isInstanceOf: that.getID()
                            }])
                            .then(function(items){
                              that.refreshModel(items[0]);
                              resolve(true);
                            }).catch(function(reason){
                              reject(reason);
                            });
      });
    };
    /*
    EngItemListModel.prototype.isLastChild = function(){
      if (!Core.is(this.getGroup())) {
        return true;
      }
      var lastIdx = this.getGroup().getInstances().length > 0  ? this.getGroup().getInstances().length-1 : null;

      if (lastIdx === null) {
        return false;
      }
      if (this.getGroup().getInstances()[lastIdx] === this) {
        return true;
      }
      return false;
    };
    */


    EngItemListModel.prototype.getInstanceName = function(){
      return this.options.grid.instanceName;
    };

    EngItemListModel.prototype.getInstanceEvolution = function(){
      return this.options.grid.CurrentEvolutionEffectivity;
    };

    EngItemListModel.prototype.getInstanceVariant = function(){
      return this.options.grid.VariantEffectivity;
    };

    EngItemListModel.prototype.getInstanceConfiguration = function(){
      return this.options.grid.Configuration;
    };

    EngItemListModel.prototype.hasStaticMapping = function(){
      return this.options.grid.hasStaticMapping;
    };

   //physical Id of product configuration
    EngItemListModel.prototype.getConfigurationID = function(){
      return this.options.grid.ConfigurationID;
    };

    EngItemListModel.prototype.getInstanceType = function(){
        return this.options.instanceType;
      };

     EngItemListModel.prototype.isInstance = function(){
    	  var isInstance = true;

    	  if (this.isRepresentation() === true)
    		  isInstance = false;

          return isInstance;
     };


    EngItemListModel.prototype.getMetaType = function(){
      var that = this;
      return PromiseUtils.wrappedWithPromise(function(resolve, reject){
        that.options.appCore.dataService.getMetaTypes([that.getType()], that instanceof that.options.appCore.Factories.ListItemFactory.getListInstanceClass())
            .then(function(result){
              return resolve(result[0]);
            }).catch(function(err){
              return resolve('businessobject'); //default value
            });
        });
    };

/*
    EngItemListModel.prototype.getInstanceMainAttribute = function(){
      return this.options.instanceMainAttribute;
    };
    */


    return EngItemListModel;

});

/**
 * @module DS/ENOXEngineer/services/XEngineerItemsFactory
 */
define('DS/ENOXEngineer/services/XEngineerItemsFactory', [
  'UWA/Core',
  'UWA/Class',
  'UWA/Class/Promise',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/ResponseParser',
  'DS/ENOXEngineer/models/EngItemListModel',
  'DS/ENOXEngineer/models/EngItemModel',
  'DS/ENOXEngineer/models/EngItemGroupModel',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineer/collections/XEngGridTreeDocument',
  'WebappsUtils/WebappsUtils'
], function(UWA, Class, Promise, Utils, ResponseParser, EngItemListModel, EngItemModel, EngItemGroupModel, XEngineerConstants,XEngGridTreeDocument, WebappsUtils) {

    'use strict';

     /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/services/XEngineerItemsFactory
     * @param {Object} options options hash or a option/value pair.
     */
    var XEngineerItemsFactory = Class.singleton(
    /**
     * @lends module:DS/ENOXEngineer/services/XEngineerItemsFactory
     */
    {

        init: function(options) {
            this._parent(options);
        },
        initialize : function(xEngApp){
          this.app = xEngApp;
          if(!this.app.core.Factories ) this.app.core.Factories = {};
          this.app.core.Factories.ListItemFactory = this;
          this.i18nManager = this.app.core.i18nManager;

        },
        buildGroupNode: function(_options){
          if(!_options ||
            !_options.property ||
            !_options.identifier == undefined ||
            !_options.firstmember){
              throw new Error("missing attribute to build grouping node");
            }
          var options = UWA.extend(_options, this.getGroupAttributes(_options));
          return new EngItemGroupModel(options);

        },
        getGroupAttributes : function(_options){
          var targetAttr = _options.property;
          var identifier = _options.identifier;
          var member = _options.firstmember;
          var options = {};
          var that = this;
          switch (targetAttr) {
            case 'reference':
            	if (identifier !== "NA"){
                    UWA.extend(options, member.options);// can not put recursive == true because of cyclic objects
                    options.grid = {}; // to avoid reference sharing,
                    options.padgrid = {};


                    UWA.extend(options.padgrid, member.options.padgrid);
                    options.viewType = 'reference';
                    delete options.instanceId;
                    delete options.instanceName;
                    delete options.instanceMainAttribute;

                    if (member.isMaterialQuantity()){
                    	options.grid['ds6w:label'] = member.options.grid['CoreMaterial'];
                    	options.grid['CoreMaterial'] = member.options.grid['CoreMaterial'];
                    	options.grid['CoreMaterialID'] = member.options.grid['CoreMaterialID'];
                      options.grid['CoreMaterialInfo'] = member.options.grid['CoreMaterialInfo'];
                      options.grid['isCoreMaterialGroupNode'] = true;
                    } else {
                        var referenceAttributes = this.app.core.dataService.getAvailableAttributesByGlobalType(options.padgrid["ds6w:globalType"]);
                        referenceAttributes.forEach(function(attribute){
                        	options.grid[attribute.sixWTag] = member.options.grid[attribute.sixWTag];
                        });
                    }


            	} else {
            		options.property = this.i18nManager.get( _options.property)
                    options.viewType = 'attributeNode';
            	}


              break;
            // case 'owner':
            //
            //   break;
            default:
            	var paramAttrs = that.app.core.dataService.getParametricalAttributesOf("VPMReference");
	            if(Array.isArray(paramAttrs)){
	            	for(var i=0; i<paramAttrs.length;i++){
	            		const custoAtt = paramAttrs[i];
	            		if(custoAtt && custoAtt.sixWTag === targetAttr){
	            			var typeRepresentation = custoAtt.type.toLowerCase();
	            			if(typeRepresentation === "date"){
	            				options["patch_isCustoDate"] = true;
	            			}
	            			break;
	            		}
	            	}
	            }
            options.property = this.i18nManager.get( _options.property)
              options.viewType = 'attributeNode';
          }

          return options;
        },
        getListNodesFromServerExpand: function(expandServerResponse, parsingOptions){
          var that = this;
          var settingManager = that.app.core.settingManager;
          return new  Promise(function(resolve,reject){
            var parseData = ResponseParser.parseAndBuildIRPCStructure(expandServerResponse,
                                              settingManager.getSetting(XEngineerConstants.DS6W_CLASSES_WITH_NLS_PROP), parsingOptions );
            that.app.core.i18nManager.resolveMissingNls(parseData.nlsTracker)
            .then(function(args){
              if(!parseData.root) // when expand result is empty
                return resolve([]);
            	var children = [];
              var pids = [];
            	for (var key in parseData.nodes){
            		if (parseData.nodes[key].children && parseData.nodes[key].children.length > 0){
                		parseData.nodes[key].children.forEach(function(child){
            				children.push(child);
                    pids.push(child.physicalid);
            			});
            		}
            	}
              var listNodes = that.createListNodes(children, that.expandListNodeOptionsMapper.bind(that));
              ResponseParser.cleanExpandParsedData(parseData);
              expandServerResponse = undefined;
              return resolve(listNodes);
            });

          });

        },

        isFinalItem :function(dataObj){
        	var isFinalItem = dataObj[widget.getValue(XEngineerConstants.FINAL_ITEMS_PREF)];
        	return ( isFinalItem && (isFinalItem == "TRUE" || isFinalItem == "True"));
        },

        showInBOM :function(dataObj){
        	if(widget.getValue("ShowNotInBOM") === undefined  || widget.getValue("ShowNotInBOM")=="false"){
	        	var showInBOM = dataObj["ds6wg:SynchroEBOMExt.V_InEBOMUser"];
	        	return !( showInBOM && showInBOM == "FALSE");
        	}
        	return true;
        },

        getQualifiedAsFinalListNodesFromServerExpand: function(expandServerResponse){
            var that = this;
            var settingManager = that.app.core.settingManager;
            return new  Promise(function(resolve,reject){
              var parseData = ResponseParser.parseAndBuildIRPCStructure(expandServerResponse,
                                                settingManager.getSetting(XEngineerConstants.DS6W_CLASSES_WITH_NLS_PROP) );
              that.app.core.i18nManager.resolveMissingNls(parseData.nlsTracker)
              .then(function(args){
                if(!parseData.root) // when expand result is empty
                  return resolve([]);

              	var children = [];
                var pids = [];
                var existingPaths="";
                var existingInstance = [];
                for (var i=0 ; i < parseData.paths.length ; i++){
                	var pathArray = parseData.paths[i];
                	for(var j=2 ; j<pathArray.length ;j+=2 ){
                		existingPaths = existingPaths+pathArray[j-1];
                		if(that.showInBOM(parseData.nodes[pathArray[j-1]]) == false ){ break ;}
                		var isFinalItem = that.isFinalItem(parseData.nodes[pathArray[j]]);
                		if(!existingInstance.includes(existingPaths)){
                			if(isFinalItem || j==(pathArray.length-1)){
                				if(parseData.nodes[pathArray[j]]["ds6w:globalType"]=="ds6w:Part" ||  j==2){
                					existingInstance.push(existingPaths);
                					children.push(parseData.nodes[pathArray[j-1]]);
                      				pids.push(parseData.nodes[pathArray[j-1]].physicalid);
                				}else if(!existingInstance.includes(existingPaths) && parseData.nodes[pathArray[j-2]] && parseData.nodes[pathArray[j-2]]["ds6w:globalType"]=="ds6w:Part"){
                					if(parseData.nodes[pathArray[j-3]]){
                						existingInstance.push(existingPaths);
	                					children.push(parseData.nodes[pathArray[j-3]]);
	                      					pids.push(parseData.nodes[pathArray[j-3]].physicalid);
                					}
                				}
                				break;
                			}

                		}else if(isFinalItem){break;}

                	}
                	existingPaths = "";
                }
                var listNodes = that.createListNodes(children, that.expandListNodeOptionsMapper.bind(that));
                ResponseParser.cleanExpandParsedData(parseData);
                expandServerResponse = undefined;
                return resolve(listNodes);
              });

            });

          },
        convertEngItemToListNode : function(instancesMap, deleteSource){
          if ( !Array.isArray(instancesMap)) {
            return new Error('invalid input');
          }
          var that = this;
          var results = [];
          for (var i = 0; i < instancesMap.length; i++) {
            var currentItem = instancesMap[i];
            var newOptions = {};
            newOptions =  that.extractAttributesFromNode(currentItem.engItem);
            newOptions.instanceId = currentItem.instance;
            newOptions.instanceName = that.i18nManager.get("loading");

            results.push(that.createListNode(newOptions, function(obj){
              return obj;
            }));
          }

          // if(deleteSource)
          // instancesMap.forEach(function(aMap){
          //   aMap.engItem.destroy();
          //   aMap.engItem = null;
          // });

          return results;

        },
        /*
        * create listnodes from a set of attributes
        **/
        getNlsedListNodes : function(items){
          var that = this;
          return new  Promise(function(resolve,reject){
                if(!Array.isArray(items))
                 return reject(new Error(" inputs error"));

                var settingManager = that.app.core.settingManager;
                var results = [];
                var nlsTracker = {
        								withNlsProp : settingManager.getSetting(XEngineerConstants.DS6W_CLASSES_WITH_NLS_PROP),
        								classes : [],
        								properties: {}
        							};
                  items.forEach(function(attributes){
                      results.push(ResponseParser.attributesParser(attributes, nlsTracker));
                  });

                  that.app.core.i18nManager.resolveMissingNls(nlsTracker)
                                  .finally(function(args){
                              return   resolve(that.createListNodes(results, that.genericEngItemOptionsMapper.bind(that)));
                              });

          });

        },
        getEngItemsListFromServerFetch : function(fetchServerResponse, isUWAModel, withconfig){
          var that = this;
          var settingManager = that.app.core.settingManager;
          return new  Promise(function(resolve,reject){
            if( !Array.isArray(fetchServerResponse.results)) return reject(fetchServerResponse);

            var parsedData = ResponseParser.parseFetchResult(fetchServerResponse, settingManager.getSetting(XEngineerConstants.DS6W_CLASSES_WITH_NLS_PROP));

            that.app.core.i18nManager.resolveMissingNls(parsedData.nlsTracker)
                            .finally(function(args){
                              var engItems = that.createEngItemNodes(parsedData.results, that.genericEngItemOptionsMapper.bind(that));

                            //for our App at each time we only one configured
                              if(withconfig && engItems.length === 1){
                                var engItem =engItems[0];

                                engItem.getConfigInitPromise().finally(function(){
                                  resolve([engItem]);
                                });
                              } else {
                                  return resolve(engItems);
                              }


                            });
          });
        },
        expandListNodeOptionsMapper : function(instance){
          var options = this.genericEngItemOptionsMapper(instance.instanceOf);
          options.instanceId = instance["physicalid"];
          options.instanceName = (instance["type"] !== "VPMRepInstance") ? (instance["ds6w:label"] || instance["ro.PLMInstance.PLM_ExternalID"]) : "";
          options.instanceType = instance["type"];
          options['ds6wg:SynchroEBOMExt.V_InEBOMUser'] = instance['ds6wg:SynchroEBOMExt.V_InEBOMUser'];
          return options;
        },
        genericEngItemOptionsMapper: function(engItem){
          engItem["ds6w:created"] = Utils.getformatedDate(engItem["ds6w:created"]);
          engItem["ds6w:modified"] = Utils.getformatedDate(engItem["ds6w:modified"]);
          return engItem;
        },
        listNodeToEngItem: function (listNode){
          var newOptions = {};
          UWA.extend(newOptions, listNode.options);
          newOptions.viewType = 'reference';
          newOptions.instances = [];
          return new EngItemModel(newOptions);

        },
        _optionsRetrievor : function(item, attributesResolver){
          var that = this;
          var rowAttr =null;
          if(attributesResolver && UWA.typeOf(attributesResolver) === 'function'){
            rowAttr = attributesResolver(item);
          }else if (attributesResolver && attributesResolver ==='fromSearch') {
            rowAttr = that.retrieveNodeDataFromSearchResult(item);
          } else if (attributesResolver && attributesResolver ==='fromDocAPI') {
            rowAttr = that.retrieveNodeDataFromDocumentAPI(item);
          } else {
            rowAttr = item;
          }
          return rowAttr;
        },
        getReferenceClass : function(){
          return EngItemModel;
        },
        getListInstanceClass : function(){
          return EngItemListModel;
        },
        isInstanceOfEngItem: function(candidate){
          if(candidate instanceof this.getReferenceClass()){
            return true;
          }else{
            return false;
          }
        },
        isInstanceOfListNodeModel: function(candidate){
          if(candidate instanceof this.getListInstanceClass()){
            return true;
          }else{
            return false;
          }
        },
        extractAttributesFromNode: function(node){
          var options = {};
          if(this.isInstanceOfListNodeModel(node) || this.isInstanceOfEngItem(node)){

            options = UWA.merge(UWA.clone(node.options.grid), UWA.clone(node.options.padgrid));
            options.type = node.options.type;
            options.physicalid = node.options.referenceId;
            options.thumbnail = node.options.thumbnail;
            options.icons = node.options.icons;
            options['ds6wg:PLMReference.V_isLastVersion'] = node.options.isLastVersion;
            options["ds6w:globalType"]= node.options.padgrid["ds6w:globalType"];

            if(node.options.instanceId)
              options.instanceId = node.options.instanceId;

          }
          return options;

        },
        extractOptionsFromNode: function(node){
          var rowOptions = null;
          var rowAttr =this.extractAttributesFromNode(node);
          if(this.isInstanceOfListNodeModel(node)){
            rowOptions = this.basicOptionsBuilder(rowAttr).addInstanceOptionsBuilder(rowAttr).Options;
          } else{
            rowOptions = this.basicOptionsBuilder(rowAttr).Options;
          }

          if(rowOptions){
            //clean the options
            delete rowOptions.isCut;
            delete rowOptions.quantity;
            delete rowOptions.showMoreInfo;
            delete rowOptions.appCore;
            if(!rowOptions.grid.instanceName || rowOptions.grid.instanceName=== this.i18nManager.get("loading")){
              delete rowOptions.grid.instanceName;
            }

          }
          return rowOptions;
        },

        createEngItem : function(item, attributesResolver){
          var that = this;
          var rowAttr =that._optionsRetrievor(item, attributesResolver);
          var rowOptions = that.basicOptionsBuilder(rowAttr).Options;
          var currentNode = new EngItemModel(rowOptions);
          return currentNode;
        },
        createListNode : function(item, attributesResolver){
            var that = this;
            var rowAttr =that._optionsRetrievor(item, attributesResolver);
            var rowOptions = that.basicOptionsBuilder(rowAttr).addInstanceOptionsBuilder(rowAttr).Options;
            var currentNode = new EngItemListModel(rowOptions);
            return   currentNode;
        },
        basicOptionsBuilder : function(attrs, isLastStep){
          var that = this;

          var globalType = "ds6w:Part";
          if (attrs["ds6w:globalType"]){
        	  globalType = attrs["ds6w:globalType"];
          }

          this.Options ={
              type: attrs.type,
              isCut: false,
              quantity: 1,
              tenant : that.app.core.settingManager.getPlatformId(),
              label : attrs["ds6w:label"],// +' - '+ attrs["ds6wg:revision"]   || '',
              grid : {},
              padgrid:{
            	  "ds6w:globalType" : globalType
              },
              showMoreInfo  :true,
              subLabel : attrs["ds6w:responsible"] +' \n'+ attrs["ds6w:modified"],
              attributes: [],
              referenceId: attrs.physicalid,
              thumbnail: attrs["thumbnail"] ||  that.getDefaultProductThumbnail(),
              appCore : that.app.core,
              icons:attrs.icons,
              isLastVersion: attrs['ds6wg:PLMReference.V_isLastVersion']
          };
          if(attrs.type === "Document"){
            this.Options.locker = attrs.locker;
            this.Options.checkedOut = (this.Options.locker && this.Options.locker.length>0);
            this.Options.isMultiFile = attrs.isMultiFile;
            this.Options["ds6w:docExtension"] = attrs["ds6w:docExtension"];
          }
          that._fillAttributes(attrs);

          if (!isLastStep) return this;
          //create the corresponding node
          return   this.Options;
        },
        _fillAttributes : function(attrsMap){
          var that = this;
          if (!this.Options.grid) {
            this.Options.grid = {};
          }

          that._fillParametricalStringDefault(this.Options);
          that.Options.grid['ds6w:description']=""; //by pass for editmode in list
          Object.keys(attrsMap)
                    .forEach(function(attrName){
                      if(attrsMap.hasOwnProperty(attrName) && that.app.core.dataService.isAKnownAttribute(attrName)){
                        that.Options.grid[attrName] = attrsMap[attrName];
                      }
                    });
          if(attrsMap['ds6wg:SynchroEBOMExt.V_InEBOMUser'] && //check for not in bom flag
           attrsMap['ds6wg:SynchroEBOMExt.V_InEBOMUser'].toUpperCase()==="TRUE" ){
            that.Options.grid['ds6wg:SynchroEBOMExt.V_InEBOMUser'] = true;
          }

          if( that.Options.padgrid["ds6w:globalType"] === "ds6w:Part") //is engitem
              that._parseCustoDateAttributes(this.Options);

          that.Options.grid['ds6w:status'] =  that.i18nManager.get("ds6w:status/"+attrsMap["ds6w:status"]); //should be nls
          that.Options.grid['ds6w:type']= that.i18nManager.get("ds6w:type/"+attrsMap.type);
          return this.Options;
        },
        _fillParametricalStringDefault: function(options){
          if(!this.customStringDefault){
            this.customStringDefault = this.app.core.dataService.getParametricalAttributesOf("VPMReference") || [];
            this.customStringDefault = this.customStringDefault.filter(function(attr){
              return (!attr.isReadOnly && attr.type ==="String");
            }).map(function(attr){
              return attr.sixWTag;
            });
          }

          if(!options || !options.grid) return ;

          this.customStringDefault.forEach(function(attrName){
            options.grid[attrName] = "";
          });

        },
        _parseCustoDateAttributes : function(options){
          if(!this.customDateAttrs){
            this.customDateAttrs = this.app.core.dataService.getParametricalAttributesOf("VPMReference") || [];
            this.customDateAttrs = this.customDateAttrs.filter(function(attr){
              return (attr.type.toLowerCase() ==="date");
            }).map(function(attr){
              return attr.sixWTag;
            });
          }

          if(!options || !options.grid) return ;
          this.customDateAttrs.forEach(function(attrName){
            var formated = Utils.dateFormatFromDsToIso(options.grid[attrName]);
            options.grid[attrName] = formated ? formated : "";
          });

        },
        getDefaultProductThumbnail : function(){
          if (this.defaultThumbnail) return this.defaultThumbnail;

            this.defaultThumbnail = WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'img/product.png');
            return this.defaultThumbnail;
        },
        getDefaultDocumentIcon:function(){
          return  WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'icons/32/I_CDM_Document.png');
        },
        getDefaultProductIcon: function(){
          return this.app.core.settingManager.getDefault3DSpaceUrl()+"/snresources/images/icons/small/I_VPMNavProduct.png";
        },
        getCADIcon:function(cad){
          if(!cad || cad.trim().length ===0) return "";
          return this.app.core.settingManager.getIconPath("I_"+cad);

        },
        addInstanceOptionsBuilder : function(attr, isLastStep){
          var that = this;
          if (!this.Options) {
            console.error(' you need to call basic method before !');
            return null;
          }

          this.Options.instanceId = attr.instanceId;
          this.Options.instanceType = attr.instanceType;
          this.Options.grid.instanceName = attr.instanceName;
          this.Options.grid["ds6wg:SynchroEBOMExt.V_InEBOMUser"] = attr["ds6wg:SynchroEBOMExt.V_InEBOMUser"];
          // if(this.Options.type === "VPMReference"){
          //   this.Options.grid.evolution = attr.evolution? attr.evolution : that.i18nManager.get("None");
          //   this.Options.grid.variant = attr.variant? attr.variant : that.i18nManager.get("None");
          // }

          if (!isLastStep) return this;

          return   this.Options;
        },
        retrieveNodeDataFromSearchResult : function(searchData){
          return {
            type : searchData["ds6w:type"],
            instanceId : searchData["id"],
            "ds6w:description" : '',
            "ds6w:label" : searchData["ds6w:identifier"],
            "ds6wg:revision" : '-',
            "ds6w:status" : searchData["ds6w:status"],
            "ds6w:responsible" : searchData["ds6w:responsible"],
            "ds6w:created" : Utils.getformatedDate(searchData["ds6w:created"]),
            "ds6w:modified" : Utils.getformatedDate(searchData["ds6w:modified"]),
            instanceName : searchData["ds6w:label"],
            physicalid : searchData["id"],
            thumbnail : searchData["preview_url"]

          }
        },
        retrieveNodeDataFromDocumentAPI : function(DocumentResponse){
          var that = this;
          if (!DocumentResponse) {
            return null;
          }
          var doc = DocumentResponse;
          if (!doc) {
            return null;
          }
          var ownerInfo = doc.relateddata.ownerInfo[0].dataelements;
          var fileInfo = (doc &&doc.relateddata && doc.relateddata.files ) ?doc.relateddata.files[0] : null; //best practrice is a file per document
          return {
            type : doc["type"],
            instanceId : doc["id"],
            "ds6w:description" : doc.dataelements["description"],
            "ds6w:globalType" : "ds6w:FileDocument",
            "ds6w:label" : doc.dataelements["title"],
            "ds6wg:revision" : doc.dataelements["revision"],
            "ds6w:status" : that.i18nManager.get(doc.dataelements["state"]),
            "ds6w:responsible" : ownerInfo["firstname"]+' '+ ownerInfo["lastname"],
            "ds6w:created" :Utils.getformatedDate(doc.dataelements["originated"]) ,
            "ds6w:modified" : Utils.getformatedDate(doc.dataelements["modified"]),
            "ds6w:identifier":doc.dataelements["name"],
            locker: (fileInfo && fileInfo.dataelements.locker && fileInfo.dataelements.locker.length>1) ? fileInfo.dataelements.locker : null,
            instanceName : "",
            "ds6w:docExtension":(fileInfo) ? fileInfo.dataelements.title.split('.').pop() : null,
            icons : [doc.dataelements.type_icon_url ? doc.dataelements.type_icon_url : that.getDefaultDocumentIcon()],
            instanceType: "DocInstance",
            isMultiFile: (fileInfo)  ? doc.relateddata.files.length >1:false,
            physicalid : doc["id"],
            thumbnail : doc.dataelements["image"].endsWith(".gif") ? WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'img/document.png') : doc.dataelements["image"]
          }
        },
        createListNodes : function(items, attributesResolver){
          var result = [];
          var that = this;

          items.forEach(function(item){

            var obj = that.createListNode(item, attributesResolver);
            if(UWA.is(obj)){
              if(widget.getValue("ShowNotInBOM") === undefined
            		  || widget.getValue("ShowNotInBOM") === "true"
            	  || ( widget.getValue("ShowNotInBOM") === "false" &&  obj.getAttributeValue('ds6wg:SynchroEBOMExt.V_InEBOMUser') !== "FALSE")){
                result.push(obj);
              }
            }
          });

          return result;
        },
        createEngItemNodes : function(items, attributesResolver){
          var result = [];
          var that = this;
          items.forEach(function(item){
            if(!item.deleted){
              var obj = that.createEngItem(item, attributesResolver);
              if(UWA.is(obj))
              result.push(obj);
            }else{
              result.push(item);
            }

          });

          return result;
        }
    });

    return XEngineerItemsFactory;
});

define('DS/ENOXEngineer/controllers/ItemViewController',
  [
    'DS/ENOXEngineer/utils/XEngineerConstants',
    'DS/ENOXEngineerCommonUtils/xEngAlertManager'
  ],
  function (
    XEngineerConstants,
    xEngAlertManager
  ) {

    'use strict';

    /**
     * @param {object} options.app  application reference
     * @param {object} options.parentController parent controller ref
     **/
    function ItemViewController(options) {
      this.idCardCmp = null;
      this.listViewCmp = null;
      this.itemViewCmp = null;
      var that = this;

      if (!options) {
        throw new Error("options are mandatory");
      }

      if (!options.app || !options.parentController) {
        throw new Error("app and parentController are mandatory");
      }

      var parentController = options.parentController;
      var app = options.app;

      function renderEngItemView(toState) {
        var idCardContainer = UWA.extendElement(that.itemViewCmp.container.querySelector('.top-container'));
        var listViewContainer = UWA.extendElement(that.itemViewCmp.container.querySelector('.listContainer'));
        app.componentsMgt.startInstances([{
            name: XEngineerConstants.IDCARD_CMP,
            container: idCardContainer,
            contextData: {
              physicalId: toState.params.pid,
              models: that.activeTreeDocument
            }
          },
          {
            name: XEngineerConstants.LIST_VIEW_NEW_CMP,
            container: listViewContainer,
            contextData: {
              physicalId: toState.params.pid,
              models: that.activeTreeDocument
            }
          }
        ]).then(function (instancesHolder) {
          that.idCardCmp = instancesHolder[0];
          that.listViewCmp = instancesHolder[1];

          that.infoPanelToken = app.mediator.subscribe(XEngineerConstants.EVENT_INFO_PANEL_VISIBLE, function(){
        	  var selectedNodes =  that.activeTreeDocument.getSelectedNodes();

            if(Array.isArray(selectedNodes) && selectedNodes.length ===0){
              app.mediator.publish(XEngineerConstants.EVENT_SHOW_PROPERTIES, [{
                id: that.activeTreeDocument.getEngineeringItem().getID(),
                metatype: 'businessobject'
              }]);
            }

          });
        }); //load of idcard & listview
      }


      return {
        activate: function (toState) {
          //cleaning previous staticMapping
          app.core.sessionManager.cleanStaticMappingContext();
          //start loading the needed item
          //make sure to load the config settings
          app.core.dataService.loadConfigurationSettings().finally(function () {
            if(toState.params.pcInfo && toState.params.path){
                 app.core.sessionManager.setStaticMappingAsOpenContext(toState.params.pid, {
                   pcInfo:toState.params.pcInfo,
                   path:toState.params.path
                 });
            }

            that.engItemLoadingPromise = app.core.dataService.getEngItemData(toState.params.pid, true /*with paramAtt*/ , app.core.settingManager.shoulAutorizedConfig() /*withconfig*/ );

            app.mediator.publish(XEngineerConstants.EVENT_TRIPTYCH_HIDE_PANEL, 'right');
            app.mediator.publish(XEngineerConstants.EVENT_TRIPTYCH_HIDE_PANEL, 'left');


            that.landingPageListnerToken = app.mediator.subscribe(XEngineerConstants.EVENT_IDCARD_CUSTOM_SHOW_LANDING, function () {
              app.router.navigate('recents_items', {
                replace: false,
                reload: true
              });
            });

            that.setActiveEngItemListerToken = app.mediator.subscribe(XEngineerConstants.EVENT_SET_ACTIVE_ENG_ITEM, function (engItem) {
              app.core.contextManager.setActiveEngItem(engItem);
            });

            app.componentsMgt.startInstances([{
                name: XEngineerConstants.ITEM_VIEW_CMP,
                container: parentController.triptychCmp.mainDiv,
                contextData: {}
              }])
              .then(function (loadedInstances) {
                that.itemViewCmp = loadedInstances[0];
                that.engItemLoadingPromise.then(function (engItems) {
                  if(!Array.isArray(engItems) || engItems.length === 0){
                    throw new Error("Unable to fetch the engineering item attributes");
                  }
                  var currentItem = engItems[0];
                  currentItem.isValidEngItem().then(function () {
                    app.mediator.publish(XEngineerConstants.EVENT_SET_ACTIVE_ENG_ITEM, currentItem);
                  //  if(app.core.contextManager.getXENTreeDocument().getChildren().length ===0) ///avoid refresh adding
                      app.core.contextManager.getXENTreeDocument().addRoot(currentItem);

                    currentItem.select();
                    that.activeTreeDocument = app.core.Factories.CollectionsFactory.getEngItemContentModels(currentItem);
                    that.activeTreeDocument.buildUserWorkingSession().then(function () {
                                  renderEngItemView(toState);
                                }).catch(function (error) {
                                  //some issues went wrong during the session building
                                  console.error(error);
                                  xEngAlertManager.errorAlert(app.core.i18nManager.get("eng.failed.to.open.EI"));
                                  app.mediator.publish(XEngineerConstants.EVENT_GO_BACK);
                                });

                  }).catch(function (e) {
                    console.error(e);
                    xEngAlertManager.errorAlert(app.core.i18nManager.get("trying.toopen.not.engineering.item"));
                    app.mediator.publish(XEngineerConstants.EVENT_GO_BACK);
                  });

                }).catch(function (error) { // the fetch of item failed
                  console.error(error);
                  var msg = (error && error.message) ? error.message : error;
                  xEngAlertManager.errorAlert(msg);
                  app.mediator.publish(XEngineerConstants.EVENT_GO_BACK);
                });


              }); //Itemview component loaded

          });


        },
        deactivate: function () {
          app.core.contextManager.resetSelection();

          //reset workun evolution when close an engineering item.
          if(app.core.settingManager.isWorkingUnderEvolution()){
            app.core.settingManager.resetWorkUnderBubble();
          }

          //to update nextGen filter
          if(app.core.contextManager.getXENTreeDocument()/* && !this._isRefreshing*/)
            app.core.contextManager.getXENTreeDocument().empty();


          that.activeTreeDocument && that.activeTreeDocument.freeXENContent();

          app.mediator.publish(XEngineerConstants.EVENT_SET_ACTIVE_ENG_ITEM, null);
          app.mediator.publish(XEngineerConstants.EVENT_SHOW_PROPERTIES, []);

          that.listViewCmp && that.listViewCmp.stop();
          that.idCardCmp && that.idCardCmp.stop();
          that.itemViewCmp && that.itemViewCmp.stop();
          that.itemViewCmp && app.componentsMgt.deleteInstance(XEngineerConstants.ITEM_VIEW_CMP, that.itemViewCmp.ref);
          that.listViewCmp && app.componentsMgt.deleteInstance(XEngineerConstants.LIST_VIEW_NEW_CMP, that.listViewCmp.ref);
          that.idCardCmp && app.componentsMgt.deleteInstance(XEngineerConstants.IDCARD_CMP, that.idCardCmp.ref);
          app.mediator.publish(XEngineerConstants.EVENT_TRIPTYCH_HIDE_PANEL, 'right');
          that.landingPageListnerToken && app.mediator.unsubscribe(that.landingPageListnerToken);
          that.setActiveEngItemListerToken && app.mediator.unsubscribe(that.setActiveEngItemListerToken);
          that.infoPanelToken && app.mediator.unsubscribe(that.infoPanelToken);

          if(that.activeTreeDocument)
            delete that.activeTreeDocument.core;

          that.activeTreeDocument = null;

          that.listViewCmp = null;
          that.idCardCmp = null;
          that.itemViewCmp = null;

          that.resetListListnerToken = null;
          that.landingPageListnerToken = null;
          that.setActiveEngItemListerToken = null;

          app.mediator.publish(XEngineerConstants.EVENT_RESET_SELECTION);
          app.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
            commandId: XEngineerConstants.UPDATE_WIDGET_TITLE,
            context: {
              label: null
            }
          });
        }
      };




    }

    return ItemViewController;

  });

define('DS/ENOXEngineer/collections/EngItemContentTreeDocument', [
  'UWA/Core',
  'DS/ENOXEngineer/collections/XEngGridTreeDocument',
  'DS/ENOXEngineer/columnsFormatter/PreferredUnitColumnProvider',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'require'
], function(
  UWA,
  XEngGridTreeDocument,
  PreferredUnitColumnProvider,
  XEngineerConstants,
  Utils,
  PromiseUtils,
  XEngAlertManager,
  localRequire) {

    'use strict';

    var EngItemContentTreeDocument = XEngGridTreeDocument.extend({
      // _embeddedEngItem: null, bad approach it put them in the prototype then shared by of objects
      // _loadInstancesPromise:null,
      // _loadDocumentsPromise:null,
      // _contentFetchers:[],
      // _contentIsLoading: true,
      init: function(embeddedEngItem, options){
    	var that = this;
        if(!embeddedEngItem || !options){
          throw new Error("EngItemContentTreeDocument require two valid parameters");
        }
        this._parent(options);
        if(typeof that._FilterBI.setNGFilterOptions === "function"){
          that._FilterBI.addEvent('ApplyNGFilter', that.onApplyNGFilter.bind(that), that);
        }
        this._contentFetchers= [];
        this._countOnGoingAttributesLoaders = 0;
        this.additionalColumnsProvidersDef = [];
        this._contentIsLoading= true;
        this._effAllLoadJobIds = [];
        this._wholeContentLoaderJobIds = [];
        this._colorizeState = false;
         /**
       * check if the treedoc has already filled by the a session manager
       * help to detect if column changed VS first rendering
       */
        this.isFilledByASessionManager = false;
        //bidirectional linking
        this._embeddedEngItem = embeddedEngItem;
        embeddedEngItem.attachContentModels(this);
        // bridge between the root and the content of tree document
        embeddedEngItem.getChildren =function(){
        	return that.getChildren();
        }

        this.enableEventListners();
      },
      getEngineeringItem: function(){
        return this._embeddedEngItem;
      },
      _getProvidersForOnlyVisibleAttributes: function(){
        return this._getProvidersByPolicy("visible");
      },
      _getProvidersForWholeContentAttributes: function(){
        return this._getProvidersByPolicy("whole");
      },
      getColumnsProvidersInstancesByPolicy: function(policy){
          return this.getColumnsProvidersDefinitionByPolicy(policy).map(function(provDef){
            return provDef.instance;
          });
      },
      getColumnsProvidersDefinitionByPolicy: function(policy){
        var _prov = null;
        switch (policy) {
          case "visible":
              _prov = this._getProvidersForOnlyVisibleAttributes();
            break;
          case  "whole":
              _prov = this._getProvidersForWholeContentAttributes();
          break;
          default:
              _prov = this.getColumnsProviders();
            break;
        }
        return _prov || [];
      },
      _getProvidersByPolicy: function(policy){
        return this.getColumnsProviders().filter(function(provDef){
          return provDef.loadingPolicy === policy;
        });
      },
      getColumnsProviders : function(){
        return Array.isArray(this.additionalColumnsProvidersDef) ? this.additionalColumnsProvidersDef : [];
      },
      isThereAProvider: function(){
        return this.getColumnsProviders().length >0;
      },
      getColumnsProvidersInstances: function(){
          return this.getColumnsProviders().map(function(provDef){
              return provDef.instance;
          });
      },
      setColumnsProviders: function(providersDef){
        if(!Array.isArray(providersDef)) return ;
        var validProvs = providersDef.filter(function(provDef){
          return provDef && provDef.ID && provDef.instance && provDef.loadingPolicy;
        });

        this.additionalColumnsProvidersDef = validProvs;
      },
      /**
       * add the providers if not exist
       * @param {*} providers
       */
      registerColumnsProviders: function(providersDef){
        if(!Array.isArray(providersDef)) return ;

        var validProvs = providersDef.filter(function(provDef){
          return provDef && provDef.ID && provDef.instance && provDef.loadingPolicy;
        });
        var that = this;
        validProvs.forEach(function(providerDef){
          var result = that.getColumnsProviders().find(function(provDef){
            return provDef.ID === providerDef.ID;
          });
          if(!result && providerDef){
            that.getColumnsProviders().push(providerDef);
          }
        });
      },
      unregisterColumnsProviders: function(ids){
        if(!Array.isArray(ids)) return ;
        ids.forEach(function(id){
          var idx = that.getColumnsProviders().findIndex(function(provDef){
            return provDef.ID === id;
          });
          if(idx>-1){
            that.getColumnsProviders().splice(idx,1);
          }
        });
      },
      freeXENContent: function(){
        this.removeRoots();
        this._contentFetchers = [];
        this._embeddedEngItem = undefined;
        var that = this;
        if(Array.isArray(this._modeleventsTokens))
          this._modeleventsTokens.forEach(function(token){
            that.core.mediator.unsubscribe(token);
          });

          if( that.getModelEvents())
           that.getModelEvents().unsubscribeAll();

        this.stopAllLoadingJobs();

        this.destroy();
      },
      enableEventListners: function(){
        this._modeleventsTokens = [];
        var that =this;
        // this._modeleventsTokens.push(
        //   that.core.mediator.subscribe(XEngineerConstants.EVENT_RELOAD_ENGINEERING_DEFINITION, function () {
        //     that.buildUserWorkingSession();
        //    })
        // );

        this._modeleventsTokens.push(
          that.core.mediator.subscribe(XEngineerConstants.EVENT_UPDATE_NODES_EFFECTIVITIES, function (options) {
            //effectivities provider is part of visible providers
            that.fillAttributesAsync4VisibleNodes(options.nodes, true, options.columns, "visible");
           })
        );


        this._modeleventsTokens.push(
          that.core.mediator.subscribe(XEngineerConstants.EVENT_UPDATE_NODES_WITH_CHANGESETS, function (_options) {
            that.withTransactionUpdate(function(){
              that.changeSetMerger(_options);
            });
           })
        );

      },
      _deleteNodesByCriteria: function(matcher){
        var me = this;
        this.withTransactionUpdate(function() {
        	me._getNoFakeNodes(me.getRoots()).filter(matcher).forEach(function(nodeToRemove){
    			nodeToRemove.remove();
            });

            me.reApplyUserCurrentViewOptions();

        });
      },
      getChildrenWithoutGroupingNodes: function(){
        return this._getNoFakeNodes(this.getRoots()||[]);
      },
      _getNoFakeNodes: function(roots){
    	  var me = this;
    	  if (roots.length > 0){
        	  if (roots[0] instanceof me.core.Factories.ListItemFactory.getListInstanceClass()){
        		  return roots;
        	  } else {
        		  var newRoots = [];
            	  roots.forEach(function(root){
            		  var children = root.getChildren();
            		  if (children != null)
            			  newRoots = newRoots.concat(children);

    	    	  });
            	  return me._getNoFakeNodes(newRoots);

    	      }
    	  } else
    		  return [];

      },
      //// TODO: to be rewrite
      _getReferenceInstances: function(refId){
        return   this.getRoots().filter(function(node){
          return (node.getID()===refId);
        });
      },

      retrieveNodesByIds: function(IDs){

    	  var me = this;
    	  var nodes = [];

    	  IDs.forEach(function(ID){
    		  var instanceNodes = me._getNoFakeNodes(me.getRoots()).filter(function(node){
             if(typeof ID === 'object'){
                return (node.getRelationID()=== ID["physicalid"]  || node.getID() === ID["physicalid"] );
             }else{
                return (node.getRelationID()=== ID || node.getID() === ID);
             }
            });
    		  nodes = nodes.concat(instanceNodes);
    	  });

    	  return nodes;
      },
      onApplyNGFilter: function(parameters){
        this.core.logger.info(" onApplyNGFilter updating user filterd view");
        var params = parameters || null;
        params = UWA.is(params, 'string') ? JSON.parse(params) : params;

        delete params.CVQuery3D;

        if(params.appId === this.core.settingManager.getAppId()){
          this._buildFilteredContent(params);
        }

      },

      getNodesByInstanceId: function(instIDs){

    	  var me = this;
    	  var nodes = [];

    	  instIDs.forEach(function(instID){
    		  var instanceNodes = me._getNoFakeNodes(me.getRoots()).filter(function(node){
                  return (node.getRelationID()===instID);
              });
    		  nodes = nodes.concat(instanceNodes);
    	  });

    	  return nodes;
      },

      _refreshNodes: function(RefIds){
        if (!Array.isArray(RefIds)) {
          return;
        }
        var ids = Utils.getArrayWithoutDuplicate(RefIds);
        if (ids.length === 0) {
          return;
        }
        var that = this;
        that.core.dataService.getEngItemsData(ids,true,false).then(function(refreshedItems) {
          that.prepareUpdate();
            for (var i = 0; i < refreshedItems.length; i++) {
              var refreshedItem = refreshedItems[i];

              that._getReferenceInstances(refreshedItem.getID()).forEach(function(impactedNode){
                impactedNode.refreshByModel(refreshedItem);
              });

            }
            that.pushUpdate();
            refreshedItems.forEach(function(node){
              node.destroy();
            });
           }).catch(function(error){
             console.error(error);
           });


      },
      hasConvertissibleColumns: function(){
        var that = this;
        return that.core.dataService.getParametricalAttributesOf("VPMReference")
                        .some(function(attr){
                          return (attr.preferredunit && attr.preferredunit.length>0);
                        });
      },
      getConvertissibleAttributes: function(){
        return this.core.dataService.getParametricalAttributesOf("VPMReference")
                        .filter(function(attr){
                          return (attr.preferredunit && attr.preferredunit.length>0);
                        });
      },
      /**
       * if no policy then all will be retrieve
       */
      getAdditionalColumns: function(policy){

        var result = [];
        this.getColumnsProvidersInstancesByPolicy(policy).forEach(function(provider){
          var cols = provider.getManagedColumnNames();
          cols = cols.map(function(dindex){
            return {
              dataIndex: dindex
            }
          });
          provider.getAdditionalColumnsUX(cols);

          result = result.concat(cols);

        });
        return result;
      },
      _bypassForConfigColumns: function(){
        var that = this;
        that.getColumnsProvidersInstances().forEach(function(provider){
          var input = {
            relids:[],
            pids:[that.getEngineeringItem().getID()]
          };
          provider.updateAttributes(input, function(response){
            console.warn(response);
          });
        });
      },
      _getCandidateForChunkLoading: function(nodes, TargetedProvpolicy, force){
        if(!Array.isArray(nodes)) return [];
        var that = this;
        var _columnsToCheck  = that.getAdditionalColumns(TargetedProvpolicy)
                                    .map(function(col){
                                            return col.dataIndex;
                                          });

        return nodes.filter(function(node){
          if(!node || !node.isEngineeringItem || !node.isEngineeringItem() ||
                  (node.isCoreMaterialGroupNode && node.isCoreMaterialGroupNode())) return false;

		  if(force) return true;


      if(that.hasConvertissibleColumns() && node.isAttributeConvertionStarted && !node.isAttributeConvertionStarted()) return true;

          for (var i = 0; i < _columnsToCheck.length; i++) {
            const attrName = _columnsToCheck[i];
            //only take not managed and not yet defined
            //!that._isNodeAttributeManagedByALoader(node, attrName) &&
            if(node.attributeRemoteLoadingNotStart(attrName)){
              return true;
            }
          }

          return false;
        });
      },

      _isNodeAttributeManagedByALoader: function(node, attrName){
          if(!node || !node.isAttributeLoadFailed || !node.isAttributePending || !attrName) return false;

          return (node.isAttributeLoadFailed(attrName) || node.isAttributePending(attrName));
      },
      prepareNodesForLoadAdditionalColumns: function(nodes, columns, force, TargetedProvpolicy){
        if(!Array.isArray(nodes)) return ;
        var that = this;
        var _columnsDataindex  = (columns && Array.isArray(columns) && columns.length>0) ? columns :
                                                                              that.getAdditionalColumns(TargetedProvpolicy).map(function(col){
                                                                                              return col.dataIndex;
                                                                                 });
        that.withTransactionUpdate(function(){
          nodes.forEach(function(node){
            var placeHolder = {};
            _columnsDataindex.forEach(function(dataIndex){
              if(force || node.getAttributeValue(dataIndex) === undefined)
                placeHolder[dataIndex] = '#queued#';
            });

            node.updateOptions({
              grid: placeHolder
            });
          });
        });




      },
      fillAttributesAsync4VisibleNodes: function(visiblesNodes, force, columnsToUpdate, TargetedProvpolicy){
        return this._prepareAndLaunchLoaderJob(visiblesNodes, this.loadVisibleColumnsByChunk.bind(this), columnsToUpdate, TargetedProvpolicy, force);
      },
      loadVisibleColumnsByChunk: function(visiblesNodes, jobId, TargetedProvpolicy){
        var chunkSize = this.core.settingManager.getSetting("effectivityChunkSize");
        return this._genericChunksLoader(visiblesNodes, jobId, chunkSize, TargetedProvpolicy);
      },
      isNotWaitingForAttributes: function(){
        return this._countOnGoingAttributesLoaders === 0;
      },
      asyncRetrieveMissingAttributes: function(nodes, columnsToUpdate){
        var that = this;
        var jobId = this._prepareAndLaunchLoaderJob(nodes, this.loadWholeContentColumnsByChunk.bind(this), columnsToUpdate, "whole");
        if(!jobId) return ;
        var jobInfo = that.getJobInfos(jobId);
        if(!jobInfo || !jobInfo.promise) return;

        that._countOnGoingAttributesLoaders ++;
        jobInfo.promise.finally(function(){
          that._countOnGoingAttributesLoaders --;
        });
        return jobId;
      },
      loadWholeContentColumnsByChunk: function(nodes,jobId, TargetedProvpolicy){
        var chunkSize = this.core.settingManager.getSetting("materialChunkSize");
        return this._genericChunksLoader(nodes, jobId, chunkSize, TargetedProvpolicy);
      },
      getJobInfos: function(jobId){
        if(!jobId || !this.chunkLoaders || !this.chunkLoaders[jobId]) return;
        return this.chunkLoaders[jobId];
      },
      stopAllLoadingJobs: function(){
        var that = this;
        if(that.chunkLoaders){
          that.cancelJobByIds( Object.getOwnPropertyNames(that.chunkLoaders));
        }
      },
      cancelJobByIds: function(ids){
        var that = this;
        if(that.chunkLoaders &&  Array.isArray(ids)){
          ids.forEach(function(id){
            var jobInfo = that.getJobInfos(id);
            if(jobInfo && jobInfo.promise){
              jobInfo.promise.cancelEmbeddedRequest();
            }
          });

        }
      },
      _prepareAndLaunchLoaderJob: function(nodes, jobProviderFunc, columnsToUpdate, TargetedProvpolicy, force){

        if(!this.isThereAProvider() || !Array.isArray(nodes) || nodes.length===0)
        return ;
        var that = this;
        nodes = that._getCandidateForChunkLoading(nodes, TargetedProvpolicy, force);
        if(nodes.length === 0) return ;

        var _columnsToUpdate = columnsToUpdate;
        if(!Array.isArray(columnsToUpdate)){
          _columnsToUpdate = [];
        }
        that.prepareNodesForLoadAdditionalColumns(nodes,_columnsToUpdate, force);

        if(!this.chunkLoaders){
          this.chunkLoaders = {};
        }
        var _loaderId = Utils.uid();
        this.chunkLoaders[_loaderId] ={};
        this.chunkLoaders[_loaderId].promise = jobProviderFunc.call(that, nodes,_loaderId, TargetedProvpolicy);
        /** return the jobId */
        return _loaderId;
      },
      _genericChunksLoader: function(nodes, jobId, _chunkSize, TargetedProvpolicy){
        var that = this;
        var chunkPromise = PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){
          var chunkSize = _chunkSize || that.core.settingManager.getSetting("defaultChunksize");
           var nbChunk = Math.ceil(nodes.length / chunkSize);
           var chunkArray = [];
            for(var i = 0;i<nbChunk;i++){
              chunkArray[i] = i;
            }
           that.chunkLoaders[jobId].remainingChunks = chunkArray;
           var initPromise =  PromiseUtils.wrappedWithCancellablePromise(function(resol, reje){
            resol();
           });

          var goblalPromise =  that.chunkLoaders[jobId].remainingChunks.reduce(function(prevChunk, currentSlice, idx){

              return PromiseUtils.wrappedWithCancellablePromise(function(resolveChunk, rejectChunk){
                        prevChunk.finally(function(result){
                              if(!that || !that.chunkLoaders || !that.chunkLoaders[jobId] ||that.chunkLoaders[jobId].shouldStop){
                               return  resolveChunk();
                              }
                              var pos = chunkSize*idx;
                              that.loadAChunk(nodes.slice(pos, pos+chunkSize), TargetedProvpolicy).then(function(){
                                resolveChunk();
                              }).catch(function(error){
                                rejectChunk(error);
                              });
                          });

               });


           },initPromise);

           goblalPromise.finally(function(){
             if( that && that.chunkLoaders)
                delete that.chunkLoaders[jobId];
            resolve();
           });


        });

        chunkPromise.xEngEmbeddedRequest = {
          cancel: function (params) {
            that.chunkLoaders[jobId].shouldStop = true;
          }
        };
        return chunkPromise;
      },
      filterAndUpdateColumnsState: function(nodes, TargetedProvpolicy){
        if(!Array.isArray(nodes)) return ;
        var that = this;

        var _columnsDataindex  = that.getAdditionalColumns(TargetedProvpolicy).map(function(col){
                                                                                              return col.dataIndex;
                                                                                         });
        var hasConvertissibleAttr = that.hasConvertissibleColumns();
        //remove node that all attributes are loading or Resolved(include all failed) OR
        //get queued or not resolved
        nodes = nodes.filter(function(node){

          if(hasConvertissibleAttr && !node.isAttributeConvertionStarted()) return true;

          for (var i = 0; i < _columnsDataindex.length; i++) {
            const col = _columnsDataindex[i];
            if(node.attributeRemoteLoadingNotStart(col)){
              return true;
            }
          }
          return !node.isRealAttributesConverted();

        });

        that.withTransactionUpdate(function(){
          nodes.forEach(function(node){
            var placeHolder = {};
            _columnsDataindex.forEach(function(dataIndex){
              if(node.attributeRemoteLoadingNotStart(dataIndex))
                placeHolder[dataIndex] = '#loading#';
            });

            if(hasConvertissibleAttr && !node.isAttributeConvertionStarted()) node.setAttributeConvertionStarted(true);
            node.updateOptions({
              grid: placeHolder
            });
          });
        });

        return nodes;

      },
      loadAChunk: function(chunkNodes, TargetedProvpolicy){
        var that = this;
        return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){

                function retrieveInfoForUpdate(node, result, additionalColumnsMod) {
                  var manageAttrLst = additionalColumnsMod.getManagedColumnNames();
                  var existingValue = {};
                  for (var iatt = 0; iatt < manageAttrLst.length; iatt++) {
                    var _column  = manageAttrLst[iatt];
                    var val = (node.isAttributePending(_column)) ? undefined : node.options.grid[_column];
                    existingValue[_column] = val;
                  }
                  if (additionalColumnsMod.toBeUpdated(existingValue) === true) {
                    if (result[additionalColumnsMod.getName()] === undefined) {
                      result[additionalColumnsMod.getName()] = {
                        pids: [],
                        relids: []
                      };
                    }

                    var pid = node.getID();
                    if (result[additionalColumnsMod.getName()].pids.indexOf(pid) === -1) {
                      result[additionalColumnsMod.getName()].pids.push(pid);
                    }

                    if (node.getRelationID) {
                      var rid = node.getRelationID();
                      if (rid && result[additionalColumnsMod.getName()].relids.indexOf(rid) === -1) {
                        result[additionalColumnsMod.getName()].relids.push(rid);
                      }
                    }
                  }
                }

                chunkNodes =  that.filterAndUpdateColumnsState(chunkNodes, TargetedProvpolicy);

                if(chunkNodes.length === 0){
                  return  resolve();
                }

                var promises =   that.getColumnsProvidersDefinitionByPolicy(TargetedProvpolicy).map(function(providerDef){
                    var input = {};
                    var provider = providerDef.instance;
                    chunkNodes.forEach(function(node){
                      if(providerDef.isTargetingOnlyInstance && (!node.getViewType  ||  node.getViewType() === "reference") ){
                        //do nothing
                        return ; // stop the current iteration and pick the next
                      }
                      retrieveInfoForUpdate(node, input, provider);


                    });

                    return  PromiseUtils.wrappedWithPromise(function(resolvePartial, rejectPartial){
                      var _setTimeoutToken = setTimeout(function(){
                        //set related attributes to failed
                        var _cols = provider.getManagedColumnNames();

                        that && that.withTransactionUpdate(function(){
                          chunkNodes.forEach(function(node){
                            var placeHolder = {};
                            _cols.forEach(function(dataIndex){
                              if(node.isAttributePending(dataIndex) || node.getAttributeValue(dataIndex) === undefined)
                                placeHolder[dataIndex] = '#failed#';
                            });

                            node.updateOptions({
                              grid: placeHolder
                            });
                          });
                        });
                        console.warn('timeout reached');
                        rejectPartial('timeout');
                      },60*1000);
                      provider.updateAttributes(input[provider.getName()], function(response) {
                        var parsed = UWA.is(response, 'string') ? JSON.parse(response) : response;
                        that._applyAttributesInListContent(parsed);// to update as soon as the result is ready
                        resolvePartial(parsed);
                        clearTimeout(_setTimeoutToken);
                      });
                    });

                });
                //applying columnsFormatter
                if(that.hasConvertissibleColumns()){
                  promises.push(PromiseUtils.wrappedWithPromise(function(resolveC, rejectC){
                      var input = [];
                      var nodesToConvert = chunkNodes.filter(function(node){
                          return !node.isRealAttributesConverted();
                      });

                      nodesToConvert.forEach(function(node){

                      that.getConvertissibleAttributes().forEach(function(attr){
                            var entry = {};
                            entry['value'] = node.getAttributeValue(attr.sixWTag);
                            entry['dimension']=attr.dimension;
                            entry['toUnit']= attr.preferredunit;
                            entry['sixw']= attr.sixWTag;
                            entry.pid = node.getID();
                            input.push(entry);
                          });
                    });
                      PreferredUnitColumnProvider.updateAttributes(input, function(response){
                        //update the state
                        nodesToConvert.forEach(function(node){
                          node.setRealAttributesConvertState(true);
                        });
                        that._applyAttributesInListContent(response);// to update as soon as the result is ready

                        resolveC();
                      });
                  }));
                }

                PromiseUtils.allSettled(promises).then(function(resultSet){
                if(Array.isArray(resultSet) && resultSet.length>0){

                }

                resolve();
                });

        });

      },
      _applyAttributesInListContent: function(result){
        if(!result) return ;
        var that = this;
        var changeSetObj = [];
        if(result.hasOwnProperty('relids') && result.hasOwnProperty('pids')){ //BYPASS for configuration columns provider issue, overwriting relid values
          delete result.pids;
        }

          if (result.hasOwnProperty('relids')){

              var ids = Object.getOwnPropertyNames(result.relids);
              var changeSetRel =  ids.map(function(id){
              var content = result.relids[id];
              var change = {
                  instanceId : id,
                  options: {
                    grid: {}
                  }
                };
                Object.getOwnPropertyNames(content).forEach(function(prop) {
                  change.options.grid[prop] = content[prop];
                });
                return change;
              });

              changeSetObj = changeSetObj.concat(changeSetRel);
          }


          if (result.hasOwnProperty('pids')){

              var ids = Object.getOwnPropertyNames(result.pids);
              var changeSetBus =  ids.map(function(id){
              var content = result.pids[id];
              var change = {
                  referenceId : id,
                  options: {
                    grid: {}
                  }
                };
                Object.getOwnPropertyNames(content).forEach(function(prop) {

                  change.options.grid[prop] = content[prop];
                });
                return change;
              });

              changeSetObj = changeSetObj.concat(changeSetBus);
          }



          that.changeSetMerger(changeSetObj);
      },
  /**
   * [{
   *  referenceId: or instanceId
   *  changesets: [{namespace:["options"], attName: "label" , value:{}}, {namespace:"", attName: "name" , value:{}}]
   * }]
   *
   */
      changeSetMerger: function(_options){
        if(!Array.isArray(_options)) return ;
        var that = this;
        that.prepareUpdate();
        _options.forEach(function(changeWrapper){
              if(changeWrapper.referenceId){
                that.retrieveNodesByIds([changeWrapper.referenceId])
                          .forEach(function(listNode){
                            listNode.updateOptions(changeWrapper.options);
                          });
              }else if(changeWrapper.instanceId){
                that.getNodesByInstanceId([changeWrapper.instanceId]).forEach(function(listNode){
                  listNode.updateOptions(changeWrapper.options);
                });
              }
        });
        that.pushUpdate();

      },
        onLoadGroupBy: function() {
          var that = this;
          var groupByPref = widget.getValue('groupBy');
          if(groupByPref){
            that.groupRoots({
              propertiesToGroup: [groupByPref]
            });
          }
        },
        onSorting: function(sortOptions) {
          var that = this;
          that.prepareUpdate();
          widget.setValue('sorting',sortOptions);
          var reverseFactor = (sortOptions.sortOrder || '').toLowerCase() === 'asc' ? 1 : -1;
          that._getTrueRoot().sortChildren({
                          isRecursive: true,
                          sortFunction: function(treeNodeModelA, treeNodeModelB) {
                                 return  reverseFactor*(treeNodeModelA.getSortableAttributeValue(sortOptions.sortAttribute) < treeNodeModelB.getSortableAttributeValue(sortOptions.sortAttribute) ? -1 : 1);
                             }
                      });
          that.pushUpdate();
        },
      reApplyUserCurrentViewOptions: function(){
        try {
          var that  = this;
          var sortOption = widget.getValue('sorting');
          if (sortOption) {
            that.onSorting(sortOption);
          }
          that.onLoadGroupBy();

        } catch (error) {
          console.error('something went wrong when re-applying user view options');

        }
      },
      refreshProvidedColumns: function(nodes,force){
        var that =this;
        that._effAllLoadJobIds.push(
          that.fillAttributesAsync4VisibleNodes(nodes,/* force*/ force, undefined /*columns to update*/, "visible" /* load only for visible nodes */)
        );
      },
      mainAddContent: function(nodes){
        if(!Array.isArray(nodes) || nodes.length===0) return ;
        var that = this;


        try { // not able to clearly  destroy datagridview , avoid launching notification for DGW issues
          that.addRoot(nodes);


          that._wholeContentLoaderJobIds.push(
            that.asyncRetrieveMissingAttributes(nodes)
            );
          that.reApplyUserCurrentViewOptions();

        } catch (error) {
          console.error(error);
        }
      },
      _contentUpdated: function(nodes){
        if(!Array.isArray(nodes)){
          console.error("_contentUpdated expect an array as input");
          return ;
        }
        var that = this;
        that.mainAddContent(nodes);
        that.core.mediator.publish('content-loader-indicator-progress',(90/that._contentFetchers.length));
        //notifiy content size change
        that.core.mediator.publish(XEngineerConstants.EVENT_NOTIFY_CONTENT_SIZE_CHANGE);
      },
      getAppropriateSessionBuilder: function(){
          var that = this;

          if(that.getEngineeringItem().hasValidTransientNextGenFilter() ||
              that.getEngineeringItem().hasValidPersistedNextGenFilter() ||
              that.getEngineeringItem().hasPreferredNGFilterId()
              ){
            return "nextGenFilter";
          }

          return "default";

      },
      retrievePreferreedNGFilter: function(){
        var that = this;
        return PromiseUtils.wrappedWithPromise(function(resolve, reject){
          var filter = that.getEngineeringItem().getPreferredNGFilter();
          if(!filter){
           return  reject(new Error('no filters found in preference'));
          }
          var _biFilter = that.getBIFilter();
          if(!_biFilter){
            return reject(new Error('no BIFilter infra to manage Filters'));
          }
          _biFilter.retrieveFilters({
            // filterIds:[filterId],
            filterObjects: [{
              envId: that.core.settingManager.getPlatformId(),
              serviceId :"3DSpace",
              contextId : "",
              objectId: filter.filterId,
              objectType: "ENOStrRefinementSpecification",
              displayName: filter.filterName
            }],
            // fromDropOnFilter: true,
            droppedEnvId: that.core.settingManager.getPlatformId(),
            doNotFillTheTagger: false,
            callback: function(data){

              if(data && Array.isArray(data.success)&& data.success.length>0){
                return resolve(data.success);
              }
              if(data && Array.isArray(data.errors)&& data.errors.length>0)
                return reject(new Error('unable to retrieve Filters'));
            }
          });

        });
      },
      _buildFilteredContent: function(_NGFilterOptions){
        if(!_NGFilterOptions ||!Array.isArray(_NGFilterOptions.filterRootIds)||
            _NGFilterOptions.filterRootIds.indexOf(this.getEngineeringItem().getID())<0)
          return null;

        if(_NGFilterOptions.empty){
            _NGFilterOptions = null;
            this.getEngineeringItem().detachPersistedFilter();
        }
        this.getEngineeringItem().setTransientNGFilteringContext(_NGFilterOptions);
        this.core.mediator.publish(XEngineerConstants.EVENT_UPDATE_IDCARD_RENDERING, false);
        this._contentFetchers = [];
        this._contentIsLoading = false;
        this.buildUserWorkingSession().then(function(options){
          console.log(options);
        }).catch(function(reason){
          //some issues went wrong during the session building
          console.error(reason);
          xEngAlertManager.errorAlert(app.core.i18nManager.get("eng.failed.to.open.EI"));
        });
        // this.getEngineeringItem().nextGenFilterMultiExpand(_NGFilterOptions);
      },
      buildUserWorkingSession: function(){
        var that = this;
        that.withTransactionUpdate(function(){
          that.ungroupRoots();
        });
        //to stop additional atributes loading from current content
        that.stopAllLoadingJobs();
        this.empty(); //launch the rebuild of datagridview
        if(Array.isArray(that._contentFetchers)){ //remove all pending requests
          that._contentFetchers.forEach(function(_onGoingRequest){
            _onGoingRequest.cancelEmbeddedRequest &&_onGoingRequest.cancelEmbeddedRequest();
          });
        }


        return PromiseUtils.wrappedWithPromise(function(resolve, reject){
           that.core.sessionManager.buildAppropriateSession(that)
                    .then(function(){
                      resolve(true);
                    }).catch(function(error){
                      reject(error);
                    });
        });
      },
      /**
       * check if the treedoc has already filled by the a session manager
       * help to detect if column changed VS first rendering
       */
      hasBeenHandledByASessionManager: function(){
        return this.isFilledByASessionManager;
      },
      fetchHolisticContentDefiniton: function(){
        var that = this;
        if(!Array.isArray(this._contentFetchers))
          throw new Error("invalid _contentFetchers ");

        PromiseUtils.allSettled(that._contentFetchers).then(function(options){
          that._contentFetchers = [];
          that._contentIsLoading = false;
          that.isFilledByASessionManager = true;
          that.pushToTagger();
          that.core.mediator.publish('content-loader-indicator-completed');
          //publish event for views
          that.core.logger.info('all HolisticContentDefiniton is loaded');
        });
      },
      registerContentFetcher: function(_promise, _label){
        if(!_promise || !_label)
          throw new Error("invalid input of registerContentFetcher");
        var that = this;
        that._contentFetchers.push(_promise);
        if(that._contentFetchers.length === 1){
          that._contentIsLoading = true;
          that.core.mediator.publish('content-loader-indicator-start');
        }

        _promise.then(function(nodes){
          that.core.logger.info(_label+' content fetched successfully ');
          that._contentUpdated(nodes);
        }).catch(function(reason){
          console.error(reason);
          that.core.mediator.publish('content-loader-indicator-progress',(90/that._contentFetchers.length));
          that.core.logger.error(reason);
          that.core.logger.error(_label);
          XEngAlertManager.errorAlert(that.core.i18nManager.replace(that.core.i18nManager.get("error.operation.failed"),{
              operation: 'content loading issue',
              error: JSON.stringify(reason)
          }));
        });
        return that;
      }
      
    });

    return EngItemContentTreeDocument;
});

/**
 * @module DS/ENOXEngineer/components/PropertiesView/PropertiesServices
 */
define('DS/ENOXEngineer/components/PropertiesView/PropertiesServices',
  [
    'UWA/Core',
    'UWA/Class',
    'DS/ENOXEngineer/services/EngineeringSettings',
    'DS/ENOXEngineer/utils/XEngineerConstants',
    'css!DS/ENOXEngineer/components/PropertiesView/ENOXProperties.css'
  ], function(UWA, Class,EngineeringSettings, XEngineerConstants) {

    'use strict';

     /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/components/PropertiesView/PropertiesServices
     * @param {Object} options options hash or a option/value pair.
     */
    var PropertiesServices = Class.singleton(
    /**
     * @lends module:DS/ENOXEngineer/components/PropertiesView/PropertiesServices
     */
    {

        init: function(options) {
          
        },
        getSecurityContext: function () {
            var security = EngineeringSettings.getSecurityContext();
            return {
              'SecurityContext': security
            }
        },

    /**
     * @return {object} - Returns the options for properties panel
     */
    getpropOptions: function (EditPropConstants) {
      var that = this;
      //FACET_EFFECTIVITY, FACET_CHANGE, FACET_VIEWS , FACET_INSTANCE "relations",
      var facets = [EditPropConstants.FACET_PROPERTIES,  EditPropConstants.FACET_INSTANCE , EditPropConstants.FACET_EFFECTIVITY, /*EditPropConstants.FACET_VIEWS, it overwriting the others commands */EditPropConstants.FACET_CHANGE];

      var propOptions = {
          'typeOfDisplay': EditPropConstants.ALL,//EditPropConstants.ONLY_EDIT_PROPERTIES,
          'selectionType': EditPropConstants.NO_SELECTION,
          'facets': facets,
          'readOnly': false,
          'extraNotif': true,
          'editMode': false,
          'context': {
              getSecurityContext : function (){
                  return that.getSecurityContext();
              }
          }
        }
      return propOptions;
    },
    // getPropModelFromSearchItem
    getPropModel : function (selectedItems, EditPropModel, EditPropAttributeModel) {
      var resultElementSelected = [];
      var that = this;
      var selection = null;

      // Construct selections in case of multiselection

      var selectionsJsonArray = [];
      var items = [];
      if((selectedItems.items) instanceof Array){
        items = selectedItems.items;
      } else{
        items[0] = selectedItems.items;
      }

      for(var i = 0; i < items.length; i++)
      {
        selectionsJsonArray.push({'metatype': items[i].metatype,
                                   'objectId': items[i].id,
                                   'tenant' : EngineeringSettings.getPlatformId(),
                                   'source':XEngineerConstants.SERVICE_3DSPACE_NAME});
      }

      selection = new EditPropModel(selectionsJsonArray);

      // on set le transient
      selection.set('isTransient', false);


      return selectionsJsonArray;
    }

    });

    return PropertiesServices;
});

define('DS/ENOXEngineer/components/PropertiesView/PropertiesPanel',
      [
        'DS/Utilities/Utils',
        'DS/EditPropWidget/EditPropWidget',
        'DS/EditPropWidget/constants/EditPropConstants',
        'DS/EditPropWidget/models/EditPropModel',
        'DS/EditPropWidget/models/EditPropAttributeModel',
        'DS/ENOXEngineer/components/PropertiesView/PropertiesServices',
        'DS/ENOXEngineer/utils/XEngineerConstants'
      ],
       function(WebUtils,EditPropWidget, EditPropConstants, EditPropModel, EditPropAttributeModel,PropertiesServices,XEngineerConstants) {

    'use strict';

    function PropertiesPanel(sandbox){
      this.sandbox = sandbox;
      var propOptions = PropertiesServices.getpropOptions(EditPropConstants);
      this._informationPanel = new EditPropWidget(propOptions);
      this._informationPanel.addFacets([{
        "require": 'DS/ENOXEngineer/facets/XENDocumentsFacet',
          "alwaysVisible": true,
          "services": [
            "3DSpace"
          ],
          "actions": [
            {
              "name": "createDocument",
              "text": this.sandbox.i18nManager.get("add_new_document"),
              "icon": "upload"
            },{
              "name": "attaachExistingDocument",
              "text": this.sandbox.i18nManager.get("cmd_add_Existing_Reference_Document"),
              "icon":"search-filter"
            }
          ],
          "inheritance": true,
          "content": null,
          "facet": {
            "name": "relateddocuments",
            "icon": "docs",
            "text": this.sandbox.i18nManager.get("title_related_Documents")
          },
          "options": {
            appContext: sandbox.core,
            "kindOfDocuments": [
              "DOCUMENT"
            ]
          }
      }]);
    }

    PropertiesPanel.prototype.start = function() {
      var that = this;
      this.setState(this.sandbox.options.items);
      this.currentId =this.sandbox.options.physicalId;
      this._informationPanel.initDatas(this.getPropertyModels());
      this._informationPanel.elements.container.inject(this.sandbox.getContainer());
      this.reRender = WebUtils.debounce(function(){
                    // this.updateAdditionalFacets(itemsArray);
                    this._informationPanel.initDatas(this.getPropertyModels());
                    this._informationPanel.elements.container.onResize();
      },10);


// FIXME: add stop method
      this.sandbox.subscribe(XEngineerConstants.EVENT_TRIPTYCH_PANEL_VISIBLE, function(side){
              that.reRender();
              if (side === "right") {
                setTimeout(function(){
                  that._informationPanel.elements.container.onResize();
                },500);
              }
      });

    };
    PropertiesPanel.prototype.getAdditionnalFacets = function(){
      var facets  = [

      ]
    }
    PropertiesPanel.prototype.updateAdditionalFacets= function(selectedNodes){
      // var facets = (this._informationPanel &&this._informationPanel.options) ? this._informationPanel.options.facets : [] ;
      if(selectedNodes.length >1){
        this._informationPanel.removeFacets(["relateddocuments"]);
        return ;
      }
      var node = (this.sandbox.core.contextManager.getXENTreeDocument() && this.sandbox.core.contextManager.getXENTreeDocument().getSelectedNodes())
      ? this.sandbox.core.contextManager.getXENTreeDocument().getSelectedNodes()[0] : null;
      if(node){
        if(!node.isEngineeringItem()){
          this._informationPanel.removeFacets(["relateddocuments"]);
        }else{
          // this._informationPanel.addFacets(["relateddocuments"]);
        }

      }


    }

    PropertiesPanel.prototype.setState = function(_selectedNodes){
      this._currentSelection = {
        items: (Array.isArray(_selectedNodes)) ? _selectedNodes :[]
      };
      if(this.sandbox.core.isPropertyPanelVisibilty){
        if(this.reRender)
            this.reRender();
      }

    };

    PropertiesPanel.prototype.getSate = function(){
      return this._currentSelection;
    };

    PropertiesPanel.prototype.getPropertyModels = function(){

      return  PropertiesServices.getPropModel(this.getSate(), EditPropModel, EditPropAttributeModel);
    };

    PropertiesPanel.prototype.resizePropertiesPanel = function(){
      this._informationPanel.onResize();
    };


    return PropertiesPanel;

});

/**
 * @author SBM2
 */
define('DS/ENOXEngineer/collections/XENContentProxyTreeDocument', [
  'DS/Tree/TreeDocument',
  'DS/ENOXEngineer/models/EngItemModel',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXEngineer/utils/Utils'
], function(
  TreeDocument,
  EngItemModel,
  XEngineerConstants,
  Utils
) {

  'use strict';
  var XENContentProxyTreeDocument  = TreeDocument.extend({
    defaultOptions: {
      nodeModelClass: EngItemModel
    },
    init: function(options){
      var that =this;
      var local_options = options || {}, that = this;
      this.core = local_options.core || {};
      delete local_options.core;
      this._parent(local_options);
      that._FilterBI =  that._FilterBI ? that._FilterBI : Utils.initFilterBIProxy({}, that.core.settingManager.getWidgetId());
      if(typeof that._FilterBI.setNGFilterOptions === "function"){
        var NGFilterOptions = {
          expandServices: 'expand',
          appID: that.core.settingManager.getAppId()
        };
        that._FilterBI.setNGFilterOptions(NGFilterOptions);
      }
    },
    getXENBIFilterProxy: function(){
      return this._FilterBI;
    },
    getSelectedNodes: function(context){
      if(!this.core) return [];

      if(this.core.sessionManager.isWorkingAnEngItem()){
        var selectedRoots = this._parent();
        if(!Array.isArray(selectedRoots) || selectedRoots.length===0) return [];

        if (context === "root" || context === "addToolBar")
        	return [selectedRoots[0]];

          var selectedNodes = (selectedRoots[0].getContentModels()) ? selectedRoots[0].getContentModels().getSelectedNodes() : [];
          return (selectedNodes.length >0) ? selectedNodes : [selectedRoots[0]];
      }else{ // from myEngineering items and recent openned
          var _activeDoc = this.core.contextManager.getActiveDocument();

          return (_activeDoc) ? _activeDoc.getSelectedNodes() : [];
      }

    },
    getNodesById: function (nodeId) {
      if(!this.core) return [];
      var treeDoc = null;

      if(this.core.sessionManager.isWorkingAnEngItem()){
          var root = this.getChildren()[0];
          if(root && root.getID() === nodeId) {
            return [root];
          }

          if(root) {
            treeDoc = root.getContentModels();
          }
      }else{
          treeDoc = this.core.contextManager.getActiveDocument();
      }

      return (treeDoc) ? treeDoc.getNodesById(nodeId) : [];
    },
    getNodesForCommands: function(context){

        if(!this.core) return [];



        if(this.core.sessionManager.isWorkingAnEngItem()){
          var selectedRoots = this._parent();
          if(!Array.isArray(selectedRoots) || selectedRoots.length===0) return [];

            var selectedNodes = (selectedRoots[0].getContentModels()) ? selectedRoots[0].getContentModels().getSelectedNodes() : [];
            return (selectedNodes.length >0 && ["root","addToolBar"].indexOf(context)!==-1) ? selectedNodes : [selectedRoots[0]];
        }else{ // from myEngineering items and recent openned
            var _activeDoc = this.core.contextManager.getActiveDocument();

            return (_activeDoc) ? _activeDoc.getSelectedNodes() : [];
        }

    }

  });

return XENContentProxyTreeDocument;


});

/**
 * @module DS/ENOXEngineer/services/XENCollectionsFactory
 */
define('DS/ENOXEngineer/services/XENCollectionsFactory', [
  'UWA/Core',
  'UWA/Class',
  'DS/ENOXEngineer/collections/XEngGridTreeDocument',
  'DS/ENOXEngineer/collections/EngItemContentTreeDocument',
  'DS/ENOXEngineer/collections/XENContentProxyTreeDocument'
], function(UWA, Class, XEngGridTreeDocument, EngItemContentTreeDocument,XENContentProxyTreeDocument) {

    'use strict';

     /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/services/XENCollectionsFactory
     * @param {Object} options options hash or a option/value pair.
     */
    var XENCollectionsFactory = Class.singleton(
    /**
     * @lends module:DS/ENOXEngineer/services/XENCollectionsFactory
     */
    {

        init: function(options) {
            this._parent(options);
        },
        initialize : function(xEngApp){
          this.app = xEngApp;
          if(!this.app.core.Factories ) this.app.core.Factories = {};
          this.app.core.logger.info("initializing XENCollectionsFactory ...");
          this.app.core.Factories.CollectionsFactory = this;
          this.i18nManager = this.app.core.i18nManager;

        },
        isInstanceContentModels: function(_models){
          return   (_models instanceof EngItemContentTreeDocument) ? true : false;
        },
        getEngItemContentModels: function(engitem, _options){
          if(!this.app.core.Factories.ListItemFactory.isInstanceOfEngItem(engitem)){
            console.warn(" getEngItemContentModels function expect a valid engineering item parameter");
            throw new Error(" getEngItemContentModels function expect a valid engineering item parameter");
          }
          var options = (_options) ? _options : {};
          options.core = this.app.core;
          options.enableNGFilter = true;
          return new EngItemContentTreeDocument(engitem, options);
        },
        getXENProxyContentTreeDocument: function(){
          var options = {
            core: this.app.core
          };
          return new XENContentProxyTreeDocument(options);
        }

    });

    return XENCollectionsFactory;
});

/**
 * @module DS/ENOXEngineer/componentsHelpers/FilterView/ENOXFilterView
 */
define('DS/ENOXEngineer/componentsHelpers/FilterView/ENOXFilterView', [
  'UWA/Core',
  'UWA/Class/View',
  'DS/UIKIT/Input/Toggle',
  'DS/ENOXEngineer/services/EngineeringSettings',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json',
  'css!DS/UIKIT/UIKIT.css'], function(Core, View, Toggle, EngineeringSettings, XEngineerConstants, ConfigFilterNLS) {

    'use strict';

    var ENOXFilterView = View.extend({
          isLicenseValid:false,
                toggle: [],
          init:function(options){

              this._parent(options);
              var that=this;

              that.isLicenseValid = true;
              that.render();
              return;

          },
          setup: function (options) {

          },
          render: function () {

            if(this.isLicenseValid == true){

              var toggleHolder = UWA.createElement('div', {});

              var labelContainer = UWA.createElement('div', {
                html : '<H5>'+ConfigFilterNLS.Evolution+':</H5>',
                'styles': {
                            'position' : 'relative',
                            'width': 'auto',
                            'display': 'inline-block'
                        }
              });
              labelContainer.inject(toggleHolder);

              var toggle0 = UWA.createElement('div',{'styles': {
                          'position' : 'relative',
                          'width': 'auto',
                          'display': 'inline-block',
                          'margin-left': '20px'
                      }
                    });
              toggle0.setStyles({'width': 'auto',display:'inline-block'});
              var toggle1 = UWA.createElement('div',{'styles': {
                          'position' : 'relative',
                          'width': 'auto',
                          'display': 'inline-block',
                          'margin-left': '10px'

                      }
                    });
              toggle1.setStyles({'width': 'auto'});
                        this.toggle[0] = new Toggle({
                checked: true,
                name: 'ViewOptions_xeng',
                id: 'ofcView_xeng',
                value: ConfigFilterNLS.Filter_official_view,
                className: 'primary'
                        }).inject(toggle0);
              this.toggle[1] = new Toggle({
                name: 'ViewOptions_xeng',
                id: 'prjView_xeng',
                value: ConfigFilterNLS.Filter_projected_view,
                className: 'primary'
                        }).inject(toggle1);
              toggle0.inject(toggleHolder);toggle1.inject(toggleHolder);
                        toggleHolder.inject(this.options.parentElement);
              if(this.options.viewJson != null)
                this.setSelectedView(this.options.viewJson.view);
            }

                },
          getJSON: function(){
            return {"view":this.getSelectedView()};
          },
                getSelectedView: function () {
                	
            if (!this.isLicenseValid)
              return XEngineerConstants.CONF_OFFICIAL_VIEW;
            if(this.toggle[0].isChecked())
              return XEngineerConstants.CONF_OFFICIAL_VIEW;
            else if(this.toggle[1].isChecked())
              return XEngineerConstants.CONF_PROJECTED_VIEW;

                },
          setSelectedView: function (view) {
            if(view == XEngineerConstants.CONF_OFFICIAL_VIEW )
              this.toggle[0].check();
            else if(view == XEngineerConstants.CONF_PROJECTED_VIEW )
              this.toggle[1].check();
                }
            });

    return ENOXFilterView;
});

define('DS/ENOXEngineer/commands/LaunchVersionGraphCmd', [
  'UWA/Core',
  'DS/UIKIT/Modal',
  'DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
  'DS/ENOXEngineer/commands/XEngineerCommandBase',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'DS/ENOXVersionExplorerUtils/VersionExplorerEnums',
  'DS/ENOXEngineer/componentsHelpers/FilterView/ENOXFilterView',
  'DS/ENOXVersionExplorerController/VersionExplorerController',
  'i18n!DS/ENOXEngineer/assets/nls/xEngineer.json'
], function(
  UWA,
  Modal,
  XEngineerModal,
  XEngCommandBase,
  Utils,
  XEngineerConstants,
  VEEnum,
  ENOXFilterView,
  VersionExplorerController,
  nlsKeys
) {

    'use strict';

    var LaunchVersionGraphCmd =  XEngCommandBase.extend({

      init: function(options){
        options = UWA.extend(options, {isAsynchronous : false});
        this._parent(options);
      },
      _buildModal : function(){
          var that = this;

          this.modal = new  XEngineerModal({
            title : this.options.appCore.i18nManager.get("manage_versions"),
            className : 'xeng-versionG-container',
            withFooter : false
          });

      },
      _configModelVersionMapper: function (modelFromVersionExplorer) {
          return {
            label: modelFromVersionExplorer.displayName,
            id: modelFromVersionExplorer.id,
            value: modelFromVersionExplorer.id,
            revision: modelFromVersionExplorer.revision,
            attributes: {MarketingName: modelFromVersionExplorer.displayName},
          }
        },

      execute : function(){
        var that = this;
        that.isCloseForOpen = false;
        this._buildModal();
        this.modal.show();
        var CMDcontainer = UWA.createElement('div', {
           html: '<div class="filter-view"></div>'+
           '<div class="version-graph"></div>',
           'styles': {
                       'height': '100%',
                       'position' : 'relative'
                   }
       }).inject(that.modal.getBody());
       var vGContainer = CMDcontainer.getElement(".version-graph");
       var filterContainer = CMDcontainer.getElement(".filter-view");
       var initialView = that.appCore.dataService.getUserEvolutionViewPref();
       var viewPanelOptions = {
         parentElement : filterContainer,
         viewJson : {
           view : initialView
         }
       };
       that.filterView = new ENOXFilterView(viewPanelOptions);

          that.versionExplorer = new VersionExplorerController({
            versionGraphContainer: vGContainer,
            widget: widget
          });
          var selectedNodes  = that.appCore.contextManager.getSelectedNodes();
          var engItem = selectedNodes[0];
          
          that.versionExplorer.setCheckVersionExternalFunction('ENOXVersionExplorerCreateNewRevision', function(treeNode){
              //Put your condition here. False implies the menu will not be shown.
        	  return engItem.isConfigured() ?  false :  true;
       });
          
          that.versionExplorer.setCheckVersionExternalFunction('ENOXVersionExplorerDeleteVersion', function(treeNode){
              //Put your condition here. False implies the menu will not be shown.
        	  return engItem.isConfigured() ?  false :  true;

       });
          
          that.versionExplorer.setCheckVersionExternalFunction('ENOXVersionExplorerShowMaturity', function(treeNode){
              //Put your condition here. False implies the menu will not be shown.
        	  return engItem.isConfigured() ?  false :  true;
       });
          
          that.versionExplorer.setCheckVersionExternalFunction('ENOXVersionExplorerNewRevisionFrom', function(treeNode){
              //Put your condition here. False implies the menu will not be shown.
        	  return engItem.isConfigured() ?  false :  true;
       });
          
          that.versionExplorer.setCheckVersionExternalFunction('ENOXVersionExplorerCreateNewBranch', function(treeNode){
              //Put your condition here. False implies the menu will not be shown.
        	  return engItem.isConfigured() ?  false :  true;
       });
          
          that.versionExplorer.setCheckVersionExternalFunction('ENOXVersionExplorerDuplicate', function(treeNode){
              //Put your condition here. False implies the menu will not be shown.
        	  return engItem.isConfigured() ?  false :  true;
       });

          that.versionExplorer.setCheckVersionExternalFunction('ENOXVersionExplorerOpenVersion', function(treeNode){
        	  return engItem.isEngineeringItem();
       });
          
          that.versionExplorer.publishEvent('ENOXVersionExplorerLoadVersionModel', {
            id: engItem.getIdForVersionGraph(),
            tenantId: that.appCore.settingManager.getPlatformId(),
            type: engItem.getTypeForVersionGraph(),
            securityContext: that.appCore.settingManager.getSecurityContext()
            //dataModelType:  engItem.isConfigured() ? VEEnum.DATA_MODEL_TYPES.MODEL_ER : VEEnum.DATA_MODEL_TYPES.MODEL_P
          });
          
          


          that.versionExplorer.subscribeEvent('ENOXVersionExplorerOpenVersion', function(itemVersion) {
            that.isCloseForOpen = true;
            that.modal.destroy();

            var treeNode = itemVersion.data || itemVersion;
            var phyid = treeNode.options.id;
            if( !engItem.isConfigured()){
            	
				var currentPhysicalID = that.appCore.contextManager.getActiveEngItem() ? that.appCore.contextManager.getActiveEngItem().getID() : null;
            	if (currentPhysicalID === phyid){
                that.appCore.mediator.publish(XEngineerConstants.EVENT_REFRESH_APP_CONTENT);
            	} else if (phyid) { //IR-642558-3DEXPERIENCER2018x in this case it will be a simple refresh
                   that.appCore.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND,{
                        commandId: XEngineerConstants.OPEN_ENG_ITEM,
                        context: {
                            item: {
                              objectId: phyid,
                              objectType: engItem.getType()
                            }
                          }
                      }); 
            	}

              that.appCore.mediator.publish(XEngineerConstants.EVENT_SHOW_PROPERTIES,[{
                  id : phyid,
                  metatype : 'businessobject'
                }]);
            } else {
            		var model = engItem.getPreferedAttachedConfigModel() || null;
                    if(model){
                      var previousVersion = model.getPreferredVersion();
                      if(previousVersion && previousVersion.id === phyid){
                        //no change then nothing
                      }else{
                        model.setPreferredVersion(phyid);
                        that.appCore.mediator.publish(XEngineerConstants.EVENT_CONF_MODEL_UPDATED, engItem.getID());
                      }
                      
                  
                    }
              
            }
          });
          
          that.versionExplorer.subscribeEvent('ENOXVersionExplorerNewVersionCreated', function(itemVersion) {
        	  that.appCore.sessionManager.setAuthoringMode('authoring');
        	  that.appCore.mediator.publish(XEngineerConstants.EVENT_NEW_VERSION_COMPLETED, itemVersion);

            });

          //this method is call before the open command
          that.modal.onClose(function(){
            that.end();
            var currentView = that.filterView.getSelectedView();
            (currentView !== initialView) && that.appCore.dataService.setUserEvolutionViewPref(currentView);

            if(!that.isCloseForOpen  && (currentView !== initialView) && engItem){
              that.appCore.mediator.publish(XEngineerConstants.EVENT_CONF_MODEL_UPDATED, engItem.getID());
            }
            var model = engItem.getPreferedAttachedConfigModel() || null;
            if(model){
                that.appCore.mediator.publish(XEngineerConstants.EVENT_VERSION_EXPLORER_CLOSED);
            }
            that.modal.destroy(),
            that.filterView.destroy();
            delete that.versionExplorer;
          }, this);

      }
      
      
    });

    return LaunchVersionGraphCmd;

});

define('DS/ENOXEngineer/controllers/XEngineerBootstrap',
      [
        'DS/ENOXEngineer/controllers/LandingPageController',
        'DS/ENOXEngineer/controllers/ItemViewController',
        'DS/ENOXEngineer/controllers/RecentsEngItemsController',
        'DS/ENOXEngineer/utils/XEngineerConstants',
        'DS/ENOXEngineerCommonUtils/XENMask',
        'DS/PlatformAPI/PlatformAPI',
        'DS/ENOXEngineer/columnsFormatter/PreferredUnitColumnProvider',
        'DS/AuthGenericCommands/AuthGenericCmdWSAccess'
      ],
      function(
        LandingPageController,
        ItemViewController,
        RecentsEngItemsController,
        XEngConstants,
        Mask,
        PlatformAPI,
        PreferredUnitColumnProvider,
        AuthGenericCmdWSAccess
      ) {

    'use strict';


    function XEngineerBootstrap(xEngApp){
      this.app = xEngApp;
      var routerState = widget.getValue('routerState') ? widget.getValue('routerState') : {};
      this._states = routerState.previousStates ? routerState.previousStates : [];

    }

    XEngineerBootstrap.prototype.initialize = function(){
      var that = this;
      //bootstrap components
      this.triptychCmp = null;
      this.editPropertyCmp = null;
      this.welcomePanelCmp = null;

      this.eventsBroker = this.app.mediator.getApplicationBroker();
      // initialize application root container

      widget.body.empty();
      Mask.unmask(widget.body);

      var container = document.createElement("div");
      container.classList.add("xeng-app-container");
      var immersiveFrame = this.app.core.moduleHelper.viewsService.getApplicationImmersiveFrame();
      //The container is added to the context to resolve Reserve and Unreserve problem
      //TODO ask Reserve Owner to provide the method
      this.app.core.contextManager.elements.container = document.body;
      immersiveFrame.setContentInBackgroundLayer(container);
      //immersiveFrame.getContent().appendChild(container);
      widget.body.appendChild(immersiveFrame.getContent());

      // application main presenter
      this.triptychCmp = this.app.componentsMgt.startNewInstance(XEngConstants.TRIPTYCH_CMP, container);

      this.welcomePanelCmp = this.app.componentsMgt.startNewInstance(XEngConstants.WELCOME_PANEL_CMP, this.triptychCmp.leftSideDiv);


      this.globalEventsManagement();


      // routes managers
      this.app.router.routerMethods = {};

      this.addRouteManager('myEngItems', new LandingPageController({
          app:this.app,
          parentController: this
      }));

      this.addRouteManager('engItem_View', new ItemViewController({
          app:this.app,
          parentController: this
      }));

      this.addRouteManager('recents_items', new RecentsEngItemsController({
          app:this.app,
          parentController: this
      }));

      this.app.routerUtils.listenToRouterStateChanges(this.app.router);
      const stateRegisterMiddleware = function(router){
        return function(toState, fromState){
          if (toState.name === 'recents_items') {
            that._states = [];
          }
          var previousSt = fromState ? fromState : {};
          that.pushNewRouterState(toState);
          return true;
        }
      }
      this.app.router.useMiddleware(stateRegisterMiddleware);
      this.app.core.viewState = {
        isChildView : function(){
          return that.isChildView();
        }
      };

    };

    XEngineerBootstrap.prototype.pushNewRouterState = function(state){
      var that = this, isDiferent = false;
      var previous = widget.getValue('routerState');
      if (previous && state.name === previous.current_State.name ) {
        for (var attr in state.params) {
          if (state.params.hasOwnProperty(attr) && state.params[attr] !== previous.current_State.params[attr]) {
            isDiferent = true;
            break;
          }
        }
        if(!isDiferent)
        return null;
      }
      this._states.push(state);
      widget.setValue('routerState',{
        current_State : state,
        previousStates : that._states
      });
    };
    XEngineerBootstrap.prototype.popPreviousState = function(){
      this._states.pop(); // to remove current state
      return this._states.pop(); //return undefined when array is empty
    }

    XEngineerBootstrap.prototype.isChildView = function(){
      var previousState = this._states.length < 2 ? null : this._states[this._states.length - 2];
      if (!previousState) {
        return false;
      }
      return previousState.name === 'engItem_View' ? true : false;
    }


    XEngineerBootstrap.prototype.globalEventsManagement = function(){
          var that = this;

          PreferredUnitColumnProvider.initialize({
            appCore: that.app.core
          });

          PlatformAPI.subscribe('DS/PADUtils/PADCommandProxy/refresh',function(option){
        	  if( option.data &&  option.data.authored &&  option.data.authored.deleted){
              that.app.sandboxBase.dataService.removedRecentEngItem(option.data.authored.deleted[0]);
              that.app.mediator.publish(XEngConstants.EVENT_DELETED_ENG_ITEM,{
                    ids : option.data.authored.deleted
                  });
            }

        	  console.log(option);
          });

          PlatformAPI.subscribe(XEngConstants.EVENT_REMOVE_CUT_INSTANCES, function(instances) {
            if(Array.isArray(instances)) {
              var context = that.app.core.contextManager.getContext();
              context.refresh({
                action: "unparent",
                instances: instances
              });
            }
          });

          //put the set partnumber completed event in the right channel
          PlatformAPI.subscribe("XEN/PUBLIC_EVENT/ENGINEERING_ITEM/PART_NUMBER_UPDATED", function(data){
            if(that.app.mediator){
              that.app.mediator.publish(XEngConstants.EVENT_SET_PARTNUMBER_COMPLETED, data);
            }
          });

          var token4 = that.app.mediator.subscribe(XEngConstants.EVENT_TRIPTYCH_PANEL_VISIBLE, function(side) {
              if (side === "right") {
                  that.app.core.isPropertyPanelVisibilty = true;
                  if (!that.editPropertyCmp){
                    that.app.mediator.publish(XEngConstants.EVENT_SHOW_PROPERTIES, []);
                  }
              }
          });

          var token3 = that.app.mediator.subscribe(XEngConstants.EVENT_TRIPTYCH_PANEL_HIDDEN, function(side) {
              if (side === "right") {
                  that.app.core.isPropertyPanelVisibilty = false;
              }
          });

          var token = that.app.mediator.subscribe(XEngConstants.EVENT_SHOW_PROPERTIES, function(itemsArray) {
              if (!that.editPropertyCmp) {
                  that.app.componentsMgt.startInstances([{
                      name: XEngConstants.PROPERTY_CMP,
                      container: that.triptychCmp.rightDiv,
                      contextData: {
                        items : itemsArray
                      }
                  }]).then(function(instances) {
                      that.editPropertyCmp = instances[0];
                  });

              } else {
                  that.editPropertyCmp.setState(itemsArray);
              }

          });

          var token2 = that.app.mediator.subscribe(XEngConstants.EVENT_WELCOME_PANEL_ACTION_SELECTED, function(action) {
              if (action.id === XEngConstants.WP_ADD_ENG_ITEM_ACTION) {
            	  that.app.mediator.publish(XEngConstants.EVENT_RESET_SELECTION);
                  that.app.mediator.publish(XEngConstants.EVENT_LAUNCH_COMMAND,{
                    commandId: XEngConstants.CREATE_NEW_ENG_ITEM
                  });


              } else if (action.id === XEngConstants.WP_MY_ENG_ITEMS_ACTION) {
                  that.app.router.navigate('myEngItems',{},{replace: false,reload: false});
              } else if (action.id === XEngConstants.WP_RECENTS_ITEMS_ACTION) {
                  that.app.router.navigate('recents_items',{},{replace: false,reload: false});
              }else if (action.id === XEngConstants.WP_IMPORT_ENG_ITEM_ACTION) {
            	  that.app.mediator.publish(XEngConstants.EVENT_RESET_SELECTION);
                  that.app.mediator.publish(XEngConstants.EVENT_LAUNCH_COMMAND,{
                    commandId: XEngConstants.IMPORT_ITEMS_CMD
                  });
              }else if (action.id === XEngConstants.WP_OPEN_ENG_ITEM_ACTION) {
            	  that.app.mediator.publish(XEngConstants.EVENT_RESET_SELECTION);
                  that.app.mediator.publish(XEngConstants.EVENT_LAUNCH_COMMAND,{
                    commandId: XEngConstants.OPEN_ENG_ITEM,
                    context: {
                        item: {
                          searchForOpen: true
                        }
                      }
                  });
              } else if(action.id === XEngConstants.WP_ADD_NEW_PART_ACTION) {
                that.app.mediator.publish(XEngConstants.EVENT_RESET_SELECTION);
                that.app.mediator.publish(XEngConstants.EVENT_LAUNCH_COMMAND,{
                  commandId: XEngConstants.CREATE_NEW_PART,
                });
              }
          });

          that.createdItemsToken = that.app.mediator.subscribe(XEngConstants.EVENT_NEW_ENG_ITEM_CREATED, function(createdItem) {
            that.app.mediator.publish(XEngConstants.EVENT_LAUNCH_COMMAND,{
              commandId: XEngConstants.OPEN_ENG_ITEM,
              context: {
                  item: {
                    objectId: createdItem.physicalid,
                    objectType: createdItem.type
                  }
                }
            });
          });
          that.goBackToken = that.app.mediator.subscribe(XEngConstants.EVENT_GO_BACK, function() {
              var targetState = that.popPreviousState();
              if (targetState) {
                that.app.router.navigate(targetState.name,targetState.params,{replace: false,reload: true});
              } else {
                that.app.router.navigate('recents_items',{},{replace: false,reload: true});
              }
            });

          that.deletedItemsToken = that.app.mediator.subscribe(XEngConstants.EVENT_DELETED_ENG_ITEM, function(deletedItem) {
        	  var state = that.app.router.getState() || {};
        	  if (state.name === "engItem_View" && deletedItem.ids.indexOf(state.params.pid) > -1){
        		  that.app.mediator.publish(XEngConstants.EVENT_GO_BACK);
        	  }
          });

          that.refreshToken  = that.app.mediator.subscribe(XEngConstants.EVENT_REFRESH_APP_CONTENT, function() {
           var state = that.app.router.getState();
           state = state ? state : {};

            console.log('refreshing the view');
           var currentRouteManager = that.getRouteManager(state.name);
           currentRouteManager = currentRouteManager ? currentRouteManager : {};
           //restarting the route manager
           currentRouteManager._isRefreshing = true;
           currentRouteManager.deactivate();
           currentRouteManager.activate(state);
           delete currentRouteManager._isRefreshing;

         });

          that.resizeTriptychToken = that.app.mediator.subscribe(XEngConstants.EVENT_TRIPTYCH_RESIZE, function (data) {

        	  var state = that.app.router.getState() || {};
        	  if (state.name !== "engItem_View"){
                  if (data < 550) {
                	  that.app.mediator.publish(XEngConstants.EVENT_TRIPTYCH_HIDE_PANEL, 'left');
                  }
                  else {
                	  that.app.mediator.publish(XEngConstants.EVENT_TRIPTYCH_SHOW_PANEL, 'left');
                  }
        	  }

          });


    }; // end of globalEventManagement function


    XEngineerBootstrap.prototype.getRouteManager = function(routeName){
      return this.app.router.routerMethods[routeName];
    }

    XEngineerBootstrap.prototype.addRouteManager = function(routeName, routeManager){

      if (this.app.router.routerMethods[routeName]) {
        throw new Error("route manager is already defined");
      }

      if (routeName.indexOf(' ') >= 0 ) {
        throw new Error("route name shouldn't contain spaces");
      }

      if (!routeManager) {
        throw new Error("route manager is mandatory");
      }

      if (typeof routeManager.activate !=='function' || typeof routeManager.deactivate !=='function') {
        throw new Error("all mandatory methods are not define on this route "+routeName);
      }

      this.app.router.routerMethods[routeName] = routeManager;
    };


    return XEngineerBootstrap;

});

/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : UX xEngineer
 *
 * @author SBM2

 ██      ██  ████████  ██      ██  ████████████
   ██  ██    ██        ██ █    ██  ██
     ██      ████████  ██   █  ██  ██    ██████
   ██  ██    ██        ██    █ ██  ██        ██
 ██      ██  ████████  ██      ██  ████████████

 */
define('DS/ENOXEngineer/ENOXEngineer', [
    'WebappsUtils/WebappsUtils',
    'DS/ENOXEngineerCommonUtils/XENMask',
    'DS/ENOXEngineerInfra/ENOXEngineerCore',
    'DS/ENOXEngineer/controllers/XEngineerBootstrap',
    'DS/ENOXEngineer/routerConfig/RouterConfig',
    'DS/LifecycleServices/LifecycleServicesSettings',
    'DS/ENOXEngineer/utils/XEngineerConstants',
    'DS/PlatformAPI/PlatformAPI',
    'DS/ENOXEngineer/services/XEngLocalStorage',
    'DS/ENOXEngineer/services/PreferencesManager',
    'DS/ENOXEngineerExternalLibs/ENOXEngineerProfills',
    'css!DS/ENOXEngineer/styles/ENOXEngineerApp.css',
  ],
  function (
    WebappsUtils,
    XENMask,
    xEngineerApp,
    XEngineerBootstrap,
    routerConfig,
    LifecycleServicesSettings,
    XEngConstants,
    PlatformAPI,
    LocalStorage,
    PreferencesManager
  ) {
    'use strict';
//\\dell423dsy\HOME\Jenkins\home_https\userContent\vsix vscode integration

    var xEngineerWidget = {
      onLoad: function () {

        widget.body.empty();
        XENMask.mask(widget.body);

        xEngineerApp({
            debug: (widget.getValue('debug_me') === '1'),
            eagerComponentsLoading: true,
            extensionsFolder: 'DS/ENOXEngineer/services/',
            componentsRepository: "DS/ENOXEngineer/assets/config/componentsDef.json"
          })
          .use('EngineeringSettings')
          .use('EngineeringDataProvider')
          .use('I18nManager')
          .use('PreferencesManager')
          .use('ViewsService') //should be initialize be for session manager
          .use('XENUserSessionManager')
          .use('XENCollectionsFactory')
          .use('XEngContextManager')
          .use('CommandsService')
          .use('XEngineerItemsFactory')
          .use('ConfigItemsFactory')
          .use('ExportService')
          .useRouter5({
            config: routerConfig,
            applicationController: XEngineerBootstrap
          })
          .start().then(function (app) {
            widget.appMediator = app.mediator;
            app.logger.info('#### xEngineer started in ' + app.getStartupTime() + 'ms !');

            app.core.settingManager.isSetValidSelectionForOpen(widget.getValue('X3DContentId'))
              .then(function (selectedEngItem) {
                if (selectedEngItem && selectedEngItem.objectId && selectedEngItem.objectId.trim().length > 0) {
                  var newState = app.router.buildState("engItem_View", {
                    pid: selectedEngItem.objectId
                  });
                  app.router.start(app.router.buildPath(newState.name, newState.params));
                }

              }).catch(function (reason) {
                app.logger.info(reason);
                var routerState = widget.getValue('routerState') ? widget.getValue('routerState') : {};
                // initialize title
                app.mediator.publish(XEngConstants.EVENT_LAUNCH_COMMAND, {
                  commandId: XEngConstants.UPDATE_WIDGET_TITLE,
                  context: {
                    label: null
                  }
                });
                if (routerState.current_State) {
                  if (routerState.current_State.name === "engItem_View")
                    app.core.isReloadedState = true;
                  app.router.start(routerState.current_State);
                } else {
                  app.router.start('recents_items', {
                    replace: false
                  });
                }
              });
            PlatformAPI.subscribe(XEngConstants.EVENT_REFRESH_WIDGETS, function (data) {
              widget.appMediator.publish(XEngConstants.EVENT_REFRESH_APP_CONTENT);
            });
            PlatformAPI.subscribe(XEngConstants.EVENT_CLEAR_WIDGETS_CLIPBOARD, function (data) {
              LocalStorage.removeItem('clipboard');
            });
          });

          },
      onStop: function () {

      },
      onRefresh: function () {
        widget.appMediator.publish(XEngConstants.EVENT_REFRESH_APP_CONTENT);
        PlatformAPI.publish(XEngConstants.EVENT_CLEAR_WIDGETS_CLIPBOARD);
      },
      endEdit: function () {
        PreferencesManager.catchUserPreference();

      }

    };

    return xEngineerWidget;
  });


/**
 * @module DS/ENOXEngineer/componentsHelpers/CollectionView/XENRelatedDocumentList
 */
define('DS/ENOXEngineer/componentsHelpers/CollectionView/XENRelatedDocumentList', [
    'UWA/Core',
    'UWA/Controls/Abstract',
    'DS/WebappsUtils/WebappsUtils',
    'DS/Tree/TreeDocument',
    'DS/CollectionView/ResponsiveLargeTilesCollectionView',
    'DS/ENOXEngineerCommonUtils/XENMask',
    'DS/ENOXEngineer/utils/XEngineerConstants',
    'DS/ENOXEngineerCommonUtils/PromiseUtils',
    'DS/Utilities/Dom',
    'DS/ENOXEngineer/utils/Utils',
    'DS/ENOXEngineerCommonUtils/xEngAlertManager',
], function(
    UWA,
    Abstract,
    WebappsUtils,
    TreeDocument,
    ResponsiveLargeTilesCollectionView,
    XENMask,
    XEngineerConstants,
    PromiseUtils,
    DomUtils,
    Utils,
    xEngAlertManager) {

    'use strict';

    var DOC_ICONS = {
        CHECKIN: 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'icons/32/I_CheckInDocument.png') + ')',
        CHECKOUT: 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'icons/32/I_CheckOutDocument.png') + ')',
        DOWNLOAD: 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'icons/32/I_DownloadDocument.png') + ')',
        DETACH: 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'icons/32/I_DetachDocument.png') + ')',
        DELETE: 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'icons/32/I_Delete.png') + ')'
    };

    var default_type_icon = WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'img/document.png');
    /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/componentsHelpers/CollectionView/XENRelatedDocumentList
     * @augments module:UWA/Controls/Abstract
     * @param {Object} options options hash or a option/value pair.
     */
    var XENRelatedDocumentList = Abstract.extend(
     /**
     * @lends module:DS/ENOXEngineer/componentsHelpers/CollectionView/XENRelatedDocumentList.prototype
     */
    {

        defaultOptions: {

        },
        _relatedDocsUX: {},
        _accordion: null,
        _informationBox: null,
        _informationContainerBox: null,
        _fileInput: null,
        _dndCounter: 0,
        init: function(options) {
            var that =this;
            this._parent(options);
            this.relName = options.relName;
            this.appCore = options.appCore;

            this.elements.container = UWA.createElement('div', {
                'class': 'documentslist_container'
            });
            this.appCore.mediator.subscribe(XEngineerConstants.EVENT_NEW_ATTACHED_DOCUMENT, function(payload){
                if(payload.parentId === that.physicalid)
                    that._relatedDocsUX.DOCUMENT.update(payload.nodes);
            });

            this._buildSkeleton();

            this._informationContainerBox = UWA.createElement('div', {
                'class': 'container_information'
            });
            this._informationBox = UWA.createElement('div', {
                'class': 'documentslist_information'
            }).inject(this._informationContainerBox);
            UWA.createElement('span', {
                'class': 'documentslist_information_icon wux-ui-3ds wux-ui-3ds-5x wux-ui-3ds-docs'
            }).inject(this._informationBox);
            this._messageInformationBox = UWA.createElement('h2', {
                'class': 'caddocumentslist_information_msg'
            }).inject(this._informationBox);
            this._informationContainerBox.hide();
            this._informationContainerBox.inject(this.elements.container);

            var that = this;
            this.elements.container.addEventListener('dragenter', this._dragEnterDocument.bind(this));
            this.elements.container.addEventListener('dragleave', this._dragLeaveDocument.bind(this));
            this.elements.container.addEventListener('dragover', this._dragOverDocument.bind(this));
            this.elements.container.addEventListener('drop', this._dropDocument.bind(this));

        },
        notApplicable: function(){
            var that= this;
            var iconHolder = this._informationBox.getElement('.documentslist_information_icon');
            if(iconHolder && iconHolder.hasClassName('wux-ui-3ds-docs')){
                iconHolder.removeClassName('wux-ui-3ds-docs');
                iconHolder.addClassName('wux-ui-3ds-block')
            }
            
            that._emptyModels();
            this.physicalid = null;
            this._displayInformationBox('notSupported');
            this._switchContainer('information');
                return;
        },
        selectionModified: function(selectedNode) {
            if(!selectedNode){
                this._switchContainer('information');
                return;
            }
            if(this.physicalid === selectedNode.getID())
                return ;
            var that =this;
            that._emptyModels();
            that.masterNode = selectedNode;
            that.physicalid = selectedNode.getID();
            that.parentType = selectedNode.getType();
            XENMask.mask(this.elements.container);
            var promises = [];
            that.appCore.dataService.getEngItemRelatedDocuments(that.physicalid, that.relName)
                                    .then(that._relatedDocsUX.DOCUMENT.update)
                                    .catch(function(error){
                                        console.error(error);
                                        that._switchContainer('information');
                                        XENMask.unmask(that.elements.container);
                                    });


        },
        _emptyModels: function(inputSections) {
            var sections = inputSections ? inputSections : Object.getOwnPropertyNames(this._relatedDocsUX);
            for (var idx = 0; idx < sections.length; idx++) {
                if (this._relatedDocsUX[sections[idx]].model) {
                    this._relatedDocsUX[sections[idx]].model.empty();
                }
            }

        },

        _displayInformationBox: function(messagetype) {
            if (messagetype === 'createDocument') {

                this._messageInformationBox.setText(this.appCore.i18nManager.get('documentsCreateDocument'));
                this._applyDefaultIcon();
            } else if (messagetype ==='notSupported'){
                this._messageInformationBox.setText(this.appCore.i18nManager.get('notSupportedSelection'));
            }else{
                this._messageInformationBox.setText(this.appCore.i18nManager.get('nodocuments'));
                this._applyDefaultIcon();
            }
            this._switchContainer('information');
        },
        _applyDefaultIcon: function(){
            var iconHolder = this._informationBox.getElement('.documentslist_information_icon');
            if(iconHolder && iconHolder.hasClassName('wux-ui-3ds-block')){
                iconHolder.removeClassName('wux-ui-3ds-block');
                iconHolder.addClassName('wux-ui-3ds-docs')
            }
        },
        _switchContainer: function(forceContainer) {
            var activeContainer = forceContainer ? forceContainer : this._activeContainer;
            switch (activeContainer) {
                case 'information':
                    this._informationContainerBox.show();
                    this._activeContainer = 'information';
                    break;
                case 'doccontent':
                    this._informationContainerBox.hide();
                    this._activeContainer = 'doccontent';
                    break;
            }
        },

        _buildSkeleton: function(){
            var that =this;

            var optsModelDocument = {
                shouldAcceptDrag: function(node, cellInfos) {
                    return true;
                },
                shouldAcceptDrop: function(node, cellInfos) {
                    if (that.options.readOnly !== true) {
                        return true;
                    } else {
                        return false;
                    }
                }
            };

            var documentModel = new TreeDocument(optsModelDocument);
            var documentGridView = new ResponsiveLargeTilesCollectionView({
                useDragAndDrop: true,
                displayedOptionalCellProperties: ['contextualMenu','description', 'activeFlag'],
                onDragStartCell: that._dragStartTile.bind(that)

            });
            documentGridView._onPostRequestCellCB = function(cellInfos){
                //if big image
                cellInfos.cellView.contentView.elements.picture.setStyle('background-size', 'contain');
                //else
                //cellInfos.cellView.contentView.elements.picture.setStyle('background-size', 'auto');

            };

            documentGridView.model = documentModel;
            documentGridView.onContextualEvent = {
                'this': this,
                'callback': this._onContextualEventDocument
            };

            var classNameDocItem = 'padAccordionItemView docItemView onlyDocument';
            var docItemView = UWA.createElement('div', {
                'class': classNameDocItem
            });
            documentGridView.getContent().inject(docItemView);
            this._relatedDocsUX.DOCUMENT = {
                model: documentModel,
                view: docItemView,
                isInjected: false,
                update: function(docNodes) {
                    XENMask.unmask(that.elements.container);
                    if(!Array.isArray(docNodes) || docNodes.length===0){
                        that._displayInformationBox('nodocuments');
                    }else{
                        that._relatedDocsUX.DOCUMENT.model.addRoot(docNodes);
                        that._relatedDocsUX.DOCUMENT.view.inject(that.elements.container);
                        that._switchContainer('doccontent');
                    }

                }
            };

        },
        createDocument: function(parameters) {
            var that = this;
            //since 3DShape is not supported for now, we give user alert,
            //not even bother to call web service
            if (parameters.parentType &&( parameters.parentType === '3DShape' || parameters.parentType === 'Document')) {
                xEngAlertManager.errorAlert(this.appCore.i18nManager.get('unableCreateDocument3DShape'));
                return false;
            }

            if (parameters.fromDrop) {
                that.appCore.dataService.addNewDocumentToEngItem({
                    targetObjID: parameters.parentId,
                    relationName: that.relName,
                    files: parameters.files
                });
            } else {
                that.appCore.dataService.addNewDocumentToEngItem({
                    targetObjID: parameters.parentId,
                    relationName: that.relName
                });
            }
        },
        addExistingDocument: function(parameters) {
            var that =this;
            that.appCore.dataService.searchManager.launchASearch({
            	title: that.appCore.i18nManager.get("eng.searchResult.InsertDocument"),
            	allowedTypes:['Document'],
                role : '',
                criteria : '',
                multiSel : true,
                in_apps_callback : function(selectedNodes){
                    that.onSelectedFromSearch(selectedNodes, parameters.engItem);
                }
              });

        },
        onSelectedFromSearch: function(selectedObjs, targetNode){
            if(!Array.isArray(selectedObjs)) return ;
            var that = this;
            var promises = [];
            XENMask.mask(that.elements.container, this.appCore.i18nManager.get('attaching.document'));
            promises = selectedObjs.map(function(doc){
                return that.appCore.dataService.attachDocumentToEngItem(targetNode, doc.id, false, that.relName);
            });

            PromiseUtils.allSettled(promises).then(function(params) {
                that._updateDocumentView();
                XENMask.unmask(that.elements.container);
            });

        },
        _onContextualEventDocument: function(params) {
            var that = this;
            var menu = [];
            var model = params.cellInfos ? (params.cellInfos.nodeModel ? params.cellInfos.nodeModel : params.cellInfos.cellModel) : null;
            if (model) {
                model.select();
                var isMonoSelect = model.getTreeDocument().getSelectedNodes().length > 1 ? false : true;
                // if (isMonoSelect && this.options.readOnly !== true) {
                //     menu.push({
                //         title: model.options.checkedOut ? 'checkInDocument' : 'checkOutDocument',
                //         icon: model.options.checkedOut ? DOC_ICONS.CHECKIN : DOC_ICONS.CHECKIN,
                //         type: 'PushItem',
                //         action: {
                //             'this': that,
                //             context: model,
                //             callback:  this._checkInOutDocument.bind(this)
                //         }
                //     });
                // }
                menu.push({
                    title: this.appCore.i18nManager.get('download'),
                    icon: DOC_ICONS.DOWNLOAD,
                    type: 'PushItem',
                    action: {
                        'this': that,
                        context: model,
                        callback:  this._downloadDocument.bind(this)
                    }
                });
                if (this.options.readOnly !== true) {
                    menu.push({
                        title: this.appCore.i18nManager.get('detachDocument'),
                        icon: DOC_ICONS.DETACH,
                        type: 'PushItem',
                        action: {
                            'this': that,
                            context: model,
                            callback: this._detachDocument.bind(this)
                        }
                    });
                    menu.push({
                        title: this.appCore.i18nManager.get('DeleteDocument'),
                        icon: DOC_ICONS.DELETE,
                        type: 'PushItem',
                        action: {
                            'this': that,
                            context: model,
                            callback: this._deleteDocument.bind(this)
                        }
                    });
                }
            }
            return menu;
        },
        _deleteDocument: function(options){
            var model = options.context;
            var that =this;
            var selectedNodes = model.getTreeDocument().getSelectedNodes();
            var promises = [];
            XENMask.mask(that.elements.container,this.appCore.i18nManager.get('deleting.documents'));
            promises = selectedNodes.map(function(doc){
                 return PromiseUtils.wrappedWithPromise(function(resolve, reject){
                    that.appCore.dataService.deleteDocument(doc,function(status){
                        resolve(true);
                        if(status)
                            model.getTreeDocument().removeRoot(doc);
                    });
                });
            });

            PromiseUtils.allSettled(promises).then(function(params) {
                XENMask.unmask(that.elements.container);
            });
        },
        _detachDocument: function(options){
            var model = options.context;
            var that =this;
            var selectedNodes = model.getTreeDocument().getSelectedNodes();
            var promises = [];
            XENMask.mask(that.elements.container, this.appCore.i18nManager.get('detaching.documents'));
            promises = selectedNodes.map(function(doc){
                return PromiseUtils.wrappedWithPromise(function(resolve, reject){
                    that.appCore.dataService.removeDocument(doc,{
                        getID: function(){
                            return that.physicalid;
                        }
                    } , that.relName,function(status){
                        resolve(true);
                        if(status)
                            model.getTreeDocument().removeRoot(doc);
                    });
                });
            });

            PromiseUtils.allSettled(promises).then(function(params) {
                XENMask.unmask(that.elements.container);
            });
        },
        _downloadDocument:function(options){
            var model = options.context;
            var that =this;
            var promises = [];
            var selectedNodes = model.getTreeDocument().getSelectedNodes();
            XENMask.mask(that.elements.container, this.appCore.i18nManager.get('downloadDocumentMask'));

            PromiseUtils.wrappedWithPromise(function(resolve, reject){
            	that.appCore.dataService.downloadDocuments(selectedNodes, resolve, reject);
            }).finally(function(params) {
                XENMask.unmask(that.elements.container);
            });

        },
       /* _checkInOutDocument: function(options){
            var model = options.context;
            var that =this;

            if (model.options.checkedOut === true) {
                XENMask.mask(that.elements.container, this.appCore.i18nManager.get('checkinDocumentMask'));
                that.appCore.dataService.checkinDocument({
                    docId: model.getID(),
                    onComplete: function(){
                        that._updateDocumentView();
                    },
                    onFailure: function(err) {
                        xEngAlertManager.errorAlert(that.appCore.i18nManager.get('createDocumentFailed'));
                        XENMask.unmask(that.elements.container);
                    }
                })
            } else {
                XENMask.mask(that.elements.container,that.appCore.i18nManager.get('checkoutDocumentMask') );

                that.appCore.dataService.checkoutDocument(model,
                    function(){
                        that._relatedDocsUX.DOCUMENT.model.withTransactionUpdate(function() {
                            model.updateOptions({
                                checkedOut: true
                            });
                            // that._relatedDocsUX.DOCUMENT.update();
                        });
                        XENMask.unmask(that.elements.container);
                }, function(){
                    xEngAlertManager.errorAlert(that.appCore.i18nManager.get('downloadServiceFailure') );
                    Mask.unmask(that.elements.container);
                } );
            }

        },*/
        _updateDocumentView: function(parameters) {
            var that = this;
            // var fromDrop = parameters.fromDrop;
            // Refresh the view
            that._relatedDocsUX.DOCUMENT.model.empty();

            that.appCore.dataService.getEngItemRelatedDocuments(that.physicalid, that.relName)
                                    .then(that._relatedDocsUX.DOCUMENT.update)
                                    .catch(function(error){
                                        console.error(error);
                                        that._switchContainer('information');
                                        if (that._isNoRelatedDocsAvailable()) {
                                            that._displayInformationBox('nodocuments');
                                        }
                                        XENMask.unmask(that.elements.container);
                                    });

        },
        _isNoRelatedDocsAvailable: function() {
            var noRelDoc = true;
            var sections = Object.getOwnPropertyNames(this._relatedDocsUX);
            for (var idx = 0; idx < sections.length && noRelDoc === true; idx++) {
                if (this._relatedDocsUX[sections[idx]].model && this._relatedDocsUX[sections[idx]].model.getRoots().length > 0) {
                    return false;
                }
            }
            return noRelDoc;
        },
        onResize: function() {
            console.log('onResize');

        },
        _dragStartTile: function(e, dropInfos) {
            var draggedNode = dropInfos.nodeModel;
            var treeDocument = draggedNode.getTreeDocument();
            if(treeDocument)

            var json_drag_external = Utils.prepareDragData(treeDocument.getXSO().get().slice(0));
            e.dataTransfer.setData('Text', json_drag_external);
            e.stopPropagation();
            return false;
        },
        _dropDocument: function(e, dropInfos) {
            e.preventDefault();
            e.stopPropagation();
            if (this.parentType && this.parentType === '3DShape') {

                return false;
            }

            var that = this;
            this._dndCounter = 0;
            that._informationContainerBox.removeClassName('drag-over');
            var types = e.dataTransfer.types;
            var localFunc = UWA.is(e.dataTransfer.types.indexOf, 'function') ? 'indexOf' : 'contains';
            var exists = types[localFunc]('Files');
            if ((UWA.is(exists, 'number') && exists >= 0) || (UWA.is(exists, 'boolean') && exists === true)) {
                that.createDocument({
                    parentId: that.physicalid,
                    files: e.dataTransfer.files,
                    fromDrop: true
                });
            } else {
                var droppedData = JSON.parse(e.dataTransfer.getData('text'));
                if (that._isNoRelatedDocsAvailable()) {
                    that._displayInformationBox('nodocuments');
                } else {
                    that._switchContainer('doccontent');
                }
                var nodes = that.appCore.contextManager.getXENTreeDocument().getSelectedNodes();
                that.appCore.settingManager.retrieveAllValidDocumentsFromDrop(droppedData)
                        .then(function(valids){
                            if(Array.isArray(valids) && valids.length>0){

                                XENMask.mask(that.elements.container, that.appCore.i18nManager.get('attaching.document'));
                                var promises = valids.map(function(doc){
                                    return that.appCore.dataService.attachDocumentToEngItem(nodes[0], doc.objectId, false, that.relName);
                                });

                                PromiseUtils.allSettled(promises).then(function(params) {
                                    that._updateDocumentView();
                                    XENMask.unmask(that.elements.container);
                                });
                            }
                        });
            }
            return false;
        },
        _dragOverDocument: function(e, dropInfos) {
            e.preventDefault();
            e.stopPropagation();
            return false;
        },
        _dragEnterDocument: function(e, dropInfos) {
            if (DomUtils.firstParentWithClass('documentslist_container')) {
                if (this._dndCounter === 0) {
                    this._informationContainerBox.addClassName('drag-over');
                    this._displayInformationBox('createDocument');
                }
                this._dndCounter++;
            }
            e.preventDefault();
            e.stopPropagation();
            return false;
        },
        _dragLeaveDocument: function(e, dropInfos) {
            if (DomUtils.firstParentWithClass('documentslist_container')) {
                this._dndCounter--;
                if (this._dndCounter === 0) {
                    this._informationContainerBox.removeClassName('drag-over');
                    if (this._isNoRelatedDocsAvailable()) {
                        this._displayInformationBox('nodocuments');
                    } else {
                        this._switchContainer('doccontent');
                    }
                }
            }
            e.preventDefault();
            e.stopPropagation();
            return false;
        }

    });

    return XENRelatedDocumentList;
});

/**
 * @module DS/ENOXEngineer/facets/XENDocumentsFacet
 */
define('DS/ENOXEngineer/facets/XENDocumentsFacet', [
    'UWA/Core', 
    'UWA/Class',
    'UWA/Controls/Abstract',
    'DS/EditPropWidget/facets/Common/FacetsBase',
    'DS/ENOXEngineer/componentsHelpers/CollectionView/XENRelatedDocumentList'
], function(UWA, Class, Abstract,FacetsBase, XENRelatedDocumentList) {

    'use strict';

   /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/facets/XENDocumentsFacet
     * @param {Object} options options hash or a option/value pair.
     */
     var XENDocumentsFacet = Class.extend(Abstract,FacetsBase,
        /**
         * @lends module:DS/ENOXEngineer/facets/XENDocumentsFacet.prototype
         */
        {

        init: function(options) {
            this._parent(options);
            this._buildView(options);
        },
        _buildView: function(options){
            if (!this._relatedDocList) {
                this.elements.container = UWA.createElement('div', {
                    'class': 'relatedDocuments'
                });
                this._relatedDocList = new XENRelatedDocumentList({
                    readOnly: this.options.readOnly,
                    relName: 'Reference Document',
                    appCore: this.options.appContext
                });
                this.appCore = this.options.appContext;
                
                this._relatedDocList.elements.container.inject(this.elements.container);
            }
        },
        updateFacet: function(){
            var firstModel = this.getModel();
            if (firstModel) {
                var nodes = this.appCore.contextManager.getXENTreeDocument().getSelectedNodes();
                if (nodes.length !== 1) {
                    console.error('Wrong number of selected object ' + nodes.length);
                    this._relatedDocList.notApplicable();
                } else {
                   if(!nodes[0].isEngineeringItem()){
                        this._relatedDocList.notApplicable();
                    }else {
                        this._relatedDocList.selectionModified(nodes[0]);
                    }
                }
            } else {
                this._relatedDocList.selectionModified();
            }
            
        },
        destroyComponent: function() {
            console.warn("destroyComponent called");
            
        },
        onResize: function(){
            console.warn("onResize");
        },
        onRefresh: function() {
            this.updateFacet();
        },
        onAction: function(actionId){
            
            if(!this.appCore || !this.appCore.contextManager || !this.appCore.contextManager.getXENTreeDocument()) 
                return ;

            var model = this.getModel();
            var nodes = this.appCore.contextManager.getXENTreeDocument().getSelectedNodes();
            if (model && Array.isArray(nodes)) {
                var node = nodes[0];

                if(actionId ==="createDocument"){
                    this._relatedDocList.createDocument({
                        parentId: node.getID(),
                        parentType: node.getType()
                    });
                }else{
                    this._relatedDocList.addExistingDocument({
                        parentId: node.getID(),
                        parentType: node.getType(),
                        engItem: node
                    })
                }
                
            }
        },
        isActionAvailable: function(actionId){
            if(!this.appCore || !this.appCore.contextManager || !this.appCore.contextManager.getXENTreeDocument()) 
                return false;
            var selectedNodes = this.appCore.contextManager.getXENTreeDocument().getSelectedNodes();
            if(!Array.isArray(selectedNodes) || selectedNodes.length!==1)
                return false;
          
           return selectedNodes[0].isEngineeringItem();
        }
    });

    return XENDocumentsFacet;
});

/**
 * @author SBM2
 */
define('DS/ENOXEngineer/models/ConfigContextModel', [
  'DS/Tree/TreeNodeModel',
  'UWA/Core',
  'DS/ENOXEngineerCommonUtils/PromiseUtils',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/ResponseParser',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'DS/ENOXEngineer/utils/XEngineerConstants'
], function(
  TreeNodeModel,
  Core,
  PromiseUtils,
  Utils,
  ResponseParser,
  xEngAlertManager,
  XEngineerConstants
) {

  'use strict';

  function ConfigContextModel(options){
      this._parentNode = {
        _nodeDepth : 1
      },
      this.pathElement = {
        externalPath : []
      },

      this.options = {
        type : '',
        physicalid : '',
        thumbnail : '',
        "ds6w:created": '',
        "ds6w:modified" : '',
        "ds6w:description" : '',
        "ds6w:responsible" : '',
        "ds6wg:revision" : '',
        "ds6w:status"  : '',
        "ds6w:label" : '',
        modelVersion : null,
        preferedVersion : null,
        relatedEngItem : null,
        preferredConfiguration : null,
        versionPCs: null
      };
      this.options = Core.extend(this.options, options);
      TreeNodeModel.call(this, this.options);
  }

  ConfigContextModel.prototype = Object.create(TreeNodeModel.prototype);
  ConfigContextModel.prototype.destroy = function(){
    // this.options.attributes.splice(0,this.options.attributes.length);
    // this.options  = undefined;
  };

  ConfigContextModel.prototype.setModelVersion = function(version){
    this.options.modelVersion = version;
  };

  ConfigContextModel.prototype.setRelatedEngItem  = function(engItem){
    this.options.relatedEngItem = engItem;
  };

  ConfigContextModel.prototype.getRelatedEngItem  = function(){
    return this.options.relatedEngItem;
  };

  ConfigContextModel.prototype.catchUserPreferences = function(){
    var that = this;
    var pref = {
      modelId: that.getID(),
      modelVersionId: that.getPreferredVersion() ? that.getPreferredVersion().id : 'N/A',
      prodConfId: that.getPreferredConfiguration() ? that.getPreferredConfiguration().id  : 'N/A'
    };
    return pref;
  }



  ConfigContextModel.prototype.getModelVersion = function(){
      return this.options.modelVersion;
  };

  ConfigContextModel.prototype.getCurrentVersionName = function(){
    return this.getPreferredVersion() ? this.getPreferredVersion().name : null;
  };

  ConfigContextModel.prototype.getCurrentVersionMarketingName = function(){
	    return this.getPreferredVersion() ? this.getPreferredVersion().marketingName : null;
	  };
	  
	ConfigContextModel.prototype.getMarketingName = function(){
		    return this.getModelVersion() ? this.getModelVersion().attributes.MarketingName : null;
		    };


  ConfigContextModel.prototype.getCurrentVersionID = function(){
    return this.getPreferredVersion() ? this.getPreferredVersion().id : null;
  };
  ConfigContextModel.prototype.getCurrentVersionRevision = function(){
    return this.getPreferredVersion() ? this.getPreferredVersion().revision : null;
  };

  ConfigContextModel.prototype.getCurrentVersionDisplayName = function(){
    return this.getCurrentVersionName() +' '+ this.getCurrentVersionRevision();
  };

  ConfigContextModel.prototype.getCurrentVersionDisplayMarketingName = function(){
	    return this.getCurrentVersionMarketingName() +' '+ this.getCurrentVersionRevision();
	  };

  ConfigContextModel.prototype.setVersionProdConfs = function(ProdConfs){
    this.options.versionPCs = ProdConfs;
  };

  ConfigContextModel.prototype.getVersionProdConfs = function(){
    return this.options.versionPCs;
  };

  ConfigContextModel.prototype.getProdConfById = function(pid){
    var prodConfs = this.getVersionProdConfs() ? this.getVersionProdConfs() : [];
    console.warn(prodConfs);
    for (var i = 0; i < prodConfs.length; i++) {
      if(prodConfs[i].id === pid)
        return prodConfs[i];
    }
    return null;
  };
  ConfigContextModel.prototype.getPreferredConfiguration = function(){
    return this.options.preferredConfiguration;
  };

    ConfigContextModel.prototype.setPreferredConfiguration = function (prodConfId) {
      var that = this;
      return PromiseUtils.wrappedWithPromise(function (resolve, reject) {
        that.loadProdConfInfos().then(function () {
          that.options.preferredConfiguration = prodConfId ? that.getProdConfById(prodConfId) : null;
          resolve();
        }).catch(function(reason){
          console.error(reason);
          reject(reason);
        });
      });
    };


  ConfigContextModel.prototype.getPreferredVersion = function(){
    return this.options.preferedVersion;
  };

  ConfigContextModel.prototype.setPreferredVersion = function(versionId){
    var that = this;

    var selectedVersion = Utils.getVersionByIdFromVersionGraph(that.getModelVersion(), versionId ) || that.getModelVersion();

    if(selectedVersion &&  Object.keys(selectedVersion).length > 0){
      this.options.preferedVersion = {
        id : ResponseParser._getPidWithoutPrefix(selectedVersion.id),
        revision : selectedVersion.revision,
        name : selectedVersion.name,
        marketingName : selectedVersion.attributes.MarketingName
      };
      that.options.preferredConfiguration = null;
      //launch the reload of related ProdConf
      that.loadProdConfInfos(true);
    }else{
      xEngAlertManager.errorAlert(that.options.appCore.i18nManager.get("error.selectedVersion.notFound"));
      
    }

  };

  ConfigContextModel.prototype.getListOfVersionsPromise= function(){
    var that = this;
    return PromiseUtils.wrappedWithPromise(function(resolve, reject){
      that.loadVersions().then( function(rootVersion){
                            if(rootVersion){
                              resolve(
                                that.options.appCore.Factories.configItemsFactory.createModelVersionsFromRootVersion(rootVersion, that.getID())
                              );
                            }else{
                              resolve([]);
                            }

                          }).catch(function(error){
                            resolve([]);
                            console.error(error)
                          });
    });
  };
  ConfigContextModel.prototype.loadVersions = function(){
    var that = this;
    return PromiseUtils.wrappedWithPromise(function(resolve, reject){
      that.options.appCore.dataService.getModelVersionsFromModel(that.getID())
                          .then( function(rootVersion){
                            if(!rootVersion.id || !rootVersion.revision){
                              that.setModelVersion(null);
                              resolve(null)
                            }else{
                            that.setModelVersion(rootVersion);
                            resolve(rootVersion);
                            }

                          }).catch(function(error){
                            that.setModelVersion(null);
                            reject(error);
                            console.error(error)
                          });
    });
  };

  ConfigContextModel.prototype.VersionsLoaderWrapper = function(){
    var that = this;
    return PromiseUtils.wrappedWithPromise(function(resolve, reject){
        if(that.getModelVersion()){ //little cache
          return resolve(that.getModelVersion());
        }
        that.loadVersions().then(resolve).catch(reject);
    });
  };

  ConfigContextModel.prototype._synchronizeModelVersions = function(selectedModelVersion){
	    var pid = this.getID() , that = this;
	    if(!pid) return null;
	    return PromiseUtils.wrappedWithPromise(function(resolve, reject){
	      that.VersionsLoaderWrapper()
	                .then(function(){
                    var modelversion = that.getModelVersion();
	                  if(!modelversion){
	                    reject();
	                    xEngAlertManager.errorAlert(that.options.appCore.i18nManager.get("error.noVersion.relatedToModel"));
	                    return;
	                  }
	                  var confPref = that.options.appCore.PreferencesManager.getEngItemOpenPreferences(that.getRelatedEngItem().getID());
	                  var prefVersionId = confPref && confPref.modelVersion ? confPref.modelVersion : null;
	                  var prodConfId = confPref &&  confPref.prodConf ? confPref.prodConf : null;
                    var versionId = (selectedModelVersion && selectedModelVersion.id) ? selectedModelVersion.id : prefVersionId;
                    
                    if(!versionId){ // when no preference and no specified version we use the main
                      versionId = modelversion.id;
                    }
                    that.setPreferredVersion(versionId);

	                  //load version's product configurations
	                  that.loadProdConfInfos()
	                    .finally(function(){
	                      that.setPreferredConfiguration(prodConfId);
	                      resolve(modelversion);
	                    });

	                }).catch(function(reason){
                    console.error(reason);
                    reject();
	                });

	    });
	  };


  ConfigContextModel.prototype.loadProdConfInfos = function(force) {
    var that = this;

    if (that.options.prodConfPromise && !force)
      return that.options.prodConfPromise;

    that.options.prodConfPromise = PromiseUtils.wrappedWithPromise(function(resolve, reject) {
      that.options.appCore.dataService.loadModelVersionProdConf(that.getID(), that.getCurrentVersionID())
        .then(function(res) {
          that.setVersionProdConfs(ResponseParser.retrieveProdConfsInfo(res));
          resolve(true);
        }).catch(function(reason) {
          console.warn(reason);
          reject(reason);
        });
    });

    return that.options.prodConfPromise;

  };

  ConfigContextModel.prototype.getType = function(){
    return this.options.type;
  };
  ConfigContextModel.prototype.getID = function(){
    return this.options.physicalid;
  };

  ConfigContextModel.prototype.getLabel = function(){
    return this.options["ds6w:label"];
  };

  ConfigContextModel.prototype.getVersion = function(){
    return this.options["ds6wg:revision"];
  };

  ConfigContextModel.prototype.getThumbnail = function(){
    return this.options.thumbnail;
  };

  ConfigContextModel.prototype.getOwner = function(){
    return this.options["ds6w:responsible"];
  };

  ConfigContextModel.prototype.getCreatedDate = function(){
    return this.options["ds6w:created"];
  };

  ConfigContextModel.prototype.getModifedDate = function(){
    return this.options["ds6w:modified"];
  };

  ConfigContextModel.prototype.getMaturity = function(){
    return this.options["ds6w:status"];
  };

  ConfigContextModel.prototype.getDescription = function(){
    return this.options["ds6w:description"];
  };

  ConfigContextModel.prototype.getIcon = function(){
    return this.options.icons && this.options.icons[0];
  };

  ConfigContextModel.prototype.getTenant = function(){
    return this.options.tenant; //to be fix in factory
  };

    ConfigContextModel.prototype.buildFilterXML = function () {

      var that = this;


      var volatileFilterCommand = that.options.appCore.settingManager.getCommand('createVolatileFilter');
      var contextXml = volatileFilterCommand.contentFormat;
      var mode = XEngineerConstants.CONF_150_MODE;


      var modelVersionFilterXml = volatileFilterCommand.ModelVersionFormat;
      modelVersionFilterXml = modelVersionFilterXml.replace("{modelName}", UWA.String.escapeHTML(this.getLabel()));
      modelVersionFilterXml = modelVersionFilterXml.replace("{modelVersionName}", UWA.String.escapeHTML(this.getCurrentVersionName()));
      modelVersionFilterXml = modelVersionFilterXml.replace("{modelVersionRevision}", UWA.String.escapeHTML(this.getCurrentVersionRevision()));

      contextXml = contextXml.replace("{filter}", modelVersionFilterXml);

      //IR-599692-3DEXPERIENCER2018x
      contextXml = contextXml.replace("{mode}", mode);
      contextXml = contextXml.replace("{SelectionView}", UWA.String.escapeHTML(that.options.appCore.dataService.getUserEvolutionViewPref()));


      return contextXml;
    };



return ConfigContextModel;


});

/**
 * @module DS/ENOXEngineer/services/ConfigItemsFactory
 */
define('DS/ENOXEngineer/services/ConfigItemsFactory', [
  'UWA/Core',
  'UWA/Class',
  'UWA/Class/Promise',
  'DS/ENOXEngineer/utils/Utils',
  'DS/ENOXEngineer/utils/ResponseParser',
  'DS/ENOXEngineer/models/ConfigContextModel',
  'DS/Tree/TreeNodeModel',
  'DS/ENOXEngineer/utils/XEngineerConstants',
  'WebappsUtils/WebappsUtils'
], function(UWA, Class, Promise, Utils, ResponseParser,ConfigContextModel, TreeNodeModel, XEngineerConstants, WebappsUtils) {

    'use strict';

     /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/services/ConfigItemsFactory
     * @param {Object} options options hash or a option/value pair.
     */
    var ConfigItemsFactory = Class.singleton(
    /**
     * @lends module:DS/ENOXEngineer/services/ConfigItemsFactory
     */
    {

        init: function(options) {
            this._parent(options);
        },
        initialize : function(xEngApp){
          this.app = xEngApp;
          if(!this.app.core.Factories ) this.app.core.Factories = {};
          this.app.core.Factories.configItemsFactory = this;
          this.i18nManager = this.app.core.i18nManager;

        },
        createModelVersionsFromRootVersion: function(rootVersion, modelId){
          if(!rootVersion) return [];
          var result= [], that =this;
          ResponseParser.getListOfVersionsFromRoot(rootVersion, result); //filling the result array
          
          return result.map(function(options){
            options["modelId"] = modelId;
            if(!options["thumbnail"])
              options["thumbnail"] = that.app.core.settingManager.getDefault3DSpaceUrl()+'/snresources/images/icons/large/I_Product_Thumbnail.png';
            return new TreeNodeModel(options);
          });

        },
        getModelsFromConfigInfo : function(serverResponse){
          var parsedModel = ResponseParser.configInfoParser(serverResponse);

          return this.createConfigModelNodes(parsedModel);
        },
        getModelVersionsFromModelInfo : function(serverResponse){
          var ModelVersions = ResponseParser.modelVersionsParser(serverResponse);
          return ModelVersions;
        },
        createConfigModelNode : function(model, attributesResolver){
          var options = model;
          if(UWA.is(attributesResolver , "function")){
            options = attributesResolver(model);
          }

          options.appCore = this.app.core;
          options["thumbnail"] = this.app.core.settingManager.getDefault3DSpaceUrl()+'/snresources/images/icons/large/I_Product_Thumbnail.png';


        return new   ConfigContextModel(options);
        },
        createConfigModelNodes : function(models, attributesResolver){
          var result = [];
          var that = this;
          models.forEach(function(model){
            var obj = that.createConfigModelNode(model, attributesResolver);
            if(UWA.is(obj))
            result.push(obj);
          });

          return result;
        }


    });

    return ConfigItemsFactory;
});

define('DS/ENOXEngineer/componentsHelpers/mixins/ListToolbarBuilder', [
'DS/ENOXCollectionToolBar/js/ENOXCollectionToolBar',
'i18n!DS/ENOXCollectionToolBar/assets/nls/ENOXCollectionToolBar',
'DS/ENOXEngineer/componentsHelpers/CollectionView/ENOXResponsiveSetView'
], function(
  ENOXCollectionToolBar,
  nls_ENOXCollectionToolBar,
  ENOXResponsiveSetView
) {

  'use strict';


  function ListToolbarBuilder(options) {
    this.buildDefaultOptionsSkeleton();
    if(!options || !options.modelEvents){
      throw new Error('modelEvents is a mandatory parameter');
    }
    this.options.modelEvents = options.modelEvents;
    this.parentSandbox = options.sandbox;
  //  this.dataset = options.data;
    this.releatedView = options.ListView;

    if(!options || !options.container){
      throw new Error('container is a mandatory parameter');
    }
    this.toolbarContainer = this.createActionBarWrapper();
    this.toolbarContainer.inject(options.container, 'top');

  }

  ListToolbarBuilder.prototype.getActions = function(){
    return this.options.actions;
  };
  ListToolbarBuilder.prototype.getSorts = function(){
    return this.options.sort;
  };

  ListToolbarBuilder.prototype.addAction = function(options){
    if(!options || !options.id || !options.text || !(options.handler instanceof Function))
      throw new Error('invalid action definition for addAction');

    this.getActions().push({
      id : options.id,
      text : options.text,
      handler: options.handler,
      fonticon : options.fonticon
    });
    return this;
  };

  ListToolbarBuilder.prototype.addActions = function(actions){
    if(!Array.isArray(actions))
      throw new Error('invalid input for addActions ');

    var that =this;
    actions.forEach(function(action){
      that.addAction(action);
    });
    return this;
  };
  ListToolbarBuilder.prototype.setDefaultView = function(viewId){
    if(!viewId)
      throw new Error('invalid viewId');
    this.options.currentView = viewId;
    return this;
  };

  ListToolbarBuilder.prototype.addSort = function(options){
    if(!options || !options.id || !options.text || !options.type)
      throw new Error('invalid sort definition for addSort');
    this.getSorts().push({
      id: options.id,
      text: options.text,
      type: options.type
    });
    if(this.getSorts().length===1){
      this.options.currentSort = {
        id : options.id,
        order : "ASC"
      };
    }
    return this;
  };

  ListToolbarBuilder.prototype.addSorts = function(sorts){
    if(!Array.isArray(sorts))
      throw new Error('invalid input for addSorts ');

    var that =this;
    sorts.forEach(function(sort){
      that.addSort(sort);
    });
    return this;
  };

  ListToolbarBuilder.prototype.getViews = function(){
    return this.options.views;
  };

  ListToolbarBuilder.prototype.addView = function(options){
    if(!options || !options.id || !options.text || !options.fonticon )
      throw new Error('invalid view definition for addView');
    this.getViews().push({
      id : options.id,
      text: options.text,
      fonticon: options.fonticon
    });
    return this;
  };

  ListToolbarBuilder.prototype.addViews = function(views){
    if(!Array.isArray(views))
      throw new Error('invalid input for addViews ');

    var that =this;
    views.forEach(function(view){
      that.addView(view);
    });

    return this;
  };

  ListToolbarBuilder.prototype.getMultselActions = function(){
    return this.options.multiselActions;
  };

  ListToolbarBuilder.prototype.addMultiselAction = function(options){
    if(!options || !options.id || !options.text || !options.fonticon || !(options.handler instanceof Function))
      throw new Error('invalid MultiselAction definition for addMultiselAction');

    this.getMultselActions().push({
      id : options.id,
      text : options.text,
      handler: options.handler,
      fonticon : options.fonticon
    });

    return this;
  };

  ListToolbarBuilder.prototype.addMultiselActions = function(MultiselActions){
    if(!Array.isArray(MultiselActions))
      throw new Error('invalid input for addViews ');

    var that =this;
    MultiselActions.forEach(function(MultiselAction){
      // that.addMultiselAction(MultiselAction);
    });

    return this;
  };
  ListToolbarBuilder.prototype.registeronMultiselClick= function(callback){
    this.options.multiselActionCallback = callback;
    return this;
  }
  ListToolbarBuilder.prototype.buildDefaultOptionsSkeleton = function(){
    this.options = {
      modelEvents : null,
      withmultisel : true,  //m
      showItemCount : true,
      components: true,
      multiselActions : null,
      multiselActionCallback: null, //this.multiselActionCallback.bind(this),
      actions : [],  //m
      sort : [],     //m
      views : [],
      filter : {
        //As of R2019xFD01: No additional functionalities are supported to accept filter options including the caching the previously searched values.
        enableCache : false
      },
      currentView : null,
      currentSort : null,
      currentNbitems : 0,
      currentNbSelections : 0
    };
    return this;

  };

  ListToolbarBuilder.prototype.build = function(){

    this.toolbarView = new ENOXCollectionToolBar(this.options);
    if(this.toolbarContainer.empty instanceof Function)
      this.toolbarContainer.empty();
    else {
      this.toolbarContainer.innerHTML = "";
    }


    this.toolbarView._modelEvents.subscribe('enox-collection-toolbar-all-selected', function() {
      console.log("inside of subscribe");
       this.selectAll();
    });
    if(this.options.components == true || this.options.components == "" || this.options.components == "undefined"){
      var that = this;
      var componentsCombobox = this.releatedView.getComponentsView();
  	  if(this.toolbarView){
  		  this.toolbarView._injectFinalItem(componentsCombobox);

  	  }
	}








  //  this.toolbarView._modelEvents.publish('enox-collection-toolbar-all-selected');
    this.toolbarView.inject(this.toolbarContainer);
  };

  ListToolbarBuilder.prototype.createActionBarWrapper = function(){
    return UWA.createElement('div', {'id' : 'listview-toolbar', 'styles' : {'height' : '40px', 'width' : 'inherit'}});
  };

  ListToolbarBuilder.prototype.updateCount = function(){
   console.warn("new count "+count);
    //this.toolbarView._itemCountContainer.innerHTML = count +" "+nls_ENOXCollectionToolBar.Item;
  };

  ListToolbarBuilder.prototype.destroy = function(){
    // this.toolbarView.destroy();
    this.options = null;
    this.toolbarView= null;
    if(this.toolbarContainer.empty instanceof Function)
      this.toolbarContainer.empty();
    else {
      this.toolbarContainer.innerHTML = "";
    }
    this.toolbarView = null;

  };





  return ListToolbarBuilder;

});

/**
 * @module DS/ENOXEngineer/components/XEngListView/js/mixins/ToolBarManager
 */
define('DS/ENOXEngineer/components/XEngListView/js/mixins/ToolBarManager', [
  'UWA/Core',
  'UWA/Class',
  'DS/Core/ModelEvents',
  'DS/ENOXEngineer/componentsHelpers/mixins/ListToolbarBuilder',
  'DS/ENOXEngineerCommonUtils/xEngAlertManager',
  'DS/ENOXEngineer/utils/XEngineerConstants',
		'DS/UIKIT/DropdownMenu',
		'DS/UIKIT/Tooltip'

	], function (UWA, Class, ModelEvents, ListToolbarBuilder, xEngAlertManager, XEngineerConstants, DropdownMenu, Tooltip) {

  'use strict';
  var _actionBar = null;

  const TOOLBAR_SWITCH_VIEW ='enox-collection-toolbar-switch-view-activated';
  const TOOLBAR_SEARCH = 'enox-collection-toolbar-filter-search-value';
  const TOOLBAR_SORT  = 'enox-collection-toolbar-sort-activated';
  const TOOLBAR_UPDATE_COUNT = 'enox-collection-toolbar-items-count-update';
  const EVENT_PERSIST_VIEW = 'event-persist-view';
  const EVENT_SELECTALL = 'enox-collection-toolbar-all-selected';
  const EVENT_UNSELECTALL = 'enox-collection-toolbar-all-unselected';
  const TOOLBAR_MULTISEL_COUNT = 'enox-collection-toolbar-selections-count-update';

  /**
   *
   * Component description here ...
   *
   * @constructor
   * @alias module:DS/ENOXEngineer/components/XEngListView/js/mixins/ToolBarManager
   * @param {Object} options options hash or a option/value pair.
   */
  var ToolBarManager = Class.extend(
    /**
     * @lends module:DS/ENOXEngineer/components/XEngListView/js/mixins/ToolBarManager.prototype
     */
    {

      init: function(options) {
        throw new Error("this is an abstract class it shouldn't be instanciated");
      },
      initializeToolbar: function() {
        var that = this;
        that._modelEvents = new ModelEvents();
        _actionBar = new ListToolbarBuilder({
          modelEvents: that._modelEvents,
          container: this.getContent(),
          ListView:that
        });
        that.buildToolBar();
        that._listenToToolbarEvents();
      },
      updateCount : function(){
        var models = this.getModels() ? this.getModels():null;
        var count = models ? models.getChildrenWithoutGroupingNodes().length : 0;
        this._modelEvents.publish({ event: TOOLBAR_UPDATE_COUNT, data: count});
      },
      updateSelectedItemsCount : function(nb){
          var that = this;
          var selectedNodeType = [];

          var filterNodes = that.getModels().getSelectedNodes().filter(function(node){
            return that.sandbox.core.Factories.ListItemFactory.isInstanceOfListNodeModel(node);
          });
          var totalNodes = that.getModels()._numberOfNodesInDocument;
          var selectedNodes= that.getModels().getSelectedNodes().length;
          var preferredView = that.preferredView;
          if(preferredView === "XENTile"){
              if(selectedNodes>0){
                 if(totalNodes === selectedNodes ){
                        that._modelEvents.publish({event: XEngineerConstants.EVENT_COLLECTION_SELECTALL_CHECKBOX_STATUS_CHECKED})
                 }else{
                        that._modelEvents.publish({event: XEngineerConstants.EVENT_COLLECTION_SELECTALL_CHECKBOX_STATUS_PARTIAL})
                 }
              }else{
                 that._modelEvents.publish({event: XEngineerConstants.EVENT_COLLECTION_SELECTALL_CHECKBOX_STATUS_UNCHECKED})
              }
          }
            if(!nb){
              that.disableMultisel();
            }
           that._modelEvents.publish({ event: TOOLBAR_MULTISEL_COUNT, data: nb}) ;

        },
      disableMultisel: function(){
        var that = this;
        if(that.activeView && (typeof that.activeView.deactivateInteractiveCumulativeSelection  === 'function')){
          that.activeView.deactivateInteractiveCumulativeSelection();
        }
      },
      _listenToToolbarEvents: function(){
        this.eventsTokens = [];
        var that = this;
        this.eventsTokens.push(that._modelEvents.subscribe({ event: TOOLBAR_SWITCH_VIEW},function(viewId){
          console.warn("switching view to  --> "+viewId);
          that.switchView(viewId);
        }));

        this.eventsTokens.push(that._modelEvents.subscribe({ event: EVENT_PERSIST_VIEW},function(viewId){
          that.sandbox.core.localStorage.setItem('List'+"_view",viewId);
        }));

        this.eventsTokens.push(that._modelEvents.subscribe({ event: TOOLBAR_SEARCH},function(searchOpt){
          var searchCrit = Array.isArray(searchOpt.searchValue) ? searchOpt.searchValue[0] : '';
          var start = (new Date()).getTime();
          that.getModels().prepareUpdate();
          that.getModels().getChildren().forEach(function(node){
             node.unMatch(searchCrit) ? node.setSearchFilterState(true) : node.setSearchFilterState(false);
             node.applyFilters();
          });
          that.getModels().pushUpdate();

          that.updateCount();
          console.warn('ending search in '+((new Date()).getTime() - start)+'ms');
        }));

        this.eventsTokens.push(that._modelEvents.subscribe({ event: TOOLBAR_SORT},function(sortOptions){
          that.getModels().onSorting(sortOptions);
        }));

        this.eventsTokens.push(that._modelEvents.subscribe({ event: EVENT_SELECTALL},function(){
          that.selectAll();
        }));

        this.eventsTokens.push(that._modelEvents.subscribe({ event: EVENT_UNSELECTALL},function(){
          that.unSelectAll();
        if(that.activeView && (typeof that.activeView.deactivateInteractiveCumulativeSelection  === 'function')){
          that.activeView.deactivateInteractiveCumulativeSelection();
          //activateInteractiveCumulativeSelection
          //isInInteractiveCumulativeSelectionFlag
        }

        }));

      },
      destroyToolbar: function(){
        var that = this;
        this.eventsTokens.forEach(function(token){
          that._modelEvents.unsubscribe(token);
        });
        _actionBar.destroy();
        _actionBar =null;
      },
      getAvailableActions: function() {
        var that = this;
        var actions=  [{
          id: "NG_Filtering",
          text: that.i18nManager.get("NG_Filtering"),
          fonticon: "fonticon fonticon-filter",
          handler: function(e) {
            console.warn("NG_Filtering");
            if(!that.sandbox.sessionManager.isUsingIndex()){
              xEngAlertManager.warningAlert(that.sandbox.i18nManager.get('filtering.not.available.in.authoring.mode'))
              return;
            }

            that.sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
              commandId: XEngineerConstants.LAUNCH_NG_FILTER_CMD,
              context: {
              }
            });
          }
        },{
          id: "Add",
          text: that.i18nManager.get("Add"),
          fonticon: "fonticon fonticon-plus",
          handler: function(e) {
            that.sandbox.core.commandManager.renderMenu(e.target.getBoundingClientRect(), "addToolBar");
          }
        },
        {
          id: "PersonalizeView",
          text: that.i18nManager.get("label_manageViewPersonalization"),
          fonticon: "fonticon fonticon-cog",
          handler: function(e) {
            if(that.preferredView === "XENTile"){
              that.sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
              commandId: XEngineerConstants.MANAGE_PERSONALIZATION_CMD,
              context: {

               }
             });
           }
           // else {
           //   console.log("in grid view");
           // }
          }
        },
         {
          id: "paste",
          text: that.sandbox.i18nManager.get("Paste"),
          fonticon: "fonticon fonticon-paste",
          handler: function(e) {
            that.sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
              commandId: XEngineerConstants.ITEM_PASTE_CMD,
              context: {
                item: that.options.engItem
              }
            });
          }
        }, {
          id: "groupby",
          text: that.i18nManager.get("tooltip_GroupBy"),
          fonticon: "fonticon fonticon-horizontal-line",
          handler: that.showGroupByMenu.bind(that)
        }];
        // if(that.sandbox.sessionManager.isUsingIndex()){
        //   actions.splice(0, 0, {
        //     id: "NG_Filtering",
        //     text: that.i18nManager.get("NG_Filtering"),
        //     fonticon: "fonticon fonticon-filter",
        //     handler: function(e) {
        //       console.warn("NG_Filtering");

        //       that.sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
        //         commandId: XEngineerConstants.LAUNCH_NG_FILTER_CMD,
        //         context: {
        //         }
        //       });
        //     }
        //   });
        // }

        return actions;
      },
      onMultiselClick: function(targetContainer){
        if(!targetContainer) return ;
        this.getModels().getSelectedItemsCommonMenu(targetContainer.getBoundingClientRect());
      },
      refreshToolBar: function(){
        if (!_actionBar)
        throw new Error(" toolbar not yet initialized");
          var that = this;
      },
      buildToolBar: function() {
        if (!_actionBar)
          throw new Error(" toolbar not yet initialized");
        var that = this;
        _actionBar.addActions(that.getAvailableActions()).registeronMultiselClick(that.onMultiselClick.bind(this))
          .addSorts(that.getModels().getAvailableAttributesToSort())
          .setDefaultView(that.getDefauftView())
          .addViews(that.getAvailableViews()).build();
      },
      /*
      showPersonalizeMenu : function(e){
         var menus = [];
         var that = this;
         var currentPref = that.sandbox.core.dataService.getViewPreference();
         var currentView = "";
         if (currentPref) {
           currentView = currentPref.ctxView;
         }
         menus.push(that.sandbox.core.commandManager.getGenericMenuEnty({
           nls_key : that.sandbox.i18nManager.get("label_manageViewPersonalization"),
           callback :   function(option){
             that.sandbox.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND, {
             commandId: XEngineerConstants.MANAGE_PERSONALIZATION_CMD,
             context: {

              }
            });
           },
           icon : 'I_Parameter'
         }));

         // menus.push(that.sandbox.core.moduleHelper.menuManager.getGenericMenuEnty({
         //   nls_key : that.sandbox.i18nManager.get("label_defaultView"),
         //   callback : function(option){
         //     that.getPersonalizedViewAction("");
         //   },
         //   icon : 'I_CldResetParams',
         //   args:["Reset View"]
         // }));

         // that.getPersonalizedViewNames().forEach(function(menuItem){
         //   if(currentView === menuItem.title){
         //     menuItem.state = 'selected';
         //   }
         //   menus.push(menuItem);
         // });

         that.sandbox.core.commandManager.showMenu(e.target.getBoundingClientRect(),menus);

       },
       */
      //  getPersonalizedViewNames: function() {
      //   var that = this;
      //   var viewNames = [];
      //   var storedViews = [];
      //   var savedSetting = (that.sandbox.core.dataService.getViewPreference() && that.sandbox.core.dataService.getViewPreference().savedSettings) ? that.sandbox.core.dataService.getViewPreference().savedSettings : {};
      //   storedViews = Object.keys(savedSetting);
      //
   		// 	if(storedViews) {
   		// 		storedViews.forEach(function(view) {
      //       viewNames.push(that.sandbox.core.commandManager.getGenericMenuEnty({
      //         nls_key : view,
      //         type: "RadioItem",
      //         callback : function(option){
      //           that.getPersonalizedViewAction(view);
      //         },
      //         args:[view]
      //       }));
   		// 		});
   		// 	}
   		// 	return viewNames;
   		// },
      // getPersonalizedViewAction: function(view) {
      //   var that = this;
      //   var currentPref = that.sandbox.core.dataService.getViewPreference();
      //   currentPref.ctxView = view;
      //   that.sandbox.core.dataService.updateViewPreference(currentPref).then(function(){
      //     that.sandbox.publish(XEngineerConstants.EVENT_REFRESH_LISTVIEW);
      //   });
      // },
      showGroupByMenu: function(e) {
        var menus = [];
        var that = this;
        menus.push(that.sandbox.core.commandManager.getGenericMenuEnty({
          nls_key: that.sandbox.i18nManager.get("None"),
          callback: function(option) {
            that.launchGroupBy({propertiesToGroup:[]});
          },
          args: ['None']
        }));

        menus.push(that.sandbox.core.commandManager.getGenericMenuEnty({
          nls_key: that.sandbox.i18nManager.get("Reference"),
          callback: function(option) {
            that.launchGroupBy({propertiesToGroup:['reference']});
          },
          args: ["Reference"]
        }));
        var attrByType = that.getModels().getAvailableAttributesForGrouping()
                            .forEach(function(attrInfo){
                            menus.push(that.sandbox.core.commandManager.getGenericMenuEnty({
                                                  nls_key: attrInfo.attrNls,
                                                  callback: function(option) {
                                                    that.launchGroupBy({propertiesToGroup:[attrInfo.sixWTag]});
                                                  },
                                                  args: [attrInfo.sixWTag]
                                                }));
                        });

        that.sandbox.core.commandManager.showMenu(e.target.getBoundingClientRect(), menus);
      },

      showComponentsMenu: function(presentSelectedView) {
	        var that = this;
	        var views = [{
	                id: XEngineerConstants.DIRECT_CMD,
	                text: that.sandbox.i18nManager.get("eng.export.components.direct"),
	                tooltip: that.sandbox.i18nManager.get("eng.export.components.view.direct"),
	                selectable: true,
	                selected: (presentSelectedView == XEngineerConstants.DIRECT_CMD)
	            }, {
	                id: XEngineerConstants.QUALIFIED_AS_FINAL_CMD,
	                text: that.sandbox.i18nManager.get("eng.export.components.qualifiedAsFinal"),
	                tooltip: that.sandbox.i18nManager.get("eng.export.components.view.qualifiedAsFinal"),
	                selectable: true,
	                selected: (presentSelectedView == XEngineerConstants.QUALIFIED_AS_FINAL_CMD)
	            }

	        ];



          if (this._dropDown == undefined) {
	            this._dropDown = new DropdownMenu({
	                target: document.querySelector("#Components"),
	                items: [],
	                events: {
	                    onClick: function(e, item) {
	                            that.getQualifiedAsFinalItemView(item.id, item);
	                        }
	                        .bind(that)
	                }
	            });

	            for (var i = 0; i < views.length; i++) {
	                this._dropDown.addItem({
	                    id: views[i].id,
	                    fonticon: views[i].fonticon,
	                    text: views[i].text,
	                    tooltip: views[i].tooltip,
	                    className: "enox-components-view",
	                    selected: views[i].selected,
	                    selectable: views[i].selectable
	                });
	            }


	            this._dropDown.show();
	        }
	    },

	    getComponentsView: function() {
	        var that = this;

	        var currentView = that.sandbox.core.localStorage.getItem(XEngineerConstants.VALUE_QUALIFIED_AS_FINAL_COMPONENT);
	        var toolTipInfo = (currentView == XEngineerConstants.DIRECT_CMD) ? that.sandbox.i18nManager.get("eng.export.components.view.direct")
										: that.sandbox.i18nManager.get("eng.export.components.view.qualifiedAsFinal");

	        var div = document.createElement('div');
	        div.id = "Components";
	        div.className = 'enox-collection-toolbar-icon fonticon fonticon-eye-cog';
	        div.addEventListener('click', function() {
	            that.showComponentsMenu(currentView);
	        })

	        this._tooltip = new Tooltip({
	            target: div,
	            body: toolTipInfo
	        });

	        return div;
	    },



	    getQualifiedAsFinalItemView: function(option, items) {
	        var that = this;

	        this._tooltip.setBody(items.tooltip);

	        var cmdID = (option) ? option : XEngineerConstants.DIRECT_CMD;
	        if (cmdID != that.sandbox.core.localStorage.getItem(XEngineerConstants.VALUE_QUALIFIED_AS_FINAL_COMPONENT)) {
	            that.sandbox.publish(XEngineerConstants.EVENT_QUALIFIED_AS_FINAL_ITEM, {
	                commandId: cmdID
	            });
	        }
      	    }

    });

  return ToolBarManager;
});

/**
 * @module DS/ENOXEngineer/components/XEngListView/js/EngItemContentViewer
 */
define('DS/ENOXEngineer/components/XEngListView/js/EngItemContentViewer', [
      'UWA/Core',
      'UWA/Controls/Abstract',
      'UWA/Class/Options',
      'DS/PlatformAPI/PlatformAPI',
      'DS/ENOXEngineer/utils/XEngineerConstants',
      'DS/ENOXEngineer/components/XEngListView/js/mixins/ToolBarManager',
      'DS/ENOXEngineer/components/XEngListView/js/mixins/EngItemViewsManager',
      'DS/ENOXEngineer/services/XEngLocalStorage',
      'DS/ENOXEngineerCommonUtils/xEngAlertManager'
    ], function(UWA, Abstract,Options, PlatformAPI, XEngineerConstants,
      ToolBarManager,EngItemViewsManager, LocalStorage, xEngAlertManager) {

    'use strict';

    /**
     *
     * Component description here ...
     *
     * @constructor
     * @alias module:DS/ENOXEngineer/components/XEngListView/js/EngItemContentViewer
     * @augments module:UWA/Controls/Abstract
     * @param {Object} options options hash or a option/value pair.
     */
    var EngItemContentViewer = Abstract.extend(
      /**
       * list of mixins extending EngItemContentViewer
       */
       Options, ToolBarManager, EngItemViewsManager,
     /**
     * @lends module:DS/ENOXEngineer/components/XEngListView/js/EngItemContentViewer.prototype
     */
    {

        defaultOptions: {
          useToolBar: true
        },
        contentType : 'BOM',

        init: function(_sandbox) {
            this.sandbox = _sandbox;
            this.sandbox.logger.info('initializing EngItemContentViewer ...');
            this._parent({});
            this.elements.container = _sandbox.container;
            this.i18nManager = _sandbox.i18nManager;
            this._views = [{
              id : 'XENTile',
              loader : 'DS/ENOXEngineerTilesViews/XENResponsiveTileView',
              text : this.i18nManager.get("big_tiles_view"),
              fonticon: 'view-big-tile'
            },{
              id : 'DataGridView',
              text : this.i18nManager.get("DataGridView"),
              loader : 'DS/DataGridView/DataGridView',
              fonticon: 'view-list'
            }
          ];

        },
        /***
        **  this function build the content view
        **/
        start: function(){
          this.sandbox.logger.info('starting EngItemContentViewer ...');
          var that = this;
          that.initializeToolbar();
          that.initializeViews();
          that.toggleToolbarItems();

          this.sandbox.registerDnDManager({
            sandbox : this.sandbox,
            container: this.getContent(),
            dropStrategy:"BOM",
            droppable:true,
            onDrop: that.onValidDrop.bind(that)
          });

          this.getModels().onPostENOXFiltering = this.updateCount.bind(this);
          this.getModels().onSelectionUpdated = this.updateSelectedItemsCount.bind(this);

        	  that.sandbox.subscribe(XEngineerConstants.EVENT_NEW_INSERTED_ENG_ITEM, function(data) {
        		  if (!data.postProcess){
        			  that.addContentToModels(data);
        		  }

        	  });


            that.sandbox.subscribe(XEngineerConstants.EVENT_INDEX_MODE_DISABLE, function(){
            	// that.refreshToolBar();
            });

        	  that.sandbox.subscribe(XEngineerConstants.EVENT_REPLACED_ENG_ITEM, function(options) {
        		  that.replaceContent(options);
          	  });

        	  that.sandbox.subscribe(XEngineerConstants.EVENT_LIST_SELECT_ITEM, function(d) {
          	    that.select(data[d.rowID]);
              });

            that.sandbox.subscribe(XEngineerConstants.EVENT_NOTIFY_CONTENT_SIZE_CHANGE, function() {
              that.updateCount();
          	});

            that.sandbox.subscribe(XEngineerConstants.EVENT_DELETED_ENG_ITEM, function(options) {
              if (Array.isArray(options.ids)) {
                if (options.ids.indexOf(that.sandbox.options.physicalId) !== -1) {
                  that.sandbox.publish(XEngineerConstants.EVENT_GO_BACK);
                } else {
                  // that._deleteNodeByReferencesId(options.ids);
                }
              }

            });

            that.sandbox.subscribe(XEngineerConstants.EVENT_DOWNLOAD_ITEM, function(d) {
            	that.sandbox.dataService.downloadDocuments(d.nodes);
      	  });
            that.sandbox.subscribe(XEngineerConstants.EVENT_REMOVE_DOCUMENT, function(d) {
            	that.sandbox.dataService.detachDocuments(d.nodes, that.getModels().getEngineeringItem());
      	  });

            that.sandbox.subscribe(XEngineerConstants.EVENT_DELETE_DOCUMENT, function(d) {
            	that.sandbox.dataService.deleteDocuments(d.nodes);
      	  });

            that.sandbox.subscribe(XEngineerConstants.EVENT_REMOVED_INSTANCE, function(options) {
              that.getModels()._deleteNodesByCriteria(function(instRefNode){
                return (options.instances.indexOf(instRefNode.getRelationID()) > -1) ? true : false;
              });
               that.updateCount();
        	  });

            that._refreshSubscription = PlatformAPI.subscribe('DS/PADUtils/PADCommandProxy/refresh', function(refresedData){

            	var listPhyid = [];

                var shouldUpdate = false;
                if (refresedData.data.authored && refresedData.data.authored.modified) {
                  refresedData.data.authored.modified.forEach(function(itemPid){

                	  listPhyid.push(itemPid);
                  });

                }
                that.updateContent(listPhyid);
              });


        	  that.sandbox.subscribe(XEngineerConstants.EVENT_REFRESH_LISTVIEW, function() {
        	   that.getModels().prepareUpdate();
        	   that.getModels().pushUpdate();
            });

            that.sandbox.subscribe(XEngineerConstants.EVENT_COLUMNS_CHANGED, function() {
              that.reDrawColumns();
             });

            that.sandbox.subscribe(XEngineerConstants.EVENT_EDIT_MATERIAL_QTY_COMPLETED, function(data){
                if(!data || !Array.isArray(data.results)) return ;//unknown format


              	that.updateContent(data.results.map(function(item){
                  return item.body.physicalid;
                }), function(node){
              		if(!node.isEngineeringItem()) return ;

              		for(var i=0; i< data.results.length; i++){
              			if(data.results[i].body.physicalid === node.getID()){
              				var qty = (data.results[i].body["attribute[MaterialUsageExtension.DeclaredQuantity]"].value[0]) ? data.results[i].body["attribute[MaterialUsageExtension.DeclaredQuantity]"].value[0].trim() : null;
              				if(qty && qty.length=== 0) qty = null;
              				node.updateOptions({
              		            grid: {
              		            	"ds6wg:MaterialUsageExtension.DeclaredQuantity":qty
              		            }
              		          });
              				return ;
              			}
              		}
              	});

              });

            that.sandbox.subscribe(XEngineerConstants.EVENT_SET_PARTNUMBER_COMPLETED, function(data){
              if(!data || !Array.isArray(data.references)) return ;//unknown format

            	that.updateContent(data.references.map(function(item){
                return item.physicalid;
              }), function(node){
            		if(!node.isEngineeringItem()) return ;

            		for(var i=0; i< data.references.length; i++){
            			if(data.references[i].physicalid === node.getID()){
            				var pn = (data.references[i].partNumber) ? data.references[i].partNumber.trim() : null;
            				if(pn && pn.length=== 0) pn = null;
            				node.updateOptions({
            		            grid: {
            		            	"ds6wg:EnterpriseExtension.V_PartNumber":pn
            		            }
            		          });
            				return ;
            			}
            		}
            	});

            });

            that.sandbox.subscribe(XEngineerConstants.EVENT_NEW_VERSION_COMPLETED, function(data){

            	var listToRefresh = [];
            	data.getParents().forEach(function(parent){
            		listToRefresh.push(parent.options.id);
            	});
                that.getModels()._refreshNodes(listToRefresh);
              });

            that._clipBoard = PlatformAPI.subscribe(XEngineerConstants.ADD_TO_CLIPBOARD, function(data) {
        	    LocalStorage.setItem('clipboard', data);
              that.sandbox.publish(XEngineerConstants.EVENT_TOOLBAR_ENABLE, 'paste');

        	    var itemRelIDs = [];
        	    if ((data || data.length != 0) && data.startsWith("CX")) {
        	      var instanceIDstr = data.substring(3);
        	      var instanceIDs = instanceIDstr.split(',');
        	      for (var idx = 0; idx < instanceIDs.length; idx++) {
        	        itemRelIDs.push(instanceIDs[idx].split('|')[1]);
        	      }
        	    }
        	    //that._setNodeCutItemStatus(itemRelIDs);
            });

            that.sandbox.publish(XEngineerConstants.EVENT_LIST_READY);
            that.updateCount();
        },

        // resetListContent: function(){
        //     var that = this;

        //     that.sandbox.publish(XEngineerConstants.EVENT_COLLECTION_ACTION_UPDATE_COUNT, 0);
        //     that.sandbox.publish(XEngineerConstants.EVENT_RELOAD_ENGINEERING_DEFINITION);
        //   },

        toggleToolbarItems: function() {
           var that = this;
           var preferredView = that.preferredView;
           var viewFromLocalStorage = that.getDefauftView();
           if(preferredView === undefined || preferredView == null){
              preferredView = viewFromLocalStorage;
           }

           if( preferredView === "DataGridView"){
              that._modelEvents.publish({ event: XEngineerConstants.EVENT_TOOLBAR_DISABLE, data:'PersonalizeView'});
              that._modelEvents.publish({ event: XEngineerConstants.EVENT_COLLECTION_TOOLBAR_CHECKBOX_HIDE, data:'DataGridView'});
           }else{
              that._modelEvents.publish({ event: XEngineerConstants.EVENT_TOOLBAR_ENABLE, data:'PersonalizeView'});
              that._modelEvents.publish({ event: XEngineerConstants.EVENT_COLLECTION_TOOLBAR_CHECKBOX_SHOW, data:'XENTile'});
           }
        },

        updateContent: function(ids, preProcessing){

        	var that = this;
          var listPhyid = [], listDocid = [], nodeType;
          var instRelMapping = [];
        	var nodesToUpdate = this.getModels().retrieveNodesByIds(ids);
          nodesToUpdate.forEach(function(node){
        	 if(typeof preProcessing === "function") preProcessing(node);

            if(node.getType().indexOf("Document") >= 0){//TODO to be migraate to right API
                  listDocid.push(node.getID());
                } else {
                  listPhyid.push(node.getID());
                  var input = {instance:node.getRelationID(), isInstanceOf:node.getID()};
                  instRelMapping.push(input);
                }

          });

          if(listDocid.length > 0){
                that.updateDocument(nodesToUpdate,listDocid);
           }
          if(listPhyid.length >0){
        	  that.update(nodesToUpdate, instRelMapping);
          }
        },
        onValidDrop: function(dropedItems) {
          var that = this;
          var cautchPid = that.sandbox.options.physicalId;
          that.sandbox.dataService.insertContentsInBOMFromDrop(dropedItems, that.getModels().getEngineeringItem())
            .then(function(listNodes) {
              var toAdd = [];
              for (var i = 0; i < listNodes.length; i++) {
                if (listNodes[i].status === "fullfilled") {
                  toAdd.push(listNodes[i].obj);
                } else {
                  console.error(listNodes[i].obj);
                  xEngAlertManager.errorAlert(that.sandbox.i18nManager.replace(that.sandbox.i18nManager.get("error.operation.failed"), {
                    operation: '',
                    error: JSON.stringify(listNodes[i].obj)
                  }));
                }
              }
              that.addContentToModels({
                nodes : toAdd,
                parentId : cautchPid
              });

            }).catch(function(error) {
              console.error(error);
              xEngAlertManager.errorAlert(that.sandbox.i18nManager.replace(that.sandbox.i18nManager.get("error.operation.failed"), {
                operation: ' ',
                error: error
              }));
            });
        },

        replaceContent: function(data){

        	var that = this;
        	var instIDToUpdate = [data.replacedId];
        	var nodesToUpdate = this.getModels().getNodesByInstanceId(instIDToUpdate);
        	var mapping = [];
        	var instInput = {instance:data.new.instance, isInstanceOf: data.new.reference};
        	mapping.push(instInput);
        	that.update(nodesToUpdate, mapping, true);
        },


        update: function(nodesToUpdate, mapping, isFromReplace){

        	var that = this;
        	this.sandbox.core.dataService.getListNodesFromEngItemsAndInstanceIds(mapping)
            .then(function(listNodes){
            that.refresh(nodesToUpdate, listNodes, isFromReplace);
            }).catch(function(error){   console.error(error);
            });

        },

        refresh: function(nodesToUpdate, listNodes, isFromReplace){
         var that = this;
         that.getModels().prepareUpdate();
         for (var i=0 ; i<nodesToUpdate.length ; i++){
           nodesToUpdate[i].refreshByModel(listNodes[i]);
         }
        that.getModels().pushUpdate();
        // if(isFromReplace){
          // refresh  columns like  effectivities, materials ..
          that.getModels().refreshProvidedColumns(nodesToUpdate, isFromReplace);
        // }
        that.getModels().reApplyUserCurrentViewOptions();

        },


        updateDocument: function(nodesToUpdate, ids){

          var that = this;
          this.sandbox.core.dataService.fetchDocumentsData(ids)
            .then(function(listNodes){
            that.refresh(nodesToUpdate, listNodes);

        }).catch(function(error){   console.error(error);
        });

      },

        selectAll: function(){
          this.getModels().selectAll();
        },
        unSelectAll: function(){
          this.getModels().unselectAll();
        },
        addContentToModels: function(options){
          var that = this;
             if(! Array.isArray(options.nodes) || options.parentId !== that.sandbox.options.physicalId) return ;

             this.sandbox.logger.info('adding content -->');

             that.getModels().mainAddContent(options.nodes);
             that.updateCount();
             that.getModels().pushToTagger();

             that.unSelectAll();
             options.nodes.forEach(function(node){
                node.select();
              });

        },
        getModels: function(){
          return (this.sandbox && this.sandbox.options) ?  this.sandbox.options.models : null;
        },
        /*
        savedViews : function(){
          //var that = this;
          var activeView = {};
          var viewKeys = [];
          //var storedViews = [];
          // this.sandbox.core.dataService.getPreference(XEngineerConstants.USER_VIEW_CUSTO_PREF).then(function(data) {
          //   if(!data || data == ''){
          //     console.log("Checking inside getPreference");
          //   } else {
          //     var activeView = JSON.parse(data);
          //     console.log(activeView);
          //     viewKeys = Object.keys(activeView);
          //   }
          // });

          this.sandbox.core.dataService.getPreference(XEngineerConstants.USER_VIEW_CUSTO_PREF)
                .then(function(data){
                  if(!data || data == ''){
                    console.log("Checking inside getPreference");
                  } else {
                    var activeView = JSON.parse(data);
                    console.log(activeView);
                    viewKeys = Object.keys(activeView);
                  }
                }).catch(function(error){   console.error(error);
                });
          // activeView = LocalStorage.getItem('activeData');
          // viewKeys = Object.keys(activeView);
          return viewKeys;
        },
        */
        stop: function(){
          this.getModels().removeFromTagger([this.sandbox.options.physicalId]); //remove need now the root ID
        	PlatformAPI.unsubscribe(this._refreshSubscription);
          PlatformAPI.unsubscribe(this._clipBoard);
          this.sandbox.logger.info('stopping EngItemContentViewer ...');
          this.destroyToolbar();
          this.destroyViews();
          this.sandbox.stop(this);
        }

    });

    return EngItemContentViewer;
});

define('DS/ENOXEngineer/commands/PersonalizationCmd',
	[
		'UWA/Class',
		'DS/ENOXEngineer/componentsHelpers/mixins/XEngDnDManager',
		'DS/ENOXEngineer/components/XEngListView/js/mixins/EngItemViewsManager',
		'DS/ENOXEngineer/components/XEngListView/js/EngItemContentViewer',
		'DS/ENOXEngineer/services/PreferencesManager',
		'DS/ENOXEngineer/commands/XEngineerCommandBase',
		'DS/ENOXEngineer/utils/XEngineerConstants',
	  'DS/ENOXEngineer/componentsHelpers/ENOXCustomizeView/js/CustomizeView'
	],
	function(	Class,
					XEngDnDManager,
					EngItemViewsManager,
					EngItemContentViewer,
					PreferencesManager,
					XEngineerCommandBase,
					XEngineerConstants,
			  	CustomizeView
				) {

	'use strict';


	var PersonalizeView = XEngineerCommandBase.extend({
		init : function(options) {
			this._parent(options);
			console.info("#PersonalizeView: init called");
		},

		execute : function(params) {
			var that = this;
			console.info("#PersonalizeView: execute called");

				var data = (that.appCore.PreferencesManager.getViewPreference())? that.appCore.PreferencesManager.getViewPreference().savedSettings:null;
				var _views = [];
				var _ctxView;
				var _customizedViews = {};
				if(!data){
					_views = ['Untitled', 'Create new view'];
					_ctxView = '';
					_customizedViews = {};
				} else {
					_customizedViews = data;
					_ctxView = that.appCore.PreferencesManager.getViewPreference().ctxView;
					_views = Object.keys(data);
					_views.splice(0,0, "Create new view");
				}

				var _buttons = [];
				var _titles = {};
				var cancelButtonLabel = that.appCore.i18nManager.get("eng.ui.button.cancel");
				var okLabel = that.appCore.i18nManager.get("eng.ui.button.ok");
				_buttons.push(cancelButtonLabel);
				_buttons.push(okLabel);
				_titles["vTitle"] = that.appCore.i18nManager.get("eng.ui.button.visible");
				_titles["aTitle"] = that.appCore.i18nManager.get("eng.ui.button.available");
				_titles["viewName"] = that.appCore.i18nManager.get("Name");
				_titles["viewType"] = that.appCore.i18nManager.get("Type");

			//	var availableAttributes = that.options.context.getActiveEngItem().getContentModels().getAvailableAttributes(["VPMReference"]);
				var availableAttributes = that.options.context.getAvailableAttributes(["VPMReference"]);
/*
				availableAttributes.VPMReference.push({attrName: "ds6wg:MaterialUsageExtension.DeclaredQuantity",
					attrNls: that.options.appCore.i18nManager.get("MaterialUsageExtension.DeclaredQuantity"),
					sixWTag: "ds6wg:MaterialUsageExtension.DeclaredQuantity",
					type: "string"});
*/
				availableAttributes.VPMReference.push({attrName: "CoreMaterial",
					attrNls: that.options.appCore.i18nManager.get("CoreMaterial"),
					sixWTag: "CoreMaterial",
					type: "string"});

				var availableAttributesDoc = that.options.context.getAvailableAttributes(["Document"]);
				console.log(availableAttributesDoc);
				var view = null;
				var defaultAttrEI = ["ds6w:status", "ds6w:responsible", "ds6wg:EnterpriseExtension.V_PartNumber", "ds6w:modified", "ds6w:created"];
				var defaultAttrDoc = ["ds6w:status", "ds6w:responsible", "ds6w:modified", "ds6w:created"];
			var attributeInfoDoc = [];
				var _availableType = [{
				  typeName : "VPMReference",
				  typeNls: that.appCore.i18nManager.get("engineering_item")
				}, {
				  typeName : "Document",
				  typeNls: that.appCore.i18nManager.get("document")
				}];

				var attrInfos = {};
				var attributeInfoEI = [];

				availableAttributesDoc.Document.map(function(attrInfo) {
					if ((attrInfo.attrName === "ds6wg:revision") || (attrInfo.attrName ==="ds6w:label")) {
							return;
						} else {
							attributeInfoDoc.push(attrInfo);
						}
				});

				availableAttributes.VPMReference.map(function(attrInfo) {
					if ((attrInfo.attrName === "ds6wg:revision") || (attrInfo.attrName ==="ds6w:label")) {
							return;
						} else {
							attributeInfoEI.push(attrInfo);
						}
				});
				// var ctxView = '';
				// ctxView = that.newSet.ctxView? that.newSet.ctxView : 'Untitled';

				var enoxCustumizeView = new CustomizeView({
		 				header: that.appCore.i18nManager.get("label_manageViewPersonalization"),
		 				body: '',
		 				attributes: {
													availableEI: attributeInfoEI,
		 			              	availableDoc :attributeInfoDoc,
													visible: []
		 										},
		 				views: _views,
		 				types : _availableType,
		 				buttons: _buttons,
						titles: _titles,
						ctxView: _ctxView,
						view: view,
						maxAttributes: 8,
						limitCountDisplay: that.appCore.i18nManager.get("no_of_visible_count_display"),
						defaultAttributesEI: defaultAttrEI,
						defaultAttributesDoc: defaultAttrDoc,
		 				customizedViews: _customizedViews,
		 				onSubmitCallBack : function(result){
				 				that.appCore.PreferencesManager.updateViewPreference(result);
								that.appCore.mediator.publish(XEngineerConstants.EVENT_REFRESH_LISTVIEW);
		 				}
		 			});
		 			enoxCustumizeView.render();

		that.end();
		}
	});

	return PersonalizeView;
});

define('DS/ENOXEngineer/services/ImportService', [
        'UWA/Class',
        'UWA/Core',
        'DS/ENOXEngineerCommonUtils/PromiseUtils',
        'DS/ENOXEngineer/utils/XENHttpClient',
        'DS/ENOXEngineer/utils/XEngineerConstants',
        'DS/WAFData/WAFData',
        'DS/ENOXEngineer/commands/ENOXImportItemUX',
        'DS/ENOXEngineer/services/EngineeringSettings',
    ],
    function(UWAClass,
        UWACore,
        PromiseUtils,
        xAppWSCalls,
        XEngineerConstants,
        WAFData,
        ENOXImportItemUX,
        EngineeringSettings) {
	
        'use strict';
        var exportHandler = {
            getResults:function(elems,jsonObject){
            	var setImportCmd = EngineeringSettings.getCommand('importService');
            	jsonObject.TimeoutConstraintsInMS = setImportCmd.timeout;
            	var that = this;
            	
            	var formData = new FormData();
           		formData.append("file", elems);
           		formData.append("text",JSON.stringify(jsonObject));
            
	            var fetchOptions = {
	  			  'data': formData
	  			};
	            
				return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){
					xAppWSCalls.perform(setImportCmd, fetchOptions.data).then(function(response) {
						return resolve(response);
							}).catch(function(error) {
								return resolve(error);
		                    });
				});
            }
		};
        return exportHandler;
       });


define ( 'DS/ENOXEngineer/commands/ENOXImportItemUX',
			['DS/ENOXEngineer/commands/XEngineerCommandBase',
			'DS/Handlebars/Handlebars',
			'DS/ENOXEngineer/componentsHelpers/commandModal/XEngineerModal',
			'DS/Windows/Dialog',
			'DS/Windows/ImmersiveFrame',
			'DS/UIKIT/Input/Text',
			'DS/Controls/LineEditor',
			"DS/Controls/Button",
			"DS/DataGridView/DataGridView",
			'DS/WAFData/WAFData',
			'DS/WebappsUtils/WebappsUtils',
			'DS/ENOXEngineer/utils/XEngineerConstants',
			'DS/ENOXEngineer/services/EngineeringSettings',
			'DS/ENOXEngineer/services/ImportService',	
			'DS/ENOXEngineerCommonUtils/PromiseUtils',
			'DS/TreeModel/DataModelSet',
			"DS/Controls/ComboBox",
			'DS/Tree/TreeDocument',
			'DS/Tree/TreeNodeModel',
			'DS/Controls/Toggle',
			'text!DS/ENOXEngineer/componentsHelpers/xEngImport/html/ImportEngineeringItems.html',
			'css!DS/ENOXEngineer/componentsHelpers/xEngImport/css/ImportEngineeringItems.css'],
function ( XEngineerCommandBase,
			Handlebars,
			Modal,
			Dialog,
			ImmersiveFrame,
			Text,
			LineEditor,
			Button,
			DataGridView,	
			WAFData,
			WebappsUtils,
			XEngineerConstants,
			EngineeringSettings,
			ImportService,	
			PromiseUtils,
			DataModelSet,
			WUXComboBox,
			TreeDocument,
			TreeNodeModel,
			Toggle,
			html_ImportEngineeringItems) {

	'use strict';
    
    var enoXImportItemUX, that;
    
    /* */
    
	var ACTION_SUCCESS = "Success";
	var ACTION_ERROR = "Error";

	var KEY_MANDATORY_COLUMN_MISSING = "MandColumnsMissing";
	var KEY_IGNORE_COLUMN_LIST = "IgnoreColumnList";
	var KEY_MANDATORY_COLUMNS = "MandColumns";
	var KEY_DATA_SEPARATOR = "ImportDataSeparator";
	var KEY_SPREADSHEET_MAPPED_COLUMNS = "MappedSpreadSheetColumns";
	var KEY_SPREADSHEET_UNMAPPED_COLUMNS = "UnmappedSpreadsheetColumns";
	var KEY_BASIC_ATTRIBUTES = "ObjectBasics";
	var KEY_TYPE_ATTRIBUTES = "TypeAttributes";
	var KEY_RELATIONSHIP_ATTRIBUTES = "RelationshipAttributes";
	var KEY_LABEL_ITEM = "labelItem";
	var KEY_VALUE_ITEM = "valueItem";
	var KEY_VALIDATION_ACTION = "Action";
	var KEY_ERROR_MESSAGE = "ErrorMessage";
	var KEY_ERROR_COUNT = "ErrorCount";
	var KEY_REPORTED_ERROR = "ReportedErrors";
	var KEY_IMPORT = "import-button";
	var KEY_CANCEL_BUTTON = "cancel-button";
	var KEY_COUNT_ROOTITEM = "COUNT_ROOTITEM";
	var KEY_COUNT_ADDNEWINSTANCE = "COUNT_ADDNEWINSTANCE";
	var KEY_COUNT_ADDNEWREFERNCE = "COUNT_ADDNEWREFRENCE";
	var KEY_COUNT_ADDEXISTINGINSTANCE = "COUNT_ADDEXISTINGINSTANCE";
	var KEY_ROOT_PHYSICAL_ID = "ROOT_PHYSICALID";
	var KEY_COUNT_MODIFY = "COUNT_MODIFY";
	var KEY_COUNT_REMOVE = "COUNT_REMOVE";
	var CONSTANT_WIDGET_DIV = "div";
	var CONSTANT_DIV_ITEMS_TO_SHOW = 7;
	var CONSTANT_EMPTY = "";
	var CONSTANT_SINGLE_SPACE = " ";
	var CONSTANT_BREAK = "</br>";

	var CONSTANT_SPAN_TAG_GREEN_TEXT = "<span class=\"enox-import-greentext\">";
	var CONSTANT_SPAN_TAG_YELLOW_TEXT = "<span class=\"enox-import-orangetext\">";
	var CONSTANT_SPAN_TAG_RED_TEXT = "<span class=\"enox-import-redtext\">";
	var CONSTANT_SPAN_TAG_GRAY_TEXT = "<span class=\"enox-import-graytext\">";
	var CONSTANT_SPAN_TAG_BLACK_BOLD_TEXT = "<span class=\"enox-import-blackBoldtext\">";
	var CONSTANT_SPAN_END_TAG = "</span>";
    var CONSTANT_SPAN_START_TAG = "<span>";	
    var CONSTANT_HTML_SPACE = "&nbsp;";

	var jsonImportValidationResults = null;
	
	var supportedFileFormats = [".csv", ".xls", ".xlsx"];
	var currentSelectedHeaderValues = {};
	
	var manageHeaderValidateMethodEnteredCount = 0;
    
    function ENOXImportItemUX () {
		var options = {
            importfiledownloadtemplate: true,
            importfilechooser: true
		};
		
		this.appCore = (that.options.appCore) ? that.context._app.core : that._ctx._app.core;
		
		this.i18nManager = (that.options.appCore && that.options.appCore.i18nManager) ? that.context._app.core.i18nManager : that._ctx._app.core.i18nManager;
		
		this.modalOptions = {
			title: this.i18nManager.get("eng.import.label"),
			className: '',
			withFooter: false
		};

		this.modal = new Modal(this.modalOptions);

		this.modal.injectFooter( this.getFooter() );

		var template = Handlebars.compile(html_ImportEngineeringItems);

		this._options = options ? UWA.clone(options, false) : {};

		this._container = this.modal.getBody();

		this._container.innerHTML = template(this._options);

		this._container = this._container.querySelector('.enox-import');

		this._importFileTemplateDownload = this._container.querySelector('.enox-import-template-download');

		this._importFileChooserLabel = this._container.querySelector('.enox-import-file-chooser-label');
        
        this._importFileChooser = this._container.querySelector('.enox-import-file-chooser-browser');
        
        this._importFileManageHeader = this._container.querySelector('.enox-import-file-chooser-manageheader');
        
        this._importFileValidationImageIndicator = this._container.querySelector('.enox-import-file-imageindicator');
        
        this._importFileValidationResultDescriptions = this._container.querySelector('.enox-import-file-validationdescriptions');

		this.createImportTemplateDownloadLink();

		this.createImportFileChooser();
		
		this.loaderVisualCue = "";
		
		this.createOnClickEventForImport();
		
		this.createOnClickEventForCancelButton();

		this.userMappedColumnHeadersColumns = {}; // holds the user Mapped column values from Select header section.
	};
    
	ENOXImportItemUX.prototype.getImageSource = function(iconKey) { return  "<img src=\"" + WebappsUtils.getWebappsAssetUrl('ENOXEngineer', 'icons/32/'+iconKey+'.png') + "\">"; }
    
    ENOXImportItemUX.prototype.getSucessIcon = function() { return this.getImageSource("I_Right"); }
    
    ENOXImportItemUX.prototype.getWarningIcon = function() { return this.getImageSource("I_Warning"); }
    
    ENOXImportItemUX.prototype.getErrorIcon = function() { return this.getImageSource("I_Error"); }
    
    ENOXImportItemUX.prototype.getDownloadIcon = function() { return this.getImageSource("I_DownloadDocument"); }
    
    ENOXImportItemUX.prototype.getBlockedIcon = function() { return "<span class=\"fonticon fonticon-block\" title="+"\""+enoXImportItemUX.i18nManager.get("eng.import.CkeckboxImageTooltip") +"\""+"></span>"; }
    
    ENOXImportItemUX.prototype.setValidationResults = function (validationResultJson) { this.jsonImportValidationResults = validationResultJson; }
    
    ENOXImportItemUX.prototype.getContextPhysicalId = function () { return (this.appCore.contextManager.getActiveEngItem()) ? this.appCore.contextManager.getActiveEngItem().getID() : null; }
    
    ENOXImportItemUX.prototype.isOperationPerformedFromContextItem = function () { return ( enoXImportItemUX.getContextPhysicalId() != null ); }
    
    ENOXImportItemUX.prototype.getIgnoreColumnsArray = function () { return this.splitData( this.getValue(KEY_IGNORE_COLUMN_LIST) ); }
    
    ENOXImportItemUX.prototype.clearTransactionCachedInfo = function (validationResultJson) {
    	this.jsonImportValidationResults = null;
    	enoXImportItemUX.clearUserMappedColumnCache();
    }
    
    ENOXImportItemUX.prototype.displayValidationResultsOnUX = function () {
		this.displayManageHeaderLink();

		if ( this.isValidation_Success() ) {			
			enoXImportItemUX.enableImportButton();
			this.displayActionSummaryReport();
		}

		else {
			enoXImportItemUX.disableImportButton();
			
			if ( enoXImportItemUX.isUnMappedColumnExists() || enoXImportItemUX.isMandatoryColumnMissing()) {
				this.displayImageIndicator_Error();
				
				UWA.Event.dispatchEvent(this._importFileManageHeader, 'click');
				
				this.displayUnMappedUserMessage();
			}
			
			else {
				this.displayReportedError();
			}
		}
	}
	
	ENOXImportItemUX.prototype.isMandatoryColumnMissing = function () { return this.containsKey(KEY_MANDATORY_COLUMN_MISSING); }

	ENOXImportItemUX.prototype.getAllMandatoryColumns = function () {
		var arrayJs = this.getValue(KEY_MANDATORY_COLUMNS);
		
		var dummyJson = {};
		
		for (var i = 0; i < arrayJs.length; i++) {
			dummyJson[ arrayJs[i] ] = arrayJs[i];
		}
		
		return arrayJs;
	}

	ENOXImportItemUX.prototype.getMissingMandatoryColumns = function () {
		if ( this.isMandatoryColumnMissing() ) {
			var missingColumns = this.splitData( this.getValue(KEY_MANDATORY_COLUMN_MISSING) );
			
			var allMandColumns = this.getAllMandatoryColumns();
			
			var missMandColumnJson = {};
			
			for (var i = 0; i < missingColumns.length; i++) {
				missMandColumnJson[ missingColumns[i] ] = allMandColumns[ missingColumns[i] ];
			}
			
			return missMandColumnJson;
		}
		
		return {};
	}
	
	ENOXImportItemUX.prototype.getMissingMandatoryColumnsDisplayValues = function () { return this.getAllValuesFromJson( this.getMissingMandatoryColumns() ); }
	
	
	ENOXImportItemUX.prototype.getAllValuesFromJson = function (jsonInfoObj) {
		var values = [];
		
		var index = 0;
		for (var jsonInfo in jsonInfoObj) { values[index++] = jsonInfoObj[jsonInfo]; }
		
		return values;
	}
	
	ENOXImportItemUX.prototype.getAllKeysFromJson = function (jsonInfoObj) {
		var values = [];
		
		var index = 0;
		for (var jsonInfo in jsonInfoObj) { values[index++] = jsonInfo; }
		
		return values;
	}
	

	ENOXImportItemUX.prototype.splitData = function (data) { return data.split( this.getValue(KEY_DATA_SEPARATOR) ); }

	ENOXImportItemUX.prototype.getMappedSpreadsheetColumns = function () { return this.jsonImportValidationResults[KEY_SPREADSHEET_MAPPED_COLUMNS]; }

	ENOXImportItemUX.prototype.getUnMappedSpreadsheetColumns = function () {
		var columnsNames = [];
		
		if (this.containsKey(KEY_SPREADSHEET_UNMAPPED_COLUMNS)) {
			columnsNames = this.splitData( this.getValue(KEY_SPREADSHEET_UNMAPPED_COLUMNS) );
		}
		
		return columnsNames;
	}

	ENOXImportItemUX.prototype.isUnMappedColumnExists = function () { return this.getUnMappedSpreadsheetColumns().length > 0; }
	
	ENOXImportItemUX.prototype.getBasicsList = function () { return this.getValue(KEY_BASIC_ATTRIBUTES); }
	
	ENOXImportItemUX.prototype.getObjectAttributeList = function () { return this.getValue(KEY_TYPE_ATTRIBUTES); }
	
	ENOXImportItemUX.prototype.getRelationShipAttributeList = function () { return this.getValue(KEY_RELATIONSHIP_ATTRIBUTES); }

	ENOXImportItemUX.prototype.isValidation_Success = function () { return (this.getValue(KEY_VALIDATION_ACTION) == ACTION_SUCCESS); }

	ENOXImportItemUX.prototype.isValidation_Error = function () { return (this.getValue(KEY_VALIDATION_ACTION) == ACTION_ERROR); }
	
	ENOXImportItemUX.prototype.getContentErrorReports = function () { return this.jsonImportValidationResults[KEY_REPORTED_ERROR]; }

	ENOXImportItemUX.prototype.isContains = function (dataArray, data) {
		var found = false;

		for ( var i = 0; i < dataArray.length; i++) {
			if (dataArray[i] == data) {
				found = true;
				break;
			}
		}

		return found; 
	}

	ENOXImportItemUX.prototype.isRootItemCreate = function () { return parseInt( this.getValue(KEY_COUNT_ROOTITEM) ) > 0; }

	ENOXImportItemUX.prototype.getCount_AddNewInstances = function () { return ( parseInt( this.getValue(KEY_COUNT_ADDNEWINSTANCE) ) + parseInt( this.getValue(KEY_COUNT_ADDEXISTINGINSTANCE) ) ); }
	
	ENOXImportItemUX.prototype.getCount_AddNewReference = function () { return parseInt( this.getValue(KEY_COUNT_ADDNEWREFERNCE) ); }
	
	ENOXImportItemUX.prototype.getCount_AddExistingInstances = function () { return parseInt( this.getValue(KEY_COUNT_ADDEXISTINGINSTANCE) ); }

	ENOXImportItemUX.prototype.getCount_Modify = function () { return parseInt( this.getValue(KEY_COUNT_MODIFY) ); }

	ENOXImportItemUX.prototype.getCount_Remove = function () { return parseInt( this.getValue(KEY_COUNT_REMOVE) ); }

	ENOXImportItemUX.prototype.containsKey = function (key) { return this.jsonImportValidationResults.hasOwnProperty(key); }

	ENOXImportItemUX.prototype.getValue = function (key) { return ( this.containsKey(key) ) ? this.jsonImportValidationResults[key] : CONSTANT_EMPTY; }

	ENOXImportItemUX.prototype.displayImageIndicator_Error = function () {
		this.displayImageIndicator(this.getErrorIcon());
		this._importFileValidationImageIndicator.removeAttribute("id");
	}

	ENOXImportItemUX.prototype.displayImageIndicator_Success = function () {
		this.displayImageIndicator( this.getSucessIcon() );
		this._importFileValidationImageIndicator.setAttribute("id", "success_image_indicator");
	}

	ENOXImportItemUX.prototype.displayImageIndicator = function (imageIndicator) { this._importFileValidationImageIndicator.innerHTML = imageIndicator; }

	ENOXImportItemUX.prototype.setValidationMessage = function (validationMessage) { this._importFileValidationResultDescriptions.innerHTML = validationMessage; }

	ENOXImportItemUX.prototype.displayReportedError = function () {
		this.displayImageIndicator_Error();

		var validationMessage = this.getValue(KEY_ERROR_MESSAGE);

		if (validationMessage == CONSTANT_EMPTY) {
			var errorCount = this.getValue(KEY_ERROR_COUNT);

			validationMessage = "<span class=\"enox-import-text-underline\">" + errorCount + CONSTANT_SINGLE_SPACE + enoXImportItemUX.i18nManager.get("eng.import.summary.contenterrorexists") + "</span>";
            
            this.createOnClickEventForErrorReports();
		}else{
			validationMessage = CONSTANT_SPAN_TAG_RED_TEXT + validationMessage + CONSTANT_SPAN_END_TAG;
		}

		this.setValidationMessage(validationMessage);
	}

	ENOXImportItemUX.prototype.displayManageHeaderLink = function () {
		this._importFileManageHeader.innerHTML = "<span class\"enox-import-text-underline\">" + enoXImportItemUX.i18nManager.get("eng.import.label.managecolumnnames") + "</span>";
        
        this.createOnClickEventForManageHeaderName();
	}
	
	ENOXImportItemUX.prototype.getElementId = function (divName) { return divName.replace(" ", "_") + "_ID"; }
	
	ENOXImportItemUX.prototype.createLoaderVisualCue = function () {
		if (enoXImportItemUX.loaderVisualCue == CONSTANT_EMPTY) {
			enoXImportItemUX.loaderVisualCue = UWA.createElement(CONSTANT_WIDGET_DIV);
			
			enoXImportItemUX.loaderVisualCue.className = "enox-import-file-loader";
		} 
		
		return enoXImportItemUX.loaderVisualCue; 
	}
	
	ENOXImportItemUX.prototype.showLoaderVisualCue = function (operationTobePerformed) {
		var loaderVisualCue = enoXImportItemUX.createLoaderVisualCue();
			
		enoXImportItemUX.clearMessagesDisplayedOnUX();

		enoXImportItemUX._importFileValidationResultDescriptions.innerHTML = CONSTANT_SPAN_TAG_BLACK_BOLD_TEXT + getVisualCueMessage(operationTobePerformed) + CONSTANT_SPAN_END_TAG;
		
		enoXImportItemUX._importFileValidationImageIndicator.appendChild(loaderVisualCue);
	}
	
	function getVisualCueMessage(operationTobePerformed){
		var message = "";
		if("Author"== operationTobePerformed){
			message = enoXImportItemUX.i18nManager.get("eng.import.VisualCueAuthoringMessage")+"...";
		}else if("Validate"== operationTobePerformed){
			message = enoXImportItemUX.i18nManager.get("eng.import.VisualCueValidateMessage")+"...";
		}
		return message;
	}
	
	ENOXImportItemUX.prototype.clearMessagesDisplayedOnUX = function () {
		enoXImportItemUX._importFileValidationImageIndicator.innerHTML = "";
		enoXImportItemUX._importFileValidationResultDescriptions.innerHTML = "";
		enoXImportItemUX._importFileManageHeader.innerHTML = "";
	}
	
	ENOXImportItemUX.prototype.hideLoaderVisualCue = function () { 
		enoXImportItemUX._importFileValidationImageIndicator.innerHTML = "";
		enoXImportItemUX._importFileValidationResultDescriptions.innerHTML = "";
	}
	
	ENOXImportItemUX.prototype.getCountMessage = function (summaryMessage, count) {
		var spaces = (this.getCount_Modify() > 0) ? (CONSTANT_HTML_SPACE + CONSTANT_HTML_SPACE + CONSTANT_HTML_SPACE + CONSTANT_HTML_SPACE + CONSTANT_HTML_SPACE) : "";
		
		return CONSTANT_SPAN_TAG_GREEN_TEXT + spaces + count + " " + summaryMessage + CONSTANT_SPAN_END_TAG;
	}

	ENOXImportItemUX.prototype.displayActionSummaryReport = function () {
		this.displayImageIndicator_Success();

		var importSummaryReport = CONSTANT_EMPTY;
		
		var spaces = (this.getCount_Modify() > 0) ? (CONSTANT_HTML_SPACE + CONSTANT_HTML_SPACE + CONSTANT_HTML_SPACE + CONSTANT_HTML_SPACE + CONSTANT_HTML_SPACE + CONSTANT_HTML_SPACE) : CONSTANT_HTML_SPACE;

		if ( this.isRootItemCreate() ) {
			importSummaryReport = CONSTANT_SPAN_TAG_GREEN_TEXT + spaces + enoXImportItemUX.i18nManager.get("eng.import.summary.rootitemcreate") + CONSTANT_SPAN_END_TAG;
		} else {
			if(this.getCount_AddNewReference() == 0 && this.getCount_AddNewInstances() == 0 && this.getCount_Modify() == 0 ){
				this.displayImageIndicator(this.getWarningIcon());
				importSummaryReport = CONSTANT_SPAN_TAG_GRAY_TEXT + spaces + enoXImportItemUX.i18nManager.get("eng.import.summary.noItemModification") + CONSTANT_SPAN_END_TAG;
				this.disableImportButton();
			}else{
				importSummaryReport = CONSTANT_SPAN_TAG_GREEN_TEXT + spaces + enoXImportItemUX.i18nManager.get("eng.import.summary.rootitemupdate") + CONSTANT_SPAN_END_TAG;
			}
		}

		if ( this.getCount_AddNewReference() > 0 ) {
            if (importSummaryReport != CONSTANT_EMPTY) { importSummaryReport += CONSTANT_BREAK; }
            importSummaryReport += this.getCountMessage( enoXImportItemUX.i18nManager.get("eng.import.summary.addnewitems"), this.getCount_AddNewReference() );
		}
		
		if ( this.getCount_AddNewInstances() > 0 ) {
			if (importSummaryReport != CONSTANT_EMPTY) { importSummaryReport += CONSTANT_BREAK; }
			importSummaryReport += this.getCountMessage( enoXImportItemUX.i18nManager.get("eng.import.summary.addnewinstances"), this.getCount_AddNewInstances() );
		}

		if ( this.getCount_Modify() > 0 ) {
            if (importSummaryReport != CONSTANT_EMPTY) { importSummaryReport += CONSTANT_BREAK; }
			importSummaryReport += this.getWarningIcon() + CONSTANT_SINGLE_SPACE + CONSTANT_SPAN_TAG_YELLOW_TEXT + this.getCount_Modify() + CONSTANT_SINGLE_SPACE + enoXImportItemUX.i18nManager.get("eng.import.summary.existingitemmodify") + CONSTANT_SPAN_END_TAG;
		}
		
		this.setValidationMessage(importSummaryReport);
	}
    
    ENOXImportItemUX.prototype.getFooter = function () {
        return "<button type='button' disabled='true' id='" + KEY_IMPORT + "' class='btn btn-primary'>" + this.i18nManager.get("eng.ui.button.import") + "</button>" + 
               "<button type='button' id='" + KEY_CANCEL_BUTTON + "' class='btn btn-default'>" + this.i18nManager.get("eng.ui.button.cancel") + "</button>";
	}
    
    ENOXImportItemUX.prototype.downloadTemplateFile = function () {
    	var filename = "Create from Spreadsheet Template";
    	var fileContent = "Level,Title,Type,Name,Revision,Description,Enterprise Item Number,Instance Name";
    	this.appCore.exportService.downloadFile(filename,fileContent,'.csv',false);
	}
    
    ENOXImportItemUX.prototype.mergeExportColumnAndAttributesInfo = function(attributes) {
    	var defaultAttributes = this.appCore.dataService.getAvailableAttributesByType([XEngineerConstants.TYPE_VPMREFERENCE]);
    	var removeBasicAttributes = ["identifier","type","revision"];
    	for (var i = 0; i < defaultAttributes.length; i++) {
    		var attributeValue = defaultAttributes[i].sixWTag.replace("ds6w:","").replace("ds6wg:","");
    		if(enoXImportItemUX.isContains(removeBasicAttributes,attributeValue)){	continue;	}
    		else{
    			attributes[defaultAttributes[i].attrNls]=attributeValue;
    		}
		}
    	return attributes;
    }
    
    ENOXImportItemUX.prototype.createOnClickEventForTemplateDownload = function () {
    	var that = this;
    	this._importFileTemplateDownload.onclick =  function() {
    		that.downloadTemplateFile();
    	};
    }
    
	ENOXImportItemUX.prototype.createImportTemplateDownloadLink = function () {
		var that = this;
		
		this._importFileTemplateDownload.innerHTML =  this.getDownloadIcon() + CONSTANT_HTML_SPACE + this.i18nManager.get("eng.ui.import.downloadtemplate");
		this.createOnClickEventForTemplateDownload();
	}

	ENOXImportItemUX.prototype.createImportFileChooser = function () {
		this._importFileChooserLabel.innerHTML = " " + this.i18nManager.get("eng.ui.import.filechooserlabel");
        
        this._importFileChooserElement = new UWA.Controls.Input.File({
            
            events: {
                onChange: function () {
                    var elems = enoXImportItemUX.modal.getContent().getElement('.uwa-file').getChildren() [0].files[0];
                    
                    enoXImportItemUX.clearUserMappedColumnCache();
        
                    if (elems == undefined) { enoXImportItemUX.clearMessagesDisplayedOnUX(); }
                    
                    else {
                        if ( enoXImportItemUX.isSupportedFileFormat(elems) ) { enoXImportItemUX.doServerCall("Validate"); }
                        
                        else {
                        	enoXImportItemUX.displayImageIndicator_Error();
                        	enoXImportItemUX.setValidationMessage( CONSTANT_SPAN_TAG_RED_TEXT + enoXImportItemUX.i18nManager.get("eng.ui.alert.file.type") + CONSTANT_SPAN_END_TAG );
                        	enoXImportItemUX.clearTransactionCachedInfo();
                        	enoXImportItemUX._importFileManageHeader.innerHTML = "";
                        	enoXImportItemUX.disableImportButton();
                        }
                	}
                }
            }
        }).inject(this._importFileChooser);
    }
	
	ENOXImportItemUX.prototype.doServerCall = function (operationTobePerformed) {
        var elems = enoXImportItemUX.modal.getContent().getElement('.uwa-file').getChildren()[0].files[0];

    	enoXImportItemUX.showLoaderVisualCue(operationTobePerformed);
    	
    	var jsonFormImportInputData = { };
		
		jsonFormImportInputData["operation"] = operationTobePerformed;
		jsonFormImportInputData["ContextEntityPhysicalId"] = enoXImportItemUX.getContextPhysicalId();
		
		
		var ignoreColumns = enoXImportItemUX.getUserIgnoreColumnsFromManageHeaders();
		
		jsonFormImportInputData[KEY_IGNORE_COLUMN_LIST] = ignoreColumns; 
		jsonFormImportInputData["userMappedColumns"] = enoXImportItemUX.getUserMappedColumnValuesFromManageHeaders();
    	
		ImportService.getResults(elems, jsonFormImportInputData).then(function(res) {
			
			enoXImportItemUX.hideLoaderVisualCue();
			if(res.error){
				enoXImportItemUX.clearTransactionCachedInfo();
				enoXImportItemUX.displayUnExpectedErrors(res.response);
			}
			else{
				var resultJson = JSON.parse(res);
				resultJson[KEY_IGNORE_COLUMN_LIST] = ignoreColumns;

				if ("Validate" == operationTobePerformed) {		
					
					if(resultJson["Action"]=="Error"){
						enoXImportItemUX.clearTransactionCachedInfo();
						enoXImportItemUX._importFileValidationResultDescriptions.innerHTML = CONSTANT_SPAN_TAG_RED_TEXT + resultJson.ErrorMessage + CONSTANT_SPAN_END_TAG;
					}
					
		            enoXImportItemUX.setValidationResults(resultJson);
		        
		            enoXImportItemUX.displayValidationResultsOnUX();
				}
				
				else {
					enoXImportItemUX.clearTransactionCachedInfo();
					enoXImportItemUX.refreshOnSuccess(resultJson); 
				}
			}

		});
	}
	
	ENOXImportItemUX.prototype.displayUnExpectedErrors = function (errorMessage) {
		this.displayImageIndicator_Error();
		var validationMessage = CONSTANT_SPAN_TAG_RED_TEXT + errorMessage + CONSTANT_SPAN_END_TAG;
		
		this.setValidationMessage(validationMessage);
		this.enableCancelButton();
	}
	
	ENOXImportItemUX.prototype.enableManageHeaderOkButton = function (enableORDisableOkbutton) { document.querySelector('#manageHeaderOkButton').dsModel.disabled = !enableORDisableOkbutton; }
    
    ENOXImportItemUX.prototype.createOnClickEventForManageHeaderName = function () {
    	var that = this;
		this._importFileManageHeader.onclick = function() {
	    	var manageHeader = createManageHeaderContent();

			var manageHeaderImmersiveFrame = new ImmersiveFrame();
			manageHeaderImmersiveFrame.inject(enoXImportItemUX.modal.modal.elements.container);
			
			that.manageHeaderDialogbox = new Dialog( {
				
				 title: enoXImportItemUX.i18nManager.get("eng.import.ManageHeaderDialogboxTitle"),
                 content: manageHeader,
                 width: 536,
                 height: 350,
                 position: {
                     at: "top center",
                     my: "center"
                 },
                 immersiveFrame: manageHeaderImmersiveFrame,
                 resizableFlag: true,
                 buttons: {
					Cancel: new Button({
						label: that.i18nManager.get("eng.ui.button.cancel"),
						onClick: function (e) {
							enoXImportItemUX.restorePreviousHeaderValuesOnCancel();
							
							enoXImportItemUX.manageHeaderDialogbox.immersiveFrame.getModel().elements.container.destroy();
						}
					}),
					
					Ok: new Button({
						label: that.i18nManager.get("eng.ui.button.ok"),
						
						domId : "manageHeaderOkButton",
						onClick: function (e) {
							clearCurrentSelectedHeaderValues();								
						
							enoXImportItemUX.doServerCall("Validate");

							enoXImportItemUX.manageHeaderDialogbox.immersiveFrame.getModel().elements.container.destroy();
						}
					})
				}
			} );
			
			enoXImportItemUX.manageHeaderDialogbox.addEventListener("close", function(e) {
				enoXImportItemUX.restorePreviousHeaderValuesOnCancel();
				
				enoXImportItemUX.manageHeaderDialogbox.immersiveFrame.getModel().elements.container.destroy();
             }); 
			
			enoXImportItemUX.manageHeaderDialogbox.getContent().getElements('.enox-import-columnmapping-checkbox').forEach(function(element) {
		            	element.addEvent("click", function(event) {
		            	var id = element.children[0].dsModel.value;
	            	
		            	var cboxId = enoXImportItemUX.userMappedColumnHeadersColumns[id];
	            	
		            	var selectedCheckBOx = element.children[0].dsModel; 
	            	
		            	if (!selectedCheckBOx.checkFlag) {
		            		cboxId.value = undefined;
		            	}
	            	
		            	enoXImportItemUX.validateUserMappedColumns(null);
	            	})
	        });
			
			enoXImportItemUX.displayUnMappedUserMessage();
			
			enoXImportItemUX.displayMandColumnsMissingErrorMessageonUX( enoXImportItemUX.getMissingMandatoryColumnsDisplayValues() );
	    }; 
    }
    
    ENOXImportItemUX.prototype.createOnClickEventForErrorReports = function () {
    	this._importFileValidationResultDescriptions.onclick =  function() {
    		enoXImportItemUX.createDataGridErrorContentReports();
    	};
    }
    
    ENOXImportItemUX.prototype.getContentErrorNotes = function () { return  this.i18nManager.get("eng.import.error.ContentErrorNotes"); }
    
    ENOXImportItemUX.prototype.restorePreviousHeaderValuesOnCancel = function () {
    	var cachedTempHeaderValues = getCurrentSelectedHeaderValues();
    	
    	var cachedHeaderValues = enoXImportItemUX.getUserMappedColumnsCBoxFromManageHeaders();
    	
    	var comboxElement;
    	
    	for (var column in cachedHeaderValues) {
    		if ( column.indexOf("_CheckBox") > -1 ) { continue; }

    		comboxElement = cachedHeaderValues[column];
    		
    		comboxElement.value = cachedTempHeaderValues[column];
    	}
    	
    	clearCurrentSelectedHeaderValues();
    }
    
    ENOXImportItemUX.prototype.createOnClickEventForCancelButton = function () {
    	var that1 = this;
    	document.getElementById(KEY_CANCEL_BUTTON).onclick =  function() {
    		enoXImportItemUX.clearTransactionCachedInfo();
    		that1.modal.destroy();
    	};
    }
    
    ENOXImportItemUX.prototype.createDataGridErrorContentReports = function () {
  		var reportedErrorColumns = 
  		  	[
  		  		  {
  		  			"text" : enoXImportItemUX.i18nManager.get("eng.import.contenterrorreport.rownumber"),
  		            "dataIndex" : "RowNumber"
  		  		  },
  		  		
  				 {
  		            "text" : enoXImportItemUX.i18nManager.get("eng.import.contenterrorreport.errordescription"),
  		            "dataIndex" : "Error Description"
  		         },
  		  		  
  		  		  {
  		  			  "text" : enoXImportItemUX.i18nManager.get("eng.import.contenterrorreport.columnname"),
  		  			  "dataIndex" : "Column Name"
  		  		  },
  		  		  
  		  		  {
  		  			  "text" : enoXImportItemUX.i18nManager.get("eng.import.contenterrorreport.columnvalue"),
  		  			  "dataIndex" : "Column Value"
  		  		  }
  	  		];
    	
		var dataModelSet = new DataModelSet();
	   	   
   	    var model = new TreeDocument( { dataModelSet: dataModelSet } );
	   	   
	   	model.prepareUpdate();
	   	
	   	var ReportedErrors = enoXImportItemUX.getContentErrorReports(); 
		
		for (var i = 0, len = ReportedErrors.length; i < len; i++) {
			var nodeData = ReportedErrors[i];
			   
			var aNode = TreeNodeModel.createTreeNodeDataModel( dataModelSet, {
																				label : nodeData.text,
																				grid : nodeData
																			} );
			model.addChild(aNode);
		}

	    model.expandAll();

	    model.pushUpdate();

		var dialogboxContent = UWA.createElement(CONSTANT_WIDGET_DIV);
		dialogboxContent.className = "enox-import-dialogboxContent";

		var dialogboxHeaderContent = document.createElement(CONSTANT_WIDGET_DIV);
		dialogboxHeaderContent.className = "dialogboxHeaderContent";

	    var dialogboxBodyContent = document.createElement(CONSTANT_WIDGET_DIV);
		dialogboxBodyContent.className = "enox-import-dialogboxBodyContent";

	    var dataGridView = new DataGridView( {
									         treeDocument: model,
									         
									         columns: reportedErrorColumns,
									         
									       	 defaultColumnDef: {
										         "width": "auto",
										     	 "typeRepresentation": "string"
									         }
     
									     } ).inject(dialogboxBodyContent);


	    var immersiveFrame = new ImmersiveFrame();
		immersiveFrame.inject(enoXImportItemUX.modal.modal.elements.container);

		dialogboxHeaderContent.innerHTML = enoXImportItemUX.getContentErrorNotes();
		dialogboxContent.appendChild(dialogboxHeaderContent);
		dialogboxContent.appendChild(dialogboxBodyContent);
			
		var editTemplateDialogbox = new Dialog( {
													title : enoXImportItemUX.i18nManager.get("eng.import.validateImportTitle"),
													content: dialogboxContent,
													immersiveFrame: immersiveFrame,
													resizableFlag: true,
													 position: {
									                     at: "top center",
									                     my: "center"
									                 },
													buttons: {
														Cancel: new Button({
															label:  enoXImportItemUX.i18nManager.get("eng.ui.button.cancel"),
															
															onClick: function (e) {
																editTemplateDialogbox.immersiveFrame.getModel().elements.container.destroy();
															}
														}),
													}
												} );
		 
		editTemplateDialogbox.addEventListener("close", function (e) {
			editTemplateDialogbox.immersiveFrame.getModel().elements.container.destroy();
		});
	}
    
    ENOXImportItemUX.prototype.enableImportButton = function () { document.getElementById(KEY_IMPORT).disabled = false; }
    
    ENOXImportItemUX.prototype.disableImportButton = function () { document.getElementById(KEY_IMPORT).disabled = true; }
    
    ENOXImportItemUX.prototype.disableCancelButton = function () { document.getElementById(KEY_CANCEL_BUTTON).disabled = true; }
    
    ENOXImportItemUX.prototype.enableCancelButton = function () { document.getElementById(KEY_CANCEL_BUTTON).disabled = false; }
    
    ENOXImportItemUX.prototype.getRootPhysicalId = function (result) { return result[KEY_ROOT_PHYSICAL_ID]; }
    
    ENOXImportItemUX.prototype.refreshOnSuccess = function(result) {
    	enoXImportItemUX.modal.destroy();
    	this.appCore.sessionManager.setAuthoringMode('authoring');
    	
    	enoXImportItemUX.appCore.mediator.publish(XEngineerConstants.EVENT_LAUNCH_COMMAND,{
            commandId: XEngineerConstants.OPEN_ENG_ITEM,
            context: {
                item: {
                  objectId: enoXImportItemUX.getRootPhysicalId(result),
                  objectType: XEngineerConstants.TYPE_VPMREFERENCE //createdItem.type
                }
              }
          });
    }
    
	ENOXImportItemUX.prototype.createOnClickEventForImport = function () {
    	document.getElementById(KEY_IMPORT).onclick = function() {
    		enoXImportItemUX.disableImportButton();
    		enoXImportItemUX.disableCancelButton();
    		enoXImportItemUX.doServerCall("Author");
		}
	}

	ENOXImportItemUX.prototype.getUserMappedColumnValuesFromManageHeaders = function () {
		var jsonUserMappedColumns = enoXImportItemUX.getUserMappedColumnsCBoxFromManageHeaders();
		
		var jsonSelectedValues = {};
		
		for (var column in jsonUserMappedColumns) {
			if ( column.indexOf("_CheckBox") > -1 ) { continue; }
			
			var userSelectedCombox = jsonUserMappedColumns[column];
			
			if (userSelectedCombox.value == undefined) { continue; }
			
			jsonSelectedValues[column] = userSelectedCombox.value;
		}
		
		return jsonSelectedValues;
	}
	
	ENOXImportItemUX.prototype.getUserIgnoreColumnsFromManageHeaders = function () {
		var jsonUserMappedColumns = enoXImportItemUX.getUserMappedColumnsCBoxFromManageHeaders();
		
		var ignoreColumns = "";
		
		for (var column in jsonUserMappedColumns) {
			if ( column.indexOf("_CheckBox") > -1 ) { continue; }

			var userSelectedCombox = jsonUserMappedColumns[column];
			
			if (userSelectedCombox.value == undefined) {
				ignoreColumns = (ignoreColumns == "") ? column : (ignoreColumns + "|@|" + column);
			}
		}
		
		return ignoreColumns;
	}
	
	ENOXImportItemUX.prototype.clearUserMappedColumnCache = function () { this.userMappedColumnHeadersColumns = {}; }
	
	ENOXImportItemUX.prototype.getUserMappedColumnsCBoxFromManageHeaders = function () { return this.userMappedColumnHeadersColumns; }
	
	ENOXImportItemUX.prototype.getUnMappedIgnoredSpreadsheetColumns = function () {
		var columnsNames;
		
		if (this.containsKey(KEY_IGNORE_COLUMN_LIST)) {
			columnsNames = this.splitData( this.getValue(KEY_IGNORE_COLUMN_LIST) );
			if(columnsNames.length==1 && columnsNames[0]=="" || columnsNames[0]==null){
				columnsNames = [];
			}
		}
		
		return columnsNames;
	}
	
	ENOXImportItemUX.prototype.displayUnMappedUserMessage = function () {
		if (enoXImportItemUX.getUnMappedSpreadsheetColumns().length > 0 || enoXImportItemUX.getUnMappedIgnoredSpreadsheetColumns().length > 0) {
			var length = (enoXImportItemUX.getUnMappedSpreadsheetColumns().length > 0 )?enoXImportItemUX.getUnMappedSpreadsheetColumns().length : enoXImportItemUX.getUnMappedIgnoredSpreadsheetColumns().length;
			document.getElementsByClassName("importColumnContainerForErrorMessage")[0].innerHTML = "<span><b>" + length + "</b>" + CONSTANT_HTML_SPACE + enoXImportItemUX.i18nManager.get("eng.import.summary.unmappedcolumnexists") + "</span>";
		} else {
			document.getElementsByClassName("importColumnContainerForErrorMessage")[0].innerHTML = "<span>" + enoXImportItemUX.i18nManager.get("eng.import.summary.allmappedcolumnexists") + "</span>";
		}
	}
	
	ENOXImportItemUX.prototype.displayUnMappedUserMessageOnUserSelection = function (unmappedColumnCount) {
		if (unmappedColumnCount > 0) {
			document.getElementsByClassName("importColumnContainerForErrorMessage")[0].innerHTML = "<span><b>" + unmappedColumnCount + "</b>" + CONSTANT_HTML_SPACE + enoXImportItemUX.i18nManager.get("eng.import.summary.unmappedcolumnexists") + "</span>";
		} else {
			document.getElementsByClassName("importColumnContainerForErrorMessage")[0].innerHTML = "<span>" + enoXImportItemUX.i18nManager.get("eng.import.summary.allmappedcolumnexists") + "</span>";
		}
	}
	
	ENOXImportItemUX.prototype.displayMandColumnsMissingErrorMessageonUX = function (columnMissingArray) {
		if (columnMissingArray.length > 0) {
			enoXImportItemUX.enableManageHeaderOkButton(false);
			var message = enoXImportItemUX.i18nManager.get("eng.import.manageheader.mandcolumnsmissing");
			message = message.replace("$1", columnMissingArray);
			document.getElementsByClassName("importMandColumnMissingContainerForErrorMessage")[0].innerHTML = CONSTANT_SPAN_TAG_RED_TEXT + message + CONSTANT_SPAN_END_TAG;
		} else {
			enoXImportItemUX.enableManageHeaderOkButton(true);
			document.getElementsByClassName("importMandColumnMissingContainerForErrorMessage")[0].innerHTML = CONSTANT_SPAN_TAG_GREEN_TEXT + enoXImportItemUX.i18nManager.get("eng.import.manageheader.allmandattributesmapped") + CONSTANT_SPAN_END_TAG;
		}
	}
	
	ENOXImportItemUX.prototype.clearManageHeaderSameAttributeErrorMessage = function () {
		document.getElementsByClassName("importColumnContainerForErrorMessage")[0].innerHTML = "";
	}
	
	ENOXImportItemUX.prototype.isSupportedFileFormat = function (fileChooserElement) {
		var supportedFileFormat = false;
		var fileName = fileChooserElement["name"];
		
		for (var i = 0; i < supportedFileFormats.length; i++) {
		    if ( fileName.endsWith( supportedFileFormats[i] ) ) { supportedFileFormat = true; break; }
		}
		
		return supportedFileFormat;
	}
	
	function getIgnoredMandColumns(userMappedJson) {
		var mandColumnsJson = enoXImportItemUX.getAllMandatoryColumns();
		
		var mandColumnsIgnoredArray = [];
		var mandColumnMissingCount = 0;
		
		for (var column in mandColumnsJson) {
			if ( !userMappedJson.hasOwnProperty(column) ) {
				mandColumnsIgnoredArray[mandColumnMissingCount++] = mandColumnsJson[column];
			}
		}
		
		return mandColumnsIgnoredArray;
	}
	
	ENOXImportItemUX.prototype.hideAlreadyMappedValues = function(){
		var userMappedValues = enoXImportItemUX.getAllValuesFromJson( enoXImportItemUX.getUserMappedColumnValuesFromManageHeaders() );
		var jsonUserMappedColumns = enoXImportItemUX.getUserMappedColumnsCBoxFromManageHeaders();
		
		for (var columnJson in jsonUserMappedColumns) {
			var cBOXElemet = jsonUserMappedColumns[columnJson];
			
			var length = (cBOXElemet._allDescendants && cBOXElemet._allDescendants.length)?cBOXElemet._allDescendants.length:0;
			for(var i = 0; i < length-1; i++){
					var val = cBOXElemet._allDescendants[i].getLabel();
					var valueItem = cBOXElemet._allDescendants[i].options.grid.valueItem;
					if(enoXImportItemUX.isContains(userMappedValues,valueItem)){
						cBOXElemet._allDescendants[i].hide();
					}else {
						cBOXElemet._allDescendants[i].show();
					}
			}
		}
	}
	
	ENOXImportItemUX.prototype.validateUserMappedColumns = function(manageHeaderColumnEvent){
		var jsonUserMappedColumns = enoXImportItemUX.getUserMappedColumnsCBoxFromManageHeaders();
		
		if (manageHeaderValidateMethodEnteredCount == 0) {
			enoXImportItemUX.clearManageHeaderSameAttributeErrorMessage();
		}
		
		manageHeaderValidateMethodEnteredCount = manageHeaderValidateMethodEnteredCount + 1;
		
		var currentComboxDomId = (manageHeaderColumnEvent == null) ? "" : manageHeaderColumnEvent.dsModel.domId;
		
		var enableOkButton = true;
		
		var jsonSelectedValues = {};
		
		var unMappedColumnCount = 0;
		
		var dupAttributeNameSelected = false;
		
		for (var column in jsonUserMappedColumns) {
			if ( column.indexOf("_CheckBox") > -1 ) { continue; }
			
			var userSelectedCombox = jsonUserMappedColumns[column];
			var userSelectedCheckbox = jsonUserMappedColumns[column + "_CheckBox"];
			
			if (userSelectedCombox.value == undefined) {
				if (userSelectedCheckbox.checkFlag) { enableOkButton = false; }
				unMappedColumnCount = unMappedColumnCount + 1;
				continue;
			}
			
			if ( jsonSelectedValues.hasOwnProperty( userSelectedCombox.value) ) {
				enableOkButton = false;
				
				dupAttributeNameSelected = true;
				
				if (userSelectedCombox.domId == currentComboxDomId) { // if user selects 2 Attribute Name to same column Name
					userSelectedCombox.value = undefined;
				} else {
					var storedCBox = jsonSelectedValues[userSelectedCombox.value];
					storedCBox.value = undefined;
				}
				
				break;
			}
			
			if (userSelectedCombox.domId == currentComboxDomId && userSelectedCombox.value != undefined) {
				userSelectedCheckbox.checkFlag = true;
			}
			
			jsonSelectedValues[userSelectedCombox.value] = userSelectedCombox;
		}
		
		enoXImportItemUX.displayMandColumnsMissingErrorMessageonUX( getIgnoredMandColumns(jsonSelectedValues) );
		
		if (!dupAttributeNameSelected) {
			enoXImportItemUX.displayUnMappedUserMessageOnUserSelection(unMappedColumnCount);
		}
		
		manageHeaderValidateMethodEnteredCount = 0;
		
	}
	
    ENOXImportItemUX.prototype.getManageHeaderNotes = function () {
    	return enoXImportItemUX.i18nManager.get("eng.import.alert.manageheadernotes");
    }
    
	function createManageHeaderContent() {
		var allMandColumns = enoXImportItemUX.getAllMandatoryColumns();
		
		var importColumnContainer = UWA.createElement(CONSTANT_WIDGET_DIV);
  		importColumnContainer.className = "enox-import-columncontainer";

		var importColumnContainerForInfo = UWA.createElement(CONSTANT_WIDGET_DIV);
		importColumnContainerForInfo.className = "enox-import-importColumnContainerForInfo";
		
		var importColumnContainerForErrorMessage = UWA.createElement(CONSTANT_WIDGET_DIV);
		importColumnContainerForErrorMessage.className = "importColumnContainerForErrorMessage";
		
		var importMandColumnMissingContainerForErrorMessage = UWA.createElement(CONSTANT_WIDGET_DIV);
		importMandColumnMissingContainerForErrorMessage.className = "importMandColumnMissingContainerForErrorMessage";
		
		var divTagForImportTableHeader = UWA.createElement(CONSTANT_WIDGET_DIV);
  		divTagForImportTableHeader.id = "enox-import-columns_container_list";

  		importColumnContainerForInfo.innerHTML = enoXImportItemUX.getManageHeaderNotes()+CONSTANT_BREAK;
		importColumnContainer.appendChild(importColumnContainerForErrorMessage);
		importColumnContainer.appendChild(importMandColumnMissingContainerForErrorMessage);
		
  		importColumnContainer.appendChild(divTagForImportTableHeader);
  		
  		var liTagForImportTableRows = UWA.createElement(CONSTANT_WIDGET_DIV);
  		liTagForImportTableRows.id = "columns_with_import_list";
  		liTagForImportTableRows.className = "enox-import-columnsHeaderForImport";
  		
  		var headerChecboxDiv = UWA.createElement(CONSTANT_WIDGET_DIV);
  		headerChecboxDiv.className = "enox-import-column-checkbox";
  		headerChecboxDiv.innerHTML = "";
  		liTagForImportTableRows.appendChild(headerChecboxDiv);
  		
  		var headerNameDiv = UWA.createElement(CONSTANT_WIDGET_DIV);
  		headerNameDiv.className = "enox-import-listitem_header_name";
  		liTagForImportTableRows.appendChild(headerNameDiv);

  		var customNameDiv = UWA.createElement(CONSTANT_WIDGET_DIV);
  		customNameDiv.className = "enox-import-listitem_custom_name";
  		liTagForImportTableRows.appendChild(customNameDiv);
  		
  		headerNameDiv.innerHTML = "<b>" + enoXImportItemUX.i18nManager.get("eng.import.manageheader.spreadsheetcolumn") + "</b>";
  		customNameDiv.innerHTML = "<b>" + enoXImportItemUX.i18nManager.get("eng.import.manageheader.schemaname") + "</b>";
  		
  		divTagForImportTableHeader.appendChild(liTagForImportTableRows);
  		
  		var divTagForAllColumns = UWA.createElement(CONSTANT_WIDGET_DIV);
		divTagForAllColumns.className = "enox-import-divTagForAllColumns";  		
  		
  		divTagForImportTableHeader.appendChild(divTagForAllColumns);
		
		//constructing mapped and unmapped values json
        var  MappedSpreadSheetColumns = enoXImportItemUX.getMappedSpreadsheetColumns();
        
        var UnmappedSpreadsheetColumns = enoXImportItemUX.getUnMappedSpreadsheetColumns();
       
        var previouslySelectedJsonUserMappedColumns = enoXImportItemUX.getUserMappedColumnsCBoxFromManageHeaders();
         
         enoXImportItemUX.clearUserMappedColumnCache();
         clearCurrentSelectedHeaderValues();
         
         //filling header names details from MappedSpreadSheetColumnsJson
 		 for (var mappedColumnKey in MappedSpreadSheetColumns) {
 			 var divTag = UWA.createElement(CONSTANT_WIDGET_DIV);

   			 divTag.className = "columns";
 			 
			if (Object.keys(MappedSpreadSheetColumns).length > CONSTANT_DIV_ITEMS_TO_SHOW) {
				 divTagForAllColumns.style.overflowY = "scroll";
			  } else {
				 divTag.style.borderRight = "1px solid #ccc";
			}
  			
  			var checkboxDiv = UWA.createElement(CONSTANT_WIDGET_DIV);
  			checkboxDiv.className = "enox-import-columnmapping-checkbox";

  			
  			var headerNameDivForRows = UWA.createElement(CONSTANT_WIDGET_DIV);
  			headerNameDivForRows.className = "enox-import-listitem_header_name hover_info";
  			
  			headerNameDivForRows.innerHTML = MappedSpreadSheetColumns[mappedColumnKey];  			
  			
  			var customNameDivForRows = UWA.createElement(CONSTANT_WIDGET_DIV);
			customNameDivForRows.className = "enox-import-listitem_custom_name display_text enable_textbox";
			
			var cboxOptionsJson = { 	
										elementsTree : enoXImportItemUX.populateComboboxContents(),
										enableSearchFlag : true,
										domId : enoXImportItemUX.getElementId(mappedColumnKey)
								   }
			
			var checkBoxEnableFlag = true;

			if ( previouslySelectedJsonUserMappedColumns.hasOwnProperty( MappedSpreadSheetColumns[mappedColumnKey] ) ) {
				var previousCbox = previouslySelectedJsonUserMappedColumns[ MappedSpreadSheetColumns[mappedColumnKey] ];
				
				if (previousCbox.value != undefined) {
					cboxOptionsJson["value"] = previousCbox.value;
				} else {
					checkBoxEnableFlag = false;
				}
			}
			
			else if ( enoXImportItemUX.isContains( UnmappedSpreadsheetColumns, MappedSpreadSheetColumns[mappedColumnKey] ) || enoXImportItemUX.isContains( enoXImportItemUX.getIgnoreColumnsArray(), MappedSpreadSheetColumns[mappedColumnKey] ) ) {
				checkBoxEnableFlag = false;
			}
			
			else if ( !enoXImportItemUX.isContains( UnmappedSpreadsheetColumns, MappedSpreadSheetColumns[mappedColumnKey] ) ) {
				cboxOptionsJson["value"] = mappedColumnKey;
			}
			
			var columnSelectCheckBox = new Toggle({
                type: "checkbox",
                checkFlag: checkBoxEnableFlag,
                value:  MappedSpreadSheetColumns[mappedColumnKey]
            });
			
			
			var cbox  = new WUXComboBox(cboxOptionsJson);
			
			
			cbox.addEventListener("change",	function(manageHeaderColumnEvent) {
				enoXImportItemUX.validateUserMappedColumns(manageHeaderColumnEvent);
			});
			
			cbox.addEventListener("preDropdown",	function(manageHeaderColumnEvent) {
				enoXImportItemUX.hideAlreadyMappedValues();
			});
			 

			enoXImportItemUX.userMappedColumnHeadersColumns[ MappedSpreadSheetColumns[mappedColumnKey] ] = cbox;
			enoXImportItemUX.userMappedColumnHeadersColumns[ MappedSpreadSheetColumns[mappedColumnKey] + "_CheckBox"] = columnSelectCheckBox;
			
			currentSelectedHeaderValues[ MappedSpreadSheetColumns[mappedColumnKey] ] = cbox.value;
			
			if(allMandColumns.hasOwnProperty(mappedColumnKey)){
				cbox["disabled"] = true;
				checkboxDiv.innerHTML = enoXImportItemUX.getBlockedIcon();
			}else{
				columnSelectCheckBox.inject(checkboxDiv);
			}
			
			cbox.inject(customNameDivForRows);
			divTagForAllColumns.appendChild(divTag);
			divTag.appendChild(checkboxDiv);
  			divTag.appendChild(headerNameDivForRows);
  			divTag.appendChild(customNameDivForRows);  			
  			
  			divTagForImportTableHeader.appendChild(divTagForAllColumns);
  		}
 		 
        return importColumnContainer;
	}
	
	ENOXImportItemUX.prototype.populateComboboxContents = function (){
		
		var cBoxTreeDocument = new TreeDocument({
		     shouldBeSelected: function(nodeModel) {
		       return nodeModel.options.comboBoxSemantics !== "section"
		     }
		});
		
		cBoxTreeDocument.addRoot(enoXImportItemUX.getObjectAttributes());
		cBoxTreeDocument.addRoot(enoXImportItemUX.getRelAttributes());
		
		cBoxTreeDocument.expandAll();
		
		  return cBoxTreeDocument;
	}
	
	ENOXImportItemUX.prototype.getObjectAttributes = function (){
		var labelItem = KEY_LABEL_ITEM;
		var valueItem = KEY_VALUE_ITEM;
		var typeAttributesHeader = {labelItem:this.i18nManager.get("eng.import.objectAttributes"),valueItem:KEY_TYPE_ATTRIBUTES};
		
		var basicAttributes =	enoXImportItemUX.getBasicsList();
		
		var objectAttributes =	enoXImportItemUX.getObjectAttributeList();

		enoXImportItemUX.updateListContents(basicAttributes,objectAttributes);
		
		return enoXImportItemUX.addAttrToRootObject(typeAttributesHeader,basicAttributes);
	}
	
	ENOXImportItemUX.prototype.getRelAttributes = function (){
		var labelItem = KEY_LABEL_ITEM;
		var valueItem = KEY_VALUE_ITEM;
		var relationAttributesHeader = {labelItem:this.i18nManager.get("eng.import.relationshipAttributes"),valueItem:KEY_RELATIONSHIP_ATTRIBUTES};
		var relationAttributes =	enoXImportItemUX.getRelationShipAttributeList();
		
		return enoXImportItemUX.addAttrToRootObject(relationAttributesHeader,relationAttributes);
	}
	
	ENOXImportItemUX.prototype.updateListContents = function (sourceList, destList){
		for (var headerValue in destList) {
			sourceList[headerValue] = destList[headerValue] ;
        }
	}
	
	ENOXImportItemUX.prototype.addAttrToRootObject = function (header,attrList){
		var root = new TreeNodeModel({
	        label: header.labelItem,
			value: header.valueItem,
	        comboBoxSemantics: "section"
		});
		
		 for (var headerValue in attrList) {
			 root.addChild(new TreeNodeModel({
		          label: attrList[headerValue],
		          grid: {
		        	    valueItem: headerValue
		          },
		          useMatchingSearchFunction: true,
		          comboBoxSemantics: "subsection"
		        })); 
		 }
		  return root;
	}
	
	function getCurrentSelectedHeaderValues() { return currentSelectedHeaderValues; }
	
	function clearCurrentSelectedHeaderValues() { currentSelectedHeaderValues = {}; }
    
    /* */


	var importEngineeringItems = XEngineerCommandBase.extend( {

		init: function (options) {
			options = UWA.extend(options, {
					isAsynchronous: false
				});
			this._parent(options);
		},

		execute: function () {
			return this.initializeENOXImportItemUX();
		},

		initializeENOXImportItemUX: function (options) {
			that = this;
			enoXImportItemUX = new ENOXImportItemUX();
			enoXImportItemUX.modal.show();
			return enoXImportItemUX;
		}
	} );

	return importEngineeringItems;

});


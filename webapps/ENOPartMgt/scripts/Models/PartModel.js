/**
 * @overview Part model
 * @licence Copyright 2006-2014 Dassault Syst�mes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOPartMgt/scripts/Models/PartModel', 
		[ 
		  'UWA/Core', 
		  'UWA/Class/Model'   
		], 
		  function(UWACore, UWAModel) {
    
    'use strict';
    
    var PartModel = UWAModel.extend({
     parse : function(resp) {

    	 var parsed = {};
//         parsed.id = resp.id;
//         parsed.type = resp.type;
//         parsed.name = resp.dataelements['Name'] != null? resp.dataelements['Name'] : "";         
//         parsed.revision = resp.dataelements['Revision'] != null? resp.dataelements['Revision'] : ""; 
//         parsed.policy = resp.dataelements['Policy'] != null? resp.dataelements['Policy'] : ""; 
//         parsed.state = resp.dataelements['State'] != null? resp.dataelements['State'] : ""; 
//         parsed.owner = resp.dataelements['Owner'] != null? resp.dataelements['Owner'] : ""; 
//         parsed.created = resp.dataelements['Created'] != null? resp.dataelements['Created'] : "";
//         parsed.project = resp.dataelements['Collabspace'] != null? resp.dataelements['Collabspace'] : ""; 
//         parsed.modified = resp.dataelements['Modified'] != null? resp.dataelements['Modified'] : ""; 
//         parsed.createdActual = (Date.parse(parsed.created))/ 1000;
//         parsed.modifiedActual = (Date.parse(parsed.modified))/ 1000;
//         parsed.description = resp.dataelements['description'] != null? resp.dataelements['description'] : ""; 
//         parsed.organization = resp.dataelements['Organization'] != null? resp.dataelements['Organization'] : "";
//         parsed.typeicon = resp.dataelements['typeicon'] != null? resp.dataelements['typeicon'] : "";
//         parsed.actionsAccess = resp.actionsAccess != null? resp.actionsAccess : {};

    	 for(var i=0;i<resp.attributes.length;i++){
    		 var value = resp.attributes[i].name;
	    	 switch(value){
	    	 	case "resourceid" :  parsed.id = resp.attributes[i].value; break;
	    	 	case "ds6w:what/ds6w:status": parsed.state = this.getState(parsed.state,resp.attributes[i].value,resp.attributes[i].dispValue);break;
	    	 	case "ds6w:identifier" : parsed.name = resp.attributes[i].dispValue;break;
	    	 	case "ds6wg:revision" : parsed.revision = resp.attributes[i].value;break;
	    	 	case "ds6w:what/ds6w:policy" : parsed.policy = resp.attributes[i].dispValue;break;
	    	 	case "ds6w:what/ds6w:type" : parsed.type = resp.attributes[i].dispValue;break;
	    	 	case "ds6w:where/ds6w:context/ds6w:project" : parsed.project = resp.attributes[i].value;break;
	    	 	case "ds6w:who/ds6w:responsible/ds6w:organizationResponsible" : parsed.organization = resp.attributes[i].value;break;
	    	 	case "ds6w:who/ds6w:responsible" : parsed.owner = resp.attributes[i].value; break;
	    	 	case "ds6w:when/ds6w:modified"  : parsed.created = resp.attributes[i].value;break;
	    	 	case "ds6w:when/ds6w:created"  : parsed.modified = resp.attributes[i].value; break;
	    	 	case (value.indexOf("ds6w:description")>-1) :parsed.description = resp.attributes[i].value; break;
	    	 	case "type_icon_url" : parsed.typeicon = resp.attributes[i].value;break;
	    	 	case "preview_url" : parsed.picture = resp.attributes[i].value;break;
	    	 	default : break;
	    	 
	    	 }
	    	 
	         var DATE_TAG_FORMAT = '%a %b %d %Y';  
	         if(parsed.created!=""){
				parsed.created = new UWA.Date(parsed.created).strftime(DATE_TAG_FORMAT);
		      } 
	
	         var key;
	         for (key in parsed) {
	             if (UWACore.owns(parsed, key) && !UWACore.is(parsed[key])) {
	                 delete parsed[key];
	             }
	         }
    	 }

         return parsed;
     },
     
     getState:function(existingStateValue,actualState,displayState){
    	 var stateValue=existingStateValue;
    	 if(actualState.split(".").length>1){
    		 stateValue = (displayState.split(".").length>1)?displayState.split(".")[1]:displayState;
    	 }
     	return stateValue;
     }
     
    });    
    return PartModel;
});

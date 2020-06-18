//=================================================================
// JavaScript Methods for Breadcrumbs
// emxBreadcrumbs.js
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//
// static const char RCSID[] = $Id: emxBreadcrumbs.js.rca 1.14 Wed Oct 22 15:48:15 2008 przemek Experimental przemek $
//=================================================================


// namespace
var backInProgress= false;
var forwardInProgress = false;
var historyLimit = getTopWindow().historyLimit? getTopWindow().historyLimit : (emxUIConstants && emxUIConstants.NUM_HISTORY_LIMIT ? emxUIConstants.NUM_HISTORY_LIMIT : 20);

var emxBreadCrumbList = emxBreadCrumbList ? emxBreadCrumbList : function(){

	var private = {
	        visitedLinks : [],
	        bcTrails: [],
	        position: 0,
	        clear: true
	};
	
	var emxBreadCrumb = emxBreadCrumb ? emxBreadCrumb : function(id1, label1 , seperator1, category1, url1, url2, categoryObj,fancyTreeJSONData, categoryDynamicName, treeURL, appInfo){

	    var public = {
	        id       			: id1,
	        label    			: label1,
	        seperator			: seperator1,
	        category 			: category1,
	        selectedId          : "",
	        structureURL		: url1,
	        pageURL      		: url2,
	        categoryObj         : categoryObj,
	        fancyTreeData		: fancyTreeJSONData,
	        categoryDynamicName : categoryDynamicName,
	        treeURL             : treeURL,
	        appInfo             : appInfo,
	        getName  : function(){
	    		if(this.category == null || this.category == "null"){
	    			return this.label;
	    		} else {
	    			return this.label + " " + this.seperator + " " + this.category;
	    		}
	    	}
	    };

	    return public;
	};
	
	var emxBreadCrumbTrail = emxBreadCrumbTrail ? emxBreadCrumbTrail : function(linksList1, position1){

	    var public = {
	    	linksList       	: linksList1 ? linksList1 : [],
	        position   			: position1 ? position1 : linksList1.length,
	        getPosition		: function () {
		    	return this.position;
	        },
	        setPosition		: function (position, deleteothers) {
		    	this.position = position;
		    	if(deleteothers){
		    		if(this.linksList.length > this.position){
	                    this.linksList.splice(this.position, this.linksList.length - this.position);
	                }
		    	}
	        },
	        getPosition		: function () {
		    	return this.position;
	        },
	        setBreadCrumb		: function (position, bc) {
	        	
	        	var newDate = new Date;
	        	var uniqueId = newDate.getTime();
	        	private.visitedLinks[uniqueId] = bc;
	            
		    	if(position){
		    		this.linksList[position - 1] = uniqueId;
		    		this.position = position;
		    	} else {
		    		this.linksList[this.position] = uniqueId;
		    		this.position = this.position + 1;
		    		this.linksList = this.linksList.splice(0, this.position);
		    	}
	        },
	        getBreadCrumb		: function (position) {
	    	    if(position){
	    	    	return this.linksList.length > 0 ? private.visitedLinks[this.linksList[position - 1]] : null;
	    	    } else {
	    	    	return this.linksList.length > 0 ? private.visitedLinks[this.linksList[this.position - 1]] : null;
	    	    }
	        },
	        length				: function () {
	    	    return this.linksList.length;
	        },
	        indexOf				: function (objectId) {
	        	for(var i = 0; i < this.linksList.length; i++ ){
	    	    	var bc = private.visitedLinks[this.linksList[i]];
	    	    	if(bc.id == objectId){
	    	    		return i + 1;
	    	    	}
	    	    }
	    	    return 0;
	        },
	        hasReference		: function (uniqueId) {
	        	return this.linksList.indexOf(uniqueId);
	        },
	        getCopy : function(){
	    		return emxBreadCrumbTrail(this.linksList.slice(), this.position);
	        },
	        getBreadCrumbArray : function(){
	    		var linksArray = new Array();
	    		for(var i = 0; i < this.linksList.length; i++){
	    			var bc = private.visitedLinks[this.linksList[i]];
	    			if(bc) {
	    				linksArray[i] = bc;
	    			} else {
	    				this.setPosition( i , true);
	    			}
	    		}
	    		return linksArray;
	        }
	    };

	    return public;
	};

    var public = {
        indexOf: function(id){
            for(var i = 0; i < private.visitedLinks.length; i++){
               var tempbc = private.visitedLinks[i];
               if(id == tempbc.id){
                   return i;
               }
            }
            return 0;
        },
        setPosition		: function (position) {
	    	private.position = position;
        },
        getPosition		: function () {
	    	return private.position;
        },
        length		: function () {
	    	return private.bcTrails.length ;
        },
        getCurrentBreadCrumbTrail: function(){
        	if(private.clear) return new emxBreadCrumbTrail(new Array());
            if(private.position == 0)
            	return null;
            else
            	return private.bcTrails[private.position - 1]; 
            	
        },
        addBreadCrumbTrail: function(bctrail){
        	private.clear = false;
        	if(backInProgress || forwardInProgress){
        		return;
        	}
        	private.bcTrails[private.position] = bctrail;
        	this.setPosition(private.position + 1);
        	if(this.getPosition() > historyLimit){
        		var removedBCTrail = private.bcTrails.splice(0, 1);
        		this.setPosition(this.getPosition() - 1)
        		for(var i = 0; i < removedBCTrail[0].linksList.length; i++){
        			var hasReference = false;
        			for(var j = 0; j < private.bcTrails.length; j++){
        				if(private.bcTrails[j].hasReference(removedBCTrail[0].linksList[i]) > -1){
        					hasReference = true;
        					break;
        				}
        			}
        			if(!hasReference) delete private.visitedLinks[removedBCTrail[0].linksList[i]];
        		}
        	}
        	if(this.getPosition() < private.bcTrails.length){
        		private.bcTrails.splice(this.getPosition(), private.bcTrails.length - this.getPosition());
        	}
            	
        },

        changeCategory: function(id, categoryObj){
        	var currTrail = this.getCurrentBreadCrumbTrail();
        	var currbc = currTrail ? currTrail.getBreadCrumb() : null;
        	var origbcPos = currTrail ? currTrail.indexOf(id) : 0;
			var origbc = origbcPos ? currTrail.getBreadCrumb(origbcPos) : null;
			origbc.category = categoryObj.item.text;
			origbc.pageURL = categoryObj.item.url;
			origbc.categoryDynamicName = categoryObj.item.dynamicName;
			currTrail.setBreadCrumb(origbcPos, origbc);
        },        
        insert: function(id, label, seperator, category, url1, url2, insertAfter, categoryObj,fancyTreeData, productInfoObj){
        	var currTrail = this.getCurrentBreadCrumbTrail();
        	var currbc = currTrail ? currTrail.getBreadCrumb() : null;
        	var origbcPos = currTrail ? currTrail.indexOf(id) : 0;
			var origbc = origbcPos ? currTrail.getBreadCrumb(origbcPos) : null;
			//To insert the category object into same level bread crumb node
			if(!categoryObj && origbc){
				categoryObj = origbc.categoryObj;
			}
			
			if(url1 == "null") url1 = null;
			if(productInfoObj == null || productInfoObj == "null") {	
				if(getTopWindow().applicationProductInfo){
					productInfoObj = getTopWindow().applicationProductInfo;
				}
			}
			var selectedId = "";
			if(!url1 && !origbc && !insertAfter){
    			if(currbc && currbc.structureURL){
    				url1 = currbc.structureURL;
    				selectedId = currbc.selectedId;
    				selectedId = selectedId ? selectedId + "," + id : id;
    			}
    	    }
			
			if(insertAfter){
				if(getTopWindow().objStructureTree){
                	var objNode = getTopWindow().objStructureTree.getSelectedNode();
                	while(objNode && objNode.parent){
                		selectedId = selectedId ? (objNode.objectID + "," + selectedId) : objNode.objectID;
                		objNode = objNode.parent;
                	}
                }
			}
        	
        	var bc = new emxBreadCrumb(id, label, seperator, category, url1, url2, categoryObj,fancyTreeData);
        	bc.selectedId = selectedId;
        	bc.appInfo = productInfoObj;
        	if(origbc){
        		if(!bc.label){
                	bc.label = origbc.label;
                }
                if(!bc.seperator){
                	bc.seperator = origbc.seperator;
                }
                if(!bc.structureURL){
                	bc.structureURL = origbc.structureURL;
                }
                if(!bc.selectedId){
                	bc.selectedId = origbc.selectedId;
                }
                if(!bc.pageURL){
                	bc.pageURL = origbc.pageURL;
                }
        	}
        	
        	var newtrail = currTrail ? currTrail.getCopy() : new emxBreadCrumbTrail(new Array());
        	if(insertAfter)newtrail.setPosition(insertAfter, true);
        	origbcPos ? newtrail.setBreadCrumb(origbcPos, bc) : newtrail.setBreadCrumb(0, bc);
        	this.addBreadCrumbTrail(newtrail);
        	/*
        	else {
                private.bcarray[private.position] = bc;
                this.setPosition(bc);
                if(private.bcarray.length > private.position){
                    private.bcarray.splice(private.position, private.bcarray.length - private.position);
                }
            }*/
            drawBreadCrumb();
        },
        insertAfter: function(mainid, id, label, seperator, category, url1, url2){
        	var currTrail = this.getCurrentBreadCrumbTrail();
        	var currbc = currTrail ? currTrail.getBreadCrumb() : null;
        	var origbcPos = currTrail ? currTrail.indexOf(mainid) : 0;
        	var origbc = origbcPos ? currTrail.getBreadCrumb(origbcPos) : null;
        	
            if(origbcPos){
                url1 = origbc.structureURL;
                this.insert(id, label, seperator, category, url1, url2, origbcPos);
            } else {
            	//do nothing
            }
            drawBreadCrumb();
        },
        currentPosition: function(){
            return private.position;
        },
        getBreadCrumb: function(bcid){
        	return private.visitedLinks[bcid];
        },
        remove: function(id){
        	var deletedLinks = new Array();
        	for (var uniqueId in private.visitedLinks){
        		var bc = private.visitedLinks[uniqueId];
        		if(bc.id == id) {
        			delete private.visitedLinks[uniqueId];
        			deletedLinks.push(uniqueId);
        		}
        	}
            drawBreadCrumb();
        },
        changeLabel: function(id, strLabel){
        	for (var uniqueId in private.visitedLinks){
        		var bc = private.visitedLinks[uniqueId];
        		if(bc.id == id) bc.label = strLabel;
        	}
        	drawBreadCrumb();
        },
        changeID: function(id, strId){
        	for (var uniqueId in private.visitedLinks){
        		var bc = private.visitedLinks[uniqueId];
        		if(bc.id == id) bc.id = strId;
        	}
        	drawBreadCrumb();
        },
        clear: function(){
        	private.clear = true;
        	getTopWindow().objStructureTree = new emxUIStructureTree;
        	getTopWindow().objDetailsTree = new emxUIDetailsTree;
        	drawBreadCrumb();
        },
        getCurrentBC: function(){
        	var currTrail = this.getCurrentBreadCrumbTrail();
        	return currTrail ? currTrail.getBreadCrumb(): null;
        },
        getFirstBC: function(){
        	var currTrail = this.getCurrentBreadCrumbTrail();
        	return currTrail ? currTrail.getBreadCrumb(1): null;
        },
        getBackButtonTooltip: function(){
			var bcLabel = emxUIConstants.STR_BACK_TOOLTIP;
        	if(this.currentPosition() > 1){
        		this.setPosition(this.currentPosition() - 1);
        		if(this.getCurrentBC()){
        			if(this.getCurrentBC().id === "MyDesk" && this.getCurrentBC().label === "root"){
						bcLabel = emxUIConstants.STR_BACK_TOOLTIP;
					}else{
						bcLabel = this.getCurrentBC().label;
					}
				}
        		this.setPosition(this.currentPosition() + 1);
        	}
        	return bcLabel;
        },
        getForwardButtonTooltip: function(){
			var bcLabel = emxUIConstants.STR_FORWARD_TOOLTIP;
        	if(this.currentPosition() < this.length()){
        		this.setPosition(this.currentPosition() + 1);
				if(this.getCurrentBC()){
        			if(this.getCurrentBC().id === "MyDesk" && this.getCurrentBC().label === "root"){
						bcLabel = emxUIConstants.STR_FORWARD_TOOLTIP;
					}else{
						bcLabel = this.getCurrentBC().label;
					}
				}
        		this.setPosition(this.currentPosition() - 1);
        	}
        	return bcLabel;
        },
        goBack: function(){
        	  if(!getTopWindow().setUWAPref){
              	var topNavRef = getTopWindow().getWindowOpener().getTopWindow();
              	if (topNavRef){
              		var popCount = 0;
              		while (!topNavRef.setUWAPref){
              			if (popCount > 2){
              				break;
              			}
              			topNavRef = topNavRef.getWindowOpener().getTopWindow();
              			popCount++;
              		}
              		if (topNavRef.setUWAPref){
      					topNavRef.setUWAPref('DefaultCategory','');
                          topNavRef.setUWAPref('objectId','');
                          topNavRef.setUWAPref('DefaultLocation','');
                          topNavRef.setUWATitle('')
      					
              		}
              	}
                } else{
		        getTopWindow().setUWAPref('DefaultCategory','');
	     	    getTopWindow().setUWAPref('objectId','');
	            getTopWindow().setUWAPref('DefaultLocation','');
	            getTopWindow().setUWATitle('');
                }
        	//if(jQuery(".btn.previous","#navButtons").hasClass("disabled") == true){
        	if(jQuery(".btn.left").hasClass("disabled") == true){
        		return;
        	}
        	backInProgress = true;
        	var appName;
			var fancyTreeData;
        	if(getTopWindow().bclist.getCurrentBC() && getTopWindow().bclist.getCurrentBC().appInfo){
        		appName = getTopWindow().bclist.getCurrentBC().appInfo.appTrigram;
				fancyTreeData = getTopWindow().bclist.getCurrentBC().fancyTreeData;
        	}
        	if(this.currentPosition() > 1){
        		this.setPosition(this.currentPosition() - 1);
        	}
        	
        	drawBreadCrumb();
        	var currTrail = this.getCurrentBreadCrumbTrail();
        	var bc =  currTrail ? currTrail.getBreadCrumb(currTrail.linksList.length): null;
        	if(bc.treeURL != null && bc.treeURL!= 'undefined'){
        		var categoryCommandName = bc.categoryDynamicName;
                var cntFrame = findFrame(getTopWindow(), "content");
                var treeURL = bc.treeURL;
				if(typeof categoryCommandName != 'undefined') {
					if(treeURL.indexOf("DefaultCategory")!= -1){
						treeURL = updateURLParameter(treeURL,"DefaultCategory",categoryCommandName);
					}else{
                	treeURL = treeURL + '&DefaultCategory='+categoryCommandName;
                }
              }
                cntFrame.location.href = treeURL;	
            }else{
			if(typeof getTopWindow().jQuery("#navBar") != 'undefined'){
				getTopWindow().jQuery("#navBar").empty();
						var shortcutTooltip = getTopWindow().emxUIConstants.STR_SHORTCUTS;
						var appMenuDiv = getTopWindow().jQuery("<div id='' class='tab-bar button-bar'></div>");
						var appShortcutButton = getTopWindow().jQuery("<button id='shortcutAppMenu' onclick='showShortcutPanel();' class='btn shortcut' title='"+shortcutTooltip+"'></button>");
						var shortcutIcon =getTopWindow().jQuery("<span title='"+shortcutTooltip+"' class='fonticon fonticon-forward site-icon'></span>");
						appMenuDiv.append(appShortcutButton);
						appShortcutButton.append(shortcutIcon);
						var nav = getTopWindow().jQuery('#navBar');
						nav.append(appMenuDiv);

			}
        		bc ? loadBreadCrumbPage(bc.id, bc.label, bc.seperator, bc.category, bc.structureURL, bc.pageURL, true): bc ;
        		if(bc.appInfo != null && typeof bc.appInfo != 'undefined' && bc.appInfo.appTrigram != appName){
        			getTopWindow().changeProduct(bc.appInfo.brandName, bc.appInfo.appName, bc.appInfo.appTrigram, bc.appInfo.appMenuList, bc.appInfo.licensedAppList, bc.appInfo.isFromIFWE);
        		}
            }
			var objStructureFancyTree = getTopWindow().objStructureFancyTree;
			if(objStructureFancyTree && fancyTreeData != null && bc.fancyTreeData){
				var currentRootNode = objStructureFancyTree.getRootNode();
				var previousRootNode = JSON.parse(bc.fancyTreeData.structureTree);
				if(previousRootNode[0].key != currentRootNode.key){
					objStructureFancyTree.reInit(bc.fancyTreeData, true);
        		}
			}else if(bc.fancyTreeData){
				objStructureFancyTree.reInit(bc.fancyTreeData, true);
			}
			var nodeExists=objStructureFancyTree.getNodeById(bc.id);
			if(nodeExists){
				nodeExists.setFocus();
				//nodeExists.setActive();
				nodeExists.tree.activeNode = nodeExists;
			}
        	backInProgress = false;
        },
        goForward: function(){
        	  if(!getTopWindow().setUWAPref){
              	var topNavRef = getTopWindow().getWindowOpener().getTopWindow();
              	if (topNavRef){
              		var popCount = 0;
              		while (!topNavRef.setUWAPref){
              			if (popCount > 2){
              				break;
              			}
              			topNavRef = topNavRef.getWindowOpener().getTopWindow();
              			popCount++;
              		}
              		if (topNavRef.setUWAPref){
      					topNavRef.setUWAPref('DefaultCategory','');
                          topNavRef.setUWAPref('objectId','');
                          topNavRef.setUWAPref('DefaultLocation','');
                          topNavRef.setUWATitle('')
      					
              		}
              	}
                } else{
		          getTopWindow().setUWAPref('DefaultCategory','');
	     	      getTopWindow().setUWAPref('objectId','');
	              getTopWindow().setUWAPref('DefaultLocation','');
	              getTopWindow().setUWATitle('');
                }
        	//if(jQuery(".btn.next","#navButtons").hasClass("disabled") == true){
        	if(jQuery(".btn.right").hasClass("disabled") == true){
        		return;
        	}
        	forwardInProgress = true;
        	var appName;
			var fancyTreeData;
        	if(getTopWindow().bclist.getCurrentBC() && getTopWindow().bclist.getCurrentBC().appInfo){
        		appName = getTopWindow().bclist.getCurrentBC().appInfo.appTrigram;
				fancyTreeData = getTopWindow().bclist.getCurrentBC().fancyTreeData;
        	}
        	if(this.currentPosition() < this.length()){
        		this.setPosition(this.currentPosition() + 1);
        	}
        	drawBreadCrumb();
        	var currTrail = this.getCurrentBreadCrumbTrail();
        	var bc =  currTrail ? currTrail.getBreadCrumb(currTrail.linksList.length): null;
        	if(bc.treeURL != null && bc.treeURL!= 'undefined'){
        		var categoryCommandName = bc.categoryDynamicName;
                var cntFrame = findFrame(getTopWindow(), "content");
                var treeURL = bc.treeURL;
                if(typeof categoryCommandName != 'undefined') {
					if(treeURL.indexOf("DefaultCategory")!= -1){
                		treeURL = updateURLParameter(treeURL,"DefaultCategory",categoryCommandName);
                	}else{
                		treeURL = treeURL + '&DefaultCategory='+categoryCommandName;
					}
                }
                cntFrame.location.href = treeURL;		
            }else{
        		bc ? loadBreadCrumbPage(bc.id, bc.label, bc.seperator, bc.category, bc.structureURL, bc.pageURL, true): bc ;
        		if(bc.appInfo != null && typeof bc.appInfo != 'undefined' && bc.appInfo.appTrigram != appName){
        			getTopWindow().changeProduct(bc.appInfo.brandName, bc.appInfo.appName, bc.appInfo.appTrigram, bc.appInfo.appMenuList, bc.appInfo.licensedAppList, bc.appInfo.isFromIFWE);
        		}
            }
			var objStructureFancyTree = getTopWindow().objStructureFancyTree;
			if(objStructureFancyTree && fancyTreeData != null && bc.fancyTreeData){
				var currentRootNode = objStructureFancyTree.getRootNode();
				var nextRootNode = JSON.parse(bc.fancyTreeData.structureTree);
				if(nextRootNode[0].key != currentRootNode.key){
					objStructureFancyTree.reInit(bc.fancyTreeData, true);
        		}
			}else if(bc.fancyTreeData){
				objStructureFancyTree.reInit(bc.fancyTreeData, true);
			}
			var nodeExists=objStructureFancyTree.getNodeById(bc.id);
			if(nodeExists){
				nodeExists.setFocus();
            	//nodeExists.setActive();
				nodeExists.tree.activeNode = nodeExists;
			}
        	forwardInProgress = false;
			},
			exportAllBC: function() {
				var  convArrToObj = function convArrToObj(array) {
					var thisEleObj = new Object();
					if(typeof array == "object"){
						for(var i in array){
							var thisEle = array[i];
							thisEleObj[i] = thisEle;
						}
					}else {
						thisEleObj = array;
					}
					return thisEleObj;
				}
				private.visitedLinks = convArrToObj(private.visitedLinks);
				return private;
			},
			importAllBC: function(info) {
				var loc_private = {
						visitedLinks : [],
						bcTrails: [],
						position: 0,
						clear: true
				};
				console.log("loc_private = " + loc_private.visitedLinks.length);
				var visitedLinks = info.visitedLinks;
				for (var prop in visitedLinks) {
					if (visitedLinks.hasOwnProperty(prop)) {
						loc_private.visitedLinks[prop] = new emxBreadCrumb(visitedLinks[prop].id, visitedLinks[prop].label , visitedLinks[prop].seperator, visitedLinks[prop].category, visitedLinks[prop].structureURL, visitedLinks[prop].pageURL, visitedLinks[prop].categoryObj, visitedLinks[prop].fancyTreeJSONData, visitedLinks[prop].categoryDynamicName, visitedLinks[prop].treeURL, visitedLinks[prop].appInfo);
					}
				}
				console.log("1 loc_private.visitedLinks = " + loc_private.visitedLinks.length);

				var bcTrails = info.bcTrails;
				for (var prop in bcTrails) {
					if (bcTrails.hasOwnProperty(prop)) {
						loc_private.bcTrails.push(new emxBreadCrumbTrail(bcTrails[prop].linksList, bcTrails[prop].position));
					}
				}
				console.log("loc_private.bcTrails = " + loc_private.bcTrails.length);

				loc_private.position = info.position;
				loc_private.clear = info.clear;
				console.log("loc_private after " + loc_private);

				private = loc_private;
        }
    }

    return public;
};

function drawBreadCrumb()
{
/*
	    var bcul = getTopWindow().document.getElementById('bcul');
	    var tempbclist = getTopWindow().bclist;
	    if(tempbclist){
			(tempbclist.currentPosition() > 1) ? jQuery('.previous').removeClass('disabled'): jQuery('.previous').addClass('disabled');
		(tempbclist.currentPosition() < tempbclist.length()) ? jQuery('.next').removeClass('disabled'): jQuery('.next').addClass('disabled');
		}

	    if(!bcul) return;


	    if(!tempbclist) return;

	    var str = "";
	    var currTrail = tempbclist.getCurrentBreadCrumbTrail();
	    if(!currTrail) return;
	    var bclength = currTrail.length();
	    //if(!bclength) return;
	    var currentPosition = currTrail.getPosition();
	    var temparr = currTrail.getBreadCrumbArray();
	    var it = 0;

	    //while(itr.hasNext()) {
	    for(var i = 0; i < bclength; i++){
		var bc = temparr[i];
		str += "<li id='liemxbc" + it +"' class='";
		if(it == currentPosition - 1){
		    str += "current";
		}
		if(it == bclength - 1){
		    str += " last-child";
		}
		if(bc != null) {
			var nodeName = bc.getName();
			
			if(emxUIConstants.UI_AUTOMATION == 'true'){
				str += "' data-aid='"+ nodeName +"";
			}
				var labelName = bc.label;
			try{
				nodeName = nodeName ? decodeURIComponent(nodeName): "";
				if(labelName) {
					if(labelName.indexOf("%") > -1 ) labelName = decodeURIComponent(labelName);
					}
			}catch(e){
				nodeName = bc.getName();
				labelName = bc.label;
			}
			if(labelName) {
					labelName = labelName.replace(/\'/g, "\\'");
				}
			if(it == currentPosition - 1){
				str += "'><a onclick=\"return false\">&nbsp;" + nodeName + "</a></li>";
			} else {
						str += "'><a href=\"javascript:loadBreadCrumbPage('" ;
						str += (bc.id ? bc.id.replace(/\'/g, "\\'") : bc.id) + "','"  ;
						str += labelName + "','" ;
						str += (bc.seperator ? bc.seperator.replace(/\'/g, "\\'") : bc.seperator) + "','" ;
						str += (bc.category ? bc.category.replace(/\'/g, "\\'") : bc.category) + "','" ;
						str += (bc.structureURL ? bc.structureURL.replace(/%27/g, "\\%27").replace(/\'/g, "\\'") : bc.structureURL) + "','" ;
						str += (bc.pageURL ? bc.pageURL.replace(/%27/g, "\\%27").replace(/\'/g, "\\'") : bc.pageURL) + "')" ;
						str += "\">&nbsp;";
						str += nodeName;
						str += "</a></li>";			
				}
		}
		it++;
	    }
	    bcul.innerHTML = str;
	    if(currentPosition){
		var bcli = getTopWindow().document.getElementById('liemxbc' + (currentPosition - 1));
		if(bcli) {
			if(bcul.offsetLeft <0)
			if(bcul.offsetLeft+bcli.offsetLeft <0){
				bcul.style.left = -(bcli.offsetLeft) + "px" ;			
			}
		}
	    }
	    var bc = currTrail.getBreadCrumb(1);
	    if(bc != null) {
		    var right_btn = getTopWindow().document.getElementById('breadcrumbs_rightbutton');
		    if( getOffsetRight(bcul) > document.getElementById('mx_objectCount').offsetLeft){		    	
				right_btn.className = "buttons next";
		    }else{
		    	if(document.getElementById('mx_objectCount').offsetLeft - getOffsetRight(bcul) <= 40){
		    		right_btn.className = "buttons next";
		    	}else{
	       			right_btn.className = "buttons next disabled";	    	
		    	}		  
		    }		    
			var left_btn = getTopWindow().document.getElementById('breadcrumbs_leftbutton');
				if(bcul.offsetLeft < 0){
			    left_btn.className = "buttons previous";
			} else {
				left_btn.className = "buttons previous disabled";
			}
	    }*/	  
}

function getOffsetRight(obj)
{
    if (obj == null)
        return 0;
    
    var offsetRight = obj.offsetLeft + obj.offsetWidth;            
    return offsetRight;    
}

function loadBreadCrumbPage(id, label, sepearator, category, structureURL, pageURL, loadOnly, bcLabel, categoryObj,fancyTreeData, productInfoObj){
	if(id) id = JSON.parse(JSON.stringify(id));
	if(label) label = JSON.parse(JSON.stringify(label));
	if(sepearator) sepearator = JSON.parse(JSON.stringify(sepearator));
	if(category) category = JSON.parse(JSON.stringify(category));
	if(structureURL) structureURL = JSON.parse(JSON.stringify(structureURL));
	if(pageURL) pageURL = JSON.parse(JSON.stringify(pageURL));
	if(loadOnly) loadOnly = JSON.parse(JSON.stringify(loadOnly));
	if(bcLabel) bcLabel = JSON.parse(JSON.stringify(bcLabel));
	if(categoryObj) categoryObj = JSON.parse(JSON.stringify(categoryObj));
	if(fancyTreeData) fancyTreeData = JSON.parse(JSON.stringify(fancyTreeData));
	if(productInfoObj) productInfoObj = JSON.parse(JSON.stringify(productInfoObj));

	if(pageURL && pageURL.indexOf("categoryTreeName") != -1 && pageURL.indexOf("&treeLabel=") == -1){
		pageURL = pageURL+"&treeLabel="+label;
	}
	
	if(typeof bcLabel != "undefined" && bcLabel!=null && bcLabel!=""){
		label = bcLabel;
	}
    // loadOnly is used to identify, the call is coming from fresh object or through navigation button
	// If call is from fresh object insert breadcrumb in bclist else update bclist.
	if(getTopWindow().bclist && !loadOnly){
		getTopWindow().bclist.insert(id, label, sepearator, category, structureURL, pageURL, null, categoryObj,fancyTreeData,productInfoObj);
	}else{
		updateBreadcrumbHeader(categoryObj);
	}
	
	var currbc = getTopWindow().bclist.getCurrentBC();
	structureURL = currbc && currbc.structureURL ? currbc.structureURL + "&bcSelectedId=" + currbc.selectedId : structureURL;
	
    var contentFrame = findFrame(getTopWindow(), "content");
    
    if(id == 'MyDesk'){
    	if(objStructureFancyTree){
    		 objStructureFancyTree.destroy();
    		 getTopWindow().hideTreePanel();
    	}
    	contentFrame.location.href = pageURL;
        getTopWindow().showMyDesk();	
	} else {
	    
		contentFrame = findFrame(getTopWindow(), "content");
		var dowrite = contentFrame.document;
		if(!dowrite.body){
			dowrite.open();
			dowrite.write("<body></body>");
			dowrite.close();
		}else{
			dowrite.body.innerHTML="";
		}
		
    	var currPage = 0;
	    var stTreeClsName = "structure-tree-navigator no-tree";
		//var outerDiv =  contentFrame.$('<div class="'+stTreeClsName+'" id="divObjectStructureTree">');
		var outerDiv = dowrite.createElement("div");
		outerDiv.className = stTreeClsName;
		outerDiv.setAttribute("id", "divObjectStructureTree");
		var divHolder = null;
		var displayFrameHolder = null;
		var hiddenTreeFrameHolder = null;
        if(getTopWindow().CACHE_CATEGORIES_COUNT === 0){
			//divHolder = contentFrame.$('<div class="structure-content" id="unique'+ii+'" name="unique'+ii+'" style="display:block">');
			divHolder = dowrite.createElement("div");
			divHolder.className = "structure-content";
			divHolder.setAttribute("id", "unique"+ii);
			divHolder.setAttribute("name", "unique"+ii);
			divHolder.setAttribute("style", "display:block");
			//displayFrameHolder = contentFrame.$('<iframe name="detailsDisplay" frameborder="0" src="'+ pageURL +'"></iframe>');
			displayFrameHolder = dowrite.createElement("iframe");
			displayFrameHolder.setAttribute("name", "detailsDisplay");
			displayFrameHolder.setAttribute("frameborder", "0");
			displayFrameHolder.setAttribute("onload", "getTopWindow().checkMemory()");
			displayFrameHolder.setAttribute("src", pageURL);
			divHolder.appendChild(displayFrameHolder);
			outerDiv.appendChild(divHolder);
			//$(divHolder).append(displayFrameHolder);
			//$(outerDiv).append(divHolder);
        } else {
            for(var ii = 0; ii < getTopWindow().CACHE_CATEGORIES_COUNT; ii++){
                var treePageURL = null;
                if(ii == currPage){
					//divHolder = contentFrame.$('<div class="structure-content" id="unique'+ii+'" name="unique'+ii+'" style="display:block">');
					divHolder = dowrite.createElement("div");
					divHolder.className = "structure-content";
					divHolder.setAttribute("id", "unique"+ii);
					divHolder.setAttribute("name", "unique"+ii);
					divHolder.setAttribute("style", "display:block");

					//displayFrameHolder = contentFrame.$('<iframe name="detailsDisplay" frameborder="0" src="'+ pageURL +'"></iframe>');
					displayFrameHolder = dowrite.createElement("iframe");
					displayFrameHolder.setAttribute("name", "detailsDisplay");
					displayFrameHolder.setAttribute("frameborder", "0");
					displayFrameHolder.setAttribute("src", pageURL);
					displayFrameHolder.setAttribute("onload", "getTopWindow().checkMemory()");
                } else {
					//divHolder = contentFrame.$('<div class="structure-content" id="unique'+ii+'" name="unique'+ii+'" style="display:none">');
					divHolder = dowrite.createElement("div");
					divHolder.className = "structure-content";
					divHolder.setAttribute("id", "unique"+ii);
					divHolder.setAttribute("name", "unique"+ii);
					divHolder.setAttribute("style", "display:none");

					//displayFrameHolder = contentFrame.$('<iframe name="detailsDisplay'+ii+'" frameborder="0" src=""></iframe>');
					displayFrameHolder = dowrite.createElement("iframe");
					displayFrameHolder.setAttribute("name", "detailsDisplay"+ii);
					displayFrameHolder.setAttribute("frameborder", "0");
					displayFrameHolder.setAttribute("src", "");
					displayFrameHolder.setAttribute("onload", "getTopWindow().checkMemory()");
                }
				divHolder.appendChild(displayFrameHolder);
				outerDiv.appendChild(divHolder);
				//$(divHolder).append(displayFrameHolder);
				//$(outerDiv).append(divHolder);
            }
        }
		
		   	
		//var extraDivHolder = contentFrame.$('<div class="structure-content" id="unique6" name="unique6" style="display:none">');
		var extraDivHolder = dowrite.createElement("div");
		extraDivHolder.className = "structure-content";
		extraDivHolder.setAttribute("id", "unique6");
		extraDivHolder.setAttribute("name", "unique6");
		extraDivHolder.setAttribute("style", "display:none");

		//var extraFrameHolder = contentFrame.$('<iframe name="detailsDisplay6" frameborder="0" src=""></iframe>');
		var extraFrameHolder = dowrite.createElement("iframe");
		extraFrameHolder.setAttribute("name", "detailsDisplay6");
		extraFrameHolder.setAttribute("frameborder", "0");
		extraFrameHolder.setAttribute("src", "");

		//$(extraDivHolder).append(extraFrameHolder);
		//$(outerDiv).append(extraDivHolder);
		extraDivHolder.appendChild(extraFrameHolder);
		outerDiv.appendChild(extraDivHolder);
		 
		if (contentFrame){
			//hiddenTreeFrameHolder = contentFrame.$('<iframe name="hiddenTreeContentFrame" class="hidden-frame" frameborder="0" src=""></iframe>');
			hiddenTreeFrameHolder = dowrite.createElement("iframe");
			hiddenTreeFrameHolder.setAttribute("name", "hiddenTreeContentFrame");
			hiddenTreeFrameHolder.className = "hidden-frame";
			hiddenTreeFrameHolder.setAttribute("frameborder", "0");
			hiddenTreeFrameHolder.setAttribute("src", "");
		} else {
			//hiddenTreeFrameHolder = contentFrame.$('<iframe name="hiddenTreeFrame" class="hidden-frame" frameborder="0" src=""></iframe>');
			hiddenTreeFrameHolder = dowrite.createElement("iframe");
			hiddenTreeFrameHolder.setAttribute("name", "hiddenTreeFrame");
			hiddenTreeFrameHolder.className = "hidden-frame";
			hiddenTreeFrameHolder.setAttribute("frameborder", "0");
			hiddenTreeFrameHolder.setAttribute("src", "");
		}
		outerDiv.appendChild(hiddenTreeFrameHolder);
		dowrite.body.appendChild(outerDiv);
		//$(outerDiv).append(hiddenTreeFrameHolder);
		//$(dowrite.body).append(outerDiv);
		
		//to register the getTopWindow function on content frame
		//contentFrame.getTopWindow = getTopWindow;
	}
	//load of the category tree, on load of breadcrumb page
	getTopWindow().emxUICategoryTab.destroy();
	if(currbc.categoryObj){
		currbc.categoryObj.category = category;
		if(id == 'MyDesk'){
			currbc.categoryObj.isMD = true;
		} else {
		currbc.categoryObj.objectId = id;
		}
		 if(structureURL == null || structureURL == "null") {
			 getTopWindow().emxUICategoryTab.init(currbc.categoryObj, false);
		 } else {
			 getTopWindow().emxUICategoryTab.init(currbc.categoryObj, true);
		 }
	}		
}

function findMenu1(strCommand){
	return findMenufromOtherMenu1(strCommand, getTopWindow().objMainToolbar);
} 

function findMenufromOtherMenu1(strCommand, mainmenu){
	if (!mainmenu) return null;
    var menuLen = mainmenu.items.length;
    for(var i = 0; i < menuLen; i++){
        if(mainmenu.items[i].command == strCommand){
            return mainmenu.items[i];
        }
    }
return null;
}


/**
* disable back menu
*/
function disableBackMenu1(){
	var objBackMenu             = findMenu1("AEFBackToolbarCommand");
    if(objBackMenu && objBackMenu.element) {
	objBackMenu.element.innerHTML=objBackMenu.element.innerHTML.replace("backarrow.png","backarrowdisabled.png");
	objBackMenu.element.style.color="#cccccc";
	objBackMenu.disable();
    }   
}

/**
* enable back menu
*/
function enableBackMenu1(){
	var objBackMenu             = findMenu1("AEFBackToolbarCommand");
    if(objBackMenu && objBackMenu.element) {
    	objBackMenu.element.innerHTML=objBackMenu.element.innerHTML.replace("backarrowdisabled.png","backarrow.png");
    	objBackMenu.element.style.color="#ffffff";
        objBackMenu.enable();
    }
}

/**
* disable forward menu
*/
function disableForwardMenu1(){ 
	var objForwardMenu          = findMenu1("AEFForwardToolbarCommand");
    if(objForwardMenu && objForwardMenu.element) {
    	objForwardMenu.element.innerHTML=objForwardMenu.element.innerHTML.replace("forwardarrow.png","forwardarrowdisabled.png");
    	objForwardMenu.element.style.color="#cccccc";
        objForwardMenu.disable();
    }
}

/**
* enable forward menu
*/
function enableForwardMenu1(){
	var objForwardMenu          = findMenu1("AEFForwardToolbarCommand");
    if(objForwardMenu && objForwardMenu.element) {
    	objForwardMenu.element.innerHTML=objForwardMenu.element.innerHTML.replace("forwardarrowdisabled.png","forwardarrow.png");
    	objForwardMenu.element.style.color="#ffffff";
        objForwardMenu.enable();
    }
}


function showPageHeaderContent(url, singleoid,sCommandArray){
    if(singleoid && singleoid != ''){
    	var cntFrame = findFrame(getTopWindow(), "content");
    	cntFrame.location.href = '../common/emxTree.jsp?mode=insert&objectId='+singleoid;
    } else if(sCommandArray.length > 0){
    	var cmdFound = false;
	    for(var i=0; i<sCommandArray.length; i++){
	    	if($('li[name=li_' + sCommandArray[i] + ']', 'div#catMenu').length > 0) {
	    		cmdFound = true;
	    		$('li[name=li_' + sCommandArray[i] + ']', 'div#catMenu').trigger('click');	    		
	    		break;
	    	}
	    }
	    if(!cmdFound){    
		     	    	showDataInTempCategoryTab(url);
	    }
    }
}

function showRefDocs(sCommand, url){
	if($('li[name=li_' + sCommand + ']', 'div#catMenu').length > 0) {
		$('li[name=li_' + sCommand + ']', 'div#catMenu').trigger('click');
	} else {
		showDataInTempCategoryTab(url);
	}
}

function showDataInTempCategoryTab(url){
	jQuery('li.active','div#catMenu').removeClass("active");
		    var ddFrames = findFrame(getTopWindow(), "detailsDisplay");
		    var id = ddFrames.frameElement.parentNode.id.replace('unique','');    
		    ddFrames.frameElement.parentNode.style.display ='none';          
		    ddFrames.name = 'detailsDisplay'+id;
		    
		    var dd6 = window.frames['content'].frames['detailsDisplay6'];
		    if(!dd6){
		    	dd6 = window.frames['content'].frames['detailsDisplay'];    	
		    }
		    dd6.frameElement.parentNode.style.display='block';
			dd6.name = 'detailsDisplay';
			dd6.location.href = url;
	    }

function updateBreadcrumbHeader(catObj){
	if(getTopWindow().bclist.getCurrentBC().categoryObj){
		var catItems = getTopWindow().bclist.getCurrentBC().categoryObj.items;
		
		for(var i=0; i<catItems.length; i++) {
			var catItem = catItems[i];
			if(catItem.isHeader && catItem.isHeader == 'true'){
				if(catObj.items){
					var catObjItems = catObj.items;
					for(var j=0; j<catObjItems.length; j++) {
						var catObjItem = catObjItems[j];
						if(catObjItem.isHeader && catObjItem.isHeader == 'true'){
							catItem.text = catObjItem.text;
						}
				}
			}
	}
		}
		
	}
}

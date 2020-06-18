/*jshint browser: true, devel: true*/
/*global define,jQuery,emxUICore,findFrame,getTopWindow*/
define('DS/ENOFrameworkStructureView/ENOFrameworkStructureView',
    [
	'DS/Foundation/FoundationData',
	'DS/Foundation/WidgetAPIs',
	'DS/ENOFrameworkPlugins/Fancytree',
	'DS/ENOFrameworkPlugins/Fancytree_filter',
	'DS/ENOFrameworkPlugins/Fancytree_edit',
	'DS/ENOFrameworkPlugins/Fancytree_dnd',
	'DS/ENOFrameworkPlugins/Fancytree_persist',
	'DS/ENOFrameworkPlugins/Fancytree_contextMenu',
	'DS/ENOFrameworkPlugins/Fancytree_ui_contextMenu',
	'DS/ENOFrameworkPlugins/Fancytree_cookie'
	], function (FoundationData,WidgetAPIs, fancytree, fancytreeFilter) {
        'use strict';
        //Private members
        var savedStrucData=null;
        var initialSettings =null;

        function copyTo(targetNode, mode, map) {
    		if(mode === undefined || mode === "over"){
    			mode = "child";
    		}
    		var pos,
    			prevParent = this.parent,
    			targetParent = (mode === "child") ? targetNode : targetNode.parent;

    		if(this === targetNode){
    			return;
    		}else if( !this.parent  ){
    			throw "Cannot move system root";
    		}else if( targetParent.isDescendantOf(this) ){
    			throw "Cannot move a node to its own descendant";
    		}

    		// Insert this node to target parent's child list
    		this.parent = targetParent;
    		if( targetParent.hasChildren() ) {
    			switch(mode) {
    			case "child":
    				// Append to existing target children
    				targetParent.children.push(this);
    				break;
    			case "before":
    				// Insert this node before target node
    				pos = jQuery.inArray(targetNode, targetParent.children);
    				_assert(pos >= 0);
    				targetParent.children.splice(pos, 0, this);
    				break;
    			case "after":
    				// Insert this node after target node
    				pos = jQuery.inArray(targetNode, targetParent.children);
    				_assert(pos >= 0);
    				targetParent.children.splice(pos+1, 0, this);
    				break;
    			default:
    				throw "Invalid mode " + mode;
    			}
    		} else {
    			targetParent.children = [ this ];
    		}

    	 	if( !targetParent.isDescendantOf(prevParent) && targetParent !== prevParent) {    	 		
    	 		targetParent.render();
    		}
    		// TODO: fix selection state
    		// TODO: fix active state
    	}

//droppedNode is the content dropped from outside & draggedNode is Fancy tree node
/*dragNode FT node where element is Dropped
 * droppedNode the real dropped node INFO from outside
 * */
 function dragDropOperationFromOutside(dragNodeFT,droppedNodeOut) {
        	var dNode = {};
        	var urlData ="";

        	var droppedNodes = JSON.parse(droppedNodeOut);
        	if(!dndValidation(dragNodeFT.data.type, droppedNodes, false, true)){
        		return;
        	}

        	var treeNodeObjId, treeNodeRelId;
			if(dragNodeFT.data.objectId){
				treeNodeObjId = dragNodeFT.data.objectId;
				treeNodeRelId = dragNodeFT.data.relId;
			}else{
				treeNodeObjId = dragNodeFT.objectId;
				treeNodeRelId = dragNodeFT.relId;
			}

			var newObj=[];
			for(var j = 0; j < droppedNodes.objects.length; j++){
        		var dataTosend = [{name: "unknownContentId", value: {displayValue:droppedNodes.objects[j].oid, actualValue: droppedNodes.objects[j].oid}}];
        		newObj.push(FoundationData.addObject(globalData,treeNodeObjId,dataTosend));//Send the parent Node where it is dropped dragNode.objectId
			}

            FoundationData.applyUpdates(globalData, function(success){
            		if(!success){
            			var alertMsg;
            			for(var k = 0; k<newObj.length; k++){
            				if(k == 0){
            					alertMsg = newObj[k].updateMessage;
            				} else{
            					alertMsg = alertMsg + "<br>" + newObj[k].updateMessage;
            			}
            			}
            			getTopWindow().showTransientMessage(alertMsg);
            		}else{
            			
            			var isRefresh = isRefreshContentNeeded(dragNodeFT);
            			if(!isRefresh == false){
            				for(var j = 0; j < newObj.length; j++){
            					fancyTreeNodeClick(newObj[j].objectId,newObj[j].relId,newObj[j].type,"create",treeNodeObjId,treeNodeRelId);
            				}
            			}
            			            			
            			getTopWindow().showTransientMessage(emxUIConstants.DND_DROPPEDSUCCESS, 'success');
            		}
            	},false);
}

 function getServiceName(){
		var service_name = location.search.match(/[?&]serviceName=([^&]*)?/);
		service_name = (service_name == null?"":service_name[1] || "");
		return service_name;
 }

 var firstTime = true;
 var hlNode;
// var wsDragTypes;
// var fdDragTypes;
 
 function prepareJSON(serviceData,useAPI){
 	var finalData = {};
 	var subData= [];
 	var list ;
 	if(firstTime){
 		var ws = WidgetAPIs.getField(serviceData, 'workspaceContentTypes').range.item;
 		var fd = WidgetAPIs.getField(serviceData, 'folderContentTypes').range.item;
 		for(var p=0;p<ws.length;p++){
 			wsDragTypes = wsDragTypes +",,"+ ws[p].display;
 		}
 		for(var p=0;p<fd.length;p++){
 			fdDragTypes = fdDragTypes +",,"+ fd[p].display;
 		}
 		firstTime = false;
 	}
 	if(useAPI){
 		list = WidgetAPIs.getWidgetData(serviceData);
 	}else{
 		//list = WidgetAPIs.getWidgetData(serviceData.responseJSON.widgets[0]);
 		list = serviceData;
 	}
 	for(var k=0; list!=null && k < list.length;k++){
 		var childsLength  = FoundationData.getChildren(list[k]);
 		subData.push  ({
 		//The MAND params for the Fancy tree
 		"title" :FoundationData.getFieldValue(list[k],"title").displayValue,
 		"name" :FoundationData.getFieldValue(list[k],"title").displayValue,
 		"icon" :list[k].dataelements.typeIcon.value[0].imageValue,
 		"key" :list[k].objectId,//+ "-" + list[k].relId,//Added THE UNIQUE KEY
 		"type": FoundationData.getFieldValue(list[k],"type").actualValue,
 		"url" :FoundationData.getFieldValue(list[k],"url").displayValue,
 		"deleteAccess" :FoundationData.getFieldValue(list[k],"deleteAccess").displayValue,
 		"fromconnectAccess" :FoundationData.getFieldValue(list[k],"fromconnectAccess").displayValue,
 		"hasSubItems" :FoundationData.getFieldValue(list[k],"hasSubItems").displayValue,
 		"modifyAccess" :FoundationData.getFieldValue(list[k],"modifyAccess").displayValue,

 		"objectId" :list[k].objectId,
 		"relId" :list[k].relId,
 		"physicalId" :list[k].physicalId,
 		"widgetType" :list[k].widgetType,

 		"lazy" : ("True" == FoundationData.getFieldValue(list[k],"hasSubItems").displayValue) ? true : false ,
 		"expanded" : false, //("True" == FoundationData.getFieldValue(list[k],"hasSubItems").displayValue && childsLength.length == 0) ? false : true,
 		"children" :  prepareJSON(FoundationData.getChildren(list[k]),false)

 		});
 	}
 	finalData.subData = subData;
 	return finalData.subData;
 }


function dragDropOperation(dragNode,dropNode,nodeVal,dataVal) {
	var dNode = {};
	var dragData ="",dropData ="";

	if(dndValidation(dragNode.type,dropNode.type, false)){
		//validation successful
	}else{
		getTopWindow().showTransientMessage(emxUIConstants.DND_TYPE_VALIDATION);
		return;
	}

    for(var elem in dragNode){
    	dNode[elem]= dragNode[elem];
    	if(elem!="url" && elem!="icon")
    		dragData = dragData +"&"+elem+"="+dragNode[elem];
    }
    var drop = {};
    for(var elem in dropNode){
    	drop[elem]= dropNode[elem];
    	if(elem!="url" && elem!="icon")
    		dropData = dropData +"&dg"+ elem+"="+dropNode[elem];
    }
    //Add DRAG type
    dropData = dropData +"mode=drop&ctrlPressed="+dataVal.originalEvent.ctrlKey;
    var urlParams = dragData +"&"+ dropData ;

    var serviceURL = enoviaServer.getUrl() + WidgetEngine.tempURI(getServiceName());
    if(dataVal.originalEvent.ctrlKey){
        //Copy operation copyFromId will be The Dragged object
    	var objID ;
    	if(dragNode.objectId)
    		objID = dragNode.objectId;
    	else
    		objID = dataVal.otherNode.objectId;
    	
    	var objectIDtoSend;
    	if(dropNode.objectId){ 
    		objectIDtoSend = dropNode.objectId;
    	}else{
    		objectIDtoSend = nodeVal.objectId;
    	}
        var dataTosend =[{name: "copyFromId", value: {displayValue:objID, actualValue: objID}}];
    	var newObj = FoundationData.addObject(globalData,objectIDtoSend,dataTosend);//Send the parent Node where it is dropped dropNode.objectId
        FoundationData.applyUpdates(globalData, function(success){
        		if(!success){        			
        			getTopWindow().showTransientMessage(newObj.updateMessage);
        		}else{
        			var hitMode = dataVal.hitMode;
        			//if(nodeVal.parent.key.indexOf("root_") == 0){
        				hitMode ="child";
        			//}
        			        			
        			var isRefresh = isRefreshContentNeeded(nodeVal);
        			if(!isRefresh == false){
        				fancyTreeNodeClick(dataVal.otherNode.data.objectId,dataVal.otherNode.data.relId,dataVal.otherNode.data.type,"create",dropNode.objectId,dropNode.relId);
        			} 
        			
        			dataVal.otherNode.copyTo(nodeVal,hitMode);
        			nodeVal.setExpanded(true);
        			getTopWindow().showTransientMessage(emxUIConstants.DND_DROPPEDCOPIED, 'success');
        		}
        	},false);

    }else{
    	//Move Operation
    	var relID,objID,type;
    	if(dragNode.relId){
    		objID = dragNode.objID;
    		relID = dragNode.relId;
    		type = dragNode.type;
    	}else{
    		objID = dataVal.otherNode.objID;
    		relID = dataVal.otherNode.relId;
    		type = dataVal.otherNode.type;
    	}
    	var objectIDtoSend;
    	if(dropNode.objectId){ 
    		objectIDtoSend = dropNode.objectId;
    	}else{
    		objectIDtoSend = nodeVal.objectId;
    	}
        var dataTosend =[{name: "moveFromId", value: {displayValue:relID, actualValue: relID}}];
    	var newObj = FoundationData.addObject(globalData,objectIDtoSend,dataTosend);//Send the parent Node where it is dropped dropNode.objectId
        FoundationData.applyUpdates(globalData, function(success){
        		if(!success){        			
        			getTopWindow().showTransientMessage(newObj.updateMessage);
        		}else{
        			var hitMode = dataVal.hitMode;
        			//if(nodeVal.parent.key.indexOf("root_") == 0){
        				hitMode ="child";
        			//}
        			
        			var isRefresh = isRefreshContentNeeded(dataVal.otherNode);
        			if(!isRefresh == false){        				
        				fancyTreeNodeClick(newObj.objectId,newObj.relId,newObj.type,"delete");
        			}         			
        			isRefresh = isRefreshContentNeeded(nodeVal);
        			if(!isRefresh == false){
        				fancyTreeNodeClick(newObj.objectId,newObj.relId,newObj.type,"create",dropNode.objectId,dropNode.relId);
        			}
        			
					dataVal.otherNode.moveTo(nodeVal,hitMode);
					nodeVal.setExpanded(true);
					getTopWindow().showTransientMessage(emxUIConstants.DND_DROPPEDMOVED, 'success');
        		}
        	},false );
    }
}

function enableScrollOnDrop(containers){
	var mouseoverTimer = null;
	jQuery(containers).on("dragenter dragleave", function(event){
		if(event.originalEvent.target == this){
			mouseoverTimer = null;
		}
	})
	.on("drop", function(event){
		mouseoverTimer = null;
	})
	.on("dragover", function(event, originalEvent){
		if(originalEvent){
			event = originalEvent;
		}
		if(event.originalEvent){
			event = event.originalEvent;
		}
		var delayToScroll = 1000; //1 second
		var edge = 50;
		var step = 10;
		var position = event.clientY > (jQuery(window).height() - edge) ? "south" : event.clientY < edge ? "north" : "other";
		if(position == "other"){
			mouseoverTimer = null;
		}
		else{
			if(!mouseoverTimer){
				mouseoverTimer = new Date();
				return;
			}
			else if (mouseoverTimer != "expired" && new Date().getTime() - mouseoverTimer.getTime() >= delayToScroll){
				mouseoverTimer = "expired";
			}
			if(mouseoverTimer != "expired") {
				return;
			}
			switch(position){
			case "south" :
				jQuery(this).scrollTop(jQuery(this).scrollTop() + step);
				break;
			case "north" :
				jQuery(this).scrollTop(jQuery(this).scrollTop() - step);
				break;
			}
		} 
	}); 
} 

        var jQDivId = "#genericFancyTree";
        var selectMode = 3;
        var selection = 0;
    	var strucData = null;
    	var structureTreeGeneric =false;
    	var deep = true;
        var hideZeros = true;
        var hideExpanded = false;
        var dataNode,otherNode;
        var imagePath = "";
        var clipboardNode = null;
        var pasteMode = null;


                
        function fancyTreeRMBClick(action, node) {
          switch( action ) {
          case "create":
    	    	  var init = { title: "",icon:"../../common/images/iconSmallFolder.png"};
    	    	  node.editCreateNode("child",init);
    	        break;
          case "edit":
        	  node.editStart();
        	  break;
          case "deleteNode":        	  	 
        	  	
        	     require(["DS/UIKIT/SuperModal"], function(SuperModal){
				 new SuperModal({
				     closable: true,
				     renderTo: getTopWindow().document.body
				 	}).confirm(emxUIConstants.DND_DeleteMessage, emxUIConstants.DND_AreYouSure, function (result) {
						 if(result){
	              var urlParam="mode=delete&";
	              for(var elem in node.data){
	              	if(elem!="url" && elem!="icon"){
	              		urlParam= urlParam +"&"+elem+"="+node.data[elem];
	              	}
	              }
	             var objID,relID,nodeType;
	             if(node.data.objectId){
	            	 objID = node.data.objectId;
	            	 relID = node.data.relId;
	            	 nodeType = node.data.type;
	             }else{
	            	 objID = node.objectId;
	            	 relID = node.relId;
	            	 nodeType = node.type;
	             }
				//This code to send the Request to server even its failied onetime(PENDING)
	            if(FoundationData.getObject(globalData, objID)._updateAction == "PENDING"){
	            	FoundationData.getObject(globalData, objID)._updateAction = undefined;
	            }

	            FoundationData.deleteObject(globalData,objID);
	            FoundationData.applyUpdates(globalData, function(success){
	            		if(!success){
	            			var obj = FoundationData.getObject(globalData, objID);	            			
	            			getTopWindow().showTransientMessage(obj.updateMessage);
	            		}else{
	            			//successful Delete of Node	            			
	            			var isRefresh = isRefreshContentNeeded(node);
	            			if(!isRefresh == false){
	            				fancyTreeNodeClick(objID,relID,nodeType,"delete");
	            			}
	            			node.remove();
	            			getTopWindow().showTransientMessage(emxUIConstants.DND_DROPPEDREMOVED, 'success');
	            		}
	            	},false );
						 }
        		     });
        	     });
        	  
	        break;
          default:
            //do Nothing
          }
        };

    	/**
        * This module is used to build the Structure Tree using fancy tree plugin
        * @example
        * require(['emxUIStructureFancyTree'], function (emxUIStructureFancyTree){
		*     objGenericFancyTree = emxUIStructureFancyTree;
		*     objGenericFancyTree.destroy();
		*     objGenericFancyTree.init(jsonOptions);
		* });
        * @version 1.0
        * @requires plugins/jQuery
        * @requires plugins/FancyTree
        * @author IXK
        * @since R417
        * @exports emxUIStructureFancyTree
        */
        var exports =  {
            className : "ENOFrameworkStructureView",
            isActive : false,
            init : function (serviceData) {
            		/*var SOURCE = [
            	              {title: "node 1", folder: true, expanded: true},
            	          	{title: "node 44", folder: true, expanded: true},
            	              {title: "node 2", folder: true, expanded: false, children: [
            	                {title: "node 2.1"},
            	                {title: "node 2.2"}
            	               ]}
            	            ];*/
            	var options = prepareJSON(serviceData,true);

            	if (options) {
            		selection=0;
            		strucData = options;
            		var len = strucData.length-1;
            		if(strucData[len] && strucData[len].settings){

            		}else{
            			savedStrucData = strucData;
            		}
            	} else {
            		strucData = savedStrucData;
            	}

                jQuery(jQDivId).fancytree({
                    extensions: ["filter","edit","dnd","persist","contextMenu"],
                    imagePath : imagePath,
                    selectMode : selectMode,
                    filter: {
                        mode: "hide",
                        autoApply: true
                     },

            		source: strucData,
            		click: function(event, data) {
            	        if( jQuery(".contextMenu:visible").length > 0 ){
            	          jQuery(".contextMenu").hide();
            	        }
            	        
            	        if(event.which!=3){
            				if( jQuery(".contextMenu:visible").length > 0 ){
                  	          jQuery(".contextMenu").hide();
                  	        }
                  	        if(data.targetType != 'expander'  && data.targetType != undefined){                  	        	
                  	        	var objId,relId,type;
                  	        	if(data.node.data.relId){
                        			relId = data.node.data.relId;
                        		}else{
                        			relId = data.node.relId;
                        		}
                          		if(data.node.data.objectId){
                          			objId = data.node.data.objectId;
                          			type = data.node.data.type;
                          		}else{
                          			objId = data.node.objectId;
                          			type = data.node.type;
                          		}
                          		if(!(typeof objId == "undefined")){
                          			fancyTreeNodeClick(objId,relId,type);
            					}
                          		data.node.setActive();
                          		return;
                  	        }
            			}            	        
            	        
            	      },

            		persist: {
                        expandLazy: true,
                        overrideSource: false,
                        store:  'local'
                       // store: 'auto', 			// auto,'cookie', 'local': use localStore, 'session': sessionStore
                        //'local': "localStore",
                        //types: "expanded"
                      },
            		activate: function (event, data) {

                    },
                    //RMB Menu
					contextMenu: {
						menu: {
						 'create': { 'name': emxUIConstants.FWCREATE, 'icon': 'add' },
						  'edit': { 'name': emxUIConstants.FWEDIT, 'icon': 'edit' },
						  'deleteNode': { 'name': emxUIConstants.FWDELETE, 'icon': 'delete' }
						  },
						actions: function(node, action, options) {
							//jQuery('#selected-action').text('Selected action "' + action + '" on node ' + node);
							fancyTreeRMBClick(action, node);
						}
                      },

            	      /*Bind context menu for every node when its DOM element is created.
            	        We do it here, so we can also bind to lazy nodes, which do not
            	        exist at load-time. (abeautifulsite.net menu control does not
            	        support event delegation)*/
            	      createNode: function(event, data){
            	        //bindContextMenu(data.node.span);

            	        //data.node.span.parentNode.addEventListener('dragover', dragoverFromOutside, false);
            	        //data.node.span.parentNode.addEventListener('drop', dropFromOutside, false);
            	        //data.node.span.parentNode.addEventListener('dragleave', dragleave, false);
						
						jQuery(data.node.span.parentNode).bind('dragover', dragoverFromOutside);
            	        jQuery(data.node.span.parentNode).bind('drop', dropFromOutside);
            	        jQuery(data.node.span.parentNode).bind('dragleave', dragleave);

            	        function dragleave(event) {            	        	
            	        	event.stopPropagation();
            	        	event.preventDefault();
            	        	if(jQuery(this)){
            	                hlNode = jQuery(this).find('span.fancytree-title').first();
            	            }
            	            if(hlNode){
            	                hlNode.removeClass('drop-no');
            	                hlNode.removeClass('drop-yes');
            	            } 
            	        	return false;
            	         }

            	        function dragoverFromOutside(event) {
	        	        	event.stopPropagation();
	        	        	event.preventDefault();	        	        	
					jQuery(document.body).trigger("dragover", jQuery(event)); //for scroll on drop
	        	        	console.log('dragover from outside');
	        	        	if(hlNode){
	        	                hlNode.removeClass('drop-no');
	        	                hlNode.removeClass('drop-yes');
	        	            }       
	        	            var storage = sessionStorage;
        	                var dragData = JSON.parse(storage.getItem("DnD"));
	        	            
	        	            var tempSpan = jQuery(this).find('span.fancytree-title').first();
	        	            if(dndValidation(this.ftnode.data.type,dragData, true, true)){     
	        	                tempSpan.addClass('drop-yes');
	        	            }else{      
	        	                tempSpan.addClass('drop-no');      
	        	            }
	        	            hlNode = tempSpan;
            	        	this.ftnode.setExpanded(true);
            	        	return false;
            	         }

            	        function dropFromOutside(event) {
            	        	event.stopPropagation();
            	        	event.preventDefault();
				jQuery(document.body).trigger("drop"); //for scroll on drop
            	        	//jQuery(this).children(".fancytree-node").removeClass("fancytree-focused");
            	        	if(jQuery(this)){
            	                hlNode = jQuery(this).find('span.fancytree-title').first();
            	            }
            	            if(hlNode){
            	                hlNode.removeClass('drop-no');
            	                hlNode.removeClass('drop-yes');
            	            }              	        	

            	        	//var droppedNode = event.dataTransfer.getData('text');
							var droppedNode = event.originalEvent.dataTransfer.getData('text');
            	        	dragDropOperationFromOutside(this.ftnode,droppedNode);
         	             	console.log(event+ 'dropped from outside');
         	             	return false;
         	            }
            	      },

                    lazyLoad: function (event, data) {
                        var node = data.node;
                        var allData = {};
                        for(var elem in node.data){
                        	if(elem!="url" && elem!="icon"){
                        		allData[elem]= node.data[elem];
                        	}
                        }
                        allData["mode"]="all";
                        //data.result = [];
                        var serviceURL = enoviaServer.getUrl() + WidgetEngine.tempURI(getServiceName());
                        WidgetAPIs.expandObject(globalData,node.data['objectId'],function(serviceData){
                        	node.addChildren(prepareJSON(serviceData,false));
                        },1);
                        data.result = [];

                    },
                    childcounter: {
        				deep: deep,
                        hideZeros: hideZeros,
                        hideExpanded: hideExpanded
        			},
        			dnd: {
	    			        autoExpandMS: 400,
	    			        focusOnClick: true,
	    			        preventVoidMoves: true,
	    			        preventRecursiveMoves: true,	    			        
	    			        containment: 'document',
	    			        scroll :false,	    			        
	    			        dragStart: function(node, data) {
	    			          /** This function MUST be defined to enable dragging for the tree.
	    			           *  Return false to cancel dragging of node.
	    			           */
	    			          return true;
	    			        },
	    			        dragEnter: function(node, data) {
	    			          /** data.otherNode may be null for non-fancytree droppables.
	    			           *  Return false to disallow dropping on node. In this case
	    			           *  dragOver and dragLeave are not called.
	    			           *  Return 'over', 'before, or 'after' to force a hitMode.
	    			           *  Return ['before', 'after'] to restrict available hitModes.
	    			           *  Any other return value will calc the hitMode from the cursor position.
	    			           */
	    			          // Prevent dropping a parent below another parent (only sort
	    			          // nodes under the same parent)
				    			/*           if(node.parent !== data.otherNode.parent){
				    			            return false;
				    			          }
				    			          // Don't allow dropping *over* a node (would create a child)
				    			          return ["before", "after"];
				    			*/
	    			        	
	    			        	//p9y to avoid drag and drop from personal to shared workspaces
	    			        	if(data.otherNode && classificationDnDValidation(node)!= classificationDnDValidation(data.otherNode)){	    			        		
	    			        		return false;
	    			        	}else{
	    			           return true;
	    			        	}
	    			        },
							draggable: { // modify default jQuery draggable options
							    scroll: true,
							    connectToFancytree: true
							  },
							droppable: { // modify default jQuery draggable options
							    scroll: false,
							    connectToFancytree: true
							},
	    			        dragDrop: function(node, data) {
	    			          /** This function MUST be defined to enable dropping of items on
	    			           *  the tree.
	    			           */
	    			        	 if( !data.otherNode ){ // It's a non-tree draggable
	    			        		 var title = jQuery(data.draggable.element).text();
	    			        		 return;
	    			        	 }else{
	    			        		 dragDropOperation(data.otherNode.data,node.data,node,data);
	    			        	 }
	    			        }
    			      },
    			      edit: {
    			    	  	triggerStart: ["f2", "dblclick", "shift+click", "mac+enter"],
    			    	    beforeEdit: function(event, data){

    			    	    },
    			    	    edit: function(event, data){

    			    	    },
    			    	    beforeClose: function(event, data){

    			    	    },
    			    	    save: function(event, data){
    			    	      // Only called when the text was modified and the user pressed enter or
    			    	      // the <input> lost focus.
    			    	      // Additional information is available (see `beforeClose`).
    			    	      // Return false to keep editor open, for example when validations fail.
    			    	      // Otherwise the user input is accepted as `node.title` and the <input>
    			    	      // is removed.
    			    	      // Typically we would also issue an Ajax request here to send the new data
    			    	      // to the server (and handle potential errors when the asynchronous request
    			    	      // returns).

    			    	    	 var node = data.node;
    			    	    	 //send parent information too  data.node.parent.data
    			    	    	 var parentData ="",pnode ="",mode;
    			    	    	 if(data.isNew){
    			    	        	 parentData = parentData+"&mode=create";
    			    	        	 pnode = data.node.parent.data;
    			    	        	 mode = "create"; 
    			    	         }else{
    			    	        	 parentData = parentData+"&mode=rename";
    			    	        	 pnode =data.node.data;
    			    	        	 mode = "rename";
    			    	         }
			    	            for(var elem in pnode){
			    	            	if(elem!="url" && elem!="icon")
			    	            		parentData = parentData +"&"+elem+"="+pnode[elem];
			    	            }
			    	            var objID,objType,relID;
			    	            if(data.node.data.objectId){
									objID = data.node.data.objectId;
									relID = data.node.data.relId;
									objType = data.node.data.type; 
								}else if(data.node.objectId){
									objID = data.node.objectId;
									relID = data.node.relId;
									objType = data.node.type;
								}else if(data.node.parent.objectId){
									objID = data.node.parent.objectId;
									relID = data.node.parent.relId;
									objType = data.node.parent.type;
								}else{
									objID = data.node.parent.data.objectId;
									relID = data.node.parent.data.relId;
									objType = data.node.parent.data.type;									
								}
			    	            //Call the Validation() to check any Validations
		    	            	var validationRes = createORRenameValidation(data.input.val(), objType, mode ,pnode);
			    	            if(validationRes){
			    	            var dataTosend =[{name: "title", value: {displayValue:data.input.val(), actualValue: data.input.val()}}];
			    	            if(!data.isNew){
			    	            //to Rename the Node
			    	            	//This code to send the Request to server even its failied onetime(PENDING)
			    		            if(FoundationData.getObject(globalData, objID)._updateAction == "PENDING"){
			    		            	FoundationData.getObject(globalData, objID)._updateAction = undefined;
			    		            }
				    	            FoundationData.modifyObject(globalData,objID,dataTosend);
				    	            FoundationData.applyUpdates(globalData, function(success){
				    	            		if(!success){
				    	            			var obj = FoundationData.getObject(globalData, objID);
				    	            			node.setTitle(data.orgTitle);				    	            			
				    	            			getTopWindow().showTransientMessage(obj.updateMessage);
				    	            		}else{
				    	            			//successful renaming Node
					    	            			 getTopWindow().showTransientMessage(emxUIConstants.DND_DROPPEDRENAMED, 'success');
					    	            			 var isRefresh = isRefreshContentNeeded(node);
					    	            			 if(!isRefresh == false){
					    	            				 fancyTreeNodeClick(isRefresh.data.objectId,isRefresh.data.relId,isRefresh.data.type,"rename");
					    	            			 }
				    	            			 node.render();
				    	            		}
			    	            	},false);
			    	            }else{
			    	            	//To Create a new node
			    	            	var newObj = FoundationData.addObject(globalData,objID,dataTosend);
				    	            FoundationData.applyUpdates(globalData, function(success){
				    	            		if(!success){				    	            			
				    	            			node.remove();
				    	            			getTopWindow().showTransientMessage(newObj.updateMessage);
				    	            		}else{
				    	            			 node.objectId = newObj.objectId;
		    			    	        		 node.relId = newObj.relId;
		    			    	        		 node.type = newObj.type;
		    			    	        		 node.icon = newObj.dataelements.typeIcon.value[0].imageValue;
		    			    	        		 node.url = newObj.url;
		    			    	        		 node.key = newObj.objectId;//+"-"+newObj.relId;//TO frame a UNIQUE KEY
		    			    	        		 node.data.fromconnectAccess = FoundationData.getFieldValue(newObj,"fromconnectAccess").displayValue;
		    			    	        		 node.data.modifyAccess = FoundationData.getFieldValue(newObj,"modifyAccess").displayValue;
		    			    	        		 node.data.deleteAccess = FoundationData.getFieldValue(newObj,"deleteAccess").displayValue;
			    			    	        		 
			    			    	        		 var isRefresh = isRefreshContentNeeded(node);
					    	            			 if(!isRefresh == false){
					    	            				 fancyTreeNodeClick(node.objectId,node.relId,node.type,"create",objID,relID);
					    	            			 }
		    			    	        		 node.render();
		    			    	        		 getTopWindow().showTransientMessage(emxUIConstants.DND_DROPPEDCREATED, 'success');
		    			    	        		 //fancyTreeNodeClick(newObj.objectId,newObj.relId,newObj.type);
				    	            		}
				    	            	},false );
			    	            }
    			    	        return true;
			    	            }else{
			    	            	return false;
			    	            }
    			    	       
    			    	    },
    			    	    close: function(event, data){
    			    	      // Editor was removed.
    			    	      // Additional information is available (see `beforeClose`).
    			    	    }
    			    	  }
                });


                this.isActive = true;
                jQuery("#FancyTree-loading").hide();
                jQuery("#genericFancyTree").show();

                
               /* Fancy Tree Filter sample Code*/
                 var tree = jQuery("#genericFancyTree").fancytree("getTree");
                jQuery("input[name=search]").keyup(function(e){
                		var n,
                		leavesOnly = jQuery("#leavesOnly").is(":checked"),
                     	match = jQuery(this).val();
                   		if(e && e.which === jQuery.ui.keyCode.ESCAPE || jQuery.trim(match) === ""){
                   			jQuery("button#btnResetSearch").click();
                   			return;
                   		}
                   		n = tree.filterNodes(match, leavesOnly);

                   		jQuery("button#btnResetSearch").attr("disabled", false);
                   		jQuery("span#matches").text("(" + n + " matches)");
                 }).focus();

               jQuery("button#btnResetSearch").click(function(e){
                   jQuery("input[name=search]").val("");
                   jQuery("span#matches").text("");
                   tree.clearFilter();
                 }).attr("disabled", true);               
	       enableScrollOnDrop(document.body);
		       var node = jQuery(jQDivId).fancytree("getRootNode");
		       node.sortChildren(function _compareTitle(a, b){
		                       var nameA = a.title.toLowerCase();
		                       var nameB = b.title.toLowerCase();
		                       if(a.data.type == "Personal Workspace")
		                                       return 1;
		                       if( b.data.type == "Personal Workspace")
		                                       return -1;
		                       
		                       if (nameA < nameB) {
		                                       return -1;
		                       } else{
		                                       return 1;
		                       }
		       }, true);
            },


            /**
             * This function is used to add a child Node to the Root node of a Structure Tree
             * @param {string} objectId - The Object id of the node to add
             * @returns {boolean}
             */
            addChildToRoot : function (objectId) {
                //var testObj = [{ title: "Folder 111", lazy: true, icon : "iconSmallFolder.gif" }];
                var rootNode = this.getRootNode();
                return this.addChild(rootNode.key, objectId);
            },

            /**
             * This function is used to add a child Node to a context node of a Structure Tree
             * @param {string} parentId - The Parent id of the node to add
             * @param {string} objectId - The Object id of the node to add
             * @example
             * if(objGenericFancyTree){
             *     objGenericFancyTree.addChild(strParentId, strObjectId);
             * }else{
             *     //legacy code
             * }
             * @returns {boolean}
             */
            addChild : function (parentId, objectId) {
                var self, node = this.getNodeById(parentId);
                self = this;
                jQuery.ajax({
                    dataType : "json",
                    url : treeAddURL,
                    data : {
                        objectId: objectId,
                        mode: "nodeData"
                    },
                    success: function (nodeData) {
                        var rootNode, newNode = node.addChildren(nodeData);
                        newNode.setActive();
                        rootNode = self.getRootNode();
                        rootNode.sortChildren(null, true);
                        strucData[selection].children.push(nodeData[0]);
                        updateBcList();
                    }
                });
                return true;
            },
            /**
             * This function is used to get a node of a Structure Tree
             * @param {string} objectId - The Object id of the node to get
             * @returns {FancyTreeNode}
             */
            getNodeById : function (objectId) {
                var node = jQuery(jQDivId).fancytree("getTree").getNodeByKey(objectId);
                return node;
            },
            /**
             * This function is used to get the root node of Structure Tree
             * @returns {FancyTreeNode}
             */
            getRootNode : function () {
                var rootNode = jQuery(jQDivId).fancytree("getRootNode").getChildren()[0];
                return rootNode;
            },
            /**
             * This function is used to set a active node of a Structure Tree
             * @param {string} objectId - The Object id of the node to activate
             * @returns {boolean}
             */
            setActiveNode : function (objectId) {
                var node = this.getNodeById(objectId);
                if (node){
                	 node.setActive();
                     return true;
                } else {
                	return false;
                }
            },
            /**
             * This function is used to get a active node of a Structure Tree
             * @returns {FancyTreeNode}
             */
            getActiveNode : function () {
                var node = jQuery(jQDivId).fancytree("getActiveNode");
                return node;
            },
            /**
             * This function is used to remove a node from a Structure Tree
             * @param {string} objectId - The Object id of the node to remove
             * @example
             * if(objGenericFancyTree){
             *     objGenericFancyTree.removeChild(strObjectId);
             * }else{
             *     //legacy code
             * }
             * @returns {boolean}
             */
            removeChild : function (objectId) {
                var node = this.getNodeById(objectId);
                if (node) {
                	node.removeChildren();
                    node.remove();
                    for(var index=0;index<strucData[0].children.length;index++) {
                    	if(strucData[0].children[index].key==node.key) {
                    		strucData[0].children.splice(index,1);
                    	}
                    }
                    //updateBcList();
                    return true;
                } else {
                	return false;
                }
            },
            /**
             * This function is used to expand all nodes of a Structure Tree
             * @returns {boolean}
             */
            expandAll : function () {
                jQuery(jQDivId).fancytree("getRootNode").visit(function (node) {
                    node.setExpanded(true);
                });
                return true;
            },
            /**
             * This function is used to collapse all nodes of a Structure Tree
             * @returns {boolean}
             */
            collapseAll : function () {
                jQuery(jQDivId).fancytree("getRootNode").visit(function (node) {
                    node.setExpanded(false);
                });
                return true;
            },
            /**
             * This function is used to modify the title of a Structure Tree
             * @param {string} objectId - The Object id of the node to modify
             * @param {string} strTitle - The title of the node
             * @example
             * if(objGenericFancyTree){
             *     objGenericFancyTree.setTitle(strObjectId, strTitle);
             * }else{
             *     //legacy code
             * }
             * @returns {boolean}
             */
            setTitle : function (objectId, strTitle) {
                var node = this.getNodeById(objectId);
                if (node) {
                	node.setTitle(strTitle);
                	for ( var index in strucData[0].children) {
                		if (strucData[0].children[index].key == node.key) {
                			strucData[0].children[index].title = strTitle;
                		}
                	}
                	//updateBcList();
                	return true;
                } else {
                	return false;
                }
            },
            /**
             * This function is used chnage the object Id of a  Structure Tree node
             * @param {string} objectId - The Object id of the node to modify
             * @param {string} newObjectId - The New Object id
             * @example
             * if(objGenericFancyTree){
             *     objGenericFancyTree.setObjectId(objectId, newObjectId);
             * }else{
             *     //legacy code
             * }
             * @returns {void}
             */
            setObjectId : function (objectId, newObjectId) {
            	jQuery(jQDivId).fancytree("getTree").changeRefKey(objectId, newObjectId);
            },
            /**
             * This function is used to refresh the Structure Tree
             * @example
             * if(objGenericFancyTree){
             *     objGenericFancyTree.refreshTree();
             * }else{
             *     //legacy code
             * }
             * @returns {jQuery.Promise}
             */
            refreshTree : function () {
            	return jQuery(jQDivId).fancytree("getTree").reload([strucData[selection]]);
            },

            /**
             * This function is used to re-initialize the Structure Tree when the back/forward
             * operation are called to switch between the components
             *
             * @returns {void}
             */
            reInit: function(jsonData)
            {
            	/*
            	 * The check for jsonData is to verify whether a Structure Tree needs to be shown for the component or not
            	 */
            	if (jsonData) {
            		this.destroy();
            		this.init(jsonData);
            	} else {
            		jQuery("#genericFancyTree").hide();
            	}
            },

            /**
             * This function is used to modify the title of a Structure Tree
             * @returns {void}
             */
            destroy : function () {
                this.isActive = false;
                jQuery(jQDivId).fancytree("destroy");
                jQuery(jQDivId).empty();
                return true;
            }

        };
        return exports;
    }); 

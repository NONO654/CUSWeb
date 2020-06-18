/*jshint browser: true, devel: true*/
/*global define,jQuery,emxUICore,findFrame,getTopWindow*/
define('emxUIStructureFancyTree',
    [], function () {
        'use strict';
        //Private members
        var savedStrucData=null;
        function reLoadStructureTree() {
        	var treeBarSelectedIndex = jQuery(	"#treeBarSelect option:selected").index();
        	var objStructureFancyTree = getTopWindow().objStructureFancyTree;
        	selection = treeBarSelectedIndex;
        	objStructureFancyTree.destroy();
        	objStructureFancyTree.init();
        }
        
        function drawTreeBar(strucData) {
        	jQuery("#togglecat").after("<div id='treeBar'>");
        	jQuery("#treeBar").append("<select id='treeBarSelect'>").change(reLoadStructureTree);
					var treeBar = jQuery("#treeBarSelect");
					treeBar.empty();
					for (var i = 0; i < strucData.length; i++) {
						var opt = jQuery("<option>");
						opt.val(strucData[i].optionLbl);
						opt.html(strucData[i].optionLbl);
						treeBar.append(opt);
					}
        };
        function updateBcList() {
        	var currBC=getTopWindow().bclist.getCurrentBC();
			if(currBC.fancyTreeData){
				currBC.fancyTreeData.structureTree= JSON.stringify(strucData);
			}
        }
        
        
        var jQDivId = "#leftPanelTree";
        var imagePath = "../common/images/";
        var selectMode = 3;
        var treeDataUrl = "../common/emxUIStructureFancyTreeGetData.jsp";
        var nodeDataUrl = "../common/emxUIStructureFancyTreeGetNodeData.jsp";
        var selection=0;
    	var strucData=null;
    	/**
        * This module is used to build the Structure Tree using fancy tree plugin
        * @example
        * require(['emxUIStructureFancyTree'], function (emxUIStructureFancyTree){
		*     objStructureFancyTree = emxUIStructureFancyTree;
		*     objStructureFancyTree.destroy();
		*     objStructureFancyTree.init(jsonOptions);
		* });
        * @version 1.0
        * @requires plugins/jQuery
        * @requires plugins/FancyTree
        * @author IXK
        * @since R417
        * @exports emxUIStructureFancyTree
        */
        var exports =  {
            //Internal use only
            className : "emxUIStructureFancyTree",
            //Internal use only
            fromActivateNode : false,
            //Internal use only
            isActive : false,
            //Internal use only
            init : function (options, isReInit) {
				var treeBarDiv = jQuery("#treeBar");
				var self = this;
				var isReInit = isReInit === true;
				var updateStrucData = function (strucData) {
	               
	                jQuery(jQDivId).fancytree({
	                    extensions: ["childcounter", "filter", "persist"],
	                    imagePath : imagePath,
	                    selectMode : selectMode,
	                    activate: function (event, data) {
	                        var strTarget, node = data.node;
	                        strTarget = 'content';
							checkMMY = false;
							self.fromActivateNode = true;
	                        var hasChildren = node.hasChildren() === true; 
	                        if(!node.isExpanded() && !hasChildren){
	                        	node.toggleExpanded(false);
	                        }
	                        emxUICore.link(node.data.url, strTarget);
							var objStructureFancyTree = getTopWindow().objStructureFancyTree;
                        	if(objStructureFancyTree){
                        		var childNodeList = objStructureFancyTree.getNodeListById(node.key);
                        		if(childNodeList != null && childNodeList.length > 1){
									//Linked folder - set parentnodeId in local storage - used in persist js
                        			localStorage.setItem(objStructureFancyTree.getRootNode().key + "|" + node.key,node.parent.key);   			        	
                        		}
                        	}
	                    },
	            		source: [strucData[selection]],
	                    lazyLoad: function (event, data) {
	                        var node = data.node;
	                        data.result = jQuery.ajax({
	                            url: treeDataUrl,
	                            dataType: "json",
								cache:false,
	                            data: {
	                                objectId: node.data.objectId,
	                                structureTreeMenu: node.data.structureTreeName,
	        						commandName: node.data.commandName,
	        						emxSuiteDirectory: node.data.SuiteDirectory,
	        						reinit:""
	                            },
								success: function(d){setTimeout(function(){node.makeVisible({scrollIntoView: false}); }, 500)}
	                        });
	                    },

						persist: {
                        	cookiePrefix : strucData[0].contextUser + "|" + strucData[0].key,
                        	isTreeReInit : isReInit,
                        	expandLazy: true,
                        	overrideSource: false,
                        	store:  'local'
                        },

	                    childcounter: {
	        				deep: true,
	                        hideZeros: true,
	                        hideExpanded: false
	        			},
	                });
	                
	                self.isActive = true;
	                jQuery("#togglecat").show();
	                jQuery("#leftPanelTree").show();
	                jQuery("#catMenu").hide();
	                jQuery("#catMenu").css('top', '16px');
	                jQuery("div#togglecat").find('button#catButton').attr('title',emxUIConstants.STR_CATEGORIES);
	                jQuery("div#togglecat").find('button#strucButton').attr('title',emxUIConstants.STR_STRUCTURE_VIEW);
	                if (jQuery("button#strucButton").attr('class') == 'toggle-inactive') {
	            		jQuery("button#catButton").removeClass("toggle-active");
	            		jQuery("button#catButton").addClass("toggle-inactive");
	            		jQuery("button#strucButton").removeClass("toggle-inactive");
	            		jQuery("button#strucButton").addClass("toggle-active");
	            	}
					
					
	            };	        	
				
				
            	if (options) {
					this.destroy();
            		jQuery('#leftPanelTree').css('top', '38px');
            		selection=0;
            		strucData = JSON.parse(options.structureTree);
            		savedStrucData = strucData;
            		if (treeBarDiv) {
            			treeBarDiv.remove();
            		}
            		if (strucData.length > 1) {
						jQuery('#leftPanelTree').css('top', '74px');
						drawTreeBar(strucData);
					}
            		
            		updateStrucData(strucData);
            		
            	} else {
					if(treeBarDiv){
                        jQuery("#treeBar").show();
            			jQuery('#leftPanelTree').css('top', '74px');
            		}else{
            			jQuery('#leftPanelTree').css('top', '38px');
            		}
					
            		strucData = savedStrucData;         		
            		
            		
            		var oid = strucData[selection].key;
            		var menu = strucData[selection].structureTreeMenu;
            		
            		jQuery.ajax({
                          url: treeDataUrl,
                          dataType: "json",
                          data: {
                              objectId: oid,
                              structureTreeMenu: menu,
      						  reinit:"reinit"
                          },
            			  success : function (strucDataSon) {
            				  
            				  strucData = JSON.parse(strucDataSon.structureTree);  
            				  updateStrucData(strucData);            				  
            			  }                        
                      });  
            		
            	}            	
            	
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
             * if(objStructureFancyTree){
             *     objStructureFancyTree.addChild(strParentId, strObjectId);
             * }else{
             *     //legacy code
             * }
             * @returns {boolean}
             */
            addChild : function (parentId, objectId, isNodeActivateFlag) {
                var self, node = this.getNodeById(parentId);
                var isNodeSetActiveFlag = isNodeActivateFlag === true;
                self = this;
                jQuery.ajax({
                    dataType : "json",
                    url : nodeDataUrl,
                    async : false,
                    data : {
                        objectId: objectId,
                        mode: "nodeData",
                        rootId: self.getRootNode().key
                    },
                    success: function (nodeData) {
                        var rootNode, newNode = node.addChildren(nodeData);
                        newNode.setFocus();
						if(isNodeSetActiveFlag){
			   				newNode.setActive();
		          		}
                        rootNode = self.getRootNode();
                        rootNode.sortChildren(null, true);                      
                      
                        
                        if(node.key===rootNode.key){
                            strucData[selection].children.push(nodeData[0]);
                        }
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
                if(this.isActive) {
            		var node = jQuery(jQDivId).fancytree("getTree").getNodeByKey(objectId);
            		return node;
            	}
            	else {
            		return null;
            	}
            },
			
            getNodeListById : function (objectId) {
                var childNodes = [];
                if(this.isActive) {
		  			var rootNode = objStructureFancyTree.getRootNode();
		  			rootNode.visit(function(node){
						if(node.key == objectId){
							childNodes.push(node);
						}
		  			});
		 		}else {
            		return null;
            	}
			return childNodes;
            },
			
			getNodeByTitle : function (rootNode,title,objectId) {
					var childNode = null;
					var index=null;
					var temp=null;
					var check=null;
				rootNode.visit(function(node){
					 index= node.title.indexOf("&");
					 check= title.indexOf("&");
					 temp=node.title;
					 
					if(index>0 && (check==-1)){
						temp=node.title.substring(0,index);
						index=node.span.textContent.indexOf(temp);
						temp=node.span.textContent.substring(index,node.span.textContent.length);
					}
					if(temp == title && node.key == objectId){
						childNode = node;
				  		return false; // stop traversal (if we are only interested in first match)
 						}
					});
				
				return childNode;
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
             * if(objStructureFancyTree){
             *     objStructureFancyTree.removeChild(strObjectId);
             * }else{
             *     //legacy code
             * }
             * @returns {boolean}
             */
            removeChild : function (objectId,rootnode) {
                var node = this.getNodeById(objectId);
				if(rootnode){
					var title = node.title;
					node = this.getNodeByTitle(rootnode,title,objectId);
				}					
                if (node) {
                	node.removeChildren();
                    node.remove();
                    for(var index=0;index<strucData[0].children.length;index++) {
                    	if(strucData[0].children[index].title==node.title && strucData[0].children[index].key==node.key) {
                    		strucData[0].children.splice(index,1);                   		
                    	}
                    }
                    updateBcList();
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
             * if(objStructureFancyTree){
             *     objStructureFancyTree.setTitle(strObjectId, strTitle);
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
					if(strucData[0] && (strucData[0].key == node.key)){
                		strucData[0].title = strTitle;
                	}
                	updateBcList();
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
             * if(objStructureFancyTree){
             *     objStructureFancyTree.setObjectId(objectId, newObjectId);
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
             * if(objStructureFancyTree){
             *     objStructureFancyTree.refreshTree();
             * }else{
             *     //legacy code
             * }
             * @returns {jQuery.Promise}
             */
            refreshTree : function () {
            		return  setTimeout(function() { jQuery(jQDivId).fancytree("getTree").reload([strucData[selection]])}, 2000);
            },
           
            /**
             * This function is used to re-initialize the Structure Tree when the back/forward
             * operation are called to switch between the components
             * 
             * @returns {void}
             */
            reInit: function(jsonData, isTreeReinit)
            {
            	/*
            	 * The check for jsonData is to verify whether a Structure Tree needs to be shown for the component or not 
            	 */
            	if (jsonData) {
            		this.destroy();
            		this.init(jsonData, isTreeReinit);
            	} else {
            		if (jQuery("#treeBar")) {
            			jQuery("#treeBar").hide();
            		}
            		jQuery("#togglecat").hide();
            		jQuery("#leftPanelTree").hide();
            		jQuery("#catMenu").show();
            		jQuery("#catMenu").css('top', '16px');
            	}
            },
            
		expandAndFocusNode : function(objectId, title) {
            	if(this.isActive) {
                    var childNodeList = this.getNodeListById(objectId);
                    var childNode = null;
			        if(childNodeList == null || childNodeList.length == 0){
			      		return;
			        }
			        else if(childNodeList.length  == 1){
	                    childNode=this.getNodeById(objectId);
					}else{
				    	childNode=this.getNodeByTitle(objStructureFancyTree.getRootNode(), title, objectId);
			      	}
					if(childNode) {
                    	var parentNode = childNode.getParent();
            			if (objStructureFancyTree && objStructureFancyTree.getRootNode().key != objectId ) {
            				parentNode.setExpanded();
                    	}
						var fancyTree=jQuery(jQDivId).fancytree("getTree");
            			childNode.setFocus();
						setTimeout(function(){
						childNode.setActive();
            			},100);
						fancyTree.focusNode=childNode;
            			fancyTree.activeNode=childNode;
						var hasChildren = childNode.hasChildren() === true; 
                        if(!childNode.isExpanded() && !hasChildren){
							setTimeout(function(){
                        	childNode.toggleExpanded(false);
							},100);
                        	
                        }
            		}
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
                jQuery("#catMenu").css('top', '0px');
				jQuery('#leftPanelTree').css('top', '0px');
				jQuery('#leftPanelTree').hide();
				jQuery("#treeBar").hide();
                jQuery("#togglecat").hide();
                return true;
            },
            //Internal use only
            handleNodeClick : function (select, node) {
                var strTarget = "detailsDisplay";
                emxUICore.link(node.data.url, strTarget);
            },
            //Internal use only
            onLazyRead : function (node) {
                node.appendAjax({
                    url: treeDataUrl,
                    data: {
                        objectId: node.data.objectId,
                        structureTreeMenu: node.data.structureTreeName,
                        mode: "children"
                    }
                });
            }
        };
        return exports;
    });

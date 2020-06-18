
define('DS/ENOLifecycleConceptExplorer/ENOLifecycleConceptExplorerMainController',
	[
		'UWA/Core',
		'UWA/Controls/Abstract',
		'DS/ENOLifecycleConceptExplorer/ENOLifecycleConceptExplorerPropertiesPanel'
	],
	function(UWA, Abstract, ENOLifecycleConceptExplorerPropertiesPanel)
	{
		'use strict';

		var controller=Abstract.extend({

			data:null,
			treeData:null,
			CETree:null,
			CEPropertiesPanel:null,
			widget:null,
			currentPerson: { login: 'default', image: 'SWXDefaultPersonImage.png', name: "Default User" },
			nodeSelectionList:[],
			TYPE_OF_OPERATION:{
				NO_OPERATION:0,
				DISPLAY_ALERT:1,
				DISPLAY_NEW_TREE:2,
				REFRESH_TREE:3,
				DISPLAY_CREATE_CONCEPT_POINT_BUTTON_VIEW: 4,
				HIGHLIGHT_NODE:5,
				CREATE_CONCEPT_POINT:5,
				CREATE_CONCEPT_BRANCH:6,
				REFRESH_NODE_DATA_ONLY:7,
				SET_CURRENT_USER:9,
				DISPLAY_BLANK_ALERT:10
			},
			WIDGET_STATES:{
			    DEBUG:0,
			    CONNECTED_VIA_COM_IE:1,
			    CHROMIUM_BROWSER:2,
			    STANDALONE:3,
			    CONNECTED_VIA_HYPERVISOR:4

			},

			CURRENT_WIDGET_STATE:null,   

			CENodeUIController:null,

			iconPath:'',

			setMenuLocalization:false,

			init:function(options)
			{
				/*options{
					CETree: ENOLifecycleTreeView object,
					CENodeUIController: Node UI Controller
					CEPropertiesPanel: Properties Panel
					iconPath: path for icons
				}*/
				this._parent(options);
				this.CETree=options.CETree;
				this.CENodeUIController=options.CENodeUIController;
				this.widget=options.widget;
				this.CURRENT_WIDGET_STATE=this.WIDGET_STATES.DEBUG
				this.iconPath=options.iconPath;
			},

			//This is invoked from C++.
			//One Interface to pass data and invoke a function
			runOperation:function(operationType,data)
			{
				if(!this.setMenuLocalization && this.widget.localize)
				{
					this.widget.body.getElement(".menuHome").setAttributes({title:this.widget.localize.home});
					this.widget.body.getElement(".menuRefresh").setAttributes({title:this.widget.localize.refresh});
					this.widget.body.getElement(".menuExpandAll").setAttributes({title:this.widget.localize.expandAll});
					this.widget.body.getElement(".menuCollapseAll").setAttributes({title:this.widget.localize.collapseAll});
					this.widget.body.getElement(".menuShowMinimap").setAttributes({title:this.widget.localize.showMinimap});
					this.widget.body.getElement(".menuHideMinimap").setAttributes({ title: this.widget.localize.hideMinimap });
					this.widget.body.getElement(".menuLatestOnTop").setAttributes({ title: this.widget.localize.NewestAtTop });
					this.widget.body.getElement(".menuLatestAtBottom").setAttributes({ title: this.widget.localize.NewestAtBottom });

					this.widget.body.getElement(".minimap-close").setAttributes({ title: this.widget.localize.closeMinimap });
					this.widget.body.getElement(".minimap-icon.zoomin").setAttributes({ title: this.widget.localize.zoomIn });
					this.widget.body.getElement(".minimap-icon.zoomout").setAttributes({ title: this.widget.localize.zoomOut });
					this.widget.body.getElement(".minimap-icon.zoomtofit").setAttributes({ title: this.widget.localize.fitAll });


                    this.setMenuLocalization=true;
				}
				
				this.displayBlankAlert(false);
				this.displayCreateConceptPointButton(false);
				this.displayTreeView(true);

				try{

					switch(operationType)
					{
						case this.TYPE_OF_OPERATION.DISPLAY_ALERT:
							{
								this.displayAlert(data);
							}
							break;
						case this.TYPE_OF_OPERATION.DISPLAY_NEW_TREE:
							{
								this.newMap(data);
							}
							break;
						case this.TYPE_OF_OPERATION.REFRESH_TREE:
							{
								this.refreshMap(data);	
							}
							break;
					    case this.TYPE_OF_OPERATION.DISPLAY_CREATE_CONCEPT_POINT_BUTTON_VIEW:
							{
								this.displayCreateConceptPointButton(true, data);
								this.displayBlankAlert(false);
								this.displayTreeView(false);
							}
							break;
						case this.TYPE_OF_OPERATION.HIGHLIGHT_NODE:
							{
								this.highlightNode(data);
							}
							break;
						case this.TYPE_OF_OPERATION.CREATE_CONCEPT_POINT:
							{
								this.createConceptPoint(data);
							}
							break;
						case this.TYPE_OF_OPERATION.CREATE_CONCEPT_BRANCH:
							{
								this.createConceptBranch(data);
							}
						break;
						
						case this.TYPE_OF_OPERATION.SET_CURRENT_USER:
							{
								this.setCurrentUser(data);
							}
							break;

						case this.TYPE_OF_OPERATION.DISPLAY_BLANK_ALERT:
							{
								this.displayBlankAlert(true, data);
								this.displayCreateConceptPointButton(false);
								this.displayTreeView(false);
							}
							break;
					}
				}
				catch(e)
				{
					//alert(e.message);
				}
			},

			displayAlert:function(data){

				var alert=this.widget.body.getElement(".display-alert");
				if(alert)
				{
					var okButton=alert.getElement("button.alert-ok");
					if (okButton)
					{
						okButton.setHTML((widget.localize?widget.localize.OK:'OK'));
						okButton.addEvents({
							click:function(evt){
								alert.hide();
							}
						})
					}
					alert.getElement(".modal-body > p").setText(data);
					alert.show();

				}
			},

			newMap:function(data){
				
				this.refreshMap(data)
				this.CETree.reframeAll();
				this.CEPropertiesPanel.hidePanel();

			},

			refreshMap:function(data){

				this.data=data ? data:this.data;
				this.treeData=JSON.parse(this.data);
				this.setupTreeDataForTreeView(this.treeData);
				this.CETree.loadTree(this.treeData);
				this.CENodeUIController.setAllNodesEventHandlers();
				//If the properties panel is visible, refresh the content with latest and greatest node data
				if (this.CEPropertiesPanel && this.CEPropertiesPanel.isVisible())
				{
					if (this.treeData.nodes.length >= this.CEPropertiesPanel.nodeData.id)
						this.setPropertiesPanelData(this.treeData.nodes[this.CEPropertiesPanel.nodeData.id-1]);
					else
						this.CEPropertiesPanel.hidePanel();
				}

				if(this.treeData.settings.error && this.treeData.settings.error.length)
				{
					this.displayAlert(this.treeData.settings.error);
				}
				else
				{
					this.widget.body.getElement(".display-alert").hide();
				}
				
				if(this.isCreateConceptConceptPointButonViewVisible())
				{
					this.displayCreateConceptPointButton(false);
				}
				this.displayBlankAlert(false);
			},

			displayCreateConceptPointButton:function(show, productName){
				
				if(show)
				{
					var ele=this.widget.body.getElement(".create-concept-point-button-div");
					ele.getElement('.title-div').setHTML(productName);
					ele.getElement('.text-div').setHTML(widget.localize ? 
								widget.localize.noConceptPoints : "There are no concept points created for this model yet.");
					var span=ele.getElement('.button-div-create-concept-point .button-div-text');
					if(!span)
					{
						UWA.createElement('span',{
							'class':'button-div-text',
							html:widget.localize ? widget.localize.createConceptPoint : "Create Concept Point"
						}).inject(ele.getElement('.button-div-create-concept-point'));
					}
					ele.show();

				}
				else
				{
					this.widget.body.getElement(".create-concept-point-button-div").hide();
				}
			},

			highlightNode:function(data){

				this.data=data ? data:this.data;
				var node_elements=this.widget.body.querySelectorAll("div.eno-lifecycle-node");
				for(var i=0; i<node_elements.length; i++)
				{
					if(node_elements[i].nodeData && node_elements[i].nodeData.id==data)
					{
						UWA.extendElement(node_elements[i]).addClassName('eno-lifecycle-node-highlighted');
					    node_elements[i].nodeData.active = true;
					}
					else
					{
						UWA.extendElement(node_elements[i]).removeClassName('eno-lifecycle-node-highlighted');
					    node_elements[i].nodeData.active = false;
					}
				}
				
			},

			createConceptPoint:function(data){
				
				this.data=data ? data:this.data;
		
			},

			createConceptBranch:function(data){

				this.data=data ? data:this.data;
				
			},
			
			expandAll:function(){
				if (this.treeData && this.treeData.nodes.length>1)
				{
				    this.CETree.expandAll();

				    //IR-404435-3DEXPERIENCER2016x
					//The node event handlers are getting lost when collapse all is called and then expanded
					this.CENodeUIController.setAllNodesEventHandlers();
				}
			},

			collapseAll:function(){

				if (this.treeData && this.treeData.nodes.length>1)
				{
					this.CETree.collapseAll();
				}
			},

			invokeCommand:function(nodeIDList, commandID, options)
			{
				var that=this;
				if (this.CURRENT_WIDGET_STATE==this.WIDGET_STATES.DEBUG)
				{
					console.log("Node ID: " + nodeIDList[0] + ", MenuID: " + commandID);

					if (commandID==3 || commandID==7)
					{
						this.showPropertiesPanel(this.treeData.nodes[nodeIDList[0]-1],commandID==3?'comments':'properties');
					}
					if(commandID==101)
					{
						this.treeData.nodes[nodeIDList[0]-1].comments.push({
								person:{
									name:"Default User",
									image: that.iconPath + 'SWXDefaultPersonImage.png'
									},
								when:(new Date()).getTime()/1000,
								text:options.COMMENT
						});

						this.CEPropertiesPanel.addComment(
							this.treeData.nodes[nodeIDList[0]-1].comments[this.treeData.nodes[nodeIDList[0]-1].comments.length-1],
						 	!this.treeData.nodes[nodeIDList[0]-1].comments.length);
					}
				}

				else if (this.CURRENT_WIDGET_STATE==this.WIDGET_STATES.CHROMIUM_BROWSER)
				{
					var JSONObject={
			                        EXECUTE_COMMAND:Number(commandID),
			                        NODE_ARRAY:nodeIDList
			                    };
			        if (options)
			        {
			        	for(var key in options){
			        		JSONObject[key]=options[key]
			        	}
			        }
					switch(Number(commandID))
					{
						case 3: 		//Show Comments
							{
								this.treeData.nodes[nodeIDList[0]-1].showComments();
							}
							break;
						
						case 4: 		//AllComments
						
							break;

						case 7:        //Properties
							{
								this.treeData.nodes[nodeIDList[0]-1].showProperties();
							}
							break;
						// case 1: 	    //View Read Only		
						// case 2:      //Create Branch
						// case 5:      //Create Concept Point
						// case 6: 	    //Open Edit
						// case 101:  	//Add Comment to C++
						// case 102:    //Refresh Map from javascript
						// case 103:    //New TITLE for node
						// case 104:    //New Description
						// case 105:    //Edit comment

						default:
						    //Fixing CATVidCtlWebViewer::AddCustomScheme deprecation
							if (dscef !==undefined)
		                    {
							    if (typeof dscef.sendString === 'function') dscef.sendString(JSON.stringify(JSONObject));
		                    }
						
					}
				}
			},

			setupTreeDataForTreeView:function (treeData)
			{
				var that=this;
				
				//Set up the RMBMenuItems for the tree
				if (treeData.rmbmenuitems)
		 		{
			 		for (i=0; i<treeData.rmbmenuitems.length;i++)
			 		{
			 			//Set up the full icon paths
			 			if (!treeData.rmbmenuitems[i].externalcommand || treeData.rmbmenuitems[i].externalcommand=="no")
			 			{	
			 				if(treeData.rmbmenuitems[i].icon)
			 					treeData.rmbmenuitems[i].icon='./assets/icons/' + treeData.rmbmenuitems[i].icon;
			 			}

			 			//Setting the RMB menu item functiond to be executed
			 			treeData.rmbmenuitems[i].fn=function(nodeID) {
		 					var options={};
		 					
		 					//externalID
		 					if(this.externalcommand=='yes' && this.uniqueid)
		 						options.uniqueid=this.uniqueid;

	 						if(this.maxnodes && that.nodeSelectionList.length>this.maxnodes)
	 						{
	 							that.displayAlert((widget.localize ? 
	 								widget.localize.tooManyNodes : "Too many nodes selected. The maximum number of nodes for this operation is: ") + this.maxnodes);
	 						}
	 						else if(!that.nodeSelectionList.length)
	 						{
	 							that.invokeCommand([Number(nodeID)],this.id,options);
	 						}
	 						else
		 					{
		 						that.invokeCommand(that.nodeSelectionList,this.id,options);
		 					}
		 				}
			 		}
			 	}

			 	/*****************for Debug Only***************/

			 	if (this.CURRENT_WIDGET_STATE==this.WIDGET_STATES.DEBUG)
				{
					var setPersonImage=function(person)
				 	{
			 			if(person.login!='default')
				            person.image=that.iconPath + person.image;
				        else
				            person.image=that.iconPath + 'SWXDefaultPersonImage.png';
				 	}

				 	setPersonImage(this.currentPerson);

				 	//Set up the proper image for the person
				 	treeData.people.forEach(function(person)
				 	{
						setPersonImage(person);
				 	});
			 	}
			 	/*****************end for Debug Only***************/


			 	//Attach the person to the comments
			 	if (treeData.comments && treeData.people){

			 		treeData.comments.forEach(function(comment){
			 			
			 			treeData.people.forEach(function(person){
			 				if (comment.who==person.id)
			 					comment.person=person;
			 			});
			 		});
				 }

		 		for (var i=0; i<treeData.nodes.length; i++)
		 		{
		 			var node=treeData.nodes[i];

		 		    //setting an image for a deleted node
		 			if (node.status === "deleted") {
		 			    node.imageurl = './assets/icons/SWXUiPDMGenericCube.png';
		 			}
		 			//setting the complete image path on the node
		 			else if (treeData.settings && treeData.settings.path)
	 				{
		 				node.imageurl = treeData.settings.path + 
		 				'/' + node.imageurl + '?md=' + new Date().getTime();
		 				// This ensures image refresh always;
		 			}

		 			//Add context menu items to the node data
			 		if(treeData.rmbmenuitems && node.rmbmenu && treeData.rmbmenu)
			 		{
			 			//Get the correct RMB Menu array of items
			 			var nodeMenu;
			 			treeData.rmbmenu.every(function(obj){
			 				if (obj.id==node.rmbmenu)
			 				{
			 					nodeMenu=obj;
				 				return false;
			 				}
			 				return true;
			 			});
			 		
			 			node.rmbmenuitems=[];

			 			nodeMenu.rmbitems.forEach(function(nodMenu){

			 				treeData.rmbmenuitems.forEach(function(treeMenu){
			 				 	
			 				 	if(nodMenu.item==treeMenu.id)
			 				 	{

			 				 		node.rmbmenuitems.push(treeMenu);

			 				 	}
			 				});
			 			});
			 			
			 		}

			 		//Add comments to individual nodes
			 		node.comments=[];
			 		if (treeData.comments)
			 		{
			 			treeData.comments.forEach(function(comment){
			 				
			 				comment.editComment=function(newComment){
			 					that.invokeCommand([0],105,{
			 						COMMENTID:this.id,
			 						COMMENTTEXT:newComment

			 					});
			 				}
			 				
			 				if (comment.node==node.id)
			 				{
			 					node.comments.push(comment);
			 				}
			 			});
			 		}

			 		//Add additional functionalty on node
			 		//On Select
			 		node.onSelect = function (nodeSelectionList) {
			 		    if (this.status === "deleted") {
			 		        (!!that.CEPropertiesPanel) && that.CEPropertiesPanel.hidePanel();
			 		    }
			 		    else {
			 		        that.setPropertiesPanelData(this);
			 		        that.nodeSelectionList = nodeSelectionList;
			 		    }
			 		}

			 		//On Comment Button Click
			 		node.saveComment=function(comment_text){
			 			that.invokeCommand([Number(this.id)],101,{
			 				COMMENT:comment_text
			 			});
			 		}

			 		// A separate function to show comments
			 		node.showComments=function(){
			 			that.showPropertiesPanel(this,"comments");
			 		}

			 		// A separate function to show comments
			 		node.showProperties=function(){
			 			that.showPropertiesPanel(this,"properties");
			 		}

			 		node.setNewTitle=function(title){
			 			that.invokeCommand([Number(this.id)],103,{
			 				TITLE:title
			 			});
			 		}

			 		node.setNewDescription=function(description){
			 			that.invokeCommand([Number(this.id)],104,{
			 				DESCRIPTION:description
			 			});
			 		}

	 			}
			},
			
			setPropertiesPanelData:function(nodeData)
			{
				if (this.CEPropertiesPanel && this.CEPropertiesPanel.isVisible())
				{
					this.CEPropertiesPanel.setPropertiesAndComments(nodeData);
				}
			},

			showPropertiesPanel:function(nodeData,contentWhich)
			{
				var that=this;
				if(!this.CEPropertiesPanel)
				{
					this.CEPropertiesPanel=new ENOLifecycleConceptExplorerPropertiesPanel(
					{
						propertiesPanelDiv:that.widget.body.getElement('.properties-panel'),
						readOnly:that.treeData.settings.readonly==="true",
						iconPath:that.iconPath,
						funcReframeAll:function(){
							var mainController=that;
							return function(){
								mainController.reframeAll();
							}
						}()
					});
				}
				this.CEPropertiesPanel.currentPerson=this.currentPerson;
				this.CEPropertiesPanel.readOnly=(this.treeData.settings.readonly==="true");
				this.CEPropertiesPanel.show(contentWhich);
				this.setPropertiesPanelData(nodeData);	
			},

			clearNodeSelections:function()
			{
				var nodeEl=this.widget.body.getElements(".eno-lifecycle-node");
				if(nodeEl && nodeEl.length)
				{
					for(var i=0;i<nodeEl.length;i++)
					{
						nodeEl[i].removeClassName("selected");
					}
				}

				this.nodeSelectionList=[];
			},
			
			setCurrentUser:function(data)
			{
				if(data)
				{
					this.currentPerson=JSON.parse(data);
				}
			},

			isCreateConceptConceptPointButonViewVisible:function()
			{
				return this.widget.body.getElement(".create-concept-point-button-div").getStyle('display')=='block';
			},

			displayBlankAlert:function(show, message)
			{
			    if (show)
			    {
			        this.widget.body.getElement(".blank-div").show();
			        this.widget.body.getElement(".blank-div .text-div").setText(message);
			    }
			    else
			        this.widget.body.getElement(".blank-div").hide();
			},

			displayTreeView:function(show)
			{
				if(show)
				{
					this.widget.body.getElement(".viewport-container").show();
					this.widget.body.getElement(".headerContent").show();
				}
				else
				{
					this.widget.body.getElement(".viewport-container").hide();
					this.widget.body.getElement(".headerContent").hide();
				}
			},


			reframeAll:function()
			{
				this.CETree.reframeAll();
			}

		});

		return controller;
	}
);


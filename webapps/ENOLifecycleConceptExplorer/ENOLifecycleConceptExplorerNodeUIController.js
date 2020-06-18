define('DS/ENOLifecycleConceptExplorer/ENOLifecycleConceptExplorerNodeUIController',
	[
		'UWA/Core',
		'UWA/Controls/Abstract',
		'DS/ENOLifecycleConceptExplorer/ENOLifecycleConceptExplorerNodeContextMenu'
	],
	function(UWA, Abstract, NodeContextMenu){

		'use strict';
		
		var nodeController=Abstract.extend({

			widget:null,
            multiSelectNodes:false,
			init: function (options) {

			    /*
                options
                {
                    widget:parent widget
                    multiSelectNodes: Select one node at a time only 
                                    or allow multi node selection with control or shift key
                }
                */

				if(options)
				{
					this._parent(options);
				}
				this.widget = options.widget;
				this.multiSelectNodes = options.multiSelectNodes;

			},

			/*Sets the context menu for the nodes*/
			setAllNodesEventHandlers:function(){

				this.node_list = this.widget.body.querySelectorAll(".eno-lifecycle-node");
				
				for (var i=0; i< this.node_list.length; i++)
				{
					if (this.node_list[i].nodeData)
					{
						this.setNodeContextMenu(this.node_list[i]);
						this.setNodeSelectionHandler(this.node_list[i]);
						UWA.extendElement(this.node_list[i]).addEvents({
							dblclick:function(evt){
								//Reset Node selection to current node only
								UWA.Event.dispatchEvent(this, 'mousedown');
								//invoke function 0 of the rmb menu item list (view or open)
								if (this.nodeData.rmbmenuitems && this.nodeData.rmbmenuitems.length && this.nodeData.status === 'none') {
								    this.nodeData.rmbmenuitems[0].fn(this.nodeData.id);
								}
							}
						})

					}
				}
			},

			setNodeSelectionHandler:function(elt)
			{
				var that=this;
				
				//Adding the selected functionality
				elt.addEventListener('mousedown',function(evt){
					
				    var nodeSelectionList = [];
				    if (that.multiSelectNodes) {

				        for (var i = 0; i < that.node_list.length; i++) {
				            if (!(evt.shiftKey || evt.ctrlKey)) {
				                UWA.extendElement(that.node_list[i]).removeClassName("selected");
				            }
				            else {

				                if (UWA.extendElement(that.node_list[i]).hasClassName("selected"))
				                    nodeSelectionList.push(Number(node_list[i].nodeData.id));
				            }
				        }

				        //If the User Clicks on the same node remove it from the list
				        if (UWA.extendElement(this).hasClassName("selected")) {
				            UWA.extendElement(this).removeClassName("selected");
				            nodeSelectionList.splice(nodeSelectionList.indexOf(Number(this.nodeData.id), 1));
				        }
				            //User clicks on a different node
				        else {
				            UWA.extendElement(this).addClassName("selected");
				            nodeSelectionList.push(Number(this.nodeData.id));
				        }
				    }
				    else {

				        for (var i = 0; i < that.node_list.length; i++) {
				           
				            UWA.extendElement(that.node_list[i]).removeClassName("selected");		           
				        }

				        UWA.extendElement(this).addClassName("selected");
				        nodeSelectionList.push(Number(this.nodeData.id));
				    }

				if(typeof this.nodeData.onSelect=='function')
						this.nodeData.onSelect(nodeSelectionList);

				});
			},
			
			setNodeContextMenu:function(elt){

				var that=this;

				//Adding the node button click
				var propButton = elt.querySelector(".node-button");

			    //function to show context menu.
                //function should be bound to element when adding event handler 
				var showContextMenu = function (evt) {

				    var ctxMenu = NodeContextMenu(elt.nodeData);
				    ctxMenu.hideAllMenus();
				    ctxMenu.show();

				    var viewport = that.widget.body.getElement(".viewport");
				    var vW = viewport.clientWidth;
				    var vH = viewport.clientHeight;
				    var x = evt.clientX;
				    var y = evt.clientY;
				    var w = ctxMenu.elements.container.clientWidth;
				    var h = ctxMenu.elements.container.clientHeight;

				    if (evt.clientX + w > vW) {
				        x = ((evt.clientX - w) > 0 ? (evt.clientX - w) : 5);
				    }

				    if (evt.clientY + h > vH) {
				        y = ((evt.clientY - h) ? (evt.clientY - h) : 5);
				    }

				    ctxMenu.options.altPosition = { x: x, y: y };
				    ctxMenu.updatePosition();
				    evt.preventDefault();
				    evt.stopPropagation();
				}
				
				if(propButton)
				{
				    propButton.addEventListener('mousedown', showContextMenu, false);

				}

				elt.addEventListener('contextmenu', showContextMenu, false);

				//Adding the button click on comment icon
				var commentIcon=elt.querySelector(".comment-icon");

				if(commentIcon)
				{
					commentIcon.addEventListener('mousedown',function(elt){

						var el=elt;
						return function(evt){
							if(!UWA.extendElement(el).hasClassName("selected"))
							{
								UWA.Event.dispatchEvent(el, 'mousedown');
							}
							elt.nodeData.showComments();
							evt.stopPropagation();
						}

					}(elt),false)

				}
							
			}
		});

		return nodeController;
	});

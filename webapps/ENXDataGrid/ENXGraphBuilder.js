define('DS/ENXDataGrid/ENXGraphBuilder',
		[
			'DS/etree/syncwidget',
			'DS/ENXDataGrid/eGraphCustomNodeView',
			'DS/etree/iact',
			'DS/ENXDataGrid/URLUtils',
			 /* the CSS resources for the SyncEGraphTree */
			 'css!DS/egraph/views.css',
			 'css!DS/etree/syncviews.css',
			 /* the CSS resource for the EGraphOverviewUI */
			 'css!DS/etree/overviewui.css',
			 'css!DS/Menu/assets/css/Menu.css',
			 'css!DS/ENXDataGrid/ENXDataGrid.css',
			 'text!DS/ENXDataGrid/assets/eGraphToolbar.json',
			 'i18n!DS/ENXDataGrid/assets/nls/graphToolbar'
		],
		function(		
				graphWidget,
				eGraphCustomNodeView,
				iact,
				URLUtils,
				eGraphViewCSS,
				syncViewsCSS,
				overviewViewsCSS,
				MenuCSS,
				DataGridCSS,
				eGraphToolbarJSON,
				nlsGraphToolbarJSON){
	
	var ENXGraphBuilder = {
			
			createGraphView: function(displayModesColumnsArray, nodes){
				/*
				 * Identify the container to insert the graph view and hide the other views(thumbnail and table)
				 */
				var divEGraph = document.getElementById("divEGraph");
				if(typeof divEGraph == "undefined" || divEGraph == null){
					divEGraph = document.createElement('div');
					divEGraph.className = 'column columnCenter';
					divEGraph.id = 'divEGraph'
				}
				
				var immersiveFrameContainer = document.body.getElementsByClassName("wux-controls-abstract wux-windows-immersive-frame wux-ui-is-rendered");
				var tableContainer;
				if(immersiveFrameContainer.length > 1){
					//tableContainer = immersiveFrameContainer[immersiveFrameContainer.length-1];
					tableContainer = immersiveFrameContainer[1];
				}else{
					tableContainer = document.body.getElementsByClassName("wux-layouts-collectionview")[0];
					if(tableContainer != undefined && tableContainer.parentElement != undefined && tableContainer.parentElement.id == 'divThumbnail')
						tableContainer = undefined;
				}
				
//				var divTable = document.body.getElementsByClassName("wux-layouts-collectionview")[0];
				var divThumbnail = document.getElementById("divThumbnail");
				
				if(divEGraph.style.display != "block"){
					var eGraphContainer = document.body.getElementsByClassName("etree-sync-container")[0]
					if(eGraphContainer != undefined){
						eGraphContainer.parentElement.style.display = "block";
						if(typeof divThumbnail != "undefined" && divThumbnail != null)
		  					divThumbnail.style.display = "none";
						if(typeof tableContainer != "undefined" && tableContainer != null)
							tableContainer.style.display = "none";
					}
					else{
						
						if(typeof tableContainer == "undefined"){
							tableContainer = document.body.getElementsByClassName("wux-windows-window-content wux-element-contentbox")[0]; 
							tableContainer.appendChild(divEGraph);
						} else if(typeof tableContainer != "undefined"){
							tableContainer.parentElement.appendChild(divEGraph);
							tableContainer.style.display = "none";
						} 
						
						//instantiate the graph
						if(graph == null || typeof graph == "undefined"){
							graph = new graphWidget.SyncEGraphTree(divEGraph, 
														{	orientation: graphWidget.OrientationMode.ROOT_ON_TOP,
															nodeView : eGraphCustomNodeView
														});
							graph.createOverview();
						}
						
					    var sharedModel = dataGridModel;
					    
					    // ajax call to retrieve the image column that needs to be set on the thumbnail to support images
					    
					    if (graph.getModel() !== sharedModel) {
			  				divEGraph.style.display = "block";

			  				if(typeof divThumbnail != "undefined" && divThumbnail != null)
			  					divThumbnail.style.display = "none";
			  				graph.setSize(); 
			  				
			  				//get the egraph instance from the widget to set the limits of the zoom
			  				var widgetEGraph = graph.widget.document.gr; 
			  				var zoomOpts = {
			  				        min: 0.1,
			  				        max: 8
			  				};

			  				widgetEGraph.setZoomOpts(zoomOpts);
			  				
			  				/*
			  				 * override the default behavior of click when click is performed on a label with href
			  				 */
			  				var stateMac = graph.widget.sm;
			  				stateMac.rootState.onmousedown=function(sm, data) {
			  				//identify if the target is the link element
		  						if(data.dom.className == "caption-title-link" || data.dom.className == "caption-title" ||
					  			   data.dom.className == "caption-colInfo2-link" || data.dom.className == "caption-colInfo2" ||
					  			   data.dom.className == "caption-colInfo3-link" || data.dom.className == "caption-colInfo3" ){
			  						var className = (data.dom.className.contains("link")) ? data.dom.className : data.dom.className + "-link";
				  					var labelContainer = data.grElt.views.main.elts.node.getElementsByClassName(className)[0];
				  					var labelHref = labelContainer.getAttribute("href");
				  					if(labelHref != "" && labelHref != undefined && labelHref != null)
				  						location.href = labelHref;
				  					else
				  						return iact.RootState.prototype.onmousedown.apply(this, arguments);
						  					
					  			}
		  						else if(URLUtils.getParameter("selection") == "none"){
			  						return;
			  					}
			  					else
						  			return iact.RootState.prototype.onmousedown.apply(this, arguments);
			  					
			  				};

			  				
			  				nodes.forEach(function(treeNode){
					        	  var imageValue = treeNode.options.grid.Image_export;
					        	  if(imageValue != undefined && imageValue != "")
					        	  {
					        		  var regex = /<img.*?src="(.+?)"/;
					        		  treeNode.options.thumbnail = regex.exec(imageValue)[1];
					        	  }
					        	  
					          	  if(treeNode.options.thumbnail == undefined)
					          		  treeNode.options.thumbnail = "../../common/images/icon64x64ImageNotFound.png";
					          });
					          
					          ENXGraphBuilder.setGraphNodes(nodes,displayModesColumnsArray);
				              
					          //set the shared model
				  				graph.setModel(sharedModel);
				  				if (sharedModel.savedViewport) {
				                  graph.setViewport(sharedModel.savedViewport);
				  				}
					          } else {
					              divEGraph.style.display = "block";
					  			if(typeof tableContainer != "undefined" && tableContainer != null)
					  				tableContainer.style.display = "none";
					  			if(typeof divThumbnail != "undefined" && divThumbnail != null)
					  				divThumbnail.style.display = "none";
					          }
						    
					    
					    		/*
					    		 * set the toolbar for the overview map to handle rotate, show/hide images and show/hide minimap
					    		 */
							   var eGraphToolbarDivContainer = document.createElement('div');
							   eGraphToolbarDivContainer.setAttribute('id','eGraphToolbarDivContainer');
							   var overviewDivContainer =	document.body.getElementsByClassName("etree-sync-overview-panel")[0];
							   overviewDivContainer.parentElement.insertBefore(eGraphToolbarDivContainer,overviewDivContainer);
								
							   
							   //TODO:
							   //setToolbar only supports stringified json. Due to which we cannot get the graphInstance on the toolbar arguments
							   // after techno provides the capability to setToolbar with a json object, modify the below code
							   //modify the JSON to add a property pointing to the egraph instance
							   
							   /*var parsedJSON = JSON.parse(eGraphToolbarJSON);
						       var entries = parsedJSON.entries;
						       var graphInstance = graph;
						       entries.forEach(function(entry){
						    	  entry.dataElements.action.argument["graph"] = graphInstance;
						       });
						      
						       var eGraphToolbar = dgView.setToolbar(JSON.stringify(parsedJSON));*/
						       
							   dgView._eGraphInstance = graph;
							   
							   // update the Toolbar JSON with internationalized IDs so that the labels on the graph toolbar are translated
							   var parsedJSON = JSON.parse(eGraphToolbarJSON);
							   var entries = parsedJSON.entries;
							   entries.forEach(function(entry){
								   entry.dataElements.tooltip = nlsGraphToolbarJSON[entry.id];
							   })
						       var eGraphToolbar = dgView.setToolbar(JSON.stringify(parsedJSON));
						       eGraphToolbar.inject(eGraphToolbarDivContainer);
						        
				      
    
					}
				
				}
				//return graph;
			},
			
			//update the graph node with the column values to be displayed based on the Display View setting
			setGraphNodes: function(nodes,tempColumnsArray){
				
  				nodes.forEach(function(treeNode){
  					
  				  if(tempColumnsArray.length == 0){
  	        		treeNode.options.label = treeNode.options.grid.type;
  				  }
  	        	  else {
	    		  	dgView.layout.getLeafColumns().forEach(function(column) {
	    		  		if(tempColumnsArray[0] != undefined && treeNode.options.grid[tempColumnsArray[0].id] != undefined && tempColumnsArray[0].id == column.id){
	      	        		treeNode.options["egraph_colInfo1"] = treeNode.options.grid[tempColumnsArray[0].id].toString();
	    		  			var href = column.href;
	    		  			var oidProperty = column.alternateOIDKey || "id";
	    		  			if(href) {
	        		  			var oid = treeNode.options.grid[oidProperty];
	        		  			var separator = href.indexOf("?")==-1?"?":"&";
	        		  			var url = "../" + href + separator + "objectId=" + oid;
	        		  			treeNode.options.egraph_colInfo1 = treeNode.options.grid[tempColumnsArray[0].id].toString() + ":" + url;
	        		  			//treeNode.options.label =  '<a id="custom_image_label" target="content" href="'+ url + '">'+content+'</a>';
	        		  		}
	    		  		}
	    		  		else if(tempColumnsArray[1] != undefined && treeNode.options.grid[tempColumnsArray[1].id] != undefined && tempColumnsArray[1].id == column.id){
	    		  			treeNode.options["egraph_colInfo2"] = treeNode.options.grid[tempColumnsArray[1].id].toString();
	    		  				var href = column.href;
	        		  			var oidProperty = column.alternateOIDKey || "id";
	        		  			if(href) {
		        		  			var oid = treeNode.options.grid[oidProperty];
		        		  			var separator = href.indexOf("?")==-1?"?":"&";
		        		  			var url = "../" + href + separator + "objectId=" + oid;
		        		  			treeNode.options.egraph_colInfo2 = treeNode.options.grid[tempColumnsArray[1].id].toString() + ":" + url;
		        		  			//treeNode.options.label =  '<a id="custom_image_label" target="content" href="'+ url + '">'+content+'</a>';
		        		  		}
	    		  		}
	    		  		
	    		  		else if(tempColumnsArray[2] != undefined && treeNode.options.grid[tempColumnsArray[2].id] != undefined && tempColumnsArray[2].id == column.id){
	    		  			treeNode.options["egraph_colInfo3"] = treeNode.options.grid[tempColumnsArray[2].id].toString();
	        		  			var href = column.href;
	        		  			var oidProperty = column.alternateOIDKey || "id";
	        		  			if(href) {
		        		  			var oid = treeNode.options.grid[oidProperty];
		        		  			var separator = href.indexOf("?")==-1?"?":"&";
		        		  			var url = "../" + href + separator + "objectId=" + oid;
		        		  			treeNode.options.egraph_colInfo3 = treeNode.options.grid[tempColumnsArray[2].id].toString() + ":" + url;
		        		  		}
	    		  		}
	    		  	});
  	        	  }

  				  if(treeNode.options.thumbnail == undefined)
  	          		  treeNode.options.thumbnail = "../ENXDataGrid/assets/icon120x80ImageNotFound.png";
  				
  				});
  				
  			
			}
	};
	
	return ENXGraphBuilder;
});

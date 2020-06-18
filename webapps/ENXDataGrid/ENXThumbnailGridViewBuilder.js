define('DS/ENXDataGrid/ENXThumbnailGridViewBuilder',
		[
			//'DS/Tree/ThumbnailGridView',
			'DS/CollectionView/ResponsiveThumbnailsCollectionView',
			'DS/CollectionView/CollectionViewStatusBar',
			'DS/ENXDataGrid/URLUtils',
			'UWA/Core',
			'UWA/Class/Promise',
		],
		function(
				//ThumbnailGridView,
				ResponsiveThumbnailsCollectionView,
				CollectionViewStatusBar,
				URLUtils,
				UWA,
				Promise){
	
	var ENXThumbnailGridViewBuilder = {
			
			createThumbnailGridView: function(displayModesColumnsArray, nodes){
				
				var divThumbnail = document.getElementById("divThumbnail");
				if(typeof divThumbnail == "undefined" || divThumbnail == null){
					divThumbnail = document.createElement('div');
					divThumbnail.className = 'column columnCenter';
					divThumbnail.id = 'divThumbnail';
				}
				
				var immersiveFrameContainer = document.body.getElementsByClassName("wux-controls-abstract wux-windows-immersive-frame wux-ui-is-rendered");
				var tableContainer;
				if(immersiveFrameContainer.length > 1){
					tableContainer = immersiveFrameContainer[1];
				}else{
					tableContainer = document.body.getElementsByClassName("wux-layouts-collectionview")[0];
					if(tableContainer != undefined && tableContainer.parentElement != undefined && tableContainer.parentElement.id == 'divThumbnail')
						tableContainer = undefined;
				}

				var divEGraph = document.getElementById("divEGraph");
				
				if(typeof tableContainer == "undefined") {
					tableContainer = document.body.getElementsByClassName("wux-windows-window-content wux-element-contentbox")[0]; 
					tableContainer.appendChild(divThumbnail);
				} else{
					tableContainer.parentElement.appendChild(divThumbnail);
					tableContainer.style.display = "none";
				}	
				var sharedModel = dataGridModel;
				
				var thumnailGrid = new ResponsiveThumbnailsCollectionView({ pageScrollValueTriggeringInfiniteScroll: 0.5 });
				/*this.thumnailGrid = new ThumbnailGridView({
			        // -- flatten the TreeDocument structure
			        model: null,

			        selection: {
			            canMultiSelect : true,
			            enableListSelection: true
			        },

			        enableActiveUI: true,
			        enableKeyboardNavigation: true,
			        height: 'auto'
			        });
				
				this.thumnailGrid.loadGridViewModel(sharedModel);
				*/
				thumnailGrid.model = sharedModel;
				
	            if (thumnailGrid.elements && thumnailGrid.elements.container){
	          	
	          	divThumbnail.style.display = "block";
	          		
	          	if(typeof divEGraph != "undefined" && divEGraph != null){
	          		divEGraph.style.display = "none";
	          	}
	          		
	          }
	          
	          var tempColumnsArray = displayModesColumnsArray;
	         
	         // new UWA.Promise(function(resolve, reject){
	            	
	         
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
	         

	              ENXThumbnailGridViewBuilder.setThumbnailDetails(thumnailGrid, nodes,tempColumnsArray);
	              
	              thumnailGrid.displayedOptionalCellProperties = ['contextualMenu'];
	            	
	              if(URLUtils.getParameter("selection") == "none"){
	            	  thumnailGrid.supportsSelection = function () {
	                      return false;
	                  }
	              }
	             /* thumnailGrid.onPostCellRequest(function(cellInfos){
						cellInfos.cellView.contentView.setPictureBackgroundSize('auto'); 
	              });*/
	              
	              thumnailGrid.buildStatusBar([
				  {
	                type: CollectionViewStatusBar.STATUS.NB_ITEMS
				  }
				  , {
	                type: CollectionViewStatusBar.STATUS.NB_SELECTED_ROWS
	              }
				  ]);
	          
	              thumnailGrid.inject(divThumbnail);
	        

			},
			
			setThumbnailDetails: function(thumbnailGrid, nodes,tempColumnsArray){
				nodes.forEach(function(treeNode){
		        	  if(tempColumnsArray.length == 0)
		        		  treeNode.options.label = treeNode.options.grid.type;
		        	  else{
		        		  
		        		  if(tempColumnsArray[0] != undefined && treeNode.options.grid[tempColumnsArray[0].id] != undefined){
			        		  thumbnailGrid.getLabel = function(treeNodeModel){
			        			  
			        			  var label =  treeNodeModel.options.grid[tempColumnsArray[0].id].toString();
				        		  
				        		  var url;
				        		  var content = treeNodeModel.options.grid[tempColumnsArray[0].id];
				        		  
		//		        		  TODO:
		//		        		  currently in SB, if subLabel/description has href then the column detail is not visible on the node of thumbnail
		//		        		  href/links on subLabel and description should be supported in future
				        		  
		//		        		  for(var index = 0; index < tempColumnsArray.length ; index++){
				        		  	dgView.layout.getLeafColumns().forEach(function(column) {
				        		  		if(tempColumnsArray[0].id == column.id){
				        		  			var href = column.href;
				        		  			var oidProperty = column.alternateOIDKey || "id";
				        		  			if(href) {
					        		  			var oid = treeNodeModel.options.grid[oidProperty];
					        		  			var separator = href.indexOf("?")==-1?"?":"&";
					        		  			url = "../" + href + separator + "objectId=" + oid;
					        		  			label =  '<a id="custom_thumbnail_label" target="content" href="'+ url + '">'+content+'</a>';
					        		  		}
				        		  		}
				        		  	});
		//		        		  }
				        		  return label;
			        		  }
		        		  }
		        	  
		        	  if(tempColumnsArray[1] != undefined && treeNode.options.grid[tempColumnsArray[1].id] != undefined){
		        		  var columnInfo1 = treeNode.options.grid[tempColumnsArray[1].id].toString();
		        		  treeNode.options.subLabel = '<span>' + columnInfo1 + '</span>'
		        	  }
		        		  
		        	  if(tempColumnsArray[2] != undefined && treeNode.options.grid[tempColumnsArray[2].id] != undefined){
		        		  var columnInfo2 = treeNode.options.grid[tempColumnsArray[2].id].toString();
		        		  treeNode.options.subLabel = treeNode.options.subLabel + ' | ' + '<span>' + columnInfo2 + '</span>'
		        	  }
		        	  if(treeNode.options.thumbnail == undefined)
		          		  treeNode.options.thumbnail = "../../common/images/icon64x64ImageNotFound.png";
		        	  }
		        		  //treeNode.options.description = treeNode.options.grid[tempColumnsArray[2].id].toString();
		        	  
		          	  
		          });
			}
	};
	
	return ENXThumbnailGridViewBuilder;
});

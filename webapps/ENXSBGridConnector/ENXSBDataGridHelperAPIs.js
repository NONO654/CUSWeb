//define('DS/ENXSBGridConnector/ENXSBDataGridHelperAPIs',
//		[], function() {
//	'use strict';
//

	var helperApi = {
			
		addNodes: function(rows, parentId) {
			var payLoad = getRowIds();
			
			var options = {
					method: 'GET',
					onComplete: function(csrf){
						payLoad["csrf"] = JSON.parse(csrf).csrf;
						var url = '../../resources/v1/ui/gridview/columnValues?' + URLUtils.getQueryString();
						
						var saveEditedObjects = {
				    			method: 'PUT',
				    			data: JSON.stringify(payLoad),
				    			onComplete: function(result) {
				    				console.log(result);
				    			},
				    			onFailure: function(error, backendresponse, response_hdrs){
				    				StandardFunctions.showTransientMessage('', 'error');
								}

				    	};

				    	WAFData.authenticatedRequest(url, saveEditedObjects);
					}
			};
			WAFData.authenticatedRequest('../../resources/v1/application/E6WFoundation/CSRF', options);
		},
			
		getRowIds: function(rows){
			var payLoad = {};
			payLoad['data'] = [];
			
			if(typeof rows!= 'undefined' && rows != null) {
				rows.forEach(function(row) {
					payLoad.data.push({
						'id': row.id,
						'dataelements': {}
					});
				});
			}
			return payLoad;
		},
		
			
		isDataModified: function(){
			if(isDataModified){
				return true;
			}
			return false;
		},
		
		refreshTreeModel: function(){
			
		},
		
		removeRows: function(rowId){
			var treeNodeModel = dgView.model[rowId];
			dataGridModel.setUseChangeTransactionMode(false);
			treeNodeModel.getParent().removeChild(treeNodeModel);
		},
		
		getNodeById: function(objectId, relId) {
			var exp = "";
			if(typeof objectId != 'undefined' && objectId != null) {
				exp += '(ittObj._options.grid.id == \'' + objectId + '\')';
			}
			if(typeof relId != 'undefined' && relId != null) {
				exp += ' && (ittObj._options.grid.relId == \'' + relId + '\')';
			}
			if(exp.startsWith(' && ')) {
				exp = exp.substring(4);
			}
			
			return this._privateGetNodes(exp);
		},

		getNodeByRowId: function(rowId) {
			var retArray = [];
			
			if(typeof rowId != 'undefined' && rowId != null) {
				var exp = '(ittObj._options.grid.rowId == \'' + rowId + '\')';
				retArray = this._privateGetNodes(exp);
			}
			
			return retArray;
		},

		getNodes: function(level, type, parentId) {
			var exp = "";
			if(typeof level != 'undefined' && level != null) {
				exp += '(ittObj._options.grid.level == \'' + level + '\')';
			}
			if(typeof type != 'undefined' && type != null) {
				exp += ' && (ittObj._options.grid.Type == \'' + type + '\')';
			}
			if(typeof parentId != 'undefined' && parentId != null) {
				exp += ' && (ittObj._parentNode != null) && (typeof ittObj._parentNode._options.grid.id != \'undefined\') && (ittObj._parentNode._options.grid.id == \'' + parentId + '\')';
			}
			if(exp.startsWith(' && ')) {
				exp = exp.substring(4);
			}
			
			return this._privateGetNodes(exp);
		},

		_privateGetNodes: function(exp) {
			var retArray = [];
			
			var evalFunc = function(nodesArray) {
				nodesArray.forEach(function(ittObj) {
										if(eval(exp)) {
											retArray.push(ittObj); // UWA.clone(ittObj, true) - for now it is throwing maximum call stack at Object.clone, inside Core.js
										}
										
										if(typeof ittObj.getChildren() != 'undefined' && ittObj.getChildren().length > 0) {
											evalFunc(ittObj.getChildren());
										}
									});
			}
			
			if(typeof dataGridModel != 'undefined' && dataGridModel != null) {
				var rootNodes = dataGridModel.getChildren();
				evalFunc(rootNodes);
			}
			
			return retArray;
		},

		getSelectedNodes: function() {
			var retArray = [];
			
			var selectedNodes = dataGridModel.getSelectedNodes();
			if(typeof selectedNodes != 'undefined' && selectedNodes != null) {
				retArray = selectedNodes; // UWA.clone(selectedNodes, true)
			}
			
			return retArray;
		},
		
		getAttributeFromNode: function(treeNodeModel,attribute){
			var value = "";
			for(var arrayIndex = 0; arrayIndex < treeNodeModel.length; arrayIndex++){
				value = treeNodeModel[arrayIndex].options.grid[attribute];
			}
			return value;
		},
		
		selectNodeModel: function(rowId) {
			var treeNodeModel = dgView.model[rowId];
			dgView.selectNodeModel(treeNodeModel);
		},
		
		unselectNodeModel: function(rowId) {
			var treeNodeModel = dgView.model[rowId];
			dgView.unselectNodeModel(treeNodeModel);
		}
	};
	
	
//	return helperApi;
//});

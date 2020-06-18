(function(GLOBAL) {

    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;
    
    if (typeof GLOBAL.DS.RAComponents.raReliabilityTable !== 'undefined') {
        return;
    }

    var chartLibrary = GLOBAL.DS.RAObjects.chartParameterLibrary;

    var raReliabilityTablePrototype = {
        is: 'ra-reliabilitytable',
        behaviors: [GLOBAL.DS.RAComponents.ratablebase]
    };
    
    raReliabilityTablePrototype.renderOnDrop = true;

    raReliabilityTablePrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.ratablebase.createdCallback.call(this);
        
        var that = this;
        
    };

    raReliabilityTablePrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.ratablebase.renderControlPanel.call(
            this,
            panel
        );
    };

    raReliabilityTablePrototype.validateRender = function() {
        return true;
    };

    
    raReliabilityTablePrototype.getColumnList = function(){
    	// these columns are hard coded
    	return [{
    		id: 'tree',
    		displayName: NLSUtils.translate('Constraint')
    	},{
    		id: 'success',
    		displayName: NLSUtils.translate('Success')
    	},{
    		id: 'failure',
    		displayName: NLSUtils.translate('Failure')
    	}];
    };
    
    // since we're not getting the row list from parameters
    raReliabilityTablePrototype.getRowList = function(parameterData){
    	var parameterIds = Object.keys(parameterData),
    		rowList = [];
    	parameterIds.forEach(function(parameterId){
    		var parameter = parameterData[parameterId],
    			displayName = parameter.displayName;
    		if(parameter.id === 'SYSTEM'){
    			rowList.push({
    				id: parameterId,
    				pid: parameterId,
    				type: 'combined',
    				displayName: parameter.displayName, // need to get constraint value >_<
    			});
    			return;
    		}
    		if(parameter.upper){
    			rowList.push({
    				id: parameterId + '_upper',
    				pid: parameterId,
    				type: 'upper',
    				displayName: decodeURIComponent(parameter.displayName) + ' < ' + parameter.upperValue, // need to get constraint value >_<
    			});
    		}
    		if(parameter.lower) {
    			rowList.push({
    				id: parameterId + '_lower',
    				pid: parameterId,
    				type: 'lower',
    				displayName: decodeURIComponent(parameter.displayName) + ' > ' + parameter.lowerValue, // need to get constraint value >_<
    			})
    		}
    		if(typeof parameter.combined !== 'undefined'){
    			rowList.push({
    				id: parameterId + '_combined',
    				pid: parameterId,
    				type: 'combined',
    				displayName: parameter.lowerValue + ' < ' + decodeURIComponent(parameter.displayName) + ' < ' + parameter.upperValue, // need to get constraint values >_<
    			})
    		}
    	});
    	return rowList;
    };
    raReliabilityTablePrototype.getRowGrid = function(row,parameterData){
    	var _rowData = parameterData[row.pid],
    		grid = {}
    	if(_rowData){
    		if(row.type === 'upper'){
        		grid.success = 1 - (+_rowData.upper);
        		grid.failure = +_rowData.upper;
    		}else if(row.type === 'lower'){
        		grid.success = 1 - (+_rowData.lower);
        		grid.failure = +_rowData.lower;
    		}else if(row.type === 'combined'){
        		grid.success = 1 - (+_rowData.combined);
        		grid.failure = (+_rowData.combined);
    		}
    	}
    	return grid;
    };

    raReliabilityTablePrototype.updateRequest = function() {
        this.renderRequest();
	};
	
	raReliabilityTablePrototype.renderRequest = function(){
		if(this.requestObject){
			this.dataProvider.executeSupport('getReliabilityDataAsJson',this.requestObject,this.updateTableGrid.bind(this),this);
		}
	};
	
	raReliabilityTablePrototype.updateTableGrid = function(_response){
		var response = JSON.parse(_response);
		var _rows = this.getRowList(response);
		if(this.treeDocument && _rows instanceof Array){
			this.treeDocument.prepareUpdate();
			_rows.forEach(function(_row){
				var rowId = _row.id,
					rowIds = Object.keys(response),
					rowIndex = rowIds.indexOf(rowId);
				
				// we already know the rows are in the list >_<
//				if(rowIndex >= 0){
					var row = this.getRowGrid(_row,response);
					var modified = this.treeDocument.getChildren().some(function(child){
						if(child.options.id === rowId){
							child.options.grid = row;
							child.updateOptions(child.options);
							return true;
						}
					},this);
					if(!modified){
						this.addRow({
							id: rowId,
							label: _row.displayName,
							grid: row
						});
					}
//				}
			},this);
			
			
			
			var rows = this.treeDocument.getChildren();
			for(var i = rows.length - 1; i >= 0; i--){
				var existingRow = rows[i];
				var found = _rows.some(function(param){
					if(param.id === existingRow.options.id){
						return true;
					}
					return false;
				});
				
				// this row in the tree document was not found in the row list
				if(!found){
					existingRow.remove();
				}
			}
			// below is code to style the "SYSTEM" row, for some reason I can't just apply a class
			// to the row to style  it.  Instead I'm stuck either using node.select or node.matchSearch
			// functions, neither of which I'm thrilled by using - d9u
//			var matchedNodesList = this.treeDocument.search({
//		        match: function(nodeInfos) {
//		            if (nodeInfos.nodeModel.options.id === "SYSTEM") {
//		            	return true;
//		            }
//		        }
//		    });
//			matchedNodesList.forEach(function(node){
//				node.select(true);
//				// node.matchSearch();
//			});
			
			// compare the rowId list to the rows on the treedocument and remove any that are no longer present
			this.treeDocument.pushUpdate();
		}

	};
	
	
    
    Polymer(raReliabilityTablePrototype);
    GLOBAL.DS.RAComponents.raReliabilityTable = raReliabilityTablePrototype;
})(this);

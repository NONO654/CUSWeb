(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.raCorrelationTable !== 'undefined') {
        return;
    }
    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;

    var chartLibrary = GLOBAL.DS.RAObjects.chartParameterLibrary;

    var raCorrelationTablePrototype = {
        is: 'ra-correlationtable',
        behaviors: [GLOBAL.DS.RAComponents.ratablebase]
    };

    raCorrelationTablePrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.ratablebase.createdCallback.call(this);
        this.applyFilters = true;
        this.addXAxis();
        this.addYAxis();
    };

    raCorrelationTablePrototype.getXParameter = function(parameter, attributes) {
        var chartParam,        
        chartParam = chartLibrary.parameterTemplates.rawNumeric.create('X');
        
        return chartParam;
    };

    raCorrelationTablePrototype.validateYData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        // and not discrete
        if (data.properties.dataType === 'STRING') {
            console.log('y parameter cannot be discrete');
            return false;
        }
        return true;
    };

    raCorrelationTablePrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.ratablebase.renderControlPanel.call(
            this,
            panel
        );
        
        var chartSettingsControl = panel.getControl('ra-chartsettingscontrol');
        
        this.controls.chartSettings = chartSettingsControl.addCheckBox(
    		'applyFilters',
    		NLSUtils.translate('APPLY_FILTERS'),
    		this.applyFilters
		);
        
        this.controls.chartSettings.setTitleText({
        	long: NLSUtils.translate('APPLY_FILTERS_NO_EXCLUDED')
    	});

        this.controls.chartSettings.setUpdateCallback(function(newVal){
        	this.applyFilters = newVal;
        	this.renderChart();
        }.bind(this));
    };
    
    raCorrelationTablePrototype.validateRender = function() {
         if (this.parameters.y.length > 0) {
            return true;
        }        
        return false;
    };
    
    raCorrelationTablePrototype.getChartSettings = function(){
        return { 
        	applyFilters: this.applyFilters
    	};
    };
    
    raCorrelationTablePrototype.restoreChartSettings = function(chartSettings) {
        if(typeof chartSettings.applyFilters !== 'undefined'){
            this.applyFilters = chartSettings.applyFilters;
            if(typeof this.controls.chartSettings !== 'undefined'){
            	this.controls.chartSettings.setCheck(this.applyFilters);
            }
        }
    };

    raCorrelationTablePrototype.updateRequest = function() {
        var that = this;

        this.requestObject = this.requestObject || {};
        this.requestObject.columnIdList = [];
        this.requestObject.rowIdList = [];
        this.requestObject.applyFilters = this.applyFilters;
        
        
        if(this.parameters && this.parameters.x instanceof Array){
        	this.parameters.x.forEach(function(param){
        		this.requestObject.columnIdList.push(param.id);
        	},this);
        }
        if(this.parameters && this.parameters.y instanceof Array){
        	this.parameters.y.forEach(function(param){
        		this.requestObject.rowIdList.push(param.id);
        	},this);
        }
        this.renderRequest();
	};
	
	raCorrelationTablePrototype.updateTableGrid = function(_response){
		var response = JSON.parse(_response);
		if(this.treeDocument && this.parameters.y instanceof Array){
			this.treeDocument.prepareUpdate();
			this.parameters.y.forEach(function(_row){
				var rowId = _row.id,
					rowIds = Object.keys(response),
					rowIndex = rowIds.indexOf(rowId);
				
				if(rowIndex >= 0){
					var row = response[rowId];
					var modified = this.treeDocument.getChildren().some(function(child){
						if(child.options.id === rowId){
							// make sure the displayName is up to date (not part of the response)
							child.options.label = decodeURIComponent(_row.displayName);
							
							// update the grid
							child.options.grid = row;
							
							// make the update
							child.updateOptions(child.options);
							return true;
						}
					},this);
					if(!modified){
						this.addRow({
							id: rowId,
							label: decodeURIComponent(_row.displayName),
							grid: row
						});
					}
				}
			},this);
			
			var rows = this.treeDocument.getChildren();
			for(var i = rows.length - 1; i >= 0; i--){
				var existingRow = rows[i];
				var found = this.parameters.y.some(function(param){
					if(param.id === existingRow.options.id){
						return true;
					}
					return false;
				});
				if(!found){
					existingRow.remove();
				}
			}
			
			// compare the rowId list to the rows on the treedocument and remove any that are no longer present
			this.treeDocument.pushUpdate();
		}
	};
	
	raCorrelationTablePrototype.renderRequest = function(){
		if(this.requestObject){
			this.dataProvider.executeSupport('getCorrelationDataAsJson',this.requestObject,this.updateTableGrid.bind(this),this);
		}
	};

    
    Polymer(raCorrelationTablePrototype);
    GLOBAL.DS.RAComponents.raCorrelationTable = raCorrelationTablePrototype;
})(this);

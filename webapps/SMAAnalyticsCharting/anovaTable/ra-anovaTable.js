(function(GLOBAL){
	var anovaTablePrototype = {
		is : 'ra-anovatable',
        behaviors: [
            GLOBAL.DS.RAComponents.chart,
            GLOBAL.DS.RAComponents.droptarget
        ]
	};
	
	anovaTablePrototype.createdCallback = function(){
		GLOBAL.DS.RAComponents.chart.createdCallback.call(this);
		GLOBAL.DS.RAComponents.droptarget.createdCallback.call(this);
		
		var that = this;
		
		this.outputIds = [];
		
		///////////// Test Stuff. Delete this later?
        this.dimensions = { width: 500, height: 500 };
		/////////////////
		
		this.dataSetId = null;
		
		this.setFilter(function(data){
			//Data is an output parameter
            if (
                data.type !==
                GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
            ) {
                return false;
            }
			//TODO: Can we get role of dataset parameters?
            // if(data.properties.parameterRole !== 'output'){ return false;
            // }
            if (this.dataSetId && data.source !== this.dataSetId) {
                return false;
            }
			
			return true;
		});
		
		this.setDropListener(function(data){
			console.log('Drop output');
			
			if(!this.dataSetId){
                // If dataSetId is not set, then we have not attached a data set
                // object.  Note: dataSetId refers to the id of the data set the
                // parameters are from,  NOT the id of the DataSet object defined by
                // ra-dataset.
				this.dataSetId = data.source;
				
				for(var key in GLOBAL.DS.RAObjects.datasets){
                    if (
                        GLOBAL.DS.RAObjects.datasets[key].getMetadata().
                            parentId === this.dataSetId
                    ) {
						this.dataSet = GLOBAL.DS.RAObjects.datasets[key];
						break;
					}
				}
				
				if(typeof this.dataSet === 'undefined'){
					this.dataSet = new GLOBAL.DS.RAConstructors.DataSet({
                        metadata: { parentId: this.dataSetId },
                        data: { terms: { metadata: { displayName: 'Terms' } } }
					});
				}
			}
			
			that.addOutput(data.properties);
		});
	};
	
	anovaTablePrototype.addOutput = function(output){
		var that = this;
		
		if(this.outputIds.indexOf(output.id) === -1){
			this.outputIds.push(output.id);
			
			if(this.dataSet.hasColumn(output.id)){
				this.updateCharts();
			} else {
				//TODO: Figure out how to handle race condition.
				var metadata = {
                    id: output.id,
                    displayName:
                        output.alias || output.displayName || output.id,
                    status: 'NOT_READY'
				};
				
				this.dataSet.setColumn(output.id, {
					values : [],
					metadata : metadata
				});
				
				var requestObject = {
					datasetId : this.dataSetId,
					paramIDs : this.outputIds
				};
				
                this.dataProvider.executeSupport(
                    'getAnovaTable',
                    requestObject,
                    function(data) {
					console.log('Anova data: ');
					data = JSON.parse(data);
					console.log(data);
					that.dataSet.updateColumn('terms', data.terms);
					that.dataSet.updateColumn(output.id, data[output.id]);
					that.updateTable();
                    }
                );
			}
		}
	};
	
	anovaTablePrototype.updateTable = function(){
        // TODO: This needs to account for columns that are metadata.status ===
        // 'NOT_READY'
		
		//Render charts based on current dataset
		/*var callback = function(chartUrl){
			var chartImage = this.querySelectorAll('image');
			
			if(!chartImage){
				chartImage = document.createElement('image');
				this.appendChild(chartImage);
			}
			
			chartImage.setAttribute('href', chartUrl);
		}*/
		
		//this.dataProvider.executeSupport('renderAVSChart', {
		//	chartId : 'anova'
		//}, callback, [this.dataSet.getDataSetObject]);
		
		var that = this;
		
		var table = this.querySelector('table');
		if(!table){
			table = document.createElement('table');
			this.appendChild(table);
		}
		
        Array.prototype.forEach.call(table.querySelectorAll('thead'), function(
            header
        ) {
			table.removeChild(header);
		});
		
        Array.prototype.forEach.call(table.querySelectorAll('tbody'), function(
            body
        ) {
			table.removeChild(body);
		});
		
		var header = document.createElement('thead');
		table.appendChild(header);
		var headerRow = header.appendChild(document.createElement('tr'));
		var columns = this.dataSet.getColumns();
		this.outputIds.forEach(function(outputId){
			var headerCell = document.createElement('cell');
			headerCell.textContent = columns[outputId].metadata.displayName;
			headerRow.appendChild(headerCell);
		});
		
		var body = document.createElement('tbody');
		table.appendChild(body);
		var addRow = function(i){
			var newRow = document.createElement('tr');
			
			that.outputIds.forEach(function(outputId){
				var rowCell = document.createElement('cell');
				rowCell.textContent = columns[outputId].values[i];
				newRow.appendChild(rowCell);
			});
			
			body.appendChild(newRow);
        };
		for(var i = 0; i < columns.terms.values.length; i++){
			addRow(i);
		}
		
		/////////////Sample code for server interaction///////////
		var requestObject = {
            chartRequest: {
                width: this.dimensions.plotWidth,
                height: this.dimensions.plotHeight,
                data: {
                    raw: [
                        { guid: 'f86ce75e-efe1-4556-b51a-8c2a7fefa29e' },
                        { guid: 'dff2c691-2212-4212-8df4-9c30cbb695d0' }
                    ]
                       },
                charts: [
                    {
                        type: 'bar',
                        guid: 'XBinnedBar1',

                        // Binned X data with glyph color/size                       
                        x: {
                            data: {
                                type: 'binnedEqualWidth',
                                numBins: 10,
                                guid: 'f86ce75e-efe1-4556-b51a-8c2a7fefa29e'
                            }
                        },
                        heights: [
                            {
                                data: {
                                    type: 'aggregation',
                                    aggregationType: 'COUNT',
                                    guid: 'dff2c691-2212-4212-8df4-9c30cbb695d0'
                                }
                            }
                        ],
                        color: {
                            data: {
                                type: 'aggregation',
                                aggregationType: 'COUNT',
                                guid: 'f86ce75e-efe1-4556-b51a-8c2a7fefa29e'
                            }
                        }
                    } 
                ],
                datasets: [this.dataSet.getDataSetObject()]
            }
        };
		
		var callback = function(data){
            console.log(data);
        };

        this.dataProvider.executePostSupport(
            'renderAVSChart',
            requestObject,
            callback
        );
	};
	
	Polymer(anovaTablePrototype);
	GLOBAL.DS.RAComponents.anovatable = anovaTablePrototype;
})(this);

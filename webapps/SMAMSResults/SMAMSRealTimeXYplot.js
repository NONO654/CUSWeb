/*! Copyright 2015 Dassault Systemes 
 global define, document 
define('DS/SMAMSResults/SMAMSRealTimeXYplot',['UWA/Core', 'DS/UIKIT/Input/Button', 'DS/D3js_external/D3js'],
	function (UWA, Button, d3) {
	'use strict';
	
	var SMAMSResults = {
		
		RTPlot: function(plotName, variableName, expDuration){
			this.dataObject = {
					timeSeriesType : 'indices',
					data : {},
					indexedColumns : 0
				};
			
			// var div = widget.editor.getUIFrame().querySelector('.results-div:not(.results-div-hidden)');
			var div = widget.editor.getUIFrame().querySelector('.wux-windows-window-maincontent');
			var mainSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
			mainSvg.setAttribute('class', 'mainplot-svg');
			div.appendChild(mainSvg);
			
			this.svgs = {
					main : mainSvg
				};
			
			this.scales = {};
			this.axisGenerators = {};
			this.axes = {};
			
			//Fixed dimensions.
			//Later, we can compute these on the fly, but this is quick and easy.
			this.dimensions = {
				totalWidth : 500,
				main : {
					//totalWidth : widget.elements.content.querySelector('#mainPlotSvg').width.animVal.value -100,
					//totalHeight : widget.elements.content.querySelector('#mainPlotSvg').height.animVal.value,
					//totalWidth : widget.elements.content.querySelector('.results-div').clientWidth + 100,
					//totalHeight : widget.elements.content.querySelector('.results-div').clientHeight + 100,
					totalWidth : 300,
					totalHeight : 150,
					leftPad : 60,
					rightPad : 10,
					topPad : 10,
					bottomPad : 35
				},
				zoom : {
					//totalWidth : widget.elements.content.querySelector('#zoomPlotSvg').width.animVal.value -100,
					//totalHeight : widget.elements.content.querySelector('#zoomPlotSvg').height.animVal.value,
					//totalWidth : widget.elements.content.querySelector('.results-div').clientWidth -100,
					//totalHeight : 100,
					totalWidth : 300,
					totalHeight : 100,
					leftPad : 60,
					rightPad : 10,
					topPad : 10,
					bottomPad : 50,
				}
			};
			
			var md = this.dimensions.main;
			
			md.plotWidth = md.totalWidth - (md.leftPad + md.rightPad);
			md.plotHeight = md.totalHeight - (md.topPad + md.bottomPad);
					
			var zd = this.dimensions.zoom;
			
			zd.plotWidth = zd.totalWidth - (zd.leftPad + zd.rightPad);
			zd.plotHeight = zd.totalHeight - (zd.topPad + zd.bottomPad);
			
			if (!widget.RTdata){
				widget.RTdata = [];
				widget.RTdata.push('time,Y\r\n0,0\r\n');
			}
			else if (widget.RTdata) {
				widget.RTdata.push('time,Y\r\n0,0\r\n');
			}
			

			this.processData(plotName);
			
			this.setupMainPlot(variableName, expDuration);
			
			if (widget.overlayview){
				widget.overlayview.push(this);
			}
			else {
				widget.overlayview = [];
				widget.overlayview.push(this);
			}
		}
	};
	
	SMAMSResults.RTPlot.prototype = {
			processData: function(plotName){
				var that = this;
				var contents = widget.RTdata[widget.RTdata.length - 1];
				contents = contents.split('\n').map(function(d){
					return d.split(',');
				}).filter(function(d){
					return d.length > 0 && !isNaN(d[0]) && d[0] !== '';
				});
				
				var variableNames = widget.RTdata[widget.RTdata.length - 1];
				variableNames = ['time', plotName];
					variableNames.split('\n').map(function(d){
					return d.split(',');
				}).filter(function(d){
					return d.length > 0 && isNaN(d[0]) && d[0] !== ''
				});
				
				var dataName = 'droppedData';
				that.dataObject.data[dataName] = {
					dataName : variableNames,
					columns : contents[0].length,
					rawData : contents
				};
				
				var indexedColumns = 0;
				for(var key in that.dataObject.data){
					if(that.dataObject.data[key].columns === 1){
						indexedColumns += 1;
					}
				}
				
				that.dataObject.indexedColumns = indexedColumns;
				
				if(this.dataObject.timeSeriesType === 'indices' || Object.keys(this.dataObject.data).length === 1){
					for(var key in this.dataObject.data){
						if(this.dataObject.data[key].columns === 1){
							addIndexedTime(this.dataObject.data[key]);
						} else {
							this.dataObject.data[key].data = this.dataObject.data[key].rawData;
						}
					}

				} else {
					//Scale indices.
					var fixedColumn, scaledColumn;

					//Identify fixed and scaled column
					if(this.dataObject.indexedColumns === 1){
						for(var key in this.dataObject.data){
							if(this.dataObject.data[key].columns === 2){
								fixedColumn = this.dataObject.data[key];
								this.dataObject.data[key].data = this.dataObject.data[key].rawData;
							} else {
								scaledColumn = this.dataObject.data[key];
							}
						}
					} else if (this.dataObject.indexedColumns === 2){
						//We can use a reduce function here to get the longer and shorter data, if needed.
						var keys = Object.keys(this.dataObject.data);
						fixedColumn = addIndexedTime(this.dataObject.data[keys[0]]);
						scaledColumn = this.dataObject.data[keys[1]];
					} else if (this.dataObject.indexedColumns === 2){

					}

					var startTime = fixedColumn.data[0][0],
					endTime = fixedColumn.data[fixedColumn.data.length - 1][0];

					addScaledTime(scaledColumn, startTime, endTime);
				}
				
			},
			
			getScales: function(dimensions, expDuration){
				var xMin = Infinity,
				xMax = -Infinity,
				yMin = Infinity,
				yMax = -Infinity;
				
				var thisData;

				for(var key in this.dataObject.data){
					thisData = this.dataObject.data[key].data;
					for(var i = 0; i < thisData.length; i++){
						for (var j = 1; j < thisData[i].length; j++){
							xMin = Math.min(xMin, thisData[i][0]);
							xMax = Math.max(xMax, thisData[i][0]);
							yMin = Math.min(yMin, thisData[i][j]);
							yMax = Math.max(yMax, thisData[i][j]);
						}
					}
				}

				//Build scales
				var xScale = d3.scale.linear()
				//.domain([xMin, xMax])
				.domain([xMin, expDuration])
				.range([0, dimensions.plotWidth]);

				var yScale = d3.scale.linear()
				.domain([yMin, yMax])
				.range([dimensions.plotHeight, 0]);

				return {
					xScale : xScale,
					yScale : yScale
				};
			},
			
			plotLines: function(svg, dimensions, scales){
				//var time = 1;

				//var lines = [];
								
				var lineData = [];
				//var myArray = [];
				
				var rawData;
				for(var key in this.dataObject.data){
					rawData = this.dataObject.data[key].data;
				}
				
				widget.myData = rawData;
				//for(var i = 1; i < 10; i++){
				//	myArray.push(0);
				//}
				
				//for(var i = 1; i < 10; i++){
				//	myTimeArray.push(i);
				//}
				
				//lineData.push(myArray);		
				lineData.push(rawData.map(function(d){
					return [d[0],d[1]];
				}));
				
				// or create a function and indices array and call lineGenerator on the index
				
				//Build lines
				//var lineGenerator = d3.svg.line()
				//    .x(function(d, i){ return scales.xScale(time + i*10)})
				//    .y(function(d){ return scales.yScale(d)});
				
				var lineGenerator = d3.svg.line()
					.x(function(d){ return scales.xScale(d[0]); })
					.y(function(d){ return scales.yScale(d[1]); });
				
				//Select a line group if one has been created in the svg.
				var lineGroup = d3.select(svg).selectAll('.lineGroup');
				
				if(lineGroup[0].length === 0){
					//Build the line group if it isn't there.
					lineGroup = d3.select(svg).append('g')
						.attr('transform', 'translate(' + dimensions.leftPad + ',' + dimensions.topPad + ')')
						.classed('lineGroup', true);
				}
				
				//Create a path for each data point we have if they don't exist already.
				
				//var color = d3.scale.category10();
				
				var color = function(i){
					var colors = ['red', 'blue', 'green', 'yellow', 'orange', 'purple'];
					return colors[i];
				};
				
				var path = lineGroup.selectAll('path')
					.data(lineData) // indices
					.enter()
					.append('path')
					.attr('class', function(d, i){return 'plotLine plotLine' + i;})
					.each(function(d, i){
						d3.select(this).style({'stroke': color(i)});
						d3.select(this).attr({'id' : 'Line'+i});
					});
					
					//.attr('style', function(d, i){
					//	return {'stroke' : color(i)}
					//});
				
				//Draw the lines.
				//This is done separately so we can use the same function to update or draw the lines.
				lineGroup.selectAll('path')
					.attr('d', function(d){ return lineGenerator(d); });
				
				
				
				function realtime(){
					
					if (widget.Time !== null){

						var now = widget.Time;

						//time data should be in an array too
						//need to pass the data received from simulation results here

						//myArray.push(Math.random() * 100);
						//myTimeArray.push(myArray.length*10);
						//myData[1].push(Math.random() * 100);
						//myData[0].push(myArray.length*10);
						lineData = [];
						//lineData.push(myArray);
						//lineData.push(myData.map(function(d){
						//	return [d[0],d[1]];
						//}));

						//scales.xScale.domain([now + 1, now + 60 + 1]);
						//scales.xScale.domain([0, lineData[0].length*10]);

						var xMin = Infinity;
						var xMax = -Infinity;
						var yMin = Infinity;
						var yMax = -Infinity;

						var oldData = widget.RTdata;
						var time1 = 0+(widget.Time+1)*0.06;
						var time2 = 0.02+(widget.Time+1)*0.06;
						var time3 = 0.04+(widget.Time+1)*0.06;
						var newData = time1+',0.01\r\n'+time2+',0.072445027\r\n'+time3+',0.128970021\r\n';
						widget.RTdata = oldData + newData;

						var contents = widget.RTdata;
						contents = contents.split('\n').map(function(d){
							return d.split(',');
						}).filter(function(d){
							return d.length > 0 && !isNaN(d[0]) && d[0] !== '';
						});

						var rawData = contents;

						for(var i = 0; i < rawData.length; i++){
							for (var j = 1; j < rawData[i].length; j++){
								xMin = Math.min(xMin, rawData[i][0]);
								xMax = Math.max(xMax, rawData[i][0]);
								yMin = Math.min(yMin, rawData[i][j]);
								yMax = Math.max(yMax, rawData[i][j]);
							}
						}

						//for(var i = 0; i < lineData.length; i++){
						//	for (var j = 1; j < lineData[i].length; j++){
						//		yMin = Math.min(yMin, lineData[i][j]);
						//		yMax = Math.max(yMax, lineData[i][j]);
						//	}
						//}

						scales.xScale.domain([xMin, xMax]);
						scales.yScale.domain([yMin, yMax]);

						widget.xAxis.transition()
						.ease('linear')
						.call(widget.xAxisGenerator);

						widget.yAxis.transition()
						.ease('linear')
						.call(widget.yAxisGenerator);



						lineData.push(rawData.map(function(d){
							return [d[0],d[1]];
						}));

						path.data(lineData);
						path.attr('d', lineGenerator);

						lineGroup.selectAll('path')
						.transition()
						.attr('transform', 'translate('+scales.xScale((-0))+')')
						.each('end',realtime);

						//myArray.shift();
						lineData = [];
						lineData.push(myArray);

						widget.Time = now+1;

					}
				}
			
				//realtime();
				
				return lineGroup;
			},
			
			setupMainPlot: function(variableName, expDuration){
				var scales = this.getScales(this.dimensions.main, expDuration),
				svg = d3.select(this.svgs.main),
				dimensions = this.dimensions.main;
				
				this.scales.main = scales;
				
				//Add axes
				var xAxisGenerator = d3.svg.axis()
					.scale(scales.xScale)
					.orient('bottom')
					.ticks(10);
				
				var yAxisGenerator = d3.svg.axis()
				    .scale(scales.yScale)
				    .orient('left')
				    .ticks(5);
					
				this.axisGenerators.main = {
					xAxisGenerator : xAxisGenerator,
					yAxisGenerator : yAxisGenerator
				};
					
				var xAxis = svg.append('g')
					.attr('class', 'xAxis axis')
					.attr('transform', 'translate(' + dimensions.leftPad + ',' + (dimensions.topPad + dimensions.plotHeight) + ')')
					.call(xAxisGenerator);
				
				svg.append('text')
					.attr('transform', 'translate(' + (dimensions.leftPad + dimensions.totalWidth/2 - 25) + ',' + (dimensions.topPad + dimensions.plotHeight + 35) + ')')
					.style('text-anchor', 'middle')
					.text('Time');
					
				var yAxis = svg.append('g')
				    .attr('class', 'yAxis axis')
				    .attr('transform', 'translate(' + dimensions.leftPad + ',' + (dimensions.topPad) + ')')
				    .call(yAxisGenerator);
				
				svg.append('text')
					.attr('transform', 'translate(' + (dimensions.leftPad + dimensions.totalWidth/2 - 190) + ',' + (dimensions.topPad + dimensions.plotHeight - 105) + ')')
					.style('text-anchor', 'middle')
					.text(variableName);
							
				this.axes.main = {
					xAxis : xAxis,
					yAxis : yAxis
				};
				
				if (!widget.xAxis){
					widget.xAxis = [];
					widget.yAxis = [];
					widget.xAxis.push(xAxis);
					widget.yAxis.push(yAxis);
				}				
				else if (widget.xAxis) {
					widget.xAxis.push(xAxis);
					widget.yAxis.push(yAxis);
				}
				
				
				if (!widget.xAxisGenerator){
					widget.xAxisGenerator = [];
					widget.yAxisGenerator = [];
					widget.xAxisGenerator.push(xAxisGenerator);
					widget.yAxisGenerator.push(yAxisGenerator);
				}
				else if (widget.xAxisGenerator) {
					widget.xAxisGenerator.push(xAxisGenerator);
					widget.yAxisGenerator.push(yAxisGenerator);
				}
				
				
				this.plotLines(this.svgs.main, dimensions, scales);
			}
			
	};
	return SMAMSResults;
});

*/

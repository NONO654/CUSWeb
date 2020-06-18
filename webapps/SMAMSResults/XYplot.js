/*! Copyright 2015 Dassault Systemes 
 global define, document 
define('DS/SMAMSResults/XYplot',['UWA/Core', 'DS/UIKIT/Input/Button', 'DS/D3js_external/D3js'],
	function (UWA, Button, d3) {
	'use strict';
	
	var SMAMSResults = {
		
		Plot: function(div, title){
			this.dataObject = {
					timeSeriesType : 'indices',
					data : {},
					indexedColumns : 0
				};
			
			// create svg
			//var div = widget.editor.getUIFrame().querySelector('.results-div');
			var mainSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
			mainSvg.setAttribute('class', 'mainplot-svg');
			div.appendChild(mainSvg);
			var zoomSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
			zoomSvg.setAttribute('class', 'zoomplot-svg');
			div.appendChild(zoomSvg);
			
			this.svgs = {
					main : mainSvg,
					zoom : zoomSvg
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
			
			this.processData();
			
			var variableNameList = [];
			for (var i = 0; i < this.dataObject.data.droppedData.dataName[0].length; i++){
				variableNameList[i] = this.dataObject.data.droppedData.dataName[0][i];
			}
			
			this.setupMainPlot(variableNameList, title);
			this.setupLegend(variableNameList, div);
			this.setupZoomPlot();
						
			if (widget.overlayview){
				widget.overlayview.push(this);
			}
			else {
				widget.overlayview = [];
				widget.overlayview.push(this);
			}
		}
	};
		
	SMAMSResults.Plot.prototype = {
		processData: function(){
			var that = this;
			var contents = widget.XYdata;
			contents = contents.split('\n').map(function(d){
				return d.split(',');
			}).filter(function(d){
				return d.length > 0 && !isNaN(d[0]) && d[0] !== '';
			});
			
			var variableNames = widget.XYdata;
			variableNames = variableNames.split('\n').map(function(d){
				return d.split(',');
			}).filter(function(d){
				return d.length > 0 && isNaN(d[0]) && d[0] !== '';
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

			// end DnD from buildInput

			if(this.dataObject.timeSeriesType === 'indices' || Object.keys(this.dataObject.data).length === 1){
				//Maintain indices.

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
		
		clearMainPlot: function(){
			var node = this.svgs.main;

			while(node.hasChildNodes()){
				node.removeChild(node.lastChild);
			}
		},
		
		clearZoomPlot: function(){
			var node = this.svgs.zoom;

			while(node.hasChildNodes()){
				node.removeChild(node.lastChild);
			}
		},
		
		getScales: function(dimensions){
			var xMin = Infinity,
			xMax = -Infinity,
			yMin = Infinity,
			yMax = -Infinity,
		    y1Min = Infinity,
		    y1Max = -Infinity,
		    y2Min = Infinity,
		    y2Max = -Infinity;
			
			var thisData;

			//Eventually, we should bin before looping.
			for(var key in this.dataObject.data){
				thisData = this.dataObject.data[key].data;
				for(var i = 0; i < thisData.length; i++){
					for (var j = 1; j < thisData[i].length; j++){
						// if selected
						if (this.dataObject.selectedList.selectedList[j-1] === 1){
						xMin = Math.min(xMin, thisData[i][0]);
						xMax = Math.max(xMax, thisData[i][0]);
						yMin = Math.min(yMin, thisData[i][j]);
						yMax = Math.max(yMax, thisData[i][j]);
					}}
					y1Min = Math.min(y1Min, thisData[i][1]);
					y1Max = Math.max(y1Max, thisData[i][1]);
					y2Min = Math.min(y2Min, thisData[i][2]);
					y2Max = Math.max(y2Max, thisData[i][2]);
					// then can do pairwise comparison to find out where the biggest gap between values is
					// this would be the dividing point between the two Y axis
				}
			}

			//Build scales
			var xScale = d3.scale.linear()
			.domain([xMin, xMax])
			.range([0, dimensions.plotWidth]);

			var yScale = d3.scale.linear()
			.domain([yMin, yMax])
			.range([dimensions.plotHeight, 0]);

			var y2Scale = d3.scale.linear()
			.domain([y2Min, y2Max])
			.range([dimensions.plotHeight, 0]);

			return {
				xScale : xScale,
				yScale : yScale,
				y2Scale : y2Scale
			};
		},
		
		plotLines: function(svg, dimensions, scales){
			//var lines = [];
			
			var lineData = [];
			
			var rawData;
			for(var key in this.dataObject.data){
				rawData = this.dataObject.data[key].data;
			}
			
			for(var i = 1; i < rawData[0].length; i++){
				lineData.push(rawData.map(function(d){
					return [d[0], d[i]];
				}));
			}
			
			// or create a function and indices array and call lineGenerator on the index
			
			//Build lines
			var lineGenerator = d3.svg.line()
			    .x(function(d){ return scales.xScale(d[0]); })
			    .y(function(d){ return scales.yScale(d[1]); });
			
			//var lineGenerator2 = d3.svg.line()
			//	.x(function(d){ return scales.xScale(d[0]); })
			//	.y(function(d){ return scales.y2Scale(d[1]); });
			
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
				var colors = ['red', 'blue', 'green', 'yellow', 'orange', 'purple', 'black', 'brown', 'gray', 'beige', 'maroon', 'navy', 'olive', 'silver', 'tan'];
				return colors[i];
			};
			
			var tempList = this.dataObject.selectedList.selectedList;
			
			lineGroup.selectAll('path')
				.data(lineData) // indices
				.enter()
				.append('path')
				.attr('class', function(d, i){return 'plotLine plotLine' + i;})
				.each(function(d, i){
					d3.select(this).style({'stroke': color(i)});
					d3.select(this).attr({'id' : 'Line'+i});
					d3.select(this).style({'opacity': tempList[i]});
				});
				
				//.attr('style', function(d, i){
				//	return {'stroke' : color(i)}
				//});
			
			//Draw the lines.
			//This is done separately so we can use the same function to update or draw the lines.
			lineGroup.selectAll('path')
				.attr('d', function(d){ return lineGenerator(d); });
			
			return lineGroup;
		},
		
		setupMainPlot: function(variableNameList, title){
			
			//var variableNameList = [];
			//for (var i = 0; i < this.dataObject.data.droppedData.dataName[0].length; i++){
			//	variableNameList[i] = this.dataObject.data.droppedData.dataName[0][i];
			//}
			
			if (!widget.variableNameList){
				widget.variableNameList = [];
				for (var i = 0; i < this.dataObject.data.droppedData.dataName[0].length; i++){
					widget.variableNameList[i] = this.dataObject.data.droppedData.dataName[0][i];
				}
			}
			else if (widget.variableNameList){
				for (var i = widget.variableNameList.length; i < widget.variableNameList.length + this.dataObject.data.droppedData.dataName[0].length; i++){
					widget.variableNameList[i] = this.dataObject.data.droppedData.dataName[0][i-widget.variableNameList.length];
				}
			}
			
			if (!this.dataObject.selectedList){
				var dataName = 'selectedList';
				this.dataObject[dataName] = {
						selectedList : []
				};
				for (var i = 0; i < this.dataObject.data.droppedData.dataName[0].length; i++){
						variableNameList[i] = this.dataObject.data.droppedData.dataName[0][i];
						this.dataObject.selectedList.selectedList[i] = 1;
				}
			}
			// if widget.selectedList does not exist, create all true. If it exists, keep as is and add. Update when click button, replot (similar to resize).
			if (!widget.selectedList){
				widget.selectedList = [];
				for (var i = 0; i < this.dataObject.data.droppedData.dataName[0].length-1; i++){
					variableNameList[i] = this.dataObject.data.droppedData.dataName[0][i];
					widget.selectedList[i] = 1;
				}
			}
			else
				for (var i = 0; i < this.dataObject.data.droppedData.dataName[0].length-1; i++){
					widget.selectedList.push(1);
				}
			else if (widget.selectedList){
				for (var i = widget.selectedList.length; i < widget.selectedList.length + this.dataObject.data.droppedData.dataName[0].length; i++){
					widget.selectedList[i] = 1;
				}
			}
			
			var scales = this.getScales(this.dimensions.main);
			var svg = d3.select(this.svgs.main);
				//.on("mouseover", this.mouseenter.bind(this, scales))
				//.on("mouseleave", this.mouseleave.bind(this, scales)),
			var dimensions = this.dimensions.main;
			this.scales.main = scales;
			
			var lineGroup = this.plotLines(this.svgs.main, dimensions, scales);
			
			//Add clip path to reduce viewable area while zooming
			//var defs = lineGroup.append('defs');
			var	clipPathName = 'lineClip';
			
			var lineClip = lineGroup.append('clipPath')
				.attr('id', clipPathName);
			
			lineClip.append('rect')
				.attr('x', 0)
				.attr('y', 0)
				.attr('width', dimensions.plotWidth)
				.attr('height', dimensions.plotHeight);
				
			lineGroup.selectAll('path')
				.attr('clip-path', 'url(#' + clipPathName + ')');
			
			//Add axes
			var xAxisGenerator = d3.svg.axis()
				.scale(scales.xScale)
				.orient('bottom')
				.ticks(10);
			
			var yAxisGenerator = d3.svg.axis()
			    .scale(scales.yScale)
			    .orient('left')
			    .ticks(5);
				
			//var y2AxisGenerator = d3.svg.axis()
			//	.scale(scales.y2Scale)
			//	.orient('right')
			//	.ticks(5);
				
			this.axisGenerators.main = {
				xAxisGenerator : xAxisGenerator,
				yAxisGenerator : yAxisGenerator
				//y2AxisGenerator : y2AxisGenerator
			};
				
			var xAxis = svg.append('g')
				.attr('class', 'xAxis axis')
				.attr('transform', 'translate(' + dimensions.leftPad + ',' + (dimensions.topPad + dimensions.plotHeight) + ')')
				.call(xAxisGenerator);
			
			svg.append('text')
				.attr('transform', 'translate(' + (dimensions.leftPad + dimensions.totalWidth/2 - 25) + ',' + (dimensions.topPad + dimensions.plotHeight + 35) + ')')
				.style('text-anchor', 'middle')
				.text('Time');
			
			if (widget.editor.getUIFrame().querySelectorAll('.adbreadcrumb')[1]){
				svg.append('text')
				.attr('transform', 'translate(' + (dimensions.leftPad + dimensions.totalWidth/2 - 25) + ',' + (dimensions.topPad + dimensions.plotHeight - 105) + ')')
				.style('text-anchor', 'middle')
				.text(widget.editor.getUIFrame().querySelectorAll('.adbreadcrumb')[1].innerHTML);
				//.text(title);
			}
			else if (!widget.editor.getUIFrame().querySelectorAll('.adbreadcrumb')[1]){
				svg.append('text')
				.attr('transform', 'translate(' + (dimensions.leftPad + dimensions.totalWidth/2 - 25) + ',' + (dimensions.topPad + dimensions.plotHeight - 105) + ')')
				.style('text-anchor', 'middle')
				//.text(widget.editor.getUIFrame().querySelectorAll('.adbreadcrumb')[1].innerHTML);
				.text(title);
			//}
				
			var yAxis = svg.append('g')
			    .attr('class', 'yAxis axis')
			    .attr('transform', 'translate(' + dimensions.leftPad + ',' + (dimensions.topPad) + ')')
			    .call(yAxisGenerator);
			
			//var y2Axis = svg.append('g')
			//	.attr('class', 'y2Axis axis')
			//	.attr('transform', 'translate(' + (dimensions.leftPad + dimensions.plotWidth) + ',' + (dimensions.topPad) + ')')
			//	.call(y2AxisGenerator);
						
			this.axes.main = {
				xAxis : xAxis,
				yAxis : yAxis
				//y2Axis : y2Axis
			};
			//return variableNameList;
		},
		
		setupZoomPlot: function(){
			
			var scales = this.getScales(this.dimensions.zoom);
			var svg = d3.select(this.svgs.zoom),
				dimensions = this.dimensions.zoom;
				
			var brushHeight = dimensions.plotHeight + 4,
				brushPad = dimensions.topPad - 2;

			this.plotLines(this.svgs.zoom, this.dimensions.zoom, scales);
			
			//Add axes
			var xAxisGenerator = d3.svg.axis()
				.scale(scales.xScale)
				.orient('bottom')
				.ticks(10);
				
			var xAxis = svg.append('g')
				.attr('class', 'xAxis axis')
				.attr('transform', 'translate(' + dimensions.leftPad + ',' + (dimensions.topPad + dimensions.plotHeight) + ')')
				.call(xAxisGenerator);
			
	         
            function brushMove(){
                var brushExtent = brushGenerator.extent();
                
                if(brushExtent[0] !== brushExtent[1]){
                    that.zoomMainPlot(brushExtent);
                }
            }
				
			//Add brush to plot
			var brushGenerator = d3.svg.brush()
				.x(scales.xScale)
				.extent(scales.xScale.domain())
				.on('brushstart', brushStart)
				.on('brush', brushMove)
				.on('brushend', brushEnd);
				
			var brushArcGenerator = d3.svg.arc()
				.outerRadius(brushHeight / 2)
				.startAngle(0)
				.endAngle(function(d, i){
					//End angle determines which direction the arc will be drawn in.
					//Negative angle -> counter clockwise, positive -> clockwise
					//i is 0 or 1. For i = 0, we want to end at pi. For i=1, end at -pi.
					return 0;
				});
				
			var brush = svg.append('g')
				.attr('class', 'zoomBrush')
				.attr('transform', 'translate(' + dimensions.leftPad + ',' + brushPad + ')')
				.call(brushGenerator);
				
			//Append arcs to the brush handles
			brush.selectAll('.resize').append('path')
				.attr('transform', 'translate(0,' + brushHeight/2 + ')')
				.attr('d', brushArcGenerator);
				
			brush.selectAll('rect')
				.attr('height', brushHeight);
						
			brush.selectAll('g').append('svg:foreignObject')
				.attr('width', 10)
				.attr('height', 10)
				.attr('transform', 'translate(' + (-14) + ',' + 10 + ')')
				.append('xhtml:span')
				.attr('class', 'fonticon fonticon-left-bold');
			
			brush.selectAll('g').append('svg:foreignObject')
				.attr('width', 10)
				.attr('height', 10)
				.attr('transform', 'translate(' + (-6) + ',' + 10 + ')')
				.append('xhtml:span')
				.attr('class', 'fonticon fonticon-right-bold');
				
			var that = this;
				
			function brushStart(){
				//console.log('deactivate drag div');
				//document.onmousemove = null;
				//document.onmouseup = null;
			}
			
			function brushEnd(){
				var brushExtent = brushGenerator.extent();
				
				if(brushExtent[0] === brushExtent[1]){
					that.zoomMainPlot(scales.xScale.domain());
				}
				
				var div = widget.editor.getUIFrame().querySelector('.results-div');
				var selectedPlot = null;
				var xMouse = 0;
				var yMouse = 0;
				var xPlot = 0;
				var yPlot = 0;
								
				function dragStart(div){
					selectedPlot = div;
					//console.log('selected true');
					xPlot = xMouse - div.offsetLeft;
					yPlot = yMouse - div.offsetTop;
				}
				
				function moveDiv(e){
					if (selectedPlot){
						xMouse = window.event.clientX;
						yMouse = window.event.clientY;
						selectedPlot.style.left = (xMouse - 175) + 'px';
						selectedPlot.style.top = (yMouse - 175) + 'px';
					}
				}
				
				function dragEnd(){
					selectedPlot = null;
					//console.log('selected false');
				}
				
				var div = widget.editor.getUIFrame().querySelector('.results-div');
				div.onmousedown = function(){
					dragStart(this);
				}
				document.onmousemove = moveDiv;
				document.onmouseup = dragEnd;
			}
		},
		
		zoomMainPlot: function(zoomVals){
			//For zooming we need to update our scale, redraw the lines, and update the axes.
			
			var zoomMin = zoomVals[0],
				zoomMax = zoomVals[1];
			
			var scales = this.scales.main,
				dimensions = this.dimensions.main;
			
			//Update scale.
			scales.xScale.domain([zoomMin, zoomMax]);
			
			//Redraw lines
			this.plotLines(this.svgs.main, dimensions, scales);
			
			//Update axes
			var xAxisGenerator = this.axisGenerators.main.xAxisGenerator
				.scale(scales.xScale);
				
			this.axes.main.xAxis.call(xAxisGenerator);
		},
			
		setupLegend: function(variableNameList, div){
			//var legend = d3.select('#legendPlotSvg');
			//var legend = d3.select('#' + widget.target.parentNode.parentNode.children[2].children[0].id);
			// create svg
			var divs = widget.editor.getUIFrame().querySelectorAll('.results-div');
			//var legendsvg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
			//div.appendChild(legendsvg);
			//var legend = d3.select(legendsvg);
			var svgs = [];
			for (var i = 0; i<divs.length; i++){
				for (var j = 0; j<divs[i].getElementsByTagName('svg').length; j++){
					svgs.push(divs[i].getElementsByTagName('svg')[j]);
				}
			}
			var svgs = widget.editor.getUIFrame().querySelectorAll('.mainplot-svg');
			var svgCount = svgs.length;
			var legend = d3.select(svgs[svgCount - 1]);
			
			legend.append('g')
				.attr('class', 'legend')
				.attr('id', 'legend')
				.attr('x', 10)
				.attr('y', 400)
				//.attr('width',  widget.elements.content.querySelector('#mainPlotSvg').width.animVal.value)
				.attr('width', '100')
				.attr('height', '50');
		
			//legend.append('rect')
			//	.attr('x', widget.elements.content.querySelector('#mainPlotSvg').width.animVal.value -170)
			//	.attr('y', 20)
			//	.attr('width','170')
			//	.attr('height','280');
			
			//var color = d3.scale.category20();
			var colors = ['red', 'blue', 'green', 'yellow', 'orange', 'purple', 'black', 'brown', 'gray', 'beige', 'maroon', 'navy', 'olive', 'silver', 'tan'];
			
			//var variableNameList = [];
			//for (var i = 0; i < this.dataObject.data.droppedData.dataName[0].length; i++){
			//	variableNameList[i] = this.dataObject.data.droppedData.dataName[0][i];
			//}
			
			var buttons = [];
			if (widget.buttons){
			    buttons = widget.buttons;
			}

			var blength = buttons.length;
			
			//if no side panel, create one. inject buttons there
			//this.sidePanel = new SidePanel(div.parentElement.parentElement.parentElement.parentElement);
			if (!div.parentElement.querySelector('.buttonsDiv') && !div.parentElement.querySelector('.buttonsDiv-hidden')){
				var editor = widget.editor;
				//var formDiv = UWA.createElement('div');
				var legendDiv = UWA.createElement('div',{
            		events: {
            			click: function(event) {
            				if(this.getAttribute('class')==='legendDiv'){
            					this.setAttribute('class','legendDiv-hidden');
            					this.querySelector('.buttonsDiv').setAttribute('class','buttonsDiv-hidden');
            				}
            				else if (this.getAttribute('class') === 'legendDiv-hidden'){
            					this.setAttribute('class','legendDiv');
            					this.querySelector('.buttonsDiv-hidden').setAttribute('class','buttonsDiv');
            				}		
            			}
            		}
            	});
				legendDiv.setAttribute('class', 'legendDiv');
				legendDiv.inject(div);
				var buttonsDiv = UWA.createElement('div');
				buttonsDiv.setAttribute('class', 'buttonsDiv');
				buttonsDiv.inject(legendDiv);
				var sideBar = UWA.createElement('div');
				sideBar.setAttribute('class', 'sideBar');
				sideBar.inject(legendDiv);
				var spOptions = {};
				spOptions.title = 'Legend';
				spOptions.content = buttonsDiv;
				spOptions.onClickOk = (function() {
	            	this.end();
	            	editor.sidePanel.addContent();
	            	editor.sidePanel.slideOut();            	
	            	editor.showActionBar();
	            }).bind(this);
				spOptions.onClickCancel = (function() {
	            	this.end();
	            	editor.sidePanel.addContent();
	            	editor.sidePanel.slideOut();            	
	            	editor.showActionBar();
	            }).bind(this);
				editor.sidePanel.focusWait = false;
				editor.sidePanel.addContent(spOptions);
				editor.sidePanel.slideIn();
			}
			else if (widget.editor.getUIFrame().querySelector('.buttonsDiv')){
				//var buttonsDiv = UWA.createElement('div');
				//buttonsDiv.setAttribute('class', 'buttonsDiv');
				//buttonsDiv.inject(div);
				//buttonsDiv.inject(widget.editor.getUIFrame().querySelector('.wux-panels-panelbase-content'));
			}
						
			//buttonsDiv.inject(widget.editor.getUIFrame().querySelector('.wux-panels-panelbase-content'));
			
			for (var i = blength + 1 ; i < blength + variableNameList.length; i++){
				if (div.parentElement.querySelector('.buttonsDiv-hidden')){
					div.parentElement.querySelector('.buttonsDiv-hidden').setAttribute('class','buttonsDiv');
					div.parentElement.querySelector('.legendDiv-hidden').setAttribute('class','legendDiv');
				}
				buttons[i-1] = new Button({ value: variableNameList[i-blength], className: 'btn-sm'}).inject(div);//div.parentElement.querySelector('.buttonsDiv'));//.inject(widget.target.parentNode.parentNode.children[0]);
				buttons[i-1].elements.container.classList.add('plot-legend');
				buttons[i-1].elements.container.style.marginBottom='10px';
				buttons[i-1].elements.container.style.color = colors[i-blength-1];
				buttons[i-1].elements.container.style.fontWeight='bold';
				buttons[i-1].elements.container.style.fontFamily='sans-serif';
				buttons[i-1].options.selector = i-1-blength;
				//buttons[i-1].options.selectorPlot = svgCount; 
				if (!widget.overlayview) {
					buttons[i-1].options.selectorPlot = 1;
				}
				else if (widget.overlayview) {
					buttons[i-1].options.selectorPlot = widget.overlayview.length + 1;
				}
				buttons[i-1].options.div = this.svgs.main; //svgs[svgCount - 1]; //widget.target.parentNode.parentNode.children[0];
				buttons[i-1].addEvent('onClick', function(){
					// need to select the div of the button
					if (d3.select(this.options.div).select('#' + 'Line' + this.options.selector).style('opacity') === '1'){
						d3.select(this.options.div).select('#' + 'Line' + this.options.selector).style('opacity', 0);
						widget.overlayview[this.options.selectorPlot-1].dataObject.selectedList.selectedList[this.options.selector]=0;
						this.elements.container.style.fontWeight=100;
						//update scale similar to zoomMainPlot, call plotLines again. update axes.
						//for(var key in this.dataObject.data){
						var k = 0;
						while(d3.select(this.options.div).select("#" + "Line" + k).data()[0]){
							//thisData = this.dataObject.data[key].data
							var xMin = Infinity,
							xMax = -Infinity,
							yMin = Infinity,
							yMax = -Infinity;
							var thisData = d3.select(this.options.div).select("#" + "Line" + k).data()[0];
							for(var i = 0; i < thisData.length; i++){
								for (var j = 1; j < thisData[i].length; j++){
									// if selected
									if (widget.selectedList[j] == true){
										xMin = Math.min(xMin, thisData[i][0]);
										xMax = Math.max(xMax, thisData[i][0]);
										yMin = Math.min(yMin, thisData[i][j]);
										yMax = Math.max(yMax, thisData[i][j]);
									}
								}
							}
							k=k+1;
						}
						var scales = this.scales.main,
						dimensions = this.dimensions.main;
					
						//Update scale.
						scales.xScale.domain([zoomMin, zoomMax]);
					
						//Redraw lines
						this.plotLines(this.svgs.main, dimensions, scales);
					
						//Update axes
						var xAxisGenerator = this.axisGenerators.main.xAxisGenerator
							.scale(scales.xScale);
						
						this.axes.main.xAxis.call(xAxisGenerator);
						
						// update y scale and plot
						//for (var i = 0; i < widget.overlayview.length; i++){
						var title = d3.select(this.options.div)[0][0].children[3].innerHTML;
						widget.overlayview[this.options.selectorPlot-1].clearMainPlot();
						widget.overlayview[this.options.selectorPlot-1].clearZoomPlot();
						widget.overlayview[this.options.selectorPlot-1].setupMainPlot(variableNameList, title);
						widget.overlayview[this.options.selectorPlot-1].setupZoomPlot();
						//}
					}
					else if (d3.select(this.options.div).select('#' + 'Line' + this.options.selector).style('opacity') === '0'){
						d3.select(this.options.div).select('#' + 'Line' + this.options.selector).style('opacity', 1);
						widget.overlayview[this.options.selectorPlot-1].dataObject.selectedList.selectedList[this.options.selector]=1;
						this.elements.container.style.fontWeight=900;
						// update y scale and plot
						//for (var i = 0; i < widget.overlayview.length; i++){
						var title = d3.select(this.options.div)[0][0].children[3].innerHTML;
						widget.overlayview[this.options.selectorPlot-1].clearMainPlot();
						widget.overlayview[this.options.selectorPlot-1].clearZoomPlot();
						widget.overlayview[this.options.selectorPlot-1].setupMainPlot(variableNameList, title);
						widget.overlayview[this.options.selectorPlot-1].setupZoomPlot();
					//}
					}
				});
			}
			//for (var i = 0; i < this.dataObject.data.droppedData.dataName[0].length; i++){
			//	buttons[i].elements.container.style.color = colors[i];
			//}
			
			widget.buttons = buttons;
		}
	};
	return SMAMSResults;
});


*/

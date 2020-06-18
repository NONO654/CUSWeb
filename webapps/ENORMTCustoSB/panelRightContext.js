//@quickreview HAT1 ZUD IR-428176-3DEXPERIENCER2017x  20-Apr-2016   R418: [IPAD Specific] : "Quick Chart" window doesn't shows "close" button.
//@quickreview  QYG           05:03:16    javascript refactoring, location moved
//@quickreview KIE1 ZUD 19/10/2016 : IR-478655-3DEXPERIENCER2018x: R19-STP: Tree view does not get refreshed after exploring Categories and synchronization does not work correctly.
//@quickreview KIE1 ZUD 20/03/2018 : IR-580732-3DEXPERIENCER2018x: validation column of the Test Case wrongly at failed
//@quickreview KIE1 ZUD 20/03/2018 : IR-580154-3DEXPERIENCER2018x:QuickCharts are inconsistent with other Requirement views 
//=================================================================
// JavaScript panelRightContext.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
// NOTE: Legacy code stay as global to avoid regression.
//       New code should be put inside of "define"
if(localStorage['debug.AMD']) {
	var _panelRightContext_js = _panelRightContext_js || 0;
	_panelRightContext_js++;
	console.info("AMD: ENORMTCustoSB/panelRightContext.js loading " + _panelRightContext_js + " times.");
}

define('DS/ENORMTCustoSB/panelRightContext', ['DS/RichEditorCusto/Util'], function(){
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/panelRightContext.js dependency loaded.");
	}
	//START : LX6 IR-348544-3DEXPERIENCER2016x
	emxUICore.instrument(window, 'DrawCompleteTree', beforeDrawCompleteTree, null);
	//END : LX6 IR-348544-3DEXPERIENCER2016x
	
	
	if(localStorage['debug.AMD']) {
		console.info("AMD: ENORMTCustoSB/panelRightContext.js finish.");
	}	
	return {};
});

function createOXmlReqTypes(reqTypes){
	var typeTag = "@type=";
	var reqCmd = "";
	for(var i=0;i<reqTypes.length;i++){
		reqCmd += typeTag + "'" + reqTypes[i] + "' ";
		if(i<reqTypes.length-1){
			reqCmd += " or ";
		}
	}
	return reqCmd;
}


function normalizeChars(attribute){
	if((typeof attribute).toLowerCase()=='string'){
		return attribute.replace(/ /g,"").replace(/'/g,"").toLowerCase();
	}else if((typeof attribute).toLowerCase()=='object'){
		for(var i=0;i<attribute.length;i++){
			attribute[i]=attribute[i].replace(/ /g,"").replace(/'/g,"").toLowerCase();
		}
		return attribute;
	}
	
}

function setRequestSetting(name, value) {
    return _setSetting(oXML, "/mxRoot/requestMap", name, value);
}

function getRequestSetting(name) {
    return _getSetting(oXML, "/mxRoot/requestMap", name);
}

function _getSetting(xml, basePath, name) {
    var nSetting = emxUICore.selectSingleNode(xml, basePath + "/setting[@name = '" + name + "']");
    if (!nSetting) {
        return null;
    } else {
        return emxUICore.getText(nSetting);
    }
}


function _setSetting(xml, basePath, name, value) {
    var nBase = emxUICore.selectSingleNode(xml, basePath);

    var nSetting = emxUICore.selectSingleNode(nBase, "setting[@name = '" + name + "']");
    if (!nSetting) {
        nSetting = xml.createElement("setting");
        nSetting.setAttribute("name", name);
        emxUICore.setText(nSetting, value);
        nBase.appendChild(nSetting);
        return null;
    } else {
        var old= emxUICore.getText(nSetting);
        emxUICore.setText(nSetting,value);
        return old;
    }
}

function refreshCustomChart(chartId,filter){
	var object = null;
	if(chartId == "divChartStatus"){
		object = refreshStatusChart();
	}else if(chartId == "divChartPLMParameter"){
		object = refreshPLMParameterChart( chartId);
	}else if(chartId == "divChartTestCase"){
		 object = refreshTestCaseChart( chartId);
	}
	return object;
}

function isTypeExpanded(type){
	expandedTypes = getRequestSetting("RMTCustomTypes");
	var returnValue = false;
	if(expandedTypes!=null&&expandedTypes.indexOf(type)>0){
		returnValue = true;
	}
	return returnValue;
}

function updateObjectInFILTERING_OBJECTS_MANAGEMENT(attribute,ranges,values,isCurrentChart){
	var modifiedRows = [];
	attribute = normalizeChars(attribute);
	ranges = normalizeChars(ranges);
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	if(quickChartFrame.FILTERING_OBJECTS_MANAGEMENT[attribute]==null){
		quickChartFrame.FILTERING_OBJECTS_MANAGEMENT[attribute] = ranges.slice();
	}
	if(isCurrentChart==false){
		for(var i =0;i<values.length;i++){
			var index = quickChartFrame.FILTERING_OBJECTS_MANAGEMENT[attribute].find(ranges[i]);
			if(values[i]==0){
				if(index>=0){
					quickChartFrame.FILTERING_OBJECTS_MANAGEMENT[attribute].splice(index,1);
				}	
			}else{
				if(index==-1){
					quickChartFrame.FILTERING_OBJECTS_MANAGEMENT[attribute].push(ranges[i]);
				}
			}
		}
	}
	var update = true;
	if(update == true){
		updateRows(modifiedRows);
	}
	
}

function addAttributeToOXML(objectList, ParameterName, ParamValues){
	if(ParameterName!=null&&ParamValues!=null){
		var attributeName = normalizeChars(ParameterName);
		for(var i = 0;i<objectList.length;i++){
			var value = ParamValues[objectList[i].getAttribute('o')];
			objectList[i].setAttribute(attributeName,normalizeChars(value));
		}
	}
}

var rangeValues;
function refreshStatusChart(){
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var values = getStatusValues();	
	return values;
	
}

function displayStatusChart(){
	var colors = generateColourList(statusValues);
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	chartStatus = new Highcharts.Chart({
		chart: {
			type			: 'bar',
			renderTo		: 'divChartStatus',
			marginTop		: 15,
			marginRight		: 20,
			marginBottom	: 50,
			zoomType		: 'y',
			reflow			: false
		},
		colors : colors,
		title		: { text		: null  },
		credits 	: { enabled 	: false },
		exporting	: { enabled 	: false },
		legend		: { enabled 	: false },
		tooltip		: { enabled 	: false	},
		legend: {
			 layout: 'horizontal',
			 align: 'center',
	         verticalAlign: 'bottom',
             borderWidth: 1,
             backgroundColor: '#FFFFFF',
             shadow: true,
             y: 10
        },
		plotOptions: {
			series: {
				pointWidth: 20,
                pointPadding: 10,
                cursor:'pointer',
                point: {
                    events: {
                        click: function () {
                        	this.series.hide();
                        	return updateTable(chartStatus.attributeName,this.series.name,false,chartStatus);
                        }
                    }
                }
			},
			column: {
	            pointWidth: 10,
	            borderWidth: 1,
	            colorByPoint: true
	        },
			bar: {
				pointWidth: 20,
                pointPadding: 0,
				dataLabels: { enabled : true },
				events: {
                    legendItemClick: 
                    	function(event) {
                    		var show =true;
                    		if(this.visible){
                    			show=false;
                    		}
                    		return updateTable('Status',this.name,show,chartStatus);
                    }
				}
			}						
		},				
		xAxis: {
categories: [""],
			title: { text: null },	
			labels2: {
				formatter: function () {
					var text = this.value,
					formatted = text.length > 18 ? text.substring(0, 18) + '...' : text;
					return '<div style="width:80px; overflow:hidden" title="' + text + '">' + formatted + '</div>';
				},
				style: {
					width: '80px'
				},
				useHTML: true
			}
		},
		yAxis: {
			allowDecimals: false,
			alternateGridColor: '#F1F1F1',
			title: { text: null }
		},		
		series: [{
			name: statusValues[0],
			data: [null],
			selected: true
		},
		{
			name: statusValues[1],
			data: [null],
			selected: true
		},
		{
			name: statusValues[2],
			data: [null],
			selected: true
		},
		{
			name: statusValues[3],
			data: [null],
			selected: true
		},
		{
			name: statusValues[4],
			data: [null],
			selected: true
		}
		]
	});
	quickChartFrame.chartStatus = chartStatus;
	chartStatus.attributeName = "Status";
	CHARTS["divChartStatus"] = chartStatus;
	var values = refreshChart("divChartStatus", chartStatus.attributeName);
	updateObjectInFILTERING_OBJECTS_MANAGEMENT('Status',statusValues,values);
	return chartStatus;
}

function refreshPLMParameterChart( filter){
	var rootObjType = getTopWindow().rootObjType;
	var OXMLTypeArg = getTopWindow().OXMLTypeArg;
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var addRootObjOnChart = ""
		if(OXMLTypeArg.indexOf(rootObjType)>=0){
			addRootObjOnChart = " or @level='0' ";
		}
	var reqObjects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+ OXMLTypeArg + addRootObjOnChart +" and (@filter='false' or @filter='0')]");
	var ReqsWithParameters = [];
	var values = [];
	var plmChartValues=[0,0];
	var allParameters = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@type='PlmParameter']");
	if(allParameters.length>0){
		var Parameters = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@type='PlmParameter' and (@filter='false' or @filter='0')]");
		for(var i =0;i<reqObjects.length;i++){
			var objectFound = false;
			var objectId = reqObjects[i].getAttribute("o");
			for(var j=0;j<Parameters.length;j++){
				var parentId = Parameters[j].parentNode.getAttribute("o");
				if(parentId == objectId){
					ReqsWithParameters[objectId] = quickChartFrame.PLMParameterValues[0];
					plmChartValues[0]+=1;
					objectFound = true;
					break;
				}
			}
			if(objectFound == false){
				ReqsWithParameters[objectId] = quickChartFrame.PLMParameterValues[1];
				plmChartValues[1]+=1;
			}
		}
		addAttributeToOXML(reqObjects, quickChartFrame.ParameterAttributeName, ReqsWithParameters);	
		values.push(filter);
		values.push(plmChartValues);
		values.push(ReqsWithParameters);
	}else{
		var idList = "";
		for(var i = 0;i<reqObjects.length;i++){
			var id = reqObjects[i].getAttribute("o");
			idList+=id;
			if(i!=reqObjects.length-1){
				idList+=",";
			}
		}
		if(idList!=null&&idList.length>0){
			values = getAjaxRequest(idList, filter);
			addAttributeToOXML(reqObjects, quickChartFrame.ParameterAttributeName, values[2]);
			plmChartValues = values[1];
		}
		
	}
	return plmChartValues;
}

function displayPLMParameterChart(Filter){
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var colors = generateColourList(PLMParameterValues);
	chartPLMParameter = new Highcharts.Chart({
		chart: {
			type		: 'bar',
			renderTo	: 'divChartPLMParameter',
			marginRight	: 20,
			zoomType	: 'y'
		},
		colors:colors,
		title		: { text		: null  },
		credits 	: { enabled 	: false },
		exporting	: { enabled 	: false },
		legend: {
			 layout: 'horizontal',
			 align: 'center',
	         verticalAlign: 'bottom',
	           borderWidth: 1,
	           backgroundColor: '#FFFFFF',
	           shadow: true,
	           y: 10
			},
		plotOptions: {
			bar: {
				pointWidth:20,
				dataLabels: { 
					enabled : true
				},
				point : {
				},
				events: {
	                legendItemClick: 
	                	function(event) {
	                		var show =true;
	                		if(this.visible){
	                			show=false;
	                		}
	                		manageRefreshWithObjectType(PLMParameterValues,ParameterAttributeName,this.name,show,chartPLMParameter,"PlmParameter");	                		
	                }
				}			
			},	
			series: {
				groupPadding: 0,
				cursor:'pointer',
                point: {
                    events: {
                        click: function () {
                        	this.series.hide();
                        	manageRefreshWithObjectType(PLMParameterValues,ParameterAttributeName,this.series.name,false,chartPLMParameter,"PlmParameter");
                        }
                    }
                }
			}
		},				
		xAxis: {
			categories: [""],
			title: { text: null }					
		},
		yAxis: {
			allowDecimals: false,
			alternateGridColor: '#F1F1F1',
			title: { text: null }						
		},
		tooltip: {
			enabled : false
		},
		series: [{
			name: PLMParameterValues[0],
			data: [null],
			selected:true
		},
		{
			name: PLMParameterValues[1],
			data: [null],
			selected:true
		}]
	});		
	quickChartFrame.chartPLMParameter = chartPLMParameter;
	chartPLMParameter.attributeName = "Parameters";
	var values = refreshChart("divChartPLMParameter", chartPLMParameter.attributeName);
	updateObjectInFILTERING_OBJECTS_MANAGEMENT(ParameterAttributeName,PLMParameterValues,values);
	CHARTS["divChartPLMParameter"] = chartPLMParameter;
	return chartPLMParameter;
}



function refreshTestCaseChart( filter,ranges){
	var OXMLTypeArg = getTopWindow().OXMLTypeArg;
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var ReqsWithTestCases = [];
	var reqObjects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+OXMLTypeArg+" and (@filter='false' or @filter='0')]");
	var values = [];
	var chartValues = [0,0];
	if(isTypeExpanded("TestCases")==true){
		var chartValues = [0,0];
		var TestCases = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@type='Test Case' and (@filter='false' or @filter='0')]");
		for(var i =0;i<reqObjects.length;i++){
			var objectFound = false;
			var objectId = reqObjects[i].getAttribute("o");
			for(var j=0;j<TestCases.length;j++){
				var parentId = TestCases[j].parentNode.getAttribute("o");
				if(parentId == objectId){
					ReqsWithTestCases[objectId] = quickChartFrame.TestCasesValues[0];
					chartValues[0]+=1;
					objectFound = true;
					break;
				}
			}
			if(objectFound == false){
				ReqsWithTestCases[objectId] = quickChartFrame.TestCasesValues[1];
				chartValues[1]+=1;
			}
		}
		addAttributeToOXML(reqObjects, quickChartFrame.TestCaseAttributeName, ReqsWithTestCases);	
		values.push(filter);
		values.push(chartValues);
		values.push(ReqsWithTestCases);
	}else{
		var idList = "";
		for(var i = 0;i<reqObjects.length;i++){
			var id = reqObjects[i].getAttribute("o");
			idList+=id;
			if(i!=reqObjects.length-1){
				idList+=",";
			}
		}
		if(idList.length>0){
			values = getAjaxRequest(idList, filter);
			addAttributeToOXML(reqObjects, quickChartFrame.TestCaseAttributeName, values[2]);
			chartValues = values[1];
		}
	}	
	return chartValues;
}


function manageRefreshWithObjectType(AttributeName,name,isShown,Chart, objectType){
	if(normalizeChars(name) == PLMParameterValues[0]){
		if(isShown==false){
			return updateTable(AttributeName,name,isShown,Chart,objectType,false);
		}else{
			return updateTable(AttributeName,name,isShown,Chart,objectType,true);
		}
	} else{
		if((normalizeChars(name) == PLMParameterValues[1])){
			if(isShown==false){
				return updateTable(AttributeName,name,isShown,Chart,objectType,true);
			}else{
				return updateTable(AttributeName,name,isShown,Chart,objectType,false);
			}
			
		}
	}
}

function displayTestCaseChart(Filter){
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var colors = generateColourList(TestCasesValues);
	chartTestCase = new Highcharts.Chart({
		chart: {
			type		: 'bar',
			renderTo	: 'divChartTestCase',
			marginRight	: 20,
			zoomType	: 'y'
		},
		colors:colors,
		title		: { text		: null  },
		credits 	: { enabled 	: false },
		exporting	: { enabled 	: false },
		legend: {
			 layout: 'horizontal',
			 align: 'center',
	         verticalAlign: 'bottom',
	           borderWidth: 1,
	           backgroundColor: '#FFFFFF',
	           shadow: true,
	           y: 10
			},
		plotOptions: {
			bar: {
				pointWidth:20,
				dataLabels: { 
					enabled : true
				},
				point : {
				},
				events: {
	                legendItemClick: function(event) {
                		var show =true;
                		if(this.visible){
                			show=false;
                		}
                		return manageRefreshWithObjectType(TestCasesValues,TestCaseAttributeName,this.name,show,chartTestCase,'Test Case');
	                }
				}
				
			},	
			series: {
				groupPadding: 0,
				cursor:'pointer',
                point: {
                    events: {
                        click: function () {
                        	this.series.hide();
                        	//return updateTable(TestCaseAttributeName,this.series.name,false,chartTestCase);
                        	return manageRefreshWithObjectType(TestCasesValues,TestCaseAttributeName,this.series.name,false,chartTestCase,null);
                        	//return onChartEvent(attributeName,this.series.name,Chart);
                        }
                    }
                }
			}
		},				
		xAxis: {
			categories: [""],
			title: { text: null }					
		},
		yAxis: {
			allowDecimals: false,
			alternateGridColor: '#F1F1F1',
			title: { text: null }						
		},
		tooltip: {
			enabled : false
		},
		series: [{
			name: TestCasesValues[0],
			data: [null],
			selected:true
		},
		{
			name: TestCasesValues[1],
			data: [null],
			selected:true
		}]
	});		
	quickChartFrame.chartTestCase =chartTestCase;
	chartTestCase.attributeName = normalizeChars(TestCaseAttributeName);
	CHARTS["divChartTestCase"] = chartTestCase;
	var values = refreshChart("divChartTestCase", chartTestCase.attributeName);
	updateObjectInFILTERING_OBJECTS_MANAGEMENT(TestCaseAttributeName,TestCasesValues,values);
	return chartTestCase;
}

function getECValues(){
	var rootObjType = getTopWindow().rootObjType;
	var reqTypesArray = getTopWindow().reqTypesArray;
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var colMapSize = colMap.columns.length;
	var attributeName = "Active EC";
	if(colMap['columns'][attributeName] == null){
		attributeName = attributeName.replace(' ','');
	}
	var valueIndex = colMap['columns'][attributeName].index
	var level = "";
	if(reqTypesArray.indexOf(rootObjType)==-1){
		level = " and @level!='0'";
	}else{
		
	}
	var objects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[(@filter='false' or @filter='0')" + level + "]");
	var values = [0,0];
	for(var i=0;i<objects.length;i++){
		var object = objects[i];
		var chilNodesSize  = object.childNodes.length;
		var child = emxUICore.selectNodes(object, "c")[valueIndex-1];
		//Chrome
		var attributeValue = child.children;
		if(attributeValue==null){
			attributeValue = child.childNodes;
		}
		var value;
		if(attributeValue == null||attributeValue.length==0){
			value = quickChartFrame.changeValues[0];
			values[0]+=1;
		}else{
			value = quickChartFrame.changeValues[1];
			values[1]+=1;
		}
		object.setAttribute(normalizeChars(attributeName),normalizeChars(value));		
	}
	return values;
}


function refreshECChart(filter){
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var values = getECValues();
	var data = getAjaxRequest(objectId, filter);
	
	chartEC.series[0].setData([{ name: changeValues[0], y : values[0], info : 'No' },
	                				{ name: changeValues[1], y : values[1], info : 'Yes'}]);
	for(var z=0;z<quickChartFrame.changeValues.length;z++) {
		if(values[z]==0){
			quickChartFrame.chartEC.series[0].data[z].setVisible(false);
	}
	
}
	return values;
}

function displayECChart(Filter){
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var colors = generateColourList(changeValues);
	chartEC = new Highcharts.Chart({
		chart: {
			type		: 'pie',
			renderTo	: 'divChartEC',
			marginRight	: 20,
			zoomType	: 'y'
		},
		colors:colors,
		title		: { text		: null  },
		credits 	: { enabled 	: false },
		exporting	: { enabled 	: false },
		legend: {
			enabled 	: true, 
			layout: 'horizontal',
			align: 'center',
	        verticalAlign: 'bottom',
            borderWidth: 1,
            backgroundColor: '#FFFFFF',
            shadow: true,
            y: 10
		},
		plotOptions: {
			pie: {
				dataLabels: { 
					distance	: 5,
					enabled 	: true ,
					format		: '{point.name}: {point.percentage:.1f} %', 
					style		: { fontSize : '10px' }
				},
				point : {
					events:{
						legendItemClick : function() {
							updateTable("Active EC",this.name,!this.visible,chartEC);							
						}
                	}
				}
			},
			series: {
				allowPointSelect: false,
				showInLegend : true,
				cursor:'pointer',
                point: {
                    events: {
                        click: function () {
                        	this.setVisible(false);
                        	return updateTable("Active EC",this.name,false,chartEC);
                        	//return onChartEvent(attributeName,this.series.name,Chart);
                        }
                    }
                }
            }
		},				
		xAxis: {
			categories: [changeValues[0], changeValues[1]],
			title: { text: null }						
		},
		yAxis: {
			alternateGridColor: '#F1F1F1',
			title: { text: null }						
		},
		tooltip: {
			formatter: function() {
				return '<b>'+ this.point.name +'</b>: '+ this.y;
			}
		},					
		series: [{
			name: 'EC',
			data: [null,null]
		}]
	});
	quickChartFrame.chartEC = chartEC;
	chartEC.attributeName = "activeec";
	CHARTS["divChartEC"] = chartEC;
	var values = refreshECChart(Filter);
	updateObjectInFILTERING_OBJECTS_MANAGEMENT("activeec",changeValues,values);
	return chartEC;
}

function refreshResponsabilityChart(objectId, filter){
	var data = getAjaxRequest(objectId, filter);
	values = DesignResponsibilityValues(data[1]);
	ResponsibilityChart.series[0].setData(values,true);
	return ResponsibilityChart;
}


function displayResponsibilityChart(objectId, filter){
	var colors = generateColourList(statusValues);
	ResponsibilityChart = new Highcharts.Chart({
		chart: {
			type			: 'bar',
			renderTo		: 'divChartResponsibility',
			marginTop		: 15,
			marginRight		: 20,
			marginBottom	: 25,
			zoomType		: 'y'
		},
		colors:colors,
		title		: { text		: null  },
		credits 	: { enabled 	: false },
		exporting	: { enabled 	: false },
		legend: {
			enabled 	: true, 
			layout: 'horizontal',
			align: 'center',
	        verticalAlign: 'bottom',
            borderWidth: 1,
            backgroundColor: '#FFFFFF',
            shadow: true,
            y: 10
		},
		plotOptions: {
			bar: {
				dataLabels: { 
					enabled : false,
					color : 'white'
				},
				point : {
					/*events:{ click : function() {clickChart("Responsibility", this.category, this.category, "divFilterResponsibility");}}*/
				}
			},	
			series: {
				groupPadding	: 0,
				stacking 		: 'normal'							
			}
		},				
		xAxis: {
			categories:  aCategoriesResponsibility,
			title: { text: null }
		},
		yAxis: {
			allowDecimals: false,
			alternateGridColor: '#F1F1F1',
			title: { text: null },
			stackLabels: {
				enabled: true
			}					
		},
		tooltip: {
			shared		: true,						
			crosshairs	: true
		},										
		series: [
			{ name : statusValues[0], data: [] },
			{ name : statusValues[1], data: [] },
			{ name : statusValues[2], data: [] },
			{ name : statusValues[3], data: [] },
			{ name : statusValues[4], data: [] }
		]				
	});
	ResponsibilityChart.attributeName = "divChartResponsibility";
	refreshResponsabilityChart(objectId, filter);
	return ResponsibilityChart;
}

function manageRefreshWithValidation(ranges,AttributeName,name,isShown,Chart, objectType){
	if(normalizeChars(name) == ranges[0]||normalizeChars(name) == ranges[1]||normalizeChars(name) == ranges[2]){
		if(isShown==false){
			return updateTable(AttributeName,name,isShown,Chart,null,true);
		}else{
			return updateTable(AttributeName,name,isShown,Chart,null,false);
		}
	} else{
		if((normalizeChars(name) == ranges[3])){
			if(isShown==true){
				return updateTable(AttributeName,name,isShown,Chart,objectType,false);
			}else{
				return updateTable(AttributeName,name,isShown,Chart,objectType,true);
			}
			
		}
	}
}

function refreshValidationChart(filter,ranges,isCurrentChart){
	//var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var objectId = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@level='0']").getAttribute("o");
	var data = getAjaxRequest(objectId, filter);
	var chartValues =null;
	if(data!=null){
		chartValues=  data[1];
	}
	values = getValidationValues(chartValues,isCurrentChart);
	return values;
}

function DisplayValidationChart(objectId, filter){
	var colors = generateColourList(validationValues);
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	chartValidation = new Highcharts.Chart({
		chart: {
			type		: 'pie',
			renderTo	: 'divChartValidation',
			marginRight	: 20,
			zoomType	: 'y'
		},
		colors:colors,
		title		: { text		: null  },
		credits 	: { enabled 	: false },
		exporting	: { enabled 	: false },
		legend: {
			enabled 	: true, 
			layout: 'horizontal',
			align: 'center',
	        verticalAlign: 'bottom',
            borderWidth: 1,
            backgroundColor: '#FFFFFF',
            shadow: true,
            y: 10
		},
		plotOptions: {
			pie: {
				dataLabels: { 
					distance	: 5,
					enabled 	: true ,
					format		: '{point.name}: {point.percentage:.1f} %', 
					style		: { fontSize : '10px' }
				},
				point : {
					events:{
						legendItemClick : function() {
							var show =true;
	                		if(this.visible){
	                			show=false;
	                		}
							return manageRefreshWithValidation(validationValues,"Validation Infos",this.name,show,chartValidation, "Test Case");
							//updateTable("Validation Infos",this.name,!this.visible,chartValidation);							
						}
                	}
				}
			},
			series:{
				allowPointSelect: false,
				showInLegend : true,
				cursor:'pointer',
                point: {
                    events: {
                        click: function () {
                        	this.setVisible(false);
                        	return manageRefreshWithValidation(validationValues,"Validation Infos",this.name,false,chartValidation, "Test Case");
                        	//return updateTable("Validation Infos",this.series.name,false,chartValidation);
                        	//return onChartEvent(attributeName,this.series.name,Chart);
                        }
                    }
                }
			},
		},				
		xAxis: {
			categories: [validationValues[0], validationValues[1], validationValues[2],validationValues[3],validationValues[4]],
			title: { text: null }						
		},
		yAxis: {
			alternateGridColor: '#F1F1F1',
			title: { text: null }						
		},
		tooltip: {
			formatter: function() {
				return '<b>'+ this.point.name +'</b>: '+ this.y;
			}
		},					
		series: [{
			name: 'Validation by Requirement',
			data: [
				{ name: validationValues[0], y : 0, info : 'notvalidated' },
				{ name: validationValues[1], y : 0, info : 'Failed'	 },
				{ name: validationValues[2], y : 0, info : 'Passed'	 },
				{ name: validationValues[3], y : 0, info : 'notReplayed' },
				{ name: validationValues[4], y : 0, info : 'noTestCases' }
			]
		}]
	});	
	quickChartFrame.chartValidation = chartValidation;
	chartValidation.attributeName = "ValidationInfos";
	CHARTS["divChartValidation"] = chartValidation;
	var values = refreshValidationChart(filter);
	updateObjectInFILTERING_OBJECTS_MANAGEMENT("ValidationInfos",validationValues,values);
	for(var z=0;z<quickChartFrame.validationValues.length;z++) {
		quickChartFrame.chartValidation.series[0].data[z].update(values[z],true);
		if(values[z]==0){
			quickChartFrame.chartValidation.series[0].data[z].setVisible(false);
		}
		
	}
	return chartValidation;
}

function refreshTimeLineChart(objectId, filter){
	var data = getAjaxRequest(objectId, filter);
	values = TimeLineValues(data[1]);
	TimeLineChart.xAxis[0].setCategories(values[5],true);
	TimeLineChart.series[0].setData(values[0],false);
	TimeLineChart.series[1].setData(values[1],false);
	TimeLineChart.series[2].setData(values[2],false);
	TimeLineChart.series[3].setData(values[3],false);
	TimeLineChart.series[4].setData(values[4],true);
	return TimeLineChart;
}

function displayTimeLineChart(objectId, filter){
	var colors = generateColourList(statusValues);
	TimeLineChart = new Highcharts.Chart({
		chart: {
			type		: 'column',
			renderTo	: 'divChartTimeline',				
			marginRight	: 20
		},
		colors:colors,
		title		: { text		: null  },
		credits 	: { enabled 	: false },
		exporting	: { enabled 	: false },	
		legend		: { enabled 	: false },	
		xAxis		: {	
			categories:  aCategoriesTimeline,
			labels: {
				rotation: 90,
				y: 25
			}
		},
		yAxis: {
			min: 0,
			title: {
				text: null
			},
			stackLabels: {
				enabled: true
			},
			alternateGridColor	: '#f1f1f1' 
		},				
		tooltip: {
			formatter: function() {
				return '<b>'+ this.x +'</b><br/>'+
					this.series.name +': '+ this.y +'<br/>'+
					'Total: '+ this.point.stackTotal;
			}
		},
		plotOptions: {
			column: {
				stacking: 'normal',
				dataLabels: {
					enabled: true,
					color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
				},
				point : {								
					//events:{ click : function() {clickLink(this.category, null, null, null, 'chartPriority', 'textPriority');}}
				}
			},
			series: {
				groupPadding: 0
			}
		},
		tooltip: {
			shared		: true,						
			crosshairs	: true
		},					
		series: [
			{name : statusValues[0], data: [], info : "Private"	},
			{name : statusValues[1], data: [], info : "InWork"	},
			{name : statusValues[2], data: [], info : "Validate"	},
			{name : statusValues[3], data: [], info : "Frozen"		},
			{name : statusValues[4], data: [], info : "Release"	}
		]
	});
	TimeLineChart.attributeName = "divChartTimeline";
	refreshTimeLineChart(objectId, filter);
	return TimeLineChart;
}

function resizeFrames(){
	var frame = $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document);
	var right = frame.contents().find('#right');
	var footer = frame.contents().find('#divPageFoot');
	var rightHeight = right.height()-footer.height();
	//HAT1 ZUD IR-428176-3DEXPERIENCER2017x     R418: [IPAD Specific] : "Quick Chart" window doesn't shows "close" button.
	//right.css({'height': rightHeight + 'px'}); 
}

function getNbRequirement(){
	var reqTypesArray = getTopWindow().reqTypesArray;
	var objects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r");
	var reqNb = 0;
	for(var i=0; i<objects.length;i++){
		var object = objects[i];
		var type = object.getAttribute('type');
		if(reqTypesArray.indexOf(type)>0){
			reqNb++;
		}
	}
	return reqNb;
}

function getValidationValues(jsonArray){
	var OXMLTypeArg = getTopWindow().OXMLTypeArg;
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var values = new Array(0,0,0,0,0);
	if(jsonArray!=null){
		for(var i = 0;i<jsonArray.length;i++ ){
			var array = jsonArray[i];
			var validationStatus = array['attribute[Validation Status]'];
			var parentReqId = array['from.id[connection]'];
			var objectId = array['id'];
			var visibleObject = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@o='"+parentReqId+"' and (@filter='false' or @filter='0')]");
			if(validationStatus == quickChartFrame.engValidationValues[0]){
				if(visibleObject!=null)
					values[0]+=1;
				validationStatus = quickChartFrame.validationValues[0];
			}else if (validationStatus == quickChartFrame.engValidationValues[1]){
				if(visibleObject!=null)
					values[1]+=1;
				validationStatus = quickChartFrame.validationValues[1];
			}else if(validationStatus == quickChartFrame.engValidationValues[2]){
				if(visibleObject!=null)
					values[2]+=1;
				validationStatus = quickChartFrame.validationValues[2];
			}else if(validationStatus == quickChartFrame.engValidationValues[3]){
				if(visibleObject!=null)
					values[3]+=1;
				validationStatus = quickChartFrame.validationValues[3];
			}
			var object = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@o='"+parentReqId+"']");
			if(object!=null){
				object.setAttribute(normalizeChars(quickChartFrame.chartValidation.attributeName),normalizeChars(validationStatus));
			}
			var TestCase = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@o='"+objectId+"']");
			if(TestCase!=null){
				TestCase.setAttribute(normalizeChars(quickChartFrame.chartValidation.attributeName),normalizeChars(validationStatus));
			}
		}
		var hasNoTestCaseObjects = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[("+OXMLTypeArg+") and (not(@"+normalizeChars(quickChartFrame.chartValidation.attributeName)+") or @"+normalizeChars(quickChartFrame.chartValidation.attributeName)+"='"+normalizeChars(quickChartFrame.validationValues[4])+"') and (@filter='false' or @filter='0')]");
		for(var i=0;i<hasNoTestCaseObjects.length;i++){
			hasNoTestCaseObjects[i].setAttribute(normalizeChars(quickChartFrame.chartValidation.attributeName),normalizeChars(quickChartFrame.validationValues[4]));
			if(hasNoTestCaseObjects[i].getAttribute('filter')=='false'){
				values[4]+=1;
			}
		}
	}
	return values;
}



function TestCaseValues(jsonArray){
	var values = new Array(TestCaseStates.length);
	for(var i = 0;i<TestCaseStates.length;i++ ){
		values[i] = 0;
	}
	for(var i = 0;i<jsonArray.length;i++ ){
		var array = jsonArray[i];
		var state = array['current'];
		values[TestCaseStates.indexOf(state)] += 1;	
	}
	return values;
}

function findObjectInXML(id, key, value){
	var object = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o='"+id+"']");
	for(var i=0;i<object.length;i++){
		object[i].setAttribute(key,value);
	}
}

function ECValues(jsonArray){
	var values = new Array(0,0);
	for(var i = 0;i<jsonArray.length;i++ ){
		var array = jsonArray[i];
		var ecValue = array['to[EC Affected Item]'];
		var id = array['id'];
		if(normalizeChars(ecValue)=="false"){
			values[0]+=1;
			findObjectInXML(id, 'activeec', 'No');
		}else{
			var changes = normalizeChars(array["to[EC Affected Item].from.current"]);
			if(changes != "complete"&&changes != "close"&&changes != "reject"){
				values[1]+=1;
				findObjectInXML(id, 'activeec', 'Yes');
			}else{
				findObjectInXML(id, 'activeec', 'No');
			}
		}
	}
	return values;
}

function DesignResponsibilityValues(jsonArray){
	var values = new Array(0,0,0,0,0);
	for(var i = 0;i<jsonArray.length;i++ ){
		var array = jsonArray[i];
		var DRValue = array['to[Design Responsibility].from.name'];
		if(DRValue == "propose"){ 
			values[0] += 1; 
		}else if(DRValue == 'approve'){ 
			values[1] += 1; 
		}else if(DRValue == 'validate'){ 
			values[2] += 1;
		}else if(DRValue == 'review'){ 
			values[3] += 1; 
		}else if(DRValue == 'release'){ 
			values[4] += 1; 
		}
	}
	return values;
}

function TimeLineValues(jsonArray){
	var JSONObject = jsonArray[0];
	var aDataTimeline0 = JSONObject['Timeline0'];
	var aDataTimeline1 = JSONObject['Timeline1'];
	var aDataTimeline2 = JSONObject['Timeline2'];
	var aDataTimeline3 = JSONObject['Timeline3'];
	var aDataTimeline4 = JSONObject['Timeline4'];
	var aCategoriesTimeline = JSONObject['CategoriesTimeline'].split(",");
	var countTimeline0			= []; 				
	for(
		var i = 0; i < aCategoriesTimeline.length; i++) { 
		countTimeline0[i] = 0; 
		}
	var countTimeline1 			= [];				
	for(var i = 0; i < aCategoriesTimeline.length; i++) { 
		countTimeline1[i] = 0; 
		}
	var countTimeline2 			= [];				
	for(var i = 0; i < aCategoriesTimeline.length; i++) {
		countTimeline2[i] = 0; 
		}
	var countTimeline3 			= [];				
	for(var i = 0; i < aCategoriesTimeline.length; i++) { 
		countTimeline3[i] = 0; 
		}
	var countTimeline4 			= [];				
	for(var i = 0; i < aCategoriesTimeline.length; i++) { 
		countTimeline4[i] = 0; 
		}
	for (var i=0;i<5;i++){
		if(aDataTimeline0[i] != 0) { for(var j = 0; j < aCategoriesTimeline.length; j++) { if(aDataTimeline0[i] <= (j+1)) { if((aDataTimeline1[i] == 0 ) || (j+1 < aDataTimeline1[i])) { countTimeline0[j]++; } } } }
		if(aDataTimeline1[i] != 0) { for(var j = 0; j < aCategoriesTimeline.length; j++) { if(aDataTimeline1[i] <= (j+1)) { if((aDataTimeline2[i] == 0 ) || (j+1 < aDataTimeline2[i])) { countTimeline1[j]++; } } } }
		if(aDataTimeline2[i] != 0) { for(var j = 0; j < aCategoriesTimeline.length; j++) { if(aDataTimeline2[i] <= (j+1)) { if((aDataTimeline3[i] == 0 ) || (j+1 < aDataTimeline3[i])) { countTimeline2[j]++; } } } }
		if(aDataTimeline3[i] != 0) { for(var j = 0; j < aCategoriesTimeline.length; j++) { if(aDataTimeline3[i] <= (j+1)) { if((aDataTimeline4[i] == 0 ) || (j+1 < aDataTimeline4[i])) { countTimeline3[j]++; } } } }
		if(aDataTimeline4[i] != 0) { for(var j = 0; j < aCategoriesTimeline.length; j++) { if(aDataTimeline4[i] <= (j+1)) { countTimeline4[j]++; } } }
		
	}
	var countTimeLineArray =  new Array(0,0,0,0,0,0);
	countTimeLineArray[0] = countTimeline0;
	countTimeLineArray[1] = countTimeline1;
	countTimeLineArray[2] = countTimeline2;
	countTimeLineArray[3] = countTimeline3;
	countTimeLineArray[4] = countTimeline4;
	countTimeLineArray[5] = aCategoriesTimeline;
	return countTimeLineArray;
}




function processValues(isEmpty,Filter,Chart){
	switch(Filter){
		case 'divChartTestCase':
			if(isEmpty){
				chart = displayTestCaseChart(Filter);
			}else{
				
				var values = refreshChart("divChartTestCase", Chart.attributeName);//refreshCustomChart("divChartTestCase",filter);
				updateObjectInFILTERING_OBJECTS_MANAGEMENT(TestCaseAttributeName,TestCasesValues,values);
			}
			
			break;
		case 'divChartValidation':
			if(isEmpty){
				chart =DisplayValidationChart(objectId,Filter);
			}else{
				chart = refreshValidationChart(objectId, Filter);
			}
			
			break;
/*		case 'divChartResponsibility':
			if(isEmpty){
				chart = displayResponsibilityChart(objectId,Filter);
			}else{
				updateObjectInFILTERING_OBJECTS_MANAGEMENT("activeec",changeValues);
				chart = refreshResponsabilityChart(objectId,Filter);
			}
			
			break;
		case 'divChartTimeline':
			if(isEmpty){
				chart = displayTimeLineChart(objectId,Filter);
			}else{
				chart = refreshTimeLineChart(objectId,Filter);
			}
			
			break;*/
		case 'divChartPLMParameter':
			if(isEmpty){
				chart = displayPLMParameterChart(Filter);
			}else{
				
				var values = refreshChart(Filter, Chart.attributeName);
				updateObjectInFILTERING_OBJECTS_MANAGEMENT(ParameterAttributeName,PLMParameterValues,values);
			}
			
			break;
	}
	return Chart;
}



function getDerivedRequirements(attributeName,ranges){
	var rootObjType = getTopWindow().rootObjType;
	var OXMLTypeArg = getTopWindow().OXMLTypeArg;
	var addRootObjOnChart = "";
	if(OXMLTypeArg.indexOf(rootObjType)>=0){
		addRootObjOnChart = " or @level='0' ";
	}
	var objects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+OXMLTypeArg + addRootObjOnChart +"and (@filter='false' or @filter='0')]");
	var values = [0,0];
	//var attributeName;
	for(var i=0;i<objects.length;i++){
		var object = objects[i];
		var attributeValue = null;
		if(attributeName=="CoveredRequirements")
		{
			attributeValue = getAtttributeValueForObjet(object,"RefiningRequirements");//child.textContent;
		}else if(attributeName=="RefiningRequirements")
		{
			attributeValue = getAtttributeValueForObjet(object,"CoveredRequirements");//child.textContent;
		}
		//var attributeValue = getAtttributeValueForObjet(object,attributeName);//child.textContent;
		if(attributeValue==null){
			attributeValue=child.text;
		}
		if(object.getAttribute('type')=='Requirement'){
			if(attributeValue == null||attributeValue.length==0){
				value = ranges[1];
				values[1]+=1;
			}else{
				value = ranges[0];
				values[0]+=1;
			}
			object.setAttribute(normalizeChars(attributeName),normalizeChars(value));
		}
	}
	return [values,true];
}


function getAjaxRequest(objectId, request){;
	var href = '../requirements/emxRMTDashboard.jsp?objectId='+objectId+ '&requestType='+request;
	var result = null;
	$.ajax({
		  url: href,
		  cache: false,
		  async: false,
		  dataType: 'json',
		  success: function(data, status, hxr){
		    result =  data;
		  },
		  error: function(jqXHR, textStatus, errorThrown) {
			console.log(textStatus);
			result = null;
		  }
	});
	return result; 
} 

function createDashboardPanel(url){
	var dashboard = $('#dashBoardSlideIn',findFrame(getTopWindow(),'detailsDisplay').document);
	if(findFrame(getTopWindow(),'detailsDisplay0')!=null){
		$('#dashBoardSlideIn',findFrame(getTopWindow(),'detailsDisplay0').document).remove();
    }
	if(dashboard.length==0||dashboard.css('display')=='none'){
		var slideInHeight = $('#mx_divBody',findFrame(getTopWindow(),'detailsDisplay').document).height();
		//var Height = slideInHeight.toString()+'px';
		var	objElm=null;
		if(dashboard.length){
			objElm = dashboard; 
		} else {
			objElm = jQuery('<div id="dashBoardSlideIn" class="ui-widget-content ui-corner-all ui-resizable" ></div>');
		}
		var panelToggle = $('#panelToggle',getTopWindow().document);
		var className = panelToggle.attr('class');
		var leftPanelWidth=null;
		if(className.contains('closed')){
			leftPanelWidth = 0;
		}else if(className.contains('open')){
			leftPanelWidth = $('#leftPanelMenu',getTopWindow().document).width();
		}
		var PanelTogglelWidth = panelToggle.width();
		var left = getTopWindow().innerWidth /* - leftPanelWidth*/ - PanelTogglelWidth -585;
		objElm.css({'width':'575px'});
	    objElm.css({'height': slideInHeight});
	    objElm.css({'border': '1px solid #aaaaaa'});
	    objElm.css({'position': 'absolute'});
	    objElm.css({'display': 'block'});
	    objElm.css({'left': left.toString() + 'px'});
	 
		var subObj = jQuery('<iframe frameborder="0" name="dashBoardSlideInFrame" id="dashBoardSlideInFrame"></iframe>');
		subObj.css({'width':'100%'});
		subObj.css({'height':'100%'});
		subObj.css({'left':'5px'});
		subObj.css({'top':'0px'});
		subObj.css({'bottom':'0px'});
	    objElm.append(subObj);     
	    var body = $('#bodySBForRMT',findFrame(getTopWindow(),'detailsDisplay').document);
	    body.append(objElm);
	    $('#dashBoardSlideInFrame').css({'top': '30px'});
	    findFrame(getTopWindow(), 'dashBoardSlideInFrame').location.href = url;
		resizeTable();
		$.getScript( "../requirements/scripts/plugins/jquery.ui-RMT.js")  .done(function( script, textStatus ) {
			$('#dashBoardSlideIn',findFrame(getTopWindow(),'detailsDisplay').document).resizable({
		        handles: 'w',
		        minWidth: 50,
		        maxWidth: $('#dashBoardSlideIn',findFrame(getTopWindow(),'detailsDisplay').document).width(),
		        ghost: false,
		        //alsoResize : '#right',
		        helper: 'ui-resizable-helper',
		        
		        start: function( event, ui ) {
		        	$('#dashBoardSlideInFrame').css('pointer-events','none');
		        },
		        stop: function( event, ui ) {  
		        	
		            var newWidth = ui.size.width;
		            var oldWidth = ui.originalSize.width;
		            var diff = oldWidth-newWidth;
		            var bodyWidth = $("#mx_divBody").width();
		            var newSize = bodyWidth+diff;
		            $("#mx_divBody").width(newSize+'px');
		            var frameContent = $('#dashBoardSlideInFrame').contents().find('#right');
		            frameContent.width('600px');
		            //var frameWidth = $('#dashBoardSlideInFrame').width;
		            //$('#dashBoardSlideInFrame').width(frameWidth + diff + 'px');
		            $('#dashBoardSlideInFrame').css({'height': slideInHeight});
		            $('#dashBoardSlideIn').css({'height': slideInHeight});
		            $('#dashBoardSlideInFrame').css('pointer-events','auto');
		            $('#dashBoardSlideIn').width(newWidth+'px');
		        }
	    	});
		});
	}
}

function resetSB(){
	var objects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r");
	for(var i=1;i<objects.length;i++){
		objects[i].setAttribute('filter','false');
	}
	setTimeout(function() {
		getTopWindow().sb.FreezePaneUtils.adjustTableColumns();
		getTopWindow().sb.processRowGroupingToolbarCommand();
        // needs a small timeout for the iPad
        getTopWindow().sb.rebuildView();
    }, 100);
}

function resizeTable() {
	var contentDiv = $('#mx_divBody',findFrame(getTopWindow(),'detailsDisplay').document);
	var slideIn = $('#dashBoardSlideIn',findFrame(getTopWindow(),'detailsDisplay').document);
	contentDiv.width(contentDiv.width() - slideIn.width() + "px");
}
function closePanel() {
	if(findFrame(getTopWindow(),'detailsDisplay')!=null){
		var slideIn = $('#dashBoardSlideIn',findFrame(getTopWindow(),'detailsDisplay').document);
		if(slideIn.length>0){
			var SlideInWidth = slideIn.width();
			slideIn.fadeOut('fast', function() {
				this.children[0].baseURI="../common/emxBlank.jsp";
				this.style["width"]="0px";
				//var windowWidth = getTopWindow().innerWidth;
				var contentDiv = $('#mx_divBody',findFrame(getTopWindow(),'detailsDisplay').document);
				var contentDivWidth = contentDiv.width();
				var newWidth= SlideInWidth +  contentDivWidth;
				contentDiv.width(newWidth + "px");
				slideIn.remove();
				});
			var oXML = findFrame(getTopWindow(), "detailsDisplay").oXML;
			var objects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r");
			FilterReset(objects,false);
			setTimeout(function() {
				getTopWindow().sb.FreezePaneUtils.adjustTableColumns();
				getTopWindow().sb.processRowGroupingToolbarCommand();
				// needs a small timeout for the iPad
				getTopWindow().sb.rebuildView();
			},100);
		}
	}
}

function showPanel() {
	var table = $("#mx_divBody",findFrame(getTopWindow(),"detailsDisplay").document);
	var toolBar = $("#divToolbar",findFrame(getTopWindow(),"detailsDisplay").document);
	table.width("-=550px");
	toolBar.width("-=550px");
	$("#rightSlideIn",getTopWindow().document).width("570px");
	$("#rightSlideIn",getTopWindow().document).fadeIn("0");
}	

function removeFilter(idHeader, idChart, idFilter) {			
	$(idFilter).fadeOut(0);
	$(idFilter).css("visibility", "hidden");
	var visible = $(idChart).is(':visible');
	if(visible == false) {
		$(idHeader).css('border-radius', '4px 4px 4px 4px');
	}				
}

function FilterReset(objects, value){
	for(var i=1;i<objects.length;i++){
		objects[i].setAttribute('filter',value);
	}
}

function getStatusValues(){
	var rootObjType = getTopWindow().rootObjType;
	var OXMLTypeArg = getTopWindow().OXMLTypeArg;
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var addRootObjOnChart = "";
	if(OXMLTypeArg.indexOf(rootObjType)>=0){
		addRootObjOnChart = " or @level='0' ";
	}
	var objects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+OXMLTypeArg+ addRootObjOnChart +" and (@filter='false' or @filter='0')]");
	var StatusIndex = colMap['columns']['Status'].index;
	var values = new Array(0,0,0,0,0);
	for(var i=0;i<objects.length;i++){
		var object = objects[i];
		status = getAtttributeValueForObjet(object,'Status');
		object.setAttribute('status',normalizeChars(status));
		if(normalizeChars(status) == normalizeChars(quickChartFrame.statusValues[0])){ 
			values[0] += 1;
		}else if(normalizeChars(status) == normalizeChars(quickChartFrame.statusValues[1])){ 
			values[1] += 1;
		}else if(normalizeChars(status) == normalizeChars(quickChartFrame.statusValues[2])){ 
			values[2] += 1;
		}else if(normalizeChars(status) == normalizeChars(quickChartFrame.statusValues[3])){ 
			values[3] += 1;
		}else if(normalizeChars(status) == normalizeChars(quickChartFrame.statusValues[4])){ 
			values[4] += 1;
		}
	}
	return values;
}

function getSubRequirementValues(attribute,ranges){
	var reqTypesArray = getTopWindow().reqTypesArray;
	var rootObjType = getTopWindow().rootObjType;
	var OXMLTypeArg = getTopWindow().OXMLTypeArg;
	//check if there are Sub Requirement in the table
	var values = new Array(0,0);
	var allSubReq = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@rel='Sub Requirement']");
	var objects;
	if(reqTypesArray!=null&&reqTypesArray.indexOf(rootObjType)!=-1){
		objects = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@level='0']");
	}else{
		objects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+OXMLTypeArg+" and @rel='Specification Structure' and (@filter='false' or @filter='0')]");
	}
	allSubReq.length = 0;
	if(allSubReq.length>0){		
		//get all Requirement
		var colSize = colMap['columns'].length;			
		for(var i = 0;i<objects.length;i++){
			var object = objects[i];
			var children;
			if(object.children==null){
				
				children = object.childNodes;
			}else{
				children = object.children;
			}
			var nbChildren = children.length-colSize;
			if(hasSubReq(children,nbChildren)==true){
				values[0]+=1;
				object.setAttribute(normalizeChars(attribute),normalizeChars(ranges[0]));
			}else{
				values[1]+=1;
				object.setAttribute(normalizeChars(attribute),normalizeChars(ranges[1]));
			}
		}
		var subObjects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+OXMLTypeArg+" and @rel='Sub Requirement' and (@filter='false' or @filter='0')]");
		for(var i = 0;i<subObjects.length;i++){
			subObjects[i].setAttribute(normalizeChars(attribute),normalizeChars(ranges[0]));
		}
		
	}else{
		var reqObjects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+OXMLTypeArg+" and @rel!='Sub Requirement' and  @rel!='Derived Requirement']");
		//ajax Request 
		var idList = "";
		for(var i = 0;i<reqObjects.length;i++){
			var id = reqObjects[i].getAttribute("o");
			idList+=id;
			if(i!=reqObjects.length-1){
				idList+=",";
			}
		}
		if(idList!=null&&idList.length>0){
			ajaxValues = getAjaxRequest(idList, "subRequirements");
			var keys = Object.keys(ajaxValues[1]);
			for(var i=0;i<keys.length;i++){
				var key = keys[i];
				var subReqValue = ajaxValues[1][key];
				var object = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o='"+key+"']");
				object.setAttribute(normalizeChars(attribute),normalizeChars(subReqValue));
				if(object.getAttribute("filter")=='false'||object.getAttribute("filter")=='0'){
					//shown objects
					if(normalizeChars(ranges[0])==normalizeChars(subReqValue)){
						values[0]+=1;
					}else{
						values[1]+=1;
					}
					
				}
			}
		}
	}
	return [values,updateTable];
}

function hideChart(idHeader, idChart){
	$(idHeader).css('border-radius', '4px 4px 4px 4px');
	$(idChart).fadeOut(10);
}


function toggleChartFilter(idHeader, idChart, chart, idFilter,objectId,colours) {
	var visibleChart	= $(idChart).is(':visible');	
	var visibleFilter 	= $(idFilter).css('visibility');	
	//var chart=null;
	$(idHeader).toggleClass("expanded");
	if(visibleChart) {
		if(visibleFilter == "visible") {
			$(idFilter).css('border-bottom', '1px solid #5f747d'); 
			$(idHeader).css('border-radius', '4px 4px 0px 0px');
		} else {
			$(idHeader).css('border-radius', '4px 4px 4px 4px');
		}
		$(idChart).fadeOut(160);
		var Attribute = normalizeChars($(idHeader)[0].innerText);
		delete FILTERING_OBJECTS_MANAGEMENT[Attribute];
		/*refreshViewHide(false,chart.attributeName);
		refreshQuickCharts();*/
	} else {
		var isEmpty=false;
		$(idHeader).css('border-radius', '4px 4px 0px 0px');
		$(idChart).fadeIn(160);
		$(idFilter).css('border-bottom', 'none');
		if($(idChart)[0].innerHTML.length==0){
			isEmpty = true;
		}		
		switch (idFilter.id) {
		case 'divFilterStatus':
			if(isEmpty){
				/*chart = */displayStatusChart(colours);
			}else{
				/*chart = */refreshStatusChart();
			}
			break;
		case 'divFilterEC':
			if(isEmpty){
				/*chart = */displayECChart(/*Filter*/);
			}else{
				/*chart = */refreshECChart(/*Filter*/);
			}
			break;
		default:
			chart = processValues(isEmpty, idChart.id,chart);
		}
		CHARTS[idChart.id].setSize($(idChart).width(),$(idChart).height(), false);
		//chart.setSize($(idChart).width(),$(idChart).height(), false);
	}    
}

function unFilterParent(objects, parentId, currentId,objectList){
	var i = currentId;
	var isParentFound = false;
	while(isParentFound==false&&i>=1){
		var object = objects[i].getAttribute('o');
		if(object == parentId){
			if(objectList.indexOf(object)==-1){
				objectList.push(objects[i].getAttribute("o"));
			}
			var parent = objects[i].getAttribute('p');
			unFilterParent(objects, parent, i-1,objectList);	
		}
		i--;
	}
}

function hasChildrenToDisplay(object, attributeName, filteredValue){
	//var currentIndex = i;
	//var hasChildrenObject = false;
	//var attributeValue = null;
	//var quit = false;
	//var objectId = object.getAttribute('o');
	var hasDiplayedChildren = false;
	var colIndex;
	if(attributeName == 'SubRequirement'){
		colIndex = colMap['columns']['Status'].index;
	}else{
		colIndex = colMap['columns'][attributeName].index;
	}
	var childList = emxUICore.selectNodes(object, "r");
	if(childList.length >0){
		for(var i=0;i<childList.length;i++){
			var child = childList[i];
			var attributeValue = emxUICore.selectNodes(child, "c")[colIndex-1].textContent;
			if(attributeValue!=filteredValue){
				hasDiplayedChildren = true;
			}
			if(hasDiplayedChildren == false){
				hasDiplayedChildren = hasChildrenToDisplay(child, attributeName, filteredValue);
			}
			
		}
	}
	return hasDiplayedChildren;
}

function hasSubReq(children,nbChildren){
	var reqTypesArray = getTopWindow().reqTypesArray;
	for(var i=0;i<nbChildren;i++){
		var child = children[i]; 
		var childType = child.getAttribute('type');
		var childRel = child.getAttribute('rel');
		if(reqTypesArray.indexOf(childType)>0&&childRel == 'Sub Requirement'){
			return true;
		}
	}
	return false;
}

function isEmptyObject( obj ) {
    for ( var name in obj ) {
    	if (obj.hasOwnProperty(name)) {
            return false;
         }
    }
    return true;
}
function isChildrenDisplayed(childrenList){
	for(var i=0;i<childrenList.length;i++){
		var child = childrenList[i];
		var filter = child.getAttribute("filter");
		if(filter == 'false'){
			return true;
		}
	}
	return false;
}

function hideUnWantedParents(type,value){
	var reqObjects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@filter='false' or @filter='0']");
	for(var i=1;i<reqObjects.length;i++){
		var object = reqObjects[i];
		var Chilren = object.getElementsByTagName('r');
		objectId = object.getAttribute('o');
		if(isChildrenDisplayed(Chilren)==false&&isEmptyObject(displayedObjects[objectId])){
			delete displayedObjects[objectId];
			hiddenObjects.push(objectId);
			object.setAttribute('filter','true');
		}
	}
	
}

function functionCreateRequest(hide,key,excludedType,showType){
	var finalRequest = "";
	var ExludedRequest = "(";
	var Request= "";
	for(var i=0;i<excludedObjects.length;i++){
		if(i!=0){
			ExludedRequest+=" and ";
		}
		ExludedRequest += "@type!='"+excludedObjects[i]+"'";
	}
	//ExludedRequest += " and @type='PlmParameter' and @type='Test Case' ";
	key = normalizeChars(key);
	var keyArray = FILTERING_OBJECTS_MANAGEMENT[key];
	if(keyArray!=null){
		if(hide==true){
			//Request +="(";
			for(var j=0;j<keyArray.length;j++){
				if(j>0){
					Request +=" and ";
				}
				Request += "@"+key+"!='"+keyArray[j]+"'";
			}
			if(keyArray.length>0){
				Request += " and ";
			}
			Request += " (@filter='false' or @filter='0')";
			Request += " or not(@"+key+"))";
		}else{
			//show
			
			for(var j=0;j<keyArray.length;j++){
				if(Request.length>0){
					Request +=" or ";
				}else{
					Request +="(";
				}
				Request += "@"+key+"='"+keyArray[j]+"'";
			}
			Request += ")";
			Request += " and @level!=0  and (@filter='true' or @filter='1'))"; 
			//Request += " or not(@"+key+")";;
		}
	}else{
		ExludedRequest+=")";
	}
	if(ExludedRequest.length>0){
		if(Request.length>0){
			finalRequest = ExludedRequest +" and "+Request;
		}else{
			finalRequest = ExludedRequest;
		}
	}else{
		finalRequest = Request;
	}
	if(excludedType!=null){		
		if(showType==true){
			if(hide==true){
				finalRequest+= " and @type!='"+excludedType+"'";
			}else{
				finalRequest+= " or @type='"+excludedType+"'";
			}
		}else{
			if(hide==true){
				finalRequest+= " or @type='"+excludedType+"'";
			}else{
				finalRequest+= " or @type!='"+excludedType+"'";
			}
		}
	}
	return finalRequest+ " and @level!=0";
}

function unFilterObjectWithDisplayedChildren(modifiedRows){
	var hiddenObjects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@filter='true' or @filter='1']");	
	for(var i=0;i<hiddenObjects.length;i++){
		var hasDisplayedChildren = false;
		var objects = hiddenObjects[i].getElementsByTagName("r");
		for(var j=0;j<objects.length;j++){
			if(objects[j].getAttribute('filter')=='false'){
				hasDisplayedChildren = true;
			}
		}
		if(hasDisplayedChildren == true){
			hiddenObjects[i].setAttribute('filter','false');
			var index = modifiedRows.indexOf(hiddenObjects[i].getAttribute('id'));
			if(index!=-1){
				modifiedRows.splice(index,1);
			}
		}
	}
}

function unFilterParents(object, modifiedRows){
	if(object.parentNode !=null){
		var value = object.parentNode.getAttribute('filter');
		if(value != null){
			if(value == 'true'){
				object.parentNode.setAttribute('filter','false');
				if(modifiedRows!=null){
					modifiedRows.push(object.parentNode.getAttribute('id'));
				}
			}
			unFilterParents(object.parentNode);
		}
	}
	
}

function updateRows(ids){
	if(ids.length>0){
		getTopWindow().sb.emxEditableTable.refreshSelectedRows(ids);
	}
	
}

function refreshViewHide(hide,type, inludeType,showType){
	//true, hide object
	//else show
	var modifiedRows = [];
	var isTablemodified = false;
	if(Object.keys(FILTERING_OBJECTS_MANAGEMENT).length==0){
		hide = false;
	}
	if(hide ==true){
		var request = functionCreateRequest(true,type,inludeType,showType);
		var objectsToHide = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+request+"]");		
		for(var i=0;i<objectsToHide.length;i++){
			var node = objectsToHide[i];
			node.setAttribute('filter','true');
			modifiedRows.push(node.getAttribute('id'));
			isTablemodified = true;
		}
		unFilterObjectWithDisplayedChildren(modifiedRows);
	}else{
		var request = functionCreateRequest(false,type,inludeType,showType);
		var objectsToShow = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+request+"]");		
		for(var i=0;i<objectsToShow.length;i++){
			isTablemodified = true;
			var node = objectsToShow[i];
			if(node.getAttribute('filter')=='true'){
				var parent = node.parentNode;
				if(parent!=null){
					var isNotParentExpanded = parent.getAttribute('display')=='block'?'false':'true';
					node.setAttribute('filter',isNotParentExpanded);	
					modifiedRows.push(node.getAttribute('id'));
					if(isNotParentExpanded == 'false'){
						unFilterParents(node, modifiedRows);
					}
				}		
			}
		}
	}
	updateRows(modifiedRows);
	return isTablemodified;
}

function displayReqSummary(){
	var OXMLTypeArg = getTopWindow().OXMLTypeArg;
	var jQueryFrame = $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document);
	var quickChartFrame =  jQueryFrame[0];
	$('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document).contents().find('#divPageFoot');
	var nbReqs = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+OXMLTypeArg+"]").length;
	var bottomText=null;
	var nbFilteredReqs = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+OXMLTypeArg+" and (@filter='false' or @filter='0')]").length;
	if(nbReqs==nbFilteredReqs){
		bottomText = quickChartFrame.allReqs;
	}else{
		var summaryString = quickChartFrame.summaryReqs;
		bottomText = summaryString.replace("$<0>",nbFilteredReqs).replace("$<1>",nbReqs);
	}
	jQueryFrame.contents().find('#divDialogButtons').find('.nbRequirements').text(bottomText);
}







function updateTable(type, value, isChecked,chart,inludeTypeObject,showtype) {
	
	var isTableModified = false;
	var noSpaceType = normalizeChars(type);
	value = normalizeChars(value);
	if(isChecked == false){
		var index = FILTERING_OBJECTS_MANAGEMENT[noSpaceType].find(value);
		if(index>=0){
			FILTERING_OBJECTS_MANAGEMENT[noSpaceType].splice(index,1);
		}
		isTableModified = refreshViewHide(true,noSpaceType,inludeTypeObject,showtype);
/*		if(!isTableModified){
			if(FILTERING_OBJECTS_MANAGEMENT[noSpaceType].find(value)==-1){
				FILTERING_OBJECTS_MANAGEMENT[noSpaceType].push(value);
			}
		}*/
	}else{
		if(FILTERING_OBJECTS_MANAGEMENT[noSpaceType].find(value)==-1){
			FILTERING_OBJECTS_MANAGEMENT[noSpaceType].push(value);
		}
		isTableModified = refreshViewHide(false,type,inludeTypeObject,showtype);
	}
	keys = Object.keys(CHARTS);
	
	for(var i=0;i<keys.length;i++){
		var key = keys[i];
		var isPieChart=CHARTS[key].options["chart"].type=="pie"?true:false;
		if(key!=chart.renderTo.id){
			refreshChart(CHARTS[key].renderTo.id,CHARTS[key].attributeName.replace(/ /g,""),isPieChart,false);
		}else{
			refreshChart(CHARTS[key].renderTo.id,CHARTS[key].attributeName.replace(/ /g,""),isPieChart,true);
		}
	}
	displayReqSummary();
	//return isTableModified;
	return true;
}	

function clickChart(type, value, isChecked) {
	if(type == "EC") {
		updateTable(type,value,isChecked);
	}					

	if(type == "Responsibility") {
		filterResponsibility = aCategoriesResponsibility.indexOf(value);					
	}

	if(type == "Validation by Requirement") {
		if(value == "Pending") 		{ filterValidation = "1"; }
		else if(value == "Failed") 	{ filterValidation = "2"; }
		else if(value == "Passed")	{ filterValidation = "3"; }					
	}		
}

function getAtttributeValueForObjet(object,attributeName){
	var returnedArray = new Array();
	var childrenLengtgh = object.childNodes.length;
	var valueIndex = colMap['columns'][attributeName].index;
	for(var i=0;i<childrenLengtgh;i++){
		var child = object.childNodes[i];
		var tagName = object.childNodes[i].tagName;
		if(tagName == "c"){
			returnedArray.push(child);
		}
	}
	var attributeValue = returnedArray[valueIndex-1].textContent;
	if(attributeValue == null){
		attributeValue = returnedArray[valueIndex-1].text;
	}
	return attributeValue;
}


function getValues(attributeName){
	var OXMLTypeArg = getTopWindow().OXMLTypeArg;
	var colMapSize = colMap.columns.length;
	var objects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r["+OXMLTypeArg+"]");
	var ranges = Object.keys(colMap['columns'][attributeName].rangeValues);
	var values = new Array(ranges.length);
		for(var i=0;i<ranges.length;i++){
		values[i] = 0;
	}
	for(var i=0;i<objects.length;i++){
		var object = objects[i];
		var attributeValue = getAtttributeValueForObjet(object,attributeName);
		for(var j=0;j<ranges.length;j++){
			var range = normalizeChars(ranges[j]);
			if(normalizeChars(attributeValue)==range ){
				object.setAttribute(normalizeChars(attributeName),normalizeChars(attributeValue));
				if(object.getAttribute('filter')!="true"){
					values[j] += 1;
				}
			}
		}
	}
	return [values,true];
}




function refreshChart(idChart, attributeName,isPieChart,isCurrentChart){
	var quickChartFrame =  $('#dashBoardSlideInFrame',findFrame(getTopWindow(),'detailsDisplay').document)[0];
	var ranges = null;
	var values = null;
	var Chart=null;
	var chartValues=null;
	if(attributeName=="SubRequirement"){
		ranges = quickChartFrame.subValues;
		values = getSubRequirementValues(attributeName,ranges);	
		chartValues = values[0];
		updateObjectInFILTERING_OBJECTS_MANAGEMENT(attributeName,ranges,chartValues,isCurrentChart);
	}else if(attributeName=="CoveredRequirements"||attributeName=="RefiningRequirements"){
		ranges = attributeName=="CoveredRequirements"?quickChartFrame.coveredValues:quickChartFrame.refinedValues;
		values = getDerivedRequirements(attributeName,ranges);
		chartValues = values[0];
		updateObjectInFILTERING_OBJECTS_MANAGEMENT(attributeName,ranges,chartValues,isCurrentChart);
	}else if(attributeName=="activeec"){
		ranges=quickChartFrame.changeValues;
		chartValues = getECValues();
		updateObjectInFILTERING_OBJECTS_MANAGEMENT(attributeName,ranges,chartValues,isCurrentChart);
	}else if(attributeName!=null){
		if(colMap['columns'][attributeName]!=null&&attributeName!='Status'){
			ranges = Object.keys(colMap['columns'][attributeName].rangeValues);
			values = getValues(attributeName);
			chartValues = values[0];
			updateObjectInFILTERING_OBJECTS_MANAGEMENT(attributeName,ranges,chartValues,isCurrentChart);
		}else{
			if(idChart == "divChartStatus"){
				ranges = quickChartFrame.statusValues;
				chartValues = refreshStatusChart(ranges,isCurrentChart);
			}else if(idChart == "divChartPLMParameter"){
				ranges = quickChartFrame.PLMParameterValues;
				chartValues = refreshPLMParameterChart( idChart,ranges,isCurrentChart);
			}else if(idChart == "divChartTestCase"){
				ranges = quickChartFrame.TestCasesValues;
				chartValues = refreshTestCaseChart( idChart,ranges,isCurrentChart);
			}else if(idChart == "divChartValidation"){
				ranges = quickChartFrame.validationValues;
				chartValues = refreshValidationChart( idChart,ranges,isCurrentChart,isCurrentChart);
			}
		}		
	}
	//if(idChart != "divChartStatus"&&idChart != "divChartPLMParameter"&&idChart != "divChartTestCase"&&idChart != "divChartValidation"){
		for(var i=0;i<quickChartFrame.Highcharts.charts.length;i++){
			var divChart = quickChartFrame.Highcharts.charts[i];
			if(divChart.renderTo.id == idChart){
				Chart = quickChartFrame.Highcharts.charts[i];	
			}
		}
		isPieChart = Chart.options["chart"].type=="pie"?true:false;;
		if(isPieChart==null||isPieChart==false){
			//barChart
			if(ranges!=null){
				for (var i=0;i<ranges.length;i++){
					Chart.series[i].data[0].update(chartValues[i],true);
					if(isCurrentChart==null||isCurrentChart==false){
						//force refresh if it's not the current chart
						if(chartValues[i]==0){
							Chart.series[i].hide();
						}else{
							Chart.series[i].show();
						}
					}
					//Chart.series[i].show();
					//Chart.series[i].setData(chartValues[i]);
				}
			}	
		}else{
			for(var z=0;z<chartValues.length;z++) {
				Chart.series[0].data[z].update(chartValues[z],true);
				if(isCurrentChart==null||isCurrentChart==false){
					if(chartValues[z]==0){
						Chart.series[0].data[z].setVisible(false);
					}else{
						Chart.series[0].data[z].setVisible(true);
					}
				}
				//Chart.series[0].data[z].setVisible(true);
			}
		}
		quickChartFrame.CHARTS[idChart] = Chart;
	//}
	
/*	if(attributeName!=null){
		if(ranges == null){
			ranges = Chart.xAxis[0].categories;
		}
		updateObjectInFILTERING_OBJECTS_MANAGEMENT(attributeName,ranges);
	}*/
	return chartValues;
}


function manageRefreshWithObjectType(ranges,AttributeName,name,isShown,Chart, objectType){
	if(normalizeChars(name) == ranges[0]){
		if(isShown==false){
			return updateTable(AttributeName,name,isShown,Chart,objectType,false);
		}else{
			return updateTable(AttributeName,name,isShown,Chart,objectType,true);
		}
	} else{
		if((normalizeChars(name) == ranges[1])){
			if(isShown==false){
				return updateTable(AttributeName,name,isShown,Chart,objectType,true);
			}else{
				return updateTable(AttributeName,name,isShown,Chart,objectType,false);
			}
			
		}
	}
}

function refreshQuickCharts(){
	if(getTopWindow().myCharts != null)
	{
		var myCharts = getTopWindow().myCharts;
		keys = Object.keys(myCharts);
		
		for(var i=0;i<keys.length;i++){
			var key = keys[i];
				var isPieChart=myCharts[key].options["chart"].type=="pie"?true:false;
				refreshChart(myCharts[key].renderTo.id,myCharts[key].attributeName.replace(/ /g,""),isPieChart);
	
		}
		displayReqSummary();
	}
}

//START : LX6 IR-348544-3DEXPERIENCER2016x
function beforeDrawCompleteTree(aRows, oLocalXML){
	if (aRows != null) {
		//objects to update as some information are missing
        aRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[(not(@type) or not(@rel)) and @level!='0']");     
    }
	if(aRow!=null){
		var id = aRow.getAttribute("o");
		var pId = aRow.getAttribute("p");
		var href = '../requirements/emxRMTDashboard.jsp?requestType=getAttributeMissingValues&ids='+id.toString()+"&pIds="+pId.toString();
		var result = null;
		$.ajax({
			  url: href,
			  cache: false,
			  async: false,
			  dataType: 'html',
			  success: function(data, status, hxr){
			    result =  data.replace(/[\[\]']+/g,"").split(':');		
			    aRow.setAttribute('type',result[0]);
			    aRow.setAttribute('rel',result[1]);
			    
			  },
			  error: function(jqXHR, textStatus, errorThrown) {
				console.log(textStatus);
				result = null;
			  }
		});
	}
	
	return true;
}
//END : LX6 IR-348544-3DEXPERIENCER2016x


if(localStorage['debug.AMD']) {
	console.info("AMD: ENORMTCustoSB/panelRightContext.js global finish.");
}

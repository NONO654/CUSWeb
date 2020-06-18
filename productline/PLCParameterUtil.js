//=================================================================
// JavaScript PLCParameterUtil.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
/* Contains code for the HighChart for parameter under test case */
/*						mm:dd:yyyy
* @quickreview KIE1 ZUD 01:22:2016  : HL ENOVIA GOV RMT Parameter under Test Execution.
* @quickreview KIE1	  16:08:24 : IR-459152-3DEXPERIENCER2017x:R419-FUN055836:NLS: In Parameters under Test Executions, high chart labels are not getting translated.
*/

function getHighChart(textExecutions, aggregatedParameter,targetParameter, maxParameter,minParameter, paramName, unit, propertiesVariables)
{
	var splitVariable = propertiesVariables.split(",");
	jDialogForParameterValues(textExecutions, aggregatedParameter,targetParameter, maxParameter,minParameter, paramName, unit, splitVariable);
}

var Chart;
function jDialogForParameterValues(textExecutions, aggregatedParameter, targetParameter,maxParameter,minParameter, paramName, unit, splitVariable)
{
		Chart = new Highcharts.Chart({
		chart: {
			renderTo        : 'divChartStatus',   
			type			: 'line',
			reflow			: false,
			width			: 830,
			height			: 480
		},
		title		: { text		: paramName  },
		credits 	: { enabled 	: false },
		exporting	: { enabled 	: false },
		legend		: { enabled 	: false },
		tooltip		: { enabled 	: true	},
		
		legend: {
			 align: 'center',
	         verticalAlign: 'bottom',
             borderWidth: 1,
             backgroundColor: '#FFFFFF',
             shadow: true,
             y: 10
        },
		xAxis: {
			categories: textExecutions,
			title: {
    			text: null
			}
		},
		yAxis: {
			allowDecimals: false,
			title: { text: splitVariable[0]+ " ( "+unit+" )"}
		},
		 series: [{
			    name:splitVariable[0],
	            data: aggregatedParameter
	        	},
	        	{
			        name:splitVariable[3],
			        data:targetParameter
			    },
	        	{
		        	name:splitVariable[2],
		        	data: minParameter
	        	},
	        	{
		        name:splitVariable[1],
		        data:maxParameter
		        }
	        ]
	});
	Chart.attributeName = paramName;
	$('#divChartStatus').Chart;
}

$(window).resize(function() {
    clearTimeout(this.id);
    this.id = setTimeout(doneResizing, 0);
});

function doneResizing(){
	Chart.setSize(window.innerWidth, window.innerHeight, doAnimation = true);
}

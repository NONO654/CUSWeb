define(
	'DS/ENXDataGrid/ENXSBGridPerformanceLogs',
	
	['DS/Windows/Dialog', 'DS/Controls/Button', 'DS/Windows/ImmersiveFrame'],
	
	function(WUXDialog, WUXButton, WUXImmersiveFrame) {
		var ENXSBGridPerformanceLogs = {
			getLogs: function() {
				var immersiveFrame = new WUXImmersiveFrame().inject(document.body);
				
				var textContent = '';
				
				if(typeof performanceLogs['serverLogs'] != 'undefined' && typeof performanceLogs['clientLogs'] != 'undefined') {
					var generateColumnDetails, executeJPOs, generateObjectSelects, generateObjectIds, generateColValues;
					
					performanceLogs['serverLogs'].forEach(function(dataobject) {
																	if('generateColumnDetails' == dataobject.id) {
																		generateColumnDetails = dataobject;
																	} else if('executeJPOs' == dataobject.id) {
																		executeJPOs = dataobject;
																	} else if('generateObjectSelects' == dataobject.id) {
																		generateObjectSelects = dataobject;
																	} else if('generateObjectIds' == dataobject.id) {
																		generateObjectIds = dataobject;
																	} else if('generateColumnValues' == dataobject.id) {
																		generateColValues = dataobject;
																	}
																});
					
					var noOfRows = Number(generateObjectIds.dataelements['noOfRows']);
					var noOfColumns = Number(generateColumnDetails.dataelements['noOfExpCols']) + Number(generateColumnDetails.dataelements['noOfProgCols']) + Number(generateColumnDetails.dataelements['noOfIconCols']);
					var totalTime = Number(performanceLogs['totalTime']);
					var serverTime = Number(performanceLogs['dataServerTime']);
					var clientTime = Number(performanceLogs['clientLogs']['connectorGridTime']) + Number(performanceLogs['clientLogs']['renderGridTime']);
					
					if(typeof generateColumnDetails != 'undefined' && typeof generateObjectIds != 'undefined' && typeof generateObjectSelects != 'undefined' && typeof executeJPOs != 'undefined') {
						textContent += 'Number of rows: ' + noOfRows + '<br />';
						textContent += 'Number of columns: ' + noOfColumns + '<br /><br />';
						
						if(typeof performanceLogs['totalTime'] != 'undefined') {
							textContent += '<b>Total time taken to load: ' + totalTime + '</b> (Server side: ' + serverTime + ', Client side: ' + clientTime.toFixed(2) + ')<br />';
							textContent += '<br />';
						}
						
						textContent += '<b><u>Server side logs</u></b><br /><br />';
						
						textContent += 'Table Name: ' + generateColumnDetails.dataelements['tableName'] + '<br />';
						textContent += 'Number of expression columns: ' + generateColumnDetails.dataelements['noOfExpCols'] + '<br />';
						textContent += 'Number of program columns: ' + generateColumnDetails.dataelements['noOfProgCols'] + '<br />';
						textContent += 'Number of icon columns: ' + generateColumnDetails.dataelements['noOfIconCols'] + '<br />';
						textContent += 'Time taken to generate column details: ' + generateColumnDetails.dataelements['time'] + '<br /><br />';
						
						textContent += 'Table program class: ' + generateObjectIds.dataelements['progClass'] + '<br />';
						textContent += 'Table progam method: ' + generateObjectIds.dataelements['progMethod'] + '<br />';
						if('undefined' != typeof generateObjectIds.dataelements['expandLevel'] && null != generateObjectIds.dataelements['expandLevel']) {
							textContent += 'Expand Level for this view: ' + generateObjectIds.dataelements['expandLevel'] + '<br />';
						}
						textContent += 'Time taken to run the above program: ' + generateObjectIds.dataelements['time'] + '<br /><br />';
						
						textContent += 'List of select expressions: ' + generateObjectSelects.dataelements['exp'] + '<br />';
						textContent += 'Time taken to retrieve values of these expressions: ' + generateObjectSelects.dataelements['time'] + '<br /><br />';
						
						for(var jpoName in executeJPOs.dataelements) {
							textContent += 'Time taken to run \'' + jpoName.split(':')[1] + '\' method of \'' + jpoName.split(':')[0] + '\' class: ' + executeJPOs.dataelements[jpoName] + '<br />';
						}
						
						textContent += '<br />Total time taken to generate column values: ' + generateColValues.dataelements['time'] + '<br /><br />';
						
						textContent += '<b><u>Client side logs</u></b><br /><br />';
						for(var logType in performanceLogs['clientLogs']) {
							textContent += logType + ': ' + this.roundNumber(performanceLogs['clientLogs'][logType], 2) + '<br />';
						}
						textContent += '<br />';
					}
				}
				
				var logsDialog = new WUXDialog({
					title: 'Data Grid performance diagnostics',
					header: '<h4>Data Grid performance diagnostics <span style=\'color:blue\'>(unit of measurement - ms)</span></h4>',
					content: textContent,
					immersiveFrame: immersiveFrame,
					modalFlag: true,
					buttons: {
						Cancel: new WUXButton({
							onClick: function(e) {
								var button = e.dsModel;
								var myDialog = button.dialog;
								myDialog.close();
							}
						})
					}
				});
			},
			roundNumber: function(val, dec) {
				return Number(Number(val).toFixed(dec));
			}
		};
		
		return ENXSBGridPerformanceLogs;
	}
);

define('DS/SMAExeLicUsage/LicenseInfoQueryDialog',
    ['DS/WebappsUtils/WebappsUtils',
     'UWA/Core',
     'UWA/Controls/Abstract',
     'DS/SMAExeJsAPI/CosAPI',
     'DS/W3DXComponents/Views/GraphView',
	 'DS/Controls/DatePicker',
	 'DS/Controls/ButtonGroup',
	 'DS/Controls/Button',
     'DS/Windows/Dialog',
     'DS/UIKIT/Modal',
	 'DS/Windows/ImmersiveFrame',
	 'i18n!DS/SMAExeLicUsage/assets/nls/SMAExeLicUsage'
    ],
     function (
    	WebappsUtils, UWA, Abstract,
    	CosAPI,
    	GraphView, WUXDatePicker, WUXButtonGroup, WUXButton, WUXDialog, UIModal, WUXImmersiveFrame, NLS)
    {

         'use strict';
      	var modal = {};
     	//var theGraph = null;
     	//var theGraph2 = null;
    	var userTable = null;
    	var jobTable = null;
    	var immersiveLicFrame = null;
     	var myContainer = null;
     	var myErrFunc = null;
     	var myAppsUrl = null;
     	var myWid = null;
     	var myTGC = null;
     	var licOuterDiv = null;
     	var licUserDiv = null;
     	var licJobDiv = null;

     	// create dialog with tables showing credit/token consumption
        var LicenseInfoQueryDialog = {
                userMap:new Map(),
                jobMap:new Map(),
                userJobList:[],
                jobJobList : [],
                licMinDate : null,
             	licMaxDate : null,
             	doDownload : false,

             	//helper function that converts milliseconds into hours,minutes, and seconds
                calculateDuration: function (ms) {
                	var  h, m, s;
                	h = Math.floor(ms / 1000 / 60 / 60);
                	ms -= h * 1000 * 60 * 60;
                	m = Math.floor(ms / 1000 / 60);
                	ms -= m * 1000 * 60;
                	s = Math.floor(ms / 1000);
                	ms -= s * 1000;
                	return {  h: h, m: m, s: s };
                },
           		// helper function to add credit/token info  to a map
                // if the entry does not exist create an entry in the map
                // otherwise add credit/token consumption info to the existing entry in the map
                // used to process both user and job credit info
                processMap:function(info, map, key, jobList) {
            		var tokens = info.totalTokens;
            		if (tokens ===undefined ) {
            			tokens = 0;
            		}
            		var hwCrd = info.totalHWCredits;
            		if (hwCrd ===undefined) {
            			hwCrd = 0;
            		}
            		var swCrd = info.totalSWCredits;
            		if (swCrd ===undefined) {
            			swCrd = 0;
            		}

            		var hwRate = info.rateHW;
            		if (hwRate ===undefined) {
            			hwRate = 0;
            		}
            		var swRate = info.rateSW;
            		if (swRate ===undefined) {
            			swRate = 0;
            		}

            		// set either cloud, premise, or embedded duration based on following rules:
            		// If Hardware Credit Rate is > 0 the job was run on the Cloud
            		// If Hardware Credit Rate = 0 the job was run on Premise
            		// If Token == -1 and Software Credit Rate > 0 then job used Software Credits
            		// If Token == -1 and Software Credit Rate == 0 then job used Embedded Compute

            		var cDuration = 0;
            		var pDuration = 0;
            		var eDuration = 0;

            		if (tokens===1 && swRate ===0) {
            			eDuration = info.duration;
            			tokens =0;
            		}
            		else {
	            		if (hwRate > 0) {
	            			cDuration = info.duration;
	            		}
	            		if (hwRate ===0) {
	            			pDuration = info.duration;
	            		}
            		}

            		// don't add in negative token amounts
            		if (tokens===-1) {
            			tokens =0;
            		}

            		// calculate unique rows by job id so check if we have already counted the given job
            		var num=1;
            		if (info.jobId !== undefined &&  info.jobId !== null && info.jobId.length > 0){
            			if (jobList.indexOf(info.jobId) >= 0 ) {
            				num = 0;
            			}
            			else {
            				jobList.push(info.jobId);
            			}
            		}

            		// either create new entry or add to existing entry
            		var userData = map.get(key);
            		if (userData === undefined) {
            			userData = {
            				Tokens:	tokens*info.duration,
            				HWcred: hwCrd,
            				SWcred: swCrd,
            				cloudDuration : cDuration,
            				premDuration : pDuration,
            				embeddedDuration : eDuration,
            				count: num
            			};
            			map.set(key, userData);
            		}
            		else {
            			userData.Tokens = userData.Tokens+tokens*info.duration;
            			userData.HWcred = userData.HWcred+hwCrd;
               			userData.SWcred = userData.SWcred+swCrd;
               			userData.cloudDuration = userData.cloudDuration + cDuration;
               			userData.premDuration = userData.premDuration + pDuration;
               			userData.embeddedDuration = userData.embeddedDuration + eDuration;
               			userData.count = userData.count+num;
            			map.set(key, userData);
            		}
                },
           		// function to add credit/token info for the user to the user map
                // if the user does not exist create an entry in the map
                // otherwise add credit/token consumption info to the existing entry in the map
        		processUser: function (userInfo) {
            		var user = userInfo.user;
            		if (user === undefined ||  user === null || user.length === 0 || 'unknown' === user.toLowerCase()) {
            			user = 'Not Available';
            		}
            		LicenseInfoQueryDialog.processMap(userInfo, LicenseInfoQueryDialog.userMap, user, LicenseInfoQueryDialog.userJobList);
        		},
           		// function to add credit/token info for the job to the job map
                // if the job does not exist create an entry in the map
                // otherwise add credit/token consumption info to the existing entry in the map
        		processJob: function (jobInfo) {
        			// get job name if id is null or empty the this was physics app
            		var jobVal = jobInfo.jobName;
            		var jobId = jobInfo.jobId;
            		if (jobId === undefined ||  jobId === null ) {
            			jobVal = 'Not Available';
            		}
            		else if (jobId.length === 0) {
            			jobVal = '';
            		}
            		if (jobVal === undefined ||  jobVal === null ) {
            			jobVal = 'Not Available';
            		}
        			var jobArr = jobVal.split('_-_');
            		var jName = jobArr[0];
            		LicenseInfoQueryDialog.processMap(jobInfo, LicenseInfoQueryDialog.jobMap, jName, LicenseInfoQueryDialog.jobJobList);
        		},

    			// create the event log table
    			createTable: function (col1) {
    				return UWA.createElement('table',  {
    					'class': 'table table-striped',
    					html: [
    					       {
    					    	   tag: 'thead',
    					    	   html: {
    					    		   tag: 'tr',
    					    		   html: [
    					    		          {
    					    		        	  tag: 'th',
    					    		        	  text: col1
    					    		          },
    					    		          {
    					    		        	  tag: 'th',
    					    		        	  text: NLS.get('swCred')
    					    		          },
    					    		          {
    					    		        	  tag: 'th',
    					    		        	  text: NLS.get('hwCred')
    					    		          },
    					    		          {
    					    		        	  tag: 'th',
    					    		        	  text: NLS.get('tokens')
    					    		          },
    					    		          {
    					    		        	  tag: 'th',
    					    		        	  text: NLS.get('embeddedDuration')
    					    		          },
    					    		          {
    					    		        	  tag: 'th',
    					    		        	  text: NLS.get('count')
    					    		          }
    					    		          ]
    					    	   }
    					       },
    					       {
    					    	   tag: 'tbody',
    					    	   html: {
    					    		   tag: 'tr',
    					    		   html: [
    					    		          {
    					    		        	  tag: 'td',
    					    		        	  colspan: 8,
    					    		        	  text: NLS.get('tableBody')
    					    		          }
    					    		          ]
    					    	   }
    					       }
    					       ]
    				});
    			},  // create table close

    			// function to handle get data button.  gets the date from the start and end
    			// date pickers and passes the date in milliseconds to the get license data function
    			onButtonClick: function () {
					LicenseInfoQueryDialog.doDownload = false;
    				LicenseInfoQueryDialog.getLicData(
    						myContainer, myErrFunc, myAppsUrl, myTGC,
    						LicenseInfoQueryDialog.licMinDate.value.getTime(),
    						LicenseInfoQueryDialog.licMaxDate.value.getTime(),
    						 myWid.config.CosRestWsRootUrl);
    			},

    			// function to handle download data button.  gets the date from the start and end
    			// date pickers and passes the date in milliseconds to the get license data function
    			// in addition sets the dowDownload to true so data is also downloaded to CSV file
    			onDownButtonClick: function () {
					LicenseInfoQueryDialog.doDownload = true;
    				LicenseInfoQueryDialog.getLicData(
    						myContainer, myErrFunc, myAppsUrl, myTGC,
    						LicenseInfoQueryDialog.licMinDate.value.getTime(),
    						LicenseInfoQueryDialog.licMaxDate.value.getTime(),
    						 myWid.config.CosRestWsRootUrl);
    			},

    			// function to take csvString data and download it to csv file
        		download :    function (csv) {
        			 var filename = 'licUsage.csv';
        			 var blob = new Blob([csv], {type: "text/csv;charset=utf-8;"});
        			 // test for IE
        			 if (navigator.msSaveBlob)
        			 { 
        				 navigator.msSaveBlob(blob, filename)
        			 }
        			 // chrome and FF
        			 else
        			 {
	        			 var href = document.createElement("a");
	        			 if (href.download !== undefined)
	        			 {
		        			 var url = URL.createObjectURL(blob);
		        			 href.setAttribute("href", url);
		        			 href.setAttribute("download", filename);
		        			 href.style = "visibility:hidden";
		        			 document.body.appendChild(href);
		        			 href.click();
		        			 document.body.removeChild(href);
	        			 }
        			 }
        		},


    			// helper function to add a row to the license data table
    			populateTable: function  (key, map, tableBody) {
            		var cdiff = LicenseInfoQueryDialog.calculateDuration(map.cloudDuration);
            		var ctimeDiff =  cdiff.h +':' + cdiff.m + ':' + cdiff.s;
            		var pdiff = LicenseInfoQueryDialog.calculateDuration(map.premDuration);
            		var ptimeDiff =  pdiff.h +':' + pdiff.m + ':' + pdiff.s;
            		var ediff = LicenseInfoQueryDialog.calculateDuration(map.embeddedDuration);
            		var etimeDiff = ediff.h +':' + ediff.m + ':' + ediff.s;
            		var tokenHours = map.Tokens/1000/60/60;
            		tokenHours = tokenHours.toFixed(2);
            		var embedHours = map.embeddedDuration/1000/60/60;
            		embedHours = embedHours.toFixed(2);
					tableBody.addContent({
						tag: 'tr',
						html: [
						       {
						    	   tag: 'td',
						    	   text: key
						       },
						       {
						    	   tag: 'td',
						    	   text: map.SWcred
						       },
						       {
						    	   tag: 'td',
						    	   text:map.HWcred
						       },
						       {
						    	   tag: 'td',
						    	   text: tokenHours
						       },
						       {
						    	   tag: 'td',
						    	   text: embedHours
						       },
						       {
						    	   tag: 'td',
						    	   text: map.count
						       }
						       ]
					});// addContent close
    			}, // populateTable close

    			// method to create main div and filter with a start and end date picker
    			// once get data button is clicked web service will get the data and
    			// populate the user and job table
    			//
           		showDialog : function (theWidget) {
           	     	myContainer = theWidget.config.container;
           	     	myErrFunc = theWidget.displayError;
           	     	myAppsUrl = theWidget.config.myapps;
           	     	myTGC = theWidget.config.tgc;
           	     	myWid = theWidget;
                    licOuterDiv = UWA.createElement('div', {'class':'outer-div'});
                    licOuterDiv.style.overflowX='auto';
                    licOuterDiv.style.overflowY='auto';
                    licOuterDiv.style.height='100%';
                    licOuterDiv.style.width='100%';
                    licOuterDiv.style.padding='15px';
                    licOuterDiv.style.display='inline-block';
                    licOuterDiv.style.border='double';

    	            var filterDiv = UWA.createElement('div',  {
    	                text: NLS.get('licenseFilter'),
    	                styles: {
    	                    display: 'inline-block',
    	                    padding: '10px',
    	                    border:'double'
    	                }
    	            }).inject(licOuterDiv);

    	            // DatePicker with min and max Value
    	            // allow picking up to a year prior
    	            var minValue = new Date();
    	            minValue.setDate(minValue.getDate() - 365);
    	            var maxValue = new Date();
    	            maxValue.setDate(maxValue.getDate() +  30);

    	            LicenseInfoQueryDialog.licMinDate = new WUXDatePicker({
    	                minValue: minValue,
    	                maxValue: maxValue,
    	                timePickerFlag: true
    	            }).inject(filterDiv);

    	            LicenseInfoQueryDialog.licMaxDate = new WUXDatePicker({
    	                minValue: minValue,
    	                maxValue: maxValue,
    	                timePickerFlag: true
    	            }).inject(filterDiv);

    	            var buttonGroup2 = new WUXButtonGroup().inject(filterDiv);
    	            // Create a Button to get the license usage data
    	            var moreButton = new WUXButton({label:NLS.get('getData'),
    	            	onClick: this.onButtonClick});
    	            // Insert the Button in the dom tree.
    	            buttonGroup2.addChild(moreButton);
    	            // Create a Button to get the license usage data and download it as CSV file
    	            var downloadButton = new WUXButton({label:NLS.get('download'),
    	            	onClick: this.onDownButtonClick});
    	            // Insert the Button in the dom tree.
    	            buttonGroup2.addChild(downloadButton);


    	            immersiveLicFrame = new WUXImmersiveFrame();
	                immersiveLicFrame.inject(myContainer);
					modal = new WUXDialog({
	                   title: NLS.get('consumptionInfo'),
	                   content: licOuterDiv,
	                   immersiveFrame: immersiveLicFrame,
	                   movableFlag: true,
	                   resizeableFlag: true,
	                   minHeight:400,
	                   horizontallyStrechable: true,
	                   closeButtonFlag: true,
	                   allowedDockAreas:  WUXDockAreaEnum.TopDockArea,
	                   currentDockArea: WUXDockAreaEnum.TopDockArea

	                });
					modal.addEventListener('close', function () {
						immersiveLicFrame.destroy();
	                });
           		},
        		// method to make web service call to get credit/token info
        		// on success create the user and job tables with the web service data
        		//
           		getLicData : function (container, errFunc, myapps, tgc, licMinMillis, licMaxMillis, cosUrl) {
           			if (licMinMillis > licMaxMillis) {
           				myErrFunc(NLS.get('startAfterEnd'),true);
           			}
           			else {
	           	     	myContainer = container;
	           	     	myErrFunc = errFunc;
	            		var spaceURL = CosAPI.get3DSpaceUrl();
	            		// if we have an url get the credit/token info for the given WU license
	            		// create the graph on success
	            		if (spaceURL)  {
	            			CosAPI.getLicenseInfoJson(cosUrl, myapps, tgc, licMinMillis, licMaxMillis, '', '', '', '', {
	            				onComplete: function(data) {
	            					LicenseInfoQueryDialog.createGraph(data);
	            				},
	            				onFailure: function (jqXHR, textStatus) {
	    	                        if (textStatus) {
	    	                        	myErrFunc(textStatus, true);
	    							}
	    							else {
	    								myErrFunc( jqXHR.toLocaleString(), false);
	    							}
	            				}
	            			});
	            		}
	            		// otherwise wait a bit and then try to get credit/token info
	            		else {
	            			setTimeout(function(){
	            				CosAPI.getLicenseInfoJson(cosUrl, myapps, tgc, licMinMillis, licMaxMillis, '', '', '', '', {
	                				onComplete: function(data) {
	                					LicenseInfoQueryDialog.createGraph(data);
	                				},
	            					onFailure: function (jqXHR, textStatus) {
	        	                        if (textStatus) {
	        	                        	myErrFunc(textStatus, true);
	        							}
	        							else {
	        								myErrFunc( jqXHR.toLocaleString(), false);
	        							}
	            					}
	            				});
	            			}, 3000);
	            		}
           			}
           		},
           		
           		// utility method to append field to line
           		// if field is undefined or null just add comma if needed
           		AddFieldToLine : function (line, field, addComma) {
           			if (field === undefined || field === null) {
           				if (addComma) {
           					line +=','
           				}
           			}
           			else {
           				line += field;
           				if (addComma) {
           					line +=','
           				}
           			}
           			return line;
           		},

           		// function that take an array of license records and turns it into comma
           		// separated list string
           		GetCSV : function(licRecords) {
           			var str = '';

           			// put in column headers
           			str += NLS.get('jobId') + ',';
           			str += NLS.get('jobName') + ',';
           			str += NLS.get('workId') + ',';
           			str += NLS.get('userName') + ',';
           			str += NLS.get('tenant') + ',';
           			str += NLS.get('startDate') + ',';
           			str += NLS.get('endDate') + ',';
           			str += NLS.get('lastSeen') + ',';
           			str += NLS.get('numTokens') + ',';
           			str += NLS.get('softwareCredits') + ',';
           			str += NLS.get('hardwareCredits') + ',';
           			str += NLS.get('softwareRate') + ',';
           			str += NLS.get('hardwareRate')+ ',' ;
           			str += NLS.get('durationms')+ '\r\n';
           			
           			// for each row add fields allowing for missing fields to be blank
           			for (var i = 0; i < licRecords.length; i++) {           				
           				var line = '';
           				// check if we have a job id and if so preface with string data
           				// to make sure all numeric job id not displayed using exponential notation
           				if (licRecords[i].jobId === undefined || licRecords[i].jobId === null) {
               				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].jobId, true);           					           					
           				}
           				else {
           					line = LicenseInfoQueryDialog.AddFieldToLine(line, 'ID-' +licRecords[i].jobId, true);  
           				}
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].jobName, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].workItemId, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].user, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].tenant, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].startDate, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].endDate, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].lastSeen, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].totalTokens, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].totalSWCredits, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].totalHWCredits, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].rateSW, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].rateHW, true);
           				line = LicenseInfoQueryDialog.AddFieldToLine(line, licRecords[i].duration, false);

           				str += line + '\r\n';
           			}

           			return str;
           		},

           		// method to parse the license data returned and add it to the user map
           		// after data is parsed create and populate the user and job tables
           		createGraph : function (data) {
                    var licData= JSON.parse(data);
                    LicenseInfoQueryDialog.userMap.clear();
                    LicenseInfoQueryDialog.jobMap.clear();
                    LicenseInfoQueryDialog.jobJobList = [];
                    LicenseInfoQueryDialog.userJobList = [];
                    if (licData !== undefined){
                    	var licRecords = licData.LicenseUsageRecords;
	                    if (licRecords !== undefined){
	                    	var licRecord = licRecords.LicenseUsageRecord;
	                    	if (licRecord) {
		                        if (licRecord.length !== undefined) {
		                        	licRecord.forEach(function (item) {
		                        		LicenseInfoQueryDialog.processUser(item);
		                        		LicenseInfoQueryDialog.processJob(item);
		                        	});
		                        }
		                        else {
	                        		LicenseInfoQueryDialog.processUser(licRecord);
	                        		LicenseInfoQueryDialog.processJob(licRecord);
		                        }
	                    	}
	                    }
                    }

					if (LicenseInfoQueryDialog.doDownload) {
						if (licData && licData.LicenseUsageRecords && licData.LicenseUsageRecords.LicenseUsageRecord) {
							var csvStr = LicenseInfoQueryDialog.GetCSV(licData.LicenseUsageRecords.LicenseUsageRecord);
							LicenseInfoQueryDialog.download(csvStr);
						}
						else {
							LicenseInfoQueryDialog.download('');
						}
					}

                    if (licUserDiv) {
                    	licUserDiv.empty();
                    }
                    licUserDiv = UWA.createElement('div',  {
    	                text: NLS.get('userConsumption')
    	            }).inject(licOuterDiv);

                    if (licJobDiv) {
                    	licJobDiv.empty();
                    }
                    licJobDiv = UWA.createElement('div',  {
    	                text: NLS.get('jobConsumption')
    	            }).inject(licOuterDiv);

                    userTable = this.createTable(NLS.get('userName'));
                    userTable.inject(licUserDiv);
                    jobTable = this.createTable(NLS.get('jobName'));
                    jobTable.inject(licJobDiv);

                    var userTableBody = userTable.getElement('tbody');
                    userTableBody.empty();
                    var jobTableBody = jobTable.getElement('tbody');
                    jobTableBody.empty();

					LicenseInfoQueryDialog.userMap.forEach(function(value, key) {
						LicenseInfoQueryDialog.populateTable(key, value,  userTableBody);
					});
					LicenseInfoQueryDialog.jobMap.forEach(function(value, key) {
						LicenseInfoQueryDialog.populateTable(key, value,  jobTableBody);
					});
           		}
        };
        return LicenseInfoQueryDialog;
    	});


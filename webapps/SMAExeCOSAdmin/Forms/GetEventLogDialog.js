define('DS/SMAExeCOSAdmin/Forms/GetEventLogDialog',
    ['UWA/Core',
     'DS/UIKIT/Modal',
     'DS/Windows/Dialog',
	 'DS/Controls/ButtonGroup',
	 'DS/Controls/Button',
	 'DS/Controls/LineEditor',
	 'DS/Windows/ImmersiveFrame',
     'DS/SMAExeCOSAdmin/Forms/EventTraceDialog',
     'DS/WebappsUtils/WebappsUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
    ],

    /*
     * function to get the event log in chunks for the given server
     */
    function ( UWA,  UIModal,  WUXDialog,
    		ButtonGroup,  WUXButton,  WUXLineEditor,
    		WUXImmersiveFrame,  EventTraceDialog,
    		WebappsUtils,  WSUtils,  COSInfo,  NLS) {

	'use strict';
	var modal = null;
	var eventTable = null;
	var eventDiv = null;
	var eventIdButton = null;
	var eventServer = null;
    var eventUrl = null;
    var eventDeployType = null;
	var immersiveFrame = null;
	var GetEventLogDialog = {};


	GetEventLogDialog = {
			// function to add a row into the event log table
			// if the row has an image display the image and add an click event listener
			// to open the trace
			populateTable: function  (data,  tableBody) {
				var d = new Date(data.millis);
				var cid = data.clusterId;
				if (cid === undefined || cid === 'undefined' || cid === null)
				{
					cid ='';
				}
				// if we have an image add the image
				// ad event listener
				// save the trace as an attribute of the row
				if (data.image) {
				    if (eventDeployType !== undefined && eventDeployType.length >0 && 'SINGLE'.toLowerCase() !==  eventDeployType) {
                        tableBody.addContent({
                            tag: 'tr',
                            html: [
                                {
                                    tag: 'td',
                                    text: data.level
                                },
                                {
                                    tag: 'td',
                                    text: d.toLocaleString()
                                },
                                {
                                    tag: 'td',
                                    text: cid
                                },
                                {
                                    tag: 'td',
                                    html: [{
                                        tag: 'img',
                                        src: data.image
                                    }]
                                },
                                {
                                    tag: 'td',
                                    text: data.message
                                },
                                {
                                    tag: 'td',
                                    text: data.source
                                }
                            ]
                        });// addContent close
                    }
				    else {
                        tableBody.addContent({
                            tag: 'tr',
                            html: [
                                {
                                    tag: 'td',
                                    text: data.level
                                },
                                {
                                    tag: 'td',
                                    text: d.toLocaleString()
                                },
                                {
                                    tag: 'td',
                                    html: [{
                                        tag: 'img',
                                        src: data.image
                                    }]
                                },
                                {
                                    tag: 'td',
                                    text: data.message
                                },
                                {
                                    tag: 'td',
                                    text: data.source
                                }
                            ]
                        });// addContent close

                    }
					var rowArray = tableBody.getElementsByTagName('tr');
					var lastRow = rowArray[rowArray.length-1];
					lastRow.setAttribute('data-tr',  JSON.stringify(data.exception));
					lastRow.addEventListener('click',  function(e){
						// get the trace from the row
						// if we clicked on the image need to get grandparent to get row
						var trace = e.target.getParent().getAttribute('data-tr');
						if (!trace) {
							trace = e.target.getParent().getParent().getAttribute('data-tr');
						}

						// set up the trace string in the form and show the modal dialog
						var traceForm = EventTraceDialog.updateFields(trace);
						EventTraceDialog.showDialog(traceForm);
					});
				}
				else {
					// if we don't have an image just set an empty column without click event
                    if (eventDeployType !== undefined && eventDeployType.length >0 && 'SINGLE'.toLowerCase() !==  eventDeployType) {
                        tableBody.addContent({
                            tag: 'tr',
                            html: [
                                {
                                    tag: 'td',
                                    text: data.level
                                },
                                {
                                    tag: 'td',
                                    text: d.toLocaleString()
                                },
                                {
                                    tag: 'td',
                                    text: cid
                                },
                                {
                                    tag: 'td',
                                    text: ''
                                },

                                {
                                    tag: 'td',
                                    text: data.message
                                },
                                {
                                    tag: 'td',
                                    text: data.source
                                }
                            ]
                        });// addContent close
                    }
                    else {
                        tableBody.addContent({
                            tag: 'tr',
                            html: [
                                {
                                    tag: 'td',
                                    text: data.level
                                },
                                {
                                    tag: 'td',
                                    text: d.toLocaleString()
                                },
                                {
                                    tag: 'td',
                                    text: ''
                                },

                                {
                                    tag: 'td',
                                    text: data.message
                                },
                                {
                                    tag: 'td',
                                    text: data.source
                                }
                            ]
                        });// addContent close

                    }
				}
			}, // populateTable close

		    // process the item fields add bug image for events having exception
			processEventItem: function  (item,  idx ) {
				item.source = item.class;
				if (item.method) {
					item.source = item.class + ':' + item.method;
				}
				item.id = 'eventLog.' + idx;
				if (item.exception) {
		    		item.image = WebappsUtils.getWebappsAssetUrl('SMAExeCOSAdmin',  'images/errorLog.png');
				}
				return item;
		    },
		    // the parse function is called after getting the event log
		    // process each event.  if the event has an exception add the bug icon
		    // in order to know which rows can be selected to open a trace
		    dataParse : function   (data) {
		        var eventArray = [];
		        var eventData= JSON.parse(data);
		        if (eventData && eventData.log && eventData.log.record){
		            if (eventData.log.record.length !== undefined) {
		            	for (var idx = 0; idx < eventData.log.record.length; idx++) {
		            		var item2 = GetEventLogDialog.processEventItem(eventData.log.record[idx], idx);
		            		eventArray.push(item2);
		            	}
		            }
		            else {
		        		var item3 = GetEventLogDialog.processEventItem(eventData.log.record,  1);
		        		eventArray.push(item3);
		            }
		        }
		        return eventArray;

		    },

			onResetButtonClick: function () {
				eventIdButton.label = '1';
				COSInfo.getFilter().value = '';
                if (eventDeployType !== undefined && eventDeployType.length >0 && 'SINGLE'.toLowerCase() !==  eventDeployType ) {
                    COSInfo.getMemberFilter().value = '';
                }
				var tableBody = eventTable.getElement('tbody');
				tableBody.empty();
				COSInfo.getMoreBtn().show();

			},
			// handle click of more button
			// get next set of rows after the millis
			// of the last row currently in the log

			// saving last millis on label of hidden button
			onButtonClick: function () {
				var logId = eventIdButton.label;
				var msgFilterVal = COSInfo.getFilter().value;
                var memberFilterVal = '';
                if (eventDeployType !== undefined && eventDeployType.length >0 && 'SINGLE'.toLowerCase() !==  eventDeployType ) {
                    memberFilterVal = COSInfo.getMemberFilter().value;
                }
				if ('1' === logId) {
    				var tableBody = eventTable.getElement('tbody');
					tableBody.empty();
				}
		    	WSUtils.getEventLogAfter(eventUrl, eventServer, logId, msgFilterVal, memberFilterVal,
	        		// success function parses event data and adds rows to the table
	                function(data){
	    				var tableBody = eventTable.getElement('tbody');
	    				var logMsgs = GetEventLogDialog.dataParse(data);

						// Populate tableBody
	    				logMsgs.forEach(function (row) {
	    					GetEventLogDialog.populateTable(row,  tableBody);
						});

        				if (logMsgs.length >0 ) {
	        				var lastMsg = logMsgs[logMsgs.length-1];
	        				eventIdButton.label = lastMsg.millis;
        				}
        				else {
        					COSInfo.getMoreBtn().hide();
        				}

	            	});// end success function
			},

			onFilterButtonClick: function () {
				// set event logId back to 1 to reset filter after change
            	eventIdButton.label = '1';

            	// call onClick to get filtered event log
            	COSInfo.getMoreBtn().dispatchEvent('onClick');
			},
			// create the event log table
			createTable: function (deployType) {
                if (deployType === undefined || deployType.length===0 || 'SINGLE'.toLowerCase() ===  deployType ) {
                    return UWA.createElement('table', {
                        'class': 'table table-striped',
                        html: [
                            {
                                tag: 'thead',
                                html: {
                                    tag: 'tr',
                                    html: [
                                        {
                                            tag: 'th',
                                            text: NLS.get('type')
                                        },
                                        {
                                            tag: 'th',
                                            text: NLS.get('time')
                                        },
                                         {
                                            tag: 'th',
                                            text: NLS.get('trace')
                                        },
                                        {
                                            tag: 'th',
                                            text: NLS.get('message')
                                        },
                                        {
                                            tag: 'th',
                                            text: NLS.get('source')
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
                                            colspan: 5,
                                            text: NLS.get('eventLogBody')
                                        }
                                    ]
                                }
                            }
                        ]
                    });
                }
                else {
                    return UWA.createElement('table', {
                        'class': 'table table-striped',
                        html: [
                            {
                                tag: 'thead',
                                html: {
                                    tag: 'tr',
                                    html: [
                                        {
                                            tag: 'th',
                                            text: NLS.get('type')
                                        },
                                        {
                                            tag: 'th',
                                            text: NLS.get('time')
                                        },
                                        {
                                            tag: 'th',
                                            text: NLS.get('clusterId')
                                        },
                                        {
                                            tag: 'th',
                                            text: NLS.get('trace')
                                        },
                                        {
                                            tag: 'th',
                                            text: NLS.get('message')
                                        },
                                        {
                                            tag: 'th',
                                            text: NLS.get('source')
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
                                            colspan: 5,
                                            text: NLS.get('eventLogBody')
                                        }
                                    ]
                                }
                            }
                        ]
                    });
                }
			},  // create table close


			// create the content of the dialog
			// div with more buttons and table
			createContent : function (deployType) {
				eventTable = this.createTable(deployType);
				eventDiv = UWA.createElement('div', {'class':'table-div'});
				eventDiv.style.overflowY='auto';
				eventDiv.style.overflowX='auto';
				eventDiv.style.padding='10px';
	            var filterDiv = UWA.createElement('div',  {
	                text: NLS.get('logMessageFilter'),
	                styles: {
	                    display: 'inline-block',
	                    padding: '5px',
	                    border:'double',
	                    'vertical-align': 'middle'
	                }
	            }).inject(eventDiv);

	            eventTable.inject(eventDiv);

	            var lineEd = new WUXLineEditor({
	            	placeholder:NLS.get('msgFilter'),
	            	sizeInCharNumber:100
	            }).inject(filterDiv);

                var lineEd2 = null;
                if (deployType !== undefined && deployType.length > 0 && 'SINGLE'.toLowerCase() !==  deployType ) {
                    lineEd2 = new WUXLineEditor({
                        placeholder: NLS.get('memberFilter'),
                        sizeInCharNumber: 50
                    }).inject(filterDiv);
                }
	            var buttonGroup1 = new ButtonGroup().inject(filterDiv);
	            var filterButton = new WUXButton({label:NLS.get('filter'),
	            	onClick: this.onFilterButtonClick});
	            buttonGroup1.addChild(filterButton);

	            // create hidden button to hold last msg millis
	            eventIdButton = new WUXButton({label:'1'});

	            var buttonGroup2 = new ButtonGroup().inject(eventDiv);
	            // Create a Button and initialise its properties
	            var moreButton = new WUXButton({label:NLS.get('more'),
	            	onClick: this.onButtonClick});

	            var resetButton = new WUXButton({label:NLS.get('reset'),
	            	onClick: this.onResetButtonClick});

	            COSInfo.setMoreBtn(moreButton);
	            COSInfo.setFilter(lineEd);
                if (deployType !== undefined && deployType.length>0 && 'SINGLE'.toLowerCase() !==  deployType ) {
                    COSInfo.setMemberFilter(lineEd2);
                }

	            // Insert the Button in the dom tree.
	            buttonGroup2.addChild(moreButton);
	            buttonGroup2.addChild(resetButton);
	            buttonGroup2.addChild(eventIdButton);

	            // hidden button to hold millis to be used when getting next set of events
	            eventIdButton.hide();
				 return eventDiv;

			},
			// function to create the  dialog from the content and show it			
			showDialog : function (server, url,deployType) {
				var content = this.createContent(deployType);
				eventServer = server;
				eventUrl = url;
                eventDeployType = deployType;

                    immersiveFrame = new WUXImmersiveFrame();
                immersiveFrame.inject(COSInfo.getContainer());
				modal = new WUXDialog({
                   title: NLS.get('eventLog'),
                   content: content,
                   immersiveFrame: immersiveFrame,
                   movableFlag: true,
                   resizeableFlag: true,
                   minHeight:400,
                   horizontallyStrechable: true,
                   closeButtonFlag: true,
                   allowedDockAreas:  WUXDockAreaEnum.TopDockArea,
                   currentDockArea: WUXDockAreaEnum.TopDockArea        			
                });
				modal.addEventListener('close', function (e) {
                    immersiveFrame.destroy();
                });



				modal.bringToFront();
		    	WSUtils.getEventLogAfter(eventUrl, eventServer, 1, '', '',
		        		// success function parses event data and adds rows to the table
		                function(data){
		    				var tableBody = eventTable.getElement('tbody');
		    				tableBody.empty();
		    				var logMsgs = GetEventLogDialog.dataParse(data);

							// Populate tableBody
		    				logMsgs.forEach(function (row) {
		    					GetEventLogDialog.populateTable(row,  tableBody);
							});

	        				if (logMsgs.length >0 ) {
		        				var lastMsg = logMsgs[logMsgs.length-1];
		        				eventIdButton.label = lastMsg.millis;
	        				}
	        				else {
	        					COSInfo.getMoreBtn().hide();
	        				}

		            	});// end success function

			}
	};
    return GetEventLogDialog;
});



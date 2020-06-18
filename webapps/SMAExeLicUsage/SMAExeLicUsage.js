define('DS/SMAExeLicUsage/SMAExeLicUsage',
	['DS/WebappsUtils/WebappsUtils', 'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
	 'DS/PlatformAPI/PlatformAPI',
    'DS/WAFData/WAFData',
	 'UWA/Data',
     'UWA/Utils',
     'UWA/Core',
     'DS/UIKIT/SuperModal',
	 'DS/Controls/ButtonGroup',
	 'DS/Controls/Button',
     'DS/SMAExeLicUsage/LicenseInfoQueryDialog',
     'DS/Logger/Logger',
     'module',
	 'i18n!DS/SMAExeLicUsage/assets/nls/SMAExeLicUsage'
	 ],
	 function(WebappsUtils,
			 i3DXCompassPlatformServices,
			 PlatformAPI,
			 WAFData,
			 Data,
			 Utils,
			 UWA, SuperModal,
			 ButtonGroup, Button, QueryDialog, Logger, module,
			 NLS
	 ) {

	'use strict';
	var MyWidget = {};
	var urlList = [];
	var idx = 0;
    var _logger = Logger.getLogger(module);
	MyWidget = {
		/* config data  used to store retrieved data*/
		config: {},
 		superModal: null,
        ajaxRequest: function(url, typ, onOk, onErr) {
            WAFData.authenticatedRequest(url, {
                method: 'GET',
                type: typ,
                onComplete: onOk,
                onFailure:onErr
            } );
        },

		displayError : function (message, showAlert) {
			if (showAlert) {
				MyWidget.superModal.alert(message, function () {
					_logger.error(message);
				});
			}
			else {
				_logger.error(message);
			}

		},
        // function to get Ticket for a CAS TGC
        getServiceTicket: function() {
           	//get url to get  ticket
	        var stURL = Utils.composeUrl(
	    		   UWA.extend(Utils.parseUrl(window.location),
	    				   {anchor: '', path: '/api/passport/ticket', query:'url=v6'}
	    		   ));
		    MyWidget.ajaxRequest(stURL, 'json',
		       	// ok function for getting ticket
		    	function(data) {
					if (data && data.success === true) {

						// use this service ticket to get a CAS TGC
						var callback = Utils.encodeUrl(Utils.buildUrl(window.location, WebappsUtils.getWebappsBaseUrl() + 'SMAExeLicUsage/gettgc.html')),
						    passportUrl = PlatformAPI.getApplicationConfiguration('app.urls.passport.cas'),
						    userId = PlatformAPI.getUser().login,
	                        casUrl = Utils.buildUrl(passportUrl, '/getcastgc?userid=' + userId + '&service=V6&ticket=' + data.result + '&callback=' + callback),
	                        reg = new RegExp('castgc=(.*-cas)');
						MyWidget.ajaxRequest(casUrl, 'text',
							// OK function for CAS
							function(data2) {
								if (reg.test(data2)) {
			                         var tgc = reg.exec(data2);
			                         MyWidget.config.tgc = tgc[1];
			         				// Load Data
			     					MyWidget.get3DSpaceUrl();
								}
							},
							// error function for CAS
							function (data3) {
								var errMsg = NLS.get('casErr');
								MyWidget.displayError(errMsg, true);
								MyWidget.displayError(errMsg+ ': ' + data3, false);
	                        });
					}
		    	}, // end ok function for ticket
		    	// error function for ticket
				function(data4) {
					var errMsg = NLS.get('ticketErr');
					MyWidget.displayError(errMsg, true);
					MyWidget.displayError(errMsg+ ': ' + data4, false);
		    	}
	        );// end ajax request

        }, // end getServiceTicket

        /*
         * method to get the COS server url using a specified 3DSpace url
         */
        getCosUrl: function (onErr) {
        	WAFData.authenticatedRequest( urlList[idx], {
        		method: 'GET',
        		type : 'text',
        		onComplete: function(data) {
        			MyWidget.config.CosRestWsRootUrl = data;
        			// Need to call the following inside this onComplete() because
        			// need the COS url for data-dependent synchronous processing.
        			// Next method will call the lic usage web service and populate the table with the results
        			try {
        				MyWidget.loadData();
        			}
        			catch (err) {
            			onErr(err);
        			}
        		},

        		// get COS url Failure
        		onFailure: function (data) {
        			var errMsg = NLS.get('cosUrlErr')+ ': ' + data;
					MyWidget.displayError(errMsg, false);
        			onErr(errMsg);
        		}
        	}); // UWA.Data.request

        },

        /*
         * method that iterates on failure over the various 3dSpaceUrls until it gets
         * the COS server url or exhausts the list
         */

        incrementUrlOnErr: function (data){
        	idx++;
        	if (idx < urlList.length ) {
        		MyWidget.getCosUrl(MyWidget.incrementUrlOnErr);
        	}
        	else {
        		var errMsg = NLS.get('cosUrlErr') + ': ' + data;
				MyWidget.displayError(errMsg, true);
        	}
        },

        // prototype bringing up graphview for credit/token consumption
        // hardcode WU license for now for prototype.
        onButtonClick : function () {
        	QueryDialog.showDialog(MyWidget);
        },


        /*
           The onLoad() function is the first one, triggered by widget.onLoad.
           Its use is to display a 'Loading' message, then call the next method.
		 */
		onLoad: function() {
			var div = UWA.createElement('div', {'class':'table-div'});
			div.style.overflowY='auto';
			div.style.height='100%';
			div.style.padding='10px';
            MyWidget.config.container = div;
            MyWidget.superModal = new SuperModal({ renderTo: MyWidget.config.container });

			// get the myApps URL and store on widget config -
			// passed to license web service to get tenant data
			MyWidget.config.myapps = PlatformAPI.getApplicationConfiguration('app.urls.myapps');
			if (typeof MyWidget.config.myapps === undefined ){
				var errMsg = NLS.get('appsErr');
				MyWidget.displayError(errMsg, true);
				return;
			}

			// Clear widget body
			widget.body.empty();

			// add a label section
			var headerLabel = NLS.get('licUsage');
            widget.body.addContent({
                tag: 'div',
                'class': 'section',
                html: [
                    { tag: 'h5', text: headerLabel }
                ]
            });

			// Create a empty table for data
			MyWidget.table = MyWidget.createTable();

			// create div for scrollbar for table
			// create button to bring up graph view for credit/token consumption
			// don't show button for now
            var buttonGroup = new ButtonGroup().inject(div);
	         // Create a Button and initialise its properties
            var button = new Button({label:NLS.get('licenseConsumption'), onClick: MyWidget.onButtonClick});

	        // Insert the Button in the dom tree.
            buttonGroup.addChild(button);
            //buttonGroup.hide();

            MyWidget.table.inject(div);
            div.inject(widget.body);

			// get CAS ticket and call license web service to get credit data
			MyWidget.getServiceTicket();
		},

		// get the COS URL
		get3DSpaceUrl: function () {
			if (MyWidget.config.CosRestWsRootUrl && MyWidget.config.CosRestWsRootUrl.length > 0) {
    			try {
    				MyWidget.loadData();
    			}
    			catch (err) {
					MyWidget.displayError(err, true);
    			}
			}
			else {
				i3DXCompassPlatformServices.getServiceUrl({
					serviceName: '3DSpace',
					onComplete: function(data) {
						for (var i = 0; i < data.length; i++) {
							if (data[i].url && data[i].url.length > 0) {
								var getCosUrlRequest = data[i].url + '/resources/eepservices/cos/url?tenant='
									+ data[i].platformId;
								urlList.push(getCosUrlRequest);
							}
						}
						MyWidget.getCosUrl(MyWidget.incrementUrlOnErr);

					}, // get COS URL on complete done

					// get 3DSpace failure
					onFailure: function (jqXHR, textStatus){
						var errMsg = NLS.get('platformUrlErr');
                        if (textStatus) {
        					MyWidget.displayError(errMsg+ ': ' + textStatus, true);
						}
						else {
        					MyWidget.displayError(errMsg+ ': ' + jqXHR.toLocaleString(), true);
						}
					}

				}); // i3DXCompassPlatformServices.getServiceUrl
			}// else close
		}, // get3DSpaceUrl close

		// Adds a row of license data to the table
		populateTable: function (data, tableBody) {
			var inUse = data['@inUse'];
			var nameText = data['@name'];
			if (data['@name']=== 'ECR'){
				nameText = NLS.get('ecr');
			}
			if (data['@name']=== 'SCR'){
				nameText = NLS.get('scr');
			}
			if (data['@name']=== 'SCT'){
				nameText = NLS.get('sct');
			}
			if (data['@name']=== 'GX2'){
				nameText = NLS.get('gx2');
			}
			tableBody.addContent({
				tag: 'tr',
				html: [
				       {
				    	   tag: 'td',
				    	   text: nameText
				       },
				       {
				    	   tag: 'td',
				    	   text: data['@available']
				       },
				       {
				    	   tag: 'td',
				    	   text: inUse
				       },

				       {
				    	   tag: 'td',
				    	   text: data['@expiration']
				       },
				       {
				    	   tag: 'td',
				    	   text: data['@tenant']
				       }
				       ]
			});// addContent close

		}, // populateTable close

		createTable: function () {
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
				    		        	  text: NLS.get('available')
				    		          },
				    		          {
				    		        	  tag: 'th',
				    		        	  text: NLS.get('inUse')
				    		          },
				    		          {
				    		        	  tag: 'th',
				    		        	  text: NLS.get('expiration')
				    		          },
				    		          {
				    		        	  tag: 'th',
				    		        	  text: NLS.get('tenant')
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
				    		        	  text: NLS.get('Loading...')
				    		          }
				    		          ]
				    	   }
				       }
				       ]
			});
		}, // create table close

		loadData: function () {

			// Here we guard the table tbody in order to put data inside.
			// Then we make 'data.json' relative url absolute using UWA.Utils.buildUrl,
			// and widget.get3DSpaceUrl().
			var tableBody = MyWidget.table.getElement('tbody'),
			dataUrl = MyWidget.config.CosRestWsRootUrl+'/admin/license_usage';

			// Set data Loading...
			tableBody.setContent({
				tag: 'tr',
				html: {
					tag: 'td',
					colspan: 5,
					text: NLS.get('Loading...')
				}
			});

			// Make web service call to get license data
			Data.request(dataUrl, {
				type: 'json',
				method: 'GET',
				allowCrossOriginRequest: true,

				headers: { Accept 	:'application/json',
					MyAppsURL      	: MyWidget.config.myapps,
					CASTGC			: MyWidget.config.tgc},
					myWidget			: MyWidget,

					onComplete: function (data) {
						// if we have license data with the correct format
						if (data && typeof data.usage !== 'undefined') {
							var licData = [];
							if (data && typeof data.usage === 'object') {
								if (typeof data.usage.feature === 'object') {
									// data.usage.feature might be a single object, or might be an array
									if (data.usage.feature.length) {
										licData = data.usage.feature;
									} else {
										licData = [data.usage.feature];
									}
								}
							}
							// Clear tableBody
							tableBody.empty();

							// Populate tableBody
							licData.forEach(function (data) {
								MyWidget.populateTable(data, tableBody);
							});

						}
						// else ... we have bad data
						else {
							var errMsg = NLS.get('licenseDataErr') ;
        					MyWidget.displayError(errMsg, true);
	                        this.options.myWidget.incrementUrlOnErr(errMsg);
						}
					}, // request onComplete close
					onFailure: function (jqXHR, textStatus) {
						var errMsg = NLS.get('badLicUsage');
                        if (textStatus) {
						    errMsg += ': ' +textStatus;
        					MyWidget.displayError(errMsg, false);
						}
						else {
						    errMsg +=  ': ' + jqXHR.toLocaleString();
        					MyWidget.displayError(errMsg, false);
						}
                        this.options.myWidget.incrementUrlOnErr(errMsg);
					}

			}); // UWA.Data.request close
		} // loadData close
	}; // myWidget close

	/*
    The 'onLoad' event is the very first event triggered when
    the widget is fully loaded.  we add MyWidget.onLoad() function
    as 'onLoad' event listener on the widget.
	 */
	widget.addEvent('onLoad', MyWidget.onLoad);

	return MyWidget;
});

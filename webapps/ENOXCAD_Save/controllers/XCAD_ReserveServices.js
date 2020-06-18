define('DS/ENOXCAD_Save/controllers/XCAD_ReserveServices', 
[	'UWA/Core', 'DS/Core/Core',  'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD', 'DS/WidgetServices/WidgetServices', 
	'DS/WidgetServices/securityContextServices/SecurityContextServices', 'DS/WAFData/WAFData'
], function(UWA, WUX, XCAD_InteractionsWEB_CAD, WidgetServices, SecurityContextServices, WAFData) {
	
	'use strict';

	var ENOUPSReserveServices = {
		nodesToBeUpdated : [], // Array of TreeNodeModel indexed with Phid as key (filled in execute)
		
		// actionName accepted value are : "reserve" or "unreserve"
		execute : function(actionName) {
			var that = this;
			WidgetServices.get3DSpaceUrlAsync({
				onComplete : function(fullServerUrl) {
					SecurityContextServices.getInstance().getSecurityContext({
						onSuccess : function(e) {
							that.sendRequest_getV5Instances(actionName, fullServerUrl, e.SecurityContext);
						}
					});
				}
			});
		},
		
		sendRequest_getV5Instances : function(actionName, fullServerUrl, securityContext) {
			var that = this;
			this.nodesToBeUpdated = [];
			
			var listPhidSelectedElement = [];
			for ( var i in widget.XCAD_MainController.selectedNodes) {
				var node = widget.XCAD_MainController.selectedNodes[i];
				this.nodesToBeUpdated[node._options.grid.Phid] = node;
				listPhidSelectedElement.push(node._options.grid.Phid);
			}

			var listModelUrl = [];
			listPhidSelectedElement.forEach(function(phid) {
				listModelUrl.push('"model//' + phid + '"');
			});

			var param = "?";
			var tenantID = WidgetServices.getTenantID();
			if (tenantID) {
				param += "tenant=" + tenantID;
			}

			// need to get the V5 Child instances since they always go with the V5 reference. They are handled implicitly
			var url = fullServerUrl + '/resources/v1/collabServices/reservation/op/getV5Instances' + param;

			WAFData.authenticatedRequest(url, {
				method : 'POST',
				type : 'json',
				timeout : 1000 * 60 * 60 * 3, // ms, 3hr
				data : listPhidSelectedElement.join(),
				headers : {
					'Accept' : 'application/json',
					'Content-Type' : 'application/json'
				},
				onComplete : function(data) {

					// [{"physicalid":"CB91C9410163E33E305E0A062AC0AA77","rel":"CB91CED60163EF46305E0A062AC0AA77,AD1E46FC024A486DB615808430815F2D,0DF832FB2D8D46DBA415745EA92012FD"}]
					for (var idx = 0; idx < data.length; idx++) {
						var v5RelsStr = data[idx]["rel"];
						var v5Rels = v5RelsStr.split(',');

						for (var relIdx = 0; relIdx < v5Rels.length; relIdx++) {
							listModelUrl.push('"model/rel/' + v5Rels[relIdx] + '"');
						}

					}

					that.sendRequest_Reservation(listModelUrl, actionName, fullServerUrl, securityContext);
				}
			});
		}, 

		sendRequest_Reservation : function(listModelUrl, actionName, fullServerUrl, securityContext) {
			var that = this;
			
			// Set request url (with its params) : 
			var param = "?";
			var tenantID = WidgetServices.getTenantID();
			if (tenantID) {
				param += "tenant=" + tenantID + "&";
			}

			if (listModelUrl.length > 1)
				param += 'isMultiSel=1&';
			else
				param += 'isMultiSel=0&';

			var listSelect = [ "physicalid" ];
			listSelect.forEach(function(select) {
				param += 'select=' + select + "&";
			});

			var url = fullServerUrl + '/resources/v1/collabServices/reservation/op/' + actionName + param;

			console.log('ENOUPSReserveServices - url = ' + url);

			// Set request headers : 
			var headers = {
				'Accept' : 'application/json',
				'Content-Type' : 'application/json',
				'SecurityContext' : securityContext
			};
			headers['Accept-Language'] = widget.lang;
			console.log('ENOUPSReserveServices - headers = ');
			console.log(headers);

			// Set request data : 
			var data = '{"urls":[' + listModelUrl + ']}';
			console.log('ENOUPSReserveServices - data = ');
			console.log(data);


			// Send the reserve/unreserve request
			WAFData.authenticatedRequest(url, {
				method : 'POST',
				type : 'json',
				timeout : 1000 * 60 * 60 * 3, // ms, 3hr
				headers : headers,
				cache : -1,
				proxy : 'passport',
				data : data,
				onComplete : function(jsonData) {
					console.log('ENOUPSReserveServices - ' + actionName + ' request completed');

					for ( var i in jsonData.results) {
						var resust = jsonData.results[i];
						if (resust.errors) {
							// Warn the user
							for ( var j in resust.errors) {
								console.log('ENOUPSReserveServices - ERROR : object has not been ' + actionName + 'ed (physicalid = "' + resust.errors[j].physicalid + '"), error message = "' + resust.errors[j].message + '"');
								// We skip internal object that was not actually selected by the user (V5 Child instances)
								if (typeof that.nodesToBeUpdated[resust.errors[j].physicalid] != 'undefined')
									widget.XCAD_MainController.displayNotif('warning', 'Failed to ' + actionName + ' data', resust.errors[j].message, '');
							}
						} else {
							// Warn the user
							console.log('ENOUPSReserveServices - SUCCESS : object "' + resust.title + '"\t has been ' + actionName + 'ed.');
							
							// We skip internal object that was not actually selected by the user (V5 Child instances)
							var node = that.nodesToBeUpdated[resust.physicalid];
							if (node) {
								widget.XCAD_MainController.displayNotif('info', 'Object ' + resust.title + ' has been ' + actionName + 'ed.', '', '');
								
								// Update the model
								var newGrid = node.options.grid;
								newGrid.Reserve = (actionName == 'reserve') ? 'I_UPSLockedByMe' : 'I_UPSUnLocked';
								newGrid.Reserved_By = (actionName == 'reserve') ? resust.lockerName : '';
								node.updateOptions({
									grid : newGrid
								});
							}
						}
					}
				},
				onFailure : function(errorData) {
					console.log('ENOUPSReserveServices - Failed to ' + actionName + ' data');
					console.log(errorData);
					// Warn the user
					widget.XCAD_MainController.displayNotif('warning', 'Failed to ' + actionName + ' data', '', '');
				},
				onTimeout : function(errorData) {
					console.log('ENOUPSReserveServices - ' + actionName + ' Timeout error');
					console.log(errorData);
					// Warn the user
					widget.XCAD_MainController.displayNotif('warning', actionName + ' Timeout error', '', '');
				}
			});
		}
	};
	
	return ENOUPSReserveServices;
});

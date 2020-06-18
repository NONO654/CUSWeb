define('DS/SMAExeCOSAdmin/Forms/DrivePropsObj',
    ['DS/WebappsUtils/WebappsUtils',
     'UWA/Core',
	 'DS/UIKIT/Form',
     'DS/UIKIT/Modal',
     'DS/SMAExeCOSAdmin/Forms/COSFormUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
     'DS/SMAExeCOSAdmin/Model/DriveModel',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
    ],
    /*
     * function to process shared drive data for stations
     * method that will display dialog and add (or edit) a shared drive for the station
     * When the dialog is submitted get the data and add shared file system list to the station data.
     * another method handles the multi-select delete of shared drives
     */
    function (WebappsUtils,  UWA,   UIForm,  UIModal,  FormUtils,  COSInfo,  COSUtils,  DriveModel,  WSUtils,  NLS) {

         'use strict';
         var DrivePropsObj = {};
         var modal = {};

         // variables that hold the data passed in
         // if adding a drive then ids is empty and the variables are simple string
         // if deleting drives then the variables are arrays of the drive data
         // and ids is an array of the collection ids to be removed on succesfult update
         var _DRIVENAME = '';
         var _DRIVEPATH = '';
         var _DRIVEDESC = '';
         var _IDS =[];
         DrivePropsObj = {

                 // function that gets the form application data and constructs the update xml for the station
                 // or removes the applications if not adding
        		 updateStation: function (name,  path,  desc,  model,  serverName,  url,  ids,  doingAdd) {
                	 _DRIVENAME = name;
                	 _DRIVEPATH = path;
                	 _DRIVEDESC = desc;
                       _IDS=ids;

                      var _DRIVEXML = '<SharedFSList>';
                      var view = COSInfo.getBones().getViewAt(1);
                      var collection = view.collection;
                      var driveModels = collection._models;

                      // build the application xml
                      // iterate to get the current applications data from the collection and skip adding if
                      // updating an existing application or not doing an add.
                      for (var i = 0 ; i < driveModels.length; i++) {
                    	  var drv = driveModels[i];
                    	  if (doingAdd) {
                    		  // only add drive row if different name
        	    			  if (drv.get('driveName') !== _DRIVENAME ) {
        	    				  _DRIVEXML = _DRIVEXML +'<SharedFS Name="'+drv.get('driveName') + '" Path="' +
        	    				  drv.get('path') + '" description="' + drv.get('description') +'" />';
        	    			  }
                    	  }
                    	  else {
                    		  // if doing delete only add applications not being deleted
                    		  if (_IDS.indexOf(drv.get('id')) === -1){
                    			  _DRIVEXML = _DRIVEXML +'<SharedFS Name="'+drv.get('driveName') + '" Path="' + drv.get('path')
                    			  + '" description="' + drv.get('description') +
        		              		'" />';
                    		  }
                    	  }
                      }
                      if (doingAdd) {
                    	  _DRIVEXML = _DRIVEXML +'<SharedFS Name="'+_DRIVENAME + '" Path="' + _DRIVEPATH +
                    	  '" description="' + _DRIVEDESC +
                    	  '" />';
                      }
                      _DRIVEXML = _DRIVEXML + '</SharedFSList>';

                      // get the xml sting for the station
                      var oneStationXml = COSUtils.getStationXml(model,  _DRIVEXML,  '');

                      // define the update station xml
                	  var StationXml = '<?xml version="1.0" encoding="utf-8"?>' +
                	 	'<StationList>' + oneStationXml +'</StationList>';


                	  // call COS API to do the update
                	  // if doing add need to add to the collection
                	  // otherwise need to remove the applications from the collection
                      if (doingAdd) {
        	        	 WSUtils.updateStation(url,  serverName,  StationXml,
        	                 function(){
        	                     // get the original station info and update with the form data
        	                     var view = COSInfo.getBones().getViewAt(1);
        	                     var collection = view.collection;
        	                     var driveModel = new DriveModel();
        	                     driveModel.set('driveName',  _DRIVENAME);
        	                     driveModel.set('path',  _DRIVEPATH);
        	                     driveModel.set('description',  _DRIVEDESC);
        	                     driveModel.set('id',  _DRIVENAME );
        	                     collection.add(driveModel,  {merge:true});
        	                 } );
        	         	  modal.hide();
                      }
                      else {
         	        	 WSUtils.updateStation(url,  serverName,  StationXml,
         		                 function(){
        		 	        		 var view = COSInfo.getBones().getViewAt(1);
        		 	        		 var collection = view.collection;
        		 	        		 for (var k = 0; k < _IDS.length; k++) {
        		 	        			 collection.remove(collection.get(_IDS[k]));
        		 	        		 }
         	        	 } );

                      }
                 },

		 		 // get the data from the model passed in and update the form's fields
        		 addDrive:  function (form, serverName, url) {
                	 // get the form data
	            	  var formVal = form.getValues();
                	  this.updateStation(
                		  formVal.driveName,
                		  formVal.drivePath,
                		  formVal.description,
            			  form.model,
            			  serverName, url, [], true
                	  );
                 },

                 // get the delete array from the selected models
                 deleteDrives: function (view, models) {
                	 var names = [];
                	 var paths = [];
                	 var descs = [];
                	 var ids = [];
                     for (var i = 0 ; i < models.length; i++) {
                   	  	var mdl = models[i];
                   	  	names.push(mdl.get('driveName'));
                   	  	paths.push(mdl.get('path'));
                   	  	descs.push(mdl.get('description')?mdl.get('description'):'');
                   	  	ids.push(mdl.get('id'));
                     }
                     if (names.indexOf('simshared') >= 0) {
                    	 COSUtils.displayError(NLS.get('simsharedModErr'), true);
                     }
                     else {
	                     this.updateStation(
	                		 names,
	                		 paths,
	                		 descs,
	                		 view.model,
	                		 view.model.get('serverName'),
	                		 view.model.get('fullCosUrl'), ids, false
	                       	);
                     }
                 },

                 // get the fields for the dialog
        		updateFields : function (model, editMode, serverName, url) {
                    // define the form fields
            		var myForm = new UIForm({
           		    className: 'vertical',
           		    fields: FormUtils.getDriveFields(),
           		    buttons: [{
           		        type: 'submit',
           		        value: NLS.get('submit')
           		    }],
           		    events: {
           		        onSubmit:  function () {
                            var splitServer = serverName.split('@@');
                            if (splitServer.length >1) {
                            	serverName = splitServer[1];
                            }
           		            try {
           		            	DrivePropsObj.addDrive(this, serverName, url);
           		            }
           		            catch (err) {
               		        	COSUtils.displayError(err, true);
           		            }
           		        },
           		        onInvalid: function () {
           		        	COSUtils.displayError(NLS.get('dlgErr'), true);
           		        }
           		    }
            		});
                    myForm.model = model;

                    return myForm;
        		},

        		// function to create the modal dialog from the form and show it
        		showDialog : function (theForm) {
        			var headerStr = NLS.get('createStation');
        			if (theForm.model){
        				headerStr = NLS.get('createDrive');
        			}
                    modal = new UIModal({
                        closable : true,
                        header : headerStr,
                        body: theForm
                    });

                    modal.inject(COSInfo.getContainer());
                    modal.show();
        		}
        };
        return DrivePropsObj;
});

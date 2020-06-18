define('DS/SMAExeCOSAdmin/Forms/ApplicationPropsObj',
    ['DS/WebappsUtils/WebappsUtils',
     'UWA/Core',
	 'DS/UIKIT/Form',
     'DS/UIKIT/Modal',
     'DS/SMAExeCOSAdmin/Forms/COSFormUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
     'DS/SMAExeCOSAdmin/Model/ApplicationModel',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
    ],
    /*
     * function to process application data for stations
     * method that will display dialog and add (or edit) an application for the station
     * When the dialog is submitted get the data and add application list to the station data.
     * another method handles the multi-select delete of applications
     */
    function (WebappsUtils, UWA,  UIForm, UIModal, FormUtils, COSInfo, COSUtils, ApplicationModel, WSUtils, NLS) {

         'use strict';
         var ApplicationPropsObj = {};
         var modal = {};

         // variables that hold the data passed in
         // if adding an application then ids is empty and the variables are simple string
         // if deleting applications then the variables are arrays of the application data
         // and ids is an array of the collection ids to be removed on successful update
         var _APPLNAME = '';
         var _APPLPATH = '';
         var _APPLVERSION = '';
         var _IDS =[];

         ApplicationPropsObj = {
                 // function that gets the form application data and constructs the update xml for the station
                 // or removes the applications if not adding
        		 updateStation: function updateStation(name, version, path, model, serverName, url, ids, doingAdd) {
                       _APPLNAME = name;
                       _APPLPATH = path;
                       _APPLVERSION = version;
                       _IDS=ids;

                      var _APPLXML = '<ApplicationList>';
                      var view = COSInfo.getBones().getViewAt(1);
                      var collection = view.collection;
                      var applicationModels = collection._models;

                      // build the application xml
                      // iterate to get the current applications data from the collection and skip adding if
                      // updating an existing application or not doing an add.
                      for (var i = 0 ; i < applicationModels.length; i++) {
                    	  var appl = applicationModels[i];
                    	  if (doingAdd) {
                    		  // only add application row if different name or version
        	    			  if (appl.get('appName') !== _APPLNAME || appl.get('version') !== _APPLVERSION) {
        	                	  _APPLXML = _APPLXML +'<Application Name="'+appl.get('appName') + '" Version="'+
        	                	  appl.get('version') +'" ExecPath="' + appl.get('path') +
        		              		'" />';
        	    			  }
                    	  }
                    	  else {
                    		  // if doing delete only add applications not being deleted
                    		  if (_IDS.indexOf(appl.get('id')) === -1){
        	                	  _APPLXML = _APPLXML +'<Application Name="'+appl.get('appName') + '" Version="'+
        	                	  appl.get('version') +'" ExecPath="' + appl.get('path') +
        		              		'" />';
                    		  }
                    	  }
                      }
                      if (doingAdd) {
        	              _APPLXML = _APPLXML +'<Application Name="'+_APPLNAME + '" Version="'+
        		              		_APPLVERSION +'" ExecPath="' + _APPLPATH +
        		              		'" />';
                      }
                      _APPLXML = _APPLXML + '</ApplicationList>';

                      // get the xml sting for the station
                      var oneStationXml = COSUtils.getStationXml(model, _APPLXML, '');

                      // define the update station xml
                	  var StationXml = '<?xml version="1.0" encoding="utf-8"?>' +
              	 			'<StationList>' + oneStationXml +'</StationList>';

                	  // call COS API to do the update
                	  // if doing add need to add to the collection
                	  // otherwise need to remove the applications from the collection
                      if (doingAdd) {
        	        	 WSUtils.updateStation(url, serverName, StationXml,
        	                 function(){
        	                     // get the original station info and update with the form data
        	                     var view = COSInfo.getBones().getViewAt(1);
        	                     var collection = view.collection;
        	                     var appModel = new ApplicationModel();
        	                     appModel.set('appName', _APPLNAME);
        	                     appModel.set('version', _APPLVERSION);
        	                     appModel.set('path', _APPLPATH);
        	                     appModel.set('id', _APPLNAME + '___'  + _APPLVERSION);
        	                     collection.add(appModel, {merge:true});
        	                 } );
        	         	  modal.hide();
                      }
                      else {
         	        	 WSUtils.updateStation(url, serverName, StationXml,
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
        		 addApplication:  function (form, serverName, url) {
                	 // get the form data
                	  var formVal = form.getValues();
                	  this.updateStation(
                		  formVal.applName,
                		  formVal.applVersion,
                		  formVal.applPath,
            			  form.model,
            			  serverName, url, [], true
                	  );
                 },

                 // get the delete array from the selected models
                 deleteApplications: function (view, models) {
                	 var names = [];
                	 var versions = [];
                	 var paths = [];
                	 var ids = [];
                     for (var i = 0 ; i < models.length; i++) {
                   	  	var mdl = models[i];
                   	  	names.push(mdl.get('appName'));
                   	  	versions.push(mdl.get('version'));
                   	  	paths.push(mdl.get('path'));
                   	  	ids.push(mdl.get('id'));
                     }
                     this.updateStation(
                		 names,
                		 versions,
                		 paths,
                		 view.model,
                		 view.model.get('serverName'),
                		 view.model.get('fullCosUrl'), ids, false
                       	);
                 },

                 // get the fields for the dialog
        		updateFields : function (model, editMode, serverName, url) {
                    // define the form fields
            		var myForm = new UIForm({
           		    className: 'vertical',
           		    fields: FormUtils.getApplicationFields(),
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
           		         ApplicationPropsObj.addApplication(this, serverName, url);
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
        				headerStr = NLS.get('createApplication');
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
        return ApplicationPropsObj;
});

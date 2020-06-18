/*
 * This is the class that builds the main widget.
 * It is a hybrid skeleton in that is has a tree view as the root view but displays
 * facets for the selected items in the tree in the  right hand side.
 *
 * Skeleton uses the concept of UWA.Model,  UWA.Collection,  and UWA.View.
 *
 * It has the ServerStationCollection as the collection in the tree root view .
 * Three kinds of objects are displayed in the tree,  Servers,  Station Groups,  and Stations. Servers can have stations and groups.
 * Groups can have stations.
 */
define('DS/SMAExeCOSAdmin/SMAExeCOSAdmin',
    ['UWA/Core',
	 'DS/Controls/ButtonGroup',
	 'DS/Controls/Button',
     'DS/W3DXComponents/Skeleton',
     'DS/W3DXComponents/Views/Temp/TempHandlebars',
     'DS/SMAExeCOSAdmin/Forms/RegisterServer',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
     'DS/SMAExeCOSAdmin/Views/RendererUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
     ],
     function(UWA, ButtonGroup, Button,
		  Skeleton,
		  Handlebars,
		  RegisterServer,
		  COSUtils,
		  WSUtils,
		  RendererUtils,
		  COSInfo,
		  NLS) {

       'use strict';
       var addedPref = 0;
       var endEdit = 0;
       var myWidget = {};

	   	// helper function to show either date or image in the table column
       myWidget.initHandlebars = function  () { // require DS/W3DXComponents/Views/Temp/TempHandlebars as Handlebars.
           Handlebars.registerHelper('propertyHelper',  function(data,  obj) {
               var key = obj.property || obj,  type = obj.type || null,  result = data[key] || '';

               switch (type) {
               case 'date':
                   result = new Date(result *1000).toLocaleString();
                   break;
               case 'image':
            	 if (result.length){
            		 result = new Handlebars.SafeString('<img src=\'' + result + '\'>');
            	 }
                 break;
               default:
                   break;
               }

               return result;
           });
       };

     	var skeletonOptions = {
                // Renderer that is going to be used for the Root (panel 0),  if not specified the first declared renderer is used
                //root: 'toolRenderer',

                useRootChannelView: function () {
                	return COSInfo.getWidget().getValue('view') === 'channel';
                },

                responsiveTrigger: function () {
                    var viewType = COSInfo.getWidget().getView().type;

                    // If channel view is active then set responsive trigger to maximize
                    if (COSInfo.getWidget().getValue('view') === 'channel') {
                        return viewType === 'maximized' || viewType === 'fullscreen';
                    } else {

                        // If normal view,  then let the width threshold of the skeleton set the responsiveness
                        return false;
                    }
                }
    	};



	    // click action for register server button.  Brings up register dialog
        myWidget.onButtonClick = function () {
        	// check if use alias flag is set and if so display register form 
        	// with additional server prop id field
        	RegisterServer.showDialogAlias(null);
	   	};

		myWidget.onContextOK = function  () {

    		WSUtils.validateLicense('SIMEEXA_AP',
        			// if success ...finish loading the widget
                    function() {
			     		// clear the widget body
			     		COSInfo.getWidget().body.empty();

			     		//get the user's security context and check if owner
			        	var context = WSUtils.getSecurityContext();
			        	var isOwner = false;
			        	if (context && context.length >0) {
			        		var ctxArr = context.split('::');
			        		if (ctxArr.length === 2) {
			        			var ctxRole= ctxArr[1];
			        			isOwner = ctxRole.startsWith('VPLMAdmin');
			        		}
			        	}

			        	// get the renderers based on user's role
			     		var renderers = RendererUtils.getRenderers(isOwner);

			     		// create the skeleton for the widget using the renderers
			     		var skeleton = new Skeleton(renderers,  skeletonOptions);
			     		var outerDiv = UWA.createElement('div', {'class':'outerContainer',
			     			styles: {width: '100%',  height: '100%',  'min-height' : '100%'}});
			     		var topDiv = UWA.createElement('div', {'class':'topContainer', styles: {width: '100%',  height: '25px'}});
			     		var bottomDiv = UWA.createElement('div', {'class':'bottomContainer', styles:{width: '100%',  height: 'calc(100% - 25px)'}});
			     		topDiv.inject(outerDiv);
			     		bottomDiv.inject(outerDiv);
			     		// create the register server button if an owner
			        	if (isOwner) {
					            var buttonGroup = new ButtonGroup().inject(topDiv);
						         // Create a Button and initialise its properties
						         var button = new Button({icon : 'plus', label:NLS.get('registerServer'),
						        	 onClick: myWidget.onButtonClick});

						         // Insert the Button in the dom tree.
						         buttonGroup.addChild(button);
			        	}
			        	else {
			        		topDiv.hide();
			        	}

			        	skeleton.render().inject(bottomDiv);
			        	COSInfo.setContainer(outerDiv);
			        	outerDiv.inject(COSInfo.getWidget().body);
			        	COSInfo.setBones(skeleton);
    		 });
     	};

        myWidget.onLoad = function () {
             myWidget.initHandlebars();
     		// add security context preference if not already added
        	if (addedPref ===0) {
        		addedPref = 1;
	        	WSUtils.addSecurityContext(myWidget.onContextOK);
        	}
        	else {
            	if (endEdit ===0) {
            		endEdit = 1;
            		myWidget.onContextOK();
            	}
        	}
		};

     	// function that iterates over the server nodes and
     	// updates the badges on the tree nodes
     	// just do it once so set flag to false
		myWidget.updateTreeBadges = function () {
    		var treeView = COSInfo.getBones().getViewAt(0);
    		if (treeView) {
		        treeView.treeModel.getRoots().forEach(function (root) {
        			WSUtils.setServerBadge(root, root.fullCosUrl, root.getLabel(), false);
		        });
    		}
     	};

     	// function that iterates over the server nodes and if expanded
     	// re-expands the server node to get the latest data
		 myWidget.refreshTree = function () {
    		var treeView = COSInfo.getBones().getViewAt(0);
    		if (treeView) {
		        treeView.treeModel.getRoots().forEach(function (model) {
					if (model.isExpanded()) {
						model.collapseAll();
						model.expandAll();
					}
		        });
    		}

     	};

		// refresh method to refresh the tree and RHS of the widget if shown
        myWidget.onRefresh = function () {
    		WSUtils.validateLicense('SIMEEXA_AP',
    			// if success ...reload the widget
                function() {
					// try to get RHS view
		            var view1 = COSInfo.getBones().getViewAt(1);
		            if (view1 ) {
		            	// if we have check if we have a collection being displayed
		            	// if yes re-fetch the collection to update
		            	if (view1.collection) {
		            		view1.collection.fetch();
		            	}
		            	// else check if properties are being shown so we have the properties form
		            	else if (view1._form) {

		            		// get the url to be used to get the latest data
			            	var fullCosUrl = view1._form.model.get('fullCosUrl');

			            	// if not defined just log message
			            	if (fullCosUrl !== undefined && fullCosUrl.length > 0){
			            		// try to get generalInfo if there dealing with station/group properties
			            		if (view1.model.get('GeneralInfo')) {
									WSUtils.stationGetStatus(fullCosUrl, view1.model.get('name'),
										// if success ...display status returned
										function(data) {
											var obj = JSON.parse(data);
											var myView = COSInfo.getBones().getViewAt(1);
											myView.model._attributes.GeneralInfo = obj.Station.GeneralInfo;
											myView.model._attributes['@status'] = obj.Station['@status'];
											myView.model._attributes.allowedUsers = obj.Station.GeneralInfo['@allowedUsers'];
											myView.model._attributes.useCount = obj.Station.GeneralInfo['@useCount'];
											myView.model._attributes.ApplicationList = obj.Station.ApplicationList;
											myView.model._attributes.SharedFSList = obj.Station.SharedFSList;

											// need to reset the property list on the station
							        		COSUtils.setPropertyMap(obj.Station);
											myView.model._attributes.PropertyList = obj.Station.PropertyList;
											myView.model.dispatchEvent('onChange');
										},
										// if fail just sync
										function () {
											var myView = COSInfo.getBones().getViewAt(1);
											myView._form.syncFields();
										});
			            		}
			                	else {
			                		// sync the fields which will get the latest status
			                		var myView = COSInfo.getBones().getViewAt(1);
									myView._form.syncFields();
			                	}
		                	}
		            	}
		            	// if RHS is a server can refresh tree
		            	// otherwise refresh tree would slide back RHS  so skip
		            	if (view1.model.id.indexOf('@@') === -1) {
		            		myWidget.refreshTree();
		            	}
		            	// if RHS station or group refresh badges
		            	else {
		            		myWidget.updateTreeBadges();
		            	}
		            }
		            else {
			            // update the tree
		            	myWidget.refreshTree();
		            }
            },
             // if fail clear the widget body
             function () {
            	COSInfo.getWidget().body.empty();
             });
		};
		myWidget.endEdit = function () {
			endEdit =1;
			myWidget.onContextOK();
 		};
        return myWidget;
   	});


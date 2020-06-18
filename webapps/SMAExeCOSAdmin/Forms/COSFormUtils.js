define('DS/SMAExeCOSAdmin/Forms/COSFormUtils',
		['UWA/Core', 
	     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
	     'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
		 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'],
		/*
		 * utility class to get fields for various forms
		 */
	function (UWA, COSInfo,  COSUtils,NLS )
	{

    	'use strict';

		var FormUtils = {
			// method to get a drop down list of the groups
			// if the given model has a group put it first in the list
			getGroupSelectArray:function (model, showEmpty) {
				var modelUrl = model._attributes.fullCosUrl;
				var grp = model._attributes['@group'];
				var modelDrm = '';
				if (model.get('GeneralInfo')) {
					modelDrm = model.get('GeneralInfo')['@drmMode'];
				}
				var groupArray = [];
				if (showEmpty) {
					groupArray.push({label:'', value:''});
				}
				model.collection._models.forEach(function (mdl){
					if (mdl.get('fullCosUrl') === modelUrl && mdl.get('GeneralInfo') &&
							mdl.get('GeneralInfo')['@drmMode'].endsWith('Grp')) {
						if (modelDrm+'Grp' === mdl.get('GeneralInfo')['@drmMode']) {
							var name =  mdl._attributes['@name'];
							groupArray.push({label:name, value:name});
							if (grp === name) {
								groupArray.reverse();
							}
						}
					}
				});
				return groupArray;
			},

			getDrmDropDown : function () {
	        	var opts = [];
	        	
	        	var bones = COSInfo.getBones();
	        	if (bones ) {
		        	var view = bones.getViewAt(1);
		        	if (view ) {
			        	for (var idx in view.model.get('serverDrms')) {
			        		var drm = view.model.get('serverDrms')[idx];
			        		opts.push({label: drm + ' Group', value: drm+'Grp' })
			        	}
		        	}
	        	}
	        	if (opts.length===0) {
	        		opts.push({label:'fiper Group', value:'fiperGrp' })
	        		opts.push({label:'Lsf Group', value:'LsfGrp' })
	        	}
	        	return opts;
			},
			
			getStationFields : function (model, editMode, serverName, viewMode, forGroup) {
				// field variables
				// if model is passed in get the values from the model
    			var sName =  '';
                var desc = '';
                var wDir = '';
                var sDir =  '';
                var tDir = '';
                var users =  '';
                var affin = '';
                var concur ='';
                var domain ='';
                var ip ='';
                var grpArr =  [];
                var logLevel = 'Info';
                var runAs = 'default';
                var os = 'WINDOWS';
                var drmMode = 'fiper';
                var groupModel = forGroup;

                // if the server name is passed in with @@
                // then it was passed in as a group@@server
                // get the server name and add the group name
                // to the group array since we are working with a station that is part of a group
                var splitServer = serverName.split('@@');
                if (splitServer.length >1) {
                	serverName = splitServer[1];
                	grpArr.push(splitServer[0], splitServer[0]);
                }

                // if the group array only has one item it is the empty name so remove it
                if (grpArr.length === 1) {
                	grpArr.pop();
                }

                var dropDownVals = [];
                if (forGroup) {
                	dropDownVals = FormUtils.getDrmDropDown();
                }

                var fields = [];
                fields.push(
                	{
           		        type: 'text',
           		        label: NLS.get('name'),
                        name : 'stationName',
                        value: sName,
                        disabled : editMode,
                        required : !editMode && !viewMode,
                        attributes : {
                            'data-attr' : 'id',
                            'data-editable' : false,
                            useGenInfo : false
                        }
                	});
                fields.push(
        		    {
           		        type: 'text',
           		        label: NLS.get('description'),
           		        value:desc,
                        name : 'description',
                        multiline : true,
                        rows: 5,
                        attributes : {
                            'data-attr' : '@description',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        className: 'verticalResizeTextArea'
        		    });

                fields.push(
                    	{
	           		        type: viewMode || editMode?'text':'select',
	           		        label: NLS.get('opSys'),
	           		        name : 'os',
	           		        value: os,
	                        disabled : editMode,
            		        options: [
                  		            { label: 'WINDOWS', value: 'WINDOWS' },
                  		            { label: 'UNIX', value: 'UNIX' }
                  		        ],
	                        attributes : {
	                            'data-attr' :'@os',
	                            'data-editable' : false,
	                            useGenInfo : true
	                        }
                    	});

                fields.push(
                    	{
	           		        type: 'text',
	           		        label: NLS.get('tempDir'),
	           		        name : 'tempDir',
	           		        value: tDir,
	                        attributes : {
	                            'data-attr' : '@tempDir',
	                            'data-editable' : false,
	                            useGenInfo : true
	                        }
                    	});
                fields.push(
        		    {
           		        type: 'text',
           		        label: NLS.get('workDir'),
                        name : 'workDir',
                        value: wDir,
                        attributes : {
                            'data-attr' : '@workDir',
                            'data-editable' : false,
                            useGenInfo : true
                        }
        		    });
                fields.push(
        		    {
           		        type: 'text',
           		        label: NLS.get('stageDir'),
                        name : 'stageDir',
                        value: sDir,
                        attributes : {
                            'data-attr' :'@stageDir',
                            'data-editable' : false,
                            useGenInfo : true
                        }
        		    });
                fields.push(
        		    {
           		        type: 'text',
           		        label: NLS.get('othersAffinity'),
                        name : 'othersAffinity',
                        value: affin,
                        attributes : {
                            'data-attr' :'@othersAffinity',
                            'data-editable' : false,
                            useGenInfo : true
                        }
        		    });
                fields.push(
        		    {
           		        type: 'text',
           		        label: NLS.get('allowedUsers'),
                        name : 'allowedUsers',
                        value: users,
                        attributes : {
                            'data-attr' : '@allowedUsers',
                            'data-editable' : false,
                            useGenInfo : true
                        }
        		    });
                // show drm drop down for groups
                if (groupModel) {
                    fields.push(
                        	{
    	           		        type: viewMode || editMode?'text':'select',
    	           		        label: NLS.get('drmMode'),
    	           		        name : 'drmMode',
    	           		        value: drmMode,
    	                        disabled : editMode,
                		        options: dropDownVals,
    	                        attributes : {
    	                            'data-attr' :'@drmMode',
    	                            'data-editable' : false,
    	                            useGenInfo : true
    	                        }
                        	});

                }
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('concurrency'),
                            name : 'concurrency',
                            value: concur,
                            attributes : {
                                'data-attr' :'@concurrency',
                                'data-editable' : false,
	                            useGenInfo : true
                            }
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('domain'),
                            name : 'domain',
                            value: domain,
                            attributes : {
                                'data-attr' : '@domain',
                                'data-editable' : false,
	                            useGenInfo : true
                            }
            		    });
                // do not show ip  or DNS for groups
                if (!groupModel){
	                fields.push(
	            		    {
	               		        type: 'text',
	               		        label: NLS.get('stationIP'),
	                            name : 'ip',
	                            value: ip,
	                            attributes : {
	                                'data-attr' :'@hostIP',
	                                'data-editable' : false,
		                            useGenInfo : true
	                            }
	            		    });
                }
                fields.push(
        		    {
        		        type: viewMode?'text':'select',
        		        label: NLS.get('logLevel'),
        		        name: 'logLevel',
        		        options: [
        		            { label: 'Debug', value: 'Debug' },
        		            { label: 'Error', value: 'Error' },
        		            { label: 'Info', value: 'Info' },
        		            { label: 'System Error', value: 'SysError' },
        		            { label: 'Warning', value: 'Warning' }
        		        ],
        		        value: logLevel,
                        attributes : {
                            'data-attr' :'@logLevel',
                            'data-editable' : false,
                            useGenInfo : true
                        }
        		    });
                fields.push(
        		    {
        		        type: viewMode?'text':'select',
        		        label:  NLS.get('runAs'),
        		        name: 'disableRunAs',
        		        options: [
        		            { label: 'Default', value: 'default' },
        		            { label: 'Disabled', value: 'disabled' },
        		            { label: 'Enabled', value: 'enabled' }
        		        ],
        		        value: runAs,
                        attributes : {
                            'data-attr' :'@disableRunAs',
                            'data-editable' : false,
                            useGenInfo : true
                        }
        		    });
                return fields;
			},
			getStationROFields : function (model, editMode, serverName, viewMode, forGroup) {
				// field variables
				// if model is passed in get the values from the model
                var groupModel = forGroup;
                var grpArr =  [];

                // if we have a model get the field values from the model
                if (model) {
                     grpArr =  FormUtils.getGroupSelectArray(model, true);
      			   	 if (model._attributes.GeneralInfo['@drmMode'].endsWith('Grp')){
      			   		 groupModel = true;
      			   	 }
                }
                
                var dropDownVals = [];
                if (forGroup) {
                	dropDownVals = FormUtils.getDrmDropDown();
                }


                // if the server name is passed in with @@
                // then it was passed in as a group@@server
                // get the server name and add the group name
                // to the group array since we are working with a station that is part of a group
                var splitServer = serverName.split('@@');
                if (splitServer.length >1) {
                	serverName = splitServer[1];
                	grpArr.push(splitServer[0], splitServer[0]);
                }

                // if the group array only has one item it is the empty name so remove it
                if (grpArr.length === 1) {
                	grpArr.pop();
                }

                var fields = [];
                // only display status for view mode since can't create or edit
                // do not display for groups since staus does not have meaning
                if (viewMode && !groupModel) {
                    fields.push(
                		    {
    	           		        type: 'text',
    	           		        label: NLS.get('status'),
    	                        disabled : viewMode,
    	                        name : 'status',
	               		        value : 'LOADING...'
                		    });
                }

                fields.push(
        		    {
           		        type: 'text',
           		        label: NLS.get('description'),
                        name : 'description',
                        disabled : !editMode,
                        multiline : true,
                        rows: 5,
                        attributes : {
                            'data-attr' : '@description',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        className: 'verticalResizeTextArea'
        		    });

                // do not show group field for a group only for a sttation
                if (!groupModel) {
	                fields.push(
	                	{
	           		        type: viewMode?'text':'select',
	           		        label: NLS.get('group'),
	                        name : 'group',
	                        options: grpArr,
	                        attributes : {
	                            'data-attr' : '@group',
	                            'data-editable' : false,
	                            useGenInfo : false
	                        },
	                        disabled : !editMode
	                	});
                }
                fields.push(
                    	{
	           		        type: viewMode || editMode?'text':'select',
	           		        label: NLS.get('opSys'),
	           		        name : 'os',
	                        disabled : true,
            		        options: [
                  		            { label: 'WINDOWS', value: 'WINDOWS' },
                  		            { label: 'UNIX', value: 'UNIX' }
                  		        ],
	                        attributes : {
	                            'data-attr' :'@os',
	                            'data-editable' : false,
	                            useGenInfo : true
	                        }
                    	});

                // do not show osName, osVersion and osArch in create dialog
                // disable the fields in edit mode
                if (editMode || viewMode && !groupModel) {
                    fields.push(
                        	{
    	           		        type: 'text',
    	           		        label:  NLS.get('osName'),
    	           		        name : 'osName',
    	                        attributes : {
    	                            'data-attr' :'@osName',
    	                            'data-editable' : false,
    	                            useGenInfo : true
    	                        },
    	                        disabled : true
                        	});
                    fields.push(
                        	{
    	           		        type: 'text',
    	           		        label: NLS.get('osVersion'),
    	           		        name : 'osVersion',
    	                        attributes : {
    	                            'data-attr' :'@osVersion',
    	                            'data-editable' : false,
    	                            useGenInfo : true
    	                        },
    	                        disabled : true
                        	});
                    fields.push(
                        	{
    	           		        type: 'text',
    	           		        label: NLS.get('osArch'),
    	           		        name : 'osArch',
    	                        attributes : {
    	                            'data-attr' :'@osArch',
    	                            'data-editable' : false,
    	                            useGenInfo : true
    	                        },
    	                        disabled : true
                        	});
                }
                // show non modifiable drm mode and use count in view and edit but not create
                if ((editMode || viewMode) && !groupModel) {
                    fields.push(
                		    {
    	           		        type: 'text',
    	           		        label: NLS.get('drmMode'),
                                name : 'drmMode',
    	                        attributes : {
    	                            'data-attr' :'@drmMode',
    	                            'data-editable' : false,
    	                            useGenInfo : true
    	                        },
    	                        disabled : true
                		    });
                }
                // for groups show drmMode pull-down
                else if (groupModel) {
                    fields.push(
                        	{
    	           		        type: viewMode || editMode?'text':'select',
    	           		        label: NLS.get('drmMode'),
    	           		        name : 'drmMode',
    	                        attributes : {
    	                            'data-attr' :'@drmMode',
    	                            'data-editable' : false,
    	                            useGenInfo : true
    	                        },
    	                        disabled : true,
    	                        options: dropDownVals
                        	});
                }
                // do not show ip  or DNS for groups
                if (!groupModel){
	                fields.push(
	            		    {
	               		        type: 'text',
	               		        label: NLS.get('stationIP'),
	                            name : 'ip',
	                            attributes : {
	                                'data-attr' :'@hostIP',
	                                'data-editable' : false,
    	                            useGenInfo : true
	                            },
    	                        disabled : !editMode
	            		    });
	                if (editMode || viewMode) {
	                    fields.push(
	                        	{
	    	           		        type: 'text',
	    	           		        label: NLS.get('stationAffinityName'),
	    	           		        name : 'hostDNS',
	    	                        attributes : {
	    	                            'data-attr' :'@hostDNS',
	    	                            'data-editable' : false,
	    	                            useGenInfo : true
	    	                        },
	    	                        disabled : true
	                        	});
	                }
                }
                return fields;
			},
			getStationGeneralFields : function (model, editMode, serverName, viewMode, forGroup) {
				// field variables
				// if model is passed in get the values from the model
                var grpArr =  [];
                var groupModel = forGroup;

                // if we have a model get the field values from the model
                if (model) {
                     grpArr =  FormUtils.getGroupSelectArray(model, true);
      			   	 if (model._attributes.GeneralInfo['@drmMode'].endsWith('Grp')){
      			   		 groupModel = true;
      			   	 }

                }

                // if the server name is passed in with @@
                // then it was passed in as a group@@server
                // get the server name and add the group name
                // to the group array since we are working with a station that is part of a group
                var splitServer = serverName.split('@@');
                if (splitServer.length >1) {
                	serverName = splitServer[1];
                	grpArr.push(splitServer[0], splitServer[0]);
                }

                // if the group array only has one item it is the empty name so remove it
                if (grpArr.length === 1) {
                	grpArr.pop();
                }

                var fields = [];
                // only display status for view mode since can't create or edit
                // do not display for groups since staus does not have meaning

                fields.push(
                    	{
	           		        type: 'text',
	           		        label: NLS.get('tempDir'),
	           		        name : 'tempDir',
	                        attributes : {
	                            'data-attr' :'@tempDir',
	                            'data-editable' : false,
	                            useGenInfo : true
	                        },
                            placeholder: NLS.get('tempDirHint'),
	                        disabled : !editMode
                    	});
                // show non modifiable install and config directory in view and edit but not create
                if (editMode || viewMode) {
                    fields.push(
                		    {
    	           		        type: 'text',
    	           		        label: NLS.get('installDir'),
                                name : 'installDir',
    	                        attributes : {
    	                            'data-attr' :'@installDir',
    	                            'data-editable' : false,
    	                            useGenInfo : true
    	                        },
                                placeholder: NLS.get('installDirHint'),
    	                        disabled : true
                		    });
                    fields.push(
                		    {
    	           		        type: 'text',
    	           		        label: NLS.get('configDir'),
                                name : 'confDir',
    	                        attributes : {
    	                            'data-attr' :'@configDir',
    	                            'data-editable' : false,
    	                            useGenInfo : true
    	                        },
                                placeholder: NLS.get('configDirHint'),
    	                        disabled : true
                		    });
                }
                fields.push(
        		    {
           		        type: 'text',
           		        label: NLS.get('workDir'),
                        name : 'workDir',
                        attributes : {
                            'data-attr' :'@workDir',
                            'data-editable' : false,
                            useGenInfo : true
                        },
                        placeholder: NLS.get('workDirHint'),
                        disabled : !editMode
        		    });
                fields.push(
        		    {
           		        type: 'text',
           		        label: NLS.get('othersAffinity'),
                        name : 'othersAffinity',
                        attributes : {
                            'data-attr' :'@othersAffinity',
                            'data-editable' : false,
                            useGenInfo : true
                        },
                        placeholder: NLS.get('othersAffinityHint'),
                        disabled : !editMode
        		    });
                fields.push(
        		    {
           		        type: 'text',
           		        label: NLS.get('allowedUsers'),
                        name : 'allowedUsers',
                        attributes : {
                            'data-attr' :'@allowedUsers',
                            'data-editable' : false,
                            useGenInfo : true
                        },
                        placeholder: NLS.get('allowedUsersHint'),
                        disabled : !editMode
        		    });
                // show non modifiable use count in view and edit for station but not for group
                if ((editMode || viewMode) && !groupModel) {
                    fields.push(
                		    {
    	           		        type: 'text',
    	           		        label: NLS.get('useCount'),
                                name : 'useCount',
    	                        attributes : {
    	                            'data-attr' :'@useCount',
    	                            'data-editable' : false,
    	                            useGenInfo : true
    	                        },
    	                        placeholder: NLS.get('useCountHint'),
    	                        disabled : true
                		    });
                }
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('concurrency'),
                            name : 'concurrency',
                            attributes : {
                                'data-attr' :'@concurrency',
                                'data-editable' : false,
	                            useGenInfo : true
                            },
                            placeholder: NLS.get('concurrencyHint'),
                            disabled : !editMode
            		    });
                return fields;
			},
			getStationLoggingFields : function (model, editMode, serverName, viewMode) {
                var fields = [];
                fields.push(
        		    {
        		        type: viewMode?'text':'select',
        		        label: NLS.get('logLevel'),
        		        name: 'logLevel',
        		        options: [
        		            { label: 'Debug', value: 'Debug' },
        		            { label: 'Error', value: 'Error' },
        		            { label: 'Info', value: 'Info' },
        		            { label: 'System Error', value: 'SysError' },
        		            { label: 'Warning', value: 'Warning' }
        		        ],
                        attributes : {
                            'data-attr' :'@logLevel',
                            'data-editable' : false,
                            useGenInfo : true
                        },
                        disabled : !editMode
        		    });
                fields.push(
                    	{
               		        type: 'text',
               		        label: NLS.get('numBackups'),
                            name : 'numBackups',
	                        placeholder: NLS.get('numBackupsHint'),
                            disabled : !editMode
                    	});
                fields.push(
                    	{
               		        type: 'text',
               		        label: NLS.get('maxSize'),
                            name : 'maxSize',
	                        placeholder: NLS.get('maxSizeHint'),
                            disabled : !editMode
                    	});
                fields.push(
            		    {
            		        type: viewMode?'text':'select',
            		        label: NLS.get('saveLogOnError'),
            		        name: 'saveLogOnError',
            		        options: [
            		            { label: NLS.get('False'), value: 'false' },
            		            { label: NLS.get('True'), value: 'true' }
            		        ],
                            disabled : !editMode
            		    });
                return fields;
			},
			getStationAdvancedFields : function (model, editMode, serverName, viewMode) {
                var fields = [];
                fields.push(
        		    {
           		       type: 'text',
           		       label: NLS.get('moreProps'),
                       name : 'moreProps',
                       multiline : true,
                       rows: 5,
                      className: 'verticalResizeTextArea',
                      placeholder: NLS.get('morePropsHint'),
                      disabled : !editMode
        		    });
                fields.push(
        		    {
           		        type: 'text',
           		        label: NLS.get('stageDir'),
                        name : 'stageDir',
                        attributes : {
                            'data-attr' :'@stageDir',
                            'data-editable' : false,
                            useGenInfo : true
                        },
                        placeholder: NLS.get('stageDirHint'),
                        disabled : !editMode
        		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('domain'),
                            name : 'domain',
                            attributes : {
                                'data-attr' :'@domain',
                                'data-editable' : false,
	                            useGenInfo : true
                            },
	                        placeholder: NLS.get('domainHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('fastFlowResults'),
                            name : 'fastFlowResults',
	                        placeholder: NLS.get('fastFlowResultsHint'),
                            disabled : !editMode
            		    });
                fields.push(
        		    {
        		        type: viewMode?'text':'select',
        		        label:  NLS.get('runAs'),
        		        name: 'disableRunAs',
        		        options: [
        		            { label: 'Default', value: 'default' },
        		            { label: 'Disabled', value: 'disabled' },
        		            { label: 'Enabled', value: 'enabled' }
        		        ],
        		        events:{
        		        	// add an event for change so can warn user about station restart
        		        	onChange:function (e) {
        		        		// get current model info
        	            		var viewAt1 = COSInfo.getBones().getViewAt(1);
        	            		if (viewAt1 ) {
        	            			var genInf = viewAt1.model.get('GeneralInfo');
        	            			if (genInf  ) {
        	            				// get field value
        	            				var fieldVal = this.getValue()[0];
        	            				// get model value
        	            				var modelVal = genInf["@disableRunAs"];
        	            				// if different display info message about restart
        	            				if (fieldVal !== modelVal){
        	            					COSUtils.displayInfo(NLS.get('runAsChanged'),  true);
        	            				}
        	            			}
        	            		}
        	                }
        		        },
                        attributes : {
                            'data-attr' :'@disableRunAs',
                            'data-editable' : false,
                            useGenInfo : true
                        },
                        disabled : !editMode
        		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('subStarttime'),
                            name : 'subStarttime',
	                        placeholder: NLS.get('subStarttimeHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('subLaunchtimeout'),
                            name : 'subLaunchtimeout',
	                        placeholder: NLS.get('subLaunchtimeoutHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('subKeepalive'),
                            name : 'subKeepalive',
	                        placeholder: NLS.get('subKeepaliveHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('fcsEnginedir'),
                            name : 'fcsEnginedir',
	                        placeholder: NLS.get('fcsEnginedirHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('fcsServerStagingdir'),
                            name : 'fcsServerStagingdir',
	                        placeholder: NLS.get('fcsServerStagingdirHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
            		        type: viewMode?'text':'select',
            		        label: NLS.get('cacheplmfiles'),
            		        name: 'cacheplmfiles',
            		        options: [
            		            { label: NLS.get('False'), value: 'false' },
            		            { label: NLS.get('True'), value: 'true' }
            		        ],
                            disabled : !editMode
            		    });
                fields.push(
            		    {
            		        type: viewMode?'text':'select',
            		        label: NLS.get('skiplock'),
            		        name: 'skiplock',
            		        options: [
            		            { label: NLS.get('False'), value: 'false' },
            		            { label: NLS.get('True'), value: 'true' }
            		        ],
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('certificate'),
                            name : 'certificate',
	                        placeholder: NLS.get('certificateHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('certificateKey'),
                            name : 'certificateKey',
	                        placeholder: NLS.get('certificateKeyHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('certificateCert'),
                            name : 'certificateCert',
	                        placeholder: NLS.get('certificateCertHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('leaseinterval'),
                            name : 'leaseinterval',
	                        placeholder: NLS.get('leaseintervalHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
            		        type: viewMode?'text':'select',
            		        label: NLS.get('predefinedonly'),
            		        name: 'predefinedonly',
            		        options: [
            		            { label: NLS.get('False'), value: 'false' },
            		            { label: NLS.get('True'), value: 'true' }
            		        ],
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('maxquiescetime'),
                            name : 'maxquiescetime',
	                        placeholder: NLS.get('maxquiescetimeHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('jobLogRepository'),
                            name : 'jobLogRepository',
	                        placeholder: NLS.get('jobLogRepositoryHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('shareableLicPath'),
                            name : 'shareableLicPath',
	                        placeholder: NLS.get('shareableLicPathHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('shareableLicRetryNum'),
                            name : 'shareableLicRetryNum',
	                        placeholder: NLS.get('shareableLicRetryNumHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('shareableLicRetryInterval'),
                            name : 'shareableLicRetryInterval',
	                        placeholder: NLS.get('shareableLicRetryIntervalHint'),
                            disabled : !editMode
            		    });
                return fields;
			},
			getStationComputeFields : function (model, editMode) {
                var fields = [];
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('mpiPath'),
                            name : 'mpiPath',
                            disabled : !editMode,
                            placeholder: NLS.get('mpiPathHint')
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('largeFileDir'),
                            name : 'largeFileDir',
	                        placeholder: NLS.get('largeFileDirHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('portRange'),
                            name : 'portRange',
	                        placeholder: NLS.get('portRangeHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('stageFileScript'),
                            name : 'stageFileScript',
	                        placeholder: NLS.get('stageFileScriptHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('clientServices'),
                            name : 'clientServices',
	                        placeholder: NLS.get('clientServicesHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('computeServices'),
                            name : 'computeServices',
	                        placeholder: NLS.get('computeServicesHint'),
                            disabled : !editMode
            		    });
                return fields;
			},
			getStationResultsFields : function (model, editMode) {
                var fields = [];
                fields.push(
        		    {
           		        type: 'text',
           		        label: NLS.get('parameterMatch'),
                        name : 'parameterMatch',
                        placeholder: NLS.get('parameterMatchHint'),
                        disabled : !editMode
        		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('exposedName'),
                            name : 'exposedName',
	                        placeholder: NLS.get('exposedNameHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('exposedPorts'),
                            name : 'exposedPorts',
	                        placeholder: NLS.get('exposedPortsHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('exposedIPAddr'),
                            name : 'exposedIPAddr',
	                        placeholder: NLS.get('exposedIPAddrHint'),
                            disabled : !editMode
            		    });
                fields.push(
            		    {
               		        type: 'text',
               		        label: NLS.get('resultsServices'),
                            name : 'resultsServices',
	                        placeholder: NLS.get('resultsServicesHint'),
                            disabled : !editMode
            		    });
                return fields;
			},
			getApplicationFields : function () {
                var fields = [];
                fields.push(
                	{
           		        type: 'text',
           		        label: NLS.get('name'),
                        name : 'applName',
                        value: '',
                        required : true
                	});
                fields.push(
                	{
           		        type: 'text',
           		        label: NLS.get('version'),
                        name : 'applVersion',
                        value: '',
                        required : true
                	});

                fields.push(
            		{
            			type: 'text',
            			label: NLS.get('path'),
            			name : 'applPath',
            			value: '',
            			required : true
            		});
                return fields;
			},
			getDriveFields : function () {
                var fields = [];
                fields.push(
                	{
           		        type: 'text',
           		        label: NLS.get('name'),
                        name : 'driveName',
                        value: '',
                        required : true
                	});
                fields.push(
            		{
            			type: 'text',
            			label: NLS.get('path'),
            			name : 'drivePath',
            			value: '',
            			required : true
            		});
                fields.push(
            		{
            			type: 'text',
            			label: NLS.get('description'),
            			name : 'description',
            			value: ''
            		});
                return fields;
			}


		};
		return FormUtils;
	});

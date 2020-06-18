define('DS/CfgEffectivityCommands/commands/CfgEffCmd', 
   [   
    'UWA/Core',
    'DS/ApplicationFrame/Command',   
    'DS/PADUtils/PADContext',	
	'DS/Utilities/Utils',    
    'DS/CfgBaseUX/scripts/CfgUtility',
    'DS/CfgBaseUX/scripts/CfgData',
	'DS/CfgBaseUX/scripts/CfgController',
    'text!DS/CfgBaseUX/assets/CfgUXEnvVariables.json'

   ], function (UWACore, AFRCommand, PADContext, Utils, CfgUtility, CfgData, CfgController, CfgUXEnvVariables_text) {

       'use strict';

       var CfgEffCmd = AFRCommand.extend({

           init: function (options) {

               this.CfgUXEnvVariables = JSON.parse(CfgUXEnvVariables_text);

               this._parent(options, {
                   mode: 'exclusive',
                   isAsynchronous: false
               });

               this.isRoot = true;

               var that = this;
				if(window.__karma__ !== undefined){					
				    window.jQueryURL = 'VENENO6WPlugins/plugins/jquery/latest/jquery';
				}			
				else{
				    window.jQueryURL = '../webapps/VENENO6WPlugins/plugins/jquery/latest/jquery';
				}
				
               if (window.cfgCmdWidgetData == undefined || window.cfgCmdWidgetData == null) {
                   window.cfgCmdWidgetData = {
					   '_isConfigAvailable':false,
					   '_isDecouplingActivated':false
				   };
				   this._setStateCmd();                   
				   this._initWSCalls();
               }
			   else{	
				  this._initCmd();
			   }
                        

           },
           _initWSCalls: function () {
               var that = this;
               CfgController.init();
               if (widget.getValue('x3dPlatformId'))
                   enoviaServerFilterWidget.tenant = widget.getValue('x3dPlatformId');
               else
                   enoviaServerFilterWidget.tenant = 'OnPremise';

               CfgUtility.populate3DSpaceURL().then(
                   function () {
                       if (widget.getValue('x3dPlatformId'))
                           enoviaServerFilterWidget.tenant = widget.getValue('x3dPlatformId');
                       else
                           enoviaServerFilterWidget.tenant = 'OnPremise';

                       CfgUtility.populateSecurityContext().then(
                        function () {
                            if (widget.getValue('x3dPlatformId'))
                                enoviaServerFilterWidget.tenant = widget.getValue('x3dPlatformId');
                            else
                                enoviaServerFilterWidget.tenant = 'OnPremise';
                            /* MAND IR-690629-3DEXPERIENCER2019x checkDecouplingActivation service call which was failing with error code 403 can be  removed (during PSE init) as decoupling is by default enabled on 19x. however root cause for this service (getconfigurationSettings for decoupling) failure is still unknown */
                                   // CfgUtility.checkDecouplingActivation().then(
                                       // function (response) {
                                           // if (response.decoupling == true) {
                                                window.cfgCmdWidgetData._isDecouplingActivated = true;
                                                console.log('Decoupling activated');
                                                CfgUtility.rolesAvailable(function (userGrantedRoles) {
                                                    if (userGrantedRoles.isCFGRoleAvail) {
                                                        window.cfgCmdWidgetData._isConfigAvailable = true;
                                                        console.log('CFG License available');
                                                        that._initCmd();
                                                    }
                                                    else {
                                                        window.cfgCmdWidgetData._isConfigAvailable = false;
                                                        console.log('CFG License not available');
                                                    }
                                                });
                                            //}
                                           /* else {
                                                window.cfgCmdWidgetData._isDecouplingActivated = false;
                                                console.log('Decoupling not activated');
                                            }*/
                                       // },
                                        /*function (error_response) { console.log(error_response); }*/
                                       // );                                
                        }
                       );
                   }
               );
           },
		   _initCmd : function(){		   
			   
			  
			   
			   if (widget) {
                 widget.addEvent('onResize', this._onResize.bind(this));
               }

               this._SelectorManager = this.getSelectorManager();

               if (null !== this._SelectorManager) {
                   if (undefined !== this._SelectorManager.onChange) {
                       var that = this;
                       var debounceSelection = Utils.debounce(function (data) {
                           that._checkSelection(data);
                       }, 1000);
                       this._SelectorManager.onChange(debounceSelection);
                   } else {
                       Logger.log('Define Filter Cmd / The onChange() function is not implemented !');
                   }
               }
               if (this._id == 'CopyVariantEffectivity') {
                   widget.addEvent('onRefresh', this._onRefresh.bind(this));
                   CfgData.isVariantEffAvailable = ' ';
               }
			   
			   var that = this;
          
               if (PADContext.get !== undefined && PADContext.get() !== null) {
                   PADContext.get().addEvent('editModeModified', function (state) {
                       if (state === true) {
                           that._checkSelection();
                       } else {
                           that.disable();
                       }
                   });
               }
			   
			   this._setStateCmd();
			   
		   },		
           _onResize: function () {

               this._setStateCmd();
           },

           _checkSelection: function () {
               var instanceLength
               this._SelectedID = '';

               var data = this.getData();
               if (data.selectedNodes.length === 1) {
                   this._SelectedID = data.selectedNodes[0].id || '';
                   this._SelectedAlias = data.selectedNodes[0].alias || '?';
                   this.isRoot = data.selectedNodes[0].isRoot;

               }


               this._setStateCmd();

           },

           getSelectorManager: function () {
               if (PADContext.get !== undefined && PADContext.get() !== null)
                   return PADContext.get().getPADTreeDocument().getXSO();
               else
                   return null;
           },

           getData: function () {
               var data = { "selectedNodes": [] };

               if (PADContext.get !== undefined && PADContext.get() !== null) {
                   var selectednodes = PADContext.get().getPADTreeDocument().getSelectedNodes();
					data.padNodes = selectednodes;
				 data.PADContext = PADContext;
                   var i, length = selectednodes.length;
                   for (i = 0; i < length; i++) {
                       if (selectednodes[i].isRoot()) {
                           //Nothing to do
                           console.log('This is a root node');
                           var item = {
                               id: selectednodes[i].getID(),
                               alias: selectednodes[i].getLabel(),
                               isRoot: true
                           };
                           data.selectedNodes.push(item);
                       }
                       else {
                           console.log('This is not a root node');
                           var item = {
                               id: selectednodes[i].getRelationID(),							  
                               alias: selectednodes[i].getLabel(),
                               isRoot: false,
                               VPMRef: selectednodes[i].options.type,
                               parentID: selectednodes[i].getParent().getID(),
                               parentalias: selectednodes[i].getParent().getLabel(),
                               effectivity: selectednodes[i].options.grid["Effectivity"],
                               variantEffectivity: selectednodes[i].options.grid["VariantEffectivity"]
                           };
                           data.selectedNodes.push(item);
                       }
                   }
               }
               return data;
           },

           getCommandState: function () {
               var isEnable = 1;
               if (!PADSession.isUsingIndex()) {
                   isEnable = 0;
               }
               return isEnable;
           },


           _setStateCmd: function () {

               var isCmdEnable = false;

               if (window.cfgCmdWidgetData._isDecouplingActivated === true && window.cfgCmdWidgetData._isConfigAvailable === true) {

                   if (this._SelectedID !== undefined && this._SelectedID !== '' && this.isRoot === false) {
                       isCmdEnable = true;
                   }
               }

               if (PADContext.get !== undefined && PADContext.get() !== null && PADContext.get().getEditMode() !== true) {
                   isCmdEnable = false;
               }

               if (this._id == 'PasteVariantEffectivity') {
                   var copiedInstance = CfgData.isVariantEffAvailable;
                   if (copiedInstance == undefined || copiedInstance == ' ')
                       isCmdEnable = false;
               }

               if (isCmdEnable === true)
                   this.enable();
               else
                   this.disable();

           },

           execute: function () {
               console.log('to be overridden by Variant/Evolution command');
           }

       });

       return CfgEffCmd;
   });



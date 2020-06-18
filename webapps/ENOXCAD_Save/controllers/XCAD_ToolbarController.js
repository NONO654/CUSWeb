define('DS/ENOXCAD_Save/controllers/XCAD_ToolbarController', [
	'UWA/Core',
	'DS/WebappsUtils/WebappsUtils',
	'DS/Controls/ComboBox', 
	'DS/Controls/Button', 
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD',
	'DS/ENOXCAD_Save/controllers/XCAD_FilterCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_NewFileNameCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_NewRevCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_ReserveCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_UnReserveCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_SaveAsNewCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_ToggleRightPanelCmd'
	], function(UWACore,WebappsUtils, WUXComboBox,WUXButton, XCAD_InteractionsWEB_CAD,FilterCmd,NewFileNameCmd,ReviseCmd,ReserveCmd,UnreserveCmd,SaveNewCmd,InfoPanelCmd) {
	'use strict';

	var ToolbarController = {

			ToolbarItemsIds: ['SaveScope','Filter','Include','Exclude','Revise','SaveNew','Reserve','Unreserve','FileRename','DO','Bookmark','Info'], 
			actionBarCommands : [],// List of commands, each command controls an
			// button behaviour in the toolbar.
			/*FilterUnmodifiedBtn: null,
			ExcludeButton: null, 
			IncludeButton: null,
			ReviseButton: null,
			LockButton: null,
			UnlockButton: null, 
			RenameButton: null,
			SaveAsNewbutton: null,
			DOButton: null, 
			BookmarkButton: null, 
			InfoButton: null,*/

			init: function() {
				console.log('init : ToolBar'/* + this._id */);
				var toolBarDiv = UWACore.createElement('div', {
					'class': 'toolbar-container'
				}).inject(widget.body,'top');

				var _pathToModule = WebappsUtils.getWebappsBaseUrl();
				for ( var i in this.ToolbarItemsIds){
					if (this.ToolbarItemsIds[i] == 'SaveScope' ) {         
						var combox=new WUXComboBox({
							elementsList:     ['Active Document','Current Editor', 'Session'],
							selectedIndex: 0,
							enableSearchFlag: false,
							actionOnClickFlag: false
						}).inject(toolBarDiv);
						combox.getContent().addClassName('comboxbox-container');
						combox.addEventListener('change', function onChange(e) {
							if (widget.XCAD_MainController.saveScope !=  e.dsModel.selectedIndex) {
								widget.XCAD_MainController.saveScope = e.dsModel.selectedIndex;

								var content = {
										saveScope : e.dsModel.selectedIndex
								}
								XCAD_InteractionsWEB_CAD.sendMessageToCad('changeSaveScope', '1.0', content);                      
							}              
						});
					}
					else if (this.ToolbarItemsIds[i] =='Filter' ){
						//var pathToModule = WebappsUtils.getWebappsBaseUrl();

						var FilterUnmodifiedBtn=new WUXButton({tooltip:'Filter Unmodified',label: 'Filter Unmodified', icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_DefineFilter.png',displayStyle: 'icon', type: 'check', touchMode: true}).inject(toolBarDiv);
						FilterCmd.init(FilterUnmodifiedBtn);
					}
					else if (this.ToolbarItemsIds[i] =='Include' ){
						this.IncludeButton=new WUXButton({ label: 'Include',disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_AddCustoExtension.png',displayStyle: 'icon', type: 'check', touchMode: true }).inject(toolBarDiv);
					}
					else if (this.ToolbarItemsIds[i] =='Exclude' ){
						var ExcludeButton=new WUXButton({ label: 'Exclude',disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_SsmExcludedSpaceSet.png',displayStyle: 'icon',iconSize: '1x', type: 'check', touchMode: true }).inject(toolBarDiv);
						ExcludeButton.addEventListener('buttonclick', function (event){
							var state=typeof event.srcElement.attributes.checked != 'undefined'
								var content = {

							}
							XCAD_InteractionsWEB_CAD.sendMessageToCad("changeFilterNotModified", '1.0', content);
						});
					}
					else if (this.ToolbarItemsIds[i] =='Revise' ){
						var ReviseButton=new WUXButton({ label: 'Revise',disabled: false, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_MajorVersion1.png',displayStyle: 'icon', type: 'standard', touchMode: true }).inject(toolBarDiv);
						ReviseCmd.init(this.ToolbarItemsIds[i],ReviseButton);
						/*this.ReviseButton.addEventListener('buttonclick', function (event){
							var state=typeof event.srcElement.attributes.checked != 'undefined'
								var content = {
									filterNotModified: state
							}
							XCAD_InteractionsWEB_CAD.sendMessageToCad("changeFilterNotModified", '1.0', content);
						});	*/		
					}
					else if (this.ToolbarItemsIds[i] =='SaveNew' ){
						var SaveAsNewbutton=new WUXButton({ label: 'Save As New',disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_SaveAsNew1.png',displayStyle: 'icon', type: 'standard', touchMode: true }).inject(toolBarDiv);
						SaveNewCmd.init(this.ToolbarItemsIds[i],SaveAsNewbutton);
					}
					else if (this.ToolbarItemsIds[i] =='Reserve' ){
						var LockButton=new WUXButton({ label: 'Lock',disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_CheckOut.png',displayStyle: 'icon', type: 'standard', touchMode: true }).inject(toolBarDiv);
						ReserveCmd.init(this.ToolbarItemsIds[i],LockButton);
					}
					else if (this.ToolbarItemsIds[i] =='Unreserve' ){
						var UnlockButton=new WUXButton({ label: 'Unlock',disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_CheckIn.png',displayStyle: 'icon', type: 'standard', touchMode: true }).inject(toolBarDiv);
						UnreserveCmd.init(this.ToolbarItemsIds[i],UnlockButton);
					}
					else if (this.ToolbarItemsIds[i] =='FileRename' ){
						var RenameButton=new WUXButton({ label: 'Rename',disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_NewFileName1.png',displayStyle: 'icon', type: 'check', touchMode: true }).inject(toolBarDiv);
						NewFileNameCmd.init(this.ToolbarItemsIds[i],RenameButton);
					}
					else if (this.ToolbarItemsIds[i] =='InfoP' ){
						var InfoButton=new WUXButton({ label: 'Information',disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_CldInfo.png',displayStyle: 'icon', type: 'check', touchMode: true }).inject(toolBarDiv);
						InfoPanelCmd.init(this.ToolbarItemsIds[i],InfoButton);
					}
					/*this.LockButton=new WUXButton({ label: 'Lock',disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_CheckOut.png',displayStyle: 'icon', type: 'standard', touchMode: true }).inject(toolBarDiv);
					this.UnlockButton=new WUXButton({ label: 'Unlock',disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_CheckIn.png',displayStyle: 'icon', type: 'standard', touchMode: true }).inject(toolBarDiv);		 
					this.RenameButton=new WUXButton({ label: 'Rename',disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_NewFileName1.png',displayStyle: 'icon', type: 'check', touchMode: true }).inject(toolBarDiv);
					this.DOButton=new WUXButton({ label: 'Derived Output',disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_SetDerivedOutputCmd.png',displayStyle: 'icon', type: 'check', touchMode: true }).inject(toolBarDiv);
					this.BookmarkButton=new WUXButton({ label: 'Bookmark',disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_Bookmark.png',displayStyle: 'icon', type: 'check', touchMode: true }).inject(toolBarDiv);
					this.InfoButton=new WUXButton({ label: 'Information',disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_CldInfo.png',displayStyle: 'icon', type: 'check', touchMode: true }).inject(toolBarDiv);*/

				}

			},
	}


	return ToolbarController;
});

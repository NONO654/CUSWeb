define('DS/ENOXCAD_Save/views/XCAD_ToolBar', [
	'UWA/Core',
	'DS/WebappsUtils/WebappsUtils',
	'DS/Controls/ComboBox',
	'DS/Controls/Button',
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD',
	'DS/ENOXCAD_Save/controllers/XCAD_FilterCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_NewFileNameCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_NewRevCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_DuplicateCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_ReserveCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_UnReserveCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_SaveAsNewCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_BookmarkCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_SetDerivedOutputCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_ToggleRightPanelCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_IncludeCmd',
	'DS/ENOXCAD_Save/controllers/XCAD_ExcludeCmd',
	'DS/Controls/TooltipModel',
	'i18n!DS/ENOXCAD_Save/assets/nls/ENOXCADWebSaveToolBarNls'
	], function(UWACore,WebappsUtils, WUXComboBox,WUXButton, XCAD_InteractionsWEB_CAD,FilterCmd,NewFileNameCmd,ReviseCmd,DuplicateCmd,ReserveCmd,UnreserveCmd,SaveNewCmd,BookmarkCmd,DOCmd,InfoPanelCmd,IncludeCmd,ExcludeCmd,WUXTooltipModel,Nls) {
	'use strict';

	var ToolbarController = {

			ToolbarItemsIds: ['SaveScope','Filter','Include','Exclude','Revise','Duplicate','SaveAsNew','Lock','Unreserve','RenameFile','EditDerivedOutputSelection','Bookmark','Info'],
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

			init: function(iSaveScope,iFilterNotModified) {
				console.log('init : ToolBar'/* + this._id */);
				var toolBarDiv = UWACore.createElement('div', {
					'class': 'toolbar-container'
				}).inject(widget.body,'top');

				var _pathToModule = WebappsUtils.getWebappsBaseUrl();
				for ( var i in this.ToolbarItemsIds){


					switch (this.ToolbarItemsIds[i]) {
					  case 'SaveScope':
						  var combox=new WUXComboBox({
								elementsList:     ['Active Document','Current Editor', 'Session'],
								selectedIndex: iSaveScope,
								enableSearchFlag: false,
								actionOnClickFlag: false,
								touchMode:false
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
					    break;
					  case 'Filter':
						//var pathToModule = WebappsUtils.getWebappsBaseUrl();
							var btndiv1 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var FilterUnmodifiedBtn=new WUXButton({checkFlag:iFilterNotModified, disabled: false,icon: _pathToModule+'ENOXCAD_Save/assets/icons/22/I_DefineFilter.png',displayStyle: 'icon', type: 'check',touchMode:false }).inject(btndiv1);
							FilterUnmodifiedBtn.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("Filter_cmd"), mouseRelativePosition:true});
							FilterCmd.init(FilterUnmodifiedBtn);
						  break;
					  case 'Include':
						  var btndiv2 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var IncludeButton=new WUXButton({ disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_AddCustoExtension.png',displayStyle: 'icon', type: 'check',touchMode:false }).inject(btndiv2);
							IncludeButton.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("Include_cmd"), mouseRelativePosition:true});
							IncludeCmd.init(this.ToolbarItemsIds[i],IncludeButton);
					    break;
					  case 'Exclude':
						  var btndiv3 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var ExcludeButton=new WUXButton({disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_SsmExcludedSpaceSet.png',displayStyle: 'icon', type: 'check' ,touchMode:false}).inject(btndiv3);
							ExcludeButton.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("Exclude_cmd"), mouseRelativePosition:true});
							ExcludeCmd.init(this.ToolbarItemsIds[i],ExcludeButton);
						  break;
					  case 'Revise':
						  var btndiv4 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var ReviseButton=new WUXButton({disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_UPSRevise.png',displayStyle: 'icon', type: 'standard',touchMode:false }).inject(btndiv4);
							ReviseButton.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("Revise_cmd"), mouseRelativePosition:true});
							ReviseCmd.init(this.ToolbarItemsIds[i],ReviseButton);
						  break;
					  case 'Duplicate':
						  var btndiv5 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var DuplicateButton=new WUXButton({disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_UPSSaveDuplicate.png',displayStyle: 'icon', type: 'standard',touchMode:false}).inject(btndiv5);
							DuplicateButton.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("Duplicate_cmd"), mouseRelativePosition:true});
							DuplicateCmd.init(this.ToolbarItemsIds[i],DuplicateButton);

						  break;
					  case 'SaveAsNew':
						  var btndiv6 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var SaveAsNewbutton=new WUXButton({disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_UPSSaveAsNew.png',displayStyle: 'icon', type: 'standard',touchMode:false}).inject(btndiv6);
							SaveAsNewbutton.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("SaveAsNew_cmd"), mouseRelativePosition:true});
							SaveNewCmd.init(this.ToolbarItemsIds[i],SaveAsNewbutton);
						  break;
					  case 'Lock':
						  var btndiv7 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var LockButton=new WUXButton({disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_UPSReserve.png',displayStyle: 'icon', type: 'standard',touchMode:false}).inject(btndiv7);
							LockButton.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("Reserve_cmd"), mouseRelativePosition:true});
							ReserveCmd.init(this.ToolbarItemsIds[i],LockButton);
						  break;
					  case 'Unreserve':
						  var btndiv8 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var UnlockButton=new WUXButton({disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_UPSUnreserve.png',displayStyle: 'icon', type: 'standard',touchMode:false}).inject(btndiv8);
							UnlockButton.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("Unreserve_cmd"), mouseRelativePosition:true});
							UnreserveCmd.init(this.ToolbarItemsIds[i],UnlockButton);
						  break;
					  case 'RenameFile':
						  var btndiv9 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var RenameButton=new WUXButton({disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_UPSNewFileName.png',displayStyle: 'icon', type: 'standard',touchMode:false}).inject(btndiv9);
							RenameButton.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("RenameFile_cmd"), mouseRelativePosition:true});
							NewFileNameCmd.init(this.ToolbarItemsIds[i],RenameButton);
						  break;
					  case 'EditDerivedOutputSelection':
						  var btndiv11 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var DOButton=new WUXButton({disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_UPSDerivedOutput.png',displayStyle: 'icon', type: 'standard',touchMode:false}).inject(btndiv11);
							DOButton.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("Do_cmd"), mouseRelativePosition:true});
							DOCmd.init(this.ToolbarItemsIds[i],DOButton);
						  break;
					  case 'Bookmark':
						  var btndiv12 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var BookmarkButton=new WUXButton({disabled: false, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_UPSBookmark.png',displayStyle: 'icon', type: 'standard',touchMode:false}).inject(btndiv12);
							BookmarkButton.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("Bookmark_cmd"), mouseRelativePosition:true});
							BookmarkCmd.init(this.ToolbarItemsIds[i],BookmarkButton);
						  break;
					  case 'Info':
						  var btndiv10 = UWACore.createElement('div', {
								'class': 'button'
							}).inject(toolBarDiv);
							var InfoButton=new WUXButton({disabled: false,checkFlag:true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_UPSInformation.png',displayStyle: 'icon', type: 'standard',touchMode:false}).inject(btndiv10);
							InfoButton.tooltipInfos = new WUXTooltipModel({ shortHelp:Nls.get("Info_cmd"), mouseRelativePosition:true});
							InfoPanelCmd.init(this.ToolbarItemsIds[i],InfoButton);
						  break;
					  default:
					    console.log('Sorry, we are out of ' + expr + '.');
					}















					/*if (this.ToolbarItemsIds[i] == 'SaveScope' ) {
						var combox=new WUXComboBox({
							elementsList:     ['Active Document','Current Editor', 'Session'],
							selectedIndex: iSaveScope,
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
						var btndiv1 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var FilterUnmodifiedBtn=new WUXButton({checkFlag:iFilterNotModified, disabled: false,tooltip:'Filter Unmodified',label:'', icon: _pathToModule+'ENOXCAD_Save/assets/icons/22/I_DefineFilter.png',displayStyle: 'icon', type: 'check' }).inject(btndiv1);

						FilterCmd.init(FilterUnmodifiedBtn);
					}
					else if (this.ToolbarItemsIds[i] =='Include' ){
						var btndiv2 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var IncludeButton=new WUXButton({ disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_AddCustoExtension.png',displayStyle: 'icon', type: 'check' }).inject(btndiv2);
						IncludeCmd.init(this.ToolbarItemsIds[i],IncludeButton);
					}
					else if (this.ToolbarItemsIds[i] =='Exclude' ){
						var btndiv3 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var ExcludeButton=new WUXButton({ disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_SsmExcludedSpaceSet.png',displayStyle: 'icon', type: 'check' }).inject(btndiv3);
						ExcludeCmd.init(this.ToolbarItemsIds[i],ExcludeButton);
					}
					else if (this.ToolbarItemsIds[i] =='Revise' ){
						var btndiv4 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var ReviseButton=new WUXButton({ disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_MajorVersion1.png',displayStyle: 'icon', type: 'standard' }).inject(btndiv4);
						ReviseCmd.init(this.ToolbarItemsIds[i],ReviseButton);

					}
					else if (this.ToolbarItemsIds[i] =='Duplicate' ){
						var btndiv5 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var DuplicateButton=new WUXButton({disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_Duplicate.png',displayStyle: 'icon', type: 'standard'}).inject(btndiv5);
						DuplicateCmd.init(this.ToolbarItemsIds[i],DuplicateButton);

					}
					else if (this.ToolbarItemsIds[i] =='SaveAsNew' ){
						var btndiv6 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var SaveAsNewbutton=new WUXButton({disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_SaveAsNew1.png',displayStyle: 'icon', type: 'standard'}).inject(btndiv6);
						SaveNewCmd.init(this.ToolbarItemsIds[i],SaveAsNewbutton);
					}
					else if (this.ToolbarItemsIds[i] =='Lock' ){
						var btndiv7 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var LockButton=new WUXButton({ disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_CheckOut.png',displayStyle: 'icon', type: 'standard'}).inject(btndiv7);
						ReserveCmd.init(this.ToolbarItemsIds[i],LockButton);
					}
					else if (this.ToolbarItemsIds[i] =='Unreserve' ){
						var btndiv8 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var UnlockButton=new WUXButton({disabled: true, icon:_pathToModule+ 'ENOXCAD_Save/assets/icons/32/I_CheckIn.png',displayStyle: 'icon', type: 'standard'}).inject(btndiv8);
						UnreserveCmd.init(this.ToolbarItemsIds[i],UnlockButton);
					}
					else if (this.ToolbarItemsIds[i] =='RenameFile' ){
						var btndiv9 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var RenameButton=new WUXButton({disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_NewFileName1.png',displayStyle: 'icon', type: 'standard'}).inject(btndiv9);
						NewFileNameCmd.init(this.ToolbarItemsIds[i],RenameButton);
					}

					else if (this.ToolbarItemsIds[i] =='Info' ){
						var btndiv10 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var InfoButton=new WUXButton({disabled: false,checkFlag:true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_CldInfo.png',displayStyle: 'icon', type: 'standard'}).inject(btndiv10);
						InfoPanelCmd.init(this.ToolbarItemsIds[i],InfoButton);
					}
					else if (this.ToolbarItemsIds[i] =='EditDerivedOutputSelection' ){
						var btndiv11 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var DOButton=new WUXButton({ disabled: true, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_DO.png',displayStyle: 'icon', type: 'standard'}).inject(btndiv11);
						DOCmd.init(this.ToolbarItemsIds[i],DOButton);
					}
					else if (this.ToolbarItemsIds[i] =='Bookmark' ){
						var btndiv12 = UWACore.createElement('div', {
							'class': 'button'
						}).inject(toolBarDiv);
						var BookmarkButton=new WUXButton({disabled: false, icon: _pathToModule+'ENOXCAD_Save/assets/icons/32/I_Bookmark.png',displayStyle: 'icon', type: 'standard'}).inject(btndiv12);
						BookmarkCmd.init(this.ToolbarItemsIds[i],BookmarkButton);
					}*/

				}

			},
	}


	return ToolbarController;
});

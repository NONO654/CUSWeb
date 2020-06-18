define('DS/ENOXCAD_Save/views/XCAD_TreeListView', [
	// -- Module Dependencies --
	'UWA/Core',
	'DS/Core/Core',
	'DS/ApplicationFrame/ContextualUIManager',
	'DS/WebappsUtils/WebappsUtils',
	'DS/Utilities/Dom',
	'DS/Tree/TreeListView',
	'DS/Tree/TreeNodeModel',
	'DS/Tree/TreeDocument',
	'DS/Controls/Toggle',
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD',
	'DS/Controls/ComboBox',
	'i18n!DS/ENOXCAD_Save/assets/nls/ENOXCADWebSaveToolBarNls',
	'i18n!DS/ENOXCAD_Save/assets/nls/ENOXCADWebSaveColumns',
	'text!DS/ENOXCAD_Save/assets/XCAD_CATIAV5ColumnsModel.json'
],
function(UWACore, WUXCore, ContextualUIManager, WebappsUtils, DomUtils, TreeListView,
		 TreeNodeModel, TreeDocument, Toggle, XCAD_InteractionsWEB_CAD,WUXComboBox,i18nENOXCADWebSaveToolBar,nlscolumns,CV5ColumnsTxt) {
	'use strict';

	var ENOUPSTreeListView = function(XCAD_MainController) {
		// 1) Set TreeListView options
		var options = TreeListView.SETTINGS.STANDARD;
		options.iapiVersion= '2';
		options.isEditable = true;
		options.showScrollbarsOnHover = true;
		options.height = 'auto';
		options.width = 'auto';
		options.overflow = 'auto';
		options.touchMode= false;
		options.show = {
		    "row Headers": false,
		    "columnHeaders": true
		  };
		options.selection.preSelection = true;



		// 2) Manage TreeListView contextual menu
		options.onContextualEvent = {
			callback : function (params) {
				console.log(params);
				var menu = [];

				if (params && params.treeview && params.treeview.nodeModel) {

					if (params.treeview.cellModel._isSelected === false) {
						params.treeview.cellModel._isSelected = true;
						params.treeview.nodeModel.select(true);
						}
					var node = params.treeview.nodeModel;
					//widget.XCAD_MainController.selectedNodes[node._options.grid.NodeId] = node;
					menu.push({
						'touchMode':false,
						'type' : 'PushItem',
						'title' :i18nENOXCADWebSaveToolBar.get("Exclude_cmd"),
						'icon': 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/I_SsmExcludedSpaceSet.png') + ')',
						//'icon': i18nENOXCADWebSaveToolBar.get("Exclude_cmd"),
						'state':widget.XCAD_MainController.actionBarCommands['Exclude']._isEnable?'enabled': 'disabled',
						'action' : {
							'callback' : function() {
								console.log(params.treeview.nodeModel);
								widget.XCAD_MainController.actionBarCommands['Exclude'].execute();
							}
						}
					});
					menu.push({
						'type' : 'PushItem',
						'icon': 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/I_AddCustoExtension.png') + ')',
						'title' : i18nENOXCADWebSaveToolBar.get("Include_cmd"),
						//'icon': i18nENOXCADWebSaveToolBar.get("Include_cmd"),
						'state':widget.XCAD_MainController.actionBarCommands['Include']._isEnable?'enabled': 'disabled',
						'action' : {
							'callback' : function() {
								console.log(params.treeview.nodeModel);
								widget.XCAD_MainController.actionBarCommands['Include'].execute();
							}
						}
					});
					menu.push({
						'type' : 'PushItem',
						'icon': 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/I_UPSRevise.png') + ')',
						'title' :i18nENOXCADWebSaveToolBar.get("Revise_cmd"),
						//'icon': i18nENOXCADWebSaveToolBar.get("Revise_cmd"),
						'state':widget.XCAD_MainController.actionBarCommands['Revise']._isEnable?'enabled': 'disabled',
						'action' : {
							'callback' : function() {
								console.log(params.treeview.nodeModel);
								widget.XCAD_MainController.actionBarCommands['Revise'].execute();
							}
						}
					});
					menu.push({
						'type' : 'PushItem',
						'icon': 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/I_UPSDerivedOutput.png') + ')',
						'title' : i18nENOXCADWebSaveToolBar.get("Do_cmd"),
						//'icon': i18nENOXCADWebSaveToolBar.get("Revise_cmd"),
						'state':widget.XCAD_MainController.actionBarCommands['EditDerivedOutputSelection']._isEnable?'enabled': 'disabled',
						'action' : {
							'callback' : function() {
								console.log(params.treeview.nodeModel);
								widget.XCAD_MainController.actionBarCommands['EditDerivedOutputSelection'].execute();
							}
						}
					});
					menu.push({
						'type' : 'PushItem',
						'icon': 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/I_UPSSaveAsNew.png') + ')',
						'title' : i18nENOXCADWebSaveToolBar.get("SaveAsNew_cmd"),
						//'icon': i18nENOXCADWebSaveToolBar.get("Revise_cmd"),
						'state':widget.XCAD_MainController.actionBarCommands['SaveAsNew']._isEnable?'enabled': 'disabled',
						'action' : {
							'callback' : function() {
								console.log(params.treeview.nodeModel);
								widget.XCAD_MainController.actionBarCommands['SaveAsNew'].execute();
							}
						}
					});
					menu.push({
						'type' : 'PushItem',
						'icon': 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/I_UPSSaveDuplicate.png') + ')',
						'title' : i18nENOXCADWebSaveToolBar.get("Duplicate_cmd"),
						//'icon': i18nENOXCADWebSaveToolBar.get("Revise_cmd"),
						'state':widget.XCAD_MainController.actionBarCommands['Duplicate']._isEnable?'enabled': 'disabled',
						'action' : {
							'callback' : function() {
								console.log(params.treeview.nodeModel);
								widget.XCAD_MainController.actionBarCommands['Duplicate'].execute();
							}
						}
					});
					menu.push({
						'type' : 'PushItem',
						'icon': 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/I_UPSReserve.png') + ')',
						'title' : i18nENOXCADWebSaveToolBar.get("Reserve_cmd"),
						//'icon': i18nENOXCADWebSaveToolBar.get("Revise_cmd"),
						'state':widget.XCAD_MainController.actionBarCommands['Lock']._isEnable?'enabled': 'disabled',
						'action' : {
							'callback' : function() {
								console.log(params.treeview.nodeModel);
								widget.XCAD_MainController.actionBarCommands['Lock'].execute();
							}
						}
					});
					menu.push({
						'type' : 'PushItem',
						'icon': 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/I_UPSUnreserve.png') + ')',
						'title' : i18nENOXCADWebSaveToolBar.get("Unreserve_cmd"),
						//'icon': i18nENOXCADWebSaveToolBar.get("Revise_cmd"),
						'state':widget.XCAD_MainController.actionBarCommands['Unreserve']._isEnable?'enabled': 'disabled',
						'action' : {
							'callback' : function() {
								console.log(params.treeview.nodeModel);
								widget.XCAD_MainController.actionBarCommands['Unreserve'].execute();
							}
						}
					});
					menu.push({
						'type' : 'PushItem',
						'icon': 'url(' + WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/I_UPSNewFileName.png') + ')',
						'title' :i18nENOXCADWebSaveToolBar.get("RenameFile_cmd"),
						'state':widget.XCAD_MainController.actionBarCommands['RenameFile']._isEnable?'enabled': 'disabled',
						'action' : {
							'callback' : function() {
								console.log(params.treeview.nodeModel);
								widget.XCAD_MainController.actionBarCommands['RenameFile'].execute();
							}
						}
					});
					/*menu.push({
                         type: 'SeparatorItem'
                     });*/

				}
				return menu;
			}
		};



		// 3) Set TreeListView columns
		options.columns =JSON.parse(CV5ColumnsTxt);
		//update columns nls
		options.columns.forEach(function(column) {
			var title =column.text;
			column.text=nlscolumns.get(title);
		});

		/*options.columns = [

		 //{// TODO : save column order and width in CAD Preferences
			//text : '',
			//dataIndex : '',
			//isHidden : true
		//},
		{
			text : 'Status',			 // We use the Status value to display the correct icon but the actual value of this column must be 'TooltipStatus'
			dataIndex : 'TooltipStatus', // in order to display the correct message when the user's mouse hover this column (that's why dataIndex != 'Status')
			isEditable : false,
			width: 55,
			onCellRequest : function(cellInfos) {
				if (!cellInfos.isHeader) { // because onCellRequest is also called on column headers
					var reusableContent = cellInfos.cellView.reuseCellContent('Status');
					reusableContent.children[0].src="";
					reusableContent.children[1].src="";
					for ( var i in cellInfos.nodeModel.options.grid.Status){
					var status=cellInfos.nodeModel.options.grid.Status[i];
					if (status != ""){
					var urlIcon = WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/' + status + '.png');

					reusableContent.children[i].src = urlIcon;
					}
					}
				}
			}
		}, {
			text : 'Action',			 // We use the Status value to display the correct icon but the actual value of this column must be 'TooltipStatus'
			dataIndex : 'TooltipAction', // in order to display the correct message when the user's mouse hover this column (that's why dataIndex != 'Status')
			isEditable : false,
			width: 50,
			onCellRequest : function(cellInfos) {
				if (!cellInfos.isHeader && cellInfos.nodeModel.options.grid.Action != 'undefined'&& cellInfos.nodeModel.options.grid.Action!="" ) { // because onCellRequest is also called on column headers
					var urlIcon = WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/' + cellInfos.nodeModel.options.grid.Action + '.png');
					var reusableContent = cellInfos.cellView.reuseCellContent('Action');
					reusableContent.children[0].src = urlIcon;
				}
			}
		},{
			text : 'Save',
			dataIndex : 'Save',
			isEditable : false,
			width: 45,

			onCellRequest : function(cellInfos) {
				if (!cellInfos.isHeader) { // because onCellRequest is also called on column headers
					//console.log("SaveColumn : onCellRequest (Save)");

					var toggleSave = new Toggle({
						type : 'checkbox',
						value : cellInfos.nodeModel.options.grid.Save
					});

					if (	cellInfos.nodeModel.options.grid.Save == 'I_UPSForcedToBeSaved'
						|| 	cellInfos.nodeModel.options.grid.Save == 'I_UPSWarning'
						||	cellInfos.nodeModel.options.grid.Save == 'I_UPSToBeSaved')
						toggleSave.checkFlag = true;
					else
						// if ('I_UPSCannotBeSaved' || 'I_UPSExcluded' || 'I_UPSNoSave')
						toggleSave.checkFlag = false;

					if (cellInfos.nodeModel.options.grid.Save == 'I_UPSCannotBeSaved')
						toggleSave.disabled = true;

					toggleSave.inject(cellInfos.cellView.getContent());

					toggleSave.addEventListener('change', function(event) {// TODO : move this out of onCellRequest
						XCAD_MainController.onToogleSaveChange(cellInfos);
					});
				}
			}
		}, {
			text : 'NodeId',
			dataIndex : 'NodeId',
			isEditable : false,
			isHidden : true// comment this line for testing (TODO: explain why we need NodeId AND Phid)
		}, {
			text : 'Phid',// TODO : comment it (just for test)
			dataIndex : 'Phid',
			isEditable : false,
			isHidden : true// comment this line for testing
		}, {
			text : 'Title',
			dataIndex : 'tree',
			isEditable : false
		}, {
			text : 'Revision',
			dataIndex : 'Revision',
			isEditable : false, // do not modify this
			width : 120
		}, {
			text : 'Type',
			dataIndex : 'Type',
			isEditable : false
		}, {
			text : 'CAD Type',
			dataIndex : 'CAD Type',
			isEditable : false
		}, {
			text : 'Name',
			dataIndex : 'Name',
			isEditable : false
		}, {
			text : 'Description',
			dataIndex : 'Description',
			isEditable : false

		}, {
			text : 'Reserve',
			dataIndex : 'Reserve',
			isEditable : false,


			onCellRequest : function(cellInfos) {
				if (!cellInfos.isHeader) { // because onCellRequest is also called on column headers
					//console.log("StatusColumn : onCellRequest (Reserve)");
					if (cellInfos.nodeModel.options.grid.Reserve != 'undefined' && cellInfos.nodeModel.options.grid.Reserve != '' ){
					var urlIcon = WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/' + cellInfos.nodeModel.options.grid.Reserve + '.png');
					var reusableContent = cellInfos.cellView.reuseCellContent('Reserve');
					reusableContent.children[0].src = urlIcon;
					}
				}
			}
		}, {
			text : 'Reserved By',
			dataIndex : 'Reserved_By',
			isEditable : false,
		}, {
			text : 'Owner',
			dataIndex : 'Owner',
			isEditable : false,
			width : 100
		}, {
			text : 'Filename',
			dataIndex : 'Filename',
			width : 100,
			isEditable : false// TODO : find how to make some nodes editable
		}, {
			text : 'Bookmarks',
			dataIndex : 'Bookmarks',
			isEditable : false,
			width : 100
		} ];*/
		// TODO : use   options.columns.push({



		// 4) Create TreeListView and registerReusableCellContent (for columns 'Status' and 'Reserve')
		var treeListView = new TreeListView(options);
		treeListView.getManager().touchMode = false;  // wbr1 : this changes nothing ?
		treeListView.getManager().options.defaultCellHeight = 26;
		//treeListView.getManager().sortColumnContent('Title', {sortOrder:'desc'});
		treeListView.getManager().registerReusableCellContent({
			id : 'Status', // a unique identifier
			buildContent : function() { // the function called when the rendering engine need to create again a reusableCellContent of type 'bargraph'
				var spanMaster = DomUtils.createElement('span');
				var imgMaster1 = DomUtils.createElement('img');
				spanMaster.appendChild(imgMaster1);
				var imgMaster2 = DomUtils.createElement('img');
				spanMaster.appendChild(imgMaster2);
				return spanMaster;
			}
		});
		treeListView.getManager().registerReusableCellContent({
			id : 'Action', // a unique identifier
			buildContent : function() { // the function called when the rendering engine need to create again a reusableCellContent of type 'bargraph'
				var spanMaster = DomUtils.createElement('span');
				var imgMaster = DomUtils.createElement('img');
				spanMaster.appendChild(imgMaster);
				return spanMaster;
			}
		});
		treeListView.getManager().registerReusableCellContent({
			id : 'Reserve', // a unique identifier
			buildContent : function() { // the function called when the rendering engine need to create again a reusableCellContent of type 'bargraph'
				var spanMaster = DomUtils.createElement('span');
				var imgMaster = DomUtils.createElement('img');
				spanMaster.appendChild(imgMaster);
				return spanMaster;
			}
		});

		// 5) Warn the CAD that treeListView is ready, the web model can be loaded
		treeListView.getManager().onReady(function(e) {
			XCAD_InteractionsWEB_CAD.sendMessageToCad('readyForInit', '1.0', {});
		});

		/*treeListView.getManager().onCellClick(function(cellInfos) {

			var columnIndex = cellInfos.dataIndex;
			if ((columnIndex =='Revision') && (!cellInfos.isHeader) ){
				var combox=new WUXComboBox({
					elementsList: ['A.1','B.1'],
					selectedIndex: 0,
					enableSearchFlag: false,
					actionOnClickFlag: false
				});
				//cellInfos.nodeModel.options.grid.Revision="";
				//cellInfos.cellView.RemoveContent();
				cellInfos.cellView.getContent().setContent(combox);
				//combox.inject(cellInfos.cellView.getContent());
			}

		});*/
		treeListView.getManager().onCellRequest(function(cellInfos) {
			var columnIndex = cellInfos.dataIndex;

			if(!cellInfos.isHeader){// because onCellRequest is also called on column headers
				if (columnIndex =='Revision') {
				//console.log("SaveColumn : onCellRequest (Save)");
				//combobox is available only when the object is includedn in save scope and has revision list
					//( we can not use Revise command availability because when the user do unrevise after a revise , revise command is unavailable
				if (typeof cellInfos.nodeModel.options.grid.Available_Commands != 'undefined' && (
						cellInfos.nodeModel.options.grid.Save == 'I_UPSForcedToBeSaved' ||
						cellInfos.nodeModel.options.grid.Save == 'I_UPSWarning'||
						cellInfos.nodeModel.options.grid.Save == 'I_UPSToBeSaved') && cellInfos.nodeModel.options.grid.Revision_List.length > 1){
					var currentRev=cellInfos.nodeModel.options.grid.Revision;
					var combox=new WUXComboBox({
						elementsList: cellInfos.nodeModel.options.grid.Revision_List,
						selectedIndex: cellInfos.nodeModel.options.grid.Revision_List.indexOf(currentRev),
						enableSearchFlag: false,
						/*actionOnClickFlag: false*/
					});
					combox.addEventListener('change', function onChange(e) {
						// check if there muli sel and force selction of current node
						/*if (cellInfos.nodeModel._isSelected === false) {
							cellInfos.nodeModell._isSelected = true;
							pcellInfos.nodeModel.select(true);
							}*/
						var selectedRev=e.dsModel.value;
						if (cellInfos.nodeModel.options.grid.Revsion != selectedRev) {
							//case of revise
							if (typeof cellInfos.nodeModel.options.grid.Available_Commands != 'undefined' && cellInfos.nodeModel.options.grid.Available_Commands.indexOf('Revise') != -1){
								widget.XCAD_MainController.actionBarCommands['Revise'].execute();
							}
							// this is case of cancel Revise
							else{
								widget.XCAD_MainController.actionBarCommands['Revise'].resetRevision(selectedRev);
							}

						}
					});
				cellInfos.cellView.getContent().setContent(combox);
			}
					//combox.inject(cellInfos.cellView.getContent());
			}
				else if (columnIndex =='Type'){
					if (typeof cellInfos.nodeModel.options.grid.Type_List != 'undefined' &&cellInfos.nodeModel.options.grid.Type_List.length > 1){

					}
				}
				else if (columnIndex =='TooltipStatus') {
					var reusableContent = cellInfos.cellView.reuseCellContent('Status');
					reusableContent.children[0].src="";
					reusableContent.children[1].src="";
					for ( var i in cellInfos.nodeModel.options.grid.Status){
					var status=cellInfos.nodeModel.options.grid.Status[i];
					if (status != ""){
					var urlIcon = WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/' + status + '.png');

					reusableContent.children[i].src = urlIcon;
				}
			}
			}
				else if (columnIndex =='TooltipAction'){
				if (cellInfos.nodeModel.options.grid.Action != 'undefined'&& cellInfos.nodeModel.options.grid.Action!="" ) { // because onCellRequest is also called on column headers
					var urlIcon = WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/' + cellInfos.nodeModel.options.grid.Action + '.png');
					var reusableContent = cellInfos.cellView.reuseCellContent('Action');
					reusableContent.children[0].src = urlIcon;
				}
			}
				else if (columnIndex =='Save'){
					//console.log("SaveColumn : onCellRequest (Save)");

					var toggleSave = new Toggle({
						type : 'checkbox',
						value : cellInfos.nodeModel.options.grid.Save
					});

					if (	cellInfos.nodeModel.options.grid.Save == 'I_UPSForcedToBeSaved'
						|| 	cellInfos.nodeModel.options.grid.Save == 'I_UPSWarning'
						||	cellInfos.nodeModel.options.grid.Save == 'I_UPSToBeSaved')
						toggleSave.checkFlag = true;
					else if (typeof cellInfos.nodeModel.options.grid.Available_Commands != 'undefined' && cellInfos.nodeModel.options.grid.Available_Commands.indexOf('Include') != -1) // if we can include the node, check box should be just unchecked and not disabled
						// if ('I_UPSCannotBeSaved' || 'I_UPSExcluded' || 'I_UPSNoSave')
						toggleSave.checkFlag = false;
					else //if (cellInfos.nodeModel.options.grid.Save == 'I_UPSCannotBeSaved')
						toggleSave.disabled = true;


					//toggleSave.inject(cellInfos.cellView.getContent());
					cellInfos.cellView.getContent().setContent(toggleSave);
					toggleSave.addEventListener('change', function(event) {// TODO : move this out of onCellRequest
						XCAD_MainController.onToogleSaveChange(cellInfos);
					});
				}
				else if (columnIndex =='Reserve'){
					if (cellInfos.nodeModel.options.grid.Reserve != 'undefined' && cellInfos.nodeModel.options.grid.Reserve != '' ){
						var urlIcon = WebappsUtils.getWebappsAssetUrl('ENOXCAD_Save', 'icons/32/' + cellInfos.nodeModel.options.grid.Reserve + '.png');
						var reusableContent = cellInfos.cellView.reuseCellContent('Reserve');
						reusableContent.children[0].src = urlIcon;
						}
				}

		}
		});
		/*treeListView.getManager().getValue(function(cellInfos) {
			var columnIndex = cellInfos.dataIndex;
			if ((columnIndex =='Revision') && (!cellInfos.isHeader)){// because onCellRequest is also called on column headers
				//console.log("SaveColumn : onCellRequest (Save)");
				if (typeof cellInfos.nodeModel.options.grid.Available_Commands != 'undefined' && cellInfos.nodeModel.options.grid.Revision_List.length > 1){
					var combox=new WUXComboBox({
						elementsList: cellInfos.nodeModel.options.grid.Revision_List,
						currentValue: cellInfos.nodeModel.options.grid.Revsion,
						enableSearchFlag: false,
						actionOnClickFlag: false
					});
					combox.addEventListener('change', function onChange(e) {
						if (cellInfos.nodeModel.options.grid.Revsion !=  e.dsModel.value) {
							//case of revise
							if (typeof cellInfos.nodeModel.options.grid.Available_Commands != 'undefined' && cellInfos.nodeModel.options.grid.Available_Commands.indexOf('Revise') != -1){
								widget.XCAD_MainController.actionBarCommands['Revise'].execute();
							}
							// this is case of cancel Revise
							else{

							}

						}
					});
				cellInfos.cellView.getContent().setContent(combox);
			}
					//combox.inject(cellInfos.cellView.getContent());
			}
		});*/
		return treeListView;
	};

	return ENOUPSTreeListView;
});

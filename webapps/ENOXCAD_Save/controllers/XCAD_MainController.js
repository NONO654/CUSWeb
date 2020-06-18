define('DS/ENOXCAD_Save/controllers/XCAD_MainController', [
	// -- Module Dependencies --
	'UWA/Core',
	'DS/Core/Core',
	'DS/WebappsUtils/WebappsUtils',
	'DS/Utilities/Dom',
	'DS/Tree/TreeNodeModel',
	'DS/Tree/TreeDocument',
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD',
	'DS/ENOXCAD_Save/views/XCAD_Triptych',
	'DS/ENOXCAD_Save/views/XCAD_TreeListView',
	'DS/Notifications/NotificationsManagerUXMessages',
	'DS/Notifications/NotificationsManagerViewOnScreen',
	'DS/Windows/ImmersiveFrame',
	'DS/ENOXCAD_Save/views/XCAD_ToolBar'
],
// -- Main function with aliases for loaded modules
function(UWACore, WUXCore, WebappsUtils, DomUtils, TreeNodeModel, TreeDocument,
		 XCAD_InteractionsWEB_CAD, ENOUPSTriptych, ENOUPSTreeListView, NotificationsManagerUXMessages, NotificationsManagerViewOnScreen,WUXImmersiveFrame,ToolBarController) {
	'use strict';

	WUXCore.setFullscreen();// TODO check why bug if WUXCore.setFullscreen is removed
	UWA.debug = true;

	// TODO : use singleton
	widget.XCAD_MainController = {



		// 1) Init XCAD_MainController attributes
		triptych : {}, 				// = ENOUPSTriptych
		treeListView : null,  		// = ENOUPSTreeListView
		saveOptionsView : null, 	// = ENOUPSSaveOptionsView
		previewBookmarksView : null,// = ENOUPSPreviewBookmarksView
		//propertiesView : null,		// = ENOUPSPropertiesView

		model : null,				// = TreeDocument
		filterNotModified : false,
		saveScope : 0, 			// 0 = Active document / 1 = Current editor / 2 = Session
		xso : {}, 				// = model.getXSO()
		allNodes : [], 			// = Array of TreeNodeModel indexed with NodeId as key
		selectedNodes : [], 	// = Array of TreeNodeModel indexed with NodeId as key (udated by the xso)
		actionBarCommands : [], // = Array of AFRCommand sub classes (filled by the command it self) indexed with CommandId
		ActiveCommandId : null,
		restrictedCharactersForFileName : '',
		notificationsManagerUXMessages : NotificationsManagerUXMessages,
        myImmersiveFrame:null,
        _pathToModule:null,


		// 2) Define the method called when the widget is loaded (Entry point of XCAD_MainController)
		onLoad : function() {
			// TODO : check why onLoad called twice
			if (typeof widget.ENOUPS_saveWidgetIsLoaded == 'undefined' || widget.ENOUPS_saveWidgetIsLoaded == false)
				widget.ENOUPS_saveWidgetIsLoaded = true;
			else
				return ;

			console.log("XCAD_Save - onLoad");
			var that = this;

            NotificationsManagerViewOnScreen.setNotificationManager(this.notificationsManagerUXMessages);



            // 2.1) Init the model (TreeDocument)
            console.log("XCAD_Save - Start Init Model");
            this._pathToModule = WebappsUtils.getWebappsBaseUrl();
			this.model = new TreeDocument({
				useAsyncPreExpand : true
			});
			console.log("XCAD_Save - End Init Model");
            // 2.2) Init the main view (ENOUPSTreeListView)
			this.treeListView = new ENOUPSTreeListView(this);

			this.treeListView.getManager().loadDocument(this.model);

			/*var cellviews=document.getElementsByClassName('wux-datagrid-cell wux-layouts-treeview-cell');
			for(var i in cellviews){
				cellviews.item(i).className +=' wux-datagrid-cell-compact';
			}*/
			window._tree = this.treeListView;

			// 2.3) Init views needed to create the right panel of the triptych (SaveOptionsView, PreviewBookmarksView and PropertiesView)
			//this.saveOptionsView = new ENOUPSSaveOptionsView();
			//this.previewBookmarksView = new ENOUPSPreviewBookmarksView();
			//this.propertiesView = new ENOUPSPropertiesView();

            // 2.3) Init the ENOUPSTriptych
			this.triptych = new ENOUPSTriptych(this.treeListView/*, this.saveOptionsView, this.previewBookmarksView, this.propertiesView*/);

			// 2.4) Manage selection
			this.xso = this.model.getXSO();
			this.xso.onChange(function() {
				var selected = that.xso.get();

				// Update properties :
				/* JUST FOR TEST >>>*/if (typeof dscef != 'undefined') {
				if (selected.length == 0) {
					// reset the properties view if no node is selected
					//that.propertiesView.editPropWidget.initDatas([]);
				}
				else if (selected.length == 1)
					// update the properties view if 1 node is selected
					that.triptych.updateBookmarkLabel( selected[0]._options.grid.AssignedBookmark);
					/*that.propertiesView.editPropWidget.initDatas([
						new EditPropModel({'objectId': selected[0]._options.grid.Phid})
					]);*/
				else {
					that.triptych.updateBookmarkLabel('');
				}
				}
			});
			this.xso.onPostAdd(function(addedNodes) {

				addedNodes.forEach(function(node) {
					that.selectedNodes[node._options.grid.NodeId] = node;
				});

				for ( var i in that.actionBarCommands)
					that.actionBarCommands[i].updateAvailability(that.selectedNodes);

				// warn the CAD
				var content = {
					selectedNodesId : [ addedNodes[0]._options.grid.NodeId ]
				}
				XCAD_InteractionsWEB_CAD.sendMessageToCad('AddSelectedNode', '1.0', content);
			});
			this.xso.onPostRemove(function(addedNodes) {
				that.triptych.updateBookmarkLabel('');
				addedNodes.forEach(function(node) {
					that.triptych.onRemovePreview();
					delete that.selectedNodes[node._options.grid.NodeId];

				});

				for ( var i in that.actionBarCommands)
					that.actionBarCommands[i].updateAvailability(that.selectedNodes);
			});

			// 2.5) Init XCAD_InteractionsWEB_CAD
			XCAD_InteractionsWEB_CAD.init();
		},



		// 3)
		// TODO : Expected value for iNodes : [{'Status':'Exist', 'Title':'tstTitle1'}, {'Status':'New', 'Title':'tstTitle2'}]
		loadNodes : function(iNodes,nbNew,nbMod,nbExc,nbInc) {
			console.log("XCAD_Save - loadNodes");
			if(this.model!=null)
				this.model.empty();
			else
				this.model = new TreeDocument({
					useAsyncPreExpand : true
				});
			this.allNodes = [];

			// TODO : Use transactions to optimize the model update

			// -- begin transition --
			this.model.prepareUpdate();

			// Add nodes in the model
			var that = this;
			iNodes.forEach(function(node) {
				var iconPath="";
				if (node.Icons != "" ){
					iconPath=that._pathToModule+'ENOXCAD_Save/assets/icons/32/'+node.Icons+'.png';
				}
				var newTreeNodeModel = new TreeNodeModel({
					'label':node.Title,
					'icons':[iconPath],
					/*'badges': {
                        bottomRight: iconPath
                    },*/
					grid : node
				});
				if (that.filterNotModified){
					if (newTreeNodeModel._options.grid.Status=='I_UPSCachedInfo')
					// Ignore section tile
						newTreeNodeModel.hide();
					else
						newTreeNodeModel.show();
				}
				else
					newTreeNodeModel.show();
				that.allNodes[node.NodeId] = newTreeNodeModel;
				that.model.addRoot(newTreeNodeModel);
			});
			// -- end transition --
			this.model.pushUpdate();
			this.treeListView.getManager().sortColumnContent('tree', {sortOrder:'asc'});
			// Update availability of every commands in the ActionBar
			for ( var i in that.actionBarCommands)
				that.actionBarCommands[i].updateAvailability(that.selectedNodes);
			//Update save stats
			that.triptych.updateStatsInfo(nbNew,nbMod,nbExc,nbInc);
		},

		ShowOnlyModifiedContentList: function(bFilterUnmodified){
			this.filterNotModified=bFilterUnmodified;
			this.model.prepareUpdate();
			this.model.getRoots().forEach(function (node) {
				if (node._options.grid.Status=='I_UPSCachedInfo') {
					if (bFilterUnmodified)// Ignore section tile
						node.hide();
					else
						node.show();
				}
			});
			this.model.pushUpdate();
			var content = {
						filterNotModified: bFilterUnmodified
					}
			XCAD_InteractionsWEB_CAD.sendMessageToCad("changeFilterNotModified", '1.0', content);
		},

		// 4)
		// TODO : Expected value for iNodes : [{'Status':'Exist', 'Title':'tstTitle1', ...}, {'Status':'New', 'Title':'tstTitle2'}]
		updateNodes : function(iNodes,nbNew,nbMod,nbExc,nbInc) {
			console.log("XCAD_Save - updateNodes");


			//update the model
			this.model.prepareUpdate();
			var that = this;
			iNodes.forEach(function(node) {
				var iconPath="";
				if (node.Icons != "" ){
					iconPath=that._pathToModule+'ENOXCAD_Save/assets/icons/32/'+node.Icons+'.png';
				}
				// We look for the current node in selectedNodes fisrt and then in allNodes because most of the time the current node will be selected and this array is smaller
				var currentNode = that.selectedNodes[node.NodeId];
				if (typeof currentNode == 'undefined')
					currentNode = that.allNodes[node.NodeId];

				// If it's a new node, add it in that.allNodes and in that.model
				if (typeof currentNode == 'undefined') {
					currentNode = TreeNodeModel({
						'label':node.Title,
						'icons':[iconPath],
						/*'badges': {
	                        bottomRight: iconPath
	                    },*/
 						 grid : node
					});

					that.allNodes[node.NodeId] = currentNode;
					that.model.addRoot(currentNode);
				}
				// Else update it
				else {
					currentNode.updateOptions({
						'label':node.Title,
						'icons':[iconPath],
						/*'badges': {
	                        bottomRight: iconPath
	                    },*/
 						 grid : node
					});
				}
				if (that.filterNotModified){
					if (currentNode._options.grid.Status=='I_UPSCachedInfo')
					// Ignore section tile
						currentNode.hide();
					else
						currentNode.show();
				}
				else
					currentNode.show();
			});

			this.model.pushUpdate();
			// I removed this sort after a node update, because if before the update the user chose sort desc, after update it will return asc
			//this.treeListView.getManager().sortColumnContent('tree', {sortOrder:'asc'});

			// Update availability of every commands in the ActionBar
			for ( var i in this.actionBarCommands)
				this.actionBarCommands[i].updateAvailability(this.selectedNodes);

			// update stats
			this.triptych.updateStatsInfo(nbNew,nbMod,nbExc,nbInc);

			//display assigned bookmark of selected node if existing
			var selected = this.xso.get();
			// update the properties view if 1 node is selected
			if (selected.length == 1)
				this.triptych.updateBookmarkLabel( selected[0]._options.grid.AssignedBookmark);

		},
		displayWarning: function(AllIncludedLocked,AllIncludedWithReadAccess){
			if (!AllIncludedLocked)
				this.triptych.DisplayNotLockedWarning();
			if(!AllIncludedWithReadAccess)
				this.triptych.DisplayReadAccessWarning();
		},


		// 5)
		onToogleSaveChange : function(cellInfos) {
			// select the node of this toogle
			cellInfos.nodeModel.select(true);

			// set value of operation and newSaveValue
			var operation, newSaveValue;
			var grid = cellInfos.nodeModel.options.grid;
			if (grid.Save == 'I_UPSForcedToBeSaved' || grid.Save == 'I_UPSWarning' || grid.Save == 'I_UPSToBeSaved') {
				operation = 'Exclude';
				newSaveValue = 'I_UPSExcluded';
			} else {// if ('I_UPSCannotBeSaved' || 'I_UPSExcluded' || 'I_UPSNoSave')
				operation = 'Include';
				newSaveValue = 'I_UPSToBeSaved';
			}

			// update the model
			var newGrid = grid;
			newGrid.Save = newSaveValue;
			cellInfos.nodeModel.updateOptions({
				grid : newGrid
			});

			// warn the CAD
			var content = {
				selectedNodesId : [ grid.NodeId ]
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad(operation, '1.0', content);
		},




		// 6)
		/**
		 * @param {TreeNodeModel.grid} iNodes
		 * @param {boolean} iFilterNotModified
		 * @param {string} iRestrictedCharactersForFileName
		 * @param {string} iMyAppsBaseUrl
		 * @param {string} iUserId
		 * @param {string} iLang
		 * @param {boolean} iIsAsyncSave
		 * @return /
		 */
		init : function(iNodes,iSaveScope,ChangeActionName, iFilterNotModified, iRestrictedCharactersForFileName, iMyAppsBaseUrl, iUserId, iLang, iIsAsyncSave,iUnreserveSaveOn,nbNew,nbMod,nbExc,nbInc,ShowPGP,PGPSaveOn) {

			this.saveScope=iSaveScope;
			this.filterNotModified = iFilterNotModified;
			this.restrictedCharactersForFileName = iRestrictedCharactersForFileName;

	    	if (!window["COMPASS_CONFIG"]) window["COMPASS_CONFIG"] = {};
	       	window["COMPASS_CONFIG"].myAppsBaseUrl = iMyAppsBaseUrl;
	       	window["COMPASS_CONFIG"].userId = iUserId;
	       	window["COMPASS_CONFIG"].lang = iLang;



	       	//Create Toolbar
	       	ToolBarController.init(this.saveScope,this.filterNotModified);
	      //create an immersive frame for popups (new filename dalog, duplicate dialop ...)
	       	this.myImmersiveFrame=new WUXImmersiveFrame({}).inject(widget.body,'top');

	       	// Load Model Nodes
			this.loadNodes(iNodes,nbNew,nbMod,nbExc,nbInc);
			this.triptych.Show();
			//Update Save options
			if(ChangeActionName!='')
				this.triptych.SetWorkUnderInfo(ChangeActionName);
			this.triptych.updateSaveAsync(iIsAsyncSave);
			this.triptych.updateUnreserveCheck(iUnreserveSaveOn);
			this.triptych.updateStatsInfo(nbNew,nbMod,nbExc,nbInc);
			if (ShowPGP){
				this.triptych.updatePGPSave(PGPSaveOn);
				this.triptych.showPGPCheckBox();
			}

		},

		IncludeInSaveScope : function(ActiveCommand) {
			console.log('Include selected nodes');
			var that = this;
			this.ActiveCommandId =ActiveCommand;


			for ( var i in that.selectedNodes) {
				var operation, newSaveValue;
				var grid = that.selectedNodes[i]._options.grid;

				if ('I_UPSCannotBeSaved' || 'I_UPSExcluded' || 'I_UPSNoSave'){// if
					operation = 'Include';
					newSaveValue = 'I_UPSToBeSaved';

				// update the model
				var newGrid = grid;
				newGrid.Save = newSaveValue;
				that.selectedNodes[i].updateOptions({
					grid : newGrid
				});

				// warn the CAD
				var content = {
					selectedNodesId : [ grid.NodeId ]
				}
				XCAD_InteractionsWEB_CAD.sendMessageToCad(operation, '1.0', content);
				}

			}

		},
		ExcludeFromSaveScope : function(ActiveCommand) {
			console.log('Exclude selected nodes');
			var that = this;
			this.ActiveCommandId =ActiveCommand;


			for ( var i in that.selectedNodes) {
				var operation, newSaveValue;
				var grid = that.selectedNodes[i]._options.grid;
				if (grid.Save == 'I_UPSForcedToBeSaved' || grid.Save == 'I_UPSWarning' || grid.Save == 'I_UPSToBeSaved') {
					operation = 'Exclude';
					newSaveValue = 'I_UPSExcluded';


				// update the model
				var newGrid = grid;
				newGrid.Save = newSaveValue;
				that.selectedNodes[i].updateOptions({
					grid : newGrid
				});

				// warn the CAD
				var content = {
					selectedNodesId : [ grid.NodeId ]
				}
				XCAD_InteractionsWEB_CAD.sendMessageToCad(operation, '1.0', content);
				}
				/*if (selectedNodes[i]._options.grid.Status == 'I_UPSNew') {
					isEnable = false;
					break;
				}*/
			}

		},
		// 7)
		showNewFileNameSidePanel : function() {
			console.log('showNewFileNameSidePanel');
			var that = this;
			this.ActiveCommandId = 'idNewFileNameCmd';

			// Create the view and display it in the left panel
		    require(['DS/ENOXCAD_Save/views/XCAD_NewFileNameView'],
    		function (ENOUPSNewFileNameView) {
				// Get the file name of the selected node
				var firstKeySelectedNodes = Object.keys(that.selectedNodes)[0];
				var selectedNode = that.selectedNodes[firstKeySelectedNodes];
				var fileName = selectedNode._options.grid.Filename;

				// Remove extention in oldFileName
				var fileNameWithOutExt = fileName.replace(/\.[^/.]+$/, "");
				console.log('fileNameWithOutExt = "' + fileNameWithOutExt + '"');

				// Create the newFileNameView, insert it in the left panel and display the left panel
				var newFileNameView = new ENOUPSNewFileNameView(fileNameWithOutExt, that.restrictedCharactersForFileName);
		    	//that.triptych.showLeftPanel(newFileNameView);
		    });
		},
		showDuplicateDialog:function(id){
			console.log('showNewFileNameSidePanel');
			var that = this;
			this.ActiveCommandId = id;
			require(['DS/ENOXCAD_Save/views/XCAD_DuplicateView'],
					function(ENOUPSDuplicateView){
				var newDupliacteView=new ENOUPSDuplicateView();
			});
		},
        onNewFileNameOk : function(newFileNameWithOutExt) {
            // warn the CAD
			var content = {
				selectedNodesId : Object.keys(this.selectedNodes),
				newFileName: newFileNameWithOutExt
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('newFileName', '1.0', content);

        },
        onDuplicateOk: function(prefixForDup) {
            // warn the CAD
			var content = {
				selectedNodesId : Object.keys(this.selectedNodes),
				prefixDup: prefixForDup
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('duplicate', '1.0', content);

        },


		/* 8) derivedOutputs = [{
        			name : 'derived outputs name',
        			checked : true/false,
        			mixedState : true/false
        		},
        		...]
		*/
		showDerivedOutputSidePanel : function(derivedOutputs) {
			console.log('showDerivedOutputSidePanel');
			var that = this;
			this.ActiveCommandId = 'ENOUPSSetDerivedOutputCmd';

			// Create the view and display it in the left panel
		    require(['DS/ENOXCAD_Save/views/XCAD_SetDerivedOutputView'],
    		function (ENOUPSSetDerivedOutputView) {
				// Create the SetDerivedOutput view, insert it in the left panel and display the left panel
				var newDerivedOutputView = new ENOUPSSetDerivedOutputView(derivedOutputs);
		    	that.triptych.showLeftPanel(newDerivedOutputView);
		    });
		},
        onSetDerivedOutputOk : function(derivedOutputs_Icon_Dico) {
			//this.hideLeftSidePanel();
            // warn the CAD
			var content = {
				derivedOutputs_Icon_Dico : derivedOutputs_Icon_Dico
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('DerivedOutputOK', '1.0', content);
        },



		// 9)
		hideLeftSidePanel : function() {
			this.triptych.hideLeftPanel();
		},
		leftSidePanelHided : function() {
			console.log('leftSidePanelHided (idNewFileNameCmd)');
			this.actionBarCommands[this.ActiveCommandId].setState(false, false);
			this.ActiveCommandId = '';
		},



		// 10)
		toogleRightPanel : function() {
			this.triptych.toogleRightPanel();
		},



		// 11)
		displayNotif : function(level, title, subtitle, message) {
			this.notificationsManagerUXMessages.addNotif({
				level: level,
				title: title,
				subtitle: subtitle,
				message: message,
				sticky: true
			});
		},

		// 12)
		onUpdatePreview : function(previewBase64) {
			document.getElementById('idBase64').setAttribute('src', 'data:image/png;base64, ' + previewBase64);
		},

		onChangeIsAsyncSave : function(iIsAsyncSave) {
            // warn the CAD
			var content = {
				isAsyncSave : iIsAsyncSave
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('ChangeIsAsyncSave', '1.0', content);
		},
		onChangeUnreserveCheck : function(iUnreserve) {
            // warn the CAD
			var content = {
					bUnreserve : iUnreserve
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('ChangeUnreserveCheck', '1.0', content);
		},
		onChangePGPCheck : function(iSavePGP) {
            // warn the CAD
			var content = {
					bSavePGP : iSavePGP
			}
			XCAD_InteractionsWEB_CAD.sendMessageToCad('ChangePGPCheck', '1.0', content);
		},
	};// << End XCAD_MainController definition

	if (widget.launched) {
		widget.XCAD_MainController.onLoad();
	} else {
		widget.onLoad = widget.XCAD_MainController.onLoad;
	}

}); // -- End of require

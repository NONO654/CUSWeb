define('DS/ENOXCAD_Save/views/XCAD_RightView', [
// -- Module Dependencies --
'UWA/Core', 'DS/Core/Core', 'DS/ApplicationFrame/ContextualUIManager', 'DS/WebappsUtils/WebappsUtils', 
'DS/Utilities/Dom', 'DS/Controls/Button', 'DS/Controls/Tab','DS/Controls/Toggle','i18n!DS/ENOXCAD_Save/assets/nls/ENOXCADWebSaveRightViewNls'], 
function(UWACore, WUXCore, ContextualUIManager, WebappsUtils, DomUtils, Button, WUXTab,WUXToggle,i18nENOXCADWebSaveRightView) {
	'use strict';

	var ENOUPSRightView =  {
		_previewMainDiv:null,
		_saveInfoview:null,
		_saveOptionsview:null,
		_ENOUPSRightDiv:null,
		_ttNew :null,   
		_tMod : null,
		_tExc :null,
		_tInc :null,
		_toogleUnreserve:null,
		_toogleAsyncSave:null, 
		_tooglePGP:null,
		_contextualBookmarkInfo:null,
		_BookmarkLabelView:null, 
		_WorkUnderInfo:null,
		_ChangeActionLabel:null, 
		_NoDefaultBookmarkWarningView:null,
		_NotAllLockedWarningView:null,
		_NotAllWithReadAccessWarningview:null,
		init: function (){
			
			var pathToModule = WebappsUtils.getWebappsBaseUrl();
			
		this._ENOUPSRightDiv = new UWA.Element('div', {
			class: 'PreviewSaveInfoViewContainer'
		});
		
		var previewBase64 = 'Qk1CAAAAAAAAAD4AAAAoAAAAAQAAAAEAAAABAAEAAAAAAAQAAADDDgAAww4AAAAAAAAAAAAAAAAAAP///wCAAAAA';// blank

		this._previewMainDiv = new UWA.Element('div',{class:'ContextualInfo'}).inject(this._ENOUPSRightDiv);
		
		new UWA.Element('img', {
			id: 'idBase64',
			class:'PreviewImg'
            /*styles: {
			    width: '180',
			    height: '100',
			    border: '1px solid black'
            }*/,
            src: 'data:image/png;base64,' + previewBase64,
            alt: 'Preview'
		}).inject(this._previewMainDiv);

		/*_BookmarkLabelView=new UWA.Element('div',styles: {
			height : '100%',
			width : '100%',
        	margin: '20px'
        }).inject(this._previewMainDiv);*/
		this._contextualBookmarkInfo=new UWA.Element('div', {
			class:'BookmarkInfo'
		}).inject(this._previewMainDiv);
		
		new UWA.Element('img', {
			class: 'contextual_bookmark_icon',
			id : 'bookmarkIcon',
            src: pathToModule+'ENOXCAD_Save/assets/icons/32/I_ENOUPSBookmark.png'
		}).inject(this._contextualBookmarkInfo);
		
		this._BookmarkLabelView = document.createTextNode('bookmark1');
	
		this._contextualBookmarkInfo.appendChild(this._BookmarkLabelView); 
		new UWA.Element('hr',{class :'Separator'}).inject(this._ENOUPSRightDiv);
		//save stats
		this._saveInfoview=new UWA.Element('div', {
			class: 'SaveInfo',
			id : 'SaveStats',
            /*styles: {
				height : '100px',
				width : '200px',
            },*/
            //text : i18nENOXCADWebSaveRightView.get("Save_stats")
		});
		var stats = document.createElement('div');
		stats.appendChild(document.createTextNode(i18nENOXCADWebSaveRightView.get("Save_stats")));
		stats.appendChild(document.createElement('br'));// Create a <h1> element
		this._tNew = document.createTextNode('New : ');     // Create a text node
		stats.appendChild(this._tNew); 
		var linebreak = document.createElement('br');
		stats.appendChild(linebreak); 
		this._tMod = document.createTextNode('Modified : ');  
		stats.appendChild(this._tMod);
		var linebreak = document.createElement('br');
		stats.appendChild(linebreak); 
		this._tExc= document.createTextNode('Excluded : ');  
		stats.appendChild(this._tExc);
		var linebreak = document.createElement('br');
		stats.appendChild(linebreak); 
		this._tInc = document.createTextNode('Included : ');  
		stats.appendChild(this._tInc);
		var linebreak = document.createElement('br');
		stats.appendChild(linebreak); 
		this._saveInfoview.appendChild(stats);
		this._saveInfoview.inject(this._ENOUPSRightDiv);
		//new UWA.Element('hr').inject(this._ENOUPSRightDiv);
		// WorkUnder info display 
		this._WorkUnderInfo=new UWA.Element('div', {class:'WorkUnder',
			styles:{
				visibility:'hidden'
				}
		}).inject(this._ENOUPSRightDiv);
		
		new UWA.Element('img', {
			class: 'WorkUnder_icon',
			id : 'WorkUnder',
            src: pathToModule+'ENOXCAD_Save/assets/icons/32/I_ENOUPSSaveUnderChange.png'
		}).inject(this._WorkUnderInfo);
		
		var workUnder = document.createTextNode(i18nENOXCADWebSaveRightView.get("Work_Under"));
		this._WorkUnderInfo.appendChild(workUnder);
		var linebreak = document.createElement('br');
		this._WorkUnderInfo.appendChild(linebreak);
		this._ChangeActionLabel=document.createTextNode('Ca12458741699421');
		this._WorkUnderInfo.appendChild(this._ChangeActionLabel);

		// No default bookmark warning view 
		
		this._NoDefaultBookmarkWarningView=new UWA.Element('div', {
			styles:{
				visibility:'hidden'
				}
		}).inject(this._ENOUPSRightDiv);
		new UWA.Element('img', {
			class: 'warning_icon',
			id : 'warningBookmark',
            src: pathToModule+'ENOXCAD_Save/assets/icons/32/I_UPSWarning.png'
		}).inject(this._NoDefaultBookmarkWarningView);
		var warningmessage=document.createTextNode(i18nENOXCADWebSaveRightView.get("No_DefaultBookmark"));
		this._NoDefaultBookmarkWarningView.appendChild(warningmessage);
		//No all locked warning view
		this._NotAllLockedWarningView=new UWA.Element('div', {
			styles:{
				visibility:'hidden'
				}
		}).inject(this._ENOUPSRightDiv);
		new UWA.Element('img', {
			class: 'warning_icon',
			id : 'warningUnlocked',
            src: pathToModule+'ENOXCAD_Save/assets/icons/32/I_UPSWarning.png'
		}).inject(this._NotAllLockedWarningView);
		var warningmessage=document.createTextNode(i18nENOXCADWebSaveRightView.get("Not_AllLocked"));
		this._NotAllLockedWarningView.appendChild(warningmessage);
		//No read access warning view 
		this._NotAllWithReadAccessWarningview=new UWA.Element('div', {
			class:'warning_last'
		}).inject(this._ENOUPSRightDiv);
		new UWA.Element('img', {
			class: 'warning_icon',
			id : 'warningUnlocked',
            src: pathToModule+'ENOXCAD_Save/assets/icons/32/I_UPSWarning.png'
		}).inject(this._NotAllWithReadAccessWarningview);
		var warningmessage=document.createTextNode(i18nENOXCADWebSaveRightView.get("No_ReadAccess"));
		this._NotAllWithReadAccessWarningview.appendChild(warningmessage);
			
		
		// Check boxes 
		var that=this; 
		this._saveOptionsview=new UWA.Element('div', {
			class: 'saveoptions',
			id : 'SaveOptions'
		}).inject(this._ENOUPSRightDiv);
		
		this._tooglePGP=new WUXToggle({
		    label: i18nENOXCADWebSaveRightView.get("PGP_checkbox"), 
		    touchMode: false,
		    visibleFlag:false
		}).inject(this._saveOptionsview,'bottom');
		//this._tooglePGP.getContent().addClassName('check_box');
		this._tooglePGP.addEventListener('change', function() {
			widget.XCAD_MainController.onChangePGPCheck(that._tooglePGP.checkFlag);
		});
		
		this._toogleUnreserve = new WUXToggle({
		    label: i18nENOXCADWebSaveRightView.get("Unreserve_checkbox"), 
		    touchMode: false
		}).inject(this._saveOptionsview,'bottom');
		//this._toogleUnreserve._toggleIcon.addClassName('checkbox-container');
		
		this._toogleUnreserve.addEventListener('change', function() {
			widget.XCAD_MainController.onChangeUnreserveCheck(that._toogleUnreserve.checkFlag);
		});
		this._toogleAsyncSave = new WUXToggle({
		    label:i18nENOXCADWebSaveRightView.get("Async_checkbox"), 
		    touchMode: false
		}).inject(this._saveOptionsview,'bottom');
		//this._toogleAsyncSave.getContent().addClassName('checkbox-container');
		this._toogleAsyncSave.addEventListener('change', function() {
			widget.XCAD_MainController.onChangeIsAsyncSave(that._toogleAsyncSave.checkFlag);
		});
		/*new UWA.Element('h4', {
			text: 'Save : '
		}).inject(ENOUPSRightView);*/
		// 2) Init the tab
		/*var tabWindow = new WUXTab({
			pinFlag: false,
			displayStyle : ['strip'],
		    touchMode: true
		});

		// 3) Insert 3 views in the tab
		// addTab(			label, 					content, 			 index, isSelected, value, icon, allowClosableFlag, showTitleFlag) -> {Object}
		tabWindow.addTab(	'Preview & Bookmarks', 	perviewBookmarksView, 1);
		tabWindow.addTab(	'Properties', 			propertiesView, 		 2);
		tabWindow.addTab(	'Save Options', 		saveOptionsView, 	 0, true);
		
		//tabWindow.inject(ENOUPSRightView);
		perviewBookmarksView.inject(ENOUPSRightView);*/
	
		},
		
		updateSaveInfo : function(inbNew,inbMod,inbExc,inbInc) {
			this._tNew.textContent =i18nENOXCADWebSaveRightView.get("Nb_New", { nbNew: inbNew });
			this._tMod.textContent =i18nENOXCADWebSaveRightView.get("Nb_Mod", { nbMod: inbMod });
			this._tExc.textContent =i18nENOXCADWebSaveRightView.get("Nb_Exc", { nbExc:inbExc });
			this._tInc.textContent =i18nENOXCADWebSaveRightView.get("Nb_Inc", { nbInc: inbInc});
		},
		UpdateBookmarkContextualInfo : function(bookmarkLabel) {	
			if (bookmarkLabel != 'undefined' && bookmarkLabel!=''){
			this._BookmarkLabelView.textContent =bookmarkLabel;
			this._contextualBookmarkInfo.style.visibility='visible';
			}
			else 
				this._contextualBookmarkInfo.style.visibility='hidden';
			
		},
		UpdateWorkUnderInfo : function(ChangeActionLabelLabel) {	
			if (ChangeActionLabelLabel != 'undefined' && ChangeActionLabelLabel!=''){
			this._ChangeActionLabel.textContent =ChangeActionLabelLabel;
			this._WorkUnderInfo.style.visibility='visible';
			}
			else 
				this._WorkUnderInfo.style.visibility='hidden';
			
		},
		DisplayNoDefaultBookmarkWarning : function() {	
				this._NoDefaultBookmarkWarningView.style.visibility='visible';			
		},
		DisplayNotAllLockedWarning : function() {	
			this._NotAllLockedWarningView.style.visibility='visible';			
		},
		DisplayNoReadAcceddWarning : function() {	
			this._NotAllWithReadAccessWarningview.style.visibility='visible';			
		},
		onUpdatePreview : function(previewBase64) {
			document.getElementById('idBase64').setAttribute('src', 'data:image/png;base64, ' + previewBase64);
		},
		onRemovePreview : function(){
			document.getElementById('idBase64').setAttribute('src', 'data:image/png;base64, ' + 'Qk1CAAAAAAAAAD4AAAAoAAAAAQAAAAEAAAABAAEAAAAAAAQAAADDDgAAww4AAAAAAAAAAAAAAAAAAP///wCAAAAA');
		}
	
	
		
	};
return ENOUPSRightView;
});

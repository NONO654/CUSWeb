define('DS/ENOXCAD_Save/views/XCAD_Triptych', [ 
	// -- Module Dependencies --
	'UWA/Core', 
	'DS/Core/Core', 
	'DS/ApplicationFrame/ContextualUIManager', 
	'DS/WebappsUtils/WebappsUtils', 
	'DS/Utilities/Dom', 
	
	'DS/CoreEvents/ModelEvents',
	'DS/ENOXTriptych/js/ENOXTriptych', 
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD',
	'DS/ENOXCAD_Save/views/XCAD_RightView'
], 
function(UWACore, WUXCore, ContextualUIManager, WebappsUtils, DomUtils, 
		ModelEvents, ENOXTriptych, XCAD_InteractionsWEB_CAD, ENOUPSRightView) {
	'use strict';

	var ENOUPSTriptych = function(treeListView/*, saveOptionsView, perviewBookmarksView, propertiesView*/) {
		var triptychDiv= UWACore.createElement('div', {
            class:'riptych-div'
        });
		// 1) Define the object Triptych
		var _ENOUPSTriptych = UWA.extend(new ENOXTriptych(), {
			_modelEvents : null,
			_options : null,
	        _divleft : null,
	        _divmain: null,
	        _divright: null,
	        
	        showLeftPanel : function(iView) {
	        	// Reset the content of the left side panel (_divleft) then insert the new View (iView) in it
	        	this._divleft.innerHTML = "";
	    		this._divleft.appendChild(iView);
	    		// Show the left side panel and make it modal
		    	this._modelEvents.publish({ event: 'triptych-show-panel', data: 'left' });
		    	this._modelEvents.publish({ event: 'triptych-make-modal', data: 'left' });
	        },
	        hideLeftPanel : function() {
	        	if (this._isLeftOpen)
	        		this._modelEvents.publish({ event: 'triptych-hide-panel', data: 'left' });
	        },
	        showPGPCheckBox:function(){
	        	ENOUPSRightView._tooglePGP.visibleFlag=true; 
	        },
	        toogleRightPanel : function() {
	    		// Show the right side panel (not modal)
		    	this._modelEvents.publish({ event: 'triptych-toggle-panel', data: 'right' });
	        },
	        updateStatsInfo : function(nbNew,nbMod,nbExc,nbInc){
	        	ENOUPSRightView.updateSaveInfo(nbNew,nbMod,nbExc,nbInc);
	        },
	        updateSaveAsync: function(checkFlag){
	        	ENOUPSRightView._toogleAsyncSave.checkFlag=checkFlag; 
	        },
	        updatePGPSave: function(checkFlag){
	        	ENOUPSRightView._tooglePGP.checkFlag=checkFlag; 
	        },
	        updateUnreserveCheck: function(checkFlag){
	        	ENOUPSRightView._toogleUnreserve.checkFlag=checkFlag; 
	        },
	        updateBookmarkLabel:function(bookmarkLabel){
	        	ENOUPSRightView.UpdateBookmarkContextualInfo(bookmarkLabel); 
	        },
	        SetWorkUnderInfo:function(ChangeActionLabelLabel){
	        	ENOUPSRightView.UpdateWorkUnderInfo(ChangeActionLabelLabel);
	        },
	        DisplayNotLockedWarning:function(){
	        	ENOUPSRightView.DisplayNotAllLockedWarning();
	        },
	        DisplayReadAccessWarning:function(){
	        	ENOUPSRightView.DisplayNoReadAcceddWarning();
	        },
	        onUpdatePreview : function(previewBase64) {
	        	ENOUPSRightView.onUpdatePreview(previewBase64) ;
			},
			onRemovePreview : function(){
				ENOUPSRightView.onRemovePreview() ;
			},
			InitDataGridView: function(iDataGridView){
				iDataGridView.inject(_ENOUPSTriptych._divmain);
			},
			Show: function(){
				this._container.style.visibility='visible';
			},
			Hide: function(){
				this._container.style.visibility='hidden';
			}
		});
		
		// 2) Init _ENOUPSTriptych ModelEvents
		_ENOUPSTriptych._modelEvents = new ModelEvents();

		_ENOUPSTriptych._modelEvents.subscribe({ event: 'triptych-hide-panel' }, function () {
            widget.XCAD_MainController.leftSidePanelHided();
        });
		
		// 3) Set _ENOUPSTriptych options
		_ENOUPSTriptych._options = {
            left: {
                minWidth: 200,
                resizable: true,
                originalSize: 350, // in pixel
                originalState: 'close', // 'open' / 'close'
                overMobile: false, // if true, panel will move over main panel on small devices
                withClose: true
            },
            right: {
                minWidth: 230,
                resizable: true, 
                originalSize: 220, 
                originalState: 'open', // 'open' / 'close'
                overMobile: false, // if true, panel will move over main panel on small devices
                withClose: false
            },
            container: UWACore.createElement('div', {class:'triptych'}).inject(widget.body), // the container where to instanciate the component
            withtransition: true, // to have smooth transition when closing/opening panels
            modelEvents: _ENOUPSTriptych._modelEvents, // to retrieve/emit events
        };
		// TODO : add left panel is modal

        
        
        // 4) Create 3 divs (left, main, right)
		/*_ENOUPSTriptych._divleft = UWACore.createElement('div', {
            styles: {
			    width: '100%',
			    height: '100%',
			    position: '60px'
            }
        });*/
        
		_ENOUPSTriptych._divmain = UWACore.createElement('div', {
            styles: {
			    width: '100%',
			    /*height: '500px',*/
			    
            }
        });
		if (treeListView != null)
			treeListView.inject(_ENOUPSTriptych._divmain);
		
        ENOUPSRightView.init();
        
        _ENOUPSTriptych._divright = ENOUPSRightView._ENOUPSRightDiv;
        
        //rightView.inject(_ENOUPSTriptych._divright);
        
        // 5) Init and return the _ENOUPSTriptych
        _ENOUPSTriptych.init(_ENOUPSTriptych._options, _ENOUPSTriptych._divleft, _ENOUPSTriptych._divmain, _ENOUPSTriptych._divright);

		return _ENOUPSTriptych;
	};

	return ENOUPSTriptych;
});

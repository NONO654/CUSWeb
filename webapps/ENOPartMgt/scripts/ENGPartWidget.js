/**
 * @overview Define the 3DSpace widget.
 * @licence Copyright 2006-2014 Dassault Systèmes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOPartMgt/scripts/ENGPartWidget', [
    'UWA/Core',
    'DS/W3DXComponents/Skeleton',
    'DS/ENOPartMgt/scripts/Models/PartModel', 
    'DS/ENOPartMgt/scripts/SkeletonUtils/ContentDisplaySkeleton',
    'DS/ENOPartMgt/scripts/TempPlatformServices',
    'DS/ENOPartMgt/scripts/PartUtility',
    'i18n!DS/ENOPartMgt/assets/nls/ENOPartMgtNLS',
    'css!DS/ENOPartMgt/ENGParts.css'
], function(
    UWACore,
    Skeleton,
    PartModel,
    ContentDisplaySkeleton,
    PlatformServices,
    PartUtility,
    NLS
) {
'use strict';
    
    var _maxHeight, _bones, ENGPartWidget, _started = false;
    
    function initBones() {
        if (_bones) {
            _bones.destroy();
            PartUtility.updateWidgetTitle();
        }

        var configRendererMap, configOptions,contextInfo; 
        
        configRendererMap = {
            minimizeIdCardView : widget.getBool('id-card-view'),
            nbItems : widget.getValue('nb-items')
        };
        
        configOptions = {
            events : {
                onItemSelect : PartUtility.updateWidgetTitle
            }
        };


		 window.enoviaServerENGPartWidget = {
                mySkeleton: null,
                securityContext:null,
                project:null,
                organization:null,
                locale:widget.lang,
                userInfo: PartUtility.getUserInfo(),
                role:null,
                query:null,
        }
        _bones = new Skeleton(ContentDisplaySkeleton.getRendererMap(configRendererMap),
        		ContentDisplaySkeleton.getRootIdCardOptions(configOptions));

        enoviaServerENGPartWidget.mySkeleton = _bones;

        _bones.render().inject(widget.body.getElement("#widget-content"));

        contextInfo = PartUtility.retrieveSecurityContext().then(function(resp){
    		enoviaServerENGPartWidget.securityContext = resp.SecurityContext;
    		var securityContextSplit = enoviaServerENGPartWidget.securityContext.split(".");
    		enoviaServerENGPartWidget.role = securityContextSplit[0];
    		enoviaServerENGPartWidget.organization = securityContextSplit[1];
    		enoviaServerENGPartWidget.project = securityContextSplit[2];
    	});
    	
        if (_maxHeight) {
            _bones.setHeight(_maxHeight);
        }
    }
    
    ENGPartWidget = {
    	
    	onReady : function(){    		
    		 widget.setBody([{
                 tag: 'div',
                 id: 'widget-content'
             }]);
    		 
        	 
        	initBones(); 

    	},
        
        onLoad : function() {  
        	PlatformServices.initializePlatformServicesIdentifiers(ENGPartWidget.onReady); 
        },
    	
        onRefresh : function() {
        	initBones();
        	PartUtility.refreshTaggerProxies();
        },
        onSearch :function(searchQuery){
        	initBones();
        	window.enoviaServerENGPartWidget.query = searchQuery;
        },
        onResetSearch :function(){
        	initBones();
        	window.enoviaServerENGPartWidget.query = null;
        	alert("Even onResetSearch set");
        }

       
    };
    
    return ENGPartWidget;
});

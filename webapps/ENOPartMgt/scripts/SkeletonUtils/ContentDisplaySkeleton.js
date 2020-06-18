/**
 * @overview Skeleton options for the 3DSpace widget.
 * @licence Copyright 2006-2014 Dassault Systèmes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOPartMgt/scripts/SkeletonUtils/ContentDisplaySkeleton',
        [ 
          'DS/W3DXComponents/Skeleton',
          'DS/W3DXComponents/ContentSet',
          'DS/ENOPartMgt/scripts/Collections/PartContentsCollection',
          'DS/ENOPartMgt/scripts/SkeletonUtils/PartSkeleton',
          'DS/ENOPartMgt/scripts/Models/PartModel',
          'DS/PlatformAPI/PlatformAPI',
          'i18n!DS/ENOPartMgt/assets/nls/ENOPartMgtNLS'          
      ], 
    function (
        Skeleton,
        ContentSet,
        PartContentsCollection,
        PartSkeleton,
        PartModel,
        PlatformAPI,
        ENGNLS
    ) {
    
    'use strict';
    
    var ContentSetWithEvents, ContentDisplaySkeleton;
    
    ContentSetWithEvents = ContentSet.extend();
    
    ContentDisplaySkeleton = {
        
    		getRootIdCardOptions : function(config) {
                return {
                    root : 'contents',
                    responsiveTrigger : function () {
                        var viewType = widget.getView().type;
                        return viewType === 'maximized' || viewType === 'fullscreen';
                    },
                   // minimizeIdCards : true,
                    rootIdCardOptions : {
                    	collapsed : true,
                        model : new PartModel({
                        	title : ENGNLS.ENG_Part_List,
                            owner : PlatformAPI.getUser().firstName+" "+PlatformAPI.getUser().lastName
                        }),
                        attributesMapping : {
                            title : 'title',
                            ownerName : 'owner'
                        },                      
                        facets : [ {
                            name : 'contents',
                            text : ENGNLS.ENG_Content,
                            icon : 'picture',
                            handler : Skeleton.getRendererHandler('contents')
                        }]
                    },
                    events : config.events
                };
            },
            
            getRendererMap : function(config) {
                return {
                    contents : {
                        collection : PartContentsCollection,
                        autoFetch : false,
                        view : ContentSetWithEvents,
                        viewOptions : PartSkeleton.getContentSetOptions(config),
                        idCardOptions : PartSkeleton.getIdCardOptions(config),
                        idKey : 'id'
                    }
                };
            }
        };
    
    return ContentDisplaySkeleton;
});

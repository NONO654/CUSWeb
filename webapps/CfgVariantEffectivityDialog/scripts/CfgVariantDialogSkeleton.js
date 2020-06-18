/**
 * Implementation of skeleton object
 * Used as main view of this widget
 * It manage the probe list and settings of each one
 */
define('DS/CfgVariantEffectivityDialog/scripts/CfgVariantDialogSkeleton', 
        [ 'UWA/Core', 
          'UWA/Class/Model',
          'UWA/Class/Collection', 
          'UWA/Class/View',

        // WebApps
          'WebappsUtils/WebappsUtils', 
          'DS/W3DXComponents/Skeleton',
          'DS/CfgVariantEffectivity/scripts/CfgVariantInit',
        'DS/CfgVariantEffectivityDialog/scripts/CfgVariantSkeletonCollection'

],

function(UWA, Model, Collection, View, WebappsUtils, Skeleton,CfgVariantInit,myCollection) {

    var mySkeleton = function(target,productID) { //constructor 
        var collection = new myCollection(productID);
        var self = 
        {
                bones: null,
                height: '300',
                unMaximizedHeight: null,
                onLoad: function () {
                   
                    if (self.bones) { // Destroy Skeleton instance to recreate it
                        self.bones.destroy();
                    }

                    var generalViewOpts = {
                        useInfiniteScroll : false,
                        usePullToRefresh : false
                    };

                    var rootViewOptions = {
                        contents:{
                            useInfiniteScroll : false,
                            usePullToRefresh : false,
                        }
                    };                  

                    var ModelsView = UWA.Class.View;

                    /*
                     * Skeleton instantiation
                     */
                     self.bones = new Skeleton(
                     { // Renderers map
                         models: {

                             // Collection constructor
                             collection: collection,
                             //custom view
                             view: null,
                             // Root View options
                             viewOptions: rootViewOptions,
                             /*
                             * Options for module 'DS/W3DXComponents/IdCard, see module doc for examples.
                             * NOTE: The way to declare different "levels" (panels) in the Skeleton is by specifying it's facets.
                             * As explained earlier, if the handler contains Skeleton.getRendererHandler('RendererName'), it will instantiate what we call
                             * a CollecitonView, if it's a Constructor it will instantiate what we call a Detail View.
                             * If it's a Collection View, it can be used to navigate to different levels (panels)
                             */
                            idCardOptions: {

                                            // Facets and actions can now me functions as well, they receive the Model as parameter
                                            facets: function() {

                                                // Facets of this Renderer , it has to be an array
                                                return [{
                                                    text: 'Model', //Incidents
                                                    icon: 'plus-circled',

                                                    /*
                                                     * Skeleton static method: function factory that handles the rendering of the view
                                                     * Parameter can be either a String or a View.
                                                     */
                                                    handler: Skeleton.getRendererHandler('ModelsHandeler')

                                                }];
                                            }
                                        }
                         },
                                    ModelsHandeler: {
                                                               view: ModelsView.extend({
                                            
                                            name: 'models-view',
                                            tagName: 'div',                                            
                                            className: 'generic-detail',
                                            render: function() {
												return this;
                                            },
											setup: function(){
												var that = this;
																																													
												var callback = function (){
												
												setTimeout(function(){																													
													CfgVariantInit.InitModelOnUI(that.container, that.model, self.bones.getCollectionAt(0));													
												},100);	
												
                                                };
												self.bones.getCollectionAt(0).getEffectivityJSON(callback);
												
											}
											
                                        })
                                    }
                     }, 
                        // Skeleton options
                                {
                                    // Renderer that is going to be used for the Root (panel 0), if not specified the first declared renderer is used
                                    root: 'projects',

                                    // Option to activate the ChannelView in the root (see 'DS/W3DXComponents/Views/Item/SkeletonRootView') for more details
                                    useRootChannelView: widget.getValue('view') === 'channel',

                                    /*
                                     * Extra function to call to test if layout should be changed, should return truthy or falsy value
                                     * It is used when the Skeleton changes size, to test if it shoudl change from one column(contracted = default) to two columns (expanded)
                                     */
                                    responsiveTrigger: function() {
                                        var viewType = widget.getView().type;

                                        // If channel view is active then set responsive trigger to maximize
                                        if (widget.getValue('view') === 'channel') {
                                            return viewType === 'maximized' || viewType === 'fullscreen';
                                        } else {

                                            // If normal view, then let the width threshold of the skeleton set the responsiveness
                                            return false;
                                        }
                                    },

                                    // startRoute: '/models/',
                                    startRoute: '/models/0/ModelsHandeler/',

                                    events: {
                                        onItemSelect: function(model) {
                                            
                                        },
                                        onSlide: function(view, model) {
                                           
                                        },
                                        onRouteChange: function(route) {
                                      
                                            console.log('In route: ' + route);
                                        }
                                    }
                                });
             
                     // Don't forget to render and add to DOM
                     // var div = document.getElementById("target-container");
                     self.bones.render().inject(target);
                 },

                 // Widget Event
                 onViewChange: function (event) {
                     if ((event.type !== 'fullscreen') && (event.type !== 'maximized')) {
                         if (UWA.is(self.unMaximizedHeight)) {
                             self.bones.setHeight(self.unMaximizedHeight);
                             self.unMaximizedHeight = null;
                         }
                     } else {
                         if (UWA.is(event.height)) {
                             self.unMaximizedHeight = self.bones.container.clientHeight;
                             self.bones.setHeight(event.height);
                         }
                     }
                 },
             };
       
            self.onLoad();
    }
    
    return mySkeleton;
});

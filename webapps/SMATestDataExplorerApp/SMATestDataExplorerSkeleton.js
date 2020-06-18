define('DS/SMATestDataExplorerApp/SMATestDataExplorerSkeleton',
[
    'UWA/Core',
    'UWA/Class/Model',
    'UWA/Class/Collection',
    'DS/CoreEvents/Events',
    'DS/W3DXComponents/Skeleton',
    'DS/W3DXComponents/ContentSet',
    'DS/W3DXComponents/Views/Layout/ListView',
    'DS/W3DXComponents/Views/Layout/GridScrollView',
    'DS/W3DXComponents/Views/Layout/TableScrollView',
    'DS/W3DXComponents/Views/Item/TileView',
    'DS/W3DXComponents/Views/Item/ThumbnailView',
    'DS/WebappsUtils/WebappsUtils', 
    'DS/SMATestDataExplorerApp/Collection/SMATestDataExplorerCollection',
    'DS/SMATestDataExplorerApp/Model/SMATestDataExplorerModel',
    'DS/SMATestDataExplorerApp/View/SMATestDataExplorerPropertyView',
    'DS/SMATestDataExplorerApp/View/SMATestDataExplorerTreeView',
    'DS/SMATestDataExplorerApp/View/SMATestDataExplorerChartView',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
    'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerUtil',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
    'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels'
],
function (
    UWA,
    UWAModel,
    UWACollection,
    WUXEvent,
    Skeleton,
    ContentSet,
    ListView,
    GridScrollView,
    TableScrollView,
    TileView,
    ThumbnailView,
    WebappsUtils,
    TestDataCollection,
    TestDataModel,
    TestDataPropertyView,
    TestDataTreeView,
    TestDataChartView,
    TestDataSession,
    TestDataUtil,
    TestDataMessage,
    i18n) {

       'use strict';

       var TestDataSkeleton = Skeleton.extend({
           
           init: function( options ) {
               var self = this;
               this.panel = options.panel;
               
               // make context menu
               this.contextMenu = this._makeContextMenu( options.panel.getContent(), [{ 
                   label: i18n['create-link'], 
                   icon: WebappsUtils.getWebappsAssetUrl( 'SMATestDataExplorerApp', 'icons/32/link.png' ),
                   handler: this._createLink
               }]);
               
               this.contextMenu.model = null;
               this.contextMenu.hide();
               
               window.addEventListener( 'click', function( e ) {  
                   self.contextMenu.model = null; 
                   self.contextMenu.hide(); 
               } );
               this.panel.getContent().addEventListener( 'mouseleave', function( e ) { 
                   self.contextMenu.model = null;
                   self.contextMenu.hide();
                });
               
           	
                var rootViewOptions = {
                    contents: {
                        useInfiniteScroll: false,
                        usePullToRefresh: true
                    },
                    skeleton: this,
                    panel: this.panel
                };

               
               var itemEvents = {
                   onDblClick: function () { 
                       if( this.model ) {
                           var treeView = self.getViewAt( 0 );
                           treeView.selectItemById( this.model.id );
                       }
                   },
                   onItemRendered: function () {
                	   var icon, th, img;
                       var app = TestDataSession.get('app');
                       if( app && this.container ) { 
                           if( this.container.hasClassName( 'thumbnail-container' )) {
                               icon = TestDataUtil.getAsamIcon( this.model.get( 'bename' ), 'thumb' );
                               this.container.addClassName( 'tde-thumbitem' );
                               th = this.container.querySelector( '.thumbnail-header' );
                               img = UWA.createElement( 'img' ).inject( th );
                               img.src = icon;
                           } else {
                               icon = TestDataUtil.getAsamIcon( this.model.get( 'bename' ), 'tile' );
                               this.container.addClassName ( 'tde-tileitem' );
                               th = this.container.querySelector( '.tile-header' );
                               img = UWA.createElement( 'img' ).inject( th );
                               img.src = icon;
                           }
                       }
                   },

                   onContextMenu: function ( event ) { 
                       //TestDataUtil.validLinkItem(params.treeview.nodeModel
                       var contextMenu = document.querySelector('.tde-ctx-menu');
                       if( contextMenu ) {
                           contextMenu.style.left = event.clientX + 'px';
                           contextMenu.style.top = event.clientY + 'px';
                       }
                       contextMenu.model = this.model;
                       contextMenu.show();
                   }
               };
               

               var explorerCollectionOptions = { skeleton: this };
               var testDataItemViewOpts = {
                   mapping: {
                       title:    function () { 
                           return this.model.get( 'name' );
                       },
                       subtitle: function() {
	                       return this.model.get( 'aename' );
	                  },
	                  content: function() {
	                      return 'Database type: ' + this.model.get( 'bename' );
	                  }
                   },

                   events: itemEvents,
                   contextMenu: this.contextMenu,
               };

               var idCardEvents = {
                   onRender: function () {
                       //-- Draw some breadcrumbs
                       var header = this.container.querySelector( '.title-section' );

                       if ( header ) {
                           while( header.firstChild ) {
                               header.removeChild( header.firstChild );
                           }
                           var path = this.model.getPath();
                           var idpath = [];
                           var bcContainer = UWA.createElement( 'div' ).inject( header );
                           bcContainer.classList.add( 'tde-inline-container' );
                           UWA.createElement( 'i', { 'class': 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-drive', styles:{ 'margin-top':'10px' } }).inject( bcContainer );
                           var breadCrumb = UWA.createElement( 'h5' ).inject( bcContainer );
                           breadCrumb.classList.add( 'tde-breadcrumb-hdr' );
                           
                           while( path && path.length ) {
                               var model = path.pop();
                               var aid = model.get( 'aid' );
                               var eid = model.get( 'eid' );

                               idpath.push( aid +'/' + eid );
                               var crumbLabel = model.get( 'name' );
                               var crumbLink = UWA.createElement( 'a', { text: crumbLabel, collection: model.collection } );
                               crumbLink.classList.add( 'tde-breadcrumb' );
                               crumbLink.setAttribute( 'data-folderId', model.get( 'id' ) );
                               crumbLink.setAttribute( 'data-aid', aid );
                               crumbLink.setAttribute( 'data-eid', eid );
                               crumbLink.setAttribute( 'data-dbIdPath', idpath.slice() );
                               crumbLink.inject(breadCrumb);
                               breadCrumb.grab(document.createTextNode(' > '));
                           }
                           breadCrumb.grab( document.createTextNode( this.model.get( 'name' ) ) );
                               
                           header.addEvent( "click", function( event ) {
                               var id = event.target.getAttribute( 'data-folderId' );
                               if( id ) {
                                   var treeView = self.getViewAt( 0 );
                                   treeView.selectItemById( id );
                               }
                           });
                       }
                   }
               };

               var rootOptions = {
                   treeRenderer: {
                       collection: TestDataCollection,
                       collectionOptions: {
                           mode: options.mode
                       },

                       viewOptions: UWA.extend({
                           events: {
                               onItemViewDrag: function () {
                                   var evt = arguments[arguments.length - 1];
                                   var dom = arguments[arguments.length - 2];
                                   evt.dataTransfer.setData( 'testData', dom.model.id );
                               }
                           }
                       }, rootViewOptions ),

                       view : TestDataTreeView,

                       idCardOptions: {
                           //thumbnailUrl: function() { return folderIcon; },  // this places an icon just before the breadcrumbs
                           facets: function () {
                               var selectType = this.isMeasurementData() ? 'testData' : 'folder';
                               var _facets = [];
                               if( selectType === 'testData' ) { 
                                   // Selected item is a dataset, show chart in panel and properties in slide-in panel
                                   _facets.push({
                                       name:    'Chart',
                                       text:    i18n.chart,
                                       icon:    'chart-bar',
                                       handler: Skeleton.getRendererHandler( 'chartRenderer' )
                                   });
                               } else if( selectType === 'folder' ) {
                                   if( this.hasChildren() ) {
                                       // folder has been selected, display tiles of its children 
                                       _facets.push({
                                           name:    'Contents',
                                           text:    i18n.contents,
                                           icon:    'folder',
                                           handler: Skeleton.getRendererHandler( 'tileRenderer' )
                                       });
                                   }
                               }
                               
                               _facets.push({
                                   name: 'Properties',
                                   text: i18n.properties,
                                   icon: 'info',
                                   handler: Skeleton.getRendererHandler( 'detailsRenderer' )
                               });
                               
                               return _facets;
                           },
                           events: idCardEvents
                       },

                       fetchMode: 'once'
                   },

                   tileRenderer: {
                       collection: TestDataCollection,
                       collectionOptions: explorerCollectionOptions,
                       view: ContentSet,
                       
                       viewOptions: {
                           contents: {
                               useInfiniteScroll: false,
                               usePullToRefresh: true,
                               selectionMode: 'nullToNull',
                               views: [{
                                   id: 'tile',
                                   title: 'Tile',
                                   view: GridScrollView,
                                   itemView: TileView,
                                   itemViewOptions: testDataItemViewOpts,
                               }, {
                                   id: 'thumbnail',
                                   title: 'Thumbnail',
                                   view: GridScrollView,
                                   itemView: ThumbnailView,
                                   itemViewOptions: testDataItemViewOpts
                               }, {
                                   id: 'list',
                                   title: 'ListView',
                                   view: GridScrollView,
                                   itemViewOptions: testDataItemViewOpts
                               }],
                               headers: []
                           },
                       },
                       idCardOptions: {
                           actions: []
                       },
                       fetchMode: 'once'
                   },
                   
                   chartRenderer: {
                       model: TestDataModel, 
                       collection: TestDataCollection,
                       collectionOptions: explorerCollectionOptions,
                       modelOptions: {  skeleton: self  },
                       view: TestDataChartView,
                       
                       viewOptions: {
                           contents: {
                               useInfiniteScroll: false,
                               usePullToRefresh: true,
                               selectionMode: 'nullToNull', // ?
                               views: []
                           },
                           width: '100%'
                       },
                       idCardOptions: {
                           actions: []
                       },
                       fetchMode: 'once'
                   },
                   
                   detailsRenderer: {
                       model: TestDataModel, 
                       collection: TestDataCollection,
                       view: TestDataPropertyView,
                       idCardOptions: {
                           attributesMapping: {
                               title: 'cardname'
                           },
                           actions: []
                       },
                       cacheFacets: false,
                       fetchMode: 'once'
                   },
               };


               var facetOptions = {
                   root: 'treeRenderer',
                   useRootChannelView: false,
                   
                   responsiveTrigger: function () {
                       if( !widget ) { return false; }                   
                       var viewType = widget.getView().type;

                       // If channel view is active then set responsive trigger to maximize
                       if( widget.getValue( 'view' ) === 'channel' ) {
                           return viewType === 'maximized' || viewType === 'fullscreen';
                       } else {
                           // If normal view, then let the width threshold of the skeleton set the responsiveness
                           return false;
                       }
                   },

                   events: {
                       onItemSelect: function( model ) {
                          var name = model&&model.get( 'name' );
                       },
                       onSlide: function( view, model ) {
                          var chart = TestDataSession.get( 'chartView' );
                          chart && chart.resize();
                       },
                       onRouteChange: function( route ) { 
                          // console.log( '==> skeleton onRouteChange' );
                       },
                       onItemViewDrag: function () { 
                          // console.log( '==> skeleton onItemViewDrag' );
                       },
                       onResize: function () {  
                          // console.log( '==> skeleton onResize' );
                       },
                       onFacetSelect: function () { 
                          // console.log( '==> skeleton onFacetSelect' );
                       },
                       onFacetUnselect: function () { 
                          // console.log( '==> skeleton onFacetUnselect' );
                       }
                   }
               };

               this._parent( rootOptions, facetOptions );
           },
           
           _makeContextMenu: function( container, items ) {
               var self = this;
               var menu = UWA.createElement('div', { 'class': 'tde-ctx-menu' }).inject(container);
               items.forEach( function( item ) {
                   var menuitem = UWA.createElement('div', { 'class': 'tde-menuitem' } ).inject( menu );
                   menuitem.addEventListener( 'mousedown', item.handler );
                   var img = UWA.createElement( 'img', { 'class': 'tde-menuitem-img' } ).inject( menuitem );
                   img.src = item.icon;
                   var label = UWA.createElement( 'span', { text: item.label, 'class': 'tde-menuitem-label' } ).inject(menuitem);
               });
               return menu;
           },
           
           _createLink: function( e ) {
               var contextMenu = document.querySelector('.tde-ctx-menu');
               var model = contextMenu.model;
               TestDataUtil.makeLink( model );
           }
       });

       return TestDataSkeleton;
   }
);

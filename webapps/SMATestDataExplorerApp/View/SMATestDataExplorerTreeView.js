define('DS/SMATestDataExplorerApp/View/SMATestDataExplorerTreeView',
        ['UWA/Core',
         'UWA/Class/View',
         'DS/Tree/FileTreeView',
         'DS/Tree/TreeDocument',
         'DS/Tree/TreeNodeModel',
         'DS/UIKIT/Spinner',
         'DS/Windows/ImmersiveFrame',
         'DS/Controls/TooltipModel',
         'DS/DataDragAndDrop/DataDragAndDrop',
         'DS/WebappsUtils/WebappsUtils',
         'DS/WebAppsFoundations/Views/CollectionView',
         'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
         'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerUtil',
         'DS/SMATestDataExplorerApp/SMATestDataExplorerQuery',
         'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerCredentials',
         'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerCreateLink',
         'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerDrag',
         'DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
         'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels',
         'css!DS/SMATestDataExplorerApp/SMATestDataExplorerApp'
        ],
    function ( UWA, UWAView, TreeView, TreeDocument, TreeNodeModel, Spinner, WUXImmersiveFrame,  WUXTooltipModel,
            DDND, WebappsUtils, CollectionView, TestDataSession, TestDataUtil, TestDataQuery, TestDataCredentials, 
            TestDataLink, TestDataDrag, TestDataMessage, i18n ) {
    'use strict';

    var ODSTree = CollectionView.extend({
        tagName:   'div',
        className: 'tde-collection-view',
        setup: function( options ) {
            this.skeleton           = options.skeleton;
            this.panel              = options.panel;
            this._rendered          = false;
            this.postSelectId       = null;
            this.elements.spinner   = new Spinner ( { visible: false, renderTo: this.skeleton.getContent() } );
            this.elements.noResults = UWA.createElement('span', { 'class': 'tde-noresults', 'text':  i18n['no-results'] } )
            .inject(this.skeleton.getContent());
            this.elements.noResults.hide();

            var app = TestDataSession.get('app');
        },

        showSpinner: function () { this.elements.spinner.show(); },
        hideSpinner: function () { this.elements.spinner.hide(); },

        render: function () {
            var self = this;
            var topcontainer = UWA.createElement( 'div', { 'class':'tde-top-container' }).inject( this.container );
            var dropzone =     UWA.createElement( 'div', { 'class':'tde-container-column-centered tde-drop-view' }).inject( topcontainer );
            var topdiv =       UWA.createElement( 'div', { 'class':'tde-top-view' }).inject( topcontainer );
            this.infodiv =     UWA.createElement( 'div', { 'class':'tde-info-view' }).inject( topdiv );
            var btndiv =       UWA.createElement( 'div', { 'class':'tde-button-view' }).inject( topdiv );

            // Database specification and user credentials
            var img = UWA.createElement( 'img' ).inject( btndiv );
            img.src = WebappsUtils.getWebappsAssetUrl( 'SMATestDataExplorerApp', 'icons/64/database.png' );
            img.tooltipInfos = new WUXTooltipModel({ title: i18n['asam-server'], shortHelp: i18n['connection-details'], longHelp: i18n['connection-details-long'] });
            img.classList.add('tde-button');

            img.addEventListener('click', function(event) {
                TestDataCredentials.showDialog();
            });

            if( widget ) {
                var host = widget.getValue( 'asamHost' );
                var port = widget.getValue( 'asamPort' );
                var serv = widget.getValue( 'asamService' );

                var hostdiv = UWA.createElement( 'div', { 'class':'tde-inline-container tde-info-container' }).inject( this.infodiv );
                UWA.createElement( 'label', { 'class':'tde-info-label', 'text': i18n['asam-host'] }).inject( hostdiv );
                UWA.createElement( 'label', { 'class':'tde-info-value', 'text': host && port ? host + ':' + port : '' }).inject( hostdiv );

                var servdiv = UWA.createElement( 'div', { 'class':'tde-inline-container tde-info-container' }).inject( this.infodiv );
                UWA.createElement( 'label', { 'class':'tde-info-label', 'text': i18n['service-label'] }).inject( servdiv );
                UWA.createElement( 'label', { 'class':'tde-info-value', 'text': serv }).inject( servdiv );
            }

            // The tree in the left-side panel
            this.treediv = UWA.createElement( 'div', { 'class':'tde-tree-container' }).inject( this.container );

            // Drop zone and search
            var droplbl = UWA.createElement( 'label', { 'class':'tde-drop-note', 'text': i18n['drop-note'] }).inject( dropzone );
            var dropsearchdiv = UWA.createElement( 'div', { 'class':'tde-container-row-middle' }).inject( dropzone );

            var dropdiv = UWA.createElement( 'div', { 'class':'tde-drop-div tde-container-column-centered' }).inject( dropsearchdiv );
            var dropitem = UWA.createElement( 'div', { 'class':'tde-drop-item wux-ui-3ds wux-ui-3ds-2x wux-ui-3ds-drag-drop' }).inject( dropdiv );
            var droploclbl = UWA.createElement( 'label', { 'class':'tde-drop-note-small', 'text': i18n['drop-loc'] }).inject( dropdiv );

            var searchdiv = UWA.createElement( 'div', { 'class':'tde-drop-div tde-container-column-centered' }).inject( dropsearchdiv );
            var searchitem = UWA.createElement( 'div', { 'class':'tde-search-item wux-ui-3ds wux-ui-3ds-2x wux-ui-3ds-search' }).inject( searchdiv );
            var searchlbl = UWA.createElement( 'label', { 'class':'tde-link', 'text': i18n.search }).inject( searchdiv );

            searchitem.addEventListener( 'click', function(event) {
                self.searchLinks();
            });

            searchlbl.addEventListener( 'click', function(event) {
                self.searchLinks();
            });


            // Search filter above the tree
            var filterdiv = UWA.createElement( 'div', { 'class':'tde-tree-filter-container' }).inject( this.treediv );
            this.filter = UWA.createElement( 'input' ).inject(filterdiv);
            this.filter.type = 'text';
            this.filter.placeholder = i18n['filter'];
            this.filter.classList.add( 'tde-tree-filter' );
            this.filter.tooltipInfos = new WUXTooltipModel({ title: i18n.filter, shortHelp: i18n['filter-exp'], longHelp: i18n['filter-exp-long'] });

            var filterIcon = UWA.createElement('i', {'class':'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-filter', styles:{ 'margin': '5px' }}).inject(filterdiv);
            filterIcon.tooltipInfos = new WUXTooltipModel({ title: i18n['apply-filter'], shortHelp: i18n['apply-filter-tip'] });

            this.filter.addEventListener( 'change', function(event) {
                self.filterTreeItems( event.target );
            });

            var treedoc = new TreeDocument({
                useAsyncPreExpand: true,
                shouldBeEditable: function () { return false; },
                shouldAcceptDrag: function () { return true; },
                shouldAcceptDrop: function () { return false; },
            });

            // Create tree
            this.tree = new TreeView({
                treeDocument: treedoc,
                apiVersion: 2,
                height: '100%',

                onDragStartCell: function (evt, dragInfos) {
                    var data = dragInfos.nodeModel.options.data;
                    evt.dataTransfer.effectAllowed = 'copy';
                    if( data.treeType === 'testData' ) {
                        var model = self.collection.get( data.model.id );
                        model && TestDataDrag && TestDataDrag.setDragData( evt, model );
                    } 
                },

                onDragEndCell: function () {},
                onDropCell: function () {},

                onContextualEvent: {
                    callback: function( params ) {
                        var menu = [];
                        if( params && params.treeview && params.treeview.nodeModel && params.treeview.nodeModel._options && 
                                params.treeview.nodeModel._options.data && 
                                TestDataUtil.validLinkItem(params.treeview.nodeModel._options.data.model) ) {
                            menu.push({
                                type: 'PushItem',
                                title: i18n['create-link'],
                                icon:  WebappsUtils.getWebappsAssetUrl( 'SMATestDataExplorerApp', 'icons/32/link.png' ),
                                action: {
                                    'callback': function( d ) {
                                        self.createLink( params );
                                    }
                                }
                            });
                        }
                        return menu;
                    }
                }
            }).inject(this.treediv);

            this.tree.elements.container.classList.add('tde-tree-view');

            // Open the selected folder
            var treeMgr = this.tree.getManager();
            treeMgr.onCellClick( function ( data ) {
                var nodeData = data.model.options.value.options.data;
                var model = nodeData.model;
                if( model && model.get( 'id' ) && self.skeleton.container.clientWidth > 500 ) {
                    self.dispatchEvent( 'onItemViewSelect', model );
                } else {
                    self.skeleton.slideBack();
                }
            });

            treedoc.onPreExpand( function( modelEvent ) {
                var node = modelEvent.target;
                if( node) {
                    if( !node.hasChildren() ) {
                        // the tree node does not have child nodes, this means either
                        // the model has no children or they haven't been retrieved yet
                        var nodedata = node.options.data;
                        var model = nodedata.model;
                        if( model ) {
                            model.getChildren()
                            .then( function( children ) {
                                if( children && children.length ) {
                                    children.forEach( function( child ) {
                                        self.addTreeNode( node, child );
                                    });
                                    node.preExpandDone();
                                } else {
                                    // need to complete the pre-expansion prior
                                    // to setting the state of the node
                                    node.preExpandDone();
                                    node.setState( { state: 'noChildren' } );
                                }
                                self.postSelect();
                            })
                            .catch( function( err ) {
                                self.postSelect();
                                node.preExpandDone();
                                node.collapse();
                                node.setState( { state: 'noChildren' } );
                                var message = err.message ? err.message : i18n['no-content'];
                                TestDataMessage.displayMessage( 'info', message, i18n.note, i18n.info );
                            });
                        }
                    } else {
                        node.preExpandDone();
                    }
                }
            });

            treedoc.onPreCollapse( function( modelEvent ) {
                var view = self.skeleton.getViewAt( 1 );
                if( view ) {
                    modelEvent.target.getChildren().forEach( function( child ) {
                        if( child.options.data.model.id === view.model.id ) {
                            self.skeleton.slideBack();
                        }
                    });
                }
            });

            if( !this._rendered ) {
                this.listenTo( this.collection, {
                    'onAdd': function ( model, collection, options ) {
                        // Only add root models to the tree
                        // Because of skeleton limitations, all models must be
                        // in a single collection
                        // Non-root models are added to the tree as children of
                        // their parent
                        var parent = model.get('parent');
                        if( !parent ) {
                            self.addTreeNode( treedoc, model );
                        }
                    }
                });
                this._rendered = true;
            }

            // Implement drop zone
            DDND.droppable( dropzone, {
                drop : function(data, sender, event) {
                    try {
                        sender.removeAttribute( 'dragover' );
                        var models = [];
                        var collection = TestDataSession.get( 'clientCollection' );

                        if( data ) {
                            var dataJSON = JSON.parse(data);
                            dataJSON && dataJSON.data && self.validLink( dataJSON.data.items ) && self.processLink( { link: dataJSON.data.items[0] } );
                        } else if( event && event.dataTransfer.items && event.dataTransfer.items.length ) {
                            for( var i = 0; i < event.dataTransfer.items.length; ++i ) {
                                var item = event.dataTransfer.items[i];
                                if( item ) {
                                    console.log( 'TODO handle data transfer drop' );
                                }
                            }
                        }
                    }	
                    catch (e) {
                        console.log( 'Drop failed');
                    }					
                },
                enter: function( e ) {
                    e.setAttribute( 'dragover', true);
                },
                over: function( e ) {
                    e.setAttribute( 'dragover', true);
                },
                leave: function( e ) {
                    e.removeAttribute( 'dragover' );
                }
            });

            TestDataSession.set( 'treeview', this );
            return this;
        },

        searchLinks: function() {
            var self = this;
            require(['DS/SMAProcWebCommonControls/import!DS/SMAProcSP/sp-search/sp-search.html'], function() {
                self.spSearch = document.createElement('sp-search');
                self.spSearch.addEventListener('change', function (evt) {
                    var selectedObjects = evt && evt.detail && evt.detail.getSelectedObjects() || [];
                    self.validLink( selectedObjects ) && self.processLink( { link: selectedObjects[0] } );
                });
                self.spSearch.multiSelect = false;
                self.spSearch.plmTypes = 'TestResult Proxy';
                self.spSearch.search();
            });
        },

        addTreeNode: function( parentNode, model ) {
            var app = TestDataSession.get('app');
            if( app && model && parentNode ) {
                var isTestData = model.isMeasurementData();
                var bename = model.get( 'bename' );
                var name = model.get( 'name' );
                var tip = name + ' (' + i18n[ bename.toLowerCase() ] + ')';
                var icon = TestDataUtil.getAsamIcon( bename );
                var node = parentNode.addChild( new TreeNodeModel( {
                    label:    model.get( 'name' ),
                    title:    tip,
                    icons:    [ icon ],
                    children: [],
                    data: {
                        model:    model,
                        treeType: isTestData ? 'testData' : 'folder'
                    }
                }));

                if( !( model._attributes.operations.children ) ) {
                    node.setState( { state: 'noChildren' } );
                }

                DDND.draggable( node, {
                    data :  'TreeNode DRAG',
                    start: function() {
                        theStatus.value = 'start' ;
                    },
                    stop: function() {
                        theStatus.value = 'stop' ;
                    }
                });

                if( isTestData ) {
                    node.setState( { state: 'noChildren' } );
                }
            }
        },

        filterTreeItems: function( filter ) {
            var doc = this.tree.getDocument();
            var roots = doc.getRoots();

            var showall = filter.value.length === 0;
            var regex = new RegExp(filter.value, 'i'); // 'i' = ignore case

            roots.forEach( function( root ) {
                showall || regex.test( root.options.label ) ? root.show() : root.hide();
            });
        },

        getSelectedTestDataIds: function(){
            return this.tree.getDocument()
            .getSelectedNodes()
            .filter( function( x ) {
                return x.options.data.treeType === 'testData';
            })
            .map(function( x ) {
                return x.options.data.id;
            });
        },

        getNodeById: function (id) {
            // -- Return tree node with given id
            var doc = this.tree.getDocument();
            if( doc) {
                var nodeList = doc.search({
                    match: function( item ) {
                        if( item.nodeModel.options.data.model.id === id ) {
                            return true;
                        }
                    }
                });
                if (nodeList) { return nodeList[0]; }
                else          { return null; }
            } 
            return null;
        },

        unselectAll: function() {
            this.tree.getDocument().getSelectedNodes().map(function( x ) {
                x.unselect();
                return 0;
            });
        },

        postSelect: function() {
            if( this.postSelectId ) {
                var node = this.getNodeById( this.postSelectId );
                if( node ) {
                    this.unselectAll();
                    node.select();
                }
                this.postSelectId = null;
            }
        },

        // *********************************************************************************************

        processLink: function( options ) {
            var objID;
            var app = TestDataSession.get('app');
            if( options.link ) {
                objID = options.link.objectId; 
            }
            var tree = this;

            if( objID && app ) {       		
                TestDataQuery.getWAFData( { 
                    spinner: TestDataSession.get( 'spinner' ), 
                    method: 'GET', 
                    request: { href: app.baseUrl() + '/Link?id=' + objID } 
                })
                .then( function( response ) {
                    // Get the host, port and service from the link
                    var currHost = widget.getValue( 'asamHost' );
                    var currPort = widget.getValue( 'asamPort' );
                    var currService = widget.getValue( 'asamService' );

                    var idpath = response.Proxy_Id;
                    if(!Array.isArray(idpath) ) {
                        idpath = idpath.split(',');
                    }
                    TestDataSession.set( 'idpath', idpath );

                    var host = response.hostName ? response.hostName : '';
                    var port = response.port ? response.port : '';
                    var srvc = response.serviceName ? response.serviceName : '';

                    // If the link points to an item in the current host, use
                    // the idpath to expand the path to the item
                    if( idpath && idpath.length && host === currHost && port === currPort && srvc === currService ) {
                        tree.expandPathSelectLast( idpath );
                    } else {
                        // A change in credentials will trigger the opening of
                        // the ASAM database
                        TestDataCredentials.showDialog({ 
                            host: host, 
                            port: port, 
                            service: srvc
                        });
                    }
                })
                .catch( function( err, errobj, errctx ) {
                    var errorMessage = (err && err.message) || i18n[ 'links-ws-fail' ];
                    TestDataMessage.displayMessage( 'error', errorMessage);
                });
            }
        },

        expandPathSelectLast: function( idpath ) {
            var id = idpath.shift();
            var self = this;
            if( idpath.length ) {
                this.expandNode( id )
                .then( function( node ) {
                    if( node ) {
                        self.expandPathSelectLast( idpath );
                    }
                });
            } else {
                self.selectItemById( id );
            }
        },

        expandNode: function( id ) {
            // expand from the root node to node
            var self = this;
            return new Promise( function( resolve, reject ) {
                var node = self.getNodeById( id );
                if( node ) {
                    if( !node.hasChildren() ) {
                        var nodedata = node.options.data;
                        var model = nodedata.model;
                        if( model ) {
                            model.getChildren()
                            .then( function( children ) {
                                if( children && children.length ) {
                                    children.forEach( function( child ) {
                                        self.addTreeNode( node, child );
                                    });
                                    node.expand();
                                } else {
                                    node.setState( { state: 'noChildren' } );
                                }
                                resolve( node );
                            })
                            .catch( function( err ) {
                                reject( err );
                            });
                        }
                    } else {
                        node.expand();
                        resolve( node );
                    }
                }
            });
        },

        selectItemById: function( id ) {
            var model, parentNode;
            var treeNode = this.getNodeById( id );
            if( treeNode ) {
                model = treeNode.options.data.model;
                this.dispatchEvent( 'onItemViewSelect', model );
                if( !treeNode.isExpanded() ) {
                    this.postSelectId = id;
                    parentNode = treeNode.getParent();
                    parentNode && ( parentNode.isExpanded() || parentNode.expand() );
                    treeNode.hasChildren() && treeNode.expand();
                }
                this.unselectAll();
                treeNode.select( true );
            } else {
                // A double click on an item in the tile view which does not
                // have a corresponding tree node
                // ( this happens when the node's parent hasn't yet been
                // expanded in the tree ).
                // Find the item in the collection, add child nodes to the tree
                // and expand its parent tree node
                var models = this.collection._models;
                for( var i = 0; i < models.length; ++i ) {
                    if( id === models[i].get( 'id' ) ) {
                        model = models[i];
                        this.dispatchEvent( 'onItemViewSelect', model );
                        var parent = model.get('parent');
                        if( parent ) {
                            var pid = parent.get( 'id' );
                            parentNode = this.getNodeById( pid );
                            if( parentNode ) {
                                var self = this;
                                parent.getChildren()
                                .then( function( children ) {
                                    if( children ) {
                                        children.forEach( function( child ) {
                                            self.addTreeNode( parentNode, child );
                                        });
                                        parentNode.isExpanded() || parentNode.expand();
                                        self.postSelectId = id;
                                        self.unselectAll();
                                        treeNode = self.getNodeById( id );
                                        treeNode && treeNode.select();
                                    } else {
                                        parentNode.setState( { state: 'noChildren' } );
                                    }
                                })
                                .catch( function( err ) {
                                    console.log( 'SMATestDataExplorerTreeView.onPreExpand ERROR: ' + err );
                                    parentNode.collapse();
                                    return;
                                });
                            }
                        }
                        return;
                    }
                }
                // If we get here, the model is either not accessible for the current user or the model 
                // could have been removed from the ASAM DB
                // TestDataMessage.displayMessage( 'warning', i18n['inaccesible-note'], i18n.warning, i18n[ 'item-inaccessible' ]);
            }
        },

        createLink: function( param ) {
            var model = param.treeview.nodeModel.options.data.model;
            TestDataUtil.makeLink( model );
        },

        validLink: function( items ) {
            var valid = false;
            if( items && items.length ) {
                var item = items[0];
                valid = ( item.objectType && item.objectType === "TestResult Proxy" && item.objectId ) ? true : false;
            }
            return valid;
        },

        destroy: function () {
            this.stopListening();
            this.tree.destroy();
            TestDataSession.set( 'treeview', null );
            this._parent();
        }
    });
    return ODSTree;
});

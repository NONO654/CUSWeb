define('DS/SMATestDataExplorerApp/Collection/SMATestDataExplorerCollection', [
    'UWA/Core',
    'UWA/Class/Collection',
    'DS/SMATestDataExplorerApp/Model/SMATestDataExplorerModel',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerQuery',
    'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerCredentials',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
    'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels'
    ],
    function ( UWA, UWACollection, TestDataModel, TestDataSession, TestDataQuery, TestDataCredentials, TestDataMessage, i18n ) {
    'use strict';

    var TestDataCollection = UWACollection.extend( {
        model: TestDataModel,
        _parentModel: null,

        // called by constructor
        setup: function (models, options) {
            this._parent(models, options);
            if( options) {
                this._parentModel = options.parentModel ? options.parentModel : options._modelKey;
            }
        },

        sync: function ( method, collection, options ) {
            var app = TestDataSession.get('app');

            if( app ) {
                var cred = TestDataCredentials.getServerCredentials();
                if( cred && cred.valid ) {
                    app.getAsamKey( { cred: cred } )
                    .then( function( key ) {
                        options.key = key; 
                        collection.getItems( method, options )
                        .then( function( items ) {
                            if( options && options.onComplete ) {
                                options.onComplete( items );
                            }
                        })
                        .then( function() {
                            var tree = TestDataSession.get( 'treeview' );
                            var idlist = TestDataSession.get( 'idpath' );
                            if( tree && idlist ) {
                                tree.expandPathSelectLast( idlist );
                            }
                        })
                        .catch( function( err ) { 
                            console.log('ERROR: ' + err );
                            // this is where 'bad credentials' error will be displayed, 
                            // so it must be an error not info message which means this
                            // cannot be the place to inform the user the selected item
                            // has no children
                            TestDataMessage.displayMessage('error', err, i18n.error);

                            if( options && options.onFailure ) {
                                options.onFailure( err );
                            }
                        });
                    })
                    .catch( function( errstr, errobj, errctx ) {
                        reject( errstr );
                    });
                } else {
                    app.reqestNewCredentials();
                }
            }
            return { cancel: function () { return; }  };
        },

        // return the items contained in this collection
        getItems: function( method, options ) {
            var collection = this;
            return new Promise( function ( resolve, reject ) {
                var pid;
                var isMeasurementData = false;
                var parent = collection._parentModel;
                if( parent ) {
                    var children = parent.get('children');
                    // if children have already been retrieved, return them
                    if( children ) {
                        if( !Array.isArray( children ) ) {
                            // if children have already been retrieved and this model has no children, 
                            // the 'children' attribute will be set to the string 'none'
                            children = null;
                        }
                        return resolve( children );
                    }
                    pid = parent.get('id');
                    isMeasurementData = parent.isMeasurementData && parent.isMeasurementData();
                }

                var app = TestDataSession.get('app');
                if( app && method === 'read' && !isMeasurementData ) { // don't get AoLocalColumn's children (i.e. ExternalComponents)
                    var link = { href: app.baseUrl() + '/tests', payload: null };

                    if( pid ) {
                        var ops = parent.get('operations');
                        link = ops && ops.children;
                    } else {
                        TestDataSession.set( 'chartCollection', collection );
                    }

                    if( link && options && options.key ) {
                        link.href += (link.href.indexOf('?') === -1 ? '?' : '&') + 'key=' + options.key;

                        TestDataQuery.getWAFData( { spinner: TestDataSession.get( 'spinner' ), request: link } )
                        .then( function( response ) {
                            if( response && response.items ) {
                                // resolve( model.addChildren( response ) );
                                var func = parent && parent.addChildren;
                                func && func.call( parent, response );
                                if( response.queries ) {
                                    response.items.forEach( function( item ) {
                                        item.queries = response.queries;
                                        item.template = response.template;
                                    });
                                }
                                resolve( response.items );
                            } else {
                                if( response.error && response.error.message ) {
                                    TestDataMessage.displayMessage( 'info', response.error.message );
                                } else {
                                    TestDataMessage.displayMessage( 'info', i18n['no-children'] );
                                }
                                parent && parent.set( 'children', 'none', { silent: true } );
                                resolve([]);
                            }
                        })
                        .catch( function( errstr, errobj, errctx ) {
                            reject( errstr, errobj );
                        });
                    }  else {
                        // no children
                        var name = 'Selected item';
                        if( parent ) {
                            parent.set( 'children', 'none', { silent: true } );
                        }
                        resolve( null );
                    }
                }
            });
        }
    });
    return TestDataCollection;
});

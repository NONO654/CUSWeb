define('DS/SMATestDataExplorerApp/SMATestDataExplorerApp', 
        ['DS/Windows/ImmersiveFrame',
         'DS/WebappsUtils/WebappsUtils',
         'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
         'DS/SMATestDataExplorerApp/SMATestDataExplorerQuery',
         'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerUtil',
         'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerCredentials',
         'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerCreateLink',
         'DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
         'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels'],
    function( WUXImmersiveFrame, WebappsUtils, TestDataSession, TestDataQuery, TestDataUtil, TestDataCredentials, TestDataCreateLink, TestDataMessage, i18n) {
    'use strict';

    var _main = null;
    var app = UWA.Class.extend({
        defaultOptions: {
            asamKey: null,
            frameWindow: null,
            treeConfig: [],
            events: {
                onDragStart: function(testData) {
//                  console.log ("Begin drag of test data " + testData.get('name') + " id " + testData.id);
                },

                onDragEnd: function(testData) {
//                  console.log ("End drag of test data " + testData.get('name') + " id " + testData.id);
                },

                onPreDrop: function (path, testData, callback) {
//                  console.log('On pre drop, Message = ' + testData.get('name') );
                },

                onPostDrop: function (code, message) {
//                  console.log('On post drop, Message = ', message );
                },

                onApply: function(testData) {
//                  console.log ('Apply test data '+ testData.get('name') + ' ' + testData.get('id'));
                }
            }
        },
        widgetPanel: null,

        init: function( options ) {
            
            this.options = UWA.extend( this.defaultOptions, options );
            this.identityCards = [];
            this._main = options.panel;

            var immersiveFrame = new WUXImmersiveFrame();
            immersiveFrame.inject( document.body );

            TestDataSession.set( 'app', this );
            TestDataSession.set( 'immersiveFrame', immersiveFrame );

            // add security context preference
            if( options.dashboard && options.dashboard.isInDashboard ) {
                options.dashboard.addSecurityContextPreference();
            }

            // initialize dialogs
            TestDataCredentials.init();
            TestDataCreateLink.init();
        },

        // Display the ASAM server credentials dialog
        reqestNewCredentials: function() {
            return TestDataCredentials.showDialog();
        },

        // use the credentials held in user preferences to update the key
        updateASAMKey: function( options ) {
            var app = this;

            return new Promise( function( resolve, reject ) {
                if( options && options.valid ) {

                    var payload = { template: {} };
                    payload.template.data = options.credentials;
                    var request = { href: app.baseUrl() + '/connections', payload: payload };

                    TestDataQuery.getWAFData({
                        method: 'POST',
                        request: request,
                        context: this,
                        spinner: TestDataSession.get( 'spinner' )
                    })
                    .then( function( response ) {
                        app.options.asamKey = response.Key;
                        resolve( response.Key );
                    });
                } else {
                    reject( new Error( 'Invalid credentials' ) );
                }
            });
        },

        // return the current key
        currentASAMKey: function() {
            return this.options.asamKey;
        },

        // If a key has been provided or previously created return it
        // otherwise call updateASAMKey to create a key
        getAsamKey: function( options ) {
            var akey = options && options.key ? options.key : this.options.asamKey;
            var app = this;

            if( akey ) {
                return Promise.resolve( akey );
            }

            return new Promise( function ( resolve, reject ) {
                var cred = options && options.cred || TestDataCredentials.getServerCredentials();
                if( cred && cred.valid ) {
                    app.updateASAMKey( cred )
                    .then( function( key ) {
                        return resolve( key );
                    });
                }
            });
        },

        baseUrl: function() {
            return 'https://' + window.location.hostname + '/3DSpace/resources/odsservices';
        },

        setPreferences: function( prefs ) {
            prefs.asamHost !== undefined     && widget.setValue( 'asamHost',     prefs.asamHost );
            prefs.asamPort !== undefined     && widget.setValue( 'asamPort',     prefs.asamPort );
            prefs.asamService  !== undefined && widget.setValue( 'asamService',  prefs.asamService );
            prefs.asamUsername !== undefined && widget.setValue( 'asamUsername', prefs.asamUsername );
            prefs.asamPassword !== undefined && widget.setValue( 'asamPassword', prefs.asamPassword );
        },

        clearPreferences: function( ) {
            widget.setValue( 'asamHost',     "" );
            widget.setValue( 'asamPort',     "" );
            widget.setValue( 'asamService',  "" );
            widget.setValue( 'asamUsername', "" );
            widget.setValue( 'asamPassword', "" );
        }, 

        // When the user changes the server credentials get a new key
        // If the key differs from the previous, reload the ASAM tests
        onCredentialsChange: function( options ) {
            var app = this;
            var oldkey = this.options.asamKey && this.options.asamKey.slice(0);
            var cred = TestDataCredentials.getServerCredentials();
            if( cred && cred.valid ) {
                app.updateASAMKey( cred )
                .then( function( key ) {
                    if( key != oldkey ) {
                        // a new user key has been created, re-populate the root collection
                        // NOTE: if the credentials used to create the key are invalid, the key is bad
                        //       no check has yet been made to determine the status of the key
                        if(app.widgetPanel) {
                            var skeleton = app.widgetPanel.getSkeleton();
                            skeleton && skeleton.destroy();
                            app.widgetPanel.buildSkeleton();
                        }

                        var link = { href: app.baseUrl() + '/tests?key=' + key, payload: null };
                        TestDataQuery.getWAFData({
                            request: link,
                            spinner: TestDataSession.get( 'spinner' )
                        })
                        .then( function( response ) {
                            if( response.queries ) {
                                response.items.forEach( function( item ) {
                                    item.queries = response.queries;
                                    item.template = response.template;
                                });
                            }
                        });
                    }
                })
                .catch( function( err ) {
                    TestDataMessage.displayMessage( 'error', err, i18n.error);
                });
            } else {
                TestDataMessage.displayMessage( 'error', i18n[ 'bad-credentials' ], i18n.error, i18n['bad-key']);
                app.reqestNewCredentials();
            }
        },

        addIdentityCard: function( idcard ) {
            if( !idcard.hasOwnProperty( 'pool' ) || idcard.pool === '' ) {
                idcard.pool = this.options.destinationPool;
            }
            this.identityCards.push( idcard );
        },

        getIdentityCard: function( domainTag ) {
            var numCards = this.identityCards.length;
            var card = null;
            if( numCards > 0 ) {
                card = this.identityCards[numCards-1];
            }
            return card;
        },

        getIdentityCardList: function () {
            return this.identityCards;
        }

    });

    return app.singleton({
        uninitializedCalls: 'throw'
    });
}
);


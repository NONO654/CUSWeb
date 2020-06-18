define('DS/SMATestDataExplorerApp/Util/SMATestDataExplorerUtil',
        ['UWA/Core',
            'DS/WebappsUtils/WebappsUtils',
            'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
            'DS/SMATestDataExplorerApp/SMATestDataExplorerQuery',
            'DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
            'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerCredentials',
            'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerCreateLink',
            'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels',
            'css!DS/SMATestDataExplorerApp/SMATestDataExplorerApp'
            ],
            function ( UWA, WebappsUtils, TestDataSession, TestDataQuery, TestDataMessage, TestDataCredentials, TestDataCreateLink, i18n) {
    'use strict';

    var Util = UWA.Class.singleton( {

        makeLink: function( model ) {
            var util = this;

            model.getProperties()
            .then( function( model ) {
                var idpath = [];
                util._buildIdPath( model, idpath );

                var link = {
                    title: '',
                    hostName:    widget.getValue( 'asamHost' ),
                    port:        widget.getValue( 'asamPort' ),
                    serviceName: widget.getValue( 'asamService' ),
                    asamPath:    model.get('asampath').replace(/\\^\\u/g, ''),
                    asamLink:    model.get('href'),
                    id:          idpath.toString()
                };

                // get link title from user
                var immersiveFrame = TestDataSession.get( 'immersiveFrame');
                if( immersiveFrame && util.validLink( link ) ) {
                    TestDataCreateLink.showDialog( link );
                }
            })
            .catch( function( err ) {
                console.log( 'SMATestDataExplorerUtil.MakeLink ERROR: ' + err );
                TestDataMessage.displayMessage('error', i18n['get-prop-fail'])
            });
        },

        validLink: function( link ) {
            return link.hostName && link.port && link.serviceName && link.asamPath && link.asamLink && link.id;
        },

        getIcon: function( name ) {
            var icon;
            if( name ) {
                var mapping = {
                        'folderThumb': 'folder_thumbnail.png',
                        'chartThumb':  'chart_thumbnail.png',
                        'folderTile':  'folder_tile.png',
                        'chartTile':   'chart_tile.png'
                }
                var item = mapping[name];
                if( item ) {
                    var path = 'icons/64/' + item;
                    icon = WebappsUtils.getWebappsAssetUrl( 'SMATestDataExplorerApp', path );
                }
            }
            return icon;
        },

        getAsamIcon: function( elementType, size ) {
            var filename;
            if( elementType ) {
                var etype = elementType.toLowerCase();
                var imap = { 
                        'aoexternalcomponent':   'aoExternalComponent.png',
                        'aofile':                'aoFile.png',
                        'aolocalcolumn':         'aoLocalColumn.png',
                        'aomeasurement':         'aoMeasurement.png',
                        'aomeasurementquantity': 'aoMeasurementQuantity.png',
                        'aosubmatrix':           'aoSubMatrix.png',
                        'aosubtest':             'aoSubTest.png',
                        'aotest':                'aoTest.png'
                };   
                filename = imap[etype];
            }

            if( !filename ) {
                console.log( 'Missing icon for ' + elementType );
                filename = 'aoTest.png';
            }
            var loc = 'icons/32/';
            if( size === 'thumb') {
                loc = 'icons/thumb/';
            } else if( size === 'tile' ) {
                loc = 'icons/64/';
            }
            return WebappsUtils.getWebappsAssetUrl( 'SMATestDataExplorerApp', loc + filename );
        },

        _buildIdPath: function( model, path ) {
            var parent = model.get('parent');
            parent && this._buildIdPath( parent, path );
            path.push( model.get('id'))
        },

        getSkeleton: function() {
            var skeleton;
            var app = TestDataSession.get('app');
            skeleton = app && app.widgetPanel && app.widgetPanel.getSkeleton();
            return skeleton;
        },
        
        getLocalIPv4: function( ) {
            // NOTE this does not work on Safari and may need to change when Chrome and Firefox become compliant
            return new Promise( function (resolve, reject) {
                var enabled = localStorage.getItem('csiDevEnabled');
                if( !enabled ) {
                    return resolve( null );
                }

                var PeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
                var pc = new PeerConnection({ iceServers: [] });
                var noop = function() {};
                var localIPs = {};
                var ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g;
                var key;

                function iterateIP( ip ) {
                    if( !localIPs[ip] ) {
                        resolve( ip );
                    }
                    localIPs[ip] = true;
                }

                pc.createDataChannel("");
                pc.createOffer().then( function( sdp ) {
                    sdp.sdp.split( '\n' ).forEach( function( line ) {
                        if( line.indexOf( 'candidate') < 0 ) {
                            return;
                        }
                        line.match( ipRegex ).forEach( iterateIP );
                    });

                    pc.setLocalDescription( sdp, noop, noop );
                }).catch(function( reason ) {
                    reject( new Error( reason ) );
                });

                pc.onicecandidate = function( ice ) {
                    if( !ice || !ice.candidate || !ice.candidate.candidate || !ice.candidate.candidate.match( ipRegex ) ) {
                        return;
                    }
                    ice.candidate.candidate.match( ipRegex ).forEach( iterateIP );
                };
            });
        },
        
        validLinkItem: function( item ) {
            // only allow link creation on select ODS items
            // TODO support access to measurement quantity's associated local columns
            // Why not "AoSubmatrix" ?
            if( item && item._attributes ) {
                var odsType = item._attributes.bename;
                if( odsType === "AoLocalColumn" || odsType === "AoMeasurementQuantity" || odsType === "AoTest" || odsType === "AoSubTest" ) {
                    return true;
                }
            }
            return false;
        }
    });
    return Util;
}
);


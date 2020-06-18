define('DS/SMATestDataExplorerApp/SMATestDataExplorerQuery', 
        [ 'UWA/Core',
            'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
            'DS/WAFData/WAFData',
            'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels'],
            function ( UWA, TestDataSession, WAFData, i18n) {
    'use strict';
    var _self;

    var SMATestDataExplorerQuery = UWA.Class.singleton({
        init: function () {
            _self = this;
            this.spServiceurl = document.createElement( 'sp-serviceurl' );
            if( typeof( widget ) !== 'undefined' && widget ) {
                this.tenant = widget.getValue( 'x3dPlatformId' );
            }
            if( !this.tenant ) { this.tenant = 'OnPremise'; }
        },

        _decodeObj:  function( obj ) {
            for( var key in obj ) {
                if( obj.hasOwnProperty( key ) ) {
                    var val = obj[key];
                    if(typeof val === 'string') {
                        var de = decodeURIComponent(val);
                        obj[key] = decodeURIComponent(val);
                    } else if( typeof val === 'object' || Array.isArray( val ) ) {
                        this._decodeObj(val);
                    }
                }
            }
        },

        _showSpinner: function( obj ) {
            obj && obj.spinner && obj.spinner.setAttribute( 'show', 'true' );
        },

        _hideSpinner: function( obj ) {
            obj && obj.spinner && obj.spinner.removeAttribute( 'show' );
        },

        _getErrorMessage: function( errobj ) {
            var message;
            if( errobj && errobj.collection && errobj.collection.error ) {
                message = errobj.collection.error.message;
            }
            return message;
        },

        getWAFData: function( options ) {
            var self = this;
            return new Promise( function (resolve, reject) {
                var payload = null;
                var method = options.method || 'GET';

                if( options && options.request ) {
                    var url = options.request.href;
                    if( options.request.payload ) {
                        payload = JSON.stringify(options.request.payload);
                    }
                    
                    // Setup request headers
                    // Append security context if provided
                    var hdr = { 'Content-Type': 'application/json' };
                    var secCtx = widget.getValue( 'collabspaces' );
                    if( secCtx ) {
                        hdr.SecurityContext = secCtx;
                    }

                    self._showSpinner( options );
//                    console.log( '** URL : ' + url );
                    WAFData.authenticatedRequest(url, {
                        headers: hdr,
                        method: method,
                        data: payload,
                        type: 'json',
                        cache: 3600,
                        onComplete: function (response) {
                            self._hideSpinner( options );
                            if( response ) {
                                var param;
                                if( response.collection ) {
                                    param = response.collection;
                                } else if( response.Key || response.nativeId || response.Proxy_Id ) {
                                    param = response;
                                }

                                if( param ) {
                                    resolve( param );
                                } else {
                                    var message = self._getErrorMessage( response );
                                    reject( new Error( message ? message : i18n['ws-fail'] ) );
                                }
                            }
                        },
                        onCancel: function( errmsg, errobj, errctx ) {
                            var message = self._getErrorMessage( errobj );
                            console.log( 'request cancelled, errmsg = ' + message ? message : errmsg  );
                            self._hideSpinner( options );
                            reject( new Error( i18n['ws-cancel'], errobj, errctx ) );
                        },
                        onFailure: function(  errmsg, errobj, errctx  ) {
                            self._hideSpinner( options );
                            var message = self._getErrorMessage( errobj );
                            // extra parentheses required on IE
                            console.log( 'request failed, errmsg = ' + ( message ? message : errmsg ) );
                            reject( new Error(  message ? message : errmsg ) );
                        },
                        onTimeout: function( errmsg, errobj, errctx ) {
                            var message = self._getErrorMessage( errobj );
                            console.log( 'request timed out, errmsg = ' + ( message ? message : errmsg )  );
                            self._hideSpinner( options );
                            reject( new Error( i18n['ws-timeout'], errobj, errctx ) );
                        }
                    });
                }
            });
        }
    });
    return SMATestDataExplorerQuery;
});

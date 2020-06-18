define('DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
    [ 'UWA/Core', 'UWA/Class' ],
    function ( UWA, Class ) {
        'use strict';

        var Session = Class.extend( {
            _attributes: [], 

            init: function ( options ) {
            },

            setup: function ( options ) {
            },

            set: function ( attr, val ) {
                this._attributes[attr] = val;
            },

            get: function (attr) {
                return this._attributes[attr];
            },

            keys: function () {
                return Object.keys(this._attributes);
            },

            has: function( attr ) {
                return this.keys().indexOf( attr ) >= 0;
            },
            remove: function( attr ) {
                var indx = this.keys().indexOf( attr );
                if( indx >= 0 ) {
                    this._attributes.splice( indx, 1 );
                }
            }
        });

        return Session.singleton( {
            uninitializedCalls: 'initialize'
        } );
    }
);




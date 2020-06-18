define('DS/SMATestDataExplorerApp/Util/SMATestDataExplorerDrag',
        [ 'UWA/Core', 
            'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
            'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerCredentials' ],
            function ( UWA, TestDataSession, TestDataCredentials ) {
    'use strict';

    // Support dragging measurement data from the ASAM Test Data Explorer tree to drop in another app such as the Test Data Viewer
    var dragServices = {
        setDragData: function( event, model ) {
            // for now, only support dragging of measurement data (AoLocalColumn)
            var app = TestDataSession.get('app');
            var cred = TestDataCredentials.getServerCredentials();
            if( app && model.isMeasurementData() && cred && cred.valid ) {
                var akey = '';
                app.getAsamKey( { cred: cred })
                .then( function( akey ) { 
                    var testData = {
                        objectType:  'asamData',
                        asamHost:    widget.getValue( 'asamHost' ),
                        asamPort:    widget.getValue( 'asamPort' ),
                        asamService: widget.getValue( 'asamService' ),
                        asamKey: akey
                    };

                    var self = this;
                    // not supported in ES5
                    // Object.entries( model._attributes ).forEach( function( [ key, val ] ) {
                    Object.keys( model._attributes ).forEach( function( key ) {
                        var val = model._attributes[key];
                        if( key && val && [ 'parent', 'plotData','fullDetails', 'userName' ].indexOf( key ) < 0 ) {
                            testData[ key ] = val;
                        }
                    });

                    var keys = Object.keys( testData );
                    if( keys.length > 4 ) {
                        event.dataTransfer.setData( 'text/plain', JSON.stringify( { data: { items: [ testData ] } } ) );
                        app.options.events.onDragStart && app.options.events.onDragStart( model );
                    }
                });
            }
        }
    };
    return UWA.namespace('DS/SMATestDataExplorerApp/Util/SMATestDataExplorerDrag', dragServices);
}
);


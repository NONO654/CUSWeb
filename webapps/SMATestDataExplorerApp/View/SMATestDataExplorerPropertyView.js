define('DS/SMATestDataExplorerApp/View/SMATestDataExplorerPropertyView',
        ['UWA/Core',
         'UWA/Class/Model',
         'UWA/Class/Collection',
         'UWA/Class/View',
         'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels'
        ],
    function (UWA, Model, Collection, View, i18n) {
    'use strict';

    var PropertyView = View.extend({
        tagName: 'div',
        domEvents: { },
        propTable: null,
        plotLabels: [ i18n['dataset-size'], i18n['zoom-domain'], i18n['zoom-range'], i18n['plot-resolution'], i18n['plot-granularity']],
        updating: false,

        render: function () {
            return this.makeTable();
        },

        setup: function () {
        },
        
        onFacetSelect: function ( e ) {
            if( this.model.isMeasurementData() ) {
                this.makeTable();
            }
        },

        onFacetUnselect: function ( e ) {
        },

        destroyTable: function() {
            if( this.propTable ) {
                this.propTable.destroy();
                this.propTable = null;
            }
        },

        makeTable: function() {
            this.destroyTable();

            this.container.setStyles({
                'text-align': 'left', 'background': 'white', 'height': '100%', 'padding': '0px 10px',
                'overflow': 'auto',
            });

            this.propTable = UWA.createElement( 'table', {
                styles: {
                    'width': '100%',
                }
            });

            UWA.createElement( 'tr', {
                html: [{
                    tag: 'th',
                    text: i18n.property,
                    styles: { 'font-weight': 'bold', 'color': '#777', 'padding': '5px 5px' },
                },
                {
                    tag: 'th',
                    text: i18n.value,
                    styles: { 'font-weight': 'bold', 'color': '#777', 'padding': '5px 5px' }, 
                }],
                styles: {
                    'border-bottom': '2px solid #ddd', 
                }
            }).inject( this.propTable );

            var self = this;
            if( !this.updating ) {
                this.updating = true;
                this.model.getProperties()
                .then( function( model ) {
                    if( model) {
                        // not supported in ES5 on IE
                        // Object.entries(model._attributes).forEach(function([key, val]) {
                        Object.keys( model._attributes ).forEach( function( key ) {
                            var val = model._attributes[key];
                            if( key && val && self.showProp( key ) ) {
                                self.makeRow( self.userProp( key ), val ).inject( self.propTable );
                            }
                        });
                        model.isMeasurementData() && self.addPlotDataRows( self.propTable );
                        self.updating = false;
                    }
                })
                .catch( function( err ) {
                    self.updating = false;
                    var errorMessage = (err && err.message) || i18n[ 'plotdata-ws-fail' ];
                    TestDataMessage.displayMessage( 'error', errorMessage );
                });
            }

            this.container.grab( this.propTable );
            this.createFooter();
            return this;
        },

        addPlotDataRows: function( ) {
            var plotdata =  this.model.get( 'plotData' );
            if( plotdata ) {
                var num = plotdata.numValues;
                var sz = plotdata.datasetSize;
                var domain = plotdata.xmax - plotdata.xmin;
                var zoomDomain = '[ ' + plotdata.xmin + ', ' + plotdata.xmax + ' ]';
                var zoomRange = '[ ' + plotdata.ymin + ', ' + plotdata.ymax + ' ]';
                var pct = domain > num ? (num/domain)*100 : 100;
                this.makeRow( i18n['dataset-size'], sz ).inject( this.propTable );
                this.makeRow( i18n['zoom-domain'], zoomDomain ).inject( this.propTable );
                this.makeRow( i18n['zoom-range'], zoomRange ).inject( this.propTable );
                this.makeRow( i18n['plot-resolution'], num ).inject( this.propTable );
                this.makeRow( i18n['plot-granularity'], pct.toFixed(2)+'%' ).inject( this.propTable );
            }
        },

        getProp: function( model, prop ) {
            var label;
            if( model && prop ) {
                label = model.get( prop );
            }
            return label && label.length ? [ { tag: 'span', text: label }] : null;
        },

        showProp: function( prop ) {
            var internalProps = [ 'parent', 'children', 'plotData', 'href', 'template', 'queries', 'operations', 'fullDetails', 'userName' ];
            return internalProps.indexOf(prop) < 0;

        },

        userProp: function( internalProp ) {    	 
            var prop = i18n[internalProp];
            return prop ? prop : internalProp;
        },

        makeRow: function( prop, value ) {
            var item = [ { tag: 'span', text: value } ];
            return UWA.createElement('tr', {
                html: [ { tag: 'td', text: prop, styles: { 'padding': '5px 5px' } },
                    { tag: 'td', html: item, styles: { 'padding': '5px 5px' } } ],
                    styles: { 'border-bottom': '1px solid #ddd' }
            });
        },

        createFooter: function () { }
    });

    return PropertyView;
});


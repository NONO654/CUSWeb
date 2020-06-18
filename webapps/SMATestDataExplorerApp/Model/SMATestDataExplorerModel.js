define('DS/SMATestDataExplorerApp/Model/SMATestDataExplorerModel', [
    'UWA/Core', 
    'UWA/Class/Model',
    'UWA/String',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerQuery',
    'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerCredentials',
    'DS/SMATestDataExplorerApp/Util/SMATestDataExplorerUtil',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
    'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels'
    ],
    function (UWA, UWAModel, UWAString, TestDataSession, TestDataQuery, TestDataCredentials, TestDataUtil, TestDataMessage, i18n) {

    'use strict';

    var testDataModel = UWAModel.extend({
        // Note: these options are displayed in the property table for this model
        // If any are not intended to be displayed (i.e. internal props) update the
        // SMATestDataExplorerPropertyView.showProp function
        defaults: {
            'objectType':      '',
            'name':            '',
            'id':              '',
            'aid':             '',
            'eid':             '',
            'href':            '',
            'bename':          '',
            'aename':          '',
            'instElement':     '',
            'userName':        '',
            'asamPath':        '',
            'parent':          null,
            'children':        null,
            'operations':      null,
            'fullDetails':     false,
            'clientModel':     false,
            'plotData': {
                'datasetSize': 0,
                'title':       '',
                'xlabel':      '',
                'ylabel':      '',
                'xunit':       '',
                'yunit':       '',
                'numValues':   0,
                'xmin':        0,
                'ymin':        0,
                'xmax':        0,
                'ymax':        0,
                'values':      []
            }
        },

        idAttribute: 'id',

        setup: function( data, options ) {
            this.addEvent("onAdd", function (model, collection, options) {
            });

            this.addEvent("onChange", function (model, options) {
            });

            this.addEvent("onAnyEvent", function (eventName, eventData) {
            });
        },

        sync: function (method, model, options) {
            return { cancel: function () { return; }  };
        },

        parse: function (response, options) {
            var attributes = {};
            attributes.operations = {};
            attributes.parent = options.parent ? options.parent : null;
            if(options.parse) {
                if( response.data ) {
                    var _id, _eid;
                    response.data.forEach( function( item ) {
                        attributes[item.name] = item.value;
                    });

                    if( attributes.eid  && attributes.aid ) {
                        attributes.id = attributes.aid + '@' + attributes.eid;
                    } else {
                        console.log('ERROR in SMATestDataExplorerModel.parse: invalid ID specification' );
                    }

                    response.href && (attributes.href = response.href);
                    attributes.operations.properties = { href: response.href, payload: null };

                    if( response.links ) {
                        this.processLinks( attributes, response );
                    }

                    if( response.queries ) {
                        this.processQueries( attributes, response );
                    }
                }
            }
            return attributes;
        },

        isMeasurementData: function() {
            var ben = this.get( 'bename' );
            return ben && ben.toLowerCase() === 'aolocalcolumn' ? true : false;
        },

        hasChildren: function() {
            var ops = this.get( 'operations' );
            return ops && ops.children ? true : false;
        },

        asamKey: function() {
            var akey = this.get( 'asamKey' );
            return ( !akey || akey.length === 0 ) ? undefined : akey;
        },

        processLinks: function( atts, item ) {
            item.links.forEach( function( link ) {
                var rel = link.rel;
                if( rel && rel.length ) {
                    var href = link.href;
                    if( !href.startsWith('http') ) {
                        href = response.href + href;
                    }
                    atts.operations[rel] = { href: href, payload: null };
                }
            }); 
        },

        processQueries: function( atts, response ) {
            var model = this;
            response.queries.forEach( function( query ) {
                var name = query.rel;
                if( name && name.length ) {
                    atts.operations[name] = model.buildOp( atts, query, response.href );
                }
            });
        },

        buildOp: function( atts, query, baseHref ) {
            var op = { payload: {}, href: query.href ? query.href : baseHref };

            if( query.data ) {
                query.data.forEach( function( item ) {
                    if( !(item.value && item.value.length) ) {
                        switch( item.name ) {
                        case 'peid':
                            if( atts.parent ) {
                                item.value = atts.parent.get( 'eid' );
                            }
                            break;

                        case 'name':
                        case 'channels':
                            item.name = 'name';
                            item.value = '[\"' + atts.name + '\"]';
                            break;

                        default: 
                            if( atts[ item.name ] ) {
                                item.value = atts[ item.name ];
                            }
                        }
                    }
                });
                op.payload = query.data;
            }
            return op;
        },

        parsePlotItem: function ( item ) {
            var model = this;
            var thisname = model.get('name');
            var attributes = {};
            if( item.data && item.data.length ) {
                for( var i = 0; i < item.data.length; ++i ) {
                    var prop = item.data[i];
                    switch( prop.name ) {
                    case 'name':
                        if( prop.value !== thisname ) { return null; }
                        break;
                    case 'points':
                        attributes.numValues = typeof prop.value === 'string' ? JSON.parse( prop.value ) : prop.value;
                        break;
                    case 'matrix':
                        attributes.values = typeof prop.value === 'string' ? JSON.parse( prop.value ) : prop.value;
                        break;
                    case 'complength':
                        attributes.datasetSize = typeof prop.value === 'string' ? JSON.parse( prop.value ) : prop.value;
                        break;
                    case 'xmin':
                    case 'xmax':
                    case 'ymin':
                    case 'ymax':
                        attributes[ prop.name ] = typeof prop.value === 'string' ? JSON.parse( prop.value ) : prop.value;
                        break;
                    default: 
                        attributes[ prop.name ] = prop.value;
                    }
                }
            }
            if( !attributes.title  ) { attributes.title = thisname; }
            if( !attributes.xlabel ) { attributes.xlabel = 'Index';}
            if( !attributes.ylabel ) { attributes.ylabel = thisname; }

            return attributes;
        },

        parsePlotData: function (response, options) {
            var model = this;
            if(options.parse) {
                if( response.items && response.items.length ) {
                    for( var i = 0; i < response.items.length; ++i ) {
                        var item = response.items[i];
                        var attributes = model.parsePlotItem( item );
                        if( attributes ) {
                            return attributes;
                        }
                    }
                }
            }
            return null;
        },

        updatePayload: function( payload, options ) {
            var zoomStart = options.zoomStart ? options.zoomStart : 0;
            var zoomEnd = options.zoomEnd ? options.zoomEnd : 0;
            payload.forEach( function( item ) {
                switch( item.name ) {
                case 'start':
                    item.value = zoomStart.toString();
                    break;

                case 'end':
                    item.value = zoomEnd.toString();
                    break;

                case 'points':
                    item.value = options.numPoints.toString();
                    break;
                }
            });
        },

        getChildren: function( options ) {
            // If model has already obtained its children return them otherwise get them
            // NOTE: will not support the display ASAM-ODS models created after initial retrieval
            var model = this;
            var ops = model.get( 'operations' );
            var op = ops && ops['children'];
            var children = model.get( 'children' );
            var app = TestDataSession.get('app');
            if(children) {
                if( !Array.isArray( children ) ) {
                    // if children have already been retrieved and this model has no children, 
                    // the 'children' attribute will be set to the string 'none'
                    children = null;
                }
                return Promise.resolve( children );
            } else if( app && !model.isMeasurementData() && op ) {
                var cred = TestDataCredentials.getServerCredentials();
                var akey = model.asamKey();
                if( akey || ( cred && cred.valid ) ) {
                    return new Promise( function (resolve, reject) {
                        // make web service call to get this model's children
                        app.getAsamKey( { key: akey, cred: cred } )
                        .then( function( key ) { 
                            op.href += (op.href.indexOf('?') === -1 ? '?' : '&') + 'key=' + key;
                            TestDataQuery.getWAFData( { 
                                method: 'GET', 
                                request: op,
                                context: model,
                                spinner: TestDataSession.get( 'spinner' )
                            })
                            .then( function( response ) {
                                if( response.items ) {
                                    resolve( model.addChildren( response ) );
                                } else {
                                    if( response.error && response.error.message ) {
                                        TestDataMessage.displayMessage( 'info', response.error.message );
                                    } else {
                                        TestDataMessage.displayMessage( 'info', i18n['no-children'] );
                                    }
                                    resolve([]);
                                }
                            })
                            .catch( function( err ) {
                                reject( err );
                            });
                        })
                        .catch( function( err ) {
                            reject( err );
                        });
                    });
                } else {
                    return Promise.resolve( app.reqestNewCredentials() );
                }
            } else {
                return Promise.resolve( [] );
            }
        },

        hasAllProperties: function( ) {
            return this.get( 'fullDetails' );
        },

        markPropertiesObsolete: function() {
            this.set('fullDetails', false);
        },

        getProperties: function( options ) {
            var model = this;
            if( model.get( 'fullDetails' )) {
                return Promise.resolve( model );
            }
            return new Promise( function( resolve, reject ) {
                var ops = model.get( 'operations' );
                var op = ops && ops.properties;
                var app = TestDataSession.get('app');
                if( app && op ) {
                    var cred = TestDataCredentials.getServerCredentials();
                    var akey = model.asamKey();
                    if( akey || ( cred && cred.valid ) ) {
                        app.getAsamKey( { key: akey, cred: cred } )
                        .then( function( key ) {
                            op.href += (op.href.indexOf('?') === -1 ? '?' : '&') + 'key=' + key;

                            TestDataQuery.getWAFData( {
                                method: 'GET',
                                request: op,
                                context: model,
                                spinner: TestDataSession.get( 'spinner' )
                            })
                            .then( function( response ) {
                                model.set( 'fullDetails', true );
                                if( response.items && response.items.length === 1 ) {
                                    var item = response.items[0];
                                    var props = item.data;
                                    if( props && props.length) {
                                        props.forEach( function( prop ) {
                                            model.set( prop.name, prop.value );
                                        });
                                    }
                                    if( item.links ){
                                        model.processLinks( model._attributes, item);
                                    }
                                }

                                if( response.queries ) {
                                    model.processQueries( model._attributes, response );
                                }
                                resolve( model );
                            })
                            .catch( function( errstr, errobj, errctx ) {
                                reject( errstr );
                            });
                        });

                    } else {
                        resolve( app.reqestNewCredentials() );
                    }
                }
            });
        },

        getClientData: function( options ) {
            var data = UWA.clone( this.get( 'plotData' ) );
            if( data && options ) {
                var zoomStart = options.zoomStart ? options.zoomStart : 0;
                var zoomEnd   = options.zoomEnd   ? options.zoomEnd   : 0;

                if( zoomStart > data.xmin || ( zoomEnd !== 0 && zoomEnd < data.xmax ) ) {
                    data.xmin = Math.max( zoomStart, data.xmin );
                    data.xmax = Math.min( zoomEnd, data.xmax );
                }

                data.numValues = data.xmax - data.xmin + 1;

                if( options.numPoints < data.numValues) {
                    this.decimate( data, options.numPoints );
                } else {
                    data.values = data.values.slice( data.xmin, data.xmax+1 );
                }
            }
            return data;
        },

        decimate: function( data, numBins ) {
            if( numBins && numBins > 0 ) {
                var bvalues = [];
                var binSz = parseInt( 2*data.numValues/numBins );
                var i = data.xmin;
                while( i <= data.xmax  ) {
                    var bmin = data.values[i];
                    var bmax = data.values[i++];

                    var j = 1;
                    while( j < binSz &&  i <= data.xmax ) {
                        if( data.values[i] < bmin ) { bmin = data.values[i]; }
                        if( data.values[i] > bmax ) { bmax = data.values[i]; }
                        ++j;
                        ++i;
                    }
                    bvalues.push(bmin);
                    bvalues.push(bmax);
                }
                data.numValues = bvalues.length;
                data.values = bvalues;
            } else {
                data.values = data.values.slice( data.xmin, data.xmax+1 );
            }
        },
        
        hasImplicitData: function() {
            var rep = this.get( 'sequence_representation' );
            return  (rep.trim().splice(0, 8) === 'implicit');
        },

        getPlotData: function( options ) {
            var self = this;
            var app = TestDataSession.get('app');
            return new Promise( function( resolve, reject ) {
                if( self.get( 'clientModel' ) ){
                    return resolve( self.getClientData( options ) );
                }
                var cred = TestDataCredentials.getServerCredentials();
                var akey = self.asamKey();
                if( akey || ( cred && cred.valid ) ) {
                    app.getAsamKey( { key: akey, cred: cred } )
                    .then( function( key ) {
                        if( options && self.isMeasurementData() ) {
                            self.getProperties()
                            .then( function( model ) {
                                if( model && options && model.isMeasurementData() ) {
                                    TestDataUtil.getLocalIPv4()
                                    .then( function( ip ) {
                                        var rep = self.get( 'sequence_representation' );
                                        if( rep && rep.trim().slice(0, 8) === 'implicit' ) {
                                            // generate series data using the seq rep, gen params and submatrix nrows
                                            model.generateImplicitData( options )
                                            .then( function( implData ) {
                                                var plotData = model.parsePlotData( implData, { parse: true } );
                                                model.set('plotData', plotData);
                                                resolve( plotData );
                                            });
                                        } else {
                                            var ops = model.get( 'operations' );
                                            var plotOp = ops && ops.plots;
                                            var payload = plotOp.payload ? { collection: { items:[ { data: UWA.clone( plotOp.payload ) }] } } : {};
                                            if( payload.collection && options.numPoints ) {
                                                var pdata = payload.collection.items[0].data;
                                                model.updatePayload( pdata, options );

                                                // TODO collection-json template should include 'ip' member
                                                if( ip ) {
                                                    var indx = pdata.findIndex(function(item) { 
                                                        return item.name ==='ip'; 
                                                    });

                                                    if( indx >= 0 ) {
                                                        pdata[indx].value = ip;
                                                    } else {
                                                        pdata.push( { name: 'ip', value: ip } );
                                                    }
                                                }
                                                var href = plotOp.href;

                                                if( href ) {
                                                    href += (href.indexOf('?') === -1 ? '?' : '&') + 'key=' + key;
                                                    var request = { href: href, payload: payload };

                                                    TestDataQuery.getWAFData({
                                                        method: 'POST',
                                                        request: request,
                                                        context: model,
                                                        spinner: TestDataSession.get( 'spinner' )
                                                    })
                                                    .then( function( response ) {
                                                        var plotData = model.parsePlotData( response, { parse: true } );
                                                        model.set('plotData', plotData);
                                                        if( rep.trim().slice(0, 3) === 'raw' ) {
                                                            options.plotdata = plotData;
                                                            model.generateImplicitData( options )
                                                            .then( function( implData ) {
                                                                var data = model.parsePlotData( implData, { parse: true } );
                                                                model.set('plotData', data);
                                                                resolve( data );
                                                            });
                                                        } else {
                                                            resolve( plotData );
                                                        }
                                                    })
                                                    .catch( function( err ) {
                                                        reject( err );
                                                    });
                                                }
                                            }
                                        }
                                    });
                                }
                            });
                        }
                    });
                }
            });
        },
        
        generateImplicitData: function( opts ) {
         // Note: this function expects properties to have already been obtained
            var implicitData = {};
            var params = JSON.parse( this.get( 'generation_parameters' ) );
            var rep = this.get( 'sequence_representation' );
            var smtx = this.get( 'parent' );
            if( this.get( 'fullDetails' ) ) {
                return new Promise( function( resolve, reject ) {
                    if( smtx && params && rep ) {
                        smtx.getProperties()
                        .then( function( parent ) {
                            var nrows = parseInt( parent.get( 'number_of_rows' ) );
                            if( nrows > 0 && params && params.length ) {
                                var start = opts.zoomStart >= 0 ? opts.zoomStart : 0;
                                var end = opts.zoomEnd > 0 && opts.zoomEnd < nrows-1 ? opts.zoomEnd : nrows-1;
                                var numPts = end - start + 1;
                                var delta = 1;
                                if( opts.numPoints && opts.numPoints > 0 &&  numPts > opts.numPoints ) {
                                    delta = Math.round( numPts/opts.numPoints );
                                }
                                
                                implicitData.items = [];
                                var data = [];
                                implicitData.items.push( { data: data } );
                                var values = [];
                                
                                data.push( { name: 'complength', value: numPts } );
                                data.push( { name: 'matrix', value: values } );
                                data.push( { name: 'xmin', value: start } );
                                data.push( { name: 'xmax', value: end } );
                                
                                switch( rep ) {
                                case 'implicit_constant':
                                    if( params && params.length === 1 ) {
                                        var p1 = params[0];
                                        for( var i = start; i <= end; i+=delta ) {
                                            values.push( p1 );
                                        }
                                        data.push( { name: 'ymax', value: p1 } );
                                        data.push( { name: 'ymin', value: p1 } );
                                        data.push( { name: 'points', value: values.length } );
                                    } else {
                                        return reject( new Error( 'error', i18n['bad-implicit-data'] ) );
                                    }
                                    break;
                                    
                                case 'implicit_linear':
                                    if( params && params.length === 2 ) {
                                        var p1 = params[0];
                                        var p2 = params[1];
                                        for( var i = start; i <= end; i+=delta ) {
                                            values.push( p1 + i*p2 );
                                        }
                                        var first = values[0];
                                        var last = values[values.length-1];
                                        data.push( { name: 'ymin', value: first < last ? first : last } );
                                        data.push( { name: 'ymax', value: first > last ? first : last } );
                                        data.push( { name: 'points', value: values.length } );
                                    } else {
                                        return reject( new Error( 'error', i18n['bad-implicit-data'] ) );
                                    }
                                    break;
                                    
                                case 'implicit_saw':
                                    if( params && params.length === 3 ) {
                                        var p1 = params[0];
                                        var p2 = params[1];
                                        var p3 = params[2];
                                        var minval = p1;
                                        var maxval = p1;
                                        for( var i = start; i <= end; i+=delta ) {
                                            var val = 1 + i % ( (p3-p1)/p2 ) * p2;
                                            values.push( val );
                                            if( val < minval ) { minval = val; }
                                            if( val > maxval ) { maxval = val; }
                                        }
                                        data.push( { name: 'ymin', value: minval } );
                                        data.push( { name: 'ymax', value: maxval } );
                                        data.push( { name: 'points', value: values.length } );
                                    } else {
                                        return reject( new Error( 'error', i18n['bad-implicit-data'] ) );
                                    }
                                    break;
                                    
                                case 'raw_linear':
                                case 'raw_linear_external':
                                    var rawdata = opts.plotdata.values;
                                    if( rawdata && params && params.length === 2 ) {
                                        var p1 = params[0];
                                        var p2 = params[1];
                                        var num = rawdata.length;
                                        if( end + start > num ) {
                                            end = num - start;
                                        }
                                        
                                        for( var i = start; i <= end; i+=delta ) {
                                            values.push( p1 + rawdata[i]*p2 );
                                        }
                                        var first = values[0];
                                        var last = values[values.length-1];
                                        data.push( { name: 'ymin', value: first < last ? first : last } );
                                        data.push( { name: 'ymax', value: first > last ? first : last } );
                                        data.push( { name: 'points', value: values.length } );
                                    } else {
                                        return reject( new Error( 'error', i18n['bad-implicit-data'] ) );
                                    }
                                    break;
                                    
                                case 'raw_polynomial':
                                case 'raw_polynomial_external':
                                    var rawdata = opts.plotdata.values;
                                    var degree;
                                    if( params && params.length ) {
                                        degree = params[0];
                                    }
                                    if( rawdata && degree && params.length === degree+2 ) {
                                        var num = rawdata.length;
                                        if( end + start > num ) {
                                            end = num - start;
                                        }
                                        
                                        for( var i = start; i <= end; i+=delta ) {
                                            var val = params[1]; // constant term
                                            var rawval = rawdata[i];
                                            var pow = rawval;
                                            for( var j = 0; j < degree; ++j ) {
                                                val += pow*params[j+2];
                                                pow *= rawval;
                                            }
                                            values.push( val );
                                            if( i === start ) {
                                                minval = maxval = val;
                                            } else {
                                                if( val < minval ) { minval = val; }
                                                if( val > maxval ) { maxval = val; }
                                            }
                                        }
                                        var first = values[0];
                                        var last = values[values.length-1];
                                        data.push( { name: 'ymin', value: minval } );
                                        data.push( { name: 'ymax', value: maxval } );
                                        data.push( { name: 'points', value: values.length } );
                                    } else {
                                        return reject( new Error( 'error', i18n['bad-implicit-data'] ) );
                                    }
                                    break;
                                    break;

                                case 'raw_linear_calibrated':
                                case 'raw_linear_calibrated_external':
                                    var rawdata = opts.plotdata.values;
                                    if( rawdata && params && params.length === 3 ) {
                                        var p1 = params[0];
                                        var p2 = params[1];
                                        var p3 = params[2];
                                        var num = rawdata.length;
                                        if( end + start > num ) {
                                            end = num - start;
                                        }
                                        
                                        for( var i = start; i <= end; i+=delta ) {
                                            values.push( p1 + rawdata[i]*p2 ) * p3;
                                        }
                                        var first = values[0];
                                        var last = values[values.length-1];
                                        data.push( { name: 'ymin', value: first < last ? first : last } );
                                        data.push( { name: 'ymax', value: first > last ? first : last } );
                                        data.push( { name: 'points', value: values.length } );
                                    } else {
                                        return reject( new Error( 'error', i18n['bad-implicit-data'] ) );
                                    }
                                    break;
                                default:
                                    console.log( 'WARNING: generation of ' + rep + ' data is not yet implemented');
                                    break;
                                }
                            }
                            resolve( implicitData );
                        });
                    } else {
                        reject( new Error( 'error',  i18n[ 'generation_failed' ] ) );
                    }
                });
            } else {
                reject( new Error( 'error',  i18n[ 'generation_failed' ] ) );
            }
        },

        addChildren: function( data ) {
            var children = [];
            var self = this;
            var items = data.items;
            if( items && items.length) {
                items.forEach( function( item ) {
                    var model = new testDataModel( item, { 
                        parse: true, 
                        parent: self, 
                        collection: self.collection, 
                        silent: true,
                        queries: data.queries,
                        template: data.template
                    });
                    children.push( model );
                    self.collection.push( model ); // skeleton requires all models to be contained in the root collection
                });
                this.set( 'children', children, { silent: true } );
            }
            return children;
        },

        getPath: function() {
            var path = [];
            var parent = this.get('parent');
            while(parent) {
                path.push(parent);
                parent = parent.get('parent');
            }
            return path;
        },

        validate: function (attr) {
            if (attr.id.length <= 0) {
                return 'Invalid value for id supplied';
            }
            if (attr.aid.length <= 0 || attr.eid.length <= 0) {
                return 'Invalid database ID supplied';
            }
        }
    });

    return testDataModel;
});

define('DS/SMAExeCOSAdmin/Views/ServerPropertiesView', [
    'UWA/Core',
    'DS/W3DXComponents/Views/Temp/TempItemView',
    'DS/SMAExeCOSAdmin/Views/ServerForm',
    'DS/W3DXComponents/Views/Layout/ScrollView',
	  'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
], function(
    UWA,
    ItemView,
    ServerForm,
    ScrollView,
    NLS
    ) {

    'use strict';
    var _name = 'server-properties';


    // Define the properties used for the COS server
    // The properties are displayed using the ServerForm
    var ServerProperties = ItemView.extend({
        name : _name,
        tagName : 'div',
        template : function() {
            return '<div class=\'' + this.getClassNames('-subcontainer') + '\'></div>';
        },
        domEvents : {},

        init : function(options) {
            [ 'container', 'template', 'tagName', 'domEvents' ].forEach(function(propToDelete) {
                delete options[propToDelete];
            });

            this._parent( options);
        },

        setup : function() {
        	// check if use alias flag is set and if so display form with additional server prop id
            this.container.addClassName(this.getClassNames('-container'));
            this._form = this._initFormAlias();
        },

        // define the fields of the COS server that is displayed in the form
        // The server properties facet declares renderer handler for the server properties
        _initForm : function() {
            var formOptions = {
                className : 'vertical',
                fields : function() {
                    var premRes = [ {
                        type : 'text',
                        name : 'ID',
                        attributes : {
                            'data-attr' : 'id',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        label : NLS.get('name')
                    }, {
                        type : 'text',
                        name : 'status',
           		        value : 'LOADING...',
                        label : NLS.get('status')
                    },  {
                        type : 'text',
                        name : 'fullCosUrl',
                        attributes : {
                            'data-attr' : 'fullCosUrl',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        label : NLS.get('fullCosUrl')
                    },  {
                        type : 'text',
                        name : 'privatePorts',
           		        value : '35125, 45341, 55447',
                        label : NLS.get('privatePorts')
                    },   {
                        type : 'textarea',
                        name : 'publicKey',
                        attributes : {
                            'data-attr' : 'eedPublicKey',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        rows : 5,
                        label : NLS.get('publicKey'),
                        placeholder : ''
                    }];

                    var cloudRes = [ {
                        type : 'text',
                        name : 'ID',
                        attributes : {
                            'data-attr' : 'id',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        label : NLS.get('name')
                    }, {
                        type : 'text',
                        name : 'status',
           		        value : 'LOADING...',
                        label : NLS.get('status')
                    },  {
                        type : 'text',
                        name : 'fullCosUrl',
                        attributes : {
                            'data-attr' : 'fullCosUrl',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        label : NLS.get('fullCosUrl')
                    }, {
                        type : 'textarea',
                        name : 'publicKey',
                        attributes : {
                            'data-attr' : 'eedPublicKey',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        rows : 5,
                        label : NLS.get('publicKey'),
                        placeholder : ''
                    }];

	     			var onCloud = false;
	     			if (this.model) {
	     				onCloud = this.model.get('onCloud');
	     			}
	     			else {
	     				onCloud = this.get('onCloud');				     				
	     			}
                    if ('false' === onCloud) {
                    	return premRes;
                    }
                    else {
                    	return cloudRes;
                    }
                }
            };

            var form = this.formProperties = new ServerForm(UWA.extend({
                model : this.model
            }, formOptions));

            return form;
        },

        // define the fields of the COS server that are displayed in the form
        // include extra server properties field to support registering mutiple cos servers with same eed id
        // The server properties facet declares renderer handler for the server properties
        _initFormAlias : function() {
            var formOptions = {
                className : 'vertical',
                fields : function() {
                    var premRes = [ {
                        type : 'text',
                        name : 'ID',
                        attributes : {
                            'data-attr' : 'id',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        label : NLS.get('alias')
                    }, {
                        type : 'text',
                        name : 'status',
           		        value : 'LOADING...',
                        label : NLS.get('status')
                    },  {
                        type : 'text',
                        name : 'fullCosUrl',
                        attributes : {
                            'data-attr' : 'fullCosUrl',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        label : NLS.get('fullCosUrl')
                    },  {
                        type : 'text',
                        name : 'serverPropId',
                        attributes : {
                            'data-attr' : 'serverPropId',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        label : NLS.get('serverPropId')
                    },  {
                        type : 'text',
                        name : 'privatePorts',
           		        value : '35125, 45341, 55447',
                        label : NLS.get('privatePorts')
                    },   {
                        type : 'textarea',
                        name : 'publicKey',
                        attributes : {
                            'data-attr' : 'eedPublicKey',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        rows : 5,
                        label : NLS.get('publicKey'),
                        placeholder : ''
                    }];

                    var cloudRes = [ {
                        type : 'text',
                        name : 'ID',
                        attributes : {
                            'data-attr' : 'id',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        label : NLS.get('alias')
                    }, {
                        type : 'text',
                        name : 'status',
           		        value : 'LOADING...',
                        label : NLS.get('status')
                    },  {
                        type : 'text',
                        name : 'fullCosUrl',
                        attributes : {
                            'data-attr' : 'fullCosUrl',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        label : NLS.get('fullCosUrl')
                    },  {
                        type : 'text',
                        name : 'serverPropId',
                        attributes : {
                            'data-attr' : 'serverPropId',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        label : NLS.get('serverPropId')
                    }, {
                        type : 'textarea',
                        name : 'publicKey',
                        attributes : {
                            'data-attr' : 'eedPublicKey',
                            'data-editable' : false,
                            useGenInfo : false
                        },
                        rows : 5,
                        label : NLS.get('publicKey'),
                        placeholder : ''
                    }];

	     			var onCloud = false;
	     			if (this.model) {
	     				onCloud = this.model.get('onCloud');
	     			}
	     			else {
	     				onCloud = this.get('onCloud');				     				
	     			}
                    if ('false' === onCloud) {
                    	return premRes;
                    }
                    else {
                    	return cloudRes;
                    }
                }
            };

            var form = this.formProperties = new ServerForm(UWA.extend({
                model : this.model
            }, formOptions));

            return form;
        },
        onRender : function() {
            var container = this.getElement('.server-properties-subcontainer');

            // No render call as this is not a view
            this.formProperties.inject(container);


            container.render = function() {};
            container.container = container;


            var scrollerView = new ScrollView({
                view : container,
                useInfiniteScroll : false,
                usePullToRefresh : false
            });

            scrollerView.render().inject(this.container);
        },

        onDestroy : function() {

            if (this.formProperties) {
                this.formProperties.destroy();
                delete this.formProperties;
            }

        }
    });

    return ServerProperties;
});


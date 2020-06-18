/**
 * @overview View to render a model in a form.
 * @licence Copyright 2006-2014 Dassault Systèmes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/SMAExeCOSAdmin/Views/ServerForm',
	[ 'UWA/Core',
	  'UWA/Utils',
	  'UWA/Class/Listener',
	  'DS/UIKIT/Form',
	  'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
	  'DS/W3DXComponents/Views/Temp/TempAutocomplete',
	  'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
	  'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
	  ],
	  function(UWACore,  UWAUtils,  Listener,   UIForm,  COSUtils,  Autocomplete,  WSUtils,  NLS) {

    'use strict';

    var ServerForm;

    // form used to display properties of the given model
    // gets the data for the specified fields from the model
    ServerForm = UIForm.extend(Listener,  {

        _disabled : false,

        _get : function  (object,  prop,  context,  args){
            if (typeof object[prop] === 'function'){
                return object[prop].apply(context,  args);
            } else {
                return UWACore.clone(object[prop],  false);
            }
        },
        init : function(options) {
            var _options = {},  model = options.model;

            if (!model) {
            	COSUtils.displayError(UWACore.i18n(NLS.missingModel),  true);
                return;
            }

            this.model = options.model;
            delete options.model;

            Object.keys(options).map(function(value) {
                _options[value] = this._get(options,  value,  this.model);
                return _options[value] ;
            },  this);

            this._parent(  _options);

            this.syncFields();

            this._modelEvent = {
                onChange : this._onModelChange,
                onDestroy : this._onModelDestroy
            };
            this.listenTo(this.model,  this._modelEvent);
        },

        setValues : function(values) {
            try {
                this._parent( values);
                // IR:IR-577753-3DEXPERIENCER2018x
                // need to disable server fields if not in edit mode
                if (values.publicKey !== undefined) {
                	this.setDisabled();
                }
            }
            catch (err) {
        		// ignore errors that seem to happen in firefox
            }
            return this;
        },

        setValue : function(name,  value,  force) {
        	// don't show undefined fields display them as empty
        	if (value===undefined || value ==='undefined') {
        		value = '';
        		// check for undefined boolean fields and set them to their default value
        		if (name === 'predefinedonly'){
        			value = 'false';
        		}
        		if (name === 'cacheplmfiles'){
        			value = 'true';
        		}
        		if (name === 'skiplock'){
        			value = 'true';
        		}
        		if (name === 'saveLogOnError'){
        			value = 'false';
        		}
        	}
        	else if (value ==='empty') {
        		value = '';
        	}
        	var values = {};
        	values[name] = value;

        	return this.setValues(values,  force);
        },

        getValues : function() {
            var values = this._parent.apply(this,  arguments),  i,  l,  element,  elements = this.getFields();

            for (i = 0,  l = elements.length; i < l; i++) {
                element = elements[i];

                if (element.getAttribute('type') === 'autocomplete') {
                    values[element.name] = element.getAttribute('data-key');
                }
            }

            return values;
        },

        clear : function(force) {
            if (this._disabled && !force) {
                return;
            }

            var values = this.getValues();

            Object.keys(values).forEach(function(key) {
                values[key] = '';
            });

            this.setValues(values);
            this.dispatchEvent('onClear');
        },

        reset : function() {
            this.syncFields();
            this.dispatchEvent('onReset');

            return this;
        },

        syncFields : function() {
            var that = this;

            if (this.elements.container) {
	            this.getFields().forEach(function(field) {
	                that.syncField(field.getAttribute('name'));
	            });
            }
            return this;
        },

        syncField : function(name) {
            var field = this.getField(name),  dataAttr, that, useGenInfo;

            if (!field) {
                return this;
            }
            that = this;
        	var fullCosUrl = this.model.get('fullCosUrl');

            dataAttr = field.getAttribute('data-attr');
            useGenInfo = field.getAttribute('useGenInfo');

            // the status field for the server must be gotten by a web service call
            // the status filed for the station in already set in the model
            if (name === 'status'){
            	// if the model has a GeneralInfo value then it is a station and status is already set
            	if (this.model.get('GeneralInfo')) {
    	            dataAttr=this.model._attributes['@status'];
    	            this.setValue(name,  dataAttr,  true);
            	}
            	else {
            		// otherwise get the url for the webservice

	            	// if not defined use the status in the model
	            	if (fullCosUrl === undefined || fullCosUrl.length === 0){
	    	            dataAttr=this.model._attributes['@status'];

	    	            this.setValue(name,  dataAttr,  true);

	            	}
	            	else {
	            		// otherwise use url to make web service call to get status for the server
	            		WSUtils.adminGetStatus(fullCosUrl,
	            			// if success ...display status returned
		                    function(data) {
		                    	that.setValue('status',  data,  true);
		                    },
		                    // if fail display error
		                    function () {
		                    	that.setValue('status',  'ERROR',  true);
		                    });
	            	}
            	}

            }
            // set the value from the model which may have been changed on edit
            else if (name === 'privatePorts') {
	            this.setValue(name,  that.model.get('privatePorts'), {silent:true} );
            }
            else if (name === 'moreProps') {
            	var props = '';

                if ( this.model.get('PropertyList') && this.model.get('PropertyList').Property){
                	this.model.get('PropertyList').Property.forEach(function (value,  key) {
                		if (!(COSUtils.hasFieldPropValue(key))) {
                			props = props.concat(key + '=' + value + '\n');
                		}
                	});
                }
	            this.setValue(name,  props,  true);
            }
            else if (COSUtils.hasFieldProp(name)){
            	var fieldVal = COSUtils.getFieldProp(name, this.model);
            	this.setValue(name,  fieldVal,  true);
            }
            else {
            	if (UWACore.is(dataAttr)) {
            		// if a data attr was set in the field option
            		// check if we need to get it from the model's GeneralInfo attribute
            		if (useGenInfo && useGenInfo === 'true') {
            			var genInf = this.model.get('GeneralInfo');
            			dataAttr = genInf[dataAttr];
            		}
	                else {
	                	// get the attribute directly from the model
             			dataAttr = this.model.get(dataAttr);
	                }
	            }
	            else if (field.value  && field.value !==undefined && field.value !=='undefined') {
	            	dataAttr= field.value;
	            }
	            else {
	                dataAttr = this.model.get(name);
	            }

            	this.setValue(name,  dataAttr,  true);
            }

            return this;
        },

        setDisabled : function(disabled,  force) {
            var dataEditable,  index,  fields,  field;

            this._disabled = true;

            if (typeof disabled === 'undefined') {
                disabled = true;
            }

            fields = this.getFields(true);

            for (index = 0; index < fields.length; index++) {
                field = fields[index];
                dataEditable = field.getAttribute('data-editable');

                if (!disabled && (dataEditable === 'false' || !dataEditable) && !force) {
                    continue;
                }

                field.disabled = disabled;
                this._disabled = disabled;
            }

            return this;
        },

        createField : function(){
            //Surcharge car impossible de personnaliser le DOM des champs avec uikit
            var fieldWrapper = this._parent.apply(this,  arguments);
            return fieldWrapper;
        },

        fields : UWACore.extend(UIForm.prototype.fields,  {
            autocomplete : function(options,  form) {
                var input,  label,  that = form,  defaultOptions = {
                    id : 'input-' + UWAUtils.getUUID().substring(0,  6)
                };

                input = new Autocomplete(UWACore.extend(defaultOptions,  options,  true));
                input.getContent().getElement('input').addClassName('form-control').getParent().removeClassName('temp-autocomplete-searchbox');

                if (UWACore.is(options.label)) {
                    label = UWACore.createElement('label',  {
                        'for' : input.getId(),
                        text : UWACore.i18n(options.label + that.options.labelSuffix)
                    });
                }

                return that.createField( input,  label);
            }
        }),

        _onModelChange : function() {
            this.syncFields();
        },

        _onModelDestroy : function() {
            this.disable();
            this.clear(true);
        },

        onReset : function() {
            this.disable();
        },

        onEdit : function() {
            this.enable();
        },

        destroy : function() {
            this.stopListening(this.model,  this._modelEvent);
            return this._parent.apply(this,  arguments);
        }
    });

    return ServerForm;
});

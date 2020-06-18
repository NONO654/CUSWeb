require(['DS/SMAProcWebCMMUtils/SMAJSCMMUtils',
    'DS/SMAProcWebCommonControls/FileChooser',
    'DS/JSCMM/SMAJSCMMExtensionManager'
], function(SMAJSCMMUtils, FileChooser, SMAJSCMMExtensionManager) {
    'use strict';
    window.Polymer({
        is: 'cmp-generic',
        properties: {
            /**
             * Mandatory property to be declared, and set to be the component's updateUI and Apply methods.
             * @type {Object}
             */
            ExtensionEditorImpl: {
                type: Object,
                notify: true
            },

            /**
             * Set to the instance of the process activity
             * @type {Object}
             */
            _activity: {
                type: Object
            },

            /**
             * Contains the properties and its value as defined in the adapter editor UI window
             * The extensionConfig object is saved in database to be later retrieved when the editor window is open.
             * @type {Object}
             */
            extensionConfig: {
                type: Object
            },

            /**
             * Object containing the values of the properties/variables
             * @type {Object}
             */
            propList: {
                type: Object,
                value: function() {
                    return {};
                }
            },

            /**
             * Contains the list of the `property` objects
             * @type {Array}
             */
            _properties: {
                type: Array,
                value: function() {
                    return [];
                }
            },
            /**
             * Contains the list of properties from descriptor with type
             * @type {Object}
             */
            _descproperties: {
                type: Object,
                value: function() {
                    return {};
                }
            },

            /**
             * Instance of the `step`
             * @type {Object}
             */
            _step: {
                type: Object
            }
        },

        /**
         * Part of the Polymer Lifecycle callbacks.
         * 'ready' callback is called when a Polymer element's local DOM has been initialized.
         */
        ready: function() {
            /** Binds the current object's (cmp-generic) UpdateUI and Apply method, so that UpdateUI and Apply method is always called on the cmp-generic object instance
             * no matter what the current object "this" refers to and assigns it to the ExtensionEditorImpl object.
             * The web component's ExtensionEditorImpl property which already has the UpdateUI and Apply methods  is being called
             * at the time the UI is loaded. Please remember, that this a mandatory step, or else the UI will not be loaded
             * Visit link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/bind for more
             * information on the usage of the bind() function.
             **/
            this.ExtensionEditorImpl = {
                UpdateUI: this.UpdateUI.bind(this),
                Apply: this.Apply.bind(this)
            };
        },

        /**
         * Updates the user interface with the information saved in the `Apply` method or the initial values for the properties described in descriptor xml.
         * @param {Object} iActivity - activity
         * @param  {Object} iStep - step
         * @param  {Object} iExtensionConfig contains the properties and values declared in the descriptor xml
         */
        UpdateUI: function(iActivity, iStep, iExtensionConfig) {
            this._activity = iActivity;
            this._step = iStep;
            /** contains the properties as declared in the descriptor xml as well as their values */
            this.extensionConfig = iExtensionConfig;
            var extensionName = iExtensionConfig.getExtensionName();
            var extension = SMAJSCMMExtensionManager.getExtension(extensionName);
            var extensionProperties = extension && extension.getProperties();
            if (extensionProperties ) {
                for (var i = 0; i < extensionProperties.length; i++) {
                    this._writePropertyToPropList(extensionProperties[i]);
                }
            }
            if (this.extensionConfig) {
                var properties = this.extensionConfig.getProperties();
                /**
                 * Checks if the _properties has a length > 0 and then sets the _properties to empty array
                 * This is to avoid duplicate entries into the array when the user edits the Editor multiple
                 * number of times before the process execution.
                 */
                if (properties.length) {
                    this._properties = [];
                }
                for (var j = 0; j < properties.length; j++) {
                    var prop = properties[j];
                    if (prop) {
                        if (this.extensionConfig.isScalarProperty(prop)) {
                            this._saveScalarPropertyToList(prop);
                        } else if (this.extensionConfig.isAggregrateProperty(prop)) {
                            this._saveAggregatePropertyToList(prop);
                        }
                    }
                }
            }
        },

        _writePropertyToPropList: function(prop) {
            if (prop.type.toLowerCase() === 'aggregate') {
                var subProperties = prop.Property;
                for (var i = 0; i < subProperties.length; i++) {
                    this._writePropertyToPropList(subProperties[i]);
                }
            } else {
                this._writeScalarPropToPropList(prop);
            }

        },

        _writeScalarPropToPropList: function(prop) {
            var type = prop.type.toLowerCase();
            var name = prop.name;
            this.set('_descproperties.' + name, type);
        },

        /**
         * Saves the scalar properties to the propList along with their values.
         * @param {Object} prop - SMAJSCMMProperty
         */
        _saveScalarPropertyToList: function(prop) {
            // Polymer Array mutation method to push element to an array and make it observable to the data system
            this.push('_properties', prop);

            var propertyName = prop.getName();
            var propertyValue = prop.getValue();

            if (propertyValue === null || propertyValue === undefined) {
                propertyValue = '';
            }
            this.set('propList.' + propertyName, propertyValue);
        },


        /**
         * Iterates through the Aggregate properties and saves the scalar properties declared inside the aggregate properties to the propList along with their values.
         * @param {Object} prop - SMAJSCMMProperty
         */
        _saveAggregatePropertyToList: function(prop) {
            var subProperties = prop.getProperties();
            for (var subPropertyIndex = 0; subPropertyIndex < subProperties.length; subPropertyIndex++) {
                var subProperty = subProperties[subPropertyIndex];
                if (this.extensionConfig.isScalarProperty(subProperty)) {
                    this._saveScalarPropertyToList(subProperty);
                } else {
                    this._saveAggregatePropertyToList(subProperty);
                }
            }
        },

        /**
         * Saves the Aggregate properties to the SMAJSCMMExtensionConfig object
         * @param {Object} prop - SMAJSCMMProperty
         * @returns {array} properties
         */
        _saveAggPropertyToExtensionConfig: function(prop) {
            var scalarPropertyList = [];
            var subProperties = prop.getProperties();
            for (var subPropertyIndex = 0; subPropertyIndex < subProperties.length; subPropertyIndex++) {
                var subProperty = subProperties[subPropertyIndex];
                if (this.extensionConfig.isScalarProperty(subProperty)) {
                    var isUpdateSuccess = this._saveScalarPropertyToExtensionConfig(subProperty);
                    if (isUpdateSuccess) {
                        scalarPropertyList.push(subProperty);
                    }
                } else {
                    subProperty.setProperties(this._saveAggPropertyToExtensionConfig(subProperty));
                    scalarPropertyList.push(subProperty);
                }
            }

            return scalarPropertyList;
        },

        /**
         * Also called from _saveAggPropertyToExtensionConfig method to save only the scalar properties in the extension Config object.
         * @param {Object} property - SMAJSCMMProperty
         * @returns {boolean} true if property could be saved
         */
        _saveScalarPropertyToExtensionConfig: function(property) {
            var propertyName = property && property.getName();
            //  Iterate through the _properties array already set in the UpdateUI method
            if (propertyName in this.propList) {
                /** Sets the property value from the proplist object to the extensionConfig Object
                 *  this extensionConfig object is set to be the extensionConfig object (SMAJSCMMExtensionConfig type)
                 * received from the web services in the UpdateUI method.
                 * `SMAJSCMMExtensionConfig.setPropertyValue` sets the value of the given property.
                 **/
                if (property.getDataType() === SMAJSCMMUtils.DataType.PLMObject) {
                    property.setDataType(SMAJSCMMUtils.DataType.String);
                }
                this.extensionConfig.setPropertyValue(property, this.propList[propertyName]);
                return true;
            }
            return false;
        },

        /**
         * Receives the values from the user interface and saves it inside the extensionConfig object
         * to be sent to the web service.
         * This method is called when the user clicks on Ok or Apply button from the editor (modal) window
         */
        Apply: function() {
            var properties = this.extensionConfig.getProperties();
            for (var i = 0; i < properties.length; i++) {
                var prop = properties[i];
                if (this.extensionConfig.isScalarProperty(prop)) {
                    this._saveScalarPropertyToExtensionConfig(prop);
                } else if (this.extensionConfig.isAggregrateProperty(prop)) {
                    prop.setProperties(this._saveAggPropertyToExtensionConfig(prop));
                }
            }
        },


        /**
         * Returns the name of the property as defined in the descriptor xml
         * @returns String Name of the property
         * @param {String} property SMAJSCMMProperty
         * @example     <Property name="message" type="string" valuetype="single" subtype="multiline">
         *                <Value>FirstMessage</Value>
         *            </Property>
         * According to the example the function returns the string "message"
         */
        getPropertyName: function(property) {
            return (property && property.getName) ? property.getName() : null;
        },

        getPropertyLabel: function(property) {
            var displayName = (property && property.getDisplayName) ? property.getDisplayName() : null;
            return displayName || this.getPropertyName(property);
        },


        /**
         * Returns the "VALUE" subelement's values for the property element declared in the descriptor xml
         * @returns Returns the Value for the particular property
         * @param {String} property SMAJSCMMProperty
         * @example     <Property name="message" type="string" valuetype="single" subtype="multiline">
         *                <Value>FirstMessage</Value>
         *            </Property>
         * According to the example the function returns the string "FirstMessage"
         */
        getPropertyValue: function(property) {
            return this.extensionConfig.isScalarProperty(property) ? property.getValue() : null;
        },

        /**
         * Returns the "type" attribute's values for the property element declared in the descriptor xml
         * @returns Returns the type for the particular property
         * @param {Object} property property to check
         * @example     <Property name="message" type="string" valuetype="single" subtype="multiline">
         * Typical values are:
         *   String: 0, Boolean: 1, Integer: 2, Real: 3, Timestamp: 4, UserType: 7, PLMObject: 8, File: 9
         */
        getPropertyType: function(property) {
            return (property && property.getDataType) ? property.getDataType() : null;
        },

        /**
         * Returns the subtype attribute values for the property element declared in the descriptor xml
         * @returns When defined returns Subtype attribute value or else null
         * @param {Object} property property to check
         * @example <Property name="message" type="string" valuetype="single" subtype="multiline">
         * if the above property is declared in the descriptor xml then "multiline" is returned from the method
         */
        getPropertySubtype: function(property) {
            var subtype = (property && property.getDataSubType) ? property.getDataSubType() : null;
            if (subtype && subtype.toLowerCase) {
                subtype = subtype.toLowerCase();
            }
            return subtype;
        },

        /**
         * Updates the propList object with the latest content in the input controls.
         * @param {Event} e event fired when  focus is moved from input control.
         */
        setProperty: function(e) {
            // normalized event object that provides equivalent target data on both shady DOM and shadow DOM
            var event = Polymer.dom(e);
            var localTarget = event && event.localTarget;
            var propertyName = localTarget && localTarget.id;
            if (propertyName) {
                var value = (localTarget.type === 'checkbox') ? localTarget.checked : localTarget.value;
                this.set('propList.' + propertyName, value);
            }
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
        },

        setFileProperty: function(e) {
            var value = e && e.detail && e.detail.datahandlerconfig;
            if (value) {
                var propName = e.target.id;
                this.propList[propName] = value;
            }
        },

        setPLMObjectProperty: function(e) {
            var value = e && e.detail && e.detail.getRuleXML && e.detail.getRuleXML();
            if (value) {
                var propName = e.target.id;
                this.propList[propName] = value;
            }
        },

        getFileActionType: function(property) {
            return property._mode === 0 ? 'download' : 'upload';
        },

        // hide internal properties from generic editor
        _filterProperty: function(property) {
            return this.getPropertyName(property) !== 'Position_Property';
        },

        _computeValue: function(propList, property) {
            return this.propList[property.getName()];
        },

        _computeBooleanValue: function(propList, property) {
            return String(this.propList[property.getName()]) === 'true';
        },
        _displayAsInputText: function(property) {
            var displayedAsCheckbox = this._displayAsCheckbox(property);
            var displayedAsTextarea = this._displayAsTextarea(property);
            var displayedAsPLMObject = this._displayAsPLMObject(property);
            var displayedAsFile = this._displayAsFile(property);
            return !(displayedAsCheckbox || displayedAsTextarea || displayedAsPLMObject || displayedAsFile);
        },
        _displayAsTextarea: function(property) {
            return this.getPropertyType(property) === SMAJSCMMUtils.DataType.String && this.getPropertySubtype(property) === 'multiline';
        },
        _displayAsCheckbox: function(property) {
            return this.getPropertyType(property) === SMAJSCMMUtils.DataType.Boolean;
        },
        _displayAsFile: function(property) {
            return this.getPropertyType(property) === SMAJSCMMUtils.DataType.File;
        },
        _displayAsPLMObject: function(property) {
            var PLMObjectDatatype = SMAJSCMMUtils.DataType.PLMObject;
            var PLMObjectDatatypeServer = SMAJSCMMUtils.DataType.server.properties[PLMObjectDatatype];
            var PLMObjectDatatypeServerName = PLMObjectDatatypeServer.name.toLowerCase();
            return this.getPropertyType(property) === SMAJSCMMUtils.DataType.PLMObject ||
                this._descproperties[property.getName()] === PLMObjectDatatypeServerName;
        }
    });
});

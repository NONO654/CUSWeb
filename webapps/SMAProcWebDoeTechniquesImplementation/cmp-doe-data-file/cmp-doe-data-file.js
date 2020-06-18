/**
 * @class element:cmp-doe-data-file
 * @noinstancector
 * @description
 * This component implements the Data File technique in DOE.
 * The Data File technique provides a convenient way for you to define your own set of trials outside of Process Composer
 * and still make use of Process Composer’s integration and automation capabilities. The design matrix can be defined by
 * data imported from one or more files, allowing you to execute the DOE study (automatically evaluate all the design points)
 * and analyze the results. Any file used must contain a row of tab or space separated values for each data point and a
 * column for each parameter to be used as a factor from that file.
 */

require(['SMAProcWebDoeTechniquesBase/SMAProcDesignDriverDataHandler', 'DS/SMAProcWebCMMUtils/SMAJSCMMParameterUtils',
         'DS/SMAProcWebCMMUtils/SMAJSCMMUtils', 'SMAProcWebDoeTechniquesBase/SMAProcDesignDriverFactorImpl'],
function (SMAProcDesignDriverDataHandler, SMAJSCMMParameterUtils, SMAJSCMMUtils, SMAProcDesignDriverFactorImpl) {
    'use strict';
    var EVENT = {
        ONPARAMSELECTED: 'paramselected',
        DATFILECONTENTREADY:'datafilecontentready'
    };
    Polymer(/** @lends element:cmp-doe-data-file# */{
        is: 'cmp-doe-data-file',
        properties: /** @lends element:cmp-doe-data-file# */{
            /**
             * The factors are added/updated in this array as and when they are selected/updated by the user
             * @type {Array}
             */
            updatedFactors: {
                type: Array,
                notify: true,
                value: function() { return []; }
            },
            /**
             * Properties/options specific to the technique - Fractional Factorial.
             * The number of levels in Fractional Factorial technique can be only 2 or 3.
             * @type {Object}
             */
            techniqueOptions: {
                type: Object,
                value: function () {
                    return {
                        'useHeaderRow': true,
                        'headerRow': 1,
                        'dataRow': 2,
                        'dataHandlerconfigString' : ''

                    };
                }
            },
            /**
             * The actual content of the selected file.
             * @type {String}
             */
            fileContent: {
                type: String,
                value: '',
                notify: true
            },
            /**
             * To hide/show document input or
             * @type {Number}
             */
            index: {
                type: Number,
                value: 0,
                notify: true
            },
            /**
             * The columns for the parameters, scanned from the selected document.
             * @type {Array}
             */
            parameterColumns: {
                type: Array,
                value: function () {
                    return  [
                            {
                                name: 'Parameter',
                                key: 'Name',
                                type: 'text',
                                width_percent: 'auto'
                            },
                            {
                                name: '',
                                key: 'col_2',
                                type: 'checkbox',
                                width_percent: '20'
                            },
                            {
                                name: 'Mode',
                                key: 'Mode',
                                type: 'dropdown',
                                icon: '',
                                width_percent: 'auto',
                                options: [
                                          { value: 'In',
                                             icon: this.resolveUrl('../../SMAProcWebAuthoringUtils/assets/images/I_SMASedInputParameter.png')},
                                          { value: 'Out',
                                              icon: this.resolveUrl('../../SMAProcWebAuthoringUtils/assets/images/I_SMASedOutputParameter.png')},
                                          { value: 'In/Out',
                                              icon: this.resolveUrl('../../SMAProcWebAuthoringUtils/assets/images/I_SMASedInOutParameter.png')}
                                      ]
                            }
                         ];
                },
                notify: true
            },

            /**
             * Height of the scanned parameters table.
             * @type {Number}
             */
            tableheight: {
                type: Number,
                value: 280
            },
            /**
             * Width of the scanned parameters table.
             * @type {Number}
             */
            tablewidth: {
                type: Number,
                value: 280
            }
        },

        behaviors: [SPBase],
        listeners: {
            'onCellModified': '_addParameter'
          },

        /**
         * Called after the element is attached to the document.
         * Can be called multiple times during the lifetime of an element.
         * Adding the activity to the file chooser.
         */
        attached: function () {
            this.$.fileChooser.activity = this.activity;
            this.fire('techniqueloaded');
        },

        /**
         * It is called from the Apply() method of cmp-doe, it sets the technique options in the plugin configuration.
         * @param {module:DS/JSCMM/SMAJSCMMExtensionConfig.SMAJSCMMExtensionConfig} pluginExtensionConfig - selected plugin configuration
         */
        Apply: function (pluginExtensionConfig) {
            console.log('In Apply() of cmp-doe-data-file..');
            // Set descriptor values with attribute settings
            if (null === pluginExtensionConfig)
                { return false; }
            if (pluginExtensionConfig.getPropertyByName('Technique Options')) {
                var properties = pluginExtensionConfig.getPropertyByName('Technique Options').getProperties();
                for (var i = 0; i < properties.length; i++){
                    switch (properties[i].getName()) {
                    case 'File':
                        properties[i].setValue(this.techniqueOptions.dataHandlerconfigString);
                        properties[i].setValueKey('<![CDATA]>');
                        break;
                    case 'Use Header Row':
                        properties[i].setValue(this.techniqueOptions.useHeaderRow);
                        break;
                    case 'Header Row':
                        properties[i].setValue(this.techniqueOptions.headerRow);
                        break;
                    case 'Data Starts on Row':
                        properties[i].setValue(this.techniqueOptions.dataRow);
                    }
                }
            }
        },

        /**
         * Updates the technique options as retrieved from the properties while updating UI in parent element cmp-doe
         * @param {Array} properties - An array of technique options or [SMAJSCMMProperty]{@link module:DS/JSCMM/SMAJSCMMProperty.SMAJSCMMProperty} objects
         */
        updateTechniqueOptions: function (properties) {
            for (var i = 0; i < properties.length; i++) {
                switch (properties[i].getName()) {
                    case 'File':
                        var configString = properties[i].getValue();
                        if (configString !== undefined && configString !== '') {
                            this.set('techniqueOptions.dataHandlerconfigString', configString);
                            var xmlConfigString = '<root>' + configString + '</root>';
                            var xmlStr = SMAJSCMMUtils.parseXML(xmlConfigString);
                            var handlerType = xmlStr.documentElement.getElementsByTagName('handlerType')[0].firstChild.nodeValue;
                            if (handlerType == 'com.dassault_systemes.sma.datahandler.DataHandlerPLM') {
                                this.index = 0;
                                this.$.fileChooser.activity = this.activity;
                                this.set('$.fileChooser.datahandlerconfigstring', this.techniqueOptions.dataHandlerconfigString);
                            } else if (handlerType == 'com.dassault_systemes.sma.datahandler.DataHandlerFile') {
                                this.index = 1;
                                this.set('$.runtimefilechooser.datahandlerconfigstring', this.techniqueOptions.dataHandlerconfigString);
                            }
                        }
                        break;
                    case 'Use Header Row':
                        this.set('techniqueOptions.useHeaderRow', properties[i].getValue());
                        break;
                    case 'Header Row':
                        this.set('techniqueOptions.headerRow', properties[i].getValue());
                        break;
                    case 'Data Starts on Row':
                        this.set('techniqueOptions.dataRow', properties[i].getValue());
                }
            }
        },

        /**
         * Triggered when the file is selected in file chooser
         */
        _fileSelectEvent: function() {
            this.techniqueOptions.dataHandlerconfigString = this.$.fileChooser.datahandlerconfigstring;
            var that = this;
              var file = that.$.fileChooser.getSelectedFile();
              if (file) {
                  that.$.fileChooser.addEventListener('filedownloaded', function (e) {
                      that.readFile(e.target._fileObj);
                  });
              }
              that.$.fileChooser.getSelectedFileDownloaded();
        },

        /**
         * Reads the file content as a text from the given blob
         * @param {Object} blob - Blob of the selected file
         */
        readFile: function(blob) {
            var reader = new FileReader();
            var that = this;
            reader.onloadend = function(e) {
                that.fileContent = reader.result;
                that.fire(EVENT.DATFILECONTENTREADY, that);
            };
            reader.readAsText(blob);
        },

        /**
         * Scans the parameters from the selected file content, renders a table with the scanned parameters
         */
        onScanParams: function() {
            var parameters, arrayData;
            if (this.fileContent != null && this.fileContent != '' && this.fileContent != undefined) {
                arrayData = this.fileContent.split('\n');
                if (this.techniqueOptions.useHeaderRow && (this.techniqueOptions.headerRow > 0)) {
                    parameters = arrayData[this.techniqueOptions.headerRow-1].split(/[ \t,]+/);
                }
                this.DOM(this.$.scannedparamstable).addClass('is-visible');
                this.$.scannedparamstable.removeRows();
                this.$.scannedparamstable.setColumns(this.parameterColumns, this.tablewidth, this.tableheight);
                var selfchildparameters, allparameters;
                if (this.activity !== null && this.activity !== undefined) {
                    selfchildparameters = SMAJSCMMParameterUtils.getPotentialParameters(this.activity);
                    allparameters = selfchildparameters.self.concat(selfchildparameters.children);
                }
                for (var i = 0; i < parameters.length; i++) {
                    var newParam = parameters[i].trim();
                    if (newParam != '' && newParam != undefined) {
                        var param = SMAProcDesignDriverDataHandler.findParameterByName(newParam, allparameters);
                        if (param == null || param == undefined || param == '') {
                            var modeIcon = this.resolveUrl('../../SMAProcWebAuthoringUtils/assets/images/I_SMASedInputParameter.png');
                            var rowcontent = {
                                    Name : {
                                        value : newParam,
                                        editable : false
                                    },
                                    col_2 : {
                                        value : 'false'
                                    },
                                    Mode : {
                                        value: 'In',
                                        icon: modeIcon
                                    }
                            };
                            var row = this.$.scannedparamstable.insertRow(rowcontent, -1);
                        }
                    }
                }
            }
        },

        /**
         * Populates the default values in the table for the factors on parameter selection,
         * also update the data structure for the parameters updatedFactors
         * @param {Object} cellinfo - The corresponding cell information of the selected factor to be updated
         * @param {String} paramName - Name of the parameter
         */
        populateDefaults: function(cellinfo, paramName) {

            if (SMAProcDesignDriverFactorImpl.findFactor(paramName, this.updatedFactors) < 0) {
                var factor = {
                        Name: paramName,
                        Column: 0
                };
                factor['cellinfo'] = cellinfo;
                this.push('updatedFactors', factor);
            }
            return this.updatedFactors;
        },

        /**
         * Whenever a scanned parameter is selected, it needs to be added to the temporary parameter container
         * @param {Object} cellinfo - Information about the selected row
         */
        _addParameter: function(event) {
            var cellinfo = event.detail.cellInfo;
            //cellinfo is passed as an argument
            this.fire(EVENT.ONPARAMSELECTED, {cellinfo: cellinfo});
        },

        /**
         * Updates the index, if its document input or runtime input
         */
        updateFileType: function() {
            this.index = this.$.filetype.selectedindex;
        },

        /**
         * Renders the document input file section in the UI
         * @param {Number} index - Selected index of the radio button
         */
        _computeClass: function (index) {
            return this.tokenList({ 'is-visible': index == 0 }) + 'command-pane ' + this.tokenList({ 'is-visible': index == 0 });
        },

        /**
         * Renders the runtime input file section in the UI
         * @param {Number} index - Selected index of the radio button
         */
        _computeClass2: function (index) {
            return this.tokenList({ 'is-visible': index == 1 }) + 'command-pane ' + this.tokenList({ 'is-visible': index == 1 });
        },

        tokenList: function(obj) {
                        var key, pieces = [];
            for (var key in obj) {
                if (obj[key]) {
                    pieces.push(key);
                }
            }
            return pieces.join(' ');
        }
    });
});

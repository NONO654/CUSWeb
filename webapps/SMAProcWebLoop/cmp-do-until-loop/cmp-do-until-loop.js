/*--------------------------------------------------------------------
[cmp-do-until-loop JS Document]

Project:        cmp
Version:        1.0
Last change:    Thu, 19 Nov 2015 20:03:20 GMT
Assigned to:    Vishakha Motwani
Description:    Do until loop component <cmp-do-until-loop>
---------------------------------------------------------------------*/
/* global Polymer */
/* jshint camelcase:false*/
/**
    @module SMAProcWebLoop
    @submodule cmp-do-until-loop
    @class cmp-do-until-loop

    @description
        This handles the code behind the 'do-until' loop component.
        It is a part of the <cmp-loop> component

    @example
        <cmp-do-until-loop id="dountilloop" name="dountilloop"></cmp-do-until-loop>

 */
(function (window) {
    'use strict';
    require(['DS/SMAProcWebCommonControls/ParameterChooser']);
    /**
        @class cmp-do-until-loop
    **/
    Polymer({
        is: 'cmp-do-until-loop',
        properties: {
            //Variables
            isItrEnabled: {
                type: Boolean,
                value: true
            },
            iterations: {
                type: Number,
                value: 10
            },
            lhsParam: {
                type: Object,
                value: function () {
                    return {};
                }
            },
            rows: {
                type: Array,
                value: function () {
                    return [];
                }
            },
            selectedItem: {
                type: Object,
                value: function () {
                    return {};
                }
            },
            tableheight: {
                type: Number,
                value: 160
            },
            tablewidth: {
                type: Number,
                value: 540
            },
            columns: {
                type: Array,
                value: function () {
                    return  [
                            {
                                name: '',
                                key: 'col_1',
                                type: 'dropdown',
                                width_percent: '15',
                                options: [
                                    { value: 'AND' },
                                    { value: 'OR' }
                                ]
                            },
                            {
                                name: '(',
                                key: 'col_2',
                                type: 'dropdown',
                                width_percent: '12',
                                options: [
                                    { value: '(' },
                                    { value: '((' }
                                ]
                            },
                            {
                                name: '',
                                key: 'col_3',
                                type: 'text',
                                width_percent: 'auto'
                            },
                            {
                                name: '',
                                key: 'col_4',
                                type: 'dropdown',
                                width_percent: '12',
                                options: [
                                    { value: '==' },
                                    { value: '!=' },
                                    { value: '<' },
                                    { value: '<=' },
                                    { value: '>' },
                                    { value: '>=' }
                                ]
                            },
                            {
                                name: '',
                                key: 'col_5',
                                type: 'text',
                                width_percent: 'auto'
                            },
                            {
                                name: ')',
                                key: 'col_6',
                                type: 'dropdown',
                                width_percent: '13',
                                options: [
                                    { value: ')' },
                                    { value: '))' }
                                ]
                            }
                         ];
                },
                notify: true
            }
        },
        /**
         * The ready event occurs when the DOM  has been loaded
         * @method ready
         */
        ready: function () {
            console.log('Ready Do While Loop...');
            this.ExtensionEditorImpl = this;
            var that = this;
            this.$.sptable.setColumns(this.columns, this.tablewidth, this.tableheight);
            this.$.sptable.addEventListener('onCellModified', function (event) {
                var cellinfo = event.detail.cellInfo;
                // when checkbox of a row is checked, modify other cells in that row
                if (cellinfo.cellType === 'dropdown') {
                    that.rows[cellinfo.rowIndex].setValue(cellinfo.value, cellinfo.colIndex);
                }
                console.log('sp-tree-table onCellModified handler');
                console.dir(cellinfo);
            });
            this.$.sptable.addEventListener('onRowMoved', function (event) {
                var rowinfo = event.detail.rowInfo;
                console.log('sp-tree-table onRowMoved handler, from ' + event.detail.oldPosition + ' to ' + event.detail.newPosition);
                console.dir(rowinfo);
                if (event.detail.newPosition == 0) {
                    that.rows[event.detail.newPosition].setValue(rowinfo.cells[0].value, 0);
                }
            });
        },

        //Event Handlers
        /**
         * Triggered when a parameter from the first parameter choosed will be selected
         * @event onSelectLHSParam
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         * @param {object} sender Reference to the node that declared the handler
         *
         */
        onSelectLHSParam: function (event, detail) {
            if (this.$.vardiv.getSelectedParameter().index >= 0) {
                //Enabling elements which can now be edited as condition parameter is selected
                this.$.condition.disabled = false;
                this.$.rhsparam.disabled = false;
                this.$.add.disabled =  false;
            }
            if (detail && detail.parameter) {
                var name = detail.parameter.getName();
                if (name && name.length > 0) {
                    this.lhsParam = {
                        index: detail.index,
                        name: name
                    };
                }
            }
        },
        initializeChoosers: function (act) {
            if (act && this.activity === undefined) {
                this.activity = act;
                this.$.vardiv.setDataContainer(this.activity);
                this.$.rhsparam.setDataContainer(this.activity);
            }
        },
        /**
         * Triggered on clicking the '+' button, adds the constant/parameter to values list
         * @event onAdd
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         * @param {object} sender Reference to the node that declared the handler
         *
         */
        onAddRow: function () {
            var that = this;
            var nrows = this.$.sptable.numRows();
            var rowdata = '';
            var rhsFullValue = this.$.rhsparam.value;
            var rhsValue, rhsType;
            if (rhsFullValue) {
                rhsType = rhsFullValue.charAt(0);
                rhsValue = rhsFullValue.substring(1);
            }
            if (rhsValue) {
                var lhsvalue = this.lhsParam.name;
                var condition = this.$.condition.value;
                var rowdata = {
                    col_1: { value: '' },
                    col_2: { value: '' },
                    col_3: { value: lhsvalue },
                    col_4: { value: condition },
                    col_5: { value: rhsValue },
                    col_6: { value: '' },
                    rowdata: { type: rhsType }
                };
                //Creating Value Array to set in the Array Property
                var valueArray = [
                    '',
                    '',
                    lhsvalue,
                    condition,
                    rhsValue,
                    '',
                    rhsType
                ];
                if (nrows > 0) {
                    rowdata.col_1.value = 'AND';
                    valueArray[0] = 'AND';
                }
                var position = this.$.sptable.getSelectedRowIndex();
                this.$.sptable.insertRow(rowdata, position);

                require([
                    'DS/SMAProcWebCMMUtils/SMAJSCMMUtils',
                    'DS/JSCMM/SMAJSCMMProperty'
                ], function (SMAJSCMMUtils, SMAJSCMMProperty) {
                    var tempProperty = new SMAJSCMMProperty();
                    tempProperty.setName('condition_' + that.rows.length);
                    tempProperty.setStructure(SMAJSCMMUtils.Structure.client.Array);
                    tempProperty.setDataType(SMAJSCMMUtils.DataType.client.String);
                    tempProperty.setDimensions('[' + valueArray.length + ']');
                    tempProperty.setValues(valueArray);
                    //Inserts in an array
                    that.rows.push(tempProperty);
                    that.$.remove.disabled = false;
                    that.$.moveup.disabled = false;
                    that.$.movedown.disabled = false;
                    console.log('Row added.');
                });
            } else {
                require(['DS/' + 'SMAProcWebAuthoringUtils/SMAProcWebAuthoringServices'], function(SMAProcWebAuthoringServices) {
                    SMAProcWebAuthoringServices.displayClosableMessages('error', ['ParameterSelect.error'], true);
                });
            }
        },
        /**
         * Triggered on clicking the '-' button, removes the selected
         * constant/parameter to values list
         * @event onRemoveRow
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         * @param {object} sender Reference to the node that declared the handler
         *
         */
        onRemoveRow: function () {
            var index = this.$.sptable.getSelectedRowIndex();
            this.$.sptable.removeRow();
            this.rows.splice(index, 1);
            if (this.rows.length <= 0) {
                this.$.remove.disabled = true;
                this.$.moveup.disabled = true;
                this.$.movedown.disabled = true;
            }
        },
        /**
         * Triggered on clicking the up arrow button, moves the selected
         * constant/parameter up by a single place in the values list
         * @event onMoveRowUp
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         * @param {object} sender Reference to the node that declared the handler
         *
         */
        onMoveRowUp: function () {
            var index = this.$.sptable.getSelectedRowIndex();
            console.log('Index before moving up: ' + index);
            if (index > 0) {
                //Decrements the index of the selected value in the array
                //to move it up in the list
                var newIndex = index - 1;
                this.rows.splice(newIndex, 0, this.rows.splice(index, 1)[0]);
                if (newIndex == 0) {
                    this.$.sptable.setCellContent(index, 0, {value: ''});
                    this.rows[0].setValue('', 0);
                }
                this.$.sptable.moveUp();
            }
        },
        /**
         * Triggered on clicking the down arrow button, moves the selected
         * constant/parameter down by a single place in the values list
         * @event onMoveRowDown
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         * @param {object} sender Reference to the node that declared the handler
         *
         */
        onMoveRowDown: function () {
            var index = this.$.sptable.getSelectedRowIndex();
            console.log('Index before moving down: ' + index);
            if (index >= 0 && index < this.rows.length - 1) {
                //Increments the index of the selected value in the array
                //to move it down in the list
                var newIndex = index + 1;
                this.$.sptable.moveDown();
                this.rows.splice(newIndex, 0, this.rows.splice(index, 1)[0]);
                if (index == 0) {
                     var row = this.$.sptable.getRow(newIndex);
                     var dropdown = row.getChildren()[0].getChildren()[0];
                     this.rows[0].setValue(dropdown.value, 0);
                }
            }
        },
        /**
         * Triggered on clicking a value in the values list
         * @event onSelect
         *
         * @param {click} event Triggered on selecting an item from the dropdown
         * @param {object} detail Attribute of the event object
         * @param {object} sender Reference to the node that declared the handler
         *
         */
        onSelect: function (event, detail, sender) {
            var itemsDOM = Polymer.dom(this.root).querySelectorAll('.paramitem');
            [].forEach.call(itemsDOM, function (itemDOM) {
                Polymer.dom(itemDOM).classList.remove('selected');
            }, this);
            //Clear any previous selections
            this.set('selectedItem.selected', false);
            //Set the selection
            //this.selectedItem = sender.templateInstance.model.param;
            this.set('selectedItem.selected', true);
            Polymer.dom(sender).classList.add('selected');
            console.log('onSelectVar sender ', sender);
            console.log('onSelectVar item ', this.selectedItem);
        },
        /**
         * Triggered on clicking the checkbox for maximum number of iterations
         * @event onIterationEnable
         *
         * @param {click} event Triggered on clicking the checkbox
         * @param {object} detail Attribute of the event object
         * @param {object} sender Reference to the node that declared the handler
         *
         */
        onIterationEnable: function () {
            this.$.iterations.readonly = !this.isItrEnabled;
        },
        /**
         * Updates the user interface with the information received from the web service.
         * @method UpdateUI
         */
        UpdateUI: function (activity, stepId, extensionConfig) {
            console.log('Inside Do Until/While Loop adapter UpdateUI');
            this.activity = activity;
            if (this.activity) {
                this.$.vardiv.setDataContainer(this.activity);
                this.$.rhsparam.setDataContainer(this.activity);
            }
            if (extensionConfig) {
                var properties = extensionConfig.getProperties();
                if (null != properties) {
                    var prop;
                    prop = extensionConfig.getPropertyByName('conditions');
                    var aggprops = prop.getProperties();
                    this.rows = aggprops.slice();

                  //Populating the rows
                    for (var i = 0; i < this.rows.length; i++) {
                        var values = this.rows[i].getValues();
                        var rowdata = {
                            col_1: { value: values[0] !== undefined && values[0] !== null ? values[0] : '' },
                            col_2: { value: values[1] !== undefined && values[1] !== null ? values[1] : '' },
                            col_3: { value: values[2] !== undefined && values[2] !== null ? values[2] : '' },
                            col_4: { value: values[3] !== undefined && values[3] !== null ? values[3] : '' },
                            col_5: { value: values[4] !== undefined && values[4] !== null ? values[4] : '' },
                            col_6: { value: values[5] !== undefined && values[5] !== null ? values[5] : '' },
                            rowdata: { type: values[6] !== undefined && values[6] !== null ? values[6] : '' }
                        };
                        this.$.sptable.insertRow(rowdata, i);
                        console.log('New row added');
                    }
                    if (this.rows.length <= 0) {
                        //Disabling elements which cannot be edited unless condition parameter is selected
                        this.$.remove.disabled = true;
                        this.$.moveup.disabled = true;
                        this.$.movedown.disabled = true;
                    } else if (this.rows.length > 0) {
                        this.$.remove.disabled = false;
                        this.$.moveup.disabled = false;
                        this.$.movedown.disabled = false;
                    }

                    prop = extensionConfig.getPropertyByName('maxIterBoolean');
                    if (prop.getValue() == false) {
                        this.isItrEnabled = false;
                        this.$.iterations.readonly = true;
                    }

                    prop = extensionConfig.getPropertyByName('maxIterations');
                    this.iterations = prop.getValue();
                }
            }
        },
        /**
         * Receives the values from the user interface and passes on to the web service.
         * @method Apply
         */
        Apply: function (extensionConfig) {
            console.log('Inside Do Until/While Loop editor Apply');
            if (null === extensionConfig)
                { return false; }
            var prop;
            prop = extensionConfig.getPropertyByName('conditions');
            prop.setProperties(this.rows);

            prop = extensionConfig.getPropertyByName('maxIterBoolean');
            prop.setValue(this.isItrEnabled);

            prop = extensionConfig.getPropertyByName('maxIterations');
            prop.setValue(this.iterations);
        }
    });
}(this));

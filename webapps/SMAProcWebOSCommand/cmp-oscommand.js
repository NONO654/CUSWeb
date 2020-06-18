require([
    'DS/SMAProcWebCMMUtils/SMAJSCMMUtils',
    'DS/SMAProcWebCMMUtils/SMAJSCMMAuthoringUtils',
    'DS/Usage/TrackerAPI',
    'DS/SMAProcWebContents/ContentService',
    'DS/SMAProcWebContents/ParameterChooser'
    //, 'DS/SMAProcWebCommonControls/HelpIcon'
    //'DS/SMAProcWebCommonControls/ParameterChooser'
], function (SMAJSCMMUtils, SMAJSCMMAuthoringUtils, TrackerAPI, ContentService) {
'use strict';
    Polymer({
    is: 'cmp-oscommand',
    properties: {
        ExtensionEditorImpl: {  },

       // extension config properties
       _commandType:     { type: String,  value: ''},
       _scriptText:      { type: String,  value: '', observer: '_scriptTextObserver' },
       _intpName:        { type: String,  value: '' },
       _intpCommand:     { type: String,  value: '' },
       _scriptExtension: { type: String,  value: '' },
       _intpArgument:    { type: String,  value: '', observer: '_intpArgumentObserver' },
       _scriptArgument:  { type: String,  value: '', observer: '_scriptArgumentObserver' },
       _command:         { type: String,  value: '', observer: '_commandObserver' },
       _maxrcSuccess:    { type: String,  value: '' },
       _hostname:        { type: String,  value: '' },
       _unix:            { type: Boolean, value: false, observer: '_unixObserver' },
       _stdOutVal:       { type: Boolean, value: false },
       _stdErrVal:       { type: Boolean, value: true  },
       _logStderr:       { type: Boolean, value: true  },
       _logStdout:       { type: Boolean, value: false },
       _linesToLog:      { type: Number,  value: 21   },
       _waitFile:        { type: String,  value: ''  },
       _waitString:      { type: String,  value: '' },
       _waitDelay:       { type: Number,  value: 0 },
       _makeJob:         { type: Boolean, value: true  },
       _retvalParam:     { type: String,  value: '', observer: '_retvalParamObserver' },
       _oscmd_env_vars:  { type: Array,   value: function () { return []; } },

       _PredefinedCommandOptions: { type: String,  value: '' },
       _releaseConcurrency:       { type: Boolean, value: false  },
       _scriptContentType: { type: String,
           value: '<rawFN></rawFN><toOption>10</toOption><del>N</del><type>text/plain</type><rwEnc>(Automatic Local)</rwEnc><rwLend>xxxx</rwLend><dataEnc></dataEnc>'
       },

       // local properties
       _activity:        { value: null },
       _extensionConfig: { value: null },
       _appIndex:        { type: Number,  value: 0,     observer: '_connectorObserver'},
       _selectedConn:    { type: Object,  value: function () { return { }; } },
       _initialConn:     { type: Object,  value: function () { return { }; } },
       _cmdIndex:        { type: Number,  value: 0,     observer: '_cmdIndexObserver' },
       _shellIndex:      { type: Number,  value: 0,     observer: '_shellIndexObserver' },
       _lineEnding:      { type: Number,  value: 1,     observer: '_lineEndingObserver' },
       _returnCode:      { type: Boolean, value: false, observer: '_returnCodeObserver' },
       _waitForFile:     { type: Boolean, value: false, observer: '_waitFileObserver'  },
       _selectedEnvVar:  { type: Object,  value: function () { return { }; } },
       _parameters:      { type: Array,   value: function () { return []; } },
       _shellData:       { type: Array,
            value: function () {
                return [
                    { cmdArgs: '',   scrArgs: '', lineEndIndex: 0, scriptContent: '', shell: 'sh',      scrExt: '.sh' }, // Bourne Shell
                    { cmdArgs: '',   scrArgs: '', lineEndIndex: 0, scriptContent: '', shell: 'csh',     scrExt: '.sh' }, // C Shell
                    { cmdArgs: '',   scrArgs: '', lineEndIndex: 0, scriptContent: '', shell: 'ksh',     scrExt: '.sh' }, // K Shell
                    { cmdArgs: '',   scrArgs: '', lineEndIndex: 0, scriptContent: '', shell: 'bash',    scrExt: '.sh' }, // Bash Shell
                    { cmdArgs: '/C', scrArgs: '', lineEndIndex: 0, scriptContent: '', shell: 'cmd.exe', scrExt: '.bat'}  // Windows Batch
                ];
            }
        },
        _tableColumns:   { type: Object,
            value: function () {
                return {columns: [
                    { name: 'Include',     key: 'includecol', type: 'checkbox', width_percent: '10%' },
                    { name: 'Name',        key: 'namecol',    type: 'text',     width_percent: '25%',  editable: 'false' },
                    { name: 'Value',       key: 'valcol',     type: 'text',     width_percent: '15%',  editable: 'true' },
                    { name: 'Description', key: 'desccol',    type: 'text',     width_percent: 'auto', editable: 'true' }
                ]};
            }
        },
        _connectors: { type: Array,
            value: function () {
                return [];
            }
        },
        _cmdType: {
            value:  [ 'Command', 'Bourne Shell', 'C Shell', 'K Shell', 'Bash', 'Windows Batch', 'Predefined Applications' ]
        },
        _lineEndType: { 
            value: [ 'Default', 'Local', 'Unix', 'Windows' ]
        }
    },

// parameter selection
    addParamToCommand: function (event, detail) {
        if (detail.parameter) {
            var name = detail.parameter.getName();
            if (name && name.length > 0) {
                if (this._command.length === 0) {
                    this.set('_command', '${PARAMETER[' + name + ']} ');
                } else {
                    var startpos = this.$.cmd.selectionStart;
                    var endpos   = this.$.cmd.selectionEnd;
                    if (startpos >= 0 && endpos >= 0) {
                        this.set('_command', this._command.slice(0, startpos) + '${PARAMETER[' + name + ']} ' + this._command.slice(endpos));
                    } else {
                        this.set('_command', this._command.concat(' ${PARAMETER[' + name + ']} '));
                    }
                }
            }
        }
        this.updateCommandPreview();
    },

// editor
    onClearEditor: function () {
        this.set('_scriptText', '');
    },
    loadFile: function (event) {
        var fn = event.target.files[0];
        var self = this;
        if (fn) {
            var reader = new FileReader();
            reader.onload = function (evt) {
                if (self._scriptText.length === 0) {
                    self.set('_scriptText', evt.target.result);
                } else {
                    var startpos = self.$.editortext.selectionStart;
                    var endpos   = self.$.editortext.selectionEnd;
                    if (startpos >= 0 && endpos >= 0) {
                        self._scriptText = self._scriptText.slice(0, startpos) + evt.target.result + self._scriptText.slice(endpos);
                    } else {
                        self._scriptText = self._scriptText.concat(' ${PARAMETER[' + name + ']} ');
                    }
                }
            };
            reader.readAsText(fn);
        } else {
            alert('Failed to load ' + fn.name);
        }
    },
    addParamToScript: function (event, detail) {
        if (detail.parameter) {
            var name = detail.parameter.getName();
            if (name && name.length > 0) {
                if (this._scriptText.length == 0) {
                    this.set('_scriptText', '${PARAMETER[' + name + ']} ');
                } else {
                    var startpos = this.$.editortext.selectionStart;
                    var endpos   = this.$.editortext.selectionEnd;
                    if (startpos >= 0 && endpos >= 0) {
                        this.set('_scriptText', this._scriptText.slice(0, startpos) + '${PARAMETER[' + name + ']} ' + this._scriptText.slice(endpos));
                    } else {
                        this.set('_scriptText',  this._scriptText.concat(' ${PARAMETER[' + name + ']} '));
                    }
                }
            }
        }
    },

// environment variables
    onToggleEnvVar: function () {
        this._showEnvVarPanel = !this._showEnvVarPanel;
        var icon = this.$.envToggleIcon;
        if (this._showEnvVarPanel) {
            icon.classList.remove('fonticon-right-dir');
            icon.classList.add('fonticon-down-dir');
        } else {
            icon.classList.remove('fonticon-down-dir');
            icon.classList.add('fonticon-right-dir');
        }
    },

    onSelectVar: function (event) {
        this._clearEnvVarSelection();

        //Set the selection
        if (event.currentTarget) {
            var itemsDOM = Polymer.dom(this.root).querySelectorAll('.envVarItem');
            var indx = itemsDOM.indexOf(event.currentTarget);
            if (indx != undefined && indx >= 0) {
                this.set('_selectedEnvVar', event.currentTarget);
            }
            Polymer.dom(event.currentTarget).classList.add('selected');
        }
    },
      _clearEnvVarSelection: function() {
          var itemsDOM = Polymer.dom(this.root).querySelectorAll('.envVarItem');
          [].forEach.call(itemsDOM, function (itemDOM) {
              Polymer.dom(itemDOM).classList.remove('selected');
          }, this);
          if (this._selectedEnvVar) {
              this.set('_selectedEnvVar', null);
          }
      },
      onAddVar: function () {
          this.push('_oscmd_env_vars', { name: '', value: '' });
      },
      onRemoveVar: function () {
          if (this._selectedEnvVar) {
              var itemsDOM = Polymer.dom(this.root).querySelectorAll('.envVarItem');
              var indx = itemsDOM.indexOf(this._selectedEnvVar);
              if (indx >= 0) {
                  this.splice('_oscmd_env_vars', indx, 1);
              }
          }
          this.set('_selectedEnvVar', null);
          this._clearEnvVarSelection();
      },
      onMoveVarUp: function () {
          if (this._selectedEnvVar) {
              var itemsDOM = Polymer.dom(this.root).querySelectorAll('.envVarItem');
              var index = itemsDOM.indexOf(this._selectedEnvVar);
              if (index > 0) {
                  var newIndex = index - 1;
                  this.splice('_oscmd_env_vars', newIndex, 0, this.splice('_oscmd_env_vars', index, 1)[0]);
              }
          }
      },
      onMoveVarDown: function () {
          if (this._selectedEnvVar) {
              var itemsDOM = Polymer.dom(this.root).querySelectorAll('.envVarItem');
              var index = itemsDOM.indexOf(this._selectedEnvVar);
              if (index >= 0 && index < this._oscmd_env_vars.length - 1) {
                  var newIndex = index + 1;
                  this.splice('_oscmd_env_vars', newIndex, 0, this.splice('_oscmd_env_vars', index, 1)[0]);
              }
          }
      },
      setParamAsEnvVar: function (event, detail) {
          var num = this._oscmd_env_vars.length;
          if (this._selectedEnvVar) {
              var itemsDOM = Polymer.dom(this.root).querySelectorAll('.envVarItem');
              var index = itemsDOM.indexOf(this._selectedEnvVar);
              if (index !== undefined && index !== null) {
                  if (detail.parameter) {
                      var name = detail.parameter.getName();
                      if (name && name.length > 0 && index >= 0 && index < num) {
                          this.set('_oscmd_env_vars' + ('.' + index) + '.value', '${PARAMETER[' + name + ']}');
                      }
                  }
              }
          }
      },
      setExitCodeParam: function (event, detail) {
          if (detail.parameter) {
              var name = detail.parameter.getName();
              if (name && name.length > 0) {
                  this.set('_retvalParam',  name);
              }
          }
      },


// Execution Options tab
      onToggleFailedPanel: function () {
          this._showFailedPanel = !this._showFailedPanel;
          var icon = this.$.failedToggleIcon;
          if (this._showFailedPanel) {
              icon.classList.remove('fonticon-right-dir');
              icon.classList.add('fonticon-down-dir');
          } else {
              icon.classList.remove('fonticon-down-dir');
              icon.classList.add('fonticon-right-dir');
          }
      },
      onToggleLogPanel: function () {
          this._showLogPanel = !this._showLogPanel;
          var icon = this.$.logToggleIcon;
          if (this._showLogPanel) {
              icon.classList.remove('fonticon-right-dir');
              icon.classList.add('fonticon-down-dir');
          } else {
              icon.classList.remove('fonticon-down-dir');
              icon.classList.add('fonticon-right-dir');
          }
      },
      onToggleWaitPanel: function () {
          this._showWaitPanel = !this._showWaitPanel;
          var icon = this.$.waitToggleIcon;
          if (this._showWaitPanel) {
              icon.classList.remove('fonticon-right-dir');
              icon.classList.add('fonticon-down-dir');
          } else {
              icon.classList.remove('fonticon-down-dir');
              icon.classList.add('fonticon-right-dir');
          }
      },
      onToggleExeEnvPanel: function () {
          this._showExeEnvPanel = !this._showExeEnvPanel;
          var icon = this.$.exeEnvToggleIcon;
          if (this._showExeEnvPanel) {
              icon.classList.remove('fonticon-right-dir');
              icon.classList.add('fonticon-down-dir');
          } else {
              icon.classList.remove('fonticon-down-dir');
              icon.classList.add('fonticon-right-dir');
          }
      },
      onLogChange: function () {
          if (this._logStderr || this._logStdout) {
              this.set('$.logLines.readonly', false);
          } else {
              this.set('$.logLines.readonly', true);
          }
      },

// lifecycle methods
    ready: function () {
        console.log('OS Command Ready');
        this.set('ExtensionEditorImpl', this);
        this._showEnvVarPanel = false;
        this._showFailedPanel = false;
        this._showLogPanel = false;
        this._showWaitPanel = false;
        this._showExeEnvPanel = false;

        this.$.types.selectedIndex = 0;

        if (this._cmdIndex > 0) {
            this.$.lineEndings.selectedIndex = this._shellData[this._shellIndex].lineEndIndex;
        }
        this.$.logLines.readonly = true;
        if (this._logStderr || this._logStdout) {
            this.$.logLines.readonly = false;
        }
        this.$.rcVal.readonly = true;
        if (this._returnCode) {
            this.$.rcVal.readonly = false;
        }
        this.$.waitFilename.readonly = true;
        this.$.findString.readonly = true;
        this.$.waitDelay.readonly = true;
        if (this._waitForFile) {
            this.$.waitFilename.readonly = false;
            this.$.findString.readonly = false;
            this.$.waitDelay.readonly = false;
        }
        this.$.xwinDisplay.readonly = true;
        if (this._unix !== null && this._unix === true) {
            this.$.xwinDisplay.readonly = false;
        }

        var tablewidth=585;
        var tableheight=200;
        this.$.optionstable.setColumns(this._tableColumns.columns, tablewidth, tableheight);

        // populate drop downs here, template binding not working on IE
        var i, sel;

        // command types
        sel = this.$.types;
        for (i = 0; i < this._cmdType.length; ++i) {
            var option = document.createElement('option');
            option.text = this._cmdType[i];
            option.value = i;
            sel.add(option);
        }
        // line endings
        sel = this.$.lineEndings;
        for (i = 0; i < this._lineEndType.length; ++i) {
            var option = document.createElement('option');
            option.text = this._lineEndType[i];
            option.value = i;
            sel.add(option);
        }

     // handlers
        var comp = this;
        this.$.types.onchange = function () {
            comp.set('_cmdIndex', comp.$.types.selectedIndex);
        };
        this.$.lineEndings.onchange = function () {
            if (comp._shellIndex !== undefined && comp._shellIndex >= 0) {
                comp.set('_lineEnding',  comp.$.lineEndings.selectedIndex);
            }
        };
        this.$.apps.onchange = function () {
            var indx = comp.$.apps.selectedIndex;
            comp.set('_selectedConn', {});
            if (indx > 0) {
                comp.set('_appIndex', indx - 1);
                comp.set('_selectedConn', comp._connectors[comp._appIndex]);
            }
            comp.updateCommandPreview();
        };

        this.$.optionstable.addEventListener('onCellModified', function () {
            comp.updateCommandPreview();
        });

        this.fire('component-ready');
    },

    attached: function () {
        console.log('OS Command attached');
    },

// Assign properties
    UpdateUI: function (act, step, extensionConfig) {
        this._initializing = true;
        this.set('_activity', act);
        this.set('_extensionConfig', extensionConfig);
        if (this._activity) {
            var service = new ContentService(this._activity);
            [this.$.cmdParam, this.$.scriptParam, this.$.envParam, this.$.exitCodeParam].forEach(function(el){
                el.setContentService(service);
                el.setDataContainer(this._activity);
            }.bind(this));
        }
        var timer = TrackerAPI.getTimer(this.tagName.toLocaleLowerCase()+'Tracker', {appID:'SIMPRCW_AP'});
        timer.stop();
        var props = extensionConfig.getProperties();
        for (var ind = 0; ind < props.length; ++ind) {
            var prop = props[ind];
            if (prop !== undefined) {
                var name = prop.getName();
                switch (name) {
                case 'maxrcSuccess': {
                        var str = '';
                        var aggprops = prop.getProperties();
                        if (aggprops) {
                            var nprops = aggprops.length;
                            for (var p = 0; p < nprops; ++p) {
                                var ranges = aggprops[p].getValues();
                                if (ranges != undefined && ranges !== 'undefined') {
                                    var len = ranges.length;
                                    for (var i = 0; i < len; ++i) {
                                        var val = ranges[i];
                                        if (val != undefined && val !== 'undefined') {
                                            str = str.concat(val);
                                            if (i < len - 1) {
                                                str = str.concat(',');
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        this.set('_maxrcSuccess', str);
                        if (str.length > 0) {
                            this.set('_returnCode', true);
                        }
                        break;
                    }
                case 'oscmd_env_vars': {
                        this.set('_oscmd_env_vars', []);
                        var len = prop.getNumberOfValues();
                        for (var i = 0; i < len; ++i) {
                            var val = prop.getValue(i);
                            if (val !== undefined && val !== 'undefined') {
                                var evar = val.split('=');
                                if (evar.length === 2) {
                                    var evarobj = {};
                                    evarobj.name = evar[0];
                                    evarobj.value = evar[1];
                                    this.push('_oscmd_env_vars', evarobj);
                                }
                            }
                        }
                        break;
                    }
                case 'commandType': {
                        var pv = prop.getValue();
                        if (pv != undefined && pv != null && pv !== 'undefined') {
                                this.set('_' + name, pv);
                        }
                        break;
                    }
                default: {
                        if (extensionConfig.isScalarProperty(name)) {
                            var pv = prop.getValue();
                            if (pv != undefined && pv != null && pv !== 'undefined') {
                                this.set('_' + name, pv);
                            }
                        } else if (prop._data) {
                            console.log('WARNING: cmp-oscommand.UpdateUI unhandled property');
                        }
                    }
                }
            }
        }
        this.updateLocals();
        this.updateCommandPreview();
        this._initializing = undefined;
        return true;
    },

// Commit properties
    Apply: function () {
        // Set descriptor values with attribute settings
        var extensionConfig = this._extensionConfig;
        if (null === extensionConfig)
            { return false; }
        var props = extensionConfig.getProperties();
        var nprops = props.length;
        for (var ind = 0; ind < nprops; ++ind) {
            var prop = props[ind];
            var retval;
            switch (prop.getName()) {
                case 'intpName':
                    retval = prop.setValue(this._cmdType[this._cmdIndex]);
                    break;
                case 'intpCommand':
                    if (this._cmdIndex > 0 && this._cmdIndex < 6) {
                        retval = prop.setValue(this._shellData[this._shellIndex].shell);
                    }
                    break;
                case 'scriptExtension':
                    if (this._cmdIndex > 0 && this._cmdIndex < 6) {
                        retval = prop.setValue(this._shellData[this._shellIndex].scrExt);
                    }
                    break;
                case 'intpArgument':
                    if (this._cmdIndex > 0 && this._cmdIndex < 6) {
                        retval = prop.setValue(this._shellData[this._shellIndex].cmdArgs);
                    }
                    break;
                case 'scriptArgument':
                    if (this._cmdIndex > 0 && this._cmdIndex < 6) {
                        retval = prop.setValue(this._shellData[this._shellIndex].scrArgs);
                    }
                    break;
                case 'scriptContentType':
                    var content = '';
                    var indx = this._shellData[this._shellIndex].lineEndIndex;
                    if (indx >= 0) {
                        content = this._scriptContentType.replace('xxxx', this._lineEndType[indx].toLowerCase());
                    }
                    retval = prop.setValue(content);
                    break;
                case 'commandType':
                    if (this._cmdIndex > 0 && this._cmdIndex < 6) {
                        retval = prop.setValue('Shell');
                    } else if (this._cmdIndex === 6) {
                        retval = prop.setValue('PredefinedCommand');
                    } else {
                        retval = prop.setValue(this._cmdType[this._cmdIndex]);
                    }
                    break;
                case 'scriptText':
                    if (this._cmdIndex > 0 && this._cmdIndex < 6) {
                        retval = prop.setValue(this._shellData[this._shellIndex].scriptContent);
                    }
                    break;
                case 'command':
                    if (this._cmdIndex === 0) {
                        retval = prop.setValue(this._command);
                    }
                    break;
                case 'maxrcSuccess':
                    // aggregate property consisting of a single subprop with a value array
                    // Prop                 {name: "maxrcSuccess", type: "aggregate", Property: Object}
                    // Prop.Property        {valuetype: "array", name: "success", Value: Array[5], arraydim: "[5]"}
                    // Prop.Property.Value  [{<TEXT>: "10:20", index: "[0]"}, {<TEXT>: "25", index: "[1]"}, {<TEXT>: "50:40", index: "[2]"}, ...]
                    if (this._returnCode && this._maxrcSuccess.length > 0) {
                        var ranges = this._maxrcSuccess.replace(/ /g, '').split(',');
                        if (ranges) {
                            var subprops = prop.getProperties();
                            if (subprops) {
                                var num = ranges.length;
                                var i;
                                var count = 0;
                                var validRanges = [];
                                for (i = 0; i < num; ++i) {
                                    var r = ranges[i];
                                    if (r && r !== '') {
                                        validRanges.push(r);
                                        count++;
                                    }
                                }
                                var dims = [];
                                dims.push(count);
                                subprops[0].resize(dims);
                                subprops[0].setValueKey('<TEXT>');
                                var valArray = [];
                                for (i = 0; i < count; ++i) {
                                    valArray.push(validRanges[i]);
                                }
                                subprops[0].setValues(valArray);
                            }
                        }
                    }
                    break;
                case 'waitFile':
                    if (this._waitForFile && this._waitFile && this._waitFile.length > 0) {
                        retval = prop.setValue(this._waitFile);
                    }
                    break;
                case 'waitString':
                    if (this._waitForFile && this._waitString && this._waitString.length > 0 && this._waitFile.length > 0) {
                        retval = prop.setValue(this._waitString);
                    }
                    break;
                case 'waitDelay':
                    if (this._waitForFile && this._waitDelay && this._waitDelay > 0 && this._waitFile.length > 0) {
                        retval = prop.setValue(this._waitDelay);
                    }
                    break;
                case 'releaseConcurrency':
                    retval = prop.setValue(this._releaseConcurrency);
                    break;
                case 'oscmd_env_vars':
                    var evarProps = this._oscmd_env_vars;
                    if (evarProps) {
                        var len = evarProps.length;
                        var dims = [];
                        dims.push(len);
                        // PCN descriptor is incorrect - env var are resizable
                        prop.setSizable(true);
                        prop.resize(dims);
                        prop.setValueKey('<TEXT>');
                        var valArray = [];
                        for (var i = 0; i < len; ++i) {
                            var evarProp = evarProps[i];
                            var str = '';
                            str = evarProp.name + '=' + evarProp.value;
                            valArray.push(str);
                        }
                        prop.setValues(valArray);
                    }
                    break;
                case 'PredefinedCommandOptions':
                    if (this._cmdIndex === 6 && this._selectedConn) {
                        prop.setValueKey('<![CDATA]>');
                        var table = this.$.optionstable;
                        var cmdopts = '<Application name = \'' + this._selectedConn.name +
                            '\' revision = \'' +  this._selectedConn['Application Version']  +
                            '\' type = \'Simulation Connector\' appName = \'' +  this._selectedConn['Application Name'] +
                            '\' appVersion = \'' + this._selectedConn['Application Version'];

                        // cmdopts += '\' physicalid = \'' + this._selectedConn.physicalid;
                        cmdopts += '\'><Values>';

                        var table = this.$.optionstable;
                        var numrows = table.numRows();

                        for (var i = 0; i < numrows; ++i) {
                            var rowinfo = table.getRowInfo(i);
                            if (rowinfo.cells[0].cellType === 'checkbox' && rowinfo.cells[0].value === true) {
                                var connopt = this._selectedConn.connectoroptions;
                                var optype = connopt[i].optionType;

                                var val = rowinfo.cells[2].value === undefined || optype === 'Standalone' ? '' : rowinfo.cells[2].value;
                                cmdopts += '<Value id=\'' + i + '\' value=\'' + val + '\' name=\'' + rowinfo.cells[1].value;

                                cmdopts += '\' optionType=\'' + optype + '\'';
                                if (optype !== 'Standalone') {
                                    cmdopts += ' separator=\'=\'';
                                }
                                cmdopts += '/>';
                            }
                        }
                        cmdopts += '</Values></Application>';
                        retval = prop.setValue(cmdopts);
                    }
                    break;
                case 'ViewData':
                    //TODO what is "ViewData"  ?
                    break;
                default: {
                    var name = '_' + prop.getName();
                    var propval = this[name];
                    var structure = prop.getStructure();
                    if (propval !== undefined && structure === SMAJSCMMUtils.Structure.client.Scalar) {
                        retval = prop.setValue(propval);
                    } else  {
                        console.log('WARNING: cmp-oscommand.Apply is not saving property value for: ' + name);
                    }
                }
            }
        }
        return true;
    },

    updateCommandPreview: function () {
        if (this._cmdIndex !== undefined && this._cmdIndex !== null) {
            if (this._cmdIndex === 0) {
                this.$.cmdPreview.value = SMAJSCMMAuthoringUtils.substituteExpression(this._activity, this._command);
            } else if (this._cmdIndex < 6 && this._shellData && this._shellIndex >= 0) {
                var preview = this._shellData[this._shellIndex].shell;
                var command = preview.concat(
                    ' ', this._shellData[this._shellIndex].cmdArgs,
                    ' __script__', this._shellData[this._shellIndex].scrExt,
                    ' ', this._shellData[this._shellIndex].scrArgs
                );
                this.$.cmdPreview.value = SMAJSCMMAuthoringUtils.substituteExpression(this._activity, command);
                this.$.lineEndings.selectedIndex =  this._shellData[this._shellIndex].lineEndIndex;
            } else {
                this.$.cmdPreview.value = this._connectorCommand();
            }
        }
    },
    _connectorCommand: function() {
        var cmd = '';
        if (this._selectedConn) {
            var table = this.$.optionstable;
            var name = this._selectedConn['Application Name'];
            if (name) {
                cmd = '"' + name + '"';
                var numrows = table.numRows();
                for (var i = 0; i < numrows; ++i) {
                    var rowinfo = table.getRowInfo(i);
                    if (rowinfo.cells[0].cellType === 'checkbox' && rowinfo.cells[0].value === true) {
                        var connopt = this._selectedConn.connectoroptions;
                        var optype = connopt[i].optionType;

                        if (rowinfo.cells[2].value === undefined || optype === 'Standalone') {
                            cmd += ' -' + rowinfo.cells[1].value;
                        } else {
                            var val = rowinfo.cells[2].value;
                            if (val && val.length) {
                                cmd += ' ' + rowinfo.cells[1].value + '=' + val;
                            }
                        }
                    }
                }
            }
        }
        return cmd;
    },
    updateLocals: function () {
        if (this._commandType !== undefined && this._commandType !== null) {
            var index;
            if (this._commandType === 'Shell' && this._intpName !== undefined) {
                index = this._cmdType.indexOf(this._intpName);
                if (index > 0 && index < this._cmdType.length) {
                    this.set('_cmdIndex', index);
                }
            } else if (this._commandType === 'PredefinedCommand') {
                this.set('_cmdIndex', 6);
            }
            this.$.types.selectedIndex = this._cmdIndex;
        }

        if (this._waitFile && this._waitFile.length > 0) {
            this.set('_waitForFile', true);
        }

        if (this._maxrcSuccess && this._maxrcSuccess.length > 0) {
            this.set('_returnCode', true);
            this.$.rcVal.readonly = false;
        } else {
            this.$.rcVal.readonly = true;
        }

        this.$.xwinDisplay.readonly = !this._unix;


        if (this._cmdIndex > 0 && this._shellData && this._shellIndex >= 0 && this._shellIndex <= 4) {
            if (this._scriptExtension) {
                this.set('_shellData' + ('.' + this._shellIndex) + '.scrExt', this._scriptExtension);
            }
            if (this._intpCommand) {
                this.set('_shellData' + ('.' + this._shellIndex) + '.shell', this._intpCommand);
            }
            if (this._scriptText && this._scriptText.length > 0) {
                this.set('_shellData' + ('.' + this._shellIndex) + '.scriptContent', this._scriptText);
            }
            if (this._intpArgument && this._intpArgument.length > 0) {
                this.set('_shellData' + ('.' + this._shellIndex) + '.cmdArgs', this._intpArgument);
            }
            if (this._scriptArgument && this._scriptArgument.length > 0) {
                this.set('_shellData' + ('.' + this._shellIndex) + '.scrArgs', this._scriptArgument);
            }

            if (this._scriptContentType && this._scriptContentType.length > 0) {
                this.set('_shellData' + ('.' + this._shellIndex) + '.lineEndIndex', 0);
                var startTag = '<rwLend>';
                var endTag = '</rwLend>';
                var evalue = '';
                var beg = this._scriptContentType.search(startTag);
                var last = this._scriptContentType.search(endTag);
                if (beg >= 0 && last >= 0) {
                    beg += startTag.length;
                    if (last > beg) {
                        evalue = this._scriptContentType.substring(beg, last);
                    }
                }
                if (evalue === 'local') {
                    this.set('_shellData' + ('.' + this._shellIndex) + '.lineEndIndex', this._lineEndType.indexOf('Local'));
                } else if (evalue === 'unix') {
                    this.set('_shellData' + ('.' + this._shellIndex) + '.lineEndIndex', this._lineEndType.indexOf('Unix'));
                } else if (evalue === 'windows') {
                    this.set('_shellData' + ('.' + this._shellIndex) + '.lineEndIndex', this._lineEndType.indexOf('Windows'));
                }
            }
        }
    },
    behaviors: [SPBase],


// observers
    _intpArgumentObserver: function(value) {
        if (!this._initializing && this._shellData && this._shellIndex >= 0) {
            this.set('_shellData' + ('.' + this._shellIndex) + '.cmdArgs', value);
            this.updateCommandPreview();
        }
    },
    _scriptArgumentObserver: function(value) {
        if (!this._initializing && this._shellData && this._shellIndex >= 0) {
            this.set('_shellData' + ('.' + this._shellIndex) + '.scrArgs', value);
            this.updateCommandPreview();
        }
    },
    _cmdIndexObserver: function(value) {
        if (!this._initializing && (value === 0 || this._shellIndex === value-1)) {
            this.updateCommandPreview();
        } else if (value === 6) {
            if (this._activity && (!this._connectors || this._connectors.length === 0)) {
                var osc = this;
                this.$.updatePanel.update();
                SMAJSCMMAuthoringUtils.getConnectorsInPLM(this._activity.getProcess(), {
                    onSuccess: function(data) {
                        if (data !== undefined && data !== null) {
                            if (Array.isArray(data)) {
                                for ( var i = 0; i < data.length; ++i ) {
                                    if ( data[i]['Connector Kind'] === 'application' ) {
                                        osc._connectors.push( data[i] );
                                    }
                                }
                            } else if ( data['Connector Kind'] === 'application' ) {
                                osc._connectors.push(data);
                            }
                            osc._populateConnectorDropdown();
                        }
                        osc.$.updatePanel.done();
                    },
                    onFailure: function() {
                        osc.$.updatePanel.done();
                        osc._populateConnectorDropdown();
                    }
                });
            } else {
                this._populateConnectorDropdown();
            }
        } else {
            this.set('_shellIndex', value-1);
        }
    },
    _shellIndexObserver: function(value) {
        if (this._shellData && value >= 0 && value < 5 && !this._initializing) {
            this.set('_intpArgument',   this._shellData[value].cmdArgs);
            this.set('_scriptArgument', this._shellData[value].scrArgs);
            this.set('_lineEnding',     this._shellData[value].lineEndIndex);
            this.set('_scriptText',     this._shellData[value].scriptContent);
            this.updateCommandPreview();
        }
    },
    _commandObserver: function() {
        if (!this._initializing) {
            this.updateCommandPreview();
        }
    },
    _lineEndingObserver: function(value) {
        if (!this._initializing && this._shellData && this._shellIndex >= 0) {
            this.set('_shellData' + ('.' + this._shellIndex) + '.lineEndIndex', value);
        }
    },
    _scriptTextObserver: function (value) {
        if (!this._initializing && this._shellData && this._shellIndex >= 0) {
            this.set('_shellData' + ('.' + this._shellIndex) + '.scriptContent', value);
        }
    },
    _unixObserver: function(value) {
        if (value) {
            this.set('$.xwinDisplay.readonly', false);
        } else {
            this.set('$.xwinDisplay.readonly', true);
        }
    },
    _waitFileObserver: function (value) {
        if (value) {
            this.set('$.waitFilename.readonly', false);
            this.set('$.findString.readonly', false);
            this.set('$.waitDelay.readonly', false);
        } else {
            this.set('$.waitFilename.readonly', true);
            this.set('$.findString.readonly', true);
            this.set('$.waitDelay.readonly', true);
        }
    },
    _returnCodeObserver: function(value) {
        if (value) {
            this.set('$.rcVal.readonly', false);
        } else {
            this.set('$.rcVal.readonly', true);
        }
    },
    _retvalParamObserver: function(value) {
        console.log('_retvalParamObserver = ' + value);
        if (value) {
            var selected = this.$.exitCodeParam.getSelectedParameter();
            var selname = '';
            if (selected && selected.parameter) {
                selname = selected.parameter.getName();
            }
            if (selname != value) {
                var validParamName = this.$.exitCodeParam.getParameterByName(value);
                if (validParamName){
                    this.$.exitCodeParam.selectParameterByName(value);
                }
            }
        }
    },

// show/hide
    _commandPaneClass: function (_cmdIndex) {
        return this.tokenList({ 'is-visible': _cmdIndex == 0 }) + 'command-pane ' + this.tokenList({ 'is-visible': _cmdIndex == 0 });
    },
    _shellPaneClass: function (_cmdIndex) {
        return this.tokenList({ 'is-visible': _cmdIndex > 0 && _cmdIndex < 6 }) + 'command-pane ' + this.tokenList({ 'is-visible': _cmdIndex > 0 && _cmdIndex < 6 });
    },
    _predefinedAppsClass: function (_cmdIndex) {
        return this.tokenList({ 'is-visible': _cmdIndex == 6 }) + 'command-pane ' + this.tokenList({ 'is-visible': _cmdIndex == 6 });
    },
    _getTitle: function (_cmdIndex) {
        return (this._cmdType && this._cmdType[_cmdIndex] || '') + ' configuration';
    },

    _populateConnectorDropdown: function() {
        var sel = this.$.apps;
        if (this._connectors && this._connectors.length > 0 && sel.options.length === 1) {
            for (var i = 0; i < this._connectors.length; ++i) {
                var option = document.createElement('option');
                option.text = this._connectors[i].Title;
                sel.add(option);
            }
            if (this._PredefinedCommandOptions && this._PredefinedCommandOptions.length > 0) {
                var parser = new DOMParser();
                var hdoc = parser.parseFromString(this._PredefinedCommandOptions, 'text/html');
                var els = hdoc.getElementsByTagName('Application');
                if (els && els.length > 0) {
                    var selectedApp = els[0].getAttribute('name');
                    if (selectedApp && selectedApp.length > 0) {
                        for (var i = 0; i < this._connectors.length; ++i) {
                            if (this._connectors[i].name === selectedApp) {
                                this.set('_selectedConn', this._connectors[i]);
                                sel.selectedIndex = i+1;
                                this.set('_appIndex', i);
                                break;
                            }
                        }
                    }
                }
            }
        } else {
            console.log('WARNING: No Predefined Applications were found.');
        }
    },

    _connectorObserver: function(value) {
        // selected connector changed, update tablewith options
        if (this._connectors && value != undefined) {
            var connector = this._connectors[value];
            var options = connector.connectoroptions;
            var table = this.$.optionstable;
            table.removeRows();

            var values;
            if (this._PredefinedCommandOptions && this._PredefinedCommandOptions.length > 0) {
                var valstart = this._PredefinedCommandOptions.indexOf('<Values>');
                if (valstart > 0) {
                    var parser = new DOMParser();
                    var hdoc = parser.parseFromString(this._PredefinedCommandOptions, 'text/html');
                    var els = hdoc.getElementsByTagName('Values');
                    if (els && els.length > 0) {
                        values = els[0].getElementsByTagName('Value');
                    }
                }
            }
            for (var i = 0; i < options.length; ++i) {
                // create table row JSON, set current option settings and insert into table
                var option = options[i];
                var rowcontent = {};

                var include = false;
                var optval = undefined;
                if (values && values.length > 0) {
                    for (var v = 0; v < values.length; ++v) {
                        if (values[v].getAttribute('name') === option.name) {
                            include = true;
                            optval = values[v].getAttribute('value');
                            break;
                        }
                    }
                }

                rowcontent['includecol'] = { value: include ? 'true' : 'false',  type: 'checkbox', editable: 'true' };
                rowcontent['namecol'] = { value: option.name,  type: 'text',     editable: 'false' };
                if (option.optionType === 'Standalone') {
                    rowcontent['valcol'] = { type: 'empty', editable: 'false' };
                } else if (option.Choices) {
                    var choices = [];
                    for (var j = 0; j < option.Choices.length; ++j) {
                        choices.push( { value: option.Choices[j] } );
                    }
                    if (optval === undefined) {
                        rowcontent['valcol'] = { type: 'dropdown', options: choices };
                    } else {
                        rowcontent['valcol'] = { type: 'dropdown', options: choices, value: optval };
                    }
                } else {
                    if (optval === undefined) {
                        rowcontent['valcol'] = { value: option.defaultValue?option.defaultValue:'',  type: 'text', editable: 'true' };
                    } else {
                        rowcontent['valcol'] = { value: optval,  type: 'text', editable: 'true' };
                    }
                }
                rowcontent['desccol'] = { value: option.description,  type: 'text',  editable: 'false' };
                this.$.optionstable.insertRow(rowcontent, -1);
            }
            this.set('_PredefinedCommandOptions', '');
            this.updateCommandPreview();
        }
    },

    _showHideClass: function (show, panel) {
        return this.tokenList({ 'is-visible': show }) + panel +' ' + this.tokenList({ 'is-visible': show });
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

/*
polyup:
 1. Constructor if required needs to be explicitly set window object
 2. Mixins are converted to behaviors
*/

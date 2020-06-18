window.require(['UWA/Core', 'DS/Windows/Dialog', 'DS/Controls/Button', 'DS/Windows/ImmersiveFrame', 
	'DS/Tree/TreeNodeModel', 'DS/Tree/TreeListView', 'DS/Controls/ComboBox', 'DS/Controls/Loader', 'DS/Controls/SpinBox', 'DS/Controls/LineEditor', 'DS/Controls/Toggle',
	'css!DS/SMAProcXSWidgets/xs-wg-dynamic-parameters/XSDynamicTableView.css'],
	function(UWA, WUXDialog, WUXButton, WUXImmersiveFrame, TreeNodeModel, TreeListView, WUXComboBox, WUXLoader, WUXSpinBox, WUXLineEditor, WUXToggle){

	'use strict';

	// Prototype
	return window.Polymer({
		is: 'xs-wg-dynamic-parameters',
		properties: {
			_adp: { value: null },
			value: {
				notify: true
			},
			rawvalue: {
				type: Object,
				notify: true,
				observer: 'rawvalueChanged'
			},
			label: {
				type: String,
				observer: 'labelChanged'
			},
			stepname: {
				type: String,
				notify: true
			},
			widgettype: {
				type: String,
				notify: true
			},
			kwstepname: {
				type: String,
				notify: true
			},
			jobstatus: {
				type: String,
				notify: true,
				value: 'Not Started',
				observer: 'jobstatusChanged'
			},
			allowfactors: {
				type: String,
				notify: true
			}
		},
		label:'',
		showMsg:false,
		tableUI: null,
		dynamicValue: {},
		toRemove: [],
		disabled:false,
		responseAndConstraintRows: [],
		immersiveFrame: null,
		progressContainer: null,
		progressSpinner: null,
		ready: function() {
			this._adp = this.XS();
			this.computeDisabled();
			if(!this.label || this.label.length < 1) this.label = 'Parameters'; //default label
			this.blockMsg = 'Dynamic parameters is enabled only after instantiation.';
		},
		labelChanged:function(value){
			//console.log(this.label);
			if(value && value.length > 0) this.label = value;
			console.log(this.allowfactors);
		},
		rawvalueChanged: function(){
			//console.log(this.rawvalue);
			this.computeDisabled();
			console.log(this.allowfactors);
		},
		computeDisabled:function(){
			if (this.rawvalue) {
				if(this._isDisabled(this.rawvalue) === true || this.isJobRunning(this.rawvalue.jobstate) === true) this.disabled = true;
				else this.disabled = false;
				
				if(this.disabled === true || (this._adp && this._adp.whichMode && this._adp.whichMode() !== 'run' && this._adp.isInDesignMode() === false)) this.showMsg = true;
			}
		},
		createTableUI: function(cols){    	
			var options = {}; //TreeListView.SETTINGS.STANDARD_CHECKBOXES;
			options.columns = cols;
			options.selection = {
					canMultiSelect: true,
					nodes: true,
					cells: false,
					unselectAllOnEmptyArea: true,
					toggle: true,
			};
			options.show = {
				rowHeaders: false,
				columnHeaders: true
			};
			
			options.resize = {
					rows: false,
					columns: true
			};
			
			options.enableDragAndDrop = false;
			options.enableActiveUI = false;
			options.enableKeyboardNavigation = true;
			options.isEditable = true;
			
			options.height = 'auto';
			//options.apiVersion = '2';
		
			this.tableUI = new TreeListView(options);
		},
		getTableColumns: function(tableType){
			var columns = [];
			columns.push({
				dataIndex: 'tree',
				text: '',
				width: 10,
				isEditable: false,
				isSortable:false
			});
			
			columns.push({
				dataIndex: 'name',
				text: 'Name',
				//typeRepresentation: 'string',
				width: 250,
				isEditable: false,
				isSortable:false,
				onCellRequest: function(cellInfos) {
					if (!cellInfos.isHeader) {   		
						var content = cellInfos.cellView.getContent();
						if(content == undefined || content.getChildren().length < 1){
							// -- inject this custom view inside the CellView
							var currentValue = '';
							if(cellInfos.cellModel && cellInfos.cellModel.options.value) currentValue = cellInfos.cellModel.options.value;
							var widget = new WUXLineEditor({
								placeholder: 'parameter name',
								value: currentValue,
								requiredFlag:true,
								selectAllOnFocus: true
							});
							widget.inject(cellInfos.cellView.elements.container);
							if(cellInfos.nodeModel.options.grid && cellInfos.nodeModel.options.grid.plm) widget.disabled = true;
						}
					}
				}
			});
			
			if((!tableType || tableType === 'Design Parameters') && this.allowfactors && (this.allowfactors === true || this.allowfactors.toLowerCase() === "true")){
				columns.push({
					dataIndex: 'factor',
					//typeRepresentation: 'boolean',
					text: 'Factor?',
					width: 50,
					isSortable:false,
					isEditable: false,
					onCellRequest: function(cellInfos) {
						if (!cellInfos.isHeader) {   		
							var content = cellInfos.cellView.getContent();
							var currentType = cellInfos.nodeModel.options.grid.datatype;
							var factorGrid = cellInfos.nodeModel.options.grid.factor;
							var Checkbox;
							var currentValue = true; //default
							var ReadOnly = (currentType && currentType.toLowerCase() === 'string')? true : false;
							if(cellInfos.cellModel && cellInfos.cellModel.options.value !== undefined) currentValue = cellInfos.cellModel.options.value;
							else if(factorGrid !== undefined) currentValue = factorGrid;
							if(true == ReadOnly) {
								cellInfos.nodeModel.options.grid.factor = false;
								currentValue = false;
							}
							if(content == undefined || content.getChildren().length < 1){
								// -- inject this custom view inside the CellView
								Checkbox = new WUXToggle({ checkFlag: currentValue, disabled: ReadOnly });
								Checkbox.inject(cellInfos.cellView.elements.container);
								Checkbox.addEventListener('change', function (event){
										event.stopPropagation();
										event.preventDefault();
									  // recover the Toggle object.
									  var check = event.dsModel;
									  this.nodeModel.options.grid.factor = check.checkFlag;
									  this.cellModel.options.value = check.checkFlag;
									  this.manager.updateRowView(this.virtualRowID);
								}.bind(cellInfos));
								
							} else if(content && content.getChildren().length && (content.getChildren())[0] instanceof WUXToggle){
								Checkbox = (content.getChildren())[0];
							}
							
							if(Checkbox) { 
								if(ReadOnly !== undefined) Checkbox.disabled = ReadOnly; 
								if(currentValue !== undefined) Checkbox.checkFlag = currentValue;
							}
						}
					}
				});
			}
			
			columns.push({
				text: 'Type',
				dataIndex: 'datatype',
				isEditable: false,
				width: 100,
				isSortable:false,
				onCellRequest: function(cellInfos) {
					if (!cellInfos.isHeader) {   		
						var content = cellInfos.cellView.getContent();
						var currentType = cellInfos.nodeModel.options.grid.datatype;
						if(content == undefined || content.getChildren().length < 1){
							// -- inject this custom view inside the CellView
							var typeList = [{labelItem: 'Real', valueItem: 'Real'}, {labelItem: 'Integer', valueItem: 'Integer'}];
							if(!tableType || tableType === 'Design Parameters') typeList.push({labelItem: 'String', valueItem: 'String'});
							var currentValue = 'Real';
							if(cellInfos.cellModel && cellInfos.cellModel.options.value) currentValue = cellInfos.cellModel.options.value;

							var Combo = new WUXComboBox({ elementsList: typeList, placeholder: 'Select type', currentValue: currentValue, enableSearchFlag: false });
							Combo.inject(cellInfos.cellView.elements.container);
							if(cellInfos.nodeModel.options.grid && cellInfos.nodeModel.options.grid.plm) Combo.disabled = true;
							//Combo.node = cellInfos.nodeModel;
//							Combo.addEventListener('change', function(event){
//								var typeSel = event.dsModel.value;
//								if(typeSel && typeSel.toLowerCase() === 'string'){
//									//this.nodeModel.options.grid.factor = false;
//									//this.manager.updateRowView(this.virtualRowID);
//								}
//							}.bind(cellInfos));
						}
					}
				}
			});

			columns.push({
				text: 'Value',
				dataIndex: 'value',
				isEditable: false,
				//typeRepresentation: 'double',
				width: 100,
				isSortable:false,
				onCellRequest: function(cellInfos) {
					if (!cellInfos.isHeader) {   		
						var content = cellInfos.cellView.getContent();
						var currentWidget; 
						if(content !== undefined || content.getChildren().length > 0) currentWidget = content.getChildren()[0];
						// -- inject this custom view inside the CellView
						var currentType = cellInfos.nodeModel.options.grid.datatype;
						var currentValue = 0;
						if(cellInfos.cellModel && cellInfos.cellModel.options.value) currentValue = cellInfos.cellModel.options.value;
						var widget = currentWidget;
						if(currentType.toLowerCase() === 'string'){
							//if(!isNaN(currentValue)) currentValue = '';
							if (typeof currentValue !== 'string' || !(currentValue instanceof String)) currentValue = currentValue.toString();
							if(!widget || !(widget instanceof WUXLineEditor)){
								widget = new WUXLineEditor({
									placeholder: 'Enter value here',
									value: currentValue,
									selectAllOnFocus: true
								});
								//widget.addClassName('wux-controls-lineeditor');
								//widget.addClassName('reAlign');
							}

						} else if(currentType.toLowerCase() === 'integer'){
							if(isNaN(currentValue)) currentValue = 0;
							else currentValue = parseInt(currentValue);
							if(!widget || !(widget instanceof WUXSpinBox) || !widget.valueType || widget.valueType != 'int'){
								widget = new WUXSpinBox({
									value: currentValue,
									stepValue: 1,
									pageStepValue: 10,
									selectAllOnFocus: true
								});
								widget.valueType = 'int';
							}
						} else if(currentType.toLowerCase() === 'real'){
							if(isNaN(currentValue)) currentValue = 0.0;
							else currentValue = parseFloat(currentValue);
							if(!widget || !(widget instanceof WUXSpinBox) || !widget.valueType || widget.valueType != 'real'){
								widget = new WUXSpinBox({
									value: currentValue,
									stepValue: 0.01,
									pageStepValue: 0.1,
									selectAllOnFocus: true
								});
								widget.valueType = 'real';
							}
						}
						if(!widget) return;
						widget.inject(cellInfos.cellView.elements.container);
					}
				}
			});

			if(!tableType || tableType === 'Design Parameters' || tableType === 'Constraints'){
				columns.push({
					text: 'Lower Bound',
					dataIndex: 'lower',
					isEditable: false,
					//typeRepresentation: 'double',
					width: 100,
					isSortable:false,
					onCellRequest: function(cellInfos) {
						if (!cellInfos.isHeader) {   		
							var content = cellInfos.cellView.getContent();
							var currentWidget; 
							if(content !== undefined || content.getChildren().length > 0) currentWidget = content.getChildren()[0];
							// -- inject this custom view inside the CellView
							var currentType = cellInfos.nodeModel.options.grid.datatype;
							var currentValue = 0;
							if(cellInfos.cellModel && cellInfos.cellModel.options.value) currentValue = cellInfos.cellModel.options.value;
							else if(cellInfos.cellModel && cellInfos.cellModel.options.lower) currentValue = cellInfos.cellModel.options.lower;
							var widget = currentWidget;
							var stepValue = (currentType.toLowerCase() === 'integer')? 1 : 0.01; //default
							var pageStep = (currentType.toLowerCase() === 'integer')? 10 : 0.1;
							var valueType = (currentType.toLowerCase() === 'integer')? 'int' : 'real';
							if(currentType.toLowerCase() === 'integer'){
								if(isNaN(currentValue)) currentValue = -10;
								else currentValue = parseInt(currentValue);
							} else if(currentType.toLowerCase() === 'real'){
								if(isNaN(currentValue)) currentValue = -10.0;
								else currentValue = parseFloat(currentValue);
							}
							
							if(!widget && currentType.toLowerCase() === 'string'){
								widget = new WUXLineEditor({
									placeholder: '',
									value: '',
									selectAllOnFocus: true
								});
							}
							else if(!widget || !(widget instanceof WUXSpinBox)){
								widget = new WUXSpinBox({
									value: currentValue,
									stepValue: stepValue,
									pageStepValue: pageStep,
									selectAllOnFocus: true
								});
								widget.valueType = valueType;
							}
							
							if(widget && currentType.toLowerCase() === 'string') widget.disabled = true; //disable bounds for string type 
							
							if(!widget) return;
							widget.inject(cellInfos.cellView.elements.container);
						}
					}
				});

				columns.push({
					text: 'Upper Bound',
					dataIndex: 'upper',
					isEditable: false,
					//typeRepresentation: 'double',
					width: 100,
					isSortable:false,
					onCellRequest: function(cellInfos) {
						if (!cellInfos.isHeader) {   		
							var content = cellInfos.cellView.getContent();
							var currentWidget; 
							if(content !== undefined || content.getChildren().length > 0) currentWidget = content.getChildren()[0];
							// -- inject this custom view inside the CellView
							var currentType = cellInfos.nodeModel.options.grid.datatype;
							var currentValue = 0;
							if(cellInfos.cellModel && cellInfos.cellModel.options.value) currentValue = cellInfos.cellModel.options.value;
							else if(cellInfos.cellModel && cellInfos.cellModel.options.upper) currentValue = cellInfos.cellModel.options.upper;
							var widget = currentWidget;
							var stepValue = (currentType.toLowerCase() === 'integer')? 1 : 0.01; //default
							var pageStep = (currentType.toLowerCase() === 'integer')? 10 : 0.1;
							var valueType = (currentType.toLowerCase() === 'integer')? 'int' : 'real';
							if(currentType.toLowerCase() === 'integer'){
								if(isNaN(currentValue)) currentValue = 10;
								else currentValue = parseInt(currentValue);
							} else if(currentType.toLowerCase() === 'real'){
								if(isNaN(currentValue)) currentValue = 10.0;
								else currentValue = parseFloat(currentValue);
							}
							if(!widget && currentType.toLowerCase() === 'string'){
								widget = new WUXLineEditor({
									placeholder: '',
									value: '',
									selectAllOnFocus: true
								});
							}
							else if(!widget || !(widget instanceof WUXSpinBox)){
								widget = new WUXSpinBox({
									value: currentValue,
									stepValue: stepValue,
									pageStepValue: pageStep,
									selectAllOnFocus: true
								});
								widget.valueType = valueType;
							}
							
							if(widget && currentType.toLowerCase() === 'string') widget.disabled = true; //disable bounds for string type
							if(!widget) return;
							widget.inject(cellInfos.cellView.elements.container);
						}
					}
				});
			} else {
				columns.push({
					text: 'Objective',
					dataIndex: 'objective',
					isEditable: false,
					width: 100,
					isSortable:false,
					onCellRequest: function(cellInfos) {
						if (!cellInfos.isHeader) {   		
							var content = cellInfos.cellView.getContent();
							if(content == undefined || content.getChildren().length < 1){
								// -- inject this custom view inside the CellView
								//var reusableContent = cellInfos.cellView.reuseCellContent('objective_dropdown');
								var typeList = [{labelItem: 'Minimize', valueItem: 'minimize'}, {labelItem: 'Maximize', valueItem: 'maximize'},{labelItem: 'Target', valueItem: 'target'}];
								var currentValue = 'minimize';
								if(cellInfos.cellModel && cellInfos.cellModel.options.value) currentValue = cellInfos.cellModel.options.value;
								var objectiveCombo = new WUXComboBox({ elementsList: typeList, placeholder: 'Select objective', currentValue: currentValue, enableSearchFlag: false });
								objectiveCombo.inject(cellInfos.cellView.elements.container);
							}
						}
					}
				});

				columns.push({
					text: 'Scale Factor',
					dataIndex: 'scale',
					isEditable: true,
					typeRepresentation: 'double',
					width: 100,
					isSortable:false
				});
			}
			
			if(this.kwstepname && this.kwstepname !== null && this.kwstepname !== ''){
				columns.push({
					text: '3DX Parameter',
					dataIndex: 'kwparam',
					placeholder: 'Enter 3DX Parameter name',
					isEditable: true,
					typeRepresentation: 'string',
					width: 200,
					isSortable:false
				});
				columns.push({
					text: 'Unit',
					dataIndex: 'kwparamunit',
					isEditable: true,
					typeRepresentation: 'string',
					placeholder: 'empty for MKS unit',
					width: 70,
					isSortable:false
				});
			}
			
			return columns;
		},
		addNewParameter: function(){			
			var thatComp = this;
			var tableUI = thatComp.tableUI;
			if(tableUI && tableUI != null){
				var roots = tableUI.getRoots();
				var rootIndx = 1;
				if(roots && roots != null && roots.length) rootIndx = roots.length + 1;
				tableUI.addRoot(thatComp.getNewRow({name:"param" + rootIndx}));
			}
		},
		removeParameters: function(){
			var thatComp = this;
			var tableUI = thatComp.tableUI;
			if(tableUI && tableUI != null){
				var tableDoc = tableUI.getDocument();
				if(tableDoc && tableDoc != null){
					var nodes = tableDoc.getSelectedNodes();
					if(nodes && nodes != null && nodes.length){
						for(var nIndx = 0; nIndx < nodes.length; nIndx++){
							thatComp.toRemove.push(nodes[nIndx].options.grid.name);
							tableDoc.removeRoot(nodes[nIndx]);
						}
					}
				}
			}
		},
		createDialog: function(frame, table){
			var thatComp = this;
			
			var dialogBody = new UWA.createElement('div', {id:'xs-wg-dynamic-parameters-diaglog-body', 'class' : 'xs-wg-dynamic-parameters-diaglog-body'});
			
			var buttonSec = new UWA.createElement('section', { id: 'xs-wg-dynamic-parameters-button-section', 'class' : 'xs-wg-dynamic-parameters-button-section'});
			buttonSec.inject(dialogBody);
			
			var tableSec = new UWA.createElement('section', { id: 'xs-wg-dynamic-parameters-table-section', 'class' : 'xs-wg-dynamic-parameters-table-section'});
			tableSec.inject(dialogBody);

			var buttonBody = new UWA.createElement('div', {
                'class': 'xs-wg-dynamic-parameters-button-body'
			});
			buttonBody.inject(buttonSec);
			var buttonContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container', style: { 'vertical-align': 'top', 'min-height': '50px', 'position':'inline-block', 'display': 'block' } });
			buttonContainer.inject(buttonBody);
			var AddButton = new WUXButton({
				label: "Add",
				emphasize: 'primary',
				onClick: function(e){
					//console.log('on Add button click');
					if(thatComp && thatComp.addNewParameter) thatComp.addNewParameter();
				}
//				function(e) {
//					console.log('on Add button click');
//					var tableUI = e.dsModel.tableUI;
//					if(tableUI && tableUI != null){
//						var roots = tableUI.getRoots();
//						var rootIndx = 1;
//						if(roots && roots != null && roots.length) rootIndx = roots.length + 1;
//						tableUI.addRoot(thatComp.getNewRow({name:"param" + rootIndx}));
//					}
//				}
			});
			AddButton.inject(buttonContainer);
			//AddButton.tableUI = thatComp.tableUI;

			var RemoveButton = new WUXButton({
				label: "Remove",
				onClick: function(e){
					//console.log('on Remove button click');
					if(thatComp && thatComp.removeParameters) thatComp.removeParameters();
				}
					
//					function(e){
//					console.log('on Remove button click');
//					var tableUI = e.dsModel.tableUI;
//					if(tableUI && tableUI != null){
//						var tableDoc = tableUI.getDocument();
//						if(tableDoc && tableDoc != null){
//							var nodes = tableDoc.getSelectedNodes();
//							if(nodes && nodes != null && nodes.length){
//								for(var nIndx = 0; nIndx < nodes.length; nIndx++){
//									thatComp.toRemove.push(nodes[nIndx].options.grid.name);
//									tableDoc.removeRoot(nodes[nIndx]);
//								}
//							}
//						}
//					}
//				}
			});
			RemoveButton.inject(buttonContainer);
			//RemoveButton.tableUI = thatComp.tableUI;
			
			/*
			var fileImport = new UWA.createElement('input', { style: { 'display' : 'none' }});
			fileImport.type = 'file';
			fileImport.accept = 'text/*';
			fileImport.thatComp = thatComp;
			
			fileImport.addEventListener('change', function(){
				
				if(fileImport && fileImport.value){
					console.log('importing file: ' + fileImport.value);
					if(fileImport.thatComp && fileImport.thatComp.importFromFile) fileImport.thatComp.importFromFile(fileImport.value);
				}
				
			});
			
			var ImportButton = new WUXButton({
				label: "Import from csv file...",
				onClick: function(e){
					console.log('on import button click');
					var fileImport = e.dsModel.fileImport;
					if(fileImport){
						fileImport.click();
					}
				}
			});
			ImportButton.inject(buttonContainer);
			ImportButton.fileImport = fileImport;
			*/

			//buttonBody.inject(dialogBody);
			var tableBody = new UWA.createElement('div', {
                'class': 'wux-controls-parameter-body'
			});

			this.tableUI.inject(tableBody);
			
			tableBody.inject(tableSec);
			
			this.progressContainer = new UWA.Element('div', { 'class': 'xs-wg-dynamic-parameters-loader', style: { 'display': 'none' } });
			this.progressSpinner = new WUXLoader({text:'Loading...', showButtonFlag:false}).inject(this.progressContainer);
			this.progressContainer.inject(dialogBody);
			
			var dialogTitle = (this.label)? this.label : 'Dynamic Parameters';
			
			var designMode = this._isDisabled() || (this._adp && this._adp.whichMode && this._adp.whichMode() !== 'run' && this._adp.isInDesignMode() === false);

			var parametersDialog = new WUXDialog({
				title: dialogTitle,
				content: dialogBody,
				width: 700,
				height: 400,
				resizableFlag: true,
				movableFlag: true,
				modalFlag: true,
				immersiveFrame: frame,
				buttons: {
					Cancel: new WUXButton({
						onClick: function (e) {
							var button = e.dsModel;
							var myDialog = button.dialog;
							console.log('on Cancel button : dialog title = ' + myDialog.title);
							var immersiveFrame = myDialog.immersiveFrame;
							myDialog.close();
							immersiveFrame.remove();
							if(myDialog.webComp && myDialog.webComp.toRemove) myDialog.webComp.toRemove = [];
						}
					}),
					Ok: new WUXButton({
						onClick: function (e) {
							var button = e.dsModel;
							var myDialog = button.dialog;
							console.log('on OK button : dialog title = ' + myDialog.title);

							var immersiveFrame = myDialog.immersiveFrame;
							if(myDialog.webComp && myDialog.webComp.onOK) myDialog.webComp.onOK(myDialog.tableUI, immersiveFrame, myDialog);
						},
						disabled : designMode
					})
				}
			});

			parametersDialog.addEventListener('close', function (e) {
				console.log('Close on dialog : ' + e.dsModel.title);
				var myDialog = e.dsModel;
				var immersiveFrame = myDialog.immersiveFrame;
				immersiveFrame.remove();
				if(myDialog.webComp && myDialog.webComp.toRemove) myDialog.webComp.toRemove = [];
				myDialog.webComp = null;
			});

			parametersDialog.tableUI = this.tableUI;
			parametersDialog.webComp = this;

			return parametersDialog;
		},
		getNewRow: function(rowData, stepConfig){
			if(!rowData) return null;
			
			var stepFactors = (stepConfig)? stepConfig.factors : undefined;
			var stepConstraints = (stepConfig)? stepConfig.constraints : undefined;
			var stepResponses = (stepConfig)? stepConfig.responses : undefined;
			
			var tableType = this.widgettype;
			if(!tableType || tableType === 'Design Parameters' || tableType === 'Constraints'){
				if((!tableType || tableType === 'Design Parameters') && rowData.mode && (rowData.mode.toLowerCase() != 'in' && rowData.mode.toLowerCase() != 'inout')) return;
				if(tableType === 'Constraints' && rowData.mode && (rowData.mode.toLowerCase() != 'out' && rowData.mode.toLowerCase() != 'inout')) return;
				
				//check if the parameter is part of factors/constraints/response
				if(rowData && rowData.name){
					if(tableType === 'Constraints'){
						if(stepResponses && stepResponses.length > 0 && stepResponses.indexOf(rowData.name) >= 0){ //save this row data
							var row = {
									options: {
										grid: {
											name: (rowData.name)? rowData.name : '',
											value: (rowData.value)? rowData.value : 0,
											datatype: (rowData.datatype)? rowData.datatype : 'Real',
											objective: (rowData.objective)? rowData.objective : 'minimize',
											scale: (rowData.scale)? rowData.scale : 1.0
										}
									}
								};
							this.responseAndConstraintRows.push(row);
							
							if(stepConstraints && stepConstraints.indexOf(rowData.name) < 0) return; //this is a response row
						}
					}
				}
				return {
					label: '',
					grid: {
						name: (rowData.name)? rowData.name : '',
						value: (rowData.value !== undefined)? rowData.value : 0,
						datatype: (rowData.datatype)? rowData.datatype : 'Real',
						lower: (rowData.lower !== undefined)? rowData.lower : -10,
						upper: (rowData.upper !== undefined)? rowData.upper : 10,
						factor: true
					}
				}
			}
			else { //responses
				if(rowData.mode && rowData.mode.toLowerCase() != 'out' && rowData.mode.toLowerCase() != 'inout') return;
				if(rowData && rowData.name){
					if(stepConstraints && stepConstraints.length > 0 && stepConstraints.indexOf(rowData.name) >= 0){ //save this row data in responses
						var row = {
								options :{
									grid: {
										name: (rowData.name)? rowData.name : '',
										value: (rowData.value)? rowData.value : 0,
										datatype: (rowData.datatype)? rowData.datatype : 'Real',
										lower: (rowData.lower !== undefined)? rowData.lower : -10,
										upper: (rowData.upper !== undefined)? rowData.upper : 10,
										factor: true
									}
								}
						};
						this.responseAndConstraintRows.push(row);
						if(stepResponses && stepResponses.indexOf(rowData.name) < 0) return; //this is a constraint row
					}
				}
				return {
					label: '',
					grid: {
						name: (rowData.name)? rowData.name : '',
						value: (rowData.value)? rowData.value : 0,
						datatype: (rowData.datatype)? rowData.datatype : 'Real',
						objective: (rowData.objective)? rowData.objective : 'minimize',
						scale: (rowData.scale)? rowData.scale : 1.0
					}
				}
			}
		},
		getRowParam: function(row){
			if(!row) return null;
			var tableType = this.widgettype;
			if(!tableType || tableType === 'Design Parameters' || tableType === 'Constraints'){
				var dataType = (row.options.grid.datatype)? row.options.grid.datatype : 'Real';
				if(dataType.toLowerCase() === 'string') row.options.grid.value = row.options.grid.value.toString();
				return {
					name: row.options.grid.name,
					dataType: dataType,
							mode: (!tableType || tableType === 'Design Parameters')? 'In' : 'Out',
									value: row.options.grid.value,
									lower: (dataType.toLowerCase() !== 'real' && dataType.toLowerCase() !== 'integer')? undefined : row.options.grid.lower,
									upper: (dataType.toLowerCase() !== 'real' && dataType.toLowerCase() !== 'integer')? undefined : row.options.grid.upper
				}
			}
			else { //responses
				return {
					name: row.options.grid.name,
					dataType: (row.options.grid.datatype)? row.options.grid.datatype : 'Real',
							mode: (!tableType || tableType === 'Design Parameters')? 'In' : 'Out',
									value: row.options.grid.value,
									objective: row.options.grid.objective,
									scale: row.options.grid.scale
				}
			}
		},
		getRowFactor: function(row){
			if(!row) return null;
			var tableType = this.widgettype;
			if(!tableType || tableType === 'Design Parameters' || tableType === 'Constraints'){
				var dataType = (row.options.grid.datatype)? row.options.grid.datatype : 'Real';
				if(dataType.toLowerCase() === 'string') row.options.grid.value = row.options.grid.value.toString();
				var factorVal = row.options.grid.factor;
				if(dataType.toLowerCase() !== 'real' && dataType.toLowerCase() !== 'integer') factorVal = false;
				return {
					name: row.options.grid.name,
					dataType: dataType,
					value: row.options.grid.value,
					lower: row.options.grid.lower,
					upper: row.options.grid.upper,
					factor: factorVal
				}
			}
			else { //responses
				return {
					name: row.options.grid.name,
					dataType: (row.options.grid.datatype)? row.options.grid.datatype : 'Real',
									value: row.options.grid.value,
									objective: row.options.grid.objective,
									scale: row.options.grid.scale
				}
			}
		},
		getRowKWMap: function(row){
			if(!row) return null;
			if(!row.options.grid.kwparam || row.options.grid.kwparam == null || row.options.grid.kwparam === '') return null;
			return { actParam: row.options.grid.name, kwparam: row.options.grid.kwparam, kwparamunit: row.options.grid.kwparamunit };
		},
		onAddParamClick:function()
		{    	
			var frame = new WUXImmersiveFrame();
			this.immersiveFrame = frame;
			var tableType = this.widgettype;
			this.createTableUI(this.getTableColumns(tableType));
			this.parametersDialog = this.createDialog(frame, this.tableUI);
			var thatComp = this;
			
			thatComp.parametersDialog.bringToFront();
			//parametersDialog.inject(frame);
			var xsContainers = document.getElementsByClassName("xs-container");
			var psContentainers = document.getElementsByTagName('ps-simulation-contents');
			var winWidget = window.widget;
			if(xsContainers && xsContainers != null && xsContainers[0]) frame.inject(xsContainers[0]);
			else if(psContentainers && psContentainers[0]) frame.inject(psContentainers[0]);
			else if(winWidget && winWidget != null && winWidget.body && winWidget.body != null) frame.inject(widget.body);
			else frame.inject(document.body);
			thatComp.showSpinner();

			this.getDynamicParameters().then(function(JSONData){

				//handle factors
				var factors = [];
				if(JSONData && JSONData.steps && thatComp.stepname && JSONData.steps[thatComp.stepname] && JSONData.steps[thatComp.stepname].factors && thatComp.allowfactors && thatComp.allowfactors.toLowerCase() === 'true'){
					factors = JSONData.steps[thatComp.stepname].factors;					
				}
				
				var roots = [];
				if(JSONData && JSONData.parameters){
					JSONData.parameters.map(function(param){
						var row = thatComp.getNewRow(param, JSONData.steps[thatComp.stepname]);
						if(row){
							var paramName = row.grid.name;
							if(factors && factors.indexOf(paramName) >= 0) {
								row.grid.factor = true;
							} else {
								row.grid.factor = false;
							}
							
							row.grid.plm = true;
							roots.push(row);
						}
					});
				}
				
				var tableDoc = thatComp.tableUI.getDocument();
				if(roots && roots.length > 0 && tableDoc){
					roots.map(function(a){ tableDoc.addRoot(a); });
				}			
				
				//handle kw steps
				if(JSONData && JSONData.steps && thatComp.kwstepname && JSONData.steps[thatComp.kwstepname]){
					var TOKWMap = {}, FROMKWMap = {};
					if(JSONData.steps[thatComp.kwstepname].TO3DX){
						var map3DX = JSONData.steps[thatComp.kwstepname].TO3DX;
						for(var mapIndx = 0; mapIndx < map3DX.length; mapIndx++){
							var map = map3DX[mapIndx];
							if(map && map.actParam && map.kwparam){
								TOKWMap[map.actParam] = [];
								TOKWMap[map.actParam].push(map.kwparam);
								if(map.kwparamunit) TOKWMap[map.actParam].push(map.kwparamunit);
								else TOKWMap[map.actParam].push('');
							}
						}
					}
					if(JSONData.steps[thatComp.kwstepname].FROM3DX){
						var map3DX = JSONData.steps[thatComp.kwstepname].FROM3DX;
						for(var mapIndx = 0; mapIndx < map3DX.length; mapIndx++){
							var map = map3DX[mapIndx];
							if(map && map.actParam && map.kwparam){
								FROMKWMap[map.actParam] = [];
								FROMKWMap[map.actParam].push(map.kwparam);
								if(map.kwparamunit) FROMKWMap[map.actParam].push(map.kwparamunit);
								else FROMKWMap[map.actParam].push('');
							}
						}
					}
					
					//now append kw param and unit to the rows
					var rows = thatComp.tableUI.getRoots().concat(thatComp.responseAndConstraintRows);
					var kwMap = (!tableType || tableType === 'Design Parameters')? TOKWMap : FROMKWMap;
					for(var rowIndx = 0; rows && kwMap && rowIndx < rows.length; rowIndx++){
						var row = rows[rowIndx];
						if(!row) continue;
						var paramName = row.options.grid.name;
						if(kwMap[paramName]) {
							row.options.grid.kwparam = kwMap[paramName][0];
							row.options.grid.kwparamunit = (kwMap[paramName][1] && kwMap[paramName][1].length)? kwMap[paramName][1] : undefined;
						}
					}
				}
				
				thatComp.showSpinner(false);
				
				//check if user already created factors outside of this dynamic parameters UI: IR-676267-3DEXPERIENCER2018x
				if(JSONData && JSONData.steps && thatComp.stepname && JSONData.steps[thatComp.stepname] && JSONData.steps[thatComp.stepname].factors) {
					factors = JSONData.steps[thatComp.stepname].factors;
				}
				if(JSONData.parameters && JSONData.parameters.length < 1 && (factors.length > 0)){
					thatComp.showError('WARNING: Found existing parameters', 'This activity already has parameters defined.\nAdding parameters will replace existing configuration.', 'Read Parameters', false);
				}

			})['catch'](function(err){
				thatComp.showSpinner(false);
				//thatComp.parametersDialog.close();
				thatComp.showError('Failed to read parameters', err, 'Read Parameters', true);
			});
			
		},
		onOK: function(tableUI, immersiveFrame, Dialog){
			this.showSpinner();
			this.setMessage("Saving changes ...");
			if(tableUI && tableUI != null){
				var rows = tableUI.getRoots();
				var selectedFactors = [];
				//handle factors
				for(var rowIndx = 0; rows && rowIndx < rows.length; rowIndx++){
					var row = rows[rowIndx];
					var dType = row.options.grid.datatype;
					if(dType && dType.toLowerCase() !== 'real' && dType.toLowerCase() !== 'integer') row.options.grid.factor = false;
					var paramName = row.options.grid.name;
					if(paramName === undefined || paramName === null || paramName.length < 1){
						this.showSpinner(false);
						this.showError('Parameter name cannot be empty', 'Empty parameter names are not allowed.\nPlease provide a valid name', 'Parameters Update', false);
						return;
					}
					if(!this.allowfactors || this.allowfactors.toLowerCase() === 'false' || this.allowfactors === false || row.options.grid.factor === undefined || row.options.grid.factor === true){
						selectedFactors.push(paramName);
					}
				}
				
				this.dynamicValue.parameters = [];
				this.dynamicValue.removeparameters = this.toRemove.slice();
				this.toRemove = [];
				var params = this.dynamicValue.parameters;
				this.dynamicValue.steps = {}; 
				if(this.stepname === undefined || this.stepname === null) this.stepname = 'DOE';
				this.dynamicValue.steps[this.stepname] = {};
				var TO3DXMAP, FROM3DXMAP;
				if(this.kwstepname && this.kwstepname !== null && this.kwstepname !== ''){
					this.dynamicValue.steps[this.kwstepname] = {};
					this.dynamicValue.steps[this.kwstepname].TO3DX = [];
					this.dynamicValue.steps[this.kwstepname].FROM3DX = [];
					TO3DXMAP = this.dynamicValue.steps[this.kwstepname].TO3DX;
					FROM3DXMAP = this.dynamicValue.steps[this.kwstepname].FROM3DX;
				}
				if(!this.widgettype || this.widgettype === 'Design Parameters') this.dynamicValue.steps[this.stepname].factors = [];
				else if(this.widgettype === 'Constraints') this.dynamicValue.steps[this.stepname].constraints = [];
				else this.dynamicValue.steps[this.stepname].responses = [];
				var factors = this.dynamicValue.steps[this.stepname].factors;
				var responses = this.dynamicValue.steps[this.stepname].responses;
				var constraints = this.dynamicValue.steps[this.stepname].constraints;
				for(var rowIndx = 0; rows && rowIndx < rows.length; rowIndx++){
					var row = rows[rowIndx];
					params.push(this.getRowParam(row));
					if(!this.widgettype || this.widgettype === 'Design Parameters') {
						if(!selectedFactors || selectedFactors.indexOf(row.options.grid.name) >= 0) factors.push(this.getRowFactor(row));
					}
					else if(this.widgettype === 'Constraints') constraints.push(this.getRowFactor(row));
					else responses.push(this.getRowFactor(row));
				}
				
				var kwrows = rows.concat(this.responseAndConstraintRows);
				
				for(var rowIndx = 0; rows && rowIndx < kwrows.length; rowIndx++){
					var row = kwrows[rowIndx];
					if(TO3DXMAP || FROM3DXMAP){
						var kwmap = this.getRowKWMap(row);
						if(kwmap && kwmap !== null){
							if((!this.widgettype || this.widgettype === 'Design Parameters') && TO3DXMAP) TO3DXMAP.push(kwmap);
							else if(FROM3DXMAP) FROM3DXMAP.push(kwmap);
						}
					}
				}

				console.log(this.dynamicValue);
				//console.log(this.rawvalue);
				if(Dialog !== undefined && Dialog !== null){
					if(Dialog.content) Dialog.content.disabled = true;
					else Dialog.disabled = true;
				}
				
				this.saveParameters();
			}
		},
		
		saveParameters: function(){
			var thatComp = this;			
			require(['DS/SMAProcWebCMMUtils/SMAProcWebCMMParser'],
					function(SMAProcWebCMMParser){
				SMAProcWebCMMParser.parseJSON(this.dynamicValue, this.rawvalue.parentId, this.rawvalue.sequence, thatComp).then(function(process){
					if(thatComp && thatComp.closeDialog) thatComp.closeDialog(true);
				})['catch'](function(err) {
					console.warn('Failed to modify process');
					//window.alert(err);
					//if(Dialog !== undefined && Dialog !== null) Dialog.close();
					//if(immersiveFrame !== undefined && immersiveFrame !== null) immersiveFrame.remove();
					//if(Dialog !== undefined && Dialog !== null) Dialog.webComp = null;
					thatComp.showError('Failed to modify process', err, 'Parameters Update', false);
				});

			}.bind(this));
		},

		getDynamicParameters: function(){
			var thatComp = this;
			var dynamicValue = {};
			dynamicValue.steps = {};
			if(this.stepname === undefined || this.stepname === null) this.stepname = 'DOE';
			dynamicValue.steps[this.stepname] = {};
			var TO3DXMAP, FROM3DXMAP;
			if(this.kwstepname && this.kwstepname !== null && this.kwstepname !== ''){
				dynamicValue.steps[this.kwstepname] = {};
				dynamicValue.steps[this.kwstepname].TO3DX = [];
				dynamicValue.steps[this.kwstepname].FROM3DX = [];
			}
			if(!this.widgettype || this.widgettype === 'Design Parameters') dynamicValue.steps[this.stepname].factors = [];
			else if(this.widgettype === 'Constraints') dynamicValue.steps[this.stepname].constraints = [];
			else dynamicValue.steps[this.stepname].responses = [];
			return new Promise(function(resolve, reject){
				if(thatComp.rawvalue === undefined || thatComp.rawvalue === null || true == thatComp._isDisabled()) {
					resolve({});
					return;
				}
				if(thatComp.rawvalue && false == thatComp._isDisabled()){
					require(['DS/SMAProcWebCMMUtils/SMAProcWebCMMParser'],
							function(SMAProcWebCMMParser){
						SMAProcWebCMMParser.getDynamicParameters(thatComp.rawvalue.parentId, thatComp.rawvalue.sequence, dynamicValue, thatComp).then(function(JSONData){
							resolve(JSONData);
						})['catch'](function(err) {
							console.warn('Failed to get dynamic parameters');
							//window.alert(err);
							reject(err);
						});

					}.bind(this));
				}
			});
		},
		
//		importFromFile: function(filePath){
//			
//			var checkExtRegEx = '/^([a-zA-Z0-9\s_\\.\-:])+(\.csv|\.txt)$/';
//			if(checkExtRegEx.test(filePath.toLowerCase())){ //this is valid file
//				
//			} else { //give error message
//				
//			}
//			
//		},
		
		showSpinner: function(hide){
			if(!this.progressContainer) return;
			if(hide !== undefined && hide === false){
				this.progressContainer.setStyle({'display': 'none'});
				if(this.progressSpinner) this.progressSpinner.off();
			} else {
				this.progressContainer.setStyle({'display': 'block'});
				if(this.progressSpinner) {
					this.progressSpinner.on();
					this.progressSpinner.text = 'Loading ...'; //put default label
				}
			}
		},
		
		showError: function(mainError, errorMsg, dialogTitle, closeDialog){
			if(!errorMsg) return;
			var msg = "<p><b>" + mainError + "</b></p>";
			if(!(errorMsg instanceof String)) errorMsg = errorMsg.toString();
			var errList = errorMsg.split('\n');
			msg += "<p>";
			for(var errIndx = 0; errIndx < errList.length; errIndx++){
				var errMsg = errList[errIndx].replace(/\n/g, "");
				msg += errMsg + "<br/>";
			}
			msg += "</p>";
			
			var dialogBody = new UWA.createElement('div', {styles: {
			        'vertical-align': 'center',
			        'min-height': '50px',
			        'width': '100%',
			        'height': '100%',
			        'position': 'relative'
		    	},
		    	html: msg
		    });
			
			var thatComp = this;
			
			//create error dialog
			var errorDialog = new WUXDialog({
				title: dialogTitle,
				content: dialogBody,
				minWidth: 100,
				minHeight: 70,
				resizableFlag: false,
				movableFlag: true,
				modalFlag: true,
				immersiveFrame: this.immersiveFrame,
				buttons: {
					Ok: new WUXButton({
						onClick: function (e) {
							var button = e.dsModel;
							var myDialog = button.dialog;
							if(myDialog) myDialog.close();
							if(closeDialog !== undefined && closeDialog === true && thatComp && thatComp.closeDialog){
								thatComp.closeDialog(true);
							}
							else if(thatComp && thatComp.showSpinner){
								thatComp.showSpinner(false);
							}
						}
					})
				}
			});

			errorDialog.addEventListener('close', function (e) {
				var myDialog = e.dsModel;
				if(closeDialog !== undefined && closeDialog === true && thatComp && thatComp.closeDialog){
					thatComp.closeDialog(true);
				}
			});
		},
		
		closeDialog: function(remove){
			if(this.parametersDialog) {
				this.parametersDialog.close();
				if(remove === true){
					var immersiveFrame = this.parametersDialog.immersiveFrame;
					if(immersiveFrame) immersiveFrame.remove();
					if(this.parametersDialog.immersiveFrame) this.parametersDialog.immersiveFrame = undefined;
					if(this.parametersDialog.webComp) this.parametersDialog.webComp = undefined;
					this.toRemove = [];
					if(this.immersiveFrame) this.immersiveFrame = undefined;
				}
			}
		},
		
		setMessage: function(msg){
			if(msg && this.progressSpinner) this.progressSpinner.text = msg;
		},

		/**
		 * if component is disabled
		 * @param  {Object} rawvalue Rawvalue
		 * @return {Boolean} is component disabled or not
		 */
		_isDisabled: function (rawvalue) {
			this._adp = this._adp || this.XS();
			if (this._adp && this._adp.whichMode && this._adp.whichMode() !== 'instantiate' && this._adp.whichMode() !== 'run' && this._adp.isInDesignMode() === false) {
				return true;
			}
			return false;
		},
		
		isJobRunning: function(jobstatus){
			return jobstatus === 'Running' || jobstatus === 'Paused' || jobstatus === 'Waiting' || jobstatus === 'Queued';
		},

		jobstatusChanged: function(jobstatus, oldstatus) {
			this.computeDisabled();
		},

		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	}); 

});

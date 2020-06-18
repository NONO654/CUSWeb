// Copyright 2016 Dassault Systemes Simulia Corp.

/*  @module SMAProcXSWidgets.mweb
	@submodule xs-wg-xyplot

	@description
				This Polymer webcomponent is used to show the plot using 2D Array

	@example
	<xs-wg-xyplot id="xsplot" value="{{xs_wg_plm_data_1}}"></xs-wg-xyplot>

*/
/* global DS, Polymer*/

(function () {
	'use strict';

	// Prototype
	Polymer({ // jshint ignore:line
		is: 'xs-wg-xyplot',
		properties: {

			value: {
				type: String,
				notify: true,
				observer: '_applyData'
			},

			label: {
				type: String,
				notify: true
			},

			xname: {
				type: String,
				notify: true,
				observer: '_applyData'
			},

			yname: {
				type: String,
				notify: true,
				observer: '_ynameChanged'
			},

			xaxis: {
				type: String,
				value: '1',
				notify: true,
				observer: '_xaxisChanged'
			},

			yaxis: {
				type: String,
				value: '2',
				notify: true,
				observer: '_yaxisChanged'
			},
			size: {
				type: String,
				notify: true,
				value: 'Small',
				observer: '_applyData'
			},
			direction: {
				type: String,
				notify: true,
				value: 'Row',
				observer: '_applyData'
			}

		},

		_getXYFormattedData: function (data) {
			var xname = this.xname ? this.xname.trim() : undefined;
			var XYData = xname + ',' + undefined + this._getData(data);
			return XYData;
		},

		_getData: function (inData) {
			var data, i, j, axis, XYData, parsedData, colSize, axisData, axisSize, rowtemp, cell;
			axis = this.xaxis + ',' + this.yaxis;
			XYData = '';
			if (this.direction === 'Row') {
				JSON.parse(inData).forEach(function (row) {
					XYData += '\r\n';
					axis.split(',').forEach(function (axisindex) {
						if (!(isNaN(axisindex) || axisindex === null)) {
							data = row.children[Number(axisindex) - 1] ? row.children[Number(axisindex) - 1].data : '0';
							if (!data) {
								data = 0;
							}
							if (Number(data) !== 0) {
								this._allZeros = false;
							}
							XYData = XYData + data + ',';
						}
					}, this);
					XYData = XYData.slice(0, -1);
				}, this);
			} else {
				parsedData = JSON.parse(inData);
				colSize = parsedData[0].children.length;
				axisData = axis.split(',');
				axisSize = axisData.length;

				for (i = 0; i < colSize; i += 1) {
					XYData += '\r\n';
					for (j = 0; j < axisSize; j += 1) {
						rowtemp = parsedData[axisData[j] - 1] ? parsedData[axisData[j] - 1] : [];
						cell = 0;
						if (rowtemp.children && rowtemp.children[i]) {
							cell = rowtemp.children[i].data ? rowtemp.children[i].data : 0;
						}
						if (Number(cell) !== 0) {
							this._allZeros = false;
						}
						XYData = XYData + cell + ',';
					}
					XYData = XYData.slice(0, -1);
				}
			}

			return XYData;
		},

		// public method to return type
		returnDatatype: function (propertyName) {
			if (propertyName === 'xaxis') {
				return 'Number';
			}			else if (propertyName === 'yaxis') {
				return 'NumberArray';
			}
			return '';
		},

		_xaxisChanged: function () {
			if (isNaN(this.xaxis) || this.xaxis === null) {
				this.xaxis = '1';
			}
			this._applyData();
		},

		_yaxisChanged: function () {
			var yindexes, yaxisArray;
			if (this.yaxis && this.yaxis.split) {
				yindexes = this.yaxis.split(',');
				yaxisArray = [];
				yindexes.forEach(function (yindex) {
					if (yindex.trim() === '') {
						yaxisArray.push('');
					} else if (isNaN(yindex) || yindex === null) {
						yaxisArray.push('2');
					} else {
						yaxisArray.push(yindex.trim());
					}
				}, this);
				this.yaxis = yaxisArray.join(',');
				this._applyData();
			} else {
				this.yaxis = '2';
			}
		},

		_ynameChanged: function () {
			var ynameIndices, yaxisArray = [];
			if (this.yname && this.yname.split) {
				ynameIndices = this.yname.split(',');
				yaxisArray.push('');
				ynameIndices.forEach(function (yindex) {
					if (yindex.trim() === '') {
						yaxisArray.push('');
					} else {
						yaxisArray.push(yindex.trim());
					}
				}, this);
				this.yaxisNameArray = yaxisArray;
				this._applyData();
			} else {
				this.yaxisNameArray = [];
				this._applyData();
			}
		},


		_applyData: function () {
			var xyplotdata, variableNameList = [], xname;
			if (this.value === undefined || this.value === null) {
				if (this.$.plot.clearMainPlot) {
					this.$.plot.clearMainPlot();
				}
			} else if (this.value.indexOf('{') !== 0 && this.$.plot.isAttached) {
				this._allZeros = true;
				xyplotdata = this._getXYFormattedData(this.value);
				xname = this.xname ? this.xname.trim() : undefined;
				variableNameList.push(xname);
				if (!this._allZeros) {
					this.$.xycontainer.classList.remove('no-data');
					this.$.container.classList.remove('no-data');
				} else {
					this.$.xycontainer.classList.add('no-data');
					this.$.container.classList.add('no-data');
				}
				this.async(function () {
					this.$.plot.clearMainPlot();
					if (!this._allZeros) {
						this.$.plot.processData(xyplotdata);
					}
					if (this.yaxisNameArray && !this._allZeros) {
						if (this.$.plot.children[3].clearLegend) {
							this.$.plot.children[3].clearLegend();
						}
						if (this.$.plot.children[3].addLegend) {
							this.$.plot.children[3].addLegend(this.yaxisNameArray);
						}
					}
					if (!this._allZeros) {
						this.$.plot.setupMainPlot(variableNameList, xname, this.label, true);
					}
				}.bind(this), 200);
			}
		},

		maximize: function () {
			this.$.xycontainer.classList.add('maximized');
			this._applyData();
		},

		restore: function () {
			this.$.xycontainer.classList.remove('maximized');
			this._applyData();
		},
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(this));

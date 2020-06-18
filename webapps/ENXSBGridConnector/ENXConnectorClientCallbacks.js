/**
 * @module DS/ENXSBGridConnector/ENXConnectorClientCallbacks
 * @returns a custom cell value for columns specific to typeRepresentations url and icon
 */
define('DS/ENXSBGridConnector/ENXConnectorClientCallbacks',
		['DS/Utilities/Dom',
		 'UWA/Core'], function(Dom,UWA) {
	'use strict';


	var module = Object.create(null);

	/**
	 * callback function called by the column getCellValue for column having typeRep url
	 * @param {Object} cellInfos object corresponding to the cell,
	 * @returns a javascript object with custom url
	 */
	module.buildURLCellValue = function(cellInfos) {
		if (!cellInfos.nodeModel._isFromOriginalModel()) {
			var newValue = {};
			newValue.label = cellInfos.nodeModel.getLabel();
			return newValue;
		} else {
			var newValue = {};
			var leafColumns = this.layout.getLeafColumns();
			var typeIconProperty = leafColumns[cellInfos.columnID].alternateTypeKey || "typeIcon";
			var oidProperty = leafColumns[cellInfos.columnID].alternateOIDKey || "id";
			var href = leafColumns[cellInfos.columnID].href

			if(href) {
				var oid = cellInfos.nodeModel.options.grid[oidProperty];
				var separator = href.indexOf("?")==-1?"?":"&";
				newValue.url = "../" + href + separator + "objectId=" + oid;
			}

			if(leafColumns[cellInfos.columnID].id == "Name"){
				newValue.label = cellInfos.nodeModel.options.grid["enx_name"];
			}
			else{
				newValue.label = cellInfos.nodeModel.options.grid[leafColumns[cellInfos.columnID].id];
			}

			if(leafColumns[cellInfos.columnID].showTypeIcon){
				var icon = {};
				icon.iconPath =  cellInfos.nodeModel.options.grid[typeIconProperty];
				icon.iconSize = {width: '16px', height: '16px'} ;
				newValue.icon = icon;
			}

			return newValue;
		}
	}


	/**
	 * callback function called by the column getCellValue for column having typeRep icon
	 * @param {Object} cellInfos object corresponding to the cell,
	 * @returns a javascript object with custom icon path and href along with other arguments
	 */
	module.buildIconCellValue = function(cellInfos) {

		var leafColumns = this.layout.getLeafColumns();
		var href = leafColumns[cellInfos.columnID].href
		var oid = cellInfos.nodeModel.options.grid["id"];
		var separator = href.indexOf("?")==-1?"?":"&";

		var newValue = {}, icon = {};
		newValue.module = "DS/ENXSBGridConnector/StandardFunctions";
		newValue.func = "executeDefaultAction";
		newValue.argument = {};
		newValue.argument.href = href + separator + "objectId=" + oid;
		if(cellInfos.nodeModel.options.grid["parentOID"])
			newValue.argument.href += "&parentOID="+ cellInfos.nodeModel.options.grid["parentOID"];
		if(cellInfos.nodeModel.options.grid["relId"])
			newValue.argument.href += "&relId="+ cellInfos.nodeModel.options.grid["relId"];
		if(leafColumns[cellInfos.columnID].suiteKey)
			newValue.argument.href += "&suiteKey="+ leafColumns[cellInfos.columnID].suiteKey;
		newValue.argument.href += "&emxSuiteDirectory=components";
		newValue.argument.href += "&jsTreeID=undefined";

		newValue.argument.target = leafColumns[cellInfos.columnID].targetLocation;
		newValue.argument.width = leafColumns[cellInfos.columnID].windowWidth;
		newValue.argument.height = leafColumns[cellInfos.columnID].windowHeight;
		//TODO
		// the below part is temporarily commented because we are setting the icon on the treeNodeModel as the icon has to be shared between different display modes
		// once the showTreeIconFlag is delivered by techno, the below code can be uncommented

		icon.iconPath =  "../" + leafColumns[cellInfos.columnID].icon;
		icon.iconSize = {width: '16px', height: '16px'} ;
		newValue.icon = icon;

		return newValue;
	}

	module.buildTypeIconCellValue = function(cellInfos) {
		if (!cellInfos.nodeModel._isFromOriginalModel()) {
			return cellInfos.nodeModel.getLabel();
		} else {
			var leafColumns = this.layout.getLeafColumns();
			var typeIconProperty = leafColumns[cellInfos.columnID].alternateTypeKey || "typeIcon";
			/*this._view = [];

			this._labelDiv = UWA.createElement('a', {'class': 'wux-tweakers-string-label'});
			this._labelDiv.innerHTML = cellInfos.nodeModel.options.grid['treeLabel'];
	//		this._labelDiv = cellInfos.nodeModel.options.grid['treeLabel'];
	        this._iconDiv = UWA.createElement('span', {'class': 'wux-tweakers-string-icon'});
	        this._view.push(this._iconDiv);
	        this._view.push(this._labelDiv);

	        var icon = {};
			icon.iconPath =  cellInfos.nodeModel.options.grid[typeIconProperty];
			icon.iconSize = {width: '16px', height: '16px'} ;


	        if (icon) {
	            Dom.generateIcon(icon, {target: this._iconDiv});
	          }*/


			/*var span = document.createElement('span');
			span.className = "wux-tweakers-string-icon wux-ui-genereatedicon-backgroundimage";
			span.style.backgroundImage = 'url(' + cellInfos.nodeModel.options.grid[typeIconProperty] + ')';
			span.style.cssText = 'width: 16px; height: 16px;'
			var aNode = cellInfos.nodeModel.options.grid['treeLabel'];*/

			var columnName =  this.layout.getLeafColumns()[cellInfos.columnID].id;
			columnName = (columnName == "Name") ? "enx_name" : columnName;
			var newStr = '<span class="wux-tweakers-string-icon wux-ui-genereatedicon-backgroundimage" style="background-image: url(' +
							cellInfos.nodeModel.options.grid[typeIconProperty] + '); width: 16px; height: 16px;"></span>' +
							cellInfos.nodeModel.options.grid[columnName];

			/*var newStr = '<span class="wux-tweakers-string-icon wux-ui-genereatedicon-backgroundimage"></span>' +
			cellInfos.nodeModel.options.grid['treeLabel'];*/

			return newStr;
		}
	},

	module.setURLCellValue = function(cellInfos, value) {
		var gridProperty = this.layout.getLeafColumns()[cellInfos.columnID].id;
		if((gridProperty == "treeLabel")){
		cellInfos.nodeModel.updateOptions({
	              grid: {
	            	  tree: value,
	            	  "treeLabel" : value.label
	              }
	            });
		}
	}

	return module;
});

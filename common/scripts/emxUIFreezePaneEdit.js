//Util getters
var emxUIFreezepaneEdit = new Object();
function get(id)
{
	var result = null;
	if(id instanceof Array)
	{
		result = [];
		for(var i = 0; i < id.length; i++)
		{
			result.push(document.getElementById(id[i]));
		}
	}else
	{
		result = document.getElementById(id)
	}
	return result;
}

function setClass(elem,className)
{
	if(elem instanceof Array)
	{
		for(var i = 0; i < elem.length; i++)
		{
			if(elem[i]){ 
				elem[i].className = className;
			}
		}
	}
	else if(elem != null) 
	{
		elem.className = className;
	}
}

function getRow(rowId)
{
	return getNode(oXML, "/mxRoot/rows//r[@id = '" + rowId + "']");
}
function getRowId(row)
{
	return getAttribute(row,"rowId");
}
function getId(row)
{
	return getAttribute(row,"id");
}
function getError(rowId)
{
	var row = getRow(rowId);
	return getAttribute(row, "e");
}
function getColumns(row)
{
	return getNodes(row,"c");
}
function getName(column)
{
	return getAttribute(column,"name");
}
function getElement(name)
{
	return oXML.createElement(name).cloneNode(true);
}
function getTextNode(text)
{
	return oXML.createTextNode(text).cloneNode(true);
}
function getNode(xml,xpath)
{
	return emxUICore.selectSingleNode(xml,xpath);
}
function getNodes(xml,xpath)
{
	return emxUICore.selectNodes(xml,xpath);
}
function getText(node)
{
	return node != null ? emxUICore.getText(node) : "";
}
function setText(node,value)
{
	return emxUICore.setText(node,value);
}
function getStatus(row)
{
	return getAttribute(row,"status");
}
function getAttribute(row,atr)
{
	var value = row != null ? row.getAttribute(atr) : null;
	return value != null ? value : "";
}

function getColumnNames(columns)
{
	var names = [];
	for(var i = 0; i < columns.length; i++)
	{
		names.push(columns[i].name);
	}
	return names;
}

function getSetting(column, setting)
{
	var value    = column.getSetting(setting);
	value        = value && value != null ? value : "";
	return value;
}

function isInlineRow(row)
{
	var status = getStatus(row);
	return status == "new" || status == "lookup";
}

function isRequiredColumn(column,action)
{
	var required = getSetting(column,"Required");
	return (required == "true" || required == "TRUE" ? true : false);
}

function isCellEditable(cell)
{
	var editMask = getAttribute(cell,"editMask");
	return editMask != "false";
}

function isMandatoryColumn(column, action)
{
	var addInputType    = getSetting(column,"Add Input Type");
	var lookupInputType = getSetting(column,"Lookup Input Type");
	var mandatory       = false;
	if(action == "new")
	{
		mandatory = (addInputType.length > 0);
	}else if (action == "lookup")
	{
		mandatory = (lookupInputType.length > 0);
	}else
	{
		mandatory = (addInputType.length > 0 || lookupInputType.length > 0);
	}
	
	return mandatory;
}

function getMandatoryColumns(action)
{
	var columns = [];
	for(var i = 0; i < colMap.columns.length; i++)
	{
 		 if(isMandatoryColumn(colMap.columns[i], action)) 
 		 {
 		 	columns.push(colMap.columns[i]);
 		 }
 	}
 	return columns;
}

function getRequiredColumns(action)
{
	var columns = [];
	for(var i = 0; i < colMap.columns.length; i++)
	{
 		 if(isRequiredColumn(colMap.columns[i], action)) 
 		 {
 		 	columns.push(colMap.columns[i]);
 		 }
 	}
 	return columns;
}

function styleMandatoryColumns()
{
	var lookups = getNodes(oXML,"/mxRoot/rows//r[@status='lookup']");
	var news    = getNodes(oXML,"/mxRoot/rows//r[@status='new']");
	var action  = "both";
	var total	= lookups.length + news.length;
	if(lookups.length > 0 && news.length == 0)
		action = "lookup";
	else if(news.length > 0 && lookups.length == 0)
		action = "new";
	//else if(lookups.length > 0 && news.length > 0)
		//action = "both";
	
	var mColumns   = getColumnNames(getMandatoryColumns(action));
	var rColumns   = getColumnNames(getRequiredColumns(action));
	var mClassName = editableTable.mode == "edit" && total != 0 ? "mx_editable mx_required" : "mx_editable";
	var rClassName = editableTable.mode == "edit" ? "mx_editable mx_required" : "mx_editable";
	var mElems = get(mColumns);
	setClass(mElems,mClassName);
	var rElems = get(rColumns);
	setClass(rElems,rClassName);
}

function validateState(selection)
{
	var checkboxes = getCheckedCheckboxes();
    var selectedCount = 0;
    for (var e in checkboxes){
        	selectedCount++;
    }
    if (selection == "single" && selectedCount > 1) {
        showError(emxUIConstants.ERR_SELECTION);
        return false;
    }
    return true;
}

function getCheckedIds()
{
	var checked = getNode(oXML,"/mxRoot/rows//r[@checked='checked']");
	checked     = checked == null ?  getNode(oXML,"/mxRoot/rows//r[@id='0']") : checked;
	return checked != null ? [getAttribute(checked,"r"), getAttribute(checked,"o"),getAttribute(checked,"p"),getAttribute(checked,"id") ] : ["","","",""];
}

function fillUpDefaults(prow, crow, adefaults,ddefaults)
{
	var pcolumns = getNodes(prow,"c");
	var hascols  = pcolumns.length != 0;
	pcolumns     = hascols ? pcolumns : colMap.columns;
	
	for(var i = 0; i < pcolumns.length; i++)
	{
		if(!pcolumns[i].getAttribute('GSBImgCol')){
		var column = hascols ? pcolumns[i].cloneNode(true) : getElement("c");
		column.setAttribute("a",adefaults[i]);
		column.setAttribute("styleCell","");
		column.setAttribute("styleColumn","");
		column.setAttribute("styleRow","");
		column.removeAttribute("i");
		column.removeAttribute("rte");
		column.removeAttribute("editMask");
		column.removeAttribute("FPRootCol");
		emxUICore.setText(column, ddefaults[i]);
		crow.appendChild(column);
	}
}
}

function expandRow(row)
{
	if(row != null && row.tagName == 'r')
	{
	  	var expand = getAttribute(row,"expand");
	  	if(!expand)
	  	{
			var childXml = emxUICore.getXMLData("../common/emxFreezePaneGetData.jsp?fpTimeStamp=" + timeStamp +
								"&levelId=" + getAttribute(row,"id") +"&IsStructureCompare="+isStructureCompare+ "&toolbarData=updateTableCache=true");	
			if (childXml)
			{
				var children = getNodes(childXml, "/mxRoot/rows/r");
				for (var i = 0; i < children.length; i++) {
					row.appendChild(children[i].cloneNode(true));
				}
				row.setAttribute("display", "block");
				row.setAttribute("expand", "true");
				if(getAttribute(row, "expandedLevels") == ""){
					row.setAttribute("expandedLevels", "1");
				}
			}
	  	}
	  	row.setAttribute("display","block");
	  	return getNodes(row,"r").length;
  	}

  	return 0;
}

// Entry point for Inline editing functions from the toolbar commands

function createNewChildRow() {
	_newInlineChild("new","current");
}

function createNewChildRowAbove() {
	_newInlineChild("new","above");
}

function createNewChildRowBelow() {
	_newInlineChild("new","below");
}

function addExistingChildRow() {
	_newInlineChild("lookup","current");
}

function addExistingChildRowAbove() {
	_newInlineChild("lookup","above");
}

function addExistingChildRowBelow() {
	_newInlineChild("lookup","below");
}

//END - entry points

function validateNewRows(state,rowIds)
{
	var eNodes = getNodes(oXML,"/mxRoot/rows//r[@e]");
	
	for(var i = 0; i < eNodes.length; i++)
	{
		eNodes[i].removeAttribute("e");
	}
	var markup = state ? "lookup" : "new";
	var newRows = [];
	// Added for user defined look up
	if(rowIds && rowIds instanceof Array){
		for(var i=0;i<rowIds.length;i++){
			newRows.push(getNode(oXML, "/mxRoot/rows//r[@id='"+ rowIds[i] +"']"));
		}
	}else{
		newRows = getNodes(oXML, "/mxRoot/rows//r[@status='"+ markup +"']");
	}
	// End
	var rRows   = getNodes(oXML, "/mxRoot/rows//r[@status='add' or @status='changed' or @status='resequence']");
	var removes  = [];
	var valids   = [];
	for(var i = 0; i < newRows.length; i++)
	{
		if(!validNewRow(newRows[i]))
		{
			removes.push(newRows[i]);
		}else
		{
			valids.push(newRows[i]);
		}
	}
	_removeNewRows(removes, removes.length > 0);
	return _validateRows(valids, rRows, markup);
}

function _validateRows(rows, rRows, markup)
{
	var validated = true;
	var error     = [];
	error.push("<mxRoot>");
	for(var i = 0; i < rows.length; i++)
	{
		var valid = _validateMandatoryRow(rows[i],markup);
		if(valid != true)
		{
			validated = false;
			error.push("<object rowId=\"" + getId(rows[i]) + "\">")
			error.push("<error><![CDATA[" + valid + "]]></error></object>");
		}
	}

	if(markup != "lookup")
	{
		for(var i = 0; i < rRows.length; i++)
		{
			var valid = _validateRequiredRow(rRows[i],markup);
			if(valid != true)
			{
				validated = false;
				error.push("<object rowId=\"" + getId(rRows[i]) + "\">")
				error.push("<error><![CDATA[" + valid + "]]></error></object>");
			}
		}
	}

	error.push("</mxRoot>");
	if(!validated){
		emxEditableTable.displayValidationMessages(error.join(""));
	}
	validated = validated ? _validateInlineRows(rows,markup) : validated;
	return validated;
}

function _validateRequiredRow(row,markup)
{
	var validated = true;
	var rColumns  = getRequiredColumns(markup);
	for(var i = 0; i < rColumns.length; i++)
	{
		var index  = rColumns[i].index;
		var cell   = getNode(row,"c["+ (index) +"]");
 		if(isCellEditable(cell))
 		{
			var cellvalue = getText(cell);
	 		validated 	  = cellvalue != null && cellvalue.length > 0;
	 		if(!validated)
	 		{
	 			validated = emxUIConstants.ERR_MANDATORY;
	 			break;
	 		}
 		}
	}
	return validated;
}

function _validateMandatoryRow(row,markup)
{
	var validated = true;
	for(var i = 0; i < colMap.columns.length; i++)
	{
 		 if(isMandatoryColumn(colMap.columns[i], markup) || (markup != "lookup" && isRequiredColumn(colMap.columns[i], markup)))
 		 {
 		 	var cell = getNode(row,"c[" + ( i + 1 ) + "]");
 		 	if(isCellEditable(cell))
 		 	{
	 		 	var cellvalue = getText(cell);
	     		validated 	  = cellvalue != null && cellvalue.length > 0;
	     		if(!validated)
	     		{
	     			validated = emxUIConstants.ERR_MANDATORY;
	     			break;
	     		}
     		}
 		 }
	}
	return validated;
}

function _validateInlineRows(rows,markup)
{
	var validated = true;
	for(var i = 0; i < rows.length; i++)
	{
		validated = _validateInlineRow(rows[i],markup);
		if(!validated)
			break;
	}
	return validated;
}

function _validateInlineRow(row,markup)
{
	var validated = true;
	for(var i = 0; i < colMap.columns.length; i++)
	{
		 var theValidator = getSetting(colMap.columns[i], "Validate");
 		 var cellvalue    = getText(getNode(row,"c[" + ( i + 1 ) + "]"));
 		 if(theValidator && theValidator.length > 0 && (cellvalue == null || cellvalue == ""))
 		 {
     		validated 	  = eval(theValidator + "('" +cellvalue+ "','" + markup + "')");
     		if(!validated)
     			break;
 		 }
	}
	return validated;
}

function validNewRow(newRow)
{
	var result = false;
	var columns = getNodes(newRow,"c");
	for(var i = 0; i < columns.length; i++)
	{
		if(!(getText(columns[i]) == ""))
		{
			result = true;
			break;
		}
	}
	return result;
}

function _removeNewRows(checkedNewRows, refresh)
{
	if(checkedNewRows.length > 0)
	{
		unRegisterSelectedRows(checkedNewRows);
	    clearPostDataXML(checkedNewRows);
	    for(var i = 0; i < checkedNewRows.length; i++)
		{
	    	checkedNewRows[i].parentNode.removeChild(checkedNewRows[i]);
		}	    
	}
	if(refresh){
		rebuildView();
	}
}

function removeNewRows()
{
	var checkedRows    = getNodes(oXML, "/mxRoot/rows//r[@checked='checked']");
	var checkedNewRows = getNodes(oXML, "/mxRoot/rows//r[@checked='checked' and (@status='new' or @status='lookup' or @status='add')]");
    if(checkedRows.length > 0 && checkedRows.length == checkedNewRows.length)
    {
	    editableTable.undo(checkedNewRows, false);
    }else
    {
    	showError(emxUIConstants.ERR_REMOVE);
    }
}

function _validParent(prow)
{
	var status = getStatus(prow);
	return (status != "cut" && status != "resequence");
}

function _newInlineChild(markup,insertAction){
	var rowsContent = getNode(oXML, "/mxRoot/rows");
	var isSingleRoot = getNode(oXML,"/mxRoot/rows//r[@id='0']") ? true : false;
	if(rowsContent.firstChild != null){
	var rowGrouping = emxUICore.selectNodes(oXML,"/mxRoot/setting[@name='groupLevel']");
	var bGroupChecked = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@checked='checked' and @rg]");
	
	if( rowGrouping.length > 0 && bGroupChecked.length > 0 ){
		_newGroupingInlineChild(markup);
	}else{
		if(validateState("single")){
				//getCheckedIds() : returns an array with [relId, checkedId, parentId, checkedRowId]
			var ids = getCheckedIds();
			var checkedId = ids[1];
			var parentCheckedId = ids[2];
			var checkedRowId = ids[3];
			var indented  = getRequestSetting('isIndentedView') == 'true';
				var rows = getNode(oXML, "/mxRoot/rows");
			if(!indented){
					//Flat Mode Structure Browser
				var level = 0;
					var createdRow = createBlankRow(markup, level, '', '', '');
			
					if((insertAction == "current" || checkedId == "") && (checkedRowId.length == 0)){
					fillUpDefaults(rows.firstChild, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
					rows.insertBefore(createdRow.cloneNode(true),rows.firstChild);
						modifyPostDataXML(createdRow, rows, markup);
				}else{
					var checkedRow = getNode(oXML, "/mxRoot/rows//r[@id = '" + checkedRowId + "']");
					if(_validParent(checkedRow)){
							if(rowGrouping.length > 0){
								//grouping ON but grouped row not checked and checked object row level is 0
								var parentCheckedRow = checkedRow.parentNode;
								insertRowToSubGroups(markup,mapGroupId[parentCheckedRow.getAttribute("id")],insertAction,checkedRow);
							}else{
					fillUpDefaults(checkedRow, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
						if(insertAction == "above"){
							rows.insertBefore(createdRow.cloneNode(true),checkedRow);
						} else if(insertAction == "below") {
							if(checkedRow.nextSibling != null) {
								rows.insertBefore(createdRow.cloneNode(true),checkedRow.nextSibling);
							} else {
								rows.appendChild(createdRow.cloneNode(true));
							}
						}
								modifyPostDataXML(createdRow, rows, markup);
					}
					}
					}
				}else if(!isSingleRoot){
					// SB Multi Root Node
					if(checkedRowId.length > 0){
						//When a row is selected, blank row should be created at a particular position
						var checkedRow = getNode(oXML, "/mxRoot/rows//r[@id = '" + checkedRowId + "']");
						if(_validParent(checkedRow)){
							var direction = getAttribute(checkedRow,"d");
							var level = getAttribute(checkedRow,"level");
							level = parseInt(level);
					if(insertAction == "current"){
								level++;
								var count = expandRow(checkedRow);
								var createdRow = createBlankRow(markup, level, direction, checkedId, checkedRowId);
								fillUpDefaults(checkedRow, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
								var first = getNode(checkedRow,"r");
								if(first == null) {
						checkedRow.appendChild(createdRow.cloneNode(true));
								}else {
									checkedRow.insertBefore(createdRow.cloneNode(true),first);
								}
								modifyPostDataXML(createdRow,checkedRow, markup);
							}else{
								if(level == 0){
									//For root nodes in multi root structure
									if(rowGrouping.length > 0){
										//grouping ON but grouped row not checked and checked object row level is 0
										var parentCheckedRow = checkedRow.parentNode;
										insertRowToSubGroups(markup,mapGroupId[parentCheckedRow.getAttribute("id")],insertAction,checkedRow);
									}else{
									var createdRow = createBlankRow(markup, level, direction, '', '');
									fillUpDefaults(checkedRow, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
									if(insertAction == "above"){
						rows.insertBefore(createdRow.cloneNode(true),checkedRow);
					}else if(insertAction == "below"){
										if(checkedRow.nextSibling != null){
											rows.insertBefore(createdRow.cloneNode(true),checkedRow.nextSibling);
										}else{
											rows.appendChild(createdRow.cloneNode(true));
					}
				}	
				modifyPostDataXML(createdRow, rows, markup);
									}
			}else{
									//For nodes other than root nodes in multi root structure
									var parentCheckedRow = checkedRow.parentNode;
									var createdRow = createBlankRow(markup, level, direction, parentCheckedId, parentCheckedRow.getAttribute('id'));
									fillUpDefaults(parentCheckedRow, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
									if(insertAction == "above"){
										parentCheckedRow.insertBefore(createdRow.cloneNode(true),checkedRow);
									}else {
										var sibling = checkedRow.nextSibling;
										if(sibling == null){
											parentCheckedRow.appendChild(createdRow.cloneNode(true));
										}else{
											sibling.parentNode.insertBefore(createdRow.cloneNode(true),sibling);
										}
									}
									modifyPostDataXML(createdRow,parentCheckedRow, markup);
								}
							}
						}
					}else{
						//When no rows is selected, row should be created at the top of structure
						level = 0;
						var createdRow = createBlankRow(markup, level, direction, checkedId, checkedRowId);
						fillUpDefaults(rows.firstChild, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
						rows.insertBefore(createdRow.cloneNode(true),rows.firstChild);
						modifyPostDataXML(createdRow, rows, markup);
					}
				} else { 
					// SB Single Root Node
				var checkedRow = getNode(oXML, "/mxRoot/rows//r[@id = '" + checkedRowId + "']");
				if(_validParent(checkedRow)) {
						var isRootNode = checkedRowId.length == 1 ? true : false;
					var direction = getAttribute(checkedRow,"d");
					var level 	  = getAttribute(checkedRow,"level");
					level = parseInt(level);
					if(isRootNode || insertAction == "current"){
						level++;			
							var count = expandRow(checkedRow);
							var createdRow = createBlankRow(markup, level, direction, checkedId, checkedRowId);
						fillUpDefaults(checkedRow, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
						var first = getNode(checkedRow,"r");
						if(first == null) {
							checkedRow.appendChild(createdRow.cloneNode(true));
						}else {
							createdRow.setAttribute("d", getAttribute(checkedRow,"d"));
							checkedRow.insertBefore(createdRow.cloneNode(true),first);
						}
						modifyPostDataXML(createdRow,checkedRow, markup);
					}else if(insertAction == "above" || insertAction == "below"){
						var parentCheckedRow = checkedRow.parentNode;
							if(level == 1 && rowGrouping.length > 0){
									//grouping ON but grouped row not checked and checked row level is 1
									insertRowToSubGroups(markup,mapGroupId[parentCheckedRow.getAttribute("id")],insertAction,checkedRow);
							}else{
							var createdRow = createBlankRow(markup, level, direction, parentCheckedId, checkedRowId);
						fillUpDefaults(parentCheckedRow, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
						if(insertAction == "above"){
							parentCheckedRow.insertBefore(createdRow.cloneNode(true),checkedRow);
						}else {
							var sibling = checkedRow.nextSibling;
							if(sibling == null){
								parentCheckedRow.appendChild(createdRow.cloneNode(true));
							}else{
								sibling.parentNode.insertBefore(createdRow.cloneNode(true),sibling);
							}
						}
						modifyPostDataXML(createdRow,parentCheckedRow, markup);
					}
				}
			}
		}
	}
		}
	}else{
		//When there are no rows in the structure, create an initial row. This is applicable only in Flat mode SB and Multi root SB.
		var level = 0;
		var createdRow = createBlankRow(markup, level, '', '', '');
		
		var newElement = oXML.createElement("r");
		for(var i=0; i< colMap.columns.length; i++){  
			//Before invoking the fillUpDefaults, we need the columns created to fill up the default data
		var dummyCell = oXML.createElement("c");
        dummyCell.setAttribute("editMask", "false");
        newElement.appendChild(dummyCell);
		}
		
		fillUpDefaults(newElement, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
		rowsContent.appendChild(createdRow.cloneNode(true));
		modifyPostDataXML(createdRow,rowsContent, markup);
	}
	callToBuildColumValues("add");
	rebuildView();
}

//Creates a blank <r> tags and sets the basic values. 
//This is a private method and is not expected to be used by applications other than BPS.
// Arguements
// markup: "add" , "new".
// level: 0,1,2...
// direction: "from", "to", "".
// checkedId: will be Parent of the created row (assigned to attribute 'p')
// checkedRowId: Row id of the parent (assigned to attribute 'pid')

function createBlankRow(markup, level, direction, checkedId, checkedRowId){
	//Defaults
	// level is compulsorily be sent to this method
	if(!direction) {
		direction = "";
	}
	if(!checkedId) {
		checkedId = "";
	}
	if(!checkedRowId) {
		checkedRowId = "";
	}

	var xml = [];
	var rowdom = emxUICore.createXMLDOM();
	var childId = checkedRowId + "," + new Date().getTime();
	var ext = markup == "new" ? "expand='true' display='block'" : "";
	xml.push("<root><r t='' o='' r='' d='"+ direction +"' "+ ext +" p='"+ checkedId +"' status='"+ markup +"' pid='"+checkedRowId+"' id='"+childId+"' level='"+level+"' s='m'></r></root>");
	rowdom.loadXML(xml);
	emxUICore.checkDOMError(rowdom);
	return getNode(rowdom,"r");
}

function _newGroupingInlineChild(markup){
	if(validateCheckedGroups()){
		var checkedRows = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@checked='checked']");
		var checkedRowId = checkedRows[0].getAttribute("id");
		var groupObject = mapGroupId[checkedRowId];
		var subGroup1 = groupObject.groupSubGroups;
		if(subGroup1 == null || subGroup1.length == 0){
			insertRowToSubGroups(markup,groupObject);
		}else{
			for(var i=0; i<subGroup1.length; i++){
				var subGroup2 = subGroup1[i];
				if(subGroup2.groupSubGroups.length == 0){
					insertRowToSubGroups(markup,subGroup2);
				}else{
					for(var j=0; j<subGroup2.groupSubGroups.length; j++){
						var subGroup3 = subGroup2.groupSubGroups[j];
						insertRowToSubGroups(markup,subGroup3);
					}
				}
			}
		}
	}else{
		showError(emxUIConstants.ERR_SELECTION);
	}
}

function validateCheckedGroups(){
	var rg1GroupChecked = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@checked='checked' and @rg='rg1']");
	var rg2GroupChecked = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@checked='checked' and @rg='rg2']");
	var rg3GroupChecked = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@checked='checked' and @rg='rg3']");
	if( rg1GroupChecked.length > 0 ){
		if( rg1GroupChecked.length == 1 )
			return true;
	}else if( rg2GroupChecked.length > 0 ){
		if( rg2GroupChecked.length == 1 )
			return true;
	}else if( rg3GroupChecked.length > 0 ){
		if( rg3GroupChecked.length == 1 )
			return true;
	}
	return false;
}

/*Private method only for the use of BPS.
 * This method will insert a row below a specified group.
 * If checkedRow and insertAction are passed then a row will be added either below or above of the checked row based on insertAction.
 * If both are not passed then a row will be added as a 1st child of the group
 * */
function insertRowToSubGroups(markup,group,insertAction,checkedRow){
	var isSingleRoot = getNode(oXML,"/mxRoot/rows//r[@id='0']") ? true : false;
	var groupRow =  group.groupElement;
	var rowsOfGroup = groupRow.getElementsByTagName("r");
	var parentRow = isSingleRoot ? getNode(oXML,"/mxRoot/rows//r[@id='0']") : getNode(oXML, "/mxRoot/rows");
	var level = isSingleRoot ? 1 : 0;
	var createdRow = createBlankRow(markup, level, '', '', '');
	if(checkedRow && insertAction){
		fillUpDefaults(checkedRow, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
		if(insertAction == "above"){
			groupRow.insertBefore(createdRow.cloneNode(true),checkedRow);
		}else{
			var sibling = checkedRow.nextSibling;
			if(sibling == null){
				groupRow.appendChild(createdRow.cloneNode(true));
			}else{
				groupRow.insertBefore(createdRow.cloneNode(true),sibling);
			}
		}
	}else if( rowsOfGroup == null || rowsOfGroup.length == 0){
		if(isSingleRoot){
			fillUpDefaults(parentRow, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
		}else{
			var firstChild = getNode(oXML,"/mxRoot/rows//r[@id='0,0']");
			fillUpDefaults(firstChild, createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
		}
		groupRow.appendChild(createdRow.cloneNode(true));
	}else{
		fillUpDefaults(rowsOfGroup[0], createdRow, colMap.getDefaultValues(markup),colMap.getDefaultDisplayValues(markup));
		groupRow.insertBefore(createdRow.cloneNode(true),rowsOfGroup[0]);
	}
	group.groupCount += 1;
	group.groupElement.setAttribute("count", group.groupCount);

		modifyPostDataXML(createdRow, parentRow, markup);
}

/*
 * This API can be used to look up specific row/s intead of all rows(whose status is "lookup"). 
 * usecase: suppose user added 3 inline rows through "+" icon and started filling the row information.
 * Once user filled up all the required cells for a particular inline row and before moving to the next  row
 * the row can be validated instantly using this API. This save's user time.
 * 
 * This is used by Apparel Team.
 */

emxEditableTable.lookupRows = function __lookupRows(lookupRowIds){
	
	if(lookupRowIds && lookupRowIds instanceof Array){
		lookupAction(lookupRowIds);
	}else{
		lookupAction();
	}
};

function lookupAction(lookupRowIds)
{
 	if(!validateNewRows(true,lookupRowIds)){
 	 	return;
 	}
	var lookupRows = getLookupRowObjs(lookupRowIds);
	var lookupJPO   = getRequestSetting("lookupJPO");
	lookupJPO       = lookupJPO != null ? lookupJPO.split(":") : [];
	
	if(lookupRows.length > 0 && lookupJPO.length == 2)
	{
		var lookupUrl = "../common/emxFreezePaneInlineProcess.jsp?timeStamp="+timeStamp+"&program="+lookupJPO[0]+"&function="+lookupJPO[1];
		var lookupXml = emxUICore.createXMLDOM();
		lookupXml.loadXML("<mxRoot/>");

		for(var i = 0; i < lookupRows.length; i++)
		{
			lookupXml.documentElement.appendChild(toLookupRow(lookupRows[i]));
		}

		lookupXml = emxUICore.getXMLDataPost(lookupUrl, lookupXml);

		if(validateResponse(lookupXml))
		{
			mergePostDataXML(getNodes(lookupXml,"object[@status='success']"));
			showErrors(getNodes(lookupXml,"object[@status='fail']"));
		}
	}
}

function getLookupRowObjs(lookupRowIds){
	
	var lookupRows = [];
	var theRoot = postDataXML.documentElement;
	if(lookupRowIds && lookupRowIds instanceof Array){
		for(var i = 0;i<lookupRowIds.length;i++){
			var lookupRowId = lookupRowIds[i];
			var lookupRowObj = getNode(theRoot,"/mxRoot//object[@rowId='"+lookupRowId+"']");
			if(lookupRowObj){
				lookupRows.push(lookupRowObj);
			}
		}
	}else{
		lookupRows  = getNodes(theRoot,"/mxRoot//object[@markup='lookup']");
	}
	return lookupRows;
}

function toLookupRow(row)
{
	var crow = row.cloneNode(true);
	var orow = getRow(getRowId(row));
	var pid  = getAttribute(orow,"p");
	crow.setAttribute("parentId",pid);

	/* Commented for IR-085013
	var columns = getColumns(orow);
    for(var i = 0; i < columns.length; i++)
    {
    	var column = getElement("column");
    	column.setAttribute("name", colMap.getColumnByIndex(i).name);
    	column.setAttribute("edited","true");
    	emxUICore.setText(column,getText(columns[i]));
    	crow.appendChild(column);
    }*/

    return crow;
}

function validateResponse(response)
{
	var error = getNode(response,"error")
	if(error != null)
	{
		showError(getText(error));
		return false;
	}
	return true;
}

function showErrors(errors)
{
	var errorDom = emxUICore.createXMLDOM();
	errorDom.loadXML("<mxRoot/>");
	for(var i = 0; i < errors.length; i++)
	{
    	errorDom.documentElement.appendChild(errors[i].cloneNode(true));
    }
	emxEditableTable.displayValidationMessages(errorDom.xml);
}

function clearPostDataXML(rows)
{
	for(var i = 0; i < rows.length; i++)
	{
		var nodes = getNodes(postDataXML,"/mxRoot//object[@rowId='" + getId(rows[i]) + "']");
		for(var l = 0; l < nodes.length; l++)
		{
			var parentNode = nodes[l].parentNode;
			parentNode.removeChild(nodes[l]);
			if(parentNode.childNodes.length == 0 && parentNode.parentNode != null && parentNode.parentNode.tagName == "mxRoot"){
				parentNode.parentNode.removeChild(parentNode);
			}
		}
	}
}

function mergePostDataXML(rows)
{
	for(var i = 0; i < rows.length; i++)
	{
		var row = rows[i];
		var postNode = getNode(postDataXML,"/mxRoot//object[@rowId='" + getRowId(row) + "']");
		postNode.setAttribute("rowId", getAttribute(row,"nId"));
		postNode.setAttribute("objectId",getId(row));
		postNode.setAttribute("markup","add");

		var oNode = getNode(oXML, "/mxRoot/rows//r[@id = '" + getRowId(row) + "']");
		oNode.setAttribute("id", getAttribute(row,"nId"));
		oNode.setAttribute("cached", "true");
		oNode.setAttribute("o",getId(row));
		var columns = getColumns(oNode);
		var oColumns= columns;
		var flag =[];
		for(var l = 0; l < columns.length; l++)
		{
			var text = getText(columns[l]);
			if(text != null && text != "" ){
				flag[l]=true;
			}else{
				flag[l]=false;
			}
			columns[l].parentNode.removeChild(columns[l]);
		}
		var pcolms = getNodes(postNode,"column");
		columns = getColumns(row);
		for(var l = 0; l < columns.length; l++)
		{
			var text = getText(columns[l]);
			//if(text != null && text.length > 0) {
				//columns[l].setAttribute("editedAfterAdd", "true");
				//columns[l].setAttribute("edited", "true");
			//}
			if(flag[l]!= true){
				oNode.appendChild(columns[l]);
			}else{
				var image = getAttribute(columns[l], "i");
				if(image){
					oColumns[l].setAttribute("i", image);
				}
				oNode.appendChild(oColumns[l]);
			}
			setText(pcolms[l], text);
		}
		oNode.setAttribute("status","add");
		oNode.setAttribute("titleValue",emxUIConstants.STR_SB_NEW_ROWTOOLTIP);
		oNode.removeAttribute("e");
		oNode.setAttribute("t",getAttribute(row,"t"));
		var relType = getPasteMatchEditRel(oNode,oNode.parentNode);
		if(toValue(relType) == "") {
			relType = getFirstPossibleRel(oNode,oNode.parentNode);
		}
		postNode.setAttribute("relType",toValue(relType));
	}
}

function toValue(value)
{
	return value == null || typeof value == "undefined" ? "" : value;
}

function modifyPostDataXML(crow,prow,markup)
{
	var cobject = getElement("object");
    cobject.setAttribute("rowId",getAttribute(crow,"id"));
    cobject.setAttribute("objectId",getAttribute(crow,"o"));
    cobject.setAttribute("relId",getAttribute(crow,"r"));
    cobject.setAttribute("selection",getAttribute(crow,"s"));
    cobject.setAttribute("level",getAttribute(crow,"level"));
    cobject.setAttribute("direction",getAttribute(crow,"d"));
    cobject.setAttribute("markup",markup);

    var columns = getColumns(crow);
    for(var i = 0; i < columns.length; i++)
    {
    	var column = getElement("column");
    	column.setAttribute("name",colMap.getColumnByIndex(i).name);
    	column.setAttribute("edited","true");
    	var text = getTextNode(columns[i].getAttribute("a"));
    	column.appendChild(text);
    	cobject.appendChild(column);
    }

    var poid    = getAttribute(prow,"o");
    var prid    = getAttribute(prow,"id");
    var pobject = getNode(postDataXML,"/mxRoot/object[@rowId='" + prid + "'][@objectId='" + poid + "']");
	if(pobject == null)
	{
    	pobject = getElement("object");
    	pobject.setAttribute("rowId",prid);
    	pobject.setAttribute("objectId",poid);
    	postDataXML.documentElement.appendChild(pobject);
    }
    pobject.appendChild(cobject);
}

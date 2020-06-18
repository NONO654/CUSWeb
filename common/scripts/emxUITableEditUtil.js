//=================================================================
// JavaScript File - emxUITableEditUtil.js
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//
// static const char RCSID[] = $Id: emxUITableEditUtil.js.rca 1.6 Wed Oct 22 15:48:51 2008 przemek Experimental przemek $
//=================================================================
//

var normalCheckedCheckbox = null;
var shiftCheckedCheckbox = null;

// Methods for Tracking the selections
function register(strID) {

	var toolBarFrame = parent;

    if (!parent.ids) {
            parent.ids = "~";
    }

    if (parent.ids.indexOf(strID + "~") == -1) {
            parent.ids += strID + "~";
    }

	if (toolBarFrame && toolBarFrame.toolbars && toolBarFrame.toolbars.setListLinks) {
    	toolBarFrame.toolbars.setListLinks( parent.ids.length > 1);
	}
}

function unregister(strID) {
    var strTemp = parent.ids;
    if(strTemp == null || strTemp == 'undefined')
    	return;
	var toolBarFrame = parent;


    if (strTemp.indexOf("~" + strID + "~") > -1) {
            strTemp = strTemp.replace(strID + "~", "");
            parent.ids = strTemp;
    }
    if (toolBarFrame && toolBarFrame.toolbars && toolBarFrame.toolbars.setListLinks) {
            toolBarFrame.toolbars.setListLinks( parent.ids.length > 1);
    }
}


function doCheckboxClick(objCheckbox, chkboxparam, event, row) {
	var evnt = event;
	if(!evnt){
		evnt = window.event;
	}
    if (objCheckbox.checked){
        register(objCheckbox.value);
        if(evnt && evnt.shiftKey){
			doCheckCheckboxes(objCheckbox, true, row)
		}else{
			doCheckCheckboxes(objCheckbox, false, row)
		}
    }else{
        unregister(objCheckbox.value);
        removeFromSelectedRows(row);
        normalCheckedCheckbox = null;
	}

    eval('document.forms[0].' + chkboxparam + '.value = ' + objCheckbox.checked);
    doSelectAllCheck();
}

/**
* Puts the check mark to the checkboxes and registers it
* @param User selected checkbox
* @param shiftDown Boolean value indicating whether shift key is down or not 
*/
function doCheckCheckboxes(objCheckbox, shiftDown, row){
			if(shiftDown){
		shiftCheckedCheckbox = row;
				if(normalCheckedCheckbox){
					//Takes care of reverse shift clicking
					if(normalCheckedCheckbox > shiftCheckedCheckbox){
						var tempChecked = shiftCheckedCheckbox;
						shiftCheckedCheckbox = normalCheckedCheckbox;
						normalCheckedCheckbox = tempChecked;
					}
					
					// Actual checking happens here
			for(var ckLen = normalCheckedCheckbox; ckLen <= shiftCheckedCheckbox; ckLen++){
				var checkbox = document.getElementById("chkbox" + ckLen);
				checkbox.checked = true;
				register(checkbox.value);
				addToSelectedRows(ckLen);
				eval('document.forms[0].chkbox' + ckLen + '.value = true');
					}
				}
				normalCheckedCheckbox = shiftCheckedCheckbox;
			}else{
		normalCheckedCheckbox = row;
		addToSelectedRows(row);
				shiftCheckedCheckbox = null;
	}
}

// adds the selected row number to the selectedrows string
// this is used in docheckbox
function addToSelectedRows(row){
	var selectedRows = document.forms[0].selectedRows;
	if(selectedRows){
		if(selectedRows.value.length < 1){
			selectedRows.value = row;
		} else if (selectedRows.value != row){
		    var found = false; 
		    var index = selectedRows.value.indexOf(row + ",");
		    if(index == 0){ //first
		       found = true;
		    } else {
		       if(selectedRows.value.indexOf("," + row + ",") != -1) { //middle
		          found = true;
		       } else {  //last
		          index = selectedRows.value.lastIndexOf("," + row);
		          if(index != -1 && (selectedRows.value.length == (index + row.length + 1))){
		             found = true;
		          }
		       }
		    }
		
		    if(!found){
		       selectedRows.value += "," + row; 
		    }            
		}
    }    
}

// Removes the selected row number from the selectedrows string
// this is used in docheckbox
function removeFromSelectedRows(row){
	var selectedRows = document.forms[0].selectedRows;
	if(selectedRows){
	    if(row == selectedRows.value){
	        selectedRows.value = "";
	    } else {
	        var index = index = selectedRows.value.indexOf(row + ",");                         
	        if(index == 0){ // first
	            selectedRows.value = selectedRows.value.slice(row.length + 1);
	        } else {
	            index = selectedRows.value.indexOf("," + row + ",");
	            if(index != -1){ //middle            
	                 selectedRows.value = selectedRows.value.slice(0,index) + selectedRows.value.slice(index + row.length + 1);
	            } else {
	                index = selectedRows.value.lastIndexOf("," + row);
	                if(index != -1){ //last
	                    if(selectedRows.value.length == (index + row.length + 1)){
	                        selectedRows.value = selectedRows.value.slice(0, index);
	                    }                        
	                }                        
	            }
			}
		}
	}
}

/**
* Returns an array of all the checkboxes given the form name.
* @param formName Form name to find the checkboxes in it
*/
function getAllTableCheckboxes(formName){
	var checkboxList = document.forms[0].getElementsByTagName("input");
	var checkboxLength = checkboxList.length;
	var checkboxes = new Array();
	
	for(var i = 0; i < checkboxLength; i++){
		if(checkboxList[i].type == "checkbox")
			checkboxes.push(checkboxList[i]);
	}
	return checkboxes;
}

//check to see if all objects are selected
function doSelectAllCheck()
{
    var objForm = document.forms[0];
    var checkAll = true;
    if (objForm.emxTableRowId)
    {
        if (objForm.emxTableRowId[0])
        {
            for (var i = 0; i < objForm.emxTableRowId.length; i++)
            {
                if(!objForm.emxTableRowId[i].checked)
                {
                  checkAll=false;
                  break;
                }
            }
        } else {

                if(!objForm.emxTableRowId.checked)
                 {
                    checkAll=false;
                 }
        }

       objForm.chkList.checked=checkAll;
    }
}


function doCheck(formname, tableCheckbox)
{
    var objForm = document.forms[0];
    if (objForm.emxTableRowId)
    {
        if (objForm.emxTableRowId[0])
        {
            for (var i = 0; i < objForm.emxTableRowId.length; i++)
            {
                objForm.emxTableRowId[i].checked = objForm.chkList.checked;
                eval('objForm.chkbox' + i + '.value = objForm.chkList.checked');
                var strID = objForm.emxTableRowId[i].value;

                if (objForm.emxTableRowId[i].checked){
                    register(strID);
                    addToSelectedRows(""+i);
                }else{
                    unregister(strID);
                    removeFromSelectedRows(""+i);
                }
            }
        } else {
            objForm.emxTableRowId.checked = objForm.chkList.checked;
            objForm.chkbox0.value = objForm.chkList.checked;
            var strID = objForm.emxTableRowId.value;

            if (objForm.emxTableRowId.checked){
                register(strID);
                addToSelectedRows("0");
            }else{
                unregister(strID);
                removeFromSelectedRows("0");
            }
        }
    }
}

function reloadTableEditPage()
{
	document.forms[0].clearEditObjList.value = "false";
	document.location.href = document.location.href;
}

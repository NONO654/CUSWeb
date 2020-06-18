
//=================================================================
// JavaScript emxUICollections.js
// Version 1.1
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of 
// MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================

//Constants
var SELECTION_MSG = "Please Make a Selection.";
var RM_WARNING_MSG = "You have chosen to remove the selected item(s) from this list.\n" +
                     "Removing item(s) from the list does not delete the item(s)from the database.\n" +
                     "To continue with the removal, click OK. To cancel the removal, click Cancel.";
var RM_SET_MSG = "Removing all the members of a Collection will also delete the Collection from the database.\n" +
                 "Continue with removal?";

  //**************************************************************************
  // This method is used to create a collection from selected item(s)(object)
  // from the list
  //
  //**************************************************************************
  function createSelectCollection() {
      var anySelected = false;
      var objectIds = "";
      
      for(var i = 0; i<document.formDataRows.elements.length; i++) 
      {
        if((document.formDataRows.elements[i].type == "checkbox") &&
           (document.formDataRows.elements[i].name != "checkAll"))
        {
          if(document.formDataRows.elements[i].checked == true)
          {
            anySelected = true; 
            objectIds += document.formDataRows.elements[i].value;
            objectIds += "|";
          } 
        }
      }

      if(anySelected)
      {          
        document.formDataRows.IdList.value=objectIds;
        showModalDialog("../common/emxCollectionsSelectCreateDialogFS.jsp", 500, 400, false);
      }
      else
      {
        alert(SELECTION_MSG);
      } 

      return;
  }

  function highlightCollectionName() {
        document.frmCreateAppendCollection.setName.focus();
        document.frmCreateAppendCollection.setName.select();
  }

  function unhighlightCollectionName() {
        document.frmCreateAppendCollection.setName.blur();
        if (isIE) {
          document.frmCreateAppendCollection.setName.focus();
          document.frmCreateAppendCollection.setName.blur();
        }
  }

  function focusCollectionName() {
        document.frmCreateAppendCollection.setName.select();
  }

  //*********************************************************************
  // This method ise used to select/de-select all checkbox(es)
  //
  //*********************************************************************
 
  function allSelected(formName)
  {
       var operand = "";
       var bChecked = false;
       var count = eval("document." + formName + ".elements.length");
       var typeStr = "";
       //retrieve the checkAll's checkbox value
       var allChecked = eval("document." + formName + ".elements[0].checked");
       for(var i = 1; i < count; i++) 
       {
          operand = "document." + formName + ".elements[" + i + "].checked";
          typeStr = eval("document." + formName + ".elements[" + i + "].type");
          if(typeStr == "checkbox")
          {
             operand += " = " + allChecked + ";";
             eval (operand);
          }          
       }
       return;
  } 

  //***************************************************************************
  // This method is used to select all or update checkbox(es), where there is
  // a check-all checkbox in the column header.
  //
  // Param formName - the formName used in the page
  //***************************************************************************
  function updateSelected(formName)
  {
     var operand = "";
     var bChecked = false, allSelected = true;
     var typeStr = "";
     var count = eval("document." + formName + ".elements.length");

     for(var i = 1; i < count; i++)  //exclude the checkAll checkbox
     {
        typeStr = eval("document." + formName + ".elements[" + i + "].type");
        if(typeStr == "checkbox")
        {  
            bChecked = eval("document." + formName + ".elements[" + i + "].checked");
            if(bChecked == false)
            {                  
               allSelected = false; 
               break;
            }
        } 
     }

     //set check-all checkbox accordingly
     operand = "document." + formName + ".elements[0].checked = " + allSelected + ";";
     eval (operand);

     return;
  }

  //**************************************************************************
  // This method is used to remove selected item(s)(object) from the list
  //
  //**************************************************************************
  function removeSelectedMembers(){
      var anySelected = false;
      var count = document.formDataRows.setCount.value;
      var selectedCount = 0;

        for(var i = 0; i<document.formDataRows.elements.length; i++) 
          if(document.formDataRows.elements[i].type == "checkbox")
          {
            if(document.formDataRows.elements[i].checked == true  && !(document.formDataRows.elements[i].name == "checkAll"))
            {
              anySelected = true; 
              selectedCount = selectedCount + 1;
            } 
          }
        if(anySelected)
        {          
          if(confirm(RM_WARNING_MSG))
          {
            if(selectedCount == count)
            {
              if(confirm(RM_SET_MSG))
              {
                document.formDataRows.deleteSet.value = "true";
                document.formDataRows.submit();
              }
              else
              {
                 return;
              }                     
            }
            document.formDataRows.submit();
          }
          else
          {
             //does nothing
          }                     
        }
        else
        {
          alert(SELECTION_MSG);
        } 

        return;
  }


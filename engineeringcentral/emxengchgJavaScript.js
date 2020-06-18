<!--
//=================================================================
// JavaScript emxengchgJavaScript.js
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of Dassault Systemes
// Copyright notice is precautionary only and does not evidence any actual or
// intended publication of such program
//=================================================================
-->
<script language="Javascript">

var NSX = (navigator.appName == "Netscape");
var IE4 = (document.all) ? true : false;
// Internationalization of AlertMessages used for Selection of an Object ,Deletion or Removal of Objects.
<%   
	String language  = request.getHeader("Accept-Language");
	String strENGResFileId = "emxEngineeringCentralStringResource";
%>
//Multitenant
//var MAKE_SELECTION_MSG = "<%=i18nNow.getI18nString("emxEngineeringCentral.Message.PleaseMakeASelection", "emxEngineeringCentralStringResource",language)%>";
//var REMOVE_WARNING_MSG = "<%=i18nNow.getI18nString("emxEngineeringCentral.Message.RemoveWarningMsg", "emxEngineeringCentralStringResource",language)%>";
//var DELETE_WARNING_MSG = "<%=i18nNow.getI18nString("emxEngineeringCentral.Message.DeleteWarningMsg", "emxEngineeringCentralStringResource",language)%>";
//var INVALID_CHARACTER_ALERT = "<%=i18nNow.getI18nString("emxEngineeringCentral.Alert.InvalidCharacter", "emxEngineeringCentralStringResource",language)%>";
var MAKE_SELECTION_MSG = "<%=EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Message.PleaseMakeASelection")%>";
var REMOVE_WARNING_MSG = "<%=EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Message.RemoveWarningMsg")%>";
var DELETE_WARNING_MSG = "<%=EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Message.DeleteWarningMsg")%>";
var INVALID_CHARACTER_ALERT = "<%=EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Alert.InvalidCharacter")%>";

function displayStatus(statusMsg, statusMsgColor)
  {
    var statusDoc = getTopWindow().StatusFrame.window.document;
    statusDoc.clear();
    statusDoc.write("<P>");     
    statusDoc.write("<strong><font size=-1 face='Arial, Helvetica'color=", statusMsgColor, ">");    
    statusDoc.write(statusMsg);
    statusDoc.write("</font></strong>");
    statusDoc.write("</P>");
    statusDoc.closeWindow();
  }

function clearField(formName,fieldName,idName) 
{
       
    var operand = "document." + formName + "." + fieldName+".value = \"\";";
    eval (operand);
    if(idName != null){
        var operand1 = "document." + formName + "." + idName+".value = \"\";";
        eval (operand1);
    }   
    return;
}

function showRDOSearch(formName, field, idField) 
{
   showModalDialog('../engineeringcentral/emxpartRDOSearchDialogFS.jsp?form=' + formName + '&field=' + field + '&fieldId=' + idField + '&searchLinkProp=SearchRDOLinks', 550,500,false);
}

function jsTrim (valString)
{
  var trmString = valString;
    
    // this will get rid of leading spaces 
    while (trmString.substring(0,1) == ' ') 
    trmString = trmString.substring(1, trmString.length);

    // this will get rid of trailing spaces 
    while (trmString.substring(trmString.length-1,trmString.length) == ' ')
    trmString = trmString.substring(0, trmString.length-1);

    return trmString;
}
  

function listboxFilter(formName,SelectBoxName,patternBox,pageArray)
{
  pattern = eval("document." + formName + "." + patternBox + ".value;");
  pattern = jsTrim(pattern);
  var expPattern = new RegExp(pattern);
  //FILTER THE RESULTS ARRAY TO CONSTRUCT A FILTER ARRAY
  var clearItem;
  var filter;
  var arrayLength = pageArray.length;
  var Counter=0;
  clearItem = "document." + formName + "." + SelectBoxName + ".options.length = 0";
  eval (clearItem);
  while(Counter < arrayLength)
  {
    filter = pageArray[Counter].match(expPattern);
    if (filter != null)
    {
      if(NSX) {
        var selLength = eval("document." + formName + "." + SelectBoxName + ".options.length");
        eval("document." + formName + "." + SelectBoxName + ".options[selLength] = new Option(pageArray[Counter],pageArray[Counter],true,true)");
      }
      else {
        addItem = "document." + formName + "." + SelectBoxName + ".options.add(new Option(pageArray[Counter],pageArray[Counter],true,true))";
        eval (addItem);
      }
    }
  Counter++;
  }
} 
 
function ECRlistboxFilter(formName,SelectBoxName,patternBox,valArray,viewArray)
{
  var arrayLength = viewArray.length;
  if(arrayLength <=1)
  {

    //alert("<%=i18nNow.getI18nString("emxEngineeringCentral.Alert.InvalidFilterItems",strENGResFileId,language)%>");
	  alert("<%=EnoviaResourceBundle.getProperty(context ,strENGResFileId,context.getLocale(),"emxEngineeringCentral.Alert.InvalidFilterItems")%>");
  }else{
    pattern = eval("document." + formName + "." + patternBox + ".value;");
    pattern = jsTrim(pattern);
    var expPattern = new RegExp(pattern);
    //FILTER THE RESULTS ARRAY TO CONSTRUCT A FILTER ARRAY
    var clearItem;
    var filter;
    var Counter=0;
    clearItem = "document." + formName + "." + SelectBoxName + ".options.length = 0";
    eval (clearItem);
    while(Counter < arrayLength)
    {
      filter = viewArray[Counter].match(expPattern);
      if (filter != null)
      {
        if(NSX) {
          var selLength = eval("document." + formName + "." + SelectBoxName + ".options.length");
          eval("document." + formName + "." + SelectBoxName + ".options[selLength] = new Option(viewArray[Counter],valArray[Counter],true,true)");
        }
        else {
          var selLength = eval("document." + formName + "." + SelectBoxName + ".options.length");
          addItem = "document." + formName + "." + SelectBoxName + ".options.add(new Option(viewArray[Counter],valArray[Counter],true,true))";
          eval (addItem);
        }
      }
    Counter++;
    }
  }
}
//Filters Contents of Select Boxes. 
function filterThis(formName,SelectBoxName,patternBox,comboValueArray,comboSelectArray)
{
  pattern = eval("document." + formName + "." + patternBox + ".value;");
  pattern = jsTrim(pattern);


 if (pattern == "")
  {

    //alert("<%=i18nNow.getI18nString("emxEngineeringCentral.Alert.InvalidValue",strENGResFileId,language)%>");  //Added for IR-053924V6R2011x
	 alert("<%=EnoviaResourceBundle.getProperty(context ,strENGResFileId,context.getLocale(),"emxEngineeringCentral.Alert.InvalidValue")%>");  //Added for IR-053924V6R2011x
  }


  if (pattern == "*")
  {

    pattern="";

  }

  //var expPattern = new RegExp(pattern);
  //FILTER THE RESULTS ARRAY TO CONSTRUCT A FILTER ARRAY
  var clearItem;
  //var filter;
  var arrayLength = comboSelectArray.length;
  var Counter=0;
  clearItem = "document." + formName + "." + SelectBoxName + ".options.length = 0";
  eval (clearItem);
  while(Counter < arrayLength)
  {
    //Check if String matches pattern
     var  sPatternMatch = false;
    var sStringToCheck = comboSelectArray[Counter];
    
    
    // this will get rid of leading wildstr 
    while (pattern.substring(0,1) == '*') 
    pattern = pattern.substring(1, pattern.length);

    // this will get rid of trailing wildstr 
    while (pattern.substring(pattern.length-1,pattern.length) == '*')
    pattern = pattern.substring(0, pattern.length-1);
    
    var PatternArray = pattern.split("*");
    var PattLength = PatternArray.length ;
    
    var i ;
    var flagFullMatch = true;
    for ( i = 0 ; i<PattLength ; i++)
    {
      var PartPattern = PatternArray[i];
      var expMatch = new RegExp(PartPattern);
      
      var MatchResult = sStringToCheck.match(expMatch);
      
      if (MatchResult == null)
      {
        flagFullMatch = false;
        break;
      }
      
      var MatchedStrLength = MatchResult[0].length;
      var startSubstr = MatchResult.index + MatchResult[0];
      sStringToCheck = sStringToCheck.substr(startSubstr);
      
    }    
    
    
    if (flagFullMatch)
    {
      if(NSX) {
        var selLength = eval("document." + formName + "." + SelectBoxName + ".options.length");
        eval("document." + formName + "." + SelectBoxName + ".options[selLength] = new Option(comboSelectArray[Counter],comboValueArray[Counter],true,true)");
      }
      else {
        addItem = "document." + formName + "." + SelectBoxName + ".options.add(new Option(comboSelectArray[Counter],comboValueArray[Counter],true,true))";
        eval (addItem);
     }
    }
    
    /*
    filter = comboSelectArray[Counter].match(expPattern);
    if (filter != null)
    {
      addItem = "document." + formName + "." + SelectBoxName + ".options.add(new Option(comboSelectArray[Counter],comboValueArray[Counter],true,true))";
      eval (addItem);
    }
    */

  Counter++;
  }
 } 
 
  //
  // function jsParseSpChr() - replaces the defined special characters with the escape chr.
  // If the text contains chrs of single quotes(') or double quotes(") put backslash (\) 
  // in front of the character.
  // argString: Text to be parsed.
  // Usage : If the user wants to escape more characters, add a new statement line for the specified chr.
  // For e.g.: to add "+" literal do this: parsedString = argString.replace(/[+]/g,"\+");
  //
  function jsParseSpChr(argString) {
    var parsedString = argString.replace(/[']/g,"\'");
    parsedString = argString.replace(/["]/g,"\"");
    return parsedString;
  }
  
  //
  // function jsValidate() - validates the user input.
  // If it contains special characters such as ~ | then display an alert.
  // argForm: Form name of the document.
  // argInputField: input element's name (could be textbox, textarea, etc.)
  //
  function jsValidate(argForm, argInputField) {
    // If the user input needs to be checked for more characters then please add additional chrs
    // in the parentheses of search method. For e.g. to add ";" change it to ".search(/[|~;]/)".
    var textToValidate = eval("document."+argForm+"."+argInputField+".value");
    var searchResult = textToValidate.search(/[|~]/);     
    if (searchResult != -1 ) {    
    alert(INVALID_CHARACTER_ALERT);  
    eval("document."+argForm+"."+argInputField+".focus()");
      return false;
    }
    return true;
  }


  //*******************************************************************************
  // This method is used to delete selected item(s)(object) from the list
  //
  //*******************************************************************************
  function deleteSelected(){
      var anySelected = false;      
        for(var i = 0; i<document.formDataRows.elements.length; i++) 
          if(document.formDataRows.elements[i].type == "checkbox")
          {
            if(document.formDataRows.elements[i].checked == true  && !(document.formDataRows.elements[i].name == "checkAll"))
            {
              anySelected = true; 
              break;
            } 
          }
        if(anySelected)
        {          
          if(confirm(DELETE_WARNING_MSG))
           document.formDataRows.submit();
          else
          {
             //does nothing
          }                     
        }
        else
        {
          alert(MAKE_SELECTION_MSG);
        } 

        return;
  }

  //*******************************************************************************
  // This method is used to remove selected item(s)(object) from the list
  //
  //******************************************************************************* 
  function removeSelected(){       
      var anySelected = false; 
      var intTotalCheckBoxCount = 0;
        for(var i = 0; i<document.formDataRows.elements.length; i++) 
          if(document.formDataRows.elements[i].type == "checkbox") {
            intTotalCheckBoxCount++;
            if(document.formDataRows.elements[i].checked == true && intTotalCheckBoxCount >= 1)
            {
             
              anySelected = true; 
              break;
            } 
          }

        if(anySelected)
        {
          if(confirm(REMOVE_WARNING_MSG))
           document.formDataRows.submit();
          else
          {
             //does nothing
          }         
        }
        else
        {          
          alert(MAKE_SELECTION_MSG);
        }

        return;
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
       var allChecked = false;
       for(var i = 0; i < count; i++)
       {
          typeStr = eval("document." + formName + ".elements[" + i + "].type");
          if(typeStr == "checkbox")
          {
        allChecked = eval("document." + formName + ".elements[" + i + "].checked");
        break;
      }           
       }

       for(i = 0; i < count; i++) 
       {
          operand = "document." + formName + ".elements[" + i + "].checked";
          typeStr = eval("document." + formName + ".elements[" + i + "].type");
          if(typeStr == "checkbox")
          {
             // Added the below line to check whether the check box is grayed or not.
             bChecked = eval("document." + formName + ".elements[" + i + "].disabled");
             // if the check box is grayed out, it cannot be selected.
             if(bChecked == false)
             {
                 operand += " = " + allChecked + ";";
                 eval (operand);
             }
          }
       }
       return;
  } 

  //******************************************************************************
  // This method is used to select all or update checkbox(es), where there is a 
  // check-all checkbox in the column header. 
  //
  // Param formName - the formName used in the page
  //******************************************************************************
  function updateSelected(formName)
  {
     var operand = "";
     var bChecked = false, allSelected = true;
     var typeStr = "";
     var checkAllIndex = 0;
     var count = eval("document." + formName + ".elements.length");

       for(var i = 0; i < count; i++)
       {
          typeStr = eval("document." + formName + ".elements[" + i + "].type");
          if(typeStr == "checkbox")
          {
        checkAllIndex = i;
        break;
      }           
       }

     for(var i = 0; i < count; i++)  //exclude the checkAll checkbox
     {
        typeStr = eval("document." + formName + ".elements[" + i + "].type");
        if(typeStr == "checkbox" && i!=checkAllIndex)
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
     operand = "document." + formName + ".elements["+checkAllIndex+"].checked = " + allSelected + ";";
     eval (operand);
     return;
  }

  function showBOMReportWindow(url) {
  var strFeatures = "width=600,height=650,resizable=yes,scrollbars=yes,dependent=no,toolbar=no,titlebar=no";
  var win = window.open(url, "BOMReport", strFeatures);
  registerChildWindows(win, getTopWindow());
  return;
  }
  
      
    //
    // variable used to detect if a form have been submitted
    //
    var clicked = false;
  
    //
    // function jsDblClick() - sets var clicked to true.
    // Used to prevent double click from resubmitting a
    // form in IE 
    //
    function jsDblClick() {
      if (!clicked) {
        clicked = true;
        return true;
      }
      else {
        return false;
      }
    }
  
    //
    // function jsIsClicked() - returns value of the clicked variable.
    //  
    function jsIsClicked() {
      return clicked;
    }
  
    //
    // function jsClickOnPage() - returns true if clicked is not set.
    // Used by the document.onclick js method to prevent mouse clicks
    // after a form have been submitted to abort the requested page 
    // for IE. This function have to be used when the form action is 
    // another page than the current running.
    //
    function jsClickOnPage(e){
      if(jsIsClicked()) {
        return false;
      } else {
        return true;
      }
    }  
  

    
</script>

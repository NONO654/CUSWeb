
function displayStatus(statusMsg, statusMsgColor)
  {
    var statusDoc = getTopWindow().StatusFrame.window.document;
    statusDoc.clear();
    statusDoc.write("<P>");     
    statusDoc.write("<strong><font size=-1 face='Arial, Helvetica'color=", statusMsgColor, ">");    
    statusDoc.write(statusMsg);
    statusDoc.write("</font></strong>");
    statusDoc.write("</P>");
    statusDoc.close();
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
   showModalDialog('emxpartRDOSearchDialogFS.jsp?form=' + formName + '&field=' + field + '&fieldId=' + idField + '&searchLinkProp=SearchRDOLinks', 550,500,false);
}

function jsTrim (valString)
{
  var trmString = valString;
  //alert("|" + trmString + "|");
    
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
    alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.JSFunction.ECRlistboxFilter</emxUtil:i18nScript>");
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
  
  //alert(pattern);


 if (pattern == "")
  {
    alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.JSFunction.PatternFilter</emxUtil:i18nScript>");
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
    //alert(pattern);
    
    var PatternArray = pattern.split("*");
    var PattLength = PatternArray.length ;
    //alert(PattLength);
    
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
      
      //alert(PartPattern);
      //alert("Here inside ");
    }    
    
    //alert(flagFullMatch);
    
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
      alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.JSFunction.InvalidChars</emxUtil:i18nScript>" +
            "<emxUtil:i18nScript localize='i18nId'>emxComponents.JSFunction.InputAlert</emxUtil:i18nScript>");
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
        for(var i = 0; i<document.formDataRows.elements.length; i++) 
          if(document.formDataRows.elements[i].type == "checkbox")
            if(document.formDataRows.elements[i].checked == true)
            {
              anySelected = true; 
              break;
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
       var allChecked = eval("document." + formName + ".elements[0].checked");
       for(var i = 1; i < count; i++) 
       {
          operand = "document." + formName + ".elements[" + i + "].checked";
          disabled = eval("document." + formName + ".elements[" + i + "].disabled");
          typeStr = eval("document." + formName + ".elements[" + i + "].type");
          // Modified for IR Mx376309V6R2011
          if(typeStr == "checkbox" && disabled == false)
          {
             operand += " = " + allChecked + ";";
             eval (operand);
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
  
  //Function to select all the check boxes used in Route pages.
  /*function doCheck(formName)
  {
    var objForm = eval("document." + formName);
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;
    for (var i=0; i < objForm.elements.length; i++)
    {
      if (objForm.elements[i].name.indexOf('chkItem') > -1)
      {
        objForm.elements[i].checked = chkList.checked;
      }
    }
  }*/

  //Function to uncheck all the check box values.
  function updateCheck(formName) {
    var objForm = eval("document." + formName);
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;

    var checked = "true";
    for (var i=0; i < objForm.elements.length; i++)
    {
      if (objForm.elements[i].name.indexOf('chkItem') > -1)
      {
        if (!objForm.elements[i].checked)
        {
          checked = "false";
        }
      }
    }
    if (checked == "false")
    {
      chkList.checked = false;
    }
    else
    {
      chkList.checked = true;
    }
  }
    function getCheckInErrorInfo()
    {
        closeDiv();
        var vcCheckinErrorMessage = document.forms[0].CheckinErrorMessage.value;
        var objEvent = emxUICore.getEvent();
        if(vcCheckinErrorMessage!='')
        {
            var sURL = "../components/emxCommonDocumentCheckInErrorMessage.jsp";
            var oXMLHTTP = emxUICore.createHttpRequest();
            oXMLHTTP.open("POST", sURL, false);
            oXMLHTTP.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
            oXMLHTTP.send("errorMessage="+vcCheckinErrorMessage);
            floatingDiv = document.createElement("div");

            floatingDiv.name="floatingdiv";
            floatingDiv.id="floatingdiv";
            floatingDiv.style.position="absolute";
            floatingDiv.style.zIndex=5;
            document.forms[0].appendChild(floatingDiv);
            

            window.focus();
            floatingDiv.style.display = "block";
            floatingDiv.focus();

            
            var floatDivInnerHTML = floatingDiv.innerHTML;
            floatDivInnerHTML +=oXMLHTTP.responseText ;
            floatingDiv.innerHTML=floatDivInnerHTML;
            var floatingDivWidth = "";
            if(isIE)
            {
                floatingDivWidth = floatingDiv.firstChild.offsetWidth;
                floatingDivHeight = floatingDiv.firstChild.offsetHeight;
            }
            else
            {
                floatingDivWidth = floatingDiv.offsetWidth;
                floatingDivHeight = floatingDiv.offsetHeight;
            }
            floatingDiv.setAttribute("width", floatingDivWidth);

            if(!isIE)
            {
                var divFormLayerBorder = document.getElementById("formLayerBorder");
                var tblHeader = document.getElementById("tblHeader");
                var tblBody = document.getElementById("tblBody");
                var tableWidth = tblBody.offsetWidth;
                if(parseInt(tblHeader.offsetWidth) > parseInt(tableWidth)){
                    tableWidth =tblHeader.offsetWidth;
                }
                if(parseInt(divFormLayerBorder.offsetWidth) < parseInt(tableWidth))
                {
                    divFormLayerBorder.style.width = tableWidth+50+"px";
                }
                floatingDivWidth = tableWidth +20;
            }
            else if(isIE){
                var divFormLabel = document.getElementById("formLabel");
                var divFormLayerBorder = document.getElementById("formLayerBorder");
                if(parseInt(divFormLabel.offsetWidth) < parseInt(divFormLayerBorder.offsetWidth))
                {
                    divFormLabel.style.width = divFormLayerBorder.offsetWidth;
                }

            }

            setDivPosition(objEvent, floatingDiv,floatingDivWidth,floatingDivHeight);
        }
        else
        {

             alert(STR_CHECKIN_STATUS_ERROR);
        }
    }
    function closeDiv()
    {
            if(floatingDiv!=null)
            {
                floatingDiv.innerHTML ="";
                floatingDiv.style.display="none";
                floatingDiv = null;
            }
        
    }
    function setDivPosition(objEvent, floatingDiv,floatingDivWidth,floatingDivHeight) 
    {
        intX = objEvent.clientX
        intY = objEvent.clientY
        //add offset to each coordinate
        intX += 15 + document.body.scrollLeft;
        intY += 15 + document.body.scrollTop;

        //make sure that all of the tooltip is visible
        if ((intX + floatingDivWidth) > (document.body.clientWidth + document.body.scrollLeft)) {

            //move it so that the right edge of the div lines up with the right edge of the window
            intX = (document.body.clientWidth + document.body.scrollLeft) - floatingDivWidth - 5;
        }

        var intWindowHeight = document.body.clientHeight || window.innerHeight;
        //make sure that all of the tooltip is visible
        if ((intY + 100) > (intWindowHeight + document.body.scrollTop)) {

            //move it so that the bottom edge of the div lines up with bottom edge of the window
            intY = (document.body.clientHeight + document.body.scrollTop) - 100;

        }
       if((floatingDivHeight + intY) > intWindowHeight){
         intY= intY-floatingDivHeight;
        }
        else {
         intY = intY-40;
        }
        floatingDiv.style.top = intY;
        floatingDiv.style.left=  intX;

}


//==================================================================================================================================
// Javascript class to Invoke Autonomy search. The object of this class has certain
// properties initialized with default values to ease the use of the search usage.
// One can optionally configure by setting different values for the properties.
// This object works in conuction with jsp "../components/emxCommonAutonomySearchSubmit.jsp"
//
// Example of usage:
// Assume that a dialog page names emxDialog.jsp has a chooser box for Persons search, 
// to enable Autonomy search. Then we shall roughly follow following steps.
// 1. Include this javascript file in dialog page.
//      - <script language="javascript" type="text/javascript" src="../common/scripts/emxCommonAutonomySearchUtil.js"></script>  
// 2. Have a javascript function submitSearch() in dialog page, this will be called after the selected search results are submitted.
//    TODO: Parameters for the function 
// 3. Have a javascript function chooser_onclick() in dialog page, hooked to onclick event of the chooser button.
//      - This function will invoke a search as below, by creating object of class emxCommonAutonomySearch
//          var objCommonAutonomySearch = new emxCommonAutonomySearch();
//          objCommonAutonomySearch.txtType = "type_Person";
//          objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitSearch"; // Defined in step 2, check documentation for onSubmit property below.
//          objCommonAutonomySearch.open();
// 4. On clicking the chooser button, chooser_onclick function will be invoked and search window will open. User will select
//    the desired objects and submit the selection. The callback function submitSearch will be invoked with the parameters.
//==================================================================================================================================

function emxCommonAutonomySearch() {
    //=================================================================
    // The URL parameters for emxFullSearch.jsp
    //=================================================================
    
    //
    //This is an optional parameter that can pass to specify the name of the function to be 
    //invoked once submit button is clicked on the search component
    this.callbackFunction = null;   // At this time this parameter is not working, so use onSubmit property

    //
    this.cancelLabel = null;

    //
    //List of OIDs to exclude from the search results
    this.excludeOID = null; 

    //
    //JPO provided by Apps that returns list of OIDs to not display in results.  This is used 
    //to further filter the results.  The method should return a StringList of OIDs to exclude 
    //from the search results
    this.excludeOIDprogram = null;
    
    //
    //The parameter specifies the name of the form in the form-based search. It is an optional parameter.
    this.formName = null;
    
    //
    //The parameter specifies the name of the frame that contains the form. It is an optional parameter
    this.frameName = null;
    
    // List of indices and their default/allowed values for the initial search results
    this.field = null;
    //
    //This parameter is deprecated. It is present for the backward compatibility.
    // If user does txtType="type_abc" then field is set to "TYPES=txt_abc"
    this.txtType = null;

    //
    //Optional parameter  - Name of the field to which the selected value from the search results to be returned.
    this.fieldNameActual = null;
    
    //
    //Optional parameter ? If the display value is different from Actual value - Name of the field to which 
    //the display value from the search results to be returned
    this.fieldNameDisplay = null;
    
    //
    //The optional parameter will be used to limit the list of indexed attributes displayed on a Form Based search.
    //This will not apply to Navigation based searches.  Comma separated list
    this.formInclusionList = null;

    //
    //The parameter will be used to either show or hide the header on the search dialog. The header includes 
    //the search text box along with the Search and Reset buttons and the page level toolbar
    this.hideHeader = null;
    
    //
    //All the selectable(s) of search criteria are optional by default. User can provide a coma separated 
    //list of search criteria that are passed as part of URL parameter mandatorySearchParam to make them mandatory.
    //These refinements will be mandatory and displayed as disabled checked checkboxes in the breadcrumb display.
    //The user will not be allowed to uncheck these search criteria. The values passed as mandatorySearchParam must 
    //be a part of the URL parameters.
    this.mandatorySearchParam = null;
    
    //
    //By default, the Search in Collection toolbar button will be displayed on the toolbar when in Navigate mode.
    //Can be turned off by this parameter. Recommended that this is not used when using type specific tables, 
    //expandJPOs or relationships in the results table.
    this.searchCollectionEnabled = null;

    //
    //Controls whether the table page adds a column of check boxes or radio buttons in the left most column of 
    //the search results table. The value passed can be multiple/single/none. 
    //multiple ? to display a check box 
    //single ? to display radio button.
    //none- no additional column is displayed for selection
    this.selection = null;

    //
    //The parameter value will allow display of the OOTB command ?AEFSaveQuery? on the toolbar. 
    this.showSavedQuery = "false";

    //
    //If submitLabel is passed, as an URL parameter then the button will be displayed with the value passed else 
    //will be displayed with label ?Done?.
    //This button will be shown only if Callback function is passed in the URL. This display can be suppressed 
    //by passing additional parameter submitLink = false. 
    //The value can be static text or a property key.
    //This is the existing URL parameter supported by structure browse component
    this.submitLabel = null;
    
    //
    //This parameter is used to define the callback URL. This could be the jsp page to perform the post processing 
    //on an Add Existing command.
    //This is the existing URL parameter supported by structure browse component
    this.submitURL = "../components/emxCommonAutonomySearchSubmit.jsp";
    
    //
    //This is the table that will be passed to Indented Table to display the searched results
    this.table = "AEFGeneralSearchResults";
    
    //
    //This parameter is used to define a custom toolbar, if required for displaying the context 
    //search using consolidated search view component. This is the toolbar that will be displayed 
    //on the search results frame
    this.toolbar = null;

    //
    //This parameter will override the system setting for FormBased vs. Navigation Based.
    this.viewFormBased = null;

    
    //=================================================================
    // Other configurable parameters
    //=================================================================
    
    //
    // The height of the search window
    this.windowHeight = 600;
    
    //
    // The width of the search window
    this.windowWidth = 800;
    
    //
    // The Registered Suite parameter to be passed to JSP is needed.
    this.registeredSuite = null;
    
    //
    // The "program" parameter for Autonomy Search
    this.searchProgram = null;
    
    //
    //The javascript path of the callback submit javascript function.
    //Selected results will be submitted to this function. In general,
    //when the search is invoked from a chooser button on any dialog, we may pass "getTopWindow().getWindowOpener().mySubmitCallback"
    //where function mySubmitCallback is defined in the dialog page.
    //This is mandatory property to set.
    //
    //Example of the callback function
    //function mySubmitCallback(arrSelectedObjects) {
    //  alert("DEBUG: ->mySubmitCallback "+ arrSelectedObjects.length);
    //  
    //  for (var i = 0; i < arrSelectedObjects.length; i++) {
    //      var objSelection = arrSelectedObjects[i];
    //      objSelection.debug(); // Alerts the following properties
    //      ...
    //      objSelection.parentObjectId
    //      objSelection.objectId
    //      objSelection.type
    //      objSelection.name
    //      objSelection.revision
    //      objSelection.relId
    //      objSelection.objectLevel
    //      ...
    //  }
    //}
    this.onSubmit = null;
    
    //=================================================================
    // Opens the Autonomy Search window using the configured parameters
    //=================================================================
    this.open = function () {
            var strURL = "../common/emxFullSearch.jsp";
            
            // Collect the url parameters
            var arrParams = new Array;
            if (this.callbackFunction != null) {
                arrParams[arrParams.length] = "callbackFunction=" + this.callbackFunction;
            }
            if (this.cancelLabel != null) {
                arrParams[arrParams.length] = "cancelLabel=" + this.cancelLabel;
            }
            if (this.excludeOID != null) {
                arrParams[arrParams.length] = "excludeOID=" + this.excludeOID;
            }
            if (this.excludeOIDprogram != null) {
                arrParams[arrParams.length] = "excludeOIDprogram=" + this.excludeOIDprogram;
            }
            if (this.formName != null) {
                arrParams[arrParams.length] = "formName=" + this.formName;
            }
            if (this.frameName != null) {
                arrParams[arrParams.length] = "frameName=" + this.frameName;
            }
            if (this.field != null) {
                arrParams[arrParams.length] = "field=" + this.field;
            }
            else {
                if (this.txtType != null) {
                    arrParams[arrParams.length] = "field=TYPES=" + this.txtType;
                }
            }
            if (this.fieldNameActual != null) {
                arrParams[arrParams.length] = "fieldNameActual=" + this.fieldNameActual;
            }
            if (this.fieldNameDisplay != null) {
                arrParams[arrParams.length] = "fieldNameDisplay=" + this.fieldNameDisplay;
            }
            if (this.formInclusionList != null) {
                arrParams[arrParams.length] = "formInclusionList=" + this.formInclusionList;
            }
            if (this.hideHeader != null) {
                arrParams[arrParams.length] = "hideHeader=" + this.hideHeader;
            }
            if (this.mandatorySearchParam != null) {
                arrParams[arrParams.length] = "mandatorySearchParam=" + this.mandatorySearchParam;
            }
            if (this.searchCollectionEnabled != null) {
                arrParams[arrParams.length] = "searchCollectionEnabled=" + this.searchCollectionEnabled;
            }
            if (this.selection != null) {
                arrParams[arrParams.length] = "selection=" + this.selection;
            }
            if (this.showSavedQuery != null) {
                arrParams[arrParams.length] = "showSavedQuery=" + this.showSavedQuery;
            }
            if (this.submitLabel != null) {
                arrParams[arrParams.length] = "submitLabel=" + this.submitLabel;
            }
            if (this.table != null) {
                arrParams[arrParams.length] = "table=" + this.table;
            }
            if (this.toolbar != null) {
                arrParams[arrParams.length] = "toolbar=" + this.toolbar;
            }
            if (this.viewFormBased != null) {
                arrParams[arrParams.length] = "viewFormBased=" + this.viewFormBased;
            }
            if (this.searchProgram != null) {
                arrParams[arrParams.length] = "program=" + this.searchProgram;
            }
            if (this.registeredSuite != null) {
                arrParams[arrParams.length] = "Registered Suite=" + this.registeredSuite;
            }
            if (this.onSubmit != null) {
                arrParams[arrParams.length] = "onSubmit=" + this.onSubmit;
            }
            if (this.submitURL != null) {
                arrParams[arrParams.length] = "submitURL=" + this.submitURL;
            }
                      
            var strParams = arrParams.join("&");
            strURL += "?" + strParams;

            // Open the search window
            showModalDialog(strURL, this.windowWidth, this.windowHeight, true);
    }//End: open()
}//End: emxCommonAutonomySearch()

//==================================================================================================================================
// Javascript class to hold a selected object in Autonomy search.
//==================================================================================================================================
function emxCommonAutonomySearchSelection(strParentObjectId, strObjectId, strType, strName, strRevision, strRelId, strObjectLevel) {
    //
    // The id of the parent object
    this.parentObjectId = strParentObjectId;
    
    //
    // The id of the object itself
    this.objectId = strObjectId;
    
    //
    // The object type
    this.type = strType;
    
    //
    // The object name
    this.name = strName;
    
    //
    // The object revision
    this.revision = strRevision;
    
    //
    // The relationship id
    this.relId = strRelId;
    
    //
    // The level numbres in indented table row
    this.objectLevel = strObjectLevel;
    
    //=============================================================
    // The method prints the values of the properties. 
    // can be used for debuging purpose
    //============================================================= 
    this.debug = function() {
        alert("emxCommonAutonomySearchSelection object: \nParnetObject=" + this.parentObjectId + "\nObjectId=" + this.objectId + "\nType=" + this.type + "\nName=" + this.name + "\nRevision=" + this.revision + "\nRel Id=" + this.relId + "\nObj Level=" + this.objectLevel);
    }//End : function debug
}//End : function emxCommonAutonomySearchSelection

//Added:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning
function validateStandardCost(idx) {
        
    var standardCostValue = idx.value;
    if (isNaN(standardCostValue))
    {
        alert("Please enter numeric value for Standard Cost");
        //alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.StandardCost.EnterNumericValue</emxUtil:i18nScript>");
       idx.value='0.0';       
      return false;
    } 
    else if (parseInt(standardCostValue,10) < 0 )
    {
        alert("Please enter positive value for Standard Cost");
        //alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.StandardCost.EnterPositiveValue</emxUtil:i18nScript>");
        idx.value='0.0';
      return false;
    }
    else{
        return true;    
    }
    
}
//End:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning   

//To disable or enable the Template Name textbox based on the selection of Save Options 
function toggleTemplateNameEdit(){
	var saveOptionsHTML = document.getElementById("SaveOptions_html");
	var childrenNodes = saveOptionsHTML.children;
	var templateName = document.getElementsByName("TemplateName");
	if(childrenNodes && childrenNodes[0].type == "radio"){
		if(childrenNodes[0].checked){
			if(templateName){
				templateName[0].disabled = false;
			}	
		}
		else{
			if(templateName){
				templateName[0].disabled = true;
			}
		}
	}
	
}

// Methods replaces paricular parameter from the url
function changeURLParam(strURL, paramName, paramValue){
    var paramPoint = strURL.indexOf(paramName);
    var remainingURL = "";
    if (paramPoint > -1){
        var remainingURL = strURL.substring(paramPoint, strURL.length);
        var amppoint = remainingURL.indexOf("&");
        if(amppoint > -1) {
            remainingURL = remainingURL.substring(amppoint, strURL.length);
        }else{
        	remainingURL = "";
        }
        strURL = strURL.substring(0,paramPoint-1);
    }

    if ((paramValue != null) || (paramValue != '') || (paramValue != 'undefined')) {
        if (strURL.indexOf("?") == -1) {
            strURL += "?" + paramName + "=" + paramValue;
        }else{
            strURL += "&" + paramName + "=" + paramValue;
        }
    }
    strURL += remainingURL;	
	return strURL;
}

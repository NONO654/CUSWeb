<script language="Javascript">

var NSX = (navigator.appName == "Netscape");
var IE4 = (document.all) ? true : false;

//Constants
var MAKE_SELECTION_MSG = "Please make a selection";
var REMOVE_WARNING_MSG = "You have chosen to remove the selected item(s) from this list.\n" +
                         "Removing item(s) from the list does not delete the item(s)from the database.\n" +
                         "To continue with the removal, click OK. To cancel the removal, click Cancel.";
var DELETE_WARNING_MSG = "You have chosen to delete the selected item(s) from the database.\n" + 
                         "Deleted item(s) can no longer be accessed from the system.\n" + 
                         "To continue with the deletion, click OK. To cancel the deletion, click Cancel.";

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
    alert("<emxUtil:i18nScript localize='i18nId'>emxTeamCentral.JSFunction.ECRlistboxFilter</emxUtil:i18nScript>");
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
  //alert("HERE");
  pattern = eval("document." + formName + "." + patternBox + ".value;");
  pattern = jsTrim(pattern);
  //alert(pattern);


 if (pattern == "")
  {
    alert("<emxUtil:i18nScript localize='i18nId'>emxTeamCentral.JSFunction.PatternFilter</emxUtil:i18nScript>");
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
      alert("<emxUtil:i18nScript localize='i18nId'>emxTeamCentral.JSFunction.InvalidChars</emxUtil:i18nScript>" +
            "<emxUtil:i18nScript localize='i18nId'>emxTeamCentral.JSFunction.InputAlert</emxUtil:i18nScript>");
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
          if(confirm(DELETE_WARNING_MSG)){
           document.formDataRows.submit();
          }
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
          if(document.formDataRows.elements[i].type == "checkbox"){
            if(document.formDataRows.elements[i].checked == true)
            {
              anySelected = true; 
              break;
            } 
          }  

        if(anySelected)
        {
          if(confirm(REMOVE_WARNING_MSG)){
           document.formDataRows.submit();
          } 
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
          typeStr = eval("document." + formName + ".elements[" + i + "].type");
          if(typeStr == "checkbox")
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
  

    
</script>

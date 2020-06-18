//******************************************************************************************************************
// Copyright Dassault Systemes 2008
//******************************************************************************************************************

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SERVICES
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function getComboSuffix()
{
	return '_selectValue';
}

/**
 * Gets the base of an url (http://mydomain/mypage.jsp?param1=value1&param2=value2).
 * @param url the url.
 * @return the base url (http://mydomain/mypage.jsp).
 */
function getUrlBase(url)
{
  var splitIdx=url.indexOf('?');
  if (splitIdx==-1) return url;
  var baseOfUrl=url.substring(0,splitIdx);
  return baseOfUrl;
}

/**
 * Gets a parameter value from an url (http://mydomain/mypage.jsp?param1=value1&param2=value2).
 * @param url the url where to find the parameter.
 * @param paramName the name of the parameter to find.
 * @return the parameter value or null if parameter name is not found.
 */
function getUrlParameterValue(url,paramName)
{
  var parameters=getUrlParametersArray(url);
  for (var i=0; i<parameters.length; i++)
  {
    var parameter=parameters[i];
    var splitIdx=parameter.indexOf('=');
    if (splitIdx==-1 && parameter==paramName) return '';
    if (splitIdx==-1) continue;
    var name=parameter.substring(0,splitIdx);
    if (name==paramName)
    {
      return parameter.substring(splitIdx+1);
    }
  }
  return '';
}

/**
 * Gets the parameters of an url (http://mydomain/mypage.jsp?param1=value1&param2=value2).
 * @param url the url.
 * @return a string containing parameters (param1=value1&param2=value2).
 */
function getUrlParameters(url)
{
  var splitIdx=url.indexOf('?');
  if (splitIdx==-1) return '';
  var parameters=url.substring(splitIdx+1);
  return parameters;
}

/**
 * Gets the parameters of an url (http://mydomain/mypage.jsp?param1=value1&param2=value2).
 * @param url the url.
 * @return an array of string containing parameters {param1=value1, param2=value2}.
 */
function getUrlParametersArray(url)
{
  var parameters=getUrlParameters(url).split(new RegExp('&'));
  return parameters;
}

/**
 * Deletes a parameter from an url (http://mydomain/mypage.jsp?param1=value1&param2=value2).
 * @param url the url where to find the parameter.
 * @param paramName the name of the parameter to remove.
 * @return the new url with the removed parameter (if not found, returns the unchanged url).
 */
function delParameterFromUrl(url, paramName)
{
  var baseUrl=getUrlBase(url);
  var oldParameters=getUrlParametersArray(url);
  var newParameters="";
  for (var i=0; i<oldParameters.length; i++)
  {
    var oldParameter=oldParameters[i];
    var splitIdx=oldParameter.indexOf('=');
    if (splitIdx!=-1)
    {
      var oldParameterName=oldParameter.substring(0,splitIdx);
      if (oldParameterName==paramName) continue;
    }
    newParameters+=((i==0) ? '' : '&')+oldParameter;
  }
  var newUrl=baseUrl+((newParameters.length>0) ? '?' : '')+newParameters;
  return newUrl;
}

/**
 * Appends or replaces a parameter to an url (http://mydomain/mypage.jsp?param1=value1&param2=value2).
 * @param url the url where to find the parameter.
 * @param paramName the name of the parameter.
 * @param paramValue the value of the parameter.
 * @return the new url with the appended or replaced parameter.
 */
function addParameterToUrl(url, paramName, paramValue)
{
  var newValue=paramValue;
  var newUrl=delParameterFromUrl(url,paramName);
  newUrl=newUrl+(newUrl.indexOf("?")==-1 ? "?" : "&")+paramName+"="+newValue;
  return newUrl;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// QUICK SEARCH PURPOSE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var restoreFilterValuesTimer=null;

/**
 * Restores quick search and saved search toolbar fields (inputs and selects) from url parameters which have been set in the url.
 */
function restoreFilterValues()
{
  var isRendered=false;
  //get the url which have been used to display the table
  var tableDocument=(this.name && this.name=='listHead') ?  /* portal mode */ this.parent.document : /* content or popup mode */ document;
  var emxTableUrl=tableDocument.location.href;
  //treat inputs of the table document
  var inputs=document.getElementsByTagName('INPUT');
  for (var i=0; i<inputs.length; i++)
  {
    var input=inputs[i];
    if (input.type!='text') continue;
    isRendered=true;
    var inputName=input.id;
    var inputValue=getUrlParameterValue(emxTableUrl,inputName);
    if (inputValue=='') continue;
    input.value=decodeURI(inputValue);
  }
  //treat selects of the table document
  var selects=document.getElementsByTagName('SELECT');
  var savedSearchComboName=getUrlParameterValue(emxTableUrl,'savedSearchCombo');
  for (i=0; i<selects.length; i++)
  {
    var select=selects[i];
    var selectName=select.id;
    var selectValue=(savedSearchComboName==selectName) ? getUrlParameterValue(emxTableUrl,'savedSearchName') : getUrlParameterValue(emxTableUrl,selectName+getComboSuffix());
    if (selectValue=='') continue;
    for (j=0; j<select.length; j++)
    {
      if (select.options[j].value==decodeURI(selectValue))
      {
        select.options[j].selected=true;
        continue;
      }
    }
  }
  //if table is rendered clearInterval
  if (isRendered==true && restoreFilterValuesTimer==null)
  {
    window.clearTimeout(restoreFilterValuesTimer);
  }
}

emxUICore.addEventHandler(window, "load", function() {
  restoreFilterValuesTimer=window.setTimeout('restoreFilterValues()',200);
});

/**
 * Runs a quick search from a table toolbar.<br>
 * This method can be called after a call to <code>runSavedSearchFromTable</code>.
 * @param searchProgramName the optional method to be used in order to execute the quick search.<br>
 *                          if not provided, the method used will be the original one.<br>
 *                          format: JPOProgram:JPOFunction.
 * @param newTableUrl 		this is an optional argument to specify the new table url to take into account 
 *  						if not provided, the original table href is used.
 */
function submitQuickFilter(searchProgramName, newTableUrl)
{
  //get the url which have been used to display the table
  var tableDocument=(this.name && this.name=='listHead') ?  /* portal mode */ this.parent.document : /* content or popup mode */ document;
  var emxTableUrl=tableDocument.location.href;
  // Replace table href by the given one
  if(null!=newTableUrl && ''!=newTableUrl){
	  emxTableUrl=newTableUrl;
  }
  //treat inputs of the current document
  var inputs=document.getElementsByTagName('INPUT');
  for (i=0; i<inputs.length; i++)
  {
    var input=inputs[i];
    if (input.type!='text' && input.type!='hidden') continue;
    var inputName=input.id;
    emxTableUrl=delParameterFromUrl(emxTableUrl,inputName);
    var inputValue=input.value;
    if (inputValue=='') continue;
    emxTableUrl=addParameterToUrl(emxTableUrl,inputName,inputValue);
  }
  //treat selects of the current document
  var selects=document.getElementsByTagName('SELECT');
  var savedSearchComboName=getUrlParameterValue(emxTableUrl,'savedSearchCombo');
  for (i=0; i<selects.length; i++)
  {
    var select=selects[i];
    var selectName=select.id;
    emxTableUrl=delParameterFromUrl(emxTableUrl,selectName+getComboSuffix());
    if (selectName==savedSearchComboName) continue;
    var selectValue=select.value;
    if (selectValue=='') continue;
    emxTableUrl=addParameterToUrl(emxTableUrl,selectName+getComboSuffix(),selectValue);
  }
  //restore the original parameters if a saved search have been launched before
  var originalParamValue=getUrlParameterValue(emxTableUrl,'originalHeader');
  if (originalParamValue!=null && originalParamValue!='') emxTableUrl=addParameterToUrl(emxTableUrl,"header",originalParamValue);
  originalParamValue=getUrlParameterValue(emxTableUrl,'originalProgram');
  if (originalParamValue!=null && originalParamValue!='') emxTableUrl=addParameterToUrl(emxTableUrl,"program",originalParamValue);
  originalParamValue=getUrlParameterValue(emxTableUrl,'originalProgramLabel');
  if (originalParamValue!=null && originalParamValue!='') emxTableUrl=addParameterToUrl(emxTableUrl,"programLabel",originalParamValue);
  originalParamValue=getUrlParameterValue(emxTableUrl,'originalInquiry');
  if (originalParamValue!=null && originalParamValue!='') emxTableUrl=addParameterToUrl(emxTableUrl,"inquiry",originalParamValue);
  originalParamValue=getUrlParameterValue(emxTableUrl,'originalInquiryLabel');
  if (originalParamValue!=null && originalParamValue!='') emxTableUrl=addParameterToUrl(emxTableUrl,"inquiryLabel",originalParamValue);
  //when requested, enforce program
  if (searchProgramName!=null && searchProgramName!='')
  {
    emxTableUrl=addParameterToUrl(emxTableUrl,"program",searchProgramName);
    emxTableUrl=delParameterFromUrl(emxTableUrl,"programLabel");
    emxTableUrl=delParameterFromUrl(emxTableUrl,"inquiry");
    emxTableUrl=delParameterFromUrl(emxTableUrl,"inquiryLabel");
  }
  //clean-up saved search parameters
  emxTableUrl=delParameterFromUrl(emxTableUrl,'savedSearchName');
  emxTableUrl=delParameterFromUrl(emxTableUrl,'savedSearchProgram');
  emxTableUrl=delParameterFromUrl(emxTableUrl,'savedSearchBaseUrl');
  emxTableUrl=delParameterFromUrl(emxTableUrl,'savedSearchCombo');
  emxTableUrl=delParameterFromUrl(emxTableUrl,'originalHeader');
  emxTableUrl=delParameterFromUrl(emxTableUrl,'originalProgram');
  emxTableUrl=delParameterFromUrl(emxTableUrl,'originalProgramLabel');
  emxTableUrl=delParameterFromUrl(emxTableUrl,'originalInquiry');
  emxTableUrl=delParameterFromUrl(emxTableUrl,'originalInquiryLabel');
  //redirect 
  //alert("emxTableUrl="+emxTableUrl);
  tableDocument.location.href=emxTableUrl;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SAVED SEARCH PURPOSE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Runs a saved search from a combobox command contained in a table toolbar.
 * This method can be called after a call to <code>submitQuickFilter</code>.
 * @param comboName the name of the combobox (i.e. the name of the combobox command).
 * @param savedSearchProgram the optional method to be used in order to execute the saved search.<br>
 *                          if not provided, the method used will be the original one.<br>
 *                          format: JPOProgram:JPOFunction.
 */
function runSavedSearchFromTable(comboName, savedSearchProgram)
{
  //get the selected saved search of from combo box
  var savedSearchCombo=document.getElementById(comboName);
  var savedSearchName=savedSearchCombo.options[savedSearchCombo.selectedIndex].value;
  var savedSearchDisplayName=savedSearchCombo.options[savedSearchCombo.selectedIndex].innerHTML;
  if (null==savedSearchName || savedSearchName.length==0) return;
  //find the table document
  var tableDocument=(this.name && this.name=='listHead') ?  /* portal mode */ this.parent.document : /* content or popup mode */ document;
  //builds the new table document url
  var emxTableNewUrl='../common/SMARunSavedSearchFromTable.jsp?'+getUrlParameters(tableDocument.location.href);
  emxTableNewUrl=addParameterToUrl(emxTableNewUrl,'savedSearchName',encodeURIComponent(savedSearchName));
  emxTableNewUrl=addParameterToUrl(emxTableNewUrl,'savedSearchDisplayName',encodeURIComponent(savedSearchDisplayName));
  emxTableNewUrl=addParameterToUrl(emxTableNewUrl,'savedSearchBaseUrl',tableDocument.location.pathname);
	  
  emxTableNewUrl=addParameterToUrl(emxTableNewUrl,'savedSearchCombo',comboName);
  if (undefined!=savedSearchProgram && savedSearchProgram!='')
  {
    emxTableNewUrl=addParameterToUrl(emxTableNewUrl,'savedSearchProgram',savedSearchProgram);
  }
  //run saved search execution jsp
  tableDocument.location.href=emxTableNewUrl;
}

/**
 * Fills a search form with a saved search from a combobox command contained in a table toolbar.
 * @param comboName the name of the combobox (i.e. the name of the combobox command).
 */
function loadSavedSearchInSearchForm(comboName)
{
  //get the selected saved search of from combo box
  var savedSearchCombo=document.getElementById(comboName);
  var savedSearchName=savedSearchCombo.options[savedSearchCombo.selectedIndex].value;
  if (null==savedSearchName || savedSearchName.length==0) return;
  //call Enovia standard methods
  getTopWindow().pageControl.setSavedSearchName(".emx"+savedSearchName);
  getTopWindow().pageControl.setDoSubmit(false);
  getTopWindow().importSavedSearchXML();
}

/***
*	
*	Method called by the refresh button on the work item details popup
*/
function refreshWorkItems() {
	// get the document form header
	var myForm = document.forms[0];
	
	// get the title which is in an h2 element
	var myTag = myForm.getElementsByTagName("h2")[0].textContent;
	
	// find the first space in the title
	var pos = myTag.indexOf(" ");
	
	// get the station name from the title
	var stationName = myTag.substring(0,pos);
	
	// reset the href to refresh the work item display for the station
	var newRef = '../simulationcentral/smaStationData.jsp?objectAction=wiDisplay&HelpMarker=SMAStation_WorkItemDisplay&stationName='
		+ stationName;
	getTopWindow().location.href=newRef;
}



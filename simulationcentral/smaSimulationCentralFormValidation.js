//
//  (c) Dassault Systemes, 2007, 2008
//
//@quickreview <sj4> <2010:10:22>  <Fix for IR-077644V6R2012WIM><V6R2012>

//constants declaration
var TRUE = "true",
FALSE = "false",
KEY_EDITABLE_IN_PS = "editableInPS",
KEY_ACTION = "Action",
VALUE_ACTION_HIDE = "hide",        
VALUE_ACTION_VIEW = "view",
VALUE_ACTION_EDIT = "edit",
VALUE_ACTION_EDIT_COMPULSORY = "edit compulsory",
VALUE_ACTION_CLONE = "clone";

function smaRunOptionTypeCallBack()
{
    var myForm = document.forms[0];
    var optType = myForm.CommandLineOption.value;
    if (optType == 'default')
    {
    	myForm.ExecuteCommand.readOnly = true;
    	myForm.ExecuteCommand.style.backgroundColor= "#A9A9A9";

    }
    else // custom
    {
    	myForm.ExecuteCommand.readOnly = false;
    	myForm.ExecuteCommand.style.backgroundColor= "#ffffff";
    }

    var tempValue = myForm.ExecuteCommand.value;
    myForm.ExecuteCommand.value = myForm.hiddenDefaultExecuteCommand.value;
    myForm.hiddenDefaultExecuteCommand.value = tempValue;
}


function smaHostListTypeCallBack()
{
	if (document.forms!= null && document.forms[0]!= null &&
			document.forms[0].HostList != null)
	{
	    var myForm = document.forms[0];
	    var host = myForm.HostList.value;
	    var displayStyle = "none";
	    var specifyValue = myForm.hiddenSpecifyExecuteDirectory.value;
	    specifyValue = specifyValue.toLowerCase();
	    // Fix for IR-098572V6R2012x changes for browser detection by m6d start
	    var browserName=navigator.appName;
	    var browserVer=parseInt(navigator.appVersion);
	    // Fix for IR-098572V6R2012x changes for browser detection by m6d end
	    if (specifyValue.indexOf("true") != -1)
	    {
    		if(browserName=='Microsoft Internet Explorer' && browserVer <8)
    		{
    			document.getElementById("calc_ExecutionDirectory").style.display="block";
    		}
    		else
    		{
    			document.getElementById("calc_ExecutionDirectory").style.display="table-row";
    		}
	    }
	    else
	    {
	    	document.getElementById("calc_ExecutionDirectory").style.display="none";
	    }
	    if (host.indexOf("SSH Server") != -1)
	    {
	    	// displayStyle changed from "block" to "table-row" and
	    	// vice - versa for mozilla/netscape by m6d start
	    	if(browserName == 'Netscape')
	    	{

	    		document.getElementById("calc_Host").style.display="table-row";
	    	}
	    	else if(browserName=='Microsoft Internet Explorer' && browserVer <8)
	    	{
	    		document.getElementById("calc_Host").style.display="block";
	    	}

	    	// displayStyle changed from "table-row" to "block" and vice - versa
	    	//for mozilla/netscape by m6d end

	    }
	    else
	    {
    		document.getElementById("calc_Host").style.display="none";

    		// displayStyle changed from "block" to "table-row" and
	    	// vice - versa for mozilla/netscape by m6d start
    		if(browserName=='Microsoft Internet Explorer' && browserVer <8){
    			displayStyle = "block";

    		}
    		else{
    			displayStyle = "table-row";
    		}

    		// displayStyle changed from "block" to "table-row" and
	    	// vice - versa for mozilla/netscape by m6d end
	    }
    	if (myForm.Station != null)
    	{
    		document.getElementById("calc_Station").style.display=
    			displayStyle;
    		document.getElementById("calc_MaxTime").style.display =
    			displayStyle;
    		document.getElementById("calc_Affinities").style.display =
    			displayStyle;
    		document.getElementById("calc_LogStdOut").style.display =
    			displayStyle;
    		document.getElementById("calc_LogStdErr").style.display =
    			displayStyle;
    		document.getElementById("calc_LogLevel").style.display =
    			displayStyle;
    		document.getElementById("calc_ReturnCodes").style.display =
    			displayStyle;
    		document.getElementById("calc_ExtendedWindowsDomain").style.display =
    			displayStyle;
    		document.getElementById("calc_ExtendedWindowsUsername").style.display =
    			displayStyle;
    		document.getElementById("calc_ExtendedWindowsPassword").style.display =
    			displayStyle;
    		document.getElementById("calc_ExtendedUnixUsername").style.display =
    			displayStyle;
    		document.getElementById("calc_ExtendedUnixPassword").style.display =
    			displayStyle;
    	}
        smaRunOptionTypeCallBack();
	}
}

function showModalDialogWithConfirm(confirmMsg,strURL, intWidth, intHeight, bScrollbars)
{
    var answer = confirm(confirmMsg);
    if (answer)
    {
        showModalDialog( strURL, intWidth, intHeight, bScrollbars);
    }
}

function smaRefCheckboxCallBack()
{
	if (document.forms!= null && document.forms[0]!= null &&
			document.forms[0].refCheckBox != null)
	{
	    var myForm = document.forms[0];
	    var check = myForm.refCheckBox.checked;

	    var checkValue = myForm.refCheckBox.value;
	    var shouldDisable = false;
	    if (check)
	    {
	    	shouldDisable = true;
	    }
	    else
	    {
	    	myForm.refCheckBox.disabled = true;
	    }
    	if (checkValue == "ExportRules")
    	{
    		myForm.ExportSource.disabled = shouldDisable;
    		myForm.SourceDocTitle.disabled = shouldDisable;
    		myForm.ExportDocType.disabled = shouldDisable;
    		myForm.ContentRel.disabled = shouldDisable;
    		myForm.ImpactRel.disabled = shouldDisable;
			smaPLMObjectParameterValidation();
    	}
    	else if (checkValue == "ImportRules")
    	{
    		myForm.ImportCategory.disabled = shouldDisable;
    		myForm.TitleSpecification.disabled = shouldDisable;
    		myForm.DocumentTitle.disabled = shouldDisable;
    		myForm.ImportDocTypeCreate.disabled = shouldDisable;
    		myForm.ImportDocPolicyCreate.disabled = shouldDisable;
    		myForm.ContentRelCreate.disabled = shouldDisable;
    		myForm.ImpactRelCreate.disabled = shouldDisable;
			smaPLMObjectParameterValidationImportRule();
    	}
	}
}

function showPageURLPane(event,url)
{

	var pageURLDiv;
	var textfield;
    if(this.document.getElementById("pageURLDiv"))
	{
		pageURLDiv = this.document.getElementById("pageURLDiv");
		textfield = this.document.getElementById("pageURLTextBox");
	}
	else
	{
		pageURLDiv = this.document.createElement("div");
		textfield = this.document.createElement("input");
	}

	pageURLDiv.className = "pageURLDiv";
	pageURLDiv.id = "pageURLDiv";
	pageURLDiv.name = "pageURLDiv";
	pageURLDiv.style.top = event.clientY +"px";
    pageURLDiv.style.left = event.clientX +"px";
    textfield.className = "pageURL";
    textfield.setAttribute("type", "text");
    textfield.setAttribute("id", "pageURLTextBox");
   //Fix for IR-077644V6R2012WIM<V6R2012>
    var urlString = getTopWindow().location.href;
    var checkIfObject= urlString.search(/\?/i);
    if(checkIfObject != "-1"){
    	urlString = urlString.substring(0,urlString.indexOf("\?"));
    }
    //End of Fix for IR-077644V6R2012WIM<V6R2012>
    textfield.setAttribute("value",urlString+url);
    textfield.style.visibility = "visible";
    pageURLDiv.appendChild(textfield);
    setTimeout(function(){
    	textfield.focus();
    	textfield.select();},50);
    document.body.appendChild(pageURLDiv);

    if(isIE){
		addEvent(pageURLDiv, "mouseout", function () {setTimeout("removePageURLDiv()", 1000);});
	}else{
		var pageURLDivHidden = this.document.createElement("div");
		pageURLDivHidden.className = "pageURLDivHidden";
		pageURLDivHidden.id = "pageURLDivHidden";
		pageURLDivHidden.name = "pageURLDivHidden";
	    pageURLDiv.appendChild(pageURLDivHidden);
		addEvent(pageURLDivHidden, "mouseout", function () {setTimeout("removePageURLDiv()", 1000);});
	}
}

// Function sends refresh to structure browser. different frame will be required based on
// left or right side refresh
function refreshStructureBrowser(frameContent){


	var urlParameters = resetParameter("refreshFrame", frameContent.name);
    urlParameters = resetParameter("action", "refresh");
    urlParameters = resetParameter("HelpMarker", "SMAHome_ActionsRefresh");
    urlParameters = resetParameter("commandURL", "../simulationcentral/smaStructureBrowserUtil.jsp");
    var url ="../simulationcentral/smaTurnOnProgress.jsp";
    var frame = findFrame(getTopWindow(), "hiddenFrame");
    var form    = frame.document.createElement('form');
    form.name   = "emxHiddenForm";
    form.id     = "emxHiddenForm";

    frame.document.body.appendChild(form);
    var formFieldValues = getKeyValuePairs(urlParameters);
    for(var index=0; index<formFieldValues.length; index++)
    {
 	  var input   = frame.document.createElement('input');
 	  input.type  = "hidden";
 	  input.name  = formFieldValues[index].name;
 	  input.value = decodeURIComponent(formFieldValues[index].value);
 	  form.appendChild(input);
 	 }

     form.action = url;
     form.method = "post";
     form.target = "hiddenFrame";
     form.submit();
}
// Function written to fix IR-123561V6R2012x.
// Checkout of Enovia did not refresh structure browser the way we wanted so
// we have implemented it in our way.
function smaCallCheckout(objectId, action, fileName, format, refresh, closeWindow, appName, appDir, partId, version,SB,customSortColumns,

customSortDirections,uiType, table,tableRowId,getCheckoutMapFromSession ,fromDataSessionKey,parentOID )
{

	callCheckout(objectId, action, fileName, format, refresh, closeWindow, appName, appDir, partId, version,SB,customSortColumns,

customSortDirections,uiType, table,getCheckoutMapFromSession ,fromDataSessionKey,parentOID );

	//setTimeout("refreshStructureBrowser(table)",1000);
	var frameContent = null;


	if(table != null && table == 'SMAContent_Results'){
		frameContent = findFrame(getTopWindow(), "detailsDisplay");
	}
	if(table != null && table == 'SMAHome_BrowseTree'){
		frameContent = findFrame(getTopWindow(), "smaHomeTOCContent");
	}
	if(table == null){
		frameContent = findFrame(getTopWindow(), "detailsDisplay");
	}


	setTimeout(function(){refreshStructureBrowser(frameContent)}, 5000);

}
function smaPLMObjectParameterValidation(){
	
	var parameterName = document.forms[0].Parameters.value;
	if (parameterName == '')
	{
		document.forms[0].ExportSource.disabled = false;
		document.forms[0].ExportDocType.disabled = false;
		document.forms[0].ContentRel.disabled = false;
		document.forms[0].ImpactRel.disabled  = false;
		document.forms[0].SourceDocTitle.disabled = false;
		//document.forms[0].SourceDocTitle.value = "";
		document.forms[0].SourceDocTitle.style.visibility = "visible";
	}
	else{
		document.forms[0].SourceDocTitle.value = "*";
		document.forms[0].SourceDocTitle.style.visibility = "hidden";
		document.forms[0].SourceDocTitle.disabled  = true;
		document.forms[0].ExportSource.disabled = true;
		document.forms[0].ExportDocType.disabled = true;
		document.forms[0].ContentRel.disabled = true;
		document.forms[0].ImpactRel.disabled  = true;
	}
}

function smaPLMObjectParameterValidationImportRule(){
	
	var parameterName = document.forms[0].Parameters.value;
	if (parameterName == '')
	{
		document.forms[0].ImportCategory.disabled = false;
	}
	else{
		document.forms[0].ImportCategory.disabled = true;
	}
}

function smaParameterValueTypeValidation(){
	var parameterValueType = document.getElementById("ValueTypeId");
	var parameterValueTypeVal = parameterValueType.value;
	var parameterType = document.getElementById("TypeId");
	var parameterTypeVal = parameterType.value;
	
	var row_PLMObject = document.getElementById("calc_PLMObject");
	var row_value = document.getElementById("calc_value");
	var row_Expression = document.getElementById("calc_Expression");
	var row_Dimension = document.getElementById("calc_Dimension");
	var row_SizeOfArray = document.getElementById("calc_SizeOfArray");
	var row_choices = document.getElementById("calc_choices");
	var row_Subtype = document.getElementById("calc_Subtype");
	
	if (parameterValueTypeVal == 'array')
	{
		parameterType.options[4].disabled=true;
		parameterType.options[5].disabled=true;
		document.forms[0].plmObjectChooserButton.disabled = true;
		hideElement(new Array(row_PLMObject, row_value, row_Expression, row_choices));
		showElement(new Array(row_Dimension, row_SizeOfArray));
		if (parameterTypeVal == 'plmobject' || parameterTypeVal == 'timestamp') {
				parameterType.value = "real";
		} else if (parameterTypeVal == 'string') {
			hideElement(new Array(row_Subtype));
		}
	}
	else if (parameterValueTypeVal == 'single') {
		parameterType.options[4].disabled=false;
		parameterType.options[5].disabled=false;
		hideElement(new Array(row_Dimension, row_SizeOfArray));
		if (parameterTypeVal == 'plmobject') {
			showElement(new Array(row_PLMObject));
			document.forms[0].plmObjectChooserButton.disabled = false;
			hideElement(new Array(row_value, row_Expression, row_choices, row_Subtype));
		} else if (parameterTypeVal == 'timestamp') {
			hideElement(new Array(row_PLMObject, row_Subtype));
			document.forms[0].plmObjectChooserButton.disabled = true;
			showElement(new Array(row_choices, row_value, row_Expression));
		} else if (parameterTypeVal == 'string') {
			showElement(new Array(row_Subtype, row_value, row_Expression, row_choices));
			hideElement(new Array(row_PLMObject));
			document.forms[0].plmObjectChooserButton.disabled = true;
		}
		else {
			hideElement(new Array(row_PLMObject, row_Subtype));
			document.forms[0].plmObjectChooserButton.disabled = true;
			showElement(new Array(row_value, row_Expression, row_choices));
		}
	}
}

function hideElement(elementArr)
{
	for (var i=0;i<elementArr.length;i++)
	{ 
		var element = elementArr[i];
	element.style.visibility = "hidden";
	element.style.display = "none";
	var elementVal = element.nextSibling;
	elementVal.style.visibility = "hidden";
	elementVal.style.display = "none";
}
}
function showElement(elementArr)
{
	for (var i=0;i<elementArr.length;i++)
	{
		var element = elementArr[i];
	element.style.visibility = "";
	element.style.display = "";
	var elementVal = element.nextSibling;
	elementVal.style.visibility = "";
	elementVal.style.display = "";
	}
}

function smaMultiValueTypeAttrValidation()
{
	var isMultivalueAttr = document.forms[0].IsMultivalue.value;
	if (isMultivalueAttr == 'true')
	{
		document.forms[0].Default.disabled = true; //disabled for multivalue attributes
		//calc_Default, calc_Choices, calc_Minimum, calc_Maximum
		document.forms[0].Default.value = "";
		//document.forms[0].Choices.value = "";
		document.forms[0].Minimum.value = "";
		document.forms[0].Maximum.value = "";
		
		
	} else {
		document.forms[0].Default.disabled = false; //enabled for single value attributes
		document.forms[0].Choices.disabled = false;
		document.forms[0].Minimum.disabled = false;
		document.forms[0].Maximum.disabled = false;
		
		document.forms[0].Default.value = "";
		document.forms[0].Default.readOnly = false;
		
		//document.forms[0].Choices.value = "";
		document.forms[0].Choices.readOnly = false;
		
		document.forms[0].Minimum.value = "";
		document.forms[0].Minimum.readOnly = false;
		
		document.forms[0].Maximum.value = "";
		document.forms[0].Maximum.readOnly = false;
		}
	//calc_Default, calc_Choices, calc_Minimum, calc_Maximum these fields are not supported for the 
	//boolean multiline and timestamp type attribute
	var type = document.forms[0].TypeId.value;  
	if((document.forms[0].Type.value=="boolean" || 
			document.forms[0].Type.value=="timestamp" ||
			document.forms[0].Type.value=="multiline") && 
			document.forms[0].IsMultivalue.value=="true"){
		
		document.forms[0].Choices.disabled = true;
		document.forms[0].Minimum.disabled = true;
		document.forms[0].Maximum.disabled = true;
	}
	else if (!(document.forms[0].Type.value=="boolean" || 
			document.forms[0].Type.value=="timestamp" ||
			document.forms[0].Type.value=="multiline") && 
			document.forms[0].IsMultivalue.value=="true"){
		
		document.forms[0].Choices.disabled = false;
		document.forms[0].Minimum.disabled = false;
		document.forms[0].Maximum.disabled = false;
	}//Support_Ranges_In_Multivalue Attributes
	
	// Display 'Required' for Integer, Real and Boolean type attribute
	if((document.forms[0].Type.value=='integer' || 
			document.forms[0].Type.value=='real'||
			document.forms[0].Type.value=='boolean')&&
			document.forms[0].IsMultivalue.value=="false")
	{
		var child =$('#calc_Default').find('td[class*="label"]');
		child.removeClass("label");
		child.addClass("labelRequired");
	}else{
		var child =$('#calc_Default').find('td[class*="labelRequired"]');
		child.removeClass("labelRequired");
		child.addClass("label");
	}
	// Display 'Required' for Integer, Real and Boolean type attribute
}

function smaEditAttrValidation()
{
	//emxFormGetValue
	//calc_Default, calc_Choices, calc_Minimum, calc_Maximum
	var isEditForm = document.forms[0].IsMultivalue.disabled;
	
	if (!isEditForm)
		document.forms[0].IsMultivalue.disabled = true;

	var isMultivalueAttr = document.forms[0].IsMultivalue.value;
	if (isMultivalueAttr == 'multival')
	{
		document.forms[0].Default.disabled=true;
		document.forms[0].Default.value = "";

	} else {
		document.forms[0].Default.readOnly = false;
		document.forms[0].Choices.readOnly = false;
		document.forms[0].Minimum.readOnly = false;
		document.forms[0].Maximum.readOnly = false;
    }
	var type = document.document.forms[0].TypeId.value;  
	if(type=="boolean"||type=="multiline"||type=="timestamp"){
		
		document.forms[0].Choices.disabled = true;
		document.forms[0].Minimum.disabled = true;
		document.forms[0].Maximum.disabled = true;
	}
	else if (!(type=="boolean"||type=="multiline"||type=="timestamp")){
		
		document.forms[0].Choices.disabled = false;
		document.forms[0].Minimum.disabled = false;
		document.forms[0].Maximum.disabled = false;
	}
	
}

function smaEditAttributeInGroup()
{
	//emxFormGetValue
	var isEditForm = document.forms[0].IsMultivalue.disabled;

	if (!isEditForm)
		document.forms[0].IsMultivalue.disabled = true;
	var calc_Type = document.getElementById("calc_Type");
	var type = calc_Type.getElementsByTagName('td')[1].innerHTML;
	type=type.replace("&nbsp;","");
	if(type =="Boolean" || type =="Date" || type =="Multiline String")
		{
		document.forms[0].Choices.disabled = true;
		document.forms[0].Minimum.disabled = true;
		document.forms[0].Maximum.disabled = true;
		}
	if(!(type =="Boolean" || type =="Date" || type =="Multiline String"))
		{
		document.forms[0].Choices.disabled = false;
		document.forms[0].Minimum.disabled = false;
		document.forms[0].Maximum.disabled = false;
		}
				
	
}
function onFixedseedClick(checkboxfield) {
    if(checkboxfield.checked)
    {
      document.forms[0]['modelSeedValue'].disabled = false;      
           
    }
    else
    {
        document.forms[0]['modelSeedValue'].disabled = true;             
    }
}

function validateValueField()
{	
	var optValue = getValueForColumn('value');
	var optExpr = getValueForColumn('Expression');
    
	if(optExpr != "" && optValue != "")
	{	               
		alert("You have entered both Expression and Value, Expression will be given priority.");                   
	}
}

function invertCheckboxState(checkBoxField)
{
	 var checkBoxId = ""+checkBoxField.id;
     var checkBoxValue = ""+checkBoxField.checked;

     var selector =   "input[name = "+checkBoxId+"][type ='hidden']"; 
	 if($(selector))
	 {
		$(selector).val(checkBoxValue);
	 }
	 checkBoxField.value = ""+checkBoxField.checked;
}

function onClickHandleForDisplayMode(radioButton)
{
	if(radioButton.checked){

		var radioButtonId = radioButton.id,//used for creating id of checkbox
		radioButtonValue = radioButton.value,
		editableInPSId = radioButtonId.replace(KEY_ACTION, KEY_EDITABLE_IN_PS);
		var nodeListArray = document.getElementsByName(editableInPSId);
		var checkBoxFieldArray = [];
		
		//replacing "Array.from" with for loop for shallow copy of array as "Array.from" is not supported in IE
		for(var i=-1,l=nodeListArray.length;++i!==l;checkBoxFieldArray[i]=nodeListArray[i]); 
		
		if(radioButtonValue == VALUE_ACTION_HIDE || radioButtonValue == VALUE_ACTION_VIEW || radioButtonValue == VALUE_ACTION_CLONE){
			for (var int = 0; int < checkBoxFieldArray.length; int++) {
				checkBoxFieldArray[int].disabled = false;
			}
		}
		else if(radioButtonValue == VALUE_ACTION_EDIT || radioButtonValue == VALUE_ACTION_EDIT_COMPULSORY){
			for (var int = 0; int < checkBoxFieldArray.length; int++) {
				checkBoxFieldArray[int].disabled = true;
				checkBoxFieldArray[int].checked = true;
				checkBoxFieldArray[int].value = TRUE;
			}
		}
	}
}

//TODO: Might need to move these methods into new file
function showImage(imageTableDiv) {
		
	var anchorTag = imageTableDiv.children[0],
	imageTag = anchorTag.children[0],
	imageURL = imageTag.src;
	
	//Create img element for image to be shown on mouse over 
	var image = document.createElement("img");
	image.src = imageURL;
	image.style.top = "0px";
	image.style.position = "fixed";	
	
	//Create container for img element created above
	var divForImage = document.createElement("div");
	divForImage.id = "imageContainerDiv";
	divForImage.appendChild(image);
	
	var detailsDisplay = findFrame(getTopWindow(), "detailsDisplay");	
	if(detailsDisplay)
		detailsDisplay.document.body.appendChild(divForImage);
	
	imageTableDiv.style.zIndex = "1";
	/*We want only imageTableDiv to receive onmouseover/onmouseout, in 
	 * case when imageTableDiv & divForImage overlaps. To ensure this, 
	 * we needed increase z-index of imageTableDiv */ 
	imageTableDiv.style.opacity = "0";
	/*In case when, imageTableDiv & divForImage overlaps, imageTableDiv 
	 * will be on foreground so as to receive the mouse events but it 
	 * should not be annoying to user, so we have made it complete transparent */
}

function hideImage(imageTableDiv) {
	
	/*Reset the properties to their original values*/
	imageTableDiv.style.zIndex = "0";
	imageTableDiv.style.opacity = "1";	
	
	var detailsDisplay = findFrame(getTopWindow(), "detailsDisplay");	
	if(detailsDisplay) {
		var divForImage = detailsDisplay.document.getElementById('imageContainerDiv');
		divForImage.parentNode.removeChild(divForImage);
	}
}


//Validation function for Process,Activity and Step's title
/*
 * args1 : this the name of title field
 * args2 : JSON object which contains details of old and current value of title field
 */
function titleValidation(args1,args2)
{
	var allBadChars ="";
	var badCharsInTitle ="";
	var title =args2.current.actual;
	var badCharacters = ARR_NAME_BAD_CHARS;
	
	if(badCharacters.indexOf(".")===-1)
	{
		badCharacters.push(".")
	}
	for(var i=0;i<badCharacters.length;i++)
	{
		allBadChars  = allBadChars+" "+badCharacters[i];
		if(title.includes(badCharacters[i]))
			{
			badCharsInTitle = badCharsInTitle+" "+badCharacters[i];
	        }
	}
	if(badCharsInTitle.length>0)
	{
	alert("Your input contains the following invalid character(s):\n"+badCharsInTitle+"\nThe characters listed below are not allowed for input:\n"+allBadChars+"\nPlease remove the invalid character from Title field");
	document.forms[0]["Title"].value=args2.old.actual;
	
	}
	
}

//disables Location Group field if Co-Simulation Group field is entered
//since these two fields are mutually exclusive
function smaExeOptionsDisableLocationGroup()
{	
	var coSimGroup = document.getElementById("CosimGroup");
	var locationGroup = document.getElementById("Group");
	if (coSimGroup.value !== '') {
		locationGroup.value = '';
		locationGroup.disabled = true;
	}
	else {
		locationGroup.disabled = false;
	}
}

/**
 * @author b1r
 */

var multiValueCount = 0;

function changeHandlerForCriteriaAttributes() {
	emxFormReloadField("CriteriaAttributes");
}

function addMultiValue(thisElem, fieldName) {
	var closestTR = $(thisElem).closest("tr");
	var clonedTR = $(closestTR).clone();
	var hiddenField = $(closestTR).closest("tbody").children("input");
	multiValueCount = $(hiddenField).attr("multiValueAttrCount");//$(closestTR).closest("tbody").children("tr").length;
	
	multiValueCount++;
	var newFieldName = fieldName + "_mva_" + multiValueCount;
	var inputElem = $(clonedTR).find("td:first-child").children();
	$(inputElem).attr("id", newFieldName).attr("name", newFieldName);
	$(inputElem).val("");
	$(clonedTR).insertAfter($(closestTR));
	var noOfMultivalues = $(clonedTR).children("td").length;//$(closestTR).closest("tbody").children("tr").length;
	if(noOfMultivalues == 2) {
		var _td = $(document.createElement("td"));
		var _image = $(document.createElement("img"))
		.attr("src", "../common/images/iconActionListRemove.gif")
		.attr("onClick", "deleteMultiValue(this, '"+fieldName+"')")
		.css("cursor", "pointer");

		$(clonedTR).append(_td);
		$(_td).append(_image);
	}
	$(hiddenField).val($(hiddenField).val()+":"+newFieldName).attr("multiValueAttrCount", multiValueCount);
}

function deleteMultiValue(thisElem, fieldName) {
	var closestTR = $(thisElem).closest("tr");
	var inputElem = $(closestTR).find("td:first-child").children();
	var hiddenField = $(closestTR).closest("tbody").children("input");
	var hiddenFieldValueArr = $(hiddenField).val().split(":");
	var newValueForHiddenField = "";
	for(var i=1; i < hiddenFieldValueArr.length; i++){
		if(inputElem.attr("id") != hiddenFieldValueArr[i]) {
			newValueForHiddenField+= ":"+hiddenFieldValueArr[i];
		}
	}
	$(hiddenField).val(newValueForHiddenField);
	$(closestTR).detach();
}

function isInteger(fieldName) {
    var value = $(fieldName).val();
   	var numbers = "0123456789";
	for(var i = 0; i < value.length; i++)	{
		if(numbers.indexOf(value.charAt(i)) == -1) {
		  return false;
		}
	}
	return true;
}

function getFieldDisplayName(fieldObj){
	if(	typeof fieldObj.title != "undefined" ) 
  	{
		return fieldObj.title;
    	} 
  	else if(typeof getFieldLabelString(fieldObj) == "undefined" && typeof fieldObj.fieldLabel == "undefined" )
  	{
  		return fieldObj.id;
    	} 
    	else if(typeof getFieldLabelString(fieldObj) == "undefined")
    	{
    		return fieldObj.fieldLabel;
    	} else {
    		return getFieldLabelString(fieldObj);
    	}
}

/**
/* Below methods are used for form validations
 * Checking for Bad characters in the Text Area, Notes and other String fields
 */
function checkBadChars(thisElem) {
	if(!thisElem)
       	thisElem=this;
       	
    var badChars = checkForBadChars(thisElem);
    if(badChars.length != 0) {
       	thisElem.focus();
       	//$(thisElem).attr('style', "border-radius: 5px; border:#FF0000 1px solid;");
       	alert(getFieldDisplayName(thisElem)+INVALID_INPUT_MSG + STR_BAD_CHARS);
       	return false;
   	}
   	
   	/*if(	$(thisElem).attr('style'))
   		$(thisElem).attr('style', '');*/
   	
    return true;
}

function validateNumericField(thisElem) {
	if(!thisElem)
       	thisElem=this;
       	
	if(isNaN(thisElem.value)){
		thisElem.focus();
		alert(INVALID_NUMERIC_VALUE +" "+getFieldDisplayName(thisElem));
		return false;
	}
	/*if(!isNumeric(thisElem, true)) {
		alert(1);
		thisElem.focus();
		return false;
	}*/
	return true;
}

function validateIntegerField(thisElem) {
	if(!isInteger(thisElem)){
		thisElem.focus();
		alert(INVALID_INTEGER_VALUE+" "+getFieldDisplayName(thisElem));
		return false;
	}
	return true;
}

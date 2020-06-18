
<%@ page contentType="text/javascript; charset=UTF-8"%>
<jsp:include page="../parameter/emxParameterFormEvents.js" />


/*!================================================================ *
Update of dimensions in the Create Parameter panel *
emxParameterUIFormCreateValidation.js * Version 1.0 * Requires:
(nothing) * Last Updated: 4-May-12, Guillaume Malaubier (GMX) * *
Copyright (c) 1992-2012 Dassault Systemes. All Rights Reserved. * This
program contains proprietary and trade secret information * of
MatrixOne,Inc. Copyright notice is precautionary only * and does not
evidence any actual or intended publication of such program
*================================================================= */

function closePopupWindow(win) 
{
  if (getTopWindow().opener)
  {
   parent.window.close();
  }
  else
  {
   window.location.href="../common/emxLogin.jsp";
  }
 
}

function checkBadChars(fieldName)
{
	if ( !fieldName ){
    	fieldName=this;
    }
    var fieldValue = fieldName.value;

    if ( fieldValue == "" ){
        return true;
    }
         var charArray = new Array(20);
		var forbiddenChars = "@ , * ? [ ] # $ { } \\\\ \\\" < > | ; & ' = % + \\/ ~ ` ^ ! : . ( )" ;
        charArray = forbiddenChars.split(" ");
		
		var strBadChars = "";
        for (var i=0; i < charArray.length; i++) {
                if (fieldValue.indexOf(charArray[i]) > -1) {
                        strBadChars += charArray[i] + " ";
                }
        }
		 
       
          if (fieldValue.length > 0 && strBadChars.length >= 1)
         {
			alert("These characters are not allowed in object name.") ;
			//TO DO: use nls
			return false;
         }
    return true;
}

function getFieldValue(iField, iSearchedString)
{
    var fieldValue = "";
    try {
        if ((null != iField) && (null != iSearchedString))
        {
            var parent = iField.parent();
            if (null != parent)
            {
                var html = parent.html();
                if ("" != html)
                {
                    var searchedString = iSearchedString.concat("=\"");
                    var start = html.indexOf(searchedString, 0) + searchedString.length;
                    var end = html.indexOf("\"", start);
                    fieldValue = html.substring(start, end);
                }
            }
        }
    } catch (ex) {
    }
    
    return fieldValue;
}

function onParameterComboChange(combo, isCurrentContext)
{
	if (!isDefined(isCurrentContext))
		isCurrentContext = true;

	// Declaration of endsWith that is not supported on IE
	if (!String.prototype.endsWith)
	{
		String.prototype.endsWith = function(searchString, position)
		{
			var subjectString = this.toString();
			if (typeof position !== 'number' || !isFinite(position) || Math.floor(position) !== position || position > subjectStringString.length)
			{
				position = subjectString.length;
			}
			position -= searchString.length;
			var lastIndex = subjectString.lastIndexOf(searchString, position);
			return lastIndex !== -1 && lastIndex === position;
		};
	}
		
    var context = isCurrentContext ? window : top.opener;
    
    if ((null != combo) && (-1 != combo.selectedIndex))
    {
        var paramType = combo.value;

        var $value = context.$("form[name='emxCreateForm'] #Value")[0];
        var $min = context.$("form[name='emxCreateForm'] #Min")[0];
        var $max = context.$("form[name='emxCreateForm'] #Max")[0];
        var $minIncluded = context.$("form[name='emxCreateForm'] #minIncludedId")[0];
        var $maxIncluded = context.$("form[name='emxCreateForm'] #maxIncludedId")[0];
        var $multiValueInput = context.$("form[name='emxCreateForm'] #MultiValue")[0];

        // the hidden input whose name is paramType exists only if the current type has some units
        var showRange = true, showMulti = true, showTolPre = true;
     	var isValTypeDisabled = false;
     	var isItfTypeDisabled = false;
     	
     	// define fields to display
         if ("BooleanParameter" == paramType)
         {
             getBooleanNLSValues(isCurrentContext);
                            
             showRange = false;
             showMulti = false;
			 showTolPre = false;
             isValTypeDisabled = true;
             isItfTypeDisabled = true;
         }
         else if  ("StringParameter" == paramType || paramType.endsWith("FormattedStringParameter"))
         {
             swapInputField("Value", false, null, isCurrentContext);
             
             showRange = false;
			 showTolPre = false;
             isItfTypeDisabled = true;

             if (paramType.endsWith("FormattedStringParameter"))
             {
				isValTypeDisabled = true;
             	isItfTypeDisabled = true;
             }
         }
         else if  ("IntegerParameter" == paramType)
         {
             swapInputField("Value", false, null, isCurrentContext);
			 
			 showTolPre = false;
             
             var min = parseInt($min.value);
             $min.value = isNaN(min) ? "" : min;
             
             var max = parseInt($max.value);
             $max.value = isNaN(max) ? "" : max;
       
             var multiValueInput = parseInt($multiValueInput.value);
             $multiValueInput.value = isNaN(multiValueInput) ? "" : multiValueInput;
	
             var value = parseInt($value.value);
             $value.value = isNaN(value) ? "" : value;
         }
         else
         {
             swapInputField("Value", false, null, isCurrentContext);
			 
			 if ("RealParameter" == paramType)
			 {
				 showTolPre = false;
			 }
            
             min = parseFloat($min.value);
             $min.value = isNaN(min) ? "" : min;
             
             max = parseFloat($max.value);
             $max.value = isNaN(max) ? "" : max;
             
             var multiValueInput = parseFloat($multiValueInput.value);
             $multiValueInput.value = isNaN(multiValueInput) ? "" : multiValueInput;
	
             value = parseFloat($value.value);
             $value.value = isNaN(value) ? "" : value;
         }
         
         // objective extension
         setInterfaceType("Specification", isItfTypeDisabled, isCurrentContext);
         
         // update valuation type field
		setValuationType("1", isValTypeDisabled, isCurrentContext); // SIMPLE (default)
         
         //update of the units
		updateDisplayUnits(paramType, isCurrentContext);
      
      	// show range & multivalues fields
         showValueField("Min", showRange, isCurrentContext);
         showValueField("Max", showRange, isCurrentContext);
         //showMultiValueField(showMulti, isCurrentContext);
		 showTolPreField(showTolPre, isCurrentContext);
    }
}

function onValTypeComboChange(combo, isCurrentContext)
{
	onValTypeChangeEvent(isCurrentContext);
}

function onAddValue()
{
	onAddValueEvent();
}

function onRemoveValue()
{
	onRemoveValueEvent();
}

function onChangeValue()
{
	onChangeValueEvent();
}

function onMinClicked()
{
	onMinClickedEvent();
}

function onMaxClicked()
{
	onMaxClickedEvent();
}

function onValueBlurred()
{
	onValueBlurredEvent();
}

function onMinBlurred()
{
	onMinBlurredEvent();
}

function onMaxBlurred()
{
	onMaxBlurredEvent();
}

function onInterfaceTypeChange(combo)
{
	 onInterfaceTypeChangeEvent(combo);
}

function onObjectiveTypeChange(combo)
{
	onObjectiveTypeChangeEvent(combo);
}

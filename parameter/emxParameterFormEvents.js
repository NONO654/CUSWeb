
function isDefined(iObject)
{
    return (null != iObject) && (undefined != iObject) ? true : false;
}

function parameterAlert(iKey)
{
	var xmlhttp;
    if (window.XMLHttpRequest) { 
		xmlhttp=new XMLHttpRequest();
    } else if (window.ActiveXObject) {
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    } else {
		alert("Your browser does not support XMLHTTP!");
    }
    
    xmlhttp.onreadystatechange=function() {
		if(xmlhttp.readyState==4 && xmlhttp.status==200){
			
			var error = "";
			if (xmlhttp.responseXML != null)
			{
				var resp = xmlhttp.responseXML.getElementsByTagName("error");
				if (resp != null && resp.length > 0)
				{
					var errorMessage = resp[0].textContent;
					if (errorMessage != iKey)
						error = errorMessage;
				}
			}
			
			if (error === "")
			{
				// the server did not return any message so they are hard coded
				if (iKey == "emxParameter.Error.ValueLessThanMin")
					error = "The seized value is less than the minimal value";
				else if (iKey == "emxParameter.Error.ValueGreaterThanMax")
					error = "The seized value is greater than the maximal value";
				else if (iKey == "emxParameter.Error.MinGreaterValue")
					error = "The seized minimal value is greater than the value";
				else if (iKey == "emxParameter.Error.MaxLessValue")
					error = "The seized maximal value is less than the value";
				else if (iKey == "emxParameter.Error.MinGreaterMax")
					error = "The seized minimal value is greater than the maximal value";
				else if (iKey == "emxParameter.Error.MaxLessMin")
					error = "The seized maximal value is less than the minimal value";
				else if (iKey == "emxParameter.Error.AlreadyInTheList")
					error = "value already present in the list";
				else if (iKey == "emxParameter.Error.MinStricLessValue")
					error = "The minimal value has to be strictly less than the value";
				else if (iKey == "emxParameter.Error.MaxStricGreaterValue")
					error = "The maximal value has to be strictly greater than the value";
				else if (iKey == "emxParameter.Error.MinStricLessAuthValues")
					error = "The minimal value has to be strictly less than the lowest authorized value";
				else if (iKey == "emxParameter.Error.MaxStricGreaterAuthValues")
					error = "The maximal value has to be strictly greater than the highest authorized value";
				else if (iKey == "emxParameter.Error.MinStricLessMultipleValues")
					error = "The minimal value has to be strictly less than the lowest multiple value";
				else if (iKey == "emxParameter.Error.MaxStricGreaterMultipleValues")
					error = "The maximal value has to be strictly greater than the highest multiple value";
			}
			
			if (error != null && error.length > 0)
				alert(error);
		}
	}

    xmlhttp.open("GET", "../parameter/emxParameterErrorMessageProcessing.jsp?key=" + iKey,true);
    xmlhttp.send(null);
}

function onAddValueEvent()
{
	try
	{
		var context = window.document ;
	    var $select = context.getElementById("MultiValueList");
		var $input = context.getElementById("MultiValue");
		var $hiddenSet = context.getElementById("MultiValueSet");
		var $min = context.getElementById("Min");
		var $minIncluded = context.getElementById("minIncludedId");
		var $max = context.getElementById("Max");
		var $maxIncluded = context.getElementById("maxIncludedId");
		var valuationType = window.$("#ValuationType").val();
		
		// get the selected value
		var selectedValue = $select.value;
		var newVal = $input.value;
		var minVal = $min.value;
		var isMinInc = $minIncluded.checked;
		var maxVal = $max.value;
		var isMaxInc = $maxIncluded.checked;
		
		var isValueValid = true;
		if (minVal.length > 0 && !isNaN(minVal) && (isMinInc == true && parseFloat(newVal) < parseFloat(minVal)) || (isMinInc == false && parseFloat(newVal) <= parseFloat(minVal)))
		{
			isValueValid = false;
			parameterAlert("emxParameter.Error.ValueLessThanMin");
		}
		if (isValueValid && maxVal.length > 0 && !isNaN(maxVal) && (isMaxInc == true && parseFloat(newVal) > parseFloat(maxVal)) || (isMaxInc == false && parseFloat(newVal) >= parseFloat(maxVal)))
		{
			isValueValid = false;
			parameterAlert("emxParameter.Error.ValueGreaterThanMax");
		}
		
		if (isValueValid == true)
		{
			// search the string in existing values
			var existingValues = $hiddenSet.value.split("|");
			if (valuationType == "2" || (valuationType == "1" && existingValues.indexOf(newVal) == -1))
			{
				// insert
				if (selectedValue == '' || selectedValue == 'Empty')
				{
					var newOption = context.createElement('option');
					newOption.innerHTML = newVal;
					newOption.value = newVal;
					
					$select.options.add(newOption);
	
					$hiddenSet.value = $hiddenSet.value + "|" + newVal;
	
					// scroll to the inserted option
					$select[$select.length-1].selected = true;
					$select[$select.length-1].selected = false;
				}
				// replace
				else
				{
					var selectedIndex = $select.selectedIndex;
					$select.options[selectedIndex].innerHTML = newVal;
					$select.options[selectedIndex].value = newVal;
					
					$hiddenSet.value = $hiddenSet.value.replace(selectedValue, newVal);
				}
				//$select.selectedIndex = 0;
				$input.value = "";
			}
			else
			{
				parameterAlert("emxParameter.Error.AlreadyInTheList");
			}
		}
    }
	catch (ex) {}
}

function onRemoveValueEvent()
{
	try
	{
		var context = window.document ;
	    var $select = context.getElementById("MultiValueList");
		var $input = context.getElementById("MultiValue");
		var $hiddenSet = context.getElementById("MultiValueSet");

		// get the selected value
		var selectedValue = $select.value;
		
		// remove input value from list
		if ($input.value == selectedValue)
		{
			$select.options[$select.selectedIndex].remove();
				
			$hiddenSet.value = $hiddenSet.value.replace("|"+$input.value, "");
			
			$select.selectedIndex = 0;
			$input.value = "";
		}
    }
	catch (ex) {}
}

function onChangeValueEvent()
{
	try
	{
		var context = window.document ;
		var $select = context.getElementById("MultiValueList");
		var $input = context.getElementById("MultiValue");

		if ($select.value != 'Empty')
			$input.value = $select.value;
    }
	catch (ex) {}
}

function onMinMaxClickedEvent(iMinMax, iIncluded)
{
	try
	{
		var context = window.document;
		var $included = context.getElementById(iIncluded);
		var isChecked = $included.checked;
		if (isChecked == false)
		{
			var $minMax = context.getElementById(iMinMax);
			var minMaxValue = $minMax.value;
			if (minMaxValue.length > 0 && !isNaN(minMaxValue))
			{
				var valuationType = window.$("#ValuationType").val();
				if (valuationType != "0")
				{
					var isValid = true;
					if (valuationType == "1")
					{
						// if a value has been set it has to be greater than the min or less than the max
						var $value = context.getElementById("Value");
						if (isDefined($value))
						{
							var val = $value.value;
							if (val.length > 0 && !isNaN(val))
							{
								if (parseFloat(val) == parseFloat(minMaxValue))
								{
									isValid = false;
									var errorMessage = iMinMax == "Min" ? "emxParameter.Error.MinStricLessValue" :
										"emxParameter.Error.MaxStricGreaterValue";
									parameterAlert(errorMessage);
								}
							}
						}
					}
					
					if (isValid)
					{
						// check of the MultiValues
						var $hiddenSet = context.getElementById("MultiValueSet");
						var valuesList = $hiddenSet.value;
						if (valuesList.length > 0)
						{
							var list = valuesList.split("|");
							if (list.length > 0)
							{
								function numSort(iList) {
									return iList.sort(function(a, b) {return +a - +b;});
								}
								var sortedList = numSort(list);
								var limit = iMinMax == "Min" ? sortedList[1] : sortedList[sortedList.length-1];
								if (parseFloat(limit) == parseFloat(minMaxValue))
								{
									isValid = false;
									if (valuationType == "1")
									{
										var errorMessage = iMinMax == "Min" ? "emxParameter.Error.MinStricLessAuthValues" :
											"emxParameter.Error.MaxStricGreaterAuthValues";
										parameterAlert(errorMessage);
									}
									else if (valuationType == "2")
									{
										var errorMessage = iMinMax == "Min" ? "emxParameter.Error.MinStricLessMultipleValues" :
											"emxParameter.Error.MaxStricGreaterMultipleValues";
										parameterAlert(errorMessage);
									}
								}
							}
						}
					}
					
					if (!isValid)
						$included.checked = true;
				}
			}
		}
	}
	catch (ex) {}
}

function onMinClickedEvent()
{
	onMinMaxClickedEvent("Min", "minIncludedId");
}

function onMaxClickedEvent()
{
	onMinMaxClickedEvent("Max", "maxIncludedId");
}

function onValueBlurredEvent()
{
	try
	{
		var valuationType = window.$("#ValuationType").val();
		if (valuationType === "1")
		{
			var context = window.document;
			var $value = context.getElementById("Value");
			var newVal = $value.value;
			var tolpreEnabled = false;
			if (newVal.length > 0 && !isNaN(newVal))
			{
				var $min = context.getElementById("Min");
				var $minIncluded = context.getElementById("minIncludedId");
				var $max = context.getElementById("Max");
				var $maxIncluded = context.getElementById("maxIncludedId");
				
				var minVal = $min.value;
				var isMinInc = $minIncluded.checked;
				var maxVal = $max.value;
				var isMaxInc = $maxIncluded.checked;
				
				var isValueValid = true;
				
				if (minVal.length > 0 && !isNaN(minVal) && (isMinInc == true && parseFloat(newVal) < parseFloat(minVal)) || (isMinInc == false && parseFloat(newVal) <= parseFloat(minVal)))
				{
					isValueValid = false;
					parameterAlert("emxParameter.Error.ValueLessThanMin");
				}
				if (isValueValid && maxVal.length > 0 && !isNaN(maxVal) && (isMaxInc == true && parseFloat(newVal) > parseFloat(maxVal)) || (isMaxInc == false && parseFloat(newVal) >= parseFloat(maxVal)))
				{
					isValueValid = false;
					parameterAlert("emxParameter.Error.ValueGreaterThanMax");
				}
				
				if (!isValueValid)
					$value.value = "";
				
				tolpreEnabled = isValueValid;
			}
			
			// Tolerance and Precision fields are enabled only if a valid value is entered
			var tolmin = context.getElementById('ToleranceMin');
			var tolmax = context.getElementById('ToleranceMax');
			var premin = context.getElementById('PrecisionMin');
			var premax = context.getElementById('PrecisionMax');
			if (tolmin != null && tolmax != null && premin != null && premax != null)
			{
				$(tolmin).prop('disabled', !isValueValid);
				$(tolmax).prop('disabled', !isValueValid);
				$(premin).prop('disabled', !isValueValid);
				$(premax).prop('disabled', !isValueValid);
				if (!isValueValid)
				{
					tolmin.value = "";
					tolmax.value = "";
					premin.value = "";
					premax.value = "";
				}
			}
		}
	}
	catch (ex) {}
}

function onMinMaxBlurredEvent(iMinMax)
{
	try
	{
		var context = window.document;
		var $min = context.getElementById("Min");
		var $minIncluded = context.getElementById("minIncludedId");
		var $max = context.getElementById("Max");
		var $maxIncluded = context.getElementById("maxIncludedId");
		var $value = context.getElementById("Value");
		var valuationType = window.$("#ValuationType").val();
		
		var minVal = $min.value;
		var isMinInc = $minIncluded.checked;
		var maxVal = $max.value;
		var isMaxInc = $maxIncluded.checked;
		var newVal = $value.value;

		var isValueValid = true;
		if (valuationType === "1" && newVal.length > 0 && !isNaN(newVal))
		{
			if (iMinMax === "Min" && minVal.length > 0 && !isNaN(minVal) &&
					(isMinInc == true && parseFloat(newVal) < parseFloat(minVal)) || (isMinInc == false && parseFloat(newVal) <= parseFloat(minVal)))
			{
				isValueValid = false;
				parameterAlert("emxParameter.Error.MinGreaterValue");
				$min.value = "";
			}
			
			if (isValueValid && iMinMax === "Max" && maxVal.length > 0 && !isNaN(maxVal) &&
					(isMaxInc == true && parseFloat(newVal) > parseFloat(maxVal)) || (isMaxInc == false && parseFloat(newVal) >= parseFloat(maxVal)))
			{
				isValueValid = false;
				parameterAlert("emxParameter.Error.MaxLessValue");
				$max.value = "";
			}
		}
		
		if (isValueValid && minVal.length > 0 && !isNaN(minVal) && maxVal.length > 0 && !isNaN(maxVal))
		{
			if (iMinMax === "Min" && (isMinInc == true && parseFloat(maxVal) < parseFloat(minVal)) || (isMinInc == false && parseFloat(maxVal) <= parseFloat(minVal)))
			{
				isValueValid = false;
				parameterAlert("emxParameter.Error.MinGreaterMax");
				$min.value = "";
			}
			
			if (isValueValid && iMinMax === "Max" && (isMaxInc == true && parseFloat(minVal) > parseFloat(maxVal)) || (isMaxInc == false && parseFloat(minVal) >= parseFloat(maxVal))) 
			{
				isValueValid = false;
				parameterAlert("emxParameter.Error.MaxLessMin");
				$max.value = "";
			}
		}
	}
	catch (ex) {}
}

function onMinBlurredEvent()
{
	onMinMaxBlurredEvent("Min");
}

function onMaxBlurredEvent()
{
	onMinMaxBlurredEvent("Max");
}

function showValueField(fieldId, show, isCurrentContext)
{
	if (!isDefined(isCurrentContext))
		isCurrentContext = true;
	
	var context = isCurrentContext ? window.document : top.opener.document;

	var $label = context.getElementById(fieldId+"CellId");
	var $cell = context.getElementById(fieldId+"CellEditId");
	
	if( show == true )
	{		
		$label.style.display = "";
		$cell.style.display = "";
	}
	else
	{		
		$label.style.display = "none";
		$cell.style.display = "none";
		
		var $field = context.getElementById(fieldId);
		
		if( $field != null )
				$field.value = "" ;
	}
		
}

function showTolPreField(show, isCurrentContext)
{
	showValueField("ToleranceMin", show, isCurrentContext);
	showValueField("ToleranceMax", show, isCurrentContext);
	showValueField("PrecisionMin", show, isCurrentContext);
	showValueField("PrecisionMax", show, isCurrentContext);
}

function showLabel(fieldId, show, isCurrentContext)
{
	if (!isDefined(isCurrentContext))
		isCurrentContext = true;
	
	var context = isCurrentContext ? window.document : top.opener.document;

	var $label = context.getElementById(fieldId+"CellId");
	$label.style.display = show == true ? "" : "none";
}

function showMultiValueField(show, isCurrentContext)
{
	if (!isDefined(isCurrentContext))
		isCurrentContext = true;
	
	var context = isCurrentContext ? window.document : top.opener.document;
	
	var $ifType = context.getElementById("InterfaceType");
	
	if($ifType.value == "Objective")
		show = false ;
	
	showValueField("MultiValue", show, isCurrentContext);

	if ( show == true )
	{
		var $multiValueList = context.getElementById("MultiValueList");
		
		while ( $multiValueList.options.length > 0 )
			 $multiValueList.remove(0);
		
		var newOption = context.createElement('option');
	    $multiValueList.options.add(newOption);
	                    
		newOption.innerHTML = "" ;  
		newOption.value = "Empty" ;
		
		var $hiddenSet = context.getElementById("MultiValueSet") ;
		$hiddenSet.value = "" ;
    }
	
}

function setValuationType(valType, isDisabled, isCurrentContext)
{
	if (!isDefined(isCurrentContext))
		isCurrentContext = true;
	
    var context = isCurrentContext ? window : top.opener;
    
	var valuationTypeField = context.$("#ValuationType");
	
	if (valType != "0" && valType != "1" && valType != "2")
		valType = "0";
	
	valuationTypeField.val(valType);
	valuationTypeField.prop('disabled', isDisabled);
	
	onValTypeChangeEvent(isCurrentContext); // update
}

// creation only !
function onValTypeChangeEvent(isCurrentContext)
{
	if (!isDefined(isCurrentContext))
		isCurrentContext = true;
	
    var context = isCurrentContext ? window : top.opener;

	var valuationType = context.$("#ValuationType").val();
	var valueField = context.$("#Value");
	
	if (isDefined(valuationType))
	{
		var valuationTypeHiddenField = context.$("#ValuationTypeHidden");
		valuationTypeHiddenField.val(valuationType);
		
		// NONE : reset and hide nominal value & multiple values
		if (valuationType == "0")
		{
			if (isDefined(valueField))
			{
				if ("[object HTMLSelectElement]" == valueField.valueOf())
					valueField.options[0].selected = true;
				else
					valueField.value = "";
			}
	
			showValueField("Value", false, isCurrentContext);
			showMultiValueField(false, isCurrentContext);
			showTolPreField(false, isCurrentContext);
		}
		// SIMPLE : show simple value field
		else if (valuationType == "1")
		{
			showValueField("Value", true, isCurrentContext);
			showMultiValueField(true, isCurrentContext);
			showTolPreField(true, isCurrentContext);
			showLabel("MultiValue", true, isCurrentContext);
			showLabel("MultiValue2", false, isCurrentContext);
		}
		// MULTI : hide simple value field [+ change MV field name (Auth instead of MV)]
		else
		{
			showValueField("Value", false, isCurrentContext);
			showMultiValueField(true, isCurrentContext);
			showTolPreField(false, isCurrentContext);
			showLabel("MultiValue", false, isCurrentContext);
			showLabel("MultiValue2", true, isCurrentContext);
		}
	}
}

function setInterfaceType(itfType, isDisabled, isCurrentContext)
{
	if (!isDefined(isCurrentContext))
		isCurrentContext = true;
	
	if (itfType != "Objective")
		itfType = "Specification";

	var ifTypeField = $("#InterfaceType");
	ifTypeField.val(itfType);
	ifTypeField.prop('disabled', isDisabled);
	
	onInterfaceTypeChangeEvent(ifTypeField, isCurrentContext); // update
}

function onInterfaceTypeChangeEvent(combo, isCurrentContext)
{
	if (!isDefined(isCurrentContext))
		isCurrentContext = true;
	
    var context = isCurrentContext ? window.document : top.opener.document;
	
	var $header = context.getElementById("ObjHeadingCellId");
	var $type = context.getElementById("ObjType");
	var $prob = context.getElementById("ProbabilityUnit");
	var $conf = context.getElementById("ConfidenceUnit");

	if(combo.value == "Objective")
	{
		$header.style.display = "";
		showValueField("ObjType", true, isCurrentContext);
		showValueField("Probability", true, isCurrentContext);
		showValueField("Confidence", true, isCurrentContext);
		
		$type.selectedIndex = 0;
		$prob.selectedIndex = 1;
		$conf.selectedIndex = 1;

		onObjectiveTypeChangeEvent($type);
	}
	else
	{
		$header.style.display = "none";
		showValueField("ObjType", false, isCurrentContext);
		showValueField("Probability", false, isCurrentContext);
		showValueField("Confidence", false, isCurrentContext);
		
		setValuationType("1", false, isCurrentContext); // SIMPLE (default)
	}
}

function onObjectiveTypeChangeEvent(combo)
{
	if(combo.value == "Target")
		setValuationType("1", true); // SIMPLE
	else // minimize/maximize
		setValuationType("0", true); // NONE
}

//edit only !
function onDisplayUnitChangeEvent()
{
	var paramType = $("#Dimension").val();
	var displayUnit = $("#DisplayUnit").val();
	var prevDisplayUnitField = $("#CurrentDisplayUnit");
	var valueField = $("#Value");
	var minField = $("#Min");
	var maxField = $("#Max");
	var multiValueCombo = $("#MultiValueList");
	var multiValueHidden = $("#MultiValueSet");
	var multiValueInput = $("#MultiValue");

	if (isDefined(paramType) && isDefined(prevDisplayUnitField) && isDefined(displayUnit))
	{
		if ("BooleanParameter" != paramType && "StringParameter" != paramType && "IntegerParameter" != paramType && "RealParameter" != paramType)
		{
			// value
			var value = null;
			if (isDefined(valueField))
				value = valueField.val();
			
			// min
			var min = null;
			if (isDefined(minField))
				min = minField.val();
				
			// max
			var max = null;
			if (isDefined(maxField))
				max = maxField.val();
			
			// multivalue
			var multiValue = null;
			if (isDefined(multiValueHidden))
				multiValue = multiValueHidden.val();
				
			var xmlhttp;
			if (window.XMLHttpRequest) {
				xmlhttp=new XMLHttpRequest();
			} else if (window.ActiveXObject) {
				xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
			} else {
				alert("Your browser does not support XMLHTTP!");
			}
		
			xmlhttp.onreadystatechange=function() {
				if(xmlhttp.readyState==4 && xmlhttp.status==200){
					var paramValue, paramMin, paramMax, paramMV;
					if (xmlhttp.responseXML != null)
					{
						paramValue = xmlhttp.responseXML.getElementsByTagName("paramValue");
						paramMin = xmlhttp.responseXML.getElementsByTagName("paramMin");
						paramMax = xmlhttp.responseXML.getElementsByTagName("paramMax");
						paramMV = xmlhttp.responseXML.getElementsByTagName("paramMV");
					}
					else
					{
						try {
							var parser = new DOMParser();
							var xmlDoc = parser.parseFromString(xmlhttp.responseText, "application/xml");
							paramValue = xmlDoc.getElementsByTagName("paramValue");
							paramMin = xmlDoc.getElementsByTagName("paramMin");
							paramMax = xmlDoc.getElementsByTagName("paramMax");
							paramMV = xmlDoc.getElementsByTagName("paramMV");
						}
						catch(e){}
					}
				
					// value
					if (isDefined(valueField) && isDefined(paramValue[0]))
						valueField.val(isNaN(paramValue[0].getAttribute('value')) ? "" : paramValue[0].getAttribute('value'));
					// min
					if (isDefined(minField) && isDefined(paramMin[0]))
						minField.val(isNaN(paramMin[0].getAttribute('value')) ? "" : paramMin[0].getAttribute('value'));
					// max
					if (isDefined(maxField) && isDefined(paramMax[0]))
						maxField.val(isNaN(paramMax[0].getAttribute('value')) ? "" : paramMax[0].getAttribute('value'));
					
					if (isDefined(multiValueCombo))
					{
						multiValueCombo.empty();
						$('<option>').val("Empty").text("").appendTo('#'+multiValueCombo.attr('id'));
						multiValueHidden.val("");
						
						if (paramMV != null && paramMV != undefined)
						{
							$.each(paramMV, function(i, val){
								if (!isNaN(val.getAttribute('value')))
								{
									// met a jour la combo list
									$('<option>').val(val.getAttribute('value')).text(val.childNodes[0].nodeValue).appendTo('#'+multiValueCombo.attr('id'));

									// met a jour le hidden set
									multiValueHidden.val(multiValueHidden.val()+"|"+val.getAttribute('value'));
								}
							});
							
							// remet Empty selected
							multiValueCombo.val($('#'+multiValueCombo.attr('id')+' option:first').val());
						}
						
						// met a jour le displayUnit
						$(prevDisplayUnitField).val(displayUnit);
						
						// vide le MV Input
						multiValueInput.val("");
					}
				}
			}

			if (prevDisplayUnitField.val() != displayUnit)
			{
				var url = "../parameter/emxParameterPrefDimensionProcessing.jsp?mode=convert&prevunit="+prevDisplayUnitField.val()+"&newunit="+displayUnit;
				
				if (isDefined(value))
					url += "&value="+encodeURI(value);
				if (isDefined(min))
					url += "&min="+encodeURI(min);
				if (isDefined(max))
					url += "&max="+encodeURI(max);
				if (isDefined(multiValue))
					url += "&multiValue="+encodeURI(multiValue);
					
				xmlhttp.open("GET", url, true);
				xmlhttp.send(null);
			}
		}
	}
}

function updateDisplayUnits(mag, isCurrentContext)
{
	if (!isDefined(isCurrentContext))
		isCurrentContext = true;
	
    var context = isCurrentContext ? window.document : top.opener.document;
    var dropDown = context.getElementById('DisplayUnit');
	
	var xmlhttp;
	if (window.XMLHttpRequest) { 
		xmlhttp=new XMLHttpRequest();
	} else if (window.ActiveXObject) {
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	} else {
		alert("Your browser does not support XMLHTTP!");
	}
	
	xmlhttp.onreadystatechange=function() {
		if(xmlhttp.readyState==4 && xmlhttp.status==200){
			var units;
			if (xmlhttp.responseXML != null)
				units = xmlhttp.responseXML.getElementsByTagName("unit");
			else
			{
				try {
					var parser = new DOMParser();
					var xmlDoc = parser.parseFromString(xmlhttp.responseText, "application/xml");
					units = xmlDoc.getElementsByTagName("unit");
				}
				catch(e){}
			}
		
			var defUnit;
			$(dropDown).empty();
			
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
			
			if ("BooleanParameter" == mag || "StringParameter" == mag || "IntegerParameter" == mag || "RealParameter" == mag || mag.endsWith("FormattedStringParameter"))
            	$(dropDown).prop('disabled', true);
           	else if (units != null && units != undefined)
			{
				for (var i=0; i<units.length; i++)
				{
					var unit = units[i];

					var newOption = context.createElement('option');
					newOption.innerHTML = unit.childNodes[0].nodeValue;
					newOption.value = unit.getAttribute('value');
					
					dropDown.options.add(newOption);
					
					//var option = new Option(unit.childNodes[0].nodeValue, unit.getAttribute('value'));
					//dropDown.options.add(option);

					if (unit.getAttribute('default') != null && unit.getAttribute('default') != undefined)
						defUnit = unit.getAttribute('value');
				}
				
				$(dropDown).val(defUnit);
				$(dropDown).prop('disabled', false);
			}
		}
	}

	xmlhttp.open("GET", "../parameter/emxParameterPrefDimensionProcessing.jsp?mode=units&mag="+mag,false);
	xmlhttp.send(null);
}

function getBooleanNLSValues(isCurrentContext){
	var tab= [];
	var xmlhttp;
	if (window.XMLHttpRequest) { 
		xmlhttp=new XMLHttpRequest();
	} else if (window.ActiveXObject) {
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	} else {
		alert("Your browser does not support XMLHTTP!");
	}
	
	xmlhttp.onreadystatechange=function() {
		if(xmlhttp.readyState==4 && xmlhttp.status==200){
			var values;
			if (xmlhttp.responseXML != null)
				values = xmlhttp.responseXML.getElementsByTagName("value");
			else
			{
				try {
					var parser = new DOMParser();
					var xmlDoc = parser.parseFromString(xmlhttp.responseText, "application/xml");
					values = xmlDoc.getElementsByTagName("value");
				}
				catch(e){}
			}
		
			if (values != null && values != undefined)
			{
				for (var i=0; i<2; i++)
					tab[i] = values[i].childNodes[0].nodeValue;
			}
			
            swapInputField("Value", true, tab, isCurrentContext);
		}
	}

	xmlhttp.open("GET", "../parameter/emxParameterPrefDimensionProcessing.jsp?mode=boolean",true);
	xmlhttp.send(null);
}

function swapInputField(iFieldName, isCombo, comboValue, isCurrentContext)
{
	if (!isDefined(isCurrentContext))
		isCurrentContext = true;
		
    try {
    	var context = isCurrentContext ? window : top.opener;
        var $field = context.$("#"+iFieldName );
        
        if (null != $field)
        {
            var type = $field.attr("type");
            var fieldLabel = iFieldName;
          
            if (isCombo && ("text" == type))
                $field.replaceWith("<select id=\"" + iFieldName + "\" name=\"" + iFieldName + "\" fieldlabel=\"" + fieldLabel + "\"><option value='Empty'>\t\t\t\t</option><option value=\"TRUE\" selected>"+comboValue[0]+"</option><option value=\"FALSE\">"+comboValue[1]+"</option></select>");
            else if (!isCombo)
            {
                var isSelect = false;
                if ((null != type) && (0 == type.indexOf("select"))) // for IE
                    isSelect = true;
                else if (!isDefined(type)) // for Chrome and FF
                {
                    var html = $field.html();
				
                    if (0 == html.toLowerCase().indexOf("<option"))
                        isSelect = true;
                }
                
                if (isSelect)
                    $field.replaceWith("<input type=\"text\" name=\"" + iFieldName + "\" id=\"" + iFieldName + "\" value=\"\" fieldlabel=\"" + fieldLabel + "\" size=\"20\" onkeypress=\"javascript:submitFunction(event)\">");
            }
        }
    } catch (ex) {
    }
}


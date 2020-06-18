/*************************************************************************
	@QuickReview B1r: 
	Change: Replacing all the validation functions from the validating JSPs into the js file.
***************************************************************************/

function cmCreatePreProcess (){
	getDimensionChooser();
	createDisplayUnitTextbox();
	$('#DisplayUnitTextId').hide();
	createCheckboxField('MinimalValue','minimalIncludedId');
	createCheckboxField('MaximalValue','maximalIncludedId');
	createMultiValueField();
	setDefaultValues();
}

function cmEditPreProcess (){
	createCheckboxField('MinimalValue','minimalIncludedId');
	createCheckboxField('MaximalValue','maximalIncludedId');
	createMultiValueField();
	//setDefaultValues();
	var dimension = $("#DimensionId").val();
	if(dimension == undefined)
		dimension = $('#DimensionHidden').val();
	if(dimension == 'IntegerParameter'||dimension == 'RealParameter'){
		var displayUnitVal = $('#DisplayUnitId').val();
		createDisplayUnitTextbox();
		$('#DisplayUnitId').hide();
		$('#DisplayUnitTextId').val(displayUnitVal);
	}else{
	changeDisplayUnit();
	}
	displayHideFieldsforEditCopy_Dimension();
	displayHideFieldsforEdit_valType();
	hideFieldsforEditandCopy();
	loadDefaultValuesTestMethodPreProcess();
}

function updateMinMaxIncluded(){
	var minMax = $('#MinMaxIncludedHidden').val();
	var val = minMax.split("|");
	var min = val[0];
	var max = val[1];
	if(val[0] == "1" || val[0]=="3"){
		$("#minimalIncludedId").prop( "checked", true );
	}else{
		$("#minimalIncludedId").prop( "checked", false );
	}
	if(val[1] == "1" || val[1]=="3"){
		$("#maximalIncludedId").prop( "checked", true );
	}else{
		$("#maximalIncludedId").prop( "checked", false );
	}
	
}

function hideFieldsforEditandCopy(){
	var IsCopy = $('#IsCopy').val();
	if(IsCopy == "1"){
		$('#DimensionHidden').closest('tr').hide();
		$('#calc_DimensionHidden').hide();
		$('#calc_DimensionHidden').next('tr').hide();
		$('#calc_DimensionHidden').next('tr').next('tr').hide();
		$('#ValuationTypeHidden').closest('tr').hide();
		$('#calc_ValuationTypeHidden').hide();
		$('#calc_ValuationTypeHidden').next('tr').hide();	
		$('#calc_ValuationTypeHidden').next('tr').next('tr').hide();	
		$('#IsCopy').hide();
		$('#calc_IsCopy').hide();
		$('#calc_IsCopy').next('tr').hide();
		$('#calc_IsCopy').next('tr').next('tr').hide();
		$('#calc_MinMaxIncludedHidden').hide();
		$('#calc_MinMaxIncludedHidden').next('tr').hide();
		$('#calc_MinMaxIncludedHidden').next('tr').next('tr').hide();
	}else{
		$('#DimensionHidden').closest('tr').hide();
		$('#calc_DimensionHidden').next('tr').hide();
		$('#calc_DimensionHidden').hide();
		$('#ValuationTypeHidden').closest('tr').hide();
		$('#calc_ValuationTypeHidden').next('tr').hide();	
		$('#calc_ValuationTypeHidden').hide();
		$('#MinMaxIncludedHidden').closest('tr').hide();
		$('#calc_MinMaxIncludedHidden').next('tr').hide();	
		$('#calc_MinMaxIncludedHidden').hide();
	}
}


function displayHideFieldsforEditCopy_Dimension(){
	var dimension = $('#DimensionHidden').val();
	var displayUnit = $("#DisplayUnitId").val();
	var IsCopy = $('#IsCopy').val();
	var pattern = /value=\'(.*?)\'/g;
	if(dimension == 'COLORParameter'){
		if(displayUnit == 'RGB'){	
			splitColorValues('NominalValue');
			splitColorValues('MinimalValue');
			splitColorValues('MaximalValue');
			splitColorValues('multiValueInputField');
		}else {
			//var pattern = /value=\'(.*?)\'/g;
			getMultiValues(pattern);
		}
	} else if(dimension == 'BooleanParameter'){
		$('#DisplayUnitId').prop('disabled', 'disabled');
		updateMinMaxIncluded();
		var nominalValue = $('#NominalValue').val();
		textToCombo('NominalValue', nominalValue);
		if(IsCopy == "1"){
			hideMinimalMaximalValueforCopy();
			hideMultiValueForCopy();
		}else{
			hideMinimalMaximalValueforEdit();
			hideMultiValueforEdit();
		}
		//var pattern =  /value=\'([a-z]+)\'/g;
		getMultiValues(pattern);
	}else if(dimension == 'IntegerParameter'||dimension == 'RealParameter'){
		updateMinMaxIncluded();
		$('#DisplayUnitId').prop('disabled', 'disabled');
		//var pattern =  /value=\'([0-9]+)\.*([0-9]+)\'/g;
		getMultiValues(pattern);
	}else if (dimension == 'StringParameter' || dimension == 'SubjectivityParameter' ){
		$('#DisplayUnitId').prop('disabled', 'disabled');
		if(IsCopy == "1"){
			hideMinimalMaximalValueforCopy();
		}else{
			hideMinimalMaximalValueforEdit();
		}
		if(dimension == 'SubjectivityParameter'){
			var nominalValuelabelTD = $("label[for=NominalValue]").closest('td');
			nominalValuelabelTD.attr("class","labelRequired");
			var multiValuelabelTD = $("label[for=MultiValue]").closest('td');
			multiValuelabelTD.attr("class","labelRequired");			
		}
		//var pattern =  /value=\'([a-z]+)\'/g;
		getMultiValues(pattern);
	}else if (dimension == 'CMYKFormattedStringParameter' || dimension == 'HEXFormattedStringParameter'|| dimension == 'RGBFormattedStringParameter'){
		$('#DisplayUnitId').prop('disabled', 'disabled');
		getMultiValues(pattern);
		disableMinMaxIncludedCheckBoxes();
	}else{
		updateMinMaxIncluded();
		//var pattern =  /value=\'([0-9]+)\.*([0-9]+)\'/g;
		getMultiValues(pattern);
	}
}

function displayHideFieldsforEdit_valType(){
	var valTyp = $('#ValuationTypeHidden').val();
	var IsCopy = $('#IsCopy').val();
	switch(valTyp){
	
	case '0':			
		if(IsCopy==1){
			hideNominalValueforCopy();
			hideMultiValueForCopy();
		}
		else{
			hideNominalValueforEdit();
			hideMultiValueforEdit();
		}
		break;
	case '2':
		if(IsCopy==1){
			hideNominalValueforCopy();
		}
		else{
			hideNominalValueforEdit();
		}
		break;
	}	
}

function splitColorValues(fieldID){
	var valueEdit = $("#"+fieldID).val();
	createThreeTextBoxes(fieldID);
	
	if(fieldID == "multiValueInputField"){
		var pattern = /value=\'(.*?)\'/g;
		getMultiValues(pattern);
	}else{	
		valueEdit = valueEdit.replace("(","");
		valueEdit = valueEdit.replace(")","");
		var res = valueEdit.split(",");
		$("#red"+fieldID).val(res[0]);
		$("#green"+fieldID).val(res[1]);
		$("#blue"+fieldID).val(res[2]);
	}	
}

function getMultiValues(pattern){
	var str = $('#MultiValue option:selected').next().val();
	var hiddenSet =  $('#hiddenMultiValue');
	var displayUnit = $("#DisplayUnitId").val();
	if((str !=null && str != "" && str != undefined ) && (str.indexOf("value")!= -1))
	{
		$('#MultiValue').find('[value="'+str+'"]').remove();
		var values = str.match(pattern);
		for(var i=0;i<values.length;i++){
			var val =values[i];
			/*if($('#DimensionHidden').val() == 'COLORParameter' && displayUnit == 'RGB' ){
				val = val.replace("value='","");
				val = val.replace("'","");
			}else{*/
				val = val.replace("value='","");
				val = val.replace("'","");
			//}
			addToMultiValue(val);
		}
	}
	if((str !=null && str != "" && str != undefined ) && (str.indexOf("|")!=-1)){
		hiddenSet.val(str);
		var arr = str.split("|");
		$('#MultiValue option:selected').remove();
		for(var i=0;i<arr.length;i++){
			$('#MultiValue').append('<option selected="selected" value="' + arr[i] + '">' + arr[i] + '</option>');
		}
		//$('#Select1').append
	}
}

function addToMultiValue(newValue){
	var context = window.document;
	var $select = context.getElementById("MultiValue");
	var $hiddenSet = context.getElementById("hiddenMultiValue");
	var newOption = context.createElement('option');
	newOption.innerHTML = newValue;
	newOption.value = newValue;
	newOption.selected = "selected";
	$select.options.add(newOption);
	$hiddenSet.value = $hiddenSet.value + "|" + newValue;
}

function getDimensionChooser(){
	var dimButton = $(document.createElement('input')).attr({ type: 'button', name:'dimChooser', id:'dimChooser', value:'...', 
		onclick:"javascript:showChooser('../parameter/emxParameterDialog.jsp?table=PARInterfaceName&CancelButton=true&headerRepeat=0&pagination=0&program=emxParameterCreation:getInterfacesList&selection=single&SubmitURL=../characteristicmaster/CharacteristicMasterSubmit.jsp&targetLocation=popup','600','600','true','','Dimension')"});
	var td = $('#DimensionId').closest('td');
	td.append(dimButton);
}


function createDisplayUnitTextbox(){
	var displayUnitText = $(document.createElement('input')).attr({ type: 'text',size:'20', name:'DisplayUnitTextId', id:'DisplayUnitTextId'});
	var td=$('#DisplayUnitId').closest('td');
	td.append(displayUnitText);
}

function createCheckboxField(textboxId,CheckBoxId){
	if($("#"+CheckBoxId).length == 0){
		var checkboxMinimalIncluded = $(document.createElement('input')).attr({ type: 'checkbox', name: CheckBoxId, id: CheckBoxId, checked: 'checked'});
		var labelIncluded = $(document.createElement('label')).text('Included');
		$("[name="+textboxId+"]").closest('td').append(checkboxMinimalIncluded).append(labelIncluded);
	}
}

function createMultiValueField(){
	
	$('[name="MultiValue"]').css({'width': 200, 'height': 50 }).attr({id: 'MultiValue', onclick: 'copyValueToInput(this)'});
	
	//add blankoption to the list
	var blankOption = $(document.createElement('option')).attr({ value: '', selected: 'selected' });
	blankOption.prependTo('#MultiValue');
	
	var br = $(document.createElement('br'));
	var br1 = $(document.createElement('br'));
	
	//create texbox, add and remove buttons
	var multiValueInputField = $(document.createElement('input')).attr({ type: 'text' , size:'20', name:'multiValueInputField', id:'multiValueInputField'});
	var hiddenMultiValueField = $(document.createElement('input')).attr({ type: 'hidden',size:'20', name:'hiddenMultiValue', id:'hiddenMultiValue'});
	var addButton = $(document.createElement('input')).attr({ type: 'button', name:'multiValueAdd', value:'+', onclick: 'onAddValueEvent(this)'});
	var removeButton = $(document.createElement('input')).attr({ type: 'button', name:'multiValueRemove', value:'-' , onclick: 'onRemoveValueEvent(this)'});
	
	//append above created fields
	$('[name="MultiValue"]').parent().append(br).append(br1).append(multiValueInputField).append(addButton).append(removeButton).append(hiddenMultiValueField);
}

function copyValueToInput(){
	var context = window.document ;
	var dimension = $('#DimensionId').val();
	if(dimension == undefined)
		dimension = $('#DimensionHidden').val();
	var displayUnit = $("#DisplayUnitId").val();
	var $select = context.getElementById("MultiValue");
	if(dimension == 'COLORParameter' && displayUnit == 'RGB'){
	/*	var temp = $select.value.replace("(","");
		temp = temp.replace(")","");*/
		var res = $select.value.split(",");
		$('#redmultiValueInputField').val(res[0]);
		$('#greenmultiValueInputField').val(res[1]);
		$('#bluemultiValueInputField').val(res[2]);
	}else{
		$("#multiValueInputField").val($select.value);
	}
}

function onAddValueEvent(){

	var context = window.document ;
	var dimension = $('#DimensionId').val();
	if(dimension == undefined)
		dimension = $('#DimensionHidden').val();
	var $select = context.getElementById("MultiValue");
	var displayUnit = $("#DisplayUnitId").val();
	// to get the selected value
	var selectedValue = $select.value;	
	var newVal="";
	var $hiddenSet = context.getElementById("hiddenMultiValue");
	var valuationType = $("#ValuationTypeId").val();		
	
	if(dimension == 'COLORParameter' && displayUnit == 'RGB'){
		newVal =$('#redmultiValueInputField').val()+","+$('#greenmultiValueInputField').val()+","+$('#bluemultiValueInputField').val();
	}else{
		newVal = $('#multiValueInputField').val();
		var isNum = $.isNumeric(newVal);
		if(isNum){
			newVal = parseFloat(newVal).toString();		
		}
		var existingValues= $hiddenSet.value.split("|");
		var existingValuesToCheck=[];
		existingValues.forEach(function(value){
			var isNum= $.isNumeric(value);
			if(isNum){
				value= parseFloat(value).toString();
			}
			existingValuesToCheck.push(value);
		});
		// search the string in existing values
		duplicateValue= existingValuesToCheck.indexOf(newVal)>-1;
	}
	// search the string in existing values
	var existingValues = $hiddenSet.value.split("|");
	if ((valuationType == undefined || valuationType == "2" || valuationType == "1") && !duplicateValue)
	{
		// insert
		if (selectedValue == '' || selectedValue == 'Empty')
		{
			var newOption = context.createElement('option');
			newOption.innerHTML = newVal;
			newOption.value = newVal;

			$select.options.add(newOption);

			$hiddenSet.value = $hiddenSet.value + "|" + newVal;
		}
		// replace
		else
		{
			var selectedIndex = $select.selectedIndex;
			$select.options[selectedIndex].innerHTML = newVal;
			$select.options[selectedIndex].value = newVal;

			$hiddenSet.value = $hiddenSet.value.replace(selectedValue, newVal);
		}
		$select.selectedIndex = 0;
		
		var no_of_options = $select.length;
		for (var i=0; i < no_of_options; i++) {
			$select[i].selected="true";
		}
		
		if(dimension == 'COLORParameter'&& displayUnit == 'RGB'){
			$('#redmultiValueInputField').val("");
			$('#greenmultiValueInputField').val("");
			$('#bluemultiValueInputField').val("");
		}else{
			$("#multiValueInputField").val("");
		}
	}
	//for internationalization(IR IR-476770-3DEXPERIENCER2018x)
	else if(newVal=='' || newVal=='Empty'){
		//XSSOK
		alert(MultiValNullAlert);
	}
	
	else
	{
		//XSSOK
		alert(MultiValDuplicateAlert);
	}
}

function onRemoveValueEvent()
{
	try
	{
		var context = window.document ;
	    var $select = context.getElementById("MultiValue");
	    var displayUnit = $("#DisplayUnitId").val();
		var $hiddenSet = context.getElementById("hiddenMultiValue");
		var inputValue = "";
		var dimension = $('#DimensionId').val();
		if(dimension == undefined)
			dimension = $('#DimensionHidden').val();
		var selectedValue = $('#MultiValue').val();
		if(selectedValue != ""){
			if(dimension == 'COLORParameter' &&  displayUnit == 'RGB'){
				inputValue =$('#redmultiValueInputField').val()+","+$('#greenmultiValueInputField').val()+","+$('#bluemultiValueInputField').val();
				if (inputValue == selectedValue)
				{
					$($select.options[$select.selectedIndex]).remove();
					$hiddenSet.value = $hiddenSet.value.replace("|"+inputValue, "");
					$select.selectedIndex = 0;
					$('#redmultiValueInputField').val("");
					$('#greenmultiValueInputField').val("");
					$('#bluemultiValueInputField').val("");
				}
			}else{
				inputValue = $('#multiValueInputField').val();
				if (inputValue == selectedValue)
				{
					$($select.options[$select.selectedIndex]).remove();
					$hiddenSet.value = $hiddenSet.value.replace("|"+$("#multiValueInputField").val(), "");
					$select.selectedIndex = 0;
					$("#multiValueInputField").val("");
				}
			}
			
		}
		var no_of_options = $select.length;
		for (var i=0; i < no_of_options; i++) {
			$select[i].selected="true";
		}
    }
	catch (ex) {}
}


function setDefaultValues(){
	//Set Valuation Type to Simple
	//jQuery is not setting the default value on MAC OS so changing it to javascript
	//$("#ValuationTypeId option[value='1']").attr("selected", "selected"); 
	document.getElementById("ValuationTypeId").value = '1';
	
}

function onDimensionChange(){
	var dimension = $("#DimensionId").val();
	$('#DisplayUnitId').show();
	$('#DisplayUnitTextId').hide();
	if(dimension == undefined)
		dimension = $('#DimensionHidden').val();
	var displayUnit = $("#DisplayUnitId").val();
	changeDisplayUnit();
	displayAllFields();
	enableMinMaxIncludedCheckBoxes();
	var nominalValuelabelTD = $("label[for=NominalValue]").closest('td');
	nominalValuelabelTD.attr("class","createLabel");
	var multiValuelabelTD = $("label[for=MultiValue]").closest('td');
	multiValuelabelTD.attr("class","createLabel");
	
	// To get simple value as default valuation type 
	setDefaultValues();
	
	if(dimension == 'BooleanParameter'){
		$('#DisplayUnitId').prop('disabled', 'disabled');
		$('#ValuationTypeId').prop('disabled', 'disabled');
		textToCombo('NominalValue', "true");
		hideMinimalMaximalValue();
		hideMultiValue();
	}else if(dimension == 'IntegerParameter'||dimension == 'RealParameter'){
		//$('#DisplayUnitId').prop('disabled', 'disabled');
		//changeComboToTextForDisplayUnit();
		$('#DisplayUnitId').hide();
		$('#DisplayUnitTextId').show();
	}else if (dimension == 'StringParameter' || dimension == 'SubjectivityParameter' ){
		$('#DisplayUnitId').prop('disabled', 'disabled');
		hideMinimalMaximalValue();
		if(dimension == 'SubjectivityParameter'){
			$('#ValuationTypeId').prop('disabled', 'disabled');
			nominalValuelabelTD.attr("class","createLabelRequired");
			multiValuelabelTD.attr("class","createLabelRequired");
		}
	}else if(dimension == 'CMYKFormattedStringParameter' || dimension == 'HEXFormattedStringParameter'|| dimension == 'RGBFormattedStringParameter'){		
		//$('#DisplayUnitId').hide();
		//$('#DisplayUnitTextId').show();
		//createThreeTextBoxes('NominalValue');
		//createThreeTextBoxes('MinimalValue');
		//createThreeTextBoxes('MaximalValue');
		//createThreeTextBoxes('multiValueInputField');		
		$('#DisplayUnitId').prop('disabled', 'disabled');
		$('#ValuationTypeId').prop('disabled', 'disabled');
		if(dimension == 'CMYKFormattedStringParameter'){
			$('#NominalValue').attr("placeholder", "Ex- [0,0,0,0]");
		}else if(dimension == 'HEXFormattedStringParameter'){
			$('#NominalValue').attr("placeholder", "Ex- #FFFF00");
		}else{
			$('#NominalValue').attr("placeholder", "Ex- [125,250,110]");
		}
		disableMinMaxIncludedCheckBoxes();
	}
}

function onDisplayUnitChange(){
	var dimension = $("#DimensionId").val();
	if(dimension == undefined)
		dimension = $('#DimensionHidden').val();
	var displayUnit = $("#DisplayUnitId").val();
	if(dimension == 'COLORParameter'){
		if(displayUnit == 'Pantone' || displayUnit == 'HEXA'){
			convertToSingleTextBox('NominalValue');
			convertToSingleTextBox('MinimalValue');
			convertToSingleTextBox('MaximalValue');
			convertToSingleTextBox('multiValueInputField');
		}
		if(displayUnit == 'RGB'){
			createThreeTextBoxes('NominalValue');
			createThreeTextBoxes('MinimalValue');
			createThreeTextBoxes('MaximalValue');
			createThreeTextBoxes('multiValueInputField');
		}
	}
}

function createThreeTextBoxes(fieldID) {
	var textRed = $(document.createElement('input')).attr({ type: 'text' , size:'5', name: "red"+fieldID , id: "red"+fieldID});
	var textGreen = $(document.createElement('input')).attr({ type: 'text' , size:'5', name:"green"+fieldID, id: "green"+fieldID});
	var textBlue = $(document.createElement('input')).attr({ type: 'text' , size:'5', name:"blue"+fieldID, id: "blue"+fieldID});
	
	$("#"+fieldID).replaceWith(textRed,textGreen,textBlue);
	
}
function enableMinMaxIncludedCheckBoxes(){
	$("#minimalIncludedId").prop( "checked", true );
	$("#minimalIncludedId").prop('disabled', false);
	$("#maximalIncludedId").prop( "checked", true );
	$("#maximalIncludedId").prop('disabled', false);
}
function disableMinMaxIncludedCheckBoxes(){
	$("#minimalIncludedId").prop( "checked", true );
	$("#minimalIncludedId").prop('disabled', 'disabled');
	$("#maximalIncludedId").prop( "checked", true );
	$("#maximalIncludedId").prop('disabled', 'disabled');
}

function textToCombo(fieldID , selectedValue){
	var val = $("#"+fieldID).val();
	//if(val != "" && val=="true")
	//TODO:Need to localize the options	
	var combo = $("<select></select>").attr("id", fieldID).attr("name", fieldID);	
	var option1 = "<option value='true'>TRUE</option>";
	var option2 = "<option value='false'>FALSE</option>";
	if(selectedValue == "true")
		option1 = "<option value='true' selected=selected>TRUE</option>";
	else
		option2 = "<option value='false' selected=selected>FALSE</option>";
	combo.append(option1).append(option2);
	$("#"+fieldID).replaceWith(combo);
}

function changeDisplayUnit(){
	emxFormReloadField("DisplayUnit");
}

function hideNominalValue(){
	$("#calc_NominalValue").next('tr').hide();
	$("#NominalValue").hide();
	$("#calc_NominalValue").next('tr').next('tr').hide();
}

function hideMinimalMaximalValue(){
	$("#calc_MinimalValue").next('tr').hide();
	$("#calc_MinimalValue").next('tr').next('tr').hide();	
	$("#calc_MaximalValue").next('tr').hide();
	$("#calc_MaximalValue").next('tr').next('tr').hide();
}

function hideMultiValue(){
	$("#calc_MultiValue").next('tr').hide();
	$("#calc_MultiValue").next('tr').next('tr').hide();	
}

function hideMultiValueForCopy(){
	$("#calc_MultiValue").hide();
	$("#calc_MultiValue").next('tr').hide();
	$("#calc_MultiValue").next('tr').next('tr').hide();	
}


function hideNominalValueforEdit(){
	$("#calc_NominalValue").hide();
}

function hideNominalValueforCopy(){
	$("#calc_NominalValue").hide();
	$("#calc_NominalValue").next('tr').hide();
	$("#calc_NominalValue").next('tr').next('tr').hide();
}

function hideMinimalMaximalValueforEdit(){
	$("#calc_MinimalValue").hide();
	$("#calc_MinimalValue").next('tr').hide();	
	$("#calc_MaximalValue").hide();
	$("#calc_MaximalValue").next('tr').hide();
}

function hideMinimalMaximalValueforCopy(){
	$("#calc_MinimalValue").hide();
	$("#calc_MinimalValue").next('tr').hide();
	$("#calc_MinimalValue").next('tr').next('tr').hide();
	$("#calc_MaximalValue").hide();
	$("#calc_MaximalValue").next('tr').hide();
	$("#calc_MaximalValue").next('tr').next('tr').hide();
}

function hideMultiValueforEdit(){
	$("#calc_MultiValue").hide();
	//$("#calc_MultiValue").next('tr').next('tr').hide();	
}


function showNominalValue(){
	//show Nominal value
	$("#calc_NominalValue").next('tr').show();
	$("#NominalValue").show();		
	$("#calc_NominalValue").next('tr').next('tr').show();
}

function showMinimalMaximalValue(){
	// Show Minimal and Maximal Value
	$("#calc_MinimalValue").next('tr').show();
	$("#calc_MinimalValue").next('tr').next('tr').show();
	$("#calc_MaximalValue").next('tr').show();
	$("#calc_MaximalValue").next('tr').next('tr').show();	
}

function showMultiValue(){
	//show Multi value
	$("#calc_MultiValue").next('tr').show();
	$("#calc_MultiValue").next('tr').next('tr').show();	
}

function enableDUandVT(){
	//enable display unit and Valuation Type
	$('#DisplayUnitId').prop('disabled', false);
	$('#ValuationTypeId').prop('disabled', false);	
}

function changeComboToText(fieldID){
	//Change Nominal Combo To Nominal Text
	var textField = $(document.createElement('input')).attr({ type: 'text' , size:'20', name:fieldID, id: fieldID});
	$("#"+fieldID).replaceWith(textField);
}

function convertToSingleTextBox(fieldID){
	var textField = $(document.createElement('input')).attr({ type: 'text' , size:'20', name:fieldID, id: fieldID});
	
	if(fieldID == 'multiValueInputField'){
		$("#red"+fieldID).replaceWith(textField);
		$("#green"+fieldID).hide();
		$("#blue"+fieldID).hide();
		
	}else{		
		var td = $(document.createElement('td'));
		var tr = $(document.createElement('tr'));	
	
		var $row = $("#red"+fieldID).closest('tr');
		//$row.replaceWith(tr.append(td.append(textField)));
		$("#red"+fieldID).replaceWith(textField);
		$("#green"+fieldID).hide();
		$("#blue"+fieldID).hide();
	
		/*if(fieldID == 'MinimalValue' ||fieldID == 'MaximalValue'){
			createCheckboxField(fieldID, (fieldID == 'MinimalValue')?'minimalIncludedId':'maximalIncludedId');
		}	*/	
	}
}

function clearAll(){
	$('#NominalValue').val("");
	$('#MinimalValue').val("");
	$('#MaximalValue').val("");
	$('#hiddenMultiValue').val("");
	$('#MultiValue').find('option:not(:first)').remove();
}

function displayAllFields(){
	//show DisplayUnitDropDown
//	$('#DisplayUnitId').show();
//	$('#DisplayUnitTextId').hide();
	showNominalValue();
	showMinimalMaximalValue();
	showMultiValue();
	enableDUandVT();
	changeComboToText('NominalValue');
	convertToSingleTextBox('NominalValue');
	convertToSingleTextBox('MinimalValue');
	convertToSingleTextBox('MaximalValue');
	convertToSingleTextBox('multiValueInputField');
	clearAll();
}


function onValuationTypeChange(){
	var valuationType = $("#ValuationTypeId").val();
	var displayUnit = $("#DisplayUnitId").val();
	displayAllFields();
	var dimension = $("#DimensionId").val();
	if(dimension == 'COLORParameter' && displayUnit == 'RGB'){		
		//$('#DisplayUnitId').hide();
		//$('#DisplayUnitTextId').show();
		createThreeTextBoxes('NominalValue');
		createThreeTextBoxes('MinimalValue');
		createThreeTextBoxes('MaximalValue');
		createThreeTextBoxes('multiValueInputField');
	}
	if (dimension == 'StringParameter' || dimension == 'SubjectivityParameter' ){
		hideMinimalMaximalValue();
		$('#DisplayUnitId').prop('disabled', 'disabled');
	}
	switch(valuationType){
		case '0':			
			hideNominalValue();
			hideMultiValue();
			break;
	
		case '2':
			hideNominalValue();
			break;

	}
}

function loadDefaultValuesTestMethodPreProcess(){

	var testMethod = this.FormHandler.Fields._container.TestMethod.ActualValue;
	if(testMethod) {
		var testMethodValue = testMethod.split("||");
		this.emxFormSetValue("TestMethod", testMethodValue[0], testMethodValue[0]); 
		var testMethodOID = document.getElementsByName("TestMethodOID")[0];
		if(testMethodOID){
			testMethodOID.setAttribute("value",testMethodValue[1]);
		}
	}
}
function isNumericFormat(){
	//XSSOK
	var dimension = $("#DimensionId").val();
	if(dimension == undefined)
		dimension = $('#DimensionHidden').val();
	if((dimension!='StringParameter') &&
			(dimension!='BooleanParameter') && 
			(dimension!='SubjectivityParameter' && dimension != 'CMYKFormattedStringParameter'
			&& dimension != 'HEXFormattedStringParameter' && dimension != 'RGBFormattedStringParameter')){
		//Check if Nominal Value is non numeric Value
		isCharNominalMinMaxNumeric("NominalValue");
		isCharNominalMinMaxNumeric("MinimalValue");
		isCharNominalMinMaxNumeric("MaximalValue");

		//Check if Mutilple Value has non numeric Value
		var multipleValues = $("#hiddenMultiValue").val();
		if(multipleValues !=null && multipleValues != ""){
			var nominalValue= $('#NominalValue').val();
			if(nominalValue === null || nominalValue === ""){
				alert(nominalNotSet);
				return false;
			}
			var arr = multipleValues.split("|");
			for(var i=0; i < arr.length;i++){
				if(arr[i] != ""){
					if(!$.isNumeric(arr[i])){
						var mulitpleLabel = $("label[for=MultiValue]").text();		
						alert(mulitpleLabel+" "+notNumeric+"  : "+arr[i]);
						return false;
					}
				}	
			}
		}
	}
	return true;
}

function isCharNominalMinMaxNumeric(fieldName){		
		var val = $("#"+fieldName).val();
		if(val != ""){
			var result = $.isNumeric(val);		
			if(!result){
				var label = $("label[for="+fieldName+"]").text();		
				alert(label+" "+notNumeric);
				return false;
			}
			var isInRange = isValinRange(val);
			if(!isInRange)
				return false;
		}
}
function isValinRange(nominalVal){
	var minValue = $("#MinimalValue").val();
	if(minValue != "" && minValue != null){
		if(parseInt(nominalVal) < parseInt(minValue)){
			alert(nominalLesserThan);
			return false;
		}
	}
	var maxValue = $("#MaximalValue").val();
	if(maxValue != "" && maxValue != null){
		if(parseInt(nominalVal) > parseInt(maxValue)){
			alert(nominalGreaterThan);
			return false;
		}
	}
	return true;
}

function isMinLessThanMax(){
	var dimension = $("#DimensionId").val();
	var valuationType = $("#ValuationTypeId option:selected").val();
	if(dimension == undefined)
		dimension = $('#DimensionHidden').val();
	if((dimension!='StringParameter') &&
			(dimension!='BooleanParameter') && 
			(dimension!='SubjectivityParameter' && dimension != 'CMYKFormattedStringParameter'
			&& dimension != 'HEXFormattedStringParameter' && dimension != 'RGBFormattedStringParameter')){
		var minValue = $("#MinimalValue").val();
		var maxValue = $("#MaximalValue").val();
		if(minValue != "" && maxValue != "" ){
			if(parseInt(minValue) > parseInt(maxValue)){
				alert(minGreaterThanMax);
				return false;
			}
			if(parseInt(minValue) == parseInt(maxValue)){
				alert(minEqualToMax);
				return false;
			}
		}
	}
	return true;
}

function validateAuthorisedValue(){
	var dimension = $("#DimensionId").val();
	var valuationType = $("#ValuationTypeId option:selected").val();
	if(dimension == undefined)
		dimension = $('#DimensionHidden').val();
	//if(dimension != 'StringParameter' &&  dimension != 'BooleanParameter' &&  dimension != 'SUBJECTIVEParameter' &&  dimension != 'COLORParameter'){
	if(dimension != 'StringParameter' &&  dimension != 'BooleanParameter' 
		&&  dimension != 'CMYKFormattedStringParameter' &&  dimension != 'HEXFormattedStringParameter'
		&&  dimension != 'RGBFormattedStringParameter' &&  dimension != 'SubjectivityParameter'){
		var nominalVal = $("#NominalValue").val();
		var multipleValues = $("#hiddenMultiValue").val();	
		if(multipleValues != null && multipleValues!= ""){
			var arr = multipleValues.split("|");
			if(arr.length != 1){
				//SRR7-IR-600319: Nominal value cannot be empty if the parameter has multiple values.
				if((nominalVal == null &&  nominalVal == "")&& valuationType==1){
					alert(nominalNotSet);
					return false;
				} else {			
					var minValue = $("#MinimalValue").val();
					var maxValue = $("#MaximalValue").val();
					if(minValue != "" || maxValue != "" ){
						for(var i=0; i < arr.length;i++){
							if(parseInt(arr[i]) < parseInt(minValue) || parseInt(arr[i]) > parseInt(maxValue)){
								alert(authOutOfLimit);
								return false;
							}
						}
					}
					if(arr.indexOf(nominalVal) == -1){
						alert(nominalNotPresentInAuth);
						return false;
					}			
				}		
			}
		}
	}
	return true;
}









// -------------------------------------------------------------------
//function to display or hide HTML div and change images accordingly
// -------------------------------------------------------------------
function switchMenu(divName, currentElement, imgType) 
{
	var el = document.getElementById(divName);
	//alert(divName);
	if(el != null)
	{
		if ( el.style.display != 'none' ) {
			//hide
			el.style.display = 'none';
			//change image based on imgType
			if(imgType == null || imgType == "undefined" || imgType == "plusMinus")
				currentElement.src = '../common/images/buttonPlus.gif';
			else if(imgType == "expandCollapse")
				currentElement.src = '../common/images/buttonChannelExpand.gif';
		}
		else {
			//show
			el.style.display = '';
			//change image based on imgType
			if(imgType == null || imgType == "undefined" || imgType == "plusMinus")
				currentElement.src = '../common/images/buttonMinus.gif';
			else if(imgType == "expandCollapse")
				currentElement.src = '../common/images/buttonChannelCollapse.gif';
		}
	}
}
// -------------------------------------------------------------------
//function to dynamically update combo box with new data
// -------------------------------------------------------------------
function fillCombobox(dataArray, prefixForCheckbox){
	//alert("hi");
	var comboboxId = prefixForCheckbox + "ComboBox";
	var textboxId =  prefixForCheckbox + "TextboxId";
	var oldTableId = prefixForCheckbox + "TableId";

	var comboBox = document.getElementById(comboboxId);
	var textBox = document.getElementById(textboxId);
	var oldTable = document.getElementById(oldTableId);

	//remove old table
	if(oldTable)
		comboBox.removeChild(oldTable);
	//reset text box
	textBox.value = "All";

	//create new table
	var table = document.createElement("TABLE");
	table.bgColor = "white";
	table.width = "100%";
	table.id = oldTableId;
	//alert("<input type='checkbox' name='"+ prefixForCheckbox +"All' value='All' checked onclick='updateTextBox(this, \""+textboxId+"\")' >All");
	var tableRow, tableRowData;
	//build "All" checkbox
	tableRow = table.insertRow(0);
	tableRowData = tableRow.insertCell(0);
	tableRowData.innerHTML = "<input type='checkbox' name='"+ prefixForCheckbox +"All' value='All' checked onclick='updateTextBox(this, \""+textboxId+"\")' >All";
	//build other checkboxes
	for(var i = 0, rowIdx = 1; i < dataArray.length; i++)
	{
		if(dataArray[i] != "")
		{
			tableRow = table.insertRow(rowIdx);
			tableRowData = tableRow.insertCell(0);
			tableRowData.innerHTML = "<input type='checkbox' name='"+ prefixForCheckbox +"Checkbox'  value='"+dataArray[i]+"' onclick='updateTextBox(this, \""+textboxId+"\")' >"+dataArray[i]+"";
			rowIdx++;
		}
	}
	//add new table to combo box
	comboBox.appendChild(table);
}
// -------------------------------------------------------------------
//function to text box on select or deselect checkboxes
// -------------------------------------------------------------------
function updateTextBox(currentElement, textboxId)
{
	var textBox = document.getElementById(textboxId);
	
	//if last char is not comma then add
	if(textBox.value.charAt(textBox.value.length-1) != ',')
		textBox.value += ",";
	//if it is checked, add value in textbox
	if(currentElement.checked == true)
	{
		textBox.value += currentElement.value + ",";
	}
	//if it is not checked then remove value from textbox
	else
	{
		textBox.value = textBox.value.replace(currentElement.value + ",", "");
	}
    textBox.value = removeExtraCommas(textBox.value);
}
// -------------------------------------------------------------------
//function to show or hide combobox, change image and update textbox accordingly
// -------------------------------------------------------------------
function showHideList(currentElement, listDivId)
{
	var el = document.getElementById(listDivId);
	//alert(listDivId);
	if(el != null)
	{
		if ( el.style.display != 'none' ) {
			el.style.display = 'none';
			currentElement.style.backgroundImage = "url('../common/images/utilCalendarArrowDown.gif')";
		}
		else {
			el.style.display = '';
			currentElement.style.backgroundImage = "url('../common/images/emxPLMOnlineAdmin_utilCalendarArrowUp.gif')";
		}
	}
	//remove extra commas
	currentElement.value = removeExtraCommas(currentElement.value);
}
// -------------------------------------------------------------------
//function to find coordinates of an element
// -------------------------------------------------------------------
function findPos(obj) {
	var curleft = curtop = 0;
	if (obj.offsetParent) 
	{
		do{
		  curleft += obj.offsetLeft;
		  curtop += obj.offsetTop;
		}while (obj = obj.offsetParent);
	}
	//alert(curleft+" "+curtop);
	 return [curleft,curtop];
}
// -------------------------------------------------------------------
//function to remove extra commas from textbox value
// -------------------------------------------------------------------
function removeExtraCommas(value) {
	//if last char of textbox value is comma then remove
	if(value.charAt(value.length-1) == ',')
		value = value.substring(0, value.length-1);
	//if first char of textbox value is comma then remove
	if(value.charAt(0) == ',')
		value = value.replace(",", "");
	//return value
	return value;
}
// -------------------------------------------------------------------
//function to set position of combobox
// -------------------------------------------------------------------
function setComboboxPosition(comboboxId, textboxId){
	var comboBox = document.getElementById(comboboxId);
	var textBox = document.getElementById(textboxId);
	//set position
	comboBox.style.left =	findPos(textBox)[0] + 'px';
	comboBox.style.top =	findPos(textBox)[1] + 21 + 'px';
	//set width
	comboBox.style.width = textBox.style.width;
}
// -------------------------------------------------------------------
//function to get values of all checkboxes (if 'All' is selected)
// -------------------------------------------------------------------
function getAllCheckboxValues(formName, checkboxName, textboxId){
	var textbox = document.getElementById(textboxId);
	var allValues = textbox.value;

	//if textbox contains "All"
	if(allValues.indexOf("All") >= 0)
	{
		allValues = "";
		
		var checkbox = eval("document."+formName+"."+checkboxName);
		
		//if checkbox exist
		if(checkbox)
		{
			//if there are more than one checkboxes
			if(checkbox.length)
			{
				for(var i=0; i < checkbox.length; i++)
				{
					allValues += checkbox[i].value + ",";
				}
				allValues = allValues.substring(0, allValues.length-1);
			}
			//if there is only one checkbox
			else
			{
				allValues = checkbox.value;
			}
		}
	}
	//return values	
	return allValues;
}
// -------------------------------------------------------------------
//function to get values of all checkboxes
// -------------------------------------------------------------------
function getReallyAllCheckboxValues(formName, checkboxName, textboxId){
	var textbox = document.getElementById(textboxId);
	var allValues = "";

		var checkbox = eval("document."+formName+"."+checkboxName);
		
		//if checkbox exist
		if(checkbox)
		{
			//if there are more than one checkboxes
			if(checkbox.length)
			{
				for(var i=0; i < checkbox.length; i++)
				{
					allValues += checkbox[i].value + ",";
				}
				allValues = allValues.substring(0, allValues.length-1);
			}
			//if there is only one checkbox
			else
			{
				allValues = checkbox.value;
			}
		}

	return allValues;
}


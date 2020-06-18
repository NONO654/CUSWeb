'use strict';

function doPostRequest(url, data, callback, cType) {
	var xhr = false;

	if(window.XMLHttpRequest) {
		xhr = new XMLHttpRequest();
	}
	else if(window.ActiveXObject) { // IE
		try {
			xhr = new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch (e) {
			try {
				xhr = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch (e) { }
		}
	}

	if(!xhr) {
		alert('Cannot create XMLHTTP instance');
		return false;
	}

	xhr.onreadystatechange = function() {
		if (xhr.readyState == 4) {
			if (xhr.status == 200) {
				callback(xhr.responseText, undefined);
			}
			else {
				callback(undefined, xhr.responseText);
			}
		}
	};

	xhr.open('POST', url, true);
	if (cType)
		xhr.setRequestHeader("Content-type", cType);
	else
		xhr.setRequestHeader("Content-type", "application/json");
	xhr.send(data);
}

/*
 * Report creation form functions
 */

function rgnFullSearch(table, type, policy, cancelNLS, field, invalidChars, cardinality) {
	var searchPattern = document.editForm[field + 'Display'].value;
	var validationPattern = /[[:@$"<>%,\[\]]/;
	if (searchPattern && searchPattern.match(validationPattern))
		alert((invalidChars ? invalidChars : 'Invalid Characters'));
	else {
		var search = '../common/emxFullSearch.jsp?table='
			+ table
			+ '&selection='
			+ (cardinality === '2' ? 'multiple' : 'single')
			+ '&field=TYPES='
			+ type
			+ ((policy === '*') ?	'' : ':POLICY=' + policy)
			+ (searchPattern ? ':NAME=' + encodeHREF(searchPattern).replace('|', ',') : '')
			+ '&showInitialResults=true&cancelLabel=emxRGN.Label.Cancel&suiteKey=RGN&StringResourceFileId=emxFrameworkStringResource&uiType=form&targetLocation=popup&fieldNameActual='
			+ field
			+ '&fieldNameDisplay='
			+ field
			+ 'Display&fieldNameOID='
			+ field
			+ 'OID';
		showFullSearchChooserInForm(search, field);
	}
}

function rgnUpdateField(field) {
	var display = document.editForm[field + 'Display'];
	var OID = document.editForm[field + 'OID'];
	var button = document.editForm[field + 'Btn'];
	if (OID.value) {
		display.setAttribute('disabled', 'true');
		button.setAttribute('disabled', 'true');
	}
}

function rgnUpdateCreateForm() {
	var fields = ['reportmodel', 'reporttemplate', 'targetDocument'];
	var field, i;
	for (i = 0; i < fields.length; i++) {
		rgnUpdateField(fields[i]);
	}
}
function rgnUpdateCreateParamForm(nbInputs) {
	var i;
	for (i = 0; i < nbInputs; i++) {
		rgnUpdateField('input' + i);
	}
}
function clearField(field) {
	var display = document.editForm[field + 'Display'];
	var OID = document.editForm[field + 'OID'];
	var btn = document.editForm[field + 'Btn'];
	display.value = "";
	display.removeAttribute('disabled');
	OID.value = "";
	OID.removeAttribute('disabled');
	document.editForm[field].value = "";
	if (btn)
		btn.removeAttribute('disabled');
}


/*
 * Dual List functions
 */

function saveDualListResult(resultInput, selectedList) {
	var result = '';
	for (var i = 0; i < selectedList.length; i++) {
		if (i > 0)
			result = result + ',';
		result = result + selectedList.options[i].getAttribute('value');
	}
	resultInput.setAttribute('value', result);
}
function makeVisible(resultInput, availableList, selectedList) {
	var elements = selectedList.options;
	for(var i = 0; i < elements.length; i++){
		elements[i].selected = false;
    }
	for (var i = (availableList.length - 1); i >= 0; i--) {
		var option = availableList.options[i];
		if (option.selected) {
			selectedList.insertBefore(option, selectedList.options[0]);
			var newInput = document.createElement('input');
			newInput.setAttribute('type', 'hidden');
			newInput.setAttribute('name', option.getAttribute('value'));
		}
	}
	saveDualListResult(resultInput, selectedList);
}
function makeInvisible(resultInput, availableList, selectedList) {
	var elements = availableList.options;
	for(var i = 0; i < elements.length; i++){
		elements[i].selected = false;
    }
	for (var i = (selectedList.length - 1); i >= 0; i--) {
		var option = selectedList.options[i];
		if (option.selected) {
			availableList.insertBefore(option, availableList.options[0]);
		}
	}
	saveDualListResult(resultInput, selectedList);
}
function switchOption(opt, beVisible) {
	if (beVisible) {
		if (opt.parentNode.tagName === 'SPAN') {
			var span = opt.parentNode;
			var list = span.parentNode;
			list.insertBefore(opt, span);
			list.removeChild(span);
		}
	} else {
		if (opt.parentNode.tagName !== 'SPAN') {
			var span = basicNewElement('span', {style: 'display: none'});
			opt.parentNode.insertBefore(span, opt);
			span.appendChild(opt);
		}
	}
}
function filterList(filter, list) {
	var opt, i, regexp;
	var opts = list.getElementsByTagName('option');
	for (i = 0; i < opts.length; i++) {
		opt = opts[i];
		regexp = new RegExp(filter, 'gi');
		switchOption(opt, opt.innerHTML.match(regexp))
	}
}
function basicNewElement(tagname, props, content, innerHTML) {
	var elem = document.createElement(tagname);
	if (innerHTML)
		elem.innerHTML = innerHTML;
	if (content) {
		if (content instanceof Array) {
			for (var i = 0; i < content.length; i++) {
				elem.appendChild(content[i]);
			}
		} else if (content instanceof Object)
			elem.appendChild(content);
		else
			elem.innerHTML = content;
	}
	for (var propName in props) {
		if (props.hasOwnProperty(propName)) {
			var prop = props[propName];
			if (prop instanceof Function)
				elem[propName] = prop;
			else
				elem.setAttribute(propName, prop);
		}

	}
	return elem;
}
function getReferenceValues(property) {
	var references = property.referenceValues;
	var refNames = Object.keys(references).sort();
	var selected = property.selectedValues;
	var options = [];
	for (var i = 0; i < refNames.length; i++) {
		var refName = refNames[i];
		var refLabel = references[refName];
		if (references.hasOwnProperty(refName) && selected.indexOf(refName) < 0) {
			options[options.length] = basicNewElement(
							'option',
							{
								value: refName,
								title: refLabel + ' [' + refName+ ']'
							},
							refLabel);
		}
	}
	return basicNewElement(
		'td',
		{
			style: 'width: 50%'
		},
		basicNewElement(
			'select',
			{
				id: 'referenceValuesList',
				size: '10',
				multiple: 'true',
				style: 'width: 100%; height: 100%'
			},
			options
		)
	)
}
function getSelectedValues(property) {
	var references = property.referenceValues;
	var selected = property.selectedValues.sort();
	var options = [];
	for (var i = 0; i < selected.length; i++) {
		var selName = selected[i];
		var selLabel = references[selName];
		if (references.hasOwnProperty(selName)) {
			options[options.length] = basicNewElement(
							'option',
							{
								value: selName,
								title: selLabel + ' [' + selName+ ']'
							},
							selLabel);
		}
	}
	return basicNewElement(
		'td',
		{
			style: 'width: 50%'
		},
		basicNewElement(
			'select',
			{
				id: 'selectedValuesList',
				size: '10',
				multiple: 'true',
				style: 'width: 100%; height: 100%'
			},
			options))
}
function getAddToSelectionButton(property) {
	var propName = property.name;
	var button = basicNewElement(
		'button',
		{
			class: 'next',
			type: 'button',
			style: 'width: 80px; margin-left: 10px; margin-bottom: 5px; margin-right: 10px'
		},
		basicNewElement(
			'img',
			{
				class: 'lc-button-arrow',
				src: '../common/images/utilArrowRight.png'
			}
		)
	);
	button.onclick = function() {
		makeVisible(
			document.getElementById(propName),
			document.getElementById('referenceValuesList'),
			document.getElementById('selectedValuesList')
		)};
	return button;
}
function getRemoveFromSelectionButton(property) {
	var propName = property.name;
	var button = basicNewElement(
		'button',
		{
			class: 'next',
			type: 'button',
			style: 'width: 80px; margin-left: 10px; margin-bottom: 5px; margin-right: 10px'
		},
		basicNewElement(
			'img',
			{
				class: 'lc-button-arrow',
				src: '../common/images/utilArrowLeft.png'
			}
		)
	);
	button.onclick = function() {
		makeInvisible(
			document.getElementById(propName),
			document.getElementById('referenceValuesList'),
			document.getElementById('selectedValuesList')
		)};
	return button;
}
function getDualListWidget(property) {
	var result = basicNewElement(
		'input',
		{
			type: 'hidden',
			id: property.name,
			name: property.name
		}
	);
	var table = document.createElement('table');
	table.setAttribute('style', 'width: 100%');
	var filterNLS = I18n['placeholder_filter'];
	if (!filterNLS)
		filterNLS = 'Filter';
	table.appendChild(
		basicNewElement(
			'tr',
			{},
			[
				basicNewElement('td', {}, property.referenceValuesLabel),
				basicNewElement('td', {}),
				basicNewElement('td', {}, property.selectedValuesLabel)
			]));
	table.appendChild(
		basicNewElement(
			'tr',
			{},
			[
				getReferenceValues(property),
				basicNewElement(
					'td',
					{width: '50px'},
					[
						getAddToSelectionButton(property),
						getRemoveFromSelectionButton(property)
					]
				),
				getSelectedValues(property)
			]));
	table.appendChild(
		basicNewElement(
			'tr',
			{},
			[
				basicNewElement(
					'td',
					{style: 'width:150px'},
					basicNewElement(
						'input',
						{
							id: 'referenceValuesFilter',
							type: 'text',
							placeholder: filterNLS,
							style: 'width:150px',
							onkeyup: function() {
								filterList(this.value, document.getElementById('referenceValuesList'))
							}
						}
					)),
				basicNewElement('td', {}),
				basicNewElement(
					'td',
					{style: 'width:150px'},
					basicNewElement(
						'input',
						{
							id: 'selectedValuesFilter',
							type: 'text',
							placeholder: filterNLS,
							style: 'width:150px',
							onkeyup: function() {
								filterList(this.value, document.getElementById('selectedValuesList'))
							}
						}
					))
			]));
	return [result, table];
}
function getPropertyInfo(property) {
	return [
		basicNewElement(
			'h2',
			{style: 'white-space: normal !important; width: 150px'},
			property.label
		),
		basicNewElement(
			'p',
			{style: 'width: 150px'},
			property.description
		),
		basicNewElement(
			'p',
			{style: 'width: 150px'},
			property.sample
		)];
}
function getCheckBox(property) {
	if ('false' === property.value)
		return {type: 'checkbox', name: property.name}
	else
		return {type: 'checkbox', name: property.name, checked: property.value};
}
function getWidget(property) {
	if(property.type) {
		switch (property.type) {
			case 'DualList':
				return getDualListWidget(property);
			case 'Boolean':
				return basicNewElement(
					'input',
					getCheckBox(property));
			case 'Error':
				return basicNewElement(
					'p',
					{style: 'color: #CE0000'},
					property.value);
			default:
				return basicNewElement(
					'textarea',
					{
						width: '100%',
						rows: '8',
						name: property.name
					},
					property.value);
		}
	}
}
function addPropertyElement(property) {
	var tBody, tr, td, elem;
	tBody = document.getElementById('propertiesTable');
	tBody.appendChild(
		basicNewElement(
			'tr',
			{},
			[
				basicNewElement(
					'td',
					{
						style: 'width: 150px; padding: 10px'
					},
					getPropertyInfo(property)
				),
				basicNewElement(
					'td',
					{
						style: 'padding: 10px'
					},
					getWidget(property))
			]));
	if (property.type === 'DualList')
		saveDualListResult(
			document.getElementById(property.name),
			document.getElementById('selectedValuesList'));
}
function addErrorPropertyElement(property) {
	document.getElementById('propertiesTable').appendChild(
		basicNewElement('tr',
		{},
		basicNewElement(
			'td',
			{},
			basicNewElement(
				'p',
				{style: 'color: #CE0000; padding: 10px; font-style: italic'},
				property.value)))
	);
}
function buildForm(props) {
	var properties = {};
	if (props)
		properties = JSON.parse(props);
	for (var propName in properties) {
		if (properties.hasOwnProperty(propName)) {
			var prop = properties[propName];
			propName === 'Error' ? addErrorPropertyElement(prop) : addPropertyElement(prop);
		}
	}
}


/*
 * CheckboxList with multi selection
 * if reset callback is defined, 
 * a reset button is added and a click on button runs the callback
 */

function addSelect(parentNode, selectData, resetAction) {
	var dropDown = basicNewElement(
		'div',
		{
			class: 'rgn-dropdown'
		},
		[
			getDropDownDisplay(parentNode, resetAction, selectData.placeholder),
			getDropDowncontent(parentNode, selectData)
		]
	);
	parentNode.appendChild(dropDown);
	parentNode.ownerDocument.onclick = function(event) {
		if (!(event.target.parentNode.parentNode.matches('.rgn-dropdown-content') 
			|| event.target.matches('.rgn-dropdown-display-img')
			|| event.target.parentNode.parentNode.matches('.rgn-dropdown-display'))) {
			var ddContent = parentNode.querySelector('.rgn-dropdown-content');
			if (ddContent && ddContent.classList.contains('show'))
				ddContent.classList.toggle('show');
		}
	}
}

function getDropDownDisplay(parentNode, resetAction, placeholder) {
	var div, display, reset;
	display = basicNewElement(
		'div',
		{},
		[
			getDropDownInputText(parentNode, placeholder),
			getDropDownInputButton(parentNode)
		]
	);
	if (resetAction) {
		display.appendChild(
			basicNewElement(
				'img',
				{
					class: 'rgn-dropdown-reset',
					src: './images/iconActionReset.png',
					onclick: resetAction
				}
			)
		)
	}
	div = basicNewElement(
		'div',
		{class: 'rgn-dropdown-display'},
		display
	);
	return div;
}

function getDropDownInputText(parentNode, placeholder) {
	return basicNewElement(
		'input',
		{
			type: 'text',
			readonly: 'true',
			placeholder: placeholder,
			onclick: function() {
 				parentNode.querySelector('.rgn-dropdown-content').classList.toggle('show');
			}
		}
	)
}

function getDropDownInputButton(parentNode) {
	return basicNewElement(
		'img',
		{
			class: 'rgn-dropdown-display-img',
			src: './images/utilSearchMinus.gif',
			onclick: function() {
 				parentNode.querySelector('.rgn-dropdown-content').classList.toggle('show');
			}
		}
	)
}

function getDropDowncontent(parentNode, selectData) {
	return basicNewElement(
		'div',
		{
			class: 'rgn-dropdown-content'
		},
		basicNewElement(
			'ul',
			{},
			getOptions(parentNode, selectData)
		)
	)
}

function getOptions(parentNode, selectData) {
	var i,
		options = selectData.options,
		selectOptions = [];
	if (options) {
		for (i = 0; i < options.length; i++) {
			var option = options[i];
			selectOptions[i] = basicNewElement(
				'li',
				{
					value: option.value,
					label: option.label,
					onclick: function() {
						if (selectData.multiple) {
							var j, selections, selectValue = '', selectDisplay = '';
							this.classList.toggle('selected');
							selections = parentNode.querySelectorAll('.selected');
							for (j = 0; j < selections.length; j++) {
								var selection = selections[j];
								if (selectValue.length > 0) {
									selectValue += '|';
									selectDisplay += '|';
								}
								selectValue += selection.getAttribute('value');
								selectDisplay += selection.getAttribute('label');
							}
						} else {
							selectValue = this.getAttribute('value');
							selectDisplay = this.getAttribute('label');
							parentNode.querySelector('.rgn-dropdown-content').classList.toggle('show');
						}
						parentNode.querySelector('.rgn-dropdown-display input').value = selectDisplay;
						parentNode.querySelector('.rgn-dropdown-display input').title = selectDisplay.replace(/\|/g,"\n");
						
						document.getElementById(selectData.resultFieldId + 'Display').value = selectDisplay;
						document.getElementById(selectData.resultFieldId + 'Display').setAttribute('value', selectDisplay);
						
						document.getElementById(selectData.resultFieldId + 'OID').value = selectValue;
						document.getElementById(selectData.resultFieldId + 'OID').dispatchEvent(new Event("update"));
						document.getElementById(selectData.resultFieldId + 'OID').setAttribute('value', selectValue);
					}
				},
				option.label
			)
		}
	}
	return selectOptions;
}

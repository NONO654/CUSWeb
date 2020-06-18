'use strict';

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
					src: '../images/iconActionReset.png',
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
			src: '../images/utilSearchMinus.gif',
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

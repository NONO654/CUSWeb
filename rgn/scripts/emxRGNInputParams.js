function submitForm() {
    findFrame(getTopWindow(),"slideInFrame").document.getElementById("divPageFoot").getElementsByClassName("btn-default")[0].setAttribute("disabled", "true");
    document.editForm.action.value = "terminate";
    basicSubmitForm();
}

function submitNext() {
    document.editForm.action.value = "next";
    basicSubmitForm();
}

function clearOID(inputFieldId) {
        document.getElementById(inputFieldId + 'OID').value = '';
};

function resetInputField(inputFieldId) {
    var resultDiv = document.getElementById(inputFieldId + 'ResultDiv'),
        selectDiv = document.getElementById(inputFieldId + 'SelectDiv');
    document.getElementById(inputFieldId + 'OID').value = '';
    selectDiv.setAttribute('hidden', 'true');
    resultDiv.removeAttribute('hidden');
};

function queryInputs(searchFieldId, cardinality, addSelectCallback, placeholder) {
    var i = 0,
        jsonData = {},
        jsonResult = [],
        waitMessage = document.getElementById(searchFieldId + 'Message'),
        resultHiddenField = document.getElementById(searchFieldId + 'OID'),
        fullTypeName = document.getElementById(searchFieldId + 'Type').value,
        searchPattern = document.getElementById(searchFieldId + 'Display').value,
        resultDiv = document.getElementById(searchFieldId + 'ResultDiv'),
        selectDiv = document.getElementById(searchFieldId + 'SelectDiv'),
        isMultiple = cardinality === 2;
    if (!waitMessage) {
    	waitMessage = document.createElement('p');
    	waitMessage.setAttribute('id', searchFieldId + 'Message');
    	resultDiv.appendChild(waitMessage);
    }
    waitMessage.innerHTML = 'Processing...';
    jsonData.queryType = 'queryInput';
    jsonData.type = fullTypeName;
    jsonData.searchPattern = searchPattern;
    doPostRequest('query', JSON.stringify(jsonData), function(answer, error) {
        if (error) {
            waitMessage.innerHTML = error;
            resultDiv.appendChild(waitMessage);
        } else {
            var droplistOptions = [];
            jsonResult = JSON.parse(answer);
            for (i = 0; i < jsonResult.length; i++) {
                var selectElement = document.createElement('option'),
                    result = jsonResult[i],
                    resultId = result.physicalid,
                    display = result.display;
                droplistOptions[i] = {
                    value: resultId,
                    label: display
                }
            }
            selectDiv.removeAttribute('hidden');
            resultDiv.setAttribute('hidden', 'true');
            addSelectCallback(
                selectDiv,
                {
                    resultFieldId: searchFieldId,
                    multiple: isMultiple,
                    attributes: {
                        style: 'width: 100%'
                    },
                    options: droplistOptions,
                    placeholder: placeholder
                },
                function () {
                    resultHiddenField.value = '';
                    selectDiv.setAttribute('hidden', 'true');
                    resultDiv.removeAttribute('hidden');
                    selectDiv.innerHTML = '';
                }
            );
            waitMessage.innerHTML = '';
        }
    })
};

function updateTerminalInputFields(inputKey) {
    var inputDisplayField, inputOIDField, inputField, newValue;
    inputDisplayField = document.getElementById(inputKey + "Display");
    inputTypeField = document.getElementById(inputKey + "Type");
    inputOIDField = document.getElementById(inputKey + "OID");
    inputField = document.getElementById(inputKey);
    newValue = inputDisplayField.value;
    inputField.setAttribute("value", newValue);
    if (inputTypeField.value.startsWith("PLM.")) inputOIDField.setAttribute("value", newValue);
    inputDisplayField.setAttribute("value", newValue);
}

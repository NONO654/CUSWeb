/*--------------------------------------------------------------------
[cmp-function-chooser JS Document]

Project:
Version:
Last change:    Fri, 20 Nov 2015 17:55:52 GMT
Description:	TODO: Description
---------------------------------------------------------------------*/
/**

*/
(function (window) {
    'use strict';
    var polymer = window.Polymer,
        //Private Methods
        _onFunctionDropDownItemChanged, _onFunctionTableItemSelect, _getFunctionsForSelectedType, _EVENT = { functiontableitemselect: 'functiontableitemselect' };

    _onFunctionDropDownItemChanged = function (event) {
        this.listFunctions = _getFunctionsForSelectedType(this._functions, event.target.value);
        this.$.functionTable.scrollTop = 0;
    };

    _onFunctionTableItemSelect = function (event) {
        var srcEle = Polymer.dom(event.target).textContent.replace(/\s/g, '');
        this.fire(_EVENT.functiontableitemselect, { selectedText: srcEle });
    };

    _getFunctionsForSelectedType = function (functions, type) {
        if (!type)
            { type = 'All Functions'; }
        var functionsOfType = functions[type];
        var functionsArray = [];
        for (var key in functionsOfType) {
            if (functionsOfType.hasOwnProperty(key)) {
                functionsArray.push(functionsOfType[key]);
            }
        }
        return functionsArray;
        //return Object.getOwnPropertyNames(functions[type]).sort();
        //if (functionsArray) {
        //    //console.log(functions);
        //    var length = functions.length;
        //    if (selectionIndex < 0 || selectionIndex > length - 1)
        //        console.log('selection index is out of range');
        //    else if (selectionIndex === 0) {
        //        for (var i = 1; i < length; i++) {
        //            for (var j = 0; j < functions[i].displayNames.length; j++) {
        //                functionsArray.push({ 'name': functions[i].displayNames[j] });
        //            }
        //        }
        //    } else {
        //        for (var j = 0; j < functions[selectionIndex].displayNames.length; j++) {
        //            functionsArray.push({ 'name': functions[selectionIndex].displayNames[j] });
        //        }
        //    }
        //}
        //return functionsArray.sort(function (a, b) {
        //    var retVal = 0;
        //    if(a.name > b.name)
        //        retVal = 1;
        //    else if(a.name < b.name)
        //        retVal = -1;
        //    return retVal;
        //});
    };
    Polymer({
        is: 'cmp-function-chooser',
        properties: {
            data: { notify: true },
            onFunctionDropDownItem: { observer: 'onFunctionDropDownItemChanged' }
        },
        //Life cycle methods
        //Event handlers
        onFunctionDropDownItemChanged: function () {
            return _onFunctionDropDownItemChanged.apply(this, arguments);
        },
        onFunctionTableItemSelect: function () {
            return _onFunctionTableItemSelect.apply(this, arguments);
        },
        //_getFunctionsForSelectedType: function () {
        //    return _getFunctionsForSelectedType.apply(this, arguments);
        //},
        ready: function () {
        },
        //this.listFunctions = this._getFunctionsForSelectedType(0);
        UpdateUI: function (functions) {
            console.log('Inside  cmp-function-chooser UpdateUI');
            this._functions = functions;
            var funcDropDown = this.$.functionTypes;
            var functionTypesArray = Object.getOwnPropertyNames(this._functions).sort();
            for (var i = 0; i < functionTypesArray.length; i++) {
                var option = document.createElement('option');
                option.text = functionTypesArray[i];
                option.value = functionTypesArray[i];
                funcDropDown.add(option);
            }
            this.listFunctions = _getFunctionsForSelectedType(this._functions);
        }
    });
}(this));

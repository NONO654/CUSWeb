/**=================================================================
 *  JavaScript JSON Utility
 *  emxUIJson.js
 *  Version 1.0
 *  Requires: nothing
 *
 *  This file adds the JSON methods to Javascript objects.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information 
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 * 
 *  static const char RCSID[] = $
 *=================================================================
 
		New methods:
            The optional keylist contains the object keys to iterate through.
            If left out all keys are used.
            
        Array
			toJSONString(optional keylist[string, string, ...])
        Boolean
			toJSONString()
        Date
			toJSONString()
        Number
			toJSONString()
        Object
			toJSONString(optional keylist[string, string, ...])
        String
			toJSONString()
			parseJSON(otional function)
			
            This method turns JSON text into an object or
            array.
            The optional funtion parameter is used to further process the key, value.
            E.G.
            myObj = jsonString.parseJSON(function (key, value) {
                return (key == "foo")? "bar" : value;
            });
*/
if (!Object.prototype.toJSONString) {
    Array.prototype.toJSONString = function (func) {
        var txtArray = [], count, len = this.length, val;
        for (count = 0; count < len; count += 1) {
            val = this[count];
            switch (typeof val) {
            case 'object':
                if (val) {
                    if (typeof val.toJSONString === 'function') {
                        txtArray.push(val.toJSONString(func));
                    }
                } else {
                    txtArray.push('null');
                }
                break;
            case 'string':
            case 'number':
            case 'boolean':
                txtArray.push(val.toJSONString());
            }
        }
        return '[' + txtArray.join(',') + ']';
    };
    Boolean.prototype.toJSONString = function () {
        return String(this);
    };
    Date.prototype.toJSONString = function () {
        function func(num) {
            return num < 10 ? '0' + num : num;
        }
        return '"' + this.getUTCFullYear() + '-' +
                func(this.getUTCMonth() + 1)  + '-' +
                func(this.getUTCDate())       + 'T' +
                func(this.getUTCHours())      + ':' +
                func(this.getUTCMinutes())    + ':' +
                func(this.getUTCSeconds())    + 'Z"';
    };
    Number.prototype.toJSONString = function () {
        return isFinite(this) ? String(this) : 'null';
    };
    Object.prototype.toJSONString = function (keyList) {
        var txtArray = [], key, count, value;          
        if (keyList) {
            for (count = 0; count < keyList.length; count += 1) {
                key = keyList[count];
                if (typeof key === 'string') {
                    value = this[key];
                    switch (typeof value) {
                    case 'object':
                        if (value) {
                            if (typeof value.toJSONString === 'function') {
                                txtArray.push(key.toJSONString() + ':' +
                                       value.toJSONString(keyList));
                            }
                        } else {
                            txtArray.push(key.toJSONString() + ':null');
                        }
                        break;
                    case 'string':
                    case 'number':
                    case 'boolean':
                        txtArray.push(key.toJSONString() + ':' + value.toJSONString());
                    }
                }
            }
        } else {
            for (key in this) {
                if (typeof key === 'string' &&
                        Object.prototype.hasOwnProperty.apply(this, [key])) {
                    value = this[key];
                    switch (typeof value) {
                    case 'object':
                        if (value) {
                            if (typeof value.toJSONString === 'function') {
                                txtArray.push(key.toJSONString() + ':' +
                                       value.toJSONString());
                            }
                        } else {
                            txtArray.push(key.toJSONString() + ':null');
                        }
                        break;
                    case 'string':
                    case 'number':
                    case 'boolean':
                        txtArray.push(key.toJSONString() + ':' + value.toJSONString());
                    }
                }
            }
        }
        return '{' + txtArray.join(',') + '}';
    };
    (function (strProtoObj) {
        var replaceList = {
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        };
        strProtoObj.parseJSON = function (func) {
            var tmp;
            function walk(key, val) {
                var itr;
                if (val && typeof val === 'object') {
                    for (itr in val) {
                        if (Object.prototype.hasOwnProperty.apply(val, [itr])) {
                            val[itr] = walk(itr, val[itr]);
                        }
                    }
                }
                return func(key, val);
            }
            if (/^[,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]*$/.test(this.
                    replace(/\\./g, '@').
                    replace(/"[^"\\\n\r]*"/g, ''))) {
                tmp = eval('(' + this + ')');
                return typeof func === 'function' ? walk('', tmp) : tmp;
            }
            throw new SyntaxError('parseJSON');
        };
        strProtoObj.toJSONString = function () {
            if (/["\\\x00-\x1f]/.test(this)) {
                return '"' + this.replace(/[\x00-\x1f\\"]/g, function (a) {
                    var cCode = replaceList[a];
                    if (cCode) {
                        return cCode;
                    }
                    cCode = txtArray.charCodeAt();
                    return '\\u00' + Math.floor(cCode / 16).toString(16) + (cCode % 16).toString(16);
                }) + '"';
            }
            return '"' + this + '"';
        };
    })(String.prototype);
}

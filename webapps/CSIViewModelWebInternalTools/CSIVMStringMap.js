//===================================================================
// COPYRIGHT DASSAULT SYSTEMES 2018/04/07
//===================================================================

define('DS/CSIViewModelWebInternalTools/CSIVMStringMap', [], function () {
	'use strict';

	/*******************************/
	/** CSIVMStringMap constructor */
	/*******************************/
	function CSIVMStringMap() {
		this._data = new Map();
		this.clear();
	};

	CSIVMStringMap.prototype.clear = function () {
		this._data.clear();
	};

	CSIVMStringMap.prototype.createValue = function (key, value) {
		if (key === undefined) return;
		var key_str = key.toString();
		var values = this._data.get(key_str);
		if (Array.isArray(values)) {
			values.push(value);
		}
		else {
			this._data.set(key_str, [value]);
		}
	};

	CSIVMStringMap.prototype.get = function (key) {
		if (key !== undefined) {
			return this._data.get(key.toString());
		}
	};

	/*
	CSIVMStringMap.prototype.set = function (key, value) {
		if (key !== undefined) {
			this._data.set(key.toString(),[value]);
		}
	};
	*/

	CSIVMStringMap.prototype.remove = function (key, value) {
		if (key !== undefined) {
			var key_str = key.toString();
			var deleteEntry = true;
			if (value !== undefined) {
				var values = this._data.get(key_str);
				if (Array.isArray(values)) {
					var index = values.indexOf(value);
					if (index > -1) {
						values.splice(index, 1);
					}
					if (values.length > 0) {
						deleteEntry = false;
					}
				}
			}
			if (deleteEntry) {
				this._data.delete(key_str);
			}
		}
	};

	CSIVMStringMap.prototype.forEachValue = function (callback, key) {
		var values;
		var cycle = function (values) {
			if (Array.isArray(values)) {
				values.forEach(callback);
			}
		}
		if (key !== undefined) {
			values = this._data.get(key.toString());
			cycle(values);
		}
		else {
			var itOnValues = this._data.values();
			var entry = itOnValues.next();
			while (!entry.done) {
				values = entry.value;
				cycle(values);
				entry = itOnValues.next();
			}
		}
	};

	CSIVMStringMap.prototype.findValue = function (callback) {
		var toreturn, values;
		var itOnValues = this._data.values();
		var entry = itOnValues.next();
		while (!entry.done && toreturn === undefined) {
			values = entry.value;
			if (Array.isArray(values)) {
				toreturn = values.find(function (value){
					return callback(value);
				});
			}
			entry = itOnValues.next();
		}
		return toreturn;
	};

	return CSIVMStringMap;
});

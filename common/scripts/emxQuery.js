//=================================================================
// JavaScript Query
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of Dassault Systemes
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================
// Query -- Utility to build and manipulate query url's
// e.g. "../common/foo.jsp?param1=a%20b&param2=x%20y"
//
// Notes about URI Encoding:
// - Search portion of constructor's qStr, if present must 
//   already be URI encoded, e.g. new Query("foo.jsp?n1=a%20value");
// - All getters and setters operate on NON-encoded values, e.g.
//   q.append("n2", "another value");
// - toString() gives final encoded URL, e.g.
//   "foo.jsp?n1=a%20value&n2=another%20value"
//
// Also note:
// - API supports multiple values per name, e.g. ?n=v1&n=v2
//   but usually that is not desired.  Use set(n,v) rather than append(n,v)
//   to ensure uniqueness
// - Implementation is based on Array, not Object; preserves ordering of params
//-----------------------------------------------------------------
 
// Works in Netscape 4.x and IE 5.0+
//=================================================================


// Initialize a new Query
// Seed it with qStr (optiona) which may contain a base URL
// portion, and a search portion, introduced with "?", e.g.
//   new Query("foo.jsp")
//   new Query("foo.jsp?n1=a%20value&n2=another%20value");
function Query(qStr) {
	if (!qStr) { qStr = ""; }
	this.items = new Array();
	qStr = qStr.toString(); // allows new Query(location /*not a string!*/)
	this.baseUrl = qStr.replace(/[?].*/, "");
	this.nvp = new Object();
	var search = qStr.substr(this.baseUrl.length+1);
	if (search == qStr) { search = ""; }
	var params = search.split("&");
	for (var i = 0; i<params.length; i++) {
		var param = decodeURIComponent(params[i]);
		if (param == '') 
			continue;
		var name = param.replace(/=.*/, "");
		var value = param.substr(name.length + 1);
		this.append(name, value);
	}
}


// Append a name/value pair to end of query
// value may be omitted, which results in &name&
// with no =value. Generally, we don't do this, though.
Query.prototype.append = function _append(name,value) {
	this.items.push({name:name, value:value});
}

// Given name/value map (Object) add all name/value pairs to the query
Query.prototype.setAll = function _setAll(map) {
	for (name in map) {
		if (typeof value != "function") { // filter out e.g. toJSONString()
			this.set(name, map[name]);
		}
	}
}

// Return all name/value pairs as a map (Object)
Query.prototype.getAll = function _getAll() {
	var res = {};
	for (var i=0; i<this.items.length; i++) {
		var item = this.items[i];
		var name = item.name;
		var value = item.value;
		if (typeof value != "function") { //e.g. toJSONString
			res[name]=value;
		}
	}
	return res;
}


// Generate the full URI encoded query URL from the built-up
// components
Query.prototype.toString = function _toString(){
	return this.baseUrl + "?" + this.getSearch();
}

// Get the base url, i.e. everything before the ?
Query.prototype.getBaseUrl = function _getBaseUrl(){
	return this.baseUrl;
}

// Get the search portion of the url, i.e. everything AFTER the ?
// NOTE: this is different from Location.search, which does include the ?
// Userful if integrating with older scripts that predate Query, and 
// that use string manipulation to build up url's (yuck).
// 
// If bEncode is passed in, and is false, then the resultant string
// is NOT URI encoded.  If you need to do this, your code is almost
// certainly wrong.
Query.prototype.getSearch = function _getSearch(bEncode){
	var params = new Array();
	for (var i=0; i<this.items.length; i++) {
		var item = this.items[i];
		var name = item.name;
		var value = item.value;
		if (typeof item.value == "function") { // e.g. to JSONString
			continue;
			}
		
		var param;
		if (value) {
			if (bEncode == false) {
				// Good luck...
				param = push(name + "=" + value);
			} else {
				param = encodeURIComponent(name) + "=" + encodeURIComponent(value);
			}
		} else {
			param = bEncode ? encodeURIComponent(name) : name;
		}
		params.push(param);
	}
	return params.join("&");
}

// sets parameter name to SINGLE value
// - if named param not previously set, appends name=value to the end
// - if previously set to single value, replaces the value in place
// - if previously set to multiple values, replaces first value and
//   removes others
Query.prototype.set = function _set(name,value) {
	this.replace(name,value,true);
}

// Replace all instances of named parameter (regardless of prior value,
// and number of times found), with single name/value given.
// appendIfMissing is boolean option to control what happens if
// if given name was not present in to begin with.  If false,
// result is no-pp; if true, result is to append name/value.
Query.prototype.replace = function _replace(name,value, appendIfMissing) {
	var first = true;
	for (var i=0; i<this.items.length; i++) {
		var item = this.items[i];
		var n = item.name;
		if (n == name) {
			if (first) {
				var ov = item.value;
				item.value=value;
				first = false;
			} else {
				this.items[i] = null;
			}
		}
	}
	if (first && appendIfMissing) {
		this.append(name,value);
	}
	this._vacuum();
}

// remove named parameter from search
Query.prototype.remove = function _remove(name) {
	for (var i=0; i<this.items.length; i++) {
		var item = this.items[i];
		var n = item.name;
		if (n == name) {
			this.items[i] = null;
		}
	}
	this._vacuum();
}

// Get current value for given named parameter; only makes
// sense to call this if no dupes are present
// null if not found;
Query.prototype.getValue = function _getValue(name) {
	for (var i=0; i<this.items.length; i++) {
		var item = this.items[i];
		if (item.name == name) {
			return item.value;
		}
	}
	return null;
}

// get Array of values for given named parameter;
// returns empty Array, NOT null, if no values found.
Query.prototype.getValueMulti = function _getValueMulti(name) {
	var res = [];
	for (var i=0; i<this.items.length; i++) {
		var item = this.items[i];
		if (item.name == name) {
			res.push(item.value);
		}
	}
	return res;
}

// private method; remove nulled items
Query.prototype._vacuum = function __vacuum() {
	// does not work on IE
	// this.items = this.items.filter(function(val){ return val; });
	// so do it the hard way
	
	var vacuumedItems = new Array();
	for (var i = 0; i < this.items.length; i++) {
		if (this.items[i] != null) {
			vacuumedItems.push(this.items[i]);
		}
	}
	this.items = vacuumedItems;
}

Query.prototype.selfTest = function selfTest(){
	var assertEq = function(actual, expected){
		if (actual != expected) {
			alert(emxUIConstants.STR_JS_AssertionFailed + " " + expected + emxUIConstants.STR_JS_Actual + " " + actual);
		}
	}
	var assertQ = function(strExpected){
		assertEq(q.toString(), strExpected);
	}

	var q = new Query();
	assertQ("?");
	
	q.setAll({
		A: "valA",
		B: "valB"
	});
	assertQ("?A=valA&B=valB");
	assertEq(q.getAll().A, "valA");
	
    var q = new Query("test?A=aa&B=BB&recursive");
	assertQ("test?A=aa&B=BB&recursive");
	
    q.append("n1","v1");
	assertQ("test?A=aa&B=BB&recursive&n1=v1");
	
    q.append("readonly");
	assertQ("test?A=aa&B=BB&recursive&n1=v1&readonly");
	
    q.append("n2", "v2");
	assertQ("test?A=aa&B=BB&recursive&n1=v1&readonly&n2=v2");
	
    q.append("something");
	assertQ("test?A=aa&B=BB&recursive&n1=v1&readonly&n2=v2&something");
	
    q.append("n1","v1a");
	assertQ("test?A=aa&B=BB&recursive&n1=v1&readonly&n2=v2&something&n1=v1a");
	
    q.replace("n2","v2b");
	assertQ("test?A=aa&B=BB&recursive&n1=v1&readonly&n2=v2b&something&n1=v1a");
	
	q.replace("n3", "v3"); // not already set, and not bAppend, so noop
	assertQ("test?A=aa&B=BB&recursive&n1=v1&readonly&n2=v2b&something&n1=v1a");
	
	q.set("n3", "v3b");
	assertQ("test?A=aa&B=BB&recursive&n1=v1&readonly&n2=v2b&something&n1=v1a&n3=v3b");
	
    q.remove("something");
	assertQ("test?A=aa&B=BB&recursive&n1=v1&readonly&n2=v2b&n1=v1a&n3=v3b");
	
	q.replace("n1", "v1b");
	assertQ("test?A=aa&B=BB&recursive&n1=v1b&readonly&n2=v2b&n3=v3b");
	assertEq(q.getValue("n1"), "v1b");
	assertEq(q.getValueMulti("n1")[0], "v1b");
	
	assertEq(q.getValue("x"), null);
	assertEq(q.getValueMulti("x").length, 0);
	
	
	// no further encoding of incoming URL
	q = new Query("test2a?space=value%20space");
	assertQ("test2a?space=value%20space");
	
	// encoding of values set via various setters
	q = new Query("test2b");
	q.set('sp', "value space");
	q.set('amp', "value&amp");
	q.set('eq', "value=equals");
	assertQ("test2b?sp=value%20space&amp=value%26amp&eq=value%3Dequals");
	
	q = new Query("test2c");
	q.append('p1', "value&amp");
	assertQ("test2c?p1=value%26amp");
	
	q = new Query("test2d");
	q.set('p1', "one");
	q.replace('p1', "o n e");
	assertQ("test2d?p1=o%20n%20e");
	
	// encoding parameter names, not just values
	q = new Query("test3a");
	q.set(".a.=.1.&.b.=.2.?.c.=.3.&.d.=.4.", ".AY.=.ONE.&.BEE.=.TWO.?.SEE.=.THREE.&.DEE.=.FOUR.");
	assertQ("test3a?.a.%3D.1.%26.b.%3D.2.%3F.c.%3D.3.%26.d.%3D.4.=.AY.%3D.ONE.%26.BEE.%3D.TWO.%3F.SEE.%3D.THREE.%26.DEE.%3D.FOUR.");
}

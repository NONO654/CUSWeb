//=================================================================
// JavaScript emxUIEmbeddedObjects.js
// This file is used to embed objects such as flash or applets
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
// $Id: emxUIEmbeddedObjects.js.rca 1.1.1.1.5.4 Wed Oct 22 15:47:56 2008 przemek Experimental przemek $
//=================================================================
// Class ObjectEmbedder -- represents an object or applet
// type 			= "applet OR object"
// parameters 		= array of objects with .name .value properties
// attributes 		= array of objects with .name .value properties
// embedAttributes 	= array of objects with .name .value properties
var APPLET_TAG = "applet";
var OBJECT_TAG = "object";
function ObjectEmbedder(){
	this.type 				= null;
	this.parameters 		= new Array();
	this.attributes 		= new Array();
	this.embedAttributes	= new Array();
}
// Public Method
ObjectEmbedder.prototype.setType = function _setType(sType){
	this.type = sType;
}
// Public Method
ObjectEmbedder.prototype.addParameter = function _addParameter(sName,sVal){
    this.parameters[this.parameters.length] = {name:sName,value:sVal};
}
// Public Method
ObjectEmbedder.prototype.addAttribute = function _addAttribute(sName,sVal){
    this.attributes[this.attributes.length] = {name:sName,value:sVal};
}
// Public Method
ObjectEmbedder.prototype.addEmbedAttribute = function _addEmbedAttribute(sName,sVal){
    this.embedAttributes[this.embedAttributes.length] = {name:sName,value:sVal};
}
// Private Method
ObjectEmbedder.prototype.drawAttributes = function _drawAttributes(){
	var attLen = this.attributes.length;
	for(var i = 0; i < attLen; i++){
		document.write(this.attributes[i].name + "=\"" + this.attributes[i].value + "\" ");
	}
}
// Private Method
ObjectEmbedder.prototype.drawParameters = function _drawParameters(){
	var paramLen = this.parameters.length;
	for(var j = 0; j < paramLen; j++){
		document.write("<param ");
		document.write("name=\"" + this.parameters[j].name + "\" ");
		document.write("value=\"" + this.parameters[j].value + "\" ");
		document.write("/>");
	}
}
// Private Method
ObjectEmbedder.prototype.drawEmbedAttributes = function _drawEmbedAttributes(){
	var attLen = this.embedAttributes.length;
	for(var i = 0; i < attLen; i++){
		document.write(this.embedAttributes[i].name + "=\"" + this.embedAttributes[i].value + "\" ");
	}
}
// Public Method
// We have to use string concatenation because javascript
// will not allow <embed> to be added to <object> via the DOM
ObjectEmbedder.prototype.draw = function _draw(){
	document.write("<" + this.type + " ");
	//draw attributes
	this.drawAttributes();
	document.write(">");
	//add parameter elements
	this.drawParameters();
	if(this.type == OBJECT_TAG){
		document.write("<embed ");
		//set embed attributes
		this.drawEmbedAttributes();
		document.write("/>");
	}
	document.write("</" + this.type + ">");
}
/*INLINE USAGE EXAMPLE
<script type="text/javascript">
	var objEmb = new ObjectEmbedder();
	objEmb.setType(OBJECT_TAG);//or APPLET_TAG
	objEmb.addParameter("timezone","eastern");
	objEmb.addAttribute("src","file.jsp");
	objEmb.addEmbedAttribute("src","file.jsp?x=y");//only for objects
	objEmb.draw();
</script>
*/

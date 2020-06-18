<%--  emxUpdateMarketingName.inc   -  Update Marketing Name for Product Central suite

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENOProductLine/CNext/webroot/productline/emxUpdateMarketingNameInclude.inc 1.3.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$
--%>

// flag keeps track of whether user has modified Marketing Name field.
var sflag;
// This function will put the same value in Marketing Name textbox as that of Name.
function updateMarketingName()
{
	var txtMarketingName=formName.txtMarketingName.value;
	if (((txtMarketingName=="")&&(!formName.chkAutoName.checked))||(sflag!="true"))
	{
		var txtName=formName.txtName.value;
		formName.txtMarketingName.value=txtName;
	}
}

//This function sets the flag value and calls for updating Marketing Name field.
function setMarketingNameFlag()
{
	sflag="true";
	if (formName.txtMarketingName.value=="")
	{
		sflag="false";
	}
	updateMarketingName();
}

/*
 *=================================================================
 *  Copyright Dassault Systemes, 2007. All rights reserved
 *  
 * This program is proprietary property of Dassault Systemes and its subsidiaries.
 * This documentation shall be treated as confidential information and may only be used by employees or contractors
 * with the Customer in accordance with the applicable Software License Agreement
 *
 *  static const char RCSID[] = $Id: emxComponentsUIFormValidation.js.rca 1.5 Wed Oct 22 16:18:16 2008 przemek Experimental przemek $
 *=================================================================
 */


//Validating for Date Value
function IssueDateValidate(){

	var strESD = document.forms[0].EstimatedStartDate.value;
	var strEFD = document.forms[0].EstimatedFinishDate.value;
    var msg = "";
		
    var fieldESD = new Date(strESD);
    var fieldEFD = new Date(strEFD);
   
	if ((trimWhitespace(strESD) != '') && (trimWhitespace(strEFD) != '') )
	{
		if (fieldESD > fieldEFD)
		{
            //Condition check when Estimated Start Date is after Estimated Finish Date. It should be before the Estimated Finish Date
			msg = "Invalid Date: Estimated Start Date should not be after Estimated Finish Date. Please enter the valid Dates.";
			alert(msg);
			return false;
		}
		
	}
	return true;
}


// For the Clone Part Form 
function checkAllRels()
  {  
      var operand = "";
      var count = eval("document.forms[0].elements.length");
      
      //retrieve the checkAll's checkbox value
      var allChecked = eval("document.forms[0].AllRels.checked");
      for(var i = 1; i < count; i++)
      {
         if (document.forms[0].elements[i].type == "checkbox")
         {
            operand = "document.forms[0].elements[" + i + "].checked";
            var checkboxname = document.forms[0].elements[i].name;
            if(checkboxname.indexOf("AllRels") != -1)
             {
            operand += " = " + allChecked + ";";
            eval (operand);
             }
         }
      }
      return;
  }

/*
  emxProgramProfileUtil.js

  This file contains javascript utilities.

  Copyright (c) 1998-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program

  static const char RCSID[] = $Id: emxProgramUtil.js.rca 1.10 Wed Oct 22 15:49:32 2008 przemek Experimental przemek $
*/

// **** Translated strings need to be defined in emxProgramScripts.jsp ****

// Sniff the browser version and set the global variable "is".
function Is () {
    // convert all characters to lowercase to simplify testing
    var agt=navigator.userAgent.toLowerCase();

    // *** BROWSER VERSION ***
    this.major   = parseInt(navigator.appVersion);
    this.minor   = parseFloat(navigator.appVersion);

    this.ie      = (agt.indexOf("msie") != -1);
    this.nav     = ((agt.indexOf('mozilla')!=-1) && (agt.indexOf('spoofer')==-1)
                        && (agt.indexOf('compatible') == -1));

    this.nav5up  = (this.nav && (this.major >= 5));
    this.nav4up  = (this.nav && (this.major >= 4));
    this.ie4up   = (this.ie && (this.major >= 4));
}

var is;
is = new Is();


/*
 * Debug Utilities
 */

// Show the properties of the given object.
function dbgShowProperties(obj) {
  var result = "";
  for (var i in obj) {
    result += i + " = " + obj[i] + "\t";
  }
  alert(result);
}


/*
 * Form Utilities
 */

// Checks the form for modification.
// For this function to work, each element that is checked for modification
// must have a hidden input element with "orig_" prepended to the name.
// If no such "orig" element exists, then the element is not checked.
function formModified(form) {

  // Every non-hidden form element that has a corresponding "orig" element
  // must be compared to see if anything changed.
  for (var i = 0; i < form.elements.length; i++) {

    // If the field is hidden then skip it.
    if (form.elements[i].type != "hidden") {

      var origStr = "form.orig_" + form.elements[i].name;

      // If the "orig" element exists, then check if it has changed.
      if (eval(origStr) != null) {

        // If the field is a multiple select, then check a different way.
        if (form.elements[i].type == "select-multiple") {

          for (var j = 0; j < form.elements[i].length; j++) {
            if (form.elements[i].options[j].defaultSelected !=
                form.elements[i].options[j].selected) {
              return true;
            }
          }

        } else {

          // Get the original value from the "orig" element.
          var origVal = eval(origStr + ".value");

          // If the values have changed, then return true.
          if (form.elements[i].value != origVal) {
            return true;
          }
        }
      }
    }
  }

  // If we got here, then nothing changed, so return false.
  return false;

}

// Checks the form for required elements.
// The form containing elements to be required is given first.
// The require argument contains the names of elements that cannot be blank
// and their translations in pairs.
// Returns the first blank element or null.
//
// Parameters:
// form     the name of the form
// msg      the error message to display
// ["NAME", "LABEL", ]    NAME = the input type name field
//                        LABEL = the name of the attribute
//
// Example:
//
// formRequire(form, msg, [
//             "EmailAddress", "Label1",
//            "password", "Label2",
//            "passwordConfirm", "Label3" ])

function formRequire(form, msg, require) {

  // Define an array to hold the blank element names.
  var firstBlank = null;
  var isBlank = false;
  var blank = new Array();

  // Loop through the names of the required form elements.
  for (var i = 0; i < require.length; i+=2) {

    // Create a shortcut to the element and name.
    var element = form[require[i]];
    var name = require[i+1];

    // If the current element exists, then check it.
    if ( element != null ) {

      isBlank = false;

      // If the element is blank, not selected, or the first blank element
      // is selected, then add it's translated name to the blank array.
      switch ( element.type ) {
        case "select-one" :
          if ( element.selectedIndex == -1 ||
               element.options[element.selectedIndex].value.length == 0 ) {
            isBlank = true;
          }
          break;
        case "select-multiple" :
          if ( element.selectedIndex == -1 ) {
            isBlank = true;
          }
          break;
        default :
          if ( element.value == "" ) {
            isBlank = true;
          }
          break;
      }

      if (isBlank) {
        blank[blank.length] = name;
        if (firstBlank == null) {
          firstBlank = element;
        }

      }

    }

  }

  // If the array of blank element names is not blank, then display an error
  // and return true.  Otherwise return false.
  if ( blank.length > 0 ) {
    alert(msg + "\n\n        " + blank.join("\n        ") );
    firstBlank.focus();
    return true;
  } else {
    return false;
  }

}

// Copies all the elements from the first form to the second form.
// The form containing elements to be copied is given first.
// The form to copy the elements to is given second.
function formCopy(fromForm, toForm) {

  // Loop through all the elements on the to form.
  for (var i = 0; i < toForm.elements.length; i++) {

    // Get the name of the element on the to form.
    var name = toForm.elements[i].name;

    // Default the value to blank.
    var value = "";

    // If an element with the same name exists on the from form, then copy it.
    if (fromForm[name] != null) {

      // Shortcut to the element with the same name on the from form.
      var element = fromForm[name];

      // Get the value of the element.
      switch (element.type) {
        case "select-one" :
          if (element.selectedIndex != -1) {
            value = element.options[element.selectedIndex].value;
          }
          break;
        case "select-multiple" :
          if (element.selectedIndex == -1 ) {
//kds - How to handle this?  Combine into a delimited list?
            value = element.options[element.selectedIndex].value;
          }
          break;
        default :
          value = element.value;
          break;
      }

      toForm[name].value = value;
    }

  }

  // Return nothing.
  return;

}

// Function: formSubmit
// Submit the form to the specified page.
// Parameters:
// form = this.form or form name
// action = url to set
// target = target frame to open
// encoding =
// Example:
// formSubmit(this.form,"emxprogramBasicsView.jsp?busId=",data,null)

function formSubmit(form, action, target, encoding) {

  var action = arguments[1];
  var target = arguments[2];
  var encoding = arguments[3];

  if (action != null) {
    form.action = action;
  }

  if (target != null) {
    form.target = target;
  }

  if (encoding != null) {
    form.encoding = encoding;
  }

  form.submit();
}

// Trim the specified element types in the form.
// The form containing elements to be trimmed is given first.
// The trim argument contains the types of elements to trim.
function formTrim(form, trim) {

  // Loop through form elements.
  for (var i = 0; i < form.elements.length; i++) {

    // Loop through the types of elements to trim.
    for (var j = 0; j < trim.length; j++) {

      // If the current element type is one of the types to trim, then trim it.
      if (form.elements[i].type == trim[j]) {
        form.elements[i].value = strTrim(form.elements[i].value);
      }

    }

  }

}


/*
 * String Utilities
 */

// Determine if a string represents a valid email address.
function strIsValidEmail(email) {
  if (email.search("^[^ ]*[@][^ ]*[.][^ ]*$") == -1) {
    return false;
  } else {
    return true;
  }
}

// Translate words in a string to other words.
// The string to be translated is given first.
// The remaining arguments are word/translation pairs.
function strTrans(str) {

  for (var i = 1; i < arguments.length; i += 2) {
    str = str.replace(eval("/" + arguments[i] + "/g"), arguments[i+1]);
  }

  return str;

}

// Trim the white space from the front and end of the given string.
function strTrim(str) {
  while (str.charAt(0) == " ")
    str = str.slice(1);

  while (str.charAt(str.length-1) == " ")
    str = str.slice(0, -1);

  return str;
}


// Function: openWindow
// PARAMETERS
// url  = the JSP page to call
// Example:
// openWindow('emxprogramBasicsView.jsp?busId=busId')
var windowHandleOpenWindow = null;

function openWindow(url, width, height)
{

    if ((windowHandleOpenWindow == null) || (windowHandleOpenWindow.closed))
    {
      if (url.indexOf("?") != -1) {
        url = url + "&random=" + (new Date()).getTime();
      } else {
        url = url + "?random=" + (new Date()).getTime();
      }
      winHeight = Math.round(screen.height*height/100);
      winWidth = Math.round(screen.width*width/100);
      winX=Math.round(screen.width/2)-(winWidth/2);
      winY=Math.round(screen.height/2)-(winHeight/2);
      windowHandleOpenWindow = window.open(url, "EditWindow", " height="+winHeight+",width="+winWidth+",left="+winX+",top="+winY+",toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=yes,resizable=1,copyhistory=1,dependent=0");
    } else {
      windowHandleOpenWindow.focus();
    }
}

// Function: checkBoxCheckAll
// Description: checks all the checkboxes in a form
// Parameters:
//  allbox        the of the field in the form
//  chkprefix     the checkbox field name to check
//
// Usage:
//     onClick='checkAll(this,"ChBxPerson");
function checkBoxCheckAll (allbox, chkprefix) {
        form = allbox.form;
        max = form.elements.length;
        for (var i=0; i<max; i++) {
            fieldname = form.elements[i].name;
            if (fieldname.substring(0,chkprefix.length) == chkprefix) {
                form.elements[i].checked = allbox.checked;
            }
        }
}


// Function: confirmDelete
//
function confirmDelete(form, chkprefix) {
        max = form.elements.length;
        for (var i=0; i<max; i++) {
            fieldname = form.elements[i].name;
            if (fieldname.substring(0,chkprefix.length) == chkprefix) {
                if (form.elements[i].checked == true) {
                    return confirm(confirmDeleteMessage);
                }
            }
        }
        alert(selectItemToDelete);
        return false;
}



// Function: returnElementValue
//
function returnElementValue(form, chkprefix) {
        max = form.elements.length;
        for (var i=0; i<max; i++) {
            fieldname = form.elements[i].name;
            if (fieldname.substring(0,chkprefix.length) == chkprefix) {
                if (form.elements[i].checked == true) {
		    return form.elements[i].value;
                }
            }
        }
        return null;
}



// Function:

function confirmDeleteSubmit(form, chkprefix, action, target, encoding) {

  var chkprefix = arguments[1];
  var action = arguments[2];
  var target = arguments[3];
  var encoding = arguments[4];

 if (confirmDelete(form, chkprefix)) {

  if (action != null) {
    form.action = action;
  }

  if (target != null) {
    form.target = target;
  }

  if (encoding != null) {
    form.encoding = encoding;
  }

  form.submit();
  }


}


// Function: confirmSelectionSubmit
// Description: validates that at least one checkbox was selected
// this only works for radio or checked boxes
// Parameters:
//  form     Form name
//  chkprefix     the checkbox field name
//  action
//  target
//  encoding
//
// Usage:
//    confirmSelectionSubmit(formname,'radio','dkkdd.jsp',null,null)


// Function: confirmSelection
//
function confirmSelection(form, chkprefix) {
        max = form.elements.length;
        for (var i=0; i<max; i++) {
            fieldname = form.elements[i].name;
            if (fieldname.substring(0,chkprefix.length) == chkprefix) {
                if (form.elements[i].checked == true) {
                    return true;
                }
            }
        }
        alert(selectItem);
        return false;
}


function confirmSelectionSubmit(form, chkprefix, action, target, encoding) {

  var chkprefix = arguments[1];
  var action = arguments[2];
  var target = arguments[3];
  var encoding = arguments[4];

 if (confirmSelection(form, chkprefix)) {

  if (action != null) {
    form.action = action;
  }

  if (target != null) {
    form.target = target;
  }

  if (encoding != null) {
    form.encoding = encoding;
  }

  form.submit();
  }


}



// Function:  confirmSelectionOpenWindow
// Opens a new window but confirms that a selection has been made
// 1) Ensure the user selected the radio/checkbox
// 2) launches a new window with the correct dimentions
// Usage:
//confirmSelectionOpenWindow(ProjectModifyMembers,'RemoveBox','ModifyRole.jsp?busId=346',50,30)

function confirmSelectionOpenWindow(form, chkprefix, action, width, height) {

 if (confirmSelection(form, chkprefix)) {

  if (action== null || action == "") {
    alert(invalidActionForFunction);
  }

  if (width == null || width == "" ) {
   width = 70
  }

  if (height == null || height == "") {
    height = 70
  }

  action = action + "&" + chkprefix + "=" + returnElementValue(form, chkprefix)  ;
  newWindow(action,width,height);

    // openWindow(action,width,height);
  }



}

// Function: newWindow
// This function checks the browser and opens the new window based browser version
// Parameters:
//  url
//  width  =  width of window in pixels
//  height =  height of window in pixels
// Usage: newWindow('call.jsp?busId=13939393',300,400)
//

function newWindow(url,width,height) {

  if (url.indexOf("?") != -1) {
    url = url + "&random=" + (new Date()).getTime();
  } else {
    url = url + "?random=" + (new Date()).getTime();
  }

 if (is.nav4up) {

   window.open(url,"Project_Central","toolbar=no,innerWidth=" + width + ",innerHeight=" + height + ",directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no");

 } else if (is.ie4up) {

    window.open(url,"Project_Central","toolbar=no,width=" + width + ",height=" + height + ",status=no,scrollbars=yes,resizable=yes,menubar=no");

  } else {

   alert(v4OrHigher);

 }

}

//-----------------------------------------------------------------
// Method doDoneMulti()
// This function assigns the seleted names and ids of the object
// to the caller window.
//
// Parameters:
//  nothing.
// Returns:
//  nothing.
//-----------------------------------------------------------------

function doDoneMulti(){

  var winObj = parent.window.getWindowOpener().parent.frames[1];
  var result = new Array();
  result[0] = "";
  result[1] = "";

  //Iterate through all the child nodes of the root.
  for(var i=0;i<localSelectableTree.root.childNodes.length;i++)
  {
    var objNode = localSelectableTree.root.childNodes[i];
    //Iterate through all the child nodes.
    if (objNode.hasChildNodes) {
        result = objNode.getCheckedValues(result);
    }
  }
  //Create new URL
  var tempHref = winObj.location.href;
  if (tempHref.indexOf('?') > -1){
    var i = tempHref.indexOf(fieldName);
    if (i >-1) {
      var j = tempHref.indexOf('&', i+1);
      if (j > -1) {
        var str1 = tempHref.substring(0, j);
        var str2 = tempHref.substring(j);
        tempHref = str1 + result[1] + str2;
      } else {
        tempHref +=  result[1];
      }
    } else {
      tempHref += "&" + fieldName + "="  + result[1];
    }
    
    i = tempHref.indexOf(fieldId);
    if (i >-1) {
      var j = tempHref.indexOf('&', i+1);
      if (j > -1) {
        var str1 = tempHref.substring(0, j);
        var str2 = tempHref.substring(j);
        tempHref = str1 + result[0] + str2;
      } else {
        tempHref += result[0];
      }
    } else {
      tempHref += "&" + fieldId + "="  + result[0];
    }
  }else{
    tempHref += "?" + fieldName + "=" + result[1] + "&" + fieldId + "="  + result[0];
  }
  parent.window.closeWindow();
  winObj.location = tempHref;
}


// Check for field length longer than the max allowed length.
// We were getting oracle errors because unicode takes more bytes
// than ascii characters and in Oracle the max length for a name 
// field is currently 128 bytes.  Assuming 2 bytes still failed.
// The largest case for unicode is 4 bytes (UTF32).  This test
// handles mixed ascii and unicode characters.
function checkFieldLength(fieldObj,charset){
  s = fieldObj.value;
  var fieldLengthMax = 127;
  var i;
  var asciiCount = 0;
  var unicodeCount = 0;
  for (i = 0; i < s.length; i++) {
    var charValue = s.charCodeAt(i);
    if (charValue < 256) {
      asciiCount++;
    } else {
      unicodeCount++;
    }
  }
  
  var byteCount = (unicodeCount * 4) + asciiCount;
  // Start Bug 331661
  if((charset != null || charset != undefined) && charset=='Shift_JIS'){
    byteCount = (unicodeCount * 2) + asciiCount;
  }
  // End Bug 331661
  if (byteCount > fieldLengthMax) {
    fieldObj.focus();
    return "Fail";
  } else {
    return "Pass";
  }
}
//ADDED:PRG:s2i:R209:IR-010514V6R2011 
//Check for field length should not be more than 30 character
function checkWBSFieldLength(fieldObj,charset){
  s = fieldObj.value;
  var fieldLengthMax = 30;
  var i;
  var asciiCount = 0;
  var unicodeCount = 0;
  for (i = 0; i < s.length; i++) {
    var charValue = s.charCodeAt(i);
    if (charValue < 256) {
      asciiCount++;
    } else {
      unicodeCount++;
    }
  }
  
  var byteCount = (unicodeCount * 4) + asciiCount;
  // Start Bug 331661
  if((charset != null || charset != undefined) && charset=='Shift_JIS'){
    byteCount = (unicodeCount * 2) + asciiCount;
  }
  // End Bug 331661
  if (byteCount > fieldLengthMax) {
    fieldObj.focus();
    return "Fail";
  } else {
    return "Pass";
  }
}




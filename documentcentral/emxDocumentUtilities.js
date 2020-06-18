/*!================================================================
 *  JavaScript Details Tree
 *  emxDocumentUtilities.js
 *
 *  This file contains for emxDocumentUtilities.
 *
 *  Copyright (c) 1992-2016 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxDocumentUtilities.js.rca 1.10 Wed Oct 22 16:02:23 2008 przemek Experimental przemek $
 *=================================================================
 */

 //=================================================================
 // JavaScript Utilities
 // by Bill Tannalfo
 //=================================================================


  //-----------------------------------------------------------------
  // function jsParseSpChr() - replaces the defined special characters with the escape chr.
  // If the text contains chrs of single quotes(') or double quotes(") put backslash (\)
  // in front of the character.
  // argString: Text to be parsed.
  // Usage : If the user wants to escape more characters, add a new statement line for the specified chr.
  // For e.g.: to add "+" literal do this: parsedString = argString.replace(/[+]/g,"\+");
  //-----------------------------------------------------------------

  function jsParseSpChr(argString)
  {
    var parsedString = argString.replace(/[']/g,"\'");
    parsedString = argString.replace(/["]/g,"\"");
    return parsedString;
  }

  //-----------------------------------------------------------------
  // function jsTrimTxt() - Takes out leading and trailing spaces of a
  // text field and returns the string DIRECTLY back to the field.
  // argForm: The form's name.
  // argInputField: The text field's name
  //-----------------------------------------------------------------

   function jsTrimTxtBx(argForm, argInputField)
   {
     var frmStr = eval("document."+argForm+"."+argInputField+".value");

    // this will get rid of leading spaces
    //
     while (frmStr.substring(0,1) == ' ')
     frmStr = frmStr.substring(1, frmStr.length);

    // this will get rid of trailing spaces
    //
     while (frmStr.substring(frmStr.length-1,frmStr.length) == ' ')
     frmStr = frmStr.substring(0, frmStr.length-1);

     eval("document."+argForm+"."+argInputField+".value = frmStr");
     return;
   }

  //-----------------------------------------------------------------
  // function jsTrim() - Takes out leading and trailing spaces of a String.
  // valString: String to be trimmed.
  //-----------------------------------------------------------------
   function jsTrim(valString)
  {
    var trmString = valString;

    // this will get rid of leading spaces
    //
    while (trmString.substring(0,1) == ' ')
    trmString = trmString.substring(1, trmString.length);

    // this will get rid of trailing spaces
    //
    while (trmString.substring(trmString.length-1,trmString.length) == ' ')
    trmString = trmString.substring(0, trmString.length-1);
    return trmString;
  }

//-----------------------------------------------------------------
// function findFrames() - updates the tree information based on the action
// objWindow:-  object Window
// strName: window to find
//-----------------------------------------------------------------

function findFrames(objWindow, strName) {
  var objFrame = objWindow.frames[strName];
  if (!objFrame) {
    for (var i=0; i < objWindow.frames.length && !objFrame; i++)
      objFrame = findFrames(objWindow.frames[i], strName);
  }

  return objFrame;
}

//-----------------------------------------------------------------
// function changeTree() - updates the tree information based on the action
// action:-  changeObjectName, changeObjectID, deleteObject, removeChild
// objectInfo: objectId or objectName depending on Action
//-----------------------------------------------------------------

  function changeTree(action, objectInfo)
  {
    var tree = getTopWindow().tempTree;
    var treeDisplayFrame = findFrames(getTopWindow(), "treeDisplay");
    if(treeDisplayFrame != null)
    {
        if(tree)
        {
          if (action == "changeObjectName") {
            tree.getSelectedNode().changeObjectName(objectInfo);
          }
          else if (action == "changeObjectID") {
            tree.getSelectedNode().changeObjectID(objectInfo);
          }
          else if (action == "deleteObject")
          {
            if (tree.nodemap[objectInfo]) {
                for (var i=0; i <tree.nodemap[objectInfo].length; i++) {
                   if (tree.nodemap[objectInfo][i].parent.nodeID == "root") {
                     getTopWindow().frames["mainFrame"].location.reload();
                     return ;
                   }
                }
            }
            tree.deleteObject(objectInfo);
          }
          else if (action == "removeChild") {
            tree.getSelectedNode().removeChild(objectInfo);
          }
        }
     }
  }

  //-----------------------------------------------------------------
  // Opens type selector
  //-----------------------------------------------------------------

  function showTypeSelector(varUrl)
  {
    txtType=eval(strType);
    txtDisplayType=eval(strDisType);
    showModalDialog(varUrl, 450, 500, true);
  }

  //-----------------------------------------------------------------
  // Opens Person Chooser
  //-----------------------------------------------------------------

  function showPersonChooser(varUrl)
  {
    showModalDialog(varUrl, 700, 500, true);
  }

  //-----------------------------------------------------------------
  // Opens Policy Chooser
  //-----------------------------------------------------------------

  function showPolicyChooser(varUrl)
  {
    showModalDialog(varUrl, 400, 400, true);
  }

  //-----------------------------------------------------------------
  // Opens Search as chooser
  //-----------------------------------------------------------------

  function showSearchDialog(varUrl)
  {
    showModalDialog(varUrl, 700, 500, true);
  }

  //-----------------------------------------------------------------
  // Opens Search as chooser
  //-----------------------------------------------------------------

  function showFolderChooser(varUrl)
  {
     showModalDialog(varUrl, 700, 500, true);
  }


  //-----------------------------------------------------------------
  // Text Area length Validation
  //-----------------------------------------------------------------

  function checkMaxLength(field, maxLimit)
  {

    if(field.value.length > maxLimit)
    {
      return true;
    }

    return false;
  }

  //-------------------------------------------------------------------------
  // Special Character Validation used in Search dialog & Person Chooser Dialog
  // This function removes all the line breaks, * and ? from the list of bad
  // characters that is retrieved from the properties file.
  //------------------------------------------------------------------------


  function checkForFilteredSpecialChars(field, msgFirst, msgSecond)
  {

    field.value   = trimWhitespace(field.value);

    badCharacters = checkForNameBadChars(field, true);

    //Filtering the bad characters

    badCharacters = filterWildCardCharacters(badCharacters);

    //Removing the wild card characters from Bad characters
    //listed in properties file

    nameBadChars = filterWildCardCharacters(nameBadChars);

    badCharacters=removeSpaces(badCharacters);
    badCharacters=trimWhitespace(badCharacters);

    if(badCharacters.length != 0)
    {
      var msg = msgFirst + " :" + "\n" +"          "+ badCharacters + "\n" + msgSecond + nameBadChars;
      alert(msg);
      return false;
    }
    return true;
  }

  //-----------------------------------------------------------------
  // Filtering WildCard character
  //-----------------------------------------------------------------


  function filterWildCardCharacters(charString)
  {    
    charString = charString.toString();
    for(var i =0; i < charString.length;i++)
    {
      if(charString.indexOf("\n") != -1)
      {
        charString = charString.replace('\n','');
      }

      if(charString.indexOf("*") != -1)
      {
        charString = charString.replace('*','');
      }

      if(charString.indexOf("?") != -1)
      {
        charString = charString.replace('?','');
      }
    }
    return charString;
  }

  //-----------------------------------------------------------------
  // Special Character Validation
  //-----------------------------------------------------------------


  function checkForSpecialChars(field, msgFirst, msgSecond)
  {

    field.value   = trimWhitespace(field.value);

    badCharacters = checkForNameBadChars(field, true);

    if(badCharacters.length != 0)
    {
      alert(msgFirst + badCharacters + msgSecond + nameBadChars);
      return false;
    }
    return true;
  }


  //-----------------------------------------------------------------
  // Special Character Validation for AG Name
  //-----------------------------------------------------------------

  function checkForSpecialCharsInAGName(field, msgFirst, msgSecond, isObject, isFilter)
  {
    nameBadChars.push("&");
    nameBadChars.push("=");
    
    var badCharacters = "";
    if(isObject){
        field.value   = trimWhitespace(field.value);
        badCharacters = checkFieldForChars(field, nameBadChars, false);
    }else{
        field         = trimWhitespace(field);
        badCharacters = checkStringForChars(field, nameBadChars, false);
    }
    
    if(isFilter){
        //Filtering the bad characters
        badCharacters = filterWildCardCharacters(badCharacters);

        //Removing the wild card characters from Bad characters
        //listed in properties file
        nameBadChars = filterWildCardCharacters(nameBadChars);

        badCharacters=removeSpaces(badCharacters);
        badCharacters=trimWhitespace(badCharacters);
    }

    if(badCharacters.length != 0)
    {
      alert(msgFirst + badCharacters + msgSecond + nameBadChars);
      return false;
    }
    return true;
  }


  //-----------------------------------------------------------------
  // Handle Unexpected Errors
  //-----------------------------------------------------------------

  function handleError()
  {
    return true;
  }

  window.onerror = handleError;


  if(parent.window)
  {
    parent.window.onerror = handleError;
  }

//--------------------------------------------------------------
// Transfer focus on to next form element
// Usage:
// <INPUT type="text" name=text2 onFocus='transferFocusToNextElement(this);'>
// Author: Amit Verma.
// Date: 20th Jan 2003
//--------------------------------------------------------------
function transferFocusToNextElement(inputElement)
{
    //
    inputElement.readOnly = true;

    //get handle to elements form
    var inputElementsForm = inputElement.form;

    //iterate over all form elements
    for (var i=0; i < inputElementsForm.length; i++ )
    {
        //holds final element index to put focus on
        index = 0;

        //temp variable to compute element index to put focus on
        c = 0;

        //passed elements matched iterating value
        if (inputElement.name == inputElementsForm.elements[i].name)
        {
            //initialize temp variable to i
            c = i;

            //iterate the further elements to eliminate
            //any hidden elements
            while(1==1)
            {
                c = c + 1;

                //if transfer focus from the last form element reset
                //counter to 0 i.e trnasfer focus to the first form element
                if(c == (inputElementsForm.length-1))
                {
                    c = 0;
                }
                if(inputElementsForm[c].type == "hidden")
                {
                    continue;
                }
                else
                {
                    //final element index value
                    index = c;
                    break;
                }
            }

            //if reached the final element reset the index to
            //0th form element trnasfer focus to the first form element
            if(index == (inputElementsForm.length-1))
            {
                index = 0;
            }

            inputElementsForm[index].focus();
            break;
        }
    }
}

//-----------------------------------------------------------------
// function checkStringForDoubleQuotes() - Checks if double quotes is present in a given string
// strText:-  Text to be passed in
// Returns True if double quotes is present in the string
//-----------------------------------------------------------------

	function checkStringForDoubleQuotes(strText){
      var strQuotes = "\"";

       if (strText.indexOf(strQuotes) > -1) {
       	return true;
       }
       else
       {
       	return false;
       }
        
	}

	function setScopListVal(){
		//var val = document.getElementsByName("name")[0].type;
		alert("6666666666666");
	}

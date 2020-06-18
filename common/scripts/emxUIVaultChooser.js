//=================================================================
// JavaScript Methods for emxVaultChooserDisplay.jsp
// Version 1.0
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================    
    
     

  function trim (textBox) {
    while (textBox.charAt(textBox.length - 1) == ' ' || textBox.charAt(textBox.length - 1) == "\r"
      || textBox.charAt(textBox.length - 1) == "\n") {
      textBox = textBox.substring(0,textBox.length - 1);
    }
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n") {
      textBox = textBox.substring(1,textBox.length);
    }
    return textBox;
  }

  function windowClose(){
    getTopWindow().closeWindow();
  }


  function doCheck(){
    var objForm = document.forms[0];
    var chkList = objForm.chkList;

    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].name.indexOf('vaults') > -1){
        objForm.elements[i].checked = chkList.checked;
      }
  }

  function updateCheck(selectType) {
    
    if(selectType == "checkbox")
    {
       var objForm = document.forms[0];
       var chkList = objForm.chkList;
       chkList.checked = false;
    }
  }

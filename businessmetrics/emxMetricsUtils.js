//=================================================================
// JavaScript utility functions for search pages
// Version 1.0
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================    

//emxSearchFooter functions
var searchOnce = 0;

function doFindNavigate() {

    var QLimit = parseInt(document.forms[0].QueryLimit.value, 10);
    
    //content frame
    var bodyFrame = findFrame(getTopWindow(),"metricsReportContent");

    if(bodyFrame.document.forms[0].QueryLimit){
        bodyFrame.document.forms[0].QueryLimit.value = QLimit;
        getTopWindow().pageControl.setQueryLimit(QLimit);
    }

    if(bodyFrame.document.forms[0].queryLimit){
        bodyFrame.document.forms[0].queryLimit.value = QLimit;
        getTopWindow().pageControl.setQueryLimit(QLimit);
    }

    if(bodyFrame.document.forms[0].pagination){
        bodyFrame.document.forms[0].pagination.value = (document.forms[0].pagination.checked)? paginationRange : '0';
        getTopWindow().pageControl.setPagination((document.forms[0].pagination.checked)? parseInt(paginationRange) : 0);
    }
    
    //check that the url is the same in both the pageController and bodyFrame
    //if not then reset
    getTopWindow().validateURL();

    //store the form values
    getTopWindow().storeFormVals(bodyFrame.document.forms[0]);


    //run local doSearch Method
    bodyFrame.doSearch();
}



function setFormfields(){
    //set pagination
    if(getTopWindow().pageControl.getPagination() != null){
        document.forms[0].pagination.checked = getTopWindow().pageControl.getPagination();
    }
    //set queryLimit
    if(getTopWindow().pageControl.getQueryLimit() != null){
        document.forms[0].QueryLimit.value = getTopWindow().pageControl.getQueryLimit();
    }

}

function trimString(strString) {
    strString = strString.replace(/^\s*/g, "");
    return strString.replace(/\s+$/g, "");
}


function focusFormElm(){
    var elm = document.getElementById("txtName");
    elm.focus();
}

function checkField(field){
      var newBadChar = "% &";
      var arrayBadChar = newBadChar.split(" ");
    field.value = trimWhitespace(field.value);
    badCharacters = checkForNameBadCharsList(field);
    if(badCharacters.length != 0) 
    {
        alert(STR_INVALID_INPUT_MSG + badCharacters +" "+ newBadChar);
        return false;
    } 
    else 
    {
        var fieldValue = field.value;
        for (var i=0; i < arrayBadChar.length; i++)
        {
            if (fieldValue.indexOf(arrayBadChar[i]) > -1)
            {
                badCharacters += arrayBadChar[i] + " ";
            }
        }
        if(badCharacters.length != 0)
        {
            alert(STR_INVALID_INPUT_MSG + STR_NAME_BAD_CHARS +" "+ newBadChar);
            return false;
        }
    }
    return true;
}

function setSaveName(str){     
    getTopWindow().getWindowOpener().getTopWindow().pageControl.setSavedReportName(str);
}
                     


function doEdit(str){
    setSaveName(str);
    getTopWindow().importSavedSearchXML();
}   

function doDelete(str){
    if(confirm(ConfirmDelete + str + "\"?")){
        var result = getTopWindow().deleteSearch(str,"delete");
        searchManageHidden.document.write(result);
        setSaveName("");
    }
}

function onFilterOptionChange(){
    var newSelectedFilter = document.MetricsSaveAsForm.filterSaveAsBody.options[document.MetricsSaveAsForm.filterSaveAsBody.selectedIndex].value;    
    currentURL = parent.document.location.href;

    var filterPoint = currentURL.indexOf("selectedFilter");
    if (filterPoint > -1){
        var remainingURL = currentURL.substring(filterPoint,currentURL.length);
        var leftSideURL = currentURL.substring(0, filterPoint);

        var amppoint = remainingURL.indexOf("&");
        if(amppoint > -1)
            remainingURL = remainingURL.substring(amppoint, currentURL.length);
        else
            remainingURL = "";

        currentURL = currentURL.substring(0,filterPoint-1);
        currentURL = leftSideURL + remainingURL;
    }

    var newPageURL = "";
    if (currentURL.indexOf("?") == -1)
        newPageURL = currentURL + "?selectedFilter=" + newSelectedFilter;
    else
        newPageURL = currentURL + "&selectedFilter=" + newSelectedFilter;

    parent.document.location.href = newPageURL;
    return;
}

//escapes the special characters in the report name
//or the title given by the user
function escapeSpecialCharacters(strTitle)
{
    var tempTitle = "";
    if(strTitle.length>0)
    {
       for(var i=0; i<strTitle.length; i++)
       {
          var s = strTitle.charAt(i);
          if(s=="'")
          {
              s="\\\'";
          }
          if(s=="\"")
          {
              s="\\\"";
          }
          tempTitle = tempTitle + s;
       }
       strTitle = tempTitle;
          
    }

    return strTitle;
}

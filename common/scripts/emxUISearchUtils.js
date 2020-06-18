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

// added for Consolidated Search
function doConsolidatedSearch()
{		
	var QLimit = parseInt(getTopWindow().document.getElementById("QueryLimit").value, 10);    
    
    var bodyFrame = findFrame(getTopWindow(),"searchContent");    
	
	if(bodyFrame && bodyFrame.contentWindow)
	{
		bodyFrame = bodyFrame.contentWindow;		
	}
	else if(bodyFrame)
	{
		bodyFrame = bodyFrame;
	}    
  
    if(bodyFrame.document.forms[0].QueryLimit){
        bodyFrame.document.forms[0].QueryLimit.value = QLimit;
        getTopWindow().pageControl.setQueryLimit(QLimit);
    }
    
     if(bodyFrame.document.forms[0].queryLimit){
        bodyFrame.document.forms[0].queryLimit.value = QLimit;
        getTopWindow().pageControl.setQueryLimit(QLimit);
    }
		
		
	//check that the url is the same in both the pageController and bodyFrame
    //if not then reset
    getTopWindow().validateURL();
    
	//store the form values
    getTopWindow().storeFormVals(bodyFrame.document.forms[0]);   
  
    
    if (getTopWindow().pageControl.getSearchContentURL().indexOf("emxSearchManage.jsp") != -1)
    {
       bodyFrame.doSearch();
       return;
    }
    
    //run local doSearch Method   	
	getTopWindow().doGenericSearch();
}

// ended for Consolidated Search

// added for Consolidated Search

function doConsolidatedFind()
{
	 if(++searchOnce == 1){
        setTimeout("searchOnce = 0", 5000);
                
       var QLimit = trimWhitespace(getTopWindow().document.getElementById("QueryLimit").value);
        
        //is the QLimit a number?
        if(isNaN(QLimit) || QLimit.length == 0){
                alert(QueryLimitNumberFormat);
                return;
        }
        
        //does QLimit contain a decimal?
        if(QLimit.indexOf(".") != -1){
                alert(QueryLimitNumberFormat);
                return;
        }
        
        //QLimit must be at least 1
        QLimit = parseInt(QLimit, 10);
        if(QLimit < 1){
                alert(QueryLimitNumberFormat);
                return;
        }       
        
        //QLimit must not be greater than 32767
        if(QLimit > upperQueryLimit){
                alert(QueryLimitMaxAllowed);
                return;
        }    
    	
        turnOnProgress("utilProgressBlue.gif");
        setTimeout("doConsolidatedSearch()", 500);
    }		

}

// ended for Consolidated Search


function doFind() {
    if(++searchOnce == 1){
        setTimeout("searchOnce = 0", 5000);
        var QLimit = trimWhitespace(document.forms['searchFooterForm'].QueryLimit.value);
        
        //is the QLimit a number?
        if(isNaN(QLimit) || QLimit.length == 0){
                alert(QueryLimitNumberFormat);
                return;
        }
        
        //does QLimit contain a decimal?
        if(QLimit.indexOf(".") != -1){
                alert(QueryLimitNumberFormat);
                return;
        }
        
        //QLimit must be at least 1
        QLimit = parseInt(QLimit, 10);
        if(QLimit < 1){
                alert(QueryLimitNumberFormat);
                return;
        }
        
        //QLimit must not be greater than 32767
        if(QLimit > upperQueryLimit){
                alert(QueryLimitMaxAllowed);
                return;
        }
    
        turnOnProgress("utilProgressBlue.gif");
        setTimeout("doFindNavigate()", 500);
    }
    
}


function doFindNavigate() {

    var QLimit = parseInt(document.forms['searchFooterForm'].QueryLimit.value, 10);
    
    //content frame
    var bodyFrame = findFrame(getTopWindow(),"searchContent");

    if(bodyFrame.document.forms[0].QueryLimit){
        bodyFrame.document.forms[0].QueryLimit.value = QLimit;
        getTopWindow().pageControl.setQueryLimit(QLimit);
    }

    if(bodyFrame.document.forms[0].queryLimit){
        bodyFrame.document.forms[0].queryLimit.value = QLimit;
        getTopWindow().pageControl.setQueryLimit(QLimit);
    }

    if(bodyFrame.document.forms[0].pagination){
        bodyFrame.document.forms[0].pagination.value = (document.forms[0].pagination.checked)? paginationRange : maxPaginationRange;    
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
        document.forms['searchFooterForm'].pagination.checked = getTopWindow().pageControl.getPagination();
    }
    //set queryLimit
    if(getTopWindow().pageControl.getQueryLimit() != null){
        document.forms['searchFooterForm'].QueryLimit.value = getTopWindow().pageControl.getQueryLimit();
    }

}

//emxSearchSaveDialog  functions
function trimString(strString) {
    strString = strString.replace(/^\s*/g, "");
    return strString.replace(/\s+$/g, "");
}




function checkField(field){
    field.value = trimWhitespace(field.value);
    badCharacters = checkForNameBadCharsList(field);
    if(badCharacters.length != 0) {
      alert(InvalidInputMsg + badCharacters);
      return false;
    }
    return true;
}


function focusFormElm(){
    var elm = document.getElementById("txtName");
    elm.focus();
}

//emxSearchSaveDialog and
//emxSearchSaveAsDialog functions
function checkField(field){
    field.value = trimWhitespace(field.value);
    badCharacters = checkForNameBadCharsList(field);
    if(badCharacters.length != 0) {
      alert(InvalidInputMsg + badCharacters);
      return false;
    }
    return true;
}

//emxSearchManage functions
function setSaveName(str){
    getTopWindow().pageControl.setSavedSearchName(str);
    
    //Modified for IR-102268V6R2012x : Begin
    getTopWindow().setSaveFunctionality(str && str.length > 0);
    //Modified for IR-102268V6R2012x : End
}
                     


function doEdit(str){
    setSaveName(str);
    //get saved search
    getTopWindow().importSavedSearchXML("edit");
}   

function doDelete(strDispVal,strVal){
    if(confirm(ConfirmDelete + strDispVal + "\"?")){
        var result = getTopWindow().deleteSearch(strVal,"delete");
        searchManageHidden.document.write(result);
        setSaveName("");
    }
}

<%--  emxGetFromCatalogVPLMDialogFS.jsp
  Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: This page constructs the frameset to gather search criteria
                                to search for business objects

   Parameters : Dialog Action-searchResults/Addchildren/Choosers
                              /SearchIn/SearchWithin
                baseType-VPLM Catalog
                searchDirection-
                selectOption-Single
                sUITable--Table bean name in session to gray out
                          search results
                if already added in case of AddExixiting scenario.
   Author     : 
   Date        : 
   History    :

   static const char RCSID[] ="$Id: emxLibraryCentralObjectFindDialogFS.jsp.rca 1.5.1.1.1.4 Mon Jan  7 14:34:17 2008 msikhinam Experimental $"
--%>


<%@include file="../emxUIFramesetUtil.inc" %>
<%--@include file = "emxLibraryCentralUtils.inc" --%> 


<%

	
	//--Getting The Request Parameters
   	String languageStr = request.getHeader("Accept-Language");
   	String baseType          = emxGetParameter(request, "baseType");	
	String searchType        = emxGetParameter(request, "searchType");
    String searchName          = emxGetParameter(request, "searchName");
    String searchDirection = emxGetParameter(request, "searchDirection");
	String strUseMode = "classifiedItems";
	
    //--Determines in which mode search was opened example.
    //--Chooser/AddChildren/SearchResults/SearchIn/SearchWithin/CreateIn
    String dialogAction    = emxGetParameter(request, "DialogAction");

    //--Parent Object Id in case of  searchIn and AddExistingCase
    String parentOId        = emxGetParameter(request, "objectId");
    // Determines single select or multiple respectively
    String selectOption    = emxGetParameter(request, "selectOption");

    //-This parameter is passed when thsi frameset is called
    //from refine search Link
    String refineSearch    = emxGetParameter(request, "refineSearch");

    if(dialogAction==null)
    {
        dialogAction="addChildren";
    }
    if(baseType==null)
    {
        baseType="*ENOCLG_ClassReference";
    }
    if (selectOption==null)
    {
        selectOption="single";
    }
    if(searchName==null)
    {
    	searchName="*";
    }
  
    //--Create Search Frameset Object
     // modified the code for the Bug 338746
    //searchFramesetObject fs = new searchFramesetObject();
	 framesetObject fs = new framesetObject();


    //---Setting the app Directory

    //fs.setDirectory(appDirectory);

    // --Setting String resourse Property File

    fs.setStringResourceFile("emxLibraryCentralStringResource");
    fs.setStringResourceFile("emxCatalogSynchroStringResource");
    // --Page Header Token Depending on DialogAction

    String pageHeading= null;
    String helpMarker = "emxhelpsearch";

	pageHeading = "emxCatalogSynchro.Command.FindChapter";

    // --Prepare the proper contentUrl with all the required
    //parameters-
    StringBuffer contentUrl = new StringBuffer(256);
		contentUrl.append("emxGetFromCatalogVPLMDialog.jsp?");
	
    //DefualtUrl to init the Frameset----------
    String defaultContentUrl    = null;

    contentUrl.append("DialogAction=" + dialogAction);
    contentUrl.append("&searchDirection=" + searchDirection);
    contentUrl.append("&objectId=" + parentOId);
    contentUrl.append("&selectOption=" + selectOption);
    contentUrl.append("&useMode=" + strUseMode);
    contentUrl.append("&baseType=" + baseType);
    contentUrl.append("&searchType=" + searchType);
    contentUrl.append("&searchName=" + searchName);

	// Prepare the proper contentUrl InCase of refine Search----
	if((refineSearch!=null && refineSearch.equalsIgnoreCase("true")))
	{
		StringBuffer contentUrlRefine = new StringBuffer(256);
		contentUrlRefine.append("emxGetFromCatalogVPLMDialog.jsp?");
	}

	// code added for the Bug 338746
	fs.initFrameset(pageHeading,helpMarker,contentUrl.toString(),false,true,false,false);
           
	fs.createCommonLink("Done",
                      "searchResults()",
                      "role_GlobalUser",
                      false,
                      true,
                      "emxUIButtonDone.gif",
                      false,
                      5);
      fs.createCommonLink("Cancel",
                      "parent.window.close()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      0);
    fs.writePage(out);
    
    
    
%>


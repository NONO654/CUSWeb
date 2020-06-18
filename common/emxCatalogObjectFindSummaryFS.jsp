<%--  emxDocumentObjectFindSummaryFS.jsp
   Copyright (c) 1992-2008 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description:  This page constructs the frameset to display the results of the search
   Parameters :  baseType (Library/Bookshelf/Book/GenericDocument/All)
                 dialogAction (SearchResults, AddChildren, SearchIn, Chooser)

   Author     : MadhavG
   Date       : 12/11/2002
   History    :

   static const char RCSID[] = "$Id: emxLibraryCentralObjectFindSummaryFS.jsp.rca 1.3.1.1.1.3 Thu Feb  7 19:52:35 2008 przemek Experimental $"
--%>


<%@include file = "../emxUIFramesetUtil.inc"%>

<%--  Table bean Name of Search results  --%>

<jsp:useBean id="emxCatalogFindObjectSummaryFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
    // Getting The Request Parameters
    String dialogAction = emxGetParameter(request, "DialogAction");
    String sQueryLimit  = emxGetParameter(request, "QueryLimit");
    String baseType = emxGetParameter(request, "baseType");
    String languageStr = request.getHeader("Accept-Language");


    // Create Frameset Object
    framesetObject fs = new framesetObject();
    fs.useCache(false);
    //fs.setDirectory(appDirectory);

    // Setting String resourse Property File
    fs.setStringResourceFile("emxLibraryCentralStringResource");

    // Setting the Table bean Instansiated
    String tableBeanName = "emxLibraryCentralFindObjectSummaryFS";
    fs.setBeanName(tableBeanName);

    // Specify URL to come in middle of frameset
    StringBuffer contentUrl =
                new StringBuffer("emxCatalogObjectFindSummary.jsp?");

    contentUrl.append("beanName=" + tableBeanName);
    contentUrl.append("&sQueryLimit=" + sQueryLimit);

    // Adding request parameter to the ContentUrl
    for(Enumeration names = emxGetParameterNames(request);
                                        names.hasMoreElements();)
    {
        String name  = (String) names.nextElement();
        String value = emxGetParameter(request, name);
        contentUrl.append("&" + name + "=" + value);
    }

    // Page Header Token Depending on Dialog Action
    String pageHeading = null;

    String helpMarker = "emxhelpsearchresults";

    if(dialogAction.equals("searchResults"))
    {
        pageHeading = "emxDocumentCentral.Button.SearchResults";
    }
    else 
    {
        pageHeading = "Select";
    }
    	

    // Common Links Creating Depneding on Dialog Action--
    // createCommonLink(java.lang.String displayString, java.lang.String href,
    // java.lang.String roleList, boolean popup, boolean isJavascript,
    // java.lang.String iconImage, boolean isTopLink, int WindowSize)
    fs.createCommonLink("NewSearch",
                        "newSearch()","role_GlobalUser", false,true,
                        "default",true,0);

    fs.createCommonLink("RefineSearch",
                        "refineSearch()","role_GlobalUser",false,
                        true,"default",true,0);

   if(dialogAction.equalsIgnoreCase("AddChildren"))
    {
        fs.createCommonLink("Select",
                            "addChild()","role_GlobalUser",false,true,
                            "emxUIButtonDone.gif",false,0);

        fs.createCommonLink("Cancel","close()",
                            "role_GlobalUser",false,true,
                            "emxUIButtonCancel.gif",false,0);
    }

    contentUrl.append("&contentPageIsDialog=false");

    // ------------------Init Frameset-----------------------------------------
    // initFrameset(java.lang.String pageHeading, java.lang.String helpMarker,
    //            java.lang.String contentURL, boolean UsePrinterFriendly,
    //            boolean IsDialogPage, boolean ShowPagination, boolean
    //                                       ShowConversion)

    fs.initFrameset(pageHeading,helpMarker,contentUrl.toString(),
                                            true,true,true,false);
    fs.writePage(out);
%>


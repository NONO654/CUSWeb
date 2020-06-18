<%--  emxDocumentObjectFindSummaryFS.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description:  This page constructs the frameset to display the results of the search
   Parameters :  baseType (Library/Bookshelf/Book/GenericDocument/All)
                 dialogAction (SearchResults, AddChildren, SearchIn, Chooser)

   Author     :
   Date       :
   History    :

   static const char RCSID[] = "$Id: emxCommonFindPartSummaryFS.jsp.rca 1.7 Wed Oct 22 16:18:15 2008 przemek Experimental przemek $
   21:36:41 ajoseph Exp $"
--%>


<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsUtil.inc" %>

<%--  Table bean Name of Search results  --%>

<jsp:useBean id="emxCommonFindPartSummaryFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
    // Getting The Request Parameters
    String dialogAction = emxGetParameter(request, "DialogAction");
    String sQueryLimit  = emxGetParameter(request, "QueryLimit");
    String baseType = emxGetParameter(request, "baseType");
    String parentType = emxGetParameter(request, "parentType");
    String languageStr = request.getHeader("Accept-Language");

    // Create Frameset Object
    framesetObject fs = new framesetObject();
    fs.useCache(false);
    fs.setDirectory(appDirectory);

    // Batch Print data
    String batchPrint = EnoviaResourceBundle.getProperty(context, "eServiceBatchPrintPDF.Batch.BatchPrintAvailable", context.getLocale(), "emxBatchPrintPDF");

    if(batchPrint == null) {
      batchPrint = "FALSE";
    }
    String document = PropertyUtil.getSchemaProperty(context,"type_GenericDocument");

    // Setting String resourse Property File
    fs.setStringResourceFile("emxComponentsStringResource");

    // Setting the Table bean Instansiated
    String tableBeanName = "emxCommonFindPartSummaryFS";
    fs.setBeanName(tableBeanName);

    // Specify URL to come in middle of frameset
    StringBuffer contentUrl =
                new StringBuffer("emxCommonFindPartSummary.jsp?");
    StringBuffer attrParamBuffer =
                new StringBuffer("beanName=" + tableBeanName);

    StringList slFieldNames = new StringList();
    slFieldNames.addElement("DialogAction");
    slFieldNames.addElement("baseType");
    slFieldNames.addElement("searchType");
    slFieldNames.addElement("searchDirection");
    slFieldNames.addElement("objectId");
    slFieldNames.addElement("sUITable");
    slFieldNames.addElement("folderContentAdd");
    slFieldNames.addElement("showPaginationMinimized");
    slFieldNames.addElement("Accept-Language");
    slFieldNames.addElement("forceRefresh");
    slFieldNames.addElement("PrinterFriendly");
    slFieldNames.addElement("sQueryLimit");
    slFieldNames.addElement("QueryLimit");
    slFieldNames.addElement("sortKey");
    slFieldNames.addElement("sortDir");
    slFieldNames.addElement("sortType");
    slFieldNames.addElement("bean");

    contentUrl.append("beanName=" + tableBeanName);
    contentUrl.append("&sQueryLimit=" + sQueryLimit);
    attrParamBuffer.append("&sQueryLimit=" + sQueryLimit);

    // Adding request parameter to the ContentUrl
    for(Enumeration names = emxGetParameterNames(request);
                                        names.hasMoreElements();)
    {
        String name  = (String) names.nextElement();
        String value = emxGetParameter(request, name);
        if(slFieldNames.contains(name))
        {
          contentUrl.append("&" + name + "=" + value);
        }
        attrParamBuffer.append("&" + name + "=" + value);
    }

    // Page Header Token Depending on Dialog Action
    String pageHeading = null;

    String helpMarker = "emxhelpsearchresults";

    if(dialogAction.equals("searchResults"))
    {
        pageHeading = "emxComponents.Button.SearchResults";
    }
    else
    {
        pageHeading = "emxComponents.Common.Select";
    }

    // Common Links Creating Depneding on Dialog Action--
    // createCommonLink(java.lang.String displayString, java.lang.String href,
    // java.lang.String roleList, boolean popup, boolean isJavascript,
    // java.lang.String iconImage, boolean isTopLink, int WindowSize)
    fs.createCommonLink("emxComponents.Button.NewSearch",
                        "newSearch()","role_GlobalUser", false,true,
                        "default",true,0);

    fs.createCommonLink("emxComponents.ActionBarCmd.RefineSearch",
                        "refineSearch()","role_GlobalUser",false,
                        true,"default",true,0);

    if(dialogAction.equals("searchResults")||
                                dialogAction.equalsIgnoreCase("searchIn"))
    {
        fs.createCommonLink(
                "emxComponents.ActionBarCmd.AddSelectedtoFolders",
                "addSelectedToFolder()","role_GlobalUser",false,
                true,"default", false,0);

        fs.createCommonLink("emxComponents.ActionBarCmd.DeleteSelected",
                           "deleteSelected()","role_GlobalUser",false,
                            true,"default",false,0);

        fs.createCommonLink("emxComponents.ActionBarCmd.SubscribetoSelected",
                           "subscribe()", "role_GlobalUser", false,
                            true, "default", false, 0 );

        if(batchPrint.equalsIgnoreCase("TRUE") && baseType.equalsIgnoreCase(document)) {
          fs.createCommonLink("emxComponents.ActionBarCmd.PrintSelected",
                              "printSelected()","role_GlobalUser",false,
                              true,"default",false,0);
        }

        fs.createCommonLink("emxComponents.Button.Close","close()",
                            "role_GlobalUser",false,true,
                            "common/images/buttonDialogCancel.gif",false,0);
    }else if(dialogAction.equalsIgnoreCase("AddChildren"))
    {
        fs.createCommonLink("emxComponents.Button.Select",
                            "addChild()","role_GlobalUser",false,true,
                            "common/images/buttonDialogDone.gif",false,0);

        fs.createCommonLink("emxComponents.Button.Cancel","close()",
                            "role_GlobalUser",false,true,
                            "common/images/buttonDialogCancel.gif",false,0);
    }

       contentUrl.append("&contentPageIsDialog=false");

    // ------------------Init Frameset-----------------------------------------
    // initFrameset(java.lang.String pageHeading, java.lang.String helpMarker,
    //            java.lang.String contentURL, boolean UsePrinterFriendly,
    //            boolean IsDialogPage, boolean ShowPagination, boolean
    //                                       ShowConversion)
    fs.initFrameset(pageHeading,helpMarker,contentUrl.toString(),
                                            true,true,true,false);
    session.setAttribute("attrParamBuffer",attrParamBuffer.toString());
    fs.writePage(out);
%>


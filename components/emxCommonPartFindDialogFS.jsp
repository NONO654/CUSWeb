<%--  emxCommonPartFindDialogFS.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.

   Description: This page constructs the frameset to gather search criteria
                                to search for business objects

   Parameters :
   Author     :
   Date       :
   History    :

--%>


<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc" %>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>


<%
  //--Getting The Request Parameters
    String languageStr = request.getHeader("Accept-Language");
    String baseType        = emxGetParameter(request, "baseType");
  String searchType        = emxGetParameter(request, "searchType");
    String searchDirection = emxGetParameter(request, "searchDirection");

    //--Chooser/AddChildren/SearchResults/SearchIn/SearchWithin/CreateIn
    String dialogAction    = emxGetParameter(request, "DialogAction");

  //--Parent Object Id in case of  searchIn and AddExistingCase
    String parentOId        = emxGetParameter(request, "objectId");

    // Determines single select or multiple respectively

    String selectOption    = emxGetParameter(request, "selectOption");

    //-This parameter is passed when thsi frameset is called
    //from refine search Link

    String refineSearch    = emxGetParameter(request, "refineSearch");
    String sUITable        = emxGetParameter(request, "sUITable");

    //--Contains information if search is called from folder Content
    String folderContentAdd= emxGetParameter(request, "folderContentAdd");
    String sPartFamily        = PropertyUtil.getSchemaProperty( context,"type_PartFamily" );
    String sPart              = PropertyUtil.getSchemaProperty( context,"type_Part" );

    if(dialogAction==null)
    {
        dialogAction="AddChildren";
    }
    if(baseType==null)
    {
        baseType=DomainConstants.TYPE_PART;
    }
    if (selectOption==null)
    {
        selectOption="single";
    }
    if(folderContentAdd==null)
    {
        folderContentAdd="false";
    }

    //--Create Search Frameset Object

    searchFramesetObject fs = new searchFramesetObject();

    //---Setting the app Directory

    fs.setDirectory(appDirectory);

    // --Setting String resourse Property File

    fs.setStringResourceFile("emxComponentsStringResource");

    // --Page Header Token Depending on DialogAction

    String pageHeading= null;
    String helpMarker = "emxhelpsearch";
    pageHeading = "emxComponents.Command.Search";
    fs.setHelpMarker(helpMarker);

    // --Setting The Query Limit From Properties File or from request
    //If its case of refine search we need to prepopulate based
    // on the entry on which user performed search so taken from request.

    String sQueryLimit = null;

    if((refineSearch!=null && refineSearch.equalsIgnoreCase("true"))){
    sQueryLimit = emxGetParameter(request, "sQueryLimit");

    //Catch Exception if in properties file some wierd enty is there

    try
    {
        Integer integerLimit = new Integer(sQueryLimit);
        int intLimit = integerLimit.shortValue();
        fs.setQueryLimit(intLimit);
    }
    //The Alert Message is Shown and Default(100) is set to BootomFrame
    catch(NumberFormatException e)
    {
        fs.setQueryLimit(100);
     }
    }

    else{

     sQueryLimit = EnoviaResourceBundle.getProperty(context,"emxFramework.Search.QueryLimit");
    //Catch Exception if in properties file some wierd enty is there
    try
    {
      Integer integerLimit = new Integer(sQueryLimit);
      int intLimit = integerLimit.shortValue();
      fs.setQueryLimit(intLimit);
    }

    //The Alert Message is Shown and Default(100) is set to BootomFrame

   catch(NumberFormatException e)
    {
        fs.setQueryLimit(100);

%>
    <script language="javascript"  type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers

    alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.MaxQueryLimit</emxUtil:i18nScript>");
    //Stop hiding here -->//]]>

    </script>

<%
    }
   }


    StringBuffer contentUrl = new StringBuffer(
                                    "emxCommonFindParts.jsp?");
    String contentUrlPart         =null;
    String defaultContentUrl    = null;
    contentUrl.append("DialogAction=" + dialogAction);
    contentUrl.append("&parentType="+baseType );
  contentUrl.append("&searchDirection=" + searchDirection);
    contentUrl.append("&objectId=" + parentOId);
    contentUrl.append("&selectOption=" + selectOption);
    contentUrl.append("&sUITable=" + sUITable);
    contentUrl.append("&folderContentAdd=" + folderContentAdd);

   if((refineSearch!=null && refineSearch.equalsIgnoreCase("true")))
   {
       StringBuffer contentUrlRefine = new StringBuffer(
                                "emxCommonFindParts.jsp?");

       contentUrlRefine.append("refineSearch="+refineSearch);
      Enumeration enumParamNames = emxGetParameterNames(request);

      while(enumParamNames.hasMoreElements())
      {
          String paramName = (String) enumParamNames.nextElement();
          String paramValue = (String)emxGetParameter(request, paramName);
          contentUrlRefine.append("&"+paramName +"=" + paramValue);
      }
      contentUrl.append("&refineSearch=true");
   }
   contentUrlPart =Framework.encodeURL(response,
                                    contentUrl+"&baseType=" + sPart+"&searchType=" + searchType);


  fs.createSearchLink("emxComponents.Command.FindParts",
                               com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentUrlPart),
                               "role_GlobalUser");
      defaultContentUrl=contentUrlPart;

    fs.initFrameset (pageHeading,
                     defaultContentUrl,
                     "emxComponents.Common.SearchHeading",
         true);
    fs.writePage(out);
%>



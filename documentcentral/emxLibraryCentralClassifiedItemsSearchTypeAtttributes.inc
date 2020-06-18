<%--
   emxLibraryCentralClassifiedItemsSearchTypeAtttributes.inc
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLibraryCentralClassifiedItemsSearchTypeAtttributes.inc.rca 1.3.3.4 Wed Oct 22 16:02:22 2008 przemek Experimental przemek $
--%>

<%@ page import = "java.util.*"%>
<%
///ADDED 20 March 2005
String strSearchProcessPage = emxGetParameter(request, "searchProcessPage");
if (strSearchProcessPage == null || "".equals(strSearchProcessPage) || "null".equals(strSearchProcessPage))
{
    strSearchProcessPage = "../documentcentral/emxLibraryCentralSearchInProcess.jsp";
}

String strMainSearchDialogPage = emxGetParameter(request, "mainSearchDialogPage");
if (strMainSearchDialogPage == null || "".equals(strMainSearchDialogPage) || "null".equals(strMainSearchDialogPage))
{
    strMainSearchDialogPage = "emxLibraryCentralClassifiedItemsSearch.jsp";
}
///ADDED 20 March 2005
%>

    <input type=hidden name="header" value="emxDocumentCentral.Common.PartsPageHeading">
    <input type=hidden name="table" value="LCMyPartsList">
    <input type=hidden name="program" value="emxLibraryCentralCommon:getClassifiedItems">
    <input type=hidden name="toolbar" value="LCPartsInPartFamilyToolBar">
    <input type=hidden name="QueryLimit" value="">
    <input type=hidden name="pagination" value="">
    <input type=hidden name="HelpMarker" value="emxhelpsearchwithinresults">
    

<%
    StringList slFieldNames = new StringList();
    slFieldNames.addElement("txtTypeDisplay");
    slFieldNames.addElement("txtTypeActual");
    slFieldNames.addElement("txtName");
    slFieldNames.addElement("txtRev");
    slFieldNames.addElement("txtDescription");
    slFieldNames.addElement("txtOwner");
    slFieldNames.addElement("txtDisplayOwner");
    slFieldNames.addElement("levelSelction");
    slFieldNames.addElement("latestRevision");
    slFieldNames.addElement("table");
    slFieldNames.addElement("Style");
    slFieldNames.addElement("program");
    slFieldNames.addElement("toolbar");
    slFieldNames.addElement("header");
    slFieldNames.addElement("selection");
    slFieldNames.addElement("StringResourceFileId");
    slFieldNames.addElement("parentOID");
    slFieldNames.addElement("SuiteDirectory");


    Enumeration eNumParameters = emxGetParameterNames(request);
    while( eNumParameters.hasMoreElements() ) {
        String strParamName = (String)eNumParameters.nextElement();
        String strParamValue = emxGetParameter(request, strParamName);

        if(!slFieldNames.contains(strParamName)){
%>
                <input type="hidden" name="<%=strParamName%>" value="<xss:encodeForHTMLAttribute><%=strParamValue%></xss:encodeForHTMLAttribute>" />
<%
        }
    }

    String CollectionName = emxGetParameter(request,"CollectionName");
if(CollectionName != null && !CollectionName.equals("")){
    session.putValue("CollectionName", CollectionName);
}

%>
        
    <input type="image" height="1" width="1" border="0" name="inputImage" value=""/>
<!-- the following div MUST come just before closing form tag -->

    <div id="divMore" style="display:none">
    </div>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script>
getTopWindow().pageControl.setType("<%= childTypeName %>");

getTopWindow().pageControl.setShowingAdvanced(false);
getTopWindow().getAdvancedSearch(true,window.document.all.divMore);
window.document.all.divMore.style.display = "";


     <%
        if (childTypeName != null && childTypeName.indexOf(",") != -1 )
        {
     %>
     //Following statement is added to remove html content form the divMore, when ever user selects more than one type
     //from the type chooser
    document.getElementById("divMore").innerHTML="";

        document.getElementById("divMore").style.visibility = "hidden";
        document.getElementById("divMore").style.display = "none";
    <% } else { %>

        document.getElementById("divMore").style.visibility = "Visible";
        document.getElementById("divMore").style.display = "content";
    <% } %>


    var strType="document.forms[0].txtTypeActual";
    var strDisType="document.forms[0].DisplayType";

<%
    String resourceBundle       = "emxLibraryCentralStringResource";
    String language            = request.getHeader("Accept-Language");
    String INVALID_INPUT_MSG    = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxDocumentCentral.ErrorMsg.InvalidInputMsg");
    String INVALID_CHAR_MSG     = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxDocumentCentral.ErrorMsg.InvalidCharMsg");
%>
    function doSearch()
    {
        var strSearchProcessPage = "<%=XSSUtil.encodeForJavaScript(context,strSearchProcessPage)%>";
        var theForm = document.forms[0];
        
        //Checking for Bad characters in Name field of SearchWithIn Dialog
        var nameField = document.getElementById("txtName");
        if(checkForFilteredSpecialChars(nameField,"<%=INVALID_INPUT_MSG%> ","\n<%=INVALID_CHAR_MSG%>") == false){
            turnOffProgress();
            return false;
        }
    try
    {
        var selectedType = document.SearchForm.txtTypeActual.value;
        theForm.action= strSearchProcessPage+"?txtTypeActual="+selectedType;
        theForm.submit();
    }
    catch(Exec)
    {
        alert(Exec)
    }
    }


    function submitToItself()
    {
    var strMainSearchDialogPage = "<%=XSSUtil.encodeForJavaScript(context,strMainSearchDialogPage)%>";
    var targetFrame = findFrame(getTopWindow(), "searchContent");
    var parentFrame = findFrame(getTopWindow(), "searchView");
    var selectedType = document.SearchForm.txtTypeActual.value;
    var objectId = document.SearchForm.txtTypeActualobjectId.value;
    var txtName = document.SearchForm.txtName.value;
    var txtRev = document.SearchForm.txtRev.value;
    var latestRevision = document.SearchForm.latestRevision.checked;
    var txtOwner = document.SearchForm.txtOwner.value;
    var txtDisplayOwner = document.SearchForm.txtDisplayOwner.value;
    var levelSelection = document.SearchForm.levelSelction.value;
    
    //encoding special characters in txtName 
    txtName = escape(txtName);
    txtName = txtName.replace("+","%2B"); // escape(String) will not encode + , so encoding explicitly
    
    var queryParam = "submitToItself=true&selfSubmit=true&txtTypeActual="+selectedType+"&objectId="+objectId+"&txtName="+txtName+"&txtRev="+txtRev+"&latestRevision="+latestRevision+"&txtOwner="+txtOwner+"&txtDisplayOwner="+txtDisplayOwner+"&levelSelction="+levelSelection;
    var startIndex = targetFrame.location.href.indexOf("submitToItself");   
    var targetURL = targetFrame.location.href;

    if(startIndex != -1)
    {
      targetURL = targetURL.substring(0, startIndex-1); 
    }
    startIndex = targetURL.indexOf("#");   
    if(startIndex != -1)
    {
      targetURL = targetURL.substring(0, startIndex-1); 
    }
    getTopWindow().pageControl.setType(document.SearchForm.txtTypeActual.value);
    
    //kp2 : Fix : 370023 start : setting targetURL with relative path
    startIndex = targetURL.indexOf("/documentcentral");
    targetURL = ".."+targetURL.substring(startIndex,targetURL.length);  
    // Fix : 370023 end
    
    getTopWindow().pageControl.setSearchContentURL(targetURL+"&"+queryParam);  
    parentFrame.location.href = parentFrame.location.href; 
    
    }
      function reload()
      {
        submitToItself();
      }
    // Script part to make Revision field null if Revision checkbox is checked while refreshing the page.
      if(document.forms[0].latestRevision.checked)
      {
        document.ContentSearchDocument.txtRev.value="";
        document.ContentSearchDocument.txtRev.readOnly=true;
      }

</script>

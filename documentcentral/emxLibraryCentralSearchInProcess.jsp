<%-- emxLibraryCentralSearchInProcess.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLibraryCentralSearchInProcess.jsp.rca 1.18 Wed Oct 22 16:02:25 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<html>
<head>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
</head>
<body>

<span id="formContent">
<form method="post" name="formSearch" target="_parent">

<%
        Enumeration enumParam = emxGetParameterNames(request);
        String strName = "";
        String strvalue = "";
        StringBuffer appendParams = new StringBuffer();
        while(enumParam.hasMoreElements())
        {
             strName = (String)enumParam.nextElement();
             if(strName != null)
             {
                strvalue = emxGetParameter(request,strName);
             }
             
%>
            <input type="hidden" name="<%=strName%>" value="<xss:encodeForHTMLAttribute><%=strvalue%></xss:encodeForHTMLAttribute>" />
            <%
        }

        String strObjectId = emxGetParameter(request,"objectId");
        String strSearchType = emxGetParameter(request,"levelSelction");
        if(strSearchType != null && strSearchType.equalsIgnoreCase("searchThisLevel"))
        {
            session.setAttribute("LCSearchType","Current Level");

        }else if(strSearchType != null && strSearchType.equalsIgnoreCase("searchSubLevel")){

            session.setAttribute("LCSearchType","All Levels");
        }
        DomainObject doObj = new DomainObject(strObjectId);
        String strObjType = doObj.getInfo(context,DomainObject.SELECT_TYPE);
        String strDefaultDocument = "";

        String strToolBar = PropertyUtil.getSchemaProperty(context, "menu_LCSearchClassifiedItemToolBar");
        String strToolBarAtLibrary = PropertyUtil.getSchemaProperty(context, "menu_LCSearchClassifiedItemAtLibraryToolBar");

%>
<input type="hidden" name="defaultType" value="<xss:encodeForHTMLAttribute><%=strDefaultDocument%></xss:encodeForHTMLAttribute>" />
<%
/// For the matchlist limit in query
//
    // Find the matchlist limit from the property file
    String strMatchlistLimit = "";
    strMatchlistLimit = EnoviaResourceBundle.getProperty(context,"eServiceLibraryCentral.SearchWithin.MatchlistLimit");
%>
    <input type="hidden" name="matchlistLimit" value="<xss:encodeForHTMLAttribute><%=strMatchlistLimit%></xss:encodeForHTMLAttribute>" />
<%


String strObjectState = emxGetParameter(request,"state");

appendParams.append("&objectId=");
appendParams.append(strObjectId);

appendParams.append("&levelSelction=");
appendParams.append(strSearchType);

appendParams.append("&matchlistLimit=");
appendParams.append(strMatchlistLimit);

appendParams.append("&suiteKey=");
appendParams.append("LibraryCentral");

appendParams.append("&state=");
appendParams.append(strObjectState);

String selectedTreeNode = emxGetParameter(request,"selectedTreeNode");

if(strObjType != null && strObjType.indexOf("Library") != -1)
{
    selectedTreeNode = "";
}

String searchWithinLevel = emxGetParameter(request,"searchWithinLevel");

String forwardURL=null;

/// For the matchlist limit in query
if(searchWithinLevel!=null && !"null".equals(searchWithinLevel) && !"".equals(searchWithinLevel) && "Library".equals(searchWithinLevel))
{
    forwardURL = "../common/emxTable.jsp?program=emxLibraryCentralUtil:getClassifiedItemsSearch&table=LCSearchClassificationListAtLibrary&selection=multiple&sortColumnName=Name&jsTreeID="+selectedTreeNode+"&sortDirection=ascending&toolbar=" + strToolBarAtLibrary + "&header=emxDocumentCentral.Common.PartsPageHeading&Style=dialog&CancelButton=true&CancelLabel=emxDocumentCentral.Button.Close&"+appendParams.toString();
}
else
{
    forwardURL = "../common/emxTable.jsp?program=emxLibraryCentralUtil:getClassifiedItemsSearch&table=LCSearchClassificationList&selection=multiple&sortColumnName=Name&jsTreeID="+selectedTreeNode+"&sortDirection=ascending&toolbar=" + strToolBar + "&header=emxDocumentCentral.Common.PartsPageHeading&Style=dialog&CancelButton=true&CancelLabel=emxDocumentCentral.Button.Close&"+appendParams.toString();
}


%>
</form>
</span>

<script>
try
{
    document.forms[0].action = "<xss:encodeForJavaScript><%=forwardURL%></xss:encodeForJavaScript>";
    window.document.forms["formSearch"].submit();
}
catch(excpetionWhileWriting)
{   
    alert(excpetionWhileWriting);
}



</script>
</body>
</html>


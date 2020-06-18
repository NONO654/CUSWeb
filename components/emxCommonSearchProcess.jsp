<%--  emxCommonSearchProcess.jsp  -

   Performs the action of connecting the objects by the given relationship

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonSearchProcess.jsp.rca 1.8 Wed Oct 22 16:17:54 2008 przemek Experimental przemek $";
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file  ="../emxContentTypeInclude.inc" %>

<%@page import="com.matrixone.apps.common.*"%>

<html>
  <body>
    <script language="javascript" src="../emxUIPageUtility.js"></script>
    <form name="searchForm" method="post">

<%
String strActionURL = emxGetParameter(request,"ActionURL");
String uiType = emxGetParameter(request,"uiType");
String SubmitURL = emxGetParameter(request,"SubmitURL");
String submitLabel = emxGetParameter(request,"submitLabel");
String cancelLabel = emxGetParameter(request,"cancelLabel");
Enumeration enumParamNames = emxGetParameterNames(request);
while(enumParamNames.hasMoreElements())
{
      String paramName = (String) enumParamNames.nextElement();
      String paramValues[]= emxGetParameterValues(request, paramName);
        if (paramValues != null) {
                for (int iCount=0; iCount<paramValues.length; iCount++) {

                %>
                <input type="hidden" name="<xss:encodeForHTMLAttribute><%=paramName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=paramValues[iCount]%></xss:encodeForHTMLAttribute>"/>
                <%
                }

        }
}

String errMsg = "";

try{

//Date validation
String dateBegin        = (String) emxGetParameter(request,"CreatedAfter");
String dateEnd          = (String) emxGetParameter(request,"CreatedBefore");

if(dateEnd==null || "".equals(dateEnd) || "null".equals(dateEnd)) {
   dateEnd = null;
}
if(dateBegin==null || "".equals(dateBegin) || "null".equals(dateBegin)) {
   dateBegin = null;
}

java.text.DateFormat df = java.text.DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), request.getLocale());
df.setLenient(false);

java.util.Date formattedDateBegin = null;
if(dateBegin != null)
formattedDateBegin = df.parse(dateBegin.trim());

java.util.Date formattedDateEnd = null;
if(dateEnd != null)
formattedDateEnd = df.parse(dateEnd.trim());

if(dateBegin != null && dateEnd != null && formattedDateEnd.compareTo(formattedDateBegin) <= 0)
{
    errMsg = EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(), "emxComponents.Common.CreatedBeforePrecedesCreateAfter"); 
    throw new Exception(errMsg);
}

}catch(Exception e)
{
    if(errMsg.trim().length() <= 0)
    errMsg = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.Common.InvalidDate");

    emxNavErrorObject.addMessage(errMsg);
    //throw new Exception(errMsg);
%>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script language="javascript">
document.searchForm.action = "../components/emxCommonSearch.jsp";
document.searchForm.submit();
</script>
    </form>
  </body>
</html>
<%
//return;
}
%>
<script language="javascript">
<% if ( strActionURL!=null && !strActionURL.equals("") ){
%>
    document.searchForm.action = "<%=XSSUtil.encodeForJavaScript(context, strActionURL)%>";
<%
}
else if("Indented".equalsIgnoreCase(uiType)){
%>
document.searchForm.action = "../common/emxIndentedTable.jsp?submitURL=<%=XSSUtil.encodeForJavaScript(context, SubmitURL)%>&submitLabel=<%=XSSUtil.encodeForURL(context, submitLabel)%>&cancelLabel=<%=XSSUtil.encodeForURL(context, cancelLabel)%>";
<% }
else{
%>
document.searchForm.action = "../common/emxTable.jsp";
<% }%>
document.searchForm.submit();
</script>

    </form>
  </body>
</html>

<%--  emxpartWhereUsedECOPostProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<jsp:useBean id="createBean"
    class="com.matrixone.apps.framework.ui.UIForm" scope="session" />

<%
String newObjectId = emxGetParameter(request, "newObjectId");
String strObjectId = emxGetParameter(request, "OBJId");
String suiteKey = emxGetParameter(request,"suiteKey");

HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
String Relationship = (String) requestMap.get("Relationship");
String checkedButtonValue = (String) requestMap.get("checkedButtonValue");
String checkboxValue = (String) requestMap.get("checkboxValue");
String ebomSubstituteChange = (String)session.getAttribute("ebomSubstituteChange");
if (ebomSubstituteChange != null && ebomSubstituteChange.equals("true"))
{
%>
<script language="Javascript">
//XSSOK
window.parent.frames.location.href	=  "../engineeringcentral/emxpartRaiseAnECOAssignDetailsFS.jsp?ecrId=<%=XSSUtil.encodeForJavaScript(context,newObjectId)%>&prevmode=false&Relationship=<%=XSSUtil.encodeForJavaScript(context,Relationship)%>&checkboxValue=<%=XSSUtil.encodeForJavaScript(context,checkboxValue)%>&checkedButtonValue=<%=XSSUtil.encodeForJavaScript(context,checkedButtonValue)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>&warn=true&selectedType=<%=XSSUtil.encodeForJavaScript(context,newObjectId)%>&Create=Create&suiteKey=<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>";
</script>
<%
}
else
{
%>
<script language="Javascript">
//XSSOK
window.parent.frames.location.href	=  "../engineeringcentral/emxpartRaiseAnECOAssignDetailsFS.jsp?ecrId=<%=XSSUtil.encodeForJavaScript(context,newObjectId)%>&prevmode=false&Relationship=<%=XSSUtil.encodeForJavaScript(context,Relationship)%>&checkboxValue=<%=XSSUtil.encodeForJavaScript(context,checkboxValue)%>&checkedButtonValue=<%=XSSUtil.encodeForJavaScript(context,checkedButtonValue)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>&selectedType=<%=XSSUtil.encodeForJavaScript(context,newObjectId)%>&Create=Create&suiteKey=<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>";
</script>
<%
}
%>

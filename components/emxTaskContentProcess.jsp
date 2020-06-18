<%--  emxTaskContentProcess.jsp - Removes Content from the route .
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxTaskContentProcess.jsp.rca 1.6 Wed Oct 22 16:18:31 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%
    String objectId   = emxGetParameter(request, "objectId");
    String fromPage   = emxGetParameter(request,"fromPage");
    String selectStr = "from["+DomainConstants.RELATIONSHIP_ROUTE_TASK+"].to.id";
    String suiteKey = emxGetParameter(request,"suiteKey");
    DomainObject taskObject = DomainObject.newInstance(context,objectId);
    objectId = taskObject.getInfo(context,selectStr);
    String folderURL = "emxCommonSelectWorkspaceFolderDialogFS.jsp";
    boolean bTeam = FrameworkUtil.isSuiteRegistered(context,"featureVersionTeamCentral",false,null,null);

    if(fromPage.equals("AddContent"))
    {
%>
<script language="javascript">
    emxShowModalDialog("emxRouteContentSearchDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&multiSelect=true&suiteKey=<%= XSSUtil.encodeForURL(context, suiteKey)%>&targetSearchPage=emxRouteAddContentProcess.jsp",750,500);
</script>
<%
}
else  if(fromPage.equals("Upload") && bTeam ) {
%>
<script language="javascript">
//XSSOK
document.location.href = '../components/emxCommonDocumentPreCheckin.jsp?showDescription=required&JPOName=emxRouteDocumentBase&showFolder=required&folderURL=<%=folderURL%>&parentRelName=relationship_VaultedDocuments&objectAction=create&routeContentId=<%=XSSUtil.encodeForURL(context, objectId)%>&parentId=RouteWizard';
</script>
<%
}
%>

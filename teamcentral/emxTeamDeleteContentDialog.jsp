<%--  emxTeamDeleteContentDialog.jsp - Remove Event, Publish/Subscribe, Folder and Route Objects

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamDeleteContentDialog.jsp.rca 1.14 Wed Oct 22 16:05:52 2008 przemek Experimental przemek $
--%>
<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxTeamCommonUtilAppInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%

  String folderId   = null;
  String routeId    = null;

  String objectId   = emxGetParameter(request,"objectId");
  String sIds       = emxGetParameter(request,"contentId");
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");

  String sTypeRoute = Framework.getPropertyValue( session, "type_Route");
  boolean bActivateDSFA= FrameworkUtil.isSuiteRegistered(context,"ActivateDSFA",false,null,null);

  BusinessObject boGeneric = new BusinessObject(objectId);
  boGeneric.open(context);
  String sTypeName = boGeneric.getTypeName();
  boGeneric.close(context);

  Access access = boGeneric.getAccessMask(context);
  boolean bAddRemoveAccess = new AccessUtil().hasAddRemoveAccess(access);
  
  String sMessage1 = "";
  String sMessage2 = "";
  String sMessage4 = "";
  String sMessage5 = "";

  if ( sTypeName.equals(sTypeRoute) ) {
    sMessage1  = i18nNow.getI18nString("emxTeamCentral.RouteContentDelete.FolderDeleteMessage","emxTeamCentralStringResource",sLanguage);
    sMessage2  = i18nNow.getI18nString("emxTeamCentral.RouteContentDelete.DatabaseMessage","emxTeamCentralStringResource",sLanguage);
  } else {
    sMessage1  = i18nNow.getI18nString("emxTeamCentral.DeleteContent.FolderDeleteMessage","emxTeamCentralStringResource",sLanguage);
    sMessage2  = i18nNow.getI18nString("emxTeamCentral.DeleteContent.DatabaseMessage","emxTeamCentralStringResource",sLanguage);
    if(bActivateDSFA){
        sMessage2  += " "+i18nNow.getI18nString("emxTeamCentral.DeleteContent.VCDatabaseMessage","emxTeamCentralStringResource",sLanguage);
      }
  }

  sMessage4  = i18nNow.getI18nString("emxTeamCentral.DeleteContent.RestoreMessage","emxTeamCentralStringResource",sLanguage);
  if(bActivateDSFA){
     sMessage4 += " "+i18nNow.getI18nString("emxTeamCentral.DeleteContent.VCRestoreMessage","emxTeamCentralStringResource",sLanguage);
  }

  sMessage5  = i18nNow.getI18nString("emxTeamCentral.DeleteContent.HeadingMessage","emxTeamCentralStringResource",sLanguage);
%>

<script language="Javascript" type="text/javascript">

  function showEditDialogPopup() {
    document.deleteform.action='emxTeamDeleteContent.jsp?contentId=<%=XSSUtil.encodeForURL(context, sIds)%>&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>';
    document.deleteform.submit();
  }
  function closeWindow() {
    parent.window.closeWindow();
    return;
  }

</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<form name="deleteform" id="deleteform" method="post">
  <script>
  	addStyleSheet("emxUIDefault");
  	addStyleSheet("emxUIForm");
  </script>	

  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />

  <table class="form">
  	<tr>
  		<td class="heading">
  			<%= sMessage5 %>
  		</td>
  	</tr>
  	<tr>
  		<td>
  			<table>
  				<tr>
  					<td>
  						<input type="radio" name="remove" id="remove" value="leaveIn" checked />&nbsp;
  					</td>
  					<td style="padding:5px;">
  						<%= sMessage1 %>
  					</td>
  				</tr>
  				<tr>
  					<td>
  						<input type="radio" name="remove" id="remove" value="takeOut" />&nbsp;
  					</td>
  					<td style="padding:5px;">
  						<%= sMessage2 %>
  					</td>
  				</tr>
  				<tr>
  					<td>
  						<input type="radio" name="remove" id="remove" value="prior" />&nbsp;
  					</td>
  					<td style="padding:5px;">
  						<%= sMessage4 %>
  					</td>
  				</tr>
  			</table>
  		</td>
  	</tr>
  </table>
</form>

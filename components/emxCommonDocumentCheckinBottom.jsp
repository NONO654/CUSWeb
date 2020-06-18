<%-- used for Checkin of file into Document Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%
  request.setAttribute("contentPageIsDialog", "true");
%>
<%@include file = "emxComponentsCheckin.inc"%>
<%
  Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");
  String objectAction = (String)emxCommonDocumentCheckinData.get("objectAction");
%>
<div id="divPageFoot" >
<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
<tr>
			<td class="functions">
		    	<span class="info-text"><emxUtil:i18n localize="i18nId">emxComponents.Common.AppletLabel</emxUtil:i18n></span>
</td>
			<td class="buttons inline">
<%
     if ( CommonDocument.OBJECT_ACTION_CREATE_MASTER.equalsIgnoreCase(objectAction) || CommonDocument.OBJECT_ACTION_CREATE_CHECKIN.equalsIgnoreCase(objectAction) )
      {
%>
			        <a onclick="javascript:parent.frames[1].goBack()"><button class="btn-default"><emxUtil:i18n localize="i18nId">emxComponents.Common.AppletDialogPrevious</emxUtil:i18n></button></a>
<%
      }
%>
			     <a onclick="javascript:parent.frames[1].checkinFile()"><button class="btn-primary"><emxUtil:i18n localize="i18nId">emxComponents.Common.AppletDialogUpload</emxUtil:i18n></button></a>
			     <a onclick="javascript:parent.frames[1].checkinCancel()"><button class="btn-default"><emxUtil:i18n localize="i18nId">emxComponents.Common.AppletDialogCancel</emxUtil:i18n></button></a>
</td>
</tr>
</table>
</div>


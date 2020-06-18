<%--  emxTeamWorkspaceTemplateCreateProcess.jsp  --  
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of DS,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxWorkspaceTemplateCreation.jsp.rca 1.2.2.1.7.5 Wed Oct 22 16:18:29 2008 przemek Experimental przemek $
 --%>

 
 <%@include file = "../common/emxNavigatorInclude.inc"%>
 <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
 <%
 String objectId = emxGetParameter(request, "objectId");
 String portalMode = emxGetParameter(request, "portalMode");
 String parsedHeader = emxGetParameter(request, "parsedHeader");
 
 
 %>
 <script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUISlideIn.js"></script>
 <script language="javascript">
		var contentURL = "../common/emxForm.jsp?form=TMCSaveAsWorkspaceTemplate&formHeader=emxTeamCentral.WorkspaceTemplateSaveDialog.Heading&HelpMarker=emxhelpsaveworkspaceastemplate&mode=edit&findMxLink=false&postProcessJPO=emxWorkspaceTemplate:saveAsTemplateProcess&submitAction=refreshCaller&preProcessJavaScript=toggleTemplateNameEdit&suiteKey=TeamCentral&openerFrame=detailsDisplay&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>";
		//XSSOK
		getTopWindow().showSlideInDialog(contentURL,true);
	
</script>


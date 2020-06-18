<%--
   emxCommonUsageCreateDialogFS.jsp
   Copyright (c) 1992-2018  Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonUsageDialogFS.jsp.rca 1.3.7.5 Wed Oct 22 16:18:18 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<%@ page import = "com.matrixone.apps.common.Download"%>

<%
  String tableBeanName = null;
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.removeDialogWarning();
  fs.setBeanName(tableBeanName);

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
	StringBuffer sbContentURL = new StringBuffer("emxCommonUsageDialog.jsp");

  String sUrl = emxGetParameter(request,"typename");
	String strRelId   = emxGetParameter(request,"relId");
  String strDocumentName = emxGetParameter(request,"documentName");
  String strDocumentId = emxGetParameter(request,"documentId");
  String strDownloadId = emxGetParameter(request,"downloadId");
  String strDownloadForwardURL = emxGetParameter(request,"downloadForwardURL");
  String strPartId = emxGetParameter(request, "trackUsagePartId");
  String strDocIds = emxGetParameter(request, "docIds");
  String strRefreshContent = emxGetParameter(request, "refreshContent");
  
  // add these parameters to each content URL, and any others the App needs
	sbContentURL.append("?typename="+sUrl);
	sbContentURL.append("&documentName="+XSSUtil.encodeForURL(context,strDocumentName));
	sbContentURL.append("&documentId="+strDocumentId);
	sbContentURL.append("&downloadId="+strDownloadId);
	sbContentURL.append("&downloadForwardURL="+strDownloadForwardURL);
	sbContentURL.append("&trackUsagePartId="+strPartId);
	sbContentURL.append("&docIds="+strDocIds);
	sbContentURL.append("&refreshContent="+strRefreshContent);
	sbContentURL.append("&checkPart="+emxGetParameter(request, "checkPart"));

  // Page Heading - Internationalized
  String PageHeading = "emxComponents.Download.EnterUsageInformation";
  String HelpMarker = "emxhelpusagecreate";

	String strCheckForClassifiedPart = emxGetParameter(request, "checkPart");
	if("true".equalsIgnoreCase(strCheckForClassifiedPart))
	{

		if(strDocumentId != null && strDocumentId.indexOf("|") != -1)
		{
			strDocIds = strDocumentId.substring(strDocumentId.indexOf("|")+1);
			strDocumentId = strDocumentId.substring(0, strDocumentId.indexOf("|"));
			if("".equals(strDocumentId))
			{
				strDocumentId = strDocIds;
			}
		}

		DomainObject dom = new DomainObject(strPartId);
		String isClassifiedPart = dom.getInfo(context, "to["+DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM+"]" );
		if(!"true".equalsIgnoreCase(isClassifiedPart))
		{
			%>
				<script>getTopWindow().document.location.href =  "<%=XSSUtil.encodeForURL(context, strDownloadForwardURL)%>";</script>
			<%
				return;
		}
		Map usageMap = Download.getUsageIds(context, strPartId);
		strRelId = (String)usageMap.get(strDocumentId);
	}


	if(strRelId != null)
  {
	  PageHeading = "emxComponents.Download.EditUsageInformation";
	  HelpMarker = "emxhelpusageedit";
	}else if(strPartId == null)
	{
		PageHeading = "emxComponents.Download.SelectPart";
		HelpMarker = "emxhelpusageedit";	
  }

	sbContentURL.append("&relId="+strRelId);

  fs.removeDialogWarning();
	fs.initFrameset(PageHeading, HelpMarker, sbContentURL.toString(), false, true, false, false);

  fs.createCommonLink("emxComponents.Button.Done",
                      "updateUsage()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "getTopWindow().closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);
  fs.writePage(out);
%>

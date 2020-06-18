<%--
  emxCommonDocumentCreatePostProcess.jsp

  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
--%>

<%@ page import = "matrix.db.*,
                   matrix.util.*,
                   com.matrixone.servlet.*,
                   java.util.*,
                   java.io.*,
                   java.net.*,
                   java.text.*" errorPage="emxComponentsError.jsp"%>

<%@ page import = "com.matrixone.apps.common.*,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>

<%@include file = "../emxRequestWrapperMethods.inc"%>   
                
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>


<%
	String newObjectId = emxGetParameter(request, "newObjectId");
	String targetLocation = emxGetParameter(request, "targetLocation");
	String folderId = emxGetParameter(request, "objectId");
	matrix.db.Context context = (matrix.db.Context)request.getAttribute("context");

	// Link to folder
	String sRelType = "Vaulted Objects";
	CommonDocument cDoc = new CommonDocument(newObjectId);
	DomainRelationship dRel = cDoc.addRelatedObject(context, new RelationshipType(sRelType), true, folderId);
	String  relId = cDoc.getInfo(context,"relationship[Vaulted Objects].id");
	//System.out.println(relId);

        // Set "Title" if it is empty
	StringList objectList= new StringList();
	objectList.add(CommonDocument.SELECT_NAME);    
	Map map = cDoc.getInfo(context, objectList);    
	String name=(String)map.get(CommonDocument.SELECT_NAME);
	String title = cDoc.getAttributeValue(context, "Title");
	if(title == null || title.isEmpty()) {
	    cDoc.setAttributeValue(context, "Title", name);
	}
	
	boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
	String csrfTokenName = "";
	String csrfTokenValue = "";
	if(csrfEnabled)
	{
	  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
	  csrfTokenName = (String)csrfTokenMap.get(ENOCsrfGuard.CSRF_TOKEN_NAME);
	  csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
	}
	Map emxCommonDocumentCheckinData = new HashMap();
	emxCommonDocumentCheckinData.put("objectAction", "checkin");
	session.setAttribute("emxCommonDocumentCheckinData", emxCommonDocumentCheckinData);	
	String processPage = "/components/enoCDMCheckinProcess.jsp";
	String targetPage = "/components/emxComponentsCheckinSuccess.jsp";
    String errorPage = "/components/emxComponentsError.jsp";
	String store = "STORE";	
    Map checkinURLMap = DocumentUtil.getFCSURLInfo(context, store.trim(), 50, processPage, targetPage, errorPage, request, response);
    String checkinURL = (String)checkinURLMap.get("action");
    String ticketStr = (String)checkinURLMap.get("ticket");
    String jobTicket = (String)checkinURLMap.get("jobTicket");
    String failurePageName = (String)checkinURLMap.get("failurePageName");
    String failurePageValue = (String)checkinURLMap.get("failurePageValue");
	String defaultFormat = Document.FORMAT_GENERIC;
	defaultFormat = XSSUtil.encodeForHTMLAttribute(context, defaultFormat); 
%>

<script>
	var checkinUrl = "<%=checkinURL%>";
	var defaultFormat = "<%=defaultFormat%>";
	var files = getTopWindow().files_to_checkin;
	var n;
	if(files != undefined)
		n = files.length;
	else
		n = 0;
	var objectId = "<%=newObjectId%>";
	var jobTicketName = '<%=jobTicket%>';
	var jobTicketValue = '<%=ticketStr%>';
	var failurePageName ="<%=failurePageName%>";
	var failurePageValue = "<%=failurePageValue%>";
	var store ="<%=store%>";
	var csrfEnabled = "<%=csrfEnabled%>";
	var csrfTokenNameName = "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>";
	var csrfTokenNameValue = "<%=csrfTokenName%>";
	var csrfTokenName = csrfTokenNameValue;
	var csrfToken = "<%=csrfTokenValue%>";

	var xhr = new XMLHttpRequest();
	var formData = new FormData();
	if (csrfEnabled){
		formData.append(csrfTokenNameName, csrfTokenNameValue);
		formData.append(csrfTokenName, csrfToken);
	}
	formData.append("noOfFiles", n);
	formData.append("parentId", "");
	formData.append("objectId", objectId);
	formData.append(jobTicketName, jobTicketValue);
	formData.append(failurePageName, failurePageValue);
	formData.append("store", store);
	if(files != undefined){
		jQuery.each(files, function(i, file) {
			formData.append("comments" + i, file.comment);
			formData.append("bfile" + i, file); 
			formData.append("fileName" + i, file.name);
			formData.append("format" + i, defaultFormat);
		});
	}
	if(n == 0) {
		parent.isCheckinRefreshFinished = true;
	}
	xhr.open("POST", checkinUrl, false);
	xhr.send(formData);
	var result = xhr.responseText;
	if(!parent.document.getElementById('checkinFrame')){
		var elem = parent.document.createElement('iframe');
		elem.id = 'checkinFrame';
		parent.document.body.appendChild(elem);
	}
	var ifrm = parent.document.getElementById('checkinFrame');
	ifrm = ifrm.contentWindow ? ifrm.contentWindow :
	ifrm.contentDocument.document ? ifrm.contentDocument.document :  ifrm.contentDocument;
	ifrm.document.open();
	ifrm.document.write(result);
	ifrm.document.close();
	getTopWindow().files_to_checkin = null;

	var frameHandle = emxUICore.findFrame(getTopWindow(),'WorkspaceContent');
	var oXM = emxUICore.findFrame(getTopWindow(),'WorkspaceContent').sbPage.oXML;
	var rowID = emxUICore.selectSingleNode(oXM, "/mxRoot/rows//r[@o = '<%=folderId%>']");
	if(rowID){
		var selectSBrows = [];selectSBrows.push(rowID.getAttribute('id'));
		var strXml="<mxRoot><action>add</action><data status='committed'><item oid= '<%=newObjectId%>' relId='<%=relId%>' pid='<%=folderId%>'/></data></mxRoot>";
		frameHandle.emxEditableTable.addToSelected(strXml,selectSBrows);	
	}
</script>

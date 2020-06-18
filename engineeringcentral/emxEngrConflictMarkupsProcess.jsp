<%--  emxEngrConflictMarkupsProcess.jsp    -  Resolve Markup Conflict Page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file = "emxDesignTopInclude.inc"%>
<%@ include file = "emxEngrVisiblePageInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
	String suiteKey = emxGetParameter(request,"suiteKey");
	String relId = emxGetParameter(request,"relId");
	String objectId = emxGetParameter(request,"objectId");
	String parentOID = emxGetParameter(request,"parentOID");
	
	String strKey = emxGetParameter(request,"key");
	String strLevel = emxGetParameter(request,"level");
	String strMarkupName = emxGetParameter(request,"checkedValue");
	String strFieldId = emxGetParameter(request,"fieldId");
	
	String strXMLInfo = (String)session.getAttribute(strFieldId);//emxGetParameter(request,strFieldId);
	
	Hashtable htConflicts = (Hashtable) session.getAttribute("ConflictList");
	htConflicts.remove(strKey);
	session.setAttribute("ConflictList", htConflicts);
		
	//Cleanup the session
	try {
		Integer strCnt = (Integer)session.getAttribute("count");
		int count = strCnt.intValue();
		for(int i=0; i<count; i++){
			session.removeAttribute("fieldId" + i);
		}
	} catch(Exception ex) {
		//donothing
	}
%>
<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
	var callback = eval(getTopWindow().getWindowOpener().emxEditableTable.prototype.loadMarkUpXML);
	//XSSOK
	var oxmlstatus = callback('<%=XSSUtil.encodeForJavaScript(context,strXMLInfo)%>', "true");
	
	var callback2 = eval(getTopWindow().getWindowOpener().emxEditableTable.prototype.updateXMLByRowId);
	//XSSOK
	var status2 = callback2('<%=XSSUtil.encodeForJavaScript(context,strLevel)%>', '<c a=\"&#160;\"></c>', '2');
	
	parent.closeWindow();
</script>


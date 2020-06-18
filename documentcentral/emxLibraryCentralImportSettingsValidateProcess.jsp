<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "$Id: emxLibraryCentralmportAG.jsp.jsp.rca 1.2.3.2 Wed Oct 22 16:02:42 2008 przemek Experimental przemek $";
   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxMultipleClassificationUtils.inc" %>
<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript">
</script>
<jsp:useBean id="formBean" scope="page" class="com.matrixone.apps.common.util.FormBean"/>
<%@ page import="javax.xml.parsers.DocumentBuilder"%>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory"%>

<%
	try{
		formBean.processForm(session, request);
		java.io.File importFile = (java.io.File) formBean.getElementValue("file");
		String approver="";
		String vault="";
		String owner="";
		Map importSettingMap=LibraryCentralCommon.getImportSettings(context);
		DocumentBuilderFactory domBuilderFac=DocumentBuilderFactory.newInstance();
        //XXE changes
        domBuilderFac.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        domBuilderFac.setFeature("http://xml.org/sax/features/external-general-entities", false);
        domBuilderFac.setFeature("http://xml.org/sax/features/external-parameter-entities",false);
		DocumentBuilder docBuilder=domBuilderFac.newDocumentBuilder();
		domBuilderFac.setNamespaceAware(true);
		org.w3c.dom.Document document=docBuilder.parse(new FileInputStream(new java.io.File(importFile.getPath())));
		/*if(importSettingMap.get(LibraryCentralConstants.SELECT_VAULT).equals(false))
			vault=new ClassificationUtil().getVaultFromXML(context,document);*/
		if(importSettingMap.get(LibraryCentralConstants.SELECT_OWNER).equals(false))
			owner=new ClassificationUtil().getOwnerFromXML(context,document);
		if(importSettingMap.get(LibraryCentralConstants.ATTRIBUTE_APPROVER).equals(false)&&
			document.getDocumentElement().getNodeName().equals(LibraryCentralConstants.DOCUMENT_LIBRARY_ELEMENT_NAME))
			approver=new ClassificationUtil().getApproverFromXML(context,document);

%>
<script language="javascript">
var vault="<xss:encodeForJavaScript><%=vault%></xss:encodeForJavaScript>";
var owner="<xss:encodeForJavaScript><%=owner%></xss:encodeForJavaScript>";
var approver="<xss:encodeForJavaScript><%=approver%></xss:encodeForJavaScript>";
if(owner!="")
	getTopWindow().slideInFrame.pagecontent.document.getElementById("ownerfieldId").value=owner;
/*if(vault!="")
	getTopWindow().slideInFrame.pagecontent.document.getElementById("vaultfieldId").value=vault;*/
if(approver!="")		
	getTopWindow().slideInFrame.pagecontent.document.getElementById("approverfieldId").value=approver;
</script>
<%	}catch(Exception err){
	err.printStackTrace();
}

%>

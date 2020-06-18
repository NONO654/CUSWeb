
<%--
	Copyright (c) 1993-2018 Dassault Systemes.
	All Rights Reserved.
	This program contains proprietary and trade secret information of
	Dassault Systemes.
	Copyright notice is precautionary only and does not evidence any actual
	or intended publication of such program
	RemoveCommonGroupDialog.jsp
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxValidationInclude.inc" %>

<%@page import="matrix.util.StringList"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<%

 try{
	 String strObjectIdOId = emxGetParameter(request, "objectId");
     StringTokenizer strObjectTokenizer = new StringTokenizer(strObjectIdOId,",");
     
     strObjectTokenizer.nextToken(); //Context LF Id
     String strProductId = strObjectTokenizer.nextToken();  //Context Product Id
     String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
     StringTokenizer strTokenizer = new StringTokenizer(arrTableRowIds[0],"|");
     String strRelId = strTokenizer.nextToken();
     DomainRelationship domRel = new DomainRelationship(strRelId);
     StringList reLSelects = new StringList(2);
     reLSelects.addElement(DomainRelationship.SELECT_FROM_ID);
     reLSelects.addElement(DomainRelationship.SELECT_TO_ID);

     Hashtable htable = (Hashtable)domRel.getRelationshipData(context ,reLSelects);

     StringList strTechFId = (StringList)htable.get(DomainRelationship.SELECT_FROM_ID);
     StringList strDVId = (StringList)htable.get(DomainRelationship.SELECT_TO_ID);
     String strurl = "../common/emxIndentedTable.jsp?program=emxCommonValues:getCommonGroupContextInCGListPage&showRMB=false&expandProgram=emxCommonValues:getCommonGroupListInSB&objectCompare=false&table=FTRCommonGroupListTable&selection=multiple&toolbar=FTRCommonGroupStructureBrowserActionToolbarMenu&ProductId="+strProductId+"&relId="+strRelId+"&parentOID="+strTechFId.get(0)+"&objectId="+strDVId.get(0)+"&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview&massUpdate=false";
     %>
     <SCRIPT LANGUAGE="JavaScript">
     //XSSOK -JSP is DEPRECATED- will be removed as part of JSP REDUCTION
         showChooser("<%=strurl%>",700,700);         
     </SCRIPT>
     <%
 
 }
 catch(Exception e)
 {
   e.printStackTrace();
   session.putValue("error.message", e.getMessage());
   //emxNavErrorObject.addMessage(e.toString().trim());
 }// End of main Try-catck block  
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

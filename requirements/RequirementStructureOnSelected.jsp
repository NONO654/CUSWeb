<%--
	RequirementStructureOnSelected.jsp

	Copyright (c) 1999-2018 Dassault Systemes, Inc.
	All Rights Reserved.
	This program contains proprietary and trade secret information of MatrixOne,
	Inc.  Copyright notice is precautionary only
	and does not evidence any actual or intended publication of such program

	static const char RCSID[] = "$Id: /ENORequirementsManagementBase/CNext/webroot/requirements/RequirementStructureOnSelected.jsp 1.2.2.1.1.1 Wed Oct 29 22:20:01 2008 GMT przemek Experimental$";
	--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
--%>
 <%-- Include JSP for error handling --%>
    <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

    <%-- Common Includes --%>
    <%@include file = "emxProductCommonInclude.inc" %>
    <%@include file = "../emxUICommonAppInclude.inc"%>
    <%@include file = "../emxTagLibInclude.inc"%>
<%	
    String strRow   = emxGetParameter(request, "emxTableRowId");
	String selectedReqFilter = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "DefaultReqFilter");
	String DefaultReqSelectedTable = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "DefaultReqTable");
	String ContentEditorOption = "";
	String tableView = "";
 	String[] tokens = strRow.split("[|]");
    String strRequirementId = (tokens.length > 1? tokens[1]: tokens[0]);
    
    if(selectedReqFilter != null)
    {  
    	//StructureBrowserOption = "&expandProgram=" + selectedReqFilter;
    	ContentEditorOption = "&selectedProgram=" + selectedReqFilter;	
    }
    if(DefaultReqSelectedTable != null)
    {
    	tableView = "&selectedTable=" + DefaultReqSelectedTable;
    }
%>	
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
 <script language="javascript" type="text/javaScript">
   		
		var strURL ="../common/emxIndentedTable.jsp?expandProgramMenu=RMTRequirementStructureProgramFilterMenu&tableMenu=RMTRequirementTableFilterMenu&toolbar=RMTRequirementStructureBrowserToolbar&selection=multiple&HelpMarker=emxhelprequirementstructurebrowser&editLink=true&header=emxRequirements.ActionLink.RequirementStructureBrowser&suiteKey=Requirements&objectId="+'<xss:encodeForJavaScript><%=strRequirementId%></xss:encodeForJavaScript>';
		strURL += "<xss:encodeForJavaScript><%=ContentEditorOption%></xss:encodeForJavaScript>";
		strURL += "<xss:encodeForJavaScript><%=tableView%></xss:encodeForJavaScript>";
		getTopWindow().location.href = strURL;

 </script>

<%-- emxFormTableInclude.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormTableInclude.jsp.rca 1.10 Wed Oct 22 15:48:00 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
    // timeStamp to handle the business objectList
    String timeStamp = Request.getParameter(request, "timeStamp");
    String header = "";
    String objectId = Request.getParameter(request, "objectId");
    String relId = Request.getParameter(request, "relId");
    String reportFormat = Request.getParameter(request, "reportFormat");
    String printerFriednly = Request.getParameter(request, "printerFriednly");
    String isEmbeddedTable=Request.getParameter(request, "isEmbeddedTable");

    Vector userRoleList = PersonUtil.getAssignments(context);

    // Process the request object to obtain the table data and set it in Table bean
    if ( tableBean.getTableData(timeStamp) == null )
        tableBean.setTableData(context, pageContext,request, timeStamp, userRoleList);

    String sortColumnName ="";
    String sortDirection = "";
    if(UIUtil.isNotNullAndNotEmpty(Request.getParameter(request, "sortColumnName"))){
    	sortColumnName=Request.getParameter(request, "sortColumnName");
    }
	if(UIUtil.isNotNullAndNotEmpty(Request.getParameter(request, "sortDirection"))){
		sortDirection=Request.getParameter(request, "sortDirection");
    }
    HashMap tableControlMap = tableBean.getControlMap(timeStamp);
    tableControlMap.put("SortColumnName",sortColumnName);
    tableControlMap.put("SortDirection",sortDirection);
    // System.out.println("tableControlMap : " + tableControlMap);
    header = tableBean.getPageHeader(tableControlMap);
    // Sort the table data
    
    if (sortColumnName != null && sortColumnName.trim().length() > 0 && (!(sortColumnName.equals("null"))) )
        tableBean.sortObjects(context, timeStamp);
%>
<!-- //XSSOK -->
<jsp:include page = "emxTableDataInclude.jsp" flush="true"> <jsp:param name="timeStamp" value="<%=timeStamp%>"/> <jsp:param name="reportFormat" value="<%=XSSUtil.encodeForURL(context, reportFormat)%>"/>
<jsp:param name="isEmbeddedTable" value="<%=isEmbeddedTable%>"/></jsp:include>

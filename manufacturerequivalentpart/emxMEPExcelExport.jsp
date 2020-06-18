<%-- emxMEPExcelExport.jsp
Copyright (c) 1992-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of MatrixOne,Inc.
Copyright notice is precautionary only
and does not evidence any actual or intended publication of such program

static const char RCSID[] = $Id: emxFreezePaneExport.jsp.rca 1.15 Wed Oct 22 15:49:01 2008 przemek Experimental przemek $
--%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>

<%@page import="com.matrixone.apps.manufacturerequivalentpart.ExportToExcelUtil"%>

<%@ page
	import="matrix.db.*,matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*,com.matrixone.apps.domain.*,java.io.*,java.util.*"%>
<%@include file="../emxTagLibInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxFrameworkStringResource"
	locale='<xss:encodeForHTMLAttribute><%= request.getHeader("Accept-Language") %></xss:encodeForHTMLAttribute>' />
<jsp:useBean id="indentedTableBean"
	class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />


<%

	ExportToExcelUtil eObj = new ExportToExcelUtil();

	//Byte Order Mark for UTF-8. Used to recognize file encoding while opening the file

	String timeStamp = emxGetParameter(request, "timeStamp");
	String strGroupingRows = emxGetParameter(request, "bGroupingRows");
	boolean bGroupingRows = false;

	String exportFormat = Request.getParameter(request, "exportFormat");
	String sbMode = Request.getParameter(request, "sbMode");
	String subHeader = Request.getParameter(request, "subHeader");
	String csvData = "";

	String mode = emxGetParameter(request, "mode");

	if ("exportToExcel".equals(sbMode) && "CSV".equals(exportFormat))
	{
		HashMap tableData = indentedTableBean.getTableData(timeStamp);

		HashMap programMap = new HashMap();
		programMap.put("tableData", tableData);
		programMap.put("timeStamp", timeStamp);
		programMap.put("sbMode", sbMode);
		programMap.put("request", request);
		programMap.put("indentedTableBean", indentedTableBean);
		programMap.put("subHeader", subHeader);
		programMap.put("pageContext", pageContext);

		String[] methodargs = JPO.packArgs(programMap);
		eObj.startExportToExcelBackgroundJob(context, programMap);

		/* JPO.invoke(context, "jpo.manufacturerequivalentpart.Part",
				null, "startMEPExportToExcelBackgroundJob", methodargs,
				Integer.class); */
	}

	else // To view/download the exported excel
	{
		String objectId = emxGetParameter(request, "jobid");
		DomainObject obj = new DomainObject(objectId);
		String logFormat = PropertyUtil.getSchemaProperty(context,"format_Log");
		String fileName = obj.getInfo(context, "format[" + logFormat + "].file.name");

		System.out.println(fileName);
		Job job = new Job(objectId);
		String workspaceDir = context.createWorkspace();
	    String workspace = workspaceDir + java.io.File.separator + job.getName(context) ;
	    java.io.File file = new java.io.File(workspace);
	    if ( !file.exists() && !file.mkdir() )
	    {
	    	workspace = context.createWorkspace();
	    	workspaceDir = workspace;
	    } 
	    file = new java.io.File(workspace + java.io.File.separator + fileName);

	    job.checkoutFile(context, false, logFormat, fileName, workspace);
	    
	     String fileEncodeType = request.getCharacterEncoding();
		if ("".equals(fileEncodeType) || fileEncodeType == null || fileEncodeType == "null")
			fileEncodeType = UINavigatorUtil.getFileEncoding(context, request);
		
	    response.setContentType("application/csv; charset=" + fileEncodeType);
		response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
		
		java.io.FileInputStream fileInputStream = new java.io.FileInputStream(file);
		InputStreamReader inputStreamReader=new InputStreamReader(fileInputStream, fileEncodeType);
		
		out.clear(); // removes unnecessary spaces
		int i;
		while ((i = inputStreamReader.read()) != -1)
			out.write(i);
		inputStreamReader.close();
		fileInputStream.close(); 
		
		//Delete the temp workspace folder
		//file = new java.io.File(workspaceDir);
		eObj.deleteDirectory(file);
	}
%>






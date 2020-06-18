<%-- emxProgramCentralProjectExportProcess.jsp

  Performs the action that exports a project to the client.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralProjectExportProcess.jsp.rca 1.27 Wed Oct 22 15:50:35 2008 przemek Experimental przemek $";


<%@include file = "emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@page import = "com.matrixone.apps.program.Task" %>

<head>
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" language="JavaScript">
    addStyleSheet("emxUIDialog");
</script>
</head>
--%>
<%@include file = "emxProgramGlobals2.inc"%>
<%@include file = "../emxRequestWrapperMethods.inc"%>

<%
//create context variable for use in pages
matrix.db.Context context = Framework.getFrameContext(session);
%>

<%
  // Gets the parameters from the request.
  String objectId = (String) emxGetParameter(request, "objectId");
  String exportFormat = (String) emxGetParameter(request, "exportFormat");
  DomainObject selectedProject = new DomainObject(objectId);
  String fileName = selectedProject.getName(context);
  String language = request.getHeader("Accept-Language");
  String extension = null;
  if(("CSV".equalsIgnoreCase(exportFormat) || "HTML".equalsIgnoreCase(exportFormat))){
    extension = ".csv";
  } else {
    extension = ".text";
  }

  try {
		Map paramMap = new HashMap();
		paramMap.put("objectId", objectId);
		paramMap.put("exportFormat", exportFormat);
		paramMap.put("language", language);
	
		StringList projectTasks  = JPO.invoke(context, "emxProjectSpace", null, "exportProjectTaskList", JPO.packArgs(paramMap),StringList.class);
					
	 	String fileEncodeType = request.getCharacterEncoding();
	  	if ("".equals(fileEncodeType) || fileEncodeType == null || fileEncodeType == "null"){
			fileEncodeType=UINavigatorUtil.getFileEncoding(context, request);
	  	}
		fileName = (fileName == null || "null".equalsIgnoreCase(fileName))?"":fileName;
		String saveAsFileName = fileName;
		fileName += extension;
		String saveAs = ServletUtil.encodeURL(fileName);
		String tempFileName = fileName;
		out.clear();
		response.setContentType ("text/plain;charset="+fileEncodeType);
		response.setHeader ("Content-Disposition", "attachment;filename=" + fileName);
		
		Iterator taskItr = projectTasks.iterator();
		while (taskItr.hasNext()) {
		   String thisLine = (String) taskItr.next();
		   out.println(thisLine);
		}
  } catch(Exception ex) {
	  ex.printStackTrace();
  }
 %>


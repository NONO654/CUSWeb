<%--  emxImportviewLogFileDownload.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = $Id: emxImportLogFileDownLoad.jsp.rca 1.1.4.4 Wed Oct 22 15:48:22 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%
    String objectId = emxGetParameter(request, "jobid");
    DomainObject obj = new DomainObject(objectId);
    String logFormat = PropertyUtil.getSchemaProperty(context, "format_Log");
    String fileName = obj.getInfo(context, "format[" + logFormat + "].file.name");
    
    Job job = new Job(objectId);
    String workspace = context.createWorkspace() + java.io.File.separator + job.getName(context) ;
    java.io.File file = new java.io.File(workspace);
    if ( !file.exists() && !file.mkdir() )
    {
    	workspace = context.createWorkspace();
    } 
    file = new java.io.File(workspace + java.io.File.separator + fileName);

    job.checkoutFile(context, false, logFormat, fileName, workspace);

    FileInputStream fis = new FileInputStream(file);
    response.setHeader ("Content-Disposition", "attachment;filename=\"" + file.getName() + "\"");
    response.setHeader ("Content-Type", "text/plain");

	/* Start: IR-056218V6R2011x */
    final int BUFF_SIZE = 1024 * 8;
	byte[] byt = new byte[BUFF_SIZE];
	int read = 0;
	out.clear();
	do {
		read = fis.read(byt);
		if (read == -1)
			break;
		out.write(new String(byt, 0, read));
	} while (true);
	/* End: IR-056218V6R2011x */
	out = pageContext.pushBody();
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>



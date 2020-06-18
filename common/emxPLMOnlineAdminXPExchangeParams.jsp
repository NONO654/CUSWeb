<%@page import ="com.matrixone.vplm.parameterizationUtilities.UIStreamUtilities"%><%@page import ="com.matrixone.vplm.ParameterizationImportExport.ParameterizationImportExport"%><%@page import="java.io.FileInputStream"%><%@page import="java.io.BufferedInputStream"%><%@page import="java.io.BufferedOutputStream"%><%@page import="java.io.OutputStream"%><%@page import="matrix.db.Context"%><%@page import="java.io.File"%>
<%@ page import ="com.matrixone.servlet.*"%><%@include file = "../common/emxNavigatorInclude.inc"%><%

//@fullReview  ZUR 11/02/15 Import Export Parameters HL V6R2012x
//@fullReview  ZUR 12/05/10 handle export for the XML parameters file and the CATNLS Zip - IR-164539V6R2013x

//emxTagLibInclude.inc
//Context ctx = Framework.getMainContext(session);
//Context ctx = Framework.getFrameContext(session);

String fileExportedName  = emxGetParameter(request,"exportFileName"); //Parameterization_Export.xml
String requestFileFormat = emxGetParameter(request,"fileFormat");

String contentType = "APPLICATION/"+requestFileFormat.toUpperCase();
//HttpServletResponse response = ((ABCActionHttpContext)ctx).getResponse();
response.setContentType(contentType);
// initialize the http content-disposition header to indicate a file attachment with the default fileExportedName
String dispHeader = "Attachment; Filename=\"" + fileExportedName + "\"";

response.setHeader("Content-Disposition",dispHeader);
//Transfer the file
byte[] fileBytes = null;

if (requestFileFormat.equalsIgnoreCase("zip"))
	fileBytes = UIStreamUtilities.getZipByteArray(context,fileExportedName);
else	
{
	ParameterizationImportExport PIE = new ParameterizationImportExport(context);
	String fileName = PIE.exportParam(context); 
	
	fileBytes = UIStreamUtilities.getByteArray(context,fileExportedName);
}

int DEFAULT_BUFFER_SIZE = fileBytes.length;
// Open streams :
BufferedOutputStream output = null;

try{	
	OutputStream myOut = response.getOutputStream();	
	output = new BufferedOutputStream(myOut);
	// Write file contents to response.
	output.write(fileBytes, 0, DEFAULT_BUFFER_SIZE);
}
finally 
{
	// close streams
	output.flush();  
	output.close();  
//	response.sendRedirect("emxPLMOnlineAdminXPExchangeParamsAjax.jsp"); 
}
%>

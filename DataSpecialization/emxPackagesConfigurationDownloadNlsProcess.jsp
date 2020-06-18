<%--  emxPackagesConfigurationDownloadNlsProcess.jsp  --  Export CATNls of packages
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreatePackage.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.BufferedInputStream"%>
<%@page import="java.io.BufferedOutputStream"%>
<%@page import="java.io.File"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
//HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
//String nlsLang = emxGetParameter(request, "NLSLang");
//System.out.println("YI3 - param  : " + nlsLang);
System.out.println(" Download packages NLS");
/*
Enumeration eNumParameters = emxGetParameterNames(request);
String parmValue = "";
String tableRowIds[] = null;
while( eNumParameters.hasMoreElements() ) {
	String parmName  = (String)eNumParameters.nextElement();
	System.out.println("param  : " + parmName + " - value : " + emxGetParameter(request, parmName));
}*/
int k = 0;
ArrayList<String> listlang = new ArrayList<String>();
String selPacksIds[] = emxGetParameterValues(request, "emxTableRowId");
String listLangStr ="";
if ((null != selPacksIds) ){

	for (k = 0; k<selPacksIds.length; k++)
	{
	String lang = selPacksIds[k];
		// rowid |fr||0,1				
		if (lang.startsWith("|") == true ) {
			lang = lang.substring(1);
		}
		int idxPipes = lang.indexOf("||");
		if (idxPipes > 0 ) {								
			lang = lang.substring(0,idxPipes);
		}	
		//System.out.println("YI3 - Language  : "+lang);
		listlang.add(lang);
		listLangStr+=lang +"#";
		
	}

}
System.out.println("YI3 - Language  : "+listLangStr);
IDAuManager manager = DAuManagerAccess.getDAuManager();
if (null != manager)
{
	try
	{
		//"/home/data/RTV/R214relyi3devpril274/apache-tomcat/temp/CATNls";
		String property = "java.io.tmpdir";
		String tmpDir = System.getProperty(property);
		property = "file.separator";
		String separator = System.getProperty(property);
		if (!tmpDir.endsWith(separator)) {
			tmpDir = tmpDir + separator;
		}
		String sessionId = context.getSession().getSessionId();
		int idx = sessionId.indexOf(":(");
		if (idx > 0 ) {								
			sessionId = sessionId.substring(0,idx);
		}	
		sessionId = sessionId.replace(":","_");
		String catnlsDirName = tmpDir+"CATNls"+separator;
	    String custoTmpDir = catnlsDirName + sessionId;

	    File custoDir = new File(custoTmpDir);
		if (custoDir.exists()) {
			tmpDir = custoTmpDir + separator;
	    }
		else {
	  	// try to create it
			if (custoDir.mkdirs()) {
				tmpDir = custoTmpDir + separator;
			}
		}
		String destPath = custoDir.getAbsolutePath();
		//System.out.println(" YI3 - Path : "+destPath);

		//destPath =destPath.substring(0,destPath.indexOf("DicoAuthorXChange/"))+"CATNls/";
		Map argsHash = new HashMap();
		argsHash.put("listLang", listLangStr);
		argsHash.put("destinationPath", destPath);
	
		// Pack arguments into string array.
		String[] args = JPO.packArgs(argsHash);
		String retVal =(String) JPO.invoke(context, "emxPackagesConfigurationProgram", null, "generateCATNLSFiles", args, String.class);

		//CATNLSGenerator cts;
		//cts = new CATNLSGenerator(context,listlang,destPath,true);
		//cts.ProcessCustomPackages();
		
		String contentType = "APPLICATION/ZIP";
		response.setContentType(contentType);
		String zipExportedName = "PackagesCATNls.zip";
		// initialize the http content-disposition header to indicate a file attachment with the default zipExportedName
		String dispHeader = "Attachment; Filename=\"" + zipExportedName + "\"";
		response.setHeader("Content-Disposition",dispHeader);
		//response.setHeader  ("Content-Disposition","attachment;  filename=\""  +  zipExportedName  +"\""); 
		//Transfer now the file
		byte[] zipBytes = manager.createZipForNLS(context,destPath);
		manager.deleteFolder(catnlsDirName);
		
		BufferedOutputStream output = null;
		try {
			int DEFAULT_BUFFER_SIZE = zipBytes.length; // 10K
			//System.out.println("1 - ZIP Bytes size : "+DEFAULT_BUFFER_SIZE);
			//System.out.println(" response  : "+response);
			// Open streams.
			output = new BufferedOutputStream(response.getOutputStream(),DEFAULT_BUFFER_SIZE);
			//System.out.println(" 2 - ZIP Bytes size : "+DEFAULT_BUFFER_SIZE);
			// Write file contents to response.
			output.write(zipBytes, 0, DEFAULT_BUFFER_SIZE);
			
		} 
		finally {
			// close streams.
			output.close();
		}
	}
	catch (Exception e)
	{
		System.out.println("Download KO: " + e.getMessage());
		emxNavErrorObject.addMessage("Download KO : " + e.getMessage());									
		%>
		<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
		<%
	}		
}

%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

			<script language="javascript" type="text/javaScript">
			//alert("Close Slide in");
			//top.closeSlideInDialog(); 

			//top.content.location.href = top.content.location.href; // idem as line above.
			//parent.window.close();
			</script>
		

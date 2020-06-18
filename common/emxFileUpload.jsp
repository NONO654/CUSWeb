<%@page import="org.apache.commons.fileupload.*,java.util.*,java.io.*"%>
<%@page import="matrix.db.JPO"%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.servlet.Framework"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%	
	String sFolderWIN 	= "c:\\temp\\";
	String sFolderUNIX 	= "/tmp/";	
	String sLanguage 	= request.getHeader("Accept-Language");
	String sOID 		= com.matrixone.apps.domain.util.Request.getParameter(request, "objectId");	
	String sRelType 	= com.matrixone.apps.domain.util.Request.getParameter(request, "relationship");	
	String sCommand 	= com.matrixone.apps.domain.util.Request.getParameter(request, "documentCommand");
	String sOSName 		= System.getProperty ( "os.name" );
	String sFolder 		= sOSName.contains("Windows") ? sFolderWIN : sFolderUNIX ;	
  
	// Save file on disk
	DiskFileUpload upload	= new DiskFileUpload();
	//List items 				= upload.parseRequest(request);  
	List files = upload.parseRequest(request);
	
	matrix.db.Context context 	= Framework.getFrameContext(session); 
     
	String initargs[] = {};		
	HashMap params = new HashMap();
	params.put("language",sLanguage);
	params.put("objectId",sOID);
	params.put("relationship",sRelType);
	params.put("documentCommand",sCommand);			
	params.put("folder",sFolder);	
	params.put("files",files);
	params.put("objectAction","create");
	params.put("timezone", (String)session.getAttribute("timeZone"));
	
	String sResult = (String)JPO.invoke(context, "emxDnD", initargs, "checkinFile", JPO.packArgs (params), String.class);	
  
%><%=sResult%>

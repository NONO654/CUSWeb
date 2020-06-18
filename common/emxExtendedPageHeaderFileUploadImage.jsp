<%@page import="com.matrixone.apps.framework.ui.*"%>
<%@page import="org.apache.commons.fileupload.*,java.util.*,java.io.*"%>
<%@page import="matrix.db.JPO"%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.servlet.Framework"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<%		
	String sLanguage 	= request.getHeader("Accept-Language");
	String sOID 		= com.matrixone.apps.domain.util.Request.getParameter(request, "objectId");	
	String sOSName 		= System.getProperty ( "os.name" );
	String sFolder 		= sOSName.contains("Windows") ? "c:\\temp\\" : "/tmp/";
	String sMCSURL 		= request.getRequestURL().toString();
	String sImageRelType 	= com.matrixone.apps.domain.util.Request.getParameter(request, "relationship");
	String suiteKey 		= com.matrixone.apps.domain.util.Request.getParameter(request,"suiteKey");
	
	// Save file on disk
	DiskFileUpload upload	= new DiskFileUpload();
	List files 				= upload.parseRequest(request);   
	
	matrix.db.Context context	= Framework.getFrameContext(session);   
	String initargs[] 			= {};		
	HashMap params 				= new HashMap();
	
	params.put("language",sLanguage);
	params.put("objectId",sOID);
	params.put("folder",sFolder);
	params.put("files",files);		
	params.put("MCSURL",	sMCSURL.replace("/common/emxExtendedPageHeaderFileUploadImage.jsp", ""));
	params.put("relationship",sImageRelType);
	
    String structureMenuObj = UITreeUtil.getTreeMenuName(application, session, context, sOID, suiteKey);
    UIMenu emxTreeObject = new UIMenu();
    String sImageDnDJPO 	= "emxDnD";
    String sImageDnDMethod  = "checkInImage";
    
	if(structureMenuObj != null)
	{
		HashMap topStructureMenuMap = emxTreeObject.getMenu(context, structureMenuObj);
    	String settingImageDnDJPO = emxTreeObject.getSetting(topStructureMenuMap, "ImageDnDJPO");
    	String settingImageDnDMethod = emxTreeObject.getSetting(topStructureMenuMap, "ImageDnDMethod");
    	if( UIUtil.isNotNullAndNotEmpty(settingImageDnDJPO) && UIUtil.isNotNullAndNotEmpty(settingImageDnDMethod) ){
    		sImageDnDJPO = settingImageDnDJPO;
    		sImageDnDMethod = settingImageDnDMethod;
    	}
	}
	FrameworkUtil.validateMethodBeforeInvoke(context, sImageDnDJPO, sImageDnDMethod, "Program");
	String sResult= (String)JPO.invoke(context, sImageDnDJPO, initargs, sImageDnDMethod, JPO.packArgs (params), String.class);
	
%><%=sResult%>

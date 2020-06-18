
<%@page import="org.apache.commons.fileupload.*,java.util.*,java.io.*"%>
<%@page import="matrix.db.JPO"%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.servlet.Framework"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="matrix.db.RelationshipType"%>
<%@page import="matrix.db.Context"%>
 <%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import=" com.matrixone.apps.common.CommonDocument"%>

<%	
	String sFolderWIN 	= "c:\\temp\\";
	String sFolderUNIX 	= "/tmp/";	
	String sLanguage 	= request.getHeader("Accept-Language");
	String sOID 		= com.matrixone.apps.domain.util.Request.getParameter(request, "objectId");	
	String sRelType 	= com.matrixone.apps.domain.util.Request.getParameter(request, "relationship");	
	String sCommand 	= com.matrixone.apps.domain.util.Request.getParameter(request, "documentCommand");
	String sOSName 		= System.getProperty ( "os.name" );
	String sFolder 		= sOSName.contains("Windows") ? sFolderWIN : sFolderUNIX ;	
	matrix.db.Context context 	= Framework.getFrameContext(session); 
	sRelType=PropertyUtil.getSchemaProperty(context,sRelType);
	String sReferenceDocument = com.matrixone.apps.domain.util.Request.getParameter(request, "referenceDocument");
	String sCreateVersion = com.matrixone.apps.domain.util.Request.getParameter(request, "createVersion");
	String sfileVersionId = com.matrixone.apps.domain.util.Request.getParameter(request, "fileVersionId");
	String sfileName = com.matrixone.apps.domain.util.Request.getParameter(request, "fileName");
	if("true".equals(sReferenceDocument))
	{
	
		DomainObject dObjDoc = DomainObject.newInstance(context,sOID);
		String refDocId=FrameworkUtil.autoName(context, DomainSymbolicConstants.SYMBOLIC_type_Document,
			DomainSymbolicConstants.SYMBOLIC_policy_Document);
		DomainObject doObj = DomainObject.newInstance(context,refDocId);
		String refObjName=doObj.getName(context);
		doObj.setAttributeValue(context,"Title",refObjName);
		sOID=refDocId;
		String strRelRefrenceDocument=PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_relationship_ReferenceDocument);
		DomainRelationship.connect(context,dObjDoc,new RelationshipType(strRelRefrenceDocument), doObj);
	}
	 
	 
	 
	// Save file on disk 
	
	DiskFileUpload upload	= new DiskFileUpload();
	//List items 				= upload.parseRequest(request);  
	List files = upload.parseRequest(request);
	
	
     
	String initargs[] = {};		
	HashMap params = new HashMap();
	params.put("language",sLanguage);
	params.put("objectId",sOID);
	params.put("relationship",sRelType);
	params.put("documentCommand",sCommand);			
	params.put("folder",sFolder);	
	params.put("files",files);
	params.put("fileVersionId",sfileVersionId);
	params.put("fileName",sfileName);
	params.put("objectAction","create");
	params.put("timezone", (String)session.getAttribute("timeZone"));
	String sResult ="";
	if(sCreateVersion!=null && sCreateVersion!="" && sCreateVersion!= "null")
	{
			sResult = (String)JPO.invoke(context, "com.dassault_systemes.enovia.processsteps.ENOProcessStepsUI", initargs, "checkinFileFromDrop", JPO.packArgs (params), String.class);
	}
	else{
		sResult = (String)JPO.invoke(context, "com.dassault_systemes.enovia.processsteps.ENOProcessStepsUI", initargs, "checkinFile", JPO.packArgs (params), String.class);
	}
	
  
%><%=sResult%>

<%@page import="java.util.List"%>
<%@page import="org.apache.poi.ss.usermodel.Cell"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFSheet"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFWorkbook"%>
<%@page import="org.apache.poi.ss.usermodel.Row"%>
<%@page import="java.io.File,org.apache.poi.hssf.usermodel.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.engineering.ImportFile"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>EBOM Import</title>
</head>
<body>
<form name="ENGBOMImport" method="post" >

<%
	long timeinMilli = System.currentTimeMillis();
	String S_TEMPDIR;
	{
	  String sProgram = "eServicecommonUtFileGetTmpDir.tcl";
	  String err = ""; // error message return by MQLCommand
	  String res = ""; // results returned by MQLCommand
	
	  // Execute the MQL command
	  MQLCommand command = new MQLCommand();
	  command.open(context);
	  command.executeCommand( context, "execute program $1",sProgram);
	  err = command.getError().trim();
	  S_TEMPDIR = command.getResult().trim();
	  command.close(context);
	
	  if ( S_TEMPDIR.length() == 0){
	     throw new Exception("temp directorty not found !!!");
	  }
	};

	String objectId = "";
	String strAction = "";
	MultipartRequest mrequest   = new MultipartRequest(request, S_TEMPDIR, MultipartRequest.UNLIMITED_POST_SIZE);
	boolean fromMyDesk = true;
	java.io.File oFile = null;
	String backgroundProcess  = mrequest.getParameter("background");
	String WorkUnderOID  = mrequest.getParameter("WorkUnderOID");
	long totalNoofRows = 0;
	
	Map resultMap = new HashMap();
	
	HashMap parentMap = new HashMap();
	boolean exception = false;
	ImportFile impoFile = new ImportFile();
	String suiteKey;
	String defaultCategory = "";
	String openerFrame = "";
	
	try {
		//Configuration command
		String commandName = mrequest.getParameter("commandName");
		if(UIUtil.isNullOrEmpty(commandName)) {
			throw new Exception(EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.ImportEBOM.NoConfigCommand"));
		}
		parentMap.put("commandName", commandName);
		
		String sFileName ="";
		Enumeration oFiles = mrequest.getFileNames();		
		
		objectId = mrequest.getParameter("objectId"); //emxGetParameter(mrequest,"objectId");
		String selPartObjectId  = mrequest.getParameter("selPartObjectId"); //emxGetParameter(mrequest, "selPartObjectId");
	
		if(UIUtil.isNotNullAndNotEmpty(objectId)) {
			fromMyDesk = false;
			selPartObjectId = UIUtil.isNullOrEmpty(selPartObjectId) ? objectId : selPartObjectId;
			parentMap.put(DomainConstants.SELECT_ID, selPartObjectId);
			parentMap.put("origin", "BOMPowerview");
		}
		
		String sName ;
		while (oFiles.hasMoreElements() ) {
			sName = (String) oFiles.nextElement();
			sFileName = mrequest.getFilesystemName(sName);

		    String extension = sFileName.substring(sFileName.lastIndexOf(".")+1);
		    
		    if(!("xlsx".equalsIgnoreCase(extension) || "xls".equalsIgnoreCase(extension))) {
		    	throw new Exception(EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.ImportEBOM.FileSupportException"));
		    }
		    oFile = mrequest.getFile(sName);
		    
		   //get total number of rows in excel sheet 
		   totalNoofRows = impoFile.getTotalRows(context,oFile);
		   parentMap.put("WorkUnderOID", WorkUnderOID);
		    
		    if(UIUtil.isNotNullAndNotEmpty(backgroundProcess)||totalNoofRows>100) {
		    	parentMap.put("BGProcess", "true");
	            Object objectArray[] = {context, parentMap, oFile};
	            Class objectTypeArray[] = {context.getClass(), parentMap.getClass(), oFile.getClass()};
	
	            BackgroundProcess bgProcess = new BackgroundProcess();
			    bgProcess.submitJob(context, impoFile, "validateAndCreateBOMStructure", objectArray, objectTypeArray);
		    } else {
				resultMap = impoFile.validateAndCreateBOMStructure(context, parentMap, oFile);
		    }
		}
		
		MapList dataList = (MapList) resultMap.get("importObjectList");
		Map columnIndexMap = (Map)resultMap.get("columnIndexMap");
		Map columnMappings = (Map)resultMap.get("columnMappings");
		StringList excelColumns = (StringList)resultMap.get("Columns");
		session.setAttribute("importDataList", dataList);
		
		defaultCategory = (String)resultMap.get("DEFAULT_CATEGORY");
		defaultCategory = UIUtil.isNotNullAndNotEmpty(defaultCategory) 
							? "&DefaultCategory="+defaultCategory
							: "";
		openerFrame = (String)resultMap.get("OPENER_FRAME");
		openerFrame = UIUtil.isNotNullAndNotEmpty(openerFrame) 
						? openerFrame
						: "ENCBOM";
		
		suiteKey = (String)resultMap.get("REGISTERED_SUITE");
	   	objectId = (String)resultMap.get("objectId");
		strAction = (String)resultMap.get("action");
		session.setAttribute("columnIndexMap", columnIndexMap);
		session.setAttribute("columnMappings", columnMappings);
		session.setAttribute("Columns", excelColumns);

	} catch ( Exception e ) {
		exception = true;
		e.printStackTrace();
		session.setAttribute("error.message", e.getMessage());
	}
	
	String contentURL = "../common/emxIndentedTable.jsp?table=StructureImportTable&header=emxEngineeringCentral.Header.EBOMImportErrors&selection=none&program=emxEngineeringUtil:displayImportedData&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&jpoAppServerParamList=session:importDataList,session:columnIndexMap,session:columnMappings,session:Columns&sortColumn=none&&customize=false&expandLevelFilter=false&findMxLink=false&massPromoteDemote=false&multiColumnSort=false&objectCompare=false&PrinterFriendly=false&showChartOptions=false&showClipboard=false&showTableCalcOptionstipPage=false&triggerValidation=false&export=false&AutoFilter=false&sortColumnName=none&displayView=details";
	
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</form>

<script type="text/javascript">
<%
boolean bgAlert = false;
if("error".equalsIgnoreCase(strAction)) {
%>	
  //XSSOK
	document.ENGBOMImport.action="<%=contentURL%>";
	
	
	showModalDialog("../common/emxBlank.jsp","max","max","true"); 	          
	var objWindow =  getTopWindow().modalDialog.contentWindow;
	document.ENGBOMImport.target = objWindow.name;
	document.ENGBOMImport.submit();
	getTopWindow().closeSlideInDialog();
	
<%
} else {
	if(!exception && UIUtil.isNotNullAndNotEmpty(backgroundProcess)){
		String bgAlertMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.ImportEBOM.BackGroundProcessMsg");
		bgAlert = true;
%>
   //XSSOK
		alert("<%=bgAlertMsg%>");
<%
	}
	if(!exception && totalNoofRows >100){
		String bgAlertMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.ImportEBOM.PartsMoreThanHundred");
		bgAlert = true;
%>
    //XSSOK
		alert("<%=bgAlertMsg%>");
<%
	}
	
	if(!bgAlert && UIUtil.isNotNullAndNotEmpty(objectId)) {
		if (fromMyDesk) {
			%>
		getTopWindow().document.location.href = "../common/emxNavigator.jsp?objectId=<xss:encodeForURL><%=objectId%></xss:encodeForURL>" + "<%=defaultCategory%>";
			getTopWindow().closeSlideInDialog();
<%
		} else {
%>
	       //XSSOK
			var frameObj = getTopWindow().openerFindFrame(getTopWindow(), "<%=openerFrame%>");
			if(frameObj != null && frameObj != "" && frameObj != 'undefined'){
				frameObj.location.href = frameObj.location.href;	
			}			
			getTopWindow().closeSlideInDialog();
<%
		}
	} else {
%>
		getTopWindow().closeSlideInDialog();
<%
	}
}
%>
</script>

</body>
</html>

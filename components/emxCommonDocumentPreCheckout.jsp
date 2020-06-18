<%--
    emxCommonDocumentPreCheckout.jsp

    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved  This program contains proprietary and trade secret
    information of MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

    Description : pre-Document Create Wizard, Step 1

    static const char RCSID[] = "$Id: emxCommonDocumentPreCheckout.jsp.rca 1.21 Wed Oct 22 16:17:52 2008 przemek Experimental przemek $";
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@ page import = "com.matrixone.apps.common.Download"%>
<%@ page import = "java.nio.file.Path"%>
<%@ page import = "java.nio.file.Paths"%>
<%@ page import = "java.nio.file.Files"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<%
	String strPartId = null;
	String isLastVersion = null;
	
	boolean getCheckoutMapFromSession = "true".equals(request.getParameter("getCheckoutMapFromSession"));
    Map emxCommonDocumentCheckoutData = new HashMap();
	String contextObjectId = (String)emxGetParameter(request, "objectId");
	DomainObject domainObject = new DomainObject(contextObjectId);
	String contextObjectAction = (String)emxGetParameter(request, "action");

	//IR-670955 : To retrieve flag values from url
	//changes for AppletFree Download Structure for DEC operation.
	//we added flag as, isExpandFromDEC in URL parameter to fetched expanded object ids from DEC side.
	//we added flag as, isRequiredPath in URL parameter to set value for paths parameter.
	// Value for paths parameter is set to "null" to get all files in one folder ( no subfolder required).
	//This changes is down to open all structure in CAD Tool once downloaded.
	// This can be dependent on isRequiredPath flag(URL parameter)
	String isExpandFromDEC = (String)emxGetParameter(request, "isExpandFromDEC");
	String isRequiredPath = (String)emxGetParameter(request, "isRequiredPath");
	//IR-670955 : END OF CODE

	String checkinAccess = "";
	String isKindOfDocument = "";
	StringList selects = new StringList();
	selects.add(DomainConstants.SELECT_IS_LAST);
	selects.add(DomainConstants.SELECT_HAS_CHECKIN_ACCESS);
	selects.add(CommonDocument.SELECT_IS_KIND_OF_DOCUMENTS);
	if(UIUtil.isNotNullAndNotEmpty(contextObjectId) && "checkout".equalsIgnoreCase(contextObjectAction)){
		Map objectMap = domainObject.getInfo(context, selects);
		isLastVersion = (String)objectMap.get(DomainConstants.SELECT_IS_LAST);
		checkinAccess = (String)objectMap.get(DomainConstants.SELECT_HAS_CHECKIN_ACCESS);
		isKindOfDocument = (String)objectMap.get(CommonDocument.SELECT_IS_KIND_OF_DOCUMENTS);
	}
	String noCheckoutAccessError = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.FileDownload.NoCheckOutAccess");
	String latestVersionAvailableError =EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.LatestVersionAvailableToCheckout");
	if(UIUtil.isNotNullAndNotEmpty(isLastVersion) && "false".equalsIgnoreCase(isLastVersion)){
%>
       <script language="javascript">
          alert("<%=latestVersionAvailableError%>");
        </script>
<%	
	return;
	}
	if("TRUE".equalsIgnoreCase(isKindOfDocument) && UIUtil.isNotNullAndNotEmpty(checkinAccess) && "false".equalsIgnoreCase(checkinAccess)){
%>
      	 <script language="javascript">
          	alert("<%=noCheckoutAccessError%>");
        </script>
<%	
		return;
	}

	
    if(getCheckoutMapFromSession) {
        String sessionKey = request.getParameter("fromDataSessionKey");
        emxCommonDocumentCheckoutData = (Map) session.getAttribute(sessionKey);
        session.removeAttribute(sessionKey);
        String tableRowIds = (String)emxCommonDocumentCheckoutData.get("emxTableRowId");
        String[] emxTableRowId = com.matrixone.jsystem.util.StringUtils.split(tableRowIds, ",");
        emxCommonDocumentCheckoutData.put("emxTableRowId", emxTableRowId);
    } else {
        Enumeration enumParam = request.getParameterNames();
        // Loop through the request elements and
        // stuff into emxCommonDocumentCheckinData
        while (enumParam.hasMoreElements())
        {
            String name  = (String) enumParam.nextElement();
            if ( "emxTableRowId".equals(name) )
            {
                String[] values = request.getParameterValues(name);
                emxCommonDocumentCheckoutData.put(name, values);
            } else {

                String value = request.getParameter(name);
                emxCommonDocumentCheckoutData.put(name, value);
            }
        }
    }


    String isAppPreProcess = request.getParameter("isAppPreProcess");
    String refresh = request.getParameter("refresh");
    if ( !"false".equals(refresh) )
    {
        emxCommonDocumentCheckoutData.put("refresh", "true");
    }
    String key = "downloadInProgress-"+emxCommonDocumentCheckoutData.get("customSortColumns")+"-"+emxCommonDocumentCheckoutData.get("fileName");
	String downloadInProgress = (String) session.getAttribute(key);
    if("true".equals(downloadInProgress)){
    	%>
    	<script type="text/javascript">
			alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.DownloadInProgress</emxUtil:i18nScript>");
		</script>
		<%
    } else if(downloadInProgress == null){
    	session.setAttribute(key, "true");
    }
    String objectAction = (String)emxCommonDocumentCheckoutData.get("objectAction");
    String action  = (String)emxCommonDocumentCheckoutData.get("action");
    String format = (String) emxCommonDocumentCheckoutData.get("format");
    String fileName = (String) emxCommonDocumentCheckoutData.get("fileName");
    String version = (String) emxCommonDocumentCheckoutData.get("version");
    String versionId = (String)emxCommonDocumentCheckoutData.get("versionId");     
     
	//IR-670955 : Start of code to get object Ids by expanding structure
	//we added flag as, isExpandFromDEC in URL parameter to execute this code.
	//Fetched object ids after expansion are retrieved from session.
   
    String[] objectIds=null;
	if("true".equalsIgnoreCase(isExpandFromDEC))
	objectIds = (String[])session.getAttribute("strExpandedobjectIds"); 
	else
	objectIds = (String[]) emxCommonDocumentCheckoutData.get("emxTableRowId");

	//IR-670955 : END OF code	
	
    if ( objectIds != null && !"".equals(objectIds) && !"null".equals(objectIds) )
    {
        //CommonDocument.
        Map objectMap = UIUtil.parseRelAndObjectIds(context, objectIds,false);
        objectIds = (String[])objectMap.get("objectIds");
		strPartId = (String) emxCommonDocumentCheckoutData.get("objectId");
		String parentId = (String) emxCommonDocumentCheckoutData.remove("objectId");
		DomainObject domPart = new DomainObject(strPartId);
		String strPartType = FrameworkUtil.getBaseType(context, domPart.getType(context), null);
        if(!domPart.TYPE_PART.equals(strPartType))
		{
			strPartId = null;
		}
	} else {
        objectIds = new String[]{(String)emxCommonDocumentCheckoutData.get("objectId")};
    }
    boolean multipleObjectIds = true;
    boolean moveFilesToVersion = false;
	boolean isValidObject = true;
	
    if (UIUtil.isNullOrEmpty(objectIds[0]))
    {
    	isValidObject = false;       
    }else if(objectIds.length == 1){
    	DomainObject domain = new DomainObject(objectIds[0]);
    	try{
    		if(domain.exists(context)){
        		multipleObjectIds = false;
        	}else{
        		isValidObject = false;
        	}
    	}catch(Exception ex){
   			isValidObject = false;        		
    	}
    }
    
    if(isValidObject){
    StringList objectSelects = new StringList(8);
    objectSelects.add(CommonDocument.SELECT_ID);
    objectSelects.add(CommonDocument.SELECT_TYPE);
    objectSelects.add(CommonDocument.SELECT_SUSPEND_VERSIONING);
    objectSelects.add(CommonDocument.SELECT_FILE_NAME);
    objectSelects.add(CommonDocument.SELECT_IS_VERSION_OBJECT);
    objectSelects.add(CommonDocument.SELECT_MASTER_ID);
    objectSelects.add(CommonDocument.SELECT_MASTER_SUSPEND_VERSIONING);
    objectSelects.add(CommonDocument.SELECT_MOVE_FILES_TO_VERSION);
    objectSelects.add(CommonDocument.SELECT_IS_KIND_OF_VC_DOCUMENT);
    objectSelects.add(CommonDocument.SELECT_HAS_CHECKIN_ACCESS);
   
    MapList objectMapList = DomainObject.getInfo(context, objectIds, objectSelects);
    Iterator itr = objectMapList.iterator();
    int fileCount = 0;
    StringList objectIdList = new StringList();

	//this will have document id as key and its file names in the form of StringList as a value
	Map mapDocumentFileNames = new HashMap();
	StringBuffer sbFileNames = new StringBuffer();
	boolean isVersion = false;
	String strFileName = request.getParameter("fileName");
    while(itr.hasNext() )
    {
        Map objectMap = (Map)itr.next();
        StringList files = (StringList)objectMap.get(CommonDocument.SELECT_FILE_NAME);
        String suspendVersion = (String) objectMap.get(CommonDocument.SELECT_SUSPEND_VERSIONING);
        String masterSuspendVersion = (String) objectMap.get(CommonDocument.SELECT_MASTER_SUSPEND_VERSIONING);
        String isVersionObject = (String) objectMap.get(CommonDocument.SELECT_IS_VERSION_OBJECT);
        String masterId = (String) objectMap.get(CommonDocument.SELECT_MASTER_ID);
        String objectId = (String) objectMap.get(CommonDocument.SELECT_ID);
        String isKindOfVCDocument = (String) objectMap.get(CommonDocument.SELECT_IS_KIND_OF_VC_DOCUMENT);
		String hasCheckAccess = (String) objectMap.get(CommonDocument.SELECT_HAS_CHECKIN_ACCESS);
		if("checkout".equalsIgnoreCase(contextObjectAction) && "false".equalsIgnoreCase(hasCheckAccess)){
			 emxCommonDocumentCheckoutData.put("error.message", noCheckoutAccessError);
			 break;
		}
        if (! UIUtil.isNullOrEmpty(isKindOfVCDocument) && isKindOfVCDocument.contains("TRUE")){
        	isKindOfVCDocument="true";
        }

        if(strFileName == null || "".equals(strFileName) )
		{
			if("true".equalsIgnoreCase(isVersionObject) )
			{
				isVersion = true;
				sbFileNames.append( (String)((StringList) objectMap.get(CommonDocument.SELECT_FILE_NAME)).get(0)+",");
			}else
			{
				mapDocumentFileNames.put(objectId, files);
			}
		}else
		{
			if(UIUtil.isNotNullAndNotEmpty(versionId) && !"undefined".equals(versionId)){
				DomainObject verObj = new DomainObject(versionId);
				String latestVersion = (String) verObj.getInfo(context, "last");
				if(!latestVersion.equals(version)) {
				    emxCommonDocumentCheckoutData.put("error.message", "emxComponents.Common.LatestVersionAvailable");
				    break;
				}
			}	
			if(files.contains(strFileName) || "true".equalsIgnoreCase(isKindOfVCDocument)) {
			    mapDocumentFileNames.put(objectId, strFileName);
			} else {
			    emxCommonDocumentCheckoutData.put("error.message", "emxComponents.CommonDocument.NoFilesToCheckout");
			    break;
			}
		}
        String objectType = (String) objectMap.get(CommonDocument.SELECT_TYPE);
        String interfaceName = (String) objectMap.get("interface.name");
        String parentType = CommonDocument.getParentType(context, objectType);
        moveFilesToVersion = (Boolean.valueOf((String)objectMap.get(CommonDocument.SELECT_MOVE_FILES_TO_VERSION))).booleanValue();
        if ( masterSuspendVersion != null && !"".equals(masterSuspendVersion) && !"null".equals(masterSuspendVersion) )
        {
            suspendVersion = masterSuspendVersion;
        }
        boolean isVersionableType = CommonDocument.checkVersionableType(context, objectType);
        if ( !isVersionableType || parentType.equals(CommonDocument.TYPE_DOCUMENTS) )
        {
            if ( files != null )
            {
                fileCount = files.size();
                if ( fileCount == 1 )
                {
                    String file = (String)files.get(0);
                    if ( file == null || "".equals(file) || "null".equals(file) )
                    {
                        fileCount = 0;
                    }
                }
            }
            if ( fileCount == 0 )
            {
                if("true".equalsIgnoreCase(isKindOfVCDocument))
                {
                	if ("download".equalsIgnoreCase(action) ||  "view".equalsIgnoreCase(action) )
                	{
                          objectIdList.add(objectId);
                    }

                    else if("checkout".equalsIgnoreCase(action))
                    {
                    	  emxCommonDocumentCheckoutData.put("error.message", "emxComponents.CommonDocument.VCDocumentCheckoutError");
                    }
                }
                else if ( !"true".equalsIgnoreCase(isVersionObject) )
                {
                    if (!moveFilesToVersion)
                    {
                        if (!multipleObjectIds)
                        {
                            emxCommonDocumentCheckoutData.put("error.message", "emxComponents.CommonDocument.NoFilesToCheckout");
                        } else if( !("download".equalsIgnoreCase(action) ||  "view".equalsIgnoreCase(action)) ){
                            emxCommonDocumentCheckoutData.put("warning.message", "emxComponents.CommonDocument.SuspendVersioningCheckout");
                        }
                           
                    } else {
                        objectIdList.add(objectId);
                    }
                }
                else if ("true".equalsIgnoreCase(suspendVersion) && "checkout".equalsIgnoreCase(action) )
                {
                    if (!multipleObjectIds)
                    {
                        emxCommonDocumentCheckoutData.put("error.message", "emxComponents.CommonDocument.SuspendVersioningCheckout");
                    } else {
                        emxCommonDocumentCheckoutData.put("warning.message", "emxComponents.CommonDocument.SuspendVersioningCheckout");
                    }

                }
                else if (!objectIdList.contains(masterId) ) {
                   objectIdList.add(objectId);
                }
            }
            else if ("true".equalsIgnoreCase(suspendVersion) && "checkout".equalsIgnoreCase(action) )
            {
                if (!multipleObjectIds)
                {
                    emxCommonDocumentCheckoutData.put("error.message", "emxComponents.CommonDocument.SuspendVersioningCheckout");
                } else {
                    emxCommonDocumentCheckoutData.put("warning.message", "emxComponents.CommonDocument.SuspendVersioningCheckout");
                }
            } else {
                objectIdList.add(objectId);
            }
        }
    }
	if(isVersion)
	{
		if(strFileName == null)
		{
			mapDocumentFileNames.put(request.getParameter("parentOID"), sbFileNames.toString());
		}else
		{
			mapDocumentFileNames.put(request.getParameter("parentOID"), strFileName);
		}
	}


	emxCommonDocumentCheckoutData.put("documentFileNames", mapDocumentFileNames);



    objectIds = new String[objectIdList.size()];
    objectIds = (String[])objectIdList.toArray(objectIds);
    emxCommonDocumentCheckoutData.put("objectIds", objectIds);
    emxCommonDocumentCheckoutData.put("multipleObjectIds", Boolean.valueOf(multipleObjectIds));
    session.setAttribute("emxCommonDocumentCheckoutData", emxCommonDocumentCheckoutData);
    String forwardURL = XSSUtil.encodeForURL(context, (String) emxCommonDocumentCheckoutData.get("forwardURL"));
    if(forwardURL == null)
    {
        forwardURL = "emxCommonDocumentCheckout.jsp";
    }
	//Check if the Download object exist for Context user to Document Object.
	//if not, needs to popup the Usage Create Dialog page
	//And create the Usage information. And download the requested document.
	if(forwardURL.indexOf("?") == -1 )
	{
		forwardURL += "?";
	}else if(forwardURL.lastIndexOf("&") != forwardURL.length() -1 )
	{
		forwardURL += "&";
	}

	
	 //IR-670955 : Passing DEC specific flag in URL to set value of paths parameter.
	 if("false".equalsIgnoreCase(isRequiredPath))
		forwardURL += "isRequiredPath=" + isRequiredPath;
	 //IR-670955 : END OF CODE
	 
String relId = request.getParameter("relId");

if(strPartId == null || Download.isVersionable(context, objectIds[0]) )
{
	if(relId != null && !"".equals(relId) && !"null".equals(relId)){
	try
	{
		StringList  slPartId = new StringList(1);
		slPartId.add("from.id");
		MapList ml = DomainRelationship.getInfo(context, new String[]{relId}, slPartId);
		strPartId = (String)((Map)ml.get(0)).get("from.id");
	}catch(Exception e)
	{//do nothing...
		}
	}
}

if(strPartId == null)
{
	strPartId = request.getParameter("trackUsagePartId");
}
if("undefined".equalsIgnoreCase(strPartId)){
    strPartId = null;
}
if( (Download.isTrackUsageOn(context) || Download.isTrackDownloadOn(context) ) && strPartId != null && !"null".equals(strPartId) && !"".equals(strPartId))
{
	DomainObject domPart = new DomainObject(strPartId);
	String strPartType = FrameworkUtil.getBaseType(context, domPart.getType(context), null);
    if(!domPart.TYPE_PART.equals(strPartType))
	{
		strPartId = null;
	}
}

boolean usageDialogWindow = false;
if(Download.isTrackUsageOn(context) && strPartId != null && !"null".equals(strPartId) && !"".equals(strPartId) && Download.isClassifiedPart(context, strPartId) )
{
		//Functionality added to track the Usage information.
	String strIds = "";
	String strDocIds = "";
	String strUsageId = null;
	boolean isTrackUsage = false;
	boolean isVersionable = false;

	//check if the given objects are versinable.
	//if the first object is versionable then rest of the objects will be versionable.
	if(objectIds.length > 0)
	{
		isVersionable = Download.isVersionable(context, objectIds[0]);
	}
	//gets the Usage Ids for given part
	Map usageMap = Download.getUsageIds(context, strPartId);
	String strDocId = null;
	for(int i=0; i<objectIds.length; i++)
	{

		strDocId = isVersionable ? request.getParameter("parentOID") : objectIds[i];
		strUsageId = (String)usageMap.get(strDocId);

		if(strUsageId == null)
		{
			isTrackUsage = true;
			if(isVersionable)
			{
				strIds = strDocId;
				break;
			}else if(strFileName != null && !"".equals(strFileName))
			{
				strIds = request.getParameter("objectId");
				break;
			}else
			{
				strIds += strDocId +"|";
			}
		}
		strDocIds += strDocId+"|";
	}
	//check if the document is Document Sheet & it is Connected to Part
   usageDialogWindow = isTrackUsage && (isVersionable || isSpecRefDocument(context, objectIds[0]));
	if(usageDialogWindow)
	{
		forwardURL = "../components/emxCommonUsageDialogFS.jsp?downloadForwardURL="+forwardURL;
		forwardURL += "&documentId="+XSSUtil.encodeForURL(context, strIds);
		forwardURL += "&docIds="+XSSUtil.encodeForURL(context, strDocIds);
	}
}
if(Download.isTrackDownloadOn(context) || Download.isTrackUsageOn(context) )
{
	forwardURL += "&trackUsagePartId="+XSSUtil.encodeURLwithParsing(context, strPartId);
}

  //boolean useDownloadApplet = true;
    
  boolean useDownloadApplet = Download.isAppletDownloadToBeTurnedOn(context , objectIds , action , fileName , format ,version ,request);
  
  emxCommonDocumentCheckoutData.put("useDownloadApplet", new Boolean(useDownloadApplet).toString());

// IR-086806V6R2012x
boolean haveError = (emxCommonDocumentCheckoutData.get("error.message") != null);
boolean haveWarning = (emxCommonDocumentCheckoutData.get("warning.message") != null);
if ( /* "checkout".equalsIgnoreCase(action) && */ (haveError || haveWarning)) {
    usageDialogWindow = true;
}
//

// IR-670955 : set to false for follwoing scenario
// In structure if an object does not have file then this value set to true and which lead to auto close of popup window.
//because of this download of files fails.
// by settings this flag to "false", we can download files from objects which has files attached.
if("true".equalsIgnoreCase(isExpandFromDEC))
	usageDialogWindow=false;
//IR-670955 : end of code

	boolean checkoutDirectoryEmpty = false;	
	if(useDownloadApplet){
		
	String userDefaultCheckoutFolder = PropertyUtil.getAdminProperty(
			context, DomainConstants.TYPE_PERSON, context.getUser(),
			"preference_DefaultCheckoutDirectory");
	
	if(UIUtil.isNullOrEmpty(userDefaultCheckoutFolder))
		userDefaultCheckoutFolder=EnoviaResourceBundle.getProperty(context,"emxFramework.DefaultCheckoutDirectory");

	
	userDefaultCheckoutFolder = FrameworkUtil.findAndReplace(
			userDefaultCheckoutFolder, "\\", "\\\\");
	checkoutDirectoryEmpty = UIUtil.isNullOrEmpty(userDefaultCheckoutFolder);
	}
%>

<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" language="JavaScript">
  if(<%=checkoutDirectoryEmpty%>){ 
	  alert("<%=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.Applet.CheckoutDirectoryEmpty")%>");	  
  }else if(<%=usageDialogWindow%>) {
     getTopWindow().showModalDialog("<%=forwardURL%>", 500, 500, true);
  }  else if (<%=useDownloadApplet%>) {
	// IR-158505: In case of checkout from pop (as for archive functionality), the showModalDialog() needs to be invoked on getTopWindow().getWindowOpener().getTopWindow().
	
    // IR-158505: In case of checkout from pop (as for archive functionality), the showModalDialog() needs to be invoked on getTopWindow().getWindowOpener().getTopWindow().
        if(<%=XSSUtil.encodeForJavaScript(context,isAppPreProcess)%>){
	         document.location.href="<%=forwardURL%>";
        }else if(getTopWindow().location.href.indexOf('emxNavigatorDialog.jsp') != -1 || getTopWindow().location.href.indexOf('emxNavigator.jsp') != -1){
			getTopWindow().showModalDialog("<%=forwardURL%>", 730, 450, true);
		}else if(getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow()){
		getTopWindow().getWindowOpener().getTopWindow().showModalDialog("<%=forwardURL%>", 730, 450, true);
	}else {
	  getTopWindow().showModalDialog("<%=forwardURL%>", 730, 450, true);
	}
  }  else {
     document.location.href="<%=forwardURL%>";
  }
</script>
<%
}else{
%>
<script type="text/javascript" language="JavaScript">
alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.InvalidOrNullObjectID</emxUtil:i18nScript>");
</script>
<%
}
%>

<%!
public static boolean isSpecRefDocument(Context context, String objId)throws Exception
{
	DomainObject dom = new DomainObject(objId);
	StringList sl = new StringList(2);
	sl.add("to["+DomainConstants.RELATIONSHIP_REFERENCE_DOCUMENT+"]");
	sl.add("to["+DomainConstants.RELATIONSHIP_PART_SPECIFICATION+"]");
	Map map = dom.getInfo(context, sl);
	String strRefRel = (String)map.get("to["+DomainConstants.RELATIONSHIP_REFERENCE_DOCUMENT+"]");
	String strSpecRel = (String)map.get("to["+DomainConstants.RELATIONSHIP_PART_SPECIFICATION+"]");
	return "true".equalsIgnoreCase(strRefRel) || "true".equalsIgnoreCase(strSpecRel);

}

%>


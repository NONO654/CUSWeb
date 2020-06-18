<%--  IEFReplaceResults.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import = "com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.* ,com.matrixone.MCADIntegration.server.cache.* " %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<html>
<head>
</head>
<script language="JavaScript" src="scripts/IEFUIConstants.js"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js"></script>
<script language="JavaScript">
function closeDialog()
{
	if(isIE_M)
	{
      parent.window.close();
	}
	else
	{
		if(top.opener && top.opener.parent)
		{
		  var parentWin = top.opener.parent;
		  parentWin.window.close();
		}
		parent.window.close();
	}
}
</script>
<%

MCADIntegrationSessionData intSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
Context context = intSessionData.getClonedContext(session);
MCADServerResourceBundle srvResourceBundle	= intSessionData.getResourceBundle();

%>
<body>
<form name="ReplaceResults">
<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<link rel="stylesheet" href="../integrations/styles/emxIEFCommonUI.css" type="text/css">
<input type=hidden name=mode value="">
<table border="0" cellpadding="0" cellspacing="0" width="100%">
 
<tr> 
 <th class=sorted colspan="3">
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.PrevDesignDetails")%></th></tr>
 </table>
 </th> 
 <th class=sorted colspan="3">
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.ParentDesignDetails")%></th></tr>
 </table>
 </th>
  <th class=sorted colspan="4">
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.ReplaceWithDesignDetails")%></th></tr>
 </table>
 </th> 
</tr>

<tr>
  <th class=sorted>
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Type")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Name")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Revision")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Type")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Name")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Revision")%></th></tr>
 </table>
 </th>
  <th class=sorted>
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Type")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Name")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Revision")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Remarks")%></th></tr>
 </table>
 </th>
</tr>



<%
   	String objectID		=Request.getParameter(request,"objectId");
	String headerKey	=Request.getParameter(request,"header");	
	String target		=Request.getParameter(request,"targetFrame");
	String selectedRows =Request.getParameter(request,"selectedRows");
	String integrationName		= "";
	String headerString			= "";
	MCADMxUtil util	            = null;

	Context _context = Framework.getFrameContext(session);
	MCADGlobalConfigObject globalConfigObject = null;
	

	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String acceptLanguage = request.getHeader("Accept-Language");
	
	if(integSessionData == null)
	{
		MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

        String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		emxNavErrorObject.addMessage(errorMessage);
	}
	else
	{
		if(target == null || "null".equalsIgnoreCase(target))
			target="popup";
	
		util	        = new MCADMxUtil(_context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());		
		integrationName	= util.getIntegrationName(_context, objectID);
        
		headerString		= integSessionData.getStringResource(headerKey);
		globalConfigObject  = integSessionData.getGlobalConfigObject(integrationName, _context);
		
	
	}
		Enumeration enumParamNames = emxGetParameterNames(request);
        HashMap paramMap = new HashMap();
        while(enumParamNames.hasMoreElements())
		{
                String paramName = (String) enumParamNames.nextElement();
                String paramValue = null;
                if(request.getMethod().equals("POST"))
				{
					paramValue = (String)emxGetParameter(request, paramName);
				}
                else 
				{
					paramValue = (String)emxGetParameter(request, paramName);
				}
               
			    
                if (paramValue != null && paramValue.trim().length() > 0 )
                    paramMap.put(paramName, paramValue);
        }
		
        String usrSelRowsForReplace = (String)paramMap.get("usrSelRowsForReplace");
		Hashtable childVsParent = new Hashtable();
		StringTokenizer tokens = new StringTokenizer(usrSelRowsForReplace,"~");
		while(tokens.hasMoreElements())
		{
		   	String parChildIds = (String)tokens.nextElement();
			StringTokenizer tildeToken = new StringTokenizer(parChildIds,"|");
			while(tildeToken.hasMoreElements()) //We will have 2 elements here.
			{
				String child = (String)tildeToken.nextElement();
				String parent =(String)tildeToken.nextElement();
				if(childVsParent.containsKey(child))
				{
					Vector parentList = (Vector)childVsParent.get(child);
					if(parentList.contains(parent) == false)
					{
						parentList.add(parent);
					}
					
				}
				else
				{
					Vector parentLst = new Vector();
					parentLst.add(parent);
					childVsParent.put(child,parentLst);
					
				}
			}
		}

        //The replace with is a major object always when searched using Designer search/collections!
        String replaceWith = (String)paramMap.get("replaceWith");

        //Get the TNR for the replaceWith's major object
		BusinessObject replaceWithObj = new BusinessObject(replaceWith);
		replaceWithObj.open(_context);
		String replaceWithVersionObjectType = replaceWithObj.getTypeName();
		String replaceWithVersionObjectName = replaceWithObj.getName();
		String replaceWithVersionObjectRevision = replaceWithObj.getRevision();
		//Check if the replace with object is a major object. If yes, then 
		//check if it has any  minor that a finalized relationship with its
		//major(self).  If it has any finalized relationship then use the major object.
		//else then use the active minor of the selected major.
		String languageStr = acceptLanguage;
		String localeLanguage = (String) paramMap.get("LocaleLanguage");
		MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(localeLanguage);
		IEFGlobalCache cache = new IEFGlobalCache();
		MCADServerGeneralUtil _generalUtil = new MCADServerGeneralUtil(_context,globalConfigObject,serverResourceBundle,cache);
        //Get the major obj from the minor
        BusinessObject replaceWithMajorObj = util.getMajorObject(_context,replaceWithObj);
		boolean isFinalized = false;
		String searchType = (String)paramMap.get("searchType");

		if( replaceWithMajorObj == null && ( searchType.equals("designer") || searchType.equals("collections") ) )
		{
			//The user selected replaceWithObj is a major object
			//For this major object check if it has any finalized minor.
			isFinalized = _generalUtil.isBusObjectFinalized(_context,replaceWithObj);
			if(!isFinalized)//If the major object is not finalised use its active minor.
			{
				String activeMinorID = util.getActiveVersionObject(_context,replaceWithObj.getObjectId());
				BusinessObject activeMinorIDObj = new BusinessObject(activeMinorID);
				activeMinorIDObj.open(_context);
				replaceWithVersionObjectType = activeMinorIDObj.getTypeName();
				replaceWithVersionObjectName = activeMinorIDObj.getName();
				replaceWithVersionObjectRevision = activeMinorIDObj.getRevision();
				activeMinorIDObj.close(_context);
				//Set the value of replacewith 
				replaceWith = activeMinorIDObj.getObjectId();
			}
		}
		else
		{
			if(searchType.equals("manual") )
			{
				BusinessObject replaceWithMajorObject = util.getMajorObject(_context,replaceWithObj);
				if(null!=replaceWithMajorObject) //If major object
				{
					//Set the value to the minor object as the user typed in.
					replaceWith = replaceWithObj.getObjectId();
					replaceWithVersionObjectType = replaceWithObj.getTypeName();
					replaceWithVersionObjectName = replaceWithObj.getName();
					replaceWithVersionObjectRevision = replaceWithObj.getRevision();
				}
				else
				{
					//You got a major object. 
					//Check if it is finalized. If yes then use the major object.
					//If not finalized find the active minor and use it.
					isFinalized = _generalUtil.isBusObjectFinalized(_context,replaceWithObj);
					if(!isFinalized)//If the major object is not finalised use its active minor.
					{
						String activeMinorID = util.getActiveVersionObject(_context,replaceWithObj.getObjectId());
						BusinessObject activeMinorIDObj = new BusinessObject(activeMinorID);
						activeMinorIDObj.open(_context);
						replaceWithVersionObjectType = activeMinorIDObj.getTypeName();
						replaceWithVersionObjectName = activeMinorIDObj.getName();
						replaceWithVersionObjectRevision = activeMinorIDObj.getRevision();
						activeMinorIDObj.close(_context);
						//Set the value of replacewith 
						replaceWith = activeMinorIDObj.getObjectId();
					}
					else
					{
						replaceWith = replaceWithObj.getObjectId();
						System.out.println("Manual Finalized Major replaceWith value is " + replaceWith);
					}
				}
			}
	    }
		replaceWithObj.close(_context);
        paramMap.put("languageStr",acceptLanguage);
		HashMap gcoMap			= new HashMap();
		gcoMap.put(integrationName, globalConfigObject);
		paramMap.put("GCOTable", gcoMap);
		paramMap.put("IntegrationName",integrationName);
		paramMap.put("ChildVsParentForReplace",childVsParent);
		paramMap.put("replaceWith",replaceWith);

		String[] intArgs = new String[]{};
		//---Need to fire the JPO and get the table.
		Hashtable replaceResults = (Hashtable)JPO.invoke(_context, "DSCReplace", intArgs, "replace",        									                                 JPO.packArgs(paramMap), Hashtable.class);
	    Enumeration keys = childVsParent.keys();
		while(keys.hasMoreElements())
		{
		  	String child  = (String)keys.nextElement();

			BusinessObject childObj = new BusinessObject(child);
			childObj.open(_context);
			String currentVersionObjectType = childObj.getTypeName();
			String currentVersionObjectName = childObj.getName();
			String currentVersionObjectRevision = childObj.getRevision();
			childObj.close(_context);

			String Remark = "";
		   	Vector parentList = (Vector)childVsParent.get(child);
			for(int k=0;k<parentList.size();k++)
			{
                String parent = (String)parentList.get(k);
				BusinessObject parentObj = new BusinessObject(parent);
				parentObj.open(_context);
				String parentVersionObjectType = parentObj.getTypeName();
				String parentVersionObjectName = parentObj.getName();
				String parentVersionObjectRevision = parentObj.getRevision();
				parentObj.close(_context);
				String masterKey = child+parent+replaceWith;
				Remark = (String) replaceResults.get(masterKey);
 %>
   <tr>
   <!--XSSOK-->
   <td align="center" class=node>&nbsp;<%=MCADMxUtil.getNLSName(_context, "Type", currentVersionObjectType, "", "" , acceptLanguage)%></td>
   <td align="center" class=node>&nbsp;<xss:encodeForHTML><%=currentVersionObjectName%></xss:encodeForHTML></td>
   <td align="center" class=node>&nbsp;<xss:encodeForHTML><%=currentVersionObjectRevision%></xss:encodeForHTML></td>

   <!--XSSOK-->
   <td align="center" class=node>&nbsp;<%=MCADMxUtil.getNLSName(_context, "Type", parentVersionObjectType, "", "" , acceptLanguage)%></td>
   <td align="center" class=node>&nbsp;<xss:encodeForHTML><%=parentVersionObjectName%></xss:encodeForHTML></td>
   <td align="center" class=node>&nbsp;<xss:encodeForHTML><%=parentVersionObjectRevision%></xss:encodeForHTML></td>

   <!--XSSOK-->
   <td align="center" class=node>&nbsp;<%=MCADMxUtil.getNLSName(_context, "Type", replaceWithVersionObjectType, "", "" , acceptLanguage)%></td>
   <td align="center" class=node>&nbsp;<xss:encodeForHTML><%=replaceWithVersionObjectName%></xss:encodeForHTML></td>
   <td align="center" class=node>&nbsp;<xss:encodeForHTML><%=replaceWithVersionObjectRevision%></xss:encodeForHTML></td>
   <!--XSSOK-->
   <td align="center" class=node>&nbsp;<%=Remark%></td>
   </tr>
    <%
			}
   %>
   <%
			
		}
 %>
  </tr>
</table>
</form>
</body>
</html>

<%--  DSCWhereUsedFilter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ include file ="MCADTopInclude.inc" %>
<%@ page import = "java.util.*,java.util.Set,matrix.db.*,matrix.util.*,com.matrixone.servlet.*" isErrorPage="true"%>
<%@ page import = "com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*" %>
<%@ page import="com.matrixone.apps.domain.util.*,com.matrixone.apps.domain.*" %>
<%@ page import="com.matrixone.apps.common.*" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);

Context context								= integSessionData.getClonedContext(session);

%>

<%
	MapList revisionVersionsList		= null;
	String tableID						= Request.getParameter(request, "tableID");
	HashMap requestMap					= (HashMap) tableBean.getTableData(tableID).get("RequestMap");
	String sObjectId					= (String) requestMap.get("objectId");

    String SELECT_ACTIVE_VERSION_ID		= "";
	HashMap majorIdMinorIdsTable		= new HashMap();
	HashMap majorIdActiveVersionTable	= new HashMap();
	HashMap majorRevisionsVersionsTable = new HashMap();
	HashMap busIdRevisionMap			= new HashMap();
	HashMap minorIdMajorIdTable			= new HashMap();
	ArrayList finalizedMajors			= new ArrayList();
	boolean isVersioningEnabled			= true;
	String defaultRevision				= "*";
	String defaultVersion				= "*";

	MCADServerResourceBundle serverResourceBundle = null;

    if (null != sObjectId)
    {
        try
        {
	//		MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);

			serverResourceBundle						= integSessionData.getResourceBundle();

	//		Context context								= integSessionData.getClonedContext(session);
			MCADMxUtil util								= new MCADMxUtil(context, integSessionData.getLogger(), serverResourceBundle, integSessionData.getGlobalCache());
			StringList selectables = new StringList();
			selectables.add(DomainObject.SELECT_ID);
			selectables.add("physicalid");
			DomainObject doObj = DomainObject.newInstance(context,sObjectId);
			Map objInfo = doObj.getInfo(context, selectables);			
			String sPhyId = (String) objInfo.get("physicalid");
			if(sPhyId.equals(sObjectId)){
				sObjectId = (String) objInfo.get(DomainObject.SELECT_ID);
			}
			String integrationName						= util.getIntegrationName(context, sObjectId);
			MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);

			isVersioningEnabled							= globalConfigObject.isCreateVersionObjectsEnabled();

			String	REL_ACTIVE_VERSION					= util.getActualNameForAEFData(context, "relationship_ActiveVersion");
			SELECT_ACTIVE_VERSION_ID					= "from[" + REL_ACTIVE_VERSION + "].to.id";

			String jpoName								= "DSCWhereUsed";
			String jpoMethod							= "getAllRevisionAndVersions";

			HashMap paramMap = new HashMap();
			paramMap.put("objectId", sObjectId);
			paramMap.put("GCO", globalConfigObject);
			paramMap.put("LCO", integSessionData.getLocalConfigObject());
			paramMap.put("languageStr", serverResourceBundle.getLanguageName());

			// get all the revision/version list
            revisionVersionsList = (MapList)JPO.invoke(context, jpoName, new String[0], jpoMethod, JPO.packArgs(paramMap), MapList.class);

			if(revisionVersionsList != null)
			{
				for(int i = 0; i < revisionVersionsList.size(); i++)
				{
					Map majorDetails			= (Map) revisionVersionsList.get(i);
					String majorId				= (String) majorDetails.get("id");
					String majorRevision		= (String) majorDetails.get("revision");
					MapList minorObjectsDetails = (MapList) majorDetails.get("versions");

					ArrayList minorIdsList		= new ArrayList(minorObjectsDetails.size());
					ArrayList minorVersionsList	= new ArrayList(minorObjectsDetails.size());

					busIdRevisionMap.put(majorId, majorRevision);

					for(int j = 0; j < minorObjectsDetails.size(); j++)
					{
						Map minorDetails	= (Map) minorObjectsDetails.get(j);
						String minorId		= (String) minorDetails.get("id");
						String minorVersion	= (String) minorDetails.get("version");

						busIdRevisionMap.put(minorId, minorVersion);
						minorIdMajorIdTable.put(minorId, majorId);
						minorVersionsList.add(minorVersion);
						minorIdsList.add(minorId);
					}

					majorRevisionsVersionsTable.put(majorRevision, minorVersionsList);
					majorIdMinorIdsTable.put(majorId, minorIdsList);
				}
			}

			Set majorIds			= majorIdMinorIdsTable.keySet();
			StringList busSelects	= new StringList();
			busSelects.add("id");
			busSelects.add("policy");
			busSelects.add("current");
			busSelects.add("state");
			busSelects.add(SELECT_ACTIVE_VERSION_ID);

			String [] oids = new String [majorIds.size()];
			majorIds.toArray(oids);

			BusinessObjectWithSelectList busWithSelectList = BusinessObjectWithSelect.getSelectBusinessObjectData(context, oids, busSelects);

			for(int i = 0; i < busWithSelectList.size(); i++)
			{
				BusinessObjectWithSelect busWithSelect = busWithSelectList.getElement(i);
				String id							   = busWithSelect.getSelectData("id");
				String policy 						   = busWithSelect.getSelectData("policy");
				String currentState 				   = busWithSelect.getSelectData("current");
				StringList stateList 				   = busWithSelect.getSelectDataList("state");
				String activeVersionId                 = busWithSelect.getSelectData(SELECT_ACTIVE_VERSION_ID);

				String finalizationState			   = globalConfigObject.getFinalizationState(policy);

				if(stateList.lastIndexOf(currentState) >= stateList.lastIndexOf(finalizationState))
				{
					finalizedMajors.add(id);
					String majorRev		= (String) busIdRevisionMap.get(id);
					String minorRev		= (String) busIdRevisionMap.get(activeVersionId);

					ArrayList minorRevList = (ArrayList) majorRevisionsVersionsTable.get(majorRev);
					minorRevList.remove(minorRev);
					minorRevList.add(" ");

					busIdRevisionMap.put(activeVersionId, " ");
				}

				majorIdActiveVersionTable.put(id, activeVersionId);
			}

			if(majorIdMinorIdsTable.containsKey(sObjectId))
			{
				//major
				defaultRevision = (String) busIdRevisionMap.get(sObjectId);
				if(finalizedMajors.contains(sObjectId))
				{
					 defaultVersion = " ";
				}
				else
				{
					String activeVersionid	= (String) majorIdActiveVersionTable.get(sObjectId);
					defaultVersion			= (String) busIdRevisionMap.get(activeVersionid);
				}

			}
			else
			{
				//minor
				String majorId  = (String) minorIdMajorIdTable.get(sObjectId);
				defaultRevision = (String) busIdRevisionMap.get(majorId);
				defaultVersion	= (String) busIdRevisionMap.get(sObjectId);

				if(defaultVersion.equals(" "))
				{
					//finalized minor
					sObjectId = majorId;
				}
			}
		}
        catch (Exception e)
        {

        }
    }
%>
<html>
<head>
<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<script language="JavaScript">

var revArray		= new Array();
 //XSSOK
var defaultRevision	= "<%=defaultRevision%>";
//XSSOK
var defaultVersion	= "<%=defaultVersion%>";

<%
	 Iterator majorRevItr = majorRevisionsVersionsTable.keySet().iterator();
     // fill up the client array for revision/version selection
     while (majorRevItr.hasNext())
     {
		 String majorRev	 = (String) majorRevItr.next();
%>
		 var versionArray	=  new Array();
<%
		 ArrayList versions = (ArrayList)majorRevisionsVersionsTable.get(majorRev);

         for (int k = 0; k < versions.size(); k++)
         {
             String version = (String)versions.get(k);
%>
             //XSSOK
             versionArray[<%=k%>] = '<%=version%>';
<%
          }
%>
          //XSSOK
          revArray['<%=majorRev%>'] = versionArray;
<%
     }
%>


function onLevelChange(levelStr)
{
  if (levelStr == 'All' || levelStr == 'Highest')
  {
     document.filterIncludeForm.showLevel.value = '';
	 document.filterIncludeForm.showLevel.disabled = true;
  }
  else
  {
     document.filterIncludeForm.showLevel.value = '1';
	 document.filterIncludeForm.showLevel.disabled = false;
  }
}

function onViewChange(designVersionStr)
{
   if (designVersionStr == 'AsStored' || designVersionStr == 'As-Built')
   {
      document.filterIncludeForm.filterRevisionList.disabled = false;
      document.filterIncludeForm.filterVersionList.disabled = false;

	  return true;
   }
   else if (designVersionStr == 'LatestRevision' || designVersionStr == 'LatestVersion'|| designVersionStr == 'ConnectedLatestRevision')
   {
	   var selectedRevision = document.filterIncludeForm.filterRevisionList.options[document.filterIncludeForm.filterRevisionList.selectedIndex].value;

	   if(defaultRevision != selectedRevision)
	   {
		   for (i = 0; i < document.filterIncludeForm.filterRevisionList.length; i++)
			{
			  if (document.filterIncludeForm.filterRevisionList.options[i].value == defaultRevision)
				{
					document.filterIncludeForm.filterRevisionList.selectedIndex = i;
					break;
				}
			}

		   onRevisionChange(defaultRevision);
	   }

	   document.filterIncludeForm.filterRevisionList.disabled = true;
	   document.filterIncludeForm.filterVersionList.disabled  = true;
//XSSOK
	   if("<%=isVersioningEnabled%>" == "true")
	   {
		   if(defaultVersion != " ")
				document.filterIncludeForm.filterVersionList.selectedIndex = document.filterIncludeForm.filterVersionList.options[defaultVersion].index;
		   else
		   {
				for (i = 0; i < document.filterIncludeForm.filterVersionList.length; i++)
				{
				  if (document.filterIncludeForm.filterVersionList.options[i].value == defaultVersion)
					 document.filterIncludeForm.filterVersionList.selectedIndex = i;
				}
		   }
	   }
   }
}

function onSubmit(level, designVersion, revList, verList)
{
var frame	= findFrame(parent ,"listDisplay");
var listHiddenFrame	= findFrame(parent ,"listHidden");
   var showLevel	= document.filterIncludeForm.showLevel.value;
   //XSSOK
   var tableID     = "<%= tableID %>";
   //XSSOK
   var objectId     = "<%= sObjectId %>";
   var curFilter = '';
   var relName = '';
   level += ':' + document.filterIncludeForm.showLevel.value;
   level = 'filterLevel=' + level;
   var designVersions = 'filterDesignVersion=' + designVersion;
   curFilter += level + '|' + designVersions;
   if (revList != null)
   {
       curFilter += '|' + 'filterRev=' + revList;
   }
   if (verList != null)
   {
       curFilter += '|' + 'filterVer=' + verList;
   }
   actionURL ="../integrations/DSCWhereUsedFilterProcess.jsp?tableID="+ tableID + "&filterLevel=" + level + "&filterDesignVersion=" + designVersion + "&filterVersionList=" + verList +"&filterRevisionList=" + revList + "&showLevel="+ showLevel + "&objectId=" + objectId;
   listHiddenFrame.location.href = actionURL;
}

function clearVersionList()
{
   for (var i=document.filterIncludeForm.filterVersionList.options.length-1; i>=0; i--)
   {
	   document.filterIncludeForm.filterVersionList.options[i] = null;
   }

   document.filterIncludeForm.filterVersionList.selectedIndex = -1;
}

function fillVersionList(arr)
{
	for (var i = 0; i < arr.length; i++)
	{
		document.filterIncludeForm.filterVersionList.options[document.filterIncludeForm.filterVersionList.options.length] =	new Option(arr[i], arr[i]);
		document.filterIncludeForm.filterVersionList.options[i].name = arr[i];
	}
}


function onRevisionChange(revSelected)
{
   var str		= '';
   var version	= '';
   var revision = '';
   if (revSelected == null)
       return true;
//XSSOK
	if("<%=isVersioningEnabled%>" == "true" && document.filterIncludeForm.filterVersionList.disabled == false)
	{
	   var versionArraySelected = new Array();
	   clearVersionList();
	   versionArraySelected = new Array();
	   var arr = revArray[revSelected];

	   if (arr != null)
	   {
		   for (var i = 0; i < arr.length; i++)
		   {
			   versionArraySelected[i] = arr[i];
		   }
	   }

	   versionArraySelected[versionArraySelected.length] = '*';

	   fillVersionList(versionArraySelected);

       document.filterIncludeForm.filterVersionList.selectedIndex = 0;
	}

}
</script>
</head>
<body>
  <form name="filterIncludeForm" method="post">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

  <table border="0">
  <tr><td><img src="../common/images/utilSpacer.gif" width="1" height="5" alt=""></td></tr>
  </table>
  <table border="0">

    <tr>
      <td class="filter">
         <table border="0">
       <tr>
	       <td>
	             &nbsp;
	       </td>
	       <td>
	 <!--XSSOK-->
         <%=serverResourceBundle.getString("mcadIntegration.Server.FieldName.ShowLevels")%>
	       </td>
	       <td>
	            &nbsp;
	       </td>
	       <td>
         <select name="filterLevel" id="filterLevel" onChange="javascript:onLevelChange(filterLevel.options[filterLevel.selectedIndex].value);return true;">
            <!--XSSOK-->
            <option value="All"><%=serverResourceBundle.getString("mcadIntegration.Server.FieldName.All")%></option>
            <!--XSSOK-->
            <option value="Highest"><%=serverResourceBundle.getString("mcadIntegration.Server.FieldName.Highest")%></option>
	    <!--XSSOK-->
            <option selected value="UpTo"><%=serverResourceBundle.getString("mcadIntegration.Server.FieldName.Upto")%></option>
         </select>
	       </td>
	       <td>
	             &nbsp;
	       </td>
	       <td>
         <input type="text" name="showLevel" onkeypress="if (event.keyCode == 13) { filterIncludeForm.execute.click(); return false; }" size="2" value="1">
	       </td>
	       <td>
	            &nbsp;
	       </td>
       </tr>
         </table>
      </td>
      <td><img src="../common/images/utilSpacer.gif" width="1" height="5" alt=""></td>
      <td class="filter">
	 <!--XSSOK-->
         <%=serverResourceBundle.getString("mcadIntegration.Server.FieldName.DesignVersion")%>
         <select name="filterDesignVersion" id="filterDesignVersion" onChange="javascript:onViewChange(filterDesignVersion.options[filterDesignVersion.selectedIndex].value);return true;">
            <!--XSSOK-->
            <option value="<%=MCADAppletServletProtocol.VIEW_AS_BUILT%>"><%=serverResourceBundle.getString("mcadIntegration.Server.FieldName."+MCADAppletServletProtocol.VIEW_AS_BUILT)%></option>
            <!--XSSOK-->
            <option value="LatestVersion"><%=serverResourceBundle.getString("mcadIntegration.Server.FieldName.LatestVersion")%></option>
            <!--XSSOK-->
            <option value="LatestRevision"><%=serverResourceBundle.getString("mcadIntegration.Server.FieldName.LatestRevision")%></option>
			<option value="<%=MCADAppletServletProtocol.VIEW_CONNECTED_LATEST_REVISION%>"><%=serverResourceBundle.getString("mcadIntegration.Server.FieldName.LatestConnectedRevision")%></option>

         </select>
         <img src="../common/images/utilSpacer.gif" width="1" height="5" alt="">
      </td>
      <td class="filter">
	 <!--XSSOK-->
         <%=serverResourceBundle.getString("mcadIntegration.Server.FieldName.Revisions")%>
      <select name="filterRevisionList" id="filterRevisionList" onChange="javascript:onRevisionChange(filterRevisionList.options[filterRevisionList.selectedIndex].value);return true;">
<%
	  Iterator majorRevisionsItr = majorRevisionsVersionsTable.keySet().iterator();

      while (majorRevisionsItr.hasNext())
      {

		  String majorRev	 = (String) majorRevisionsItr.next();
		  if (defaultRevision.startsWith(majorRev))
		  {
%>
				<option selected name="<%=majorRev%>" value="<xss:encodeForHTMLAttribute><%=majorRev%></xss:encodeForHTMLAttribute>"><%=majorRev%></option>
<%
		  }
          else
		  {
%>
				<option name="<%=majorRev%>" value="<xss:encodeForHTMLAttribute><%=majorRev%></xss:encodeForHTMLAttribute>"><%=majorRev%></option>
<%
          }
      }
%>
		<option name="*" value="*">*</option>
      </select>
         <img src="../common/images/utilSpacer.gif" width="1" height="5" alt="">
      </td>
<%
if(isVersioningEnabled)
{
%>
      <td class="filter">
	  <!--XSSOK-->
         <%=serverResourceBundle.getString("mcadIntegration.Server.FieldName.Versions")%>
         <select name="filterVersionList" id="filterVersionList">
<%
	  ArrayList versions = (ArrayList)majorRevisionsVersionsTable.get(defaultRevision);

      for (int k = 0; k < versions.size(); k++)
      {
            String minorVer = (String)versions.get(k);

            if (defaultVersion.equals(minorVer))
			{
%>
               <option selected name="<%=minorVer%>" value="<xss:encodeForHTMLAttribute><%=minorVer%></xss:encodeForHTMLAttribute>"><%=minorVer%></option>
<%
			}
            else
			{
%>
               <option name="<%=minorVer%>" value="<xss:encodeForHTMLAttribute><%=minorVer%></xss:encodeForHTMLAttribute>"><%=minorVer%></option>
<%
            }
         }
%>
			<option name="*" value="*">*</option>
         </select>
         &nbsp;
      </td>
<%
}
else
{
%>
         <input type="hidden" name="filterVersionList" id="filterVersionList">
<%
}
%>
      <td>
	<!--XSSOK-->
        <input type="button" name="execute" value="<%=serverResourceBundle.getString("mcadIntegration.Server.FieldName.Refresh")%>" onClick="javascript:onSubmit(filterLevel.options[filterLevel.selectedIndex].value,filterDesignVersion.options[filterDesignVersion.selectedIndex].value,filterRevisionList.options[filterRevisionList.selectedIndex].value,(filterVersionList != null && filterVersionList.selectedIndex >= 0) ? filterVersionList.options[filterVersionList.selectedIndex].value : null);">
      </td>
    </tr>

  </table>
  <input type="hidden" name="tableId" value="1">
  <input type="hidden" name="sortColumnName" value="level">
  </form>

</body>
</html>

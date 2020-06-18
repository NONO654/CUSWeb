

<%-- Common Includes --%>
<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.program.ResourcePlan"%>
<%@page import="com.matrixone.apps.program.ResourceRequest"%>
<%@page import="com.matrixone.apps.framework.ui.UITableCommon"%>
<%@page import="com.matrixone.apps.common.Task"%>
<%@page import="matrix.util.*"%>
<%@page import="com.matrixone.apps.domain.util.PolicyUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.apps.program.FTE"%>
<%@page import="com.matrixone.apps.program.ProjectSpace"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@page import="com.matrixone.apps.domain.util.eMatrixDateFormat"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="java.util.*"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>


<%@page import="matrix.db.MQLCommand"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>


<%
	boolean bFlag = false;
	try 
	{
		String languageStr = context.getSession().getLanguage();
		String strMode = emxGetParameter(request, "mode");
		String projectId = emxGetParameter(request, "objectId");
		projectId = XSSUtil.encodeURLForServer(context, projectId);
		String strReturnResult = "";
		StringBuffer sBuff = new StringBuffer();
		String strSubMode = emxGetParameter(request, "submode");
		String strFTESpanInMonths = EnoviaResourceBundle.getProperty(context,"emxProgramCentral.ResourcePlanTable.FTESpanInMonths");
		String strFTESpanFWDMonths = EnoviaResourceBundle.getProperty(context, "emxProgramCentral.ResourcePlanTable.FTESpanFWDMonths");
		String strFTESpanBWDMonths = EnoviaResourceBundle.getProperty(context,"emxProgramCentral.ResourcePlanTable.FTESpanBWDMonths");
		String strPageHeading = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourcePool.PeopleSummary", languageStr);
		if (("createclone").equals(strMode)) 
		{
            %>
            <script language="javascript" type="text/javaScript">
             //window.parent.location.href = "../common/emxFullSearch.jsp?table=PMCGeneralSearchResults&field=TYPES=type_ProjectSpace&selection=single&excludeOIDprogram=emxWhatIf:excludeExperimentProject&txtExcludeOIDs=<%=projectId%>&submitURL=../programcentral/emxProgramCentralResourceRequestUtil.jsp?mode=preCreateCloneRequest&objectId=<%=projectId%>";
            var searchUrl = "../common/emxFullSearch.jsp?table=PMCGeneralSearchResults&field=TYPES=type_ProjectSpace&selection=single&excludeOIDprogram=emxWhatIf:excludeExperimentProject&txtExcludeOIDs=<%=projectId%>&submitURL=../programcentral/emxProgramCentralResourceRequestUtil.jsp?mode=postCreateCloneRequest&objectId=<%=projectId%>";
            showModalDialog(searchUrl, "812", "700", "true", "popup");
            </script>
            <%
        } 
		else if (("preCreateCloneRequest").equals(strMode)) 
		{
			String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
			String strTokenId = "";
			String strSelectedProjectSpaceID = "";
			String strFromProjectSpaceID = emxGetParameter(request,"objectId");
			if (strTableRowId == null || strTableRowId.length == 0) 
			{
				String strLanguage = context.getSession().getLanguage();
				String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
		        		"emxProgramCentral.ResourceRequest.SelectProjectSpace", strLanguage);
                %>
                <script language="JavaScript" type="text/javascript">
                alert("<%=sErrMsg%>");
                </script>
                <%
               	return;
   			} 
			else 
			{
			    for (int i = 0; i < strTableRowId.length; i++) 
			    {
			        java.util.StringTokenizer strTokenizer = new java.util.StringTokenizer(strTableRowId[i], "|");
			        int nTokenCount = strTokenizer.countTokens();
                	for (int j = 0; j < nTokenCount; j++) 
                	{
               		   strTokenId = strTokenizer.nextToken();
               		   if (j == 0)
               		   {
               			   strSelectedProjectSpaceID = strTokenId;
               		   }
               		}
  				}
           }
           %>
           <script language="javascript" type="text/javaScript">
           getTopWindow().resizeTo(750,600);//because the full search windows is very wide
           getTopWindow().location.href = "../common/emxForm.jsp?form=PMCResourceRequestCloneForm&formHeader=emxProgramCentral.Common.CreateNewClonedResourceRequest&suiteKey=ProgramCentral&mode=edit&postProcessURL=../programcentral/emxProgramCentralResourceRequestUtil.jsp?mode=postCreateCloneRequest&fromProjectSpaceId=<%=XSSUtil.encodeForURL(context,strFromProjectSpaceID)%>&toProjectSpaceId=<%=XSSUtil.encodeForURL(context,strSelectedProjectSpaceID)%>&objectId=<%=XSSUtil.encodeForURL(context,strSelectedProjectSpaceID)%>";
           </script>
           <%
        } 
		else if (("postCreateCloneRequest").equals(strMode)) 
		{
			String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
			strTableRowId = ProgramCentralUtil.parseTableRowId(context, strTableRowId);
			String toProjectSpaceId = strTableRowId[0];
		    String fromProjectSpaceId = emxGetParameter(request,"objectId");
			
		    HashMap paramMap = new HashMap();
            paramMap.put("projectFromId", fromProjectSpaceId);
            paramMap.put("projectToId", toProjectSpaceId);
            paramMap.put("Resource", null);  // Resources should not be copied while cloning the resource request.
            paramMap.put("BSkill", ProgramCentralConstants.EMPTY_STRING);
            paramMap.put("PRole", ProgramCentralConstants.EMPTY_STRING);
            paramMap.put("standardCost", ProgramCentralConstants.EMPTY_STRING);
            ResourcePlan resourceBean = new ResourcePlan();
            resourceBean.cloneResourcePlan(context, paramMap);
            %>
            <script language="javascript">
             var resourcePlanFrame=findFrame(getTopWindow().getWindowOpener().getTopWindow(), "PMCResourcePlan");				
             resourcePlanFrame.location.href=resourcePlanFrame.location.href;
			 getTopWindow().closeWindow();
            </script>
            <%
        }
		else if (("WBSRequest").equals(strMode)) 
		{
			String strOrganizationId = "";
			String strTextOrganization = "";
			String strTextOrganizationValue = "";
			strTextOrganization = emxGetParameter(request, "txtName");
			strTextOrganizationValue = emxGetParameter(request,"txtValue");
			strOrganizationId = emxGetParameter(request,"emxTableRowId");
			java.util.StringTokenizer strTokenizer = new java.util.StringTokenizer(strOrganizationId, "|");
			strOrganizationId = strTokenizer.nextToken();
			DomainObject dom = new DomainObject(strOrganizationId);
			String strOrganizationDisplayName = dom.getName(context);
            %>
            <script language="javascript" type="text/javaScript">
            var vOrganizationNameDisplay = window.parent.getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,strTextOrganization)%>");
            vOrganizationNameDisplay[0].value ="<%=strOrganizationDisplayName%>" ; <%-- XSSOK --%>
            var vOrganizationValue = window.parent.getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,strTextOrganizationValue)%>");
            vOrganizationValue[0].value ="<%=XSSUtil.encodeForJavaScript(context,strOrganizationId)%>" ;
            window.parent.closeWindow();
            </script>
            <%
        }
		else if (("WBSRequestSkill").equals(strMode)) 
		{
			String strTextBusinessSkill = "";
			String strTextBusinessSkillName = "";
			String strTextBusinessSkillValue = "";
			String strTextBusinessSkillId = "";
			strTextBusinessSkillName = emxGetParameter(request,"txtName");
			strTextBusinessSkillId = emxGetParameter(request,"txtValue");
			String[] strBSkillIds = emxGetParameterValues(request,"emxTableRowId");
			String strObjname = "";
			String strObjvalue = "";
			int tableRowlen = strBSkillIds.length;
			StringList slBusinessSkill = new StringList();
			StringList slBusinessSkillId = new StringList();
			for (int i = 0; i < tableRowlen; i++) 
			{
				StringList splitObject = com.matrixone.apps.domain.util.FrameworkUtil.split(strBSkillIds[i], "|");
				Search search = new Search();
				int cnt = splitObject.size();
				strObjname = search.getObjectName(context,(String) splitObject.get(0));
				strObjvalue = (String) splitObject.get(0);
				slBusinessSkill.add(strObjname);
				slBusinessSkillId.add(strObjvalue);
			}
			if (slBusinessSkill.size() > 1) 
			{
				strTextBusinessSkill = FrameworkUtil.join(slBusinessSkill, ",");
				strTextBusinessSkillValue = FrameworkUtil.join(slBusinessSkillId, ",");
			}
			else 
			{
				strTextBusinessSkill = strObjname;
				strTextBusinessSkillValue = strObjvalue;
			}
            %>
            <script language="javascript" type="text/javaScript">
            var vBusinessSkillNameDisplay = window.parent.getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,strTextBusinessSkillName)%>");
            vBusinessSkillNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strTextBusinessSkill)%>" ;
            var vBusinessSkillValue = window.parent.getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,strTextBusinessSkillId)%>"); <%-- XSSOK --%>
            vBusinessSkillValue[0].value ="<%=XSSUtil.encodeForJavaScript(context,strTextBusinessSkillValue)%>" ;
            getTopWindow().closeWindow();
            </script>
            <%
        }
		else if (("createWBS").equals(strMode)) 
		{
			String strProjectRole = null;
			String strOrganizationId = null;
			String strOrganizationName = null;
			String strprojectObjectId = (String) emxGetParameter(request, "objectId");
			String[] slTableRowIds = emxGetParameterValues(request,"emxTableRowId");
			String strBusinessId = "";
			FTE fte = FTE.getInstance(context);
			MapList mlFTE = null;
			Map mapFTE = null;
			DomainObject dmoProject = DomainObject.newInstance(context,strprojectObjectId);
			final String SELECT_ATTRIBUTE_TASK_ESTIMATED_START_DATE = "attribute["+ DomainConstants.ATTRIBUTE_TASK_ESTIMATED_START_DATE+ "]";
			final String SELECT_ATTRIBUTE_TASK_ESTIMATED_FINISH_DATE = "attribute["+ DomainConstants.ATTRIBUTE_TASK_ESTIMATED_FINISH_DATE+ "]";
			StringList slBusSelect = new StringList();
			slBusSelect.add(SELECT_ATTRIBUTE_TASK_ESTIMATED_START_DATE);
			slBusSelect.add(SELECT_ATTRIBUTE_TASK_ESTIMATED_FINISH_DATE);
			String strStartDate = "";
			String strFinishtDate = "";
			Map mapObjInfo = dmoProject.getInfo(context, slBusSelect);
			strStartDate = (String) mapObjInfo.get(SELECT_ATTRIBUTE_TASK_ESTIMATED_START_DATE);
			strFinishtDate = (String) mapObjInfo.get(SELECT_ATTRIBUTE_TASK_ESTIMATED_FINISH_DATE);
			Date dtStartDate = eMatrixDateFormat.getJavaDate(strStartDate);
			Date dtFinishDate = eMatrixDateFormat.getJavaDate(strFinishtDate);
			Calendar calStartDate = Calendar.getInstance();
			Calendar calFinishDate = Calendar.getInstance();
			calStartDate.setTime(dtStartDate);
			calFinishDate.setTime(dtFinishDate);
			int nFTESpanInMonths = 0;
			int nMonth = 0;
			int nYear = 0;
			int nFinishMonth = 0;
			int nFinishYear = 0;
			int nNumberOfMonths = 0;
			int nMonthCounter = 0;
			int nYearCounter = 0;

			nYear = calStartDate.get(Calendar.YEAR);
			nFinishYear = calFinishDate.get(Calendar.YEAR);
			nMonth = calStartDate.get(Calendar.MONTH) + 1; //0=January
			nFinishMonth = calFinishDate.get(Calendar.MONTH) + 1;//0=January
			MapList mlFTEMonthYearList = null;
			mlFTEMonthYearList = fte.getTimeframes(dtStartDate,dtFinishDate);
			nFTESpanInMonths = mlFTEMonthYearList.size();
			String strMonthYear = "";
			String strFTE = "";

			int nCntRequest = Integer.parseInt(emxGetParameter(request,"cntRequest"));
			if (slTableRowIds != null) 
			{
				MapList mlRequestList = new MapList();
				HashMap finalRequestMap = null;
				boolean confirmFlag = false;
				for (int k = 0; k < slTableRowIds.length; k++) 
				{
					String strTaskObj = (String) emxGetParameter(request, "Taskobj" + slTableRowIds[k]);
					int nTaskOdj = Integer.parseInt(strTaskObj);
					Map mapObject = new HashMap();
					mlFTE = new MapList();
					Iterator objectListIterator = mlFTEMonthYearList.iterator();
					boolean blFlag = false;
					boolean blTimelineFTE = false;
					for (int i = 0; i < nFTESpanInMonths; i++) 
					{
						mapObject = (Map) objectListIterator.next();
						int nTimeFrame = (Integer) mapObject.get("timeframe");
						int nTimeYear = (Integer) mapObject.get("year");
						mapFTE = new HashMap();
						strMonthYear = nTimeFrame + "-" + nTimeYear;
						try 
						{
							strFTE = (String) emxGetParameter(request,strMonthYear + nTaskOdj);
							if(strFTE.trim().isEmpty())
								strFTE = "0";
							double nNumberOfPeople = Task.parseToDouble(strFTE);
							if (nNumberOfPeople < 0){
								String strLanguage = context.getSession().getLanguage();
								String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
						        		"emxProgramCentral.Validate.ValidatePeople", strLanguage);
								request.setAttribute("error.message",sErrMsg);
								return;
							}
						} 
						catch (NumberFormatException e) 
						{
							String strLanguage = context.getSession().getLanguage();
							String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
					        		"emxProgramCentral.ResourceRequest.SelectNumericFTE", strLanguage);
							request.setAttribute("error.message",sErrMsg);
							return;
						}
						mapFTE.put(strMonthYear, strFTE);
						mlFTE.add(mapFTE);
					}
					strOrganizationId = (String) emxGetParameter(request, "txtOrganizationId" + nTaskOdj);
					strOrganizationName = (String) emxGetParameter(request, "txtOrganization" + nTaskOdj);
					strProjectRole = (String) emxGetParameter(request,"txtProjectRole" + nTaskOdj);
					String standardCost = (String) emxGetParameter(request, "txtStandardCost" + nTaskOdj);
					String currency = (String) emxGetParameter(request,"selcurrency");
					strBusinessId = (String) emxGetParameter(request,"txtBusinessSkillId" + nTaskOdj);
					Map paramMap = new HashMap();
					paramMap.put("projectObjectId", strprojectObjectId);
					paramMap.put("ProjectRole", strProjectRole);
					paramMap.put("OrganizationID", strOrganizationId);
					paramMap.put("FTEValue", mlFTE);
					paramMap.put("BusinessSkillId", strBusinessId);
					paramMap.put("standardCost", standardCost);
					paramMap.put("selectedCurrency", currency);
					mlRequestList.add(paramMap);
					} 
					for (Iterator iterRequest = mlRequestList.iterator(); iterRequest.hasNext();) 
					{
						finalRequestMap = (HashMap) iterRequest.next();
						ResourceRequest resourceRequest = new ResourceRequest();
						resourceRequest.createWBSRequest(context,finalRequestMap);
					}
				}
			else 
			{
				String strLanguage = context.getSession().getLanguage();
				String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
		        		"emxProgramCentral.Common.SelectProjectRoleRow", strLanguage);
				request.setAttribute("error.message", sErrMsg);
				return;
			}
            %>
            <script language="javascript">
            window.getTopWindow().getWindowOpener().location = window.getTopWindow().getWindowOpener().location;//To refresh the background SB
            getTopWindow().closeWindow();
            </script>
            <%
       	}
  		else if (("delete").equals(strMode)) 
  		{
  			String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
   			Map mapResult = null;
   		    ResourceRequest resourceRequest = new ResourceRequest();
   		    mapResult = resourceRequest.deleteRequests(context,strTableRowId);
   		    StringList slPersonList = (StringList) mapResult.get("PersonList");
   		    StringList slCommittedRequestList = (StringList) mapResult.get("CommittedRequest");
   		    StringList slNonCommittedRequestList = (StringList) mapResult.get("NonCommittedRequest");
   		    String strLanguage = context.getSession().getLanguage();
   		    String strCommittedReqTxtNotice = "";
   		    String strPersonTxtNotice = "";
   		    String sErrMsg = "";
   		    strCommittedReqTxtNotice = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
   	        		"emxProgramCentral.ResourceRequest.DoNotSelectCommittedRequest", strLanguage);
   		    strPersonTxtNotice = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
   	        		"emxProgramCentral.Common.SelectResourceRequest", strLanguage);
   			if (slCommittedRequestList.size() > 0 && slPersonList.size() > 0) 
   		    {
   		    	sErrMsg = strCommittedReqTxtNotice + " and "+ strPersonTxtNotice;
   		    }
   			else if (slCommittedRequestList.size() > 0) 
   			{
   			    sErrMsg = strCommittedReqTxtNotice;
   			}
	   		 else if (slPersonList.size() > 0) 
   		    {
	             sErrMsg = strPersonTxtNotice;
   		    }
   		    if (null != sErrMsg && !"null".equals(sErrMsg)&& !"".equals(sErrMsg)) 
   		    {
                %>
                <script language="JavaScript">
                alert("<%=sErrMsg%>");  <%-- XSSOK --%>
                </script>
               <%
            }
                int count = slNonCommittedRequestList.size();
                String partialXML = "";
				for (int i = 0; i < count; i++) 
				{
					String strRowId = (String)slNonCommittedRequestList.get(i);
                    partialXML += "<item id=\"" + strRowId +"\" />";
                }
				String xmlMessage = "<mxRoot>";
	            String message = "";
	            xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
	            xmlMessage += partialXML;
	            xmlMessage += "<message><![CDATA[" + message  + "]]></message>";
	            xmlMessage += "</mxRoot>";
                %>
	            <script language="javascript" type="text/javaScript">
	            var topFrame = findFrame(getTopWindow(), "PMCResourcePlan");
	            topFrame.removedeletedRows('<%= xmlMessage %>');   <%-- XSSOK --%>
	            topFrame.refreshStructureWithOutSort();
            </script>
            <%
       	}
  		else if (("EditPagedelete").equals(strMode)) 
  		{
       			String strRequestID = (String) emxGetParameter(request,"objectId");
       			String strProjectId = "";
       			if (null != strRequestID && !"null".equalsIgnoreCase(strRequestID) && !"".equals(strRequestID)) 
       			{
       				DomainObject requestDo = DomainObject.newInstance(context, strRequestID);
       				strProjectId = (String) requestDo.getInfo(context,"to["+ DomainConstants.RELATIONSHIP_RESOURCE_PLAN + "].from.id");
       			}
       			String[] strTableRowId = new String[1];
       			strTableRowId[0] = strRequestID;
       			Map mapResult = null;
       			ResourceRequest resourceRequest = new ResourceRequest();
       			mapResult = resourceRequest.deleteRequestsEditAction(context, strTableRowId);
       			String sErrMsg = "";
       			StringList slPersonList = (StringList) mapResult.get("PersonList");
       			StringList slCommittedRequestList = (StringList) mapResult.get("CommittedRequest");
       			StringList slNonCommittedRequestList = (StringList) mapResult.get("NonCommittedRequest");
       			String strLanguage = context.getSession().getLanguage();
       			String strCommittedReqTxtNotice = "";
       			String strPersonTxtNotice = "";
       			strCommittedReqTxtNotice = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.DoNotSelectCommittedRequest", strLanguage);
       			strPersonTxtNotice = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.DoNotSelectPerson", strLanguage);
       			StringBuffer sbfResourcePlanUrl = new StringBuffer(UINavigatorUtil.getCommonDirectory(context));
       			sbfResourcePlanUrl.append("/emxIndentedTable.jsp?table=PMCResourceRequestSummaryTable&toolbar=PMCResourcePlanToolBar,PMCResourceRequestLifecycleFilterMenu");
       			sbfResourcePlanUrl.append("&freezePane=Name&selection=multiple&HelpMarker=emxhelpresourceplanlist");
       			sbfResourcePlanUrl.append("&header=emxProgramCentral.ResourceRequest.ResourceRequest");
       			sbfResourcePlanUrl.append("&program=emxResourceRequest:getTableResourcePlanRequestData&expandProgram=emxResourceRequest:getTableExpandChildResourceRequestData&editLink=false&emxSuiteDirectory=programcentral");
       			sbfResourcePlanUrl.append("&categoryTreeName=type_ProjectSpace&isStructure=true&treeLabel=TestRP&otherTollbarParams=projectID,isStructure");
       			sbfResourcePlanUrl.append("&projectID=");
       			sbfResourcePlanUrl.append(strProjectId);
       			sbfResourcePlanUrl.append("&isStructure=true&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral&objectId=");
       			sbfResourcePlanUrl.append(strProjectId);
       			sbfResourcePlanUrl.append("&treeTypeKey=type.Project");

       			if (slCommittedRequestList.size() > 0) 
       			{
       				sErrMsg = strCommittedReqTxtNotice;
       			}
       			if (slPersonList.size() > 0) 
       			{
       				sErrMsg = strPersonTxtNotice;
       			}
       			if (slCommittedRequestList.size() > 0 && slPersonList.size() > 0) 
       			{
       				sErrMsg = strCommittedReqTxtNotice + " and "+ strPersonTxtNotice;
       			}
       			if (null != sErrMsg && !"null".equals(sErrMsg)&& !"".equals(sErrMsg)) 
       			{
                    %>
                    <script language="JavaScript">
                    alert("<%=sErrMsg%>"); <%-- XSSOK --%>
                    </script>
                    <%
                }
                %>
                <script language="JavaScript">
                window.parent.getWindowOpener().location.href = "<%=sbfResourcePlanUrl%>";   <%-- XSSOK --%>
                window.closeWindow();
                </script>
                <%
        } 
  		else if (("PublicDiscussion").equals(strMode)) 
  		{
  		    String[] strProgram = emxGetParameterValues(request,"program");
  		    String[] strProgram1 = { "emxResourceRequest:getTableResourcePlanRequestData" };
  		    if (strProgram == null) 
  		    {
  		      strProgram = strProgram1;
  		    }
  		    String strType = "";
  		    if (null != (strProgram)) 
  		    {
  		      String[] strProgramValues = strProgram[0].split(":");
  		      strType = strProgramValues[1].toString();
  		    }
  		    String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
  		    strTableRowId = ProgramCentralUtil.parseTableRowId(context, strTableRowId);
  		    String strTokenId = "";
  		    String strRequestID = "";
  		    
  		    if (null == strTableRowId) 
  		    {
  		    	strRequestID = (String) emxGetParameter(request,"objectId");
  		    } 
  		    else 
  		    {
  		    	if ("getTableResourcePlanRequestData".equals(strType) || "getTableResourcePoolRequestData".equals(strType)) 
			    		{

					strRequestID = strTableRowId[0];
  		        }
  		    }
         	DomainObject dmoRequest = new DomainObject(strRequestID);
   			boolean isObjectExist = false;
         	isObjectExist = dmoRequest.exists(context);
         	String strResourceRequestID = "";
         	boolean isRequestObject = false;
         	if (isObjectExist) 
         	{
         		isRequestObject = dmoRequest.isKindOf(context,DomainConstants.TYPE_RESOURCE_REQUEST);
   				if (isRequestObject) 
   				{
   					strResourceRequestID = strRequestID;
   				} 
   				else 
   				{
   					String strLanguage = context.getSession().getLanguage();
  					String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
  			        		"emxProgramCentral.ResourceRequest.SelectRequest", strLanguage);
                    %>
                    <script language="JavaScript">
                    alert("<%=sErrMsg%>");
                    window.closeWindow();
                    </script>
                    <%
                    return;
				}
			} 
         	else 
         	{
         	    String strLanguage = context.getSession().getLanguage();
				String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
		        		"emxProgramCentral.ResourceRequest.SelectRequest", strLanguage);
                %>
                <script language="JavaScript">
                alert("<%=sErrMsg%>");
                window.closeWindow();
                </script>
                <%
                return;
			}
            %>
            <script language="javascript" type="text/javaScript">
            getTopWindow().showSlideInDialog("../common/emxForm.jsp?form=APPCreateDiscussion&formHeader=emxComponents.Discussion.Reply&HelpMarker=emxhelpcreatediscussion&mode=edit&showPageURLIcon=false&Export=false&findMxLink=false&DiscType=Public&postProcessURL=../components/emxComponentsDiscussionCreateProcess.jsp&submitAction=doNothing&suiteKey=Components&objectId=<%=XSSUtil.encodeForURL(context,strResourceRequestID)%>");
            </script>
            <%
        } 
  		else if (("PrivateDiscussion").equals(strMode)) 
  		{
  			String[] strProgram = emxGetParameterValues(request,"program");
			String[] strProgram1 = {"emxResourceRequest:getTableResourcePlanRequestData"};
			if (strProgram == null) 
			{
				strProgram = strProgram1;
			}
			String strType = "";
			if (null != (strProgram)) 
			{
				String[] strProgramValues = strProgram[0].split(":");
				strType = strProgramValues[1].toString();
			}
			String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
			strTableRowId = ProgramCentralUtil.parseTableRowId(context, strTableRowId);
			String strTokenId = "";
			String strRequestID = "";
			if (null == strTableRowId) 
			{
				strRequestID = (String) emxGetParameter(request,"objectId");
			} 
			else 
			{
				if ("getTableResourcePlanRequestData".equals(strType) || "getTableResourcePoolRequestData".equals(strType)) 
							{

					strRequestID = strTableRowId[0];
				}

			}
			DomainObject dmoRequest = new DomainObject(strRequestID);
			boolean isObjectExist = false;
			isObjectExist = dmoRequest.exists(context);
			String strResourceRequestID = "";
			boolean isRequestObject = false;
			if (isObjectExist) 
			{
				isRequestObject = dmoRequest.isKindOf(context,DomainConstants.TYPE_RESOURCE_REQUEST);
				if (isRequestObject) 
				{
					strResourceRequestID = strRequestID;
				} 
				else 
				{
					String strLanguage = context.getSession().getLanguage();
					String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			        		"emxProgramCentral.ResourceRequest.SelectRequest", strLanguage);
                    %>
                    <script language="JavaScript">
                    alert("<%=sErrMsg%>");
                    window.closeWindow();
                    </script>
                    <%
                    return;
				}
			} 
			else 
			{
				String strLanguage = context.getSession().getLanguage();
				String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
		        		"emxProgramCentral.ResourceRequest.SelectRequest", strLanguage);
                %>
                <script language="JavaScript">
                alert("<%=sErrMsg%>");
                window.closeWindow();
                </script>
                <%
                return;
			}
            %>
            <script language="javascript" type="text/javaScript">
            getTopWindow().showSlideInDialog("../common/emxForm.jsp?form=APPCreateDiscussion&formHeader=emxComponents.Discussion.Reply&HelpMarker=emxhelpcreatediscussion&mode=edit&showPageURLIcon=false&Export=false&findMxLink=false&DiscType=Private&postProcessURL=../components/emxComponentsDiscussionCreateProcess.jsp&submitAction=doNothing&suiteKey=Components&objectId=<%=XSSUtil.encodeForURL(context,strRequestID)%>");
            </script>
            <%
    	} 
  		else if (("RemoveAssignmentByProjectLead").equals(strMode)) 
  		{
  			String strProjectId = emxGetParameter(request, "objectId");
    		String[] strSelectedId = emxGetParameterValues(request,"emxTableRowId");
   			
   			String strRequestId = "";
   			String strPersonId = "";
   			String strTokenId = "";
   			String sMessage = "";
   			String partialXML = "";
   			StringList slResourceTokens = null;
   			for (int i = 0; i < strSelectedId.length; i++) 
   			{
   				slResourceTokens = FrameworkUtil.splitString(strSelectedId[i], "|");
   				for (int j = 0; j < slResourceTokens.size(); j++) 
   				{
   					strTokenId = (String)slResourceTokens.get(j);
   					if (j == 1) 
   					{
   						boolean isResourceRequestObject = false;
   						boolean isPersonObject = false;
   						DomainObject dmoObject = DomainObject.newInstance(context, strTokenId);
   						isPersonObject = dmoObject.isKindOf(context,DomainConstants.TYPE_PERSON);
   						if (isPersonObject) 
   						{
   							strPersonId = strTokenId;
   							strRequestId = (String)slResourceTokens.get(2);
   							ResourceRequest resourceRequestObj = new ResourceRequest();
   							sMessage = resourceRequestObj.removeAssignment(context,strPersonId, strRequestId);
   							if (sMessage != null && !"".equals(sMessage) && !"null".equals(sMessage)) 
   							{
   								String strLanguage = context.getSession().getLanguage();
   								String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
   						        		"emxProgramCentral.Common.SelectCommittedPerson", strLanguage);
                                %>
                                <script language="JavaScript">
                                alert("<%=sErrMsg%>");
                                window.closeWindow();
                                </script>
                                <%
                                return;
      						}
   							else
   							{
   								String strRowId = (String)slResourceTokens.lastElement();
   				                partialXML += "<item id=\"" + strRowId +"\" />";
   							}
                        }
   						else if (!isPersonObject) 
                        {
                        	strRequestId = strTokenId;
                            String strLanguage = context.getSession().getLanguage();
                            String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourcePool.PeopleAction.SelectPerson", strLanguage);
                            %>
                            <script language="JavaScript">
                            alert("<%=sErrMsg%>");
                            window.closeWindow();
                            </script>
                            <%
                            return;
                        }
                        break;
                    }
                }
   			}
   		    String xmlMessage = "<mxRoot>";
   		    String message = "";
   		    xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
   		    xmlMessage += partialXML;
   		    xmlMessage += "<message><![CDATA[" + message  + "]]></message>";
   		    xmlMessage += "</mxRoot>";
            %>
            <script language="javascript" type="text/javaScript">
            var topFrame = findFrame(getTopWindow(), "PMCResourcePlan");
            topFrame.removedeletedRows('<%= xmlMessage %>');    <%-- XSSOK --%>
            topFrame.refreshStructureWithOutSort();
            window.closeWindow();
            </script>
            <%
  		}
   		else if (("CopyRequest").equals(strMode)) 
   		{
 			String strProjectId = emxGetParameter(request, "objectId");
            String strSelectedId = emxGetParameter(request,"emxTableRowId");
            StringList slRequestTokens = FrameworkUtil.split(strSelectedId, "|");
            String strErrMsg = "";
            if(null!=slRequestTokens && slRequestTokens.size()>3)
            {
   			String isFromRMB = emxGetParameter(request, "isFromRMB");
   			if (isFromRMB != null && "true".equalsIgnoreCase(isFromRMB.trim())) 
   			{
   				String strRootObjectId = emxGetParameter(request,"rootObjectId");
   			    if (strRootObjectId != null && !"Null".equalsIgnoreCase(strRootObjectId) && !"".equalsIgnoreCase(strRootObjectId.trim())) 
   			    {
   			    	strProjectId = strRootObjectId;
   			    }
            }
   		    String strRequestId = "";
   		    String strPersonId = "";
   		    String strTokenId = "";
   		    String strState = "";
   		    String strLevel = "";
   		    String strObjectId = "";
   		    java.util.StringTokenizer strTokenizer = new java.util.StringTokenizer(strSelectedId, "|");
   		    int nTokenCount = strTokenizer.countTokens();
   		    for (int j = 0; j < nTokenCount; j++) 
   		    {
   		    	strTokenId = strTokenizer.nextToken();
   		    	if (j == 1) 
   		    	{
   		    		strObjectId = strTokenId;    
   		    	}
   		    	if (j == 3) 
   		    	{
   		    		strLevel = strTokenId;
   		    	}
   		    }
            boolean isResourceRequestObject = false;
            boolean isPersonObject = false;
            Object strCopyReq = null;
            DomainObject dmoObject = DomainObject.newInstance(context,strObjectId);
            isResourceRequestObject = dmoObject.isKindOf(context,DomainConstants.TYPE_RESOURCE_REQUEST);
            isPersonObject = dmoObject.isKindOf(context,DomainConstants.TYPE_PERSON);
            if (isResourceRequestObject) 
            {
            	strRequestId = strObjectId;
            	ResourcePlan resourceBean = new ResourcePlan();
            	resourceBean.copyRequest(context, strProjectId,strRequestId);
            }
   			if (isPersonObject) 
   			{
   			    strPersonId = strObjectId;
   			    String strLanguage = context.getSession().getLanguage();
                    strErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.SelectResourceRequest", strLanguage);
                    %>
                    <script language="JavaScript">
                    alert("<%=strErrMsg%>");
                    </script>
                    <%
                    return;
                }
            }
            else
            {
                String strLanguage = context.getSession().getLanguage();
                strErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.SelectResourceRequest", strLanguage);
                %>
                <script language="JavaScript">
                alert("<%=strErrMsg%>");
                </script>
                <%
                return;
            }
            %>
            <script language="javascript" type="text/javaScript">
            window.parent.location.href = window.parent.location.href;
            </script>
            <%
        }
		else if (("edit").equals(strMode)){
			if(("SubmitRequestComment").equals(strSubMode)){
				String strRowIds = null;
				boolean invokeScript = false;
				String strLanguage = context.getSession().getLanguage();
				strRowIds = emxGetParameter(request, "rowIds");
				StringList slRequestId = new StringList();
				slRequestId = FrameworkUtil.split(strRowIds, ",");
				String strRequestId = "";
				String[] strPersonId = new String[slRequestId.size()];
				String strTokenId = "";
				String strState = "";
				String strLevel = "";
				String strComment = "";
				strComment = emxGetParameter(request, "Comment");
				if (ProgramCentralUtil.isNullString(strComment))
					strComment = emxGetParameter(request, "Comment1");
				if (ProgramCentralUtil.isNullString(strComment))
					strComment = "";
				MQLCommand mql = new MQLCommand();
				mql.open(context);
				strComment = strComment.replace("\"", "");
				mql.executeCommand(context, "set env global $1 $2","SUBMIT_REQUEST",strComment);
				mql.close(context);
						
				for (int i = 0; i < slRequestId.size(); i++){
					invokeScript = false;
					strRequestId = (String) slRequestId.get(i);
					DomainObject dmoObject = DomainObject.newInstance(context, strRequestId);
					strState = dmoObject.getInfo(context,DomainConstants.SELECT_CURRENT);
					if (strState.equals(DomainConstants.STATE_RESOURCE_REQUEST_CREATE)){
						ResourceRequest resourceRequestObj = new ResourceRequest(strRequestId);
						String requestedStatus = DomainConstants.STATE_RESOURCE_REQUEST_REQUESTED;
						String[] args = {strRequestId};
						resourceRequestObj.submitRequestByPL(context);
						invokeScript = true;
					} 
					else if (strState.equals(DomainConstants.STATE_RESOURCE_REQUEST_REJECTED)){
						ResourceRequest resourceRequestObj = new ResourceRequest(strRequestId);
						String requestedStatus = DomainConstants.STATE_RESOURCE_REQUEST_REQUESTED;
						resourceRequestObj.reuseRejectedRequestByPL(context);
						invokeScript = true;
					} else if (strState.equals(DomainConstants.STATE_RESOURCE_REQUEST_PROPOSED)){
						ResourceRequest resourceRequestObj = new ResourceRequest(strRequestId);
						String requestedStatus = DomainConstants.STATE_RESOURCE_REQUEST_REQUESTED;
						String[] methodArguments = new String[0];
						String[] Arguments = new String[]{strRequestId};
						JPO.invoke(context,"emxResourceRequest",Arguments, "reuseProposedRequestByPL", methodArguments);
						invokeScript = true;
					} 
					if (invokeScript){
		                    %>
                            <script language="javascript">
	                             var topFrame = findFrame(getTopWindow(), "PMCResourcePlan");
	                             topFrame.location.href = topFrame.location.href;
                            </script>
                            <%
                    }
				}//End
			}			
			else if (("EditPageSubmitRequestComment").equals(strSubMode)) 
			{
				String strRowIds = null;
				String sErrMsg = null;
				boolean invokeScript = false;
				String strLanguage = context.getSession().getLanguage();
				if (("SubmitRequestComment").equals(strSubMode))
					strRowIds = emxGetParameter(request, "rowIds");
				if (("EditPageSubmitRequestComment").equals(strSubMode))
					strRowIds = emxGetParameter(request, "objectId");

				StringList slRequestId = new StringList();
				slRequestId = FrameworkUtil.split(strRowIds, ",");
				String strRequestId = "";
				String[] strPersonId = new String[slRequestId.size()];
				String strTokenId = "";
				String strState = "";
				String strLevel = "";
				String strComment = "";
				strComment = emxGetParameter(request, "Comment");

				if (ProgramCentralUtil.isNullString(strComment))
					strComment = emxGetParameter(request, "Comment1");
				if (ProgramCentralUtil.isNullString(strComment))
					strComment = "";

				MQLCommand mql = new MQLCommand();
				mql.open(context);
				strComment = strComment.replace("\"", "");
				mql.executeCommand(context, "set env global $1 $2","SUBMIT_REQUEST",strComment);
				mql.close(context);

				for (int i = 0; i < slRequestId.size(); i++) 
				{
					sErrMsg = null;
					invokeScript = false;
					strRequestId = (String) slRequestId.get(i);
					strTokenId = strRequestId;
					boolean isResourceRequestObject = false;
					boolean isPersonObject = false;
					DomainObject dmoObject = DomainObject.newInstance(context, strRequestId);
					isResourceRequestObject = dmoObject.isKindOf(context,DomainConstants.TYPE_RESOURCE_REQUEST);
					isPersonObject = dmoObject.isKindOf(context,DomainConstants.TYPE_PERSON);
					if (isResourceRequestObject && !isPersonObject) 
					{
						String strRelationshipType = DomainConstants.RELATIONSHIP_RESOURCE_PLAN;
						String strType = DomainConstants.TYPE_RESOURCE_REQUEST;
						String whereClause = "";
						final String SELECT_REL_ATTRIBUTE_FTE = "to["+ DomainConstants.RELATIONSHIP_RESOURCE_PLAN+ "].attribute["+ DomainConstants.ATTRIBUTE_FTE + "]";
						StringList relSelect = new StringList();
						relSelect.add(SELECT_REL_ATTRIBUTE_FTE);
						Map mapRequestInfo = dmoObject.getInfo(context,relSelect);
						String strStateValue = null;
						FTE fte = FTE.getInstance(context);
						if (null != mapRequestInfo.get(SELECT_REL_ATTRIBUTE_FTE)&& !"null".equals(mapRequestInfo.get(SELECT_REL_ATTRIBUTE_FTE))&& !"".equals(mapRequestInfo.get(SELECT_REL_ATTRIBUTE_FTE))) 
						{
							fte = FTE.getInstance(context, (String) mapRequestInfo.get(SELECT_REL_ATTRIBUTE_FTE));
						}
						Map mapFTEValues = null;
						mapFTEValues = fte.getAllFTE();
						boolean isValidFTE = false;
						if (null != mapFTEValues && !"null".equals(mapFTEValues) && !"".equals(mapFTEValues)) 
						{
							for (Iterator iter = mapFTEValues.keySet().iterator(); iter.hasNext();) 
							{
								String strTimeFrame = (String) iter.next();
								Double dFTEValue = 0D;
								dFTEValue = (Double) mapFTEValues.get(strTimeFrame);
								if (dFTEValue > 0) 
								{
									isValidFTE = true;
									break;
								}
							}
							if (isValidFTE == false) 
							{
								sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.InvalidRequestForSubmission", strLanguage);
								invokeScript = true;
							}
						}
						strState = dmoObject.getInfo(context,DomainConstants.SELECT_CURRENT);
						if (strState.equals(DomainConstants.STATE_RESOURCE_REQUEST_CREATE)) 
						{
							ResourceRequest resourceRequestObj = new ResourceRequest(strRequestId);
							String requestedStatus = DomainConstants.STATE_RESOURCE_REQUEST_REQUESTED;
							String[] args = {strRequestId};
							//sErrMsg = resourceRequestObj.triggerCheckResourcePoolMessage(context, args);
							if (ProgramCentralUtil.isNullString(sErrMsg)) 
							{
								String checkResourcePool=resourceRequestObj.triggerCheckResourcePoolMessage(context, args);
								if (ProgramCentralUtil.isNullString(checkResourcePool)){
								resourceRequestObj.submitRequestByPL(context);
								invokeScript = true;
								
								}
								else{
								 sErrMsg=checkResourcePool;
								 invokeScript = true;
								}
							} 
							else
								invokeScript = true;
						} 
						else if (strState.equals(DomainConstants.STATE_RESOURCE_REQUEST_REJECTED)) 
						{
							ResourceRequest resourceRequestObj = new ResourceRequest(strRequestId);
							String requestedStatus = DomainConstants.STATE_RESOURCE_REQUEST_REQUESTED;
							resourceRequestObj.reuseRejectedRequestByPL(context);
							sErrMsg = null;
							invokeScript = true;
						} 
						else 
						{
							sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.DoNotSelectRequestedRequest", strLanguage);
							invokeScript = true;
						}
					}
					if (!isResourceRequestObject) 
					{
						sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.SelectResourceRequest", strLanguage);
						invokeScript = true;
					}
					if (invokeScript) 
					{
						if (!ProgramCentralUtil.isNullString(sErrMsg)) 
						{
                            %>
                            <script language="javascript">
                            alert("<%=sErrMsg%>");
                            window.parent.closeWindow();
                            </script>
                            <%
                        }
                    }
					else
					{
                        %>
                        <script language="javascript">
                        window.parent.getWindowOpener().location.href = window.parent.getWindowOpener().location.href;
                        window.parent.closeWindow();
                        </script>
                        <%
                    }
				}
				if (invokeScript) //Added:IR-166717V6R2013x 
				{
					if (ProgramCentralUtil.isNullString(sErrMsg)) 
					{
                        %>
                        <script language="javascript">
                              window.parent.closeWindow();
                        </script>
                        <%
                    }
				}//End
			}
            if (("rejectRequest").equals(strSubMode)) 
            {
                String strRejection = emxGetParameter(request,"Comment");
                String strRowIds = emxGetParameter(request, "rowIds");
                StringList slRequestIds = new StringList();
                slRequestIds = FrameworkUtil.split(strRowIds, ",");
                String strRequestId = "";
                String strTokenId = "";
                MQLCommand mql = new MQLCommand();
                mql.open(context);
                strRejection = strRejection.replace("\"", "");
                mql.executeCommand(context, "set env global $1 $2 ","REJECT_REQUEST",strRejection);
                mql.close(context);
                for (int i = 0; i < slRequestIds.size(); i++) 
                {
                    strTokenId = (String) slRequestIds.get(i);
                    strRequestId = strTokenId;
                    ResourceRequest resourceRequestObj = new ResourceRequest(strRequestId);
                    resourceRequestObj.reject(context);
                }     
                    
                %>
	       		<script language="javascript">
                    topFrame = findFrame(getTopWindow(),"detailsDisplay");
                    if(topFrame == null){
                        var contentFrame = findFrame(getTopWindow(),"content");
                    }
                    getTopWindow().closeSlideInDialog();
                    topFrame.location.href = topFrame.location.href;
		                   	
                </script>
                <%
            }
		} 
		else if (("Resources").equals(strMode) || "ResourcePlanAddResources".equals(strMode)) 
		{
			String[] strProgram = emxGetParameterValues(request,"program");
			String[] strProgram1 = { "emxResourceRequest:getTableResourcePlanRequestData" };
			if (strProgram == null) 
			{
				strProgram = strProgram1;
			}
			String[] strProgramValues = strProgram[0].split(":");
			String strType = strProgramValues[1].toString();
			String strResourcePoolId = null;
			String strRequestId = "";
			StringList slRequestTokens = null;
			String strRequestId1 = "";
			String strLanguage = context.getSession().getLanguage();
			String strProjectId = "";
			if (strType.equals("getTableResourcePlanRequestData")) 
			{
				strRequestId = emxGetParameter(request, "emxTableRowId");
				slRequestTokens = FrameworkUtil.split(strRequestId, "|");
				String strErrMsg = "";
				if(null!=slRequestTokens && slRequestTokens.size()>3)
		        {
				strRequestId1 = (String) slRequestTokens.get(1);
				DomainObject dmoRequest = DomainObject.newInstance(context, strRequestId1);
				strResourcePoolId = "from["+ DomainConstants.RELATIONSHIP_RESOURCE_POOL+ "].to.id";
				strResourcePoolId = dmoRequest.getInfo(context,strResourcePoolId);
				strProjectId = projectId;
				if (dmoRequest.isKindOf(context,DomainConstants.TYPE_RESOURCE_REQUEST)
						&& (null == strResourcePoolId || "".equals(strResourcePoolId) || "null".equalsIgnoreCase(strResourcePoolId))) 
				{
					strErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.NoResourcePool", strLanguage);
				}
				if (dmoRequest.isKindOf(context,DomainConstants.TYPE_PERSON)) 
				{
					strErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.SelectResourceRequest", strLanguage);
				}
				String strRequestState = "";
				strRequestState = dmoRequest.getInfo(context,DomainConstants.SELECT_CURRENT);
				if (DomainConstants.STATE_RESOURCE_REQUEST_REQUESTED.equals(strRequestState)
						|| DomainConstants.STATE_RESOURCE_REQUEST_COMMITTED.equals(strRequestState)) 
				{
					strErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.DoNotAllowResources", strLanguage);
					strRequestState = i18nNow.getRangeI18NString(DomainConstants.ATTRIBUTE_RESOURCE_STATE,strRequestState, strLanguage);
					strErrMsg = strErrMsg + "   " + strRequestState;
				}
		        }
				if (null != strErrMsg && !"".equals(strErrMsg)&& !"null".equalsIgnoreCase(strErrMsg)) 
				{
                    %>
                    <script language="javascript" type="text/javaScript">
					alert("<%=strErrMsg%>");  <%-- XSSOK --%>
					window.closeWindow();
					</script>
                    <%
                    return;
                }
				if (slRequestTokens.size()<=3) 
				{
					strErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Project.CannotPerformAction", strLanguage);
                    %>
                    <script language="javascript" type="text/javaScript">
					alert("<%=strErrMsg%>");  <%-- XSSOK --%>
					window.closeWindow();
					</script>
                    <%
                    return;
				}
				else if(!"ResourcePlanAddResources".equals(strMode)) {
					%>
                    <script language="javascript" type="text/javaScript">
                    	var contentFrame = findFrame(getTopWindow(),"detailsDisplay");
                    	if(contentFrame == null){
                    		var contentFrame = findFrame(getTopWindow(),"content");
                    	}
                    	contentFrame.location.href = contentFrame.location.href;
					</script>
	                <%
				}
			}
			if (strType.equals("getTableResourcePoolRequestData"))
            {
                    strRequestId = emxGetParameter(request,"emxTableRowId");
                    slRequestTokens = FrameworkUtil.split(strRequestId, "|");
                    String strErrMsg = "";
                    if(slRequestTokens.size()==3)
                    {
                    strRequestId1 = (String) slRequestTokens.get(0);
                    DomainObject dmo = DomainObject.newInstance(context,strRequestId1);
                    String strCurrentState = dmo.getInfo(context,DomainConstants.SELECT_CURRENT);
                    DomainObject dmoRequest = DomainObject.newInstance(context,strRequestId1);
                    strResourcePoolId = "from["+DomainConstants.RELATIONSHIP_RESOURCE_POOL+"].to.id";
                    strResourcePoolId = dmoRequest.getInfo(context,strResourcePoolId);
                    strProjectId = strResourcePoolId;
                    if (DomainConstants.STATE_RESOURCE_REQUEST_REJECTED.equals(strCurrentState)) 
                    {
                        strErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.DoNotAllowResources", strLanguage);
                        strCurrentState = i18nNow.getRangeI18NString(DomainConstants.ATTRIBUTE_RESOURCE_STATE,strCurrentState, strLanguage);
                        strErrMsg = strErrMsg + "   " + strCurrentState;
                    }
	                    if (ProgramCentralUtil.isNotNullString(strErrMsg)) 
                    {
                        %>
                         <script language="javascript" type="text/javaScript">
                         alert("<%=strErrMsg%>");  <%-- XSSOK --%>
                        window.closeWindow();
                        </script>
                        <%
                        return;
                    }
            }
                    else
                    {
                    	strErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.ResourcePlan.SelectResourceRequest", strLanguage);
                    	 %>
                         <script language="javascript" type="text/javaScript">
                         alert("<%=strErrMsg%>");
                         getTopWindow().window.closeWindow();
                         </script>
                         <%
                         return;
                    }
                    
                   
            }
			if (strType.equals("getTableResourceRequestPeopleData")) 
			{
				strRequestId1 = emxGetParameter(request,"ResourceRequestId");
				DomainObject dmoRequest = DomainObject.newInstance(context, strRequestId1);
				strResourcePoolId = "from["+ DomainConstants.RELATIONSHIP_RESOURCE_POOL+ "].to.id";
				strResourcePoolId = dmoRequest.getInfo(context,strResourcePoolId);
				DomainObject dmo = DomainObject.newInstance(context,strRequestId1);
				String strCurrentState = dmo.getInfo(context,DomainConstants.SELECT_CURRENT);
				String strErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.DoNotAllowResources", strLanguage);
				if (strCurrentState.equalsIgnoreCase(DomainConstants.STATE_RESOURCE_REQUEST_REJECTED)) 
				{
					strCurrentState = i18nNow.getRangeI18NString(DomainConstants.ATTRIBUTE_RESOURCE_STATE,strCurrentState, strLanguage);
                    %>
                    <script language="javascript" type="text/javaScript">
                    getTopWindow().window.closeWindow();
                    alert("<%=strErrMsg%>  "+"<%=strCurrentState%> !");
                    window.closeWindow();
                    </script>
                    <%
                    return;
				}
			} else if (ProgramCentralUtil.isNotNullString(strRequestId1)) {
	            DomainObject dmoRequestDo = DomainObject.newInstance(context, strRequestId1);
	            DomainObject dmoProjectDo = DomainObject.newInstance(context, projectId);
	            final String ATTRIBUTE_RESOURCE_PLAN_PREFRENCE = PropertyUtil.getSchemaProperty(context,"attribute_ResourcePlanPreference");
	            String strPlanPreference = dmoRequestDo.getInfo(context,"to[" + DomainConstants.RELATIONSHIP_RESOURCE_PLAN + "].from.attribute["+ ATTRIBUTE_RESOURCE_PLAN_PREFRENCE+ "].value");
	            String strPersonId = "";
	            String strTokenId = "";
	            String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
	            String strTableRowIds = FrameworkUtil.join(strTableRowId,"~");
	            %>
	            <script language="javascript" type="text/javaScript">
	           
	            <%
	            boolean isPhasePlanPref = "Phase".equalsIgnoreCase(strPlanPreference);
	            String url1 ="";
	            if (isPhasePlanPref)
	            {
	                 url1 = "../programcentral/emxProgramCentralResourceRequestUtil.jsp?mode=addResourcesByResourceManagerForPhase&requestId="+strRequestId1+"&objectId="+XSSUtil.encodeForURL(context,projectId)+"&strType="+strType;
	            } 
	            else 
	            {
	                 url1 = "../programcentral/emxProgramCentralResourceRequestUtil.jsp?mode=addResourcesByResourceManager&requestId="+strRequestId1+"&objectId="+XSSUtil.encodeForURL(context,projectId)+"&strType="+strType;
	            }
                %>
                <%-- XSSOK --%>
                var url ="../common/emxFullSearch.jsp?field=TYPES=type_Person:POLICY=policy_Person:RESOURCE_POOL_ID=<%=strResourcePoolId%>&excludeOIDprogram=emxResourcePool:getExcludeOIDForAddResourcesSearch&table=PMCCommonPersonSearchTable&selection=multiple&form=PMCCommonPersonSearchForm&submitURL=<%=url1%>";
                	showModalDialog(url);
                </script><%
            }
		} 
		else if (("addResourcesByResourceManager").equals(strMode)) 
		{
			String[] strResourceRowId = emxGetParameterValues(request,"emxTableRowId");
			String strResourcePoolId = emxGetParameter(request,"objectId");
			String strRequestTokenIds = emxGetParameter(request,"requestId");
			String strType = emxGetParameter(request, "strType");
			String numberofPeopleUnit = EnoviaResourceBundle.getProperty(context, "emxProgramCentral.ResourcePlan.NumberofPeopleUnit");
			StringList slRequestTokens = FrameworkUtil.split(strRequestTokenIds, "|");
			String strRequestId = "";
			ResourceRequest resourceRequestObj = null;
			String strTableRowIds = FrameworkUtil.join(strResourceRowId,"~");
			StringList slResourceTokens = new StringList();
			slResourceTokens = FrameworkUtil.split(strTableRowIds,"~");
			FTE fteRequest = FTE.getInstance(context);
			MapList mlFTE = null;
			Map mapFTE = null;
			Calendar calStartDate = Calendar.getInstance();
			Calendar calFinishDate = Calendar.getInstance();
			int nMonth = 0;
			int nYear = 0;
			int nMonthCounter = 0;
			int nYearCounter = 0;
			int nFTESpanInMonths = 0;
			String strFTE = "";

			final String SELECT_START_DATE = "attribute["+ DomainConstants.ATTRIBUTE_START_DATE + "]";
			final String SELECT_END_DATE = "attribute["	+ DomainConstants.ATTRIBUTE_END_DATE + "]";
			StringList slBusSelect = new StringList();
			slBusSelect.add(SELECT_START_DATE);
			slBusSelect.add(SELECT_END_DATE);

			MapList mlResources = new MapList();
			if (strType.equals("getTableResourcePlanRequestData")) 
			{
				strRequestId = (String) slRequestTokens.get(0);
				resourceRequestObj = new ResourceRequest(strRequestId);
				DomainObject dmoProject = DomainObject.newInstance(context, strResourcePoolId);
				DomainObject dmoRequest = DomainObject.newInstance(context, strRequestId);
				String strStartDate = "";
				String strFinishtDate = "";
				Map mapObjInfo = dmoRequest.getInfo(context,slBusSelect);
				strStartDate = (String) mapObjInfo.get(SELECT_START_DATE);
				strFinishtDate = (String) mapObjInfo.get(SELECT_END_DATE);
				Date dtStartDate = eMatrixDateFormat.getJavaDate(strStartDate);
				Date dtFinishDate = eMatrixDateFormat.getJavaDate(strFinishtDate);
				calStartDate.setTime(dtStartDate);
				calFinishDate.setTime(dtFinishDate);
				int nFinishMonth = 0;
				int nFinishYear = 0;
				int nNumberOfMonths = 0;
				nYear = calStartDate.get(Calendar.YEAR);
				nFinishYear = calFinishDate.get(Calendar.YEAR);
				nMonth = calStartDate.get(Calendar.MONTH) + 1; //0=January
				nFinishMonth = calFinishDate.get(Calendar.MONTH) + 1;//0=January
				MapList mlFTEMonthYearList = null;
				mlFTEMonthYearList = fteRequest.getTimeframes(dtStartDate, dtFinishDate);
				nFTESpanInMonths = mlFTEMonthYearList.size();
				String strMonthYear = "";
				double nFTE = 0;
				for (int k = 0; k < slResourceTokens.size(); k++) 
				{
					Map mapResourceMap = new HashMap();
					Map mapObject = new HashMap();
					mlFTE = new MapList();
					nMonthCounter = nMonth;
					nYearCounter = nYear;
					Iterator objectListIterator = mlFTEMonthYearList.iterator();
					for (int i = 0; i < nFTESpanInMonths; i++) 
					{
						mapObject = (Map) objectListIterator.next();
						int nTimeFrame = (Integer) mapObject.get("timeframe");
						int nTimeYear = (Integer) mapObject.get("year");
						mapFTE = new HashMap();
						strMonthYear = nTimeFrame + "-" + nTimeYear;
						strFTE = "1"; //rg6  //remove fte for add resource from resource pool
						String strResourceFTEValue = EnoviaResourceBundle.getProperty(context, "emxProgramCentral.ResourceRequest.FTE");
						Double dbMaxResourceFTE = new Double(strResourceFTEValue);
						String strLanguage = context.getSession().getLanguage();
						String strErrorMessage = null;
						double dbAllocatedFTE = 0d;
						try 
						{
							dbAllocatedFTE = Task.parseToDouble(strFTE);
						} 
						catch (NumberFormatException nfe) 
						{
							if ("".equalsIgnoreCase(strFTE)) 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.EnterFTEValue", strLanguage);
								strErrorMessage = strErrorMessage + ":"	+ strMonthYear;
							} 
							else 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.NotValidFTEValue", strLanguage);
								strErrorMessage = strFTE + ":"+ strErrorMessage + ":"+ strMonthYear;
							}
							throw new ServletException(strErrorMessage);
						}
						if ("FTE".equalsIgnoreCase(numberofPeopleUnit)) 
						{
							if (dbAllocatedFTE > dbMaxResourceFTE) 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.MaxAllowedResourceFTE", strLanguage);
								strErrorMessage = strErrorMessage + ":"	+ strResourceFTEValue;
								throw new MatrixException(strErrorMessage);
							}
						}
						if (null != strFTE && !"null".equals(strFTE) && !"".equals(strFTE)) 
						{
							mapFTE.put(strMonthYear, strFTE);
						}
						mlFTE.add(mapFTE);
					}
					mapResourceMap.put("FTE", mlFTE);
					String strResource = (slResourceTokens.get(k)).toString();
					StringList slResourceId = FrameworkUtil.split(strResource, "|");
					mapResourceMap.put("Resource_Id", slResourceId.get(0));
					mapResourceMap.put("ResourceState",DomainConstants.ATTRIBUTE_RESOURCE_STATE_RANGE_REQUESTED);
					mapResourceMap.put("RequestId", strRequestId);
					mlResources.add(mapResourceMap);
				}
			}
			if (strType.equals("getTableResourcePoolRequestData")) {
				strRequestId = (String) slRequestTokens.get(0);
				String strRequestState = "";
				DomainObject dmoRequest = DomainObject.newInstance(context, strRequestId);
				strRequestState = dmoRequest.getInfo(context,DomainConstants.SELECT_CURRENT);
				resourceRequestObj = new ResourceRequest(strRequestId);
				String strStartDate = "";
				String strFinishtDate = "";
				Map mapObjInfo = dmoRequest.getInfo(context,slBusSelect);
				strStartDate = (String) mapObjInfo.get(SELECT_START_DATE);
				strFinishtDate = (String) mapObjInfo.get(SELECT_END_DATE);

				Date dtStartDate = eMatrixDateFormat.getJavaDate(strStartDate);
				Date dtFinishDate = eMatrixDateFormat.getJavaDate(strFinishtDate);
				calStartDate.setTime(dtStartDate);
				calFinishDate.setTime(dtFinishDate);

				int nFinishMonth = 0;
				int nFinishYear = 0;
				int nNumberOfMonths = 0;

				nYear = calStartDate.get(Calendar.YEAR);
				nFinishYear = calFinishDate.get(Calendar.YEAR);
				nMonth = calStartDate.get(Calendar.MONTH) + 1; //0=January
				nFinishMonth = calFinishDate.get(Calendar.MONTH) + 1;//0=January

				MapList mlFTEMonthYearList = null;
				mlFTEMonthYearList = fteRequest.getTimeframes(dtStartDate, dtFinishDate);
				nFTESpanInMonths = mlFTEMonthYearList.size();
				String strMonthYear = "";
				double nFTE = 0;
				for (int k = 0; k < slResourceTokens.size(); k++) 
				{
					Map mapResourceMap = new HashMap();
					Map mapObject = new HashMap();
					mlFTE = new MapList();
					nMonthCounter = nMonth;
					nYearCounter = nYear;
					Iterator objectListIterator = mlFTEMonthYearList.iterator();
					for (int i = 0; i < nFTESpanInMonths; i++) 
					{
						mapObject = (Map) objectListIterator.next();
						int nTimeFrame = (Integer) mapObject.get("timeframe");
						int nTimeYear = (Integer) mapObject.get("year");
						mapFTE = new HashMap();
						strMonthYear = nTimeFrame + "-" + nTimeYear;
						strFTE = "0"; //rg6  //remove fte for add resource from resource pool
						String strResourceFTEValue = EnoviaResourceBundle.getProperty(context, "emxProgramCentral.ResourceRequest.FTE");
						Double dbMaxResourceFTE = new Double(strResourceFTEValue);
						String strLanguage = context.getSession().getLanguage();
						String strErrorMessage = null;
						double dbAllocatedFTE = 0d;
						try 
						{
							dbAllocatedFTE = Task.parseToDouble(strFTE);
						} 
						catch (NumberFormatException nfe) 
						{
							if ("".equalsIgnoreCase(strFTE)) 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.EnterFTEValue", strLanguage);
								strErrorMessage = strErrorMessage + ":"	+ strMonthYear;
							} 
							else 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.NotValidFTEValue", strLanguage);
								strErrorMessage = strFTE + ":"+ strErrorMessage + ":"+ strMonthYear;
							}
							throw new ServletException(strErrorMessage);
						}
						if ("FTE".equalsIgnoreCase(numberofPeopleUnit)) 
						{
							if (dbAllocatedFTE > dbMaxResourceFTE) 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.MaxAllowedResourceFTE", strLanguage);
								strErrorMessage = strErrorMessage + ":"	+ strResourceFTEValue;
								throw new MatrixException(strErrorMessage);
							}
						}
						if (null != strFTE && !"null".equals(strFTE)&& !"".equals(strFTE)) 
						{
							mapFTE.put(strMonthYear, strFTE);
						}
						mlFTE.add(mapFTE);
					}
					mapResourceMap.put("FTE", mlFTE);
					String strResource = (slResourceTokens.get(k)).toString();
					StringList slResourceId = FrameworkUtil.split(strResource, "|");
					mapResourceMap.put("Resource_Id", slResourceId.get(0));
					mapResourceMap.put("ResourceState", strRequestState);
					mapResourceMap.put("RequestId", strRequestId);
					mlResources.add(mapResourceMap);
				}
			}
			ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"),DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
            try
            {
                resourceRequestObj.addResources(context, mlResources);
            }
            finally
            {
            	ContextUtil.popContext(context);
            }
            %>
            <script language="javascript" type="text/javascript">
			var topFrame=findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
			var portalFrame=findFrame(getTopWindow().getWindowOpener().getTopWindow(), "portalDisplay");
			if(null!=portalFrame ){
				var resourcePlan=findFrame(getTopWindow().getWindowOpener().getTopWindow(), "PMCResourcePlan");				
				resourcePlan.location.href=resourcePlan.location.href;
				getTopWindow().closeWindow();				
			}else{
				getTopWindow().closeWindow();
				topFrame.refreshFrameWindow();          
			}	
            </script>
            <%
        } 
		else if (("addResourcesByResourceManagerForPhase").equals(strMode)) 
		{
			String[] strResourceRowId = emxGetParameterValues(request,"emxTableRowId");
			String strResourcePoolId = emxGetParameter(request,"objectId");
			String strRequestTokenIds = emxGetParameter(request,"requestId");
			String strType = emxGetParameter(request, "strType");
			String strTableRowIds = FrameworkUtil.join(strResourceRowId,"~");
			StringList slResourceTokens = FrameworkUtil.split(strTableRowIds, "~");
			StringList slRequestTokens = FrameworkUtil.split(strRequestTokenIds, "|");
			String strRequestId = "";

			Calendar calStartDate = Calendar.getInstance();
			Calendar calFinishDate = Calendar.getInstance();
			int nMonth = 0;
			int nYear = 0;
			int nMonthCounter = 0;
			int nYearCounter = 0;
			int nFTESpanInMonths = 0;
			String strFTE = "";

			final String SELECT_START_DATE = "attribute["+ DomainConstants.ATTRIBUTE_START_DATE + "]";
			final String SELECT_END_DATE = "attribute["+ DomainConstants.ATTRIBUTE_END_DATE + "]";

			StringList slBusSelect = new StringList();
			slBusSelect.add(SELECT_START_DATE);
			slBusSelect.add(SELECT_END_DATE);
			ResourceRequest resourceRequestObj = null;

			FTE fteRequest = FTE.getInstance(context);
			MapList mlFTE = null;
			Map mapFTE = null;
			MapList mlResources = new MapList();
			String numberofPeopleUnit = EnoviaResourceBundle.getProperty(context,"emxProgramCentral.ResourcePlan.NumberofPeopleUnit");

			if (strType.equals("getTableResourcePlanRequestData")) 
			{
				strRequestId = (String) slRequestTokens.get(0);
				resourceRequestObj = new ResourceRequest(strRequestId);
				DomainObject dmoProject = DomainObject.newInstance(context, strResourcePoolId);
				DomainObject dmoRequest = DomainObject.newInstance(context, strRequestId);

				StringList slRequestPhaseIdList = dmoRequest.getInfoList(context,ResourcePlanTemplate.SELECT_RESOURCE_REQUSET_PHASE_ID);
				for (int k = 0; k < slResourceTokens.size(); k++) 
				{
					Map mapResourceMap = new HashMap();
					Map mapObject = new HashMap();
					mlFTE = new MapList();
					String strPhaseId = "";
					String strPhaseOID = "";
					for (int nCount = 0; nCount < slRequestPhaseIdList.size(); nCount++) 
					{
						mapFTE = new HashMap();
						strPhaseId = (String) slRequestPhaseIdList.get(nCount);
						DomainObject phasedo = DomainObject.newInstance(context, strPhaseId);
						String strPhaseName = phasedo.getInfo(context,DomainConstants.SELECT_NAME);
						strPhaseOID = "PhaseOID-" + strPhaseId;
						strFTE = "1"; //rg6  //remove fte for add resource from resource pool
						String strResourceFTEValue = EnoviaResourceBundle.getProperty(context,"emxProgramCentral.ResourceRequest.FTE");
						Double dbMaxResourceFTE = new Double(strResourceFTEValue);
						String strLanguage = context.getSession().getLanguage();
						String strErrorMessage = null;
						double dbAllocatedFTE = 0d;
						try 
						{
							dbAllocatedFTE = Task.parseToDouble(strFTE);
						} 
						catch (NumberFormatException nfe) 
						{
							if ("".equalsIgnoreCase(strFTE)) 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.EnterFTEValue", strLanguage);
								strErrorMessage = strErrorMessage + ":"+ strPhaseName;
							} 
							else 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.NotValidFTEValue", strLanguage);
								strErrorMessage = strFTE + ":"+ strErrorMessage + ":"+ strPhaseName;
							}
							throw new ServletException(strErrorMessage);
						}
						if ("FTE".equalsIgnoreCase(numberofPeopleUnit)) 
						{
							if (dbAllocatedFTE > dbMaxResourceFTE) 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.MaxAllowedResourceFTE", strLanguage);
								strErrorMessage = strErrorMessage + ":"+ strResourceFTEValue;
								throw new MatrixException(strErrorMessage);
							}
						}
						if (null != strFTE && !"null".equals(strFTE)&& !"".equals(strFTE)) 
						{
							mapFTE.put(strPhaseOID, strFTE);
							mapFTE.put("PhaseId", strPhaseId);
						}
						mlFTE.add(mapFTE);
					}
					mapResourceMap.put("FTE", mlFTE);
					String strResource = (slResourceTokens.get(k)).toString();
					StringList slResourceId = FrameworkUtil.split(strResource, "|");
					mapResourceMap.put("Resource_Id", slResourceId.get(0));
					mapResourceMap.put("ResourceState",DomainConstants.ATTRIBUTE_RESOURCE_STATE_RANGE_REQUESTED);
					mapResourceMap.put("RequestId", strRequestId);
					mapResourceMap.put("resourcePlanPreference","Phase");
					mapResourceMap.put("mode", strType);
					mlResources.add(mapResourceMap);
				}
			}
			if (strType.equals("getTableResourcePoolRequestData")) 
			{
				strRequestId = (String) slRequestTokens.get(0);
				String strRequestState = "";
				DomainObject dmoRequest = DomainObject.newInstance(context, strRequestId);
				strRequestState = dmoRequest.getInfo(context,DomainConstants.SELECT_CURRENT);
				resourceRequestObj = new ResourceRequest(strRequestId);
				String strStartDate = "";
				String strFinishtDate = "";
				Map mapObjInfo = dmoRequest.getInfo(context,slBusSelect);
				strStartDate = (String) mapObjInfo.get(SELECT_START_DATE);
				strFinishtDate = (String) mapObjInfo.get(SELECT_END_DATE);
				Date dtStartDate = eMatrixDateFormat.getJavaDate(strStartDate);
				Date dtFinishDate = eMatrixDateFormat.getJavaDate(strFinishtDate);

				calStartDate.setTime(dtStartDate);
				calFinishDate.setTime(dtFinishDate);

				int nFinishMonth = 0;
				int nFinishYear = 0;
				int nNumberOfMonths = 0;

				nYear = calStartDate.get(Calendar.YEAR);
				nFinishYear = calFinishDate.get(Calendar.YEAR);
				nMonth = calStartDate.get(Calendar.MONTH) + 1; //0=January
				nFinishMonth = calFinishDate.get(Calendar.MONTH) + 1;//0=January

				MapList mlFTEMonthYearList = null;
				mlFTEMonthYearList = fteRequest.getTimeframes(dtStartDate, dtFinishDate);
				nFTESpanInMonths = mlFTEMonthYearList.size();

				String strMonthYear = "";
				double nFTE = 0;
				for (int k = 0; k < slResourceTokens.size(); k++) 
				{
					Map mapResourceMap = new HashMap();
					Map mapObject = new HashMap();
					mlFTE = new MapList();
					nMonthCounter = nMonth;
					nYearCounter = nYear;
					Iterator objectListIterator = mlFTEMonthYearList.iterator();
					for (int i = 0; i < nFTESpanInMonths; i++) 
					{
						mapObject = (Map) objectListIterator.next();
						int nTimeFrame = (Integer) mapObject.get("timeframe");
						int nTimeYear = (Integer) mapObject.get("year");
						mapFTE = new HashMap();
						strMonthYear = nTimeFrame + "-" + nTimeYear;
						strFTE = "0";
						String strResourceFTEValue = EnoviaResourceBundle.getProperty(context, "emxProgramCentral.ResourceRequest.FTE");
						Double dbMaxResourceFTE = new Double(strResourceFTEValue);
						String strLanguage = context.getSession().getLanguage();
						String strErrorMessage = null;
						double dbAllocatedFTE = 0d;
						try 
						{
							dbAllocatedFTE = Task.parseToDouble(strFTE);
						} 
						catch (NumberFormatException nfe) 
						{
							if ("".equalsIgnoreCase(strFTE)) 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.EnterFTEValue", strLanguage);
								strErrorMessage = strErrorMessage + ":"	+ strMonthYear;
							} 
							else 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.NotValidFTEValue", strLanguage);
								strErrorMessage = strFTE + ":"+ strErrorMessage + ":"+ strMonthYear;
							}
							throw new ServletException(strErrorMessage);
						}
						if ("FTE".equalsIgnoreCase(numberofPeopleUnit)) 
						{
							if (dbAllocatedFTE > dbMaxResourceFTE) 
							{
								strErrorMessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.MaxAllowedResourceFTE", strLanguage);
								strErrorMessage = strErrorMessage + ":"	+ strResourceFTEValue;
								throw new MatrixException(strErrorMessage);
							}
						}
						if (null != strFTE && !"null".equals(strFTE) && !"".equals(strFTE)) 
						{
							mapFTE.put(strMonthYear, strFTE);
						}
						mlFTE.add(mapFTE);
					}
					mapResourceMap.put("FTE", mlFTE);
					String strResource = (slResourceTokens.get(k)).toString();
					StringList slResourceId = FrameworkUtil.split(strResource, "|");
					mapResourceMap.put("Resource_Id", slResourceId.get(0));
					mapResourceMap.put("ResourceState", strRequestState);
					mapResourceMap.put("RequestId", strRequestId);
					mapResourceMap.put("resourcePlanPreference","Phase");
					mapResourceMap.put("mode", strType);
					mlResources.add(mapResourceMap);
				}
			}
			ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"),DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
			try
			{
			    resourceRequestObj.addResources(context, mlResources);
			}
			finally
			{
				ContextUtil.popContext(context);
			}
			
            %>
            <script language="javascript" type="text/javascript">
            getTopWindow().getWindowOpener().location.href=getTopWindow().getWindowOpener().location.href;
            getTopWindow().closeWindow();
            </script>
            <%
        } 
		else if (("removeResourcesByResourceManager").equals(strMode)) 
		{
			String selectedResourceRowIds = emxGetParameter(request,"emxTableRowId");
			StringList strResourceRowId = FrameworkUtil.split(selectedResourceRowIds, "-");
			MapList mlResources = new MapList(strResourceRowId.size());
			Map mapResourceMap = new HashMap();
			StringList slResourceTokens = null;
			StringList slResourceIds = new StringList();
			StringList slRequestIds = new StringList();
			Map mapCommittedResourceMap = new HashMap();
			String strRequestId = null;
			String strResourceId = null;
			Map reqResourceRowId = new HashMap();

			for (int i = 0; i < strResourceRowId.size(); i++) 
			{
				slResourceTokens = FrameworkUtil.split(strResourceRowId.get(i), "|");
				strResourceId = (String) slResourceTokens.get(1);
				strRequestId = (String) slResourceTokens.get(2);
				slResourceIds = (StringList) mapResourceMap.get(strRequestId);
				DomainObject dmoObject = DomainObject.newInstance(context, strRequestId);
				String strRequestState = dmoObject.getInfo(context,DomainConstants.SELECT_CURRENT);
				reqResourceRowId.put(strRequestId+"Row"+strResourceId, (String)slResourceTokens.lastElement());
                if (slResourceIds == null)
                {
                	StringList slNewResourceIds = new StringList();
                	slNewResourceIds.add(strResourceId);
                    mapResourceMap.put(strRequestId, slNewResourceIds);
                }
                else
                {
                	slResourceIds.add(strResourceId);
                	mapResourceMap.put(strRequestId, slResourceIds);
                }
			}
			String partialXML = "";
			for (Iterator itr = mapResourceMap.keySet().iterator(); itr.hasNext();) 
			{
				strRequestId = (String) itr.next();
				ResourceRequest resourceRequestObj = new ResourceRequest(strRequestId);
				slResourceIds = (StringList) mapResourceMap.get(strRequestId);
				ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"),DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
	            try
	            {
	            	resourceRequestObj.removeResources(context,slResourceIds);
	            }
	            finally
	            {
	                ContextUtil.popContext(context);
	            }
				for(int k=0; k<slResourceIds.size(); k++)
				{
					strResourceId = (String)slResourceIds.get(k);
				    String strRowId = (String)reqResourceRowId.get(strRequestId+"Row"+strResourceId);
				    partialXML += "<item id=\"" + strRowId +"\" />";
				}
			}
			
	        String xmlMessage = "<mxRoot>";
	        String message = "";
	        xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
	        xmlMessage += partialXML;
	        xmlMessage += "<message><![CDATA[" + message  + "]]></message>";
	        xmlMessage += "</mxRoot>";
            %>
            <script language="javascript" type="text/javaScript">
            var topFrame = findFrame(getTopWindow(), "detailsDisplay");
            if(topFrame == null){
            	var topFrame = findFrame(getTopWindow(), "content");
            }
            topFrame.removedeletedRows('<%= xmlMessage %>');  <%-- XSSOK --%>
            topFrame.refreshStructureWithOutSort();
            window.closeWindow();
            </script>
            <%
        } 
		else if (("stateEdit").equals(strMode)) 
		{
			String strObjectId = emxGetParameter(request, "objectId");
			String strRelId = emxGetParameter(request, "relId");
			String strSuiteKey = emxGetParameter(request, "suiteKey");
			String strFormName = emxGetParameter(request, "formName");
			String strFieldNameActual = emxGetParameter(request,"fieldNameActual");
			String strFieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
			DomainObject dmObject = DomainObject.newInstance(context,strObjectId);
            %>
            <script language="javascript" type="text/javascript">
            var formName = null;
            var treeRootId = null;
            if (getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>)
            {
                formName = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>;
                if(formName.elements["resourcePoolId"])
                {
                    treeRootId = formName.elements["resourcePoolId"].value;
                }
                else if(formName.elements["projectID"])
                {
                    treeRootId = formName.elements["projectID"].value;
                }
            }
            if (treeRootId == null)
            {
                throw new Error("treeRootId not found !!");
            }

            window.parent.location.href = "../programcentral/emxProgramCentralResourceRequestEditStateFS.jsp?"+
                                             "&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>"+"&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>"+
                                             "&suiteKey=<%=XSSUtil.encodeForURL(context,strSuiteKey)%>"+"&formName=<%=XSSUtil.encodeForURL(context,strFormName)%>"+
                                             "&fieldNameActual=<%=XSSUtil.encodeForURL(context,strFieldNameActual)%>"+"&fieldNameDisplay=<%=XSSUtil.encodeForURL(context,strFieldNameDisplay)%>"+
                                             "&treeRootId="+treeRootId+"&multiSelect=false";

            </script>
            <%
        } 
		else if (("ResourcePoolEdit").equals(strMode)) 
		{
			String strObjectId = emxGetParameter(request, "objectId");
			String strRelId = emxGetParameter(request, "relId");
			String strSuiteKey = emxGetParameter(request, "suiteKey");
			String strFormName = emxGetParameter(request, "formName");
			String strFieldNameActual = emxGetParameter(request,"fieldNameActual");
			String strFieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
			DomainObject dmObject = DomainObject.newInstance(context,strObjectId);
            %>
            <script language="javascript" type="text/javascript">
            var formName = null;
            var treeRootId = null;
            if (getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>)
            {
                formName = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>;
                if(formName.elements["resourcePoolId"])
                {
                    treeRootId = formName.elements["resourcePoolId"].value;
                }
                else if(formName.elements["projectID"])
                {
                    treeRootId = formName.elements["projectID"].value;
                }
            }
            if (treeRootId == null)
            {
                throw new Error("treeRootId not found !!");
            }
            window.parent.location.href = "../programcentral/emxProgramCentralResourceRequestEditStateFS.jsp?"+
                                             "&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>"+"&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>"+
                                             "&suiteKey=<%=XSSUtil.encodeForURL(context,strSuiteKey)%>"+"&formName=<%=XSSUtil.encodeForURL(context,strFormName)%>"+
                                             "&fieldNameActual=<%=XSSUtil.encodeForURL(context,strFieldNameActual)%>"+"&fieldNameDisplay=<%=XSSUtil.encodeForURL(context,strFieldNameDisplay)%>"+
                                             "&treeRootId="+treeRootId+"&multiSelect=false";

            </script>
            <%
        }
		else if (("ApproveRequestByResourceManager").equals(strMode)) 
		{
			String[] strResourceRequestRowIds = emxGetParameterValues(request, "emxTableRowId");
			String strResourceRequestRowId = emxGetParameter(request,"emxTableRowId");
			StringList slResourceRequestTokens = new StringList();
			String strResourceRequestId = null;
			StringList slResourceRequestId = new StringList();
			for (int i = 0; i < strResourceRequestRowIds.length; i++) 
			{
				slResourceRequestTokens = FrameworkUtil.split(strResourceRequestRowIds[i], "|");
				if (slResourceRequestTokens.size() >= 4) 
				{
					String strLanguage = context.getSession().getLanguage();
					String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.DoNotSelectPerson", strLanguage);
                    %>
                    <script language="JavaScript">
                    alert("<%=sErrMsg%>");   <%-- XSSOK --%>
                    window.closeWindow();
                    </script>
                    <%
                    return;
				}
				strResourceRequestId = (String) slResourceRequestTokens.get(0);
				DomainObject dmoObject = DomainObject.newInstance(context, strResourceRequestId);
				String strCurrentState = dmoObject.getInfo(context,DomainConstants.SELECT_CURRENT);
				if (DomainConstants.STATE_RESOURCE_REQUEST_COMMITTED.equals(strCurrentState)|| DomainConstants.STATE_RESOURCE_REQUEST_REJECTED.equals(strCurrentState)) 
				{
					String strLanguage = context.getSession().getLanguage();
					String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.NotInDesiredState", strLanguage);
                    %>
                    <script language="JavaScript">
                    alert("<%=sErrMsg%>");   <%-- XSSOK --%>
                    window.closeWindow();
                    </script>
                    <%
                    break;
				} 
				else 
				{
					slResourceRequestId.add(strResourceRequestId);
				}
			}
			ResourceRequest.approve(context, slResourceRequestId);
            %>
            <script language="javascript" type="text/javaScript">
            window.parent.location.href = window.parent.location.href ;
            </script>
            <%
	    } 
		else if (("ProposeRequestByResourceManager").equals(strMode)) 
		{
			String[] strResourceRequestRowIds = emxGetParameterValues(request, "emxTableRowId");
			String strResourceRequestRowId = emxGetParameter(request,"emxTableRowId");
			StringList slResourceRequestTokens = new StringList();
			String strResourceRequestId = null;
			StringList slResourceRequestId = new StringList();

			for (int i = 0; i < strResourceRequestRowIds.length; i++)
			{
				slResourceRequestTokens = FrameworkUtil.split(strResourceRequestRowIds[i], "|");
				if (slResourceRequestTokens.size() >= 4) 
				{
					String strLanguage = context.getSession().getLanguage();
					String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.DoNotSelectPerson", strLanguage);
                    %>
                    <script language="JavaScript">
                    alert("<%=sErrMsg%>"); <%-- XSSOK --%>
                    window.closeWindow();
                    </script>
                    <%
                    return;
				} 
				else 
				{
					strResourceRequestId = (String) slResourceRequestTokens.get(0);
					boolean IfNotInAppropriateState = PolicyUtil.checkState(context,strResourceRequestId,DomainConstants.STATE_RESOURCE_REQUEST_REQUESTED,PolicyUtil.GT);
					if (IfNotInAppropriateState) 
					{
						String strLanguage = context.getSession().getLanguage();
						String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ResourceRequest.NotInDesiredState", strLanguage);
                        %>
                        <script language="JavaScript">
                        alert("<%=sErrMsg%>");  <%-- XSSOK --%>
                        window.closeWindow();
                        </script>
                        <%
                        break;
					} 
					else 
					{
						slResourceRequestId.add(strResourceRequestId);
					}
				}
			}
			ResourceRequest.propose(context, slResourceRequestId);
            %>
            <script language="javascript" type="text/javaScript">
            window.parent.location.href = window.parent.location.href ;
            </script>
            <%
        } 
		else if ("AssignResourcePoolStandardCost".equalsIgnoreCase(strMode)) 
		{
			String[] saResourceRequestIds = emxGetParameterValues(request, "emxTableRowId");
			StringList sbResReq = new StringList();
			StringList sbResourcePool = new StringList();
			String strLanguage = context.getSession().getLanguage();
			if (saResourceRequestIds != null) 
			{
				StringList slResourceRequestTokens = new StringList();
				String strResourceRequestId = null;
				StringList slResourceRequestId = new StringList();
				DomainObject dObj = DomainObject.newInstance(context);
				for (int i = 0; i < saResourceRequestIds.length; i++) {
					slResourceRequestTokens = FrameworkUtil.splitString(saResourceRequestIds[i], "|");
					strResourceRequestId = (String) slResourceRequestTokens.get(1);
					dObj.setId(strResourceRequestId);
					if (!dObj.isKindOf(context,DomainConstants.TYPE_RESOURCE_REQUEST)) 
					{
						String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.SelectResourceRequest", strLanguage);
                        %>
                        <script language="JavaScript">
                        alert("<%=sErrMsg%>");  <%-- XSSOK --%>
	                    window.closeWindow();
	                    </script>
                        <%
                        return;
					}
					String strResReqName = dObj.getName(context);
					String strResourceReqCurrState = dObj.getCurrentState(context).getName();
					final String SELECT_RESOURCE_POOL_ID = "from["+DomainConstants.RELATIONSHIP_RESOURCE_POOL+"].to.id";
					String resourcePoolId = dObj.getInfo(context, SELECT_RESOURCE_POOL_ID);
	                if(resourcePoolId != null && ! "".equalsIgnoreCase(resourcePoolId))
	                {
					if (DomainConstants.STATE_RESOURCE_REQUEST_CREATE.equalsIgnoreCase(strResourceReqCurrState)|| 
							DomainConstants.STATE_RESOURCE_REQUEST_REJECTED.equalsIgnoreCase(strResourceReqCurrState)) 
					{
						slResourceRequestId.add(strResourceRequestId);
					} 
					else 
					{
	                           sbResReq.add(strResReqName);
					}
				}
	                else
				{
	                	sbResourcePool.add(strResReqName);
	                }
				}
				if (sbResourcePool.size() > 0) 
                {
					String strResourceRequest = FrameworkUtil.join(sbResourcePool,",");
                    String sAlertMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                    		"emxProgramCentral.ResourcePlan.AssignResourcePoolStandardCost.NoResourcePoolStandardCost", strLanguage)+ strResourceRequest;
                    %>
                    <script language="javascript" type="text/javaScript">
                    alert("<%=sAlertMsg%>");  <%-- XSSOK --%>
                    </script>
                    <%
				}
				if (sbResReq.size() > 0) 
				{
					String strResourceRequest = FrameworkUtil.join(sbResReq,",");
                    String sAlertMsg = strResourceRequest + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                    		"emxProgramCentral.ResourcePlan.AssignResourcePoolStandardCost.CantAssignResourcePoolStandardCost", strLanguage);
				    %>
                    <script language="javascript" type="text/javaScript">
		            alert("<%=sAlertMsg%>");  <%-- XSSOK --%>
		            </script>
                    <%
                }
				if (slResourceRequestId.size() > 0) 
				{
					Map paramMap = new HashMap();
					paramMap.put("resourceRequestIds",slResourceRequestId);
					ResourceRequest resourceRequest = new ResourceRequest();
					resourceRequest.assignResourcePoolStandardCost(context, paramMap);
                %>
                <script language="javascript" type="text/javaScript">
                window.parent.location.href = window.parent.location.href ;
                </script> 
                <%
            }
		} 
		} 
		else if ("PhaseTimelineCostFTEFilter".equalsIgnoreCase(strMode)) 
		{
			String category = emxGetParameter(request,"categoryTreeName");
			category = XSSUtil.encodeURLForServer(context, category);
			String objectId = emxGetParameter(request, "objectId");
			objectId = XSSUtil.encodeURLForServer(context, objectId);
			String jsTreeID = emxGetParameter(request, "jsTreeID");
	        String strLifecycleFilter = emxGetParameter(request,"PMCResourceRequestLifecycleFilter");
			String strPhaseTimelineFilter = emxGetParameter(request,"PMCResourceRequestPhaseTimelineFilter");
			String strCostsFTEFilter = emxGetParameter(request,"PMCResourceRequestCostsFTEFilter");
			String strURL = "../common/emxIndentedTable.jsp?table=PMCResourceRequestSummaryTable&toolbar"
					+ "=PMCResourcePlanToolBar,PMCResourceRequestLifecycleFilterMenu&freezePane=Name"
					+"&categoryTreeName="
					+ category
					+"&HelpMarker=emxhelpresourceplanlist&header=emxProgramCentral.ResourceRequest.ResourceRequest"
					+"&expandProgram=emxResourceRequest:getTableExpandChildResourceRequestData"
					+"&editLink=false&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral"
					+"&emxSuiteDirectory=programcentral&relId=null&objectId=";
			strURL = strURL + objectId;
			strURL = strURL + "&projectID=" + objectId;
			strURL = strURL + "&jsTreeID=" + XSSUtil.encodeForURL(context,jsTreeID);
			strURL = strURL + "&PMCResourceRequestPhaseTimelineFilter="
					+ strPhaseTimelineFilter;
			strURL = strURL + "&PMCResourceRequestCostsFTEFilter="
					+ strCostsFTEFilter;
	        strURL = strURL + "&PMCResourceRequestLifecycleFilter="+ XSSUtil.encodeForURL(context,strLifecycleFilter);
			strURL = strURL +"&postProcessJPO=emxResourceRequestBase:postProcessRefreshTable";
			strURL = strURL +"&selection=multiple";
		    strURL = strURL +"&editRootNode=false";
            %>
            <script language="javascript">
            var strUrl = "<%=strURL%>";  <%-- XSSOK --%>
            window.parent.location.href = strUrl;
            </script>
            <%
	    } 
		else if ("LifecycleCurrencyFilter".equalsIgnoreCase(strMode)) 
		{
			String category = emxGetParameter(request,"categoryTreeName");
			String objectId = emxGetParameter(request, "objectId");
			objectId = XSSUtil.encodeURLForServer(context, objectId);
			String jsTreeID = emxGetParameter(request, "jsTreeID");
			String strLifecycleFilter = emxGetParameter(request,"PMCResourceRequestLifecycleFilter");
			String strCurrencyFilter = emxGetParameter(request,"PMCResourceRequestCurrencyFilter");
	        String strCostsFTEFilter = emxGetParameter(request,"PMCResourceRequestCostsFTEFilter");
	        String strPhaseTimelineFilter = emxGetParameter(request,"PMCResourceRequestPhaseTimelineFilter");
			String strURL = "../common/emxIndentedTable.jsp?table=PMCResourceRequestSummaryTable&toolbar"
					+ "=PMCResourcePlanToolBar,PMCResourceRequestLifecycleFilterMenu&freezePane=Name"
					+"&categoryTreeName="
					+category
					+"&HelpMarker=emxhelpresourceplanlist&header=emxProgramCentral.ResourceRequest.ResourceRequest"
					+"&expandProgram=emxResourceRequest:getTableExpandChildResourceRequestData"
					+"&editLink=true&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&SuiteDirectory=programcentral"
					+"&emxSuiteDirectory=programcentral&relId=null&objectId=";
			strURL = strURL + objectId;
			strURL = strURL + "&projectID=" + XSSUtil.encodeForURL(context,objectId);
			strURL = strURL + "&jsTreeID=" + XSSUtil.encodeForURL(context,jsTreeID);
			strURL = strURL + "&PMCResourceRequestLifecycleFilter="+ XSSUtil.encodeForURL(context,strLifecycleFilter);
			strURL = strURL + "&PMCResourceRequestCurrencyFilter="+ XSSUtil.encodeForURL(context,strCurrencyFilter);
	        strURL = strURL + "&PMCResourceRequestCostsFTEFilter=" + XSSUtil.encodeForURL(context,strCostsFTEFilter);
	        strURL = strURL + "&PMCResourceRequestPhaseTimelineFilter="+ XSSUtil.encodeForURL(context,strPhaseTimelineFilter);
			strURL = strURL +"&postProcessJPO=emxResourceRequestBase:postProcessRefreshTable";
		    strURL = strURL +"&selection=multiple";
		    strURL = strURL +"&editRootNode=false";
            %>
            <script language="javascript">
            var strUrl = "<%=strURL%>";    <%-- XSSOK --%>
            window.parent.location.href = strUrl;
            </script>
            <%
        }
		else if (("createRequest").equals(strMode)) 
        {
			String objectId = emxGetParameter(request, "projectID");
			if(ProgramCentralUtil.isNullString(objectId))
				objectId = emxGetParameter(request, "objectId");
			String[] args = new String[1];
			args[0] = objectId;
			String emxTableRowId   =  emxGetParameter(request, "emxTableRowId");
			StringList slemxTableRowId = FrameworkUtil.split(emxTableRowId, "|");
			ResourceRequest request1 = new ResourceRequest();
	        Map idMap = request1.createAutomatedResourceRequest(context, args);
	        String xmlMessage = "<mxRoot>" +
	        "<action><![CDATA[add]]></action>" +
	        "<data status=\"committed\" fromRMB=\"" + false + "\"";
	        if(null!=slemxTableRowId && slemxTableRowId.size()>3)
            {
	        	xmlMessage +=" pasteBelowOrAbove=\"true\"";
            }
	        xmlMessage += " >"+
	        "<item oid=\"" + (String)idMap.get(DomainConstants.SELECT_ID) + "\" relId=\"" + (String)idMap.get("planRelId") + "\" pid=\"" + objectId + "\""; 
	        if(null!=slemxTableRowId && slemxTableRowId.size()>3)
	        {
	        	xmlMessage +=" direction=\"\" pasteAboveToRow=\"" + slemxTableRowId.get(3) +"\" ";
	        }
	        xmlMessage += " />";
	        xmlMessage += "</data></mxRoot>";
            %>
            <script language="javascript" type="text/javaScript">
            var topFrame = findFrame(getTopWindow(), "PMCResourcePlan");
            topFrame.emxEditableTable.addToSelected('<%=xmlMessage%>');    <%-- XSSOK --%>
            topFrame.refreshStructureWithOutSort();
            
            </script>
            <%
        }  
        else if("PreremoveResourcesByResourceManager".equalsIgnoreCase(strMode)){
    		String[] strResourceRowId = emxGetParameterValues(request,"emxTableRowId");
    		String strURL = "../programcentral/emxProgramCentralResourceRequestUtil.jsp?mode=removeResourcesByResourceManager&emxTableRowId=";
    		String sErrMsg = ProgramCentralConstants.EMPTY_STRING;
    		String strLanguage = context.getSession().getLanguage();

    		for (int i = 0; i < strResourceRowId.length; i++) 
    		{
    			StringList slResourceTokens = FrameworkUtil.split(strResourceRowId[i], "|");
    			if (slResourceTokens.size() < 4) 
    			{
   					 sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.RemoveResources.DoNotSelectRequests", strLanguage);
   					 break;    	            	
    			}
    		}
    		
    		
      		for(int i =0; i<strResourceRowId.length;i++){
    			strURL +=  XSSUtil.encodeForURL(context,strResourceRowId[i])+"-";
    		}
    		strURL = strURL.substring(0, strURL.length()-1);  
    		
    		Enumeration requestParams = emxGetParameterNames(request);
    		StringBuilder url = new StringBuilder();		
    		if (requestParams != null) {
    			while (requestParams.hasMoreElements()) {
    				String param = (String) requestParams.nextElement();
    				String value = emxGetParameter(request, param);
    				url.append("&" + param);
    				url.append("=" + XSSUtil.encodeForURL(context, value));
    			}
    			strURL += url.toString();
    		}	
    		%> 
    			<script language="javascript">
    				var errorMsg = "<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>";
    				if(errorMsg == null || errorMsg ==""){
    					
    					alert("<%= EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.RemoveResources.ConfirmMessage", strLanguage)%>")
    					 var strUrl =  "<%=XSSUtil.encodeForJavaScript(context,strURL)%>";
    					 document.location.href = strUrl;
    					 
    				}else{
    					alert(errorMsg);		
    					window.parent.location.href =  window.parent.location.href;
    					
    				}
            </script>
            <%
        } 
        else if("PreRejectRequest".equalsIgnoreCase(strMode)){
        	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    		String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");    	
    		
    		String strURL = "../common/emxForm.jsp?form=PMCResourceRequestRejectForm&mode=edit&formHeader=emxProgramCentral.ResourcePlan.HeaderForRejection&suiteKey=ProgramCentral&SuiteDirectory=programcentral&postProcessURL=../programcentral/emxProgramCentralResourceRequestUtil.jsp&submode=rejectRequest&toolbar=null";
    		String sErrMsg = ProgramCentralConstants.EMPTY_STRING;
    		
    		
    		for(int i =0; i<tableRowIdList.length;i++){
    			strURL += "emxTableRowId="+ XSSUtil.encodeForURL(context,tableRowIdList[i])+"&";
    		}
    		strURL = strURL.substring(0, strURL.length()-1);   		
    		
    		Enumeration requestParams = emxGetParameterNames(request);
    		StringBuilder url = new StringBuilder();		
    		if (requestParams != null) {
    			while (requestParams.hasMoreElements()) {
    				String param = (String) requestParams.nextElement();
    				String value = emxGetParameter(request, param);
    				url.append("&" + param);
    				url.append("=" + XSSUtil.encodeForURL(context, value));
    			}
    			strURL += url.toString();
    		}
    		
    		String[] ObjectIdList = ProgramCentralUtil.parseTableRowId(context, tableRowIdList);
    		for(int i=0; i< ObjectIdList.length;i++){
    			 boolean isResourceRequestObject = false;
                 boolean isPersonObject = false;
                 String objId = (String) ObjectIdList[i];
                 DomainObject dmoObject = DomainObject.newInstance(context, objId);
                 isResourceRequestObject = dmoObject.isKindOf(context,DomainConstants.TYPE_RESOURCE_REQUEST);
                 isPersonObject = dmoObject.isKindOf(context,DomainConstants.TYPE_PERSON);
                     
                 if (isResourceRequestObject) 
                 {
                    String strState = dmoObject.getInfo(context,DomainConstants.SELECT_CURRENT);
                     if (strState.equals(DomainConstants.STATE_RESOURCE_REQUEST_REJECTED)|| strState.equals(DomainConstants.STATE_RESOURCE_REQUEST_COMMITTED)) 
                     {
                         String strLanguage = context.getSession().getLanguage();
                         sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.DoNotSelectRejectedCommittedRequest", strLanguage);
                         break;
                     } 
                 }else if (isPersonObject) 
                 {
                    
                     String strLanguage = context.getSession().getLanguage();
                     		sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.DoNotSelectPerson", strLanguage);                        
                     break;
                 }
    		             
    		}
    		%> 
    			<script language="javascript">
    			debugger;
    				var errorMsg = "<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>";
    				if(errorMsg == null || errorMsg ==""){
    					 var strUrl =  "<%=XSSUtil.encodeForJavaScript(context,strURL)%>";
    					 getTopWindow().showSlideInDialog(strUrl,false);
    					 
    				}else{
    					alert(errorMsg);		
    					window.parent.getWindowOpener().location.reload(true);
    	                window.parent.closeWindow();
    					
    				}
    			 </script>
    		<%	
         
    	}
   		else 
   		{
   		    throw new IllegalArgumentException(strMode);
        }
  	} 
	catch (Exception e) 
	{
  		bFlag = true;
  		e.printStackTrace();
  		session.putValue("error.message", e.getMessage());
  	}
    %>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "../components/emxComponentsDesignBottomInclude.inc"%>

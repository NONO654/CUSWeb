<%--  emxProgramCentralResourcePoolPeopleUtil.jsp   -   This Page is used to show autonomysearch and for further processing action

   Copyright (c) Dassault Systemes, 1993-2018 - 2007. All rights reserved.
   This program contains proprietary and trade secret information of Dassault Systems.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: Exp $
--%>

<%--
Change History:
Date       Change By  Release        Bug/Functionality        Details
-----------------------------------------------------------------------------------------------------------------------------
19-Aug-09   wqy        V6R2010x     IR-012088V6R2010x,       Added Check for selection of People only.
                                    IR-012091V6R2010x

20-Aug-09   wqy        V6R2010x     IR-012043V6R2010x        Added code for getTopWindow().close() to close autonomy search window       
                       
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<!-- Java script functions -->


<%@page import="com.matrixone.fcs.tools.Submit"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Enumeration"%>

<%@page import="matrix.db.Context"%>
<%@page import="matrix.db.BusinessObjectWithSelectList"%>
<%@page import="matrix.db.BusinessObject"%>
<%@page import="matrix.db.BusinessObjectWithSelect"%>
<%@page import="matrix.db.BusinessObjectWithSelectItr"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.framework.taglib.XSSEncodeForCSSTag"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>  

<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<%@page import ="com.matrixone.apps.program.ResourcePool"%>
    
<!-- Page display code here -->
<form name="ResourcePoolPeopleUtil" method="post" >
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<%
    try 
    {
        String strMode = emxGetParameter(request, "mode");
        strMode = XSSUtil.encodeURLForServer(context, strMode);
        if (strMode == null || "".equals(strMode) || "null".equals(strMode))  
        {
        
            String languageStr = context.getSession().getLanguage();
            String errMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
            		"emxProgramCentral.ResourcePool.PeopleAction.InvalidMode.errMsg", languageStr) + " '" + strMode + "'"; 
            throw new Exception(errMsg);
        }
        
        if("AssignSkills".equals(strMode))
        {
            String strTxtType = "";
            String strSelection = "";
            String strOnSubmit = "";
            String suiteDir  = (String) emxGetParameter(request, "SuiteDirectory");
               
            strTxtType = "type_BusinessSkill";
            strSelection = "multiple";
            strOnSubmit = "getTopWindow().getWindowOpener().getSelectedSkill";
        %>
            <script type="text/javascript">

                var objCommonAutonomySearch = new emxCommonAutonomySearch();
                objCommonAutonomySearch.txtType = "<%=XSSUtil.encodeForJavaScript(context,strTxtType)%>";
                objCommonAutonomySearch.selection = "<%=XSSUtil.encodeForJavaScript(context,strSelection)%>";
                objCommonAutonomySearch.submitURL= encodeURI("../"+"<%=XSSUtil.encodeForURL(context,suiteDir)%>"+"/emxProgramCentralResourcePoolPeopleUtil.jsp?mode=SubmitAssignSkills");
                objCommonAutonomySearch.open();
            </script>
        <%
        }
        else if("AssignToProjectSpaces".equals(strMode))
        {
            String strTxtType = "";
            String strSelection = "";
            String strOnSubmit = "";
            StringList slTableRowId  = new StringList();
           // StringList slPersonIds  = new StringList();
            String strPersonId = null;
            String strPersonIds = null;
            String strResourcePoolId = null;
            
            String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
            
            for (int i = 0; i < strEmxTableRowIds.length; i++)
            {
                slTableRowId  = FrameworkUtil.split(strEmxTableRowIds[i],"|");
                strPersonId = (String) slTableRowId.get(1);
                strResourcePoolId = (String) slTableRowId.get(2);
                if(strPersonIds != null)
                {
                    strPersonIds = strPersonIds +"," +strPersonId;
                }
                else
                {
                    strPersonIds = strPersonId;
                }
            }
            String suiteDir  = (String) emxGetParameter(request, "SuiteDirectory");
            strTxtType = "type_ProjectSpace";
            strSelection = "multiple";
            strOnSubmit = "getTopWindow().getWindowOpener().getSelectedProjectSpace"; 
            StringList slPersonIdList = FrameworkUtil.split(strPersonIds,",");
            boolean isKindOfPerson = isKindOfPersonObject(context, slPersonIdList);
            if(isKindOfPerson)
            {
            %>
            <script type="text/javascript">
                  var objCommonAutonomySearch = new emxCommonAutonomySearch();
                  objCommonAutonomySearch.txtType = "<%=XSSUtil.encodeForJavaScript(context,strTxtType)%>";
                  objCommonAutonomySearch.selection = "<%=XSSUtil.encodeForJavaScript(context,strSelection)%>";
                  var URI = "../"+"<%=XSSUtil.encodeForURL(context,suiteDir)%>"+"/emxProgramCentralResourcePoolPeopleUtil.jsp?mode=SubmitAssignToProjectSpaces&PersonIds="+"<%=XSSUtil.encodeForURL(context,strPersonIds)%>"+"&ResourcePoolId="+"<%=XSSUtil.encodeForURL(context,strResourcePoolId)%>"+"&excludeOIDprogram=emxWhatIf:excludeExperimentProject";
                  objCommonAutonomySearch.submitURL= encodeURI(URI);
                  objCommonAutonomySearch.open();
            </script>
            <%
            }
            else
            {
                String strLanguage = context.getSession()
                .getLanguage();

                String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                		"emxProgramCentral.ResourcePool.PeopleAction.SelectPerson", strLanguage);
            %>
                <script language="JavaScript">
                    alert("<%=sErrMsg%>");
                </script>
            <%
            }
        }
        else if("SubmitAssignSkills".equals(strMode))
        {
            String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
//           If there are not objects selected
            if (strEmxTableRowIds == null || strEmxTableRowIds.length == 0){
                String languageStr = context.getSession().getLanguage();
                String errMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                		"emxProgramCentral.ResourcePool.PeopleAction.SelectSkill", languageStr);
                throw new Exception(errMsg);
            }
            
            String strTableRowId = null;
            matrix.util.StringList slTokens = null;
            String strObjectId = null;
            matrix.util.StringList slSelectedBusinessSkill = new matrix.util.StringList();
            for (int i = 0; i < strEmxTableRowIds.length; i++)
            {
                strTableRowId = strEmxTableRowIds[i];
                if (strTableRowId == null || strTableRowId.length() == 0)
                {
                    continue;
                }
                slTokens = split(context,strTableRowId, "|");
                strObjectId = (String)slTokens.get(1);
                slSelectedBusinessSkill.add(strObjectId);
            }   
                
        }
        else if("SubmitAssignToProjectSpaces".equals(strMode))
        {
            String strTableRowIds = emxGetParameter(request,"PersonIds");
            String strResourcePoolId = emxGetParameter(request,"ResourcePoolId");
            StringList slPersonIds = FrameworkUtil.split(strTableRowIds,",");
            //String[] strPersonIds = slPersonIds.toArray(new String[slPersonIds.size()]);
            String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
            StringList slProjectIds = new StringList();
            StringList slProjectIdsToassign = new StringList();
           String strProjectId = null;
           
            for (int i = 0; i < strEmxTableRowIds.length; i++)
            {
                slProjectIds = FrameworkUtil.split(strEmxTableRowIds[i],"|");
                strProjectId = (String)slProjectIds.get(0);
                slProjectIdsToassign.add(strProjectId);
            }
          ResourcePool resourcePool = new ResourcePool(strResourcePoolId);
          resourcePool.assignPeoplesToProjectSpace(context,slProjectIdsToassign,slPersonIds);
          %>
          <script language="JavaScript">
              getTopWindow().closeWindow();
          </script>
          <%
        }
        else if("AssignToProjectRequest".equals(strMode))
        {
            String strTxtType = "";
            String strSelection = "";
            String strOnSubmit = "";
            String strPersonId = "";
            String strResourcePoolId = null;
            String strPersonIds = null;
            StringList slTableRowId = new StringList();
            String suiteDir  = (String) emxGetParameter(request, "SuiteDirectory");
            String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
            
            for (int i = 0; i < strEmxTableRowIds.length; i++)
            {
                slTableRowId  = FrameworkUtil.split(strEmxTableRowIds[i],"|");
                strPersonId = (String) slTableRowId.get(1);
                strResourcePoolId = (String) slTableRowId.get(2);
                if(strPersonIds != null)
                {
                    strPersonIds = strPersonIds +"," +strPersonId;
                }
                else
                {
                    strPersonIds = strPersonId;
                }
            }
            //Modified:9-Mar-2010:s4e:R209 PRG:IR-013248
            //Modified to get only Resource pool related requests,Instead of passing parameters to "objCommonAutonomySearch" the same parameters
            //has been passed to "emxFullSearch.jsp" which also includes "includeOIDprogram" which returns only resource pool related requests.
            strTxtType = "type_ResourceRequest";
            strSelection = "single";
            String strIncludeOIDprogram = "emxResourceRequestBase:getIncludeOIDForResourcePoolRequestSearch";
            strOnSubmit = "getTopWindow().getWindowOpener().getSelectedProjectSpace"; 
            StringList slPersonIdList = FrameworkUtil.split(strPersonIds,",");
            boolean isKindOfPerson = isKindOfPersonObject(context, slPersonIdList);
            if(isKindOfPerson)
            {
            %> <script type="text/javascript">
                    <%--var objCommonAutonomySearch = newemxCommonAutonomySearch();
                <!-- XSSOK-->     objCommonAutonomySearch.txtType = "<%=strTxtType%>";
                 <!-- XSSOK-->    objCommonAutonomySearch.selection ="<%=strSelection%>";--%>                    
                    var URI = "../"+"<%=XSSUtil.encodeForURL(context,suiteDir)%>"+"/emxProgramCentralResourcePoolPeopleUtil.jsp?mode=AssignToResourceRequest&PersonIds="+"<%=XSSUtil.encodeForURL(context,strPersonIds)%>"+"&ResourcePoolId="+"<%=XSSUtil.encodeForURL(context,strResourcePoolId)%>";
                    var nURL ="../common/emxFullSearch.jsp?field=TYPES="+"<%=XSSUtil.encodeForJavaScript(context,strTxtType)%>"+"&table=AEFGeneralSearchResults"+"&selection="+"<%=XSSUtil.encodeForJavaScript(context,strSelection)%>"+"&includeOIDprogram="+"<%=XSSUtil.encodeForJavaScript(context,strIncludeOIDprogram)%>"+"&submitURL="+URI;
                    showModalDialog(nURL, this.windowWidth,this.windowHeight, true);
                    //objCommonAutonomySearch.submitURL= encodeURI(URI);
                    //objCommonAutonomySearch.open();
                </script> <%
                
            }
          //End:9-Mar-2010:s4e:R209 PRG:IR-013248
            else
            {
                String strLanguage = context.getSession()
                .getLanguage();

                String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                		"emxProgramCentral.ResourcePool.PeopleAction.SelectPerson", strLanguage);
            %>
                <script language="JavaScript">
                    alert("<%=sErrMsg%>");
                </script>
            <%
            }
        }
        else if ("AssignToResourceRequest".equals(strMode))
        {
            StringList slTableRowIds =  new StringList();
            String strResourceRequestId = null;
            String strPersonIds = emxGetParameter(request,"PersonIds");
            StringList slPersonIds = FrameworkUtil.split(strPersonIds,",");
            String strResourcePoolId = emxGetParameter(request,"ResourcePoolId");
            String[] strEmxTableRowIds = emxGetParameterValues(request,"emxTableRowId");
            
            for (int i = 0; i < strEmxTableRowIds.length; i++)
            {
                 slTableRowIds = FrameworkUtil.split(strEmxTableRowIds[i],"|");
                 strResourceRequestId = (String) slTableRowIds.get(0);
            }
            ResourcePool resourcePool = new ResourcePool(strResourcePoolId);
            resourcePool.assignPeoplesToResourceRequest(context,slPersonIds,strResourceRequestId);
            %>
            <script language="JavaScript">
                getTopWindow().closeWindow();
            </script>
        <%
        }
        else if ("ResourcePoolReport".equals(strMode))
        {
        	String strObjectId = emxGetParameter(request,"objectId");
             String strSubmitUrl = "";
             
             Enumeration enumParams=emxGetParameterNames(request);
             StringBuilder urlBuilder  =   new StringBuilder();
             
             while(enumParams.hasMoreElements()) {
                  String param=(String)enumParams.nextElement();
                  String paramValue=emxGetParameter(request,param);
                  if ("submode".equalsIgnoreCase(param)) {
                      param="mode";
                  }
                  urlBuilder.append("&"+param+"="+paramValue);
             }            
             strSubmitUrl = urlBuilder.toString().substring(1);
             
             String strAction = "../common/emxIndentedTable.jsp?"+strSubmitUrl;
        %>
        <% 
        String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
        if(strEmxTableRowIds == null) {
        	strEmxTableRowIds = new String[1];
        	strEmxTableRowIds[0] = strObjectId ;
        }
        StringList slTableRowIdValuesSplit = null;
        String strResourcePoolIds = "";
        String strResourcePoolId = "";
        for (int i = 0; i < strEmxTableRowIds.length; i++)
        {
            slTableRowIdValuesSplit = FrameworkUtil.split(strEmxTableRowIds[i],"|"); 
            strResourcePoolId = (String)slTableRowIdValuesSplit.get(0);
       
            if(null!=strResourcePoolIds && !"".equals(strResourcePoolIds) && !"null".equals(strResourcePoolIds))
            {
                strResourcePoolIds = strResourcePoolIds +"," +strResourcePoolId;
            }
            else
            {
                strResourcePoolIds = strResourcePoolId;
            }
        %>
            <input type="hidden" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=strEmxTableRowIds[i]%></xss:encodeForHTMLAttribute>" />
        <%
        }
        %>
        <input type="hidden" name="ResourcePoolId" value="<xss:encodeForHTMLAttribute><%=strResourcePoolIds%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="ReportMode" value="<xss:encodeForHTMLAttribute><%=strMode%></xss:encodeForHTMLAttribute>" />
        <script language="javascript" type="text/javaScript">
           var objSubmitForm = document.forms["ResourcePoolPeopleUtil"];
           objSubmitForm.action = "<%=XSSUtil.encodeForJavaScript(context,strAction)%>";
           objSubmitForm.submit();
 <%          
           String URL = "../programcentral/emxProgramCentralUtil.jsp?mode=blankResourcePoolChart";
 %>
           var url = "<%=URL%>";
			var topFrame = findFrame(getTopWindow(), "PMCResourcePoolReportChart");	
			topFrame.location.href = url; 
        </script>
            <%
        }
        else if("ResourcePerPoolReport".equals(strMode))
        {
            String strObjectId = emxGetParameter(request,"objectId");
            String strSubmitUrl = "";
            
            Enumeration enumParams=emxGetParameterNames(request);
            StringBuilder urlBuilder  =   new StringBuilder();
            
            while(enumParams.hasMoreElements()) {
                 String param=(String)enumParams.nextElement();
                 String paramValue=emxGetParameter(request,param);
                 paramValue =   XSSUtil.encodeURLForServer(context, paramValue);
                 if ("submode".equalsIgnoreCase(param)) {
                     param="mode";
                 }
                 urlBuilder.append("&"+param+"="+paramValue);
            }            
            strSubmitUrl = urlBuilder.toString().substring(1);
           
            String strAction = "../common/emxIndentedTable.jsp?";
            strAction = strAction + strSubmitUrl;
            %>
        <input type="hidden" name="ResourcePoolId" value="<%=XSSUtil.encodeForHTMLAttribute(context,strObjectId)%>" />
        <input type="hidden" name="ReportMode" value="<xss:encodeForHTMLAttribute><%=strMode%></xss:encodeForHTMLAttribute>" />
        <script language="javascript" type="text/javaScript">
           var objSubmitForm = document.forms["ResourcePoolPeopleUtil"];
           objSubmitForm.action = "<%=XSSUtil.encodeForJavaScript(context,strAction)%>";
           objSubmitForm.submit();
       </script>
           <%
        }
        else if("ResourcePoolPeopleReport".equals(strMode))
        {
            String strSubmitUrl = "";
            
            Enumeration enumParams=emxGetParameterNames(request);
            StringBuilder urlBuilder  =   new StringBuilder();
            
            while(enumParams.hasMoreElements()) {
                 String param=(String)enumParams.nextElement();
                 String paramValue=emxGetParameter(request,param);
                 if ("submode".equalsIgnoreCase(param)) {
                	 param="mode";
                 }
                 urlBuilder.append("&"+param+"="+paramValue);
            }            
            strSubmitUrl = urlBuilder.toString().substring(1);
            
            String strPMCReportPeopleOverallFilter = emxGetParameter(request,"PMCReportPeopleProjectAssignementFilter");
            String strAction = "../common/emxIndentedTable.jsp?"+strSubmitUrl;
             
            String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
            StringList slTableRowIdValuesSplit = null;
            String strPersonIds = "";
            String strPersonId = "";
            for (int i = 0; i < strEmxTableRowIds.length; i++)
            {
                slTableRowIdValuesSplit = FrameworkUtil.split(strEmxTableRowIds[i],"|"); 
                strPersonId = (String)slTableRowIdValuesSplit.get(1);
                strPersonId = XSSUtil.encodeURLForServer(context, strPersonId);
                if(null!=strPersonIds && !"".equals(strPersonIds) && !"null".equals(strPersonIds))
                {
                    strPersonIds = strPersonIds +"," +strPersonId;
                }
                else
                {
                    strPersonIds = strPersonId;
                }
            %>
                <input type="hidden" name="emxTableRowId" value="<%=strEmxTableRowIds[i]%>" />
            <%
            }
            %>
            <input type="hidden" name="PMCReportPeopleProjectAssignementFilter" value="<xss:encodeForHTMLAttribute><%=strPMCReportPeopleOverallFilter%></xss:encodeForHTMLAttribute>" />
            <input type="hidden" name="ResourcePoolId" value="<%=XSSUtil.encodeForHTMLAttribute(context,strPersonIds)%>" />
            <input type="hidden" name="ReportMode" value="<%=strMode%>" />
            <% 
            StringList slPersonIdList = FrameworkUtil.split(strPersonIds,",");
            boolean isKindOfPerson = isKindOfPersonObject(context, slPersonIdList);
            if(isKindOfPerson)
            {
               %>
               <script language="javascript" type="text/javaScript">
                    var objSubmitForm = document.forms["ResourcePoolPeopleUtil"];
                    objSubmitForm.action = "<%=XSSUtil.encodeForJavaScript(context,strAction)%>";
                    objSubmitForm.submit();
               </script>
               <%
            }
            else
            {
                String strLanguage = context.getSession().getLanguage();
                String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                		"emxProgramCentral.ResourcePool.PeopleAction.SelectPerson", strLanguage);
            %>
                <script language="JavaScript">
                     alert("<%=sErrMsg%>");
                     window.closeWindow();
                </script>
                <%
            }
               %>
            <%
        }
        else if("ResourcePoolPeopleReportFilter".equals(strMode))
        {
            String strSubmitUrl = emxGetParameter(request,"submitURL");
            strSubmitUrl = strSubmitUrl.replaceAll("%26","&");
            String strPMCReportPeopleOverallFilter = emxGetParameter(request,"PMCReportPeopleProjectAssignementFilter");
            String strPMCReportLoadingProjectFilter = emxGetParameter(request,"PMCReportResourceLoadingProjectFilter");
            String strAction = "../common/emxIndentedTable.jsp?"+strSubmitUrl;
            String strStartDateValue = emxGetParameter(request, "PMCCustomFilterFromDate");
            String strEndDateValue   = emxGetParameter(request, "PMCCustomFilterToDate"); 
            String strPersonIds = emxGetParameter(request,"ResourcePoolId");
            %>
            <input type="hidden" name="PMCCustomFilterFromDate" value="<xss:encodeForHTMLAttribute><%=strStartDateValue%></xss:encodeForHTMLAttribute>" />
            <input type="hidden" name="PMCCustomFilterToDate" value="<xss:encodeForHTMLAttribute><%=strEndDateValue%></xss:encodeForHTMLAttribute>" />
            <input type="hidden" name="PMCReportPeopleProjectAssignementFilter" value="<%=XSSUtil.encodeForHTMLAttribute(context,strPMCReportPeopleOverallFilter)%>" />
            <input type="hidden" name="PMCReportResourceLoadingProjectFilter" value="<xss:encodeForHTMLAttribute><%=strPMCReportLoadingProjectFilter%></xss:encodeForHTMLAttribute>" />
            <input type="hidden" name="ResourcePoolId" value="<%=XSSUtil.encodeForHTMLAttribute(context,strPersonIds)%>" />
            <input type="hidden" name="ReportMode" value="<%=strMode%>" />
            <input type="hidden" name="sortColumnName" value="none" />
            <% 
            StringList slPersonIdList = FrameworkUtil.split(strPersonIds,",");
            boolean isKindOfPerson = isKindOfPersonObject(context, slPersonIdList);
            if(isKindOfPerson)
            {
            %>
                <script language="javascript" type="text/javaScript">
                     var objSubmitForm = document.forms["ResourcePoolPeopleUtil"];
                     objSubmitForm.action = "<%=XSSUtil.encodeForJavaScript(context,strAction)%>";
                     objSubmitForm.target="_parent";
                     objSubmitForm.submit();
                </script>
              <%
            }
            else
            {
                String strLanguage = context.getSession()
                            .getLanguage();

                String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                		"emxProgramCentral.ResourcePool.PeopleAction.SelectPerson", strLanguage);
            %>
                <script language="JavaScript">
                     alert("<%=sErrMsg%>");
                     window.closeWindow();
                </script>
                <%
            }
               %>
            <%
        }
        else if("AssignSkillToPerson".equals(strMode))
        {
            String strAction = "../components/emxComponentsAddSkillSearchForward.jsp?mode=ResourcePool&HelpMarker=emxhelpskillssearch";
            %>
            <% 
            String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
            StringList slTableRowIdValuesSplit = null;
            //String strResourcePoolIds = "";
            String strPersonIds = "";
            //String strResourcePoolId = "";
            String strPersonId = "";
            for (int i = 0; i < strEmxTableRowIds.length; i++)
            {
                slTableRowIdValuesSplit = FrameworkUtil.split(strEmxTableRowIds[i],"|"); 
                strPersonId = (String)slTableRowIdValuesSplit.get(1);
                strPersonId = XSSUtil.encodeURLForServer(context, strPersonId);
                if(null!=strPersonIds && !"".equals(strPersonIds) && !"null".equals(strPersonIds))
                {
                    strPersonIds = strPersonIds +"," +strPersonId;
                }
                else
                {
                    strPersonIds = strPersonId;
                }
            %>
                <input type="hidden" name="emxTableRowId" value="<%=strEmxTableRowIds[i]%>" />
            <%
            }
            StringList slPersonIdList = FrameworkUtil.split(strPersonIds,",");
            boolean isKindOfPerson = isKindOfPersonObject(context, slPersonIdList);
            if(isKindOfPerson)
            {
               %>
               <script language="javascript" type="text/javaScript">
                    var objSubmitForm = document.forms["ResourcePoolPeopleUtil"];
                    objSubmitForm.action = "<%=XSSUtil.encodeForJavaScript(context,strAction)%>";
                    objSubmitForm.target="_parent";
                    objSubmitForm.submit();
               </script>
               <%
            }
            else
            {
                String strLanguage = context.getSession()
                            .getLanguage();

                String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                		"emxProgramCentral.ResourcePool.PeopleAction.SelectPerson", strLanguage);
            %>
                <script language="JavaScript">
                     alert("<%=sErrMsg%>");
                     window.closeWindow();
                </script>
                <%
            }
               %>
            <%
        }
        else{
            return;
        }        
%>

    
</form>

<script type="text/javascript">

function getSelectedSkill(arrSelectedObjects) 
{
    var objForm = document.forms["ResourcePoolPeopleUtil"];
    if (objForm) 
    {
        for (var i = 0; i < arrSelectedObjects.length; i++) 
        {
            var objSelection = arrSelectedObjects[i];
           
            //objSkillDisplay.value = objSelection.name;
            alert(objSelection.name);
            //objSkillOID.value = objSelection.objectId;
            alert(objSelection.objectId);
        }
    }
}

function getSelectedSkill(arrSelectedObjects) 
{
    var objForm = document.forms["ResourcePoolPeopleUtil"];
    if (objForm) 
    {
        for (var i = 0; i < arrSelectedObjects.length; i++) 
        {
            var objSelection = arrSelectedObjects[i];
           
            //objSkillDisplay.value = objSelection.name;
            alert(objSelection.name);
            //objSkillOID.value = objSelection.objectId;
            alert(objSelection.objectId);
        }
    }
}
</script>
<!-- Page display code here -->

<%
        
            // Do something here
    }
    catch (Exception ex) 
    {
         if (ex.toString() != null && ex.toString().length() > 0) 
         {
            emxNavErrorObject.addMessage(ex.toString());
         }
        ex.printStackTrace();
    } 
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>

<%!

    /**
     * Method to split the string at given delimiter. 
     * Not using FrameworkUtil.split because of following issue.
     * If value "|A||C" is to be splitted at "|", then FrameworkUtil.split returns 3 tokens instead of 4. "A", "", "C".
     *
     * @param strValue - The value to be splitted
     * @param strDelimiter - The delimiter
     * @return StringList object containing the values tokenized at delimiter.
     * @throws Exception if operation fails
     */
    private static StringList split(Context context,String strValue, String strDelimiter) throws Exception {
        if (strValue == null) {
            
           
            String languageStr = context.getSession().getLanguage();
            String errMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
            		"emxProgramCentral.ResourcePool.PeopleAction.NullValue.errMsg", languageStr);
            throw new Exception(errMsg);
            //throw new Exception("Null strValue");
        }
        
        if (strDelimiter == null) {
            //added by na2
            String languageStr = context.getSession().getLanguage();
            String errMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
            		"emxProgramCentral.ResourcePool.PeopleAction.NullDelimiter.errMsg", languageStr);
            throw new Exception(errMsg);
            
            // throw new Exception("Null strDelimiter");
        }
        
        StringList slTokens = new StringList();
        String strTempValue = strValue;
        int nLengthOfDelimiter = strDelimiter.length();
        int nIndex = 0;
        boolean isFinished = false;
        
        while (!isFinished) {
            nIndex = strTempValue.indexOf(strDelimiter);
            if (nIndex == -1) {
                slTokens.add(strTempValue);
                isFinished = true;
            }
            else {
                slTokens.add(strTempValue.substring(0, nIndex));
                strTempValue = strTempValue.substring(nIndex+nLengthOfDelimiter);
            }
        }
        
        return slTokens;
    }

    /**
     * Method to check person object
     * @param context - Context object
     * @param slPersonIdList - PersonId list
     * @throws Exception if operation fails
     */
    private static boolean isKindOfPersonObject(Context context, StringList slPersonIdList) throws Exception 
    {
       StringList slSelectList = new StringList();
       slSelectList.add(DomainConstants.SELECT_ID);
       slSelectList.add("type.kindof["+DomainConstants.TYPE_PERSON+"]");
       String [] strPersonIds = new String [slPersonIdList.size()];
       slPersonIdList.copyInto(strPersonIds);
       BusinessObjectWithSelectList personObjWithSelectList = BusinessObject.getSelectBusinessObjectData(context,strPersonIds,slSelectList);
       BusinessObjectWithSelect bows = null;
       StringList slSelectIdDataList = null;
       StringList slSelectIdList = null;
       String strSelectQuery = "";
       Map mapQueryWithDataList = null;
       Map mapObjectIdWithQueryDataList = new HashMap();
       boolean isKindOfPerson = false;
       for(BusinessObjectWithSelectItr itr= new BusinessObjectWithSelectItr(personObjWithSelectList); itr.next();)
       {
           bows = itr.obj();
           isKindOfPerson = "true".equalsIgnoreCase(bows.getSelectData("type.kindof["+DomainConstants.TYPE_PERSON+"]"))?true:false;
           if(!isKindOfPerson)
           {
               break;   
           }
       }
       return isKindOfPerson;
    }

%>

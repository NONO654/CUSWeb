<%--  SpecificationProcess.jsp
   Processing logic to connect selected Requirement Specifications to a Project folder.

   Copyright (c)  2008-2018 Dassault Systemes. All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%-- Include JSP for error handling --%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<!-- /*
* @quickreview LX6 QYG 12:08:24(IR-123051V6R2013x  "FIR : No message on invoking invalid commands for Group in list view. ")
* @quickreview LX6 JX5 12:09:24 (IR-189357V6R2014   "STP: Requirement Specification creation page, 'Project Folder' browser button does not open window to add existing project folder. ")
*/ -->
<%-- @quickreview T25 OEP 12:12:10 : HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet--%>
<%-- @quickreview T25 DJH 12:12:12 : Solved merge with Louis' code --%>
<%-- @quickreview T25 OEP 12:12:18 : HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included --%>
<%-- @quickreview T25 DJH 13:10:18 : HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included. --%>
<%-- @quickreview LX6     18:12:14 : IR-328112-3DEXPERIENCER2016    STP: Object name modified from properties page is not displayed on specification structure display page. 
<%-- @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget. --%>
<%-- @quickreview QYG      15:07:15 : IR-380863-3DEXPERIENCER2016x - Add to Project KO for Requirement Specification --%>
<%-- Common Includes --%>
<%@include file="emxProductCommonInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.FrameworkUtil,
                com.matrixone.apps.domain.util.MapList,
                com.matrixone.apps.requirements.RequirementsCommon"
%>
<%@page import="com.matrixone.apps.requirements.RequirementGroup"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
//Start:IR:1230516R2013x:LX6
boolean isError = false;
try
{
//End:IR:1230516R2013x:LX6
   boolean isSlideIn = "slidein".equalsIgnoreCase(emxGetParameter(request, "targetLocation"));
   String objectId = emxGetParameter(request, "objectId");
   String mode = emxGetParameter(request,"mode");

   if ("specCreate".equalsIgnoreCase(mode))
   {
      String treePage = (String) session.getAttribute("treePage");

      // Replace the current content page with the new object's tree view...
      if ("true".equalsIgnoreCase(treePage))
      {
         String actionURL = "../common/emxTree.jsp?mode=insert&objectId=" + objectId;
%>
<script type="text/javascript">
	if(<xss:encodeForJavaScript><%=isSlideIn%></xss:encodeForJavaScript>)
	{
		var parentContentFrame = findFrame(getTopWindow(), "content");
		parentContentFrame.location.href="<xss:encodeForJavaScript><%=actionURL%></xss:encodeForJavaScript>";
		getTopWindow().closeSlideInDialog();
	}
	else
    {
    //KIE1 ZUD TSK447636 
		var parentContentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
		parentContentFrame.location.href="<xss:encodeForJavaScript><%=actionURL%></xss:encodeForJavaScript>";
		getTopWindow().closeWindow();
    }
</script>
<%
         session.removeAttribute("treePage");
      }
      // Otherwise, just refresh the existing table list of objects...
      else
      {
%>
<script type="text/javascript">
	if(<xss:encodeForJavaScript><%=isSlideIn%></xss:encodeForJavaScript>)
	{
		getTopWindow().refreshTablePage();
		getTopWindow().closeSlideInDialog();
	}
	else
	{
	//KIE1 ZUD TSK447636 
		if(getTopWindow().getWindowOpener().editableTable)
		{
		  getTopWindow().getWindowOpener().editableTable.loadData();
		  getTopWindow().getWindowOpener().emxEditableTable.refreshStructureWithOutSort();
		}
		else
		{
		  getTopWindow().getWindowOpener().document.location.href = getTopWindow().getWindowOpener().document.location.href;
		}
   		getTopWindow().closeWindow();
	}
</script>
<%
      }
   }

   else if("addToProject".equalsIgnoreCase(mode))
   {
	   //Start:IR:1230516R2013x:LX6
	   String[] emxTableRowId = emxGetParameterValues(request,"emxTableRowId");
	   //Start:IR:189357R2014:LX6
     if(emxTableRowId != null)
	   {
		     boolean isRequirementGroupInList = RequirementGroup.isRequirementGroupObject(context,emxTableRowId);
		     if(isRequirementGroupInList == true)
		     {
		       isError = true;
		       throw new Exception("invalidForReqGroup");
		     }		   
	   }
     //End:IR:189357R2014:LX6
	   //End:IR:1230516R2013x:LX6
      // Check whether Program Central is installed or not.
      //Modified:17-Mar-09:kyp:R207:RMT Bug 370346
      // Modified the property name appVersionProgramManagement to appVersionProgramCentral to check PMC installation!
      boolean pmcInstall = FrameworkUtil.isSuiteRegistered(context, "appVersionProgramCentral", false, null, null);
      //End:R207:RMT Bug 370346

      if (pmcInstall)
      {
         String[] objectIds = emxGetParameterValues(request, "emxTableRowId");
         String param="";
         if (objectIds != null)
         {
            for (int ii = 0; ii < objectIds.length; ii++)
               param += (ii == 0? "": ";") + objectIds[ii];
         }

         //To get the list of all active projects
         MapList resultList = RequirementsCommon.getActiveProjectFolders(context);
         int resultSize = resultList.size();

         String formName          = emxGetParameter(request, "formName");
         String fieldNameDisplay  = emxGetParameter(request, "fieldNameDisplay");
         String fieldNameActual   = emxGetParameter(request, "fieldNameActual");
         String rmtInstall        = emxGetParameter(request, "rmtInstall");

         String strType = "type_ProjectVault";
         
         boolean aerInstall = FrameworkUtil.isSuiteRegistered(context, "appVersionAerospaceProgramManagementAccelerator", false, null, null);
         
         if(aerInstall){
        	 strType = "type_ProjectVault:Type!=type_ContractPart,type_ContractSection";
         }	
%>
<script type="text/javascript">
   var strURL="../common/emxFullSearch.jsp?showToolbar=true&selection=multiple&toolbar=RMTRequirementSpecificationSearchToolbar&table=RMTProjectFolderList&field=TYPES=<%=strType%>&SubmitLabel=emxFramework.Common.Done&cancelButton=true&cancelLabel=emxFramework.Common.Cancel&submitURL=../requirements/SpecificationConnectToFolderProcess.jsp"+"&fieldNameDisplay="+'<xss:encodeForJavaScript><%=fieldNameDisplay%></xss:encodeForJavaScript>'+"&fieldNameActual="+'<xss:encodeForJavaScript><%=fieldNameActual%></xss:encodeForJavaScript>&param=<xss:encodeForJavaScript><%=param%></xss:encodeForJavaScript>';
   showModalDialog(strURL);
</script>
<%
         }
      // PMC is not installed, so the Project Search popup is not available...
      else
      {
%>
<script type="text/javascript">
   alert("<emxUtil:i18nScript localize='i18nId'>emxRequirements.Alert.PMCNotInstalled</emxUtil:i18nScript>");
   //KIE1 ZUD TSK447636 
   getTopWindow().closeWindow();
</script>
<%
      }
//START : IR-328112-3DEXPERIENCER2016    STP: Object name modified from properties page is not displayed on specification structure display page.
   }else if("refreshTable".equalsIgnoreCase(mode)){
	   String objectToRefresh = emxGetParameter(request,"ObjectToRefresh");
	   String rowId = emxGetParameter(request,"rowIds");
	   %>
	   <script type="text/javascript">  
	   var oXML = findFrame(getTopWindow(), "detailsDisplay").oXML;
	   var modifiedObjects = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@o='"+"<%=rowId%>"+"']");
	   arrIds=[];
	   for(var i=0;i<modifiedObjects.length;i++){
		   var id = modifiedObjects[i].getAttribute("id")
		   arrIds.push(id);
	   }
	   getTopWindow().sb.emxEditableTable.refreshRowByRowId(arrIds);
	   </script>
	   <%
   }
//END : IR-328112-3DEXPERIENCER2016    STP: Object name modified from properties page is not displayed on specification structure display page.
//Start:IR:1230516R2013x:LX6
}
catch(Exception e)
{
    String strAlertString = "emxRequirements.Alert." + e.getMessage();
    String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), strAlertString);
    if (i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
    {
        session.putValue("error.message", e.getMessage());
    }
    else
    {
        session.putValue("error.message", i18nErrorMessage);
    } 
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script type="text/javascript">
<%
if(isError == true)
{
%>
//KIE1 ZUD TSK447636 
getTopWindow().closeWindow();
<%
}
%>
</script type="text/javascript">
<!-- //End:IR:1230516R2013x:LX6 -->

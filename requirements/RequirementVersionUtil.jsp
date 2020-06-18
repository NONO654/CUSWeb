<%--
  RequirementVersionUtil.jsp

  Performs the action that creates an incident.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /web/requirements/RequirementVersionUtil.jsp 1.2 Wed Dec 03 15:50:10 2008 GMT ds-qyang Experimental$";

 --%>
 
<%-- @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget. --%>
<%--

Change History:
Date       Change By  Release   Bug/Functionality        Details
-----------------------------------------------------------------------------------------------------------------------------
1-Apr-09   kyp        V6R2010   372526                   For rollup functionality, modified submitLabel and cancelLabel 

--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
     respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview T25 DJH 18 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
 --%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>

<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Vector"%>
<%@page import = "com.matrixone.apps.common.util.FormBean"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.requirements.Requirement"%>
<%@page import = "com.matrixone.apps.requirements.RequirementsCommon"%>
<%@page import = "com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainRelationship"%>
<%@page import = "com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<html>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
    <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
    <form name="frm">
<%

    try
    {
        String strAlertMessage = "";
        String strMode = emxGetParameter(request,"mode");

        if ((strMode.equalsIgnoreCase("create")))
        {
			//extract Table Row ids of the checkboxes selected.
            String[] arrTableRowIds=emxGetParameterValues(request,"emxTableRowId");
			String parentObj = emxGetParameter(request, "objectId");

			String objIdToVersion = "";
			String location="appendChild";
            if (arrTableRowIds == null || arrTableRowIds.length < 1)
			{
				objIdToVersion = parentObj;
			}
			else
			{
	            if (arrTableRowIds[0].indexOf("|") >= 0 )
	            {
	                objIdToVersion = ((String[])ProductLineUtil.getObjectIds(arrTableRowIds))[0];
	                if(objIdToVersion.indexOf("|") >= 0 )
	                {
	                	objIdToVersion = objIdToVersion.substring(0, objIdToVersion.indexOf('|'));
	                }
	            }
	            else
	            {
	                objIdToVersion = arrTableRowIds[0];
	            }
			}
			
			if(!objIdToVersion.equals(parentObj))
			{
	            location = "lastSibling";
			}
			//Added:06-March-09:OEP:V6R2010:Bug:370464
			if (arrTableRowIds != null && arrTableRowIds.length > 1)
			{
			    %>
			    <script language="javascript" type="text/javaScript">
			    alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.MultiSelectionNotAllowed")%></xss:encodeForJavaScript>");
			    </script>
			    <%
			}
			 else
			 {
			RequirementsCommon requirementcommonBean = new RequirementsCommon(); 
			DomainRelationship dr = requirementcommonBean.createRequirementVersion(context,parentObj,objIdToVersion);

			String versionOid = requirementcommonBean.getObjectId();
            boolean closeRel = dr.openRelationship(context);
            StringList relSelects = new StringList(DomainConstants.SELECT_ID);
            Map details = dr.getRelationshipData(context, relSelects);
            StringList newRelId = (StringList) details.get(DomainConstants.SELECT_ID);
            dr.closeRelationship(context, closeRel);
	          %>
		            
			<script language="javascript" type="text/javaScript">
				if(typeof getTopWindow().emxEditableTable != 'undefined' && getTopWindow().emxEditableTable.isRichTextEditor){
			          	getTopWindow().emxEditableTable.addToSelected('<mxRoot><action>add</action><data  status="committed" >' + 
			          	'<item location="<xss:encodeForJavaScript><%=location%></xss:encodeForJavaScript>" oid="<xss:encodeForJavaScript><%=versionOid%></xss:encodeForJavaScript>" relId="<xss:encodeForJavaScript><%=newRelId.elementAt(0)%></xss:encodeForJavaScript>" pid="<xss:encodeForJavaScript><%=parentObj%></xss:encodeForJavaScript>"/></data></mxRoot>');
			    }
			    else{
					getTopWindow().refreshTablePage();
				}
			 </script>
		            <%
			 }
			//Ended:06-March-09:OEP:V6R2010:Bug:370464
		}
		else if ((strMode.equalsIgnoreCase("rollUp")))
        {		
			//extract Table Row ids of the checkboxes selected.
            String[] arrTableRowIds=emxGetParameterValues(request,"emxTableRowId");
			String requirementId = emxGetParameter(request, "objectId");
			
//			Added:7-Nov-09:kyp:R207:RMT Bug 373937			
			String suiteKey = emxGetParameter(request, "suiteKey");
//			End:R207:RMT Bug 373937

            if (arrTableRowIds != null && arrTableRowIds.length > 0)
			{
				String versionId = "";
	            if (arrTableRowIds[0].indexOf("|") >= 0 )
	            {
		                versionId = ((String[])ProductLineUtil.getObjectIds(arrTableRowIds))[0];
					    if(versionId.indexOf("|") >= 0 )
			            {
			               	versionId = versionId.substring(0, versionId.indexOf('|'));
			            }
	            }
	            else
	            {
	                versionId = arrTableRowIds[0];
	            }

	            boolean isVersionSelected = false;
	            String csrfTokenName="";
	            String csrfTokenValue="";
	            DomainObject versionObj = DomainObject.newInstance(context, versionId);
	            String policy = versionObj.getInfo(context, DomainConstants.SELECT_POLICY);
	            boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
	            if(csrfEnabled)
	            {
	            	Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
	            	csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
	            	csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
	            	System.out.println("CSRFINJECTION");
	            }
	            
	   
	            if(ReqSchemaUtil.getRequirementVersionPolicy(context).equals(policy)){
	            	isVersionSelected = true;
	            }
	            
				String strDirection = emxGetParameter(request,"direction");
				String strRelationship = emxGetParameter(request,"relationship");
				String strRollupMode = emxGetParameter(request,"rollUpMode");
				StringBuffer tableRelHref = new StringBuffer("../common/emxIndentedTable.jsp?");
				//tableRelHref.append("direction=" + strDirection);
				tableRelHref.append("program=emxRequirement:getVersionRels");
				//tableRelHref.append("&relationship=" + strRelationship);
				tableRelHref.append("&selection=multiple");
				tableRelHref.append("&isIndentedView=false");
				tableRelHref.append("&showClipboard=false");
				tableRelHref.append("&autoFilter=false");
				tableRelHref.append("&findMxLink=false");
				tableRelHref.append("&multiColumnSort=false");
				tableRelHref.append("&PrinterFriendly=false");
				tableRelHref.append("&triggerValidation=false");
				tableRelHref.append("&customize=false");
				tableRelHref.append("&Export=false");
				tableRelHref.append("&objectCompare=false");
				tableRelHref.append("&expandLevelFilter=false");
				tableRelHref.append("&cancelLabel=emxFramework.Common.Cancel");
				tableRelHref.append("&submitLabel=emxFramework.Button.Submit");				
				tableRelHref.append("&objectId=" + versionId);
//				Added:7-Nov-09:kyp:R207:RMT Bug 373937
				tableRelHref.append("&HelpMarker=emxhelpversionsrollup&suiteKey="+suiteKey);				
//				End:R207:RMT Bug 373937
				tableRelHref.append("&table=RMTRequirementRollUpTable");
				tableRelHref.append("&submitURL=../requirements/RequirementVersionUtil.jsp");
				tableRelHref.append("&mode=rollUp" + strRollupMode);
				tableRelHref.append("&parentObjectId=" + requirementId);
				tableRelHref.append("&"+ENOCsrfGuard.CSRF_TOKEN_NAME +"=" + csrfTokenName);
				tableRelHref.append("&"+ csrfTokenName +"=" + csrfTokenValue);

				String strTableRelHref = tableRelHref.toString();
				
				%>
				<script language="javascript" type="text/javaScript">
				if(<xss:encodeForJavaScript><%=isVersionSelected%></xss:encodeForJavaScript>){
					var fullHref  = "<xss:encodeForJavaScript><%=strTableRelHref%></xss:encodeForJavaScript>";
					//parent.document.location.href = fullHref
					showNonModalDialog(fullHref, 700, 500);
					//parent.closeWindow();
				}else{
					alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.SelectVersoin")%></xss:encodeForJavaScript>");
				}
				</script>
				<%
				
				//RequirementsCommon requirementcommonBean = new RequirementsCommon();
				//requirementcommonBean.rollUpRequirementVersionInfo(context,requirementId,versionId);
			}
		}
		else if (strMode.startsWith("rollUp"))
        {
			String[] arrTableRowIds=emxGetParameterValues(request,"emxTableRowId");
			String requirementId = emxGetParameter(request, "parentObjectId");
			String versionId = emxGetParameter(request, "objectId");
			
			StringBuffer relIds = new StringBuffer("");
            if (arrTableRowIds != null && arrTableRowIds.length > 0)
			{
				for (int i = 0; i < arrTableRowIds.length; i++)
				{
					if (relIds.length() > 0)
						relIds.append(",");
					relIds.append((arrTableRowIds[i].split("[|]"))[0]);
					//System.out.println("arrTableRowIds is: " + arrTableRowIds[i]);
				}
			}
			
			RequirementsCommon requirementcommonBean = new RequirementsCommon();
			requirementcommonBean.rollUpRequirementVersionInfo(context,strMode,requirementId,versionId,relIds.toString());
			
			%>
			//KIE1 ZUD TSK447636 
				<script language="javascript" type="text/javaScript">
				if(typeof getTopWindow().getWindowOpener().getTopWindow().emxEditableTable != 'undefined' && getTopWindow().getWindowOpener().getTopWindow().emxEditableTable.isRichTextEditor){
			          	getTopWindow().getWindowOpener().getTopWindow().emxEditableTable.refreshParent(); 
			    }
				//parent.closeWindow();
				if(isIE){ getTopWindow().open('','_self',''); }
				getTopWindow().closeWindow();
				</script>
			<%
		}
    }
    catch (Exception e)
    {
        //bFlag=true;
        String strAlertString = "emxRequirements.Alert." + e.getMessage();
        String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), strAlertString); 
        if(i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
        {
            session.putValue("error.message", e.getMessage());
        }else{
            session.putValue("error.message", i18nErrorMessage);
        }
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</form>
</html>


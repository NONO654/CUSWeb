<%-- ProductConfigurationCreate.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/configuration/ProductConfigurationUtil.jsp 1.70.2.7.1.2.1.1 Wed Dec 17 12:39:33 2008 GMT ds-dpathak Experimental$: ProductConfigurationUtil.jsp";
--%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.domain.*" %>
<%@page import="com.matrixone.apps.productline.*" %>
<%@page import = "com.matrixone.apps.configuration.*"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.configuration.ProductConfiguration"%>
<%@page import="javax.json.*" %>

<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../emxUIPageUtility.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIJson.js"></SCRIPT>
<script type="text/javascript" src="../webapps/c/UWA/js/UWA_Standalone_Alone.js"></script>

<%
	String strMode = emxGetParameter(request, "mode");
	String _sParentOID = emxGetParameter(request, "parentOID");
	String sParentObjId = emxGetParameter(request, "parentObjectID");//From RMB Assembly Configuration
	String isFromRMB = emxGetParameter(request, "isFromRMB");
	if(sParentObjId == null)
		sParentObjId = _sParentOID;

    String pcCreateMode =  EnoviaResourceBundle.getProperty(context,"emxConfiguration.ProductConfiguration.UIMode");
 // If block of code is unused, not getting called. Need to revisit the code for deprecation.
	if (strMode != null && strMode.equals("Apply")) {
		try {
			ProductConfiguration pConf = (ProductConfiguration) session
					.getAttribute("productconfiguration");
			String objectId = pConf.create(context); // Code added for fixing IR-242839V6R2014x 
			String validationMessage = i18nNow.getI18nString(
					"emxProduct.Alert.PcCreateSucessAlert", bundle,
					acceptLanguage);
			 isFromRMB = (String) session.getAttribute("isFromRMB");			
			/* JSONObject returnCode = new JSONObject();
			returnCode.put("code", "CREATE_SUCCESSFUL");
			returnCode.put("message", validationMessage);
			returnCode.put("objectId", objectId); // Code added for fixing IR-242839V6R2014x
			returnCode.put("isFromRMB", isFromRMB); */
			
			JsonObjectBuilder jsonObjBuild = Json.createObjectBuilder();
			jsonObjBuild.add("code", "CREATE_SUCCESSFUL");
			jsonObjBuild.add("message", validationMessage);
			jsonObjBuild.add("objectId", objectId);
			jsonObjBuild.add("isFromRMB", isFromRMB);
			JsonObject returnCode = jsonObjBuild.build();
					
			out.clear();
			out.println(returnCode.toString());
			out.flush();
		} catch (Exception ex) {
			/* JSONObject returnCode = new JSONObject();
			returnCode.put("code", "CREATE_ERROR");
			returnCode.put("message", ex.getMessage()); */
			JsonObjectBuilder jsonObjectBuild = Json.createObjectBuilder();
			jsonObjectBuild.add("code", "CREATE_ERROR");
			jsonObjectBuild.add("message", ex.getMessage());
			JsonObject returnCode = jsonObjectBuild.build();
			
			out.clear();
			out.println(returnCode.toString());
			out.flush();
		}
	} else {
		try {
			String contextOID = ConfigurationConstants.EMPTY_STRING;
			String parentProductId = ConfigurationConstants.EMPTY_STRING;
			String emxTableRowId = emxGetParameter(request,
					"emxTableRowId");
			session.removeAttribute("parentOID");
			
			if (emxTableRowId == null) {
				contextOID = emxGetParameter(request, "objectId");
				if(sParentObjId != null)
				parentProductId = sParentObjId;
				
			} else {
				//parentProductId = emxGetParameter(request, "objectId");
				parentProductId = sParentObjId;
				StringTokenizer rowIdTokens = new StringTokenizer(
						emxTableRowId, "|");
				rowIdTokens.nextElement();
				if (rowIdTokens.hasMoreElements()) 
				{
					contextOID = (String) rowIdTokens.nextElement();
					if(contextOID.indexOf(",") > 0 || emxTableRowId.endsWith("|0"))
					{
						%>
		                 <script>
		                  	 alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.CannotPerform</emxUtil:i18nScript>");
		                 </script>
			           <%
			            out.flush();
			            return;
					}else {
						DomainObject domContext = DomainObject.newInstance(context,contextOID);
						String ctxType = domContext.getInfo(context,ConfigurationConstants.SELECT_TYPE);
						if(ConfigurationConstants.TYPE_PRODUCT_CONFIGURATION.equalsIgnoreCase(ctxType))
						{
		%>
		                 <script>
		                    alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.CannotPerform</emxUtil:i18nScript>");
		                 </script>
		                 <%
		                    out.flush();
		                                    return;
		                                }
					}
				} else 
				{
					contextOID = null;
				}
                 			}
			ProductConfiguration pConf = ProductConfigurationFactory.newInstance(context);
                 			if (ProductLineCommon.isNotNull(contextOID))
			{
				//pConf.loadContextStructure(context, contextOID,parentProductId);
				pConf.hasConfigurationFeatures(context, contextOID);
			}
                 			session.setAttribute("productconfiguration", pConf);
                 			session.setAttribute("parentOID",parentProductId);
                 			session.setAttribute("isFromRMB",isFromRMB);
                 			
                 %>
<script language="javascript" type="text/javaScript">
	<% if(pcCreateMode == null || !"Solver".equals(pcCreateMode))
	{
	%>
                showModalDialog("../components/emxCommonFS.jsp?functionality=ProductConfigurationCreateFlatViewFSInstance&PRCFSParam1=ProductConfiguration&context=sbEdit&suiteKey=Configuration&parentOID=<%=XSSUtil.encodeForURL(context,sParentObjId)%>&objectId=<%=XSSUtil.encodeForURL(context,contextOID)%>",940,680,true,'MediumTall');    
     <%
	}else {
	%>	

	getTopWindow().showSlideInDialog("ProductConfiguratorCreateFS.jsp?PRCFSParam1=ProductConfiguration&context=sbEdit&strAction=create&suiteKey=Configuration&parentOID=<%=XSSUtil.encodeForURL(context,sParentObjId)%>&contextId=<%=XSSUtil.encodeForURL(context,contextOID)%>&objectId=<%=XSSUtil.encodeForURL(context,contextOID)%>", true, this, "right");
    getTopWindow().document.getElementById("rightSlideIn").style.width = "500px";
    <%
	}
	%>
</script>
            
 <%
             	} catch (FrameworkException ex) {
             %>
        <script language="javascript" type="text/javaScript">
              alert("<%=XSSUtil.encodeForJavaScript(context,ex.getMessage())%>");
        </script>
 <%
 		}
 	}
 %>


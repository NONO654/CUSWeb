<%-- ProductConfigurationViewPreProcess.jsp
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

<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../emxUIPageUtility.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIJson.js"></SCRIPT>

<%@page import = "com.matrixone.apps.configuration.ProductConfiguration"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import = "java.util.TimeZone"%>
<%@page import = "java.text.DateFormat"%>
<%@page import = "com.matrixone.apps.domain.util.eMatrixDateFormat"%>
<%@page import = "java.util.Calendar"%>

<%

String pcCreateMode =  EnoviaResourceBundle.getProperty(context,"emxConfiguration.ProductConfiguration.UIMode");
String pcId = emxGetParameter(request,"objectId");
String fromPCComparePage = emxGetParameter(request,"fromPCComparePage");
ProductConfiguration pConf = new ProductConfiguration();
pConf.setId(pcId);
pConf.setUserAction(ProductConfiguration.ACTION_PC_EDIT);
pConf.loadDetails(context);
boolean effectiveFeaturesExist = true;
String strStartEffectivity = ConfigurationConstants.EMPTY_STRING;
String contextId = ConfigurationConstants.EMPTY_STRING;
String strProductContextId = ConfigurationConstants.EMPTY_STRING;


try
{
	DomainObject domPC = new DomainObject(pcId);
	StringList pcSelects = new StringList();
	pcSelects.add("to["+ConfigurationConstants.RELATIONSHIP_PRODUCT_CONFIGURATION+"].from.id");
	pcSelects.add("to["+ConfigurationConstants.RELATIONSHIP_FEATURE_PRODUCT_CONFIGURATION+"].from.id");
	pcSelects.add("attribute["+ConfigurationConstants.ATTRIBUTE_START_EFFECTIVITY+"]");

	Map pcMap = domPC.getInfo(context, pcSelects);
	contextId = (String)pcMap.get("to["+ConfigurationConstants.RELATIONSHIP_PRODUCT_CONFIGURATION+"].from.id");
	strProductContextId = (String)pcMap.get("to["+ConfigurationConstants.RELATIONSHIP_FEATURE_PRODUCT_CONFIGURATION+"].from.id");
	String attrStartEffectivityDate = (String)pcMap.get("attribute["+ConfigurationConstants.ATTRIBUTE_START_EFFECTIVITY+"]");

	TimeZone tz = TimeZone.getTimeZone(context.getSession().getTimezone());
	Calendar cal = Calendar.getInstance(tz);
	double dbMilisecondsOffset = (double)cal.DST_OFFSET;
	double iClientTimeOffset = (new Double(dbMilisecondsOffset/(1000*60*60))).doubleValue();
	strStartEffectivity = eMatrixDateFormat.getFormattedDisplayDate(attrStartEffectivityDate, iClientTimeOffset, context.getLocale());

	if(!"Solver".equals(pcCreateMode))
	{
		pConf.initContext(context);
		pConf.loadContextStructure(context,pConf.getContextId(),pConf.getParentProductId());
	}

}
catch(Exception epn)
{
	effectiveFeaturesExist = false;
}

if(contextId == null){
%>
<SCRIPT language="javascript" type="text/javaScript">
		alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.NoReadAcess</emxUtil:i18nScript>");	
</SCRIPT>
<%
	} else {

if(!"Solver".equals(pcCreateMode))
{
pConf.loadSelectedOptions(context);
session.setAttribute("productconfiguration", pConf);

%>
<SCRIPT language="javascript" type="text/javaScript">

    //XSSOK
	var effectiveFeatures = "<%=effectiveFeaturesExist%>";
	if(effectiveFeatures == "false")
	{
		alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.ProductConfiguration.SelectedOptions.IneffectiveObsolete</emxUtil:i18nScript>");
		showModalDialog('ProductConfigurationViewFS.jsp?FSmode=featureSelect&PRCFSParam2=edit&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&functionality=ProductConfigurationEditOptionsContentFSInstance&suiteKey=Configuration&HelpMarker=emxhelpproductconfigurationdetails', 940, 770);
	}else {
   		showModalDialog('ProductConfigurationViewFS.jsp?FSmode=featureSelect&PRCFSParam2=edit&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&functionality=ProductConfigurationEditOptionsContentFSInstance&suiteKey=Configuration&HelpMarker=emxhelpproductconfigurationdetails', 940, 770);
	}
</SCRIPT>

<%
}else if("true".equals(fromPCComparePage)){
	String appendParams = emxGetQueryString(request);
%>
<SCRIPT>
	showModalDialog('ProductConfiguratorFS.jsp?contextId=<%=XSSUtil.encodeForURL(context, contextId) %>&strProductContextId=<%=XSSUtil.encodeForURL(context, strProductContextId)%>&pcId=<%=XSSUtil.encodeForURL(context, pcId)%>&txtStartEffectivity=<%= XSSUtil.encodeForURL(context, strStartEffectivity) %>&strAction=edit&<%=XSSUtil.encodeForJavaScript(context, appendParams) %>', 940, 770);
</SCRIPT>
<%	
}
else
{
	String appendParams = emxGetQueryString(request);
%>
<SCRIPT>	
	location.href = 'ProductConfiguratorFS.jsp?contextId=<%=XSSUtil.encodeForURL(context,contextId)%>&strProductContextId=<%=XSSUtil.encodeForURL(context,strProductContextId)%>&pcId=<%=XSSUtil.encodeForURL(context,pcId)%>&txtStartEffectivity=<%= XSSUtil.encodeForURL(context, strStartEffectivity) %>&strAction=view&<%=XSSUtil.encodeForJavaScript(context, appendParams) %>';
</SCRIPT>
<%
}
}
%>


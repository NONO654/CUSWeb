<% response.setContentType("text/xml");
   response.setContentType("charset=UTF-8");
   response.setHeader("Content-Type", "text/xml");
   response.setHeader("Cache-Control", "no-cache");
   response.getWriter().write("<?xml version='1.0' encoding='iso-8859-1'?>");
%>
<%--
//@fullReview  ZUR 11/06/24 HL XP New Infra Applications Param
--%>

<%@ page import="java.util.*"%>
<%@ page import="java.lang.Integer"%>

<%@ page import ="com.matrixone.vplm.FreezeServerParamsSMB.FreezeServerParamsSMB"%>
<%@ page import ="com.matrixone.vplm.applicationsIntegrationInfra.AppIntUIConnector"%>

<%@ page import ="com.matrixone.apps.domain.util.ContextUtil"%>
<%@ page import ="com.matrixone.apps.framework.ui.UICache"%>
<%@ page import ="com.matrixone.apps.framework.ui.CacheManager"%>
<%@ page import ="matrix.util.StringList"%>

<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%

//	<root>
//		<ParamsAppsSet>S_OK</ParamsAppsSet>
//		<ParamsAppsSet>E_Fail</ParamsAppsSet>
//
//		<Freezeret>S_OK</Freezeret>
//		<Freezeret>E_Internal</Freezeret>
//		<Freezeret>E_Frozen</Freezeret>
//
//		<!-- 3 next present only if ParamsAppsSet==E_Fail -->
//		<ParamsStoredAndDeployed>paramID1,paramID2,paramID3</ParamsStoredAndDeployed>
//		<ParamsStoredOnly>paramID4,paramID5</ParamsStoredOnly>
//		<ParamsNotStored>paramID6,paramID7,paramID8,paramID9</ParamsNotStored>
//
//		<ReloadCacheRet>S_OK</ReloadCacheRet>
//		<ReloadCacheRet>E_Fail</ReloadCacheRet>
//		<ReloadCacheRet>S_Unneeded</ReloadCacheRet>
//	</root>

AppIntUIConnector appIntUIConnector = new AppIntUIConnector(context);

String domainID = emxGetParameter(request,"domainID");

String nbParametersStr = emxGetParameter(request,"numberbofSentParams");
int nbParameters = Integer.parseInt(nbParametersStr);

boolean doReloadCache = false;
String[] parameterIDs = new String[nbParameters];

for (int i=0 ; i<nbParameters ; i++)
{
	parameterIDs[i] = emxGetParameter(request, "iParamID_" + i);
	int nbOfArguments = Integer.parseInt(emxGetParameter(request, "nbOfArguments_" + i));
	for (int j=0 ; j<nbOfArguments ; j++)
	{
		String argumentID    = emxGetParameter(request, "iArgumentID_"    + i + "_" + j);	
		String argumentValue = emxGetParameter(request, "iArgumentValue_" + i + "_" + j);	
		appIntUIConnector.setValues(domainID, parameterIDs[i], argumentID, argumentValue);
	}
	if (!doReloadCache)
		doReloadCache = appIntUIConnector.parameterRequiresReloadCache(domainID, parameterIDs[i]);
}

String retXmlString = "<root>";
if (appIntUIConnector.deploy() == AppIntUIConnector.S_SUCCESS)
{
	retXmlString += "<ParamsAppsSet>S_OK</ParamsAppsSet>";
	if ("true".equalsIgnoreCase(emxGetParameter(request, "frzStatus")))
	{
		FreezeServerParamsSMB freezeInst = new FreezeServerParamsSMB();
		String commandtofreeze = appIntUIConnector.getCommandName(domainID);
		int iretFreeze = freezeInst.SetServerFreezeStatusDB(context, commandtofreeze);
		if (iretFreeze == FreezeServerParamsSMB.S_SUCCESS)
			retXmlString += "<Freezeret>S_OK</Freezeret>";
		else if (iretFreeze == FreezeServerParamsSMB.E_INTERNAL_ERROR)
			retXmlString += "<Freezeret>E_Internal</Freezeret>";
		else
			retXmlString += "<Freezeret>E_Frozen</Freezeret>";
	}
}
else
{
	retXmlString += "<ParamsAppsSet>E_Fail</ParamsAppsSet>";
	
	String paramStoredAndDeployed = "";
	String paramStoredOnly = "";
	String paramNotStored = "";
	for (String parameterID : parameterIDs)
	{
		int status = appIntUIConnector.getDeployStatus(domainID, parameterID);
		if (status == AppIntUIConnector.PARAM_STORED_AND_DEPLOYED)
			paramStoredAndDeployed += ("".equals(paramStoredAndDeployed) ? "" :",") + parameterID;
		else if (status == AppIntUIConnector.PARAM_STORED_ONLY)
			paramStoredOnly += ("".equals(paramStoredOnly) ? "" :",") + parameterID;
		else if (status == AppIntUIConnector.PARAM_NOT_STORED)
			paramNotStored += ("".equals(paramNotStored) ? "" :",") + parameterID;
	}
	if (!"".equals(paramStoredAndDeployed))
		retXmlString += "<ParamsStoredAndDeployed>" + paramStoredAndDeployed + "</ParamsStoredAndDeployed>";
	else
		doReloadCache = false;
	if (!"".equals(paramStoredOnly))
		retXmlString += "<ParamsStoredOnly>" + paramStoredOnly + "</ParamsStoredOnly>";
	if (!"".equals(paramNotStored))
		retXmlString += "<ParamsNotStored>" + paramNotStored + "</ParamsNotStored>";
}

if (doReloadCache)
{
	try
	{
		ContextUtil.startTransaction(context, false);
		UICache.loadUserRoles(context, session);
		StringList errAppSeverList = CacheManager.resetRemoteAPPServerCache(context, pageContext);
		CacheManager.resetRMIServerCache(context);
		ContextUtil.commitTransaction(context);
		retXmlString += "<ReloadCacheRet>S_OK</ReloadCacheRet>";
	}
	catch (Exception e)
	{
		ContextUtil.abortTransaction(context);
		retXmlString += "<ReloadCacheRet>E_Fail</ReloadCacheRet>";
	}
}
else
	retXmlString += "<ReloadCacheRet>S_Unneeded</ReloadCacheRet>";

retXmlString += "</root>";

response.getWriter().write(retXmlString);

%>

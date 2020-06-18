<%-- (c) Dassault Systemes, 2007, 2008 --%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../simulationcentral/smaWebUtil.inc"%>

<%@page import="matrix.util.StringList"%>
<%@page import="java.io.UnsupportedEncodingException"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Iterator"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page
	import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page
	import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%@page import="matrix.db.BusinessType"%>
<%@page import="matrix.db.BusinessTypeList"%>
<%@page import="matrix.db.BusinessTypeItr"%>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.db.RelationshipType"%>
<%@page import="matrix.db.JPO"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.util.Map, java.util.Enumeration"%>

<jsp:useBean id="tableBean"
	class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<jsp:useBean id="simBean"
	class="com.dassault_systemes.smaslm.matrix.web.smaSearchSimulation"
	scope="session" />


<html>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/jquery-latest.js"></script>
<%!
void buildFTSURLWithDefault (URLBuilder URL)
{
    URL.append("../common/emxFullSearch.jsp")
    .append("?showInitialResults=true&table=AEFGeneralSearchResults");
    
}

StringList getAGAssinableTypeList (Context context)
{
    final String TYPE_ANALYTICS_CASE = SimulationUtil.getSchemaProperty(context, SimulationConstants.SYMBOLIC_type_AnalyticsCase);
    final String TYPE_SIMULATION = SimulationUtil.getSchemaProperty(context, SimulationConstants.SYMBOLIC_type_Simulation);
    final String TYPE_SIMULATION_ACTIVITY = SimulationUtil.getSchemaProperty(context, SimulationConstants.SYMBOLIC_type_SimulationActivity);
    final String TYPE_SIMULATION_TEMPLATE = SimulationUtil.getSchemaProperty(context, SimulationConstants.SYMBOLIC_type_SimulationTemplate);
    final String TYPE_SIMULATION_DOCUMENT_NONVER = SimulationUtil.getSchemaProperty(context, SimulationConstants.SYMBOLIC_type_SimulationDocument_NonVersioned);
    final String TYPE_SIMULATION_DOCUMENT_VER = SimulationUtil.getSchemaProperty(context, SimulationConstants.SYMBOLIC_type_SimulationDocument_Versioned);
    final String TYPE_SIMULATION_DOCUMENT = SimulationUtil.getSchemaProperty(context, SimulationConstants.SYMBOLIC_type_SimulationDocument);
    StringList agAssignableTypes = new StringList();
    agAssignableTypes.add(TYPE_ANALYTICS_CASE);
    agAssignableTypes.add(TYPE_SIMULATION);
    agAssignableTypes.add(TYPE_SIMULATION_ACTIVITY);
    agAssignableTypes.add(TYPE_SIMULATION_TEMPLATE);
    agAssignableTypes.add(TYPE_SIMULATION_DOCUMENT_NONVER);
    agAssignableTypes.add(TYPE_SIMULATION_DOCUMENT_VER);
    agAssignableTypes.add(TYPE_SIMULATION_DOCUMENT);
    return agAssignableTypes;
}
%>
<%
String objectAction = emxGetParameter(request, "objectAction");
String objectId = emxGetParameter(request, "objectId");
String fieldParam = emxGetParameter(request, "field");
if (objectAction != null && "assignAttributeGroups".equals(objectAction)
&& objectId != null && !"".equals(objectId))
{
    StringList agAssignableTypes = getAGAssinableTypeList(context);
    // type_SimulationActivity type_Simulation type_AnalyticsCase type_SimulationTemplate type_SimulationDocument 
    DomainObject domainObj = DomainObject.getObject(context, objectId);
    String objectType = domainObj.getInfo(context, DomainObject.SELECT_TYPE);
    final String TYPE_SIMULATION_DOCUMENT_NONVER = SimulationUtil.getSchemaProperty(context, SimulationConstants.SYMBOLIC_type_SimulationDocument_NonVersioned);
    final String TYPE_SIMULATION_DOCUMENT_VER = SimulationUtil.getSchemaProperty(context, SimulationConstants.SYMBOLIC_type_SimulationDocument_Versioned);
    final String TYPE_SIMULATION_DOCUMENT = SimulationUtil.getSchemaProperty(context, SimulationConstants.SYMBOLIC_type_SimulationDocument);
    if(objectType.contains(TYPE_SIMULATION_DOCUMENT)) {
        if(objectType.contains(TYPE_SIMULATION_DOCUMENT_NONVER)) {
        	agAssignableTypes.remove(TYPE_SIMULATION_DOCUMENT_NONVER);
        }else {
        	agAssignableTypes.remove(TYPE_SIMULATION_DOCUMENT_VER);
        }    	
    	agAssignableTypes.remove(TYPE_SIMULATION_DOCUMENT);
    }else {
    	agAssignableTypes.remove(objectType);
    }
    String assinableTypes = "";
    for (int i = 0; i < agAssignableTypes.size(); i++)
    {
        assinableTypes += agAssignableTypes.get(i) + ",";
    }
    fieldParam = fieldParam + ":ATTRIBUTE_GROUP_TYPE!=" + assinableTypes.substring(0, assinableTypes.length());
}

URLBuilder URL = getURLBuilder(request);
buildFTSURLWithDefault(URL);
String from3DSpace  = emxGetParameter(request, "from3DSpace");
Enumeration eNumParameters = emxGetParameterNames(request);
while( eNumParameters.hasMoreElements() ) {
    String parmName = (String)eNumParameters.nextElement();
    String parmValue = "";
    if ("field".equals(parmName))
    {
        parmValue = fieldParam;
    } else {
        parmValue = (String)emxGetParameter(request,parmName);
    }
    URL.append("&"+parmName+"="+parmValue);
    }

//URL.append("../common/emxFullSearch.jsp?showInitialResults=true&table=SMASimType_Results&selection=multiple&submitURL=../simulationcentral/smaFTSSearchPostUtilAction.jsp?slmmode=chooserMultiple&formName=emxCreateForm&frameName=searchPane&slmform=SMASimulation_Create&field=TYPES=type_SimulationAttributeGroup");

// ${COMMON_DIR}/emxFullSearch.jsp?showInitialResults=true&table=SMASimType_Results&selection=multiple&submitURL=\${SUITE_DIR}/smaFTSSearchUtil.jsp?slmmode=chooserMultiple&formName=emxCreateForm&frameName=searchPane&slmform=SMASimulation_Create&field=TYPES=type_SimulationAttributeGroup:LATESTREVISION=true
if(from3DSpace!=null && from3DSpace.equalsIgnoreCase("true"))
	{
%>
<script language="Javascript">
getTopWindow().location.href="<%=XSSUtil.encodeForJavaScript(context, URL.toString())%>";
</script>
<%
	}
else
	{
%>
<script language="Javascript">
showModalDialog('<%=XSSUtil.encodeForJavaScript(context, URL.toString())%>');
</script>
<%
	}
%>





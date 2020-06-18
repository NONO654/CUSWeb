<%--  smaOpenSimInAdvise.jsp 
  -- jsp launched from run command of simulation activity property page.

 * (c) Dassault Systemes, 2013
 *  
--%>


<%-- Common Includes --%>
<%@page import="java.util.Iterator"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "com.matrixone.apps.domain.util.ContextUtil" %>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.Parameters"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.URLBuilder"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.AnalyticsCaseEntityWUtil"%>

<%@page import = "matrix.db.JPO"%>

<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<!--  <html> and <head> were added by something above here.   -->
</head>
<body>

<%
    String sError = "";
    URLBuilder contentURL = new URLBuilder(
        request.getRequestURI().length(),
        request.getCharacterEncoding());
    
    // get simulation id
    String strObjId = emxGetParameter(request, "objectId");
    String emxTblRowId = "";
    
    // RA run as
    String runAsStr = emxGetParameter(request, "runAs");		 
    boolean runAs = Boolean.parseBoolean(runAsStr);
    
    if (strObjId != null &&  strObjId.length() > 0)
    {
    	String[] objIdArray = strObjId.split("\\,");
    	Map<String, String> jobIdMap = AnalyticsCaseEntityWUtil.getJobIdsForObjects(context, objIdArray);
    	    	
    	try{
    		Iterator it = jobIdMap.entrySet().iterator();
    		while (it.hasNext()){
    			Map.Entry me = (Map.Entry) it.next();
    			if (! me.getValue().toString().isEmpty()){
    				emxTblRowId += "&emxTableRowId=|" + me.getValue().toString() + "|" 
    								+ me.getKey().toString() + "|0,0";
    			}
    		}
    	}
    	catch(Exception e){
    		 sError = SimulationUtil.getI18NString(context,
                     "smaSimulationCentral.Discover.NoJobs");
                 emxNavErrorObject.addMessage(sError);
    	}
    	
    	Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
        String href = SlmUIUtil.getCommandHref(context,"SMADiscover_OpenInAdvise", 
        									objIdArray[0], objIdArray[0], requestMap);
        
        contentURL.append(href).append(emxTblRowId);
        
        if (runAs){
        	contentURL.append("&runAs=true");
        }
    }
    else {
    	sError = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.Discover.NoJobs");
            emxNavErrorObject.addMessage(sError);
    }
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%
        // if we have an error print out message
        // otherwise re-set href
        if (sError.length()>0 )
        {
%>
<script language=javascript>
window.closeWindow();
</script>
<%
            return;  
        }    
%>

<script language="javascript">

window.location.href = "<%=contentURL.toString()%>";
</script>

</body>
</html>


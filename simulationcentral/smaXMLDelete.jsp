<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%-- Wrapper JSP to invoke deleteJPO with selected rows. --%>

<%-- Common Includes --%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="matrix.db.JPO"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>

<jsp:useBean id="tableBean"
    class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<!-- Used to load "findFrame" --> 
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
    matrix.db.Context context2 = (matrix.db.Context) request
        .getAttribute("context");
    if (context2 != null)
        context = context2;

    String timeStamp = emxGetParameter(request, "timeStamp");
    Map tableData = (Map) tableBean.getTableData(timeStamp);

    String tableRowId[] = 
        request.getParameterValues("emxTableRowId");
    

    String strDeleteJPO = emxGetParameter(request, "deleteJPO");
    String strJPOName = null;
    String strMethodName = null;
    if (strDeleteJPO != null)
    {
        strJPOName = strDeleteJPO.substring(0, 
            strDeleteJPO.indexOf(":"));
        strMethodName = strDeleteJPO.substring(
            strDeleteJPO.indexOf(":") + 1, strDeleteJPO.length());
    }

    try
    {
        if ((strJPOName != null) && !(strJPOName.equals(""))
            && (strMethodName != null)
            && !(strMethodName.equals("")))
        {
            Map inputMap = new HashMap();
            final String OBJECT_IDS = "objectIDs";
            inputMap.put(OBJECT_IDS, tableRowId);

            inputMap.put("requestMap",
                UINavigatorUtil.getRequestParameterMap(pageContext));
            inputMap.put("tableData", tableData);
            inputMap.put("selectedStep", 
                (String)session.getAttribute("selectedStep"));


            ContextUtil.startTransaction(context, true);
            try
            {
            	String deleteStatus = "true";
            	String xmlAttribute = emxGetParameter(request, "xmlAttribute");
            	
            	// If we are dealing with deletion of parameters, especially object parameters then we need to
            	// disconnect the referenced object from the activity.
            	// The JPO SimulationParameters:deleteParameter disconnects the referenced object if the parameter we are
            	// deleting is an object parameter
            	if(xmlAttribute.equalsIgnoreCase("attribute_Parameters")){
                	
                    if(tableRowId != null){
                    	
                    	Map argsMap = new HashMap();
	                    Map requestMap = (Map)inputMap.get("requestMap");
	                    String objectID = (String)requestMap.get("objectId");
	                    String parentOID = (String)requestMap.get("parentOID");
	                    
	                    if(objectID != null)
	                    {	                    	
	                        argsMap.put("objectId", objectID);
	                        argsMap.put("tableRowId", tableRowId);
	                        argsMap.put("parentOID", parentOID);
				
	                        deleteStatus = (String) JPO.invoke(
	                            context,
	                            "jpo.simulation.SimulationParameters",
	                            null,
	                            "deleteParameter",
	                            JPO.packArgs(argsMap),
	                            String.class);
	                    }
                    }
                }
            	
            	if("true".equals(deleteStatus)){
                String errorMsg = (String)
                    JPO.invoke(context,
                        strJPOName, new String[0],
                        strMethodName, JPO.packArgs(inputMap),
                        String.class);
                
                if (errorMsg != null && !(errorMsg.equalsIgnoreCase("ExportRules") || errorMsg.equalsIgnoreCase("ImportRules")
                		|| errorMsg.equalsIgnoreCase("DeleteRules")))
                {
                    ContextUtil.abortTransaction(context);
                    emxNavErrorObject.addMessage(errorMsg);
                }
                else
                {
                    ContextUtil.commitTransaction(context);
                    
                    // If we are deleting the rules, once that we have deleted the selected rules successfully, 
                    // just refresh the rule channel.
                    if(strMethodName.equalsIgnoreCase("deleteRules")){
                    	String ruleType = errorMsg;
                    	if(ruleType!=null && ruleType.equalsIgnoreCase("ExportRules")){
                  		%>
		                    <script>
		                    var f = findFrame(getTopWindow(),'SMAImportExport_TabExportRule'); 
		                    f.location.href = f.location.href;
		                    </script>
                   	   <%}
                    	else if(ruleType!=null && ruleType.equalsIgnoreCase("ImportRules")){
                    		%>
		                    <script>
		                    var f = findFrame(getTopWindow(),'SMAImportExport_TabImportRule'); 
		                    f.location.href = f.location.href;
		                    </script>
                   	   <%}
                    	else if(ruleType!=null && ruleType.equalsIgnoreCase("DeleteRules")){
                    		%>
		                    <script>
		                    var f = findFrame(getTopWindow(),'SMAImportExport_TabDeleteRule'); 
		                    f.location.href = f.location.href;
		                    </script>
                   	   <%}
                    	
                    }
                }
                }
            }
            catch (Exception ex)
            {
                ContextUtil.abortTransaction(context);
                throw ex;
            }
        }
    }
    catch (Exception exJPO)
    {
        emxNavErrorObject.addMessage(ErrorUtil.getMessage(exJPO));
    }
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

<script language="Javascript">

    var myFrame = findFrame(getTopWindow(), "_self");
    if ( myFrame )
        myFrame.parent.location.href = myFrame.parent.location.href;

</script>

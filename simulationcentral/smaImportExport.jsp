<%--  smaMassExport.jsp   - jsp launched from export command of simulation activity import/export page"
 * (c) Dassault Systemes, 2007, 2008
 *  
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.ManualExecution"%>
<%@page import="matrix.db.JPO"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.ImportExportServices"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../simulationcentral/smaWebUtil.inc"%>

<%@page import = "java.util.List, java.util.Enumeration"%>
<%@page import = "java.util.HashMap, java.util.Map, matrix.util.*"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "com.dassault_systemes.smaslm.common.util.StringValidator"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script src="../plugins/libs/jquery/2.0.0/jquery.min.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%

    String objectAction = emxGetParameter(request, "objectAction");
	String objId        = emxGetParameter(request, "objectId");
	String timeStamp = emxGetParameter(request, "timeStamp");
    HashMap tableDataMap = (HashMap) tableBean.getTableData(timeStamp);
    HashMap requestMap = (HashMap) tableBean.getRequestMap(tableDataMap);
	String xmlTableTag = (String) requestMap.get("xmlTableTag");
    String parentOID = (String)requestMap.get("parentOID");
    String stepType = (String) requestMap.get("stepType");
    String objIdName    = "dummy2";
    String hostName     = "dummy4";
    String strName      = "dummy5";
	String userName     = "dummy6";
	String userPass     = "dummy7";
    String startCommand = "dummy8";
    String suiteKey = emxGetParameter(request, "suiteKey");
    String jobId = "";
    String objNames = "";
    String _Error =  "";
    String fileExpressions = "";
    StringBuffer contentURL = new StringBuffer(175);
    StringBuilder rowStr = new StringBuilder();
    final String RUNNING = 
        SimulationConstants.JOB_STATUS_RUNNING;
    final String PAUSED = 
        SimulationConstants.JOB_STATUS_PAUSED;
    final String ACTION_IMPORT = 
        SimulationConstants.ACTION_IMPORT;
    final String ACTION_EXPORT = 
        SimulationConstants.ACTION_EXPORT;
    final String ACTION_DELETE = 
        SimulationConstants.ACTION_DELETE;
    final String ACTION_EXPORTPREVIEW = 
        SimulationConstants.ACTION_EXPORTPREVIEW;
    final String ACTION_DELETEPREVIEW = 
        SimulationConstants.ACTION_DELETEPREVIEW;
    final String ACTION_IMPORTPREVIEW = 
        SimulationConstants.ACTION_IMPORTPREVIEW;
    final String NOT_STARTED= SimulationConstants.JOB_STATUS_NOTSTARTED;
    
	if (context != null &&  objId!= null && !objId.equals("") && objectAction!=null )
	{
        String mqlGetNameRev = "print bus " + objId + " select name revision dump |;";
        String[] methodargs2 = {objId};
		String status = (String)JPO.invoke(context, "jpo.simulation.SIMULATIONS",null,"getStatus", methodargs2, String.class);
        if ( (RUNNING.equals(status) || PAUSED.equals(status)) ||
            (NOT_STARTED.equals(status)))
        {
            String lang = context.getSession().getLanguage();
            String errMsg = "";
            if (ACTION_IMPORT.equals(objectAction))
            {
                errMsg = SimulationUtil.getI18NString(context,
                "Error.ImportExport.ImportErr");
            }
            else if (ACTION_EXPORT.equals(objectAction))
            {
                errMsg = SimulationUtil.getI18NString(context,
                "Error.ImportExport.ExportErr");
            }
            else if (ACTION_DELETE.equals(objectAction))
            {
                errMsg = SimulationUtil.getI18NString(context,
                "Error.ImportExport.DeleteErr");
            }
            else if (ACTION_EXPORTPREVIEW.equals(objectAction))
            {
                errMsg = SimulationUtil.getI18NString(context,
                "Error.ImportExport.ExportPreviewErr");
            }
            else if (ACTION_DELETEPREVIEW.equals(objectAction))
            {
                errMsg = SimulationUtil.getI18NString(context,
                "Error.ImportExport.DeletePreviewErr");
            }
            else if (ACTION_IMPORTPREVIEW.equals(objectAction))
            {
                errMsg = SimulationUtil.getI18NString(context,
                "Error.ImportExport.ImportPreviewErr");
            }
            if (errMsg.length() > 0)
            {
    			_Error =  _Error + errMsg;
    			emxNavErrorObject.addMessage(errMsg);  
            }
        }
        else
        {
            String adapterName = (String) requestMap.get("adapterName");
			// xmlTableTag is the stepId
			String[] retArr = parentOID.split("\\~");
			xmlTableTag = retArr[2];

            HashMap paramMap2 = new HashMap();
            Enumeration params = request.getParameterNames();
            while (params.hasMoreElements())
            {
                String name = (String) params.nextElement();
                String value = emxGetParameter(request, name);
                paramMap2.put(name,value);
            }

            Boolean hasRule = false;
            HashMap paramMap = new HashMap();
            paramMap.put("objectId",objId);
            paramMap.put("requestMap",requestMap);
            
            String[] methodargs = JPO.packArgs(paramMap);
            if (objectAction.indexOf("import")>=0)
		        hasRule = (Boolean)JPO.invoke(context, "jpo.simulation.ImportExport",null,"hasImportRules", methodargs, Boolean.class);
		    else if(objectAction.indexOf("export")>=0)
		        hasRule = (Boolean)JPO.invoke(context, "jpo.simulation.ImportExport",null,"hasExportRules", methodargs, Boolean.class);
            else
		        hasRule = (Boolean)JPO.invoke(context, "jpo.simulation.ImportExport",null,"hasDeleteRules", methodargs, Boolean.class);
		    if(!hasRule)
		    {
                String lang = context.getSession().getLanguage();
                String errMsg = "";
                if (ACTION_IMPORT.equals(objectAction))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                    "Error.ImportExport.RuleImportErr");
                }
                else if (ACTION_EXPORT.equals(objectAction))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                    "Error.ImportExport.RuleExportErr");
                }
                else if (ACTION_DELETE.equals(objectAction))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                    "Error.ImportExport.RuleDeleteErr");
                }
                else if (ACTION_EXPORTPREVIEW.equals(objectAction))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                    "Error.ImportExport.RuleExportPreviewErr");
                }
                else if (ACTION_DELETEPREVIEW.equals(objectAction))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                    "Error.ImportExport.RuleDeletePreviewErr");
                }
                else if (ACTION_IMPORTPREVIEW.equals(objectAction))
                {
                    errMsg = SimulationUtil.getI18NString(context,
                    "Error.ImportExport.RuleImportPreviewErr");
                }
                if (errMsg.length() > 0)
                {
                    _Error =  _Error + errMsg;
                    emxNavErrorObject.addMessage(errMsg);  
                }
	        }
	        else
	        {
                String sRowIds[] = 
                    emxGetParameterValues(request, "emxTableRowId");
                int numRows = (sRowIds != null) ?  sRowIds.length: 0;
                
                // create row id string as comma separated list
                for (int ii=0; ii<numRows; ii++ )
                {
                    if (rowStr.length() > 0)
                        rowStr = rowStr.append(",");
                    rowStr = rowStr.append(sRowIds[ii]);
                }
                
                //rowStr = parentOID;
	            if(objectAction.equalsIgnoreCase("exportPreview"))
	            {
                    String headerStr = SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.ExportRule.ExportPreview");
	                contentURL.append("../common/emxTable.jsp")
	                	      .append("?table=SMAExportRule_Preview")
	                	      .append("&objectBased=false")
	                	      .append("&program=jpo.simulation.ImportExport:getExportPreviewTable")
                              .append("&objectId=").append(objId)
                              .append("&emxTableRowId=").append(parentOID)
	                	      .append("&header=").append(headerStr)
                              .append("&suiteKey=").append(suiteKey)
	                	      .append("&HelpMarker=SMAExportRule_ListPreview")
	                	      .append("&xmlTableTag=").append(xmlTableTag)
	                	      .append("&stepType=").append(stepType)
	                	      .append("&adapterName=").append(adapterName);
	            }
                else if(objectAction.equalsIgnoreCase("deletePreview"))
	            {
                    String headerStr = SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.DeleteRule.DeletePreview");
	                contentURL.append("../common/emxTable.jsp")
	                	      .append("?table=SMADeleteRule_Preview")
	                	      .append("&objectBased=false")
	                	      .append("&program=jpo.simulation.ImportExport:getDeletePreviewTable")
	                	      .append("&objectId=").append(objId)
                              .append("&emxTableRowId=").append(rowStr)
	                	      .append("&header=").append(headerStr)
                              .append("&suiteKey=").append(suiteKey)
	                	      .append("&HelpMarker=SMADeleteRule_ListPreview")
	                	      .append("&xmlTableTag=").append(xmlTableTag)
                              .append("&stepType=").append(stepType)
                              .append("&adapterName=").append(adapterName);
	            }
	            else
	            {
			        String tmpMQL = "print bus $1 select $2 $3 dump $4;";
			        objIdName = MqlUtil.mqlCommand(context, tmpMQL,objId,"name","revision","|");
			        objNames = objIdName.replaceFirst("\\|.*", "" );
				
					userName = StringValidator.validate(context.getUser());
					userPass = StringValidator.validate(context.getPassword());
			        
				    hostName = "localhost";
		            if( objectAction.equalsIgnoreCase("import") || 
		                objectAction.equalsIgnoreCase("importPreview") )
		            {
                        try 
                        {
    						fileExpressions = (String)JPO.invoke(
                                context, "jpo.simulation.ImportExport", 
                                null,"getFileExpressions",methodargs , 
                                String.class);
                        }
                        catch (Exception ex)
                        {
                            String eMsg = ErrorUtil.getMessage(ex);
                            emxNavErrorObject.addMessage(eMsg);
                            _Error =  _Error + eMsg;
                        }

		            }
	            }
	        }
		}
    }
	else
	{
        String errMsgInternal = SimulationUtil.getI18NString(context,
            "Error.Internal.NoObject");
        emxNavErrorObject.addMessage(errMsgInternal);
	    _Error =  _Error + errMsgInternal;
    }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%
    if (_Error.length()>0) 
    {
%>
<script language = javascript>
closeWindow();
</script>
<%
		return;  
	}
	else
	{
	
	    if (contentURL.length() > 0)
	    {
%>
	        <script language="javascript">
	            window.resizeTo(850,400);
	            getTopWindow().location.href = "<%=contentURL.toString()%>";
	        </script>
<%
	    }
	    else
	    {
	        String dataXML = "";
	        if (ACTION_EXPORT.equals(objectAction))
	        {
	            HashMap paramMap = new HashMap();
	            paramMap.put("objectId", objId);
	            paramMap.put("xmlTableTag", xmlTableTag);
	            paramMap.put("emxTableRowId", parentOID);
	            paramMap.put("emxTableRowId", parentOID);
	            paramMap.put("getFolders", "true");
	            String jpoArgs[] = JPO.packArgs(paramMap);
	            ManualExecution mExe = new ManualExecution(context,"download",jpoArgs,request);
	            dataXML = mExe.attachFCSTicketAsCData();
	        }
	        else if (ACTION_IMPORT.equals(objectAction))
            {
                //HashMap paramMap = new HashMap();
                //paramMap.put("objectId", objId);
                //paramMap.put("xmlTableTag", xmlTableTag);
                //paramMap.put("emxTableRowId", parentOID);
                //paramMap.put("emxTableRowId", parentOID);
                //paramMap.put("getFolders", "true");
                //String jpoArgs[] = JPO.packArgs(paramMap);
                //ManualExecution mExe = new ManualExecution(context,"upload",jpoArgs,request);
                dataXML = "";//mExe.attachFCSTicketAsCData();
            }
            
	        
	        
            startCommand = startCommand.replace("\\","/");
            URLBuilder contentURL1 = getURLBuilder(request);
		    contentURL1.append("../simulationcentral/smaLocalOperations.jsp?")
		               .append("objectId=").append(objId)
		               .append("&objectAction=").append(objectAction)
		               .append("&dataXML=").append(XSSUtil.encodeForURL(context, dataXML));

%>
			<script language="javascript">
			    showModalDialog("<%=contentURL1.toString()%>", 850, 400, true)
			</script>
<%
        }
    }
%>

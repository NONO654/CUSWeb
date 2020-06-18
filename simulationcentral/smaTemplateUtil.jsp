<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Utility to return xml string to structure browser.  This is called
  after creating new documents
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Map"%>
<%@page import = "matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<html>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<body>
<%
    String objectAction = emxGetParameter(request,
        "objectAction");
    if (objectAction == null)
    {
        String timeStamp = emxGetParameter(request, "timeStamp");
        HashMap requestMap = (HashMap) tableBean
            .getRequestMap(timeStamp);

        // Get row ID of parent (so we can add to it)
        objectAction = (String) requestMap.get("objectAction");
    }

    String objectId = emxGetParameter(request, "objectId");
    String jpo = emxGetParameter(request, "postProcessJPO");

    String action = "";
    String message = "";

    if ("removeOutputFiles".equalsIgnoreCase(objectAction)
        || "setUpToDate".equalsIgnoreCase(objectAction)
        || "purgeRevisions".equalsIgnoreCase(objectAction))
    {
        try
        {

            StringList SL = FrameworkUtil.split(jpo, ":");

            String jpoProgram = "";
            String jpoFunction = "";

            // Badly formed postProcessJPO URL parameter
            if (SL.size() != 2)
            {
                action = "error";
                message = "Internal Error: no colon found in "
                    + jpo;
            }

            // Call JPO passed in
            else
            {
                // Get JPO 
                jpoProgram = (String) SL.get(0);
                jpoFunction = (String) SL.get(1);

                // Pass JPO the objectId of the entity passed in
                String[] args = new String[] { objectId };

                // Do the deed
               	FrameworkUtil.validateMethodBeforeInvoke(context, jpoProgram, jpoFunction, "POSTPROCESS");
                Map returnMap = (Map) JPO.invoke(context,
                    jpoProgram, null, jpoFunction, args,
                    Map.class);

                // Check returnMap for errors
                if (returnMap != null)
                {
                    String Action = (String) returnMap
                        .get("Action");
                    message = (String) returnMap.get("Message");
                }
            }
        }
        catch (Exception ex)
        {
            message = ErrorUtil.getMessage(ex);
        }

        if (message != null && message.length() > 0)
        {
            emxNavErrorObject.addMessage(message);
        }
    }

    else if ("disconnect".equalsIgnoreCase(objectAction))
    {
        try
        {
            String rowIdsStr = "";

            // get selected sim/SAs for disconnect command
            String sRowIds[] = emxGetParameterValues(request,
                "emxTableRowId");
            int numRows = (sRowIds != null) ? sRowIds.length
                : 0;
            StringBuilder rowStr = new StringBuilder();

            // create row id string as comma separated list
            for (int ii = 0; ii < numRows; ii++)
            {
                if (rowStr.length() > 0)
                    rowStr = rowStr.append(",");
                rowStr = rowStr.append(sRowIds[ii]);
            }
            rowIdsStr = rowStr.toString();
            StringList SL = FrameworkUtil.split(jpo, ":");

            String jpoProgram = "";
            String jpoFunction = "";

            // Badly formed postProcessJPO URL parameter
            if (SL.size() != 2)
            {
                action = "error";
                message = "Internal Error: no colon found in "
                    + jpo;
            }

            // Call JPO passed in
            else
            {
                // Get JPO 
                jpoProgram = (String) SL.get(0);
                jpoFunction = (String) SL.get(1);

                // Pass JPO the objectId of the entity passed in
                String[] args = new String[] {objectId,rowIdsStr};

                // Do the deed
               	FrameworkUtil.validateMethodBeforeInvoke(context, jpoProgram, jpoFunction, "POSTPROCESS");
                Map returnMap = (Map) JPO.invoke(context,
                    jpoProgram, null, jpoFunction, args,
                    Map.class);

                // Check returnMap for errors
                if (returnMap != null)
                {
                    String Action = (String) returnMap
                        .get("Action");
                    message = (String) returnMap.get("Message");
                }
            }
        }
        catch (Exception ex)
        {
            message = ErrorUtil.getMessage(ex);
        }

        if (message != null && message.length() > 0)
        {
            emxNavErrorObject.addMessage(message);
        }
    }
   
       else if ("viewInstructions".equalsIgnoreCase(objectAction))
    {
    	// Pass JPO the objectId of the entity passed in
           String[] args = new String[] { objectId };
   StringBuffer documentURL = new StringBuffer(126);

           // Do the deed
           Map documentMap = (Map) JPO.invoke(context,
               "jpo.simulation.Template", null,
               "getTemplateDocs", args, Map.class);

    int numDocs = ((Integer) documentMap.get("numberOfDocuments")).intValue();

    if (numDocs == 0)
		{
               String msg = SimulationUtil
                   .getI18NString(context,
                       "smaSimulationCentral.Template.Message.NoInstructons");
               String lang = request.getHeader("Accept-Language");
              
               String close = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(),"emxFramework.Common.Close");
   %>
   <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
                   <script>
                   addStyleSheet("emxUIDefault");
                   addStyleSheet("emxUIProperties");
                   addStyleSheet("emxUIMenu");
                   function closeWindow()
                   {
                       getTopWindow().closeWindow();
                   }
               </script>

   <br><br><br><br>
   <table class="label" border="0" width="99%" cellpadding="5" cellspacing="2">
       <tr>
           <th><%=msg%></th>
       </tr>
       <tr><th>
   <input type="button" value="<%=close %>" onclick="javascript:closeWindow(); return false"/>
       </th></tr>
   </table>
   <%
   		}
   	
   	else 
		{	
   		if(numDocs == 1)
			{
		MapList documentInfo = 	(MapList)(documentMap.get("documentList"));
		Map fileMap = (Map)documentInfo.get(0);
     
           String instructionsID = (String) fileMap
               .get(DomainObject.SELECT_ID);

           if (instructionsID == null
               || instructionsID.length() == 0)
				{
               String msg = SimulationUtil
                   .getI18NString(context,
                       "smaSimulationCentral.Template.Message.NoInstructons");
               String lang = request.getHeader("Accept-Language");
              
               String close = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(),"emxFramework.Common.Close");
   %>
   <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
               <script>
                   addStyleSheet("emxUIDefault");
                   addStyleSheet("emxUIProperties");
                   addStyleSheet("emxUIMenu");
                   function closeWindow()
                   {
                       getTopWindow().closeWindow();
                   }
               </script>

   <br><br><br><br>
   <table class="label" border="0" width="99%" cellpadding="5" cellspacing="2">
       <tr>
           <th><%=msg%></th>
       </tr>
       <tr><th>
   <input type="button" value="<%=close %>" onclick="javascript:closeWindow(); return false"/>
       </th></tr>
   </table>
   <%
				}

           else
				{
           	int numFiles = ((Integer) fileMap.get("numberFiles"))
                   .intValue();
               
               // If only 1 file is found, view it immediately
               // otherwise download all files
               

     
               // If just 1 file, open it
               if (numFiles == 1)
					{
                   /* fix for IR-214980V6R2014x:
                   'appProcessPage' parameter is handle of post checkout-process (mostly for refresh)
                   
                   but 'appProcessPage' parameter is added here with no value, 
                   to avoid below mentioned block
                   
                   emxCommonDocumentCheckout.jsp: line 475-477 (Enovia build of 1341)
                   if (appProcessPage != "undefined" && appProcessPage.length > 0) {
                       setTimeout("closeWindow()", 500);
                   }
                   */
                   documentURL
                       .append(
                           "../components/emxCommonDocumentPreCheckout.jsp")
                       .append("?action=view")
                       .append("&objectId=")
                       .append(instructionsID+"&isAppPreProcess=true&appProcessPage=");
                   
               
					}

               
               else
					{
documentURL.append("../common/emxTable.jsp")
                           .append("?program=jpo.simulation.Template:getDocumentListBase")
                           .append("&table=SMA_TemplateDocuments")
                           .append("&popup=true")
                           .append("&objectId=")
                           .append(objectId);
            	  
					}
               

   				
				}
   		
			}
   	
   	else
			{
   	documentURL.append("../common/emxTable.jsp")
                           .append("?program=jpo.simulation.Template:getDocumentListBase")
                           .append("&table=SMA_TemplateDocuments")
                           .append("&popup=true")
                           .append("&objectId=")
                           .append(objectId);
   	
			}
        	
   		%>
   	    <script>
   	 getTopWindow().showModalDialog("<%=documentURL.toString()%>",700,600);
   	    </script>
   		<%

		}
       
    }
    

    // User wants to pick a different document for instructions
    else if ("assignInstructions"
        .equalsIgnoreCase(objectAction))
    {
    	String[] childRowIds = request.getParameterValues("emxTableRowId");

        HashMap programMap = new HashMap();
        HashMap paramMap = new HashMap();

        paramMap.put("objectId", objectId);
        paramMap.put("Assign Docs", childRowIds);

        programMap.put("paramMap", paramMap);

        String[] args = JPO.packArgs(programMap);

        // Do the deed
        Boolean assignedInstructions = (Boolean) JPO.invoke(
            context, "jpo.simulation.Template", null,
            "updateInstructions", args, Boolean.class);

        if (!assignedInstructions)
        {
            String msg = SimulationUtil
                .getI18NString(context,
                    "smaSimulationCentral.Content.ErrMsg.cannotaddduplicate1");
            emxNavErrorObject.addMessage(msg);
        }
        else
        {
%>
            <script>
            if ( getTopWindow().getWindowOpener() )
                getTopWindow().closeWindow();
            </script>
<%
    	}
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%
    if ("disconnect".equalsIgnoreCase(objectAction) ||  "setUpToDate".equalsIgnoreCase(objectAction))
    {
%>
<script language="javascript">
    getTopWindow().refreshTablePage()
</script>
<%
    }
%>
</body>
</html>


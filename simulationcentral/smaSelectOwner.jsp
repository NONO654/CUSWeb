<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
   Initiate a Person search for selecting a new owner.
   
   This jsp simply passes the objectId on through the search forms
   so that it is available in the final processing jsp.
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%!
  private static final String SLM_FRAMEWORK_BUNDLE = "smaSimulationCentralStringResource";
  private static final String NO_OBJECT_ERROR = "smaSimulationCentral.Error.NoObjectSelected";
  private static final String NO_PERM_ERROR = "smaSimulationCentral.Error.SetOwner.NoPerm";
%>


<!--  <html> and <head> were added by something above here.   -->
</head>
<body>

<%
    String strObjId = emxGetParameter(request, "objectId");
	if(strObjId==null || "".equals(strObjId))
		strObjId = (String)session.getAttribute("CHANGEOWNERIDS");
		
    String sRowIds_temp[] = request.getParameterValues("emxTableRowId");
   
  //WXB-IR170400-to get the ObjectIds -START
    if(sRowIds_temp==null)
    {
    	sRowIds_temp = new String[1];
   		sRowIds_temp[0]=strObjId;
    }
  
    	String sRowIds[] = sRowIds_temp[0].split("\\*");
  //WXB-IR170400-to get the ObjectIds -END
  
    if ( sRowIds != null && sRowIds.length > 0)
    {
        // If called from emxTable, the row ids might be
        //   <connection id>|<selected object id>
        // If called from an emxIndentedTable, the row ids are:
        //   <parent object id>|<selected object id>|<conection id>|<indented table ordering tag>
        // In either case, pull out the <selected object id>.
        if (sRowIds[0] != null  &&  sRowIds[0].indexOf('|') > -1)
        {
            for (int ix=0; ix<sRowIds.length; ix++)
            {
                String objectId = sRowIds[ix];
                int pos1 = objectId.indexOf('|');
                pos1 += 1;
                int pos2 = objectId.indexOf('|', pos1);
                if (pos2 == -1)
                {
                    pos2 = objectId.length();
                }
                sRowIds[ix] = objectId.substring(pos1, pos2);
            }
        }
    }
    else if ( strObjId != null )
    {
        // handle the possibility of multiple objects
        sRowIds = strObjId.split("\\*");
    }
    else
    {
        // your screwed
    }

    String objectId = null;

    if (sRowIds == null || sRowIds.length == 0)
    {
        i18nNow i18nInstance = new i18nNow();
        String strLang = request.getHeader("Accept-Language");
        String strMsg = i18nInstance
            .GetString(SLM_FRAMEWORK_BUNDLE, strLang, NO_OBJECT_ERROR);
        emxNavErrorObject.addMessage(strMsg);
    }
    else
    {
        // if we already have a "*" separated string just use it.
        if (strObjId != null && strObjId.indexOf('*') > -1)
            objectId = strObjId;
        else 
        {
            // need to create a "*" separated string of objects
            StringBuilder objsToProcess = new StringBuilder();
            for (int iii = 0; iii < sRowIds.length; iii++)
            {
                String selObjectId = sRowIds[iii];
                if ( iii > 0)
                    objsToProcess.append("*");
                objsToProcess.append(selObjectId);
            }
            objectId = objsToProcess.toString();
        }
    }

    if (objectId != null)
    {
      // Verify that the user has permission.
        String[] arguments = {objectId};
        Boolean permFlag = (Boolean) 
            JPO.invoke(context, 
                "jpo.simulation.SimulationUtil", null,
                "checkSetOwner", arguments, Boolean.class);
        if (permFlag.booleanValue() == false)
        {
            i18nNow i18nInstance = new i18nNow();
            String strLang = request.getHeader("Accept-Language");
            String strMsg = i18nInstance
                .GetString(SLM_FRAMEWORK_BUNDLE, strLang, NO_PERM_ERROR);
            emxNavErrorObject.addMessage(strMsg);

            objectId = null;
        }
    }
  //WXB-IR170400-START-To pass the Objectids * separated 
    objectId = "";
    for(int i=0;i<sRowIds.length;i++)
    {
    	objectId+=sRowIds[i];
    	if(i<sRowIds.length-1)
    		objectId+="*";
    }
  //WXB-IR170400-END 
    if (objectId != null)
    {
        String searchUrl = emxGetParameter(request, "searchUrl");
%>
        <form name="application"  action="<%=searchUrl%>" method="post">
          <input type="hidden" name="objectId" value="<%=objectId%>">
         
<%
    
        // Loop through the request elements and add them to the URL
        //
        Enumeration enumParam = request.getParameterNames();
        while (enumParam.hasMoreElements())
        {
            String name = (String) enumParam.nextElement();
            if (name.equals("objectId"))
                continue;
            String value = emxGetParameter(request, name);
            if (name.equals("timeStamp"))
            {
                name="callerTimeStamp";
            }
%>
            <input type="hidden" name="<%=name%>" value="<%=value%>">
<%
        }
%>
    
        </form>
        <script>
            document.application.submit();
        </script>
<%
    }
    else
    {
        // Display error message.
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
        // the above include will cause the display of an alert 
        // message. The following will kill the popup window once
        // the alert message is dismissed.
        <script>
            getTopWindow().closeWindow();
        </script>
<%
    }
%>

</body>
</html>

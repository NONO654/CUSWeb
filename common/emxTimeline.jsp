<%-- emxTimeline.jsp
        
        Copyright (c) 1992-2018 Dassault Systemes.
        All Rights Reserved.
        This program contains proprietary and trade secret information of MatrixOne, 
        Inc.
        Copyright notice is precautionary only and does not evidence any actual or 
        intended publication of such program.

        static const char RCSID[] = $Id: emxTimeline.jsp.rca 1.6 Wed Oct 22 15:48:34 2008 przemek Experimental przemek $
 --%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<html>
<head></head>
<body>
<%

String timestamp = Long.toString(System.currentTimeMillis());
String suiteKey = emxGetParameter(request, "suiteKey");
String program = emxGetParameter(request, "program");
String filterCommand = emxGetParameter(request, "filterCommand");
String header = emxGetParameter(request, "header");
//Begin of Add by Vibhu,Infosys for Bug 303031 on 2nd May,05
double dblTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
//End of Add by Vibhu,Infosys for Bug 303031 on 2nd May,05
try{
    if(program == null){
        throw new Exception("The \"program\" parameter was not found in the URL.");
    }
    //get the Program and the method name
    int index = program.indexOf(':');
    String progName = program.substring(0, index);
    String methName = program.substring(index+1, program.length());

    //Get the filter attribute setting from the filter command
    Map filterCommandMap = (Map) UIMenu.getCommand(context, filterCommand);
    Map settings = (Map) filterCommandMap.get("settings");
    String attributeFilter = (String) settings.get(UITimeline.SETTING_ATTRIBUTE_FILTER_LIST);
    
    //Get the tablerowids from the request and obtain the ids of the selected objects
    //in the list page
    String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId");
    String[] objectIds = null;
    if(tableRowIds!= null){ //added a check to avoid null pointer exception
        objectIds = new String[tableRowIds.length];
	    for(int i=0;i<tableRowIds.length;i++){
	        int iPosition = tableRowIds[i].indexOf("|");
	        if(iPosition == -1){
	            objectIds[i] = tableRowIds[i];
	        }else{
	            objectIds[i] = tableRowIds[i].substring(iPosition + 1, tableRowIds[i].length());
	        }
	    }
    }

    //Call the JPO method
    String[] initArgs = new String[0];
    HashMap methodMap = new HashMap(3);
    methodMap.put("objectIds", objectIds);
    methodMap.put("suiteKey", suiteKey);
    methodMap.put(UITimeline.SETTING_ATTRIBUTE_FILTER_LIST, attributeFilter);
	//Begin of Add by Vibhu,Infosys for Bug 303031 on 2nd May,05
	methodMap.put("ClientOffset",Double.toString(dblTZOffset));
	//End of Add by Vibhu,Infosys for Bug 303031 on 2nd May,05
    //Added by Vibhu,Infosys for Bug 304312 on 5/18/2005
	methodMap.put("localeObj",context.getLocale());
    String[] methodArgs = JPO.packArgs(methodMap);
    FrameworkUtil.validateMethodBeforeInvoke(context, progName, methName, "Program");
    MapList roadMapStruct =
      (MapList) JPO.invoke(context,
                 progName, initArgs,
                 methName, methodArgs, MapList.class);

    session.setAttribute(timestamp, roadMapStruct);

    StringBuffer url = new StringBuffer("emxTimelineDisplay.jsp?timestamp=");
    url.append(timestamp);
    url.append("&suiteKey=");
    url.append(suiteKey);
    url.append("&filterCommand=");
    url.append(filterCommand);
    url.append("&header=");
    url.append(header);

    response.sendRedirect(url.toString());
}catch (Exception ex) {
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());
}
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

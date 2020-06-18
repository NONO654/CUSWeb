<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.XmlTableUtil"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
    String timeStamp = (String) emxGetParameter(request,"timeStamp");
    HashMap tableData = (HashMap) tableBean.getTableData(timeStamp);
    
    Map requestMap = (Map)tableData.get("RequestMap");
    MapList editObjectMapList = (MapList)tableData.get("EditObjectList");
    
    String actId = (String) emxGetParameter(request, "objectId"),
        stepId = (String) emxGetParameter(request, "selectedStep");
    
    int i = 0;
    if(editObjectMapList!=null){
    for (Iterator<Map> iterator = editObjectMapList.iterator(); iterator
        .hasNext();i++)
    {
        Map editObjectMap = iterator.next();
        String optionName = (String) editObjectMap.get("id"),
            optionValue = (String) emxGetParameter(request, "Argument Value"+(100+i));
        
        XmlTableUtil.saveArgumentValue(context, actId, stepId, optionName, optionValue);
    }    
    }else{
    %>
        <script>
        getTopWindow().closeWindow();
        </script>
<% 
    }
%>
<script>
var topFrm = getTopWindow().opener.getTopWindow();
frame = findFrame(topFrm,"SMAOSCommand_ConnectorOptions");
frame.location.href = frame.location.href ;
getTopWindow().closeWindow();
</script>

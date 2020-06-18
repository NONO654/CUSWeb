<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%-- 
<%@include file=  "../components/emxSearchInclude.inc"%>
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import = "matrix.db.JPO"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>


<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
String timeStamp = emxGetParameter(request, "timeStamp");
String tableRowId[] = request.getParameterValues("emxTableRowId");

Map tableData = (Map)tableBean.getTableData(timeStamp);
Map tableRequestMap = (Map)tableData.get("RequestMap");

String strJPO = (String)tableRequestMap.get("postProcessJPO");
String strJPOName = null;
String strMethodName = null;
if (strJPO != null)
{
  strJPOName = strJPO.substring(0, strJPO.indexOf(":"));
  strMethodName = strJPO.substring(strJPO.indexOf(":") + 1, strJPO.length());
}

try 
{ 
  if ( (strJPOName != null) && !(strJPOName.equals("")) 
        && (strMethodName != null) && !(strMethodName.equals("")) )
  {
    Map inputMap = new HashMap();
    final String OBJECT_IDS = "objectIDs";
    inputMap.put(OBJECT_IDS, tableRowId);

    inputMap.put("requestMap", UINavigatorUtil.getRequestParameterMap(pageContext));
    inputMap.put("tableData", tableData);
    inputMap.put("selectedStep", (String)session.getAttribute("selectedStep"));

    JPO.invoke(context, strJPOName, new String[0], strMethodName, JPO.packArgs(inputMap));
  }
} 
catch (Exception exJPO)
{
   throw (new FrameworkException(exJPO.toString()));
}

%>


<script language="Javascript">
<%--
--%>
channel = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"SMAOSCommand_ConnectorOptions");
channel.location.href=channel.location.href;
getTopWindow().closeWindow();
</script>


<%--
$Id: emxBTCreateNavigationPage.jsp
--%>

<html>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%

String errorMessage = "";

String SelectedId="";
//System.out.println("Inside JSP");
try 
{
	SelectedId = emxGetParameter(request, "selectedID");
} catch (Exception ex) {
errorMessage = ex.toString().trim();
}
String contentUrl= "../common/emxIndentedTable.jsp?SelectedId="+SelectedId+"&program=emxBTAdvSearch:getSelectedObjectsFromAdvSearch&relationship=relationship_VPLMrel@DELLmiProductionPlugInstanceCusto&direction=from&table=DELBT_AdvSearchResults&suiteKey=BlendingTable&header=emxBlendingTableCentral.Header.SelectedObjects&expandLevelFilter=false&showClipboard=false&findMxLink=false&rowGrouping=false&objectCompare=false&rowGrouping=false&showPageURLIcon=fals";
%>


<frameset cols="25%,*" framespacing="0" frameborder="yes">
<frameset rows="50%,*" framespacing="0" frameborder="yes">
	<frame name="topLeftFrame" id="topLeftFrame" src=<%=contentUrl%> marginwidth="0" marginheight="0"/>
	<frame name="downLeftFrame" id="downLeftFrame" src="../common/emxBlank.jsp" marginwidth="0" marginheight="0"/>
</frameset>
<frame name="rightFrame" id="rightFrame" src="../common/emxBlank.jsp" marginwidth="0" marginheight="0" />
</frameset>

<body class="content" >
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

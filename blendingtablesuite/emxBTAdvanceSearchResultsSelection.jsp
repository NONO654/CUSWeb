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
    String timeStamp = emxGetParameter(request, "timeStamp");
    String[] selectedIds = emxGetParameterValues(request, "emxTableRowId");
    //System.out.println("Selected Ids : " + selectedIds);   
    if(selectedIds!=null&&selectedIds.length>0)
    { 
		for(int i=0; i<selectedIds.length; i++)
		{
			String tmpStr = selectedIds[i];
			
			String delims = "[|]+";
			String[] Nametokens = tmpStr.split(delims);
			if( Nametokens.length > 0 )
				SelectedId += Nametokens[1] + "|";
		}
    }
    request.setAttribute("selectedIds", selectedIds);
} catch (Exception ex) {
errorMessage = ex.toString().trim();
}
String contentUrl="\"../blendingtablesuite/emxBTCreateNavigationPage.jsp?selectedID="+SelectedId+"\"";
%>

<script language="javascript">
top.opener.frames['content'].location =<%=contentUrl%>;
top.close(); 
</script>
</html>

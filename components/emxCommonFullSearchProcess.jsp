<%-- 
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
--%>


<%@page import="com.matrixone.apps.common.Issue"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import = "com.matrixone.apps.domain.util.*" %> 
<%@ page import = "com.matrixone.apps.domain.*" %> 
<%@ page import = "com.matrixone.apps.common.Task" %> 
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil" %> 
<script language="JavaScript" src="../common/scripts/emxUIConstants.js"  type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<html>
<body>
<%


String[] emxTableRowId =emxGetParameterValues(request,"emxTableRowId");
String[] FTSrowid = new String  [emxTableRowId.length];
String objectId =emxGetParameter(request,"objectId");
StringBuilder stbselectedIds= new StringBuilder();
int  k =0;
for (String i : emxTableRowId)
{
	
	StringTokenizer strTokenizer = new StringTokenizer(emxTableRowId[k] , "|");
     FTSrowid[k]=(strTokenizer.nextToken()) ;
     stbselectedIds.append(FTSrowid[k]);
      if(strTokenizer.hasMoreTokens())
      {
    	  stbselectedIds.append(",");
      }
     k++;
}
if (emxGetParameter(request, "mode").equals("IssuechangeOwner"))
{
String IssueID       = emxGetParameter(request, "IssueID");

StringTokenizer strToken = new StringTokenizer(IssueID,"!!");
String Issue[] = new String[strToken.countTokens()];
int i =0;
while(strToken.hasMoreTokens())
{

	Issue[i]= strToken.nextToken();
	i++;
}
HashMap paramMap = new HashMap();
HashMap requestMap = new HashMap();
HashMap requestValuesMap = new HashMap();
requestValuesMap.put("emxTableRowId",Issue);
requestMap.put("emxTableRowId",FTSrowid);
paramMap.put("reqMap",requestMap);
paramMap.put("reqTableMap",requestValuesMap);
try{
JPO.invoke(context, "emxCommonIssue", null, "changeOwner", JPO.packArgs(paramMap), null);
}catch(Exception e)
	{
		session.putValue("error.message", e.toString());
	}
%>
</body>
</html>
<script language="javascript" type="text/javaScript">
if(getTopWindow().getWindowOpener().refreshSBTable){
getTopWindow().getWindowOpener().refreshSBTable();
}else{
	var frame = findFrame(getTopWindow(), "frameTable");
	if(frame){
		frame.refreshSBTable();
	}else{
		frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "frameTable");
		if(frame){
			frame.refreshSBTable();
		}else{
			frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
			frame.refreshSBTable();
		}	
	}
}
getTopWindow().closeWindow();
</script>
<%
}
if(!FrameworkUtil.isOnPremise(context) && emxGetParameter(request, "mode").equals("addPeopleToCompany")){
	session.setAttribute("selectedPeople",FTSrowid);
%> 
	<jsp:forward page="emxComponentsAddExistingPersonProcess.jsp" >
		<jsp:param name="objectId" value="<%=objectId%>"/>
	</jsp:forward>
	<% 
}
String strURL ="";
if(emxGetParameter(request, "mode").equals("addPeopleToCompany") || emxGetParameter(request, "mode").equals("collberate") )
		{
	if(emxGetParameter(request, "mode").equals("addPeopleToCompany") )
			{
	     session.setAttribute("selectedPeople",FTSrowid);
	     strURL = "../components/emxComponentsAddExistingPersonRolesDialogFS.jsp?objectId="+XSSUtil.encodeForURL(context,objectId);
			}
	
	if(emxGetParameter(request, "mode").equals("collberate") )
	{
       strURL = "../components/emxComponentsSpecifyShareTypesFS.jsp?selectedIds="+XSSUtil.encodeForURL(context,stbselectedIds.toString())+"&objectId="+XSSUtil.encodeForURL(context,objectId);

	}
		
%>
<script language="javascript" type="text/javaScript">
//OPENEROK
if(getTopWindow().opener){
//XSSOK
getTopWindow().location.href = "<%=strURL%>";
}else{
	getTopWindow().showModalDialog("<%=strURL%>");
}
</script>
<%
		}
%>

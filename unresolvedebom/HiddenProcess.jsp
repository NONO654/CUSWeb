 <%-- HiddenProcess.jsp  -  Hidden Page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%-- <jsp:useBean id="unresolvedEBOM" class="com.matrixone.apps.unresolvedebom.UnresolvedEBOM" scope="session"/> --%>
<%
  String objectId = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"objectId"));
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String selPartRelId = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"selPartRelId"));
  String selPartObjectId = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"selPartObjectId"));
  String selPartParentOId = emxGetParameter(request,"selPartParentOId");
  String calledMethod      = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "calledMethod"));
  String replace = emxGetParameter(request, "replace");
  String isWipMode = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "isWipMode"));
  String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
  


  String strPartId = "";
  String relId = selPartRelId;
  int count = selectedItems.length;
  String totalCount = String.valueOf(count);
  String selectedId = "";
  String[] selPartIds = new String[count];
	for (int i=0; i < selectedItems.length ;i++){
	    selectedId = selectedItems[i];
	    //if this is coming from the Full Text Search, have to parse out |objectId|relId|
	    StringTokenizer strTokens = new StringTokenizer(selectedItems[i],"|");
	    if ( strTokens.hasMoreTokens())
	    {
	        selectedId = strTokens.nextToken();
	        selPartIds[i] = selectedId.trim();
	    }
	}
 String strSelectedPartId  = selPartIds[0];

%>
<script language="javascript" type="text/javaScript">//<![CDATA[
//XSSOK                                                                
var calledMethod = "<%=calledMethod%>";

//Added By Chetan for XBOM -Starts
if(calledMethod == "copyFrom")
{
	//XSSOK
	<%=calledMethod%>('<%=objectId%>','<%=selPartObjectId%>','<%=selectedId%>');
}
function copyFrom(objectId,selPartObjectId,selectedId)
{
	//XSSOK
    var sURL = "../unresolvedebom/IntermediateProcess.jsp?objectId=<%=strSelectedPartId%>&From=CopyFrom&isWipMode=<%=isWipMode%>&PUEUEBOMChangeViewFilter=Official";
    if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN || !getTopWindow().getWindowOpener()){
    	showModalDialog(sURL);
    }
    else{
    	getTopWindow().location.href=sURL;
    }
	
}
</script>

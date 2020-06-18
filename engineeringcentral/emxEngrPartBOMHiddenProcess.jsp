<%--  emxEngrPartBOMHiddenProcess.jsp  -  Hidden Page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIModal.js "></script>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
  String objectId = emxGetParameter(request,"objectId");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String selPartRelId = emxGetParameter(request,"selPartRelId");
  String relType = emxGetParameter(request,"relType");
  String selPartObjectId = emxGetParameter(request,"selPartObjectId");
  String selPartParentOId = emxGetParameter(request,"selPartParentOId");
  String tablemode = emxGetParameter(request,"tablemode");
  String calledMethod      = emxGetParameter(request, "calledMethod");
  String replace = emxGetParameter(request, "replace");
  String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
  String frameName = emxGetParameter(request, "frameName");
  String BOMViewMode = emxGetParameter(request, "BOMViewMode");
  String replaceRowQuantity = emxGetParameter(request,"replaceRowQuantity");
  String WorkUnderOID = emxGetParameter(request,"WorkUnderOID");
  int count = selectedItems.length;
  String totalCount = String.valueOf(count);
  String selectedId = "";
  String[] selPartIds = new String[count];
  String hideWithBOMSelection = "false";
        for (int i=0; i < selectedItems.length ;i++)
        {
            selectedId = selectedItems[i];
            //if this is coming from the Full Text Search, have to parse out |objectId|relId|
            StringTokenizer strTokens = new StringTokenizer(selectedItems[i],"|");
            if ( strTokens.hasMoreTokens())
            {
                selectedId = strTokens.nextToken();
                selPartIds[i] = selectedId.trim();
            }
        }
        if(UIUtil.isNotNullAndNotEmpty(tablemode) && tablemode.equals("view") && calledMethod.equals("replaceExisting")){
        	for (int i=0; i < selPartIds.length ;i++)
            {
        		String sState = DomainObject.newInstance(context,selPartIds[i]).getInfo(context, DomainConstants.SELECT_CURRENT);
        		if(sState != null && !sState.equalsIgnoreCase(DomainConstants.STATE_PART_PRELIMINARY)){
        			hideWithBOMSelection = "true";
        			break;
        		}
            }
        }
        if(calledMethod.equals("replaceExisting"))
        {
            session.setAttribute("selPartIds",selPartIds);
        }
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" type="text/javaScript">//<![CDATA[
//XSSOK
var calledMethod = "<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>";
var frameName = parent.name;
var tablemode = "<%=XSSUtil.encodeForJavaScript(context,tablemode)%>";
var BOMViewMode = "<%=XSSUtil.encodeForJavaScript(context,BOMViewMode)%>";
var hideWithBOMSelection = "<%=XSSUtil.encodeForJavaScript(context,hideWithBOMSelection)%>";
var replaceRowQuantity = "<%=XSSUtil.encodeForJavaScript(context,replaceRowQuantity)%>";
var WorkUnderOID = "<%=XSSUtil.encodeForJavaScript(context,WorkUnderOID)%>";
if(calledMethod == "replaceExisting")
{
//XSSOK
<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>('<%=XSSUtil.encodeForJavaScript(context,objectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartRelId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartObjectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartParentOId)%>','<%=XSSUtil.encodeForJavaScript(context,replace)%>','<%=totalCount%>','<%=XSSUtil.encodeForJavaScript(context,relType)%>','<%=XSSUtil.encodeForJavaScript(context,frameName)%>');
}
else if(calledMethod == "copyTo")
{
	//XSSOK
<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>('<%=XSSUtil.encodeForJavaScript(context,objectId)%>','<%=XSSUtil.encodeForJavaScript(context,selectedId)%>');
}
else if(calledMethod == "copyFrom")
{
	//XSSOK
<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>('<%=XSSUtil.encodeForJavaScript(context,objectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartRelId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartObjectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartParentOId)%>','<%=XSSUtil.encodeForJavaScript(context,selectedId)%>','<%=XSSUtil.encodeForJavaScript(context,frameName)%>');
}
else if(calledMethod == "AVLCopyFrom" )
{
	//XSSOK
<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>('<%=XSSUtil.encodeForJavaScript(context,objectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartRelId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartObjectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartParentOId)%>','<%=XSSUtil.encodeForJavaScript(context,selectedId)%>','<%=XSSUtil.encodeForJavaScript(context,frameName)%>');
}
function replaceExisting(objectId,selPartRelId,selPartObjectId,selPartParentOId,replace,totalCount,relType,frameName)
{
    var url = "../engineeringcentral/emxEngrBOMReplaceDailogFS.jsp?objectId="+objectId+"&selPartRelId="+selPartRelId+"&selPartObjectId="+selPartObjectId+"&selPartParentOId="+selPartParentOId+"&replaceWithExisting="+replace+"&totalCount="+totalCount+"&relType="+relType+"&frameName="+frameName+"&tablemode="+tablemode+"&hideWithBOMSelection="+hideWithBOMSelection+"&BOMViewMode="+BOMViewMode+"&replaceRowQuantity="+replaceRowQuantity+"&WorkUnderOID="+WorkUnderOID;

	if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN)
	{
		showModalDialog(url);	
	}
    else {getTopWindow().location.href=url;}	
    //getTopWindow().location.href=url;
}

function copyTo(objectId,selectedId)
{
    var url = "../engineeringcentral/emxpartCopyComponentsIntermediateProcess.jsp?objectId="+objectId+"&checkBox="+selectedId+"&frameName="+frameName;
if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN)
	{
		showModalDialog(url);	
	}
    else {getTopWindow().location.href=url;}

}

function copyFrom(objectId,selPartRelId,selPartObjectId,selPartParentOId,selectedId,frameName)
{
    var url = "../engineeringcentral/emxEngrBOMCopyFromFS.jsp?objectId="+objectId+"&selPartRelId="+selPartRelId+"&selPartObjectId="+selPartObjectId+"&selPartParentOId="+selPartParentOId+"&checkBox="+selectedId+"&frameName="+frameName;

	if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN)
	{
		showModalDialog(url);	
	}
    else {getTopWindow().location.href=url;}
}
function AVLCopyFrom(objectId,selPartRelId,selPartObjectId,selPartParentOId,selectedId,frameName)
{
	var url = "../engineeringcentral/emxEngrBOMCopyFromFS.jsp?objectId="+objectId+"&selPartRelId="+selPartRelId+"&selPartObjectId="+selPartObjectId+"&selPartParentOId="+selPartParentOId+"&checkBox="+selectedId+"&AVLReport=TRUE"+"&frameName="+frameName;
  
	if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN)
	{
		showModalDialog(url);	
	}
    else {getTopWindow().location.href=url;}
}
</script>

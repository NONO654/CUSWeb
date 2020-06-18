<!-- emxMassPromoteDemote.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
-->

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxToolbarInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUITableUtil.js"></script>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<%!
public StringList getObjectIds(Context context,String [] memberIds) throws Exception
{
    StringList strList = new StringList();
    StringList objectIdList = new StringList();
    String oid = "";    
    if(memberIds != null && memberIds.length > 0) 
    {   
       for(int i = 0; i < memberIds.length ; i++) 
       {                     
          if(memberIds[i].indexOf("|") != -1)
          {
             strList = FrameworkUtil.split(memberIds[i], "|");
             if (strList.size() == 3)
             {
                 oid = (String)strList.get(0);
             }else
             {
                 oid = (String)strList.get(1);
             }         
          }else
          {
             oid = memberIds[i];
          }
           objectIdList.add(oid);                  
        }      
     }
    
    return objectIdList;
}
%>

<%     
	String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	String uiType = emxGetParameter(request,"uiType");
	String cmd = emxGetParameter(request,"cmd");
	StringList strlFirstOids = getObjectIds(context,arrTableRowIds);
	java.util.Set set = new java.util.HashSet(strlFirstOids);	
	String idsSelected  = "";
	java.util.Iterator itr = set.iterator();
	while(itr.hasNext())
	{
	    String id = (String)itr.next();
	    idsSelected += id;
	    
	    if(itr.hasNext())
	        idsSelected += ",";
	}
	String strURL = "emxMassPromoteDemoteProcess.jsp?uiType="+XSSUtil.encodeForURL(context, uiType)+"&cmd="+XSSUtil.encodeForURL(context, cmd);
  %>
<script type ="text/javascript" language="JavaScript">
var uiType = '<xss:encodeForJavaScript><%=uiType%></xss:encodeForJavaScript>';
function callback(strURL,close)
{
	if(close == true)
	{
		alert("<emxUtil:i18nScript localize="i18nId">emxFramework.MassPromoteDemote.SuccessMessage</emxUtil:i18nScript>");
		win.closeWindow();
	}
	else 
	{
		var strFeatures = "location=no,menubar=no,titlebar=yes,width=700,height=500,resizable=yes,scrollbars=auto";
		document.errorForm.action = strURL;
		document.errorForm.method ="post";
		document.errorForm.target = win.name;
		addSecureToken(document.errorForm);
		document.errorForm.submit();
		removeSecureToken(document.errorForm);
	}
	if(strURL == "NoAlert")	
	{
		win.closeWindow();
		return;
	}
	if (uiType =="table")
	{
		parent.refreshTableData();
	}
	else
	{
		//IR-066682V6R2011x
		parent.emxEditableTable.refreshStructureWithOutSort();
		parent.rebuildView();
	}
	
} 
//var strFeatures = "width=780,height=500,dependent=yes,resizable=yes";
	var strFeatures = "location=no,menubar=no,titlebar=yes,width=700,height=500,resizable=yes,scrollbars=auto";
	 var win = window.open("emxErrorReportDialog.jsp?status=Progress", "NewWindow", strFeatures);
	 function getIds()
	 {
		//XSSOK
		document.processingForm.action = '<%=strURL%>';
		document.processingForm.method ="post";
		document.processingForm.target = "processPage";
		addSecureToken(document.processingForm);
		document.processingForm.submit();
		removeSecureToken(document.processingForm);
	 }
</script>
<body onload ='getIds()'> 
	<form name ="errorForm">
	</form>
	<form name = "processingForm">
		<input type="hidden" value ='<xss:encodeForHTMLAttribute><%=idsSelected%></xss:encodeForHTMLAttribute>' name ="emxTableRowId" id = "emxTableRowId" />
	</form>
</body>
<iframe name ="processPage" src = 'emxBlank.jsp' >

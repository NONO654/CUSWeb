<%-- ProductConfigurationRecomputeListPrice.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/configuration/ProductConfigurationRecomputeListPrice.jsp 1.70.2.7.1.2.1.1 Wed Dec 17 12:39:33 2008 GMT ds-dpathak Experimental$: ProductConfigurationRecomputeListPrice.jsp";
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.*"%>
<%@page import = "java.util.List" %>
<%@page import = "com.matrixone.apps.configuration.*"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%> 
<%@page import = "com.dassault_systemes.enovia.configuration.modeler.ConfigurationGovernanceCommon"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

<%

String mode = emxGetParameter(request,"mode");

if(mode.equals("RecalculateOnProperties"))
{
	String objectId = emxGetParameter(request, "objectId");
	String[] args = new String[2];
	args[0] = objectId;
	args[1] = "true";
	JPO.invoke(context,"jpo.CfgDictionaryMdl.ConfigurationModelerUA",null,"recomputeListPrice",args);
%>	
    <script language="javascript" type="text/javaScript">
    
    var contentFrameObj = findFrame(getTopWindow(),"content");
    contentFrameObj.document.location.href = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&DefaultCategory=FTRProductConfigurationTree";                
    
    </script>
<%
}
else if(mode.equals("RecalculateOnSummaryColumn"))
{
	String objectId = emxGetParameter(request, "objectId");
	String[] args = new String[2];
	args[0] = objectId;
	args[1] = "true";
	JPO.invoke(context,"jpo.CfgDictionaryMdl.ConfigurationModelerUA",null,"recomputeListPrice",args);
%>	
    <script language="javascript" type="text/javaScript">
   				 
    window.parent.editableTable.loadData();
    window.parent.rebuildView();                    
    
    </script>
<%
}
else if(mode.equals("RecalculateOnSummaryAction"))
{
	String[] arrTableRowIds     = emxGetParameterValues(request, "emxTableRowId");
	boolean  isAlert            = false;	 
	for(int j = 0; j < arrTableRowIds.length; j++)
	{
		String   strIds         = arrTableRowIds[j];
		String[] arrIds         = strIds.split("\\|");
		String   strPCId        = arrIds[1];
		boolean  isPCFrozen     = ConfigurationGovernanceCommon.isFrozenState(context,strPCId);
		if(isPCFrozen){
			isAlert = true;
			break;
		}
	}
	
	if(isAlert)
	{
		%>
        <script language="javascript" type="text/javaScript">
              alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.PleaseSelectNonFrozenPC</emxUtil:i18n>");
        </script>
       <%
	}
	else 
	{
		for(int i = 0; i < arrTableRowIds.length; i++)
		{
			String   strIds         = arrTableRowIds[i];
			String[] arrIds         = strIds.split("\\|");
			String   strPCId        = arrIds[1];
		
			String[] args = new String[2];
			args[0] = strPCId;
			args[1] = "true";
			JPO.invoke(context,"jpo.CfgDictionaryMdl.ConfigurationModelerUA",null,"recomputeListPrice",args);
		}
		%>	
		<script language="javascript" type="text/javaScript">
		   				 
		window.parent.editableTable.loadData();
		window.parent.rebuildView();                    
		    
		</script>
	    <%
	}
}
%>


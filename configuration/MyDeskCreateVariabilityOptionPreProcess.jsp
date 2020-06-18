<%--
  MyDeskCreateVariabilityOptionPreProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
                 
<%
  try
  {	  
	 String strLanguage = context.getSession().getLanguage();      
     String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
     String strCreationType = emxGetParameter(request, "CreationType");
     String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.RowSelect.Single", strLanguage);
     String strVariabilityOptionNotAllowed = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.VariabilityOptionNotAllowed", strLanguage);
     
     if(strTableRowIds != null && strTableRowIds.length > 1)
     {
        %>
    	<script language="javascript" type="text/javaScript">
           alert("<%=strRowSelectSingle%>");                
   		</script>
   		<%
     }
     else if(strTableRowIds != null && strTableRowIds.length == 1)
     {
    	String strObjectId = ""; 
    	String strType = "";
    	StringList lstVariabilityGroupChildTypes = new StringList();
    	
    	boolean isObjectFrozen = false;
    	String[] arrTableRowId = strTableRowIds[0].toString().split("\\|");
    	strObjectId = arrTableRowId[1];
    	if(ProductLineCommon.isNotNull(strObjectId))
    	{
    		DomainObject domObj = DomainObject.newInstance(context, strObjectId);
    		StringList strSelect = new StringList();
    		strSelect.add(DomainConstants.SELECT_TYPE);
    		Map variantMap = domObj.getInfo(context, strSelect);
    		strType = (String) variantMap.get(DomainConstants.SELECT_TYPE);
    		lstVariabilityGroupChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_VARIABILITYGROUP);
    	}
    	
    	if(!lstVariabilityGroupChildTypes.contains(strType))
    	{
    		%>
        	<script language="javascript" type="text/javaScript">
               alert("<%=strVariabilityOptionNotAllowed%>");                
       		</script>
       		<%
    	}
    	else
    	{
	        %>
	         <body>   
             <form name="FTRVariabilityOptionCreateForm" method="post">
		     <script language="javascript" type="text/javaScript">          
		           	 var submitURL = "../common/emxCreate.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&type=type_VariabilityOption&showApply=true&typeChooser=false&autoNameChecked=false&nameField=both&submitAction=none&vaultChooser=true&form=type_CreateVariabilityOption&header=emxConfiguration.Form.Heading.CreateVariabilityOption&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&createJPO=ConfigurationFeature:createVariabilityOption&HelpMarker=emxhelpvariantoptioncreate&policy=policy_ConfigurationOption&postProcessURL=../configuration/MyDeskCreateVariabilityOptionPostProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&parentOID=<%=XSSUtil.encodeForURL(context,strObjectId)%>&UIContext=myDesk";
		          	 getTopWindow().showSlideInDialog(submitURL, "true");
		     </script>
		     </form>
             </body>
	        <%
        }
     }
  }
  catch(Exception e){
    	    session.putValue("error.message", e.getMessage());
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

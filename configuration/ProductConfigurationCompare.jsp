<%--
  ProductConfigurationCompare.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxProductCommonInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>

<%@page import="matrix.util.StringList"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>

<%
	String received = emxGetParameter(request, "context");
	String objectId = emxGetParameter(request, "objectId");
	try 
	{				  	
		  String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
		  boolean isFTRUser = ConfigurationUtil.isFTRUser(context);
		  boolean isCMMUser = ConfigurationUtil.isCMMUser(context);
		  boolean isMobileMode = UINavigatorUtil.isMobile(context);
  		  boolean personAccess = false;
  		  if (PersonUtil.hasAssignment(context, PropertyUtil.getSchemaProperty(context,"role_ProductManager")) ||
			    	PersonUtil.hasAssignment(context, PropertyUtil.getSchemaProperty(context,"role_SystemEngineer"))||
			    	PersonUtil.hasAssignment(context, PropertyUtil.getSchemaProperty(context,"role_VPLMProjectLeader"))||
			    	PersonUtil.hasAssignment(context, PropertyUtil.getSchemaProperty(context,"role_SeniorDesignEngineer"))||
			    	PersonUtil.hasAssignment(context, PropertyUtil.getSchemaProperty(context,"role_DesignEngineer")))
  		  {
  			personAccess = true;
  		  }
		  String colHyperlinkURL = "../configuration/ProductConfigurationViewAction.jsp?fromPCComparePage=true";
		  String colHyperlinkTargetLocation = "listHidden";
		  String colHyperlinkIcon = "images/iconActionEdit.gif";
		  String colHyperlinkIconToolTipKey = "emxConfiguration.Title.EditIcon";
		  String registeredSuiteKey = "Configuration";
		  if(isMobileMode||(!isFTRUser&&!isCMMUser)||!personAccess){
			  colHyperlinkURL="";
		  }
		  StringBuffer bn = new StringBuffer();
		  if(arrTableRowIds != null){
			  StringList strObjectIdList = new StringList();
		      StringTokenizer strTokenizer = null;
  		   	  String strObjectID = "";
		      for(int i=0;i<arrTableRowIds.length;i++)
			    {
			      
			    	if(arrTableRowIds[i].indexOf("|") > 0){
			              strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
			              strTokenizer.nextToken();				              				              
			              strObjectID = strTokenizer.nextToken() ;				              
			              strObjectIdList.add(strObjectID);
			          }
			          else{
			        	  strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
			        	  strObjectID = strTokenizer.nextToken() ;
			        	  strObjectIdList.add(strObjectID);				        	  
			          }
			    }
		      for(int i=0;i<strObjectIdList.size();i++)
		      {   
		          bn.append((String)strObjectIdList.get(i));
		          if(i<(strObjectIdList.size()-1)){
		           bn.append(",");
		          }
		      }
		  }
		  //----------------------------------------------------------		  
		  //getting all PCs ID from PC summary to be passed in URL----
		  //----------------------------------------------------------
 		  StringBuffer allPC = new StringBuffer();
 	      String strAllPCParam="&AllPCID=";
		  String timeStamp = emxGetParameter(request,"timeStamp");
 	      HashMap tableData = indentedTableBean.getTableData(timeStamp);
 	      MapList objList = indentedTableBean.getObjectList(tableData);
		  for(int i =0 ; i< objList.size(); i++){                
              Map mapPC = new HashMap();
              mapPC = (Map) objList.get(i);
              String strObjectId = (String) mapPC.get(DomainConstants.SELECT_ID);
              allPC.append(strObjectId);
	          if(i<(objList.size()-1)){
	        	  allPC.append(",");
	          }
          }
		  if(bn.length()==0){
			  strAllPCParam=strAllPCParam+allPC;
		  }
		  //----------------------------------------------------------		  
		  //getting all PCs ID from PC summary to be passed in URL----
		  //----------------------------------------------------------	
		if (received.equals("Product") || received.equals("ProductVariant"))
		{
			
			String strURL = "../common/emxGridTable.jsp?colHyperlinkIconToolTipKey="+ XSSUtil.encodeForURL(context,colHyperlinkIconToolTipKey)+ "&registeredSuiteKey="+ XSSUtil.encodeForURL(context,registeredSuiteKey)+ "&colHyperlinkIcon="+ XSSUtil.encodeForURL(context,colHyperlinkIcon)+ "&colHyperlinkTargetLocation="+ XSSUtil.encodeForURL(context,colHyperlinkTargetLocation)+ "&colHyperlinkURL="+ XSSUtil.encodeForURL(context,colHyperlinkURL)+ "&table=FTRProductConfigurationComparisonReportTable&objectId="+  XSSUtil.encodeForURL(context,objectId)+ "&freezePane=Display Name,Name,Revision,Type,Seq No&rowJPO=emxProductConfiguration:getCFStructureForPCCompareGrid&colJPO=emxProductConfiguration:getProductConfigurationForGrid&selectId="+bn.toString()+strAllPCParam+"&header=emxProductConfiguration.Header.ProductConfigurationComparison&subHeader=emxConfiguration.Table.SubHeader.SelectedOptionsComparison&SuiteDirectory=configuration&suiteKey=Configuration&expandLevelFilterMenu=FTRExpandAllLevelFilter&editLink=false&objectCompare=false&sortColumnName=Sequence Order&sortDirection=ascending&helpMarker=emxhelpproductconfigurationcomparisonreport";
%>
		<script language="Javascript">
    	    var url = '<%=XSSUtil.encodeForJavaScript(context,strURL)%>';
        	showModalDialog(url,700,800,true,'Large');
        </script>
<%
	} else if(received.equals("LogicalFeature")){
		String strURL = "../common/emxGridTable.jsp?colHyperlinkIconToolTipKey="+ XSSUtil.encodeForURL(context,colHyperlinkIconToolTipKey)+ "&registeredSuiteKey="+ XSSUtil.encodeForURL(context,registeredSuiteKey)+ "&colHyperlinkIcon="+ XSSUtil.encodeForURL(context,colHyperlinkIcon)+ "&colHyperlinkTargetLocation="+ XSSUtil.encodeForURL(context,colHyperlinkTargetLocation)+ "&colHyperlinkURL="+ XSSUtil.encodeForURL(context,colHyperlinkURL)+ "&table=FTRProductConfigurationComparisonReportTable&objectId="+  XSSUtil.encodeForURL(context,objectId)+ "&freezePane=Display Name,Name,Revision,Type,Seq No&rowJPO=emxProductConfiguration:getCFStructureForPCCompareGrid&colJPO=emxProductConfiguration:getProductConfigurationForGrid&selectId="+bn.toString()+strAllPCParam+"&header=emxProductConfiguration.Header.GridTable.ProductConfigurationComparison&subHeader=emxConfiguration.Table.SubHeader.SelectedOptionsComparison&SuiteDirectory=configuration&suiteKey=Configuration&expandLevelFilterMenu=FTRExpandAllLevelFilter&editLink=false&objectCompare=false&sortColumnName=Sequence Order&sortDirection=ascending&helpMarker=emxhelpproductconfigurationcomparisonreport";
		%>
				<script language="Javascript">
		    	    var url = '<%=XSSUtil.encodeForJavaScript(context,strURL)%>';
		        	showModalDialog(url,700,800,true,'Large');
		        </script>	
	<%	
	}
	} catch (Exception e) {
		e.printStackTrace();
		session.putValue("error.message", e.getMessage());
	}
%>


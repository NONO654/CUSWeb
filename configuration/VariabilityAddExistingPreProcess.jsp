<%--
  VariabilityAddExistingPreProcess.jsp
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

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
  try
  {	  
	  String strLanguage = context.getSession().getLanguage();
      String isModel = emxGetParameter(request,"isModel");
      String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
      String strObjectID = null;
      String parentId = null;      
      String parentForIRule = emxGetParameter(request, "parentOID");
      String strAddExistingNotAllowed = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.AddExistingNotAllowed", strLanguage);
      String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.RowSelect.Single", strLanguage);
      
      if(strTableRowIds != null && strTableRowIds.length > 1)
      {
         %>
     	 <script language="javascript" type="text/javaScript">
               alert("<%=strRowSelectSingle%>");                
    	 </script>
    	 <%
      }
      else
      {
	      if("true".equals(isModel))
	      {
	    	  strObjectID = emxGetParameter(request, "parentOID");    
	    	  parentId = emxGetParameter(request, "parentOID");
	    	  if(strTableRowIds != null && strTableRowIds.length == 1){
	    		 StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0] , "|"); 
	    		 strTokenizer.nextToken();
	             strObjectID = strTokenizer.nextToken();
	    	  }      
	      }
	      else
	      {
	    	  StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0] , "|");
	    	  if(strTableRowIds[0].indexOf("|") > 0){                        
	              strTokenizer.nextToken();
	              strObjectID = strTokenizer.nextToken();
	              if(strTokenizer.hasMoreTokens()){
	                  parentId = strTokenizer.nextToken();                        
	              }
	          }
	          else{
	              strObjectID = strTokenizer.nextToken();
	          }
	      }
	      
	      StringList objectSelectList = new StringList();
	      objectSelectList.addElement(ConfigurationConstants.SELECT_TYPE);
	      
	      Hashtable parentInfoTable = (Hashtable)(new DomainObject(strObjectID).getInfo(context, objectSelectList));
	      String strParentType = (String)parentInfoTable.get(ConfigurationConstants.SELECT_TYPE);
	      
	      StringList PLSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_PRODUCT_LINE);
	      StringList MDSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_MODEL);
	      StringList PRDSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_PRODUCTS);
	      if(!PLSubTypes.contains(strParentType) && !MDSubTypes.contains(strParentType) && !PRDSubTypes.contains(strParentType))
	      {
	    	  %>
	          <script language="javascript" type="text/javaScript">
	                alert("<%=XSSUtil.encodeForJavaScript(context,strAddExistingNotAllowed)%>");
	          </script>
	         <%
	      }
	      else
	      {
	    	  String strInclusionFeatureTypes = EnoviaResourceBundle.getProperty(context,"emxConfiguration.Variability.AddExisting.Features.IncludeTypes");
	    	  boolean isCloudMode = UINavigatorUtil.isMobile(context);
	    	  if(isCloudMode){
	    		  strInclusionFeatureTypes.replaceAll(",type_ConfigurationFeature", "");
	    	  }
			  String strformInclusionList = "DISPLAY_NAME";
			  String contextAccessFunction = "ConfigurationFeature";
	      	  %>
	          <body>   
	          <form name="FTRVariabilityFullSearch" method="post">
	          <script language="Javascript">
	              var strFeatureTypes = "<%=XSSUtil.encodeForJavaScript(context,strInclusionFeatureTypes)%>";
	              var context = "<%=XSSUtil.encodeForJavaScript(context,contextAccessFunction)%>";
	              var submitURL = "../common/emxFullSearch.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&txtType=<%=XSSUtil.encodeForURL(context,strParentType)%>&field=TYPES="+strFeatureTypes+":CURRENT!=policy_ConfigurationFeature.state_Obsolete,policy_PerpetualResource.state_Obsolete&excludeOIDprogram=ConfigurationFeature:excludeAvailableVariability&table=FTRConfigurationFeaturesSearchResultsTable&HelpMarker=emxhelpfullsearch&selection=multiple&showInitialResults=false&showSavedQuery=true&hideHeader=true&formInclusionList=<%=XSSUtil.encodeForURL(context,strformInclusionList)%>&context="+context+"&suiteKey=Configuration&submitURL=../configuration/VariabilityAddExistingPostProcess.jsp?suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&parentOID=<%=XSSUtil.encodeForURL(context,parentId)%>&emxExpandFilter=1&isModel=<%=XSSUtil.encodeForURL(context,isModel)%>&parentForIRule=<%=XSSUtil.encodeForURL(context,parentForIRule)%>";
	              showModalDialog(submitURL,575,575,"true","Large");
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

<%--
  VariabilityGroupsAddExistingPreProcess.jsp
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
      String strInclusionFeatureTypes = "";
      String strformInclusionList = "";
      String parentForIRule = emxGetParameter(request, "parentOID");
      String strVariabilityOptionCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.VariabilityOptionCheck", strLanguage);
      String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureAddOptionNotAllowed", strLanguage);
      String strAddExistingOnVariabilityGroupUnsupported = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.AddExistingOnVariabilityGroupUnsupported", strLanguage);
      
      if("true".equals(isModel)){
    	  strObjectID = emxGetParameter(request, "parentOID");    
    	  parentId = emxGetParameter(request, "parentOID");
    	         
      }
      else{
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
      
      boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strObjectID);
      String contextAccessFunction="";
      if(strParentType != null && !"".equals(strParentType))
      {
          if(bInvalidState){
              %>
              <script language="javascript" type="text/javaScript">
                    alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidStateCheck)%>");
              </script>
             <%
          }
          else{
        	  StringList varSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIABILITYGROUP);
    	      if(varSubTypes.contains(strParentType)){
    		  	  strInclusionFeatureTypes = EnoviaResourceBundle.getProperty(context,"emxConfiguration.VariabilityOption.AddExisting.Features.IncludeTypes");
    	      }else{
    	    	  strInclusionFeatureTypes = EnoviaResourceBundle.getProperty(context,"emxConfiguration.VariabilityGroup.AddExisting.Features.IncludeTypes");
    	      }
        		  
        		  strformInclusionList = "DISPLAY_NAME";
        		  contextAccessFunction = "ConfigurationFeature";
        	
              %>
              <body>   
              <form name="FTRVariabilityGroupFullSearch" method="post">
              <script language="Javascript">
                  var strFeatureTypes = "<%=XSSUtil.encodeForJavaScript(context,strInclusionFeatureTypes)%>";
                  var context = "<%=XSSUtil.encodeForJavaScript(context,contextAccessFunction)%>";
                  var submitURL = "../common/emxFullSearch.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&txtType=<%=XSSUtil.encodeForURL(context,strParentType)%>&field=TYPES="+strFeatureTypes+":CURRENT!=policy_ConfigurationFeature.state_Obsolete&excludeOIDprogram=ConfigurationFeature:excludeAvailableVariabilityGroups&table=FTRConfigurationFeaturesSearchResultsTable&HelpMarker=emxhelpfullsearch&selection=multiple&showInitialResults=false&showSavedQuery=true&hideHeader=true&formInclusionList=<%=XSSUtil.encodeForURL(context,strformInclusionList)%>&context="+context+"&suiteKey=Configuration&submitURL=../configuration/VariabilityGroupsAddExistingPostProcess.jsp?suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&parentOID=<%=XSSUtil.encodeForURL(context,parentId)%>&emxExpandFilter=1&isModel=<%=XSSUtil.encodeForURL(context,isModel)%>&parentForIRule=<%=XSSUtil.encodeForURL(context,parentForIRule)%>";
                  showModalDialog(submitURL,575,575,"true","Large");
              </script>
              </form>
              </body>
              <%     
          } 
      }
  }catch(Exception e){
 	    session.putValue("error.message", e.getMessage());
  }
  %>
  
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

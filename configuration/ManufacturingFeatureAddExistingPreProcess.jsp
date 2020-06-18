<%--
  ManufacturingFeatureAddExistingPreProcess.jsp
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
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="java.util.Enumeration" %>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>


<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
boolean bIsError = false;
String action = "";
String msg = "";

  try
  {	  
	  String strLanguage = context.getSession().getLanguage();
      String isModel = emxGetParameter(request,"isModel");
      String strObjIdContext = emxGetParameter(request, "objectId");
      String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
      String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
      String strObjectID = null;
      String parentId = null;      
      String strInclusionFeatureTypes="";
      String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureAddOptionNotAllowed", strLanguage);
      String parentForIRule = emxGetParameter(request, "parentOID");
      // List of Sub Types of Features that need to be searched for Add Existing.
      
    
      if("true".equals(isModel)){
    	  strObjectID = emxGetParameter(request, "parentOID");    
    	  parentId = emxGetParameter(request, "parentOID");
    	         
      }
      else{
    	  String tempRelID = "";
    	  StringTokenizer strTokenizer = null;
      for(int i=0;i<arrTableRowIds.length;i++)
      {
          
          if(arrTableRowIds[i].indexOf("|") > 0){
                strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                tempRelID = strTokenizer.nextToken();                                                       
                strObjectID = strTokenizer.nextToken() ;                            
            }
            else{
                strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                strObjectID = strTokenizer.nextToken() ;                                     
            }
      }
      }      
      String strParentType = new DomainObject(strObjectID).getType(context);
      
      boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strObjIdContext);
      
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
        	  if(mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_PRODUCTS)){
        			  strInclusionFeatureTypes = EnoviaResourceBundle.getProperty(context,"emxConfiguration.ManufacturingFeature.AddExisting.ProductContext.IncludeTypes");
        	  }
        	  else if (mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_LOGICAL_FEATURE)){
        		  strInclusionFeatureTypes = EnoviaResourceBundle.getProperty(context,"emxConfiguration.ManufacturingFeature.AddExisting.LogicalFeatureContext.IncludeTypes");
        	  }
              else if (mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_MODEL)){
            	  strInclusionFeatureTypes = EnoviaResourceBundle.getProperty(context,"emxConfiguration.ManufacturingFeature.AddExisting.ModelContext.IncludeTypes");
              }
              else if (mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_MANUFACTURING_FEATURE)){
            	  strInclusionFeatureTypes = EnoviaResourceBundle.getProperty(context,"emxConfiguration.ManufacturingFeature.AddExisting.ManufacturingFeatureContext.IncludeTypes");
              }
              %>
              <body>   
              <form name="FTRConfigurationFeatureFullSearch" method="post">
              <script language="Javascript">
                  var strFeatureTypes = "<%=XSSUtil.encodeForJavaScript(context,strInclusionFeatureTypes)%>";
                  var submitURL = "../common/emxFullSearch.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&txtType=<%=XSSUtil.encodeForURL(context,strParentType)%>&field=TYPES="+strFeatureTypes+":CURRENT!=policy_ManufacturingFeature.state_Obsolete&excludeOIDprogram=ManufacturingFeature:excludeAvailableManufacturingFeature&table=FTRLogicalFeatureSearchResultsTable&HelpMarker=emxhelpfullsearch&selection=multiple&showInitialResults=false&formInclusionList=DISPLAY_NAME&showSavedQuery=true&hideHeader=true&suiteKey=Configuration&submitURL=../configuration/ManufacturingFeatureAddExistingPostProcess.jsp?suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&parentOID=<%=XSSUtil.encodeForURL(context,parentId)%>&emxExpandFilter=1&isModel=<%=XSSUtil.encodeForURL(context,isModel)%>&parentForIRule=<%=XSSUtil.encodeForURL(context,parentForIRule)%>";
                  showModalDialog(submitURL,575,575,"true","Large");
              </script>
              </form>
              </body>
              <%     
          } 
      }
  }catch(Exception e)
     {
    	    bIsError=true;
    	    session.putValue("error.message", e.getMessage());
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

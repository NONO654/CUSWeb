<%--
  LogicalFeatureAddExistingPreProcess.jsp
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

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.*"%>
<%@page import = "java.util.Enumeration" %>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
StringList strObjectIdList = new StringList();

  try
  {	  
	  String strMode = emxGetParameter(request, "mode");
      String strParentObjId = emxGetParameter(request, "ParentObjId");
      
	  if(strMode != null && strMode.equals("getLFSelectionType"))
      {  
      DomainObject LFObjectId = new DomainObject(strParentObjId);
      String strSelect = "attribute[" + ConfigurationConstants.ATTRIBUTE_LOGICAL_SELECTION_TYPE + "]";
      String strSelectionType = LFObjectId.getInfo(context, strSelect);
      out.println("SelectionType=" + strSelectionType + "#");
      }else{
    	  
      String isModel = emxGetParameter(request,"isModel");
      String strObjIdContext = emxGetParameter(request, "objectId");
      String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");      
      String strObjectID = null;
      String parentId = null;
      String txtType = null;      
      // List of Sub Types of Features that need to be searched for Add Existing.
      String strInclusionFeatureTypes = EnoviaResourceBundle.getProperty(context,"emxConfiguration.LogicalFeatureOption.AddExisting.Features.IncludeTypes");
      String strInclusionProductTypes = EnoviaResourceBundle.getProperty(context,"emxConfiguration.LogicalFeatureOption.AddExisting.Products.IncludeTypes");
      String strLanguage = context.getSession().getLanguage();
      String strProductAsLogicalFeatureCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.ProductAsLogicalFeatureCheck", strLanguage);
      String strLeafLevelCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.LeafLevel.Selected", strLanguage);
      String parentForIRule = emxGetParameter(request, "parentOID");
      if("true".equals(isModel)){
    	  strObjectID = emxGetParameter(request, "parentOID");    
    	  parentId = emxGetParameter(request, "parentOID");    	         
          
     %>
     <body>   
     <form name="FTRLogicalFeatureFullSearch" method="post">  
     <input type="hidden" name="excludeOID" value=""/>  
     <script language="Javascript">
         var strFeatureTypes = "<%=XSSUtil.encodeForJavaScript(context,strInclusionFeatureTypes)%>";
         var strProductTypes = "<%=XSSUtil.encodeForJavaScript(context,strInclusionProductTypes)%>";
         var submitURL = "../common/emxFullSearch.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&txtType=<%=XSSUtil.encodeForURL(context,txtType)%>&field=TYPES="+strFeatureTypes+":CURRENT!=policy_LogicalFeature.state_Obsolete&showInitialResults=false&excludeOIDprogram=LogicalFeature:excludeAvailableCandidateLogicalFeature&table=FTRLogicalFeatureSearchResultsTable&HelpMarker=emxhelpfullsearch&selection=multiple&showSavedQuery=true&hideHeader=true&formInclusionList=DISPLAY_NAME,PARTFAMILY&suiteKey=Configuration&submitURL=../configuration/LogicalFeatureAddExistingPostProcess.jsp?suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&parentOID=<%=XSSUtil.encodeForURL(context,parentId)%>&isModel=<%=XSSUtil.encodeForURL(context,isModel)%>";
  	 showModalDialog(submitURL,850,630,"true","Medium");
     </script>
     </form>
     </body>
     <% 
            
     } else{
         StringTokenizer strTokenizer = null;         
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
         ConfigurationUtil util = new ConfigurationUtil();
         boolean isFrozen = false; 
         for(int i =0 ;i<strObjectIdList.size();i++)
         {
             isFrozen = util.isFrozenState(context,(String)strObjectIdList.get(i));
             if(isFrozen)
                 break;                      
         }
         
         DomainObject parentObj =  new DomainObject(strObjectID);
         StringList objectSelectList = new StringList();
         objectSelectList.addElement(DomainConstants.SELECT_TYPE);  
         objectSelectList.addElement(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);      
         Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList);
         txtType  = (String)parentInfoTable.get(DomainConstants.SELECT_TYPE);   
         String strLeafLeavel = (String)parentInfoTable.get(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);   
     
         if(strObjIdContext!=null && !strObjIdContext.equals(strObjectID) && mxType.isOfParentType(context,txtType,ConfigurationConstants.TYPE_PRODUCTS))
         {
             %>
             <script language="javascript" type="text/javaScript">
                   alert("<%=XSSUtil.encodeForJavaScript(context,strProductAsLogicalFeatureCheck)%>");                
             </script>
            <%
         }
         else if(isFrozen)
         {
          %>
             <script language="javascript" type="text/javaScript">
                   alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.LogicalFeatureReleased</emxUtil:i18n>");  
             </script>
          <%
         } 
         else if(strLeafLeavel.equalsIgnoreCase("Yes"))
         {
             %>
             <script language="javascript" type="text/javaScript">
                   alert("<%=XSSUtil.encodeForJavaScript(context,strLeafLevelCheck)%>");   
                                getTopWindow().close;
             </script>
            <%
         }
         else{
                                    
    	     %>
    	     <body>   
    	     <form name="FTRLogicalFeatureFullSearch" method="post">
    	     
             <script language="Javascript">
             var strFeatureTypes = "<%=XSSUtil.encodeForJavaScript(context,strInclusionFeatureTypes)%>";
             var strProductTypes = "<%=XSSUtil.encodeForJavaScript(context,strInclusionProductTypes)%>";
                       
             var submitURL = "../common/emxFullSearch.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&txtType=<%=XSSUtil.encodeForURL(context,txtType)%>&field=TYPES="+strFeatureTypes+","+strProductTypes+":CURRENT!=policy_LogicalFeature.state_Obsolete&showInitialResults=false&excludeOIDprogram=LogicalFeature:excludeAvailableLogicalFeature&table=FTRLogicalFeatureSearchResultsTable&HelpMarker=emxhelpfullsearch&selection=multiple&showSavedQuery=true&showInitialResults=false&hideHeader=true&formInclusionList=DISPLAY_NAME,PARTFAMILY&suiteKey=Configuration&submitURL=../configuration/LogicalFeatureAddExistingPostProcess.jsp?suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&parentOID=<%=XSSUtil.encodeForURL(context,parentId)%>&emxExpandFilter=1&isModel=<%=XSSUtil.encodeForURL(context,isModel)%>&parentForIRule=<%=XSSUtil.encodeForURL(context,parentForIRule)%>";
             showModalDialog(submitURL,575,575,"true","Medium");
             </script>
    	     </form>
    	     </body>
    	     <%  
      }
     }
    }
  }catch(Exception e)
     {
    	    session.putValue("error.message", e.getMessage());
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%--  LogicalFeatureMergeReplaceSearchPreProcess.jsp
   Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><body leftmargin="1" rightmargin="1" topmargin="1" bottommargin="1" scroll="no">
<%--Breaks without the useBean--%>

<%@ page import = "java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.Part"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="java.util.Map"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.HashMap"%>

<html>

  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
  <jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
try
{
	boolean isRootNodeSelected = false; //IR-346897-3DEXPERIENCER2016x- for rootNode checking
	
    String strMode    = emxGetParameter(request, "mode");
    String jsTreeID = emxGetParameter(request,"jsTreeID");  
    String initSource = emxGetParameter(request,"initSource");
    String relID = emxGetParameter(request, "relId");
    String strObjectId    = emxGetParameter(request, "objectId");
    String strContext    = emxGetParameter(request, "context");
    String strPrentOId = emxGetParameter(request, "parentOID");
    String strProductId = emxGetParameter(request, "prodId");
    String strLanguage = context.getSession().getLanguage();
    String strLeafLevelCopyCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.LeafLevel.CopyFrom", strLanguage);
   
    LogicalFeature logicalFeature = new LogicalFeature();
    String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    String strObjectID = "";
    StringTokenizer strTokenizer = null;
    
    for(int i=0;i<strTableRowIds.length;i++)
    {
        strTokenizer = new StringTokenizer(strTableRowIds[i] , "|");
        if(strTableRowIds[i].indexOf("|") > 0){
              strTokenizer.nextToken();
              strObjectID = strTokenizer.nextToken() ;   
          }    
        else{
      	  isRootNodeSelected = true;                         
        }
    }
    
    //IR-346897-3DEXPERIENCER2016x- for rootNode checking
    if(isRootNodeSelected == true){
		 %>
        <script language="javascript" type="text/javaScript">
              alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");
        </script>
        <%
	}
    else
    {
    
    
    DomainObject parentObj =  new DomainObject(strObjectID);
    StringList objectSelectList = new StringList();
    objectSelectList.addElement(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);
    objectSelectList.addElement(ConfigurationConstants.SELECT_TYPE);  //IR-346897-3DEXPERIENCER2016x- for rootNode checking
    Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList); 
    String strLeafLeavel = (String)parentInfoTable.get(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);
    String strType = (String)parentInfoTable.get(ConfigurationConstants.SELECT_TYPE);
    boolean isOfProductType=false;  //IR-346897-3DEXPERIENCER2016x- for rootNode checking
    if(ProductLineCommon.isNotNull(strType))
    {
     isOfProductType= mxType.isOfParentType(context, strType, ConfigurationConstants.TYPE_PRODUCTS);
    }
     if(strMode.equalsIgnoreCase("MergeReplace")&& (strLeafLeavel.equalsIgnoreCase(ConfigurationConstants.RANGE_VALUE_LEAFLEVEL_NO) || 
    		 isOfProductType)) //IR-346897-3DEXPERIENCER2016x- for rootNode checking
    	    {
      String step = emxGetParameter(request, "Step");
      boolean showPopup = false;
      
      if(step!=null && step.equals("SearchFeature") )
      {          
          session.removeAttribute("originalPartList");
          session.removeAttribute("nonRemoveParts");
          session.removeAttribute("removedParts");
          session.removeAttribute("Part List");
          String strFeatureId = "";
          String strRelId = emxGetParameter(request, ConfigurationConstants.SELECT_RELATIONSHIP_ID);
                      
          String strProdId = "";
          if(strContext!= null && strContext.equals("RMB"))
          {
              strRelId = relID;
              strFeatureId = strObjectId;
              strProdId = strPrentOId;
              strProductId = strPrentOId;
          }
          else{
        	  StringTokenizer strRowIdTZ = new StringTokenizer(strTableRowIds[0],"|");
                   
          if(strRowIdTZ.countTokens()>2)
             {
                 strRelId = strRowIdTZ.nextToken();
                 strFeatureId = strRowIdTZ.nextToken();
                 strProdId = strRowIdTZ.nextToken();
                 strProductId = strPrentOId;
             }             
           else
             {
                 strRelId = strRowIdTZ.nextToken();
                 strFeatureId = strRowIdTZ.nextToken();
             }             
          }
          String strSelectedType = "";
          if(strFeatureId!=null && !strFeatureId.equals("")&& !strFeatureId.equals("0")){
        	  DomainObject domFeature = new DomainObject(strFeatureId);
        	  //strSelectedType = domFeature.getInfo(context,DomainObject.SELECT_TYPE);
          }
           strPrentOId = strProdId;
           if(strContext!= null && strContext.equals("RMB") && strObjectId.equals("")){
                 %>
                 <script>
                    alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.CannotPerform</emxUtil:i18nScript>");
                 </script>
                 <%
			}
			else  if(strProdId.equals(""))
            {
                 %>
                 <script>                  
                  alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.CannotPerform</emxUtil:i18nScript>");
                 </script>
                 <% 
             }else if( isOfProductType ){
                 %>
                 <script>                  
                  alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.MergeandReplace.CannotPerform</emxUtil:i18nScript>");
                 </script>
                 <% 
             }
             else
                 showPopup = true; 
         if(showPopup)
         {
             
        	 boolean inValidState = logicalFeature.InvalidStateforMergeReplace(context, strFeatureId);
        	 
             if(!inValidState)
             {
                 showPopup = false;
                 %>
                 <script>                  
                  alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.FeatureisinRelease</emxUtil:i18nScript>");
                 </script>
                 <% 
             }
             else
                 showPopup = true;
         }
         Map urlData = new HashMap();
         urlData.put("strProductId",XSSUtil.encodeForURL(context,strProductId));
         urlData.put("initSource",XSSUtil.encodeForURL(context,initSource));
         urlData.put("jsTreeID",XSSUtil.encodeForURL(context,jsTreeID));
         urlData.put("strObjectId",XSSUtil.encodeForURL(context,strObjectId));
         urlData.put("strFeatureId",XSSUtil.encodeForURL(context,strFeatureId));
         urlData.put("strRelId",XSSUtil.encodeForURL(context,strRelId));
         
         
         String contentURL = logicalFeature.URLforMergeReplace(context,urlData , "Search");        
          
         if(showPopup)
         {
             %>
             <Script>
               showModalDialog("<%=XSSUtil.encodeForJavaScript(context, contentURL)%>", 780, 500,true, 'Large');
             </script>
             <%      
         }
         
      }
      
  }  else{       
      %>
      <script language="javascript" type="text/javaScript">
            alert("<%=XSSUtil.encodeForJavaScript(context,strLeafLevelCopyCheck)%>");                                             
      </script>
     <%        
} 
    }
     
}
catch(Exception ex) 
{
        session.putValue("error.message", ex.getMessage());
} 
%>

</html>




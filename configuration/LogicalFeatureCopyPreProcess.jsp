<%--
  LogicalFeatureCopyPreProcess.jsp
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
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="java.util.Enumeration" %>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.HashMap"%>
<%@page import ="com.matrixone.apps.domain.util.MapList"%>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
boolean allowAction=true;

  try
  {   
	  session.removeAttribute("selectedValues"); 
      String strLanguage = context.getSession().getLanguage();
      String strObjIdContext = emxGetParameter(request, "objectId");
      String strFunctionality = emxGetParameter(request, "functionality");
      String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
      String isFromPropertyPage = emxGetParameter(request, "isFromPropertyPage");
      
      String strObjectID = null;
      
      String strLogicalOptionCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.LogicalOptionCheck", strLanguage);
      String strProductAsLogicalFeatureCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.ProductAsLogicalFeatureCheck", strLanguage);
      String strLeafLevelCopyCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.LeafLevel.CopyFrom",strLanguage);
      String strObsoleteFeatureCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ObsoleteFeature",strLanguage);
      
      if(isFromPropertyPage != null && isFromPropertyPage.equals("true")){
          strTableRowIds = new String[]{"-1|"+strObjIdContext+"|-1|-1"};
      }
      session.setAttribute("selectedValues", strTableRowIds);  
      if(strTableRowIds[0].indexOf("|") > 0){
             StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0] , "|");              
             strTokenizer.nextToken() ;
             strObjectID = strTokenizer.nextToken() ;
             if(strTokenizer.hasMoreTokens()){
                 strTokenizer.nextToken();                        
             }
      }
      else{
          strObjectID = strObjIdContext;
      }
     
     StringTokenizer strTokenizer;
      String strLevelId = "";
      String strFeatureId = ""; 
    MapList selectedFeatureId=new MapList();
    StringList featureList=new StringList();
    for(int iCount=0;iCount<strTableRowIds.length;iCount++)
      {   
    
          strTokenizer = new StringTokenizer(strTableRowIds[iCount] , "|");
      	while(strTokenizer.hasMoreElements()){
            strTokenizer.nextToken();
            strFeatureId = strTokenizer.nextToken();
            if(strTokenizer.hasMoreTokens()){
             strTokenizer.nextToken();
            strLevelId = strTokenizer.nextToken();         
            String[] temp= strLevelId.split(",");        
            int countL=temp.length;            
            HashMap featureMap = new HashMap();
            featureMap.put("OId",strFeatureId);          
            featureMap.put("LevelCount",countL);
            selectedFeatureId.add(featureMap); 
            featureList.add(strFeatureId);
            }
           
            }
      }
    String strLeafLeavel="";
    String strParentType="";
    String current="";
	for(int i=0;i<featureList.size();i++){
    DomainObject parentObj =  new DomainObject((String)featureList.get(i));
    StringList objectSelectList = new StringList();
    objectSelectList.addElement(DomainConstants.SELECT_TYPE);
    objectSelectList.addElement(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);
    objectSelectList.addElement(ConfigurationConstants.SELECT_CURRENT);
    Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList);
    strParentType = (String)parentInfoTable.get(DomainConstants.SELECT_TYPE); 
    strLeafLeavel = (String)parentInfoTable.get(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);  
    current=(String)parentInfoTable.get(ConfigurationConstants.SELECT_CURRENT);
    if(current.equalsIgnoreCase(ConfigurationConstants.STATE_OBSOLETE)){    		   
		  allowAction=false;
		  break;
	  }
	}
	
    
    boolean result= ConfigurationUtil.isAllowMultilevel(context,selectedFeatureId);

  
	      if(strObjIdContext!=null && !strObjIdContext.equals(strObjectID) && mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_PRODUCTS))
	      {
	          %>
	          <script language="javascript" type="text/javaScript">
	                alert("<%=XSSUtil.encodeForJavaScript(context,strProductAsLogicalFeatureCheck)%>");                
	          </script>
	         <%
	      }
          else if(strFunctionality != null && strFunctionality.equals("LogicalFeatureCopyFrom")){
              if(strParentType != null && !"".equals(strParentType) && strParentType.equalsIgnoreCase(ConfigurationConstants.TYPE_EQUIPMENT_FEATURE))
              {
                  %>
                  <script language="javascript" type="text/javaScript">
                        alert("<%=XSSUtil.encodeForJavaScript(context,strLogicalOptionCheck)%>");
                  </script>
                 <%
              }
              else if(strLeafLeavel.equalsIgnoreCase(ConfigurationConstants.RANGE_VALUE_LEAFLEVEL_YES))
              {
                  %>
                  <script language="javascript" type="text/javaScript">
                        alert("<%=XSSUtil.encodeForJavaScript(context,strLeafLevelCopyCheck)%>");                                             
                  </script>
                 <%
              }
              else if(!allowAction){
           	   %>
                  <script language="javascript" type="text/javaScript">
                     alert("<%=XSSUtil.encodeForJavaScript(context,strObsoleteFeatureCheck)%>");      
                  </script>
               <%
           	  
             }
              else{
                  %>  
                    
                  <body>   
                  <form name="FTRLogicalFeatureFullSearch" method="post">                        
                  <script language="Javascript">                        
                      var submitURL="../common/emxPortal.jsp?portal=FTRLogicalFeatureCopyFromPortal&contextIndependent=no&mode=portal&header=emxProduct.ActionLink.CopyFrom&toolbar=&HelpMarker=emxhelplogicalfeaturecopyfrom&suiteKey=Configuration&functionality=LogicalFeatureCopyFrom&featureType=Configuration&objIdContext=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>";
                      showModalDialog(submitURL,575,575,"true","Large");                    
                  </script>     
                  </form>
                  </body>                      
                  <%                  
              }                   
          } 
          else if(strFunctionality != null && strFunctionality.equals("LogicalFeatureCopyTo")){
              if(strTableRowIds[0].endsWith("|0")){
                    %>
                       <script language="javascript" type="text/javaScript">
                             alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");      
                       </script>
                    <%
              }
              else if(!allowAction){
            	   %>
                   <script language="javascript" type="text/javaScript">
                      alert("<%=XSSUtil.encodeForJavaScript(context,strObsoleteFeatureCheck)%>");      
                   </script>
                <%
            	  
              }
        	  else if(!result){
        		  %>
   	           <script language="javascript" type="text/javaScript">
   	                 alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.SelectitemAtSameLevel</emxUtil:i18n>");
   	           </script>
   	        <%
        	  }
              else{
                  %>      
                  <body>   
                  <form name="FTRLogicalFeatureFullSearch" method="post">                  
                  <script language="Javascript">       
                     var submitURL="../common/emxPortal.jsp?portal=FTRLogicalFeatureCopyToPortal&contextIndependent=no&mode=portal&header=emxProduct.ActionLink.CopyTo&toolbar=&HelpMarker=emxhelplogicalfeaturecopyto&suiteKey=Configuration&functionality=LogicalFeatureCopyTo&featureType=Configuration&objIdContext=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&isFromPropertyPage=<%=XSSUtil.encodeForURL(context,isFromPropertyPage)%>";                       
                     showModalDialog(submitURL,575,575,"true","Large");                     
                  </script>  
                  </form>
                  </body>            
                  <%       
              }              
          }
         
  }catch(Exception e)
     {
            session.putValue("error.message", e.getMessage());
     }
     %>                     
                   
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

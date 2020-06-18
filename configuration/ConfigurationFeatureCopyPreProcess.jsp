<%--
  ConfigurationFeatureCopyPreProcess.jsp
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
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
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
      String strvariabilityMode = emxGetParameter(request, "variabilityMode");
      String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
      String isFromPropertyPage = emxGetParameter(request, "isFromPropertyPage");
      
      String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureAddOptionNotAllowed",strLanguage);
      String strObsoleteFeatureCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ObsoleteFeature",strLanguage);
      String strObjectID = null;
      
      String strVariantValueCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.VariantValueCheck",strLanguage);      
      String strVariabilityOptionCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.VariabilityOptionCheck",strLanguage);
            
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
      
      String strParentType = new DomainObject(strObjectID).getType(context);
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
	for(int i=0;i<featureList.size();i++){
	    DomainObject parentObj =  new DomainObject((String)featureList.get(i));	  
	   String current= parentObj.getInfo(context,ConfigurationConstants.SELECT_CURRENT);	    
	    if(current.equalsIgnoreCase(ConfigurationConstants.STATE_OBSOLETE)){    		   
			  allowAction=false;
			  break;
		  }
		}

         boolean result= ConfigurationUtil.isAllowMultilevel(context,selectedFeatureId);
          if(strFunctionality != null && strFunctionality.equals("ConfigurationFeatureCopyFrom")){
        	  boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strObjIdContext);
        	  if(bInvalidState){
        		  %>
                  <script language="javascript" type="text/javaScript">
                        alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidStateCheck)%>");
                  </script>
                 <%
        	  }
        	  else if(strParentType != null && !"".equals(strParentType) && mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_VARIANTVALUE))
              {
                  %>
                  <script language="javascript" type="text/javaScript">
                        alert("<%=XSSUtil.encodeForJavaScript(context,strVariantValueCheck)%>");
                  </script>
                 <%
              }
        	  else if(strParentType != null && !"".equals(strParentType) && mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_VARIABILITYOPTION))
              {
                  %>
                  <script language="javascript" type="text/javaScript">
                        alert("<%=XSSUtil.encodeForJavaScript(context,strVariabilityOptionCheck)%>");
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
                  <form name="FTRConfigurationFeatureFullSearch" method="post">                         
                  <script language="Javascript">   
                      var submitURL="../common/emxPortal.jsp?portal=FTRConfigurationFeatureCopyFromPortal&contextIndependent=no&mode=portal&header=emxProduct.ActionLink.CopyFrom&toolbar=&HelpMarker=emxhelpvariantcopyfrom&suiteKey=Configuration&functionality=ConfigurationFeatureCopyFrom&variabilityMode=<%=strvariabilityMode%>&featureType=Configuration&objIdContext=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>";
                      showModalDialog(submitURL,575,575,"true","Large");                                         
                  </script>     
                  </form>
                  </body>         
                  <%        		  
        	  }                   
          } 
          else if(strFunctionality != null && strFunctionality.equals("ConfigurationFeatureCopyTo")){
        	  if(strTableRowIds[0].endsWith("|0")){
        	        %>
        	           <script language="javascript" type="text/javaScript">
        	                 alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");
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
                  <form name="FTRConfigurationFeatureFullSearch" method="post">                  
                  <script language="Javascript">                     
                     var submitURL="../common/emxPortal.jsp?portal=FTRConfigurationFeatureCopyToPortal&contextIndependent=no&mode=portal&header=emxProduct.ActionLink.CopyTo&toolbar=&HelpMarker=emxhelpvariantcopyto&suiteKey=Configuration&functionality=ConfigurationFeatureCopyTo&variabilityMode=<%=strvariabilityMode%>&featureType=Configuration&objIdContext=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&isFromPropertyPage=<%=XSSUtil.encodeForURL(context,isFromPropertyPage)%>";
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

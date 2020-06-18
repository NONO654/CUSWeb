<%--
  ManufacturingFeatureCreatePreProcess.jsp
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
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

                   
<%
boolean bIsError = false;
String action = "";
String msg = "";

  try
  {	  
  
	  String strLanguage = context.getSession().getLanguage();      
      String strObjIdContext = emxGetParameter(request, "objectId");
      String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId"); 
      String strCreationType = emxGetParameter(request, "strCreationType");
      String strUIContext = emxGetParameter(request, "UIContext");
      String strHelpMarker = emxGetParameter(request, "HelpMarker");
      String strMode = emxGetParameter(request, "mode");
      String strObjectID = null;
      String parentId = null;      
      String heading = "";
      String formType = "";      
      
      String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureCreateOptionNotAllowed", strLanguage);
      String strEditModeNotSelected = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.LogicalFeature.Create.EditModeNotSelected", strLanguage);
      heading = "emxConfiguration.ActionLink.CreateManufacturingFeature";
      String selectOne = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.SelectOne", strLanguage);
      
      formType = "FTRCreateManufacturingFeature";
     
      if(strTableRowIds!=null){
    	 
         if(strMode!=null && strMode.equalsIgnoreCase("edit"))
          {
        	 if(strTableRowIds.length>1){
        	 %>
        	          <script language="javascript" type="text/javaScript">
        	                alert("<%=XSSUtil.encodeForJavaScript(context,selectOne)%>");                
        	          </script>
        	  <%
            }
            else{
              StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0] , "|"); 
              if(strTableRowIds[0].indexOf("|") > 0){                       
                String temp = strTokenizer.nextToken() ;
                strObjectID = strTokenizer.nextToken() ;
                  if(strTokenizer.hasMoreTokens()){
                   parentId = strTokenizer.nextToken();                        
                }
              }
             else{
              strObjectID = strTokenizer.nextToken();
             }
	          boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strObjectID);
		      if(bInvalidState == true){
	    	  %>
	          <script language="javascript" type="text/javaScript">
	                alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidStateCheck)%>");                
	          </script>
	         <%
	         }
	         else{
	         %>
	          <body>   
	          <form name="FTRCreateManufacturingFeature" method="post">
	          <script language="Javascript">
	          var submitURL = "../common/emxCreate.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&showApply=true&autoNameChecked=false&submitAction=none&typeChooser=false&nameField=both&vaultChooser=true&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&postProcessURL=../configuration/ManufacturingFeatureCreatePostProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&policy=policy_ManufacturingFeature";
	              getTopWindow().showSlideInDialog(submitURL,true);
	          </script>
	          </form>
	          </body>
	          <%     
	         }
          }
      }
         else{
          //alert message
          %>
          <script language="javascript" type="text/javaScript">
                alert("<%=XSSUtil.encodeForJavaScript(context,strEditModeNotSelected)%>");                
          </script>
         <%
       }
      } else if (strUIContext.equalsIgnoreCase("Model")||strUIContext.equalsIgnoreCase("Classification")) {
          %>
          <body>   
          <form name="FTRCreateManufacturingFeature" method="post">
          <script language="Javascript">
              var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&showApply=true&autoNameChecked=false&typeChooser=false&nameField=both&vaultChooser=true&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&submitAction=refreshCaller&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&policy=policy_ManufacturingFeature";
              getTopWindow().showSlideInDialog(submitURL, "true");
          </script>
          </form>
          </body>
          <%  
     }
     else{
         %>
         <body>   
         <form name="FTRCreateManufacturingFeature" method="post">
         <script language="Javascript">
             var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&showApply=true&autoNameChecked=false&typeChooser=false&nameField=both&vaultChooser=true&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&submitAction=refreshCaller&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&policy=policy_ManufacturingFeature";
             getTopWindow().showSlideInDialog(submitURL, "true");
         </script>
         </form>
         </body>
         <%                  
     }
  }catch(Exception e)
     {
       bIsError=true;
       session.putValue("error.message", e.getMessage());
     }
 %>
     
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

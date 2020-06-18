<%--
  ConfigurationFeatureCreatePreProcess.jsp
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
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
                 
<%
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
      String heading = "";
      String formType = "";    
      String strPolicy = "";
      String createJPO = "";                  
      String strConfigurationOptionCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ConfigurationOptionCheck",strLanguage);
      String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureCreateOptionNotAllowed", strLanguage);
      String strKeyInTypeCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.KeyInTypeCheck", strLanguage);
      String strContextNotSupportedForConfigurationOption = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForConfigurationOption", strLanguage);
      String strEditModeNotSelected = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.EditModeNotSelected",strLanguage);
      String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.RowSelect.Single", strLanguage);
      String strCFNotAllowed = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.ConfigurationFeatureNotAllowed", strLanguage);
            
      if(strCreationType.equals("type_ConfigurationFeature")){
          heading = "emxConfiguration.Form.Heading.FeatureCreate";
          formType = "type_ConfigurationFeatureCreate";
          strPolicy = "policy_ConfigurationFeature";
          createJPO ="ConfigurationFeature:createAndConnectConfigurationFeature";
      }
      else{
          heading = "emxConfiguration.Form.Heading.OptionCreate";
          formType = "type_ConfigurationOptionCreate";
          strPolicy = "policy_ConfigurationOption";
          createJPO ="ConfigurationFeature:createAndConnectConfigurationOption";
      }
      
      if(strTableRowIds != null && strTableRowIds.length > 1){
    	  %>
          <script language="javascript" type="text/javaScript">
                alert("<%=XSSUtil.encodeForJavaScript(context,strRowSelectSingle)%>");                
          </script>
         <%    	  
      }
      else if((strUIContext!= null && strUIContext.equals("myDesk") && strTableRowIds != null && strTableRowIds.length!=0) || (strUIContext!= null && strUIContext.equals("context")) ){    	
    	  
    	  if((strUIContext.equals("myDesk") && strMode != null && strMode.equals("edit")) || strUIContext.equals("context")){
    		  StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0] , "|"); 
              if(strTableRowIds[0].indexOf("|") > 0){                       
                  strTokenizer.nextToken() ;
                  strObjectID = strTokenizer.nextToken() ;
                  if(strTokenizer.hasMoreTokens()){
                      strTokenizer.nextToken();                        
                  }
              }
              else{
                  strObjectID = strTokenizer.nextToken();
              }
                   
              DomainObject parentObj =  new DomainObject(strObjectID);
              StringList objectSelectList = new StringList();
              objectSelectList.addElement(ConfigurationConstants.SELECT_TYPE);      
              objectSelectList.addElement(ConfigurationConstants.SELECT_ATTRIBUTE_KEYIN_TYPE);
              
              Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList);
              String strParentType = (String)parentInfoTable.get(ConfigurationConstants.SELECT_TYPE);      
              String strParentKeyInType = (String)parentInfoTable.get("attribute[Key-In Type]");
                    
              boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strObjectID);
              
            //If the context Configuration Feature is defined to have Key-In type other than Blank, then the Subfeature defined under it can only be of type Configuration Option
              if(strParentKeyInType != null && !"".equals(strParentKeyInType) && !strParentKeyInType.equalsIgnoreCase("Blank") && !strCreationType.equals("type_ConfigurationOption"))
              {
                  %>
                    <script language="javascript" type="text/javaScript">
                          alert("<%=XSSUtil.encodeForJavaScript(context,strKeyInTypeCheck)%>");
                    </script>
                   <%
              }else  if(strCreationType.equals("type_ConfigurationFeature") && mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE)){
            	  %>
                  <script language="javascript" type="text/javaScript">
                        alert("<%=XSSUtil.encodeForJavaScript(context,strCFNotAllowed)%>");                
                  </script>
                 <%
              }else if(strCreationType.equals("type_ConfigurationOption") && !mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE) ){
                  %>
                    <script language="javascript" type="text/javaScript">
                          alert("<%=XSSUtil.encodeForJavaScript(context,strContextNotSupportedForConfigurationOption)%>");
                    </script>
                   <%
              }   
              else if(mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_CONFIGURATION_OPTION))
              {
                  %>
                  <script language="javascript" type="text/javaScript">
                        alert("<%=XSSUtil.encodeForJavaScript(context,strConfigurationOptionCheck)%>");                
                  </script>
                 <%
              }
              else if(bInvalidState == true){
                  %>
                  <script language="javascript" type="text/javaScript">
                        alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidStateCheck)%>");                
                  </script>
                 <%
              }
              else{
                  %>
                  <body>   
                  <form name="FTRConfigurationFeatureCreate" method="post">
                  <script language="Javascript">
                      var submitURL = "../common/emxCreate.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&showApply=true&showPolicy=false&typeChooser=false&autoNameChecked=false&nameField=both&createJPO=<%=XSSUtil.encodeForURL(context,createJPO)%>&submitAction=none&vaultChooser=true&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&postProcessURL=../configuration/ConfigurationFeatureCreatePostProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&policy=<%=XSSUtil.encodeForURL(context,strPolicy)%>";
                      getTopWindow().showSlideInDialog(submitURL, "true");
                  </script>
                  </form>
                  </body>
                  <%     
              }
    	  }
    	  else{
    		  %>
              <script language="javascript" type="text/javaScript">
                    alert("<%=XSSUtil.encodeForJavaScript(context,strEditModeNotSelected)%>");              
              </script>
             <%
    	  }          
      }else{
    	  %>
          <body>   
          <form name="FTRConfigurationFeatureCreate" method="post">
          <script language="Javascript">
              var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&showApply=true&showPolicy=false&typeChooser=false&autoNameChecked=false&nameField=both&vaultChooser=true&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&createJPO=<%=XSSUtil.encodeForURL(context,createJPO)%>&SuiteDirectory=configuration&submitAction=refreshCaller&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&policy=<%=XSSUtil.encodeForURL(context,strPolicy)%>";
              getTopWindow().showSlideInDialog(submitURL, "true");
          </script>
          </form>
          </body>
          <%                                               
      } 
  }
  catch(Exception e){
    	    session.putValue("error.message", e.getMessage());
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

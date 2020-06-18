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

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
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
      
      String strProductAsLogicalFeatureCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.ProductAsLogicalFeatureCheck",strLanguage);
      String strEquipmentFeatureCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.EquipmentFeatureCheck", strLanguage);
      String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.LogicalFeatureReleased", strLanguage);
      String strEditModeNotSelected = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.LogicalFeature.Create.EditModeNotSelected", strLanguage);
      String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.RowSelect.Single", strLanguage);
      String strLeafLevelCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.LeafLevel.Selected", strLanguage);
         
          heading = "emxConfiguration.Form.Heading.LogicalCreate";
          formType = "FTRCreateLogicalFeature";           
          
          if(strTableRowIds != null && strTableRowIds.length > 1){
              %>
              <script language="javascript" type="text/javaScript">
                    alert("<%=XSSUtil.encodeForJavaScript(context,strRowSelectSingle)%>");                
              </script>
             <%       
          }
          else{
          
        	  if(strTableRowIds!=null){
        		  
        		  if(strMode!=null && strMode.equalsIgnoreCase("edit"))
        		  {
        			  if(strTableRowIds!=null){
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
        			  }    
                      
                      DomainObject parentObj =  new DomainObject(strObjectID);
                      StringList objectSelectList = new StringList();
                      objectSelectList.addElement(DomainConstants.SELECT_TYPE);  
                      objectSelectList.addElement(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);      
                      Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList);
                      String strParentType = (String)parentInfoTable.get(DomainConstants.SELECT_TYPE);   
                      String strLeafLeavel = (String)parentInfoTable.get(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);   
                      
                      boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strObjectID);
                      
                       
                       if(strParentType.equalsIgnoreCase(ConfigurationConstants.TYPE_EQUIPMENT_FEATURE))
                      {
                          %>
                          <script language="javascript" type="text/javaScript">
                                alert("<%=XSSUtil.encodeForJavaScript(context,strEquipmentFeatureCheck)%>");                
                          </script>
                         <%
                      }                    
                        
                       if(strObjIdContext!=null && !strObjIdContext.equals(strObjectID) && mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_PRODUCTS))
                       {
                           %>
                           <script language="javascript" type="text/javaScript">
                                 alert("<%=XSSUtil.encodeForJavaScript(context,strProductAsLogicalFeatureCheck)%>");                
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
                      else if(strLeafLeavel.equalsIgnoreCase(ConfigurationConstants.RANGE_VALUE_LEAFLEVEL_YES))
                       {
                           %>
                           <script language="javascript" type="text/javaScript">
                                 alert("<%=XSSUtil.encodeForJavaScript(context,strLeafLevelCheck)%>");                                             
                           </script>
                          <%
                       }
                      else{
                          %>
                          <body>   
                          <form name="FTRLogicalFeatureCreate" method="post">
                          <script language="Javascript">
                              var submitURL = "../common/emxCreate.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&showApply=true&autoNameChecked=false&typeChooser=false&nameField=both&submitAction=none&vaultChooser=true&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&postProcessURL=../configuration/LogicalSystemArchitectureCreatePostProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&policy=policy_LogicalFeature";
                              getTopWindow().showSlideInDialog(submitURL, "true");
                          </script>
                          </form>
                          </body>
                          <%     
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
        		  
                      
        		  
        	  }
        	   else if (strUIContext.equalsIgnoreCase("Model")||strUIContext.equalsIgnoreCase("Classification")) {
        		   
        		   %>
                   <body>   
                   <form name="FTRLogicalFeatureCreate" method="post">
                   <script language="Javascript">
                   var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&showApply=true&autoNameChecked=false&typeChooser=false&nameField=both&vaultChooser=true&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&submitAction=refreshCaller&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&policy=policy_LogicalFeature";
                   getTopWindow().showSlideInDialog(submitURL, "true");
                   </script>
                   </form>
                   </body>
                   <%  
        		  
        	  }
        	  else{
        		  %>
                  <body>   
                  <form name="FTRLogicalFeatureCreate" method="post">
                  <script language="Javascript">
                      var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&showApply=true&autoNameChecked=false&typeChooser=false&nameField=both&vaultChooser=true&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&submitAction=refreshCaller&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&policy=policy_LogicalFeature";
                      getTopWindow().showSlideInDialog(submitURL, "true");
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

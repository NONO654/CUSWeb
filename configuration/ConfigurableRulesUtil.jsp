
<%--
  ConfigurableRulesUtil.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/ConfigurableRulesUtil.jsp 1.3.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.ConfigurableRulesUtil"%> 

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
 
<%
boolean bFlag=false;
try{
  //gets the mode passed
  String strMode = emxGetParameter(request, "mode");
  if(strMode.equals("validate")){
    String objectId = emxGetParameter(request, "objectId");
       
       ArrayList invalidReferenceList = ConfigurableRulesUtil.validateBCRforInvalidFOReference(context,objectId);
      
       
       if(invalidReferenceList.size()==0){
  %>
      <!--Javascript to show the alert message that left expression is invalid-->
      <script language="javascript" type="text/javaScript">
        alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.AllValidRules</emxUtil:i18n>");
      </script>
  <%  }else{
%>      
    <!--Javascript to show the alert message that left expression is invalid-->
    <script language="javascript" type="text/javaScript">
      var msg = "<emxUtil:i18n localize='i18nId'>emxProduct.Alert.OverAllBooleanCompatibilityRuleInvalidFeatureOptionReferenceStart</emxUtil:i18n>";
      msg += "\n\n";
      msg += "<emxUtil:i18n localize='i18nId'>emxProduct.Alert.OverAllBooleanCompatibilityRuleInvalidFeatureOptionReferenceTableHeading</emxUtil:i18n>";  
      msg += "\n\n";
<%      
      for(int i=0;i<invalidReferenceList.size();i++){
        HashMap invalidMap = (HashMap)invalidReferenceList.get(i);
        String strBCRname = (String)invalidMap.get("BCRNAME");
%>          
      msg += "<%=XSSUtil.encodeForJavaScript(context,strBCRname)%>";
      msg += "\t\t\t";
<%
    ArrayList invalidFOlist = (ArrayList)invalidMap.get("INVALID_LIST");
    for(int j=0;j<invalidFOlist.size();j++){
        String strFOname = (String)invalidFOlist.get(j);
        if(j!=0){
%>
              msg += ",";
<%
        }
        if((j!=0)&&((j%3)==0)){
%>
      msg += "\n        \t\t\t";
<%      
        }
%>      
      msg += "<%=XSSUtil.encodeForJavaScript(context,strFOname)%>";
<%  
    }
%>      
      msg += "\n\n";
<%
      }
%>  
      alert(msg);
    </script>
<%
    }
  }
  }catch (Exception e){
    bFlag=true;
    session.putValue("error.message", e.getMessage());
  }
  %>
  
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
  <%
      if (bFlag)
      {
  %>
      <!--Javascript to bring back to the previous page-->
      <script language="javascript" type="text/javaScript">
        history.back();
      </script>
  <%
      }
%>

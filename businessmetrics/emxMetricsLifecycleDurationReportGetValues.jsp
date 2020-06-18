
<%-- emxMetricsLifecycleDurationReportGetValues.jsp - This file will display the Policy and states associated with the chosen Type
   
   Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsLifecycleDurationReportGetValues.jsp.rca 1.11 Wed Oct 22 16:11:58 2008 przemek Experimental $
--%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file="emxMetricsConstantsInclude.inc"%>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="request"/>

<head>
    <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
    <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
</head>
<body>

<%
    String choosenType = emxGetParameter(request,"Type");
    String languageStr = request.getHeader("Accept-Language");  
    HashMap policyDetails = metricsReportBean.singlePolicyWithMultipleStates(context, choosenType, languageStr);
    if(policyDetails != null && policyDetails.size() > 0 && !(policyDetails.containsKey("No Policy")) && !(policyDetails.containsKey("No States")) && !(policyDetails.containsKey("All Policy"))) {
        String strActualPolicyName = (String) policyDetails.get("ActualPolicyName");
        String strTranslatedPolicyName = (String) policyDetails.get("Policy");
        String target = (String) policyDetails.get("Target State");
        String fromState = (String) policyDetails.get("From State");
        String toState = (String) policyDetails.get("To State");
        String strAllStates = (String) policyDetails.get("Hidden States");
%>
        <script>
            var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
            var targetState = contentFrame.document.getElementById("trgState");
            targetState.innerHTML = '<%= XSSUtil.encodeForJavaScript(context, target) %>';
            var fromState = contentFrame.document.getElementById("frmState");
            fromState.innerHTML = '<%= XSSUtil.encodeForJavaScript(context, fromState) %>';
            var toState = contentFrame.document.getElementById("toState");
            toState.innerHTML = '<%= XSSUtil.encodeForJavaScript(context, toState) %>';
            contentFrame.document.forms[0].hdnAllStates.value = '<%=XSSUtil.encodeForJavaScript(context, strAllStates) %>';
            contentFrame.document.forms[0].txtPolicyActual.value = '<%=XSSUtil.encodeForJavaScript(context, strActualPolicyName) %>';
            contentFrame.document.forms[0].lstTargetState.selectedIndex = contentFrame.document.forms[0].lstTargetState.options.length-1;
            contentFrame.document.forms[0].lstToState.selectedIndex = contentFrame.document.forms[0].lstToState.options.length-1;
            contentFrame.document.forms[0].txtPolicyDisplay.value = '<%=XSSUtil.encodeForJavaScript(context, strTranslatedPolicyName)%>';
            contentFrame.document.forms[0].btnPolicy.disabled = true;
        </script>
<%
    } else {
        if(policyDetails.containsKey("No Policy")){
%>
            <script>
                 var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
                 contentFrame.document.forms[0].hdnAllStates.value = '';
                 var lenTargetState = contentFrame.document.forms[0].lstTargetState.options.length;
                 for(var i=lenTargetState-1;i>-1;i--){
                     contentFrame.document.forms[0].lstTargetState.options[i] = null;
                 }
                 var lenFromState = contentFrame.document.forms[0].lstFromState.options.length;
                 for(var i=lenFromState-1;i>-1;i--){
                     contentFrame.document.forms[0].lstFromState.options[i] = null;
                 }
                 var lenToState = contentFrame.document.forms[0].lstToState.options.length;
                 for(var i=lenToState-1;i>-1;i--){
                     contentFrame.document.forms[0].lstToState.options[i] = null;
                 }
                contentFrame.document.forms[0].txtPolicyDisplay.value = '';
                contentFrame.document.forms[0].btnPolicy.disabled = true;
                alert(STR_METRICS_TYPE_WITH_NO_POLICY);
            </script>
<%
        }else if(policyDetails.containsKey("All Policy")  || policyDetails.size()==0){
%>
            <script>
                 var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
                 contentFrame.document.forms[0].hdnAllStates.value = '';
                 var lenTargetState = contentFrame.document.forms[0].lstTargetState.options.length;
                 for(var i=lenTargetState-1;i>-1;i--){
                     contentFrame.document.forms[0].lstTargetState.options[i] = null;
                 }
                 var lenFromState = contentFrame.document.forms[0].lstFromState.options.length;
                 for(var i=lenFromState-1;i>-1;i--){
                     contentFrame.document.forms[0].lstFromState.options[i] = null;
                 }
                 var lenToState = contentFrame.document.forms[0].lstToState.options.length;
                 for(var i=lenToState-1;i>-1;i--){
                     contentFrame.document.forms[0].lstToState.options[i] = null;
                 }
                contentFrame.document.forms[0].txtPolicyDisplay.value = '';
                contentFrame.document.forms[0].btnPolicy.disabled = true;
                alert(STR_METRICS_POLICY_WITH_NO_STATE);
            </script>
<%        
        } 
        else if(policyDetails.containsKey("No States"))
        {
%>
          <script>
              var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
              contentFrame.document.forms[0].hdnAllStates.value = '';
              var lenTargetState = contentFrame.document.forms[0].lstTargetState.options.length;
              for(var i=lenTargetState-1;i>-1;i--){
                  contentFrame.document.forms[0].lstTargetState.options[i] = null;
              }
              var lenFromState = contentFrame.document.forms[0].lstFromState.options.length;
              for(var i=lenFromState-1;i>-1;i--){
                  contentFrame.document.forms[0].lstFromState.options[i] = null;
              }
              var lenToState = contentFrame.document.forms[0].lstToState.options.length;
              for(var i=lenToState-1;i>-1;i--){
                  contentFrame.document.forms[0].lstToState.options[i] = null;
              }
              contentFrame.document.forms[0].txtPolicyDisplay.value = '';
              contentFrame.document.forms[0].btnPolicy.disabled = false;
          </script>

<%
        }
    }
%>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

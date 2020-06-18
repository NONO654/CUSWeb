<%--  emxMetricsObjectCountInStateReportGetValues.jsp - This JSP populates the "Policy" and "State" fields of the Object Count in State dialog apge

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsObjectCountInStateReportGetValues.jsp.rca 1.12 Wed Oct 22 16:11:56 2008 przemek Experimental $
--%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file="emxMetricsConstantsInclude.inc"%>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="request"/>

<head>
    <script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
</head>
<body>

<%
    String choosenType             = emxGetParameter(request,"Typename");
    String choosenPolicy           = emxGetParameter(request,"Policyname");
    String mode                    = emxGetParameter(request,"Mode");
    String languageStr             = request.getHeader("Accept-Language");  
    String strTranslatedPolicyVal  = "";
    String strTranslatedPolicyName = "";
    String strTranslatedStateName  = "";
    String strTranslatedForm       = "";
    ArrayList policyList = new ArrayList();
    MapList parentPoliciesMap = new MapList();

    if (choosenType == null || "null".equals(choosenType) || "".equals(choosenType)) {
        choosenType = "";
    }

    if (choosenPolicy == null || "null".equals(choosenPolicy) || "".equals(choosenPolicy)) {
        choosenPolicy = "";
    }

    if (mode == null || "null".equals(mode) || "".equals(mode)) {
        mode = "";
    }
    
    // To eliminate the policy which are hidden
    
    if((!"".equalsIgnoreCase(choosenType) && (choosenType != null)) 
                              && (!"liststate".equalsIgnoreCase(mode))){
        MapList policiesMap = mxType.getPolicies(context,choosenType,false);
        for (int i = 0; i < policiesMap.size(); i++){
            HashMap policyMap = (HashMap)policiesMap.get(i);
            String policyName = (String) policyMap.get("name");
            policyList.add(policyName);
        }
        if(policiesMap.size()==0){
            while(true){
                choosenType = metricsReportBean.loopParent(context,choosenType);
                if(choosenType.length() == 0){
                    break;
                }else{
                    parentPoliciesMap = mxType.getPolicies(context,choosenType,false);
                    if(parentPoliciesMap.size() != 0){
                        break;
                    }
                }
            }
        }
    }

    // Enter this loop for populating the policies of the chosen type in the dialog page
    if("listpolicy".equalsIgnoreCase(mode)) {
        StringBuffer polBuffer = new StringBuffer ();
        Iterator polItr = policyList.iterator ();
        String policyName = "";
        String firstPolicy = "";
        int policyCount = 0; 
        while ( polItr.hasNext() ){
            policyName = (String) polItr.next ();
            if(policyCount == 0){
                firstPolicy = policyName;
            }
            strTranslatedPolicyVal = i18nNow.getAdminI18NString("Policy", policyName, languageStr);
            strTranslatedPolicyName = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(strTranslatedPolicyVal+"","'","\\\'"),"\"","\\\"");
            //polBuffer.append ("<option value =\""+ policyName + "\" text=\"" + strTranslatedPolicyName + "\">" + strTranslatedPolicyName + "</option>"); 
            polBuffer.append ("<option value =\"");
            polBuffer.append (XSSUtil.encodeForHTMLAttribute(context, policyName));
            polBuffer.append ("\" text=\"");
            polBuffer.append (strTranslatedPolicyName);
            polBuffer.append ("\">");
            polBuffer.append (strTranslatedPolicyName);
            polBuffer.append ("</option>");
            policyCount++;
        }  
        StringBuffer policyCombo = new StringBuffer ("<select name=\"listpolicy\" style=\"\" id=\"listpolicy\" onChange=\"javascript:updateState();\">");
        policyCombo.append (polBuffer.toString ());
        policyCombo.append("</select>");
        ArrayList firstPol = metricsReportBean.getStateNames(context,firstPolicy);
        StringBuffer firstateBuffer = new StringBuffer ();
        String stateName = "";
        Iterator firstpolItr = firstPol.iterator ();  
        while ( firstpolItr.hasNext() ){
            stateName = (String) firstpolItr.next ();
            strTranslatedForm = i18nNow.getStateI18NString(firstPolicy, stateName, languageStr);
            strTranslatedStateName = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(strTranslatedForm+"","'","\\\'"),"\"","\\\"");
            //firstateBuffer.append ("<option value =\""+ stateName + "\" text=\"" + strTranslatedStateName + "\">" + strTranslatedStateName + "</option>");  
            firstateBuffer.append ("<option value =\"");
            firstateBuffer.append (XSSUtil.encodeForHTMLAttribute(context, stateName));
            firstateBuffer.append ("\" text=\"");
            firstateBuffer.append (strTranslatedStateName);
            firstateBuffer.append ("\">");
            firstateBuffer.append (strTranslatedStateName);
            firstateBuffer.append ("</option>");
        }
        StringBuffer stateCombo = new StringBuffer ("<select name=\"liststate\" style=\"\" id=\"liststate\" >");      
        stateCombo.append(firstateBuffer.toString ());
        stateCombo.append("</select>");
%>
        <script>
            var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
            var grpByObject = contentFrame.document.getElementById("lstpolicy");
            //XSSOK
            grpByObject.innerHTML = '<%= policyCombo.toString () %>';
            var grpByObject = contentFrame.document.getElementById("trgState");
          //XSSOK
            grpByObject.innerHTML = '<%= stateCombo.toString () %>';
        </script>

<%
    } else if("liststate".equalsIgnoreCase(mode)) {
        ArrayList stateNames = metricsReportBean.getStateNames(context,choosenPolicy);
        StringBuffer firstateBuffer = new StringBuffer ();
        String stateName = "";
        Iterator firstpolItr = stateNames.iterator ();  
        while ( firstpolItr.hasNext() ){
            stateName = (String) firstpolItr.next ();
            strTranslatedForm = i18nNow.getStateI18NString(choosenPolicy, stateName, languageStr);
            strTranslatedStateName = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(strTranslatedForm+"","'","\\\'"),"\"","\\\"");
            //firstateBuffer.append ("<option value =\""+ stateName + "\">" + strTranslatedStateName + "</option>");  
            firstateBuffer.append ("<option value =\"");
            firstateBuffer.append (stateName);
            firstateBuffer.append ("\" text=\"");
            firstateBuffer.append (strTranslatedStateName);
            firstateBuffer.append ("\">");
            firstateBuffer.append (strTranslatedStateName);
            firstateBuffer.append ("</option>");
        }
        StringBuffer stateCombo = new StringBuffer ("<select name=\"liststate\" style=\"width:\" id=\"liststate\" >");      
        stateCombo.append(firstateBuffer.toString ());
        stateCombo.append("</select>");
%>
        <script>
            var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
            var grpByObject = contentFrame.document.getElementById("trgState");
          //XSSOK
            grpByObject.innerHTML = '<%= stateCombo.toString () %>';
        </script>
<%
    }
    if(policyList.size() == 0 && "listpolicy".equalsIgnoreCase(mode) && parentPoliciesMap.size()==0){
%>
        <script>
            alert(STR_METRICS_TYPE_WITH_NO_POLICY);
        </script>
<%
    }
%>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

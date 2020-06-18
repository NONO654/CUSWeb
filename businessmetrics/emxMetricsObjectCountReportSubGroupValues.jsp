<%--  emxMetricsObjectCountReportSubGroupValues.jsp
    Copyright (c) 2005-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program
    static const char RCSID[] = $Id: emxMetricsObjectCountReportSubGroupValues.jsp.rca 1.8 Wed Oct 22 16:11:58 2008 przemek Experimental $
--%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="request"/>

<head>
    <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
    <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
</head>

<body>
<%
    String strType     = emxGetParameter(request,"Type");
    String attrName    = emxGetParameter(request,"AttributeName");
    String languageStr = request.getHeader("Accept-Language");
    String attrType    = "";
    String strBundle   = "emxMetricsStringResource";
    String strSubGroup = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.SubGroup");
    StringBuffer attrBuffer = new StringBuffer ();
    Map attrDetailsMap = metricsReportBean.getAttributeDetails(context,strType);
    // Get all the Attribute names which are the keys in the HashMap
    java.util.Set attrKeys = attrDetailsMap.keySet ();
    java.util.Iterator attrItr = attrKeys.iterator ();
        if(attrName.equalsIgnoreCase("owner")) {
            attrType = "string";
        }
        else if(attrName.equalsIgnoreCase("current")) {
            attrType = "string";
        }
        else if(attrName.equalsIgnoreCase("description")) {
            attrType = "string";
        }
        else if(attrName.equalsIgnoreCase("originated")) {
            attrType = "timestamp";
        }
        else if(attrName.equalsIgnoreCase("modified")) {
            attrType = "timestamp";
        }
        else{
            attrType = (String) attrDetailsMap.get(attrName);
        }
        attrBuffer.append ("<option value =\"\"></option>"); 
        while ( attrItr.hasNext() ){
            String attributeName = (String) attrItr.next ();
            
            // Check to prevent the same attribute name appearing in both the 
            // groupby and subgroup select boxes
            if(attributeName.equalsIgnoreCase(attrName)){
                continue;
            }
            
            // Get the Range of an attribute
            int rangeSize = metricsReportBean.getRangeSize(context,attributeName);
            String attrTypeSpecific = (String) attrDetailsMap.get(attributeName);
            String sAttributeName = i18nNow.getAttributeI18NString(attributeName,languageStr);
            // add all the other Range and Integer attribs to another array
            if (!"timestamp".equalsIgnoreCase(attrType)){
                if(rangeSize > 0 || "integer".equalsIgnoreCase(attrTypeSpecific)){
                    attrBuffer.append ("<option value =\""+ XSSUtil.encodeForHTMLAttribute(context, attributeName) + "\">" + sAttributeName + "</option>"); 
                } 
            }else{
                if (!"timestamp".equalsIgnoreCase(attrTypeSpecific)){
                    if(rangeSize > 0 || "integer".equalsIgnoreCase(attrTypeSpecific)){
                        attrBuffer.append ("<option value =\""+ XSSUtil.encodeForHTMLAttribute(context, attributeName) + "\">" + sAttributeName + "</option>"); 
                    }
                }
            }
        }
        StringBuffer sbSubGroup = new StringBuffer ("<select name=\"lstSubgroup\" id=\"lstSubgroup\">");
        sbSubGroup.append (attrBuffer.toString ());
        sbSubGroup.append("</select>");

        //Escape single quotes
        String sSubGroup = sbSubGroup.toString();
        StringTokenizer st = new StringTokenizer(sSubGroup, "'");
        StringBuffer sbSubGroupEscape = new StringBuffer();
        while(st.hasMoreTokens() ){
            sbSubGroupEscape.append(st.nextToken());
            if(st.hasMoreTokens()){
                sbSubGroupEscape.append("\\'");
            }
        }

%>

    <script>
        var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
        var grpByObject = contentFrame.document.getElementById("subGrpBydiv");
        //XSSOK
        grpByObject.innerHTML = '<%= sbSubGroupEscape.toString () %>';
<%  
        if ("timestamp".equalsIgnoreCase(attrType)){%>
            contentFrame.document.forms[0].optDateUnit[0].disabled=false;
            contentFrame.document.forms[0].optDateUnit[1].disabled=false;
            contentFrame.document.forms[0].optDateUnit[2].disabled=false;
            contentFrame.document.forms[0].optDateUnit[3].disabled=false;
            contentFrame.document.forms[0].optDateUnit[0].checked=true;
<%  
        }
        else{
%>
            contentFrame.document.forms[0].optDateUnit[0].disabled=true;
            contentFrame.document.forms[0].optDateUnit[1].disabled=true;
            contentFrame.document.forms[0].optDateUnit[2].disabled=true;
            contentFrame.document.forms[0].optDateUnit[3].disabled=true;
            contentFrame.document.forms[0].optDateUnit[0].checked=false;
<%
        }
%>
    </script>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

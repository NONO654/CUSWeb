<%--  emxMetricsObjectCountOverTimeReportGetValues.jsp
    Copyright (c) 2005-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program
    static const char RCSID[] = $Id: emxMetricsObjectCountOverTimeReportGetValues.jsp.rca 1.9 Wed Oct 22 16:11:56 2008 przemek Experimental $
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
    String choosenType = emxGetParameter(request,"Type");
    String languageStr = request.getHeader("Accept-Language");
    String strBundle   = "emxMetricsStringResource";
    String attrType    = "";
    String strSubGroup = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.SubGroup");
    String strSelectOne = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.SelectOne");
    Map attrDetailsMap = metricsReportBean.getAttributeDetails(context,choosenType);
    StringBuffer attrBuffer = new StringBuffer ();
    
    // Get all the Attribute names which are the keys in the HashMap
    java.util.Set attrKeys = attrDetailsMap.keySet ();
    java.util.Iterator attrItr = attrKeys.iterator ();
    
    String searchBasics = (String)EnoviaResourceBundle.getProperty(context, "emxMetrics.MetricsReports.ObjectCountOverTimeBasicAttributes");
    StringList basicList = FrameworkUtil.split(searchBasics, ",");
    attrBuffer.append ("<option value =\"SelectOne\">");
    attrBuffer.append (strSelectOne); 
    attrBuffer.append ("</option>"); 
    for(int l=0;l<basicList.size();l++ ){
        String strBasicAttr = (String)basicList.get(l);
        
        if(strBasicAttr.equalsIgnoreCase("Originated") || strBasicAttr.equalsIgnoreCase("Modified")){
            String sBasicAttributeName = i18nNow.getBasicI18NString(strBasicAttr,languageStr);
            attrBuffer.append ("<option value =\""+ strBasicAttr + "\">" + sBasicAttributeName + "</option>"); 
        }
    }
    while ( attrItr.hasNext() ){
        String attributeName = (String) attrItr.next ();
        String sAttributeName = i18nNow.getAttributeI18NString(attributeName,languageStr);
        attrType = (String) attrDetailsMap.get(attributeName);
        if("timestamp".equalsIgnoreCase(attrType)){
            attrBuffer.append ("<option value =\""+ XSSUtil.encodeForHTMLAttribute(context, attributeName) + "\">" + sAttributeName + "</option>"); 
        }
    }
    StringBuffer sbGroupBy = new StringBuffer ("<select name=\"lstGroupBy\" style=\"width:190\" id=\"lstGroupBy\" onChange=\"javascript:updateSubgroupForOverTime();\">");
    sbGroupBy.append (attrBuffer.toString ());     
    sbGroupBy.append("</select>");
    String strSubGroupBy = "<select name=\"lstSubgroup\" id=\"lstSubgroup\"></select>";
    //Escape single quotes
    String sGroupBy = sbGroupBy.toString();
    StringTokenizer st = new StringTokenizer(sGroupBy, "'");
    StringBuffer sbGroupByEscape = new StringBuffer();
    while(st.hasMoreTokens() ){
        sbGroupByEscape.append(st.nextToken());
        if(st.hasMoreTokens()){
            sbGroupByEscape.append("\\'");
        }
    }

%>
    <script>
        var contentFrame = findFrame(getTopWindow(),"metricsReportContent");
        var grpByObject = contentFrame.document.getElementById("grpBydiv");
        //XSSOK
        grpByObject.innerHTML = '<%= sbGroupByEscape.toString () %>';
        var subGrpByObject = contentFrame.document.getElementById("subGrpBydiv");
        //XSSOK
        subGrpByObject.innerHTML = '<%=strSubGroupBy%>';
    </script>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </body>
</html>

<%-- smaAddCategoryFS.jsp
    Copyright (c) 1992-2003 MatrixOne, Inc.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: smaAddCategoryFS.jsp.rca 1.7 Thu May 27 19:38:38 2004 jwilliams Experimental young bwarren young young young young young young young young young young young young young young young young young young young young young young young young young young young young young young young chen chen chen chen young young young chen chen chen young chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen $
 --%>

<%@page import="java.net.URLEncoder"%>

<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%
    String objectId   = emxGetParameter(request,"objectId");
    String categories = emxGetParameter(request,"categories");

    StringBuffer queryString = new StringBuffer("");

    Enumeration eNumParameters = emxGetParameterNames(request);
    int paramCounter = 0;
    while( eNumParameters.hasMoreElements() ) 
    {
        String strParamName = (String)eNumParameters.nextElement();
        String strParamValue = emxGetParameter(request, strParamName);
        
        if("categories".equals(strParamName)) {
        	strParamValue = URLEncoder.encode(strParamValue);
        }
        
        if(paramCounter > 0)
            queryString.append("&");

        paramCounter++;
        queryString.append(strParamName);
        queryString.append("=");
        queryString.append(strParamValue);
    }
    String bodyURL = "../simulationcentral/smaAddCategory.jsp?"+queryString.toString();
    String footURL = "../simulationcentral/smaAddCategoryFooter.jsp?"+queryString.toString();

    final String locale = context.getSession().getLanguage();
    String header = SimulationUtil.getI18NString(context,
        "Common.AddCategory.PageHeading");

%>
<html>
    <head>
        <title><%=header %></title>
        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
        <script language="javascript" src="../common/scripts/emxUIPopups.js"></script>
        <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </head>
        <frameset rows="45,*,45" framespacing="0" frameborder="no" border="0"> 
            <frame src="smaAddCategoryHeader.jsp" id="AddCatBody" name="AddCatHead" marginwidth="10" marginheight="10" frameborder="no" noresize scrolling="no" />
            <frame src="<%=bodyURL %>"            id="AddCatBody" name="AddCatBody" marginwidth="8"  marginheight="8"  frameborder="no" />
            <frame src="<%=footURL %>"            id="AddCatFoot" name="AddCatFoot" marginwidth="8"  marginheight="8"  frameborder="no" noresize scrolling="no" />
        </frameset>
 </html>
%>

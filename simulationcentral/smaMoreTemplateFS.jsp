<%-- smaMoreFS.jsp
    Copyright (c) 1992-2003 MatrixOne, Inc.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: smaMoreFS.jsp.rca 1.7 Thu May 27 19:38:38 2004 jwilliams Experimental young bwarren young young young young young young young young young young young young young young young young young young young young young young young young young young young young young young young chen chen chen chen young young young chen chen chen young chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen chen $
 --%>


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
         
        if(paramCounter > 0)
            queryString.append("&");

        paramCounter++;
        queryString.append(strParamName);
        queryString.append("=");
        queryString.append(strParamValue);
    }
    String bodyURL = "../simulationcentral/smaMoreTemplate.jsp?"+queryString.toString();

%>
<html>
    <head>
        <title>Select Categories</title>
        <script language="javascript" src="scripts/emxUIConstants.js"></script>
        <script language="javascript" src="scripts/emxUIModal.js"></script>
        <script language="javascript" src="scripts/emxUIPopups.js"></script>
        <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </head>
        <frameset rows="45,*" framespacing="0" frameborder="no" border="0"> 
            <frame src="smaMoreHeader.jsp" id="AddCatBody" name="AddCatHead" marginwidth="10" marginheight="10" frameborder="no" noresize scrolling="no" />
            <frame src="<%=bodyURL %>"             id="AddCatBody" name="AddCatBody" marginwidth="8"  marginheight="8"  frameborder="no" />
        </frameset>
 </html>
%>

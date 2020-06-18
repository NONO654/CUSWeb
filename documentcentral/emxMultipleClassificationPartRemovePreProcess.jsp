<%--  emxMultipleClassificationPartRemovePreProcess.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] = "$Id: emxMultipleClassificationPartRemovePreProcess.jsp.rca 1.1.2.1 Wed Oct 22 16:02:26 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>

<%
    final String MCM_STRING_RESOURCE = "emxLibraryCentralStringResource";


    boolean isSearchAllSublevels = "All Levels".equalsIgnoreCase( (String)session.getAttribute("LCSearchType") );
    
    String strarChildIds[]        = (String[]) emxGetParameterValues(request, "emxTableRowId");
    strarChildIds               = getTableRowIDsArray(strarChildIds); 
    String strParentObjectId    = emxGetParameter(request, "objectId");
    Vector vecCurrentAttributes = com.matrixone.apps.classification.Classification.findAttributes(context, strParentObjectId);

    int intCountOfPartsThatWillLoseAttributes = 0;
    if(strarChildIds != null && strarChildIds.length > 0) {
        for (int i=0; i<strarChildIds.length; i++)
        {
            boolean isGoingToLoseAttributes = com.matrixone.apps.classification.Classification.checkIfItLosesAttributeOnRemoval(context,
                                                                               strParentObjectId,
                                                                               vecCurrentAttributes,
                                                                               strarChildIds[i], isSearchAllSublevels);
            if (isGoingToLoseAttributes)
            {
                intCountOfPartsThatWillLoseAttributes++;
            }
        }
    }
%>

<html>
<head>
</head>
<body>

<!--
-- This form stores all the request paramters as hidden form fields. After your is confirmed to go
-- about the remove process this form is submitted.
-->
<form name="formForward" method="post" action="../components/emxCommonPartRemovePreProcess.jsp">
<%

    for (Enumeration enumParameterNames = emxGetParameterNames(request); enumParameterNames.hasMoreElements();)
    {
        String strParameterName = (String)enumParameterNames.nextElement();
        if (strParameterName != null)
        {
            // Do not put the hidden field for the emxTableRowId, because it is String[], it will be taken care
            // afterwards.
            if ("emxTableRowId".equals(strParameterName))
            {
                continue;
            }

            String strParameterValue = (String) emxGetParameter(request, strParameterName);
            if (strParameterValue != null)
            {
%>
                <input type="hidden" name="<%=strParameterName%>" value="<xss:encodeForHTMLAttribute><%=strParameterValue%></xss:encodeForHTMLAttribute>" />
<%
            }
        }
    }



    // Now genrating the input fields for the emxTableRowId
    for (int i=0; i < strarChildIds.length; i++)
    {
%>      <input type="hidden" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=strarChildIds[i]%></xss:encodeForHTMLAttribute>" />
<%  }
%>
</form>




<script language="javascript">
    var isToBeContinued = true;
<%
  if (intCountOfPartsThatWillLoseAttributes != 0)
//    if(true)
    {
        String strConfirmationMessagePrefix = EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(sLanguage),"emxMultipleClassification.RemovePart.ConfirmMsgPrefix");
        String strConfirmationMessageSuffix = EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(sLanguage),"emxMultipleClassification.RemovePart.ConfirmMsgSuffix");
%>
        isToBeContinued = window.confirm("<xss:encodeForJavaScript><%=strConfirmationMessagePrefix%> <%=intCountOfPartsThatWillLoseAttributes%> <%=strConfirmationMessageSuffix%></xss:encodeForJavaScript>");
<%
    }
%>
        if (isToBeContinued)
        {
            document.formForward.submit();
        }

</script>

</body>
</html>

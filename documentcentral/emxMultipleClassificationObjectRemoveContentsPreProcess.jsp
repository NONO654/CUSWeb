<%--  emxMultipleClassificationObjectRemoveContentsPreProcess.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] = "$Id: emxMultipleClassificationObjectRemoveContentsPreProcess.jsp.rca 1.2.3.2 Wed Oct 22 16:02:24 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>

<%
    final boolean isSearchAllSublevels  = "All Levels".equalsIgnoreCase( (String)session.getAttribute("LCSearchType") );
    String suiteDir                     = EnoviaResourceBundle.getProperty(context,"eServiceSuiteLibraryCentral.Directory");
    final String LC_STRING_RESOURCE     = "emxLibraryCentralStringResource";

    String strarChildIds[]      = (String[]) emxGetParameterValues(request, "emxTableRowId");
    strarChildIds               = getTableRowIDsArray(strarChildIds);


    String strParentObjectId    = emxGetParameter(request, "objectId");
    Vector vecCurrentAttributes = (Vector)com.matrixone.apps.classification.Classification.findAttributes(context, strParentObjectId);


    int intCountOfPartsThatWillLoseAttributes = 0;
    if(strarChildIds != null && strarChildIds.length > 0) {
        for (int i=0; i<strarChildIds.length; i++) {
            boolean isGoingToLoseAttributes = com.matrixone.apps.classification.Classification.checkIfItLosesAttributeOnRemoval(context,
                                                                             strParentObjectId,
                                                                             vecCurrentAttributes,
                                                                             strarChildIds[i], isSearchAllSublevels);
            if (isGoingToLoseAttributes) {
                intCountOfPartsThatWillLoseAttributes++;
            }
        }
    }


%>

<!--
-- This form stores all the request paramters as hidden form fields. After your is confirmed to go
-- about the remove process this form is submitted.
-->
<body>
<form name="formForward" method="post" action="../<xss:encodeForHTML><%=suiteDir%></xss:encodeForHTML>/emxLibraryCentralObjectPreRemoveContentsProcess.jsp">
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
       <input type="hidden" name="<%=strParameterName%>" value="<xss:encodeForHTMLAttribute><%=strParameterValue%></xss:encodeForHTMLAttribute>"/>
<%
      }
    }
  }

  // Now genrating the input fields for the emxTableRowId
    for (int i=0; i < strarChildIds.length; i++)
    {
%>
        <input type="hidden" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=strarChildIds[i]%></xss:encodeForHTMLAttribute>"/>
<%  
    }
%>
</form>
</body>



<script language="javascript">

    var isToBeContinued = true;
<%
    if (intCountOfPartsThatWillLoseAttributes != 0)
    {
        String strConfirmationMessagePrefix = EnoviaResourceBundle.getProperty(context,LC_STRING_RESOURCE,new Locale(sLanguage),"emxMultipleClassification.RemovePart.ConfirmMsgPrefix");
        String strConfirmationMessageSuffix = EnoviaResourceBundle.getProperty(context,LC_STRING_RESOURCE,new Locale(sLanguage),"emxMultipleClassification.RemovePart.ConfirmMsgSuffix");
%>
        isToBeContinued = window.confirm("<xss:encodeForJavaScript><%=strConfirmationMessagePrefix%></xss:encodeForJavaScript> <xss:encodeForJavaScript><%=intCountOfPartsThatWillLoseAttributes%></xss:encodeForJavaScript> <xss:encodeForJavaScript><%=strConfirmationMessageSuffix%></xss:encodeForJavaScript>");
        
<%
    }
%>
    if (isToBeContinued)
    {
      document.formForward.submit();
    }

</script>

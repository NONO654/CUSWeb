<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "$Id: emxMultipleClassificationAttributeGroupDeleteProcess.jsp.rca 1.2.3.2 Wed Oct 22 16:02:42 2008 przemek Experimental przemek $";
   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>

<%
    String objIds[]         = emxGetParameterValues(request,"emxTableRowId");
    int countClassifiedItems= 0;
    String stdMsg           = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(sLanguage),"emxMultipleClassification.Deleted.Message4");
    AttributeGroup AG       = new AttributeGroup();
    StringBuffer sbErrorMsg = new StringBuffer();
   
    if(objIds != null) {
        String[] agName = getTableRowIDsArray(objIds);
        AG.setName(agName[0]);
    }

    countClassifiedItems = (int) AG.getNumberOfEndItemsWhereUsed(context);

    if (countClassifiedItems >= 1) {
        String message= MessageUtil.getMessage(context,
                null,
                "emxMultipleClassification.Deleted.Message",
                new String[]{Integer.toString(countClassifiedItems)},
                null,
                context.getLocale(),
        "emxLibraryCentralStringResource");
        sbErrorMsg.append(message);

    } else {
        try {
            AG.delete(context);
        } catch(Exception e) {
           sbErrorMsg.append(stdMsg);
        }
    }
%>
<script language=javascript>
    var vErrorMsg   = "<xss:encodeForJavaScript><%=sbErrorMsg.toString().trim()%></xss:encodeForJavaScript>";
    if (vErrorMsg != "") {
        alert(vErrorMsg)
    } else {
          var contentFrame = findFrame(getTopWindow(),"content");
          if(contentFrame.location.href.indexOf("emxIndentedTable.jsp") >= 0){
              contentFrame.refreshSBTable(contentFrame.configuredTableName);
          }
    }
</script>





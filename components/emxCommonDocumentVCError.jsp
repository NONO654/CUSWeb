<%--
   emxCommonDocumentVCError.jsp -- error page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentVCError.jsp.rca 1.2.6.5 Wed Oct 22 16:18:24 2008 przemek Experimental przemek $";
--%>
<%@ page import = "matrix.db.*,matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.domain.* " isErrorPage="true"%>
<%@ page import="com.matrixone.apps.common.util.ComponentsUtil" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
    Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");
    String objectAction= (String)emxCommonDocumentCheckinData.get("objectAction");
    if(emxCommonDocumentCheckinData != null) {
        String objectId = (String)emxCommonDocumentCheckinData.get("objectId");
        boolean bIsVCDoc = false;
        String strErrorMessage = request.getParameter("ErrorMessage");
        if(objectId != null && !"".equals(objectId)) {
            try {
                DomainObject domainObj = DomainObject.newInstance(context);
                domainObj.setId(objectId);
                String isVCDoc = domainObj.getInfo(context, com.matrixone.apps.common.CommonDocument.SELECT_IS_KIND_OF_VC_DOCUMENT);
                if(!objectAction.equalsIgnoreCase(com.matrixone.apps.common.VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER)){
                domainObj.deleteObject(context);
                }
                session.setAttribute("DesignSync.error", "true");
                if ((isVCDoc != null) && (!"".equals(isVCDoc)) && (!"null".equals(isVCDoc))) {
                    bIsVCDoc = true;
                    if(strErrorMessage != null && !"".equals(strErrorMessage)) {
                        session.setAttribute("error.message", strErrorMessage);
                    }
                }
            }catch(Exception e) {
                if(strErrorMessage != null && !"".equals(strErrorMessage)) {
                    session.setAttribute("error.message", strErrorMessage);
                }
            }
        }
        if(bIsVCDoc) {
            if(objectAction.equalsIgnoreCase(com.matrixone.apps.common.VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER)){
%>
            <jsp:forward page="../components/emxCommonDocumentConversionDialogFS.jsp">
                <jsp:param name ="fromAction" value  ="previous" />
            </jsp:forward>
<%
        }
        else{
%>
            <jsp:forward page="../components/emxCommonDocumentCreateDialogFS.jsp">
                <jsp:param name ="fromAction" value  ="previous" />
            </jsp:forward>
<%
            }
        }
    }
    //if null exception object, create one to display
    if ( request.getParameter("ErrorMessage") != null )
    {
      exception = new Exception(request.getParameter("ErrorMessage"));
    }

    if (exception == null) {
       exception = new Exception("\"Exception Unavailable\"");
    }
%>

<jsp:include page = "emxMQLNotice.jsp" flush="true" />

<img src="../common/images/utilSpacer.gif" width="1" height="8" />
<TABLE cellSpacing="0" cellPadding="1" width="95%" border="0" align="center">
  <TBODY>
  <TR>
    <TD>
      <TABLE cellSpacing="0" cellPadding="3" width="100%" border="0">
        <TBODY>
        <TR>
          <Td class=errorHeader><%=XSSUtil.encodeForHTML(context, ComponentsUtil.i18nStringNow("emxComponents.Error.Header",request.getHeader("Accept-Language")))%></TH></TR>
        <TR>
          <TD class=errorMessage><%=XSSUtil.encodeForHTML(context, exception.toString())%></TD>
        </TR>
        </TBODY>
      </TABLE>
    </TD>
   </TR>
  </TBODY>
 </TABLE>

<br/>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

<%
  // remove the error message if it was in the session
  session.removeValue("error.message");
%>


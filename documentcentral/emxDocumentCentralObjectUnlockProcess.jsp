<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<%--  emxDocumentCentralObjectUnlockProcess.jsp   -
    This page is used to Unlock a business object.
    Copyright (c) 1992-2016 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of
    MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

    Description: This page is used to Unlock a business object.
    Parameters : Request Object
                URL:
                Form: FormBean
                AEF Supplied :
    Author     : mallikc
    Date       : 11/22/2002
    History    :

    static const char RCSID[] = "$Id: emxDocumentCentralObjectUnlockProcess.jsp.rca 1.14 Wed Oct 22 16:02:29 2008 przemek Experimental przemek $";
--%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="emxLibraryCentralUtils.inc"%>

<%

    String objectId = emxGetParameter(request, "objectId");

    DomainObject obj = null;

    try
    {
      Document documentVC = (Document)DomainObject.newInstance(context, DomainConstants.TYPE_DOCUMENT);
      documentVC.setId(objectId);
      String vcfileStr = documentVC.getInfo(context, "vcfile");

      if("true".equalsIgnoreCase(vcfileStr)) {
          String cmd           = "mod bus $1 vcconnection unlock";
          MqlUtil.mqlCommand(context, cmd, objectId);
      }else {
        obj = new DomainObject(objectId);

        // invoking unlock method
        obj.unlock(context);
      }
    }
    catch ( Exception e )
    {
        session.setAttribute("error.message",
                    getSystemErrorMessage(e.toString()));
    }

%>
<script language="javascript">//<![CDATA[
<!-- Hide Javascript from non-JavaScript browsers

  //send response to parent getWindowOpener() page

 //parent.window.document.location.reload();
 parent.window.document.location.href=parent.window.document.location.href;

// Stop Hiding here -->//]]>
</script>

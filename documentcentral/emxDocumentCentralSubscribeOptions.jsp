<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<%--  emxTeamSubscribeWorkspaceOptions.jsp

    Copyright (c) 1992-2016 Dassault Systemes.
    All Rights Reserved  This program contains proprietary and trade secret
    information of  MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

    Description: Process page perform the subscription addition/removal.
    Parameters : chkSubscribeEvent
                 objectId
                 sUnsubscribedEventIds
                 callPage
                 objectIdString

    Author     : Neaz Faiyaz
    Date       : 04/02/2003
    History    :

    static const char RCSID[] = "$Id: emxDocumentCentralSubscribeOptions.jsp.rca 1.13 Wed Oct 22 16:02:19 2008 przemek Experimental przemek $";
--%>

<%@ include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import="java.util.Vector" %>

<jsp:useBean id="subBean" scope="page" class="com.matrixone.apps.library.SubscriptionBean"/>

<%
    // Read the parameters
    String arrSubEvtStr[] = emxGetParameterValues(request, "chkSubscribeEvent");
    String parentId       = emxGetParameter(request, "objectId");
    String strUnSubEvtIds = emxGetParameter(request, "sUnsubscribedEventIds");
    String callPage       = emxGetParameter(request, "callPage");
    String objectIdString = emxGetParameter(request, "objectIdString");
    String targetLocation = emxGetParameter(request,"targetLocation");

    // If Remove selected is called from the Subscription table
    if(callPage!=null && callPage.equalsIgnoreCase("subscriptionTable"))
    {
      subBean.processUnSubscribeEvents(context,strUnSubEvtIds);
    }
    else
    {
      // Process unsubscribe events
      if(!strUnSubEvtIds.equals(""))
      {
        subBean.processUnSubscribeEvents(context, strUnSubEvtIds);
      }

      if(arrSubEvtStr != null)
      {
        StringTokenizer st   = new StringTokenizer(objectIdString,";");

        // ...
        while(st.hasMoreTokens())
        {
          String objectId   = st.nextToken();

          TreeMap hashSubEvt =
                          subBean.getAllObjectEvents(context,objectId);

          Vector vctSubEvtStr = new Vector() ;

          for(int i = 0; i < arrSubEvtStr.length; i++ )
          {
            if(!hashSubEvt.containsKey(arrSubEvtStr[i]))
            {
                vctSubEvtStr.addElement(arrSubEvtStr[i]);
            }
          }

          // bean call to process subscription addition/delete.
          subBean.processSubscribeEvents(context, objectId, vctSubEvtStr);
        }
      }
    }

%>

<html>
<body>
<script language="javascript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript">
 if("<%=XSSUtil.encodeForJavaScript(context,callPage)%>"=="subscriptionTable")
 {
   getTopWindow().refreshTablePage();
 }
 else
 {

   if("slidein" == "<%=XSSUtil.encodeForJavaScript(context,targetLocation)%>")
   {
        topWindow   = findFrame(getTopWindow(),"detailsDisplay");
        if(!topWindow) {
            topWindow = findFrame(getTopWindow(),"content");
        }
        topWindow.document.location.href = topWindow.document.location.href;
        getTopWindow().closeSlideInDialog();
   }
   else
   {
       if(getTopWindow().getWindowOpener().getTopWindow().modalDialog)
       {
            getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
       }
       parent.window.getWindowOpener().document.location.href =  parent.window.getWindowOpener().document.location.href;
       parent.closeWindow();
    }
 }
</script>

</body>
</html>


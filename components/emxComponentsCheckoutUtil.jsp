<%-- emxComponentsCheckoutUtil.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsCheckoutUtil.jsp.rca 1.7 Wed Oct 22 16:18:24 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
  <script language="javascript" src="../emxUIPageUtility.js"></script>
<script language="javascript">
function callCheckout(objectId, action, fileName, format, refresh, closeWindow, appName, appDir)
{
    document.commonDocumentCheckout.objectId.value = objectId;
    document.commonDocumentCheckout.fileName.value = fileName;
    document.commonDocumentCheckout.format.value = format;
    document.commonDocumentCheckout.action.value = action;
    document.commonDocumentCheckout.refresh.value = refresh;
    document.commonDocumentCheckout.closeWindow.value = closeWindow;
    document.commonDocumentCheckout.appDir.value = appDir;
    document.commonDocumentCheckout.appName.value = appName;
    var intWidth = "730";
    var intHeight = "450";
    var strFeatures = "width=" + intWidth + ",height=" + intHeight;
    var intLeft = parseInt((screen.width - intWidth) / 2);
    var intTop = parseInt((screen.height - intHeight) / 2);
    if (isIE_M) {
            strFeatures += ",left=" + intLeft + ",top=" + intTop;
    } else{
            strFeatures += ",screenX=" + intLeft + ",screenY=" + intTop;
    }
    if (isNS4_M) {
            strFeatures += ",resizable=no";
    } else {
            strFeatures += ",resizable=yes";
    }

    var strFeatures = "width=730,height=450,dependent=yes,resizable=yes,toolbar=yes";
    var win = window.open('', "CheckoutWin", strFeatures);
    document.commonDocumentCheckout.target="CheckoutWin";
    document.commonDocumentCheckout.submit();

}

function viewer(url) {
      window.open(url,"FileViewer","location=no,menubar=no,titlebar=no,width=700,height=600,resizable=yes,scrollbars=yes");
      return;
}

</script>

<form name="commonDocumentCheckout" method="post" action="../components/emxComponentsCheckout.jsp">
  <table>
    <input type="hidden" name="objectId" value="" />
    <input type="hidden" name="action" value="" />
    <input type="hidden" name="format" value="" />
    <input type="hidden" name="fileName" value="" />
    <input type="hidden" name="appName" value="" />
    <input type="hidden" name="appDir" value="" />
    <input type="hidden" name="closeWindow" value="" />
    <input type="hidden" name="refresh" value="" />
  </table>
</form>

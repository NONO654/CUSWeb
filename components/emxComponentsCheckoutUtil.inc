<%-- emxComponentsCheckoutUtil.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsCheckoutUtil.inc.rca 1.9 Wed Oct 22 16:17:43 2008 przemek Experimental przemek $"
--%>
<script language="javascript">
function callCheckout(objectId, action, fileName, format, refresh, closeWindow, appName, appDir)
{
    document.componentCheckout.objectId.value = objectId;
    document.componentCheckout.fileName.value = fileName;
    document.componentCheckout.format.value = format;
    document.componentCheckout.action.value = action;
    document.componentCheckout.refresh.value = refresh;
    document.componentCheckout.closeWindow.value = closeWindow;
    document.componentCheckout.appDir.value = appDir;
    document.componentCheckout.appName.value = appName;
    var strFeatures = "width=450,height=350,dependent=yes,resizable=yes,toolbar=yes";
    var win = window.open('', "CheckoutWin", strFeatures);
    document.componentCheckout.target="CheckoutWin";
    document.componentCheckout.submit();

}
</script>

<form name="componentCheckout" method="post" action="../components/emxComponentsCheckout.jsp">
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

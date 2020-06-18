<%-- emxCommonDocumentCheckoutUtil.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckoutUtil.jsp.rca 1.10 Tue Oct 28 23:01:05 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
  <script language="javascript" src="../emxUIPageUtility.js"></script>
<script language="javascript">
function callCheckout(objectId, action, fileName, format, refresh, closeWindow, appName, appDir, partId, version,SB)
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
    // Code added for the Bug 295197 Dt 8/11/2005
    var today=new Date();
    var suffix=today.getTime();
    var strFeatures = "";
    var winName = "_self";
    var win = "";

    if(SB == null && "view" == action)
    {
        //modified for Bug no : 317605. Dt 03/04/2006. Added scrollbars=yes
        strFeatures = "width=730,height=450,dependent=yes,resizable=yes,toolbar=yes,scrollbars=yes";
        winName="CheckoutWin"+suffix;
        // Till Here
        win = window.open('', winName, strFeatures);
    }
    document.commonDocumentCheckout.trackUsagePartId.value = partId;
    document.commonDocumentCheckout.version.value = version;
    if("view" == action)
    {
        document.commonDocumentCheckout.target=winName;
    } else {
        document.commonDocumentCheckout.target = "hiddenFrame";
    }
    document.commonDocumentCheckout.submit();

}
</script>

<form name="commonDocumentCheckout" method="post" action="../components/emxCommonDocumentPreCheckout.jsp">
  <table>
    <input type="hidden" name="objectId" value="" />
    <input type="hidden" name="action" value="" />
    <input type="hidden" name="format" value="" />
    <input type="hidden" name="fileName" value="" />
    <input type="hidden" name="appName" value="" />
    <input type="hidden" name="appDir" value="" />
    <input type="hidden" name="closeWindow" value="" />
    <input type="hidden" name="refresh" value="" />
    <input type="hidden" name="trackUsagePartId" value="" />
    <input type="hidden" name="version" value="" />


  </table>
</form>

<script language="javascript">

function callViewer(objectId, action, fileName, format, viewerURL, partId, version)
{
    document.commonDocumentViewer.objectId.value = objectId;
    document.commonDocumentViewer.id.value = objectId;
    document.commonDocumentViewer.fileName.value = fileName;
    document.commonDocumentViewer.file.value = fileName;
    document.commonDocumentViewer.format.value = format;
    document.commonDocumentViewer.fileAction.value = action;
    document.commonDocumentViewer.action = viewerURL;
    document.commonDocumentViewer.trackUsagePartId.value = partId;
    document.commonDocumentViewer.version.value = version;

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

  //modified for Bug no : 317605. Dt 03/04/2006. Added scrollbars=yes
    var strFeatures = "width=730,height=450,dependent=yes,resizable=yes,toolbar=yes,scrollbars=yes";
    var win = window.open('', "CheckoutWin", strFeatures);
    document.commonDocumentViewer.target="CheckoutWin";
    document.commonDocumentViewer.submit();

}

</script>

<form name="commonDocumentViewer" method="post" action="../components/emxCommonDocumentPreCheckout.jsp">
  <table>
    <input type="hidden" name="objectId" value="" />
    <input type="hidden" name="id" value="" />
    <input type="hidden" name="fileAction" value="view" />
    <input type="hidden" name="format" value="" />
    <input type="hidden" name="fileName" value="" />
    <input type="hidden" name="file" value="" />
    <input type="hidden" name="trackUsagePartId" value="" />
    <input type="hidden" name="version" value="" />
  </table>
</form>

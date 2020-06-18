
<html>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<head>
<title></title>
<%@include file = "../emxStyleDefaultInclude.inc"%> 
<%@include file = "../emxStyleDialogInclude.inc"%> 
    
<script language="javascript">

function doDone() 
{
  if (top.syncDisplayFrame.document.frmSync == null)
    top.close();
  else
  {
 	turnOnProgress();
    top.syncDisplayFrame.document.frmSync.target="_top";
    top.syncDisplayFrame.document.frmSync.submit();
          
  }
}
        
function doCancel() 
{
  top.close();
}
</script>
</head>

<body>
<table border="0" width="100%">
    <tr>
    <td align="right">
      <table border="0">
        <tr>
          <td><a href="javascript:doDone()"><img src="images/buttonDialogDone.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Button.Submit</emxUtil:i18n>"></a></td><td><a href="javascript:doDone()"><emxUtil:i18n localize="i18nId">emxFramework.Button.Submit</emxUtil:i18n></a></td>
          <td>&nbsp;&nbsp;</td>
          <td><a href="javascript:doCancel()"><img src="images/buttonDialogCancel.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n>"></a></td><td><a href="javascript:doCancel()"><emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n></a></td>
        </tr>
      </table>
    </td>
    </tr>
</table>
</body>
</html>



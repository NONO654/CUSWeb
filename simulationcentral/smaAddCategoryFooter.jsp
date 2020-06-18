<%-- smaShowRelated.jsp

   Copyright (c) 1999-2007 MatrixOne, Inc.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%
    String objectId = emxGetParameter(request,"objectId");
%>

<head>
<title>Select Categories</title>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" language="javascript" >
    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIDialog");
</script>

<body>
<form name="addCategoryFooter" method="post" onsubmit="doAdd(); return false">
      <table width="100%" border="0" margin="0" align="center" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right">
            <table border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td>&nbsp;&nbsp;</td>
                <td><a class="footericon" href="javascript:doAdd()"><img border="0" " src="../common/images/buttonDialogDone.gif"></a></td>
                <td nowrap>&nbsp;<button class="default button" type="button" onclick="doAdd()"><emxUtil:i18n localize="i18nId">emxFramework.Common.Done</emxUtil:i18n></button></td>
                <td>&nbsp;&nbsp;</td>
                <td><a class="footericon" href="javascript:getTopWindow().closeSlideInDialog()"><img border="0" src="../common/images/buttonDialogCancel.gif"></a></td>
                <td nowrap>&nbsp;<button class="default button" type="button" onclick="getTopWindow().closeSlideInDialog()"><emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n></button></td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
      </form>

    <script language="javascript">
        function doAdd()
        {
            var frame = findFrame(parent,"AddCatBody");
            
            var elems = frame.document.forms["addCategoryForm"].elements;
            var params = "";
            for ( var ii=0; ii<elems.length; ii++ )
            {
                if ( elems[ii].checked )
                   params += elems[ii].id + ",";
            }
 
            if ( params.length > 0 )
            {
                var contentURL = "../simulationcentral/smaAddCategoryProcess.jsp";
                contentURL += "?objectId=" + "<%=objectId %>";
                contentURL += "&categories=" + params;

                objForm = document.forms["addCategoryFooter"];
                objForm.target = "listHidden";
                objForm.action = contentURL;
                objForm.submit();
            } 
            getTopWindow().closeSlideInDialog();
        }
    </script>
</body>


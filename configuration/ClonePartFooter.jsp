<%--
  emxProductCentralProductVariantUtil.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

 <script type="text/javascript">
        addStyleSheet("emxUIDefault");
        addStyleSheet("emxUIDialog");
</script>

</head>

<body class="foot dialog">

    <form action="SelectFeature" method="post" name="bottomCommonForm">
      <table>
              <tr>
              <td class="buttons">
                    <a href="javascript:parent.frames[0].movePrevious()"><img border="0" alt=<%=i18nNow.getI18nString("emxProduct.Button.Previous", bundle,acceptLanguage)%> src="../common/images/buttonDialogPrevious.gif"></a>
               
                    <a href="javascript:parent.frames[0].movePrevious()" class="button">
                    <emxUtil:i18n localize="i18nId">
                    emxProduct.Button.Previous
                    </emxUtil:i18n></a>
               <a href="javascript:parent.frames['pagecontentBody'].moveNext()"><img border="0" alt=<%=i18nNow.getI18nString("emxProduct.Button.Next", bundle,acceptLanguage)%> src="../common/images/buttonDialogNext.gif"></a>
                
                    <a href="javascript:parent.frames['pagecontentBody'].moveNext()" class="button">
                    <emxUtil:i18n localize="i18nId">emxProduct.Button.Next
                    </emxUtil:i18n></a>
                
                
                <a href="javascript:parent.frames[0].closeWindow()"><img border="0" alt=<%=i18nNow.getI18nString("emxProduct.Button.Cancel", bundle,acceptLanguage)%> src="../common/images/buttonDialogCancel.gif"></a>
                
                    <a class="button" href="javascript:parent.frames[0].closeWindow()">
                    <emxUtil:i18n localize="i18nId">emxProduct.Button.Cancel
                    </emxUtil:i18n></a>
                 
                 
          </td>
        </tr>
      </table>
 </form>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

 <%@include file = "../emxUICommonEndOfPageInclude.inc"%> 


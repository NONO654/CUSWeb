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
<%
  String strMode = emxGetParameter(request, "mode");
%>
 <script type="text/javascript">
        addStyleSheet("emxUIDefault");
        addStyleSheet("emxUIDialog");
</script>
<body class="foot dialog">


    <form action="SelectFeature" method="post">
    <div id="divPageFoot">
<div id="divDialogButtons">
    
       <table>
              <tr>
              <td class="functions"></td>
              <td class="buttons">
              <table>
<tbody>
<tr>

<%if (!(strMode.equalsIgnoreCase("edit"))&&!(strMode.equalsIgnoreCase("viewEdit"))){%>
               
               <td>
                    <a class="footericon" href="javascript:parent.frames[1].movePrevious()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxProduct.Button.Previous</emxUtil:i18n>" src="../common/images/buttonDialogPrevious.gif"></a>
                </td>
                <td>
                    <a href="#" class="button"><button class="btn-primary" type="button" onClick="javascript:parent.frames[1].movePrevious()">
                    <emxUtil:i18n localize="i18nId">emxProduct.Button.Previous</emxUtil:i18n></button>
                    </a>
                    </td>
               
<%}%>
        <% if((strMode.equals("viewEdit"))) {
        %>
                <td>
                    <a class="footericon" href="javascript:parent.frames[0].doApply()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxProduct.Button.Apply</emxUtil:i18n>" src="../common/images/buttonDialogApply.gif" /></a>
               </td>
                <td>
                    <a href="#" class="button"><button class="btn-primary" type="button" onClick="javascript:parent.frames[0].doApply()">
                    <emxUtil:i18n localize="i18nId">emxProduct.Button.Apply</emxUtil:i18n></button>
                    </a>
                    </td>
               
              <%}%>                  
              <td>                 
                <a class="footericon" href="javascript:parent.frames[1].submit()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxProduct.Button.Done</emxUtil:i18n>" src="../common/images/buttonDialogDone.gif"></a>
                </td>
                <td>
                    <a href="#" class="button"><button class="btn-default" type="button" onClick="javascript:parent.frames[1].submit()">
                    <emxUtil:i18n localize="i18nId">emxProduct.Button.Done</emxUtil:i18n></button>
                    </a>
             </td>
             <td>
                
                
                <a class="footericon" href="javascript:parent.frames[1].closeWindow()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxProduct.Button.Cancel</emxUtil:i18n>" src="../common/images/buttonDialogCancel.gif"></a>
                </td>
                <td>
                    <a class="button" href="#"><button class="btn-default" type="button" onClick="javascript:parent.frames[1].closeWindow()">
                    <emxUtil:i18n localize="i18nId">emxProduct.Button.Cancel</emxUtil:i18n></button>
                    </a>
               </td>                    
                 </tr>
</tbody>
</table>
              </td>
              </tr>
            </table>
            </div>
            </div>
 </form>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
 <%@include file = "../emxUICommonEndOfPageInclude.inc"%> 


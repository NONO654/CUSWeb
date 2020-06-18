<%-- DesignEffectivityFooter.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
	String strPRCFSParam2 = emxGetParameter(request, "PRCFSParam2");	
%>
	<script type="text/javascript">
		addStyleSheet("emxUIDefault");
		addStyleSheet("emxUIDialog");
	</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
    <form action="" method="post">
      <table width="100%" border="0" align="center" cellspacing="0" cellpadding="0">
        <tr><td colspan=2>&nbsp;</td></tr>
		<tr><td>&nbsp;</td>
          <td align="right" valign=bottom>
            <table border="0" cellspacing="0" cellpadding="0">
              <tr>
				
                <td>&nbsp;&nbsp;</td>
                <td><a href="javascript:parent.frames[1].submit()"><img border="0" alt="Done" src="../emxUIButtonDone.gif"></a></td>
                <td nowrap>&nbsp;
					<a href="javascript:parent.frames[1].submit()" class="button">
					<emxUtil:i18n localize="i18nId">emxCommonButton.Done
					</emxUtil:i18n></a>
				</td>
                <td>&nbsp;&nbsp;</td>
                <td><a href="javascript:parent.frames[1].closeWindow()"><img border="0" alt="Cancel" src="../emxUIButtonCancel.gif"></a></td>
                <td nowrap>&nbsp;
					<a class="button" href="javascript:parent.frames[1].closeWindow()">
					<emxUtil:i18n localize="i18nId">emxCommonButton.Cancel
					</emxUtil:i18n></a>
				</td>

              </tr>
            </table>
          </td>
        </tr>
      </table>
    </form>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

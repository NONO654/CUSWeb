<%-- ProductConfigurationFooter.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
	String strPRCFSParam2 = emxGetParameter(request, "PRCFSParam2");	
%>
  <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>         
	<script type="text/javascript">
		addStyleSheet("emxUIDefault");
		addStyleSheet("emxUIDialog");
	</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<html>
 <body class="foot dialog">
    <form action="" method="post" name="bottomCommonForm">
    <div id="divPageFoot">
      <table>
              <tr>
                <td class="buttons">
                <table>
                <tr>
             <% if (strPRCFSParam2.equals("createNew"))
				{
				%>
               
                    <td><a href="javascript:parent.frames[1].movePrevious()"><img border="0" alt="Previous" src="../common/images/buttonDialogPrevious.gif"></a></td>
               
                    <td><a href="javascript:parent.frames[1].movePrevious()" class="button">
					<emxUtil:i18n localize="i18nId">
					emxProduct.Button.Previous
                    </emxUtil:i18n></a></td>
				<%
				}
				%>
				
				<%
					if (strPRCFSParam2.equals("createNew") || strPRCFSParam2.equals("edit"))
					{
				%>
				
                <td><a href="javascript:parent.frames[1].submit()"><img border="0" alt="Done" src="../common/images/buttonDialogDone.gif"></a></td>
                <td><a href="javascript:parent.frames[1].submit()" class="button">
					<emxUtil:i18n localize="i18nId">emxProduct.Button.Done
                    </emxUtil:i18n></a> </td>
                <td><a href="javascript:parent.frames[1].closeWindow()"><img border="0" alt="Cancel" src="../common/images/buttonDialogCancel.gif"></a></td>
                <td><a class="button" href="javascript:parent.frames[1].closeWindow()">
					<emxUtil:i18n localize="i18nId">emxProduct.Button.Cancel
                    </emxUtil:i18n></a></td>
				<%
					}
				%>
				
				<%
					if (strPRCFSParam2.equals("view"))
					{
				%>    
                  <td><a href="javascript:parent.frames[1].closeWindow()"><img border="0" alt="Done" src="../common/images/buttonDialogDone.gif"></a></td>
                  <td><a href="javascript:parent.frames[1].closeWindow()" class="button">
						<emxUtil:i18n localize="i18nId">
							emxProduct.Button.Done
                        </emxUtil:i18n></a></td>
				<%	
                    }%>
				
              </tr>
            </table>
          </td>
				
        </tr>
      </table>
         </div>
    </form>
    </body>

    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
        </html>

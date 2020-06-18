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


<body class="foot dialog">
    <form action="" method="post" name="bottomCommonForm">
        <div id="divPageFoot">
        <div id="divDialogButtons">
    
        <table>
              <tr>
                  <td class="functions"></td>
                  <td class="buttons">
                  <table>
                      <tbody>
                      <tr>
<%
                      //Objectid is null during the Product Configuration Creation and not Null during edit operation
    		          if (strPRCFSParam2.equals("createNewProductRevision")) {
%>
                          <td>
					          <a class="footericon" href="javascript:parent.frames[1].movePrevious()">
					              <img border="0" alt=<emxUtil:i18n localize="i18nId">emxCommonButton.Previous</emxUtil:i18n> src="../common/images/buttonDialogPrevious.gif"></a>
	 			          </td>
				          <td>
					          <a href="#" class="button"><button class="btn-primary" type="button" onClick="javascript:parent.frames[1].movePrevious()">
					              <emxUtil:i18n localize="i18nId">emxCommonButton.Previous</emxUtil:i18n></button></a>
				          </td>	
<%
                      }
                      if (strPRCFSParam2.equals("createNewProductRevision")|| strPRCFSParam2.equals("edit")) {
%>
                          <td>
                              <a class="footericon" href="javascript:parent.frames[1].submit()">
                                  <img border="0" alt=<emxUtil:i18n localize="i18nId">emxCommonButton.Done</emxUtil:i18n> src="../common/images/buttonDialogDone.gif"></a>
                          </td>
                          <td>
                              <a href="#" class="button"><button class="btn-primary" type="button" onClick="javascript:parent.frames[1].submit()">
					              <emxUtil:i18n localize="i18nId">emxCommonButton.Done</emxUtil:i18n></button></a>
                          </td>
					      <td>
                              <a class="footericon" href="javascript:parent.frames[1].closeWindow()">
                                  <img border="0" alt=<emxUtil:i18n localize="i18nId">emxCommonButton.Cancel</emxUtil:i18n> src="../common/images/buttonDialogCancel.gif"></a>
                          </td>
                          <td>
                              <a class="button" href="#"><button class="btn-default" type="button" onClick="javascript:parent.frames[1].closeWindow()">
                                  <emxUtil:i18n localize="i18nId">emxCommonButton.Cancel</emxUtil:i18n></button></a>
                          </td>
<%
                      }
 					  if (strPRCFSParam2.equals("view")) {
%>    
                          <td>
	                          <a class="footericon" href="javascript:parent.frames[2].closeWindow()">
	                              <img border="0" alt=<emxUtil:i18n localize="i18nId">emxCommonButton.Done</emxUtil:i18n> src="../common/images/buttonDialogDone.gif"></a>
                          </td>
                          <td>
                              <a href="#" class="button"><button class="btn-default" type="button" onClick="javascript:parent.frames[2].closeWindow()">
                                  <emxUtil:i18n localize="i18nId">emxCommonButton.Done</emxUtil:i18n></button></a>
                          </td>
<%
                      }
%>
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


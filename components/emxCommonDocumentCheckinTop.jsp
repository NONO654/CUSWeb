<%-- emxCommonDocumentCheckinTop.inc - used for Checkin of file into Document Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckinTop.jsp.rca 1.11 Wed Oct 22 16:17:42 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%
  request.setAttribute("contentPageIsDialog", "true");
%>
<%@include file = "emxComponentsCheckin.inc"%>
  <script language="JavaScript">
    function removeFiles()
    {
      parent.frames[1].getApplet().removeSelectedFiles();
      return;
    }

    var isShow = true;

    function showAdvanced()
    {
      parent.frames[1].getApplet().setTopPanelVisible(isShow);
      if(isShow)
      {
        isShow = false;
      }
      else
      {
        isShow = true;      
      }
      return;
    }
    
  function browseFiles() {
    parent.frames[1].getApplet().doFileChooser();
    return;
  }

  </script>
  <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
<%
    String sHelpMarker = "emxhelpfileuploadwithapplet";

    // Getting the display name for the page.
    Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");

    String heading = (String) emxCommonDocumentCheckinData.get("header");
    String toolbarName = "";
    
    if ( heading == null || "".equals(heading) || "null".equals(heading) )
    {
        String objectAction = (String)emxCommonDocumentCheckinData.get("objectAction");
        if ( CommonDocument.OBJECT_ACTION_CREATE_MASTER.equalsIgnoreCase(objectAction) )
        {
            heading = "emxComponents.CommonDocument.Step2UploadFiles";
            toolbarName = "APPFileUploadAppletToolBar";
        } else if ( CommonDocument.OBJECT_ACTION_UPDATE_MASTER.equalsIgnoreCase(objectAction) ) {
            heading = "emxComponents.CommonDocument.UpdateFiles";
            toolbarName = "APPFileUpdateAppletToolbar";
        } else if ( CommonDocument.OBJECT_ACTION_CREATE_MASTER_PER_FILE.equalsIgnoreCase(objectAction) ) {
            heading = "emxComponents.CommonDocument.UploadFilesToIndividualDocuments";
            toolbarName = "APPFileUploadAppletToolBar";
        } else if ( CommonDocument.OBJECT_ACTION_CHECKIN_WITH_VERSION.equalsIgnoreCase(objectAction) ) {
            heading = "emxComponents.CommonDocument.CheckinFiles";
            toolbarName = "APPFileUploadAppletToolBar";
        } else if (CommonDocument.OBJECT_ACTION_UPDATE_HOLDER.equalsIgnoreCase(objectAction) ) {
            heading = "emxComponents.Common.UpdateDocuments";
            toolbarName = "APPFileUploadAppletToolBar";
        } else {
            heading = "emxComponents.Common.CheckinDocuments";
            toolbarName = "APPFileUploadAppletToolBar";
        }
    }


    String PageHeading = ComponentsUtil.i18nStringNow(heading,request.getHeader("Accept-Language"));
    
   
%>
<div id="pageHeadDiv">
	<form>
				
		<table>
   		 <tr>
      		<td class="page-title"><h2 id="ph"><%=XSSUtil.encodeForHTML(context, PageHeading)%></h2></td>      		
    	</tr>
		</table>			
		<!--//XSSOK-->
		<jsp:include page = "../common/emxToolbar.jsp" flush="true"><jsp:param name="toolbar" value="<%=toolbarName%>"/><jsp:param name="suiteKey" value="Components"/><jsp:param name="PrinterFriendly" value="false"/><jsp:param name="helpMarker" value="<%=sHelpMarker%>"/><jsp:param name="export" value="false"/></jsp:include>

	</form>							
</div>


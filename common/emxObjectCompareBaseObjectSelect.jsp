<%--  emxObjectCompareAttributeSelect.jsp
        Copyright (c) 1992-2018 Dassault Systemes.
        All Rights Reserved.   
        This program contains proprietary and trade secret information of MatrixOne,Inc.
        Copyright notice is precautionary only   and does not evidence any actual or intended publication of such program
        static const char RCSID[] = $Id: emxObjectCompareBaseObjectSelect.jsp.rca 1.5 Wed Oct 22 15:48:02 2008 przemek Experimental przemek $
--%>

<jsp:useBean id="compare" class="com.matrixone.apps.domain.util.ObjectCompare" scope="session"/>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%
      framesetObject fs = new framesetObject();
      fs.setDirectory(appDirectory);

      // ----------------- Do Not Edit Above ------------------------------
       String previousPage=emxGetParameter(request,"previous");

      // Specify URL to come in middle of frameset
      StringBuffer contentURL = new StringBuffer("emxObjectCompareBaseObjectSelectBody.jsp");
       if (previousPage != null && previousPage.equals("true"))
       {
         contentURL.append("?previous=true");
       }

      String finalURL=contentURL.toString();
      finalURL=FrameworkUtil.encodeHref(request,finalURL);

      // Page Heading - Internationalized
      String PageHeading = "emxFramework.ObjectCompare.SelectBaseObject";

      String HelpMarker = "emxhelpobjectcomparison";

      //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
      fs.initFrameset(PageHeading,
                      HelpMarker,
                      finalURL,
                      false,
                      true,
                      false,
                      false);

      fs.removeDialogWarning();
      fs.setStringResourceFile("emxFrameworkStringResource");

      String roleList = "role_GlobalUser";


      fs.createFooterLink("emxFramework.Button.Next",
                          "submit()",
                          roleList,
                          false,
                          true,
                          "common/images/buttonDialogNext.gif",
                          0);


      fs.createFooterLink("emxFramework.Button.Cancel",
                          "parent.window.closeWindow()",
                          roleList,
                          false,
                          true,
                          "common/images/buttonDialogCancel.gif",
                          0);


      // ----------------- Do Not Edit Below ------------------------------

      fs.writePage(out);

%>

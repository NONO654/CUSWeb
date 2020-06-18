<%--  emxObjectCompareAttributeSelect.jsp  
      Copyright (c) 1992-2018 Dassault Systemes.
      All Rights Reserved. 
      This program contains proprietary and trade secret information of MatrixOne,Inc.
      Copyright notice is precautionary only   and does not evidence any actual or intended publication of such program  

    static const char RCSID[] = $Id: emxObjectCompareAttributeSelect.jsp.rca 1.5 Wed Oct 22 15:48:40 2008 przemek Experimental przemek $
--%>

<jsp:useBean id="compare" class="com.matrixone.apps.domain.util.ObjectCompare" scope="session"/>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
    framesetObject fs = new framesetObject();

    fs.setDirectory(appDirectory);

    // ----------------- Do Not Edit Above ------------------------------
    try
    {
        String obj=emxGetParameter(request,"baseCompId");
        String previousPage=emxGetParameter(request,"previous");
        // Specify URL to come in middle of frameset
        StringBuffer contentURL = new StringBuffer("emxObjectCompareAttributeSelectBody.jsp");

        // logic for handling previous button.
        if (previousPage != null && !previousPage.equals("null") && previousPage.equals("true"))
        {
           contentURL.append("?previous=true");
        }
        else if (obj != null)
        {
           // setting Base Object ID.
           compare.setBaseObjectID(context,obj);
        }

        String finalURL=contentURL.toString();
        finalURL=FrameworkUtil.encodeHref(request,finalURL);

        // Page Heading - Internationalized
        String PageHeading = "emxFramework.ObjectCompare.SelectAttribute";

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
        fs.createFooterLink("emxFramework.Button.Previous",
                          "goBack()",
                          roleList,
                          false,
                          true,
                          "common/images/buttonDialogPrevious.gif",
                          0);

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

        fs.writePage(out);

    }
    catch (Exception ex)
    { 
       if (ex != null &&  ex.toString().trim().equals("'business object' does not exist"))
       {
%>

              <script language = "javascript">
                     alert("<emxUtil:i18nScript localize="i18nId">emxFramework.ObjectCompare.ObjectsDeleted</emxUtil:i18nScript>");
                     parent.window.closeWindow();
               </script>

<%
       }
       else if (ex.toString()!=null && ex.toString().length()>0) 
       {
            emxNavErrorObject.addMessage(ex.toString());
       } 
    }
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc" %>

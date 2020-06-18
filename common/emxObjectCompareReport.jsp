<%--  emxObjectCompareReport.jsp  
      Copyright (c) 1992-2018 Dassault Systemes.
      All Rights Reserved. 
      This program contains proprietary and trade secret information of MatrixOne,Inc.
      Copyright notice is precautionary only   and does not evidence any actual or intended publication of such program  
 
    static const char RCSID[] = $Id: emxObjectCompareReport.jsp.rca 1.8 Wed Oct 22 15:48:28 2008 przemek Experimental przemek $
--%>

<jsp:useBean id="compare" class="com.matrixone.apps.domain.util.ObjectCompare" scope="session"/>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
    //String acceptLanguage=request.getHeader("Accept-Language");
     if (!compare.isObjectsComparable(context))
    {
        String mainMsg = UINavigatorUtil.getI18nString("emxFramework.Common.NoTreeDisplayMsg1","emxFrameworkStringResource",acceptLanguage);
        String msg1 = UINavigatorUtil.getI18nString("emxFramework.Common.NoTreeDisplayMsg2","emxFrameworkStringResource",acceptLanguage);
        String msg2 = UINavigatorUtil.getI18nString("emxFramework.Common.NoTreeDisplayMsg3","emxFrameworkStringResource",acceptLanguage);
        String msg3 = UINavigatorUtil.getI18nString("emxFramework.Common.NoTreeDisplayMsg4","emxFrameworkStringResource",acceptLanguage);
        mainMsg = mainMsg + "\\n" + msg1 + "\\n" + msg2 + "\\n" + msg3;
%>
        <script language = "javascript">
               //XSSOK
               alert("<%=mainMsg%>");
               parent.window.closeWindow();
         </script>
<%
    }
    framesetObject fs = new framesetObject();
    fs.setDirectory(appDirectory);

     // ----------------- Do Not Edit Above ------------------------------
    
    try
    {
       String attributes[] =emxGetParameterValues(request,"attrItem");
       String basics[] =emxGetParameterValues(request,"basicItem");
       String pivot=emxGetParameter(request,"pivot");
       String objectView=emxGetParameter(request,"objectview");

       if(attributes==null)
       {
            attributes = new String[]{};
       }

       if(basics==null)
       {
            basics = new String[]{};
       }

       if (pivot == null || "null".equals(pivot) || pivot.length() < 0 )
       {
            //setting the attributes selected for comparison
            compare.setSelectedAttributes(context,attributes,basics);
            if (objectView != null && !"null".equals(objectView) && "default".equals(objectView))
            {
                compare.pivot=false;
            }
            else if (objectView != null && !"null".equals(objectView) && "pivot".equals(objectView))
            {
                compare.pivot=true;
            }
       }
       else if ("true".equals(pivot))
       {
           compare.pivot=true;
       }
       else if ("false".equals(pivot))
       {
           compare.pivot=false;
       }


      // Specify URL to come in middle of frameset
      StringBuffer contentURL = new StringBuffer("emxObjectCompareReportBody.jsp");
      String finalURL=contentURL.toString();

      finalURL=FrameworkUtil.encodeHref(request,finalURL);

      String PageHeading = "emxFramework.ObjectCompare.Report";
      String HelpMarker = "emxhelpobjectcomparison";
      fs.setStringResourceFile("emxFrameworkStringResource");

      fs.enableSpreadSheetPage();
      fs.removeDialogWarning();

      //for displaying subheading
      String baseObjectId=compare.getBaseObjectID();
      BusinessObject bo=new BusinessObject(baseObjectId);
      bo.open(context);
      fs.setObjectId(baseObjectId);
      bo.close(context);

      //(String pageHeading, String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
      fs.initFrameset(PageHeading,HelpMarker,finalURL,true,true,false,false,0,"emxFramework.ObjectCompare.ReportsubHead");

      String roleList = "role_GlobalUser";

      fs.setToolbar("ObjectComparePivotToolBar");

      fs.createCommonLink("emxFramework.Button.Previous",
                        "goBack()",
                        roleList,
                        false,
                        true,
                        "common/images/buttonDialogPrevious.gif",
                        false,
                        0);

      fs.createCommonLink("emxFramework.Common.Done",
                        "parent.window.closeWindow()",
                        roleList,
                        false,
                        true,
                        "common/images/buttonDialogDone.gif",
                        false,
                        0);


      // ----------------- Do Not Edit Below ------------------------------

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
          else if (ex != null && ex.toString().length() > 0)
          {
                emxNavErrorObject.addMessage(ex.toString());
          } 
       }
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc" %>

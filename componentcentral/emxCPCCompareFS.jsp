<%--  emxObjectCompareReport.jsp
      (c) Dassault Systemes, 1993-2016.  All rights reserved.

--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.componentcentral.CPCCompare"%>
<%
    //String acceptLanguage=request.getHeader("Accept-Language");
CPCCompare compareBean =(CPCCompare)session.getAttribute("compareBean");

    framesetObject fs = new framesetObject();
    String appDirectory = (String)FrameworkProperties.getProperty(context, "eServiceSuiteComponentCentral.Directory");
    fs.setDirectory(appDirectory);

     // ----------------- Do Not Edit Above ------------------------------

    try
    {
       String pivot=emxGetParameter(request,"pivot");
       String disExtAttr = emxGetParameter(request,"disExtAttr");
       String baseObjId = emxGetParameter(request,"baseObjId");
       String calledMethod = emxGetParameter(request,"calledMethod");
       if(baseObjId != null) {
			compareBean.setBaseObjectID(context, baseObjId);
		}
	   if ("true".equals(pivot))
	   {
		   compareBean.pivot=true;
	   }
	   else if ("false".equals(pivot))
	   {
		   compareBean.pivot=false;
       }
       if ("true".equals(disExtAttr))
       {
           compareBean.displayExtAttr=true;
       }
       else if ("false".equals(disExtAttr))
       {
           compareBean.displayExtAttr=false;
       }


      // Specify URL to come in middle of frameset
      StringBuffer contentURL = new StringBuffer("emxCPCCompare.jsp");
      String finalURL=contentURL.toString();
	  if(calledMethod!= null && calledMethod.equals("addExisting")) {
  	  	finalURL=finalURL+"?calledMethod=" + calledMethod;
  	  }
      finalURL=FrameworkUtil.encodeHref(request,finalURL);

      String PageHeading = "emxComponentCentral.ObjectCompare.Title";
      String HelpMarker = "emxhelpcomparereports";
      fs.setStringResourceFile("emxComponentCentralStringResource");


      fs.removeDialogWarning();

      //for displaying subheading

	  //for displaying subheading
	  String baseObjectId=compareBean.getBaseObjectID();
	  BusinessObject bo=new BusinessObject(baseObjectId);
	  bo.open(context);
	  fs.setObjectId(baseObjectId);
      bo.close(context);
      //(String pageHeading, String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
      fs.initFrameset(PageHeading,HelpMarker,finalURL,false,true,false,false,1,"emxComponentCentral.ObjectCompare.ReportsubHead");
		fs.useCache(false);
      String roleList = "role_GlobalUser";

     // fs.setToolbar("CPCCompareToolBar");
		fs.createCommonLink("emxComponentCentral.ObjectCompare.Pivot","pivotCompareReportTable()",roleList,false,true,"",true,4);
	    if(!compareBean.displayExtAttr) {

		  fs.createCommonLink("emxComponentCentral.ObjectCompare.ShowExtendedAttributes","displayExtendedAttributes()",roleList,false,true,"",true,4);
		}
	    else {
		  fs.createCommonLink("emxComponentCentral.ObjectCompare.HideExtendedAttributes","displayExtendedAttributes()",roleList,false,true,"",true,4);
		}

		if(calledMethod!= null && calledMethod.equals("addExisting")) {
			fs.createFooterLink("emxComponentCentral.Button.Submit",
                        "submitAddExisting()",
                        roleList,
                        false,
                        true,
                        "common/images/buttonWizardDone.gif",
                        0);
		}
    	fs.createFooterLink("emxComponentCentral.Button.Cancel",
                        "parent.window.close()",
                        roleList,
                        false,
                        true,
                        "common/images/buttonDialogCancel.gif",
                        0);


      // ----------------- Do Not Edit Below ------------------------------

      fs.writePage(out);
        }
        catch (Exception ex)
        {ex.printStackTrace();
          if (ex != null &&  ex.toString().trim().equals("'business object' does not exist"))
          {
%>

              <script language = "javascript">
                     alert("<emxUtil:i18nScript localize="i18nId">emxComponentCentral.ObjectCompare.ObjectsDeleted</emxUtil:i18nScript>");
                     parent.window.close();
               </script>

<%
          }
          else if (ex != null && ex.toString().length() > 0)
          {
                emxNavErrorObject.addMessage(ex.toString());
          }
       }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc" %>

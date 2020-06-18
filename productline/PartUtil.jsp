
<%--
  PartUtil.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/PartUtil.jsp 1.5.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";

--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.productline.Part"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.domain.*"%>

<html>

  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
 

<%
  String strMode;
   boolean errFlag = false;
  //Get the mode called
  strMode = emxGetParameter(request, "mode");
  String strObjectId = emxGetParameter(request, "objectId");
  //System.out.println("OBJID = " + strObjectId);
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String objectId = emxGetParameter(request, "RelationshipId");

  String relationshipId = emxGetParameter(request, "relId");

  String productId = "";

  Part partBean = new Part();

  if (strMode.equalsIgnoreCase("disconnect"))
  {
      String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
      String arrObjectIds[] = null;
      String arrRelIds[] = null;
      boolean bIsFromTree = false;
      arrObjectIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("ObjId");
      arrRelIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("RelId");

      bIsFromTree = true;
      boolean bFlag = partBean.disconnect(context,arrObjectIds,arrRelIds);

      if (bIsFromTree)
      {
// Begin of Modify by Enovia MatrixOne for Bug # 301879 Date 04/07/2005
%>
   <script language="javascript" type="text/javaScript">
<%
        for(int i=0;i<arrObjectIds.length;i++)
        {
%>
  <!-- hide JavaScript from non-JavaScript browsers -->
  //<![CDATA[

  var tree = getTopWindow().trees['emxUIDetailsTree'];
  tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[i])%>");

  //]]>
<%
          }
%>
    refreshTreeDetailsPage();
  </script>

<%
// End of Modify by Enovia MatrixOne for Bug # 301879 Date 04/07/2005
      }
     else
      {
%>
  <script language="javascript" type="text/javaScript">
    refreshContentPage();
  </script>
<%

      }
     }

if (strMode.equalsIgnoreCase("edit"))
  {
    try {
      //Part partBean1 = new Part();
      String strRelId = emxGetParameter(request, "hidRelationshipId");
      FormBean formBean = new FormBean();
      //processing the form bean which will set all the data available in the request
      formBean.processForm(session,request);
      partBean.editPart(context,strRelId,formBean);

    }
    catch(Exception e)
     {
        errFlag = true;
       session.putValue("error.message", e.getMessage());
     }
%>

<!--Javascript to reload the content pane provided the Expressions are valid and the BCR has been created-->
    <script language="javascript" type="text/javaScript">
      //alert(parent.window.getWindowOpener().parent.document.location);
      parent.window.getWindowOpener().parent.document.location.reload();
      parent.window.closeWindow();
      parent.window.getWindowOpener().window.getTopWindow().focus();
      window.getTopWindow().focus();
    </script>


<%
   }

    //REPLACE of GBOM starts here Added by Enovia MatrixOne <Amrut> for 10.6SP1 Release
    if( strMode.equalsIgnoreCase("replace") )
    {
        //Added by Vibhu,Enovia MatrixOne for Bug 311488 on 11/8/2005
        String strSourceGBOM = (String)emxGetParameter(request, "txtSourceGBOMId");
        String strDestGBOM =(String)emxGetParameter(request, "txtDestGBOMId");
        try
        {
            //Instantiating the FormBean
            com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
            //Processing the form using FormBean.processForm
            formBean.processForm(session,request);
            //Invoking method replacePart of Part bean.
            boolean bResult=partBean.replacePart(context,formBean);
        }
        catch(Exception ex)
        {
            errFlag = true;
            session.putValue("error.message", ex.getMessage());
        }
%>
        <script language="javascript" type="text/javaScript">
        var refFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
       
       <%   
          if(!strSourceGBOM.equals(strDestGBOM)){
	
	%>
	        var tree = parent.window.getWindowOpener().getTopWindow().trees['emxUIDetailsTree'];
	        tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,strSourceGBOM)%>");
	        refFrameObj.refreshTreeDetailsPage();
	  <%
	  } else {
	  %>
	  	      refFrameObj.refreshTablePage();
<%
}
%>
	  //End of Add by Enovia MatrixOne on 16-May-2005 for Bug#304479
	      parent.window.closeWindow();
  </script>
  
<%

    }
    //Replace of Parts ends here


  if( errFlag == true && strMode.equalsIgnoreCase("edit") )
    {
%>

        <script language="javascript" type="text/javaScript">
            history.back();
        </script>


<%
  } // End of if
%>


<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>



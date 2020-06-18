<%--  TaskChooserFS

  Frameset for Task Chooser Page

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program

--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
 <%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
 <%@include file = "emxProductCommonInclude.inc" %>
 <%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%--Breaks without the useBean--%>
<%@page import="com.matrixone.apps.productline.*"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
 <% try{
	 String objectId = emxGetParameter(request, "objectId");
	 Product productBean = (Product) com.matrixone.apps.domain.DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCTS,"ProductLine");
	 String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
     String arrObjectIds[] = null;
     boolean bIsFromTree = false;
     if (arrTableRowIds[0].indexOf("|") >=0 )
     {
       arrObjectIds = com.matrixone.apps.productline.ProductLineUtil.getObjectIds(arrTableRowIds);
       bIsFromTree = true;
     }
     else
       arrObjectIds   = arrTableRowIds;
	 //Get the selected Projects/Programs in the chooser
         Map mpObjIdRelId = new HashMap();
    // String []arrSelectedTaskIds = emxGetParameterValues(request,"checkbox");
     //call the method to connect the context Product to selected Tasks
     productBean.setId(objectId);
     mpObjIdRelId = productBean.associateTasks(context,arrObjectIds);
    
     /*Begin of Add:Raman,Enovia MatrixOne Bug#303524 on 5/13/2005*/
      //if Tasks are succesfully connected to the Product
      if (mpObjIdRelId!=null && !mpObjIdRelId.isEmpty())
        {
     %>

       <!--Javascript to refresh the Tasks List page -->
       
<script language="javascript" type="text/javaScript">              
       
       getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
       getTopWindow().closeWindow();
       </script>
<%}
 }catch(Exception e){
     session.putValue("error.message", e.getMessage());
     
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

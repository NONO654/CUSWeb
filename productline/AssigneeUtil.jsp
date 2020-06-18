
<%--  AssigneeUtil.jsp   

    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved.

    This program contains proprietary and trade secret information of MatrixOne,
    Inc.  Copyright notice is precautionary only and does not evidence
    any actual or intended publication of such program

    static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/AssigneeUtil.jsp 1.3.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";
        
--%>
<%--Importing package com.matrixone.apps.domain --%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>

<%--Importing package com.matrixone.apps.product --%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>

<%@page import = "com.matrixone.apps.domain.DomainConstants"%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>



<html>
  <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
  <script language="javascript" src="../common/script/emxUICore.js"></script>


<%

try
{
    //Instantiating ProductLineutil and ProductLinecommon beans
    ProductLineCommon ProductLineCommonBean = new ProductLineCommon();

    //extract Table Row ids of the checkboxes selected.
    String arrRowIds[] = emxGetParameterValues(request,"emxTableRowId");
    //extract the mode selected.
    String strMode = emxGetParameter(request,"mode");
    
    
    
    // If the mode is Disconnect, then the relationship will be disconnected 
    if (strMode.equalsIgnoreCase("Disconnect"))
    {
    //extracts Rel id of the Objects to be disconnected.
    String[] arrRelIds=(String[])(ProductLineUtil.getObjectIdsRelIds(arrRowIds)).get("RelId");
    //extracts Object id of the Objects to be disconnected.
    String[] arrObjIds=(String[])(ProductLineUtil.getObjectIdsRelIds(arrRowIds)).get("ObjId"); 
    //returns true in case of successful disconnect.
    boolean bRemove=ProductLineCommonBean.removeObjects(context,arrRelIds);
    //Refreshing the tree
    
%>
      <script language="javascript" type="text/javaScript">
<%    
    for(int i=0;i<arrObjIds.length;i++)
    {
      
%>
      var tree = getTopWindow().trees['emxUIDetailsTree'];
      tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,arrObjIds[i])%>");
<%
    }
%>
      refreshTreeDetailsPage(); 
      </script>
<%

     }
}catch(Exception e)
{
    session.putValue("error.message", e.toString());    
}


%>     


<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


  
</html>

  






 
 

   

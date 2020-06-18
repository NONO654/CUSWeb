<%-- ProductConfigurationDBChooser.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/configuration/ProductConfigurationUtil.jsp 1.70.2.7.1.2.1.1 Wed Dec 17 12:39:33 2008 GMT ds-dpathak Experimental$: ProductConfigurationUtil.jsp";
--%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.productline.*" %>
<%@page import = "com.matrixone.apps.configuration.ProductConfiguration"%>

<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<SCRIPT language="javascript" src="../emxUIPageUtility.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT>
<%
try
{

// Getting table row ids from the list page
      String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
      String strObjectIds[] = null;

      // Getting object ids for the corresponding row ids
      strObjectIds = ProductLineUtil.getObjectIds(strTableRowIds);

      // Deleting objects from database
        ProductConfiguration.deleteObjects(context,strObjectIds);
     
%>
          <script language="javascript" type="text/javaScript">
<%
///NEXT_GEN_UI (replaced emxUIDetailsTree with emxUIStructureTree
        for(int i=0;i<strObjectIds.length;i++)
        {
%>
            var tree = getTopWindow().trees['emxUIStructureTree'];
            tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,strObjectIds[i])%>");
<%
        }
%>
        //<![CDATA[
          // Reloading the tree page after delete/remove
          refreshTreeDetailsPage();
         // Reloading the feature list page after delete/remove
         refreshTablePage();
        //]]>
        </script>
 <%}
 catch(Exception ex)
 {	String msg = ex.toString();
	if(msg.contains("java.lang.Exception:")){
		msg = msg.replace("java.lang.Exception:","");
 %>
		 <script language="javascript" type="text/javaScript">
	     alert("<%=XSSUtil.encodeForJavaScript(context,msg)%>");
	     </script>
<%}
	else{	
%>
		 <script language="javascript" type="text/javaScript">
	     alert("<%=XSSUtil.encodeForJavaScript(context,msg)%>");
	     </script>
<%}
}
%>

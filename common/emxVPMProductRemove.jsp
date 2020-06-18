<%--  emxTest.jsp   -   FS page for Create CAD Drawing dialog
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTestDelete.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $
--%>

<%-- 

<%@ page
	import="java.util.*,com.matrixone.vplmintegrationitf.util.*,com.matrixone.vplmintegration.util.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.framework.taglib.*,matrix.db.*"%>

<%@ page import = "java.util.Set" %>
<%@ page import = "java.util.List" %>
<%@ page import = "java.text.DateFormat" %>
<%@ page import = "java.util.ArrayList" %>

<%@page  import="com.matrixone.apps.domain.util.i18nNow"%>
<%@include file  =  "../components/emxCalendarInclude.inc"  %> 
<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
 --%>
<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMDebugUtil"%> 
<%@include file = "../components/emxComponentsUtil.inc"%> 
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
//VPLMDebugUtil.dumpObject(requestMap);
String msgString = null;

try
{
  //String tableRowId = emxGetParameter(request, "emxTableRowId");
  String tableRowId = (String) requestMap.get("emxTableRowId");
  String role = (String) requestMap.get("role");
  String objectId = (String) requestMap.get("objectId");

  Map programMap = new HashMap();
	programMap.put("emxTableRowId", tableRowId);
     programMap.put("role", role);
     programMap.put("objectId", objectId);

	String[] methodargs =JPO.packArgs(programMap);
				
   JPO.invoke(context, "emxVPLMProdEdit", null,"removePrd", methodargs);	
     
  }
catch (Exception ex)
{
	    if  ((  ex.toString()  !=  null)  &&  (ex.toString().trim().length()>0))   
	    {
	    	String msgError = (String)(ex.toString());
	    	if ( (msgError.indexOf("Unique")) > 0 )
	    	{
         emxNavErrorObject.addMessage("Instance to Remove not Unique. Remove action is not allowed");
	    	}
	    	else
	    	 ex.printStackTrace();
	    }

}
%>
 <%@include file = "emxNavigatorBottomErrorInclude.inc"%>

<html>
<body>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" >

// remise à jour de la page
top.refreshTablePage();

</script>


</body>
</html>

 



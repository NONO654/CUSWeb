<%--
  ModelRemoveDeletePostProcess.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>


<%@page import = "java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "matrix.util.StringList"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
	boolean bIsError = false;
	String action = "";
	String msg = "";
	//Instantiate the common and util beans
	ProductLineCommon commonBean = new ProductLineCommon();
	//get the table row ids of the Model objects selected
	String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    //get the relationship ids of the table row ids passed
    Map relIdMap=ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);

    String[] arrRelIds = (String[]) relIdMap.get("RelId");
    String[] strObjectIds = (String[]) relIdMap.get("ObjId");
    String strMode = emxGetParameter(request, "mode");

    
	try{
	
	    if(strMode.equalsIgnoreCase("Remove")){
	    	boolean bFlag = commonBean.removeObjects(context,arrRelIds);	
	    } else if(strMode.equalsIgnoreCase("Delete")){
	        String parentObjectID= emxGetParameter(request,"objectId");
	        //Instantiating ProductLineUtil.java bean
	        com.matrixone.apps.productline.ProductLineUtil productlineUtil = new com.matrixone.apps.productline.ProductLineUtil();
	        com.matrixone.apps.productline.Model modelBean = (com.matrixone.apps.productline.Model)DomainObject.newInstance(context,ProductLineConstants.TYPE_MODEL,"ProductLine");
	        //Getting the object ids from the table row ids
	        String arrObjectIds[] = null;
	        arrObjectIds = productlineUtil.getObjectIds(arrTableRowIds);
	        
	    	boolean bReturnVal= modelBean.delete(context,arrObjectIds,parentObjectID);
	    }
		action = "removeandrefresh";
	}
    catch(Exception e){
         bIsError=true;
         action = "error";
         msg = e.toString();                                      
     }
     out.clear();
     response.setContentType("text/xml");
   %>
 <mxRoot>
     <!-- XSSOK -->
     <action><![CDATA[<%= action %>]]></action>
     <!-- XSSOK -->
     <message><![CDATA[<%= msg %>]]></message>    
 </mxRoot>
 

<%-- emxCPXPartBOMAddExisting.jsp

   Copyright (c) 1992-2016 Dassault Systemes.
  <%--  emxEngrPartBOMAddExisting.jsp   - The Processing page for Part connections.

   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program

   static const char RCSID[] = $Id: emxEngrPartBOMAddExisting.jsp.rca 1.2.3.2 Wed Oct 22 16:02:54 2008 przemek Experimental przemek przemek $

--%>

<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@include file = "../engineeringcentral/emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%
  
  String objectId = emxGetParameter(request, "objectId");
  String selPartObjectId = emxGetParameter(request, "selPartObjectId");
  String highestFN = emxGetParameter(request, "highestFN");
  if("".equals(selPartObjectId) || selPartObjectId == null)
  {
	  selPartObjectId = objectId;
  }
  String selPartRelId = emxGetParameter(request, "selPartRelId");
  String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
  MapList tempListNewget=(MapList)session.getAttribute("tempListNew");
  String strInput = "";
  //Start: 367764
  //String callbackFunctionName = "loadMarkUpXML";
  String callbackFunctionName = "addToSelected";
  //End: 367764
  java.util.HashMap requestMap = new java.util.HashMap();
  requestMap.put("objectId",objectId);
  requestMap.put("selPartObjectId",selPartObjectId);
  requestMap.put("selPartRelId",selPartRelId);
  requestMap.put("selectedItems",selectedItems);
  requestMap.put("tempListNewget",tempListNewget);
  requestMap.put("callingApp","CPX");
  requestMap.put("highestFN",highestFN);
  try{
      strInput = new com.matrixone.apps.engineering.EBOMMarkup().getMarkup(context,requestMap);
  }catch(Exception ex){
      if (ex.toString() != null && (ex.toString().trim()).length() > 0)
          emxNavErrorObject.addMessage(ex.toString().trim()); 
  }
  
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript">
  //refresh the calling structure browser and close the search window
  //XSSOK
  var callback = eval(getTopWindow().getWindowOpener().parent.emxEditableTable.<%=callbackFunctionName%>);
  //376740 ends
  //var status = callback('<%=strInput%>', "true");
  var status = callback('<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>');
  //End: 367764
  getTopWindow().closeWindow();
</script>

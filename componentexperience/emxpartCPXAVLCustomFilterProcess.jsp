<%--
  emxpartAVLCustomFilterProcess.jsp
  © Dassault Systemes, 1993 - 2010.  All rights reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxpartAVLCustomFilterProcess.jsp.rca 1.8 Wed Oct 22 15:52:32 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%

  // tableID parameter will is the key to obtain the current table data.
  String tableID = Request.getParameter(request, "tableID");
  // Obtain the requestMap which contain all the request params to emxTable.jsp
  HashMap requestMap = tableBean.getRequestMap(tableID);
  String location="";
  String locationId = "";
  String hostCompId = "";
  // obtain the location Name selected by the User
  location = emxGetParameter(request,"locationName");
  if (("").equals(location)) {
        locationId="All";
  }
  else {
      // obtain the Id of the location selected by the User
	  locationId = emxGetParameter(request,"locationId");
  }
  // If the location value is blank, set the Location to 'All' locations

  // update the 'locations'in the requestMap by the one user selected.
  requestMap.put("location",locationId);
  // Set the location Id into session as these values are accessed by the edit locaiton screen
  session.setAttribute("locationId", locationId);
  String filterOption = emxGetParameter(request,"filterTable");
  requestMap.put("selectedFilter",filterOption);
  filterOption = filterOption.substring(filterOption.indexOf(':')+1);
  
  String useBOMQualification = emxGetParameter(request,"useBOMQualification");
  requestMap.put("useBOMQualification",useBOMQualification);

  try {
      String initargs[] = {};
     // Call the getEBOM's method of emxPart JPO to get the data to be populated in the table.
      MapList ebomList = (MapList) JPO.invoke(context, "emxPart", initargs,  filterOption, JPO.packArgs (requestMap), MapList.class);
      // set the data obtained izn the table.
      tableBean.setFilteredObjectList(tableID,ebomList);
  }
  catch(Exception e){
    throw e;
  }
%>
<script language="JavaScript">
   // refresh the table page.
   parent.refreshTableBody();
</script>

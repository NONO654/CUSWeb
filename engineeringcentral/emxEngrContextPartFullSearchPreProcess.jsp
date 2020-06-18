<%--  emxEngrContextPartFullSearchPreProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<%!
	public StringList getPartKeyValue(Map mapKeyPartId, String strPartId, String strParentId){
		 StringList strKeyPartIdList = (StringList)mapKeyPartId.get(strPartId);
		 if(strKeyPartIdList == null || "null".equals(strKeyPartIdList)){
			 strKeyPartIdList = new StringList();
		 }
		 StringList strKeyParentIdList = (StringList)mapKeyPartId.get(strParentId);
		 if(strKeyParentIdList != null){
			 for(int i=0;i<strKeyParentIdList.size();i++){
				 String strKeyParentId = (String)strKeyParentIdList.get(i);
				 if(!strKeyPartIdList.contains(strParentId + "|" +strKeyParentId)){
					 strKeyPartIdList.add(strParentId + "|" +strKeyParentId);
				 }
			 }
		 }
		 else{
			 strKeyPartIdList.add(strParentId);
		 }
		 return strKeyPartIdList;
	}
%>
<%
  String objID = "";
  String objectId = emxGetParameter(request,"objectId");
  String mode = emxGetParameter(request, "mode");
  String EngView = emxGetParameter(request,"EngView");
  String header = "emxEngineeringCentral.Common.SearchResults";
  String cancelLabel = "emxEngineeringCentral.Button.Close";
  String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
  String revisionFilter = emxGetParameter(request,"ENCBOMRevisionCustomFilter");
  String jsTreeID = emxGetParameter(request,"jsTreeID");

  if (mode == null || "".equals(mode) || "null".equals(mode))
  {
      mode = "PlantContext";
  }
  if (EngView == null || "".equals(EngView) || "null".equals(EngView))
  {
      EngView = "true";
  }

  String contextPart = "";
  //this is single select so should only have one value selected
  if (tableRowIdList!= null) {
       //process - relId|objectId|parentId - using the tableRowId
       String tableRowId = tableRowIdList[0];
       String firstIndex = tableRowIdList[0].substring(0,tableRowIdList[0].indexOf("|"));
       StringTokenizer strTok = new StringTokenizer(tableRowId,"|");
       contextPart = strTok.nextToken();
       if(!firstIndex.equals("")) //first index is relId so need to fetch objecId
       {
           contextPart = strTok.nextToken();
       }

  }

  Part part = new Part(contextPart);
  MapList ebomList = null;
  Map mapKeyPartId = new HashMap();
  Map mapChangePartId = new HashMap();
  //construct selects
  SelectList objSelects = new SelectList(1);
  SelectList relSelects = new SelectList(1);
  objSelects.add(DomainConstants.SELECT_ID);
  objSelects.add(DomainConstants.SELECT_REVISION);
  relSelects.add(DomainConstants.SELECT_FROM_ID);

  //fetch all parts in the given bom that have children
  String whereClause = "";
  if (EngView.equals("true"))  {
      //whereClause = "from["+ DomainConstants.RELATIONSHIP_EBOM + "]==\'True\'";
      ebomList = part.getRelatedObjects(context,
                                         DomainConstants.RELATIONSHIP_EBOM,  // relationship pattern
                                         DomainConstants.TYPE_PART,          // object pattern
                                         objSelects,                         // object selects
                                         relSelects,                         // relationship selects
                                         false,                              // to direction
                                         true,                               // from direction
                                         (short)0,                           // recursion level
                                         null,                        // object where clause
                                         null);                              // relationship where clause
      //actionURL = "../common/emxTable.jsp?suiteKey="+suiteKey+"&program=emxPart:getPartsInEBOM&table=ENCContextPartSearchTable&sortColumnName=Name&HelpMarker=emxhelpsearchresults&header="+header+"&CancelButton=true&CancelLabel="+cancelLabel+"&selection=multiple&contextId="+contextId+"&ObjectId="+ObjectId;
  }

  StringBuffer parentPartBuffer = new StringBuffer(250);
  if (ebomList != null)
  {
      Iterator i = ebomList.iterator();
      int cnt=0;
      while (i.hasNext())
      {
          if (cnt > 0)
          {
             parentPartBuffer.append(",");
          }
          Map m = (Map) i.next();
		  String strParentId = (String)m.get(DomainConstants.SELECT_FROM_ID);
		  String strParentDup = (String)mapChangePartId.get(strParentId);
		  if(strParentDup!=null){
			  strParentId = strParentDup;
		  }
		  String strPartId = (String)m.get(DomainConstants.SELECT_ID);
		  if(revisionFilter!=null && revisionFilter.equalsIgnoreCase("Latest")){
			  String oldRev = (String)m.get(DomainConstants.SELECT_REVISION);
			  DomainObject domObj = DomainObject.newInstance(context,strPartId);
			  BusinessObject bo = domObj.getLastRevision(context);
			  bo.open(context);
			  objID = bo.getObjectId();
			  String newRev = bo.getRevision();
			  bo.close(context);

			  if(!oldRev.equals(newRev)){
				  mapChangePartId.put(strPartId, objID);
				  strPartId = objID;
				  domObj = DomainObject.newInstance(context,strPartId);
			  }
		  }
          parentPartBuffer.append(strPartId);
		  mapKeyPartId.put(strPartId, getPartKeyValue(mapKeyPartId, strPartId, strParentId));
          cnt++;
      }
      //also add context part as a parent part
      if (cnt > 0)
      {
         // parentPartBuffer.append(",");
      }
  }
  //parentPartBuffer.append(contextPart);


  //String contentURL = "../common/emxFullSearch.jsp?field=ID=" + parentPartBuffer.toString();
  //contentURL += "&table=ENCContextPartSearchTable&objectId="+objectId+"&selection=multiple";
String fieldValue = parentPartBuffer.toString();
if (fieldValue.length() == 0)
{
	fieldValue = "None";
}

  String contentURL = "../common/emxFullSearch.jsp?";
  //modified for includeOIDprogram starts
  //contentURL += "field=TYPES=type_Part:ID="+fieldValue;
  contentURL += "field=TYPES=type_Part&includeOIDprogram=emxENCFullSearch:getEBOMsWithinContext&contextPart="+contextPart+"&revisionFilter="+revisionFilter;
  //modified for includeOIDprogram ends
  contentURL += "&table=ENCContextPartSearchTable&HelpMarker=emxhelpfullsearch&objectId="+objectId+"&selection=multiple&suiteKey=EngineeringCentral";
  contentURL += "&sortColumnName=Name&header="+header+"&CancelButton=true&CancelLabel="+cancelLabel+"&submitLabel=emxEngineeringCentral.Button.HighlightSelected";
  contentURL += "&submitURL=../engineeringcentral/emxEngrBOMPartSearchWithinProcess.jsp";
  session.setAttribute("mapKeyPartId", mapKeyPartId);
%>
<html>
<head>
</head>
<body>
<!-- 370797: instead of "form" used "searchwithin" -->
<!-- <form name="searchwithin" method="post">
<input type="hidden" name="field" value = "" /> -->
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script>
var frameName = parent.name;
//XSSOK
//document.searchwithin.field.value = "TYPES=type_Part:ID=" + "<%=fieldValue%>";
//XSSOK
//document.searchwithin.action = "<%=XSSUtil.encodeForJavaScript(context,contentURL)%>";
//document.searchwithin.submit();
//document.location.href="<%=contentURL%>";

parent.showModalDialog("<%=XSSUtil.encodeForJavaScript(context,contentURL)%>"+"&frameName="+frameName);
</script>
<!-- </form> -->
</body>
</html>


<%--  emxRMTContextObjFullSearchPreProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program

<!--    /* -->
<!--     * @quickreview T25 OEP 12:07:26 (IR-170677V6R2013x "NHI:V6R214: Function_030512 : VNLS : Button on Search window not getting translated in Specific languages.") -->
<!--     * @quickreview LX6 JX5 12:07:30 (IR-163649V6R2013x "NHI:V6R2013X: Function_030512 : Comment is not getting searched.") -->
<!--     * @quickreview LX6 JX5 12:07:30 (IR-184711V6R2013x "TVTZ,JA-V6R2013x-CATIA-RMT-Wk32.3-T1.2 _S9- Search Pop window header is not translated.") -->
<!--     * @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet -->
<!--     * @quickreview QYG     15:04:24  3DSearch integration  -->
<!--     * @quickreview LX6     15:05:37 IR-350188-3DEXPERIENCER2016x : Search with in context  displays incorrect result. --> 
<!--     * @quickreview KIE1 ZUD 19:01:23 IR-658231-3DEXPERIENCER2019x: Search within context shows wrong types and count for 6Wtags --> 
<!--     */ -->
--%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%!
	public StringList getObjKeyValue(Map mapKeyObjId, String strObjId, String strParentId){
		 StringList strKeyObjIdList = (StringList)mapKeyObjId.get(strObjId);
		 if(strKeyObjIdList == null || "null".equals(strKeyObjIdList)){
			 strKeyObjIdList = new StringList();
		 }
		 StringList strKeyParentIdList = (StringList)mapKeyObjId.get(strParentId);
		 if(strKeyParentIdList != null){
			 for(int i=0;i<strKeyParentIdList.size();i++){
				 String strKeyParentId = (String)strKeyParentIdList.get(i);
				 if(!strKeyObjIdList.contains(strParentId + "|" +strKeyParentId)){
					 strKeyObjIdList.add(strParentId + "|" +strKeyParentId);
				 }
			 }
		 }
		 else{
			 strKeyObjIdList.add(strParentId);
		 }
		 return strKeyObjIdList;
	}
%>
<%
  String objID = "";
  String objectId = emxGetParameter(request,"objectId");
  String header = "emxEngineeringCentral.Common.SearchResults";
  String cancelLabel = "emxEngineeringCentral.Button.Close";
  // Start:IR:177439V6R2013x:T25
  //Review:OEP
  final String STRING_HIGHLIGHTSELECTED = "emxRequirements.Button.HighlightSelected";
//END:IR:177439V6R2013x:T25
// Start:IR:184711V6R2014:LX6
  final String STRING_HEADER = "emxRequirements.Button.SearchWithInContext";
//End:IR:184711V6R2014:LX6  
  String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
  //Add this parameter to the Url.
  String selectedProgram = emxGetParameter(request,"selectedProgram");
  if(selectedProgram ==  null)
  {
	  selectedProgram = "";
  }

  String contextObject = "";
  //this is single select so should only have one value selected
  if (tableRowIdList!= null) {
       String tableRowId = tableRowIdList[0];
       String firstIndex = tableRowIdList[0].substring(0,tableRowIdList[0].indexOf("|"));
       StringTokenizer strTok = new StringTokenizer(tableRowId,"|");
       contextObject = strTok.nextToken();
       if(!firstIndex.equals("")) //first index is relId so need to fetch objecId
       {
           contextObject = strTok.nextToken();
       }

  }

  DomainObject Obj = new DomainObject(contextObject);
  MapList objList = null;
  Map mapKeyObjId = new HashMap();
  Map mapChangeObjId = new HashMap();
  //construct selects
  SelectList objSelects = new SelectList(1);
  SelectList relSelects = new SelectList(1);
  objSelects.add(DomainConstants.SELECT_ID);
  relSelects.add(DomainConstants.SELECT_FROM_ID);

  //fetch all Objs in the given bom that have children
  String whereClause = "";
  //Add of Comments objects in the search result of "Search within context" feature
  //Start:IR:163649V6R2013x:LX6
  String Types =  ReqSchemaUtil.getRequirementType(context)
                  +","
                  +ReqSchemaUtil.getRequirementSpecificationType(context)
                  +","
                  +ReqSchemaUtil.getChapterType(context)
                  +","
                  +ReqSchemaUtil.getCommentType(context)
                  +","
  				  +ReqSchemaUtil.getParameterType(context)
  				  +","
	  			  +ReqSchemaUtil.getTestCaseType(context);
  //End:IR:163649V6R2013x:LX6
  objList = Obj.getRelatedObjects(context,
                                  ReqSchemaUtil.getExtendedSpecStructureRelationships(context) ,  // relationship pattern
                                  Types,// object pattern
                                  objSelects,                         // object selects
                                  relSelects,                         // relationship selects
                                  false,                              // to direction
                                  true,                               // from direction
                                  (short)0,                           // recursion level
                                  null,                        // object where clause
                                  null);                              // relationship where clause
  
  StringBuffer parentObjBuffer = new StringBuffer(250);
  if (objList != null)
  {
      Iterator i = objList.iterator();
      int cnt=0;
      while (i.hasNext())
      {
          if (cnt > 0)
          {
             parentObjBuffer.append(",");
          }
          Map m = (Map) i.next();
		  String strParentId = (String)m.get(DomainConstants.SELECT_FROM_ID);
		  String strParentDup = (String)mapChangeObjId.get(strParentId);
		  if(strParentDup!=null){
			  strParentId = strParentDup;
		  }
		  String strObjId = (String)m.get(DomainConstants.SELECT_ID);
          parentObjBuffer.append(strObjId);
		  mapKeyObjId.put(strObjId, getObjKeyValue(mapKeyObjId, strObjId, strParentId));
          cnt++;
      }
      //also add context Obj as a parent Obj
      if (cnt > 0)
      {
         // parentObjBuffer.append(",");
      }
  }
  
  //This code is used to get the filter type of Requirement Specification
  String contentURL = "../common/emxFullSearch.jsp?";
  //modified for includeOIDprogram starts
  //Start:IR:163649V6R2013x:LX6
  contentURL += "field=TYPES="+Types+"&objectId="+contextObject+"&selectedProgram="+selectedProgram+"&includeOIDprogram=emxRequirementSearch:getContextObjects";
  //End:IR:163649V6R2013x:LX6
  contentURL += "&table=RMTGlobalSearchBasicsTable&HelpMarker=emxhelpfullsearch&objectId="+objectId+"&selection=multiple&suiteKey=Requirements";
  //TODO: Changer le label du bouton cancel
   // Start:IR:177439V6R2013x:T25
   // Start:IR:184711V6R2014:LX6
  //Review:OEP
  contentURL += "&sortColumnName=Name&header="+STRING_HEADER+"&CancelButton=true&CancelLabel="+"cancelLabel"+"&submitLabel="+STRING_HIGHLIGHTSELECTED;
  // End:IR:177439V6R2013x:T25
  // End:IR:184711V6R2014:LX6
  contentURL += "&submitURL=../requirements/emxRMTObjSearchWithinProcess.jsp";
  session.setAttribute("mapKeyObjId", mapKeyObjId);
%>
<html>
<head>
  <script src="../common/emxUIConstantsJavaScriptInclude.jsp" type="text/javascript"></script>
  <script src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
  <script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
  <script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
  <script src="../common/scripts/jquery-latest.js" type="text/javascript"></script>
</head>
<body>
<script>
//START : LX6 IR-350188-3DEXPERIENCER2015x : Search with in context  displays incorrect result
var oXML = parent.oXML;
var allowedOID = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@filter='false' and not(@level='0')]");
var IdArray="";
for(var i=0;i<allowedOID.length;i++){
	IdArray += allowedOID[i].getAttribute("o");
	if(i<allowedOID.length-1){
		IdArray += ",";
	}
}
if(isSnN()){
	var url = "<xss:encodeForJavaScript><%=contentURL%></xss:encodeForJavaScript>" + "&allowedOIDs="+IdArray;
	showModalDialog(url);	
}else{
	window.open(null,"searchWithinContextPopup","modal=yes");
	
	var f = document.createElement("form");
	f.setAttribute('method',"post");
	f.setAttribute('action', "<xss:encodeForJavaScript><%=contentURL%></xss:encodeForJavaScript>");
	f.setAttribute('name',"searchwithin");
	f.setAttribute('target',"searchWithinContextPopup");

	var i1 = document.createElement("input"); //input element, text
	i1.setAttribute('type',"hidden");
	i1.setAttribute('name',"field");
	i1.setAttribute('value',"");
	
	var i2 = document.createElement("input"); //input element, text
	i2.setAttribute('type',"hidden");
	i2.setAttribute('name',"allowedOIDs");
	i2.setAttribute('id',"allowedOIDs");
	i2.setAttribute('value',IdArray);
	
	f.appendChild(i1);
	f.appendChild(i2);
	
	document.forms["searchwithin"] = f;
    document.body.appendChild(f);
    
	f.submit();
}
//END : LX6 IR-350188-3DEXPERIENCER2015x : Search with in context  displays incorrect result
</script>
</body>
</html>


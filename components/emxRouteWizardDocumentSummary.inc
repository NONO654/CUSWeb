<%--  Create Dialog for Route Wizard
Copyright (c) 1992-2018 Dassault Systemes.
All Rights Reserved.
--%>
<%@page import="com.matrixone.apps.framework.lifecycle.LifeCyclePolicyDetails"%>
<%!
static public String populateCombo(matrix.db.Context context, 
        HttpSession session,
        String sStates,
        String sRelationID, 
        String sPolicy, 
        String sNoneValue,
        String sLangStr , 
        String currState , 
        String selectedState, 
        HashMap stateMap, 
		BusinessObject routableObj) {

String sReturn = "";

try {
	String sSymbolicPolicyName = FrameworkUtil.getAliasForAdmin(context, "policy", sPolicy, true);
	String changedState="";
	if(stateMap != null)
	{
	    changedState = (String)stateMap.get(sRelationID);
	}
	boolean fromMap  = false;
	if(changedState == null || "".equals(changedState) || "null".equals(changedState))
	{
	    changedState = "";
	}
	else
	{
	    fromMap = true;
	}	
	StringTokenizer sTok =  new StringTokenizer(sStates, ",");
	
	int iStateCount= sTok.countTokens();
	String name = "stateSelect";
	if(iStateCount > 1) {
	sReturn = "<select name=\""+ name +"\" id=\""+ sRelationID +"\">";
	sReturn += "<option value=\""+sRelationID+"#"+sNoneValue+"None\" Selected>" + i18nNow.getI18nString("emxComponents.Common.None", "emxComponentsStringResource", sLangStr) + "</option>";
	
	try
	{
	boolean showState = false;
	for (int count=0; count < iStateCount; count++){
	  	if(count == iStateCount-1){
	    	break;
	  	}
	String sStateName =  sTok.nextToken().trim();
			if (sStateName.equals(currState) || showState ) {
				showState = true;
	  if(FrameworkUtil.hasAccessForStateName( context, routableObj, sStateName, "Promote")){
		if(changedState.equals(sStateName) && fromMap){
			   sReturn += "<option value=\""+XSSUtil.encodeForHTMLAttribute(context, sRelationID+"#"+sStateName)+"\" Selected >" +XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getStateI18NString(context,sPolicy,sStateName,sLangStr)) +"</option>";
			   }
		else if(sStateName.equals(selectedState) && !fromMap){
			   sReturn += "<option value=\""+XSSUtil.encodeForHTMLAttribute(context, sRelationID+"#"+sStateName)+"\" Selected>" +XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getStateI18NString(context,sPolicy,sStateName,sLangStr)) +"</option>";
			   }
		else{
			   sReturn += "<option value=\""+XSSUtil.encodeForHTMLAttribute(context, sRelationID+"#"+sStateName)+"\" >" + XSSUtil.encodeForHTML(context,EnoviaResourceBundle.getStateI18NString(context,sPolicy,sStateName,sLangStr))+"</option>";
			   }
		   }
	    }
	}
	
	} catch(MatrixException e){}
	
	sReturn += "</select>";
	return sReturn;
	}
	else
	{
	sReturn = "<input type=hidden name=\""+ "label" +"\" value=\"\"  >" + i18nNow.getStateI18NString(sPolicy,currState,sLangStr);
	}
	} catch(Exception exp) {	
	sReturn = exp.getMessage();	
	}
  return sReturn;
}

%>

<%
  DomainObject documentObject =  DomainObject.newInstance(context);
  String strName="";
  MapList routableObjsList =  new MapList();;
  String sDocID = null;
  try{
  hashRouteWizFirst = (Hashtable)formBean.getElementValue("hashRouteWizFirst");
  sDocID  = (String)hashRouteWizFirst.get("documentID");
  }catch(Exception ect){
  }

if (emxPage.isNewQuery()) {

  MapList cloneList  = new MapList();
  StringList sDocIdList = new StringList();
  String sTotalDocIds= "";

if(hashRouteWizFirst != null && sDocID != null && (!sDocID.equals(""))) {
if(searchDocId != null && !"null".equals(searchDocId)){
  searchDocId= sDocID + searchDocId;
 }else{
  searchDocId= sDocID;
}
}

if((!searchDocId.equals("null")) && (!searchDocId.equals(""))){

	HashMap<String, String> statesWithIdsMap = new HashMap<String, String>();
	String statesWithIds = emxGetParameter(request,"statesWithIds");
	if(UIUtil.isNotNullAndNotEmpty(statesWithIds)) {
		StringList statesWithIdsList = new StringList(statesWithIds.split(";"));
		Iterator statesWithIdsItr = statesWithIdsList.iterator();
		while(statesWithIdsItr.hasNext()) {
			String stateWithId = (String) statesWithIdsItr.next();
			if(UIUtil.isNotNullAndNotEmpty(stateWithId)) {
				String[] tempArr = stateWithId.split(":");
				statesWithIdsMap.put(tempArr[0], tempArr[1]);
			}
		}
	}

StringTokenizer strTokDocsIds = new StringTokenizer(searchDocId, "~");


while (strTokDocsIds.hasMoreTokens()) {
 HashMap tempHashMap = new HashMap();
  String strId = (String)strTokDocsIds.nextToken();

  if(!sDocIdList.contains(strId)) {

  documentObject.setId(strId);
String strType  = (String)documentObject.getInfo(context,documentObject.SELECT_TYPE);
 String strPolicy  = (String)documentObject.getInfo(context,documentObject.SELECT_POLICY);
 StateList strStateList = LifeCyclePolicyDetails.getStateList(context,documentObject,strPolicy);

 String strStates= "";

Iterator<State> itr = strStateList.iterator();
while(itr.hasNext()){
  strStates += itr.next().getName() + ",";
 }

 String strRev= "";
  String strVer= "";
 String selected = "";

 if(strType.equals(DomainConstants.TYPE_DOCUMENT)) {
 strName  = (String) documentObject.getInfo(context,"attribute["+DomainConstants.ATTRIBUTE_TITLE+"]");
 } else {
 strName = (String) documentObject.getInfo(context,documentObject.SELECT_NAME);
 }
 strRev  = (String) documentObject.getInfo(context,documentObject.SELECT_REVISION);
 strVer= (String) documentObject.getInfo(context,"from[Active Version].to.revision");
	 if(strVer == null || "null".equals(strVer)){
 strVer  = "";
 }
selected = statesWithIdsMap.get(strId);

 tempHashMap.put(documentObject.SELECT_TYPE,strType);
 tempHashMap.put(documentObject.SELECT_ID,strId);
  tempHashMap.put(documentObject.SELECT_NAME,strName);
  tempHashMap.put(documentObject.SELECT_POLICY,strPolicy);
  tempHashMap.put(documentObject.SELECT_STATES,strStates);
  tempHashMap.put("selectedState", selected);
  tempHashMap.put("version",strVer);

 //if(strType.equals(DomainConstants.TYPE_DOCUMENT)) {
  tempHashMap.put(documentObject.SELECT_REVISION,strRev);
 //}else{
 // tempHashMap.put(documentObject.SELECT_REVISION,strVer);
 // }

 cloneList.add((Map)tempHashMap);
 sDocIdList.add(strId);
 sTotalDocIds = sTotalDocIds + "~"+ strId;
 }

 }

  hashRouteWizFirst.put("documentID",sTotalDocIds+"~");

  formBean.setElementValue("hashRouteWizFirst",hashRouteWizFirst);
  formBean.setFormValues(session);

  //session.putValue("hashRouteWizFirst",hashRouteWizFirst);
  }

  routableObjsList= cloneList;

 // pass the resultList to the following method
  emxPage.getTable().setObjects(routableObjsList);
  // pass in the selectables to the following method
  emxPage.getTable().setSelects(new StringList());
  }

 routableObjsList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
//added added for the bug 313531
String contentSelected = "";


%>

<tr>
<td>
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>
 <table class="list" id="docList">
 	<tbody>

 <framework:sortInit
 defaultSortKey="<%=documentObject.SELECT_NAME%>"
 defaultSortType="string"
 mapList="<%= routableObjsList %>"
 resourceBundle="emxComponentsStringResource"
 ascendText="emxComponents.Common.SortAscending"
 descendText="emxComponents.Common.SortDescending"
 params = "<%=sParams%>"  />
  <tr>
  	<th width="5%" style="text-align:center">
		<input type="checkbox" name="chkList" id="chkList" onclick="doCheck(this.form.name)" />
	</th>
	<th width="200" nowrap>
  		<framework:sortColumnHeader
 			title="emxComponents.Common.Name"
		    sortKey="<%=documentObject.SELECT_NAME %>"
			sortType="string"
			/>
	</th>
	<th nowrap>
	  <framework:sortColumnHeader
		 title="emxComponents.Common.Rev"
		 sortKey="<%=documentObject.SELECT_REVISION%>"
		 sortType="real"/>
	</th>
	<th nowrap>
	  <framework:sortColumnHeader
		 title="emxComponents.Common.Version"
		 sortKey="version"
		 sortType="real"/>
	</th>
	<th>
	  <emxUtil:i18n localize="i18nId">emxComponents.AttachmentsDialog.StateCondition</emxUtil:i18n>
	</th>
</tr>

<%
if (routableObjsList.size() == 0) {
  %>
<tr>
  <td align="center" colspan="13" class="error">
 		<emxUtil:i18n localize="i18nId">emxComponents.AddContent.NoContents</emxUtil:i18n>
  </td>
</tr>
  <%
} else {

  %>
  <!-- //XSSOK -->
<framework:mapListItr mapList="<%=routableObjsList%>" mapName="routableObjsMap">
  <%

 String objId = (String) routableObjsMap.get(documentObject.SELECT_ID);
documentObject.setId(objId);

String currState  = (String)documentObject.getInfo(context,documentObject.SELECT_CURRENT);
String selectedState = (String) routableObjsMap.get("selectedState");
if(UIUtil.isNullOrEmpty(selectedState)) {
	selectedState = (String)documentObject.getInfo(context,documentObject.SELECT_CURRENT);
}
sType = (String) routableObjsMap.get(documentObject.SELECT_TYPE);
 sPolicy  = (String) routableObjsMap.get(documentObject.SELECT_POLICY);
sStates  = routableObjsMap.get(documentObject.SELECT_STATES).toString();


 if(!(sStates.indexOf('[') <0 ) ) {
 sStates = sStates.substring(sStates.indexOf('[')+1,sStates.indexOf(']'));
 }

 strName  = (String) routableObjsMap.get(documentObject.SELECT_NAME);

if(sType.equals(DomainConstants.TYPE_DOCUMENT)) {

 sRev= (String) routableObjsMap.get(documentObject.SELECT_REVISION);
  sVer= (String) routableObjsMap.get("version");
} else { 

  //if(sType.equals(DomainConstants.TYPE_RTS_QUOTATION)) {
//strName= documentObject.getInfo(context, "to["+relRTSQuotation+"].from.name");
//buyerCompany  = documentObject.getInfo(context, "to["+relRTSQuotation+"].from.to["+relCompRFQ+"].from.to["+relRFQHolder+"].from.name");
//strName= buyerCompany+"/"+strName;
  //}
sRev  = (String)routableObjsMap.get(documentObject.SELECT_REVISION);
sVer  = (String)routableObjsMap.get("version");
if(sVer == null || "null".equals(sVer)){
sVer  = "";
}
}

//start of code added for the bug 313531
if(contentSelectArray.contains((String)routableObjsMap.get(documentObject.SELECT_ID))) { 
  contentSelected = "checked";
} else {
  contentSelected = "";
}
//end of code added for the bug 313531

%>

<tr class='<framework:swap id ="1" />'>
  <td style="font-size: 8pt" align="center">
  <!-- code modified for the bug 313531 -->
 <!-- //XSSOK -->
 <input type="checkbox" name="chkItem1" id="chkItem1" value ="<%=XSSUtil.encodeForHTMLAttribute(context,routableObjsMap.get(documentObject.SELECT_ID).toString())%>" onclick="updateCheckBox()" <%=contentSelected%> />
  </td>
  <td><%=XSSUtil.encodeForHTML(context,strName)%>&nbsp;</td>
  <td><%=sRev%>&nbsp;</td>
  <td><%=sVer%>&nbsp;</td>
  <td>
  <%
        //if(sType.equals(DomainConstants.TYPE_RTS_QUOTATION)|| !FrameworkUtil.hasAccess(context, documentObject, "promote")) {
		if(!FrameworkUtil.hasAccess(context, documentObject, "promote")) {
  %>
  <select name="stateSelect" id="<%=objId%>">
  <option value="<%=objId+"#"+sNoneValue+"None" %>" Selected> <%=i18nNow.getI18nString( "emxComponents.AttachmentsDialog.none", "emxComponentsStringResource",sLanguage)%> </option>
  </select>
  <%
}else{
%>
         <!-- //XSSOK -->
        
		 <%=populateCombo(context, session,sStates,  objId, sPolicy , sNoneValue,sLanguage , currState , selectedState, hashStateMap, documentObject)%>
<%
}
  %>
  </td>

</tr>
</framework:mapListItr>
  <%
}
  %>
</td>

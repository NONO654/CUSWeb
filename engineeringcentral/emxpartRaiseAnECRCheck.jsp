<%--  emxPartRaiseAnECRCheck.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@page import = "com.matrixone.apps.engineering.EngineeringUtil"%>
<%@ page import   = "com.matrixone.apps.engineering.EngineeringConstants"%>
<%@ page import   = "com.matrixone.apps.domain.DomainConstants"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%!    
    public String getObjectIds(String[] objectIds, String symbolToSplit, String symbolToConcat, int index) {
       String objectIdReturn = "";       
       
       int length = objectIds == null ? 0 : objectIds.length;
       
       for (int i = 0; i < length; i++) {
           
           if ("".equals(objectIdReturn)) {
               objectIdReturn = (String) FrameworkUtil.split(objectIds[i], symbolToSplit).get(index) + "|";
           } else {
               objectIdReturn += symbolToConcat + (String) FrameworkUtil.split(objectIds[i], symbolToSplit).get(index) + "|";
           }
       }
       
       return objectIdReturn;
    }
%>


<%
  boolean isMBOMInstalled = EngineeringUtil.isMBOMInstalled(context);
  Part part = (Part)DomainObject.newInstance(context,DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  String selectedParts = emxGetParameter(request, "selectedParts");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String objectId = emxGetParameter(request, "objectId");
  String suiteKey = emxGetParameter(request, "suiteKey");
  String sContextMode = emxGetParameter(request, "sContextMode");
  session.setAttribute("selectedParts",selectedParts);
  //X3 Start - Added for EBOM Substitute Mass Change
  String sEBOMSubChange = emxGetParameter(request, "ebomSubstituteChange");
  if (sEBOMSubChange == null) sEBOMSubChange="false";
  session.setAttribute("ebomSubstituteChange",sEBOMSubChange);
  //X3 End - Added for EBOM Substitute Mass Change
  // Added for Part where used indent table
  String closeParentWindow = emxGetParameter(request, "closeParentWindow");
  if (closeParentWindow == null || "".equals(closeParentWindow) || "null".equals(closeParentWindow)) {
	  closeParentWindow = "false";
  }
  String fromPartWhereUsed = emxGetParameter(request, "fromPartWhereUsed");
  if ("true".equals(fromPartWhereUsed)) {
      String selectedObjectIds[] = emxGetParameterValues(request, "emxTableRowId");       
      selectedParts = getObjectIds(selectedObjectIds, "|", ",", 1);  
  }
  // clear the session for the user attribs
  session.removeAttribute("searchECRprop_KEY");
  session.removeAttribute("attributeMap");
  session.removeAttribute("selectedECRprop");
  session.removeAttribute("dispAttribs");

  StringTokenizer sObjectIdTok = new StringTokenizer(selectedParts, ",",false);
  boolean bFailed = false;
  //Added for MBOM X3
  boolean noMFR = false;
  String  sTypeName = "";
//Added for IR-084750V6R2012
  String sDevPart = PropertyUtil.getSchemaProperty(context,"policy_DevelopmentPart");
  while (sObjectIdTok.hasMoreTokens()) {
    String passedId = sObjectIdTok.nextToken();

	//Added for Bug: 308765
	String stateRelease = com.matrixone.apps.engineering.EngineeringUtil.getReleaseState(context,DomainObject.POLICY_EC_PART);
    part.setId(passedId);
  //Added for MBOM X3  

  DomainObject pmObj = new DomainObject(passedId);
  String sPolicy = (String)pmObj.getInfo(context , DomainConstants.SELECT_POLICY);
  //Added for IR-084750V6R2012   starts 
   if(sDevPart.equals(sPolicy))
  {
     %>
       <script language="javascript">
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BOMPowerView.DevPartalertmessage</emxUtil:i18nScript>");
       closeWindow();
       </script>
     <% 
  return;
  }
  //Added for IR-084750V6R2012 ends
  if(isMBOMInstalled && sPolicy.equals(DomainConstants.POLICY_PART))
  {
   /* //query plants
	//PartMaster pm = new PartMaster();	
	java.lang.Class clazz = java.lang.Class.forName("com.matrixone.apps.mbom.PartMaster");
   	com.matrixone.apps.engineering.IPartMaster pm =(com.matrixone.apps.engineering.IPartMaster) clazz.newInstance();
	String strAsmPMId = pm.getPartMaster(context , passedId);

	if(strAsmPMId == null && ("").equals(strAsmPMId))
		{
		 noMFR = true;
		 break;
		}

	pmObj.setId(strAsmPMId); */
	StringList busSelect = new StringList(1);
	busSelect.add(DomainConstants.SELECT_ID);
	busSelect.add(EngineeringConstants.SELECT_PLANT_ID);

	MapList plantList = pmObj.getRelatedObjects(context,
									PropertyUtil.getSchemaProperty(context,"relationship_ManufacturingResponsibility"),
									PropertyUtil.getSchemaProperty(context,"type_Plant"),
													   busSelect,
													   null,
													   true,
													   false,
													   (short)1,
													   null,
													   null);

	if(plantList.size()<1 && sEBOMSubChange.equals("true"))
	  {
		noMFR = true;
	    break;
	  }
  }
   //End: Added for MBOM X3
    StringList strSelects = new StringList(3);
    strSelects.add(DomainConstants.SELECT_NAME);
    strSelects.add(DomainConstants.SELECT_TYPE);
    strSelects.add(DomainConstants.SELECT_VAULT);

    StringList strPartSelects = new StringList(DomainConstants.SELECT_ID);

    Map mapInfo = (Map) part.getInfo(context, strSelects);
String strWhereClause = "(current =="+DomainConstants.STATE_PART_RELEASE+") && (!((next.current == "+DomainConstants.STATE_PART_RELEASE+") || (next.current == "+DomainConstants.STATE_PART_OBSOLETE+")))";

 MapList mapListParts = DomainObject.findObjects(context,
                  (String) mapInfo.get(DomainConstants.SELECT_TYPE),
                  (String) mapInfo.get(DomainConstants.SELECT_NAME),
                  "*",
                  null,
                  "*",
                  strWhereClause,
                  false,
                  strPartSelects);

 boolean bReturn = false;

if (mapListParts.size() > 0)
{
	Map mapPart = (Map) mapListParts.get(0);
	String strId = (String) mapPart.get(DomainConstants.SELECT_ID);

	if (strId.equals(passedId.substring(0,passedId.indexOf("|"))))
	{
		bReturn = true;
	}
}

    if(!bReturn) {
      sTypeName = " " + part.getInfo(context,DomainConstants.SELECT_NAME) + " ";
      bFailed = true;
      break;
    }
   	//Added for MBOM X3
}
  
  if(isMBOMInstalled && noMFR)
		{
%>
  <script language="javascript">
	    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.WhereUsed.NoMR</emxUtil:i18nScript>");
	    closeWindow();
  </script>
<% }

  if(bFailed) {

%>
   <script language="javascript">
   //XSSOK
     alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.CommonAlert.ERROR</emxUtil:i18nScript><emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.WhereUsedSumary.StateLevelCheckAlert</emxUtil:i18nScript><%=sTypeName%><emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.WhereUsedSumary.StateCheckAlert1</emxUtil:i18nScript>");
     closeWindow();
   </script>
<%
  } else if (!noMFR) {
      String sRaiseECRURL = "emxpartRaiseAnECRWizardFS.jsp?jsTreeID=" + jsTreeID + "&objectId=" + objectId + "&suiteKey=" + suiteKey + "&sContextMode="+sContextMode+"";
%>
  
  <script language="javascript">
 //XSSOK
   if ("true" == "<%=XSSUtil.encodeForJavaScript(context,closeParentWindow)%>") {
	 //XSSOK
	   window.location.href = "<%=XSSUtil.encodeForJavaScript(context,sRaiseECRURL)%>";
   } else {
	 //XSSOK
	   emxShowModalDialog("<%=XSSUtil.encodeForJavaScript(context,sRaiseECRURL)%>",850, 630);
   }
  </script>
<%
  }
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>


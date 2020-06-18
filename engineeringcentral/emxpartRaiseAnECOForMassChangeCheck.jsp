<%--  emxpartRaiseAnECOForMassChangeCheck.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>

<%
  Part part = (Part)DomainObject.newInstance(context,DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  String selectedParts = emxGetParameter(request, "selectedParts");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String objectId = emxGetParameter(request, "objectId");
  String suiteKey = emxGetParameter(request, "suiteKey");
  String sContextMode = emxGetParameter(request, "sContextMode");
  session.setAttribute("selectedParts",selectedParts);
  //X3 Start - Added for EBOM Substitute Mass Change
  String sEBOMSubChange = emxGetParameter(request, "ebomSubstituteChange");
  
  String closeParentWindow = emxGetParameter(request, "closeParentWindow");
  if (closeParentWindow == null || "".equals(closeParentWindow) || "null".equals(closeParentWindow)) {
      closeParentWindow = "false";
  }
  
  if (sEBOMSubChange == null) sEBOMSubChange="false";
  session.setAttribute("ebomSubstituteChange",sEBOMSubChange);
  //X3 End - Added for EBOM Substitute Mass Change

  // clear the session for the user attribs
  session.removeAttribute("searchECRprop_KEY");
  session.removeAttribute("attributeMap");
  session.removeAttribute("selectedECRprop");
  session.removeAttribute("dispAttribs");

  StringTokenizer sObjectIdTok = new StringTokenizer(selectedParts, ",",false);
  boolean bFailed = false;
  String  sTypeName = "";
//Added for IR-084750V6R2012 starts
  String sDevPart = PropertyUtil.getSchemaProperty(context,"policy_DevelopmentPart");
  String strContextPolicy=DomainConstants.EMPTY_STRING;
  //Added for IR-084750V6R2012 ends
  while (sObjectIdTok.hasMoreTokens()) {
    String passedId = sObjectIdTok.nextToken();

	//Added for Bug: 308765
	String stateRelease = com.matrixone.apps.engineering.EngineeringUtil.getReleaseState(context,DomainObject.POLICY_EC_PART);
    part.setId(passedId);
  //Added for IR-084750V6R2012   starts 
    strContextPolicy   = part.getPolicy(context).getName();
    if(sDevPart.equals(strContextPolicy))
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
  }
  if(bFailed) {

%>
   <script language="javascript">
   //XSSOK
     alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.CommonAlert.ERROR</emxUtil:i18nScript><emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.WhereUsedSumary.StateLevelCheckAlert</emxUtil:i18nScript><%=sTypeName%><emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.WhereUsedSumary.StateCheckAlert1</emxUtil:i18nScript>");
     closeWindow();
   </script>
<%
  } else {
      String sRaiseECOURL = "emxpartRaiseAnECOWizardFS.jsp?jsTreeID=" + jsTreeID + "&objectId=" + objectId + "&suiteKey=" + suiteKey + "&sContextMode="+sContextMode+"";
%>

  <script language="javascript">
  //XSSOK
  if ("true" == "<%=XSSUtil.encodeForJavaScript(context,closeParentWindow)%>") {
	  //XSSOK
      window.location.href = "<%=XSSUtil.encodeForJavaScript(context,sRaiseECOURL)%>";
  } else {
	//XSSOK
	  emxShowModalDialog("<%=XSSUtil.encodeForJavaScript(context,sRaiseECOURL)%>",850, 630);
  }
  </script>
<%
  }
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>


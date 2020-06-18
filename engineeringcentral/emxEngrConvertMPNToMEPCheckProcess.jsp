<%--  emxEngrConvertMPNToMEPCheckProcess   -  
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "eServiceUtil.inc" %>
<%@include file = "emxengchgUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "emxengchgJavaScript.js"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc"%>

<%
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  
  String showModalDialog = "false";


  String url = null;
  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  if(checkBoxId != null )
  {
      String relObjId = checkBoxId[0];
      StringTokenizer st = new StringTokenizer(relObjId, "|");
      String sRelId = st.nextToken();
      String sObjId = st.nextToken();
      DomainObject dom = new DomainObject(sObjId);
      String mepType = dom.getInfo(context, DomainConstants.SELECT_TYPE);
      if(mepType.equals(DomainConstants.TYPE_MPN)){
          String placeholderMEP=emxGetParameter(request,"placeholderMEP");
          if("true".equalsIgnoreCase(placeholderMEP)) {
		showModalDialog = "true";
          url = "../common/emxFullSearch.jsp?field=TYPES=type_Part:POLICY=policy_ManufacturerEquivalent&table=MEPAddExistingResults&HelpMarker=emxhelpfullsearch&header=emxManufacturerEquivalentPart.GlobalSearch.ManufacturerPartSearchResults&hideHeader=false&suiteKey=ManufacturerEquivalentPart&from=FullTextSearch&objectId="+sObjId;
          url += "&showInitialResults=false&selection=single&submitURL=../engineeringcentral/emxEngrMEPartsAddExistingPartsProcess.jsp?placeholderMEP=true";

          } else {
          //url = "emxEngrCreateMfrEquivalentPartFromMPNDialogFS.jsp?objectId="+sObjId+"&suiteKey"+suiteKey;
          url = "../common/emxCreate.jsp?type=type_Part&form=AssignPartToPlaceholder&typeChooser=true&policy=policy_ManufacturerEquivalent&createJPO=jpo.manufacturerequivalentpart.Part:createPartToPlaceholder&showApply=true&header=emxEngineeringCentral.Command.AssignNewPartToPlaceholder&HelpMarker=emxhelpmpncreate&submitAction=refreshCaller&parentOID="+sObjId+"&suiteKey="+suiteKey;
          }
%>

    <script language="Javascript">
    //XSSOK
    if ("<%= showModalDialog%>" == "true") {
    	//XSSOK
        emxShowModalDialog('<%=XSSUtil.encodeForJavaScript(context,url)%>', 600, 600,true);
    } else {
    	//XSSOK
        getTopWindow().showSlideInDialog('<%=XSSUtil.encodeForJavaScript(context,url)%>', true);
    }
    </script>
<%
      }else{
%>
    <script language="Javascript">
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.PleaseSelectMPNItem</emxUtil:i18nScript>");
    </script>
<%
    }
   }
%>

<%@include file = "emxDesignBottomInclude.inc"%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


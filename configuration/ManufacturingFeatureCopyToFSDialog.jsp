<%--
  ManufacturingFeatureCopyToFSDialog.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%@page import = "java.util.*"%>
<%@page import="com.matrixone.apps.domain.DomainObject" %>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle" %>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>

<script>
var action = "";
</script>
<%
  //Retrieves Objectid in context
  String strObjectId = emxGetParameter(request, "objectId"); //source
  String strObjectIdToBeConnected = emxGetParameter(request, "objectIdTobeconnected"); //destination
  String appendParams = emxGetQueryString(request);
  String share = emxGetParameter(request, "share");
  String clone = emxGetParameter(request, "clone");
  String sProgramTable = null;
  String sAll = emxGetParameter(request, "All");
  String sSelObjName = emxGetParameter(request, "selObjName");
  java.util.HashMap selectedValues = (HashMap)session.getAttribute("selectedValues");
  selectedValues.put("selObjId", strObjectId);
  selectedValues.put("selObjName", sSelObjName);
  selectedValues.put("All", sAll);
  selectedValues.put("share",share);
  selectedValues.put("clone",clone);

  String suiteKey = emxGetParameter(request, "suiteKey");
  ArrayList  includedOption=new ArrayList();
  
  String IncludedData = EnoviaResourceBundle.getProperty(context,"eServiceSuite"+suiteKey + ".ManufacturingFeatureCopyTo.IncludedData");
  StringTokenizer st = new StringTokenizer(IncludedData);
  while(st.hasMoreTokens())
  {
    String Value=st.nextToken(",");
    String sOptValue = emxGetParameter(request, Value);
    selectedValues.put(Value,sOptValue);
 }

  session.setAttribute("selectedValues",selectedValues);
  //check propety setting for enabling cross the level selection
  String strEnableMultilvel = EnoviaResourceBundle.getProperty(context,"emxConfiguration.Copy.MultiLevelSelection.Enabled");

  sProgramTable = "expandProgram=ManufacturingFeature:getManufacturingFeatureStructure&table=FTRManufacturingFeaturesTable";
  
%>

<script>
  var objIDtobeConnected = "<%= XSSUtil.encodeForJavaScript(context,strObjectIdToBeConnected )%>";
</script>
<%
   String strBodyURL = "../common/emxIndentedTable.jsp?suiteKey=Configuration&HelpMarker=emxhelpfeaturecopyto&showHeader=false&objectId="+strObjectId+"&" + sProgramTable + "&MasterFTRShow=false&selection=single&mode=edit&toolbar=FTRManufacturingFeatureCopyToStepTwoMenu";
%>

<html>
<body style="height:100%" >
   <form name="CopyTo" method="post" id="VariantFSDialogPage" style="height:1%;min-height:1%">
   <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
   </form>
   <iframe src="<xss:encodeForHTMLAttribute><%=strBodyURL%></xss:encodeForHTMLAttribute>" height="100%" width="100%" frameborder="0" scrolling="no" name="FeatureSelection">
   </iframe>
</body>
<SCRIPT language="javascript" type="text/javaScript">
  
  function movePrevious() 
  {
     var formName = document.CopyTo;
     formName.target = "_top";
     formName.action="../components/emxCommonFS.jsp?functionality=ManufacturingFeatureCopyTo&HelpMarker=emxhelpcopytotechnicalfeature&suiteKey=Configuration&objectIdTobeconnected=" + objIDtobeConnected + "&fromPrevious=true";
     formName.submit();
  }

  function closeWindow()
  {
       var formName = document.CopyTo;
       parent.window.closeWindow();
  }  
</SCRIPT>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
   
</html>

<%--
  GBOMUpdateDVValuePostProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
 --%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.configuration.Part"%>
<%@page import="com.matrixone.apps.configuration.ProductConfiguration"%>

<html>
<head>
    <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
    <script language="Javascript" src="../common/scripts/emxUICore.js"></script>
    <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
    <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
</head>
<body>
<%
try{
	String strObjectId = emxGetParameter(request, "objectId");
    String arrRelIds[] = null;
    String strGBOMRelId = "";
    boolean bool= false;
    String param = emxGetParameter(request, "param");
    String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");

    //Get the GBOMrelId from the session if present
    strGBOMRelId = (String)session.getAttribute("GBOMRelId");

    if(param!=null && param.equals("search") )
    {
        strGBOMRelId = null;
    }

    //After the selection of Product Configuration
    if(strGBOMRelId !=null && param == null)
    {
         StringTokenizer objIDs = new StringTokenizer(arrTableRowIds[0],"|");
         String strPCId = objIDs.nextToken();
         String lfeatureId = emxGetParameter(request, "lfeatureId");
          //Invoke method from Part bean to update the values
          //Part.updateDVValuesFromConfiguration(context,strGBOMRelId,lfeatureId, strPCId);
          String strEffectivity = ProductConfiguration.getEffectivityExpression(context,strPCId,lfeatureId,strGBOMRelId);
          // empty the effectivity before updating the Design Variant Values.
          //if the Effectivity is empty then set the expression directly.
          if(strEffectivity!=null && !strEffectivity.equals("")){
        	  //TODO - CLEAR EFFECTIVITY DECOUPLE MODE----
//        	  com.matrixone.apps.effectivity.EffectivityFramework Eff = new com.matrixone.apps.effectivity.EffectivityFramework();   
  //      	  Eff.setRelExpression(context,strGBOMRelId,"");
          }
          ProductConfiguration.setEffectivityExpressionOnGBOMRel(context, lfeatureId, strPCId, strGBOMRelId);
          Part.updateDuplicatePartXML(context,lfeatureId);
          ProductConfiguration.deltaUpdateBOMXMLAttributeOnPC(context,lfeatureId,"GBOMUpdate");
          bool=true;
          session.removeAttribute("GBOMRelId");
    }
    //First time in the this from command Update Design Variant Vaues Action Link
    else if (param.equals("search"))
    { 
        //Retrieve  selected Part Id and its relId
         arrRelIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("RelId");       
         strGBOMRelId = arrRelIds[0];
      
         //set the selected PartId and its relId into session 
         session.setAttribute("GBOMRelId", strGBOMRelId);
         String strProductId=emxGetParameter(request, "prodId"); 
         //Invoke the Search Product Configuration Page           
%>
         <script language="javascript" type="text/javaScript">     
         var url='../common/emxFullSearch.jsp?field=TYPES=type_ProductConfiguration&table=FTRSearchProductConfigurationsTable&includeOIDprogram=emxFTRPart:includePCBasedOn&showInitialResults=false&selection=single&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&mode=Chooser&chooserType=CustomChooser&fieldNameActual=tmpname&fieldNameDisplay=tmpname&formName=tmpname&frameName=tmpname&suiteKey=Configuration&objectId=<%=XSSUtil.encodeForURL(context,strProductId)%>&lfeatureId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&submitURL=../configuration/GBOMUpdateDVValuePostProcess.jsp';    
         getTopWindow().window.showModalDialog(url,850,630,true,'Medium');
         </script>
<%
    }
    if(bool)
    {
%>
    <script language="javascript" type="text/javaScript">
    getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
    getTopWindow().window.closeWindow();
   </script>
<%
    }
}
catch(Exception e)
{
	throw new FrameworkException(e);
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

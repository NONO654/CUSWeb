<%--  ManufacturingFeatureReplacePreProcess.jsp
   Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<html>
<body leftmargin="1" rightmargin="1" topmargin="1" bottommargin="1" scroll="no">
<%--Breaks without the useBean--%>
<%@ page import = "java.util.StringTokenizer"%>
<%@page import = "matrix.db.Context" %>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.util.*"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.configuration.Part"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="matrix.db.JPO"%>
<%@page import="java.util.Map"%>



  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<%

try
{
   
    String strMode    = emxGetParameter(request, "mode");
    String jsTreeID = emxGetParameter(request,"jsTreeID");  
    String suiteKey = emxGetParameter(request,"suiteKey");    
    String regisateredSuite = emxGetParameter(request,"SuiteDirectory");    
    String initSource = emxGetParameter(request,"initSource");
    String strObjectId    = emxGetParameter(request, "objectId");
    String strContext    = emxGetParameter(request, "context");
    //String strParentOId = emxGetParameter(request, "parentOID");
    String strProductId = emxGetParameter(request, "parentOID");    
    String objType = "";
    String timeStamp = emxGetParameter(request, "timeStamp");
    
   
   
    Part partBean = new Part();
    LogicalFeature logicalFeature = new LogicalFeature();
    if(strMode.equalsIgnoreCase("Replace"))
    {

        try
        {
            
                String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
                String strRelId = "";
                String strFeatureId = "";
                String strParentId = "";
                boolean showPopup = false;


                    StringTokenizer strRowIdTZ = new StringTokenizer(strTableRowIds[0],"|");
                    if(strRowIdTZ.countTokens()>2)
                    {
                        strRelId = strRowIdTZ.nextToken();
                        strFeatureId = strRowIdTZ.nextToken();
                        strParentId = strRowIdTZ.nextToken();
                    }
                    else
                    {
                        strRelId = strRowIdTZ.nextToken();
                        strFeatureId = strRowIdTZ.nextToken();
                    }
                

                if(strParentId.equals("") || strParentId.equals(strFeatureId))
                {
                    %>
                    <script>
                       alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.CannotPerform</emxUtil:i18nScript>");
                    </script>
                    <%
                }
                else
                    showPopup = true;
                
                             
                if(showPopup)
                {
                    // TODO Need to change this code to call the showModalDialog / showNonModalDialog javascript function with appropriate popup size
                    %>     
                    <body>   
                    <form name="FTRManufacturingFeatureReplace" method="post">
                    <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
                    <input type="hidden" name="tableIdArray" value="<xss:encodeForHTMLAttribute><%=strTableRowIds%></xss:encodeForHTMLAttribute>" />         
                    <script language="Javascript">
                        //window.open('about:blank','newWin','height=575,width=575');
                        //document.FTRManufacturingFeatureReplace.target="newWin";                      
                        //document.FTRManufacturingFeatureReplace.action="../components/emxCommonFS.jsp?functionality=ManufacturingFeatureReplace&suiteKey=Configuration&HelpMarker=emxhelpfeaturesplitreplace&featureType=Manufacturing&objIdContext=<%=XSSUtil.encodeForURL(context,strContext)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&objectId=<%=XSSUtil.encodeForURL(context,strFeatureId)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>&strProdId=<%=XSSUtil.encodeForURL(context,strProductId)%>&RelId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
                        //document.FTRManufacturingFeatureReplace.submit();
                        
                    var strURL = "../components/emxCommonFS.jsp?functionality=ManufacturingFeatureReplace&suiteKey=Configuration&HelpMarker=emxhelpfeaturesplitreplace&featureType=Manufacturing&objIdContext=<%=XSSUtil.encodeForURL(context,strContext)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&objectId=<%=XSSUtil.encodeForURL(context,strFeatureId)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>&strProdId=<%=XSSUtil.encodeForURL(context,strProductId)%>&RelId=<%=XSSUtil.encodeForURL(context,strRelId)%>";        
                    showModalDialog(strURL, 700, 500,true,'Medium');
                                           
                    </script>     
                    </form>
                    </body>         
                    <%
                }
   
        }
        catch(Exception e)
        {
            e.printStackTrace();
            %>
            <Script>
            alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.Exception</emxUtil:i18nScript>");
            </Script>
            <%
        }
    }
}

catch(Exception ex) 
{

    session.putValue("error.message", ex.getMessage());
} 
%>
</body>
</html>

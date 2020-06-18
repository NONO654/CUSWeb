
<%--  GBOMReplacePreProcess.jsp-- Will redirect to GBOMReplaceDialog with proper params
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
--%>

<%@include file= "../common/emxNavigatorInclude.inc"%>
<%@include file= "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import="com.matrixone.apps.configuration.Part"%>

<html>
<head>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

</head>
<%  
    String strParentOID = (String)emxGetParameter(request, "objectId");
    //String strSourceGBOMRelID = "";
    String strMode = (String)emxGetParameter(request, "mode");
    String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
    StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
    String strSourceGBOMRelID = strTokenizer.nextToken();
    String strObjectId = strTokenizer.nextToken();
    
    
       Part sourcePart = new Part();
       //XSSOK, strParentOID is used in API to create domain object and strSourceGBOMRelID is taken from emxGetParameterValues
       String url = sourcePart.urlReplaceGBOMCommand(context, strParentOID, strSourceGBOMRelID, strMode, strObjectId);
       %>     
       <body>   
       <form name="FTRGBOMReplace" method="post">
       <input type="hidden" name="tableIdArray" value="" />
       <script language="Javascript">
           var href = "<%=XSSUtil.encodeForJavaScript(context,url)%>"; 
           //showDetailsPopup(href);
           showModalDialog(href, 875, 550,true,'Large');                       
       </script>     
       </form>
       </body>         
       <%    
%>


<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>


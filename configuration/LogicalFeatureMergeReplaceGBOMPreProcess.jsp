<%--  LogicalFeatureMergeReplaceGBOMPreProcess.jsp
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

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><html>
<body leftmargin="1" rightmargin="1" topmargin="1" bottommargin="1" scroll="no">
<%--Breaks without the useBean--%>

<%@page import = "java.util.StringTokenizer"%>
<%@page import = "matrix.db.Context" %>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
try
{
    String strMode    = emxGetParameter(request, "mode");
    String jsTreeID = emxGetParameter(request,"jsTreeID");  
    String initSource = emxGetParameter(request,"initSource");
    String strObjectId    = emxGetParameter(request, "objectId");
    String strProductId = emxGetParameter(request, "prodId");
   
    String strCancel = i18nNow.getI18nString("emxProduct.Button.Cancel",
            "emxConfigurationStringResource",request.getHeader("Accept-Language"));

    String strDone = i18nNow.getI18nString("emxProduct.Button.Done",
            "emxConfigurationStringResource",request.getHeader("Accept-Language"));
    LogicalFeature logicalFeature = new LogicalFeature();
    
    
    if(strMode.equalsIgnoreCase("MergeReplace"))
    {
    	String objectId = strObjectId;  
    	MapList removedPartList = (MapList) session.getAttribute("removedParts");
        String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
        // variable to store rel and obj ids
        String strRelIds[] = new String[strTableRowIds.length];
        String strObjIds[] = new String[strTableRowIds.length];          
        // Seperate the Obj and Rel Ids  
        
        for(int i =0; i< strTableRowIds.length ; i++)
        {
            String strRowId = strTableRowIds[i];
            StringTokenizer strRowIdTZ = new StringTokenizer(strRowId,"|");
            strObjIds[i] = strRowIdTZ.nextToken();
            strRelIds[i] = strRowIdTZ.nextToken();              
        }          
        if (initSource == null)
         {
                initSource = "";
         }
        Map urlData = new HashMap();
        urlData.put("strProductId",strProductId);
        urlData.put("initSource",initSource);
        urlData.put("jsTreeID",jsTreeID);
        urlData.put("objectId",objectId);
        urlData.put("strDone",strDone);
        urlData.put("strCancel",strCancel);
        urlData.put("strObjIds",strObjIds);
        urlData.put("removedPartList",removedPartList);
        String contentURL = logicalFeature.URLforMergeReplace(context,urlData ,"GBOMtable");
        
        %>
       <html>
       <body style="height:100%" >
        <iframe  src="<%=XSSUtil.encodeURLwithParsing(context,contentURL)%>" height="100%" width="100%" frameborder="0" scrolling="no" name="FeatureGBOM">
        </iframe>
       </body>
       </html>
        <%
    	
    }       

}
     
     catch(Exception e)
     {
      
       if(session.getAttribute("error.message") == null){
          session.putValue("error.message", e.toString());
       }
      
     }
finally
{
%>
<script>
window.parent.getTopWindow().getWindowOpener().parent.getTopWindow().closeWindow();
</script>
<%
}
 %>
   
</body>
</html>

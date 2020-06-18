
<%--
    RenameCommonGroupPreProcess.jsp
	Copyright (c) 1993-2018 Dassault Systemes.
	All Rights Reserved.
	This program contains proprietary and trade secret information of
	Dassault Systemes.
	Copyright notice is precautionary only and does not evidence any actual
	or intended publication of such program
	AddCommonGroupPostProcess.jsp
--%>



<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="java.util.StringTokenizer"%>
<%@page import="java.util.HashMap"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
 <jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
String timeStamp = emxGetParameter(request, "timeStamp");
HashMap requestMap = (HashMap) indentedTableBean.getRequestMap(timeStamp);
String objectId = emxGetParameter(request,"objectId"); //Design Variant ID
String relId = emxGetParameter(request,"relId"); //rel Id between LF and DV
String strFromWhere = emxGetParameter(request,"fromWhere");
String parentOID = (String)requestMap.get("parentOID");
String jsTreeID = emxGetParameter(request,"jsTreeID");  
String initSource = emxGetParameter(request,"initSource");
String[] strSelectedCGs  = emxGetParameterValues(request ,"emxTableRowIdActual");
 try{
	 if(strFromWhere.equalsIgnoreCase("ConfigurationOptionContext")){
         %>
         <script language="javascript" type="text/javaScript"> 
         var timeStamp = '<%=XSSUtil.encodeForJavaScript(context,timeStamp)%>'; 
         var objectId = '<%=XSSUtil.encodeForJavaScript(context,objectId)%>'; 
         var relId = '<%=XSSUtil.encodeForJavaScript(context,relId)%>'; 
         var parentOID = '<%=XSSUtil.encodeForJavaScript(context,parentOID)%>';
         var initSource = '<%=XSSUtil.encodeForJavaScript(context,initSource)%>';
         var jsTreeID = '<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>';         
         var url= "../components/emxCommonFS.jsp?functionality=RenameCommonGroup&fromWhere=ConfigurationOptionContext&timeStamp="+timeStamp
         +"&objectId="+objectId+"&relId="+relId+"&parentOID="+parentOID+"&SuiteDirectory=Configuration&suiteKey=Configuration&initSource="+initSource+"&jsTreeID="+jsTreeID;
         showNonModalDialog(url,860,600,true, '', 'Medium');
         </script>
        <%
    }else if(strFromWhere.equalsIgnoreCase("StructureBrowser")){
        String strCGsToRename="";
        boolean bFlag = true;
        if(strSelectedCGs == null ){
            bFlag = false;
            %>
                <script language="javascript">
                alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.MustSelectAtLeastOne</emxUtil:i18n>"); 
                </script>
            <%          
        }else {
            for(int iCnt = 0 ; iCnt < strSelectedCGs.length ; iCnt++){

            StringTokenizer strTokens = new StringTokenizer(strSelectedCGs[iCnt] , "|");
            String strCGIds = strTokens.nextToken();
            
            if (!"".equals(strCGsToRename) && strCGIds.indexOf("&") != -1){
                strCGsToRename = strCGsToRename +"|"+strCGIds.substring(0,strCGIds.indexOf("&"));
            }else{
                  int iLastPosition= strCGIds.indexOf("&");
                  if(iLastPosition>=0){
                     strCGsToRename  = strCGIds.substring(0,iLastPosition);
                  }else{
                    %>
	                     <script language="javascript" type="text/javaScript"> 
	                     alert("<emxUtil:i18n localize="i18nId">emxProduct.Alert.InvalidSelection</emxUtil:i18n>");
	                     window.getTopWindow().location.href = window.getTopWindow().location.href ;
	                    </script>
                    <%
                     bFlag=false;
                 }
             }
          }//end FOR
        }//end Else
        if(bFlag){
        	session.setAttribute("emxTableRowIdActual",strSelectedCGs);
        %>
           <script language="javascript" type="text/javaScript"> 
	        var timeStamp = '<%=XSSUtil.encodeForJavaScript(context,timeStamp)%>'; 
	        var objectId = '<%=XSSUtil.encodeForJavaScript(context,objectId)%>'; 
	        var relId = '<%=XSSUtil.encodeForJavaScript(context,relId)%>'; 
	        var parentOID = '<%=XSSUtil.encodeForJavaScript(context,parentOID)%>';
	        var initSource = '<%=XSSUtil.encodeForJavaScript(context,initSource)%>';
	        var jsTreeID = '<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>';    
	        var url= "../components/emxCommonFS.jsp?functionality=RenameCommonGroup&fromWhere=StructureBrowser&timeStamp="+timeStamp
            +"&objectId="+objectId+"&relId="+relId+"&parentOID="+parentOID+"&SuiteDirectory=Configuration&suiteKey=Configuration&initSource="+initSource+"&jsTreeID="+jsTreeID;
	        showNonModalDialog(url,860,600,true, '', 'Medium');
	        </script>
	    <%
        }
    }
	 
 }catch(Exception e){
	   e.printStackTrace();
	   session.putValue("error.message", e.getMessage());
	   //emxNavErrorObject.addMessage(e.toString().trim());
	 }// End of main Try-catck block  
	 
     %>	 
   
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%--  PortalIntermediate.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<!--  
	@quickreview HAT1 ZUD 17:12:22 : IR-531745-3DEXPERIENCER2018x: R20-NLS: Name and Revision on the Traceability windows is No Translated. 
	@quickreview HAT1 ZUD 18:01:24 : IR-576654-3DEXPERIENCER2018x: R20-STP: Traceability command from the Requirement category of the product shows Error when invoked without selecting requirements.  
-->


<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>  


<%
String contentURL = "";
String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
String emxRows = "RowInfo=";
String objectId = "";  //HAT1 ZUD IR-531745-3DEXPERIENCER2018x fix.
String emxTempRows = "";

//HAT1 ZUD IR-531745-3DEXPERIENCER2018x fix.

//Collect all the parameters to forward them 
StringBuffer sfb = new StringBuffer();
int paramind = 1;
Enumeration enumParamNames = emxGetParameterNames(request);
while(enumParamNames.hasMoreElements()) 
{
    String paramName = (String) enumParamNames.nextElement();
    String paramValue = emxGetParameter(request, paramName);
    if(paramValue != null && !"null".equals(paramValue) && !"".equals(paramValue) ) 
    {
    	if(paramind > 1)
            sfb.append("&");

        sfb.append(paramName);
        sfb.append("=");
        sfb.append(paramValue);
        paramind++;
     }
}

String appendParams = sfb.toString();
 //

// Populate the RowInfo parameters
if (tableRowIdList != null)
{
   int numRows = tableRowIdList.length;
   for(int kk = 0; kk < numRows; kk ++)
   {
	   if(kk == 0){
		   emxTempRows += tableRowIdList[kk];
	   }
	   else{
		   emxTempRows += "%3A" + tableRowIdList[kk];
	   }  
   }
   
   emxRows += emxTempRows;
   //IR-576654-3DEXPERIENCER2018x fix.
   String[] objId = tableRowIdList[0].split("[|]");
   objectId = "&objectId=" + objId[1];
}

contentURL = "../common/emxPortal.jsp?"+appendParams+"&"+emxRows+objectId;  //HAT1 ZUD IR-531745-3DEXPERIENCER2018x fix.

%>

<script language="JavaScript" type="text/javascript">
document.location.href = '<%=XSSUtil.encodeForJavaScript(context, contentURL)%>';
</script>



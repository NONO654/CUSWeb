<%--  emxEngrSearchIntermediateProcess.jsp -  This page displays clock in search result page on deletion
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>


<% 
  String languageStr = emxGetParameter(request,"languageStr");
  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String timeStamp = emxGetParameter(request, "timeStamp");
  String fullTextSearch = emxGetParameter(request, "fullTextSearch");
  String suiteKey     = emxGetParameter(request,"suiteKey");  
  //Added for MultiPart Creation
  if(suiteKey == null || "".equals(suiteKey) || "null".equals(suiteKey)) {
   suiteKey = "eServiceSuiteEngineeringCentral";
  }
  String initSource  = emxGetParameter(request,"initSource");
  String[] selPartIds = emxGetParameterValues(request, "emxTableRowId");  
  String ImageData = emxGetParameter(request, "ImageData");
  String createMode = emxGetParameter(request, "createMode");
  String[] checkBoxId =new String[selPartIds.length];
  //Start: 375954
  String struiType =  emxGetParameter(request,"uiType");
  String strIds ="";
  Map levelIdMap      = new HashMap();
  //End: 375954
  String selectedId = "";
   if(selPartIds != null)
    {
           for (int i=0; i < selPartIds.length ;i++)
           {
             StringTokenizer strTokens = new StringTokenizer(selPartIds[i],"|");
             if (strTokens.hasMoreTokens())
             {
                selectedId = strTokens.nextToken();
                if(selPartIds.length >1)
                //IR-036950 - Starts
                //strIds +=selectedId+"|";
				strIds +=selectedId+"~";
				//IR-036950 - Ends
                else
                	strIds +=selectedId;
               //checkBoxId[i] =(String)selectedId;
               //Start: 375954
               if(struiType!=null && !struiType.equalsIgnoreCase("table")){
                levelIdMap.put(selectedId, strTokens.nextToken());
               }
               //End: 375954
             }//End of if loop
            }//End of for loop
    }//End of if loop
 
    String url ="../common/emxIndentedTable.jsp?table=ENCPartSearchEditDetails&HelpMarker=emxhelppartsearchresultsedit&program=emxECSearchMassUpdate:getPartSearchEditDetails&toolbar=EmptyMenu&preProcessJPO=emxPart:checkLicense&hideRMBCommands=true&mode=edit&hideHeader=false&ImageData=" 
    		+ ImageData +"&initSource="+initSource+"&jsTreeID="+jsTreeID+"&languageStr="+languageStr+"&timeStamp="+timeStamp+"&suiteKey="+suiteKey+"&selection=multiple";
    if("ENG".equals(createMode) || "LIB".equals(createMode) || "MFG".equals(createMode)){
        url+="&header=emxEngineeringCentral.CreatePart.MyEngViewEditPartTitle&createMode="+createMode;
    }else{
        url+="&header=emxEngineeringCentral.CreatePart.MyEngViewEditPartTitle";
    }
  //R212 change: show only Custom Table View icon and Help Marker in the toolbar
  url+="&showSavedQuery=false&searchCollectionEnabled=false&massPromoteDemote=false&multiColumnSort=false&triggerValidation=false&showClipboard=false&objectCompare=false&export=false&autoFilter=false&printerFriendly=false&displayView=details&fromPage=MyEngineeringView&postProcessJPO=enoPartManagement:massPartUpdate";
%>

  
   <%@include file = "emxDesignBottomInclude.inc" %>
    
  <html>
  <head>
  </head>
  <body>
  <form id='formid' method="post" > 
  <input type="hidden" name="objIds" value="<xss:encodeForHTMLAttribute><%=strIds%></xss:encodeForHTMLAttribute>"/>
  </form>
  </body>
  </html>

<script language="Javascript">
//XSSOK
	var sURL = "<%=XSSUtil.encodeForJavaScript(context,url)%>";
	document.forms["formid"].action=sURL;
	document.forms["formid"].submit();   
</script>
         
 
 
 


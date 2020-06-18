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
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.util.PartMgtUtil"%>
<% 
  String languageStr = emxGetParameter(request, "languageStr");
  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String timeStamp = emxGetParameter(request, "timeStamp");
  String initSource  = emxGetParameter(request,"initSource");
  String[] selPartIds = emxGetParameterValues(request, "emxTableRowId");
  String[] checkBoxId =new String[selPartIds.length];
  StringList sObjectsList = new StringList();
  //Start: 375954
  String struiType =  emxGetParameter(request,"uiType");
  Map levelIdMap      = new HashMap();
  Map revMap      = new HashMap();
  //End: 375954
   if(selPartIds != null)
    {
		   for (int i=0; i < selPartIds.length ;i++)
		   {
			 StringTokenizer strTokens = new StringTokenizer(selPartIds[i],"|");
			 if (strTokens.hasMoreTokens())
			 {
			   String selectedId = strTokens.nextToken();
			   sObjectsList.add((String)selectedId);
			  
			   //Start: 375954
			   if(struiType!=null && !"table".equalsIgnoreCase(struiType)){
			   levelIdMap.put(selectedId, strTokens.nextToken());
			   }
			   //End: 375954
			 }//End of if loop
			}//End of for loop
	}//End of if loop
	 HashMap paramMap = new HashMap();
     paramMap.put("deleteObjects", sObjectsList);
     String[] methodargs = JPO.packArgs(paramMap);
     StringList retMap =PartMgtUtil.getObjectRevisionsInOrder(context, sObjectsList);
    
     for (int i = 0; i < retMap.size(); i++) {
    	 checkBoxId[i] = (String)retMap.get(i);
     }
  session.setAttribute("emxTableRowId",checkBoxId);
  //Start: 375954
  if(!struiType.equalsIgnoreCase("table")){
  session.setAttribute("emxTableRowLevelId",levelIdMap);
  //End: 375954
  }
%>
<body>
  <form name="hFrm" method="post" action="emxEngrSearchDeleteProcess.jsp">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
    <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="initSource" value="<xss:encodeForHTMLAttribute><%=initSource%></xss:encodeForHTMLAttribute>" />
    <!-- 375954 : adding uiType as hidden parameter -->
    <input type="hidden" name="uiType" value="<xss:encodeForHTMLAttribute><%=struiType%></xss:encodeForHTMLAttribute>" />
    <script language="javascript">
    var frameName = findFrame(getTopWindow(),"listHead");
	if(frameName !=null){
    var divElement =  frameName.document.getElementById('imgProgressDiv');
    divElement.style.visibility = 'visible';
	}
    document.hFrm.submit(); 
 </script>
 </form>
 </body>
</html>


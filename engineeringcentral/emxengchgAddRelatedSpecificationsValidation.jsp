<%--  emxengchgAddRelatedSpecificationsValidation.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null) {
	initSource = "";
  }
  
  long timeinMilli = System.currentTimeMillis();
  String objectId = emxGetParameter(request,"objectId");
  String emxTableRowId = emxGetParameter(request,"emxTableRowId");
  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  String helpmarker= emxGetParameter(request,"HelpMarker");
  
  String sObjId = "";
  StringBuffer sbSelectedRows = new StringBuffer();
  if(checkBoxId != null ) {
      try {
          StringTokenizer st = null;
          String sRelId = "";
          
          for(int i=0;i<checkBoxId.length;i++) {
              if(checkBoxId[i].indexOf("|") != -1) {
                  st = new StringTokenizer(checkBoxId[i], "|");
                  sRelId = st.nextToken();
                  sObjId = st.nextToken();
              } else {
                  sObjId = checkBoxId[i];
              }
              DomainObject domObj = DomainObject.newInstance(context);
              domObj.setId(sObjId);
              String strBlValue = domObj.getInfo(context,"from["+DomainConstants.RELATIONSHIP_PART_SPECIFICATION+"]");
              if(strBlValue !=null && strBlValue.equals("True")){
            	  sbSelectedRows.append(sObjId);
            	  
            	  if( i != (checkBoxId.length-1) )
            	  sbSelectedRows.append(",");
              }
              
          }
      } catch (Exception e) {
          session.setAttribute("error.message", e.getMessage());
      }
  } 

	if( sbSelectedRows != null && sbSelectedRows.length() > 0 ){					
		String contentURL = "../common/emxIndentedTable.jsp?program=emxECO:getAddRelatedSpecificationsWithRelSelectables&header=emxEngineeringCentral.AffectedItems.AddRelatedSpecificationsHeader&table=ENCAffectedItemsAddPartSpecificationsList&expandLevelFilter=true&sortColumnName=Related Part&direction=from&Export=false&submitLabel=emxEngineeringCentral.Button.Submit&cancelLabel=emxEngineeringCentral.Common.Cancel&Registered Suite=EngineeringCentral&suiteKey=EngineeringCentral&selection=multiple&showPageURLIcon=false&HelpMarker="+helpmarker+"&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&massPromoteDemote=false&triggerValidation=false&customize=false&submitURL=../engineeringcentral/emxengchgAddRelatedProcess.jsp";
	%>
		<form name="addRelated" method="post" target="_parent">
			<input type="hidden" name="strChangeObjId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
			<input type="hidden" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=emxTableRowId%></xss:encodeForHTMLAttribute>" />
			<input type="hidden" name="sbSelectedRows" value="<xss:encodeForHTMLAttribute><%=sbSelectedRows%></xss:encodeForHTMLAttribute>" />
		</form>	
		<script language="Javascript">
			//XSSOK
			window.open('about:blank','newWin' + "<%=timeinMilli%>",'height=500,width=800,resizable=yes');
			//XSSOK
			document.addRelated.target="newWin" + "<%=timeinMilli%>";
			//XSSOK
			document.addRelated.action = "<%=XSSUtil.encodeForJavaScript(context,contentURL)%>";
			document.addRelated.submit();
			closeWindow();
		</script>
	<%
	} else {
	%>
		   <script language="Javascript">
		   alert("<emxUtil:i18nScript  localize="i18nId">emxEngineeringCentral.Alert.AddRelated</emxUtil:i18nScript>");
		   </script>
	<%
	}
	%>
	

<%--  emxEngrPartPortalRefresh.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
--%>


<%@include file = "../emxUICommonAppInclude.inc"%>
<%
String fromEditPartPage   = emxGetParameter(request, "fromEditPartPage");

%>	
<script>
var fromEditPartPage="<%=fromEditPartPage%>";

if(fromEditPartPage=="true"){
	setTimeout(function(){ 
			window.parent.parent.location.href=window.parent.parent.location.href;	
		}, 0);
	
}
else{
	var frameName=findFrame(window.parent.parent, "ENCRelatedItem");
	var displaymode=frameName.displayMode; 
	
	if(displaymode == null || displaymode == "null" || displaymode == "" ){
	     frameName=findFrame(window.parent.parent, "ENC3DPlay");
	     displaymode=frameName.displayMode;    
	  }  
	if(displaymode != null || displaymode != "null" || displaymode != "" ){
		frameName.location.href = frameName.location.href;
	} 
}
</script>

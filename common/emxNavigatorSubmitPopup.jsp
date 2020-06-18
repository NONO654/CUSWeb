<%--  emxNavigatorSubmitPopup.jsp   - Page for poping up a window from an actin link page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxNavigatorSubmitPopup.jsp.rca 1.8 Tue Oct 28 22:59:40 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>

<html>
<head><title><%=sAppName%></title>
<script language="JavaScript" src="scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/emxUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript">
<%
     String targetLocation = emxGetParameter(request, "targetLocation");
     String frameName = emxGetParameter(request,"frameName");
%>
var frameName="<xss:encodeForJavaScript><%=frameName%></xss:encodeForJavaScript>";
function submitSpecialForm(){
	var targetLocation = "<xss:encodeForJavaScript><%=targetLocation%></xss:encodeForJavaScript>";
	var objListWindow = findFrame(getTopWindow().getWindowOpener(), "listDisplay");
/* added for getting the proper frame using frame name*/
	if(!objListWindow){
			  objListWindow = findFrame(getTopWindow().getWindowOpener().parent, frameName);
			  var objListChildWindow = findFrame(objListWindow, "listDisplay");
			  if(!objListChildWindow){
				  objListChildWindow = findFrame(objListWindow, "formViewDisplay");
			  }	
			  if(!objListChildWindow){
				  objListChildWindow = findFrame(objListWindow, "formEditDisplay");
			  }  
			  objListWindow = objListChildWindow ? objListChildWindow : objListWindow;
		}
	if(!objListWindow){
	   objListWindow=findFrame(parent.getWindowOpener().parent, "formViewDisplay");
	   if(!objListWindow){
	        objListWindow = parent.getWindowOpener().parent.frames['formEditDisplay'];
	   }
	
	   if(!objListWindow){
	        objListWindow = parent.getWindowOpener().parent;
	   }
	}

   var objForm = objListWindow.document.forms['emxSubmitForm'] ? objListWindow.document.forms['emxSubmitForm'] : objListWindow.document.forms[0];
   var strURL=objForm.action;
   
   if(objForm.timeStamp){
	   strURL += "&timeStamp=" + objForm.timeStamp.value;
   }
   <%if(targetLocation != null && !targetLocation.equals("")) {%>
       strURL +="&targetLocation="+targetLocation;
   <%}%>
   var locform = document.forms[0];
   var inputElements = objForm.getElementsByTagName("input");
   for(var i = 0 ; i < inputElements.length; i++)
   {
	   if((inputElements[i].type == "checkbox" || inputElements[i].type == "radio") && !inputElements[i].checked){
		   continue;
	   }
		if(inputElements[i].name != "toolbar" && inputElements[i].name != "categoryTreeName" && inputElements[i].name != "treeMenu"){	   	
	   var clonedItem   = document.createElement('input');
   	   clonedItem.type  = "hidden";
	   clonedItem.name  = inputElements[i].name;
	   clonedItem.value = inputElements[i].value;
	   locform.appendChild(clonedItem);		   
		}	
   }
   
   locform.action = strURL;
   locform.method = "post";
   
   addSecureToken(locform);
   locform.submit();
   removeSecureToken(locform);
}

</script>
</head>

<body onload="submitSpecialForm()">
<form name="localForm" action="" method="post">
</form>
</body>
</html>


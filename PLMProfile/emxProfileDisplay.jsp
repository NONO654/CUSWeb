<%--  emxProfileDisplay.jsp
--%>
<%@ include file = "../emxUICommonAppInclude.inc"%>

<%@ page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>
<%@ page import = "com.matrixone.apps.domain.util.PropertyUtil"%>
<%@ page import = "java.util.Map"%>
<%@ page import = "java.util.List"%>
<%@ page import = "java.util.Iterator"%>
<%@ page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@ page import="java.net.URLEncoder" %>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >   
<script language="javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<link href="../common/styles/emxUIDefault.css" rel="stylesheet">
<link href="../common/styles/emxUIMenu.css" rel="stylesheet">
<link href="../common/styles/emxUIToolbar.css" rel="stylesheet">
<link href="../common/styles/emxUIDOMLayout.css" rel="stylesheet">
<link href="../common/styles/emxUIDOMDialog.css" rel="stylesheet">
<link href="../common/styles/emxUIDialog.css" rel="stylesheet">
<link href="../common/styles/emxUIForm.css" rel="stylesheet">
<link href="../common/styles/emxUICalendar.css" rel="stylesheet">
<link href="../common/styles/emxUITypeAhead.css" rel="stylesheet">
<%
System.out.println("Begin emxProfileDisplay.jsp");
String form = emxGetParameter(request,"form");
String objectId = emxGetParameter(request,"objectId");
String languageStr      = request.getHeader("Accept-Language");
String requiredName = EnoviaResourceBundle.getProperty(context, "emxComponents.Common.NameError", "emxComponentsStringResource", languageStr);
System.out.println("form "+form);
System.out.println("objectId "+objectId);
System.out.println("End emxProfileDisplay.jsp");
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript">
function cloneEntity() {
	parent.document.getElementById("imgProgressDiv").style.visibility = "visible";
	var xmlhttp;
    if (window.XMLHttpRequest) { 
		xmlhttp=new XMLHttpRequest();
    } else if (window.ActiveXObject) {
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    } else {
		alert("Your browser does not support XMLHTTP!");
    }
    xmlhttp.onreadystatechange=function() {
		if(xmlhttp.readyState==4 && xmlhttp.status==200){
			parent.document.getElementById("imgProgressDiv").style.visibility = "hidden";
			var errorProfile = xmlhttp.responseXML.getElementsByTagName("errorProfile");
			if (errorProfile != null && errorProfile.length > 0) {
				$.each(errorProfile, function() {
					alert($(this).text());
				});
			} else {
				getTopWindow().refreshTablePage();
				getTopWindow().closeSlideInDialog();
			}
		}
	}
	var name=$('#Name').val();
	if(name.length != 0) {
		xmlhttp.open("GET","emxProfileProcess.jsp?command=clone&objectId=<%=objectId%>&profileName="+encodeURIComponent(name)
						+"&importList="+$('#attrImportList').val()+"&description="+encodeURIComponent($('#Description').val()),true);
	} else if(name.length == 0) {
		alert("<%=requiredName%>");
	}
	xmlhttp.send(null);
}
function createEntity() {
	parent.document.getElementById("imgProgressDiv").style.visibility = "visible";
	var xmlhttp;
    if (window.XMLHttpRequest) { 
		xmlhttp=new XMLHttpRequest();
    } else if (window.ActiveXObject) {
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    } else {
		alert("Your browser does not support XMLHTTP!");
    }
    xmlhttp.onreadystatechange=function() {
		if(xmlhttp.readyState==4 && xmlhttp.status==200){
			parent.document.getElementById("imgProgressDiv").style.visibility = "hidden";
			var createdProfile = xmlhttp.responseXML.getElementsByTagName("createdProfile");
			if (createdProfile != null && createdProfile.length > 0) {
				var profileId = "";
				$.each(createdProfile, function() {
					profileId = $(this).text();
				});
				getTopWindow().refreshTablePage();
				var contentFrame = getTopWindow().findFrame(getTopWindow(),"content");
				if(contentFrame){
					contentFrame.document.location.href = "../common/emxTree.jsp?mode=replace&objectId="+profileId;
				}
			} else {
				alert("Error during the profile creation");
				getTopWindow().refreshTablePage();
			}
			getTopWindow().closeSlideInDialog();
		}
	}
	var name=$('#attrName').val();
	if(name.length != 0) {
		xmlhttp.open("GET","emxProfileProcess.jsp?command=create&profileName="+encodeURIComponent(name)+"&description="+encodeURIComponent($('#attrDescription').val()),true);
	} else if(name.length == 0) {
		alert("<%=requiredName%>");
	}
	xmlhttp.send(null);
}
</script>
</head>
<body onload="pageInit()" class="editable slide-in-panel">
	<form name="emxProfileGenericForm" action="<rg:writePreProcessPageSubmitAction/>" method="post" style="margin:0px;padding:0px;">
		<div id="searchPage">
			<jsp:include page = "../common/emxFormEditDisplay.jsp" flush="true">
  				<jsp:param name="form" value="<%=form%>"/>
				<jsp:param name="mode" value="edit"/>
				<jsp:param name="targetLocation" value="slidein"/>
  			</jsp:include>
  		</div>
	</form>
 </body>

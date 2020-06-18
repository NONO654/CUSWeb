<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<%@ page import="java.util.Enumeration"%>
 <%
  
 String objectId = request.getParameter("objectId");

 %>
 <script>
	var objectId = "<%=objectId%>";
		//alert(window.parent.parent.document.getElementById("iframeContent").contentWindow.location.href);
	//window.parent.parent.document.getElementById("iframeContent").contentWindow.document.getElementById("iframeLeft").contentWindow.location.href = "../cssc/csscBOMList.jsp?objectId="+objectId;
	window.parent.parent.document.getElementById("iframeContent").contentWindow.reLoadBOMList(objectId);
	window.parent.parent.document.getElementById("iframeContent").contentWindow.location.href = "../cssc/csscCaptures.jsp?objectId="+objectId;
 </script>

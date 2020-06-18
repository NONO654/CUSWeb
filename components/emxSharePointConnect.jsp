<%@include file="../common/emxNavigatorInclude.inc"%>
<%@ page import="ds.enovia.apps.msf.sharePointConnect.SharePointController" %>


<!DOCTYPE html>
<html>
<body onload="webLoad();">

	<script>
		function webLoad() {
		
			<%
				try {

					SharePointController controller = new SharePointController(request);
			%> 
					alert("<%= (null == controller.IsFaulted() ? "App token registered successfully" : ("Controller faulted: " + controller.getTraces())) %>");
			<%	
				} catch(Exception ex) {	
			%>		
					alert("Exception occurred: " + "<%=ex.getMessage() %>");
			<%	
				}
			%>	
			
			window.open("emxSharePointRegistration.jsp", "_self");

		}
	</script>

</body>
</html>

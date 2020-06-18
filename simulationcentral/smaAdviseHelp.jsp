<%--  smaAdviseHelp.jsp - file to display Results Analytics help and tutorials.
 * (c) Dassault Systemes, 2013
 *
--%>
<html>
<head>
	<script	src="../plugins/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>
	<script src="./smaAdviseHelp.js" type="text/javascript"></script>
	
	<link rel="stylesheet" type="text/css" href="./styles/smaAdviseHelp.css">
</head>
<body>
	 <div class="sim-ui-advise-tutorial">
		<div class="sim-ui-advise-tutorial-prev"></div>
		<div class="sim-ui-advise-tutorial-image"></div>
		<div class="sim-ui-advise-tutorial-next"></div>
		<div class="sim-ui-advise-tutorial-close"></div>
		<div class="sim-ui-advise-tutorial-dontShow"></div>
	</div>
	<script>
		var tutorialTopic = <%=request.getParameter("topic")%>;
		jQuery(document).ready(function() { launchHelp(tutorialTopic); });
	</script>
</body>
</html>

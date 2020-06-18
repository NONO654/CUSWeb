<%--  IEFTreeTableContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<html>
<body>
	<script language="javascript">
		parent.loadPage("");

		var headerFrame = parent.frames['headerDisplay'];
		if(headerFrame && headerFrame.document && headerFrame.document.imgProgress)
			headerFrame.document.imgProgress.src = "./images/utilSpace.gif";
	</script>
</body>
</html>

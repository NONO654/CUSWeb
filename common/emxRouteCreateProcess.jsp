<%@ include file="../emxUICommonAppInclude.inc"%> 
<%@page import="java.util.*"%>
<%@page import="matrix.db.*"%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.apps.domain.util.*"%>


<%	
	String sRecipients		= "";
	String aRecipients[]	= emxGetParameterValues(request, "recipients");
	String sTitle			= request.getParameter("title");
	String sInstructions	= request.getParameter("instructions");
	String sDueDate			= request.getParameter("duedate");
	String sRequired		= request.getParameter("required");
	String sAction			= request.getParameter("action");
	String sIds				= request.getParameter("ids");
	String sStart			= request.getParameter("start");
	
	if(null != aRecipients) {
		for(int i = 0; i < aRecipients.length; i++) {
			sRecipients += aRecipients[i] + ";";
		}
	}
	
	if(null == sTitle)			{ sTitle = ""; }
	if(null == sInstructions)	{ sInstructions = ""; }
	if(null == sDueDate) 		{ sDueDate 		= ""; }
	if(null == sAction) 		{ sAction 		= ""; }
	if(null == sIds) 			{ sIds 		= ""; }

	
	String initargs[] = {};
	HashMap params = new HashMap();
	params.put("recipients"		, sRecipients	);
	params.put("title"			, sTitle		);
	params.put("instructions"	, sInstructions	);
	params.put("duedate"		, sDueDate		);
	params.put("required"		, sRequired		);
	params.put("action"			, sAction		);
	params.put("ids"			, sIds			);
	params.put("start"			, sStart		);
		
	String sOIDRoute = (String)JPO.invoke(context, "emxDashboardRoutes", initargs, "createRoute", JPO.packArgs (params), String.class);		

%>

<html>
	<body>
		<script language="javascript" src="../common/scripts/emxUIFormUtil.js"></script>
		<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
		<script type="text/javascript">
			var posLeft = (screen.width  / 2 ) - 425;
			var posTop  = (screen.height / 2 ) - 350;
			window.open('../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, sOIDRoute)%>', '', 'height=700,width=950,top=' + posTop + ',left=' + posLeft + ',toolbar=no,directories=no,status=no,menubar=no;return false;');
			self.closeWindow();
		</script>
	</body>
</html>

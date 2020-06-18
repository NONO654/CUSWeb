<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ page import="java.util.*,com.jspsmart.upload.*,java.io.*,java.text.*"%> 
<%@ page import="matrix.util.UUID,matrix.db.RelationshipType,com.matrixone.servlet.Framework,matrix.db.Context,com.matrixone.apps.domain.DomainObject,com.matrixone.apps.domain.util.PersonUtil,matrix.util.MatrixException,com.matrixone.apps.domain.util.ContextUtil,com.matrixone.apps.domain.util.FrameworkException,com.matrixone.apps.domain.util.MqlUtil,com.matrixone.apps.domain.util.ContextUtil,com.matrixone.apps.domain.DomainRelationship"%>
<%@ page import="jxl.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "CSICTreeUtilInclude.inc" %>
<html> 
<head> 
	<title></title> 
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> 
</head>
<body> 
<% 
	String fieldNameActual=request.getParameter("fieldNameActual");
	String fieldName ="";
	if(fieldNameActual!=null &&fieldNameActual.length()>0){
		fieldName = fieldNameActual.substring(0, fieldNameActual.indexOf("_"));
	}
	context = Framework.getFrameContext(session);
	String oids = request.getParameter("objectId");
	String shipScop = request.getParameter("shipScop");
	
	try {
		
		String[] ids = oids.split(",");
		for(int i = 0;i<ids.length;i++){
			System.out.println("------------------>>>1");
			if(shipScop!=null && shipScop.length()>0){
				System.out.println("ids[i]-------1-----"+ids[i]);
				System.out.println("shipScop------1------"+shipScop);
				ContextUtil.pushContext(context);
				String strMQL = "modify bus "+ids[i]+"  PLMEntity.V_description '"+shipScop+"'";
				ContextUtil.popContext(context);
			
				MqlUtil.mqlCommand(context,strMQL);
			}
			
		}
	} catch (Exception e) {
	%>
		
	<%
	 
	}
	%> 


</body> 
<script type="text/javascript">
var fieldNameActual = "<%=fieldNameActual%>";
var fieldName = "<%=fieldName%>";
var shipScop = "<%=shipScop%>";
window.close();
window.parent.parent.opener.document.getElementsByName(fieldName)[0].value = shipScop;
window.parent.parent.opener.document.getElementsByName(fieldNameActual)[0].value = shipScop;
window.close();

</script>
</html> 
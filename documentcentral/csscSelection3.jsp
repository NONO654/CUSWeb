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
	<title>文件上传处理页面</title> 
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> 
</head>
<body> 
<% 
	context = Framework.getFrameContext(session);
	String oids = request.getParameter("objectId");
	
	String shipScop = request.getParameter("shipScop");
	
	try {
		
		String[] ids = oids.split(",");
		for(int i = 0;i<ids.length;i++){
			
			if(shipScop!=null && shipScop.length()>0){
				String strMQL = "modify bus "+ids[i]+"  PLMEntity.V_description '"+shipScop+"'";
				System.out.println("strMQL-------------"+strMQL);
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
window.close();
</script>
</html> 
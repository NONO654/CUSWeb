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
	String mode = "";
	String relFilePath = "";
	SimpleDateFormat format = new SimpleDateFormat("yyyyMMddhhmmss");
	Date myDate = new Date();
	String tempname = format.format(myDate);
			 
	// 新建一个SmartUpload对象 
	SmartUpload su = new SmartUpload(); 
	// 上传初始化 
	su.initialize(pageContext); 
	// 设定上传限制 
	// 1.限制每个上传文件的最大长度。 
	// su.setMaxFileSize(100000000); 
	// 2.限制总上传数据的长度。 
	// su.setTotalMaxFileSize(20000); 
	// 3.设定允许上传的文件（通过扩展名限制）,仅允许doc,txt文件。 
	   su.setAllowedFilesList("xlsx"); 
	// 4.设定禁止上传的文件（通过扩展名限制）,禁止上传带有exe,bat,jsp,htm,html扩展名的文件和没有扩展名的文件。 
	// su.setDeniedFilesList("exe,bat,jsp,htm,html"); 
	su.upload();
	try {
		//改名开始
		com.jspsmart.upload.File myfile =  su.getFiles().getFile(0);
		String filename = su.getFiles().getFile(0).getFileName();
		String prefix=filename.substring(filename.lastIndexOf(".")+1);
		if(!"xlsx".equals(prefix)&&!"xls".equals(prefix)){
		%>
			<script type="text/javascript">
				window.opener.location.reload();
				alert("请导入正确的类型，只支持.xlsx或.xls文件类型。");
				window.close();
			</script>
		<%
			return;
		}
			
		
		mode = su.getRequest().getParameter("mode");
		String objectId = request.getParameter("objectId");
					
		if (myfile.getFileExt().length()>0) {
			String temp_FileName = "tempname" + "."+prefix;//这儿在日期字符串加上了一个标识符
			myfile.saveAs("/upload/"+temp_FileName,su.SAVE_VIRTUAL);
			String strPathFile = request.getSession().getServletContext().getRealPath("/");
			relFilePath = strPathFile+"upload/" + temp_FileName;	
			HashMap<String, String> paramMap = new HashMap<String, String>(2);
		
			paramMap.put("relFilePath", relFilePath);
		
			
			paramMap.put("mode", mode);
			paramMap.put("objectId", objectId);
			System.out.println("CSICImportDesignStructure:importWorkSpace------------->>>");
			String information = (String)JPO.invoke(context, "CSICImportDesignStructure", new String [] {}, "importWorkSpace", JPO.packArgs(paramMap),String.class);
			
			
			System.out.println("information__" + information);
			if("OK".equals(information)) {
			%>
				<script type="text/javascript">
					window.opener.location.reload();
					alert("导入完成，请关闭。");
					window.close();
				</script>
			<%
			} else if("ERROR".equals(information)){
			%>
				<script type="text/javascript">
					window.opener.location.reload();
					alert("导入出现问题，请重新导入。");
					window.close();
				</script>
				
			<%
			}else{
			%>	
				<script type="text/javascript">
					
					alert("<%=information%>");
					window.close();
				</script>
			<%
			}
		}
	} catch (Exception e) {
	%>
		<script type="text/javascript">
			window.opener.location.reload();
			alert("导入出现问题，请重新导入。");
			window.close();
		</script>
				
	<%
	//out.println(e.toString());  
	}
	%> 


</body> 
</html> 
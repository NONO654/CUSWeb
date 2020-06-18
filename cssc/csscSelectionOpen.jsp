<%@page contentType="text/html;charset=utf-8"%>
<%@page	import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,java.io.PrintWriter"%>
<%@page	import="java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>
<html>
<%
	String objectId="";
	String[]  strSelectedCollections = FrameworkUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId"));
	System.out.println("strSelectedCollections------"+strSelectedCollections.length);
	if(strSelectedCollections.length==0){
		System.out.println("ERROR");
		PrintWriter ps = response.getWriter();
		ps.write("<script>alert('请选择对象！')</script>");
		ps.write("<script>window.close()</script>");
		ps.flush();
		return;
	}
	
	for(int i = 0;i<strSelectedCollections.length;i++){
			objectId += strSelectedCollections[i]+",";
	} 
%>
<script>
	 
	// openwin("csscSelection.jsp?objectId="+objectId,"适用船型及范围",800,700);
	
	
	var oid = "<%=objectId%>";

		
        var openUrl = "csscSelection.jsp?objectId="+oid;//弹出窗口的url  
        var iWidth=900; //弹出窗口的宽度;  
        var iHeight=700; //弹出窗口的高度;  
        var iTop = (window.screen.availHeight-30-iHeight)/2; //获得窗口的垂直位置;  
        var iLeft = (window.screen.availWidth-10-iWidth)/2; //获得窗口的水平位置;  
        window.open(openUrl,"","height="+iHeight+", width="+iWidth+", top="+iTop+", left="+iLeft);   
		
 
</script>
</html>
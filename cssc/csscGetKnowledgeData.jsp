<%@page contentType="text/html;charset=utf-8"%>
<%@page
	import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.framework.ui.UIUtil,matrix.db.Person,java.io.File"%>
<%@page
	import="java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>
<%
	Context context = Framework.getFrameContext(session);
	String [] ids = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
	String selectId = ids[0];
	
	
	
	
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
	<body>
		<form id="formPage" action="csscGetKnowledgeDataSubmit.jsp" method="post"/>
		<input type="hidden" name="oid" id="oid" value=""/>
		<input type="hidden" name="selectId" id="selectId" value="<%=selectId%>"/>
	</body>
</html>
 <script language="javascript">
	var selectId = "<%=selectId%>";
	var dataVal = findFrame(getTopWindow(),"CSSCShowKnowledgeLibCommand").document.getElementsByName("emxTableRowIdActual");
	var values = "";
	var flg = "FALSE";
	for (var i = 0; i < dataVal.length; i++) {
		if (dataVal[i].checked) {
			if(dataVal[i].value!=null && dataVal[i].value!=""){
				flg = "TRUE";
			}
			values+=dataVal[i].value+"]";
		}
	}
	
	if(flg=="FALSE"){
		alert("请选择工艺知识库引用数据！");
	}
	values = "]]"+values;

	document.getElementById("oid").value = values;
	document.getElementById("formPage").submit();

 </script>	
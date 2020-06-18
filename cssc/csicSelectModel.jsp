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
	response.setContentType("text/html;charset=UTF-8");
	String objectId = request.getParameter("objectId");
	System.out.println("objectId-----"+objectId);
	try{
		
		DomainObject dom = DomainObject.newInstance(context);
		
		String [] ids = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
		for(int i = 0;i<ids.length;i++){
		dom.setId(ids[i]);
		ContextUtil.pushContext(context);
		dom.connectFrom(context, "Classified Item", new DomainObject(objectId));
		ContextUtil.popContext(context);
		System.out.println(ids[i]);
		}
	} catch(Exception e) {
		e.printStackTrace();
	}
%>

 <script language="javascript">
	window.parent.parent.opener.location.href = win
<%@page import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.common.Company,com.matrixone.apps.common.Person,com.matrixone.apps.program.Task"%>
<%@page
    import="java.util.Set,java.util.HashSet,java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*,com.matrixone.apps.framework.ui.UIUtil"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>
<%@page contentType="text/html;charset=utf-8"%>
<%!
	public  String getAsiccString(String str) {
		String resultString = "";
		try {
			if(UIUtil.isNotNullAndNotEmpty(str)) {
				char[] s=str.toCharArray();
				for(int o = 0;o<s.length;o++) {
					int value=Integer.valueOf(s[o]);
					resultString+=value;
				}
			}
			
		}catch(Exception e) {
			e.printStackTrace();
		}
		System.out.println("resultString---"+resultString);
		return resultString;
	}

%>
<%
	response.setContentType("text/html;charset=UTF-8");
	Context context = Framework.getFrameContext(session);
	Enumeration<String> paraNames = request.getParameterNames(); 

while(paraNames.hasMoreElements()){ 
    String paraKey = paraNames.nextElement(); 
    String paraValue  = request.getParameter(paraKey); 
    System.out.println(paraKey + "=" + paraValue); 
}
	
	String information = "";
	DomainObject taskDom = DomainObject.newInstance(context);
	
	try 
	{
		String objectId = request.getParameter("objectId");
		 
		taskDom.setId(objectId);
		//String related  = MqlUtil.mqlCommand(context,"print bus "+objectId+" select to[CSSCClassifiedItem] dump");
		HashMap paramMap = new HashMap();
		paramMap.put("objectId",objectId);
		String resultMap = (String)JPO.invoke(context, "CSSCSystemOperationJPO", new String [] { }, "createObject", JPO.packArgs(paramMap),String.class);  

		
	
	
	}catch(Exception e){
		e.printStackTrace();
	}	
		
%>
	

	<script type="text/javascript">
			window.parent.location.href=window.parent.location.href;
		
	</script>
	
	

	
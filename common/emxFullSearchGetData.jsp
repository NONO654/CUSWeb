<%@ page import = "matrix.db.*,matrix.util.*,com.matrixone.servlet.Framework,java.util.*,java.io.*,com.matrixone.apps.domain.util.*,com.matrixone.apps.framework.ui.*,javax.json.*,com.matrixone.enovia.bps.search.SearchNextGen" %>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%@include file = "emxNavigatorInclude.inc"%>
<%
	String redirectToSnN = Request.getParameter(request, "action");
	
		out.clear();
		try{
		Enumeration eNumParameters = emxGetParameterNames(request);
		com.matrixone.enovia.bps.search.SearchNextGen searchNextGen = new SearchNextGen(context, request, eNumParameters);
		String queryType = (String)emxGetParameter(request,"queryType");
		
		
		if(searchNextGen.getRedirectToSnN() && (queryType == null || queryType.equals("Indexed"))){
				JsonObject refinementForSnN = searchNextGen.getRefinementForSnN(); 
				out.print(refinementForSnN);
		}else{
			out.print("");
			}
		}catch(Throwable t){
			out.print(UISearchUtil.buildJsonForException(t));
		}
	%>
		


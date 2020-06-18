
<%@page import="com.dassault_systemes.enovia.bom.modeler.util.BOMMgtUtil"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../emxContentTypeInclude.inc" %>

<%
String relIdList = (String)request.getParameter("relIdList");
Enumeration en1 = request.getParameterNames();
while(en1.hasMoreElements()) {
	String reqParam = (String)en1.nextElement();
	String value = (String)request.getParameter(reqParam);
	relIdList = value;
}
	String selPartRowId = "";
	String sFailedMessage = "";
	out.clear();
	response.setContentType("text/plain");
	
	try {
		
		if(relIdList != null && !"null".equals(relIdList)){
			String[] arrayOfRelToSort = relIdList.split("~");
			if(arrayOfRelToSort.length >0) {
				LinkedList lList = new LinkedList(Arrays.asList(arrayOfRelToSort));
				BOMMgtUtil.persistBOMOrderFromJSP(context, lList, new LinkedList());
			}
		}
		out.clear();
	}
	catch (Exception e) {
		out.clear();
		out.write(e.getMessage());
	}
  
%>
 

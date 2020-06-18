<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS"  %>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
	String parent = emxGetParameter(request,"role_parent");
    if(parent==null) parent = "";
    String name = emxGetParameter(request,"PLM_ExternalID");
    String desc = emxGetParameter(request,"v_id");
    if(desc==null) desc = " ";
        
    Map role = new HashMap();
    Map fin = new HashMap();
	fin.put("method","createRole");
	 
    role.put("role_Parent",parent);
    role.put("v_id",desc);
    role.put("PLM_ExternalID",name);
    role.put("Solution","VPM");
    fin.put("iRoleInfo",role);
      
    // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
    ClientWithoutWS client = new ClientWithoutWS(mainContext);
    Map ret = client.serviceCall(fin);
    int resultat = ((Integer)ret.get("resultat")).intValue();

    if(resultat==0){
    	String message = name + " " +getNLSMessageWithParameter("CONF_HasBeenCreated","Role");
       	%>
        	<jsp:forward page="emxPLMOnlineAdminCreateRole.jsp">
            	<jsp:param name="message" value="<%=message%>"/>
        	</jsp:forward>
 	<%}else if (resultat==2){
        String message = getNLSMessageWithParameter("ERR_IDCannotBeEmpty","RoleName");
   	%>
        <jsp:forward page="emxPLMOnlineAdminCreateRole.jsp">
            <jsp:param name="message" value="<%=message%>"/>
        </jsp:forward>
    <%}else if (resultat==3){
        String message = getNLSMessageWithParameter("ERR_IDAlreadyExist","Role");%>
        <jsp:forward page="emxPLMOnlineAdminCreateRole.jsp">
            <jsp:param name="message" value="<%=message%>"/>
        </jsp:forward>
    <%}else if (resultat==1){
        String message = getNLS("ERR_CreationRight");
    %>
        <jsp:forward page="emxPLMOnlineAdminCreateRole.jsp">
            <jsp:param name="message" value="<%=message%>" />
        </jsp:forward>
    <%}%>


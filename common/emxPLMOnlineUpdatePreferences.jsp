<%--
    Document   : emxPLMOnlineUpdatePreferences.jsp
    Author     : LXM
    Modified : 01/10/2010 -> Remove the query before update (New WS spec)
--%>
<%@ page import="matrix.db.Context" %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="java.net.URLEncoder" %>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>    
        <%
        String form = emxGetParameter(request,"group");
        Map person = new HashMap();

        Map update = new HashMap();
	  update.put("method","updatePerson");
        person.put("Preferences",form);
        person.put("PLM_ExternalID",mainContext.getUser());
        update.put("iPersonInfo",person);
      
        // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
        ClientWithoutWS client = new ClientWithoutWS(mainContext);
        Map result = client.serviceCall(update);
        Integer res = (Integer)result.get("resultat");

        String resTemp =   res.toString();
        boolean resultat = resTemp.equals("0");
        if(resultat == true){
            if(!form.contains("ctx::"))form = "ctx::"+form;
           mainContext.resetRole(form);
           %>
           <jsp:forward page="emxPLMOnlinePreferences.jsp">
               <jsp:param name="message" value="Your Default Context has been updated!"></jsp:param>
               <jsp:param name="Preferences" value="<%=form%>"></jsp:param>
           </jsp:forward>
        <%}else{%>
           <jsp:forward page="emxPLMOnlinePreferences.jsp">
               <jsp:param name="message" value="Unable to update your default Context!"></jsp:param>
           </jsp:forward>
        <%}%>
   </body>
</html>






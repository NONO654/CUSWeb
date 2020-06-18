<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosDisciplineServices" %>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.IPLMxPosResourceManager" %>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosManagerAccess" %>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.IPLMxPosDiscipline" %>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<html>
  <head> 
     <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body>
  <%
        String disciplines = emxGetParameter(request,"disciplines");
        String parentdiscipline = emxGetParameter(request,"parentDisciplines");

        if (parentdiscipline == null ) parentdiscipline="";
         
        String[] subDisciplines = disciplines.split(",,");

        if(parentdiscipline.equals("")){
            for(int i = 1; i < subDisciplines.length ; i++){
                manageContextTransaction(mainContext,"start");

                IPLMxPosResourceManager irm = PLMxPosManagerAccess.getResourceManager();
                IPLMxPosDiscipline disc = irm.createDiscipline(mainContext,subDisciplines[i],subDisciplines[i]);

                manageContextTransaction(mainContext,"end");
            }
          }else{
            for(int i = 1; i < subDisciplines.length ; i++){
                manageContextTransaction(mainContext,"start");
                int res =PLMxPosDisciplineServices.createSubDiscipline(mainContext,parentdiscipline,subDisciplines[i],subDisciplines[i]);
                manageContextTransaction(mainContext,"end");
            }
          }

        if(!parentdiscipline.equals("")){
        %>
            <jsp:forward page="emxPLMOnlineAdminDisciplineDetails.jsp">
                <jsp:param name="disc" value="<%=parentdiscipline%>"></jsp:param>
                <jsp:param name="source" value="notRoot"></jsp:param>
            </jsp:forward>
        <%}else{%>
            <jsp:forward page="emxPLMOnlineAdminDisciplineDetails.jsp">
                <jsp:param name="disc" value="<%=parentdiscipline%>"></jsp:param>
            </jsp:forward>
        <%}%>
  </body>
</html>

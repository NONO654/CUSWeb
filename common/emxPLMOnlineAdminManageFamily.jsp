<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosTableServices" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>  
    <%
        String method =emxGetParameter(request,"method");
        String editValues = emxGetParameter(request,"edit");
        String addValues =emxGetParameter(request,"add");

        if (editValues == null)editValues = "";
        if (addValues == null)addValues = "";
 String Description="";
        int ret = -1;
        int retAddMessage = -1;
        String message="";
        
        
            if (editValues != ""){
              
                String[] valueOneByOne = editValues.split(",SEP,");
                Integer[] rowOrders = new Integer[valueOneByOne.length];

                for(int i = 0 ; i <valueOneByOne.length ; i++){
                     Description="";
                    String ValueNameID[] = valueOneByOne[i].split(";;");
                 
                    if(ValueNameID.length==3){Description=ValueNameID[2];}
                    if (Description.equals(""))Description=" ";

                    manageContextTransaction(mainContext,"start");
                    ret = PLMxPosTableServices.addMessageToSecurityLevel(mainContext,"Family",ValueNameID[1], Description);
                    manageContextTransaction(mainContext,"end");
                }

                if (ret == -1){
                    message = "Couldn't edit the rows";
                }
            }

            if (addValues != ""){
                  
                String[] valueOneByOne = addValues.split(",SEP,");
                Description = "";
                for(int i = 0 ; i <valueOneByOne.length ; i++){
                    String ValueNameID[] = valueOneByOne[i].split(";;");

                    if(ValueNameID.length == 2)Description=ValueNameID[1];
                    if (Description.equals(""))Description=" ";

                    manageContextTransaction(mainContext,"start");
                   
                    ret=PLMxPosTableServices.addRowToTable(mainContext, "Family",ValueNameID[0] , ValueNameID[0], PLMxPosTableServices.rowType_String, new Integer(i));
                    PLMxPosTableServices.addFamilyToSolution(mainContext, ValueNameID[0], "VPM");
                    retAddMessage = PLMxPosTableServices.addMessageToSecurityLevel(mainContext,"Family",ValueNameID[0],Description );
                    manageContextTransaction(mainContext,"end");
                    if (ret == -1){
                        message = "Couldn't add rows";
                    }
                }
             }
  
   %>
   <jsp:forward page="emxPLMOnlineAdminFamily.jsp">
       <jsp:param name="Message" value="<%=message%>"></jsp:param>
   </jsp:forward>
  </body>
</html>

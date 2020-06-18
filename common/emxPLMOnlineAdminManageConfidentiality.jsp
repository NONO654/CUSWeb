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

        int retAddMessage = -1;
        String message="";
        String Description="";

        if(method.equals("delete")){
            manageContextTransaction(mainContext,"start");
            String val =emxGetParameter(request,"values");
            int res = PLMxPosTableServices.removeRowFromTable(mainContext, val);
            if (res == - 1){
                message = "Couldn't delete this row";
            }
            manageContextTransaction(mainContext,"end");
        }else{
            if (editValues != ""){
                String[] valueOneByOne = editValues.split(",SEP,");
                StringList ids = new StringList();
                StringList level = new StringList();
                StringList alias = new StringList();
                StringList rowTypes = new StringList();
                Integer[] rowOrders = new Integer[valueOneByOne.length];

                for(int i = 0 ; i <valueOneByOne.length ; i++){
                    String ValueNameID[] = valueOneByOne[i].split(";;");
                  
                    ids.addElement(ValueNameID[0]);   
                    level.addElement(ValueNameID[1]);
                    alias.addElement(ValueNameID[2]);
                          
                    rowTypes.addElement(PLMxPosTableServices.rowType_Integer);
                    rowOrders[i]=Integer.parseInt(ValueNameID[1]);

                    if(ValueNameID.length==4)Description=ValueNameID[3];
                    manageContextTransaction(mainContext,"start");
                    retAddMessage = PLMxPosTableServices.addMessageToSecurityLevel(mainContext,"Confidentiality",ValueNameID[2], Description);
                    manageContextTransaction(mainContext,"end");
                }

                manageContextTransaction(mainContext,"start");
                int ret=PLMxPosTableServices.modifyRowsOfTable(mainContext,"Confidentiality",ids,alias,level,rowTypes,rowOrders);
                manageContextTransaction(mainContext,"end");
                if (ret == -1){
                    message = "Couldn't edit the rows";
                }
            }
            if (addValues != ""){
                  
                String[] valueOneByOne = addValues.split(",SEP,");
                Description = "";
                for(int i = 0 ; i <valueOneByOne.length ; i++){
                    String ValueNameID[] = valueOneByOne[i].split(";;");

                    if(ValueNameID.length == 3)Description=ValueNameID[2];
                    manageContextTransaction(mainContext,"start");
                    int ret=PLMxPosTableServices.addRowToTable(mainContext, "Confidentiality",ValueNameID[1] , ValueNameID[0], PLMxPosTableServices.rowType_Integer, new Integer(ValueNameID[0]));
                    retAddMessage = PLMxPosTableServices.addMessageToSecurityLevel(mainContext,"Confidentiality",ValueNameID[1],Description );
                    manageContextTransaction(mainContext,"end");
                    if (ret == -1){
                        message = "Couldn't add rows";
                    }
                }
             }
        }     
   %>
   <jsp:forward page="emxPLMOnlineAdminConfidentiality.jsp">
       <jsp:param name="Message" value="<%=message%>"></jsp:param>
   </jsp:forward>
  </body>
</html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseInfo" %>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseUserAssignment" %>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
    <%    
    	String YourPersonHasBeenUpdated = getNLS("YourPersonHasBeenUpdated");
	String Users = emxGetParameter(request,"users");
        String ctxs = emxGetParameter(request,"secContexts");
        String licences = emxGetParameter(request,"licences");

        String[] UsersTable = Users.split(",,");
        String[] CtxTable = ctxs.split(",,");
        String[] licencesTable = licences.split(",,");

        StringList listCtx = new StringList();

        for (int i = 0 ; i < CtxTable.length ; i++){
            listCtx.addElement((String)CtxTable[i]);
        }

        StringList listUsers = new StringList();

        for (int i = 0 ; i < UsersTable.length ; i++){
            listUsers.addElement((String)UsersTable[i]);
           try{
           LicenseUserAssignment lua = new LicenseUserAssignment((String)UsersTable[i]);

            // retrieve licenses list from request parameters
            for ( int j = 0 ; j < licencesTable.length ; j++ ) {
                String value = licencesTable[j];
                String val = value.substring(4,value.length()-4);
               lua.addLicenseParameterIfValid(value,val);

            }

            // person licenses assignments modifications (add/remove)
            lua.update(context,myNLS);
       }catch(Exception e){
           e.printStackTrace();
       }
        }
        manageContextTransaction(mainContext,"start");
        AdminUtilities.assignSecurityContextsToUsers(mainContext, listUsers, listCtx);
        manageContextTransaction(mainContext,"end");
      
       %>
       <script>
                alert("<%=YourPersonHasBeenUpdated%>");
               parent.document.getElementById("frameRow").rows="100,0";
              var resultat="";
                var res = parent.sommaire.document.submitForm;
                for(var i = 0 ; i <res.elements.length-1 ; i++ ){
                if( (res.elements[i].name != null) || (res.elements[i].name != "") ){
                    resultat = resultat + res.elements[i].name + "=" + encodeURIComponent(res.elements[i].value)+"&";
                }}
             resultat = resultat+res.elements[res.elements.length-1].name+ "=" + encodeURIComponent(res.elements[res.elements.length-1].value);
             parent.document.getElementById("frameCol").cols="20,80";
              parent.Topos.location.href="emxPLMOnlineLocalAdminQueryPerson.jsp?"+resultat;
            </script>
       </body>
</html>

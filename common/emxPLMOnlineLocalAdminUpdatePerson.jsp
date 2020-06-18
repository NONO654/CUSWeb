<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseInfo" %>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseUserAssignment" %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS"%>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
    Map person = new HashMap();
    Map contextadd1 = new HashMap();
    Map contextrem1 = new HashMap();
    Map ctx2Add = new HashMap();
    Map ctx2Rem = new HashMap();
    Map orga = new HashMap();
    Map listorga = new HashMap();
    Map update = new HashMap();
    String YourPersonHasBeenUpdated = getNLS("YourPersonHasBeenUpdated");

    
    String PLM_ID = emxGetParameter(request,"PLM_ExternalID");
    String ctxUser = emxGetParameter(request,"ctxUser");
    String ctxAdmin = emxGetParameter(request,"ctxAdmin");
    // JIC 2015:04:01 Added Casual Hour support
    String CasualHour = emxGetParameter(request,"CasualHour");
     
    person.put("PLM_ExternalID",PLM_ID);
    person.put("Preferences","");
    int j = 0;
    int k = 0;
    String ctx2Adds = (String)emxGetParameter(request,"Ctx2Add");
    
    String[] ctxAddd = ctx2Adds.split(",");
    for (int i = 0 ; i <ctxAddd.length ; i++){
        contextadd1 = new HashMap();
        if (!ctxAddd[i].equals("")){
            contextadd1.put("PLM_ExternalID",ctxAddd[i]);
            ctx2Add.put("context"+j,contextadd1); 
            j++;
        }
    }
            
    String ctx2Remove = emxGetParameter(request,"Ctx2Remove");
        
    String[] ctxRemove = ctx2Remove.split(",");
        
    for (int i = 0 ; i <ctxRemove.length ; i++){
        contextrem1 = new HashMap();
        if (!ctxRemove[i].equals("")){
            contextrem1.put("PLM_ExternalID",ctxRemove[i]);
       
            ctx2Rem.put("context"+k,contextrem1);   
            k++;
        }
    }
    if (CasualHour != null) {
        person.put("CasualHour", CasualHour);
    }
    update.put("iCtx2Add",ctx2Add);
    update.put("iCtx2Rem",ctx2Rem);     
    update.put("method","updatePerson");
    update.put("iPersonInfo",person);
    
    // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
    ClientWithoutWS client = new ClientWithoutWS(mainContext);
    Map result = client.serviceCall(update);
   
    int res = ((Integer)result.get("resultat")).intValue();
    String message = "";
    
    if (res==1){
        message = "PLMKey Problem";
    }
    else if(res==0){
        String licences = emxGetParameter(request,"licences");
        String[] licencesTable = licences.split(",,");

        try{
            LicenseUserAssignment lua = new LicenseUserAssignment(PLM_ID);
            if (!licences.equals("")){
                // retrieve licenses list from request parameters
                for ( int l = 0 ; l < licencesTable.length ; l++ ) {
                    String value = licencesTable[l];
                    // JIC 15:05:06 Added split on string "!!"
                    if(value.contains("!!")){
                    	String sParamValueOneByOne[] = value.split("!!");
                        lua.addLicenseParameterIfValid(sParamValueOneByOne[0],sParamValueOneByOne[1]);
                    }
                }
            }
            else{
                lua.addLicenseParameterIfValid("","");
            }
            // person licenses assignments modifications (add/remove)
            lua.update(mainContext,myNLS);
        }
        catch(Exception e){
            e.printStackTrace();
        }
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
<%
    }
%>
  
       </body>
</html>

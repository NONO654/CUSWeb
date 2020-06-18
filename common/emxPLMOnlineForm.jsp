<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfig"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfigManager"%>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosTableServices" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<html>
    <head>
  
       <script>
        function effacer(){

            var selectBox = document.getElementById("SecurityContextsElse");
             var sizeSelectBox = selectBox.options.length - 1;

            while (sizeSelectBox >= 0){
                if(selectBox.options[sizeSelectBox].selected){
                    var text = selectBox.options[sizeSelectBox].value;
                    selectBox.options[sizeSelectBox]=null;
                    var opt = new Option(text,text);
                    document.getElementById("SecurityContextsHas").options[ document.getElementById("SecurityContextsHas").options.length]=opt;
                   document.getElementById("stockAdd").value = document.getElementById("stockAdd").value+ "," + text;
			 if (document.getElementById("stockRemove").value.indexOf(","+text) != -1){
				var value2Add = document.getElementById("stockRemove").value;
				document.getElementById("stockRemove").value = value2Add.substring(0,value2Add.indexOf("," + text)) + value2Add.substring(value2Add.indexOf("," + text)+text.length+1,value2Add.length);
			 }	
                }
                sizeSelectBox = sizeSelectBox - 1;
            }
            }





         function ajouter(){
             var selectBox = document.getElementById("SecurityContextsHas");
            var sizeSelectBox = selectBox.options.length - 1;

             while (sizeSelectBox >= 0){
                if(selectBox.options[sizeSelectBox].selected){
                    var text = selectBox.options[sizeSelectBox].value;
                    selectBox.options[sizeSelectBox]=null;
                    var opt = new Option(text,text);
                    document.getElementById("SecurityContextsElse").options[ document.getElementById("SecurityContextsElse").options.length]=opt;
                    document.getElementById("stockRemove").value = document.getElementById("stockRemove").value + "," + text;
			 if (document.getElementById("stockAdd").value.indexOf(","+text) != -1){
				var value2Add = document.getElementById("stockAdd").value;
				document.getElementById("stockAdd").value = value2Add.substring(0,value2Add.indexOf("," + text)) + value2Add.substring(value2Add.indexOf("," + text)+text.length+1,value2Add.length);
			 }	
             }
                sizeSelectBox = sizeSelectBox - 1;
            }
}


    </script>
     
</head>
<body>
    <%

        String HostCompanyName= getHostCompanyName(mainContext);
       
        String source = (String)emxGetParameter(request,"source");
        if (source==null) source = "";

        String test = getNLS("PersonID");
        String type = emxGetParameter(request,"type");
	String res = emxGetParameter(request,"result");
        String assignees =emxGetParameter(request,"Assignees");
        String members =emxGetParameter(request,"Members");
        String child = emxGetParameter(request,"child");
     // String address = emxGetParameter(request,"Address");
        String employees = emxGetParameter(request,"Employees");
        String parent = emxGetParameter(request,"parent");
        String managers = emxGetParameter(request,"Managers");
        String description = emxGetParameter(request,"description");
        String destination = emxGetParameter(request,"dest");
        String name = emxGetParameter(request,"name");
        String FirstName = emxGetParameter(request,"FirstName");
        String LastName = emxGetParameter(request,"LastName");
        String secLevel = emxGetParameter(request,"secLevel");

        String street = emxGetParameter(request,"Street");
        String city = emxGetParameter(request,"City");
        String postalCode = emxGetParameter(request,"PostalCode");
        String country = emxGetParameter(request,"Country");
        String state = emxGetParameter(request,"State");
        String Active = emxGetParameter(request,"Active");
        String Alias = emxGetParameter(request,"Alias");

        String phone = emxGetParameter(request,"Phone");
	  String Work_Phone_Number = emxGetParameter(request,"WorkPhoneNumber");

        String email = emxGetParameter(request,"Email");
        String employeeOf = emxGetParameter(request,"employeeOf");
        String memberOf = emxGetParameter(request,"memberOf");
  
        String ctxs = emxGetParameter(request,"ctxs");
	
        String PLM_ExternalID = emxGetParameter(request,"PLM_ExternalID");
    
        Enumeration eNumObj     = emxGetParameterNames(request);
        StringList listElem = new StringList();
        int size = listElem.size();
        while (eNumObj.hasMoreElements())
        {
            String nextElem = (String)eNumObj.nextElement();
            listElem.addElement(nextElem);
        }
        
        /*Getting the server mode : SMB or VPM*/
        InstallConfigManager icm = new InstallConfigManager();
        InstallConfig ic = null;
        String mode="";
        try {
            ic = icm.getInstallConfig(context);
            mode = ic.getMode();
        }
        catch (Exception e) { }
        
      
      %>


        <% if (type.equals("Project")){
            String settings = getNLS("Settings");
            String applications = getNLS("Applications");
            String designTable = getNLS("DesignTable");
            String Users = getNLS("Users");
            String Reference = getNLS("Reference");
            String PRM = getNLS("PRMTree");
        %>
            <script>
			
                var objDetailsTree = top.objDetailsTree;
                var objSelectedNode = objDetailsTree.getSelectedNode();
                // var objNewNodeSettings = addNodeToTree(objSelectedNode,"iconSmallFiles.gif","<%=settings%>","emxPLMOnlineHelpNONE.jsp");
                <% if(!mode.equals("SMB")){
                    String disciplines = emxGetParameter(request,"disciplines");
                    String[] disciplinesTable = disciplines.split(",,");

                    for (int i = 0 ; i < disciplinesTable.length ; i ++ ){
                        if(!disciplinesTable[i].equals("")){%>
                            var namesFormHelp = "emxPLMOnlineAdminDisciplineDetails.jsp?suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common&source=project&disc="+"<%=disciplinesTable[i]%>";
                            addNodeToTree(objSelectedNode,"iconSmallDisciplines.gif","<%=disciplinesTable[i]%>",namesFormHelp);
                        <%}
                    }
                }%>
            
      //      addNodeToTree(objNewNodeSettings,"utilSpacer.gif","<%=Reference%>","emxPLMOnlineResourcesDetails.jsp?source=DefaultSettings&Project="+"<%=URLEncoder.encode(name,"UTF-8")%>");
          //  addNodeToTree(objSelectedNode,"iconSmallProgram.gif","<%=PRM%>","emxPLMOnlineResourcesDetails.jsp?source=UsersSettings&PRM="+"<%=URLEncoder.encode(name,"UTF-8")%>");

                var pro = "<%=child%>";
                var proType = "<%=type%>";
                var tabPro = pro.split(",");

                for(var j = 0 ; j <= tabPro.length-2; j++)
                {
                    var proName = "emxPLMOnline"+proType+"Details.jsp?name="+encodeURIComponent(tabPro[j])+"&dest=Rsc";
                    addNodeToTree(objSelectedNode,"iconSmallProject.gif",tabPro[j],proName);
                }
							

            </script>
       <%}else if (type.equals("Resources")){
            String[] tabProject = name.split(",");
            for(int i = 0 ; i < tabProject.length ; i++){
        %>
                <script>
                    var objDetailsTree = top.objDetailsTree;
                    var objSelectedNode = objDetailsTree.getSelectedNode();
                    var nom = "Settings_"+"<%=tabProject[i]%>";

                    addNodeToTree(objSelectedNode,"iconSmallSettings.gif",nom,"emxPLMOnlineSettingsDetails.jsp");
                    addNodeToTree(objSelectedNode,"emxPLMOnlineSettingsDetails.gif",nomPRM,"emxPLMOnlineSettingsDetails.jsp");
                    addNodeToTree(objNewNodeSettings,"emxPLMOnlineSettingsDetails.gif","Default","emxPLMOnlineSettingsDetails.jsp");
                    addNodeToTree(objNewNodeSettings,"emxPLMOnlineSettingsDetails.gif","User","emxPLMOnlineSettingsDetails.jsp");
                </script>
            <%}
       }else{
            if (! source.equals("Admin")){%>
                <script>
                    var objDetailsTree = top.objDetailsTree;
                    var objSelectedNode = objDetailsTree.getSelectedNode();
                    var pro = "<%=child%>";
                    var proType = "<%=type%>";
                    var tabPro = pro.split(",");

                    for(var j = 0 ; j <= tabPro.length-2; j++)
                    {
                        var proName = "emxPLMOnline"+proType+"Details.jsp?name="+encodeURIComponent(tabPro[j])+"&dest="+proType;
                        addNodeToTree(objSelectedNode,"utilSpacer.gif",tabPro[j],proName);
                    }
                </script>
            <%}
       }%>
       <form style="width:98%"  action="" name="submitForm" id="submitForm">
           
              <div class="divPageBodyVPLM" >
                   
                <table  width="60%" id="middle" align="center" >
                <%if( ( listElem.contains("PLM_ExternalID")) ){
						String UserAlias = getNLS("UserAlias");
					%>
                    <tr>
                        <td valign="top" align="right"><img src="images/iconSmallDescription.gif"></td>
                        <td>
                            <table class="basic">
                                <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("UserID")%></td><td class="MatrixFeel" id="PLM_ExternalID"><%=XSSUtil.encodeForHTML(context,PLM_ExternalID)%></td></tr>
                                <tr style="height:30px">
                                    <td class="MatrixLabel"><%=UserAlias%></td>
                                    <%if (! source.equals("Admin")){%>
                                        <td class="MatrixFeel" id="Alias"><%=XSSUtil.encodeForHTML(context,Alias)%></td>
                                    <%}else{%>
                                        <td class="MatrixFeel">
                                            <input type="text" id="Alias" name="Alias" maxlength="40" value="<%=XSSUtil.encodeForHTML(context,Alias)%>">
                                        </td>
                                    <%}%>
                                </tr>
                                <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("FirstName")%></td><td class="MatrixFeel"><input type="text" id="V_first_name" name="V_first_name" maxlength="40" value="<%=XSSUtil.encodeForHTML(context,FirstName)%>"></td></tr>
                                <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("LastName")%></td><td class="MatrixFeel"><input type="text" id="V_last_name" maxlength="40" value="<%=XSSUtil.encodeForHTML(context,LastName)%>"></td></tr>
                                <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("HomePhone")%></td><td class="MatrixFeel"><input type="text" id="V_phone" maxlength="20" value="<%=XSSUtil.encodeForHTML(context,phone)%>" ></td></tr>
                                <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("WorkPhone")%></td><td class="MatrixFeel"><input type="text" id="Work_Phone_Number" maxlength="20" value="<%=XSSUtil.encodeForHTML(context,Work_Phone_Number)%>" ></td></tr>
                                <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("Email")%></td><td class="MatrixFeel"><input type="text" id="V_email" maxlength="50" value="<%=XSSUtil.encodeForHTML(context,email)%>"></td></tr>
                                <% if( source.equals("Admin")){%>
                                    <tr style="height:30px">
                                        <td class="MatrixLabel"><%=getNLS("Active")%></td>
                                        <td class="MatrixFeel">
                                        <%if (Active.equals("Active")){%>
                                            <input type="checkbox" id="Active" maxlength="50" checked  >
                                        <%}else{%>
                                            <input type="checkbox" id="Active" maxlength="50" >
                                        <%}%>
                                        </td>
                                    </tr>
                                <%}%>
                                <tr><hr ></tr>
                            </table>
                        </td>
                    </tr>
                <%}if(listElem.contains("Street")){            %>
            <tr>
                <td valign="top" align="right"><img src="images/iconSmallAddress.gif"></td>
                <td>
                    <table class="basic">
                        <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("Street")%></td><td class="MatrixFeel"><input type="text" maxlength="40" id="Street" value="<%=XSSUtil.encodeForHTML(context,street)%>"></td></tr>
                        <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("City")%></td><td class="MatrixFeel"><input type="text" maxlength="40" id="City" value="<%=XSSUtil.encodeForHTML(context,city)%>"></td></tr>
                        <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("State")%></td><td class="MatrixFeel"><input type="text" maxlength="40" id="State" value="<%=XSSUtil.encodeForHTML(context,state)%>"></td></tr>
                        <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("PostalCode")%></td><td class="MatrixFeel"><input type="text" maxlength="40" id="PostalCode" value="<%=XSSUtil.encodeForHTML(context,postalCode)%>"></td></tr>
                        <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("Country")%></td><td class="MatrixFeel"><input type="text" maxlength="40" id="Country" value="<%=XSSUtil.encodeForHTML(context,country)%>"></td></tr>

                      <tr><hr></tr>
                    </table>
                </td>
            </tr>
               <%}if ( (listElem.contains("employeeOf") ||(listElem.contains("memberOf") ) ) && !(mode.equals("SMB")) ){%>
                    <tr>
                        <td valign="top" align="right"><img src="images/iconSmallCompany.gif"></td>
                        <td>
                            <table class="basic">
                                <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("Employee")%></td><td class="MatrixFeel"><%=XSSUtil.encodeForHTML(context,employeeOf)%></td></tr>
                                <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("Member")%></td><td class="MatrixFeel"><%=XSSUtil.encodeForHTML(context,memberOf)%></td></tr>
                                <tr><hr></tr>
                            </table>
                        </td>
                    </tr>
                    <%}
            if(listElem.contains("description")){ %>
            <tr>
                <td valign="top" align="right"><img src="images/iconSmallAttachment.gif"></td>
                <td>
                    <table class="basic">
                        <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("Description")%></td><td class="MatrixFeel"><%=XSSUtil.encodeForHTML(context,description)%></td></tr>
                    <tr><hr></tr></table>
                </td>
            </tr>
            
                    <%}
            if(listElem.contains("secLevel") ) {
                if(!mode.equals("SMB") ){
				String Accreditation = getNLS("Accreditation");%>
            <tr>
                <td valign="top" align="right"><img src="images/iconSmallConfidentiality.gif"></td>
                <td>
                    <table class="basic">
                         <tr style="height:30px"><td class="MatrixLabel"><%=Accreditation%></td>
                           
                               <% if( source.equals("Admin")){%>
                                <td class="MatrixFeel">
                                <select name="Accreditation" id="Accreditation">
                                    <option style="color:gray ; font-style : italic" selected value=""><%=getNLS("None")%></option>

                             <%
                            manageContextTransaction(mainContext,"start");
                       MapList mpl = PLMxPosTableServices.getTableRows(mainContext, "Confidentiality");
                                manageContextTransaction(mainContext,"end");


                    for(int mi=0; mi<mpl.size(); ++mi) {

                        Hashtable h = (Hashtable)mpl.get(mi);
                        String allSecLevel = (String)h.get("V_row_name");
                 
                    if (allSecLevel.equals(secLevel)){
                             %><option selected value="<%=h.get("V_row_name")%>"><%=h.get("V_row_name")%> </option>
                    <%}else{%>
                   
                    <option value="<%=h.get("V_row_name")%>"><%=h.get("V_row_name")%> </option>
                    <%}}%>
                    <%}else{%>
                     <td class="MatrixFeel" name="Accreditation" id="Accreditation">
                    <%=XSSUtil.encodeForHTML(context,secLevel)%>
                    <%}%>
                      </td>
                            </tr>

                    <tr><hr></tr></table>
                </td>
            </tr>
             
            <%}} if(listElem.contains("ctxs")) {%>
                    <tr>
                        <td valign="top" align="right"><img src="images/iconSmallContext.gif"></td>
                        <td>
                            <table class="basic">
                                <tr >
                                    <td class="MatrixLabel"><%=getNLS("SecurityContexts")%></td>
                                <%if (source.equals("Admin") ) {
                                      Map parametrec= new HashMap();
                                      Map lisc= new HashMap();
                                      Map fin= new HashMap();
                                      
                                      parametrec.put("PLM_ExternalID","*");
                                      lisc.put("context0",parametrec);
                                      
                                      fin.put("method","queryContext");
                                      
                                      fin.put("iContextInfo",lisc);
                                      // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
                                      ClientWithoutWS client = new ClientWithoutWS(mainContext);                                      
                                      Map result = client.serviceCall(fin);
                                      Map contextResult = (Map)result.get("context");
                                      String[] tab = ctxs.split(",");
                                      StringList tabCtx = new StringList();
                                      
                                      for(int j = 0 ; j < tab.length ; j++) {
                                        String[] tabSec = tab[j].split("\n");
                                        tabCtx.addElement(tabSec[0]);
                                     }
                            %>
                                    <td class="MatrixFeel">
                                        <div style="height : 90px ; overflow :auto ">
                                            <select size="5" id="SecurityContextsHas" multiple>
                                                <%for (int j = 0 ; j <  tabCtx.size() ; j++){ %>
                                                 <option value="<%=XSSUtil.encodeForHTML(context,(String)tabCtx.get(j))%>"><%=XSSUtil.encodeForHTML(context,(String)tabCtx.get(j))%>
                                                <br>
                                                <%}%>
                                            </select>
                                        </div>
                                    </td>
                                    <td class="MatrixFeel">
                                        <div style="height : 90px ; overflow :auto ">
                                            <select size="5" id="SecurityContextsElse" multiple>
                                                <%for (int i = 0 ; i < contextResult.size() ; i++){
                                                    Map temp = (Map)contextResult.get("context"+i);
                                                    String PLM = (String)temp.get("PLM_ExternalID");
                                                        if (! (tabCtx.contains(PLM) ) ){
                                                %>
                                                            <option value="<%=PLM%>"><%=PLM%>
                                                        <%}%>
                                                        <br>
                                                <%}%>
                                            </select>
                                        </div>
                                    </td>
                                </tr>
                                <tr><td></td>
                                    <td align="right"><img src="images/buttonActionbarPrev.gif" onclick="effacer();"></td>
                                    <td align="left"><img src="images/buttonActionbarNext.gif" onclick="ajouter();"></td>
                                </tr>
                            <%}else{
                                   if ((mode.equals("SMB"))){%>
                                        <td class="MatrixFeel">
                                            <div style="height : 60px ; overflow :auto ">
                                            <%String[] tab = ctxs.split(",");

                                            for(int i = 0 ; i < tab.length ; i++) {
                                                String[] tabSec = tab[i].split("\n");
                                                if (tabSec[0].indexOf(HostCompanyName) != -1){
                                                    String nameSec = tabSec[0].substring(0,tabSec[0].indexOf(".")) + " in " + tabSec[0].substring(tabSec[0].lastIndexOf(".")+1, tabSec[0].length());
                                            %><%=XSSUtil.encodeForHTML(context,nameSec)%>
                                            <br> <%}}%>
                                            </div>
                                        </td>
                                        </tr><%
                                    }else{
										%>
                                        <td class="MatrixFeel">
                                            <% String[] tab = ctxs.split(",");
                                               for(int i = 0 ; i < tab.length ; i++) {
											        String[] tabSec = tab[i].split("\n");
                                                %><%=XSSUtil.encodeForHTML(context,tabSec[0])%>
                                                <br>
                                                <%}%>
                                            </td></tr>
                                   <%}
                            }
                        %>
                        <tr><hr></tr>
                </table>
                        </td>
                    </tr>
            <%}
            
            if(listElem.contains("child") || (listElem.contains("parent"))){ 
			
            String image= "images/iconSmall"+type+".gif";
            %>
            <tr>
                <td valign="top" align="right"><img src="<%=image%>"></td>
                <td><table class="basic">
                        <%if ( listElem.contains("parent") ){%>
                        <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("Parent")%></td><td class="MatrixFeel"><%=XSSUtil.encodeForHTML(context,parent)%></td></tr>
                        
                        <%}
                        if ( listElem.contains("child") ){ 
                        String[] tabChild = child.split(",");%>
                        <tr style="height:30px"><td class="MatrixLabel"><%=getNLS("Child")%></td><td class="MatrixFeel"><table> <tr ><td class="MatrixFeel">
                                    <% for (int i = 0 ; i <tabChild.length ; i++){
                                    
                                    %> <%=XSSUtil.encodeForHTML(context,tabChild[i])%> <br>
                                    
                                <%}%></td><tr>  </table>
                            </td>
                        </tr>   
                        <tr><hr></tr>
                        <%}%>
                    </table>
                </td>
            </tr>  
            
            <%}        
          
            
            
            if ( ( listElem.contains("Members")) ||  (listElem.contains("Employees")) || (listElem.contains("Managers")) ||  (listElem.contains("Assignees")) ) 
            {            
            %>
            
            <% if ( listElem.contains("Members") ) {
            String[] tabMembers = members.split(",");%>
            <tr >
                <td valign="top" align="right"><img src="images/iconSmallPerson.gif"></td>
                <td>
                    <table class="basic">
                        <tr style="height:50px"><td class="MatrixLabel"><%=getNLS("Members")%></td>
                            <%if (tabMembers.length >1) {%>
                            <td class="MatrixFeel" style="height : 10px"><div  style="height : 150px ; overflow : auto;" >
                                <%for(int i = 0 ; i <tabMembers.length ; i++){
                                %> <%=XSSUtil.encodeForHTML(context,tabMembers[i])%><br>
                            <%}%></div>
                            <%}else{%>
                            <td class="MatrixFeel"><%=XSSUtil.encodeForHTML(context,tabMembers[0])%>
                                <%}%> 
                        </td></tr><tr><hr></tr>
                        
                        <%}%>                        
                        <% if ( listElem.contains("Employees") ) {
                        String[] tabEmployees = employees.split(",");%>
                        
                        <tr style="height:50px"><td class="MatrixLabel"><%=getNLS("Employees")%></td>
                            <%if (tabEmployees.length >1) {%>
                            <td class="MatrixFeel"><div style="height : 150px ; overflow : auto;" >
                                <%for(int i = 0 ; i <tabEmployees.length ; i++){
                                %> <%=XSSUtil.encodeForHTML(context,tabEmployees[i])%><br>
                            <%}%></div>
                            <%}else{%>
                            <td class="MatrixFeel"><%=XSSUtil.encodeForHTML(context,tabEmployees[0])%>
                                <%}%>
                        </td></tr>
                    </table>
                </td>
            </tr>
            <%}%>
             <%}%>
            <% if ( listElem.contains("disciplines") ) {
                    String disciplines = emxGetParameter(request,"disciplines");

                    String[] disciplinesTable = disciplines.split(",,");
%>
            <tr>
                <td valign="top" align="right"><img src="images/iconSmallDisciplines.gif"></td>
                <td>
                    <table class="basic">
                        <tr ><td class="MatrixLabel">Disciplines</td><td class="MatrixFeel"></td>
                            <%if (disciplinesTable.length >1) {%>
                            <div style="overflow : auto; " >
                                <%for(int i = 0 ; i <disciplinesTable.length ; i++){
                                %> <tr><td class="MatrixLabel"></td> <td class="MatrixFeel"> <%=XSSUtil.encodeForHTML(context,disciplinesTable[i])%></td></tr>
                            <%}%></div>
                            <%}else if (disciplinesTable.length == 1){%>
                            <td class="MatrixFeel"><%=XSSUtil.encodeForHTML(context,disciplinesTable[0])%>
                                <%}%>
                        </td></tr>
                        <tr><hr></tr>
            <%}
            %>
            <% if ( listElem.contains("Assignees") ) {
            String[] tabAssignees = assignees.split(",");%>
            <tr>  
                <td valign="top" align="right"><img src="images/iconSmallPerson.gif"></td>
                
                <td>
                    <table class="basic">
                        <tr>
                            <td class="MatrixLabel"><%=getNLS("Assignees")%></td>
                            <td class="MatrixFeel"></td>
                            <%if (tabAssignees.length >1) {%>
                            <div style="overflow : auto; " >
                                <% int taille = tabAssignees.length;
                                if (taille > 30)taille=30;
                                for(int i = 0 ; i <taille ; i++){
                                %> <tr>
                                    <td class="MatrixLabel"></td>
                                    <td class="MatrixFeel"> <%=XSSUtil.encodeForHTML(context,tabAssignees[i])%></td>
                                </tr>
                            <%}%></div>
                            <%}else{%>
                            <td class="MatrixFeel"><%=XSSUtil.encodeForHTML(context,tabAssignees[0])%></td>
                                <%}%>
                        <tr><hr></tr>
                    </table>
                </td>
            </tr>
            <%}
            %>
           
    </table></div>
    </form>
         <%     if ( source.equals("Admin") ){
        %>
        <textarea id="stockAdd" style="visibility : hidden" cols="1" rows="1"></textarea>
        <textarea id="stockRemove" style="visibility : hidden" cols="1" rows="1"></textarea>
        <%}%>
     <%if ( ( listElem.contains("phone"))||(listElem.contains("email"))||(listElem.contains("employeeOf"))||(listElem.contains("memberOf"))||(listElem.contains("ctxs")) ){%>   
       <div class="footer" style="height : 5%" id="footer">
   <%}%></div>
</body>   
</html>

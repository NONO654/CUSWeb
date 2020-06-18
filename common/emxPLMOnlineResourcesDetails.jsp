<%@page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosResourceServices"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Map" %>
<%@page import="java.util.HashMap" %>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosDisciplineServices" %>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfig"%>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfigManager"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@include file= "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<html>
<head>
</head>
<body>
<%
    InstallConfigManager icm = new InstallConfigManager();
    InstallConfig ic = null;
    
    String mode="";
    try {
          ic = icm.getInstallConfig(context);
           mode = ic.getMode();
    }
    catch (Exception e) { }

    String projectName = emxGetParameter(request,"Project");
    String source = emxGetParameter(request,"source");
    MapList SettingsMapList = new MapList();
    String target = "emxPLMOnlineAdminProject.jsp?source="+source;
    String userName = mainContext.getUser();

    manageContextTransaction(mainContext,"start");
    StringList disciplines = PLMxPosDisciplineServices.getDisciplinesForProjectAsStrings(mainContext,projectName);

    if(source.equals("UsersSettings") || source.equals("DefaultSettings")){
    %> 
        <script>addHeader("images/iconSmallFiles.gif","Settings");</script>
        <table id="tableRes" width="100%">
            <tr bgcolor="#b0b2c3" style="width : 100%">
                <td class="MatrixLabel"><%=myNLS.getMessage("Name")%></td>
                <td class="MatrixLabel"><%=myNLS.getMessage("Version")%></td>
                <td class="MatrixLabel"><%=myNLS.getMessage("Created")%></td>
                <td class="MatrixLabel"><%=myNLS.getMessage("Modified")%></td>
                <td class="MatrixLabel"><%=myNLS.getMessage("Maturity")%></td>
            </tr>
            <%
                if(source.equals("UsersSettings")){
                    SettingsMapList =PLMxPosResourceServices.getUserSettings(mainContext,userName,projectName);
                    for(int i = 0 ; i < SettingsMapList.size() ; i++){
                        Map SettingsMap = (Map)SettingsMapList.get(i);
                        String V_Name = (String)SettingsMap.get("V_Name");
                        String V_version = (String)SettingsMap.get("V_version");
                        String C_created = (String)SettingsMap.get("C_created");
                        String C_modified = (String)SettingsMap.get("C_modified");
                        String V_maturity = (String)SettingsMap.get("V_maturity");

                        SimpleDateFormat DEFAULT_DATE_FORMAT =  matrix.util.DateFormatUtil.initDateFormat(mainContext);
                        Date dateCreated = new Date(1000 * Long.parseLong(C_created));
                        String finalDateCreated = DEFAULT_DATE_FORMAT.format(dateCreated).toString();
                    
                        Date dateModified = new Date(1000 * Long.parseLong(C_modified));
                        String finalDateModified = DEFAULT_DATE_FORMAT.format(dateModified).toString();
            %>
                        <tr>
                            <td class="MatrixFeel"><%=V_Name%></td>
                            <td class="MatrixFeel"><%=V_version%></td>
                            <td class="MatrixFeel"><%=finalDateCreated%></td>
                            <td class="MatrixFeel"><%=finalDateModified%></td>
                            <td class="MatrixFeel"><%=V_maturity%></td>
                        </tr>               
                        <%}
                }else{
                    if(source.equals("DefaultSettings")){
                        SettingsMapList =PLMxPosResourceServices.getReferenceSettings(mainContext,projectName);
                        for(int i = 0 ; i < SettingsMapList.size() ; i++){
                            Map SettingsMap = (Map)SettingsMapList.get(i);
                            String V_Name = (String) SettingsMap.get("V_Name");
                            String V_version = (String)SettingsMap.get("V_version");
                            String C_created = (String)SettingsMap.get("C_created");
                            String C_modified = (String)SettingsMap.get("C_modified");
                            String V_maturity = (String)SettingsMap.get("V_maturity");
                            SimpleDateFormat DEFAULT_DATE_FORMAT =  matrix.util.DateFormatUtil.initDateFormat(mainContext);
                            Date dateCreated = new Date(1000 * Long.parseLong(C_created));
                            String finalDateCreated = DEFAULT_DATE_FORMAT.format(dateCreated).toString();
                    
                            Date dateModified = new Date(1000 * Long.parseLong(C_modified));
                            String finalDateModified = DEFAULT_DATE_FORMAT.format(dateModified).toString();
                        %>
                        <tr>
                            <td class="MatrixFeel"><%=V_Name%></td>
                            <td class="MatrixFeel"><%=V_version%></td>
                            <td class="MatrixFeel"><%=finalDateCreated%></td>
                            <td class="MatrixFeel"><%=finalDateModified%></td>
                            <td class="MatrixFeel"><%=V_maturity%></td>
                        </tr>
                        <%}
                    }
                }
    }
    else{
        if(!mode.equals("SMB")){%>
            <script>
                var objDetailsTree = top.objDetailsTree;
                var objSelectedNode = objDetailsTree.getSelectedNode();

                <%for (int i = 0 ; i < disciplines.size() ; i ++ ){
                    if(!disciplines.get(i).equals("")){%>
                        //  var namesFormHelp = "emxPLMOnlineAdminDisciplineDetails.jsp?suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common&source=project&disc="+"<%=disciplines.get(i)%>";
                        var prjPRMName = "emxPLMOnlineResourcesDetails.jsp?Project="+encodeURIComponent("<%=disciplines.get(i)%>")+"&source=PRM&dest=Project&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common";
                        addNodeToTree(objSelectedNode,"iconSmallDisciplines.gif","<%=disciplines.get(i)%>",prjPRMName);
                    <%}
                }%>
           </script>
        <%}%>
        <%String PRMNAME = "PRM -" +projectName;%>
        <script>addHeader("images/iconSmallProgram.gif","<%=PRMNAME%>");</script>
        <table id="tableRes" width="100%">
            <tr bgcolor="#b0b2c3" style="width : 100%">
                <td class="MatrixLabel"> <%=myNLS.getMessage("Name")%></td>
                <td class="MatrixLabel"><%=myNLS.getMessage("Description")%></td>
                <td class="MatrixLabel"><%=myNLS.getMessage("ResourceSet")%></td>
                <td class="MatrixLabel"><%=myNLS.getMessage("Created")%></td>
                <td class="MatrixLabel"><%=myNLS.getMessage("Modified")%></td>
                <td class="MatrixLabel"><%=myNLS.getMessage("Maturity")%></td>
            </tr><%
            if(source.equals("PRM")){
                SettingsMapList =PLMxPosResourceServices.getProjectResourceMngts(mainContext,projectName);
                for(int i = 0 ; i < SettingsMapList.size() ; i++){
                    Map SettingsMap = (Map)SettingsMapList.get(i);
                    String PLMExternalID = (String) SettingsMap.get("PLM_ExternalID");
                    String C_created = (String)SettingsMap.get("C_created");
                    String C_modified = (String)SettingsMap.get("C_modified");
                    String V_maturity = (String)SettingsMap.get("V_maturity");
                    String V_description = (String)SettingsMap.get("V_description");
                    String V_ResourceSetID = (String)SettingsMap.get("V_ResourceSetID");
                    SimpleDateFormat DEFAULT_DATE_FORMAT =  matrix.util.DateFormatUtil.initDateFormat(mainContext);
                    Date dateCreated = new Date(1000 * Long.parseLong(C_created));
                    String finalDateCreated = DEFAULT_DATE_FORMAT.format(dateCreated).toString();
                    
                    Date dateModified = new Date(1000 * Long.parseLong(C_modified));
                    String finalDateModified = DEFAULT_DATE_FORMAT.format(dateModified).toString();
               %>
                    <tr>
                        <td class="MatrixFeel"><%=PLMExternalID%></td>
                        <td class="MatrixFeel"><%=V_description%></td>
                        <td class="MatrixFeel"><%=V_ResourceSetID%></td>
                        <td class="MatrixFeel"><%=finalDateCreated%></td>
                        <td class="MatrixFeel"><%=finalDateModified%></td>
                        <td class="MatrixFeel"><%=V_maturity%></td>
                    </tr>      
                <%}
            }
        }
        manageContextTransaction(mainContext,"end");
        mainContext.disconnect();
        %>
        </table>
        <div class="footer" style="height : 5%"><hr>
        </div>
    </body>
<html>

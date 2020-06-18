<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosDisciplineServices" %>
<html>
<head>
    <script>
        function addRow(){
            var newRow = document.getElementById('tableConfi').insertRow(-1);
            var size = document.getElementById('tableConfi').rows.length;
            var inputId = 'Sec'+size;
            addCellInARowWithTextInput(newRow, "Confidentiality",0,"Add a discipline",inputId,"","30","200");
        }

        function save(disc){
            var disciplines = "";
            var input = document.getElementsByTagName('Input');
            for (var i = 0 ; i < input.length ; i++){
                disciplines = disciplines +",," +input[i].value;
            }
            var link = "emxPLMOnlineAdminManageDiscipline.jsp?method=create&disciplines="+encodeURIComponent(disciplines)+"&parentDisciplines="+encodeURIComponent(disc);
            window.location.href=link;
        }
    </script>
</head>
<body>
         <%if (AdminUtilities.isCentralAdmin(mainContext)){%>
    <%
        String discipline = emxGetParameter(request,"disc");
        String source = emxGetParameter(request,"source");

        String Add = getNLS("Add");
        String Save = getNLS("Save");
        if (source == null)source ="";
        if (discipline == null)source ="";

        String role ="";
        StringList disciplines = new StringList();

        manageContextTransaction(mainContext,"start");
        if(source.equals("")){
            disciplines = PLMxPosDisciplineServices.getRootDisciplinesAsStrings(mainContext,null);
            %>
            <div class="headerVPLM" style="height : 5%"><%=getNLS("CreateRootDisciplines")%><hr></div>
            <%
        }
        else{
            disciplines = PLMxPosDisciplineServices.getSubDisciplines(mainContext,discipline);
            %>
            <div class="headerVPLM" style="height : 5%">  <%=discipline%> <%=getNLS("SubDisciplines")%><hr></div>
            <%
        }
        manageContextTransaction(mainContext,"end");
        %>
        <div class="middle" style="height :70%">
            <table  width="50%" align="center" style="height:100%">
                <tr style="height:70%" valign="top">
                    <td>
                        <table width="100%"  align="center" id="tableConfi" style="border-color: white" border="1px">
                            <tr  valign="middle" align="center" >
                                <td class="headerConf"  > <%=getNLS("DisciplineName")%></td>
                            </tr>
                            <%for (int i = 0 ; i < disciplines.size(); i ++){%>
                                <tr>
                                <%if (!(source.equals("project"))){%>
                                    <td class="Confidentiality"><a href="emxPLMOnlineAdminDisciplineDetails.jsp?source=notroot&disc=<%=URLEncoder.encode((String)disciplines.get(i))%>"><%=disciplines.get(i)%></td>
                                <%}else{%>
                                    <td class="Confidentiality"><a href="emxPLMOnlineAdminDisciplineDetails.jsp?source=project&disc=<%=URLEncoder.encode((String)disciplines.get(i))%>"><%=disciplines.get(i)%></td>
                                <%}%>
                                </tr>
                            <%}%>
                        </table>
                    </td>
                </tr>
            </table>
    </div>
    <%if (!(source.equals("project"))){%>
        <script>addFooter("javascript:addRow()","images/buttonDialogAdd.gif","<%=Add%>","<%=Add%>","javascript:save('<%=discipline%>')","images/buttonDialogDone.gif","<%=Save%>","<%=Save%>")</script>
         <%}}else{
          String NonAppropriateContextAdmin = getNLS("NonAppropriateContextAdmin");%>

   <script>addTransparentLoading("<%=NonAppropriateContextAdmin%>","display");</script>
   <%}%>
</body>
</html>

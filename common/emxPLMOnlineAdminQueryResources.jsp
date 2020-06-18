<%@ page  import=" com.dassault_systemes.pos.resource.interfaces.IPLMxPosResource"%>
<%@ page import=" com.dassault_systemes.pos.resource.interfaces.IPLMxPosResourceManager"%>
<%@ page import=" com.dassault_systemes.pos.resource.interfaces.PLMxPosResourceServices"%>
<%@ page import=" com.dassault_systemes.pos.resource.interfaces.PLMxPosManagerAccess"%>
<%@ page import=" com.matrixone.apps.domain.util.MapList"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
    <%
        String projectName = emxGetParameter(request,"PLM_ExternalID");
        String source = emxGetParameter(request,"source");
        MapList SettingsMap = new MapList();
        
        manageContextTransaction(mainContext,"start");
        if (source.equals("Settings")){
            SettingsMap =PLMxPosResourceServices.getReferenceSettings(mainContext,projectName);
        }
        if (source.equals("PRM")){
            SettingsMap =PLMxPosResourceServices.getProjectResourceMngts(mainContext,projectName);
        }           
        if (source.equals("DesignTable")){
            SettingsMap =PLMxPosResourceServices.getResourceTables(mainContext,projectName);
        }
        manageContextTransaction(mainContext,"end");
        %>
         <table id="tableRes" width="100%" border="1px" style=" border-color: white">
            <tr bgcolor="#b0b2c3" style="width : 100%">
                <td class="MatrixLabel"><%=getNLS("Name")%></td>
                <% if (source.equals("PRM")){%>
                    <td class="MatrixLabel"><%=getNLS("ResourceSet")%></td>
                <%}%>
                <td class="MatrixLabel"><%=getNLS("Created")%></td>
                <td class="MatrixLabel"><%=getNLS("Modified")%></td>
                <td class="MatrixLabel"><%=getNLS("Project")%></td>
            </tr>

       <% if ( SettingsMap == null || SettingsMap.size() == 0 ){%>
           <tr  style="width : 100%">
               <td  colspan="5" align="center" style=" font-size: 12pt ; font-weight: bold" > No Deliverable Found</td>
           </tr>
        <%}else{%>
            <% for (int i  = 0 ; i < SettingsMap.size() ; i++ ) {
                Map map = (Map)SettingsMap.get(i);
                String plmID = "";
		if(source.equals("Settings")) { plmID = (String)map.get("V_Name"); }
                else { plmID = (String)map.get("PLM_ExternalID"); }
                String V_ResourceSetID = (String)map.get("V_ResourceSetID");
                String C_created = (String)map.get("C_created");
                String C_modified = (String)map.get("C_modified");
                String V_maturity = (String)map.get("V_maturity");
                String V_project = (String)map.get("OwnerName");
                SimpleDateFormat DEFAULT_DATE_FORMAT =  matrix.util.DateFormatUtil.initDateFormat(context);
                Date dateCreated = new Date(1000 * Long.parseLong(C_created));
                String finalDateCreated = DEFAULT_DATE_FORMAT.format(dateCreated).toString();
                Date dateModified = new Date(1000 * Long.parseLong(C_modified));
                String finalDateModified = DEFAULT_DATE_FORMAT.format(dateModified).toString();
         %>
           <tr class="tabRow">
                <td class="MatrixFeel">
                    <%=plmID%>
                </td>
                <% if (source.equals("PRM")){%>
                    <td class="MatrixFeel">
                        <%=V_ResourceSetID%>
                    </td>
                <%}%>
                <td class="MatrixFeel">
                    <%=finalDateCreated%>
                </td>
                <td class="MatrixFeel">
                    <%=finalDateModified%>
                </td>
                <td class="MatrixFeel">
                    <%=V_project%>
                </td>
            </tr>
            <%}%>
        <%}%>
    </table>
   </body>
</html>

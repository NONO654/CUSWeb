<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="java.util.*" %>
<%@ page import="java.lang.Integer" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%--
    Document   : emxPLMOnlineAdminProject.jsp
    Author     : LXM
    Modified : 19/10/2010 -> New UI 
    Modified : 16/08/2018 --> Title Support [FUN080973]
--%>
 <%
        /*get request parameters*/
        String source = emxGetParameter(request,"source");
        %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>
            function getValue(){
                var plmId = document.getElementById('send');
                var sendID = document.getElementsByName('XPProject');
                var target = plmId.href;
                if (sendID.length == 0){
                	// RBR2: Added The V_Name to fetch
                    var newTarget = target + encodeURIComponent(document.getElementById("V_Name").value);
                    newTarget = newTarget + "&Param2=Project";
                }else{
                	//XPProjectFilter
                	// In XP mode:
                	// Either end user go with prefeered project : CASE 1
                		// Here we are treating it as Name
                	// Either end user with provide their own value : CASE 2
                		// Here end user provided value will be treated as Title [Overriding the Preference]
                	var newTarget = "";
                	var filterPreferredValue = document.getElementById("XPProjectFilter").value;
                	var titleFilter = document.getElementById("V_Name").value;
                	if(titleFilter === filterPreferredValue){ // No change in preferred value
                		// To achieve the name based preferences : Need to discuss with JIC or LFE TODO
                		newTarget = target + encodeURIComponent("*"); // Any title but name is considered
                		// Here Param3 will be treated as Name not as a Title.
                		newTarget = newTarget + "&Param2=XPProject&Param3=" +filterPreferredValue; // No param Param3
                	} else {
                		// Effect of Preferred Project will nullify
                		newTarget = target + encodeURIComponent(titleFilter);
                		newTarget = newTarget + "&Param2=XPProject"; // No param Param3
                	}
                    
                    
                }
				parent.document.getElementById("frameCol").cols="20,80";
				parent.Topos.location.href=newTarget;
            }

             function submitQueryRSC(){
                parent.document.getElementById("frameCol").cols="20,80";
             	// RRB2: Added The V_Name to fetch
                var prjTitle = document.getElementById("V_Name").value;
                // TODO: Add V_Name in query parameter.
                parent.Topos.location.href="emxPLMOnlineAdminQueryResources.jsp?source="+"<%=source%>"+"&V_Name="+encodeURIComponent(prjTitle);
            }

          </script>
    </head>
    <body>
        <%
        /*get request parameters*/
        
        /*Prepare NLS Words*/
     	String dest = (String)emxGetParameter(request,"dest");
        // RBR2: FUN[080973] String ByProjectName=  getNLS("ByProjectName"); // ByProjectTitle
        String ByProjectTitle=  getNLS("ByProjectTitle"); // ByProjectTitle
        // RBR2: FUN[080973]  String Name = getNLS("Name");
        String Title = getNLS("Title");
        String Search = getNLS("Search");

        String FilterProject = "*"; // RBR2: Working:
        // We need think about how the end user should set the preferences
        
	if (source==null || (source!=null && source.equals("Project"))){
            source = "Admin";
	%>
        <form action="javascript:getValue" name="submitForm" id="submitForm " target="_parent">
            <a id="send" href="emxPLMOnlineAdminQueryProject.jsp?Param1=" ></a>
	<%if(dest==null) {%>
            <a href="javascript:CreationFrame('Project')" class="link"><%=getNLS("New")%></a>
	<%}%>			
         <%}else if (source.equals("XPProject")){
             FilterProject = prefUtil.getUserPreferredUIProjectFilter(mainContext);%>
             <a id="send" name="XPProject" href="emxPLMOnlineAdminQueryProject.jsp?Param1="></a>
          <%}else{
           
          %>
          <form action="javascript:submitQueryRSC()"  name="submitForm" id="submitForm" method="GET">
         <%}%>		
	 <table width="100%">
            <tr>
                <td>
                    <table width="100%">
                        <script>
                            addTable("I_ENOVIA_RscProject.bmp","<%=ByProjectTitle%>",0);
                            <!--RBR2: Title Support With CSE Only Removd FilterProject from here--> 
                            addTdRE("<%=Title%>","V_Name","<%=FilterProject%>","getValue");
                            addCloseTag();
                         </script>
                         <!--RBR2: if above is * and this has value then it needs to be treated as name [Only XPMode]-->
                         <tr hidden><td id="XPProjectFilter" hidden><%=FilterProject%></td><tr>
                    </table>
                  </td>
            </tr>
         </table>
        </form>
        <% if (source.equals("Settings") || source.equals("PRM") ){%>
                        <script>addFooter("javascript:submitQueryRSC()","images/buttonDialogApply.gif","<%=Search%>","<%=Search%>");</script>
                            
        <%}else{%>
                         <script>addFooter("javascript:getValue()","images/buttonDialogApply.gif","<%=Search%>","<%=Search%>");</script>
        <%}%>
     </body>
</html>


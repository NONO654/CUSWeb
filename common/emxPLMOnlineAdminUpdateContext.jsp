
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
      <%@ page import="java.util.Map" %>
      <%@ page import="java.util.HashMap" %>
       <%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
    <%@ page import="matrix.util.StringList" %>

<html>
    <head>
       <META Http-Equiv="Cache-Control" Content="no-cache">
<META Http-Equiv="Pragma" Content="no-cache">
<META Http-Equiv="Cache" Content="no store">
<META Http-Equiv="Expires" Content="0">  
<!-- <LINK REL="Stylesheet" HREF="styles/charte.css" TYPE="text/css"> -->
<link rel="icon" href="images/hbanner.jpg" />
  </head>
  <body  style="font-family: sans-serif,Tahoma;">
  
        <%
            Map parametrec= new HashMap();
            Map lisc= new HashMap();
            Map orga= new HashMap();
            Map liso= new HashMap();
            Map project= new HashMap();
            Map listproject= new HashMap();
            Map role= new HashMap();
            Map listrole= new HashMap();
            Map fin= new HashMap();
            
           parametrec.put("PLM_ExternalID",request.getParameter("PLM_ExternalID"));
           parametrec.put("members",new String[]{""});
           parametrec.put("v_id","");

           lisc.put("context0",parametrec);

           orga.put("street","");
           orga.put("city","");
           orga.put("state","");
           orga.put("postalCode","");
           orga.put("country","");
           orga.put("v_name","");
           orga.put("v_distinguished_name","");
           orga.put("org_Type","");
           orga.put("org_Parent","");
           orga.put("PLM_ExternalID","");
           orga.put("org_Child",new String[]{""});
           orga.put("users_Op",new String[]{""});
           orga.put("users_Hier",new String[]{""});
           orga.put("managers",new String[]{""});

           liso.put("organization0",orga);

           project.put("v_id","");
           project.put("members",new String[]{""});
           project.put("project_Parent","");
           project.put("project_Child",new String[]{""});
           project.put("managers",new String[]{""});
           project.put("PLM_ExternalID","");

           listproject.put("project0",project);

           role.put("v_id","");
           role.put("role_Parent","");
           role.put("role_Child",new String[]{""} );
           role.put("PLM_ExternalID","");

           listrole.put("role0",role);

            String[] slec = new String[3];
            slec[1]="";
            slec[2]="";
            slec[0]="";
                
            //fin.put("endpoint",request.getServerName());
            //StringBuffer URLPath = request.getRequestURL();
            //String LimitBySlash[] = (String[])URLPath.toString().split("://");
            //String protocol = LimitBySlash[0];
			//fin.put("protocol",protocol);
            //fin.put("port",request.getServerPort());
            //fin.put("urlpath",request.getContextPath());
            //fin.put("iKey",session.getAttribute("PLMKey"));
            fin.put("method","queryContext");

            fin.put("iProjectInfo",listproject);
            fin.put("iContextInfo",lisc);
            fin.put("iOrganizationInfo",liso);
            fin.put("iRoleInfo",listrole);
            fin.put("iSelectableList",slec);

            // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
            ClientWithoutWS client = new ClientWithoutWS(mainContext);
            Map result = client.serviceCall(fin);
            if(((Map) result.get("context")).size()>0) {%>
               <table class="L">
                 <tr>
                     <th class="TH" colspan="2">Context</th>
                 </tr>
                 <tr>
                     <th class="TH">Name</th>
                     <th class="TH">Assignees</th>
                 </tr>
                        <% Map rep =(Map)((Map) result.get("context")).get("context0");
                        StringList member = (StringList)rep.get("member"); %>
                            <tr>
                                <td class="TD"><%=rep.get("PLM_ExternalID")%></td>
                                <td class="TD">
                                    <%if(member.size()>0){%>
                                    <select size="5">
                                        <% for(int k=0; k<member.size(); ++k) {%>
                                              <option><%=member.get(k)%></option>
                                        <%}%>
                                    </select>
                                    <%}%>
                                </td>
                            </tr>
            </table>
            <% } %>
    </body>
</html>

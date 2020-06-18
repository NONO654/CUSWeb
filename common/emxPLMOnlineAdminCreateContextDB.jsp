<%
	Map ctxs = new HashMap();
    Map role = new HashMap();
    Map organization = new HashMap();
    Map project = new HashMap();
    String source = emxGetParameter(request,"source");
    if (source==null){source="";}
    String organ= "";
    int nbCtxReussi = 0;
    int nbCtxTotal = 0;
    if ( ! (source.equals("LocalAdmin")) ){
		response.setContentType("text/xml");
		response.setContentType("charset=UTF-8");
		response.setHeader("Content-Type", "text/xml");
		response.setHeader("Cache-Control", "no-cache");
		response.getWriter().write("<?xml version='1.0' encoding='UTF-8'?>");
	}
%>
<%@ include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@ include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS"  %>
<%
    if (source.equals("LocalAdmin")){
    	Enumeration eNumObj     = emxGetParameterNames(request);
        organ= emxGetParameter(request,"org");
        while (eNumObj.hasMoreElements())
        {
        	String nextElem = (String)eNumObj.nextElement();
            if (nextElem.indexOf(",,") != -1){
            	String[] PersContext = nextElem.split(",,");
                role = new HashMap();
                organization = new HashMap();
                project = new HashMap();
                ctxs = new HashMap();

                String contextName = PersContext[0]+"."+organ+"."+PersContext[1];
                ctxs.put("PLM_ExternalID",contextName);
                role.put("PLM_ExternalID",PersContext[0]);
                organization.put("PLM_ExternalID",organ);
                project.put("PLM_ExternalID",PersContext[1]);

        		nbCtxTotal++;
        		Map fin = new HashMap();
				fin.put("method","createContext");
				fin.put("iContextInfo",ctxs);
       			fin.put("iOrganizationInfo",organization);
       			fin.put("iProjectInfo",project);
       			fin.put("iRoleInfo",role);

                // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
       			ClientWithoutWS client = new ClientWithoutWS(mainContext);
       			Map ret = client.serviceCall(fin);
        		if(((Integer)ret.get("resultat")).intValue()==0){nbCtxReussi++;}
        	}
    	}
	}
    else
    {
    	String roleCatch = emxGetParameter(request,"roleProject");
        String organizationName = emxGetParameter(request,"organization");
		String regex="[.,]";
        String[] roleProjectList = roleCatch.split(",");
       
        nbCtxTotal = roleProjectList.length;
        nbCtxReussi = 0;
            
       	for (int i = 0 ; i < roleProjectList.length ; i++){
        	String[] roleOrg = roleProjectList[i].split(regex);
            String roles = roleOrg[0];
            String organizations = organizationName;
            String projects =  roleOrg[1];
        	String name = roles+"."+organizations+"."+projects;
        
        	ctxs.put("PLM_ExternalID",name);                               
        	role.put("PLM_ExternalID",roles);
        	organization.put("PLM_ExternalID",organizations);
        	project.put("PLM_ExternalID",projects);
        
        	Map fin = new HashMap();
			fin.put("method","createContext");
			fin.put("iContextInfo",ctxs);
       		fin.put("iOrganizationInfo",organization);
       		fin.put("iProjectInfo",project);
       		fin.put("iRoleInfo",role);
           
            // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
       		ClientWithoutWS client = new ClientWithoutWS(mainContext);
       		Map ret = client.serviceCall(fin);
        
        	if(((Integer)ret.get("resultat")).intValue()==0){nbCtxReussi++;}
        }
	}
    String SecCntxts = getNLSMessageWithParameter("CONF_HasBeenCreated","SecurityContexts");
    String  message =nbCtxReussi + "/" + nbCtxTotal +SecCntxts;

    if ( ! (source.equals("LocalAdmin")) ){
        response.getWriter().write("<root><message>"+message+"</message></root>");
	}else{
%>
        <jsp:forward page="emxPLMOnlineLocalAdminOrganization.jsp">
        	<jsp:param name="message" value="<%=message%>"/>
            <jsp:param name="org" value="<%=organ%>"/>
        </jsp:forward>
<%  }%>

<%@include file = "emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>

<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<html>  
<HEAD>
    <script src="scripts/emxUIAdminConsoleUtil.js"></script>
    <link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css">
</HEAD>
<%
      String NonAppropriateContextAdmin = getNLS("NonAppropriateContextAdmin");
	  if ( AdminUtilities.isLocalAdmin(mainContext) || AdminUtilities.isCentralAdmin(mainContext) || AdminUtilities.isProjectAdmin(mainContext) ){
		// String PLMKey = (String)session.getAttribute("PLMKey");
	  // if(PLMKey==null || PLMKey.length()<=0) {
      // V2KeyService v2s = new V2KeyService();
      // ServiceKeyHolder skh = new ServiceKeyHolder();
                
      // CredentialSet CredentialSetVar = new CredentialSet("V6LOGIN","v2");
      // CredentialSetVar.addAuthenticationCredential("user", mainContext.getUser(), false);
      // CredentialSetVar.addAuthenticationCredential("password", mainContext.getPassword(), true);

      // CredentialSetVar.addApplicativeCredential("SecurityContext", "VPLMDesigner",false);
      // CredentialSetVar.addApplicativeCredential("Machine", "localhost", false);
      // CredentialSetVar.addApplicativeCredential("Port", String.valueOf(request.getServerPort()), false);
      // CredentialSetVar.addApplicativeCredential("URLPath", request.getContextPath(), false);
// CredentialSetVar.setRequest(request);
      // v2s.generateServiceKey(CredentialSetVar, skh);
		
	// String plmkey = skh.getValue().getValue();
	
      // session.setAttribute("PLMKey", plmkey);

	// }

        String HostCompanyName= getHostCompanyName(mainContext);
        String source = (String)emxGetParameter(request,"source");
        String dest = (String)emxGetParameter(request,"dir");
        String target = "emxPLMOnlineAdmin"+source+".jsp";
        if(source.equals("XPProjectSearch")){target = "emxPLMOnlineAdminProject.jsp?source=XPProject";}
        if(source.equals("XPPersonSearch")){target = "emxPLMOnlineAdminPerson.jsp?source=XPPerson";}
        if(source.equals("XPOrganization")){target = "emxPLMOnlineAdminOrganizationSubTree.jsp?PLM_ExternalID="+HostCompanyName;}

        if(source.equals("Settings")){target = "emxPLMOnlineAdminProject.jsp?source=Settings";}
        if(source.equals("PRM")){target = "emxPLMOnlineAdminProject.jsp?source=PRM";}
        if(source.equals("Application")){target = "emxPLMOnlineAdminProject.jsp?source=Application";}
        if(source.equals("DesignTable")){target = "emxPLMOnlineAdminProject.jsp?source=DesignTable";}
    	if(dest != null){
    		target = target + "?dest="+dest; 
    	}
%>   
	<FRAMESET name="frameRow" id="frameRow" framespacing="1" rows="100"> 
		<FRAMESET style="height:100%" name="frameCol" id="frameCol" cols="100,0">  
			<FRAME style=" margin-top: 4% ; border: 0px" width="100%" height="98%" name="sommaire" id="sommaire" target="Topos" src="<%=target%>" scrolling="auto">
			<FRAME name="Topos" id="Topos" src="" scrolling="auto" > 
		</FRAMESET>
		<FRAMESET >
    		<FRAME name="banniere" id="banniere" scrolling="auto" target="sommaire" src="" marginwidth="0" marginheight="0">
		</FRAMESET>
		<NOFRAMES> 
		<P>Cette page utilise des cadres, mais votre navigateur ne les prend pas 
		en charge.</p> 
		</NOFRAMES>
	</FRAMESET>
<%}else{%>
	<body>
		<div class="transparencyTotal" id="loading"   style="z-index:1;position:absolute" >
        	<table width="100%" style="height : 100%" >
            	<tr valign="middle" align="middle">
                	<td style="color:#990000 ; font-style:italic; font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt">
                    <%=NonAppropriateContextAdmin%></td>
                </tr>
            </table>
        </div>
    </body>
<%}%>
</html>

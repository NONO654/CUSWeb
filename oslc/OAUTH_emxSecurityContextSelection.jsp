<%--  emxSecurityContextSelection.jsp   - security context selection page for MatrixOne applications

   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This programs contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxSecurityContextSelection.jsp $
--%>
<!DOCTYPE html>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../emxRequestWrapperMethods.inc"%>
<%@ page import="matrix.db.*, matrix.util.*, com.matrixone.servlet.*, java.text.* ,java.util.* , com.matrixone.apps.domain.*, com.matrixone.apps.domain.util.*, com.matrixone.apps.framework.taglib.*"  %>
<emxUtil:localize id="i18nId" bundle="emxFrameworkStringResource" locale='<%= request.getHeader("Accept-Language") %>' />

<%@ page import="com.matrixone.apps.domain.util.PersonUtil" %>
<%@ page import="com.matrixone.apps.domain.util.PropertyUtil" %>
<%
System.out.println("####################################  OAUTH_EMXSECURITYCONTEXTSELECTION.jsp ####################################");

String sRoleToDisplay = "true";
String disableAutoLogin = "false";
String displaySingleValue = "true";
String loginPage =  Framework.getPropertyValue("ematrix.login.page");
matrix.db.Context context = Framework.getFrameContext(session);
String widgetId = emxGetParameter(request, "widgetId");
String stremxNavigatorData = "emxNavigatorData";
String languageStr        = request.getHeader("Accept-Language");
if(widgetId != null){
	stremxNavigatorData = widgetId + "emxNavigatorData";
}

Map emxNavigatorData = (Map)session.getAttribute(stremxNavigatorData);
String paramNameValues = "";
if( emxNavigatorData == null )
{
    emxNavigatorData = new HashMap();
}
Enumeration enumParam = request.getParameterNames();
// Loop through the request elements and
boolean isFirstParam = true;
while (enumParam.hasMoreElements())
{
    String paramName  = (String) enumParam.nextElement();
    String paramValue = emxGetParameter(request, paramName);
    if( !paramName.equals(LoginServlet.FORM_LOGIN_NAME) && !paramName.equals(LoginServlet.FORM_LOGIN_PASSWORD) )
    {
        if( isFirstParam )
        {
            paramNameValues = XSSUtil.encodeForURL(context, paramName) + "=" + XSSUtil.encodeForURL(context, paramValue);
            isFirstParam = false;
        } else {
            paramNameValues += "&" +XSSUtil.encodeForURL(context, paramName) + "=" + XSSUtil.encodeForURL(context, paramValue);
        }
        emxNavigatorData.put(paramName, paramValue);
    }
}
session.setAttribute(stremxNavigatorData, emxNavigatorData);
String switchContext = emxGetParameter(request,"switchContext");
String collabSpace = emxGetParameter(request,"collabSpace");
MatrixServletException servletException = Framework.getError(request);
if (switchContext != null)
{
     session.setAttribute("switchContext", switchContext);
} else {
	switchContext = "false";
    session.setAttribute("switchContext", switchContext);
}
if (servletException != null)
{
     session.setAttribute("error.message", servletException.getMessage());
}
if( context != null )
{
    
    boolean passwordExpired = false;
	
	int bStatus=0;
	
	try{
	 bStatus=context.getPasswordStatus();
	
	}catch(Exception e)
	{
		System.out.println("#Exception ---- ##"+e);
		bStatus=1;
		
	}
	
		
    if ( bStatus != 0)
    {
        passwordExpired = true;
        String requestURI = request.getRequestURI();
        String dispatcherURL = "../common/emxChangeExpiredPassword.jsp";
        if (requestURI != null && (requestURI.indexOf("emxNavigator.jsp") > 0 || requestURI.indexOf("emxSecurityContextSelection.jsp") > 0))
        {
            dispatcherURL = "emxChangeExpiredPassword.jsp";
        } else {
            dispatcherURL = "common/emxChangeExpiredPassword.jsp";
        }
        request.getRequestDispatcher(dispatcherURL).forward(request, response);
    }
    if( !passwordExpired )
    {
        disableAutoLogin = emxGetParameter(request,"disableAutoLogin");
        if( disableAutoLogin == null || "".equals(disableAutoLogin))
        {
            disableAutoLogin = "false";
        }
        String securityContext = emxGetParameter(request,"SecurityContext");;
        String forwardURL = (String)session.getAttribute("ForwardURL");
        String appName = (String) emxNavigatorData.get("appName");
        if (forwardURL != null && forwardURL.length() > 0 ){
            if(forwardURL.indexOf("//") == 0){
                forwardURL = forwardURL.substring(1,forwardURL.length());
            }
        } else {
            forwardURL = "/common/emxNavigator.jsp?appName="+ appName;
        }
        if(Framework.isLoggedIn(request)&& forwardURL.contains("emxNavigatorDialog.jsp")  ){
           forwardURL = "/common/emxNavigator.jsp?appName="+ appName;
           session.setAttribute("ForwardURL", forwardURL);
        }
        forwardURL = Framework.getClientSideURL(response, forwardURL);
        if ("true".equalsIgnoreCase(switchContext))
        {
            out.clear();
        } else {
            try
            {
              PersonUtil.refreshUserAssignments(context);
            } catch(Exception ex)
            {
              // Do Nothing
            }

        }
        if (!"true".equalsIgnoreCase(switchContext))
        {
%>

          <html>
          <head>
          <meta HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE"/>
          <link rel="shortcut icon" href="../favicon.ico" type="image/x-icon" />
          <title><emxUtil:i18n localize="i18nId">emxFramework.Login.Title</emxUtil:i18n></title>
          <script>var topMostEnoviaWindow=true;</script>
          <!-- //XSSOK -->
          <script language="javascript" src="<%=Framework.getClientSideURL(response, "common/scripts/emxUIConstants.js")%>"></script>
          <!-- //XSSOK -->
          <script language="javascript" src="<%=Framework.getClientSideURL(response, "common/scripts/emxUICore.js")%>"></script>
          <script language="javascript" src="../common/scripts/jquery-latest.js"></script>
          
          <link rel="stylesheet" type="text/css" href="<%=Framework.getClientSideURL(response, "common/styles/emxUIDefault.css")%>"/>
<%
        }
%>
        <script language="javascript">
        function onOrganizationChange(){
              $.ajax({
                  url: 'OAUTH_emxSecurityContextComponents.jsp',
                  dataType: 'json',
                data: 'scParamType=Company&scParamValue='+encodeURIComponent($('#Organization').val()),
                  success: function(data)
                  {
                    $('#Project').empty();
                    $('#Role').empty();
                    $.each(data, function(i, val1){
                        if(val1.indexOf("role_") >= 0){
                        	val1 = val1.replace("role_", "");
                        	var arryRoles = val1.split("|");                        	
                            $('#Role').append($('<option></option>').val(arryRoles[0]).html(arryRoles[1]));
                        } else {
                            $('#Project').append($('<option></option>').val(val1).html(val1));
                        }
                    });
                  }
              });
          }

        function onProjectChange(){
                        $.ajax({
                              url: 'OAUTH_emxSecurityContextComponents.jsp',
                              dataType: 'json',
                  data: 'scParamType=Project&scParamValue='+encodeURIComponent($('#Project').val())+"&org="+encodeURIComponent($('#Organization').val()),
                              success: function(data)
                                        {
                                          $('#Role').empty();
                                              $.each(data, function(i, val1){
                                            	  var arrRoles = val1.split("|"); 
                                                  $('#Role').append($('<option></option>').val(arrRoles[0]).html(arrRoles[1]));
                                              });
                        }
                });
        }

        </script>
        <script language=Javascript>
        function adjustLoginPanel(){
            var pnlouter = document.getElementById('panelouter');

            var hlfht = pnlouter.offsetHeight;
            hlfht = hlfht/2;
            var tp = '-' + hlfht + 'px';
            pnlouter.style.marginTop = tp;

            var hlflft = pnlouter.offsetWidth;
            hlflft = hlflft/2;
            var lft = '-' + hlflft + 'px';
            pnlouter.style.marginLeft = lft;
         }

         function mxSubmitSwitchContext()
         {
            var frameContent = findFrame(getTopWindow(),"content");
            var objForm = document.loginForm;
            objForm.ContentURL.value = frameContent.document.location.href;
            objForm.currentApp.value = getTopWindow().currentApp;
            
            objForm.switchContext.value = "true";
            //addSecureToken(objForm);
            objForm.submit();
            //removeSecureToken(objForm);
         }
        function mxSubmit ()
        {
          var objForm = document.loginForm;
          //addSecureToken(objForm);
          objForm.submit();
          //removeSecureToken(objForm);

        }
        function mxCancel ()
        {
          closeSecurityContextDialog();
        }
        </script>

<%
        if (!"true".equalsIgnoreCase(switchContext))
        {
%>
            </head>
            <body class="sign-in security-context" onload="adjustLoginPanel();$('#submitButton').focus();">
            <div id="panelouter" class="wrap-outer">
<%
        } else {
%>
            <div id="panelouter" class="wrap-outer popup-dialog  sign-in security-context">
<%
        }
%>
        <div class="wrap-inner">
        <div class="panel">
<%
        String strdefOrg = "";
        String strdefPrj = "";
        String strdefRole = "";
        StringList organizations = new StringList();
        StringList projects = new StringList();
        StringList roles = new StringList();
        if( collabSpace != null && !"".equals(collabSpace))
        {
            securityContext = PersonUtil.getSecurityContext(context, collabSpace);
            if( securityContext.indexOf("|") > 0)
            {
                securityContext = "";
            }
        }

        if( securityContext!= null && PersonUtil.isValidSecurityContext(context, securityContext) ) {
            //System.out.println("COLLAB SPACE IS PROVIDED AND FOUND UNIQUE SECURITY CONTEXT");
            //System.out.println("OR SECURITY CONTEXT IS BEEN PROVIDED AND VALID");
%>
            <script>
                var rToken = "<%=request.getParameter("rToken")%>";
                var port = "<%=request.getParameter("port")%>";
                var ticket= "<%=request.getParameter("ticket")%>";
                submitWithCSRF("OAUTH_emxSecurityContextSelectionProcess.jsp?widgetId=<%=XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "widgetId"))%>&SecurityContext=<%=XSSUtil.encodeForURL(context, securityContext)%>&rToken=" + rToken + "&port=" + port + "&ticket=" + ticket, window); 
            </script>
<%
			return;
        } else if( !PersonUtil.hasSecurityContext(context, context.getUser()) ) {
            //System.out.println("CONTEXT PERSON "+ context.getUser() +" DOESN'T HAVE ANY SECURITY CONTEXT AVIALABLE");
			session.removeAttribute("ForwardURL");
%>
            <!-- //XSSOK -->
            <script> document.location.href="<%=forwardURL%>"; </script>
<%
        } else {
            
            disableAutoLogin = "true";
            System.out.println("DISABLE AUTOLOGIN PARAMETER IS SET AS " + disableAutoLogin);
            if( "false".equals(disableAutoLogin))
            {
                System.out.println("DISABLE AUTOLOGIN PARAMETER IS NOT PROVIDED");
                securityContext = PersonUtil.getDefaultSecurityContext(context);
                System.out.println("CONTEXT PERSON "+ context.getUser() +" HAVE DEFAULT SECURITY CONTEXT SET AS == " + securityContext);
            }
            if(PersonUtil.isValidSecurityContext(context, securityContext) && !"true".equalsIgnoreCase(switchContext) )
            {
                System.out.println("CONTEXT PERSON "+ context.getUser() +" HAVE DEFAULT SECURITY CONTEXT SET AS == " + securityContext);
                System.out.println("AND IT IS VALID and SWITCHCONTEXT PARAMETER IS FALSE");
    %>
                <script>
                    var rToken = "<%=request.getParameter("rToken")%>";
                    var port = "<%=request.getParameter("port")%>";
                    var ticket= "<%=request.getParameter("ticket")%>";
                    submitWithCSRF("OAUTH_emxSecurityContextSelectionProcess.jsp?widgetId=<%=XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "widgetId"))%>&SecurityContext=<%=XSSUtil.encodeForURL(context, securityContext)%>&rToken=" + rToken + "&port=" + port + "&ticket=" + ticket, window); 
                </script>
    <%
            } else {
                StringList selects = new StringList();
                selects.addElement(DomainObject.SELECT_NAME);
                MapList securityContextDetails = PersonUtil.getSecurityContexts(context, context.getUser(), selects);
                if( (securityContextDetails != null && securityContextDetails.size() == 1) && ("false".equals(switchContext) || ("true".equalsIgnoreCase(switchContext) && (collabSpace != null))))
                {
                    Map scMap = (Map)securityContextDetails.get(0);
                    securityContext = (String)scMap.get(DomainObject.SELECT_NAME);
                    System.out.println("CONTEXT PERSON "+ context.getUser() +" HAVE ONLY ONE SECURITY CONTEXT AS == " + securityContext);
    %>
                    <script>
                        var rToken = "<%=request.getParameter("rToken")%>";
                        var port = "<%=request.getParameter("port")%>";
                        var ticket= "<%=request.getParameter("ticket")%>";
                        submitWithCSRF("OAUTH_emxSecurityContextSelectionProcess.jsp?widgetId=<%=XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "widgetId"))%>&SecurityContext=<%=XSSUtil.encodeForURL(context, securityContext)%>&rToken=" + rToken + "&port=" + port + "&ticket=" + ticket, window); 
                    </script>
    <%
                } else {
                    String relSecurityContextProject= PropertyUtil.getSchemaProperty(context, DomainSymbolicConstants.SYMBOLIC_relationship_SecurityContextProject);
                    String relSecurityContextOrganization = PropertyUtil.getSchemaProperty(context, DomainSymbolicConstants.SYMBOLIC_relationship_SecurityContextOrganization);
                    String relSecurityContextRole = PropertyUtil.getSchemaProperty(context, DomainSymbolicConstants.SYMBOLIC_relationship_SecurityContextRole);

                    Iterator itr = securityContextDetails.iterator();
                    strdefOrg = PersonUtil.getDefaultOrganization(context, context.getUser());
                    strdefPrj = PersonUtil.getDefaultProject(context, context.getUser());
                    strdefRole = PersonUtil.getDefaultSCRole(context, context.getUser());
                    if( collabSpace != null && !"".equals(collabSpace))
                    {
                        strdefPrj = collabSpace;
                    }
                    while(itr.hasNext())
                    {
                        Map scMap = (Map)itr.next();
                        String strOrg = (String)scMap.get("from[" + relSecurityContextOrganization + "].to.name");
                        String strPrj = (String)scMap.get("from[" + relSecurityContextProject + "].to.name");
                        String strRole = (String)scMap.get("from[" + relSecurityContextRole + "].to.name");
                        if( "".equals(strdefOrg) )
                        {
                            strdefOrg = (String)scMap.get("from[" + relSecurityContextOrganization + "].to.name");
                            strdefPrj = (String)scMap.get("from[" + relSecurityContextProject + "].to.name");
                            strdefRole = (String)scMap.get("from[" + relSecurityContextRole + "].to.name");
                        }
                        if( !organizations.contains(strOrg) )
                        {
                            organizations.addElement(strOrg);
                        }
                        if( !projects.contains(strPrj) && strdefOrg.equals(strOrg))
                        {
                            projects.addElement(strPrj);
                        }
                        if( !roles.contains(strRole) && strdefPrj.equals(strPrj))
                        {
                            roles.addElement(strRole);
                        }
                    }
                    Collections.sort(organizations);
                    Collections.sort(projects);
                    Collections.sort(roles);
                }
            }
        }
        String strOrganization = "";
        if (organizations != null && organizations.size() >0 )
        {
            strOrganization = (String)organizations.get(0);
        }
        String strProject = "";
        if (projects != null && projects.size() >0 )
        {
            strProject = (String)projects.get(0);
        }
        String strRole = "";
        if (roles != null && roles.size() >0 )
        {
            strRole = (String)roles.get(0);
        }

        if( FrameworkUtil.isOnPremise(context) && organizations.size() == 1 && projects.size() == 1)
        {
            sRoleToDisplay = "false";
        }

        try
        {
            sRoleToDisplay = FrameworkProperties.getProperty("emxComponents.NewSecurityModel.RoleDefaultSelectionForContextSelection");
            displaySingleValue = FrameworkProperties.getProperty("emxComponents.NewSecurityModel.DisplaySingleValueInContextSelection");
        } catch(Exception ex )
        {
          // Do nothing
        }
        if( "false".equals(sRoleToDisplay) && organizations.size() == 1 && projects.size() == 1)
        {
            //System.out.println("DISPLAY ROLE IS SET TO FALSE AND THE CONTEXT PERSON "+ context.getUser() +" HAVE ONLY ONE ORG and ONE PROJECT AS == " + organizations.get(0) + " && " + projects.get(0));
            if( "false".equalsIgnoreCase(switchContext) || ("true".equalsIgnoreCase(switchContext) && (collabSpace != null)))
            {
%>
                <script>
                    var rToken = "<%=request.getParameter("rToken")%>";
                    var port = "<%=request.getParameter("port")%>";
                    var ticket= "<%=request.getParameter("ticket")%>";
                    submitWithCSRF("OAUTH_emxSecurityContextSelectionProcess.jsp?widgetId=<%=XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "widgetId"))%>&Organization=<%=XSSUtil.encodeForURL(context, (String)organizations.get(0))%>&Project=<%=XSSUtil.encodeForURL(context, (String)projects.get(0))%>&rToken=" + rToken + "&port=" + port + "&ticket=" + ticket, window); 
                </script>
<%
            }
        }
%>
            <h1><emxUtil:i18n localize="i18nId">emxFramework.ChooseSecurityContext</emxUtil:i18n></h1>
            <div id="panelcnt" class="panel-content">
            <form id="loginForm" name="loginForm" method="post" action="OAUTH_emxSecurityContextSelectionProcess.jsp?rToken=<%=request.getParameter("rToken") + "&port=" + request.getParameter("port") + "&ticket=" + request.getParameter("ticket")%>">
                <input type="hidden" name="widgetId" id="widgetId" value="<xss:encodeForHTMLAttribute><%=widgetId%></xss:encodeForHTMLAttribute>" />
                <div class="panel-mask"></div>
                <div class="panel-head"><emxUtil:i18n localize="i18nId">emxFramework.Login.Head</emxUtil:i18n></div>
                <div class="panel-body">
                <ul>
                   <li class="select-box">
<%
        if( "true".equals(displaySingleValue) || organizations.size() > 1)
        {
%>
            <label><emxUtil:i18n localize="i18nId">emxFramework.SecurityContextSelection.Organization</emxUtil:i18n></label>
<%
        }
        if( organizations.size() > 1)
        {
%>
            <span><select name="Organization" id="Organization" onchange="onOrganizationChange()">
<%
            for(int i = 0 ; i < organizations.size() ; i++)
            {
                strOrganization = (String)organizations.get(i);
                if (strOrganization.equals(strdefOrg))
                {
%>
                    <option selected="selected"><xss:encodeForHTML><%=strOrganization.trim()%></xss:encodeForHTML></option>
<%
                } else {
%>
                    <option><xss:encodeForHTML><%=strOrganization.trim()%></xss:encodeForHTML></option>
<%
                }
            }
%>
                </select></span>
<%
        } else {
            if( "true".equals(displaySingleValue))
            {
%>
                <input type="text" name="Organization_txt" id="Organization_txt" value="<xss:encodeForHTMLAttribute><%=strOrganization%></xss:encodeForHTMLAttribute>" disabled="disabled"/>
<%
            }
%>
            <input type="hidden" name="Organization" id="Organization" value="<xss:encodeForHTMLAttribute><%=strOrganization%></xss:encodeForHTMLAttribute>"/>
<%
        }
%>
        </li>
        <li class="select-box">
<%
        if( "true".equals(displaySingleValue) || organizations.size() > 1 || (projects != null && projects.size() > 1))
        {
%>
            <label><emxUtil:i18n localize="i18nId">emxFramework.SecurityContextSelection.Project</emxUtil:i18n></label>
<%
        }
        if(organizations.size() > 1 || (projects != null && projects.size() > 1))
        {
        	if(collabSpace!=null){
        		%>
	    	    <span><select disabled="disabled" name="Project" id="Project" onchange="onProjectChange()">
<%
        	}else{
%>
            <span><select name="Project" id="Project" onchange="onProjectChange()">
<%
        	}
            for(int i = 0 ; i < projects.size() ; i++)
            {
                strProject = (String)projects.get(i);
                if (strProject.equals(strdefPrj))
                {
%>
                    <option selected="selected"><xss:encodeForHTML><%=strProject.trim()%></xss:encodeForHTML></option>
<%
                } else {
%>
                    <option><xss:encodeForHTML><%=strProject.trim()%></xss:encodeForHTML></option>
<%
                }
            }
%>
            </select></span>
<%
        } else {
            if( "true".equals(displaySingleValue))
            {

%>
                <input type="text" name="Project_txt" id="Project_txt" value="<xss:encodeForHTMLAttribute><%=strProject%></xss:encodeForHTMLAttribute>" disabled="disabled"/>
<%
            }
%>
            <input type="hidden" name="Project" id="Project" value="<xss:encodeForHTMLAttribute><%=strProject%></xss:encodeForHTMLAttribute>" />
<%
        }
%>
        </li>
        <li class="select-box">
<%
        if( "true".equals(sRoleToDisplay) )
        {
            if( "true".equals(displaySingleValue) || organizations.size() > 1 || (projects.size() > 1) || roles.size() > 1)
            {
%>
                <label><emxUtil:i18n localize="i18nId">emxFramework.SecurityContextSelection.Role</emxUtil:i18n></label>
<%
            }
            if( roles.size() > 1 || projects.size() > 1 || organizations.size() > 1)
            {
            	 
%>
                <span>
                <select name="Role" id="Role">
<%
                for(int i = 0 ; i < roles.size() ; i++)
                {
                    strRole = (String)roles.get(i);
                    String strRoleDisplay = strRole;
                    try
                    {
                    	strRoleDisplay = i18nNow.getRoleI18NString(strRole, languageStr);
                    } catch (Exception ex)
                    {
                    	//Do Nothing just display actual role name
                    }
                    if (strRole.equals(strdefRole))
                    {
%>
                        <option selected="selected" value="<xss:encodeForHTMLAttribute><%=strRole.trim()%></xss:encodeForHTMLAttribute>"><%=strRoleDisplay.trim()%></option>
<%
                    } else {
%>
                        <option value="<xss:encodeForHTMLAttribute><%=strRole.trim()%></xss:encodeForHTMLAttribute>"><%=strRoleDisplay.trim()%></option>
<%
                    }
                }
%>
                </select></span>
<%
            } else {
                if( "true".equals(displaySingleValue))
                {
                	String strRoleDisplay = strRole;
                	 try
                     {
                     	strRoleDisplay = i18nNow.getRoleI18NString(strRole, languageStr);
                     } catch (Exception ex)
                     {
                     	//just display actual role name
                     }
%>
                    <input type="text" name="Role_txt" id="Role_txt" value="<xss:encodeForHTMLAttribute><%=strRoleDisplay%></xss:encodeForHTMLAttribute>" disabled="disabled"/>
<%
                }
%>
                <input type="hidden" name="Role" id="Role" value="<xss:encodeForHTMLAttribute><%=strRole%></xss:encodeForHTMLAttribute>" />
<%
            }
        }
%>
        </li>
        <li class="buttons">
<%
        if (!"true".equalsIgnoreCase(switchContext))
        {
%>
            <button id="submitButton" onClick="mxSubmit(); return false;" class="btn-primary"><label><emxUtil:i18n localize="i18nId">emxFramework.SecurityContextSelection.Done</emxUtil:i18n></label></button>
<%
        } else {
%>
            <input type="hidden" name="ContentURL" />
            <input type="hidden" name="currentApp" />
            <input type="hidden" name="switchContext" />
            <button onClick="mxSubmitSwitchContext(); return false;" class="btn-primary"><emxUtil:i18n localize="i18nId">emxFramework.SecurityContextSelection.Done</emxUtil:i18n></button>
            <button onClick="mxCancel(); return false;" class="btn-default"><emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n></button>
<%
        }
%>
        </li>
        </ul>
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>        
        </div><!-- /.panel-body -->
        </form>
        </div><!-- /.panel-content -->
        </div><!-- /.panel -->
        </div><!-- /.wrap-inner -->
        </div><!-- /.wrap-outer -->
<%
        if (!"true".equalsIgnoreCase(switchContext))
        {
%>
            </body>
<%
        }
    }
} else {
    String loginurl = loginPage;
    if( !"".equals(paramNameValues) )
    {
        loginurl += "?" + paramNameValues;
    }
    loginurl = "/OAUTH_" + loginurl.split("/")[1];
    //System.out.println("USER IS NOT LOGGED IN SENDING TO LOGIN PAGE WITH URL AS == "+ loginurl);
%>
<!-- \\XSSOK -->
    <script>document.location.href="..<%=loginurl%>"</script>
<%
}
if (!"true".equalsIgnoreCase(switchContext))
{
%>
    </html>
<%
}
%>

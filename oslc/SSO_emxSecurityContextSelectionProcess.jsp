<%--  emxSecurityContextSelectionProcess.jsp   - security context selection process page for MatrixOne applications

   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxSecurityContextSelectionProcess.jsp $
--%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../emxRequestWrapperMethods.inc"%>
<%@ page import="com.matrixone.apps.domain.util.PersonUtil,java.net.URL,java.net.URLConnection,java.net.HttpURLConnection" %>
<%@ page import="java.lang.reflect.*,java.net.URLEncoder,org.apache.http.StatusLine,org.apache.http.params.*,org.apache.http.client.methods.*,org.apache.http.impl.client.DefaultHttpClient,org.apache.commons.io.IOUtils,org.apache.http.HttpEntity,org.apache.http.HttpResponse,com.matrixone.apps.domain.DomainConstants" %>
<html>
    <head>
<%
    //System.out.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! HD_EMXSECURITYCONTEXTSELECTIONPROCESS.jsp !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    Context context = Framework.getContext(session);
 %>
 <%
    String myAppsUrl ="";
	
	String redirectParam = request.getParameter("redirectParam");
	String mode = request.getParameter("mode");

//System.out.println("####PROCESSS####redirectParam.jsp ####"+redirectParam);
								String timeZone = (String) session.getAttribute("timeZone");
	  							//System.out.println("timeZone-----OAUTH-------->"+timeZone);
	
	
			String sessionTimeZone = context.getSession().getTimezone(); 
			TimeZone tj = TimeZone.getTimeZone(sessionTimeZone);
	     	int rawOffset = tj.getRawOffset();
	        double iClientTimeOffset = (new Double((new Double(-rawOffset)).doubleValue() / 3600000)).doubleValue();
			
				  							//System.out.println("iClientTimeOffset-----OAUTH-------->"+iClientTimeOffset);

				        session.setAttribute("timeZone", ""+iClientTimeOffset);  //required for SB.

			
	
    String ContentURL = emxGetParameter(request,"ContentURL");
    if( ContentURL != null && !"".equals(ContentURL) )
    {
       session.setAttribute("ContentURL", ContentURL);
    }
    String forwardURL = (String)session.getAttribute("ForwardURL");
    if (forwardURL != null && forwardURL.length() > 0 )
    {
        if(forwardURL.indexOf("//") == 0)
        {
            forwardURL = forwardURL.substring(1,forwardURL.length());
        }
    }
    else
    {
        forwardURL = "/common/emxNavigator.jsp";
    }

    String currentApp = emxGetParameter(request,"currentApp");
    if( currentApp != null && !"".equals(currentApp) )
    {
        if ( forwardURL.indexOf("?") > 0 ) {
        	forwardURL = forwardURL.trim() + "&appName=" + currentApp;
        } else {
        	forwardURL = forwardURL.trim() + "?appName=" + currentApp;
        }
    }
    
    String widgetId = emxGetParameter(request, "widgetId");
    String stremxNavigatorData = "emxNavigatorData";
    if(widgetId != null){
    	stremxNavigatorData = widgetId + "emxNavigatorData";
    }

    Map emxNavigatorData = (Map)session.getAttribute(stremxNavigatorData);
    if( emxNavigatorData != null )
    {
        Collection keySet = emxNavigatorData.keySet();
        Iterator keyItr = keySet.iterator();
        boolean firstParam = true;
        while( keyItr.hasNext() )
        {
            String paramName = (String)keyItr.next();
            String paramValue = (String)emxNavigatorData.get(paramName);
            if( forwardURL.indexOf("?") > 0 )
            {
                firstParam = false;
            }
            if( firstParam )
            {
                forwardURL += "?" +paramName + "=" + XSSUtil.encodeForURL(context, paramValue);
            } else {
                forwardURL += "&" +paramName + "=" + XSSUtil.encodeForURL(context, paramValue);
            }
        }
        session.removeAttribute(stremxNavigatorData);
    }
    String securityContext = emxGetParameter(request,"SecurityContext");
    try
    {
        forwardURL = Framework.getClientSideURL(response, forwardURL);
        String swContext = emxGetParameter(request,"SecurityContext");
        String scOrg = emxGetParameter(request,"Organization");
        String scPrj = emxGetParameter(request,"Project");
        String scRole = emxGetParameter(request,"Role");
        if(securityContext == null  || "".equals(securityContext))
        {
            securityContext = PersonUtil.getSecurityContext(context,scOrg,scPrj,scRole);
        }
        PersonUtil.setSecurityContext(session, securityContext);
        PersonUtil.setDefaultSecurityContext(context, securityContext);
        forwardURL+=(forwardURL.contains("?") ? "&collabSpace=":"?collabSpace=")+PersonUtil.getDefaultProject(context, context.getUser());
    }
    catch(Exception e)
    {
        //System.out.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Unable To Set Security Context !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        e.printStackTrace();
      //throw e;
    }
    //String callingpage = (String)session.getAttribute("switchContext");
    String callingpage = emxGetParameter(request,"switchContext");
    if (callingpage == null)
    {
        callingpage = (String)session.getAttribute("switchContext");
    }
    if ("true".equalsIgnoreCase(callingpage) )
    {
        String proxyTicket = null;
        try
        {
            Class objectTypeArray[] = new Class[2];
            objectTypeArray[0] = HttpServletRequest.class;
            objectTypeArray[1] = String.class;
            Class c = Class.forName("com.dassault_systemes.dspassport.cas.client.proxyticket.CASProxyTicketManager");
            Object obj = c.newInstance();
            Method method = c.getMethod("getProxyTicket", objectTypeArray);
            proxyTicket = (String)method.invoke(obj, request, "V6");
        }
        catch (Exception ce)
        {
          //ce.printStackTrace();
          //Do nothing
          //System.out.println("Failed to get Proxy Ticket for MyApps to update LastUsed SecurityContext");
        }
        if(proxyTicket != null )
        {
            DefaultHttpClient httpclient = new DefaultHttpClient();
            try
            {
                String url = FrameworkUtil.getMyAppsURL(context, request,response) + "/resources/AppsMngt/cstorages/setlastused?";
                url = url +"cstorage="+context.getTenant();
                url = url +"&cspace="+XSSUtil.encodeForURL(securityContext);
                url = url +"&proxyTicket="+proxyTicket;
                HttpPost adduser = new HttpPost(url);
                adduser.addHeader("Accept", "application/ds-json");
                adduser.addHeader("Accept-Language", "en-US,en");
                String Resp = null;
                HttpResponse respClient = httpclient.execute(adduser);
                HttpEntity entity = respClient.getEntity();
                Resp = IOUtils.toString(entity.getContent());
            } catch (Exception ex) {
                ex.printStackTrace();
                System.out.println("Failed to update MyApps with LastUsed SecurityContext");
            }
            finally
            {
                httpclient.getConnectionManager().shutdown();
            }
        }
    }
	
	session.removeAttribute("ForwardURL");
	
	
	//System.out.println("ticket  "+request.getParameter("ticket"));
	//System.out.println("!!!!!!redirectParam!!"+redirectParam);

				//redirectParam=redirectParam+"&mode="+mode;
				
		//System.out.println("!!!!FORWORD TO Final JSP !!redirectParam!!"+redirectParam);
				//System.out.println("!!!!FORWORD TO Final JSP !!mode!!"+mode);

				
%>
    <script>
        
        var ticket = "<%=request.getParameter("ticket")%>";
        var jSessionID = "<%=session.getId()%>";
		var strURL = "<%=redirectParam%>";
		var mode = "<%=mode%>";
		//alert("strURL---"+strURL);
        document.location.href=strURL+"&mode="+mode;
		//document.location.href="http://" + port + "/AuthorizeToken?oauth_token=" + rToken + "&ticket=" + ticket + "&jSessionID=" + jSessionID;
    </script>
  </head>
</html>

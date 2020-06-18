<%--
    
   Copyright (c) 2009 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes,
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   emxAutoLogin.jsp - Login page using GET mode that redirects to the MatrixOne login page (using POST mode)

   Parameters:
         session  : the session ID
         tk       : the one-use ticket
         forward  : the JSP page to be redirected to

         Other parameters are considered as 'forward' page parameters
   
--%>

<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.MissingResourceException" %>
<%@ page import="javax.servlet.http.Cookie"%>
<%@ page import="com.matrixone.jsystem.util.Base64Utils" %>
<%@ page import="com.dassault_systemes.vplmsecurity.PLMSecurityLoginSession" %>
<%@ page import="com.dassault_systemes.vplmsecurity.util.NLSException" %>
<%@ page import="com.dassault_systemes.vplmsecurity.util.MsgCatalog" %>
<%@ page import="com.dassault_systemes.plmsecurity.util.Logger" %>
<%@ page import="com.matrixone.servlet.Framework"%>

<%-- @include file = "../common/emxPLMOnlineAdminIncludeNLS.jsp" --%>

<%!
    private static Logger _log = Logger.getLogger("SilentLogin");

    private void dbg(String message)
    {
        _log.debug(message);
    }

    private String notNull(String str) {
        return (str==null) ? "null" : str;
    }

	private String getNLSOrDefault(MsgCatalog msg, String tag, String default_value)
	{
        String value = default_value;
        try {
            if (msg!=null) value = msg.getMessage(tag);
        }
        catch (MissingResourceException ex) {}
        return value;
    }

    private void setCookies(HttpServletResponse resp, String str) {
        String[] cookies = str.split("\n");
        int nb_cookies = (cookies==null) ? 0 : cookies.length;
        dbg("Cookies: "+nb_cookies);
        for (int i = 0; i < nb_cookies; i++) {
            String sCookie = cookies[i];
            String[] values = sCookie.split(";");
            if (values==null||values.length<1) {
                // error: not a valid cookie
                ///System.out.println("ERROR: cookie #"+i+" ["+sCookie+"] is invalid");
                _log.error("ERROR: cookie #"+i+" ["+sCookie+"] is invalid");
                continue;
            }
            // 1) name = value
            int idx = values[0].indexOf('=');
            if (idx<=0) {
                // error: not a valid cookie
                ///System.out.println("ERROR: ["+values[0]+"] is not a valid cookie 'name=value' pair");
                _log.error("ERROR: ["+values[0]+"] is not a valid cookie 'name=value' pair");
                continue;
            }
            String cookie_path  = "";
            String cookie_domain= "";
            String cookie_name  = values[0].substring(0,idx);
            String cookie_value = values[0].substring(idx+1);
            Cookie cookie = new Cookie(cookie_name, cookie_value);
            // 2) path
            if (values.length>1 && values[1].length()>0) {
                values[1] = values[1].trim();
                int idxPath = values[1].indexOf("Path=");
                cookie_path = (idxPath >= 0) ? values[1].substring(idxPath+5): values[1];
                cookie.setPath(cookie_path);
            }
            // 3) domain
            if (values.length>2 && values[2].length()>0) {
                values[2] = values[2].trim();
                int idxDomain = values[2].indexOf("Domain=");
                cookie_domain = (idxDomain >= 0) ? values[2].substring(idxDomain+7): values[2];
                cookie.setDomain(cookie_domain);
            }
            /**
             * With current JAVA compilation level, it is not possible to use 1.7 methods (setHttpOnly, setSecure)
             *
            // 4) httponly
            if (values.length>3 && values[3].length()>0) {
                values[3] = values[3].trim();
                boolean httponly = "y".equalsIgnoreCase(values[3])||"httponly".equalsIgnoreCase(values[3]);
                cookie.setHttpOnly(httponly);
            }
            // 5) secure
            if (values.length>4 && values[4].length()>0) {
                values[4] = values[4].trim();
                boolean secure = "y".equalsIgnoreCase(values[4])||"secure".equalsIgnoreCase(values[4]);
                cookie.setSecure(secure);
            }
            */
            dbg("> Cookie [name="+cookie_name+", value="+cookie_value+", path="+cookie_path+", domain="+cookie_domain+"]");
            resp.addCookie(cookie);
        }
    }
%>
<%
/**
 * 
 */
    ///initTrace("SilentLogin");
    Locale locale = request.getLocale();
    if (locale==null) locale = Locale.getDefault();
    MsgCatalog msg = null;
    try {
        msg = new MsgCatalog("emxAutoLogin", locale);
    }
    catch (Exception ex) {
        _log.warn("Could not find emxAutoLogin Catalog [{}]", ex.getMessage());
    }
    ///initNLSCatalog("emxAutoLogin",request);
    String  sDebug  = request.getHeader("X-login-debug");
    boolean bDebug  = (sDebug!=null);
    String sToken64 = request.getParameter("token");
    String sSession = request.getParameter("session");
    String sTicket  = request.getParameter("tk");
    String sPath    = request.getContextPath();
    String sForward = request.getParameter("forward");
    String sSessionName  = request.getParameter("sessionname");
    String sCleanSession = request.getParameter("cleansession");
    String sRequestParamList = "token,session,sessionname,cleansession,forward,tk";
    String[] listParam = sRequestParamList.split(",");
    Vector enumListParam = new Vector();
    for (int iElem = 0; iElem < listParam.length; iElem++) {
        String elemParam = listParam[iElem];
        enumListParam.add(elemParam);
    }
    boolean bInvalidateSession = false;
    try {
        _log.traceIn("SilentLogin");
        dbg("parameters:");
        dbg("> session = "+sSession);
        dbg("> ticket  = "+sTicket);
        dbg("> path    = "+sPath);
        dbg("> token   = "+sToken64);
        //
        // forward parameter and its arguments
        //
        if (sForward==null || sForward.length()<=0) {
            sForward = "/common/emxNavigator.jsp";
        }
        String sForwardURL = sForward;
        StringBuffer sForwardParam = null;
        dbg("> forward = "+sForward);
        //
        Enumeration lParams = request.getParameterNames();
        while (lParams.hasMoreElements()) {
            // 
            String sParamName = (String)lParams.nextElement();
            //sRequestParamList.indexOf(sParamName)<0)
            if (!enumListParam.contains(sParamName)) {
                String sTemp = null;
                dbg("> param["+sParamName+"] = ["+request.getParameter(sParamName)+"]");
                if (sForwardParam == null) {
                    sForwardParam = new StringBuffer(sParamName);
                }
                else {
                    sForwardParam.append("&");
                    sForwardParam.append(sParamName);
                }
                sForwardParam.append("=");
                sTemp = request.getParameter(sParamName);
                // Encode pipe | character to avoid issues
                if (sTemp != null) {
                    sForwardParam.append(sTemp.replace("|","%7C"));
                }
            }
        }
        if (sForwardParam!=null && sForwardParam.length()>0) {
            sForwardURL += "?" + sForwardParam;
            dbg("> all parameters = ["+sForwardParam+"]");
        }
        // this session
        String sThisSession = (session==null) ? "null" : session.getId();
        //
        String sCheckTicket = Framework.getPropertyValue(session,"ematrix.autologin.checkticket");
        //boolean bCheckTicket = !("false".equalsIgnoreCase(sCheckTicket));
        boolean bCheckTicket = ("true".equalsIgnoreCase(sCheckTicket));
        dbg("> check ticket = ["+bCheckTicket+"]");
        //
if ("new".equals(sDebug)) {
        if (sToken64!=null && sToken64.length()>0) {
            //
            // -------------------------------------------------------------------
            // JSP forward to self with cookies (including session cookie)
            // -------------------------------------------------------------------
            //
            response.setHeader("Cache-Control", "no-cache");
            // set all cookies
            String sToken = new String(Base64Utils.decode(sToken64));
            if (session!=null && (request.getRequestedSessionId()==null || !PLMSecurityLoginSession.compareSessions(sThisSession,request.getRequestedSessionId()))) {
                bInvalidateSession = true;
            }
            if (request.getRequestedSessionId()!=null && PLMSecurityLoginSession.compareSessions(sThisSession,request.getRequestedSessionId())) {
                // special case : subsequent request (hopefully, came on same session already)
                // should forward to target url directly
                dbg("INFO: already right session - forward to target url directly");
                response.setHeader("X-debug-session-action",   "Already right session - forward to target url directly");
                sForwardURL = sPath + sForwardURL;
                // checking ticket
                if (sTicket==null || sTicket.length()<=0) {
                    // no ticket: abort
                    throw new NLSException("Exception.MissingTicket", "PLMSecurityLoginSession", request.getLocale());
                }
                sSession = request.getRequestedSessionId();
                PLMSecurityLoginSession.checkTicket(sSession,sTicket,null);
            }
            else {
                dbg("INFO: Forward to self with cookies");
                response.setHeader("X-debug-session-action",   "Forward to self with cookies");
                // new session : must set cookies
            dbg("> cookies = ["+sToken+"]");
            setCookies(response, sToken);
                // forward to self, with no 'token' and 'session' parameters
                sForwardURL = request.getRequestURI()+"?tk="+sTicket+"&forward="+sForward;
                if (sForwardParam!=null && sForwardParam.length()>0) {
                    sForwardURL += "&" + sForwardParam;
                }
        }
            if (bDebug) {
                response.setHeader("X-debug-session-params",   sSession);
                response.setHeader("X-debug-session-server",   sThisSession);
                response.setHeader("X-debug-session-requested",   request.getRequestedSessionId());
                response.setHeader("X-debug-session-invalidate",   Boolean.toString(bInvalidateSession));
                //response.setHeader("X-debug-session-comp",   Boolean.toString(bSessionOnThisServer));
            }
            dbg("Forwarding to: "+sForwardURL);
            response.sendRedirect(sForwardURL);
        }
        else {
            //
            // -------------------------------------------------------------------
            // JSP forward to target
            // -------------------------------------------------------------------
            //
            dbg("INFO: Forward to target url");
            response.setHeader("Cache-Control", "no-cache");
            // must close (invalidate) this HttpSession if (and only if) it
            // does not correspond to the targeted session (sSession).
            // This avoids opening too many session just to execute this JSP.
            if (session!=null && !PLMSecurityLoginSession.compareSessions(request.getRequestedSessionId(), sThisSession)) {
                bInvalidateSession = true;
            }
            if (bDebug) {
                response.setHeader("X-debug-session-action",   "Forward to target url");
                response.setHeader("X-debug-session-server",   sThisSession);
                response.setHeader("X-debug-session-requested",   request.getRequestedSessionId());
                response.setHeader("X-debug-session-invalidate",   Boolean.toString(bInvalidateSession));
                //response.setHeader("X-debug-session-comp",   Boolean.toString(bSessionOnThisServer));
            }
            // checking ticket
            if (sTicket==null || sTicket.length()<=0) {
                // no ticket: abort
                //throw new IllegalArgumentException("MISSING TICKET WITH SESSION");
                throw new NLSException("Exception.MissingTicket", "PLMSecurityLoginSession", request.getLocale());
            }
            sSession = request.getRequestedSessionId();
            if (sSession==null || sSession.length()<=0) {
                // no session: abort
                throw new NLSException("Exception.MissingSession", "PLMSecurityLoginSession", request.getLocale());
            }
            PLMSecurityLoginSession.checkTicket(sSession,sTicket,null);
            // forward
            dbg("Forwarding to: "+sPath+sForwardURL);
            response.sendRedirect(sPath+sForwardURL);
        }
}
else {
        //
        if (sSession!=null && sSession.length()>0) {
            //
            // -------------------------------------------------------------------
            // JSP forward based on session ID
            // -------------------------------------------------------------------
            //
            response.setHeader("Cache-Control", "no-cache");
            dbg("Using session ID");
            // checking ticket
            if (bCheckTicket) {
                if (sTicket==null || sTicket.length()<=0) {
                    // no ticket: abort
                    //throw new IllegalArgumentException("MISSING TICKET WITH SESSION");
                    throw new NLSException("Exception.MissingTicket", "PLMSecurityLoginSession", request.getLocale());
                }
                PLMSecurityLoginSession.checkTicket(sSession,sTicket,null);
            }

            // servlet properties
            String default_session_cookie = null;
            try { default_session_cookie = Framework.getPropertyValue(session,"ematrix.login.sessioncookie"); } catch (Exception e) {}
            if (default_session_cookie==null) default_session_cookie = "JSESSIONID";

            // redirect url
            dbg("Forwarding to: "+sPath+sForwardURL);
            // set session ID on cookie response
            // - this is required to reuse same session
            //   (and avoid re-authentication case in external authentication mode)
            if (sSessionName==null || sSessionName.length()<=0) { sSessionName = default_session_cookie; }

            //  checking no 'sSessionName' cookie already exists
            dbg("Session: ");
            dbg("  {"+(session==null ? "(none)" : session.getId())+"}");
            Cookie[] cookies = request.getCookies();
            boolean bSessionIsAlreadySet = false;
            if( cookies != null ){
                dbg("Cookies ("+cookies.length+")");
                for (int i = 0; i < cookies.length; i++){
                    Cookie cookie = cookies[i];
                    if((cookie.getName()).compareTo(sSessionName) == 0 ){
                        if((cookie.getValue()).compareTo(sSession) == 0 ){
                            dbg("  {"+cookie.getValue()+"} => ALREADY SET");
                            bSessionIsAlreadySet = true;
                            if (bDebug) {
                                response.setHeader("X-debug-session-cookie-already-set",   cookie.getValue());
                            }
                        }
                        else {
                            dbg("  {"+cookie.getValue()+"} => DELETING");
                            cookie.setMaxAge(0);
                            response.addCookie(cookie);
                            if (bDebug) {
                                response.setHeader("X-debug-session-cookie-deleting",   cookie.getValue());
                            }
                        }
                    }
                }
            }
            else {
                dbg("Cookies (none)");
            }
            
            String sCookiePath = (String)(sPath.endsWith("/") ? sPath : sPath + "/");
            dbg("SetCookie "+sSessionName+"={"+sSession+"} for path "+sCookiePath);
            Cookie cookie = new Cookie(sSessionName, sSession);
            // Tomcat7 issue:
            //   need to set cookie path with same path as the one used for
            //   session cookie during login (now ends with / - ex: /enovia/)
            if (sCookiePath != null) cookie.setPath(sCookiePath);
            //
            response.addCookie(cookie);
            // must close (invalidate) this HttpSession if (and only if) it
            // does not correspond to the targeted session (sSession).
            // This avoids opening too many session just to execute this JSP.
            //if (session.getId().compareTo(sSession) != 0) {
            if (bCheckTicket) {
                if (session!=null && !PLMSecurityLoginSession.compareSessions(sSession,session.getId())) {
                    bInvalidateSession = true;
                }
            }
            if (bDebug) {
                response.setHeader("X-debug-session-requested", (String)((request.getRequestedSessionId()==null)?"null":request.getRequestedSessionId()));
                response.setHeader("X-debug-session-parm",   sSession);
                response.setHeader("X-debug-session-server",   sThisSession);
                response.setHeader("X-debug-set-cookie",     sSessionName+"="+sSession+", path="+sCookiePath);
                response.setHeader("X-debug-forward-to",     sPath+sForwardURL);
                response.setHeader("X-debug-session-invalidate",   Boolean.toString(bInvalidateSession));
                //response.setHeader("X-debug-session-comp",   Boolean.toString(bSessionOnThisServer));
            }
            // forward
            response.sendRedirect(sPath+sForwardURL);
}
%>
<%
        }
    }
    catch(Exception e)
    {
        String sAdvice = "";
        String sRedirectMsg = "";
        ///System.out.println("Exception: " + e);
        ///e.printStackTrace();
        _log.error("SilentLogin raised exception", e);
        if (e instanceof NLSException) {
            sRedirectMsg = getNLSOrDefault(msg, "Exception.Type.IllegalAccess","Illegal Access");
            sAdvice = ((NLSException)e).getAdvice();
        }
        String sErrorTitle = "HTTP Status 403 - "+getNLSOrDefault(msg, "SilentLogin.Title.Forbidden","Forbidden");
%>
<html>
<head>
<title><%=sErrorTitle%></title>
<style>
BODY {font-family:Tahoma,Arial,sans-serif;color:black;background-color:white;} 
H1   {color:white;background-color:#525D76;font-size:22px;} 
B    {color:white;background-color:#525D76;} 
.msg {color:red;  font-size:22px;} 
HRbis   {color : #525D76;}
</style>
</head>
<body>
    <h1><%=sErrorTitle%></h1>
    <HR size="1" noshade="noshade">
<%
    if (sRedirectMsg.length()>0) {
%>
        <p/><b><%=getNLSOrDefault(msg, "SilentLogin.Paragraph.ErrorType","Error Type")%>:</b> <%=sRedirectMsg%>
<%
    }
%>
    <p/><b><%=getNLSOrDefault(msg, "SilentLogin.Paragraph.Message","Message")%>:</b> <font class="msg"><%=e.getMessage()%></font>
<%
    if (sAdvice!=null) {
%>
        <p/><b><%=getNLSOrDefault(msg, "SilentLogin.Paragraph.Advice","Advice")%>:</b> <%=sAdvice%>
<%
    }
    if (_log.isDebugEnabled()) {
%><pre><%
        PrintWriter w = new PrintWriter(out);
        e.printStackTrace(w);
%></pre><%
    }
%>
    <HR size="1" noshade="noshade">
</body>
</html>
<%
    }
    finally {
        if (bInvalidateSession) {
            if (sCleanSession != null) {
                dbg("Session.invalidate() = {"+session.getId()+"}");
                session.invalidate();
            }
        }
        _log.traceOut();
    }
%>


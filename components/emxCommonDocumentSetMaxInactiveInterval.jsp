<%-- emxCommonDocumentSetMaxInactiveInterval.jsp --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle" %>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>

<%
int interval = session.getMaxInactiveInterval();
int maxInterval = Integer.parseInt((String)FrameworkProperties.getProperty(context,"emxFramework.ServerTimeOutInSec"));
if(interval != maxInterval  && session.getAttribute("InactiveInterval") == null) {
	session.setMaxInactiveInterval(maxInterval);
	session.setAttribute("InactiveInterval", new Integer(interval));
} else {
	interval = ((Integer)session.getAttribute("InactiveInterval")).intValue();
    session.setMaxInactiveInterval(interval);
	session.removeAttribute("InactiveInterval");
}
	
	String srvTime;
	String srvExpiryTime;
	try{
		srvTime = EnoviaResourceBundle.getProperty(context, "emxFramework.SessionTimeout.AutoLogout.Cookie.ServerTime");
		srvExpiryTime = EnoviaResourceBundle.getProperty(context, "emxFramework.SessionTimeout.AutoLogout.Cookie.ServerExpiryTime");
	} catch(Exception e) {
		srvTime = "eno-bps-server-time";
		srvExpiryTime = "eno-bps-server-expiry-time";
	}
	final long currTime = System.currentTimeMillis();
	final long expiryTime = currTime + (session.getMaxInactiveInterval() * 1000);
	
	Cookie[] cookiesArray = request.getCookies();
	for(Cookie cookie: cookiesArray) {
		String cookieName = cookie.getName();
		if(srvTime.equals(cookieName)) {
			cookie.setValue("");
			cookie.setPath("/");
			cookie.setMaxAge(0);
			response.addCookie(cookie);
			cookie = new Cookie(srvTime, Long.toString(currTime));
			cookie.setPath("/");
			response.addCookie(cookie);
		} else if(srvExpiryTime.equals(cookieName)) {
			cookie.setValue("");
			cookie.setPath("/");
			cookie.setMaxAge(0);
			response.addCookie(cookie);
			cookie = new Cookie(srvExpiryTime, Long.toString(expiryTime));
			cookie.setPath("/");
			response.addCookie(cookie);
		}
	}
%>

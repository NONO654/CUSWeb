<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>

<%@page import="org.apache.http.client.HttpClient"%>
<%@page import="org.apache.http.client.entity.UrlEncodedFormEntity"%>
<%@page import="org.apache.http.HttpEntity"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.StatusLine"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="org.apache.http.client.methods.*"%>
<%@page import="org.apache.http.params.*" %>
<%@page import="org.apache.http.impl.client.DefaultHttpClient"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.dassault_systemes.dspassport.cas.client.proxyticket.CASProxyTicketManager"%>
<%@page import="org.apache.commons.io.IOUtils"%>
<%@page import="java.util.*" %>
<%@page import="com.dassault_systemes.platform.ven.jackson.databind.*" %>
<%@ page import="com.dassault_systemes.i3dx.rest.appservices.AppsResource" %>
<%@ page import="com.dassault_systemes.i3dx.rest.appservices.SecurityResources" %>
<%@ page import="com.dassault_systemes.i3dx.rest.appservices.UsersMngtResource" %>
<%@ page import="com.dassault_systemes.i3dx.rest.appservices.EnvironmentResource" %>
<%@ page import="com.dassault_systemes.i3dx.rest.appservices.RoleResource" %>

<%@page import="javax.ws.rs.core.Response"%>
<%@page import="org.slf4j.Logger"%>
<%@page import="org.slf4j.LoggerFactory"%>

<%

Logger logger = LoggerFactory.getLogger("emxCrossDomainProxy");
logger.debug("CROSS DOMAIN PROXY");

// set favorite input parameters
String favorite_value = "";

// are we onPremise ?
String podDefinitionName = PropertyUtil.getEnvironmentProperty(context, "PodDefinitionName");
boolean onPremise = podDefinitionName == null || podDefinitionName.isEmpty();

logger.debug("OnPremise: {}", onPremise);

// read parameters
Map<String, String> parameters = new HashMap<String, String>();
parameters.put("type", "");
parameters.put("method", "");
parameters.put("url", "");

Map<String, String> headers = new HashMap<String, String>();
String post = "";

for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
    String param = entry.getKey();
    String[] values = entry.getValue();

    if (param.matches("^headers\\[.*\\]$")) {
        logger.debug("Header param {}", param);
        String h = param.substring(param.indexOf("[") + 1, param.length() - 1).toLowerCase();
        logger.debug("Header {}", h);
        if (values != null && values.length > 0) {
            String v = "";
            for(int i = 0; i < values.length; i++) {
                v += values[i];
                if (i < values.length - 1) {
                    v += ";";
                }
            }
            headers.put(h, v);
            logger.debug("header[{}]={}", h, v);
        }
    } else {
        logger.debug("Classic param {}", param);
        if (values != null && values.length > 0) {
            parameters.put(param, values[0]);
		post=post+param+"="+ values[0];
            logger.debug("param[{}]={}", param, values[0]);
        }
    }
}

String type = parameters.get("type");
String method = parameters.get("method");
String url = parameters.get("url");

if (method == null || method.isEmpty()) {
    method = request.getMethod().toString();
}

// url argument is required
if (url == null || url.isEmpty()) {
    response.setStatus(403);
    return;
}

String myappsURL = PropertyUtil.getEnvironmentProperty(context, "MYAPPS_URL");
String passportURL = PropertyUtil.getEnvironmentProperty(context, "PASSPORT_URL");
logger.debug("MyApps url {}", myappsURL);

// on cloud we need to build target URL
if (!onPremise) {
    // get proxy ticket
    CASProxyTicketManager casManager = new CASProxyTicketManager();
    String proxyTicket = casManager.getProxyTicket(request, "V6");
    logger.debug("ProxyTicket {}", proxyTicket);

    if (!url.contains("?")) {
        url += "?proxyticket=" + proxyTicket;
    } else {
        url += "&proxyticket=" + proxyTicket;
    }
    logger.debug("url {}", url);
}

// use service URL if relative url given
if (! (url.startsWith("http") || url.startsWith("https")) ) {
    url = myappsURL + url;
    logger.debug("built url {}", url);
}

// compass input parameters
String compass_envid = "";
String compass_objid = "";
String compass_objtype = "";
String compass_contextid = "";
String compass_webonly = "";
String compass_os = "";
String compass_id = "";

// set preference input parameters
String preference_install = "";
String preference_platform = "";
String preference_appid = "";
String preference_name= "";
String preference_value= "";
String file= "";

// parse query string if any
if (url.contains("?")) {
    // get query string
    String query = url.substring(url.indexOf("?") + 1, url.length());
    logger.debug("query string {}", query);
    // remove original query string
    url = url.substring(0, url.indexOf("?") + 1);
    if (query != null && !query.isEmpty()) {
        String[] parts = query.split("&");
        String join = "";
        for(String part: parts) {
            logger.debug("token {}", part);
            String[] p = part.split("=");
            if (p.length == 2) {
                String key = p[0];
                String value = URLEncoder.encode(p[1]);
                logger.debug("key {}", key);
                logger.debug("value {}", value);
                url += join + key + "=" + value;
                logger.debug("url {}", url);
                join = "&"; 
                // set arguments for onpremise
                if (key.equals("envid")) compass_envid = value;
                if (key.equals("objid")) compass_objid = value;
                if (key.equals("objtype")) compass_objtype = value;
                if (key.equals("contextid")) compass_contextid = value;
                if (key.equals("webonly")) compass_webonly = value;
                if (key.equals("os")) compass_os = value;
                if (key.equals("id")) compass_id = value;
                if (key.equals("preferredInstall")) preference_install = value;
                if (key.equals("preferredPlatform")) preference_platform = value;
                if (key.equals("appid")) preference_appid = value;
                if (key.equals("value")) favorite_value = value;
		  if (key.equals("value")) preference_value = value;
 		  if (key.equals("name")) preference_name = value;
		  if (key.equals("file")) file = value;
            }
        }
    }
}

// make request
if (!onPremise || (onPremise && url.startsWith(passportURL)) ){
    // cloud: make actual request
    logger.debug("make request");
    DefaultHttpClient client = new DefaultHttpClient();
    try {
        HttpRequestBase req;

        if (method.equalsIgnoreCase("post")) {
            req = new HttpPost(url);

            // forward request body
            logger.debug("Forward request body");
            logger.debug("Get input stream");
            InputStream inputStream = request.getInputStream();
            logger.debug("Read input stream");
            StringBuilder sb = new StringBuilder();
            int c;
            try {
                while((c = inputStream.read()) != -1){
                    sb.append((char) c);
                }
            } catch (Exception e) {
                logger.error("Unable to read request body", e);
                response.setStatus(500);
                return;
            }

            String body = sb.toString();
          
 		logger.debug("Forwarded body is {}", body);
		if (null != parameters.get("process") && !parameters.get("process").isEmpty()){
			post = "process="+parameters.get("process");
		}
		if (null != parameters.get("value") && !parameters.get("value").isEmpty()){
			post = "value="+parameters.get("value");
		}
		if (null != parameters.get("envids") && !parameters.get("envids").isEmpty()){
			post = "envids="+parameters.get("envids");
		}

            ((HttpPost) req).setEntity(new StringEntity(post));
		req.setHeader("Content-Type","application/x-www-form-urlencoded");

        } else {
		logger.debug("URL {}",url);
            req = new HttpGet(URLDecoder.decode(url));
        }
        logger.info(req.toString());

        // forward headers
        /*
        logger.debug("forward headers");
        Enumeration<String> headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String header = headerNames.nextElement();
            String value = request.getHeader(header);
            logger.debug("header[{}]={}", header, value);
            if (headers.containsKey(header)) {
                value = headers.get(header);
                logger.debug("Override header {} with {}", header, value);
            }
            //req.setHeader(header, value);
        }
        */

        // add headers
        for (Map.Entry<String, String> entry : headers.entrySet()) {
            String header = entry.getKey();
            String value = entry.getValue();
            logger.debug("Set header {}: {}", header, value);
            req.setHeader(header, value);
        }
        // forward cookie header
        String cookie = request.getHeader("Cookie");
        if (cookie != null && !cookie.isEmpty()) {
            req.setHeader("Cookie", cookie);
        }

        HttpResponse resp = client.execute(req);
        logger.debug(resp.getStatusLine().toString());
        logger.debug(resp.toString());
        response.setStatus(resp.getStatusLine().getStatusCode());

        HttpEntity entity = resp.getEntity();
        String body = "";
        if (entity != null) {
            body = IOUtils.toString(entity.getContent());
            logger.debug("body {}", body);
        }

        response.getWriter().write(body);
    } catch (Exception e) {
        logger.error("Exception", e);
        response.setStatus(500);
        return;
    } finally {
        client.getConnectionManager().shutdown();
    }
} else {
    // onpremise: directly call service
    try {
        if(url.contains("setPreferences")) {
            UsersMngtResource userMngtResource = new UsersMngtResource();

            Response resp = userMngtResource.setUserPreferences(request, preference_name, URLDecoder.decode(preference_value,"UTF-8"), preference_platform, preference_install, preference_appid);

            ObjectMapper mapper = new ObjectMapper();
            response.addHeader("Content-Type", "application/json");
            mapper.writeValue(response.getWriter(), resp.getEntity());
        } else if(url.contains("setFavorite")) {
            UsersMngtResource userMngtResource = new UsersMngtResource();
            Response resp = userMngtResource.setFavoriteApps(request, URLDecoder.decode(parameters.get("value"),"UTF-8"));

            ObjectMapper mapper = new ObjectMapper();
            response.addHeader("Content-Type", "application/json");
            mapper.writeValue(response.getWriter(), resp.getEntity());
        } else if(url.contains("compass")) {
            AppsResource appsResource = new AppsResource();
            Response resp = appsResource.getCompass(request, compass_envid, compass_objid, compass_objtype, compass_contextid, "", compass_os, compass_id);
            ObjectMapper mapper = new ObjectMapper();

            response.addHeader("Content-Type", "application/json");
            mapper.writeValue(response.getWriter(), resp.getEntity());
        } else if(url.contains("role/request")) {
            RoleResource roleResource = new RoleResource();
            Response res = roleResource.requestRole(request, parameters.get("platform"), parameters.get("process"));
            ObjectMapper mapper = new ObjectMapper();
            response.addHeader("Content-Type", "application/json");
            mapper.writeValue(response.getWriter(), res.getEntity());
        } else if(url.contains("encrypt")) {
            SecurityResources secResource = new SecurityResources();
            Response res = secResource .encrypt(request, parameters.get("value"));
            ObjectMapper mapper = new ObjectMapper();
            response.addHeader("Content-Type", "text/plain");
            mapper.writeValue(response.getWriter(), res.getEntity());

        } else if(url.contains("startup")) {
            UsersMngtResource userMngtResource = new UsersMngtResource();
            Response resp = userMngtResource.startup(request, "",false, "FALSE", false, "");

            ObjectMapper mapper = new ObjectMapper();
            response.addHeader("Content-Type", "application/json");
            mapper.writeValue(response.getWriter(), resp.getEntity());
        } else if(url.contains("setlegal/cookie")) {
            UsersMngtResource userMngtResource = new UsersMngtResource();
            Response resp = userMngtResource.cookies(request, parameters.get("envids"));

            ObjectMapper mapper = new ObjectMapper();
            response.addHeader("Content-Type", "application/json");
            mapper.writeValue(response.getWriter(), resp.getEntity());
        } else if(url.contains("setlegal")) {
            UsersMngtResource userMngtResource = new UsersMngtResource();
            Response resp = userMngtResource.setLegal(request, parameters.get("envids"));

            ObjectMapper mapper = new ObjectMapper();
            response.addHeader("Content-Type", "application/json");
            mapper.writeValue(response.getWriter(), resp.getEntity());
        } else if(url.contains("checkoutticket")) {
            EnvironmentResource envResource = new EnvironmentResource();
            Response resp = envResource.getCheckoutTicket(request, response, compass_envid, URLDecoder.decode(URLDecoder.decode(file,"UTF-8"),"UTF-8"));
            ObjectMapper mapper = new ObjectMapper();
            response.addHeader("Content-Type", "application/json");
            mapper.writeValue(response.getWriter(), resp.getEntity());
        } else if(url.contains("user/process")) {
            UsersMngtResource userMngtResource = new UsersMngtResource();
            Response resp = userMngtResource.getProcesses(request, parameters.get("platform"));

            ObjectMapper mapper = new ObjectMapper();
            response.addHeader("Content-Type", "application/json");
            mapper.writeValue(response.getWriter(), resp.getEntity());
        } else {
            response.setStatus(404);
            return;
        }
    } catch(Exception e) {
        logger.error("Exception", e);
        response.setStatus(500);
        return;
    }
}
%>

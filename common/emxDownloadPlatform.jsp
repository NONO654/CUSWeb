<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>

<%@page import="org.apache.http.client.HttpClient"%>
<%@page import="org.apache.http.HttpEntity"%>
<%@page import="org.apache.http.HttpResponse"%>
<%@page import="org.apache.http.StatusLine"%>
<%@page import="org.apache.http.client.methods.*"%>
<%@page import="org.apache.http.params.*" %>
<%@page import="org.apache.http.impl.client.DefaultHttpClient"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="org.apache.commons.io.IOUtils"%>
<%@page import="java.util.*" %>
<%@page import="javax.ws.rs.core.Response"%>
<%@page import="java.io.InputStream"%>
<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import="java.net.URLDecoder"%>

<%
 	String iCallBack = (String)emxGetParameter(request,"callback");
	String iURLs = (String)request.getQueryString();
	
	//Get URL from the query string 
	String iURLSplit[] = iURLs.split("url=");
	if(iURLSplit.length < 2 ) {
		response.setStatus(403);
		return;
	}

	String iURL = URLDecoder.decode(iURLSplit[1],"UTF-8");
	if(iURL==null || iURL.length()==0) {
		response.setStatus(403);
		return;
	}

	// read request body
	InputStream in=request.getInputStream();
	StringBuffer xmlStr=new StringBuffer();
	int d;
	while((d=in.read()) != -1){
          xmlStr.append((char)d);
	}



	String downloadURL = PropertyUtil.getEnvironmentProperty(context, "ONLINE_INSTALL_URL");
	// For security purposes accept only download platform URL
	if(iURL.contains(downloadURL) || downloadURL.contains(iURL)  ){
		ArrayList privateParameters = new ArrayList();
		privateParameters.add("url");
		String parameterName = "";
		String formData = "";
		Enumeration requestParameterNames = request.getParameterNames();
		BasicHttpParams httpParams = new BasicHttpParams();
		while ( requestParameterNames.hasMoreElements() ) {
			parameterName = requestParameterNames.nextElement().toString();
			if(!privateParameters.contains(parameterName)) {
				Object parameterValue = request.getParameter(parameterName);

				if (null != parameterValue && parameterValue != ""){ 

					httpParams.setParameter(parameterName, parameterValue);
				}else{
					formData = parameterName ;
				}
			}

		}
		Boolean isPost = request.getMethod().equalsIgnoreCase("POST");
		HttpPost httpMethod =  new HttpPost(iURL) ;
		httpMethod.setParams(httpParams);

		httpMethod.setEntity(new StringEntity(formData ));
	
        	DefaultHttpClient httpclient = new DefaultHttpClient();
		String Resp = null;
		try {
			String headerName = request.getHeader("Cookie");
			if(headerName != null && !headerName.isEmpty()){
				httpMethod.setHeader("Cookie", headerName );
		}
		
 		httpMethod.setHeader("Accept", "application/json");
		HttpResponse responseTiti = httpclient.execute(httpMethod);

		StatusLine respstatus=responseTiti.getStatusLine();
		response.setStatus(respstatus.getStatusCode());

		HttpEntity entity = responseTiti.getEntity();
        	Resp = IOUtils.toString(entity.getContent());
		if (iCallBack != null && !iCallBack.isEmpty())Resp = iCallBack +"("+Resp.toString()+")";

        	response.getWriter().write(Resp);
		} catch (Exception e) {
			 response.getWriter().write(Resp);

		} finally {
			httpclient.getConnectionManager().shutdown();
		}
	}else{
		response.setStatus(403);
		return;
	}


%>




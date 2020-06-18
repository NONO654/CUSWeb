<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
--%>
<%@page import="com.matrixone.apps.domain.util.Request"%>
<%@page import="matrix.db.JPO"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../emxTagLibInclude.inc"%>
<%
    out.clear();

    if (request.getProtocol().equals("HTTP/1.1")) {
        response.setHeader("Cache-Control", "public");
    } else { // HTTPS
        response.setHeader("Cache-Control", "private");
    }

    response.setContentType("text/xml; charset=UTF-8");
    response.setDateHeader("Expires", System.currentTimeMillis() + 5000);

    try {
        String mode = Request.getParameter(request, "mode");
        // String rowIds = Request.getParameter(request, "rowIds");

        InputStream is = request.getInputStream();
        BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"));
        String line = "";

        String requestData = reader.readLine();
        requestData = requestData.replace("rowIds=", "");
        String[] aRowIds = requestData.split("[,]");
        HashMap tempMap = new HashMap();
        tempMap.put("mode", mode);
        tempMap.put("aRowIds", aRowIds);
        tempMap.put("lang", request.getHeader("Accept-Language"));
        String message = (String) JPO.invoke(context, "emxSpecificationStructure", new String[] {},
                "reorderValidation", JPO.packArgs(tempMap), String.class);
        if (message != null) {
            throw new Exception(message);
        }
%>
<mxRoot> <action>CONTINUE</action> <message><![CDATA[]]></message>
<%
    } catch (Exception ex) {
        out.clear();
%> <mxRoot> <action>ERROR</action> <message><![CDATA[<xss:encodeForHTML><%=ex.getMessage()%></xss:encodeForHTML>]]></message>
<%
    }
%> </mxRoot>

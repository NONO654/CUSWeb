<%@ page contentType="image/jpeg"%>
<%
    /* FMATH is sending the data in base64, we just need to send the original bytes */
    String image = request.getParameter("image");

    // Size protection 
    if (image.length() > 100000)
        return;

    String save = request.getParameter("save");
    String name = request.getParameter("name");
    String type = request.getParameter("type");
    if (save != null && name != null && ("JPG".equalsIgnoreCase(type) || "PNG".equalsIgnoreCase(type))) {
%>data:image/png;base64,<%=image%>
<%
    } else {
        // NOP
    }
%>

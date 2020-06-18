<%-- (c) Dassault Systemes, 2008 --%>


<%
    StringBuilder refreshURL = new StringBuilder(100);

    refreshURL
        .append("../simulationcentral/smaStructureBrowserUtil.jsp")
        .append("?action=refresh")
        .append("&refreshFrame=smaHomeTOCContent")
        .append("&closeWindow=false");
%>

<jsp:include page = "<%=refreshURL.toString() %>" flush="true" />

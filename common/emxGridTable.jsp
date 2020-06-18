<%--  emxGridTable.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%
    //for some reason, JSP forward to emxIndentedTable will disable table customization so this JSP will always redirect.
    String forwardUrl = "./emxIndentedTable.jsp?dynamicStamp=" + new Date().getTime();
	String cellWrap = emxGetParameter(request,"cellwrap");
	cellWrap = UITableIndented.getSBWrapStatus(context, cellWrap);
    boolean bForward = false;
    ArrayList excludeList = new ArrayList(10);
    excludeList.add("emxTableRowId");
    excludeList.add("jsTreeID");
    excludeList.add("chartAlert");
    excludeList.add("calcAlert");
    excludeList.add("UseCellData");
    excludeList.add("colFields");
    excludeList.add("cellFields");
    excludeList.add("cellRels");
    excludeList.add("isIndentedView");
    excludeList.add("timeStamp");
    excludeList.add("program");
    excludeList.add("expandProgram");

    String[] urlParams = new String[]{"table","AEFDynamicGrid",
                                      "gridTable", "true",
                                      "editRootNode", "false",
                                      "selection", "multiple",
                                      "editLink", "true",
                                      "findMxLink", "false",
                                      "subHeader", "Dynamic Grid Table",
                                      "toolbar", "AEFGridFilterToolbar",
                                      "cellwrap",XSSUtil.encodeForURL(cellWrap),
                                      "postProcessJPO", "emxUITableGrid:postProcessRefresh",
                                      "objectId", XSSUtil.encodeForURL(emxGetParameter(request,"parentOID")),
                                     };

    for (int i=0; i < urlParams.length ; i=i+2)
    {
        String param = urlParams[i];
        excludeList.add(param);
        String value = urlParams[i+1];
        forwardUrl = appendUrlParam(request, forwardUrl, param, value, bForward, false);
    }

    if ("true".equalsIgnoreCase(emxGetParameter(request,"useRowSelectionsAsCols")) ||
        "true".equalsIgnoreCase(emxGetParameter(request,"useRowSelectionsAsRows")))
    {
        String[] tableIds = request.getParameterValues("emxTableRowId");
        if (tableIds != null && tableIds.length != 0)
        {
            String boIds = null;
            for(String id : tableIds)
            {
                StringList ids = FrameworkUtil.split("B"+id,"|");
                if (ids.size() > 1)
                    id = (String) ids.get(1);
                else
                    id = (String) ids.get(0);
                if (boIds == null)
                    boIds = id;
                else
                    boIds += "~" + id;
            }
            if ("true".equalsIgnoreCase(emxGetParameter(request,"useRowSelectionsAsCols")))
            {
                forwardUrl = appendUrlParam(request, forwardUrl, "colBOIds", boIds, bForward, false);
            }
            if ("true".equalsIgnoreCase(emxGetParameter(request,"useRowSelectionsAsRows")))
            {
                forwardUrl = appendUrlParam(request, forwardUrl, "rowBOIds", boIds, bForward, false);
            }
        }
    }

    if ("true".equalsIgnoreCase(emxGetParameter(request,"flatView")) ||
        "true".equalsIgnoreCase(emxGetParameter(request,"useRowSelectionsAsRows")))
    {
        forwardUrl = appendUrlParam(request, forwardUrl, "program", "local:com.matrixone.apps.framework.ui.UITableGrid:getTableRootIds", bForward, true);
        if (!"true".equalsIgnoreCase(emxGetParameter(request,"flatView")))
        {
            forwardUrl = appendUrlParam(request, forwardUrl, "expandProgram", "local:com.matrixone.apps.framework.ui.UITableGrid:getTableExpandedIds", bForward, true);
        }
    }
    else
    {
        forwardUrl = appendUrlParam(request, forwardUrl, "expandProgram", "local:com.matrixone.apps.framework.ui.UITableGrid:getTableExpandedIds", bForward, true);
    }

    if (!"true".equalsIgnoreCase(emxGetParameter(request, "flatView")))
    {
        forwardUrl = appendUrlParam(request, forwardUrl, "isIndentedView", "true", bForward, true);
    }
    else
    {
        forwardUrl = appendUrlParam(request, forwardUrl, "isIndentedView", "false", bForward, true);
    }

    Enumeration enumeration = request.getParameterNames();
    while (enumeration.hasMoreElements())
    {
        String parameterName = (String) enumeration.nextElement();
        String parameterValue = emxGetParameter(request, parameterName);
        if (excludeList.contains(parameterName))
            continue;
        forwardUrl = appendUrlParam(request, forwardUrl, parameterName, parameterValue, bForward, false);
    }

    //System.out.println("\n" + forwardUrl);
    if(bForward)
    {
%>
        <!-- //XSSOK -->
        <jsp:forward page="<%=forwardUrl%>"/>
<%
    }
    else
    {
        out.clear();
        request.getRequestDispatcher(forwardUrl).forward(request, response);
    }
%>

<%!
public String appendUrlParam(HttpServletRequest request, String url, String param, String defaultValue, boolean bForward, boolean force)
{
    if (force || emxGetParameter(request,param) == null)
    {
        if (!"".equals(defaultValue))
            url += "&" + param + "=" + XSSUtil.encodeForURL(defaultValue);
    }
    else if (!bForward)
    {
        url += "&" + param + "=" + XSSUtil.encodeForURL(emxGetParameter(request,param));
    }
    return url;
}
%>

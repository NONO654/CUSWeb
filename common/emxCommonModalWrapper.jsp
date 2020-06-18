<%--  emxModalWrapper.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxModalWrapper.jsp.rca 1.30.3.2.2.2 Fri Dec 19 01:57:49 2008 ds-kvenkanna Experimental $

--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>

<html>
    <head>
       <script type="text/javascript">
       function postForm () {
           var myForm = document.createElement("form");
           myForm.method="post" ;
           var myInput = null;
<%
    String languageStr = request.getHeader("Accept-Language");


    StringBuffer qStringBuff = new StringBuffer();
    Enumeration eNumParameters = emxGetParameterNames(request);

    String parmValue = "";
    String tableRowIds[] = null;
    while( eNumParameters.hasMoreElements() ) {
        String parmName  = (String)eNumParameters.nextElement();
       
        if(parmName != null && "emxTableRowId".equals(parmName)){
            tableRowIds = emxGetParameterValues(request,parmName);
            
            
            for(int i =0;i<tableRowIds.length;i++)  
            {%>
                myInput = document.createElement("input") ;
                myInput.setAttribute("type", "hidden") ;
                myInput.setAttribute("name", "<xss:encodeForHTMLAttribute><%=parmName%></xss:encodeForHTMLAttribute>") ;
                myInput.setAttribute("value", "<xss:encodeForHTMLAttribute><%=tableRowIds[i]%></xss:encodeForHTMLAttribute>") ;
                myForm.appendChild(myInput) ;
            <%
            }
                
        }
        else
        {
            parmValue = (String)emxGetParameter(request,parmName);
            qStringBuff.append(XSSUtil.encodeForURL(context,parmName)); 
            qStringBuff.append("="); 
            qStringBuff.append(XSSUtil.encodeForURL(context, parmValue));
        }

        if(eNumParameters.hasMoreElements()){
            qStringBuff.append("&");
        }
    }
    String strPageHeader    = (String)emxGetParameter(request,"header");
    String suiteKey         = (String)emxGetParameter(request,"suiteKey");
    String objectId         = (String)emxGetParameter(request,"objectId");
    String strTitle         = null;
    
    if(strPageHeader != null && !"".equals(strPageHeader) && suiteKey != null && !"".equals(suiteKey))
    {
        strTitle = UINavigatorUtil.parseHeader(context, pageContext, strPageHeader, objectId, suiteKey, languageStr);
    }
    if(strTitle == null || "".equals(strTitle))
    {
        strTitle= UIUtil.getWindowTitleName(context, null,objectId, null);
    }
%>
//XSSOK
myForm.action = "../common/emxIndentedTable.jsp?<%=qStringBuff.toString()%>" ;
myForm.target = 'structure_browser';
document.body.appendChild(myForm) ;
myForm.submit() ;
document.body.removeChild(myForm) ;
}
    </script>
    <Title><xss:encodeForHTML><%=strTitle%></xss:encodeForHTML></Title>
    <link rel="stylesheet" href="styles/emxUIStructureBrowser-IE.css"/>
    </head>
    <body onload="javascript:postForm()">

        <div id="bgg">
                <iframe src="../common/emxBlank.jsp" id="structure_browser" name="structure_browser" border="0" frameborder="0" ></iframe>
        </div>
    </body>
</html>


<%--  IEFCreateDesignTemplateObjectFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file = "../components/emxSearchInclude.inc"%>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	
     Context context        = integSessionData.getClonedContext(session);
     String queryString = emxGetEncodedQueryString(context,request);
    String attrModelType                        = MCADMxUtil.getActualNameForAEFData(context, "attribute_ModelType");
    String attrDesignatedUser                   = MCADMxUtil.getActualNameForAEFData(context, "attribute_DesignatedUser");
	
%>
<html>
<head>
<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="JavaScript">

function jsTrim(valString)
{
    var trmString = valString;

    // this will get rid of leading spaces
    while(trmString.substring(0, 1) == ' ')
		trmString = trmString.substring(1, trmString.length);

    // this will get rid of trailing spaces
    while(trmString.substring(trmString.length - 1, trmString.length) == ' ')
		trmString = trmString.substring(0, trmString.length - 1);

    return trmString;
}

function trimWhitespace(strString)
{
    strString = strString.replace(/^[\s\u3000]*/g, "");
    return strString.replace(/[\s\u3000]+$/g, "");
}

function cancel()
{
	window.close();
}

function submit()
{
	var framecontentFrame = findFrame(this,"contentFrame");
	var isInputValid = framecontentFrame.checkInput();
	if(isInputValid)
	{
            //XSSOK
	    setObjectValue(framecontentFrame, "<%=attrModelType%>");
	//XSSOK
        setObjectValue(framecontentFrame, "<%=attrDesignatedUser%>");
        
		framecontentFrame.document.createForm.submit();
	}
}

function setObjectValue(framecontentFrame, inputName)
{
        //XSSOK
	var Unassigned =  "<%=i18nNow.getI18nString("emxIEFDesignCenter.Common.Unassigned", "emxIEFDesignCenterStringResource", request.getHeader("Accept-Language"))%>";
    
    var defaultVal = "Unassigned";	
	var inputElement   = framecontentFrame.document.createForm.elements[inputName + "_dummy"];
    var hiddenElement  = framecontentFrame.document.createForm.elements[inputName];
    
    if(hiddenElement != null && hiddenElement != "undefined" && inputElement.value == Unassigned)
    {
             hiddenElement.value = defaultVal;
    }	
}

//Event handlers End
</script>
</head>

<frameset rows="12%,*,12%,0" frameborder="no" framespacing="2">
	<frame name="headerFrame" src="IEFCreateDesignTemplateObjectHeader.jsp" scrolling=no>
	<frame name="contentFrame"  src="IEFCreateDesignTemplateObjectContent.jsp?<%= queryString %>" marginheight="5" marginwidth="10">
	<frame name="bottomFrame" src="IEFCreateDesignTemplateObjectFooter.jsp" scrolling=no >
	<frame name="hiddenFrame" src="IEFCreateDesignTemplateObject.jsp" scrolling=no >
</frameset>
</html>

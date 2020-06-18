<%--  emxProgramCentralDynamicInsertRow.jsp
  Copyright (c) 1992-2018 Dassault Systems.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc. Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
--%>

<%@ page import = "java.util.*"%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<%@page import="matrix.util.StringList"%>
<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js" ></SCRIPT>

<%
            String fromRMB = "true";
            String strNewObjectId    = emxGetParameter(request, "newObjectId");
            String strParentOID      = emxGetParameter(request, "objectId");
            String relId = "";
            String pasteBelowToRow = "";
            String strName = emxGetParameter(request, "Name");

          //PRG:RG6:R213:Mql Injection:parameterized Mql:21-Oct-2011:start
            String sCommandStatement = "temp query bus $1 $2 $3 select $4 dump $5";
            String strURL =  MqlUtil.mqlCommand(context, sCommandStatement,DomainConstants.TYPE_URL,strName,"*","id", "|"); 
            //PRG:RG6:R213:Mql Injection:parameterized Mql:21-Oct-2011:End
    
            StringList slURLList = FrameworkUtil.split(strURL, "|");

            if(slURLList.size()<5)
            {
	            String xmlMessage = "<mxRoot>" + "<action><![CDATA[add]]></action>" + 
	            "<data status=\"committed\" fromRMB=\"" + fromRMB + "\"" + " >" +
	            "<item oid=\"" + XSSUtil.encodeForXML(context,strNewObjectId) + "\" relId=\"" + XSSUtil.encodeForXML(context,relId) + "\" pid=\"" + XSSUtil.encodeForXML(context,strParentOID) + 
	            "\" direction=\"\" pasteBelowToRow=\"" + pasteBelowToRow + "\" />" + "</data></mxRoot>";  //PRG:RG:R212:5-July-2011:direction field value modified to remove arrow
            %>
	            <script type="text/javascript" language="JavaScript">
	            var topFrame = findFrame(getTopWindow(), "PMCBookmark"); 
	            if(topFrame == null) {
	            	topFrame = findFrame(getTopWindow(), "detailsDisplay");
	            	getTopWindow().closeSlideInDialog();            	            
	            }
	            <%-- XSSOK--%>  
	            topFrame.emxEditableTable.addToSelected('<%=xmlMessage%>');
	        	topFrame.refreshStructureWithOutSort();
	            </script>
            <%
            }
            %>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

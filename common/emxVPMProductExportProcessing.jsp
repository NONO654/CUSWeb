<%--  emxVPMExportProcessing.jsp   -   Call Project Team to manage Export
   Copyright (c) 1992-2002 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
       
   
    emxVPMProductExportFS.jsp
     - emxVPMProductExportContent.jsp
       - emxVPMProductExportProcessing.jsp

    RCI - Wk13 2010 - Creation
--%>

<%@page import = "com.matrixone.vplmintegration.util.*"%>

<%@ page import = "com.dassault_systemes.VPLMJSRMExchange.VPLMJExchangeAccess"%>


<%--@include file ="./emxInfoUtils.inc"--%>
<%--<%@include file = "../emxUICommonAppInclude.inc"%>--%>

<html>
     <%@include file = "emxNavigatorInclude.inc"%>
    <%@include file = "emxNavigatorTopErrorInclude.inc"%>
    <emxUtil:localize id="i18nId" bundle="emxVPLMProductEditorStringResource" locale='<%= request.getHeader("Accept-Language") %>' />
    <head>
<script language="javascript" src="./scripts/emxUIConstants.js"></script>
<script language="javascript" src="./scripts/emxUICore.js"></script>
<script language="javascript" src="./scripts/emxUICoreMenu.js"></script>
<script language="JavaScript" src="./scripts/emxUITableUtil.js" type="text/javascript"></script>
    <script type="text/javascript">
    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIList");
    addStyleSheet("emxUIProperties");
    addStyleSheet("emxUITemp","../");
    </script>    
	
        <script language="JavaScript" type="text/javascript">
		</script>    	
    </head>   
    
    <%


    String msgString = null;
    	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);


	try {

        String plmId = (String) requestMap.get("PLM_ExternalID");
            
       try {
         VPLMJExchangeAccess accessServices = VPLMJExchangeAccess.getInstance();
	     accessServices.ExportImpl(plmId);
        }
        catch (Exception e) {
            session.putValue("error.message", e.getMessage());
        e.printStackTrace();
        	throw e;
           }
        
    }
    catch(Exception exception)
    {
        exception.printStackTrace();
        msgString = exception.getMessage();
        emxNavErrorObject.addMessage(msgString);
    }


/////////////////// gérer les messages ....

    %>
        <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
    </body>
</html>



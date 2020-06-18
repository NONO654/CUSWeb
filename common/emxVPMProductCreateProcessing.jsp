<%--  emxVPMCreateVPMActionProcessing.jsp   -   Creates VPLM Structure by taking partId as input
   Copyright (c) 1992-2002 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
       
   RCI - Dec 2009 - 1st delivery
   RCI - Jan 2010 - get Attributes to be used by the called jpo
--%>

<%@page import = "com.matrixone.vplmintegration.util.*"%>
<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMDebugUtil"%>

<%--@include file ="./emxInfoUtils.inc"--%>


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
    String url = null;
    try
    {
        //Get the context
        //Context context = Framework.getFrameContext(session);
        //Get the language
        String languageStr			= request.getHeader("Accept-Language");
        String paramRole = (String) session.getAttribute("role");
           
        //Create the arguments
       	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
//        VPLMDebugUtil.dumpObject(requestMap);

        String plmId = (String) requestMap.get("PLM_ExternalID");
        String descId = (String) requestMap.get("V_description");
        String indCodeId = (String) requestMap.get("V_IndustryCode");
        String stdNbId = (String) requestMap.get("V_StdNumber");
        String suppNameId = (String) requestMap.get("V_SupplierName");
        String supplierId = (String) requestMap.get("V_Supplier");
        String type =  (String) requestMap.get("type");
      
        ContextUtil.startTransaction(context, true);		

        Map programMap = new HashMap();
        programMap.put("PLM_ExternalID", plmId );
        programMap.put("V_description", descId );
        programMap.put("V_IndustryCode", indCodeId );
        programMap.put("V_StdNumber", stdNbId );
        programMap.put("V_SupplierName", suppNameId );
        programMap.put("V_Supplier", supplierId );
        programMap.put("type", type );
        programMap.put("role", paramRole );    


        String [] args  = JPO.packArgs(programMap);
        // Invoke the JPO - Succeed: display the created Product in an emxTree - Failed: go back to emxVPMProductCreateFS.jsp
        Hashtable createdPrd = null;
        try {
            createdPrd = (Hashtable)JPO.invoke(context, "emxVPLMProdEdit", null, "createPrd", args, Hashtable.class);
        }
        catch (Exception e) {
            session.putValue("error.message", e.getMessage());
        	if (e.getMessage().contains("NameNotUnique")) {
                url = "emxVPMProductCreateType.jsp?failed=1";    // information not sent by the modeler. Will be appropriate after migration on templates
            }
            else {
                url = "emxVPMProductCreateType.jsp?failed=2";
            }
            throw e;
           }
        if(createdPrd!=null && createdPrd.size()>0)
        {
 
        	String m1id = (String) createdPrd.get("OBJECTID");
        	url = "emxTree.jsp?objectId="+m1id;
        }
    }
    catch(Exception exception)
    {
        exception.printStackTrace();
        msgString = exception.getMessage();
        emxNavErrorObject.addMessage(msgString);
    }
    response.sendRedirect(url);
    %>
        <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
    </body>
</html>



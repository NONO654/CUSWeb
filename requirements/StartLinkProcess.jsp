<%--  StartLinkProcess.jsp

   Copyright (c) 2010-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
     
--%>

<%--
     @quickreview HAT1 ZUD 17:05:19 : HL - TSK3278161:	ENOVIA GOV TRM Deprecation of functionalities to clean up
       
--%>



<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.requirements.DeleteUtil"%>

<%@page import="java.util.Map"%>
<%@page import="java.util.Random"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<%@page import="matrix.util.MatrixException"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>

<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.apps.requirements.RequirementsConstants"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><html>

<head>
    <SCRIPT language="JavaScript">
    function handleOnClose()  
    {
         if (window.event.clientX < 0 || window.event.clientY < 0)
         {
         parent.location.href = "StartLinkProcess.jsp?mode=remove";
         }
    }
    </script>
</head>  
   
<%!
    /**
     * Checks if the given object is kind of Requirement
     */
    public boolean isRequirement(Context context, String strSourceObjectId) throws MatrixException 
    {
        if (strSourceObjectId == null)
        {
            return false;
        }
        
        DomainObject dmoObject = DomainObject.newInstance(context, strSourceObjectId);
        return dmoObject.isKindOf(context, ReqSchemaUtil.getRequirementType(context));    
    }
	
	// ++ HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy. ++
	public boolean isRequirementProxy(Context context, String strSourceObjectId)throws MatrixException, FrameworkException 
	{
        if (strSourceObjectId == null)
        {
            return false;
        }
		
        DomainObject object = DomainObject.newInstance(context, strSourceObjectId);
        StringList selectList = new StringList(1);
        selectList.addElement("type");
        Map objectInfo = object.getInfo(context, selectList);
        String objType = (String)objectInfo.get("type");
        
	    if(objType.equalsIgnoreCase("Requirement Proxy"))
	    {
	    	return true;
	    }
	    return false;
	}
    // -- HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy.-- 

%>
 <body onBeforeUnload="handleOnClose();">
</body>
<%
boolean eFlag = false;
    try
    {
        String tableRowIds = emxGetParameter(request, "emxTableRowId");
        String mode = emxGetParameter(request, "mode");
        String timeStamp = emxGetParameter(request, "timeStamp");      
        String strSourceObjectId = null;
        String sLanguage = request.getHeader("Accept-Language");
        String suiteKey = emxGetParameter(request, "suiteKey");
        String errMsg = null; 
        String strStringResourceFile = UINavigatorUtil.getStringResourceFileId(context,suiteKey);

        
        if(tableRowIds != null){
            
             if(tableRowIds != null && tableRowIds.indexOf("|") >= 0)
             {
                 strSourceObjectId = tableRowIds.split("[|]")[1];
             }
             
             if (!isRequirement(context, strSourceObjectId)) 
                {
                 // throw new Exception("Please select Requirements Only");
                 errMsg = EnoviaResourceBundle.getProperty(context, strStringResourceFile, context.getLocale(), "emxRequirements.Alert.SelectRequirementOnly"); 
                 throw new Exception(errMsg);
                 
                }
             // ++ HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy.++ 
             else if(isRequirementProxy(context, strSourceObjectId))
             {
     	    	//the object is leaf object.
     	    	 errMsg = EnoviaResourceBundle.getProperty(context, strStringResourceFile, context.getLocale(), "emxRequirements.Alert.InvalidSpecTreeSelectionReqProxy"); 
                 throw new Exception(errMsg);
             }
             // -- HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy.-- 

                else 
                {
                    DomainObject bo = DomainObject.newInstance(context, strSourceObjectId);
                    State curState = bo.getCurrentState(context);
                    String strState = curState.getName();

                 // ++ HAT1 ZUD  : TSK3278161 - R419: Deprecation of functionalities to clean up. ++
                 if(strState.equals("Obsolete"))   // (strState.equals("Release") || 
                    {
                        // throw new Exception("Source object is in Release or Obsolete state");
                     errMsg = EnoviaResourceBundle.getProperty(context, strStringResourceFile, context.getLocale(), "emxRequirements.Alert.Error10"); 
                        throw new Exception(errMsg);
                        
                    }
                 // -- HAT1 ZUD  : TSK3278161 - R419: Deprecation of functionalities to clean up. -- 
                }
        }
        out.clear();
        out.println("");
    }
    catch (Exception exp)
    {
        eFlag = true;
        out.clear();
        System.out.println(exp);
        out.print(exp.getMessage());
        return;
    }
    %>

<%
if(eFlag)
{
    out.clear();
}
%>



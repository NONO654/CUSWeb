<%-- 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%-- @quickreview T25 OEP 12:12:10 : HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet--%>
<%-- @quickreview T25 DJH 12:12:12 : Resolved compilation error. --%>
<%-- @quickreview T25 OEP 12:12:18 : HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included --%>
<%-- @quickreview JX5 QYG 13:12:18 : CSRF Fix STP: In CATIA, Delete, Delete with child & Detach commands found in context menu working is KO. --%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxTagLibInclude.inc"%>
<%@ page import="java.util.Enumeration"%>
<%@page import="javax.json.JsonObject"%>
<HTML>

<HEAD>
<script src="../common/emxUIConstantsJavaScriptInclude.jsp"
	type="text/javascript">
    </script>
<script src="../common/scripts/emxUIConstants.js" type="text/javascript">
    </script>
<script src="../common/scripts/emxUICore.js" type="text/javascript">
    </script>
<script src="../common/scripts/emxClientSideInfo.js"
	type="text/javascript">
    </script>
</HEAD>


<%
	try{

 	String sForwardPage 	= emxGetParameter(request, "targetPage");
	String sForwardDir 		= emxGetParameter(request, "targetDir");
	String sPath    		= request.getContextPath();
	String sMode			= emxGetParameter(request, "mode");
	String sOperation		= emxGetParameter(request,"operation");
	
	
	//MatrixOne ID translation...
	HashMap<String,String> idParams = new HashMap<String,String>();
	
	String objId = emxGetParameter(request, "objectId"); 
	String newObjId = "";
	String sourceId = emxGetParameter(request, "sourceId");
	String newSourceId = "";
	String rowId = emxGetParameter(request, "emxTableRowId");
	String newRowId = "";
	String relId = emxGetParameter(request, "relId");
	String newRelId = "";
	String rootObjId = emxGetParameter(request, "rootObjectId");
	String newRootObjID = "";
	
	if(objId != null && !"".equals(objId))
	{
		newObjId = MqlUtil.mqlCommand(context, "print bus $1 select $2 dump", objId, "id").trim();
		idParams.put("objectId",newObjId);
	}
	
	if(sourceId != null && !"".equals(sourceId))
	{
		newSourceId = MqlUtil.mqlCommand(context, "print bus $1 select $2 dump", sourceId, "id").trim();
		idParams.put("sourceId",newSourceId);
	}
	
	if(relId != null && !"".equals(relId))
	{
		newRelId = MqlUtil.mqlCommand(context, "print connection $1 select $2 dump", relId, "id").trim();
		idParams.put("relId",newRelId);
	}
	if(rootObjId != null && !"".equals(rootObjId))
	{
		newRootObjID = MqlUtil.mqlCommand(context, "print bus $1 select $2 dump", rootObjId, "id").trim();
		idParams.put("rootObjectId",newRootObjID);
	}
	if(rowId != null && !"".equals(rowId))
	{
		String[] ids = rowId.split("[|]",-1);
		if(ids.length == 4)
		{	//relId,objId, parentId,row number
			String tempRelId = "";
			String tempObjId = "";
			String tempObjId2 = "";

			if(ids[0] != null && !"".equals(ids[0]))
				tempRelId = MqlUtil.mqlCommand(context, "print connection $1 select $2 dump", ids[0], "id").trim();
			if(ids[1] != null && !"".equals(ids[1]))
				tempObjId = MqlUtil.mqlCommand(context, "print bus $1 select $2 dump", ids[1], "id").trim();
				if(ids[2] != null && !"".equals(ids[2]))
					tempObjId2 = MqlUtil.mqlCommand(context, "print bus $1 select $2 dump", ids[2], "id").trim();
		
					newRowId = tempRelId+"|"+tempObjId +"|"+ tempObjId2  +"|"+ ids[3];
		}
		else if (ids.length == 1)
		{	//objId
			newRowId= MqlUtil.mqlCommand(context, "print bus $1 select $2 dump", ids[0], "id").trim();
		}

		idParams.put("emxTableRowId",newRowId);
	}
	
	
	String sForwardURL = sForwardDir+"/"+sForwardPage;
	
	StringBuilder sForwardParam = new StringBuilder(150);
	
	Enumeration lParams = emxGetParameterNames(request);
	while (lParams.hasMoreElements()) 
	{
		String sParamName = (String)lParams.nextElement();

		sForwardParam.append("&");
		sForwardParam.append(sParamName);	
		sForwardParam.append("=");
		if(!idParams.containsKey(sParamName))
		{
			sForwardParam.append(emxGetParameter(request, sParamName));
		}
		else
		{
			sForwardParam.append(idParams.get(sParamName));
		}
	}
	
	if (sForwardParam!=null && sForwardParam.length()>0) 
	{
		sForwardURL += "?" + sForwardParam;
	}

    response.flushBuffer();

    String url = sPath+"/"+sForwardURL;
        
    //JX5 CSRF token generation for specific targetPage(s)
    if(sForwardPage.equalsIgnoreCase("RequirementRemove.jsp")
    		||sForwardPage.equalsIgnoreCase("DeleteChildren.jsp")
    		||sForwardPage.equalsIgnoreCase("DeleteSelected.jsp")
    		||(sForwardPage.equalsIgnoreCase("SpecificationStructureUtil.jsp")&& sMode.equalsIgnoreCase("disconnect"))
    		||(sForwardPage.equalsIgnoreCase("RMTRequirementGroupProcess.jsp")&&(sOperation.equalsIgnoreCase("delete")||sOperation.equalsIgnoreCase("detach")))
    		||sForwardPage.equalsIgnoreCase("emxParameterDeleteParameters.jsp")
    		||sForwardPage.equalsIgnoreCase("emxParameterRemove.jsp")){
    	
    	JsonObject tokenJson = ENOCsrfGuard.getCSRFTokenJson_New(context, session);
    	String tokenName = tokenJson.getString(ENOCsrfGuard.CSRF_TOKEN_NAME);
    	String tokenValue = tokenJson.getString(tokenName);
    	String appendURL = "&" + ENOCsrfGuard.CSRF_TOKEN_NAME + "="+ tokenName + "&" + tokenName + "=" + tokenValue+ "";

    	url = url + appendURL;
    }


	//response.sendRedirect(sPath+"/"+sForwardURL);
%>
<script type="text/javascript">
    this.document.location.href="<xss:encodeForJavaScript><%=url%></xss:encodeForJavaScript>";
</script>
<%
				
} catch (Exception ex) {
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());
}
%>

</HTML>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

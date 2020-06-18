<%--  emxEngrECRECOConnectAffecteditems.jsp   - The Processing page for ECR connections.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.engineering.ECO,java.util.HashMap" %>
<%@page import="com.matrixone.apps.engineering.TeamECO" %>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%
	String changeId          = emxGetParameter(request, "objectId");
	String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
	String relType          =  emxGetParameter(request, "srcDestRelName"); 
	HashMap returnMap = null;
	String errorMessage = "";
	String policyClassification = emxGetParameter(request, "policyClassification");
	//	377129
	boolean isMBOMInstalled = com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context);
	if(isMBOMInstalled)
	{
	    String languageStr    = request.getHeader("Accept-Language");
	    String implementChange= FrameworkProperties.getProperty(context, "emxMBOM.MBOM.ImplementChange");
	    if(!implementChange.equals("")&& implementChange.equalsIgnoreCase(com.matrixone.apps.engineering.EngineeringConstants.TYPE_MCO))
	    {
	        matrix.util.StringList idList=null;
	        String typeInfo="";
	        matrix.util.StringList idFinalList=new matrix.util.StringList();
	        for(int i=0;i<selectedItems.length;i++)
	        {
	            String selectedItem=selectedItems[i];
	            idList= FrameworkUtil.splitString(selectedItem,"|");
	            String selId=(String)idList.get(1);
	            DomainObject selObj=new DomainObject(selId);
	            typeInfo=(String)selObj.getType(context);
	            if(typeInfo.equalsIgnoreCase(com.matrixone.apps.engineering.EngineeringConstants.TYPE_MANUFACTURING_PART))
	            {
	            	//Multitenant
	            	//errorMessage = (i18nNow.getI18nString("emxEngineeringCentral.Part.ManufacturingPart","emxEngineeringCentralStringResource",languageStr));
	            	errorMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.ManufacturingPart"); 
	                break;
	                
	            }
	        }	        
	    }
	}
	

	//377129	
	String partsWithRevision = "";
	String[] filteredParts = null;
	String msgLatestRev = "";
	String msgSelectValidParts = "";
	boolean noFilteredPartExist = false;
	boolean partsWithRevisionExist = false;
	String strHasNoAccess = "false";	
	String sAccessAlert = "";
	
	if(errorMessage.equals(""))
	{	
		//363480	
	if(selectedItems !=null)
	{
		Map partMap = (Map)JPO.invoke(context,"emxENCFullSearch",null, "filterPartsWithNextReleasedRevision",selectedItems,Map.class);
		partsWithRevision = (String)partMap.get("partsWithRevision");
		filteredParts = (String[])partMap.get("filteredParts");
		//Multitenant
		//msgLatestRev = i18nNow.getI18nString("emxEngineeringCentral.Alert.LatestRevisionExists","emxEngineeringCentralStringResource",context.getSession().getLanguage())
		msgLatestRev = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Alert.LatestRevisionExists")
		+partsWithRevision;
	}	
	selectedItems = filteredParts;	
    if((filteredParts==null)||(filteredParts.length == 0))
    {
        noFilteredPartExist = true;  
    }  
    if(!partsWithRevision.equals(""))
    {
        partsWithRevisionExist = true;
    }
	//363480
		
	HashMap requestMap = new HashMap();
	requestMap.put("changeId",changeId);
	requestMap.put("selectedItems",selectedItems);
	requestMap.put("relType",relType);
	
	if(selectedItems.length>0 && selectedItems!= null){
		try{
			if(!"TeamCollaboration".equals(policyClassification)){
			    returnMap = new ECO().connectAffectedItems(context, requestMap);			    
			}
			else{
				returnMap = new TeamECO().connectAffectedItems(context, requestMap);
			}
			strHasNoAccess = (String)returnMap.get("strHasNoAccess");
            errorMessage = (String)returnMap.get("errorMessage");
            sAccessAlert = (String)returnMap.get("sAccessAlert");
		}
	  	catch (Exception ex)
		{
	  	  if (ex.toString() != null && (ex.toString().trim()).length() > 0)
	          emxNavErrorObject.addMessage(ex.toString().trim());
			}
		}
	}
	//377129
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript">
//363480
	//XSSOK
	var blPartsRevisionExist = "<%=partsWithRevisionExist%>";
	//XSSOK
	var blNoFilteredPartExist = "<%=noFilteredPartExist%>";
	//XSSOK
	var revisionMessege = "<%=msgLatestRev%>";

	if(blPartsRevisionExist == 'true'){
		alert(revisionMessege);
	}
	if(blNoFilteredPartExist == 'true'){
		parent.closeWindow();
	}
	//363480

  //refresh the calling structure browser and close the search window
  	var access = "<xss:encodeForJavaScript><%=strHasNoAccess%></xss:encodeForJavaScript>";
	var erroralert = "<xss:encodeForJavaScript><%=errorMessage%></xss:encodeForJavaScript>";
	if(erroralert!=""){
		alert(erroralert);
	}else{
		if(access=="false"){
			getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
			getTopWindow().closeWindow();
		}else{
			alert("<xss:encodeForJavaScript><%=sAccessAlert%></xss:encodeForJavaScript>");
		}
	}
</script>


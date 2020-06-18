 <%--  emxEngrItemMarkupPreProcess.jsp  
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<%
  String languageStr = request.getHeader("Accept-Language");
			//i18nNow i18nnow = new i18nNow();
  
//Multitenant
//String strMarkupalertmessage = i18nNow.getI18nString("emxEngineeringCentral.Markup.ChangeOwnerNotAllowedForPartsAndSpecs","emxEngineeringCentralStringResource",context.getSession().getLanguage());
String strMarkupalertmessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.ChangeOwnerNotAllowedForPartsAndSpecs"); 
String mode   = emxGetParameter(request, "mode");

  String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
  String objectId = emxGetParameter(request,"objectId");
  String selPartRelId = "";
  String selPartObjectId = "";
  String selPartParentOId = "";
  String strRelEbomIds = null;
  String selectIds = "";
  if (tableRowIdList!= null) {
    for (int i=0; i< tableRowIdList.length; i++) {
    	 //process - relId|objectId|parentId - using the tableRowId
    	String tableRowId = tableRowIdList[i];        
        
    	//Modified for ENG Convergence Start
    	if(mode != null && mode!= "" && mode.equals("ChangeOwnerFromPartContext")) {    		
	        StringTokenizer strTok = new StringTokenizer(tableRowId,"|");
	        selPartRelId = strTok.nextToken();	        
	        if (i==0) {
	            selectIds = strTok.nextToken();	            
	        } else {
	                selectIds += "," + strTok.nextToken();	                
	        }
    	} else {   	       
	       String firstIndex = tableRowIdList[i].substring(0,tableRowIdList[i].indexOf("|"));
	       StringTokenizer strTok = new StringTokenizer(tableRowId,"|");
	       selPartRelId = strTok.nextToken();
	       if(!"".equals(firstIndex)) {
	           selPartObjectId = strTok.nextToken();
	           selPartParentOId = strTok.nextToken();
	           if (i==0) {
	               selectIds = selPartObjectId;
	               }       
	               else {
	                   selectIds += selPartObjectId;
	               }
	           if (i < tableRowIdList.length -1) {
	               selectIds += ",";
	           }
	       }
    	} //Modified for ENG Convergence End
    }
  }
  session.setAttribute("selectIds",selectIds);

	String strMemberClause = "";
  boolean allowChangeOwner = true;

	DomainObject doChange = new DomainObject(objectId);
	DomainObject doObj = new DomainObject(selectIds);
	
	//Added to fix bug # 352931 start
	try{
	
		if (doObj.isKindOf(context, DomainConstants.TYPE_PART) || doObj.isKindOf(context, DomainConstants.TYPE_CAD_DRAWING) || doObj.isKindOf(context, DomainConstants.TYPE_CAD_MODEL) || doObj.isKindOf(context, DomainConstants.TYPE_DRAWINGPRINT) || doObj.isKindOf(context, PropertyUtil.getSchemaProperty(context,"type_PartSpecification")))
		{
			allowChangeOwner = false;
		}
	}
	catch(Exception e){
		allowChangeOwner = false;
		strMarkupalertmessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.NoAccessPrivileges");
		
	}
	//Added to fix bug # 352931 end
	String strCompId = null;

	if (doChange.isKindOf(context, DomainConstants.TYPE_ECR))
	{
		strCompId = doChange.getInfo(context, "to["+ PropertyUtil.getSchemaProperty(context,"relationship_ChangeResponsibility") + "].from.id");
	}
	else if (doChange.isKindOf(context, DomainConstants.TYPE_ECO))
	{
		strCompId = doChange.getInfo(context, "to["+DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.id");
	}

	if (strCompId == null || strCompId.length() == 0)
	{
		//Modified for IR-445270
	    	String strDefProject = doObj.getProjectOwner(context).toString();	
		String strDefRDOName = doObj.getOrganizationOwner(context).toString();
		strCompId  = "*"+"."+strDefRDOName.trim()+"."+strDefProject;
		//strCompId = Company.getHostCompany(context);
//		Modified for 373823
		//DomainObject doComp = new DomainObject(strCompId);
		//strCompId = doComp.getInfo(context, DomainConstants.SELECT_NAME);
	}

	if (strCompId != null && strCompId.length() > 0)
	{
		strMemberClause = ":ASSIGNED_SECURITY_CONTEXT=" + strCompId;
		//strMemberClause = ":MEMBER_ID=" + strCompId;
	}
	String contentURL ="../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active" + strMemberClause + "&HelpMarker=emxhelpfullsearch&table=APPMemberListPeopleSearchList&selection=single&objectId="+selPartParentOId+"&submitURL=../engineeringcentral/emxEngrItemMarkupChangeOwner.jsp";
%>
<script>
//Added to fix bug # 352931 start
//XSSOK
var allowChangeOwner = "<%=allowChangeOwner%>"; 
//XSSOK
var strMarkupalertmessage = "<%=strMarkupalertmessage%>"; 
if (allowChangeOwner == "false")
	{	
		alert(strMarkupalertmessage);		
	}
//Added to fix bug # 352931 end
		else if ("ChangeOwnerFromPartContext" == "<%=XSSUtil.encodeForJavaScript(context,mode)%>") {
			//document.location.href='<%=XSSUtil.encodeForJavaScript(context,contentURL)%>';		
			var contentFrame   = findFrame(getTopWindow(),"ENCECBOMMarkups");
			
			if (contentFrame == null || contentFrame == undefined || contentFrame == "") {
				contentFrame   = findFrame(getTopWindow(), "ENCECBOMMarkupsForCA");
			}
			
			contentFrame.showModalDialog("<%=XSSUtil.encodeForJavaScript(context,contentURL)%>", 575, 575);
	} else {
			var contentFrame   = findFrame(getTopWindow(),"listHidden");
			//XSSOK
			contentFrame.parent.showModalDialog("<%=XSSUtil.encodeForJavaScript(context,contentURL)%>", 575, 575);
		}
</script>

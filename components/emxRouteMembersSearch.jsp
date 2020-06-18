<%--  emxRouteMembersSearch.jsp   -  
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
	
   To Redirect to People/Role/Group/Member List search page based on parameters
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxComponentsUtil.inc" %>
<%@ page import="matrix.db.Context,com.matrixone.apps.common.util.ComponentsUIUtil,com.matrixone.apps.framework.ui.UIUtil,com.matrixone.apps.domain.DomainObject,com.matrixone.apps.common.Route,java.util.*,com.matrixone.apps.domain.util.FrameworkException,com.matrixone.apps.domain.util.ENOCsrfGuard" %>
<%!

	private static final String SUBMIT_URL = "../components/emxRouteAddPeopleProcess.jsp";
	private static final String DEFAULT_MEMBERLIST_SEARCH = "../common/emxFullSearch.jsp?showInitialResults=true&field=TYPES=type_MemberList:CURRENT=policy_MemberList.state_Active&table=AEFGeneralSearchResults&selection=multiple&hideHeader=true&mode=Chooser&chooserType=TypeChooser&HelpMarker=emxhelpsearch";
	
	private static final String DEFAULT_USERGROUP_SEARCH = "../common/emxFullSearch.jsp?showInitialResults=true&table=AEFUserGroupsChooser&selection=multiple&form=AEFSearchUserGroupsForm&cmdName=addUserGroups&field=TYPES=type_Group:CURRENT=policy_Person.state_Active&HelpMarker=emxhelpsearch";
	private static final String DEFAULT_USERGROUP_SEARCH_CLOUD = "../common/emxFullSearch.jsp?showInitialResults=true&table=AEFUserGroupsChooser&selection=multiple&form=AEFSearchUserGroupsForm&cmdName=addUserGroups&field=TYPES=type_Group:CURRENT=policy_Person.state_Active&HelpMarker=emxhelpsearch&source=usersgroup&rdfQuery=type:foaf:Group";
	private boolean isALlScope(String scopeId) {
	    return scopeId.equalsIgnoreCase("All");
	}
	
	private boolean isOrganizationScope(String scopeId) {
	    return scopeId.equalsIgnoreCase("Organization");
	}
	
	private void INDENTED_TABLE(StringBuffer buffer) {

	    buffer.append("../common/emxIndentedTable.jsp?");
	    buffer.append("selection=multiple").append('&');
	    buffer.append("expandLevelFilterMenu=false").append('&');
	    buffer.append("customize=false").append('&');
	    buffer.append("Export=false").append('&');
	    buffer.append("multiColumnSort=false").append('&');
	    buffer.append("PrinterFriendly=false").append('&');
	    buffer.append("showPageURLIcon=false").append('&');
	    buffer.append("showRMB=false").append('&');
	    buffer.append("showClipboard=false").append('&');
	    buffer.append("objectCompare=false").append('&');
	    buffer.append("submitLabel=emxFramework.Common.Done").append('&');
	    buffer.append("cancelLabel=emxFramework.Common.Cancel").append('&');
	    buffer.append("cancelButton=true").append('&');
	    buffer.append("displayView=details").append('&');
	    buffer.append("HelpMarker=emxhelpselectgroup").append('&');
	    buffer.append("submitURL=").append(SUBMIT_URL);
	    
	}
	
	private String getMemberSearchURL(Context context, Map paramMap, String objectId, String scopeId, String owningOrganization, String memberType, String fromPage, String action, String routeOrganization) throws FrameworkException {
	    StringBuffer buffer = new StringBuffer(300);
	    if("Person".equalsIgnoreCase(memberType)) {
	        buffer.append(getPersonSearchURL(context, scopeId, owningOrganization,routeOrganization));
	    } else if("Role".equalsIgnoreCase(memberType)) {
	        buffer.append(getRoleSearchURL(scopeId));
	    } else if("Group".equalsIgnoreCase(memberType)) {
	        buffer.append(getGroupSearchURL(scopeId));
	    } else if("MemberList".equalsIgnoreCase(memberType)) {
	        buffer.append(getMemberListSearchURL(scopeId));
	    } else if("editAccess".equalsIgnoreCase(memberType)) {
	        buffer.append(getEditAccessURL(scopeId));
	    }else if("UserGroup".equalsIgnoreCase(memberType)){
	    	buffer.append(getUserGroupSearchURL(context,scopeId));
	    } else {
	        throw new FrameworkException("Invalid memberType:" + memberType);
	    }
	    
	    paramMap.remove("submitURL");
	    paramMap.remove("SubmitURL");
	    paramMap.remove("action");
	    paramMap.remove("HelpMarker");
	    paramMap.remove("helpMarker");
	    paramMap.remove("categoryTreeName");
	    paramMap.remove("toolbar");
	    paramMap.remove("editLink");
	    paramMap.remove("PrinterFriendly");

	    String tokenName = (String)paramMap.get(ENOCsrfGuard.CSRF_TOKEN_NAME);
	    if(UIUtil.isNotNullAndNotEmpty(tokenName)){
	    	paramMap.remove(ENOCsrfGuard.CSRF_TOKEN_NAME);
	    	paramMap.remove(tokenName);
	    }
	    
        for (Iterator iterator = paramMap.keySet().iterator(); iterator.hasNext();) {
            String paramName = (String) iterator.next();
            if(buffer.charAt(buffer.length()-1)=='?'){
            	buffer.append(paramName).append('=').append(paramMap.get(paramName));	
            }else{
            buffer.append('&').append(paramName).append('=').append(paramMap.get(paramName));
        }
	    
		if(!buffer.toString().contains("&scopeId=") && UIUtil.isNotNullAndNotEmpty(scopeId)){
	    	buffer.append('&').append("scopeId").append('=').append(scopeId);
		}
		if(!buffer.toString().contains("&OwningOrganization=") && UIUtil.isNotNullAndNotEmpty(owningOrganization)){
		    buffer.append('&').append("OwningOrganization").append('=').append(owningOrganization);
		}
	    
        }	    
	    return buffer.toString();
	}

	private String getPersonSearchURL(Context context, String scopeId, String owningOrganization, String routeOrganization) throws FrameworkException {
	    StringBuffer buffer = new StringBuffer();
	  	if(isALlScope(scopeId)) {
		    Map map = new HashMap(2);
		    map.put("submitURL", SUBMIT_URL);
			map.put("showInitialResults", "true");
    	    buffer.append(ComponentsUIUtil.getPersonSearchFTSURL(map));
    	} else if(isOrganizationScope(scopeId)) {
    	    try {
    	    	if(UIUtil.isNullOrEmpty(routeOrganization)){
    	    		DomainObject scopeObj = new DomainObject(com.matrixone.apps.domain.util.PersonUtil.getUserCompanyId(context));
    	    		routeOrganization = scopeObj.getInfo(context, DomainObject.SELECT_NAME);
    	    	}
	    	   	String memberField = (owningOrganization.equalsIgnoreCase(routeOrganization) || (UIUtil.isNullOrEmpty(owningOrganization)))?(routeOrganization):(owningOrganization);
	    	    Map map = new HashMap(3);
			    map.put("submitURL", SUBMIT_URL);
				map.put("showInitialResults", "true");
		    	map.put("field", "TYPES=type_Person:CURRENT=policy_Person.state_Active:MEMBER=" + memberField);
	    	    buffer.append(ComponentsUIUtil.getPersonSearchFTSURL(map));
    	    } catch (Exception e) {
    	        throw new FrameworkException(e);
    	    }
    	} else {
			Map map = new HashMap(3);
			map.put("submitURL", SUBMIT_URL);		
			map.put("includeOIDprogram", "emxRoute:getPersonsIdListInWorkspace");
			map.put("table", "APPPersonSearchResults");
			buffer.append(ComponentsUIUtil.getPersonSearchFTSURL(map));
    	}
    	buffer.append("&header=emxComponents.Common.SelectPerson");
    	return buffer.toString();
	}
	
	private String getRoleSearchURL(String scopeId) {
	    StringBuffer buffer = new StringBuffer();
	    INDENTED_TABLE(buffer);   
	    buffer.append('&').
	    append("table=APPRoleSummary").append('&').
	    append("header=emxComponents.AddRoles.SelectRoles").append('&');
    	if(isALlScope(scopeId) || isOrganizationScope(scopeId)) {
    	    buffer.append("program=emxRoleUtil:getRolesSearchResults").append('&');
    	    buffer.append("toolbar=APPRoleSearchToolbar").append('&');
    	}  else {
    	    buffer.append("program=emxRoute:getRolesInWorkspace").append('&');
    	    buffer.append("scopeId=").append(scopeId).append('&');
    	}
    	return buffer.toString();
	}

		private String getUserGroupSearchURL(Context context, String scopeId) {
		
			StringBuffer buffer = new StringBuffer();	
			if(isALlScope(scopeId) || isOrganizationScope(scopeId)) {
			   try{ 		
				if(UINavigatorUtil.isCloud(context)){
				   buffer.append(DEFAULT_USERGROUP_SEARCH_CLOUD);
			       }else{
				   buffer.append(DEFAULT_USERGROUP_SEARCH);
			       }
			   }catch(Exception e){
				//System.out.println(e);
			   }
			}else{
				try{
				  if(UINavigatorUtil.isCloud(context)){
					buffer.append(DEFAULT_USERGROUP_SEARCH_CLOUD).append("&includeOIDprogram=emxRoute:getAllUserGroupsInScope");
				  }else{
					buffer.append(DEFAULT_USERGROUP_SEARCH).append("&includeOIDprogram=emxRoute:getAllUserGroupsInScope");
				  }
				}catch(Exception e){
					System.out.println(e);
				}
			}
			buffer.append("&submitURL=").append(SUBMIT_URL);
			return buffer.toString();
	 
     }

	private String getGroupSearchURL(String scopeId) {
	    StringBuffer buffer = new StringBuffer();
	    INDENTED_TABLE(buffer);
	    buffer.append('&').
	    append("table=APPGroupSummary").append('&').
	    append("header=emxComponents.AddGroups.SelectGroups").append('&');
    	if(isALlScope(scopeId) || isOrganizationScope(scopeId)) {
    	    buffer.append("program=emxGroupUtil:getGroupSearchResults").append('&');
    	    buffer.append("toolbar=APPGroupSearchToolbar").append('&');
    	}  else {
    	    buffer.append("program=emxRoute:getGroupsInWorkspace").append('&');
    	}
    	return buffer.toString();
	}

	private String getMemberListSearchURL(String scopeId) {
	    StringBuffer buffer = new StringBuffer(300);
    	if(isALlScope(scopeId) || isOrganizationScope(scopeId)) {
    		buffer.append(DEFAULT_MEMBERLIST_SEARCH).append("&includeOIDprogram=emxMemberList:getAllMemberLists").append('&').
    	    append("&submitURL=").append(SUBMIT_URL);
    	}  else {
    	    	    INDENTED_TABLE(buffer);
    	    buffer.append("&program=emxRoute:getMemberLists").append('&').
    	    append("table=APPMemberList");
    	}
    	buffer.append("&header=emxComponents.Common.MemberLists");
    	return buffer.toString();
	}
	private String getEditAccessURL(String scopeId) {
	    StringBuffer buffer = new StringBuffer();	    
	    buffer.append("emxRouteTemplateEditAccessFS.jsp?");
    	return buffer.toString();
	}
	
%>

<%
	
	String objectId  	= emxGetParameter(request,"objectId");
	String scopeId   	= emxGetParameter(request,"scopeId");
	String rtState = "";
	String owningOrganization = emxGetParameter(request,"OwningOrganization");
	
	String fromPage = emxGetParameter(request, "fromPage");
	String action = emxGetParameter(request, "action");
	String memberType = emxGetParameter(request, "memberType");
	String type ="";
	String revisionAlertMsg = "";
	String routeOrganization = "";
	objectId = UIUtil.isNullOrEmpty(objectId) ? "": objectId;
	scopeId = UIUtil.isNullOrEmpty(scopeId) ? "": scopeId;
	
	DomainObject domObj = DomainObject.newInstance(context);	
	if(!objectId.equals("")) {
	    domObj.setId(objectId);
        StringList selectList = new StringList();
	    selectList.add(DomainConstants.SELECT_TYPE);
	    selectList.add(DomainConstants.SELECT_ORGANIZATION);
	    selectList.add(DomainConstants.SELECT_CURRENT);
	    selectList.add(Route.SELECT_RESTRICT_MEMBERS);
	    selectList.add(RouteTemplate.SELECT_OWNING_ORGANIZATION_NAME);
	    Map objectInfo =  domObj.getInfo(context, selectList);
	   	type = (String)objectInfo.get(DomainConstants.SELECT_TYPE);
	    rtState = (String)objectInfo.get(DomainConstants.SELECT_CURRENT);
	    routeOrganization = (String)objectInfo.get(DomainConstants.SELECT_ORGANIZATION);
	    if(UIUtil.isNullOrEmpty(scopeId)){
			scopeId = (String)objectInfo.get(Route.SELECT_RESTRICT_MEMBERS);
	   	}
	    if(UIUtil.isNullOrEmpty(owningOrganization)){
	    	owningOrganization = (String)objectInfo.get(RouteTemplate.SELECT_OWNING_ORGANIZATION_NAME);
	    }
	}
	owningOrganization = UIUtil.isNullOrEmpty(owningOrganization) ? "": owningOrganization;
	Map paramMap = new HashMap();
    Enumeration eNumParameters = emxGetParameterNames(request);

    while( eNumParameters.hasMoreElements() ) {
    	String strParamName = (String)eNumParameters.nextElement();
    	paramMap.put(strParamName, emxGetParameter(request, strParamName));
    }
    String suiteKey = (String)paramMap.get("suiteKey");
    if(suiteKey == null || "".equals(suiteKey) || "".equals(suiteKey)) {
        paramMap.put("suiteKey", "Components");
    }
	paramMap.remove("program");
	String URL = getMemberSearchURL(context, paramMap, objectId, scopeId, owningOrganization, memberType, fromPage, action, routeOrganization); 
	
	if(fromPage.equals("RouteAccessSummary") && type.equals("Route Template")){
		revisionAlertMsg = i18nNow.getI18nString("emxComponents.RouteTaskSummary.EditAllMessage", "emxComponentsStringResource",request.getHeader("Accept-Language"));
	}
%>	
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script type="text/javascript">
//XSSOK
var revisionAlertMsg = "<%=revisionAlertMsg%>";
//XSSOK
if(revisionAlertMsg != "" && "<%=rtState%>" != "Inactive" && ! confirm(revisionAlertMsg)){
	window.closeWindow();
}else{
	//XSSOK
	if(<%=fromPage.equals("RouteAccessSummary")%>) {

    showModalDialog("<%=XSSUtil.encodeURLwithParsing(context, URL)%>",800,520, true);    

		} else {
			if(<%=memberType.equalsIgnoreCase("MemberList")%>){
				showModalDialog("<%=XSSUtil.encodeURLwithParsing(context, URL)%>",800,520, true);
			}else if(<%="Person".equalsIgnoreCase(memberType)%>){
				showModalDialog("<%=XSSUtil.encodeURLwithParsing(context, URL)%>",800,520, true);
			}else if(<%="UserGroup".equalsIgnoreCase(memberType)%>){
				showModalDialog("<%=XSSUtil.encodeURLwithParsing(context, URL)%>",800,520, true);
			}else{
				document.location.href = "<%=XSSUtil.encodeURLwithParsing(context, URL)%>";
			}
		}
   
}
</script>


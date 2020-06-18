<%--  
	ECMGetAffectedItemPath.jsp
	JSP to help in cross highlight feature, to find out the relationship traversal 
	Copyright (c) 1992-2018 Dassault Systemes.
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil,
				com.matrixone.apps.domain.DomainConstants,
				com.matrixone.apps.domain.DomainObject,
				com.matrixone.apps.domain.DomainRelationship"%>
<%
String fromAffectedItems = emxGetParameter(request, "fromAffectedItems");
		  
if(!"true".equalsIgnoreCase(fromAffectedItems)) {
	response.setHeader("Cache-Control", "no-cache");
    String ecoId       = emxGetParameter(request, "contextECOId");
	String selPartId       = emxGetParameter(request, "selPartId");
    String idPath = "";
    String relTraversal =  PropertyUtil.getSchemaProperty(context, "relationship_ReportedAgainstChange");
    String repAginstId = new DomainObject(ecoId).getInfo(context, "from["+relTraversal+"].to.id");
    if(UIUtil.isNullOrEmpty(repAginstId))
    	repAginstId = new DomainObject(ecoId).getInfo(context, "to["+PropertyUtil.getSchemaProperty(context, "relationship_ChangeAction")+"].from.from["+relTraversal+"].to.id");
    
    if(!repAginstId.equals(selPartId)) {
	    DomainObject domObj = new DomainObject(selPartId);
	    
	    MapList mapList = domObj.getRelatedObjects(context,
								DomainConstants.RELATIONSHIP_EBOM,
								DomainConstants.TYPE_PART,
								new StringList(DomainConstants.SELECT_ID),
								new StringList(DomainRelationship.SELECT_ID),
								true,
								false,
								(short)0,
								"",
								null,
								(short) 0,
								false,
								false,
								(short) 0,
								null, null, null, null, null);
	
	    Iterator itr = mapList.iterator();
	    Map tempMap = null;
	    
	    boolean flag = false;
	    while(itr.hasNext()) {
			tempMap = (Map)itr.next();
			if("1".equals(((String)tempMap.get("level")))) {
				idPath = "";
			}
			
			idPath = ((String)tempMap.get("id[connection]")) + "/" + idPath;
			
			if(repAginstId.equals(((String)tempMap.get("id")))) {
				idPath = repAginstId + "/" + idPath.substring(0, idPath.length()-1);
				flag = true;
				break;			
			}
	    }
	  
	    if(!flag) idPath = "NOTEXIST";
    } else {
     	idPath = XSSUtil.encodeForHTML(context, selPartId);
    }
    response.getWriter().write(idPath+"@");
} else {
	String strRel       = emxGetParameter(request, "strRel");
	String	result = MqlUtil.mqlCommand(context, "print connection $1 select $2 dump", strRel, "to.id");
	response.getWriter().write(result+"@");
}
%>

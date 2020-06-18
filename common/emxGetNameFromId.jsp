<!--
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program

  static const char RCSID[] = $Id: emxGetNameFromId.jsp.rca 1.6.3.2 Wed Oct 22 15:48:31 2008 przemek Experimental przemek $
-->
<%@ page import="com.matrixone.jdom.*,com.matrixone.jdom.output.*,com.matrixone.apps.domain.*"%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@page import="javax.json.Json"%>
<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxFormUtil.inc"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
out.clear();
response.setContentType("text/plain; charset=UTF-8");

String strOut = "";
String strActions = emxGetParameter(request, "action");
String strParentId = emxGetParameter(request, "parentId");
String strObjectId = emxGetParameter(request, "objectId");
String strRelId = emxGetParameter(request, "relId");

String timeStamp     = emxGetParameter(request, "timeStamp");
String uiType        = emxGetParameter(request, "uiType");
String columnName    = emxGetParameter(request, "columnName");

HashMap requestMap = new HashMap();
MapList columns    = new MapList();
HashMap column     = new HashMap();
if(timeStamp != null && !"undefined".equalsIgnoreCase(timeStamp))
{
    if ("table".equalsIgnoreCase(uiType))
	{
	    requestMap = tableBean.getRequestMap(timeStamp);
	    columns    = tableBean.getColumns(timeStamp);
	}
	else if("structureBrowser".equalsIgnoreCase(uiType))
	{
	    requestMap = indentedTableBean.getRequestMap(timeStamp);
	    columns    = indentedTableBean.getColumns(timeStamp);
	}
    
    for (int i = 0; i < columns.size(); i++)
    {
        HashMap columnMap = (HashMap)columns.get(i);
        String ccolumnName = tableBean.getName(columnMap);
        if(ccolumnName.equals(columnName))
        {
            column = columnMap;
            break;
        }
    }
}

String strFirstRel= "";
	try {		    
	    if("relname".equals(strActions) && strRelId != null && !"".equals(strRelId) && !"null".equals(strRelId)) {
	      	StringList  slRelNameSelect = new StringList(1);
	      	slRelNameSelect.add(DomainConstants.SELECT_NAME);
	        MapList ml = DomainRelationship.getInfo(context, new String[]{strRelId}, slRelNameSelect);	       
	        String strRelName = (String)((Map)ml.get(0)).get(DomainConstants.SELECT_NAME);
	        String strAliasRelName = FrameworkUtil.getAliasForAdmin(context, "relationship",strRelName, true);
	        strOut = strAliasRelName;
	    }
	   
	    if("objecttype".equals(strActions) && strObjectId != null && !"".equals(strObjectId) && !"null".equals(strObjectId)) {
	        StringList  slTypeNameSelect = new StringList(1);
	        slTypeNameSelect.add(DomainConstants.SELECT_TYPE);
	        MapList ml = DomainObject.getInfo(context, new String[]{strObjectId}, slTypeNameSelect);	       
	        String strTypeName = (String)((Map)ml.get(0)).get(DomainConstants.SELECT_TYPE);
	        String strAliasTypeName = FrameworkUtil.getAliasForAdmin(context, "type",strTypeName, true);
	        strOut = strAliasTypeName;
	    }	    
	    
	    if("objectname".equals(strActions) && strObjectId != null && !"".equals(strObjectId) && !"null".equals(strObjectId)) {
	        StringList  slTypeNameSelect = new StringList(1);
	        slTypeNameSelect.add(DomainConstants.SELECT_NAME);
	        MapList ml = DomainObject.getInfo(context, new String[]{strObjectId}, slTypeNameSelect);	       
	        String strObjName = (String)((Map)ml.get(0)).get(DomainConstants.SELECT_NAME);
	        strOut = strObjName;
	    }
	    if("typename".equals(strActions) && strObjectId != null && !"".equals(strObjectId) && !"null".equals(strObjectId)) {
	        StringList  slTypeNameSelect = new StringList(1);
	        slTypeNameSelect.add(DomainConstants.SELECT_TYPE);
	        MapList ml = DomainObject.getInfo(context, new String[]{strObjectId}, slTypeNameSelect);	       
	        String strTypeName = (String)((Map)ml.get(0)).get(DomainConstants.SELECT_TYPE);
	        strTypeName = FrameworkUtil.findAndReplace(strTypeName," ","_");
	        String strResKey = "emxFramework.Type."+strTypeName;
	        strOut = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,strResKey,request.getLocale());
	    }
	    
	    if("rellist".equals(strActions) && strObjectId != null && !"".equals(strObjectId) && !"null".equals(strObjectId) && strParentId != null && !"".equals(strParentId) && !"null".equals(strParentId)) {
	        StringList  slTypeNameSelect = new StringList(1);
	        slTypeNameSelect.add(DomainConstants.SELECT_TYPE);
	        MapList ml = DomainObject.getInfo(context, new String[]{strObjectId}, slTypeNameSelect);
	        MapList m2 = DomainObject.getInfo(context, new String[]{strParentId}, slTypeNameSelect);
	        String strObjTypeName = (String)((Map)ml.get(0)).get(DomainConstants.SELECT_TYPE);
	        String strParentTypeName = (String)((Map)m2.get(0)).get(DomainConstants.SELECT_TYPE);	    
	       
	        String strFromRelListResult = "";
	        String strToRelListResult = "";
	        StringList slFromRelList = new StringList();
	        StringList slToRelList = new StringList();
	        StringBuffer sbufPossibleRel = new StringBuffer("");
	        
	        strFromRelListResult = MqlUtil.mqlCommand(context,"print type $1 select $2 dump $3",strParentTypeName,"fromrel","|");
	        StringTokenizer stokenFromRel = new StringTokenizer(strFromRelListResult, "|");
	        
	        while (stokenFromRel.hasMoreTokens()) {
	            slFromRelList.addElement(stokenFromRel.nextToken().trim());	           
	        }
	        
	        strToRelListResult = MqlUtil.mqlCommand(context,"print type $1 select $2 dump $3",strObjTypeName,"torel","|");
	        StringTokenizer stokenToRel = new StringTokenizer(strToRelListResult, "|");
	        
	        while (stokenToRel.hasMoreTokens()) {
	            slToRelList.addElement(stokenToRel.nextToken().trim());	           
	        }
	        String strAliasRelNameTemp  = "";
	        for(int i = 0;i < slFromRelList.size() ;i++ ){
	            for(int j = 0;j < slToRelList.size() ;j++ ){
	                if(slFromRelList.get(i).equals(slToRelList.get(j))){
	                    strAliasRelNameTemp = FrameworkUtil.getAliasForAdmin(context, "relationship",(String)slToRelList.get(j), true);
	                    sbufPossibleRel.append(strAliasRelNameTemp+"|");
	                    break;
	                }
	            }
	        }
	        if(sbufPossibleRel.lastIndexOf("|") > 0){
	            sbufPossibleRel.setCharAt(sbufPossibleRel.lastIndexOf("|"),' ');
	        }
	        strOut = sbufPossibleRel.toString();
	        
	        //Added For Structure Compare-Sync Starts
	        if(strRelId != null && !"".equals(strRelId) && !"null".equals(strRelId)) {
		      	StringList  slRelNameSelect = new StringList(1);
		      	slRelNameSelect.add(DomainConstants.SELECT_NAME);
		        MapList mapl = DomainRelationship.getInfo(context, new String[]{strRelId}, slRelNameSelect);	       
		        String strRelName = (String)((Map)mapl.get(0)).get(DomainConstants.SELECT_NAME);
		        strRelName = "relationship_"+strRelName;
		        if(strOut.contains(strRelName)){
		            strOut = strRelName;
		        }else{
		          StringList strList =  FrameworkUtil.split(strOut,"|");
	              strOut =  (String)strList.get(0);
		        }
	        }
	        //Added For Structure Compare-Sync  Ends
	    }
	    //System.out.println("strOut>>"+strOut);
	    if("getRangeProgramFromTCL".equals(strActions)){

	        com.matrixone.apps.framework.ui.UIForm form = new UIForm();
	        Map rangevalues = form.getRangeValues(context,requestMap, strObjectId, "", column, request.getHeader("Accept-Language"));
	        // Map rangevalues = form.fillRangeValues(context,requestMap, strObjectId, "", column, request.getHeader("Accept-Language"));
	        JsonObjectBuilder json = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder());
	        java.util.Iterator itr = rangevalues.keySet().iterator();
	        while(itr.hasNext())
	        {
	            String key = (String)itr.next();
	            json.add(key,String.valueOf(rangevalues.get(key)));
	        }
	        strOut = json.build().toString();
	    }
	} catch (Exception ex) {
	    System.out.println("emxGetNameFromId : " + ex.toString());
	    if(ex.toString()!=null && ex.toString().length()>0)
	        emxNavErrorObject.addMessage(ex.toString());
	}
%><%=strOut%>

<% response.setContentType("text/xml; charset=UTF-8"); %><?xml version="1.0" encoding="UTF-8"?>
<%--  emxFreezePaneProcessHookIn.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFreezePaneProcessHookIn.jsp.rca 1.1.1.1.5.4 Wed Oct 22 15:48:34 2008 przemek Experimental przemek $
   
--%>

<%@ page import="com.matrixone.jdom.*,
    com.matrixone.jdom.Document,
    com.matrixone.jdom.input.*,
    com.matrixone.jdom.output.*" %>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%
    String timeStamp = emxGetParameter(request, "timeStamp");
    String levelId = emxGetParameter(request, "levelId");
    String hookInURL = emxGetParameter(request, "hookInURL");
    String hookInJPO = emxGetParameter(request, "hookInJPO");
    String mode = emxGetParameter(request, "mode");
    String action = "";
    String alertMessage = "";

    HashMap requestMap = indentedTableBean.getRequestMap(timeStamp);
    String sToolbarData = (String)emxGetParameter(request, "toolbarData");
    if (sToolbarData != null) {
        StringList toolbarList = FrameworkUtil.split(sToolbarData, "|");
        for (int itr = 0; itr < toolbarList.size(); itr++) {
            String urlParameter = (String)toolbarList.get(itr);
            if (urlParameter != null && !"".equals(urlParameter)) {
                StringList urlParameterList = FrameworkUtil.split(urlParameter, "=");
                requestMap.put(urlParameterList.get(0), urlParameterList.get(1));
            }
        }
    }
    //Bug - 367368
    if ("pre".equalsIgnoreCase(mode)){
        requestMap.put("freezePaneMode","edit");
    }else{
        requestMap.put("freezePaneMode","view");
    }

    String rootId = (String) requestMap.get("objectId");

    String suiteKey = (String) requestMap.get("suiteKey");
    String registeredSuite = suiteKey;

    if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
        registeredSuite = suiteKey.substring(13);

    String stringResFileId = UINavigatorUtil.getStringResourceFileId(context, registeredSuite);
    if(stringResFileId == null || stringResFileId.length()==0)
        stringResFileId="emxFrameworkStringResource";

    String strLanguage = request.getHeader("Accept-Language");

    try
    {
        if (hookInURL != null && !"".equals (hookInURL))
        {
            request.setAttribute("context", context);
            hookInURL = UIUtil.addSecureTokeninURL(context, session, hookInURL);
        %>
            <!-- XSSOK : used in JSP include -->
            <jsp:include page = "<%=hookInURL%>" flush="true" />
        <%
        }

        if(hookInJPO != null && !"".equals(hookInJPO) && hookInJPO.indexOf(":") > 0)
        {

            HashMap tableData = indentedTableBean.getTableData(timeStamp);
            HashMap newTableData = new HashMap(tableData);
            TreeMap indexedObjList = (TreeMap)tableData.get("IndexedObjectList");
            MapList objectList = null;
            String oid = null;
            String relid = null;
            String parentid = null;

            if(levelId == null || levelId.length() == 0)
            {
                objectList = new MapList(indexedObjList.values());
                newTableData.put("ObjectList", objectList);
                oid = parentid = rootId;
                relid = "";
            }
            else
            {
                Map objectInfo = (Map)indexedObjList.get(levelId);
                oid = (String)objectInfo.get("id");
                relid = (String)objectInfo.get("id[connection]");
                int index = levelId.lastIndexOf(',');
                if (index < 0) {
                    parentid = rootId;
                } else {
                    String parentLevelId = levelId.substring(0, index);
                    Map parentObjectInfo = (Map)indexedObjList.get(parentLevelId);
                    
                    //Modified for Bug : 350533
                    if(parentObjectInfo != null)
                    	parentid = (String)parentObjectInfo.get("id");
                    else
                        parentid = rootId;
                }
                newTableData.put("ObjectList", objectInfo.get("children"));
            }

            HashMap programMap = new HashMap();
            HashMap paramMap = new HashMap();

            paramMap.put("objectId", oid);
            paramMap.put("parentOID", parentid);
            paramMap.put("relId", relid);
            paramMap.put("timeStamp", timeStamp);
            programMap.put("requestMap", requestMap);
            programMap.put("paramMap", paramMap);
            programMap.put("tableData", newTableData);

            String[] methodargs = JPO.packArgs(programMap);
            String strJPOName = hookInJPO.substring(0, hookInJPO.indexOf(":"));
            String strMethodName = hookInJPO.substring (hookInJPO.indexOf(":") + 1, hookInJPO.length());
            if (mode.equalsIgnoreCase("pre")){
				FrameworkUtil.validateMethodBeforeInvoke(context, strJPOName, strMethodName,"preProcess");
        	}else{
        		FrameworkUtil.validateMethodBeforeInvoke(context, strJPOName, strMethodName,"cancelProcess");
        	}	
            Map retMap =(HashMap)JPO.invoke(context, strJPOName, null, strMethodName, methodargs, HashMap.class);

            if(retMap != null && retMap.size()>0)
            {
            	action = (String) retMap.get("Action");
                if (mode.equalsIgnoreCase("pre"))
                {
                    MapList retObjectList = (MapList)retMap.get("ObjectList");
                    if(retObjectList != null){
                    Iterator listIterator = retObjectList.iterator();
                    while(listIterator.hasNext())
                    {
                        Map retObjectInfo = (Map) listIterator.next();
                        String lId = (String) retObjectInfo.get("id[level]");
                        Map objectInfo = (Map)indexedObjList.get(lId);
                        objectInfo.putAll(retObjectInfo);
                    }
                        if("continue".equalsIgnoreCase(action)){
                        	action = "refresh";
                        }
                    }
                }
                
                String msg = (String) retMap.get("Message");
                if(msg != null && !"".equals(msg))
                {
                    alertMessage = EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(request.getHeader("Accept-Language")), msg);                    
                    if ((alertMessage == null) || ("".equals(alertMessage)))
                    {
                        alertMessage = msg;
                    }
                }
            }
        }
    } catch (Exception ex)
    {
        action = "error";
        if (ex.toString() != null && (ex.toString().trim()).length() > 0){
            alertMessage = ex.toString().trim();
        }
    }    

    alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\\n","\n");
    alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\\r","\r");
    alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\\t","\t");
%>
<mxRoot>
<!-- //XSSOK -->
<action><![CDATA[<%= action %>]]></action>
<!-- //XSSOK -->
<message><![CDATA[<%= alertMessage %>]]></message>
</mxRoot>


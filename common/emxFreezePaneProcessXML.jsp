<% response.setContentType("text/xml; charset=UTF-8"); %><?xml version="1.0" encoding="UTF-8"?>
<%-- emxFreezePaneProcessAction.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFreezePaneProcessXML.jsp.rca 1.9 Tue Oct 28 22:59:39 2008 przemek Experimental przemek $
--%>

<%@ page import="com.matrixone.jdom.*,
	java.util.HashMap,
    com.matrixone.jdom.Document,
    com.matrixone.jdom.input.*,
    com.matrixone.jdom.output.*" %>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>
<%
	String isStructureCompare = emxGetParameter(request, "isSync");
	if ( "TRUE".equalsIgnoreCase(isStructureCompare)){
		indentedTableBean = (com.matrixone.apps.framework.ui.UIStructureCompare)structureCompareBean;
	}
    String action = "continue";
    String alertMessage = "";
    String status="";
    String timeStamp = emxGetParameter(request,"timeStamp");
    if(timeStamp == null || "".equals(timeStamp)){
    	timeStamp = emxGetParameter(request,"fpTimeStamp");
    }
    HashMap hmReturnData=new HashMap();
    Map retMap 	= new HashMap();
    SAXBuilder builder = new SAXBuilder();
    builder.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
    builder.setFeature("http://xml.org/sax/features/external-general-entities", false);
    builder.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
    
    //  create DOM with incoming XML stream
    Document doc = builder.build(request.getInputStream());
    UITableIndented uiti = new UITableIndented();
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

    String updateInPostProcess = (String) requestMap.get("updateInPostProcess");
    String postProcessJPO = (String) requestMap.get("postProcessJPO");
    String postProcessURL = (String) requestMap.get("postProcessURL");
    String rootId = (String) requestMap.get("objectId");

    String suiteKey = (String) requestMap.get("suiteKey");
    String registeredSuite = suiteKey;

    if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") ) {
        registeredSuite = suiteKey.substring(13);
    }

    String stringResFileId = UINavigatorUtil.getStringResourceFileId(context, registeredSuite);
    if(stringResFileId == null || stringResFileId.length()==0) {
        stringResFileId="emxFrameworkStringResource";
    }

    try
    {
        ContextUtil.startTransaction(context, true);
        String timeZone = (String)session.getAttribute("timeZone");
        //Getting the return XML 
        
        //Added to by pass the connection program and improve performance
        if(!"true".equalsIgnoreCase(updateInPostProcess)){
        hmReturnData=(HashMap) indentedTableBean.updateIndentedTableObjects(context, doc, timeZone, request.getLocale(), requestMap);
        action = (String)hmReturnData.get("action");
        status = (String) hmReturnData.get("status");
        //modified for Bug - 343790
        if(!"success".equals(action)&&!"refresh".equals(action)){
            alertMessage =(String) hmReturnData.get("message");
			  //If alert message containg system error
            if(UIUtil.isNotNullAndNotEmpty(alertMessage)){
            	int pos = alertMessage.lastIndexOf("#5000001:");
                if (pos > -1){
                	alertMessage = alertMessage.substring(pos+9).trim();
                }
            }
        }	    
        }

        if(!"Error".equalsIgnoreCase(action))
        {
        if (postProcessURL!= null && !"".equals (postProcessURL))
        {
          request.setAttribute("context", context);
	//set XML Doc with updated value as request Parameter to available in JPO
          request.setAttribute("XMLDoc", doc);          
          request.setAttribute("requestMap", requestMap);
          postProcessURL = UIUtil.addSecureTokeninURL(context, session, postProcessURL);
%>
          <!-- //XSSOK -->
          <jsp:include page = "<%=postProcessURL%>" />
<%
        }

        if(postProcessJPO != null && !"".equals(postProcessJPO) && postProcessJPO.indexOf(":") > 0)
        {
            HashMap tableData = indentedTableBean.getTableData(timeStamp);
            HashMap newTableData = new HashMap(tableData);
           
            if ( "TRUE".equalsIgnoreCase(isStructureCompare)){
            	MapList leftobjectList 		= null;
            	MapList rightobjectList 	= null;
                TreeMap leftindexedObjList = (TreeMap)tableData.get("LeftIndexedObjectList");
                TreeMap rightindexedObjList = (TreeMap)tableData.get("RightIndexedObjectList");
                
                if(leftindexedObjList != null){
                	leftobjectList = new MapList(leftindexedObjList.values());
            	}else{
            		leftobjectList = new MapList();
            	}
                
                if(rightindexedObjList != null){
                	rightobjectList = new MapList(rightindexedObjList.values());
                }else{
                	rightobjectList= new MapList();
                }
                
                newTableData.put("LeftObjectList", leftobjectList);
                newTableData.put("RightObjectList", rightobjectList);

            }else {
            TreeMap indexedObjList = (TreeMap)tableData.get("IndexedObjectList");

            MapList objectList = new MapList(indexedObjList.values());
            newTableData.put("ObjectList", objectList);
            }

            HashMap programMap = new HashMap();
            HashMap paramMap = new HashMap();

            paramMap.put("objectId", rootId);
            paramMap.put("parentOID", rootId);
            paramMap.put("relId", "");
            paramMap.put("timeStamp", timeStamp);
            paramMap.put("EditAction", "apply");
            programMap.put("requestMap", requestMap);
            programMap.put("paramMap", paramMap);
            programMap.put("tableData", newTableData);
            //Fix 375887 passing xml doc to post process JPO.
            programMap.put("XMLDoc", doc); 

            String[] methodargs = JPO.packArgs(programMap);
            String strJPOName = postProcessJPO.substring(0, postProcessJPO.indexOf(":"));
            String strMethodName = postProcessJPO.substring (postProcessJPO.indexOf(":") + 1, postProcessJPO.length());
            FrameworkUtil.validateMethodBeforeInvoke(context, strJPOName, strMethodName,"postProcess");
            
            if("true".equalsIgnoreCase(updateInPostProcess)){
            	retMap =(HashMap)JPO.invoke(context, strJPOName, null, strMethodName, methodargs, HashMap.class);
            	  //support for post process jpo
               	MapList childrenItem = (MapList)retMap.get("changedRows");
   				if(childrenItem != null){
   					for(int i=0;i<childrenItem.size();i++){
   						String items="items"+i;
   						Map tempMap = (Map)childrenItem.get(i);
    						
   						MapList tempList = new MapList();
   						tempList.add(tempMap);
   						
   						hmReturnData.put(items,tempList);
   					}
   				}
                
            } else {
            	retMap =(HashMap)JPO.invoke(context, strJPOName, null, strMethodName, methodargs, HashMap.class);
            }

            if(retMap != null && retMap.size()>0)
            {
                String msg = (String) retMap.get("Message");
                action = (String) retMap.get("Action");
                if("continue".equalsIgnoreCase(action))
                    action= "success";
                if("stop".equalsIgnoreCase(action))
                    action= "error";
                if(msg != null && !"".equals(msg))
                {
                    alertMessage = i18nNow.getI18nString(msg, stringResFileId, request.getHeader("Accept-Language"));
                    if ((alertMessage == null) || ("".equals(alertMessage)))
                    {
                        alertMessage = msg;
                    }
                }
            }
        }
        }
        if(action.equalsIgnoreCase("continue") || action.equalsIgnoreCase("refresh")|| action.equalsIgnoreCase("success")|| action.equalsIgnoreCase("execScript")) {
            ContextUtil.commitTransaction(context);
        } else {
            ContextUtil.abortTransaction(context);
        }
    } catch (Exception ex)
    {
        ContextUtil.abortTransaction(context);
        action = "error";
        status = "";
        if (ex.toString() != null && (ex.toString().trim()).length() > 0){
            alertMessage = ex.toString().trim();
            if(UIUtil.isNotNullAndNotEmpty(alertMessage)){
            	int pos = alertMessage.lastIndexOf("#5000001:");
                if (pos > -1){
                	alertMessage = alertMessage.substring(pos+9).trim();
                }
            }
        }
    }

    alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\\n","\n");
    alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\\r","\r");
    alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\\t","\t");

    String strSortColumnNames = emxGetParameter(request,"strSortColumnNames");
    StringList tempStringList = FrameworkUtil.split(strSortColumnNames, ",");
    
    if (tempStringList != null && tempStringList.size() > 0)
    {
        HashMap tableData = indentedTableBean.getTableData(timeStamp);
        MapList relBusObjList = indentedTableBean.getFilteredObjectList(tableData);
        //Set is introduced to remove the duplicates
        java.util.Set hashSet = new HashSet(tempStringList);

        Iterator looper = hashSet.iterator();
        while (looper.hasNext())
        {
            String columnName = ((String)looper.next()).trim();
            if (columnName != null && !"".equals(columnName) && !"null".equals(columnName))
            {
                for (int i = 0; i < relBusObjList.size(); i++)
                {
                   ((Map)relBusObjList.get(i)).remove(columnName);
                }
            }
        }
    }
    //clear the output buffer
    out.clear();
%>
<mxRoot>
	<!-- //XSSOK -->
	<action><![CDATA[<%= action %>]]></action>	 
     	<!-- //XSSOK -->
     	<message><![CDATA[<%= alertMessage %>]]> </message>
     	  <%
     	  String isSync = emxGetParameter(request,"isSync");
     	  if("true".equals(isSync)){
     	      status = "sync";
     	  }
     	  %>
	     	<!-- //XSSOK -->
	     	<data status="<%= status %>">
	  <%	
		int k=0;
		int m=0;
		
		StringList rowIds = new StringList();
		StringList relIds = new StringList();
		
		itemsInsertion:
			while(k==0){
			      String items="items"+m;
			      MapList xmlItems=(MapList)hmReturnData.get(items);
			    
			        if(xmlItems!=null && !xmlItems.isEmpty()){
				        for(int i=0;i<xmlItems.size();i++){
					            HashMap item=(HashMap)xmlItems.get(i);
						        String oid=(String)item.get("oid");
						        String syncDir=(String)item.get("syncDir");						        
						        String pid=(String)item.get("pid");
						        String relid=(String) item.get("relid");
						        String rowId=(String) item.get("rowId");
						        String markup=(String) item.get("markup");
						         
						        if("add".equals(markup))
						        {
						            rowIds.add(rowId);
						            relIds.add(relid);
						        }
						         
							        %>
							        <item oId="<%= oid %>" rowId="<%= rowId %>" pId="<%= pid %>" relId="<%= relid %>" syncDir="<%=syncDir %>"  markup="<%= markup %>">
							     <% 
							     Map columns=(Map) item.get("columns");
							       if(columns==null){
							         //do nothing
							       }
							       else{
							            java.util.Set KeySet=columns.keySet();
							            Object[] akeySet=KeySet.toArray();
							            
							            for(int j=0;j<akeySet.length;j++){
							    	        String strColName=(String)akeySet[j];
							                String strColValue=(String) columns.get(akeySet[j]);
							                %>
								            <columns name="<%= strColName %>"><%= XSSUtil.encodeForXML(context,strColValue) %></columns>
								            <%
							             }
						            }    
							   %> </item>   <%
				         }
				     }
			        else{
			          	break itemsInsertion;
			        }
			      m++;
			   }
		if ( !"TRUE".equalsIgnoreCase(isStructureCompare)){
			  indentedTableBean.updateCacheRelationData(context,timeStamp,rowIds, relIds);
		}
			%>
		</data>	
</mxRoot>

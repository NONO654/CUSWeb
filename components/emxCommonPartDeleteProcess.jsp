<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: Disconnects Child objects from Parent
   Parameters : ObjectId-parent objectId
                ChildIds to be Disconnected

   static const char RCSID[] = "$Id: emxCommonPartDeleteProcess.jsp.rca 1.9.2.1 Mon Dec 15 11:20:50 2008 rcheluva Experimental $";
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc" %>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>
<%@ include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.common.Part"%>

<%

    String strFinalerrMsg    = "";
    Vector vecObjectIds      = new Vector();

    String parentId          = emxGetParameter(request, "objectId");
    String childIds[]        = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
    String selObjIds[] = new String[childIds.length];
    String sObjId            = "";
    String strSearchType     = "";
    StringList sObjectsList = new StringList();
    
   if(childIds!= null) {
	   try {
            	for (int i=0; i < childIds.length ;i++)
         	    {
         		   String selectedId = childIds[i];
         		   sObjectsList.add((String)selectedId);
         		}//End of for loop
         		StringList retMap = Part.getObjectRevisionsInOrder(context,sObjectsList);
         		 for (int i = 0; i < retMap.size(); i++) {
         			 selObjIds[i] = (String)retMap.get(i);
         			 vecObjectIds.addElement(selObjIds[i]);    
         	     }
				 DomainObject.deleteObjects(context, selObjIds);
            } catch(Exception e) {              
                        
                String error = e.getMessage();
               if(error.indexOf("java.lang.Exception:") != -1)
               {
               int firstIndex = error.indexOf("java.lang.Exception:");
               error = error.substring(firstIndex+20);
               int endIndex = error.indexOf("Warning:");
               if(endIndex != -1)
                   error = (error.substring(0,endIndex)).trim(); 
                endIndex = error.indexOf("Severity:");
               if(endIndex != -1)
                  error = (error.substring(0,endIndex)).trim(); 
              }
              else if(error.trim().length() == 0)
              {
                error =EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.NoDeleteAccess");
              }
              if(strFinalerrMsg != null && !strFinalerrMsg.trim().equalsIgnoreCase(""))
              {
                  if(error != null && error.indexOf("'") != -1){
                        error = error.substring(error.indexOf("'"),error.lastIndexOf("'")+1);
                  }
                   strFinalerrMsg = strFinalerrMsg+","+error;
              }else{
                strFinalerrMsg = error;
              }
                if(strFinalerrMsg != null && strFinalerrMsg.indexOf(":") != -1)
                {
                    strFinalerrMsg = strFinalerrMsg.substring(strFinalerrMsg.indexOf(":")+1);
                }
                    session.setAttribute("error.message",strFinalerrMsg);
            }
            finally
             {
                 //ContextUtil.popContext(context);
             }
    }

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
   <script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
   <script language="javascript">
       updateCountAndRefreshTree("<%=appDirectory%>", getTopWindow());
       getTopWindow().refreshTablePage();
   </script>

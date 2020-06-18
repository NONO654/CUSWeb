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


   static const char RCSID[] = "$Id: emxCommonPartRemoveProcess.jsp.rca 1.17 Wed Oct 22 16:17:52 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "emxComponentsUtil.inc" %>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
    Vector vecObjectIds = new Vector();

    String parentId = emxGetParameter(request, "objectId");
    String strSearchType = "";

    String childId = emxGetParameter(request, "childIds");
    String fromPreProcess = emxGetParameter(request, "fromPreProcess");

    String childIds[] = emxGetParameterValues(request,"emxTableRowId");
    if(fromPreProcess != null && fromPreProcess.equals("true"))
    {
      int count=0;
      if(childId!= null) {
        StringTokenizer st   = new StringTokenizer(childId,",");
        int countToken = st.countTokens();
        childIds = new String[countToken];
        while(st != null && st.hasMoreTokens())
        {
          childIds[count] = (String)st.nextToken();
          count++;
        }
      }
    }

    String sRelClassifiedItem = DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM;
    String sRelSubclass       = PropertyUtil.getSchemaProperty(context,"relationship_Subclass");

    if(childIds!= null)
    {
        strSearchType = (String)session.getAttribute("LCSearchType");

        if(strSearchType != null && strSearchType.equalsIgnoreCase("All Levels"))
        {
            int iSize = childIds.length;
            String strTemp = "";
            String strResultID = "";
            StringTokenizer strToken = null;
            String strItemID = "";
            for(int i=0;i<childIds.length;i++)
            {
                strToken = new StringTokenizer(childIds[i],"|");
                strItemID = strToken.nextToken();
                while(strToken.hasMoreTokens())
                {
                    strItemID = strToken.nextToken();
                }

                RelationshipType relType = new RelationshipType(sRelClassifiedItem);
                StringBuffer strBuffer = new StringBuffer();
                strBuffer.append("expand bus "+parentId+" from relationship '"+sRelSubclass+","+sRelClassifiedItem+"' recurse to all select bus id where \"from["+sRelClassifiedItem+"].to.id == '"+strItemID+"'\" dump ','");
                DomainObject tempChildObj = new DomainObject(strItemID);
                String strResult = MqlUtil.mqlCommand(context,strBuffer.toString());
                StringTokenizer stResult = new StringTokenizer(strResult,"\n");
                while(stResult.hasMoreTokens())
                {
                    strTemp = (String)stResult.nextToken();
                    strResultID = strTemp.substring(strTemp.lastIndexOf(",")+1);
                    try
                    {
                        DomainObject parentObj = new DomainObject(strResultID);
                        parentObj.disconnect(context,relType,true,tempChildObj);

                    }
                    catch(Exception e)
                    {
                        session.setAttribute("error.message",e.getMessage());
                    }
                }

                try
                {
                    DomainObject parentObj = new DomainObject(parentId);
                    StringList slSelAttrs     = new StringList ();
                    slSelAttrs.add (DomainConstants.SELECT_ID);
                    String strObjectWhere = DomainConstants.SELECT_ID+"== '"+strItemID+"'";
                    MapList resultList = (MapList)parentObj.getRelatedObjects(context,DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM,"*",slSelAttrs,null,true,false, (short)1,strObjectWhere,null);
                    if(resultList.size() == 0)
                    {
                        parentObj.disconnect(context,relType,true,tempChildObj);
                    }

                }
                catch(Exception e)
                {
                }
                vecObjectIds.addElement(strItemID);
            }
        }
        else
        {
            RelationshipType relType = new RelationshipType(sRelClassifiedItem);
            DomainObject parentObj = new DomainObject(parentId);

            StringTokenizer strToken = null;
            String strObjectId = "";

            for(int i=0;i<childIds.length;i++)
            {
                strToken = new StringTokenizer(childIds[i],"|");
                strObjectId = strToken.nextToken();
                while(strToken.hasMoreTokens())
                {
                    strObjectId = strToken.nextToken();
                }

                DomainObject tempChildObj = new DomainObject(strObjectId);
                try
                {
                    parentObj.disconnect(context,relType,true,tempChildObj);
                }
                catch(Exception e)
                {
                    session.setAttribute("error.message",e.getMessage());
                }
                vecObjectIds.addElement(strObjectId);
            }

        }
    }

	String removeMode = emxGetParameter(request, "removeMode");
%>
   <script language="javascript" src="../common/scripts/emxUICore.js"></script>
   <script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
      <script language="javascript">
       function updateCountAndRefreshTreeLBC(appDirectory,openerObj,parentOIDs){ 
           var objectIds = getObjectsToBeModified(openerObj,parentOIDs);
           var objectIdArray = Object.keys(objectIds);
           for (var i = objectIdArray.length-1; i >= 0; i--) {
        	  var updatedLabel = getUpdatedLabel(appDirectory,objectIdArray[i],openerObj);
        		  
        	  openerObj.changeObjectLabelInTree(objectIdArray[i], updatedLabel, true, false, false);
           }
       }
   </script>
   <script language="javascript">
       if(<%=removeMode.equalsIgnoreCase("LIB")%>){
    	   updateCountAndRefreshTreeLBC("<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>", getTopWindow()); 
       } else {
           updateCountAndRefreshTree("<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>", getTopWindow());   
       }
       getTopWindow().refreshTablePage();
   </script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

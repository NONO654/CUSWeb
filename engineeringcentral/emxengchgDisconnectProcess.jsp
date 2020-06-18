<%--  emxengchgDisconnectProcess.jsp   -  This page deletes the selected objectIds
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
  <%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%

    DomainObject rel = DomainObject.newInstance(context);
    String jsTreeID         = emxGetParameter(request,"jsTreeID");
    String objectId         = emxGetParameter(request,"objectId");
    String initSource       = emxGetParameter(request,"initSource");
    String suiteKey         = emxGetParameter(request,"suiteKey");
    String summaryPage      = emxGetParameter(request,"summaryPage");
    String[] sCheckBoxArray = emxGetParameterValues(request, "checkBox");

    if(sCheckBoxArray == null)
    {
        sCheckBoxArray = emxGetParameterValues(request, "emxTableRowId");
    }

    boolean hasException = false;
    String url    = "";
    String delId  ="";

    // Added for bug no. 310523
    StringBuffer restrictedParts = new StringBuffer();
    StringBuffer strBuffStates = new StringBuffer();
    StringList listFailedParts = new StringList();
    StringList strListStatesToCompare = new StringList();
    StringList strListStates = new StringList();
    // Addition ends 

    if(sCheckBoxArray != null)
    {
        try
        {
            //377009: do not push context before removing affected items.
			//ContextUtil.pushContext(context);
            BusinessObject FromObject        = null;
            BusinessObject ToObject          = null;
            String FromId                    = "";
            String ToId                      = "";
            matrix.db.Relationship relobject = null;
            StringTokenizer st               = null;
            String sRelId                    = null;            
            String sPartId                   = null;
            	
            StringList selectRelStmts = new StringList(1);
            selectRelStmts.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);
            
            DomainObject dObj1      = null;
            String whereclause      = null;            
            MapList totalresultList = null;
            Map sRelatedECRNameMap  = null;
            StringList raisedAgainstECRRel = new StringList();
            
            for(int i=0; i < sCheckBoxArray.length; i++)
            {
                st = new StringTokenizer(sCheckBoxArray[i], "|");
                sRelId = st.nextToken();
               
                FromObject = null;
                ToObject =null;
                FromId ="";
                ToId="";
                relobject = new matrix.db.Relationship(sRelId);
                relobject.open(context);

                FromObject = relobject.getFrom();
                ToObject = relobject.getTo();
                if(FromObject != null )
                {
                    FromId = FromObject.getObjectId();
                }
                if(ToObject != null)
                {
                    ToId = ToObject.getObjectId();
                }

                relobject.close(context);

                // Modified for bug no. 310523
                boolean allowDisconnect = true;
                String relTypeName = relobject.getTypeName();
                if (relTypeName == null || "null".equals(relTypeName) || "".equals(relTypeName))
                {
                    relTypeName = "";
                }

                if(DomainConstants.RELATIONSHIP_PART_SPECIFICATION.equalsIgnoreCase(relTypeName))
                {
                    DomainObject domObj = new DomainObject(FromId);
                    String sState = domObj.getInfo(context, DomainConstants.SELECT_CURRENT);

                    // load the property defined states first time
                    if (strListStates.size() == 0)
                    {
                        // Get the states on which the disconnect is not allowed from the property.
                        String propAllowLevel = JSPUtil.getCentralProperty(application, session, "emxEngineeringCentral" ,"Part.RestrictSpecConnectStates");
                        if (propAllowLevel == null || "null".equals(propAllowLevel) || "".equals(propAllowLevel))
                        {
                            // If Property is not set, assume states Review and beyond.
                            propAllowLevel = "state_Review,state_Approved,state_Release,state_Obsolete";
                        }

                        String sPolicy= PropertyUtil.getSchemaProperty(context, "policy_ECPart");
                        strListStates = FrameworkUtil.split(propAllowLevel, ",");

                        for (int j = 0; j < strListStates.size(); j++)
                        {
                            String stateReal = FrameworkUtil.lookupStateName(context, sPolicy, (String)strListStates.get(j));
                            if (stateReal != null && !"null".equals(stateReal) && !"".equals(stateReal))
                            {
                                strListStatesToCompare.add(stateReal);
                                // Get the display names of the states for displaying in the Alert.
                                String sDisplayState = i18nNow.getStateI18NString(sPolicy, stateReal, request.getHeader("Accept-Language"));
                                if (strBuffStates.length() > 0)
                                {
                                    strBuffStates.append(", ");
                                }
                                // Formulate the states in the alert message.
                                strBuffStates.append(sDisplayState);
                            }
                        }
                    }

                    if (strListStatesToCompare.contains(sState))
                    {
                        allowDisconnect = false;
                    }
                }

                if (allowDisconnect)
                {
					//for bug for 342758 starts
					//377009:do not push context before removing affected items.
					//ContextUtil.pushContext(context);
                    DomainRelationship.disconnect(context, sRelId);
					//377009:do not push context before removing affected items.
					//ContextUtil.popContext(context);
					//for bug for 342758 ends
                    if(objectId.equals(FromId))
                    {
                        delId=delId+ToId+";";
                    }
                    else
                    {
                        delId=delId+FromId+";";
                    }
                    //Added to fix IR-057208V6R2011x - Starts
                    //Relationship "Raised Against ECR" Needs to be removed when ECR Remove action is executed
                    dObj1 =  new DomainObject(ToId);
                    whereclause = "(id==\"" +FromId+"\")" ;//ECR Id
                    
                    totalresultList = dObj1.getRelatedObjects(context,
                                            DomainObject.RELATIONSHIP_RAISED_AGAINST_ECR, // relationship pattern
                                            DomainConstants.TYPE_ECR,    // object pattern
                                            new StringList(),            // object selects
                                            selectRelStmts,              // relationship selects
                                            true,                        // to direction
                                            false,                       // from direction
                                            (short)1,                    // recursion level
                                            whereclause,                 // object where clause
                                            null);  
                    
                   
                    if(totalresultList!=null && totalresultList.size()>0)
                    {
	                    sRelatedECRNameMap = (Map)totalresultList.get(0);
	                    sRelId = (String)sRelatedECRNameMap.get(DomainConstants.SELECT_RELATIONSHIP_ID);                     
	                    if(sRelId != null)
	                    {
	                        
	                    	raisedAgainstECRRel.add(sRelId);
	                    }
                    }
                    //Added to fix IR-057208V6R2011x - ends                    
                    
                }
                else
                {
                    listFailedParts.add(FromId);
                }
            }
            //Added to fix IR-057208V6R2011x - Starts
            for(int i =0; i<raisedAgainstECRRel.size(); i++)
            {
            	sRelId = (String)raisedAgainstECRRel.get(i);
            	DomainRelationship.disconnect(context, sRelId);            	
            }
			   //Added to fix IR-057208V6R2011x - Ends
            url = summaryPage + "?objectId=" + objectId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey;

            // Added for bug no.310523
            // If Failed parts are there, form the alert message to be shown
            int listFailedPartsSize = listFailedParts.size();
            if (listFailedPartsSize > 0)
            {
                String[] arrFailedParts = new String[listFailedPartsSize];
                for (int i = 0; i < listFailedPartsSize; i++)
                {
                    arrFailedParts[i] = (String)listFailedParts.get(i);
                }
                StringList objectSelects = new StringList();
                objectSelects.add(DomainConstants.SELECT_TYPE);
                objectSelects.add(DomainConstants.SELECT_NAME);
                objectSelects.add(DomainConstants.SELECT_REVISION);

                Part part = (Part)DomainObject.newInstance(context, DomainConstants.TYPE_PART, DomainConstants.ENGINEERING);
                MapList failedPartMapList = part.getInfo(context, arrFailedParts, objectSelects);
                int failedPartMapListSize = failedPartMapList.size();
                Map temp = null;

                for (int j = 0; j < failedPartMapListSize; j++)
                {
                    temp = new HashMap();
                    temp = (HashMap)failedPartMapList.get(j);
                    if (j!=0)
                    {
                        restrictedParts.append("\\n");
                    }
                    restrictedParts.append((String)temp.get(DomainConstants.SELECT_TYPE));
                    restrictedParts.append(" ");
                    restrictedParts.append((String)temp.get(DomainConstants.SELECT_NAME));
                    restrictedParts.append(" ");
                    restrictedParts.append((String)temp.get(DomainConstants.SELECT_REVISION));
                }
            }
        }
       catch(Exception Ex)
       {
          session.setAttribute("error.message", Ex.toString());
          hasException=true;
       }
       finally
       {
           //377009:do not push context before removing affected items.
		   //ContextUtil.popContext(context);
	   }
    }
%>


<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%><script language="Javascript">

  var tree = getTopWindow().objDetailsTree;
  var isRootId = false;

  if (tree)
  {
    if (tree.root != null)
    {
      var parentId = tree.root.id;
      var parentName = tree.root.name;

<%
  StringTokenizer sIdsToken = new StringTokenizer(delId,";",false);
    while (sIdsToken.hasMoreTokens())
  {
      String RelId = sIdsToken.nextToken();

%>
	//XSSOK
      var objId = '<%=RelId%>';
      tree.getSelectedNode().removeChild(objId);

      if(parentId == objId )
      {
        isRootId = true;
      }
<%
    }
%>
    }
  }
  if(isRootId)
  {
	//XSSOK
    var url =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + parentId + "&emxSuiteDirectory=<%=appDirectory%>";
    var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
    if (contentFrame)
    {
      contentFrame.location.replace(url);
    }
        else
        {
      if(getTopWindow().refreshTablePage)
      {
        getTopWindow().refreshTablePage();
      }
      else
      {
        getTopWindow().location.href = getTopWindow().location.href;
      }

        }
  }
  else
  {
<%
    if(restrictedParts.length() > 0)
      {
%>
			  //XSSOK
              alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.CannotRemoveConnectedParts1</emxUtil:i18nScript> "+"<%=strBuffStates.toString()%>"+"\n\n<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.CannotRemoveConnectedParts2</emxUtil:i18nScript>\n"+"<%=restrictedParts.toString()%>");
<%
      }
%>
     parent.location.href =parent.location.href;
  }
</script>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

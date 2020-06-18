<%--  emxComponentsDiscussionSubscriptionProcess.jsp
   Copyright (c) 2001-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsDiscussionSubscriptionProcess.jsp.rca 1.5.6.5 Wed Oct 22 16:18:08 2008 przemek Experimental przemek $
--%>
<%@ page import="com.matrixone.apps.domain.*" %>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%@include file = "emxComponentsContentType.inc"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
    String timeStamp = Request.getParameter(request, "timeStamp");  
    HashMap tableData = indentedTableBean.getTableData(timeStamp);
    HashMap requestMap = indentedTableBean.getRequestMap(tableData);  
    String filterValue = (String)requestMap.get("selectedFilter");
	if(filterValue==null || "null".equalsIgnoreCase(filterValue) || "".equals(filterValue))
	{
		filterValue = "";
	}
    String action = emxGetParameter(request,"action");
    String emxTableRowIds[] = emxGetParameterValues(request,"emxTableRowId");
    String id = "";
    String unsubscribeMessages = "";
        try
        {
                ContextUtil.startTransaction(context, true);

                if("unsubscribe".equalsIgnoreCase(action))
                {
                        com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
                        com.matrixone.apps.common.DiscussionEvent discussion = null;
                        discussion = new com.matrixone.apps.common.DiscussionEvent();
                        String subsPersonName = "";
                        DomainObject domObj = new DomainObject();
                        MapList objList = new MapList();
                        StringList objSelects = new StringList();
                        objSelects.add(DomainObject.SELECT_ID);
                        objSelects.add("from["+PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_relationship_SubscribedPerson)+"].to.id");
                        for(int i=0;i<emxTableRowIds.length;i++)
                        {
                            // IR-029748V6R2011
                            if( emxTableRowIds[i].indexOf("|") >-1 ) {
                                id = emxTableRowIds[i].substring( emxTableRowIds[i].indexOf("|")+1 );
                            } else {
                                id = emxTableRowIds[i];
                            }
                          // IR-029748V6R2011 - end changes
                            objList = new DomainObject(id).getRelatedObjects(context,
                                                                              PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_relationship_PublishSubscribe) + "," + PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_relationship_Publish),
                                                                              "*",
                                                                               objSelects,
                                                                               null,
                                                                               true,
                                                                               true,
                                                                               (short)0,
                                                                                "",
                                                                                null,
                                                                                null,
                                                                                null,
                                                                                null);

                                boolean unSubscribed = false;
                                Iterator objListItr = objList.iterator();
                                while(objListItr.hasNext())
                                {
                                    Map objMap = (Map)objListItr.next();
                                    try
                                    {
                                        StringList subsPersonId = (StringList)objMap.get("from["+PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_relationship_SubscribedPerson)+"].to.id");
                                        if(subsPersonId!=null)
                                        {
                                            for(int j=0;j<subsPersonId.size();j++)
                                            {
                                                String personId = (String)subsPersonId.get(j);
                                                if(personId.equals(person.getId()))
                                                {

                                                    discussion.unSubscribe(context,(String)objMap.get(DomainObject.SELECT_ID));
                                                    unSubscribed = true;
                                                }
                                            }
                                        }
                                    }
                                    catch(ClassCastException cce)
                                    {
                                        String subsPersonId = (String)objMap.get("from["+PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_relationship_SubscribedPerson)+"].to.id");
                                        if(subsPersonId.equals(person.getId()))
                                        {
                                             discussion.unSubscribe(context,(String)objMap.get(DomainObject.SELECT_ID));
                                             unSubscribed = true;
                                        }
                                    }
                                }

                                if (!unSubscribed)
                                {
                                    String msgIds[] = new String[1];
                                    msgIds[0]= id;
                                    String tempMsg = getParentSubscription(context, msgIds);
                                    if (tempMsg != null && !"".equals(tempMsg))
                                    {
                                        if ("".equals(unsubscribeMessages))
                                        {
                                            unsubscribeMessages = tempMsg;
                                        }
                                        else
                                        {
                                            unsubscribeMessages = unsubscribeMessages + "\\n" + tempMsg;
                                        }
                                    }
                                }
                        }


                }
                else if("subscribe".equalsIgnoreCase(action))
                {
                    String event="New Reply";
                    for(int i=0;i<emxTableRowIds.length;i++)
                    {
                        // IR-029748V6R2011
                        String sObjId = "";
                        if( emxTableRowIds[i].indexOf("|") >-1 ) {
                            sObjId = emxTableRowIds[i].substring( emxTableRowIds[i].indexOf("|")+1 );
                        } else {
                            sObjId = emxTableRowIds[i];
                        }
                        SubscriptionUtil.createSubscription(context,sObjId,event,true);
                      // IR-029748V6R2011 - end changes
                    }
                }
                ContextUtil.commitTransaction(context);

            }
            catch(Exception ex)
            {
                    ContextUtil.abortTransaction(context);
                    if(ex.toString() != null && (ex.toString().trim()).length()>0){
                            emxNavErrorObject.addMessage(ex.toString().trim());
                    }
            }

            String strAlert = EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(), "emxComponents.Discussion.UnSubscribe"); 
%>
             <script language="JavaScript">
                    var msgs = "<%=XSSUtil.encodeForJavaScript(context, unsubscribeMessages)%>";
                    if (msgs != "")
                    {
                        alert("<%=XSSUtil.encodeForJavaScript(context, strAlert)%>" + "\n" + msgs);
                    }
             </script>



<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script language ="javascript">
//XSSOK
if("<%=filterValue%>"!='' && "<%=XSSUtil.encodeForJavaScript(context, filterValue)%>"=="emxDiscussion:getSubscribedDiscussionList")
{
	// getTopWindow().refreshTablePage();
	// parent.window.location.href = parent.window.location.href;
}
else
{ 
     parent.ids=null;
     //parent.window.location.href = parent.window.location.href;
     //getTopWindow().refreshTablePage();
}
var refreshURL = parent.window.location.href;
refreshURL = refreshURL.replace("persist=true","");
parent.window.location.href = refreshURL;
 
</script>

<%!
    public  String getParentSubscription(Context context, String[] objList) throws Exception
    {     
        String unsubscribedMsg = "";
        StringBuffer selectBuf = new StringBuffer();
        selectBuf.append("to[");
        selectBuf.append(PropertyUtil.getSchemaProperty(context,"relationship_Message"));
        selectBuf.append("].from.to[");
        selectBuf.append(PropertyUtil.getSchemaProperty(context,"relationship_Thread"));
        selectBuf.append("].from.");

        StringBuffer selectBuf1 = new StringBuffer();
        selectBuf1.append("from[");
        selectBuf1.append(PropertyUtil.getSchemaProperty(context,DomainObject.SYMBOLIC_relationship_PublishSubscribe));
        selectBuf1.append("].to.from[");
        selectBuf1.append(PropertyUtil.getSchemaProperty(context,DomainObject.SYMBOLIC_relationship_Publish));
        selectBuf1.append("].to.from[");
        selectBuf1.append(PropertyUtil.getSchemaProperty(context,DomainObject.SYMBOLIC_relationship_SubscribedPerson));
        selectBuf1.append("].to.name");

        StringBuffer subscriptionUser = new StringBuffer();
        subscriptionUser.append(selectBuf.toString());
        subscriptionUser.append(selectBuf1.toString());
        
        StringBuffer subscriptionEvent = new StringBuffer();
        subscriptionEvent.append(selectBuf.toString());
        StringBuffer selectBuf2 = new StringBuffer();
        selectBuf2.append("from[");
        selectBuf2.append(PropertyUtil.getSchemaProperty(context,DomainObject.SYMBOLIC_relationship_PublishSubscribe));
        selectBuf2.append("].to.from[");
        selectBuf2.append(PropertyUtil.getSchemaProperty(context,DomainObject.SYMBOLIC_relationship_Publish));
        selectBuf2.append("].to.attribute[");
        selectBuf2.append(PropertyUtil.getSchemaProperty(context,"attribute_EventType"));
        selectBuf2.append("]");
        
        subscriptionEvent.append(selectBuf2.toString());        
        
        String subAttr = PropertyUtil.getSchemaProperty(context,"attribute_Subject");

        DomainObject.MULTI_VALUE_LIST.add(subscriptionUser.toString());
        StringList selectList = new StringList();
        selectList.addElement(subscriptionUser.toString());
        selectList.addElement(subscriptionEvent.toString());
        selectList.addElement("attribute[" + subAttr + "]");

        try
        {
            Map messageObj = null;
            
            BusinessObjectWithSelectList bosWithSelect  = BusinessObject.getSelectBusinessObjectData(context,objList,selectList);
            for(int j=0;j<bosWithSelect.size();j++)
            {
            	BusinessObjectWithSelect bows = bosWithSelect.getElement(j);
            	
                StringList subscriberList = bows.getSelectDataList(subscriptionUser.toString());
                StringList eventList = bows.getSelectDataList(subscriptionEvent.toString());

                boolean subscriptionFound = false;
                if (subscriberList != null && subscriberList.contains(context.getUser())) {
                    for(int k=0; eventList != null && subscriberList != null && k < subscriberList.size(); k++)
                    {
                        if (eventList != null && (eventList.elementAt(k).equals("New Reply") ||
                             eventList.elementAt(k).equals("New Discussion")
                            ) &&
                            subscriberList.elementAt(k).equals(context.getUser())
                           )
                        {
                            subscriptionFound = true;
                            break;
                        }
                    }
                }

                if (subscriptionFound)
                {
                    unsubscribedMsg = bows.getSelectData("attribute[" + subAttr + "]");
                }
            }
        }
        catch(Exception ex)
        {
            ex.printStackTrace();
            throw ex;
        }
        return unsubscribedMsg;
    }
%>

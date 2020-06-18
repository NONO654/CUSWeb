<%--  emxComponentsDiscussionAccessUtil.jsp   -  Deleting the Selected Members and dosconnecting the route members.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsDiscussionAccessUtil.jsp.rca 1.7 Wed Oct 22 16:18:44 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%  
  String mode = emxGetParameter(request,"mode");    
  String objId[]         = emxGetParameterValues(request, "emxTableRowId");  
  String objectId        = emxGetParameter(request, "objectId");

  String sAttrAccessType = PropertyUtil.getSchemaProperty(context, "attribute_AccessType");
  String relMessage      = PropertyUtil.getSchemaProperty(context, "relationship_Message");
  String relThread       = PropertyUtil.getSchemaProperty(context, "relationship_Thread");
  
  String sPersonId    = "";
  StringTokenizer sPersonIdsToken =null;

  DomainObject    domainObject   =  DomainObject.newInstance(context);
  DomainObject    message        =  DomainObject.newInstance(context);
  
  StringList granteeList              = new StringList();
  
  String conObjectId = "";
  String threadId    = "";
  String relMessageId = "";

  AccessUtil accessUtil    = new AccessUtil();
  DomainObject conObject = null;  
  message.setId(objectId);  
      
  String sAccessType = message.getInfo(context,"to["+relMessage+"].attribute["+DomainObject.ATTRIBUTE_ACCESS_TYPE+"]");
  if("Specific".equals(sAccessType)){
    granteeList = message.getGrantees(context);
  } else {
  // getting the object id connected to Thread type
    conObjectId = message.getInfo(context,"to["+relMessage+"].from.to["+relThread+"].from.id");        
    conObject   = DomainObject.newInstance(context);
    conObject.setId(conObjectId);
    conObject.open(context);
    granteeList = conObject.getGrantees(context);    
    conObject.close(context);
    threadId = message.getInfo(context,"to["+relMessage+"].from.id");
  }     
  relMessageId = message.getInfo(context,"to["+relMessage+"].id");     
  if (granteeList == null){
    granteeList = new StringList();
  }
  //removing the duplicates
  boolean exist=true;
  for (int k=0;k<granteeList.size();k++){
    Object obj = granteeList.elementAt(k);
    exist=true;
    while(exist){
      if(granteeList.indexOf(obj) == granteeList.lastIndexOf(obj) ){
        exist = false;
      } else{
        granteeList.remove(obj);
      }
    }
  }     
  BusinessObjectList objList = new BusinessObjectList();
  objList.addElement((BusinessObject)message);
  
  //revoking Access for the members for Thread object
  BusinessObject.revokeAccessRights(context,objList);

  String personName = "";
  DomainObject personObj = DomainObject.newInstance(context);
  if("remove".equals(mode)) {
    DomainRelationship.setAttributeValue(context,relMessageId,sAttrAccessType,"Specific");
    for (int i = 0; i < objId.length; i++) {            
      personObj.setId(objId[i]);       
      granteeList.removeElement(personObj.getName(context));
    }     
    //granting ADD Access to the members for Thread object
    for (int j = 0;j < granteeList.size(); j++) {
     accessUtil.setAdd((String)granteeList.elementAt(j));						
    }
    if (accessUtil.getAccessList().size() > 0){
      String[] args = new String[]{objectId};
      JPO.invoke(context, "emxDiscussion", args, "grantAccess", JPO.packArgs(accessUtil.getAccessList()));
    }     
  } else {       
    DomainRelationship.setAttributeValue(context,relMessageId,sAttrAccessType,"Inherited");
  }  
%>
  <script language="javascript">
   getTopWindow().refreshTablePage();
  </script>


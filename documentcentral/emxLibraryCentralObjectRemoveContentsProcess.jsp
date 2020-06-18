<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: Disconnects Child objects from Parent
   Parameters : ObjectId-parent objectId
                ChildIds to be Disconnected

   Author     :
   Date       :
   History    :

   static const char RCSID[] = "$Id: emxLibraryCentralObjectRemoveContentsProcess.jsp.rca 1.11 Wed Oct 22 16:02:42 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>
<%
  String sPart  = PropertyUtil.getSchemaProperty(context,"type_Part");
  String sGenericDocument  = PropertyUtil.getSchemaProperty(context,"type_GenericDocument");
  String sPartFamily = LibraryCentralConstants.TYPE_PART_FAMILY;
  String sGeneralClass   = LibraryCentralConstants.TYPE_GENERAL_CLASS;
  String sRelClassifiedItem =           LibraryCentralConstants.RELATIONSHIP_CLASSIFIED_ITEM;
  String sRelSubclass =   LibraryCentralConstants.RELATIONSHIP_SUBCLASS;
  String  sClassification = LibraryCentralConstants.TYPE_CLASSIFICATION ;
  String  sLibraries = LibraryCentralConstants.TYPE_LIBRARIES ;
  StringBuffer sbRemoveErrorMsg = new StringBuffer();
  Vector vecObjectIds = new Vector();
     //----Getting parameter from request---------------------------

  String parentId = emxGetParameter(request, "objectId");
  String childId = emxGetParameter(request, "childIds");
    
    String sObjId = "";
    String strSearchType = "";
    String childIds[] = null;
    int count=0;
    if(childId!= null) {
    StringTokenizer st   = new StringTokenizer(childId,",");
    int countToken = st.countTokens();
    childIds = new String[countToken];
    while(st != null && st.hasMoreTokens())
    {
      sObjId = (String)st.nextToken();
      childIds[count] = sObjId;
      vecObjectIds.addElement(sObjId);
      count++;
    }
  }
  DomainObject domObj = new DomainObject(sObjId);
  String objType = domObj.getInfo(context,"type");
  String languageStr         = request.getHeader("Accept-Language");
  String objectsNotRemoved = "";
  BusinessType busType = new BusinessType(objType,context.getVault());
  String  strParentType = busType.getParent(context);
  Classification baseObject =(Classification)DomainObject.newInstance(context,sPartFamily,LibraryCentralConstants.LIBRARY);
        try {
  if(objType != null && !objType.equals("") &&
      (strParentType.equals(sClassification))) {  objectsNotRemoved=baseObject.removeObjects(context,childIds,sRelSubclass,parentId,null );


  } else {
      strSearchType = (String)session.getAttribute("LCSearchType");
      objectsNotRemoved=baseObject.removeObjects(context,childIds,sRelClassifiedItem,parentId,strSearchType);
  }
  
  } catch(Exception e) {
    session.setAttribute("error.message",getSystemErrorMessage (e.getMessage()));
  }
  int index = objectsNotRemoved.indexOf("|");
  String strResult = objectsNotRemoved.substring(index+1);
  objectsNotRemoved = objectsNotRemoved.substring(0,index);
  StringBuffer strObjNotRemovedName =new StringBuffer();
  StringTokenizer st   = new StringTokenizer(objectsNotRemoved,",");
  while(st.hasMoreTokens())
  {
    sObjId = st.nextToken().trim();
    DomainObject dObj = new DomainObject(sObjId);
    vecObjectIds.removeElement(sObjId);
    strObjNotRemovedName.append(dObj.getInfo(context,DomainObject.SELECT_NAME));
    strObjNotRemovedName.append(" ");

  }
 if(strObjNotRemovedName.length() > 0) {
     sbRemoveErrorMsg.append(EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(languageStr),"emxDocumentCentral.Message.ObjectsNotRemoved"));
     sbRemoveErrorMsg.append(" \n").append(strObjNotRemovedName.toString().trim());
  }

%>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language="javascript" src="emxLibraryCentralUtilities.js"></script>
<script language="javascript" type="text/javaScript">
    var vErrorMsg   = "<xss:encodeForJavaScript><%=sbRemoveErrorMsg.toString().trim()%></xss:encodeForJavaScript>";
    try {
        if(vErrorMsg != "") {
            alert(vErrorMsg);
        }
		// Changes added by PSA11 start(IR-536333-3DEXPERIENCER2018x).
        updateCountAndRefreshTreeLBC('<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>',getTopWindow());
		// Changes added by PSA11 end.        
        getTopWindow().refreshTablePage();
    }catch (ex) {
        getTopWindow().refreshTablePage();
    }
</script>

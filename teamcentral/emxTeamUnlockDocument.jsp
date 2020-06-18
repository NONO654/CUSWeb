<%--  emxTeamUnlockDocument.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamUnlockDocument.jsp.rca 1.11 Wed Oct 22 16:06:38 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%
  //get document Id
  String docId    = emxGetParameter(request, "docId");

  //get category Id
  String catId    = emxGetParameter(request, "catId");
  String pageName = emxGetParameter(request, "pageName");
  //Added for Bug #371651 starts
  String customSortColumns = emxGetParameter(request, "customSortColumns");
  String customSortDirections = emxGetParameter(request, "customSortDirections");
  String uiType = emxGetParameter(request, "uiType");
  String table = emxGetParameter(request, "table");
  String strLanguage = request.getHeader("Accept-Language");
 
  //Added for Bug #371651 ends
  if ( catId == null )
    catId = docId;

  if (docId != null)
  {
    //build business object/open/unlock/close
    DomainObject document = DomainObject.newInstance(context, docId);
    document.open(context);

    // The Master Document itself is not locked so we get the control object.
    StringBuffer sbLockIdSelect = new StringBuffer(56);
    sbLockIdSelect.append("relationship[");
    sbLockIdSelect.append(CommonDocument.RELATIONSHIP_ACTIVE_VERSION);
    sbLockIdSelect.append("].to.id");

    String lockObjId = (String)document.getInfo(context, sbLockIdSelect.toString());
    if(UIUtil.isNullOrEmpty(lockObjId)){
    	lockObjId = docId;
    }
    DomainObject lockObj = DomainObject.newInstance(context, lockObjId);
    String ObjLocker = (String)lockObj.getInfo(context, "locker");
    strLanguage = PropertyUtil.getAdminProperty(context, "user", ObjLocker, PersonUtil.PREFERENCE_ICON_MAIL_LANGUAGE);
    
    String unlockMessage = "\""+document.getTypeName()+"\" "+"\""+document.getName(context)+"\" "+"\""+document.getRevision(context)+"\" "+EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", new Locale(strLanguage), "emxComponents.DOCUMENTS.Event.Document_Unlocked");
    
    document.close(context);

    MqlUtil.mqlCommand(context, "unlock businessobject $1 comment $2;",lockObjId,unlockMessage);
    lockObj.close(context);
  }
%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="javascript">
  var frameContent;
  if(getTopWindow().getWindowOpener()) {
    frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"detailsDisplay");
  } else {
    frameContent = findFrame(getTopWindow(),"listDisplay");
    if(!frameContent){
    	frameContent = findFrame(getTopWindow(),"detailsDisplay");
    	frameContent.emxEditableTable.refreshStructureWithOutSort();
    }
    else{
    	  frameContent.refreshTableContent();
    }
  }  
  

  if(getTopWindow().getWindowOpener()) {
    getTopWindow().closeWindow();
  }
</script>


<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = $Id: emxLibraryCentralObjectsDeleteProcess.jsp.rca 1.17 Wed Oct 22 16:02:24 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript">

</script>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>

<%
    String callPage             = emxGetParameter(request, "callPage");
    String emxTableRowIds[]     =(String[]) emxGetParameterValues(request, "emxTableRowId");
    String sGenericDocument     = LibraryCentralConstants.TYPE_GENERIC_DOCUMENT;
    String sDocument            = LibraryCentralConstants.TYPE_DOCUMENT;
    String sDocumentSheet       = LibraryCentralConstants.TYPE_DOCUMENT_SHEET;
    String sFolder              = LibraryCentralConstants.TYPE_WORKSPACE_VAULT;
    String stdMsg               = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(sLanguage),"emxDocumentCentral.Deleted.NotAbleToDeleteMessage");
    String sLockMsg             = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(sLanguage),"emxDocumentCentral.Deleted.NotAbleToDeleteLockedObjectMessage");
    String sType                = null;
    Vector vecObjectIds         = new Vector();
    Vector vecLockedObjects     = new Vector();

    boolean isLocked            = false;

    StringBuffer sbErrorObjMsg  = new StringBuffer();
    StringBuffer sbLockedObjMsg = new StringBuffer();
    StringBuffer sbFinalErrMsg  = new StringBuffer();
    StringBuffer responseXML    = new StringBuffer();

    if(callPage == null) {
        callPage = "emxTable";
    }

    Map levelIdMap      = new HashMap();
    responseXML.append("<mxRoot>");
    responseXML.append("<action>remove</action>");
    // if coming from a configurable table we need to get the object id
    // out of the object id / relationship pair
    String []objIds     = getTableRowIDsArray(emxTableRowIds);
    if(objIds != null) {
        for(int i = 0; i < objIds.length; i++) {
            vecObjectIds.addElement(objIds[i]);
            StringTokenizer strTokens = new StringTokenizer(emxTableRowIds[i],"|");
            while (strTokens.hasMoreTokens()) {
                levelIdMap.put(objIds[i], strTokens.nextToken());
            }
        }
    }

    
    try {
        if (objIds.length > 0) {
            DomainObject domObj         = DomainObject.newInstance(context);
            StringBuffer sbLockedSelect = new StringBuffer();

            sbLockedSelect.append("relationship[");
            sbLockedSelect.append(com.matrixone.apps.common.CommonDocument.RELATIONSHIP_ACTIVE_VERSION);
            sbLockedSelect.append("].to.locked");

            StringList  selDocumentList = new StringList();
            selDocumentList.add(DomainObject.SELECT_TYPE);
            selDocumentList.add(DomainObject.SELECT_NAME);
            selDocumentList.add(sbLockedSelect.toString());
            selDocumentList.add(com.matrixone.apps.common.CommonDocument.SELECT_VCFILE_LOCKED);
            selDocumentList.add(DomainObject.SELECT_LOCKED);
            selDocumentList.add(DomainObject.SELECT_CURRENT);

            for (int i = 0; i < objIds.length; ++i) {
                String objectId     = objIds[i];
                domObj.setId(objectId);
                Map resultMap       = domObj.getInfo(context, selDocumentList);
                String docLocked    = (String)resultMap.get(sbLockedSelect.toString());
                String objectLocked = (String)resultMap.get(DomainObject.SELECT_LOCKED);
                String vcDocLocked  = (String)resultMap.get(com.matrixone.apps.common.CommonDocument.SELECT_VCFILE_LOCKED);
                isLocked            = (!UIUtil.isNullOrEmpty(docLocked) && docLocked.indexOf("TRUE") != -1)||
                                        (!UIUtil.isNullOrEmpty(vcDocLocked) && (vcDocLocked.equalsIgnoreCase("TRUE")))||
                                        (!UIUtil.isNullOrEmpty(objectLocked) && (objectLocked.equalsIgnoreCase("TRUE")));
                sType               = (String)resultMap.get(DomainObject.SELECT_TYPE);

                String sState       = (String)resultMap.get(DomainObject.SELECT_CURRENT);
                String sActiveState = LibraryCentralConstants.STATE_DOCUMENT_SHEET_ACTIVE;

                try {
                    if (isLocked) {
                        sbLockedObjMsg.append("\n").append(sType).append (" ").
                        append((String)resultMap.get(DomainObject.SELECT_NAME));
                        vecObjectIds.removeElement(objectId);
                    } else {
                        if(sType != null && (sType.equalsIgnoreCase(sGenericDocument) || sType.equalsIgnoreCase(sDocument))){
                            com.matrixone.apps.common.CommonDocument.deleteDocuments(context,new String[]{objectId});
                        } else if (sType.equalsIgnoreCase(sDocumentSheet) && sState.equalsIgnoreCase(sActiveState)) {
                            sbErrorObjMsg.append("\n").append(i18nNow.getAdminI18NString("Type", sType, sLanguage)).append (" ").
                            append((String)resultMap.get(DomainObject.SELECT_NAME));
                            vecObjectIds.removeElement(objectId);
                        } else {
                            String strReturn    = null;
                            if(domObj.isKindOf(context, LibraryCentralConstants.TYPE_LIBRARIES)) {
                                Libraries LcObj         =(Libraries)DomainObject.newInstance(context,objectId,LibraryCentralConstants.LIBRARY);
                                strReturn    = LcObj.deleteObjects(context);
                            } else if(domObj.isKindOf(context, LibraryCentralConstants.TYPE_CLASSIFICATION)) {
                                Classification LcObj    =(Classification)DomainObject.newInstance(context,objectId,LibraryCentralConstants.LIBRARY);
                                strReturn    = LcObj.deleteObjects(context);
                            } else if(sType != null && sType.equalsIgnoreCase(sFolder)) { 
                            	DCWorkspaceVault folderObj = (DCWorkspaceVault)DomainObject.newInstance(context,objectId,LibraryCentralConstants.DOCUMENT);
                            	strReturn    = folderObj.deleteObjects(context);
                            } else {
                                domObj.deleteObject(context);
                            }
                            if(strReturn != null && strReturn.equalsIgnoreCase("false")) {
                                sbErrorObjMsg.append("\n").append(i18nNow.getAdminI18NString("Type", sType, sLanguage)).append (" ").
                                append((String)resultMap.get(DomainObject.SELECT_NAME));
                                vecObjectIds.removeElement(objectId);
                            }
                        }
                    }
                }catch (Exception exp) {
                    sbErrorObjMsg.append("\n").append(sType).append (" ").
                    append((String)resultMap.get(DomainObject.SELECT_NAME));
                    vecObjectIds.removeElement(objectId);
                }
                
            }//End of for

            if (sbErrorObjMsg.toString().length() > 0) {
                sbFinalErrMsg.append(stdMsg).append(sbErrorObjMsg);
            }
  
            if (sbLockedObjMsg.toString().length() > 0) {
                if(sbFinalErrMsg.toString().length() > 0 ) {
                    sbFinalErrMsg.append("\n\n");
                }
                sbFinalErrMsg.append(sLockMsg).append(sbLockedObjMsg);
            }          
       } // if length() > 0 : there were some selected objects

    } catch (FrameworkException fe) {
        fe.printStackTrace();
    }
    catch(Exception e) {
        
    }
    Iterator itr =  vecObjectIds.iterator();
   // Adding the Item level details for the Deleted Objects
    while ( itr.hasNext() ){
        String objectId = (String)itr.next();
        responseXML.append("<item id='");
        responseXML.append((String)levelIdMap.get(objectId));
        responseXML.append("'/>");
    }
    responseXML.append("</mxRoot>");    
%>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language="javascript" src="emxLibraryCentralUtilities.js"></script>
<script language=javascript>
    var vErrorMsg   = "<xss:encodeForJavaScript><%=sbFinalErrMsg.toString().trim()%></xss:encodeForJavaScript>";
    var iSize       = "<xss:encodeForJavaScript><%=vecObjectIds.size()%></xss:encodeForJavaScript>";
    var vCallPage   = "<xss:encodeForJavaScript><%=callPage%></xss:encodeForJavaScript>";
    if(vErrorMsg != "") {
        alert(vErrorMsg);
    }
    var vStructureTreeObject = getTopWindow().objStructureTree;
    var vDeleteRows = <xss:encodeForJavaScript><%=vecObjectIds.size()>0%></xss:encodeForJavaScript>;
    if(vDeleteRows) { 
        if(parent.removedeletedRows) {
            var responseXML  = "<xss:encodeForJavaScript><%=responseXML.toString()%></xss:encodeForJavaScript>";
            parent.removedeletedRows(responseXML);
        }
    }
    try {
<%
       int iSize = vecObjectIds.size();
       for (int i = 0; i < iSize; ++i) {
%>
           var childId = '<xss:encodeForJavaScript><%=(String)vecObjectIds.elementAt(i)%></xss:encodeForJavaScript>';
          //following if condition is commented as a fix of IR-169668V6R2013x
          //if (vStructureTreeObject.objects[childId]) {
    	        getTopWindow().deleteObjectFromTrees(childId,true);
          // }
<%
       }
%>
       // Changes added by PSA11 start(IR-536333-3DEXPERIENCER2018x).  
       updateCountAndRefreshTreeLBC('<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>',getTopWindow(), false);
	   // Changes added by PSA11 end.       
	   // Changes done by PSA11(IR-484829-3DEXPERIENCER2018x) start.
	   var detailsDisplayFrame = findFrame(getTopWindow(),'detailsDisplay');
       detailsDisplayFrame.lastSelection = null; 
       // Changes done by PSA11 end	   
    }catch (ex) {
        getTopWindow().refreshTablePage();
    }
</script>

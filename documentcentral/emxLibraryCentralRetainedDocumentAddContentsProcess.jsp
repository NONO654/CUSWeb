<%--emxLibraryCentralRetainedDocumentAddContentsProcess.jsp
    Copyright (c) 1992-2016 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of
    MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

    Description: Add contents to given Buisness object
    Parameters : childIds
                objectId

    Author     : Suman
    Date       : 03/23/2007
    History    :

static const char RCSID[] = $Id: emxLibraryCentralRetainedDocumentAddContentsProcess.jsp.rca 1.4.1.4 Wed Oct 22 16:02:35 2008 przemek Experimental przemek $;

--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import = "com.matrixone.apps.domain.util.i18nNow"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%



    //----Getting parameter from request---------------------------
    String parentId            = emxGetParameter(request, "objectId");
    String childIds[]          = getTableRowIDsArray(emxGetParameterValues(request,"emxTableRowId"));
    String typeCheck="";
    StringList slUniqueName=new StringList();
    BusinessObjectList bolist=new BusinessObjectList();
    String PurgeDocType=(String)PropertyUtil.getSchemaProperty(context, "type_PurgedRecord");
    String retainedRel = PropertyUtil.getSchemaProperty(context, "relationship_RetainedRecord");
    DomainRelationship domrel = new DomainRelationship();
    String strRev = JSPUtil.getCentralProperty(application,session,"emxLibraryCentral","Record.IncludeAllRevisions");

    try
    {
        if(childIds!= null)
        {
            String strType= "";
            String strRevision = "";
            String strName = "";
            String sNoConnectRevisions = "";
            String sNoConnectMessage = "";
            boolean bToConnectFailed =false;
            for(int i=0;i<childIds.length;i++)
            {
                StringTokenizer st   = new StringTokenizer(childIds[i],"|");
                String sObjId = "";
                while(st.hasMoreTokens())
                {
                    sObjId = st.nextToken();
                }//End of while

/*Property Setting To Enable/Disable to include all the Revisions in Add Existing Functionality.
##If the value is set to "TRUE" then selecting one revision of the document in Add Existing Search page than
it will also be connected to all the revisions of Documents.
*/
    if("TRUE".equalsIgnoreCase(strRev)){
           BusinessObject busObj= new BusinessObject(sObjId);
           bolist=busObj.getRevisions(context);
           sNoConnectRevisions = "";
           bToConnectFailed =false;
           for (int j=0;j<bolist.size();j++)
           {
              BusinessObject sRev=bolist.getElement(j);
              String sid=sRev.getObjectId();
              DomainObject domObjForState=new DomainObject(sid);
              StringList slSelects = new StringList();
              slSelects.add(DomainConstants.SELECT_TYPE);
              slSelects.add(DomainConstants.SELECT_REVISION);
              slSelects.add(DomainConstants.SELECT_NAME);
              Map mObjsls = domObjForState.getInfo(context,slSelects);

               strType= (String)mObjsls.get(DomainConstants.SELECT_TYPE);
               strRevision = (String)mObjsls.get(DomainConstants.SELECT_REVISION);
               strName = (String)mObjsls.get(DomainConstants.SELECT_NAME);
              DomainObject domObj=new DomainObject(parentId);
              StringList slConId=domObj.getInfoList(context,"from["+retainedRel+"].to.id");
              if(!slConId.contains(sid)&&!strType.equalsIgnoreCase(PurgeDocType)){
                        if(domObjForState.getAccessMask(context).hasToConnectAccess()) {
                              domrel.connect(context,parentId,retainedRel,sid,true);
                        } else {

                            sNoConnectRevisions= "".equals(sNoConnectRevisions)?  "\n\r"+strType+" "+strName+" "+strRevision : sNoConnectRevisions+"\n\r"+strType+" "+strName+" "+strRevision;

                            bToConnectFailed= true;
                        }

             }//End of if
            }//End of for
            if(true == bToConnectFailed && !(sNoConnectMessage.contains(sNoConnectRevisions))) {
                sNoConnectMessage = "".equals(sNoConnectMessage)?sNoConnectMessage = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource", new Locale(context.getSession().getLanguage()),"emxLibraryCentral.Message.CannotConnectObject")+ "\n\r"+sNoConnectRevisions : sNoConnectMessage+sNoConnectRevisions;
            }
    }//End of if
    else{
      domrel.connect(context,parentId,retainedRel,sObjId,true);
    }//End of else
  }//End of for
      if (!"".equals(sNoConnectMessage)) {
          session.setAttribute("error.message",sNoConnectMessage);
      }
  }//End of if
 }catch(Exception e)
 {
        session.setAttribute("error.message",getSystemErrorMessage (e.getMessage()));
 }//End of catch

%>
<script language="javascript" type="text/javaScript">
   var frame = findFrame(getTopWindow(), "detailsDisplay");
	if(frame){
		frame.refreshSBTable();
	}else{
		frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
		frame.refreshSBTable();
	}
        getTopWindow().closeWindow();

</script>

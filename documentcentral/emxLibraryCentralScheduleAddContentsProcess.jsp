<%--emxLibraryCentralScheduleAddContentsProcess.jsp
    Copyright (c) 1992-2016 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of
    MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

    Description: Add contents to given Buisness object
    Parameters : childIds
                objectId

    Author     : Deepika
    Date       : 02/26/2007
    History    :

    static const char RCSID[] = $Id: emxLibraryCentralScheduleAddContentsProcess.jsp.rca 1.2.1.4 Wed Oct 22 16:02:16 2008 przemek Experimental przemek $;

--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
    //----Getting parameter from request---------------------------
    String parentId            = emxGetParameter(request, "objectId");
    String childIds[]          = getTableRowIDsArray(emxGetParameterValues(request,"emxTableRowId"));


    try
    {
        if(childIds!= null)
        {

            for(int i=0;i<childIds.length;i++)
            {
                StringTokenizer st   = new StringTokenizer(childIds[i],"|");
                String sObjId = "";
                while(st.hasMoreTokens())
                {
                    sObjId = st.nextToken();
                }
                sObjId= childIds[i];
                String retainedRel = PropertyUtil.getSchemaProperty(context, "relationship_RetainedRecord");
                DomainRelationship domrel = new DomainRelationship();
                DomainObject obj1=new DomainObject(parentId);
                domrel.connect(context,sObjId,retainedRel,parentId,true);

            }
        }

    }
    catch(Exception e)
    {

        session.setAttribute("error.message",
                                    getSystemErrorMessage (e.getMessage()));
    }


    String strChildIds = "";
    for(int k=0;k<childIds.length;k++){
        strChildIds = strChildIds+childIds[k]+",";
    }

%>
<script language="javascript" type="text/javaScript">
    try{
        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
        getTopWindow().closeWindow();
    }catch(exec){
        parent.window.getWindowOpener().parent.document.location.href=parent.window.getWindowOpener().parent.document.location.href;
        parent.closeWindow();
    }
</script>

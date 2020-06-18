<%--  emxLBCHomePageIntermediate.jsp  -
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxLibraryCentralUtils.inc"%>

<%
    try
    {

        StringBuffer contentURL = new StringBuffer();
        
        Boolean hasLibrarianRole = JPO.invoke(context, "emxObjectAccessBase", null, "hasLibrarianRole", null,Boolean.class);
        Boolean hasLibraryUserRole = JPO.invoke(context, "emxLibraryCentralCommon", null, "hasLibraryViewerRole", null,Boolean.class);
        Boolean hasRetentionRecordRole = JPO.invoke(context, "emxLibraryCentralCommon", null, "hasRetentionRecordRole", null,Boolean.class);
        
        if(hasLibrarianRole || hasLibraryUserRole)
        {
        	contentURL.append("../common/emxIndentedTable.jsp?freezePane=Name&program=emxLibraryCentralUtil:getAllLibraries,emxLibraryCentralUtil:getAllDocumentLibraries,emxLibraryCentralUtil:getAllGeneralLibraries,emxLibraryCentralUtil:getAllPartLibraries,emxLibraryCentralUtil:getAllInprocessLibraries,emxLibraryCentralUtil:getAllActiveLibraries&programLabel=emxDocumentCentral.Common.All,emxLibraryCentral.Common.DocumentLibrary,emxLibraryCentral.Common.GeneralLibrary,emxLibraryCentral.Common.PartLibrary,emxLibraryCentral.Common.InProcessLibraries,emxLibraryCentral.Common.ActiveLibraries&table=LCLibraryList&selection=multiple&sortColumnName=Name&sortDirection=ascending&toolbar=LCLibrariesToolBar&header=emxDocumentCentral.Common.Libraries&HelpMarker=emxhelplibrarylist&path=Library&suiteKey=LibraryCentral");
        
        }else
        {
        	if(hasRetentionRecordRole)
        	{
        		contentURL.append("../common/emxIndentedTable.jsp?freezePane=Name&table=LCRetentionRecordSummary&toolbar=LCRetentionRecordSummaryToolbar&program=emxRetentionRecordBase:getActiveScheduledStateRecords,emxRetentionRecordBase:getCreatedStateRecords,emxRetentionRecordBase:getAllRetentionRecords,emxRetentionRecordBase:getPurgedStateRecords&programLabel=emxLibraryCentral.Command.Filter.Active/Scheduled,emxLibraryCentral.Command.Filter.Created,emxLibraryCentral.Command.Filter.All,emxLibraryCentral.Command.Filter.Purged&header=emxLibraryCentral.Common.RecordRetentionSchedule&HelpMarker=emxhelplibraryrecretentionsummary&selection=multiple&suiteKey=LibraryCentral");
        	}else
        	{
        		contentURL.append("../common/emxIndentedTable.jsp?freezePane=Name&program=emxCommonAccessRequest:getAllAccessRequests&table=APPAccessRequestSummary&selection=multiple&sortColumnName=Name&sortDirection=ascending&toolbar=APPSummaryAccessRequestToolbar&header=emxLibraryCentral.AccessRequest.AccessRequests&HelpMarker=emxhelprequests&path=Library&suiteKey=LibraryCentral");
        	}
            
        }
        
%>
        <script>
            document.location.href='<xss:encodeForJavaScript><%=contentURL.toString()%></xss:encodeForJavaScript>';
        </script>
<%
    }
    catch (Exception ex)
    {
        ex.printStackTrace();
    }
%>

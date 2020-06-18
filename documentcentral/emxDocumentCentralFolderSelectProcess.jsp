<%--  emxDocumentCentralFolderSelectProcess.jsp   -
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: Add children to folder(s)
   Parameters : FolderIDs and childrenIds
   Author     : MadhavG
   Date       : 12/13/2002
   History    :

   static const char RCSID[] = $Id: emxDocumentCentralFolderSelectProcess.jsp.rca 1.16 Wed Oct 22 16:02:19 2008 przemek Experimental przemek $;

--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="LibraryCentralBean" class="com.matrixone.apps.library.Libraries" scope="session"/>
<%

    //--------------Getting parameters(childIds and FolderIds)

    String emxTableRowIds[]  =   emxGetParameterValues(request,"emxTableRowId");
    String languageStr       = request.getHeader("Accept-Language");
    String childIds[]        = LibraryCentralBean.getObjectRowID();
    StringList slFolderIds   = getTableRowIDs(emxTableRowIds);
    String folderIds[]       = (String[]) slFolderIds.toArray(new String[slFolderIds.size()]);
    String objNameNotAdded   = "";
    String useMode           = emxGetParameter(request,"useMode");
    useMode                  = UIUtil.isNullOrEmpty(useMode)?"":useMode;

    // --------------Adding to Folders---------------------------

    try
    {
        objNameNotAdded = DCWorkspaceVault.addToFolders(context,
                                                 folderIds,childIds);
    }
    catch(Exception e)
    {
        session.setAttribute("error.message",
                            getSystemErrorMessage (e.toString()));
    }
%>

<script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    // if("addToFoldersFromListPage"  == "<%=useMode%>")
    if("addToFoldersFromListPage"  == "<xss:encodeForJavaScript><%=useMode%></xss:encodeForJavaScript>")
    {
        getTopWindow().getWindowOpener().location.href =getTopWindow().getWindowOpener().location.href;
    }
    getTopWindow().closeWindow();
   //Stop hiding here -->//]]>
</script>

<%--  emxLibraryCentralObjectAddContentsProcess.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: Add contents to given Buisness object
   Parameters : childIds
                objectId

   Author     :
   Date       :
   History    :

    static const char RCSID[] = $Id: emxLibraryCentralObjectAddContentsProcess.jsp.rca 1.6 Wed Oct 22 16:02:44 2008 przemek Experimental przemek $;

   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<%@include file = "../common/emxTreeUtilInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
	 //----Getting parameter from request---------------------------

	String sRelSubclass        = LibraryCentralConstants.RELATIONSHIP_SUBCLASS;

    String parentId            = emxGetParameter(request, "objectId");
    String childIds[]          = emxGetParameterValues(request,"emxTableRowId");
    String folderContentAdd    = emxGetParameter(request, "folderContentAdd");

    //Getting the Type Info  of the Parent.

    DomainObject parentobj = new DomainObject(parentId);

    String sParentType   = parentobj.getInfo(context,DomainObject.SELECT_TYPE);
	String strVault      = parentobj.getVault();
    BusinessType busType = new BusinessType(sParentType,new Vault(strVault));

	String strParentType = busType.getParent(context);

      //Getting the Appropriate Bean instance from the Object Id.
		if(strParentType!= null && strParentType.equalsIgnoreCase(LibraryCentralConstants.TYPE_CLASSIFICATION))
		{
			Classification baseObject =(Classification)DomainObject.newInstance(context,parentId,LibraryCentralConstants.LIBRARY);
			  try
			  {
				baseObject.addSubclass(context,childIds);
			  }
			  catch(Exception e)
			  {
				  session.setAttribute("error.message",getSystemErrorMessage (e.getMessage()));
			  }
		 }
		 else
		 {
			Libraries baseObject =(Libraries)DomainObject.newInstance(context,parentId,LibraryCentralConstants.LIBRARY);
			try
			{
			   baseObject.addSubclass(context,childIds);
			}
			catch(Exception e)
			{

				session.setAttribute("error.message",getSystemErrorMessage (e.getMessage()));
			}
 		}

    String strChildIds = "";
    for(int k=0;k<childIds.length;k++){
        strChildIds = strChildIds+childIds[k]+",";
    }

%>

<script language="JavaScript" src="../components/emxComponentsTreeUtil.js" type="text/javascript"></script>
<script language="javascript" type="text/javaScript">
    try {
        addMultipleStructureNodes("<xss:encodeForJavaScript><%=strChildIds%></xss:encodeForJavaScript>","<xss:encodeForJavaScript><%=parentId%></xss:encodeForJavaScript>","<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>",getTopWindow().getWindowOpener().getTopWindow());
        updateCountAndRefreshTree("<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>", getTopWindow().getWindowOpener().getTopWindow());
        parent.closeWindow();
    }catch (ex){
        parent.closeWindow();
    }
</script>

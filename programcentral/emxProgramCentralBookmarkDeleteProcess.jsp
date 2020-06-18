<%--  emxProgramCentralBookmarkProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralBookmarkDeleteProcess.jsp.rca 1.15 Wed Oct 22 15:49:46 2008 przemek Experimental przemek $";

  Reviewed for Level III compliance by AMM 5/3/2002
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  com.matrixone.apps.program.URL bookmark = (com.matrixone.apps.program.URL) DomainObject.newInstance(context, DomainConstants.TYPE_URL, "PROGRAM");
  com.matrixone.apps.program.ProjectSpace project = (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE, "PROGRAM");

  String[] strBookmarks = emxGetParameterValues(request,"emxTableRowId");
    String partialXML = "";
  StringList slBookmarkTokens = new StringList();
  String strBookmarkId = null;
  String strBookmarkRelId = null;
  StringList slBookmarkIds = new StringList();
  StringList slBookmarkRelIds = new StringList();
//Added 12-Aug-2010:rg6:IR-054478V6R2011x
  DomainObject dObjBookmark = DomainObject.newInstance(context);
  String strLanguage = request.getHeader("Accept-Language");
//End 12-Aug-2010:rg6:IR-054478V6R2011x 

  String sUiTypeParam = emxGetParameter(request, "uiType"); //Added:PRG:RG6:R212:5-July-2011:IR-116259V6R2012x::

  if(null !=strBookmarks)
  {
	// [ADDED::PRG:RG6:Feb 22, 2011:IR-087045V6R2012 :R211::Start]
	  String SELECT_IS_URL_TYPE = "type.kindof["+DomainConstants.TYPE_URL+"]";
      String SELECT_HAS_DELETE_ACCESS = "current.access[delete]";
      StringList slBookMarkSelects = new StringList();
      slBookMarkSelects.add(DomainConstants.SELECT_ID);
      slBookMarkSelects.add(DomainConstants.SELECT_NAME);
      slBookMarkSelects.add(SELECT_IS_URL_TYPE);
      slBookMarkSelects.add(SELECT_HAS_DELETE_ACCESS);
      slBookMarkSelects.add("to["+DomainConstants.RELATIONSHIP_LINK_URL+"].id");
      slBookMarkSelects.add("to["+DomainConstants.RELATIONSHIP_TASK_DELIVERABLE+"].id");
      slBookMarkSelects.add("to["+DomainConstants.RELATIONSHIP_REFERENCE_DOCUMENT+"].id");
      slBookMarkSelects.add("to["+DomainConstants.RELATIONSHIP_LINK_URL+"].from.id");
      slBookMarkSelects.add("to["+DomainConstants.RELATIONSHIP_TASK_DELIVERABLE+"].from.id");
      slBookMarkSelects.add("to["+DomainConstants.RELATIONSHIP_REFERENCE_DOCUMENT+"].from.id");
      
  for (int i = 0; i < strBookmarks.length; i++)
  {
		      String[] strBookmarkTokens = strBookmarks[i].split("\\|");
		      strBookmarkId = (String)strBookmarkTokens[1];     
		      String rowId =  (String)strBookmarkTokens[strBookmarkTokens.length-1];
		      
      if(ProgramCentralUtil.isNotNullString(strBookmarkId))
      {
      dObjBookmark.setId(strBookmarkId);
    	  Map mapBookmarkInfo = dObjBookmark.getInfo(context,slBookMarkSelects);
    	  String sIsURLType = (String) mapBookmarkInfo.get(SELECT_IS_URL_TYPE);
    	  String sName = (String) mapBookmarkInfo.get(DomainConstants.SELECT_NAME);
          strBookmarkRelId = (String) mapBookmarkInfo.get("to["+DomainConstants.RELATIONSHIP_LINK_URL+"].id");
          String strBookmarkParentId = (String) mapBookmarkInfo.get("to["+DomainConstants.RELATIONSHIP_LINK_URL+"].from.id");
          
          if(ProgramCentralUtil.isNullString(strBookmarkRelId)){
        	  strBookmarkRelId = (String) mapBookmarkInfo.get("to["+DomainConstants.RELATIONSHIP_TASK_DELIVERABLE+"].id");
          }
          
          if(ProgramCentralUtil.isNullString(strBookmarkRelId)){
        	  strBookmarkRelId = (String) mapBookmarkInfo.get("to["+DomainConstants.RELATIONSHIP_REFERENCE_DOCUMENT+"].id");
          }
          
          if(ProgramCentralUtil.isNullString(strBookmarkParentId)){
        	  strBookmarkParentId = (String) mapBookmarkInfo.get("to["+DomainConstants.RELATIONSHIP_TASK_DELIVERABLE+"].from.id");
          }
          
          if(ProgramCentralUtil.isNullString(strBookmarkParentId)){
        	  strBookmarkParentId = (String) mapBookmarkInfo.get("to["+DomainConstants.RELATIONSHIP_REFERENCE_DOCUMENT+"].from.id");
          }
          
    	  if(null != sIsURLType && "TRUE".equalsIgnoreCase(sIsURLType.trim()))
    	  {
    		  String sHasDeleteAccess = (String) mapBookmarkInfo.get(SELECT_HAS_DELETE_ACCESS);
		  String strUserName = context.getUser();
		  boolean bRemoveStatus = true;
		  DomainObject bookmarkParent = DomainObject.newInstance(context,strBookmarkParentId);
		  if(bookmarkParent.isKindOf(context,DomainObject.TYPE_WORKSPACE_VAULT)){
                      String folderId = (String)strBookmarkTokens[2];
                      bRemoveStatus = PMCWorkspaceVault.hasAccessOnWorkspaceVault(context,folderId, ProgramCentralConstants.VAULT_ACCESS_REMOVE, strUserName);
		  }
    		  if(null != sHasDeleteAccess && "TRUE".equalsIgnoreCase(sHasDeleteAccess.trim()) && bRemoveStatus == true) //IR-170213V6R2013x: added bRemoveStatus check
    		  {
    			  slBookmarkRelIds.add(strBookmarkRelId);
    	          slBookmarkIds.add(strBookmarkId);  
    		  }
    		  else
    		  {
    			  String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
    					  "emxProgramCentral.ProjectContent.NoDeleteAccessToBookmark", strLanguage );
    	          %>
    	          <script language="JavaScript" type="text/javascript">
    	                      alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg+"\\n"+sName)%>");
    	          </script>
    	         <%return;
    		  }
    	  }
    	  else
    	  {
    		//Added 12-Aug-2010:rg6:IR-054478V6R2011x
    	  String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
    			  "emxProgramCentral.Bookmark.SelectBookmarkOnly", strLanguage );
          %>
           <script language="JavaScript" type="text/javascript">
                                          alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                                          window.closeWindow();
                                      </script>
          <%return;      
    		//End 12-Aug-2010:rg6:IR-054478V6R2011x
    	  }
      }
      partialXML += "<item id=\"" + rowId + "\" />";
  }
//[ADDED::PRG:RG6:Feb 22, 2011:IR-087045V6R2012 :R211::End]
  String[] strBookmarkRelIds = (String[])slBookmarkRelIds.toArray(new String[slBookmarkRelIds.size()]);
  String[] strBookmarkObjIds = (String[])slBookmarkIds.toArray(new String[slBookmarkIds.size()]);
 
    //Delete bookmarks
     if( strBookmarkRelId != null)
    {
         bookmark.removeURLs(context, strBookmarkRelIds, true);
         if("structureBrowser".equalsIgnoreCase(sUiTypeParam))  //Added:PRG:RG6:R212:5-July-2011:IR-116259V6R2012x::
         {
         //[Added::Feb 21, 2011:MS9:2012:IR-054191::Start]
         String xmlMessage = "<mxRoot>";
         String message = "";
         xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
         xmlMessage += partialXML;
         xmlMessage += "<message><![CDATA[" + message + "]]></message>";
         xmlMessage += "</mxRoot>";
                 
         %>
         <script type="text/javascript" language="JavaScript">
         window.parent.removedeletedRows('<%= xmlMessage %>');     <%-- XSSOK--%>  
         </script>
         <%
         //[Added::Feb 21, 2011:MS9:2012:IR-054191::End]
         } //Added:PRG:RG6:R212:5-July-2011:IR-116259V6R2012x::Start
         else
         {
             %>
                 <script type="text/javascript" language="JavaScript">
                     if(getTopWindow().refreshTablePage)
                     {
                         getTopWindow().refreshTablePage();
                     }
                 </script>
             <%
                 
          } //Added:PRG:RG6:R212:5-July-2011:IR-116259V6R2012x::End 
    }
%>
<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    var tree = getTopWindow().objDetailsTree;
<%
    //Loop through all ids passed in for delete and remove them from the navigation tree
    if (strBookmarkObjIds != null)
    {
      Iterator bookmarksItr = Arrays.asList(strBookmarkObjIds).iterator();
      while (bookmarksItr.hasNext())
      {
        String tempBookMarkId = (String) bookmarksItr.next();
%>
	    if(tree != null)
            tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,tempBookMarkId)%>",false);
<%
      } //end while itr has next
    } //end if folders does not equal null
  }
%>
  </script>
</html>

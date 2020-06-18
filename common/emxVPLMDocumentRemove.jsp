<%--  emxVPLMDocumentRemove.jsp   -

   Copyright (c) 1992-2008 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxVPLMDocumentRemove.jsp.rca 1.14 Wed Oct 22 16:18:22 2008 przemek Experimental przemek przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../components/emxComponentsUtil.inc"%>

<%
  String[] oids = emxGetParameterValues(request, "emxTableRowId");
try
{
  //get document Id
  Map objectMap = UIUtil.parseRelAndObjectIds(context, oids, false);
  oids = (String[])objectMap.get("objectIds");
  String[] relIds = (String[])objectMap.get("relIds");
  String action = emxGetParameter(request, "action");
  String objectId = emxGetParameter(request, "objectId");

  if ( "disconnect".equals(action) )
  {
      //Added for the Bug 314495 Begin
      boolean contextPushed = false;
      try
      {
          	Map programMap = new HashMap();
		programMap.put("objectId", objectId);
		programMap.put("documentIds", oids);
		String[] methodargs =JPO.packArgs(programMap);
				
		JPO.invoke(context, "VPLMDocument", null,"detachDocuments", methodargs);	
      }
      catch (Exception exp)
      {
        try
        {
            //Added for the Bug 314495 Begin
            DomainObject commonRt2 = DomainObject.newInstance(context,objectId);
            Access contextAccess = commonRt2.getAccessMask(context);
            if(contextAccess.hasToConnectAccess())
            {
                ContextUtil.pushContext(context);
                contextPushed = true;
                Map programMap = new HashMap();
		    programMap.put("objectId", objectId);
		    programMap.put("documentIds", oids);
		    String[] methodargs =JPO.packArgs(programMap);
				
		    JPO.invoke(context, "VPLMDocument", null,"detachDocuments", methodargs);
           
		 } else
		 {
                 throw new FrameworkException(exp);
             }
         } catch(Exception ex) 
	   {
                throw new FrameworkException(ex);
         }
         finally
         {
            if( contextPushed)
              ContextUtil.popContext(context);
         }
       }

  } else if ("delete".equalsIgnoreCase(action) )
  {
	Map programMap = new HashMap();
	programMap.put("objectId", objectId);
	programMap.put("documentIds", oids);
	String[] methodargs =JPO.packArgs(programMap);
				
	JPO.invoke(context, "VPLMDocument", null,"detachDocuments", methodargs);
      CommonDocument.deleteDocuments(context, oids);
  }
} catch (Exception ex)
{
    session.setAttribute("error.message" , ex.toString());
}
%>
<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" >
  var frameContent = findFrame(top,"detailsDisplay");
  var contTree = top.objDetailsTree;
  if(contTree == null) {
      if (frameContent != null )
      {
        frameContent.document.location.href = frameContent.document.location.href;
      } else {
        top.document.location.href = top.document.location.href;
      }
  } else {
<%
      for (int i=0;i<oids.length;i++){
        String objId = oids[i];
%>
          contTree.deleteObject("<%=objId%>", false);
<%
        }
%>
    if (frameContent != null )
    {
    parent.location.href = parent.location.href;
    } else {
      top.document.location.href = top.document.location.href;
    }
  }
</script>

</body>
</html>

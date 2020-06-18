<%--  emxengchgECRDisconnectObjs.jsp   -  This page deletes the selected objectIds
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>


<%
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String summaryPage = emxGetParameter(request,"summaryPage");

  String[] sCheckBoxArray = emxGetParameterValues(request, "checkBox");

  String url = "";
  String delId ="";

    if(sCheckBoxArray != null)
    {
       try
       {
           //377009: do not push context before removing affected items.
		   //ContextUtil.pushContext(context);
          for(int i=0; i < sCheckBoxArray.length; i++)
          {
            StringTokenizer st = new StringTokenizer(sCheckBoxArray[i], "|");
            String sRelId = st.nextToken();

            BusinessObject FromObject = null;
            BusinessObject ToObject =null;
            String FromId ="";
            String ToId="";

            matrix.db.Relationship relobject = new matrix.db.Relationship(sRelId);
            relobject.open(context);

            FromObject = relobject.getFrom();
            ToObject = relobject.getTo();

            if(FromObject != null ){
              FromId = FromObject.getObjectId();
            }
            if(ToObject != null ){
              ToId = ToObject.getObjectId();
            }
            relobject.close(context);

            if(objectId.equals(FromId)){
              delId=delId+ToId+";";
            } else{
              delId=delId+FromId+";";
            }

            DomainRelationship.disconnect(context,sRelId);

            if(st.hasMoreTokens())
            {
              String sRelRAE = st.nextToken();
              if(!"null".equals(sRelRAE) && !"".equals(sRelRAE)) {
                DomainRelationship.disconnect(context, sRelRAE);
              }
            }

          }

         url = summaryPage + "?objectId=" + objectId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey;
       }
       catch(Exception Ex)
       {
          // System.out.println(Ex.toString());
          throw Ex;
       }
       finally
       {
           //377009
		   //ContextUtil.popContext(context);
	   }
    }

%>

<%@include file = "emxDesignBottomInclude.inc"%>

<script language="Javascript">
   var tree = getTopWindow().objDetailsTree;
   if(tree)
   {
<%
   StringTokenizer sIdsToken = new StringTokenizer(delId,";",false);
   while (sIdsToken.hasMoreTokens()) {
     String RelId = sIdsToken.nextToken();

%>
	//XSSOK
     tree.deleteObject("<%=RelId%>");
<%
   }

%>

}
// Modified "parent.location.reload();" to "parent.location.href= parent.location.href ;" for Bug No 316615
  parent.location.href= parent.location.href ;
</script>


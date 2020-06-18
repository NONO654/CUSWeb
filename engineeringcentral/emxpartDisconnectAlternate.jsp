<%--  emxpartDisconnectAlternate.jsp  - To disconnect alternate from a part. 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>

  <script language="JavaScript">
  </script>
  
 
 
<%
   
  String[] sRelItemsArray = emxGetParameterValues(request,"alternate");
  String sDelimiter="|";
  String sPartId = emxGetParameter(request,"busId");
  BusinessObject partObj = new BusinessObject(sPartId);
  for(int i=0; i<sRelItemsArray.length;i++)
    {
  StringTokenizer st = new StringTokenizer(sRelItemsArray[i],sDelimiter);
  
  String sRelId = st.nextToken();
  String objId = st.nextToken();
  partObj.open(context);  
  BusinessObject obj = new BusinessObject(objId);
  obj.open(context);
  Relationship relationship = new Relationship(sRelId);
  relationship.open(context);
  partObj.disconnect(context,relationship);
  relationship.close(context);
  obj.close(context);
  partObj.close(context);  
    }
 
  
 String url="emxpartReviewPartData.jsp?busId="+sPartId+"&tabName=Alternate"; 
                context.shutdown();

%> 
<%@include file = "emxDesignBottomInclude.inc"%>
<!--XSSOK-->
<jsp:forward page="<%=XSSUtil.encodeForJavaScript(context,url)%>" />


 

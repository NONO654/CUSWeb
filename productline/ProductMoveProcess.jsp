<%--  ProductMoveProcess.jsp

      Copyright (c) 1999-2018 Dassault Systemes.

      All Rights Reserved.
      This program contains proprietary and trade secret information
      of MatrixOne, Inc.  Copyright notice is precautionary only and
      does not evidence any actual or intended publication of such program


    --%>
    <%-- Include JSP for error handling --%>
    <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

    <%-- Common Includes --%>
    <%@include file = "emxProductCommonInclude.inc" %>
    <%@include file = "../emxUICommonAppInclude.inc"%>
    <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

    <%@page import = "com.matrixone.apps.domain.DomainConstants"%>
    <%@page import = "com.matrixone.apps.domain.DomainRelationship"%>
    <%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
    <%@page import = "com.matrixone.apps.domain.DomainObject"%>
    <%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>

    <%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
	<%//Begin of Modify by Praveen,Enovia MatrixOne for bug#300717 03/17/2005 %>
    <%@page import = "com.matrixone.apps.domain.util.ContextUtil"%>
    <%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
	<%//End of Modify by Praveen,Enovia MatrixOne for bug#300717 03/17/2005 %>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<script>
    bRefreshFlag = false;
</script>

<%
boolean bFlag=false;

try{
boolean bHasDisconnectAccess = true;
String STR_DELIMITER = ",";
String[] strSelectedModelId = (String[])emxGetParameterValues(request,"emxTableRowId");
if(strSelectedModelId!=null)

{

String timeStamp = emxGetParameter(request, "timeStamp");
HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
//Get the symbolic relationship name from the requestmap
String strSrcDestRelNameSymb = (String)requestMap.get("srcDestRelName");
String strSrcDestRelName = "";

//Get the actual relationship name
if (strSrcDestRelNameSymb != null) {
    strSrcDestRelName = PropertyUtil.getSchemaProperty(context,strSrcDestRelNameSymb);
 }
DomainObject dObj = new DomainObject();
ProductLineCommon commonBean = new ProductLineCommon();

//get the Product Ids fro the request Map
String strProductsToBeMovedIds =(String)requestMap.get("ProductsToBeMovedIds");
StringTokenizer stProductsToBeMovedIds = new StringTokenizer(strProductsToBeMovedIds,STR_DELIMITER);
int iArraySize = stProductsToBeMovedIds.countTokens();
String[] strProductsToBeMovedIdsArray = new String[iArraySize];
//array to store relationship Ids
String[] strToBeMovedRelIds = new String[iArraySize];

//array to store Object Ids
String[] strProductToBeMovedIds = new String[iArraySize];
//construct an array from the the stringTokenizer
for(int i = 0 ; i < iArraySize ; i++)

    {
     strProductsToBeMovedIdsArray[i] = stProductsToBeMovedIds.nextToken();
    }
//get the RelIds and objectIds from the "|" separated strProductsToBeMovedIdsArray values.
if(strProductsToBeMovedIdsArray!=null)
  {
      Map relIdMap=ProductLineUtil.getObjectIdsRelIds(strProductsToBeMovedIdsArray);
      strToBeMovedRelIds = (String[]) relIdMap.get("RelId");
      strProductToBeMovedIds = (String[]) relIdMap.get("ObjId");
  }

for(int i = 0;i<strProductToBeMovedIds.length;i++)
{
    dObj = new DomainObject(strProductToBeMovedIds[i]);

    /*checks whether the context user has remove access for
      each of the selected */

   if (!FrameworkUtil.hasAccess(context, dObj, "ToDisconnect"))
    {
     bHasDisconnectAccess = false;
     break;
    }
 }
if(bHasDisconnectAccess)
{
     // Begin of Modify by Enovia MatrixOne for Bug # 300719 Date 05/10/2005
     DomainObject domModel = DomainObject.newInstance(context, strSelectedModelId[0]);
     Map mpProduct = domModel.getRelatedObject(
                             context,
                             ProductLineConstants.RELATIONSHIP_PRODUCTS,
                             true,
                             new StringList(DomainConstants.SELECT_ID),
                             null);

    if(mpProduct!=null){
     //start the transaction
     ContextUtil.startTransaction(context, true);
    
    //Begin of Modify by Enovia MatrixOne for Bug 304880 on 5/20/2005
     for(int i=0;i<strToBeMovedRelIds.length;i++)
     {
         if(strToBeMovedRelIds[i]==null || 
             "null".equalsIgnoreCase(strToBeMovedRelIds[i]) ||
             "".equals(strToBeMovedRelIds[i]))
         {
             DomainObject dObj1 = new DomainObject(strProductToBeMovedIds[i]);
             strToBeMovedRelIds[i] = dObj1.getInfo(context,
                                            "to["+ProductLineConstants.RELATIONSHIP_PRODUCTS+"].id");
         }
     }
    for(int i=0;i<strToBeMovedRelIds.length;i++)
    {
        if(strToBeMovedRelIds[i]!=null && 
             !"null".equalsIgnoreCase(strToBeMovedRelIds[i]) &&
             !"".equals(strToBeMovedRelIds[i]))
        {
            DomainRelationship.disconnect(context, strToBeMovedRelIds[i]);
        }
    }
    //End of Modify by Enovia MatrixOne for Bug 304880 on 5/20/2005

     //connect the Products to the new model (selected on the search results page)
     DomainRelationship.connect(context, new DomainObject(strSelectedModelId[0]), strSrcDestRelName,true,strProductToBeMovedIds);

     BusinessObject busProductLastRevision = null;
     DomainObject domProductObj = null;

     domProductObj = DomainObject.newInstance(context, (String)mpProduct.get(DomainConstants.SELECT_ID));
     busProductLastRevision = domProductObj.getLastRevision(context);

     for(int j=0;j<strProductToBeMovedIds.length;j++)
     {
         busProductLastRevision.revise(context,new BusinessObject(strProductToBeMovedIds[j]), false);
         busProductLastRevision = new BusinessObject(strProductToBeMovedIds[j]);
     }

     //End the transaction
     ContextUtil.commitTransaction(context);

%>
<!--Javascript to refresh the Products List page -->
<script>
//Begin of Add by Enovia MatrixOne on 16-May-2005 for Bug#304479
var tree = getTopWindow().getWindowOpener().getTopWindow().trees['emxUIDetailsTree'];
<%
    for(int k=0;k<strProductToBeMovedIds.length;k++){
%>
     tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,strProductToBeMovedIds[k])%>");
<%
    }
%>
//End of Add by Enovia MatrixOne on 16-May-2005 for Bug#304479
             var contentFrame = findFrame(getTopWindow().getWindowOpener().parent.parent,"detailsDisplay");
             //Begin of Modify by Enovia MatrixOne for Bug 304880 on 5/20/2005
             if(contentFrame)
             {
                contentFrame.location = contentFrame.location;
             }
             else if (findFrame(getTopWindow().getWindowOpener().parent.parent,"content"))
             {
                 var successMsg = "<%=i18nStringNowUtil("emxProduct.Alert.ProductMoved",bundle,acceptLanguage)%>";
                 alert(successMsg);
             }
             //End of Modify by Enovia MatrixOne for Bug 304880 on 5/20/2005
             parent.window.closeWindow();
</script>
<%
    }
    else{
    %>
<script>
          alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.HasNoProductUnderDestinationModel</emxUtil:i18n>");
          bRefreshFlag=true;
</script>
 <%
    }
     // End of Modify by Enovia MatrixOne for Bug # 300719 Date 05/10/2005
}
else{
    %>
<script>
          alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.HasDisconnectAccess</emxUtil:i18n>");
          bRefreshFlag=true;
</script>
 <%

}

 }
 else{
    %>
<script>
          alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.PleaseSelectAnItem</emxUtil:i18n>");
          bRefreshFlag=true;
</script>
 <%

}

  } catch (Exception e){
       ContextUtil.abortTransaction(context);
       String strAlertString = "emxProduct.Alert." + e.getMessage();
       String i18nErrorMessage = i18nStringNowUtil(strAlertString,bundle,acceptLanguage);
       if(i18nErrorMessage.equals(DomainConstants.EMPTY_STRING)){
         bFlag=true;
         session.putValue("error.message", e.getMessage());
       }else{
         session.putValue("error.message", i18nErrorMessage);
       }
 %>
 <script>
        bRefreshFlag = true;
 </script>
 <%
     }
    %>
<!--Modified by Enovia MatrixOne on 6/7/2005 for Issue about Move Product-->
<!--Javascript to refresh the footer frame-->
<script>
        if(bRefreshFlag)
        {
            footerFrame = findFrame(parent,"listFoot");
            if(footerFrame != null)
            {
                footerFrame.location.reload();
                bRefreshFlag = false;
            }
        }
</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
    if (bFlag)
    {
%>
    <!--Javascript to bring back to the previous page-->
    <script language="javascript" type="text/javaScript">
      history.back();
    </script>
<%
    }
%>


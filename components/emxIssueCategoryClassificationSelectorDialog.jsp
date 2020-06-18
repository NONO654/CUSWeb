<%--  emxIssueCategoryClassificationSelectorDialog.jsp

  Issue Category Classification page

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program


--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@ page import = "matrix.db.Context"%>
<%@ page import = "java.util.List"%>
<%@ page import = "java.util.Map"%>
<%@ page import = "java.util.HashMap"%>
<%@ page import = "com.matrixone.apps.domain.util.i18nNow"%>

<jsp:useBean id="issue" scope="page" class="com.matrixone.apps.common.Issue"/>

<%
try{
//Start of Add By Infosys, for Bug # 284950 on 16 Jan 2006
String strFromProcess = emxGetParameter(request, "fromProcess");
if ((strFromProcess==null)|| ("null".equalsIgnoreCase(strFromProcess)) )
	strFromProcess = "";

//End of Add By Infosys, for Bug # 284950 on 16 Jan 2006

 List issueCategoryList = null;
 StringList busSelects = new StringList(issue.SELECT_ID);
 Map issueCategoryMap = new HashMap();
   String strCatClassValue = "";

 //For Localized Values
 String strLanguage = request.getHeader("Accept-Language");

 //Get the Issue Categories(Passing the Name to query)
 busSelects.add(issue.SELECT_NAME);

 //to retrieve Category objects
 issueCategoryList = issue.getIssueCategories(context, busSelects);

 Iterator mainCategoryItr = issueCategoryList.iterator();
 Map currentMap = null;
 Map subCategoryMap = null;
 String strObjectId = "";
 StringList subCategoryList = null;
 Iterator subCategoryItr = null;

 //to traverse through each category
 while(mainCategoryItr.hasNext())
    {
    currentMap =  (Map) mainCategoryItr.next();
    issue.setId((String)currentMap.get(issue.SELECT_ID));
    strObjectId = (String)currentMap.get(issue.SELECT_ID);

    //To retrieve classifications
    subCategoryItr = issue.getClassifications(context, strObjectId,busSelects).iterator();

    subCategoryList = new StringList();

    while(subCategoryItr.hasNext())
    {
    subCategoryMap = (Map) subCategoryItr.next();
    subCategoryList.add((String)subCategoryMap.get(issue.SELECT_NAME));
    }

    issueCategoryMap.put((String)currentMap.get(issue.SELECT_NAME),subCategoryList);
    }
%>

  <script language="javascript" type="text/javaScript">//<![CDATA[
    <%-- hide JavaScript from non-JavaScript browsers --%>

  //get reference to the tree object
    var tree = parent.tree;

    //set the current frame to the display frame
    tree.displayFrame = self.name;

    //to display radio buttons
    tree.multiSelect = false;

<%
 if (issueCategoryList != null && (issueCategoryList.size() > 0))
 {
%>
  // Creating root of the category classification tree
    tree.createRoot( "<framework:i18n localize='i18nId'>emxComponents.Common.Categories</framework:i18n>", "../common/images/iconSmallContent.gif", "none");
<%
  Object[] issueCategoryNames = issueCategoryMap.keySet().toArray();
  String strIssueCatName = "";
  String strTemp = "";
  String strCatClass = "";

  String strIssueCatNameTempJ;
  String strIssueCatNameTempJNext;


  //Bubble Sorting the Object Array issueCategoryNames Lexicographically
  for(int j=0; j<(issueCategoryNames.length-1); j++)
  {
   //System.out.println("issueCategoryNames[" + ii + "]" + (String)issueCategoryNames[ii] );
   for(int k=0; k<(issueCategoryNames.length-1)-j; k++)
   {
    strIssueCatNameTempJ = (String)issueCategoryNames[k];
    strIssueCatNameTempJNext = (String)issueCategoryNames[k+1];

    //Compare succeeding elements in the Object Array
    if(strIssueCatNameTempJ.compareToIgnoreCase(strIssueCatNameTempJNext) > 0 )
    {
     //Swap consecutive objects if first is Lexicographically greater than the other
     Object temp = issueCategoryNames[k+1];

     issueCategoryNames[k+1] = issueCategoryNames[k];
     issueCategoryNames[k] = temp;
    }
   }
  }

  //traversing through Categories
  for(int i=0; i<issueCategoryNames.length; i++)
  {
     strIssueCatName = (String)issueCategoryNames[i];
     StringBuffer sbCategoryStr = new StringBuffer("emxComponents.Common.").append(strIssueCatName.replace(' ', '_'));

%>
	//XSSOK
    var strCategLabel="<framework:i18n localize='i18nId'><%=sbCategoryStr%></framework:i18n>";
    //To check whether the entry is available in Property file
    if(strCategLabel.substring(0,13)=="Error in i18n")
     strCategLabel="<%=XSSUtil.encodeForJavaScript(context,strIssueCatName)%>";
    // Adding the Category to the tree
    objCurNode = tree.root.addChild(strCategLabel, "../common/images/iconSmallContent.gif", false, "", "radiobutton", "<%=XSSUtil.encodeForURL(context,strIssueCatName)%>");
    //Graying out the Category object
    objCurNode.selectable = false;
<%
     StringList subCategories = (StringList)issueCategoryMap.get(strIssueCatName);
   // To sort the subcategories
     subCategories.sort();

     //Traversing through Classifications in a Category
     for(int j=0; j<subCategories.size(); j++)
     {
     strTemp = (String)subCategories.get(j);
     //Reading the entry from property file
     StringBuffer sbSubCategoryStr = new StringBuffer("emxComponents.Common.").append(strTemp.replace(' ', '_'));
     //To separate Category and Classification by '/'
     strCatClass = strIssueCatName + "/" + strTemp;
%>
    //XSSOK
	var strClassnLabel="<framework:i18n localize='i18nId'><%=sbSubCategoryStr%></framework:i18n>";
    //To check whether the entry is available in Property file
    if(strClassnLabel.substring(0,13)=="Error in i18n")
     strClassnLabel="<%=XSSUtil.encodeForJavaScript(context, strTemp)%>";

    //Adding Classification to Category
     objCurNode1 = objCurNode.addChild(strClassnLabel,"../common/images/iconSmallFile.gif", false, "", "radiobutton", "<%=XSSUtil.encodeForJavaScript(context,strCatClass)%>");
<%
     } //end of for (Classifications)
  }//end of for (Categories)
 }//end of if
    else {
%>
  // Creating root of the category classification tree and displaying 'No Items' message
    tree.createRoot( "<framework:i18n localize='i18nId'>emxComponents.Common.NoItemsToDisplay</framework:i18n>", "../common/images/iconCategory.gif", "none");
<%
 }//end of else
%>
  //Displaying tree
  tree.draw();
//Modified for Bug No:322703 0 6/21/2007 3:23 PM Begin
function closeWindow() {
   window.closeWindow();
    return;
  }
//Modified for Bug No:322703 0 6/21/2007 3:23 PM End

</script>
<%

//Start of Add By Infosys, for Bug # 284950 on 16 Jan 2006
if (Boolean.parseBoolean(strFromProcess))
{
String strPleaseSelectItem = i18nNow.getI18nString("emxComponents.Common.PleaseSelectAnItem","emxComponentsStringResource",request.getHeader("Accept-Language"));
%>
	<script language="javascript">
		alert("<%=XSSUtil.encodeForJavaScript(context, strPleaseSelectItem)%>");
	</script>
<%
}
//End of Add By Infosys, for Bug # 284950 on 16 Jan 2006

} // End of try
catch(Exception ex) {
 ex.printStackTrace(System.out);
 session.putValue("error.message", ex.getMessage());
} // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>









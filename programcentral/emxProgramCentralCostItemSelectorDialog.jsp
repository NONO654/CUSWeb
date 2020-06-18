<%--  emxProgramCentralCostItemSelectorDialog.jsp

  Cost Category List page

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralCostItemSelectorDialog.jsp.rca 1.15 Wed Oct 22 15:49:35 2008 przemek Experimental przemek $";
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<jsp:useBean id="financialTemplateCategory" scope="page" class="com.matrixone.apps.program.FinancialTemplateCategory"/>

<%
    //alert message if none is selected
    String strSelectItem = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.PleaseSelectAnItem", request.getHeader("Accept-Language"));
%>
<html>

  <body onLoad="loadTree()">
    <framework:i18n localize="i18nId">emxProgramCentral.PowerSearch.LoadingTree</framework:i18n>
  </body>

  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    function loadTree() {
      //get reference to the tree object
      var tree = parent.tree;

      //set the current frame to the display frame
      tree.displayFrame = self.name;

      //we want radio buttons
      tree.multiSelect = true;
      
      tree.alertMessage = "<%=strSelectItem%>";
<%
//  com.matrixone.apps.program.FinancialTemplateCategory financialTemplateCategory =
//   (com.matrixone.apps.program.FinancialTemplateCategory) DomainObject.newInstance(context, DomainConstants.TYPE_FINANCIAL_TEMPLATE_CATEGORY, "PROGRAM");

  String categoryId = emxGetParameter(request, "objectId");
  MapList financialTemplateList = new MapList();
  StringList busSelects = new StringList();
  String parentCategoryId = null;
  java.util.HashMap costCategoriesMap = new java.util.HashMap();
  java.util.HashMap costCategoriesMapID = new java.util.HashMap();
  try {
    //For Localized Values
    String languageStr = request.getHeader("Accept-Language");

    //Get the Cost Categories
    busSelects.add(financialTemplateCategory.SELECT_ID);
    busSelects.add(financialTemplateCategory.SELECT_NAME);
    financialTemplateList = financialTemplateCategory.getCostCategories(context, 1, busSelects, null);
    Iterator mainCategoryItr = financialTemplateList.iterator();
    while(mainCategoryItr.hasNext())
    {
      Map current =  (Map) mainCategoryItr.next();
      financialTemplateCategory.setId((String)current.get(financialTemplateCategory.SELECT_ID));
      Iterator subCategoryItr = financialTemplateCategory.getSubCategories(context,1,busSelects,null).iterator();
      StringList subCategoryList = new StringList();
      while(subCategoryItr.hasNext())
      {
        Map subCategoryMap = (Map) subCategoryItr.next();
        subCategoryList.add((String)subCategoryMap.get(financialTemplateCategory.SELECT_NAME));
      }
      costCategoriesMap.put((String)current.get(financialTemplateCategory.SELECT_NAME),subCategoryList);
      costCategoriesMapID.put((String)current.get(financialTemplateCategory.SELECT_NAME),(String)current.get(financialTemplateCategory.SELECT_ID));
    }
  } catch(Exception e) {
    // this catch section should only be reached when the projectId has not been set or provided
    financialTemplateList.clear();

%>
      tree.createRoot("<framework:i18n localize="i18nId">emxProgramCentral.Common.NoItemsToDisplay</framework:i18n>", "../common/images/iconSmallFinancial.gif", "none");
<%
  }

  if (financialTemplateList != null)
  {

%>
      tree.createRoot( "<framework:i18n localize="i18nId">emxProgramCentral.Common.CostItems</framework:i18n>", "../common/images/iconSmallFinancial.gif", "none");
<%

    Object[] costCategoryNames = costCategoriesMap.keySet().toArray();
    for(int i=0; i<costCategoryNames.length; i++)
    {
      String costCatName = (String)costCategoryNames[i];
      String costCatId  = (String)costCategoriesMapID.get(costCatName);
      
      StringBuffer categoryStr = new StringBuffer("emxProgramCentral.Common.").append(costCatName.replace(' ', '_'));               
%>
      
      objCurNode = tree.root.addChild("<framework:i18n localize="i18nId"><xss:encodeForHTML><%=categoryStr%></xss:encodeForHTML></framework:i18n>", "../common/images/iconSmallCostBudgetItem.gif", false, "", "checkbox", "<%=XSSUtil.encodeURLForServer(context,costCatName)%>");
<%

      StringList subCategories = (StringList)costCategoriesMap.get(costCatName);
      for(int j=0; j<subCategories.size(); j++)
      {
        String tempStr = (String)subCategories.get(j);
        //store the sub-category name and the category type such that 
        //there is no need for another call to the dB from the summary page
        //also for main categories do not append the category type so that
        //the sub-categories and main categorory can be distinguished 
        String value = tempStr + "|" + costCatName;
       
        StringBuffer subCategoryStr = new StringBuffer("emxProgramCentral.Common.").append(tempStr.replace(' ', '_'));      
%>
      objCurNode = tree.nodes["<framework:i18n localize="i18nId"><xss:encodeForHTML><%=categoryStr%></xss:encodeForHTML></framework:i18n>"];            
      
      objCurNode = objCurNode.addChild("<framework:i18n localize="i18nId"><xss:encodeForHTML><%=subCategoryStr%></xss:encodeForHTML></framework:i18n>","../common/images/iconSmallCostBudgetItem.gif", false, "", "checkbox", "<%=XSSUtil.encodeURLForServer(context,value)%>");
<%

      }
    }
  }
%>
      tree.draw();
    }
    // Stop hiding here -->//]]>
  </script>

</html>

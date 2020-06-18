<%--  emxProgramCentralBenefitItemSelectorProcess.jsp.jsp

  Sets the selected benefits items from the tree and passes the
  selected benefit names in the url

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralBenefitItemSelectorProcess.jsp.rca 1.10 Wed Oct 22 15:50:28 2008 przemek Experimental przemek $";
  2001/08/10 2:00 pm LN

  Reviewed for Level III compliance by AMM 5/7/2002
--%>

<%@include file = "./emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<jsp:useBean id="financialTemplateCategory" scope="page" class="com.matrixone.apps.program.FinancialTemplateCategory"/>

<%
 com.matrixone.apps.program.ProjectSpace project = (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE, "PROGRAM");
 //com.matrixone.apps.program.FinancialTemplateCategory financialTemplateCategory = (com.matrixone.apps.program.FinancialTemplateCategory) DomainObject.newInstance(context, DomainConstants.TYPE_FINANCIAL_TEMPLATE_CATEGORY, "PROGRAM");

  //Get parameters from url
  String objectId = emxGetParameter(request, "objectId");
  String[] selectedCategories = emxGetParameterValues(request, "checkbox");
  
  String  strBenefitNames = "";

  for(int i = 0; i < selectedCategories.length; i++) {
    if(selectedCategories[i].indexOf('|') == -1){ // this indicates that the item is a category, not a benefit item
                                                  // in which case you want to ensure that its items are added
      MapList financialTemplateList = new MapList();
      StringList busSelects = new StringList();
      String parentCategoryId = null;
      java.util.HashMap benefitCategoriesMap = new java.util.HashMap();
      java.util.HashMap benefitCategoriesMapID = new java.util.HashMap();
      //For Localized Values
      String languageStr = request.getHeader("Accept-Language");
      //Get the Benefit Categories
      busSelects.add(financialTemplateCategory.SELECT_ID);
      busSelects.add(financialTemplateCategory.SELECT_NAME);
      financialTemplateList = financialTemplateCategory.getBenefitCategories(context, 1, busSelects, null);
      Iterator mainCategoryItr = financialTemplateList.iterator();
      while(mainCategoryItr.hasNext())
      {
        Map current = (Map) mainCategoryItr.next();
        if(((String)current.get(financialTemplateCategory.SELECT_NAME)).equals(selectedCategories[i])){
          financialTemplateCategory.setId((String)current.get(financialTemplateCategory.SELECT_ID));
          Iterator subCategoryItr = financialTemplateCategory.getSubCategories(context,1,busSelects,null).iterator();
          StringList subCategoryList = new StringList();
          while(subCategoryItr.hasNext()){
            Map subCategoryMap = (Map) subCategoryItr.next();
            strBenefitNames+=(String)subCategoryMap.get(financialTemplateCategory.SELECT_NAME)+"|"+selectedCategories[i]+";";
          }
          // eliminate duplicate possibilities by incrementing to the next category or item
          int comparator = i;
          while(i<(selectedCategories.length-1) && selectedCategories[i+1].indexOf("|"+selectedCategories[comparator])!=-1 ){
            i++;
          }
          break; // end looping through categories once you've found the one you're looking for
        }
      }
    } else {
      strBenefitNames += selectedCategories[i] + ";";
    } // end else
  } // end for

  session.putValue("benefitNames", strBenefitNames);
%>
<html>
  <body class="white">
  <form name="finishAction" method="post">
  <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>  
    <script language="javascript" type="text/javaScript">//<![CDATA[
      <!-- hide JavaScript from non-JavaScript browsers
        var tempURL = parent.window.getWindowOpener().parent.document.location.href;
        if(tempURL.indexOf("emxProgramCentralBenefitItemCreateDialogFS.jsp")!=-1) {
          parent.window.getWindowOpener().parent.document.location ="emxProgramCentralBenefitItemCreateDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context,objectId)%>";
        }
        else { 
          parent.window.getWindowOpener().parent.document.location ="emxProgramCentralFinancialCreate3of3DialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context,objectId)%>";
        }
        parent.window.closeWindow();
      // Stop hiding here -->//]]>
    </script>
  </form>
</html>

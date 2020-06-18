<%-- emxProgramCentralFinancialCategoriesAddProcess.jsp

  Process page for adding cost and benefit categories to a financial

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = "$Id: emxProgramCentralFinancialCategoriesAddProcess.jsp.rca 1.9 Wed Oct 22 15:50:33 2008 przemek Experimental przemek $";

--%>

<%@include file = "./emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%@page import="com.matrixone.apps.domain.util.i18nNow"%>

<jsp:useBean id="financialItem"               scope="page" class="com.matrixone.apps.program.FinancialItem"/>
<jsp:useBean id="costItem"                    scope="page" class="com.matrixone.apps.program.CostItem"/>
<jsp:useBean id="benefitItem"                 scope="page" class="com.matrixone.apps.program.BenefitItem"/>

<%
//  com.matrixone.apps.program.FinancialItem financialItem =
//   (com.matrixone.apps.program.FinancialItem) DomainObject.newInstance(context, DomainConstants.TYPE_FINANCIAL_ITEM, "PROGRAM");
//  com.matrixone.apps.program.BenefitItem benefitItem =
//   (com.matrixone.apps.program.BenefitItem) DomainObject.newInstance(context, DomainConstants.TYPE_BENEFIT_ITEM, "PROGRAM");
//  com.matrixone.apps.program.CostItem costItem =
//   (com.matrixone.apps.program.CostItem) DomainObject.newInstance(context, DomainConstants.TYPE_COST_ITEM, "PROGRAM");

  // figure out if coming from benefit items page or cost items page
  String whereFrom = emxGetParameter(request,"whereFrom");

  // set financial item id
  String objectId = emxGetParameter(request,"objectId");
  financialItem.setId(objectId);

  // to make if statements easier to read
  boolean fromBenefit = whereFrom.equalsIgnoreCase("benefit");
  boolean fromCost    = whereFrom.equalsIgnoreCase("cost");

  // string to hold policy
  String policy = null;

  if(fromBenefit) {
    String[] benefitCatNames           = emxGetParameterValues(request,"benefitCatNames");
    String[] benefitCatLedgerNumbers   = emxGetParameterValues(request,"benefitCatLedgerNumbers");
    String[] benefitCatOptions         = emxGetParameterValues(request,"benefitCatOptions");
    String[] benefitCatPlannedBenefits = emxGetParameterValues(request,"benefitCatPlannedBenefits");

    try
    {
      policy = benefitItem.getDefaultPolicy(context, DomainObject.TYPE_BENEFIT_ITEM);
      if(benefitCatNames != null) {
        for ( int i=0; i<benefitCatNames.length; i++) {
          HashMap map = new HashMap();
          map.put(benefitItem.ATTRIBUTE_LEDGER_ACCOUNT_NUMBER, benefitCatLedgerNumbers[i].trim());
          String intervalValue = ProgramCentralUtil.convertDecimalForDBStorage((String)benefitCatPlannedBenefits[i].trim());
          if (benefitCatPlannedBenefits[i] != null && !benefitCatPlannedBenefits[i].equals("")) {
            //int totalPlannedBenefits = Integer.parseInt(benefitCatPlannedBenefits[i].trim());
            //int splitPlannedBenefits = Integer.parseInt(benefitCatPlannedBenefits[i].trim());
            if ((benefitCatOptions[i].trim()).equals("0")) {
              intervalValue = intervalValue + "|" + "Copy";
      } else {
              intervalValue = intervalValue + "|" + "Split";
            }
          }
          HashMap intervalMap = new HashMap();
          intervalMap.put("Planned", intervalValue);

          benefitItem.create(context, benefitCatNames[i], policy, financialItem, "", map, intervalMap);

          // commit the data
          ContextUtil.commitTransaction(context);

        }// end of for( int i=0; i<benefitCategories.length; i++)
      }
    }
    catch (Exception e)
    {
      ContextUtil.abortTransaction(context);
      // Do not see why the budget needs to be deleted.
      // financialItem.delete(context, true);
      throw e;
    }
  }
  else if(fromCost) {
    String[] costCatNames         = emxGetParameterValues(request,"costCatNames");
    String[] costCatLedgerNumbers = emxGetParameterValues(request,"costCatLedgerNumbers");
    String[] costCatOptions       = emxGetParameterValues(request,"costCatOptions");
    String[] costCatPlannedCosts  = emxGetParameterValues(request,"costCatPlannedCosts");

    try
    {
      policy = costItem.getDefaultPolicy(context, DomainObject.TYPE_COST_ITEM );
      if(costCatNames != null) {
        for ( int i=0; i<costCatNames.length; i++) {
          HashMap map = new HashMap();
          map.put(costItem.ATTRIBUTE_LEDGER_ACCOUNT_NUMBER, costCatLedgerNumbers[i].trim());
          String intervalValue = ProgramCentralUtil.convertDecimalForDBStorage((String)costCatPlannedCosts[i].trim());
          if (costCatPlannedCosts[i] != null && !costCatPlannedCosts[i].equals("")) {
//            double totalPlannedCosts = Double.parseDouble(costCatPlannedCosts[i].trim());
//            double splitPlannedCosts = Double.parseDouble(costCatPlannedCosts[i].trim());
            if ((costCatOptions[i].trim()).equals("0")) {
              intervalValue = intervalValue + "|" + "Copy";
            } else {
              intervalValue = intervalValue + "|" + "Split";
            }
          }
          HashMap intervalMap = new HashMap();
          intervalMap.put("Planned", intervalValue);

          costItem.create(context, costCatNames[i], policy, financialItem, "", map, intervalMap);

          // commit the data
          ContextUtil.commitTransaction(context);

        } // end of for( int i=0; i<costCategories.length; i++)
      }
    }
    catch (Exception e)
    {
      ContextUtil.abortTransaction(context);
      // Do not see why the budget needs to be deleted.
      // financialItem.delete(context, true);
      throw e;
    }
  }
  else { // no valid "whereFrom" parameter passed
    
	 
	  String languageStr = context.getSession().getLanguage();
	  String errMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
  			"emxProgramCentral.Financial.Categories.NoValidwhereFrom.errMsg", languageStr);
	  throw new IllegalArgumentException(errMsg);
	  //throw new IllegalArgumentException("DEBUG: No valid 'whereFrom' parameter passed!");
  }
%>

<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- // hide JavaScript from non-JavaScript browsers

    // parent.window.getWindowOpener().parent.document.focus();
    //parent.window.getWindowOpener().parent.document.location.reload();
	//Modified for Bug#340466 on 8/27/2007 - Start
	parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;
	//Modified for Bug#340466 on 8/27/2007 - End
    parent.window.closeWindow();

    // Stop hiding here -->//]]>
  </script>
</html>

<%--  emxProgramCentralFinancialCostItemDeleteProcess

  Deletes the Cost Categories in second page of Financial Create Dialog

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralFinancialCostItemDeleteProcess.jsp.rca 1.10 Wed Oct 22 15:49:46 2008 przemek Experimental przemek $";
--%>

<%@include file = "./emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  com.matrixone.apps.program.CostItem costItem =
   (com.matrixone.apps.program.CostItem) DomainObject.newInstance(context, CostItem.TYPE_COST_ITEM, DomainConstants.PROGRAM);

String objectId = emxGetParameter(request, "objectId");
java.util.HashMap createParams = (HashMap)session.getValue("CreateFinancialParameters");

try {
  String[] lines = emxGetParameterValues(request, "selectedIds");
  String[] ids = emxGetParameterValues(request, "costCatIds");
  String[] names = emxGetParameterValues(request, "costCatNames");
  String[] types = emxGetParameterValues(request, "costCatTypes");
  String[] ledgerNumbers = emxGetParameterValues(request, "costCatLedgerNumbers");
  String[] options = emxGetParameterValues(request, "costCatOptions");
  String[] plannedCosts = emxGetParameterValues(request, "costCatPlannedCosts");

  int itemNumber = ids.length - lines.length;

  if (itemNumber > 0) {

    String[] costCatNames = new String[itemNumber];
    String[] costCatTypes = new String[itemNumber];
    String[] costCatLedgerNumbers = new String[itemNumber];
    String[] costCatOptions = new String[itemNumber];
    String[] costCatPlannedCosts = new String[itemNumber];

    boolean remove = false;
    int current = 0;
    for (int i=0; i<ids.length; i++) {
      for (int j=0; j<lines.length; j++) {
        if (Integer.parseInt(lines[j])==i) {
          remove = true;
          break;
        }
      }
      if (remove) {
        remove = false;
      } else {
        costCatNames[current] = names[i];
        costCatTypes[current] = types[i];
        costCatLedgerNumbers[current] = ledgerNumbers[i];
        costCatOptions[current] = options[i];
        costCatPlannedCosts[current] = plannedCosts[i];
        current++;
      }
    }
    createParams.put("costCatNames", costCatNames);
    createParams.put("costCatTypes", costCatTypes);
    createParams.put("costCatLedgerNumbers", costCatLedgerNumbers);
    createParams.put("costCatOptions", costCatOptions);
    createParams.put("costCatPlannedCosts", costCatPlannedCosts);
  }
  else
  {
	createParams.remove("costCatNames");
	createParams.remove("costCatTypes");
	createParams.remove("costCatLedgerNumbers");
	createParams.remove("costCatOptions");
	createParams.remove("costCatPlannedCosts");
  }

  session.putValue("CreateFinancialParameters", createParams);

} catch (Exception e) {

}

%>


<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
	//Modified for Bug#340466 on 8/28/2007 - Start
    //parent.document.location.reload();
	parent.document.location.href = parent.document.location.href;
	//Modified for Bug#340466 on 8/28/2007 - End
    // Stop hiding here -->//]]>
  </script>
</html>



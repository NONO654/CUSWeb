<%--  emxProgramCentralFinancialBenefitItemDeleteProcess

  Deletes the Benefit Categories in third page of Financial Create Dialog

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralFinancialBenefitItemDeleteProcess.jsp.rca 1.10 Wed Oct 22 15:49:38 2008 przemek Experimental przemek $";
--%>

<%@include file = "./emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  com.matrixone.apps.program.BenefitItem benefitItem =
   (com.matrixone.apps.program.BenefitItem) DomainObject.newInstance(context, BenefitItem.TYPE_BENEFIT_ITEM, DomainConstants.PROGRAM);

String objectId = emxGetParameter(request, "objectId");
java.util.HashMap createParams = (HashMap)session.getValue("CreateFinancialParameters");

try {
  String[] lines = emxGetParameterValues(request, "selectedIds");
  String[] ids = emxGetParameterValues(request, "benefitCatIds");
  String[] names = emxGetParameterValues(request, "benefitCatNames");
  String[] types = emxGetParameterValues(request, "benefitCatTypes");
  String[] ledgerNumbers = emxGetParameterValues(request, "benefitCatLedgerNumbers");
  String[] options = emxGetParameterValues(request, "benefitCatOptions");
  String[] plannedBenefits = emxGetParameterValues(request, "benefitCatPlannedBenefits");

  int itemNumber = ids.length - lines.length;

  if (itemNumber > 0) {

    String[] benefitCatNames = new String[itemNumber];
    String[] benefitCatTypes = new String[itemNumber];
    String[] benefitCatLedgerNumbers = new String[itemNumber];
    String[] benefitCatOptions = new String[itemNumber];
    String[] benefitCatPlannedBenefits = new String[itemNumber];

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
        benefitCatNames[current] = names[i];
        benefitCatTypes[current] = types[i];
        benefitCatLedgerNumbers[current] = ledgerNumbers[i];
        benefitCatOptions[current] = options[i];
        benefitCatPlannedBenefits[current] = plannedBenefits[i];
        current++;
      }
    }
    createParams.put("benefitCatNames", benefitCatNames);
    createParams.put("benefitCatTypes", benefitCatTypes);
    createParams.put("benefitCatLedgerNumbers", benefitCatLedgerNumbers);
    createParams.put("benefitCatOptions", benefitCatOptions);
    createParams.put("benefitCatPlannedBenefits", benefitCatPlannedBenefits);
  }
  else
  {
	createParams.remove("benefitCatNames");
	createParams.remove("benefitCatTypes");
	createParams.remove("benefitCatLedgerNumbers");
	createParams.remove("benefitCatOptions");
	createParams.remove("benefitCatPlannedBenefits");
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

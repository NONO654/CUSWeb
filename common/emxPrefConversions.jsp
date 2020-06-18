<%--  emxPrefConversions.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefConversions.jsp.rca 1.12 Wed Oct 22 15:48:04 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<HTML>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
  <HEAD>
    <TITLE></TITLE>
    <META http-equiv="imagetoolbar" content="no" />
    <META http-equiv="pragma" content="no-cache" />
    <SCRIPT language="JavaScript" src="scripts/emxUIConstants.js"
    type="text/javascript">
    </SCRIPT>
    <script language="JavaScript" src="scripts/emxUICore.js"></script>
    <SCRIPT language="JavaScript" src="scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT type="text/javascript">
       addStyleSheet("emxUIDefault");
       addStyleSheet("emxUIForm");

       function doLoad() {
         if (document.forms[0].elements.length > 0) {
           var objElement = document.forms[0].elements[0];

           if (objElement.focus) objElement.focus();
           if (objElement.select) objElement.select();
         }
       }
    </SCRIPT>
  </HEAD>
  <BODY onload="doLoad(), turnOffProgress()">
    <FORM method="post" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose();" action="emxPrefConversionsProcessing.jsp">
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.Preferences.Currency</emxUtil:i18n>
          </TD>
          <TD class="inputField">
            <TABLE border="0">
<%
    try
    {
    ContextUtil.startTransaction(context, false);
    // Get Currency choices
    String asEntered = UINavigatorUtil.getI18nString("emxFramework.Preferences.Currency.As_Entered", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
    String attribute_Currency =PropertyUtil.getSchemaProperty(context, "attribute_Currency");
    AttributeType attributeCurrency = new AttributeType(attribute_Currency);
    StringList currencyChoices = new StringList();
                    try
                    {
                        attributeCurrency.open(context);
                        currencyChoices = attributeCurrency.getChoices();
                        }catch(Exception mx)
                        {}
    currencyChoices.insertElementAt("As Entered", 0);
    // Get Currency preference set for logged in user
    String currencyDefault = PersonUtil.getCurrency(context);
    if(currencyDefault==null || currencyDefault.trim().length()== 0)
    {
      currencyDefault="As Entered";
    }
    // for each currency choice
    for (int i = 0; i < currencyChoices.size(); i++)
    {
        // get choice
        String choice = (String)currencyChoices.get(i);

        // translate the choice
        String choicePropKey = "emxFramework.Range.Currency." + choice.replace(' ', '_');
        String choicePropValue = UINavigatorUtil.getI18nString(choicePropKey, "emxFrameworkStringResource", request.getHeader("Accept-Language"));

        // if translation not found then show choice.
        if (choicePropValue == null || choicePropValue.equals(choicePropKey))
        {
            choicePropValue = choice;
        }

%>
              <TR>
                <TD>
<%

        // if choice is equal to default then
        // mark it selected
        if (choice.equals(currencyDefault))
        {
%>
                  <INPUT type="radio" name="currency" id=
                  "currency" value="<%=XSSUtil.encodeForHTML(context, choice)%>" checked />
<%
        }
        else
        {
%>
                  <INPUT type="radio" name="currency" id=
                  "currency" value="<%=XSSUtil.encodeForHTML(context, choice)%>" />
<%
        }
%>
                  <!-- //XSSOK -->
                  &nbsp;<%=choicePropValue%>
                </TD>
              </TR>
<%
    }
%>
            </TABLE>
          </TD>
        </TR>
        <TR>
          <TD>
            &nbsp;
          </TD>
          <TD>
            &nbsp;
          </TD>
        </TR>
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.Preferences.UnitOfMeasure</emxUtil:i18n>
          </TD>
          <TD class="inputField">
            <TABLE border="0">
<%
    // Get Unit Of Measure choices
    String english = UINavigatorUtil.getI18nString("emxFramework.Preferences.UnitOfMeasure.English", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
    String metric = UINavigatorUtil.getI18nString("emxFramework.Preferences.UnitOfMeasure.Metric", "emxFrameworkStringResource", request.getHeader("Accept-Language"));

    // Get UOM preference set for logged in user
    String unitOfMeasureDefault = PersonUtil.getUnitOfMeasure(context);
    if(unitOfMeasureDefault==null || unitOfMeasureDefault.trim().length()== 0)
    {
        unitOfMeasureDefault="As Entered";
    }

    String strChecked = "";

    if (unitOfMeasureDefault.equals("As Entered"))
    {
        strChecked = "checked";
    }

%>
<TR>
    <!-- //XSSOK -->
    <TD><INPUT type="radio" name="unitOfMeasure" id="unitOfMeasure" value="As Entered" <%=strChecked%> />&nbsp;<%=asEntered%></TD>
</TR>

<%
    strChecked = "";
    if (unitOfMeasureDefault.equals("English"))
    {
        strChecked = "checked";
    }
%>

<TR>
    <!-- //XSSOK -->
    <TD><INPUT type="radio" name="unitOfMeasure" id="unitOfMeasure" value="English" <%=strChecked%> />&nbsp;<%=english%></TD>
</TR>

<%
    strChecked = "";
    if (unitOfMeasureDefault.equals("Metric"))
    {
        strChecked = "checked";
    }
%>

<TR>
    <!-- //XSSOK -->
    <TD><INPUT type="radio" name="unitOfMeasure" id="unitOfMeasure" value="Metric" <%=strChecked%> />&nbsp;<%=metric%></TD>
</TR>

<%
    }
    catch (Exception ex)
    {
        ContextUtil.abortTransaction(context);

        if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        {
            emxNavErrorObject.addMessage("emxPrefConversions:" + ex.toString().trim());
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }
%>
            </TABLE>
          </TD>
        </TR>
      </TABLE>
    </FORM>
  </BODY>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</HTML>



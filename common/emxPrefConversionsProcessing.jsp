<%--  emxPrefConversionsProcessing.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxPrefConversionsProcessing.jsp.rca 1.7 Wed Oct 22 15:48:39 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<HTML>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    // Get Currency
    String currency = emxGetParameter(request, "currency");

    // Get Unit Of Measure
    String unitOfMeasure = emxGetParameter(request, "unitOfMeasure");

    try
    {
        // Set conversion values.
        ContextUtil.startTransaction(context, true);

        if (currency != null)
        {
            PersonUtil.setCurrency(context, currency);
        }
        if (unitOfMeasure != null)
        {
            PersonUtil.setUnitOfMeasure(context, unitOfMeasure);
        }
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

    if ("As Entered".equals(currency)) {
      CurrencyConversion.removeCurrency(session);
    } else {
      CurrencyConversion.setCurrency(session, currency);
    }

    if ("As Entered".equals(unitOfMeasure)) {
      UnitConversion.removeUnitSystem(session);
    } else  {
      UnitConversion.setUnitSystem(session, unitOfMeasure);
    }
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>



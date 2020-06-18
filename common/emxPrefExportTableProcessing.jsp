<%--  emxPrefExportTable.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxPrefExportTableProcessing.jsp.rca 1.6 Wed Oct 22 15:48:20 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    // check if change has been submitted or just refresh mode
    // Get Format
    String exportFormat = emxGetParameter(request, "format");
    
    // if change has been submitted then process the change
    if (exportFormat != null)
    {
        try
        {
            ContextUtil.startTransaction(context, true);
            
            //this string comes from emxFramework.Preferences.ExportFormat.Choices
            String stringToCompare = "Text";
            String stringToCompareCSV = "CSV";
            
            if (exportFormat.equals(stringToCompare) || exportFormat.equals(stringToCompareCSV))
            {
                // Get record separator
                String recordSeparator = emxGetParameter(request, "recordSeparator");
                PersonUtil.setRecordSeparator(context, recordSeparator);

                // Get field separator
                String fieldSeparator = emxGetParameter(request, "fieldSeparator");
                PersonUtil.setFieldSeparator(context, fieldSeparator);

                // Get Remove Carriage Returns
                String removeCarriageReturns = emxGetParameter(request, "removeCarriageReturns");
                PersonUtil.setRemoveCarriageReturns(context, removeCarriageReturns);
            }

            PersonUtil.setExportFormat(context, exportFormat);
        }
        catch (Exception ex) {
            ContextUtil.abortTransaction(context);

            if(ex.toString()!=null && (ex.toString().trim()).length()>0)
            {
                emxNavErrorObject.addMessage("emxPrefExportTable:" + ex.toString().trim());
            }
        }
        finally
        {
            ContextUtil.commitTransaction(context);
        }
    }
%>


<%@include file = "emxNavigatorBottomErrorInclude.inc"%>


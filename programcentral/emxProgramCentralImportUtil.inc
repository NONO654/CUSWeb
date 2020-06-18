<%--
  emxProgramCentralImportUtil.inc

  Preprocess form for importing a project.
  The ProgramCentralUtil bean contains static methods that handle the parsing of the csv
  input file and the type specific validation for each import.  If new types are added to the
  import a type specific validation will need to be written for each.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralImportUtil.inc.rca 1.27 Tue Oct 28 22:59:43 2008 przemek Experimental przemek $"
--%>

    <%--
     * Load the contents of a csv file into a MapList.  Once the file is loaded
     * into a MapList a type specific validator is called to validate the data.
     *
     * @param fileContents the imported Financial item, Cost and Benefit items
     * @param language used to internationalize the error messages
     * @param context the eMatrix <code>Context</code> object
     * @return MapList containing the validated data
     * @since AEF 9.5.4.1
     * @deprecated since V6R2014x
     * @grade 0
     * --%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.program.ImportUtil"%>
<%!
    static public MapList loadAndValidateImport(java.io.File inputFile,
                                                String importType,
                                                String language,
                                                Context context)
                                                throws MatrixException
    {
	return ImportUtil.loadAndValidateImport(inputFile,importType,language, context);
    }
%>

    <%--
     * Load the contents of a csv file into a MapList.  This is a finite state
     * parser that ignores commas between double quotes.  This was necessary
     * because a string tokenizer would see the comma as a delimiter causing
     * an error during the validation.  Once the file is loaded into a MapList
     * it calls a type specific validator to validate the data.
     *
     * @param fileContents the imported Financial item, Cost and Benefit items
     * @param language used to internationalize the error messages
     * @param context the eMatrix <code>Context</code> object
     * @return MapList containing the validated data
     * @since AEF 9.5.4.1
     * @deprecated since V6R2014x
     * @grade 0
     * --%>
<%!
    static public MapList loadImport(java.io.File inputFile,
                                     String importType,
                                     String language,
                                     Context context) throws MatrixException
    {
	return loadImport(inputFile,importType,language, context);
    }
%>

    <%--
     * Validate the contents of a ascii financial import.
     *
     * @param fileContents the imported Financial item, Cost and Benefit items
     * @param language used to internationalize the error messages
     * @param context the eMatrix <code>Context</code> object
     * @return MapList containing the validated data
     * @since AEF 9.5.4.1
     * @deprecated since V6R2014x
     * @grade 0
     * --%>
<%!
    static public MapList financialValidator(MapList fileContents,
                                             String language,
                                             Context context)
                                             throws MatrixException
    {
	return financialValidator(fileContents, language, context);
    }
%>

    <%--/**
     * Validate the contents of a ascii Risk import.
     *
     * @param fileContents the imported Risk and RPN items
     * @param language used to internationalize the error messages
     * @param context the eMatrix <code>Context</code> object
     * @return MapList containing the validated data
     * @since AEF 9.5.4.1
     * @deprecated since V6R2014x
     * @grade 0
     */--%>
<%!
      static public MapList riskValidator(MapList fileContents,
                                          String language,
                                          Context context)
                                          throws MatrixException
    {
	return ImportUtil.riskValidator(fileContents, language, context);
    }
%>

<%--/**
     * get range of string values as a StringList from an attibute name
     * default from language en-us
     *
     * param context the eMatrix <code>Context</code> object
     * param attributeName the attribute name to get range values     *
     * return StringList containing range values
     *
     */--%>

<%!

    static public StringList getAttrRangeList(Context context, String attributeName)
       throws MatrixException
    {
	return ImportUtil.getAttrRangeList(context, attributeName);
    }

%>

    <%--/**
     * Validate the contents of a ascii Quality import.
     *
     * @param fileContents the imported Quality, Discrete and Continuous Metrics
     * @param language used to internationalize the error messages
     * @param context the eMatrix <code>Context</code> object
     * @return MapList containing the validated data
     * @since AEF 9.5.4.1
     * @deprecated since V6R2014x
     * @grade 0
     */--%>
<%!
    static public MapList qualityValidator(MapList fileContents,
                                           String language,
                                           Context context)
                                           throws MatrixException
    {
	return ImportUtil.qualityValidator( fileContents, language, context);
    }
%>

    <%--/**
     * Test field to verify it is an integer
     *
     * @param value The value of the field to be validated
     * @param context the eMatrix <code>Context</code> object
     * @return true if busObj is the first revision
     * @since AEF 9.5.4.1
     * @deprecated since V6R2014x
     * @grade 0
     */--%>
<%!
    static public boolean intValidator(String value,
                                       Context context)
                                       throws MatrixException
    {
	return ImportUtil.intValidator(value, context);
    }
%>

    <%--/**
     * Test field to verify it is an real
     *
     * @param value The value of the field to be validated
     * @param context the eMatrix <code>Context</code> object
     * @return true if busObj is the first revision
     * @since AEF 9.5.4.1
     * @deprecated since V6R2014x
     * @grade 0
     */--%>
<%!
    static public boolean realValidator(String value,
                                        Context context)
                                        throws MatrixException
    {
	return ImportUtil.realValidator(value, context);
    }
%>

    <%--/**
     * Test date to verify it is valid for the given format and converts it
     * to a valid Matrix date.
     *
     * @param format the format the date should be validated against
     * @param date the date to be validated
     * @param language Used to internationalize the string part of the date
     * @param context the eMatrix <code>Context</code> object
     * @return true if busObj is the first revision
     * @since AEF 9.5.4.1
     * @deprecated since V6R2014x
     * @grade 0
     */--%>
<%!
    static public String dateValidator(String format,
                                       String date,
                                       String language,
                                       Context context)
                                       throws MatrixException
    {
	return ImportUtil.dateValidator(format,date,language, context);
    }
%>

    <%--/**
     * Load the list of attributes to be used for the import of the specified
     * type.
     *
     * @param typeStr the type to be imported
     * @param language Used to internationalize the strings
     * @param context the eMatrix <code>Context</code> object
     * @return true if busObj is the first revision
     * @since AEF 9.5.4.1
     * @deprecated since V6R2014x
     * @grade 0
     */--%>
<%!
    static public StringList loadHeaderList(String typeStr,
                                            String language,
                                            Context context)
                                            throws MatrixException
    {
	return loadHeaderList(typeStr,language,context);
    }
%>

    <%--/**
     * Translate the header list into it's internationalized representation
     * for display as the header on the summary page
     *
     * @param headerList the list of attributes to be displayed in the header
     * @param language Used to internationalize the strings
     * @param context the eMatrix <code>Context</code> object
     * @return stringlist with internationalized values
     * @since AEF 9.5.4.1
     * @deprecated since V6R2014x
     * @grade 0
     */--%>
<%!
    static public StringList translateHeaderList(String entryType,
                                                 StringList headerList,
                                                 Locale local,
                                                 String language,
                                                 Context context)
                                                 throws MatrixException
    {
	return ImportUtil.translateHeaderList(entryType, headerList,local,language, context);
    }

%>

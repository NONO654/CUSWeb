<%--  emxProgramCentralFinancialUtil.inc

  Contains Utility methods for interval Headers.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved. 

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  Reviewed for Level III compliance by KIP 5/15/2002

  static const char RCSID[] = "$Id: emxProgramCentralFinancialUtil.inc.rca 1.11 Wed Oct 22 15:49:28 2008 przemek Experimental przemek $"
--%>

<%@ page import="com.matrixone.apps.domain.util.eMatrixDateFormat, java.util.Locale, java.util.Calendar" %>
<%@ page import="java.text.ParseException, java.util.GregorianCalendar, java.text.SimpleDateFormat" %>

<%!
    /**
     * Method which returns the Monthly Table Header String for the given date
     * in the format "dd/mm/yyyy"
     */
    private String getMonthlyHeader(String strDate, String languageStr) throws Exception
    {
        String result=null;
        try
        {
            Calendar cal = new GregorianCalendar();
            SimpleDateFormat formatter = new SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
            cal.setTime(formatter.parse(strDate));
            String i18nMonth = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", 
			  "emxProgramCentral.Common."+getMonthName(cal.get(Calendar.MONTH)), languageStr);
            if(languageStr.indexOf("ja")!= 0)
            {
              result = i18nMonth + "'" + cal.get(Calendar.YEAR);
            }
            else
            {
              String seperator = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", 
			  "emxProgramCentral.Common.DateSeperator", languageStr);
              result =  cal.get(Calendar.YEAR)+ seperator +i18nMonth;
            }
   
        }
        catch (ParseException pe)
        {
            result = "Wrong Date String";
        }
        return result;
    }

    /**
     * Method which returns the Quaterly Table Header String for the given date
     * in the format "dd/mm/yyyy"
     */
    private String getQuaterlyHeader(String strDate, String languageStr) throws Exception
    {
        String result=null;
        try
        {
            String seperator = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", 
			  "emxProgramCentral.Common.DateSeperator", languageStr);

            Calendar cal = new GregorianCalendar();
            SimpleDateFormat formatter = new SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
            cal.setTime(formatter.parse(strDate));
            String i18nMonth = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", 
            "emxProgramCentral.Common."+getMonthName(cal.get(Calendar.MONTH)), languageStr);
            if(languageStr.indexOf("ja")!=0){            
              result = i18nMonth + "'" + cal.get(Calendar.YEAR);
             }
             else{
              result =  cal.get(Calendar.YEAR)+ seperator +i18nMonth;
             }
             
            cal.set(Calendar.MONTH,cal.get(Calendar.MONTH)+2);
            i18nMonth = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", 
			  "emxProgramCentral.Common.Functionality.errMsg", languageStr);
            if(languageStr.indexOf("ja")!=0){            
              result = result + " - " + cal.get(Calendar.YEAR) + "'" + i18nMonth; 
            }
            else
            {
              result = result + " - " + cal.get(Calendar.YEAR)+ seperator +i18nMonth;
            }
        }
        catch (ParseException pe)
        {
            result = "Wrong Date String";
        }

        return result;
    }

    /**
     * Method which returns the Weekly Table Header String for the given date
     * in the format "dd/mm/yyyy"
     */
    private String getWeeklyHeader(String strDate)
    {
        String result=null;
        try
        {
            Calendar cal = new GregorianCalendar();
            SimpleDateFormat formatter = new SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
            cal.setTime(formatter.parse(strDate));
            result = formatter.format(cal.getTime());
        }
        catch (ParseException pe)
        {
            result = "Wrong Date String";
        }
        return result;
    }

    /**
     * Method which returns the Table Header String for the given date
     * in the format "dd/mm/yyyy" and the Interval.
     */
    private String getHeader(String strDate, String strInterval, String languageStr) throws Exception
    {
        String result=null;
        if(strInterval.equals("Monthly"))
        {
            result = getMonthlyHeader(strDate, languageStr);
        }
        else if(strInterval.equals("Quarterly"))
        {
            result = getQuaterlyHeader(strDate,languageStr);
        }
        else if(strInterval.equals("Weekly"))
        {
            result = getWeeklyHeader(strDate);
        }
        else
        {
            result = "Wrong Interval Name";
        }
        return result;
    }

    /**
    * To get the name on the month what you give
    *   @param String month in numeric data
    * @return Strnig --> Name of the month
    */
    public String getMonthName(int month)
    {
        String str_Month="";
        switch (month)
        {
            case 0:  str_Month="Jan";break;
            case 1:  str_Month="Feb";break;
            case 2:  str_Month="Mar";break;
            case 3:  str_Month="Apr";break;
            case 4:  str_Month="May";break;
            case 5:  str_Month="Jun";break;
            case 6:  str_Month="Jul";break;
            case 7:  str_Month="Aug";break;
            case 8:  str_Month="Sep";break;
            case 9:  str_Month="Oct";break;
            case 10: str_Month="Nov";break;
            case 11: str_Month="Dec";break;
        }
        return str_Month;
    }

    /**
     * This method returns the current year.
     * return int current Year.
     */
    private int getCurrentYear()
    {
        return Calendar.getInstance().get(Calendar.YEAR);
    }

    /**
    * Returns true if the aDate is less than the current date.
    *   @param String month in numeric data
    * @return boolean --> Name of the month
    */
    public boolean isPreviousInterval(String strInterval, String aDate)
    {
        Calendar cal = new GregorianCalendar();

        SimpleDateFormat formatter = new SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);

        long currentTimeMillis = System.currentTimeMillis();

        try
        {
            cal.setTime(formatter.parse(aDate));

            if(strInterval.equals("Monthly"))
            {
                cal.add(Calendar.MONTH, 1);
            }
            else if(strInterval.equals("Quarterly"))
            {
                cal.add(Calendar.MONTH, 3);
            }
            else if(strInterval.equals("Weekly"))
            {
                cal.add(Calendar.DATE, 7);
            }
        }
        catch(java.text.ParseException e)
        {
          return false;
        }

        return (currentTimeMillis > (cal.getTime().getTime()));
    }


    /**
    * Returns a StringList which contains intenationalized String objects.
    *   @param String contains the Attrribute string.
    *   @param StringList contains Strings to be internationlized
    *   @param String contains the language header.
    * @return StringList --> internationlized string list
    */

    public StringList getRangeI18nStringList(String attrString, StringList list, String languageStr)
    {
      StringList returnList = null;

      try
      {
          int size = list.size();

          returnList = new StringList(size);

          for(int i=0; i<size; i++)
          {
            String rangeString = (String)list.get(i);
                   rangeString = i18nNow.getRangeI18NString(attrString, rangeString, languageStr);
                returnList.add(rangeString);
          }
      }
      catch(Exception e)
      {
      }
      return returnList;
    }


%>

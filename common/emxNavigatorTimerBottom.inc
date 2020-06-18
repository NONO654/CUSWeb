<%--
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%

if (emxTimerLogFile != null && emxTimerLogFile.trim().length() > 0)
{
    String pageURL = request.getRequestURI();
    StringBuffer logBufferStr = new StringBuffer();

    String userName = PersonUtil.getFullName(context);
    Date currDate = (Calendar.getInstance()).getTime();

    String emxPageID = emxGetParameter(request, "timeStamp");

    if (pageURL != null && pageURL.indexOf("common/emxTable.jsp") >= 0)
    {
        logBufferStr.append("\r\n\r\n" + "#######################################################");
        logBufferStr.append("\r\n" + currDate + " - Page URL : " + pageURL);

        logBufferStr.append("\r\nPage ID \t: " + emxPageID);

        logBufferStr.append("\r\nUser Name \t: " + userName);
        logBufferStr.append("\r\nTable Name \t: " + emxGetParameter(request, "table"));

        String tInquiryList = emxGetParameter(request, "inquiry");
        String tProgramLst = emxGetParameter(request, "program");
        String tSelectedFilter = emxGetParameter(request, "selectedFilter");

        // Get the list of enquiries and label
        if (tInquiryList != null && tInquiryList.trim().length() > 0 )
        {
            String tInquiry = "";
            if (tInquiryList.indexOf(",") > 0 )
                tInquiry = tInquiryList.substring(0, tInquiryList.indexOf(","));
            else
                tInquiry = tInquiryList;

            // If the "selectedFilter" is passed in use that value
            if (tSelectedFilter != null && tSelectedFilter.length() > 0)
                tInquiry = tSelectedFilter;

            logBufferStr.append("\r\nInquiry \t: " + tInquiry );

        } else if (tProgramLst != null && tProgramLst.length() > 0 ) {

            String tProgramParam = "";

            if (tProgramLst.indexOf(",") > 0 )
                tProgramParam = tProgramLst.substring(0, tProgramLst.indexOf(","));
            else
                tProgramParam = tProgramLst;

            // If the "selectedProgram" is passed in, use that value
            if (tSelectedFilter != null && tSelectedFilter.length() > 0)
                tProgramParam = tSelectedFilter;

            logBufferStr.append("\r\nJPO Name \t: " + tProgramParam );
        }

        logBufferStr.append("\r\nTime \t\t: " + (System.currentTimeMillis() - emxTimerStart) + " (in Milli Seconds)");
        logBufferStr.append("\r\n--------------------------------------------------------");

    } else {
        logBufferStr.append("\r\n--------------------------------------------------------");
        logBufferStr.append("\r\n" + currDate + " - Page URL : " + pageURL );

        String tPageID = emxGetParameter(request, "timeStamp");

        if (emxPageID != null)
        {
            logBufferStr.append("\r\nPage ID \t: " + emxPageID);
        }
        logBufferStr.append("\r\nUser Name \t: " + userName);
        logBufferStr.append("\r\nTime \t\t: " + (System.currentTimeMillis() - emxTimerStart) + " (in Milli Seconds)");
        logBufferStr.append("\r\n--------------------------------------------------------");
    }

	// Dump the log string to the file
    java.io.PrintStream writer = null;
    try {
        writer = new java.io.PrintStream(new FileOutputStream(emxTimerLogFile, true));
    } catch (Exception ex) {
    	writer = System.out;
    } finally {
    	writer.println(logBufferStr.toString());
    	writer.close();
    }
    
}

%>

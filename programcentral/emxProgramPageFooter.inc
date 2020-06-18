<%--
  emxProgramPageFooter.inc

  Bottom Include File for all jsp pages in Program Central Suite

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramPageFooter.inc.rca 1.8 Wed Oct 22 15:49:40 2008 przemek Experimental przemek $"
--%>

<%
  long currentTime = System.currentTimeMillis();

/*
  System.out.println("Time For " + request.getRequestURI() + " := " +
          (emxProgramTimerHtmlStartTime - emxProgramTimerJavaStartTime) + ", " +
          (currentTime - emxProgramTimerHtmlStartTime) + ", " +
          (currentTime - emxProgramTimerJavaStartTime));
*/

  int total = out.getBufferSize();
  int available = out.getRemaining();
  int used = total - available;

/*
  System.out.print("Buffer Status: ");
  System.out.print(Integer.toString(used));
  System.out.print('/');
  System.out.print(Integer.toString(total));
  System.out.print(" = ");
*/

  java.text.NumberFormat percentFmt = java.text.NumberFormat.getInstance();
  percentFmt.setMinimumFractionDigits(1);
  percentFmt.setMaximumFractionDigits(3);

/*
  System.out.print(percentFmt.format((100D * used)/total));
  System.out.println("%");
*/

try
{
  if (context.isTransactionActive()) {
    context.abort();
    //System.out.println("******** Transaction Not Closed *********");
    throw new Exception("Transaction was not closed.  Please report to system administrator.");
  }
  }
  catch(Exception exp){
	 exp.printStackTrace();
         throw new MatrixException(exp);
  }
%>


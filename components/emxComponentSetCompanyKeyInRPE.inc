<%--  emxComponentSetCompanyKeyInRPE.inc  -- set company key in rpe

    Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: emxComponentSetCompanyKeyInRPE.inc.rca 1.5 Wed Oct 22 16:18:08 2008 przemek Experimental przemek $
--%>

<%
  // Getting Company Key from session
  String companyKey = (String)session.getAttribute(Person.RPE_COMPANY_KEY);

  // Check Company key is null then get comapny key from admin person
  // and set in session for fututre
  if ( comapnyKey == null )
  {
      companyKey = Person.getComapnyKey(context);
      session.setAttribute(Person.RPE_COMPANY_KEY, companyKey);
  }

  // setting Comapny key as RPE value for triggers
  PropertyUtil.setGlobalRPEValue(context, Person.RPE_COMPANY_KEY, companyKey);
%>

<%-- emxLibraryCentralClassifiedItemsSearch.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLibraryCentralClassifiedItemsSearch.jsp.rca 1.7 Wed Oct 22 16:02:33 2008 przemek Experimental przemek $
--%>

<html>
<head>
<title>Search</title>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<script type="text/javascript" language="javascript" src="../common/scripts/emxUICalendar.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIPopups.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICalendar.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxSearchGeneral.js"></script>
<script language = "javascript" type = "text/javascript" src = "../documentcentral/emxDocumentUtilities.js"></script>
</head>
<body onload="doLoad(), turnOffProgress(), getTopWindow().loadSearchFormFields()">
<form name="SearchForm" method="post" id="SearchForm" onSubmit="doSubmit(); return false">

<%@include file = "../documentcentral/emxLibraryCentralClassifiedItemsSearchBasicAttributes.inc"%>

<%@include file = "../documentcentral/emxLibraryCentralClassifiedItemsSearchTypeAtttributes.inc"%>

</form> 
</body>
</html>

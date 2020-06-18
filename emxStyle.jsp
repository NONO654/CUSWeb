<%--  emxStyle.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxStyle.jsp.rca 1.8 Wed Oct 22 16:10:05 2008 przemek Experimental przemek $
--%>

<style type="text/css">

<%--   Begin Error Styles  --%>

TABLE.error {	BACKGROUND-COLOR: #f00}
TH.error {	FONT-WEIGHT: bold; FONT-SIZE: 13px; COLOR: #fff; BACKGROUND-COLOR: #f00; TEXT-ALIGN: left}
TD.errMsg {	FONT-WEIGHT: bold; FONT-SIZE: 11px; COLOR: #f00; BACKGROUND-COLOR: #eee}

<%--   End Error Styles  --%>

		body.background {
            background-position: 100% 0px; 
            overflow: auto;
        }

        td.dialog {
            text-align: center;
            vertical-align: middle;
        }
        
        div.dialogBackground {
            height: 500px; 
            background-image: url(common/images/loginChangePasswordScreen.jpg); 
            background-position: 50% 50%; /*ngui - login layout*/
            background-repeat: no-repeat;
        }
        
        div.inputFields {
            width: 538px; 
            text-align: left; 
            padding-top: 85px; 
            padding-left: 60px; /*ngui - login layout*/
            padding-top: 140px; /*ngui - login layout*/
            margin-left: auto;
            margin-right: auto;
        }
        
        .label {
            font: 12px verdana; 
            line-height: 18px;
        }
        
        .button {
            font: 12px verdana;
            padding: 0px 12px 0px 12px;
        }

</style>

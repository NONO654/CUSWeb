<%--
  emxProgramCentralDashboardsUtil.inc

  Utility page for Dashboard pages.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralDashboardsUtil.inc.rca 1.18 Wed Oct 22 15:49:30 2008 przemek Experimental przemek $"
--%>

<%@ page import ="java.awt.Font,java.awt.GraphicsEnvironment" %>
<%@ page import = "javachart.utility.*, javachart.chart.*, java.awt.*, java.awt.Frame, java.awt.Image, java.awt.Graphics" autoFlush="true" %>

<%!

 //Get the Threshold Values from the properties file
 public int[] getThresholdValues(Context ctx) throws MatrixException
 {
   int slipValue1=0;
   int slipValue2=0;
   int riskValue1=0;
   int riskValue2=0;
   int costratioValue1=100;
   int costratioValue2=110;
   String proName ="emxProgramCentral";
   String ascendText1 ="eServiceApplicationProgramCentral.SlipThresholdGreenYellow";
   String ascendText2 ="eServiceApplicationProgramCentral.SlipThresholdYellowRed";
   String ascendText3 ="eServiceApplicationProgramCentralRPNThreshold.Yellow";
   String ascendText4 ="eServiceApplicationProgramCentralRPNThreshold.Red";
   String ascendText5 ="eServiceApplicationProgramCentral.CostRatioThresholdGreenYellow";
   String ascendText6 ="eServiceApplicationProgramCentral.CostRatioThresholdYellowRed";

   String s=ctx.getLocale().getLanguage();
   String s1 = EnoviaResourceBundle.getProperty(ctx, ascendText1);
   s1=s1.trim();
   slipValue1 = Integer.parseInt(s1);
   String s2 = EnoviaResourceBundle.getProperty(ctx, ascendText2);
   s2=s2.trim();
   slipValue2 = Integer.parseInt(s2);
   String s5 = EnoviaResourceBundle.getProperty(ctx, ascendText5);
   if ( s5 != null )
   {
     s5=s5.trim();
     costratioValue1 = Integer.parseInt(s5);
   }
   String s6 = EnoviaResourceBundle.getProperty(ctx, ascendText6);
   if ( s6 != null )
   {
   s6=s6.trim();
     costratioValue2 = Integer.parseInt(s6);
  }

     String s3 = EnoviaResourceBundle.getProperty(ctx, ascendText3);
     s3=s3.trim();
     riskValue1 = Integer.parseInt(s3);
     String s4 = EnoviaResourceBundle.getProperty(ctx, ascendText4);
     s4=s4.trim();
     riskValue2 = Integer.parseInt(s4);

   int values[]={slipValue1,slipValue2,riskValue1,riskValue2,costratioValue1,costratioValue2};
  return values;
 }

 //Get the Color Code Values from the properties file
 public String[] getColorCodeValues(Context ctx) throws MatrixException
 {
   String slipColor1="008000";
   String slipColor2="FFCC00";
   String slipColor3="FF0000";
   String riskColor1="008000";
   String riskColor2="FFCC00";
   String riskColor3="FF0000";
   String costRatioColor1="008000";
   String costRatioColor2="FFCC00";
   String costRatioColor3="FF0000";
   String proName ="emxProgramCentral";
   String ascendText1 ="eServiceApplicationProgramCentral.SlipThreshholdColor1";
   String ascendText2 ="eServiceApplicationProgramCentral.SlipThreshholdColor2";
   String ascendText3 ="eServiceApplicationProgramCentral.SlipThreshholdColor3";
   String ascendText4 ="eServiceApplicationProgramCentral.RiskThreshholdColor1";
   String ascendText5 ="eServiceApplicationProgramCentral.RiskThreshholdColor2";
   String ascendText6 ="eServiceApplicationProgramCentral.RiskThreshholdColor3";
   String ascendText7 ="eServiceApplicationProgramCentral.CostRatioThreshholdColor1";
   String ascendText8 ="eServiceApplicationProgramCentral.CostRatioThreshholdColor2";
   String ascendText9 ="eServiceApplicationProgramCentral.CostRatioThreshholdColor3";

   String s=ctx.getLocale().getLanguage();
   String s1 = EnoviaResourceBundle.getProperty(ctx, ascendText1);
   slipColor1=s1.trim();
   String s2 = EnoviaResourceBundle.getProperty(ctx, ascendText2);
   slipColor2=s2.trim();
   String s3 = EnoviaResourceBundle.getProperty(ctx, ascendText3);
   slipColor3=s3.trim();
   String s4 = EnoviaResourceBundle.getProperty(ctx, ascendText4);
   riskColor1=s4.trim();
   String s5 = EnoviaResourceBundle.getProperty(ctx, ascendText5);
   riskColor2=s5.trim();
   String s6 = EnoviaResourceBundle.getProperty(ctx, ascendText6);
   riskColor3=s6.trim();
   String s7 = EnoviaResourceBundle.getProperty(ctx, ascendText7);
   costRatioColor1=s7.trim();
   String s8 = EnoviaResourceBundle.getProperty(ctx, ascendText8);
   costRatioColor2=s8.trim();
   String s9 = EnoviaResourceBundle.getProperty(ctx, ascendText9);
   costRatioColor3=s9.trim();
   String values[]={slipColor1,slipColor2,slipColor3,riskColor1,riskColor2,riskColor3,costRatioColor1,costRatioColor2,costRatioColor3};

   return values;
  }

 //Get the Threshold Values from the properties file
 public int[] getThresholdValues(HttpServletRequest request) throws Exception
 {
	try {
		return (int[])ContextUtil.runInAnonymousContext(new ContextUtil.Callable() {
			public Object call(Context ctx) throws MatrixException{
					return getThresholdValues(ctx);
			}
		});
	} catch(MatrixException mex) { 
		throw mex; 
	} catch(Exception ex) { throw new Exception(ex); }
 }

 //Get the Color Code Values from the properties file
 public String[] getColorCodeValues(HttpServletRequest request) throws Exception
 {
	try {
	return (String[])ContextUtil.runInAnonymousContext(new ContextUtil.Callable() {
			public Object call(Context ctx) throws MatrixException{
					return getColorCodeValues(ctx);
			}
		});
	} catch(MatrixException mex) { 
		throw mex; 
	} catch(Exception ex) { throw new Exception(ex); }
 }

 public boolean isKavaChart(HttpServletRequest request) throws Exception
  {
    boolean kava =true;
    String StrName ="emxProgramCentral";
    String s=request.getHeader("Accept-Language");
    String ascendText ="eServiceProgramCentral.KavaChart";
    String s1 = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral",ascendText, s);
    if((s1.trim()).equals("TRUE"))
    {
      kava=true;
    } else {
      kava=false;
    }
   return kava;
  }

  static public final int MX_KC_TITLE  = 1;
  static public final int MX_KC_LABEL  = 2;
  static public final int MX_KC_LEGEND = 3;


  public String getKavaChartFontName(HttpServletRequest request, int label) throws Exception
  {
    String kavaFontName = "Arial";  // Arial is default for Java (Logical Font.)
    String StrName = "emxProgramCentral";   
    String strAcceptLang  = request.getHeader("Accept-Language");
	StringList slAcceptLang = FrameworkUtil.split(strAcceptLang, ",");
	String strAcceptLang1 = (String)slAcceptLang.get(0);
	StringList slParseAcceptLang = FrameworkUtil.split(strAcceptLang1, "-");
	strAcceptLang1 = (String)slParseAcceptLang.get(0);
	StringList slUnicodeLang = new StringList(3);
	slUnicodeLang.add("ja");
	slUnicodeLang.add("zh");
	
	if(slUnicodeLang.contains(strAcceptLang1)){
		kavaFontName = "Arial Unicode MS";
	}else{
		kavaFontName = "Arial";
	}
	
    String strPropertyKey = "";    
    if ( label == MX_KC_TITLE ) {
      if(slUnicodeLang.contains(strAcceptLang1)){
      	strPropertyKey = "eServiceProgramCentral.ForUnicode.kcTitleFont";
      }else{
      	strPropertyKey = "eServiceProgramCentral.kcTitleFont";
      	}
    } else if ( label == MX_KC_LABEL ) {
      if(slUnicodeLang.contains(strAcceptLang1)){
      	strPropertyKey = "eServiceProgramCentral.ForUnicode.kcLabelFont";
      }else{
      	strPropertyKey = "eServiceProgramCentral.kcLavelFont";
      	}
    } else if ( label == MX_KC_LEGEND ) {
      if(slUnicodeLang.contains(strAcceptLang1)){
      	strPropertyKey = "eServiceProgramCentral.ForUnicode.kcLegendFont";
      }else{
      strPropertyKey = "eServiceProgramCentral.kcLegendFont";
      }
    }

    String strPropFont    = EnoviaResourceBundle.getProperty(ProgramCentralUtil.getAnonymousContext(), "ProgramCentral", strPropertyKey, strAcceptLang);
    // confirmming for system fonts.
    Font[] fonts = GraphicsEnvironment.getLocalGraphicsEnvironment().getAllFonts();
    for (int i=0 ; i < fonts.length ; i++ ) {
      if ( strPropFont.trim().equalsIgnoreCase(fonts[i].getFontName()) ) {
        kavaFontName = fonts[i].getFontName();
      }
    }
    return kavaFontName;
  }

%>


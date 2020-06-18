<%@page	import="com.dassault_systemes.parameter_modeler.PlmParameterPrivateServices"%>
<%@page import = "com.dassault_systemes.parameter_ui.PlmParameterJPOServices"%>
<%@page import="com.dassault_systemes.knowledge_itfs.IKweUnit"%>
<%@page import="java.net.URLDecoder"%>

<%
	String mode = emxGetParameter(request, "mode");

	if (mode != null && !mode.equals("save"))
	{
		response.setContentType("text/xml");
		response.setContentType("charset=UTF-8");
		response.setHeader("Content-Type", "text/xml");
		response.setHeader("Cache-Control", "no-cache");
		response.getWriter().write("<?xml version='1.0' encoding='UTF-8'?>");
	}
%>

<%@include file="../common/emxNavigatorNoDocTypeInclude.inc"%>


<%
	if (mode != null && mode.equals("save"))
	{
		try
		{
			if (!context.isTransactionActive())
				ContextUtil.startTransaction(context, true);

			// preferred dimensions
			String dimensionslist = emxGetParameter(request, "dimensionListHidden");
			PlmParameterPrivateServices.setPreference(context, "preference_DimensionsList", dimensionslist);

			// preferred display units
			String displayUnits = "";
			TreeMap<String, IKweUnit> displayUnitsMap = PlmParameterPrivateServices.getAllMagnitudesWithDisplayUnit(context);
			for (Map.Entry<String, IKweUnit> displayUnit : displayUnitsMap.entrySet())
			{
				String prefUnit = emxGetParameter(request, displayUnit.getKey());
				displayUnits += displayUnit.getKey() + ":" + prefUnit + ",";
			}

			PlmParameterPrivateServices.setPreference(context, "preference_DisplayUnits", displayUnits);
		}
		catch (Exception ex)
		{
			ContextUtil.abortTransaction(context);
		}
		finally
		{
			ContextUtil.commitTransaction(context);
		}
	}
	else if (mode != null && mode.equals("units"))
	{
		// load units for given magnitude
		try
		{
			String mag = emxGetParameter(request, "mag");

			String[] args = new String[1];
			args[0] = mag;
			ArrayList<IKweUnit> units = (ArrayList<IKweUnit>) JPO.invoke(context, "emxParameter", null,
				"getRelatedUnits", args, ArrayList.class);
			IKweUnit prefUnit = (IKweUnit) JPO.invoke(context, "emxParameter", null, "getPreferredUnit", args,
				IKweUnit.class);

			String xmlReturn = "<root>";
			for (IKweUnit unit : units)
			{
				if (!unit.getSymbol().isEmpty())
				{
					xmlReturn += "<unit value='" + unit.getSymbol() + "'";
	
					if (unit.getName().equals(prefUnit.getName()))
						xmlReturn += " default='true'";
	
					xmlReturn += ">" + unit.getNLSName(context) + "</unit>";
				}
			}
			xmlReturn += "</root>";
			response.getWriter().write(xmlReturn);
		}
		catch (Exception e)
		{
			e.printStackTrace();
			throw e;
		}
	}
	else if (mode != null && mode.equals("boolean"))
	{
		// get boolean NLS values
		try
		{
			StringList booleanValues = (StringList) JPO.invoke(context, "emxParameter", null,
				"getBooleanNLSValues", null, StringList.class);

			String xmlReturn = "<root>";
			Iterator it = booleanValues.iterator();
			while (it.hasNext())
				xmlReturn += "<value>" + it.next() + "</value>";
			xmlReturn += "</root>";
			response.getWriter().write(xmlReturn);
		}
		catch (Exception e)
		{
			e.printStackTrace();
			throw e;
		}
	}
	else if (mode != null && mode.equals("convert"))
	{
		try
		{
			String[] args = new String[3];
			args[0] = emxGetParameter(request, "prevunit");
			args[1] = emxGetParameter(request, "newunit");

			if (args[0] != null && !args[0].isEmpty() && args[1] != null && !args[1].isEmpty())
			{
				String xmlReturn = "<root>";

				// simple value
				String value = URLDecoder.decode(emxGetParameter(request, "value"), "UTF-8");
				if (value != null && !value.isEmpty())
				{
					args[2] = value;

					ArrayList<Double> ret = (ArrayList<Double>) JPO.invoke(context, "emxParameter", null,
						"getConvertedValues", args, ArrayList.class);
					xmlReturn += "<paramValue value='" + ret.get(0).doubleValue() + "'>" + ret.get(0).doubleValue() + "</paramValue>";
				}

				// min
				String minValue = URLDecoder.decode(emxGetParameter(request, "min"), "UTF-8");
				if (minValue != null && !minValue.isEmpty())
				{
					args[2] = minValue;

					ArrayList<Double> ret = (ArrayList<Double>) JPO.invoke(context, "emxParameter", null,
						"getConvertedValues", args, ArrayList.class);
					xmlReturn += "<paramMin value='" + ret.get(0).doubleValue() + "'>" + ret.get(0).doubleValue() + "</paramMin>";
				}

				// max
				String maxValue = URLDecoder.decode(emxGetParameter(request, "max"), "UTF-8");
				if (maxValue != null && !maxValue.isEmpty())
				{
					args[2] = maxValue;

					ArrayList<Double> ret = (ArrayList<Double>) JPO.invoke(context, "emxParameter", null,
						"getConvertedValues", args, ArrayList.class);
					xmlReturn += "<paramMax value='" + ret.get(0).doubleValue() + "'>" + ret.get(0).doubleValue() + "</paramMax>";
				}

				// multiples values
				String paramValues = URLDecoder.decode(emxGetParameter(request, "multiValue"), "UTF-8");
				if (paramValues != null && !paramValues.isEmpty())
				{
					System.out.println("paramValues = " + paramValues);

					if (paramValues.startsWith("|"))
						paramValues = paramValues.substring(1);
					if (paramValues.endsWith("|"))
						paramValues = paramValues.substring(0, paramValues.length() - 1);

					System.out.println("paramValues (trimmed) = " + paramValues);

					String[] values = paramValues.split("\\|");

					String[] args2 = new String[values.length + 2];
					args2[0] = emxGetParameter(request, "prevunit");
					args2[1] = emxGetParameter(request, "newunit");

					for (int i = 0; i < values.length; i++)
					{
						args2[i + 2] = values[i];
						System.out.println("values[" + i + "] = '" + values[i] + "'");
					}

					ArrayList<Double> MValues = (ArrayList<Double>) JPO.invoke(context, "emxParameter", null,
						"getConvertedValues", args2, ArrayList.class);

					Iterator<Double> it = MValues.iterator();
					while (it.hasNext())
					{
						Double mv = it.next();
						xmlReturn += "<paramMV value='" + mv.doubleValue() + "'>" + mv.doubleValue() + "</paramMV>";
					}
				}

				xmlReturn += "</root>";
				response.getWriter().write(xmlReturn);
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			throw e;
		}
	}
%>


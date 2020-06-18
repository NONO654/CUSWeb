<%--

  emxProgramCentralVaultSupport.inc

  Methods used by JSP pages to retrieve vault information

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralVaultSupport.inc.rca 1.12 Wed Oct 22 15:49:26 2008 przemek Experimental przemek $";
--%>

<%--
    here are the methods that will be written for Multi-Vault in Person Bean: 
    1. StringList getAllCompanyVaults(context) 
    2. StringList getLocalCompanyVaults(context) 
    3. StringList getSearchDefaultVaults(context) 
    4. void setSearchDefaultVaults(context, String)
--%>

<%--/**
     * Get all company's vaults.
     *
     * @param context the eMatrix <code>Context</code> object
     * @return stringlist of all vaults in the company.
     * @since AEF 10.0
     * @grade 0
     */--%>
<%!
    static public StringList GetAllVaults(Context context)
                                          throws MatrixException
    {
      
       // Get all vaults so that user can choose
       // this is all company's vaults not all vaults from all servers
       StringList vaultList = new StringList();
       
       com.matrixone.apps.common.Person person =
       com.matrixone.apps.common.Person.getPerson(context);
       Company company = person.getCompany(context);

       StringList selectList = new StringList(2);
       selectList.add(company.SELECT_VAULT);
       selectList.add(company.SELECT_SECONDARY_VAULTS);
       Map companyMap = company.getInfo(context,selectList);
       StringList secVaultList = FrameworkUtil.split((String)companyMap.get(company.SELECT_SECONDARY_VAULTS),null);
       Iterator itr = secVaultList.iterator();
          
       String vaults = (String)companyMap.get(company.SELECT_VAULT);
       vaultList.add(vaults);
       while (itr.hasNext() )
       {
           vaultList.add(PropertyUtil.getSchemaProperty(context, (String)itr.next()));
       }
       
       return vaultList;
    }
%>

<%--/**
     * Get all company's local vaults.
     *
     * @param context the eMatrix <code>Context</code> object
     * @return stringlist of all local vaults in the company.
     * @since AEF 10.0
     * @grade 0
     */--%>
<%!
    static public StringList GetAllLocalVaults(Context context)
                                               throws MatrixException
    {
        StringList vaultList = GetAllVaults(context);
        StringItr itr = new StringItr(VaultUtil.getLocalVaults(context));
        StringList localVaultList = new StringList();
        while (itr.next() )
        {
           String vault = itr.obj();         
           if(vaultList.contains(vault))
           {
              localVaultList.add(vault);
           }   
        }           
        
        return localVaultList;
    }
%>

<%--/**
     * Take a ; delimited string and turn it into a stringlist.
     *
     * @param context the eMatrix <code>Context</code> object
     * @return stringlist of all vaults that the user has access to.
     * @since AEF 10.0
     * @grade 0
     */--%>
<%!
    static public StringList convertToStringList(String vaultStr, String splitAt)
                                                throws MatrixException
    {
      StringList vaultSL = new StringList();
      StringList vaultSplit = FrameworkUtil.split(vaultStr, splitAt);
      Iterator vaultItr = vaultSplit.iterator();
      while (vaultItr.hasNext()){
        vaultSL.add(((String) vaultItr.next()).trim());
      }
      return vaultSL;
    }
%>

<%--/**
     * Get all vaults the user has access to.
     *
     * @param context the eMatrix <code>Context</code> object
     * @return stringlist of all vaults in the system.
     * @since AEF 10.0
     * @grade 0
     */--%>
<%!
    static public StringList GetAllSystemVaults(Context context)
                                          throws MatrixException
    {
      
      // Get all vaults so that user can choose
      VaultList vVaults = Vault.getVaults(context, true, false);
      Iterator vItr = vVaults.iterator();

      StringList vaultList = new StringList();
      while (vItr.hasNext()) {
        Vault aVault = (Vault) vItr.next();
        vaultList.add(aVault.toString());
      }

      return vaultList;
    }
%>

<%--/**
     * Get all vaults the user has access to.
     *
     * @param context the eMatrix <code>Context</code> object
     * @return stringlist of all remote vaults in the system.
     * @since AEF 10.0
     * @grade 0
     */--%>
<%!
    static public StringList GetAllSystemRemoteVaults(Context context)
                                                throws MatrixException
    {
      StringList vaultList = GetAllSystemVaults(context);
      StringItr itr = new StringItr(VaultUtil.getLocalVaults(context));
      while (itr.next())
      {
        vaultList.remove(itr.obj());
      }
      
      return vaultList;
    }
%>



<%--/**
     * Get a person's default vault preference
     *
     * @param context the eMatrix <code>Context</code> object
     * @return stringlist of the user's vault(s) preference.
     * @since AEF 10.0
     * @grade 0
     */--%>
<%!
    static public StringList GetVaults(Context context, String theId)
                                                throws MatrixException
    {
      com.matrixone.apps.common.Person person =
        (com.matrixone.apps.common.Person) DomainObject.newInstance(context,
        DomainConstants.TYPE_PERSON);

      StringList vaultSL = new StringList();
      if(theId != null && !"".equals(theId)) {
        person.setId(theId);
        vaultSL = convertToStringList(person.getSearchDefaultVaults(context), ",");
      }

      return vaultSL;
          
    }
%>

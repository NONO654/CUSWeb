export default class SP {
  
  static getCollabSpaces_$afterReceive (name, me, ctx) {
    // get the default security context if it exist else set the first available in the list
    const cspaces = ctx[name].response.data.cspaces;
    const cspace = cspaces.find(cspace => cspace.isDefault);
    ctx.mcs.sec = cspace ? cspace.name : cspaces[0].name;
  }

  static getCOSConfig_$afterReceive (name, me, ctx) {       
    // get the config info from response's xml (check if it is not multi-cos)
    let config = ctx[name].response.parsedData.COSConfigurationList.COSConfiguration;
    config = config.isDefault ? config : config.find(configuration => configuration.isDefault);

    // initialize
    ctx.cos = ctx.cos || {};
    // update cos data to context    
    ctx.cos.rooturl = config.fullCosUrl;
    ctx.cos.id = config['@attributes'].id;
  }

  
}




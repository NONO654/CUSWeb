export default class PS {
  
  static run_$beforeSend (name, me, ctx) {
    me.headers = {
      "accept": "application/json",
      "content-type": "text/plain",
      "EEDTicket": ctx.job.ticket,
      "ResourceCredentials": ctx.job.creds,
      "ResourceId": ctx.simulation.id,
      "RunInfo": `<RunInfo logLevel="Information" submissionHost="${ctx.cos.pvtStnName}" />`
    };

    let ApplicationData = ctx.job.appdata.replace(/(\n|\r)/gm, '');
    const tenant = `<TenantWU>${ctx.mcs.platform}</TenantWU></Application>`;
    const appurl = `<AppUrl>${ctx.mcs.mcsurl}</AppUrl>`;
    me.headers.ApplicationData = ApplicationData.replace(/<Appurl>.*<\/AppUrl>/gim, appurl).replace(/<\/Application>/gim, tenant);
  }

}




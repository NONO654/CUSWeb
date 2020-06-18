export class E6W {
  static buildPayload (body) {
    try {
      // parsing and stringifying to remove whitespaces
      const parsed = JSON.parse(body);
      const stringified = JSON.stringify(parsed);
      return 'updateWidget=' + encodeURIComponent(stringified); 
    } catch (ex) {
      console.warn('Unable to build payload. Check the body for JSON consistency', ex, body);
    }    
  }
  
  static buildHeaders (csrf) {
    return {
      'content-type': 'application/x-www-form-urlencoded',
      eno_csrf_token: csrf
    };
  }

  static generateGUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      var r = Math.random() * 16 | 0, v = c === 'x' ? r : r & 3 | 8;
      return v.toString(16);
    });
  }
}

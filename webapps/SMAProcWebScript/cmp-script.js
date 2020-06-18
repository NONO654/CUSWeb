export default class CmpScript extends HTMLElement {
    constructor() {
        super();
        console.info('CmpScript constructor');
        this.scriptLanguage = 'unknown';
        this.scriptContent = '';
        this.ExtensionEditorImpl = this;
    }
    connectedCallback() {
        console.info('CmpScript connectedCallback');
        this.updateHTML();
    }
    updateHTML() {
        this.innerHTML = `
            <style>
                cmp-script {display: block; padding: 1em;}
                cmp-script[hidden] {display: none;}
            </style>
            <p>Script language: <kbd>${this.scriptLanguage}</kbd></p>
            <p>Script content:</p>
            <pre>${this.scriptContent}</pre>`;
    }
    UpdateUI(act, step, extensionConfig) {
        console.log('cmp-script load', act, step, extensionConfig);
        const SCRIPT_STRING_RX = /^#!(Jython|DynamicJava)\n#\n# Isight 4.5 Script - will not run in earlier versions.\n#\n/;
        var scriptProperty = extensionConfig.getPropertyByName('script');
        var scriptContent = scriptProperty ? scriptProperty.getValue() : '';
        if (SCRIPT_STRING_RX.test(scriptContent)) {
            this.scriptLanguage = SCRIPT_STRING_RX.exec(scriptContent)[1];
            this.scriptContent = scriptContent.replace(SCRIPT_STRING_RX, '');
        }
        this.updateHTML();
    }
    Apply() {}
}
customElements.define('cmp-script', CmpScript);


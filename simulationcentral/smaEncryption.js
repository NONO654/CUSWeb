

function rc4(message, key)
    {
        var S = [], i, j, k, swap, encodedMessage = '';
        // Key-scheduling algorithm
        for (var i = 0; i < 256; i++) {
            S[i] = i;
        }
        j = 0;
        for (i = 0; i < 256; i++) {
            j = (j + S[i] + key.charCodeAt(i % key.length)) % 256;
            swap = S[i];
            S[i] = S[j];
            S[j] = swap;
        }
        
        // Pseudo-random generation algorithm and encrypt the original message with bitwise XOR
        i = 0;
        j = 0;
        for (k = 0; k < message.length; k++) {
            i = (i + 1) % 256;
            j = (j + S[i]) % 256;
            swap = S[i];
            S[i] = S[j];
            S[j] = swap;
            encodedMessage += String.fromCharCode(message.charCodeAt(k) ^ S[(S[i] + S[j]) % 256]);
        }
        return encodedMessage;
    }

function getEncodedCredentials(loginTicket, pubkey) {
    
	var topWindow =  getTopWindow().getWindowOpener();
    var credentialsToEncrypt =
    '<ProtectedResourceSet>' +
        '<protectedResource resourceName="MCS">' +
            '<credentialSet authenticationType="sso">' +
                '<credential name="ticket">' + loginTicket + '</credential>' +
            '</credentialSet>' +
        '</protectedResource>' +
        '<protectedResource resourceName="OS">' +
            '<credentialSet authenticationType="' + topWindow.sessionStorage.domainName + '">' +
            '<credential name="user">' + topWindow.sessionStorage.windowsUser + '</credential>' +
                '<credential name="password">' + topWindow.sessionStorage.windowsPass + '</credential>' +
        '</credentialSet>' +
        '<credentialSet authenticationType="X">' +
            '<credential name="user">' + topWindow.sessionStorage.linuxUser + '</credential>' +
                '<credential name="password">' + topWindow.sessionStorage.linuxPass + '</credential>' +
        '</credentialSet>' +
        '</protectedResource>' +
        '<protectedResource resourceName="IsightV5">' +
            '<credentialSet authenticationType="FiperCmd">' +
            '<credential name="user" sensitive="false">' + topWindow.sessionStorage.isightV5User + '</credential>' +
                '<credential name="password" sensitive="true">' + topWindow.sessionStorage.isightV5Password + '</credential>' +
        '</credentialSet>' +
        '</protectedResource>' +
    '</ProtectedResourceSet>';
    
    return encrypt(credentialsToEncrypt, pubkey);
    
}

function encrypt(data, pubkey) {
    
    if (!pubkey) {
        throw new Error('Invalid or missing public key');
    }
    
    // Generate key
    // var keyGenerator = KeyGenerator.getInstance("RC4");
    // keyGenerator.init(128);
    // var key = keyGenerator.generateKey();
    var key = forge.random.getBytesSync(16);

    // Encrypt key 
    // var cipher = Cipher.getInstance("RSA");
    // cipher.init(Cipher.WRAP_MODE, targetKey);
    // var encryptedKey = cipher.wrap(key);
    var targetKey = forge.pki.publicKeyFromPem('-----BEGIN PUBLIC KEY-----\n' + pubkey + '\n-----END PUBLIC KEY-----\n');
    var encryptedKey = forge.pki.rsa.encrypt(key, targetKey, 0x02);


    // Encrypt data
    // cipher = Cipher.getInstance("RC4");
    // cipher.init(Cipher.ENCRYPT_MODE, key);
    // var encryptedData = cipher.doFinal(data);
    var encryptedData = rc4(data, key);

    // Compute/Encrypt signature or Digest
    var digest = forge.md.md5.create();
    digest.update(encryptedKey);
    digest.update(encryptedData);
    var encryptedSig = digest.digest();

    // Encode message
    var encode = forge.util.encode64;
    return '|' + encode(encryptedKey) + '|' + encode(encryptedData) + '|' + encode(encryptedSig.data) + '|';
}


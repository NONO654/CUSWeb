/**  
* @quickReview QPV 15:03:10 Replace inflater code found on internet by call to zlib existing functions
* @quickReview QOU 15:01:27 Add "use strict"
* @fullReview QPV  15:01:23 Creation (temporary, it's an external code)
*/

define('DS/ZipJS/LoaderInflate',
[
    'UWA/Class',
    'UWA/Element',
    'WebappsUtils/WebappsUtils',
    'ZipJS/inflate'
],

function (Class, Element, WebappsUtils, inflate)
{
    "use strict";

    var Z_OK = 0;
    var Z_NO_FLUSH = 0;
    var Z_STREAM_END = 1;
    var Z_BUF_ERROR = -5;

    var LoaderInflate = Class.extend(
    {
        Inflate : function (data)
        {
            // Init

            var z = gztools.getZstream();
            var bufsize = 512;
            var flush = Z_NO_FLUSH;
            var buf = new Uint8Array(bufsize);
            var nomoreinput = false;

            z.inflateInit();
            z.next_out = buf;

            // inflate

            var err, buffers = [], bufferIndex = 0, bufferSize = 0, array;
            if (data.length === 0)
                return;

            z.next_in_index = 0;
            z.next_in = data;
            z.avail_in = data.length;

            do
            {
                z.next_out_index = 0;
                z.avail_out = bufsize;

                if ((z.avail_in === 0) && (!nomoreinput))
                {
                    // if buffer is empty and more input is available, refill it
                    z.next_in_index = 0;
                    nomoreinput = true;
                }
                err = z.inflate(flush);
                if (nomoreinput && (err === Z_BUF_ERROR))
                {
                    return -1;
                }
                if (err !== Z_OK && err !== Z_STREAM_END)
                {
                    break;
                }
                if (z.next_out_index)
                {
                    if (z.next_out_index === bufsize)
                    {
                        buffers.push(new Uint8Array(buf));
                    }
                    else
                    {
                        buffers.push(new Uint8Array(buf.subarray(0, z.next_out_index)));
                    }
                    bufferSize += z.next_out_index;

                    if ((err === Z_STREAM_END))
                        break;
                }
            }
            while (z.avail_in > 0 || z.avail_out === 0);

            array = new Uint8Array(bufferSize);

            buffers.forEach(function (chunk)
            {
                array.set(chunk, bufferIndex);
                bufferIndex += chunk.length;
            });
            return array;
        }
    });

    return LoaderInflate;
});

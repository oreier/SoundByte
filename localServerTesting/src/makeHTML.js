import fs from 'fs';

export function construct(inputFilename, outputFilename) {

    const startHTML = `<!DOCTYPE html>
    <html>
        <head>
            <meta charset="UTF-8" />
            <title>WebView Test</title>
            <link rel="shortcut icon" href="#"> <!--just so we don't get the annoying error message (we don't need an icon)-->
            <script type="module" src="https://cdn.jsdelivr.net/npm/vexflow@4.2.2/build/esm/entry/vexflow.js"></script>
        </head>

        <body>

            <div id="output"></div> <!--The object we're attaching the staff to-->
            <script type="module">\n`;

    const endHTML = `
            </script>
        </body>
    </html>
    `;

    const fileContents = fs.readFileSync(inputFilename, 'utf8');

    fs.writeFile(outputFilename + '.html', startHTML + fileContents + endHTML, (err) => {
        if (err) throw err;
        console.log("Constructed HTML file");
    });
}
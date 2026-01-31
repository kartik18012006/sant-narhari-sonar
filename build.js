const fs = require('fs');
const path = require('path');

const outDir = path.join(__dirname, 'build', 'web');
fs.mkdirSync(outDir, { recursive: true });

const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Sant Narhari Sonar</title>
</head>
<body>
  <p>Placeholder. Run <b>GitHub Actions</b> → Deploy to Vercel workflow to deploy the full Flutter app.</p>
</body>
</html>`;

fs.writeFileSync(path.join(outDir, 'index.html'), html);
console.log('Build complete: build/web/index.html');

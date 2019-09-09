const express = require('express');
const serveIndex = require('serve-index');


const app = express();
const PORT = process.env.PORT = 5421;

app.use('/logs', express.static('../scripts/logs'), serveIndex('../scripts/logs', {'icons': true}))

app.listen(PORT, () => {
  console.log('Server is running at:',PORT);
});
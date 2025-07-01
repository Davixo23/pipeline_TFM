const express = require('express');
const cors = require('cors');

const app = express();

// Permitir CORS para todas las solicitudes (origenes)
app.use(cors());

app.get('/api/hello', (req, res) => {
  res.json({ name: 'Juan Pérez' });
});

const PORT = 4000;
const HOST = '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log(`Backend escuchando en http://${HOST}:${PORT}`);
});

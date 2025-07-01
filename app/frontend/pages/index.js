import { useEffect, useState } from 'react';

export default function Home() {
  const [name, setName] = useState('');

  useEffect(() => {
    // Detectar si estamos en navegador o en servidor
    const isBrowser = typeof window !== 'undefined';

    // URL base para fetch
    const backendUrl = isBrowser ? 'http://localhost:4000' : 'http://backend:4000';

    fetch(`${backendUrl}/api/hello`)
      .then(res => res.json())
      .then(data => setName(data.name))
      .catch(console.error);
  }, []);

  return (
    <div style={{ fontFamily: 'Arial', padding: 20 }}>
      <h1>Hola Mundo desde Next.js</h1>
      <p>Nombre recibido del backend: <strong>{name || 'Cargando...'}</strong></p>
    </div>
  );
}

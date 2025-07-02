import { useEffect, useState } from 'react';

export default function Home() {
  const [name, setName] = useState('');

  useEffect(() => {
    fetch('/api/hello')
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

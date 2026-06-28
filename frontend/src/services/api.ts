import axios from 'axios';

// Em produção (Docker), as requisições passam pelo Nginx como proxy reverso.
// A variável REACT_APP_API_URL é injetada no build; por padrão usa /api (relativo).
const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || '/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Injeta o token JWT automaticamente em todas as requisições autenticadas
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;

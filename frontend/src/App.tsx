import React from 'react';
import Router from './router';
import { QueryClient, QueryClientProvider } from 'react-query';
import './App.scss';
import { AuthProvider } from './hooks/AuthContext';

const App: React.FC = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false
      },
      mutations: {
        retry: false
      }
    }
  });

  return (
    <AuthProvider>
      <QueryClientProvider client={queryClient}>
        <Router />
      </QueryClientProvider>
    </AuthProvider>
);
}

export default App;

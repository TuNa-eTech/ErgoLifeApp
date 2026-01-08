import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { Login } from './pages/Login';
import { Layout } from './components/Layout';
import { TaskTemplates } from './pages/TaskTemplates';
import { TaskTemplateEditor } from './pages/TaskTemplateEditor';

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, isLoading } = useAuth();
  
  if (isLoading) return <div className="flex items-center justify-center h-screen bg-slate-50">Loading...</div>;
  
  if (!isAuthenticated) return <Navigate to="/login" />;
  
  return <>{children}</>;
};

function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<Login />} />
          
          <Route path="/" element={
            <ProtectedRoute>
               <Layout />
            </ProtectedRoute>
          }>
             <Route index element={<Navigate to="/templates" replace />} />
             <Route path="templates" element={<TaskTemplates />} />
             <Route path="templates/new" element={<TaskTemplateEditor />} />
             <Route path="templates/:id" element={<TaskTemplateEditor />} />
          </Route>
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}

export default App;

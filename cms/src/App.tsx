import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { Login } from './pages/Login';
import { Layout } from './components/Layout';
import { TaskTemplates } from './pages/TaskTemplates';
import { TaskTemplateEditor } from './pages/TaskTemplateEditor';
import { Dashboard } from './pages/Dashboard';
import { UsersList } from './pages/Users/UsersList';
import { UserDetail } from './pages/Users/UserDetail';
import { HousesList } from './pages/Houses/HousesList';
import { HouseDetail } from './pages/Houses/HouseDetail';

import { ErrorBoundary } from './components/ErrorBoundary';

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
               <ErrorBoundary>
                  <Layout />
               </ErrorBoundary>
            </ProtectedRoute>
          }>
             <Route index element={<Dashboard />} />
             
             <Route path="users" element={<UsersList />} />
             <Route path="users/:id" element={<UserDetail />} />
             
             <Route path="houses" element={<HousesList />} />
             <Route path="houses/:id" element={<HouseDetail />} />

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


import React, { useEffect, useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { adminApi, type User } from '../../api/admin';
import { ArrowLeft, Wallet, Activity, Calendar, Trash2, AlertTriangle } from 'lucide-react';

interface DeleteDialogProps {
  user: User;
  onConfirm: () => void;
  onCancel: () => void;
  isDeleting: boolean;
}

const DeleteConfirmDialog: React.FC<DeleteDialogProps> = ({
  user,
  onConfirm,
  onCancel,
  isDeleting,
}) => {
  const [confirmText, setConfirmText] = useState('');
  const displayName = user.displayName || 'No Name';
  const isConfirmed = confirmText === displayName;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md mx-4 overflow-hidden">
        <div className="p-6">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center">
              <AlertTriangle className="w-5 h-5 text-red-600" />
            </div>
            <h3 className="text-lg font-bold text-slate-900">Delete User</h3>
          </div>

          <p className="text-sm text-slate-600 mb-4">
            This action is <span className="font-semibold text-red-600">permanent and cannot be undone</span>.
            All user data including activities, tasks, rewards, and Firebase account will be deleted.
          </p>

          <p className="text-sm text-slate-600 mb-2">
            Type <span className="font-mono font-semibold bg-slate-100 px-1.5 py-0.5 rounded">{displayName}</span> to confirm:
          </p>
          <input
            type="text"
            value={confirmText}
            onChange={(e) => setConfirmText(e.target.value)}
            placeholder={displayName}
            className="w-full px-3 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-red-500 text-sm"
            autoFocus
          />
        </div>

        <div className="flex gap-3 px-6 pb-6">
          <button
            onClick={onCancel}
            disabled={isDeleting}
            className="flex-1 px-4 py-2.5 rounded-lg border border-slate-200 text-slate-700 hover:bg-slate-50 transition-colors text-sm font-medium disabled:opacity-50"
          >
            Cancel
          </button>
          <button
            onClick={onConfirm}
            disabled={!isConfirmed || isDeleting}
            className="flex-1 px-4 py-2.5 rounded-lg bg-red-600 text-white hover:bg-red-700 transition-colors text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isDeleting ? 'Deleting...' : 'Delete User'}
          </button>
        </div>
      </div>
    </div>
  );
};

export const UserDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);

  useEffect(() => {
    if (id) {
      adminApi.getUser(id)
        .then(res => setUser(res.data?.data))
        .catch(err => console.error(err))
        .finally(() => setLoading(false));
    }
  }, [id]);

  const handleDelete = async () => {
    if (!user) return;
    setIsDeleting(true);
    try {
      await adminApi.deleteUser(user.id);
      navigate('/users');
    } catch (error) {
      console.error("Failed to delete user:", error);
      alert('Failed to delete user. Please try again.');
      setIsDeleting(false);
    }
  };

  if (loading) return <div>Loading user details...</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <Link to="/users" className="flex items-center gap-2 text-slate-500 hover:text-slate-900 transition-colors">
          <ArrowLeft className="w-4 h-4" />
          Back to Users
        </Link>

        <button
          onClick={() => setShowDeleteDialog(true)}
          className="inline-flex items-center gap-2 px-4 py-2 rounded-lg border border-red-200 text-red-600 hover:bg-red-50 transition-colors text-sm font-medium"
        >
          <Trash2 className="w-4 h-4" />
          Delete Account
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Profile Card */}
        <div className="lg:col-span-1 bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
          <div className="flex flex-col items-center text-center">
            <div className="w-24 h-24 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-3xl font-bold text-white mb-4">
              {user.displayName?.[0] || 'U'}
            </div>
            <h1 className="text-xl font-bold text-slate-900">{user.displayName || 'No Name'}</h1>
            <p className="text-slate-500 text-sm mb-6">{user.email}</p>

            <div className="w-full grid grid-cols-2 gap-4 border-t border-slate-100 pt-6">
              <div className="text-center">
                <p className="text-2xl font-bold text-emerald-600">{user.walletBalance}</p>
                <p className="text-xs text-slate-500 uppercase font-semibold mt-1">Wallet</p>
              </div>
              <div className="text-center">
                <p className="text-2xl font-bold text-slate-900">{user._count?.activities || 0}</p>
                <p className="text-xs text-slate-500 uppercase font-semibold mt-1">Activities</p>
              </div>
            </div>
          </div>
        </div>

        {/* Details Card */}
        <div className="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
           <h3 className="text-lg font-bold text-slate-900 mb-6">Account Details</h3>
           
           <div className="space-y-4">
             <div className="flex items-center justify-between py-3 border-b border-slate-50">
                <span className="text-slate-500 flex items-center gap-2"><Calendar className="w-4 h-4" /> Joined Date</span>
                <span className="font-medium">{new Date(user.createdAt).toLocaleDateString()}</span>
             </div>
             <div className="flex items-center justify-between py-3 border-b border-slate-50">
                <span className="text-slate-500 flex items-center gap-2"><Wallet className="w-4 h-4" /> Wallet Balance</span>
                <span className="font-medium">{user.walletBalance} Coins</span>
             </div>
             <div className="flex items-center justify-between py-3 border-b border-slate-50">
                <span className="text-slate-500 flex items-center gap-2"><Activity className="w-4 h-4" /> Total Activities</span>
                <span className="font-medium">{user._count?.activities || 0} Sessions</span>
             </div>
             <div className="flex items-center justify-between py-3 border-b border-slate-50">
                <span className="text-slate-500">Firebase UID</span>
                <code className="text-xs bg-slate-100 px-2 py-1 rounded">{user.firebaseUid}</code>
             </div>
           </div>
        </div>
      </div>

      {/* Delete Confirmation Dialog */}
      {showDeleteDialog && (
        <DeleteConfirmDialog
          user={user}
          onConfirm={handleDelete}
          onCancel={() => setShowDeleteDialog(false)}
          isDeleting={isDeleting}
        />
      )}
    </div>
  );
};

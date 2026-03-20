import { FormEvent, useEffect, useMemo, useState } from 'react';
import toast from 'react-hot-toast';
import api from './services/api';
import { useAuthStore } from './store/auth.store';

type Product = {
  id: string;
  name: string;
  description?: string;
  price: number;
  stock_quantity: number;
  category: string;
  image_url?: string;
  is_active: boolean;
};

type AdminUser = {
  id: string;
  email: string;
  full_name: string;
  role: string;
  is_active: boolean;
  created_at?: string;
};

type Campaign = {
  id: string;
  title: string;
  status: string;
  raised_amount?: number;
  target_amount?: number;
  created_at?: string;
};

type FeedPost = {
  id: string;
  user_name?: string;
  user_email?: string;
  content?: string;
  media_url?: string;
  media_type?: string;
  likes_count?: number;
  comments_count?: number;
  created_at?: string;
};

type NewProduct = {
  name: string;
  description: string;
  price: string;
  stock_quantity: string;
  category: string;
  image_url: string;
};

const initialProduct: NewProduct = {
  name: '',
  description: '',
  price: '',
  stock_quantity: '',
  category: '',
  image_url: '',
};

export default function App() {
  const { user, isAuthenticated, login, logout } = useAuthStore();

  const [email, setEmail] = useState('admin@gmail.com');
  const [password, setPassword] = useState('admin123');
  const [loadingLogin, setLoadingLogin] = useState(false);

  const [products, setProducts] = useState<Product[]>([]);
  const [loadingProducts, setLoadingProducts] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [saving, setSaving] = useState(false);
  const [uploadingImage, setUploadingImage] = useState(false);
  const [newProduct, setNewProduct] = useState<NewProduct>(initialProduct);
  const [activeTab, setActiveTab] = useState<
    'products' | 'users' | 'campaigns' | 'beneficiary' | 'feed'
  >('products');

  const [users, setUsers] = useState<AdminUser[]>([]);
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const [beneficiaryCampaigns, setBeneficiaryCampaigns] = useState<Campaign[]>([]);
  const [feedPosts, setFeedPosts] = useState<FeedPost[]>([]);

  const categories = useMemo(
    () => ['T-Shirts', 'Accessories', 'Bags', 'Stationery', 'Other'],
    []
  );

  const loadProducts = async () => {
    setLoadingProducts(true);
    try {
      const res = await api.getProducts();
      const rows = (res.data?.data || []) as Product[];
      setProducts(rows);
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to fetch products');
    } finally {
      setLoadingProducts(false);
    }
  };

  useEffect(() => {
    if (isAuthenticated) {
      loadProducts();
      loadUsers();
      loadCampaigns();
      loadBeneficiaryCampaigns();
      loadFeedPosts();
    }
  }, [isAuthenticated]);

  const loadUsers = async () => {
    try {
      const res = await api.getAdminUsers();
      setUsers((res.data?.data || []) as AdminUser[]);
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to fetch users');
    }
  };

  const loadCampaigns = async () => {
    try {
      const res = await api.getAdminCampaigns();
      setCampaigns((res.data?.data || []) as Campaign[]);
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to fetch campaigns');
    }
  };

  const loadBeneficiaryCampaigns = async () => {
    try {
      const res = await api.getAdminBeneficiaryCampaigns();
      setBeneficiaryCampaigns((res.data?.data || []) as Campaign[]);
    } catch (error: any) {
      toast.error(
        error?.response?.data?.error || 'Failed to fetch beneficiary campaigns'
      );
    }
  };

  const loadFeedPosts = async () => {
    try {
      const res = await api.getAdminFeedPosts(300);
      setFeedPosts((res.data?.data || []) as FeedPost[]);
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to fetch feed posts');
    }
  };

  const onLogin = async (e: FormEvent) => {
    e.preventDefault();
    setLoadingLogin(true);
    try {
      const res = await api.adminLogin(email.trim(), password);
      const data = res.data?.data;
      login(data.user, data.token);
      toast.success('Logged in as admin');
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Login failed');
    } finally {
      setLoadingLogin(false);
    }
  };

  const onCreateProduct = async (e: FormEvent) => {
    e.preventDefault();
    if (!newProduct.name.trim()) return toast.error('Product name is required');
    if (!newProduct.category.trim()) return toast.error('Category is required');

    const price = Number(newProduct.price);
    const stock = Number(newProduct.stock_quantity);
    if (!Number.isFinite(price) || price <= 0) {
      return toast.error('Price must be greater than zero');
    }
    if (!Number.isInteger(stock) || stock < 0) {
      return toast.error('Stock quantity must be a non-negative integer');
    }

    setSaving(true);
    try {
      await api.createProduct({
        name: newProduct.name.trim(),
        description: newProduct.description.trim(),
        price,
        stock_quantity: stock,
        category: newProduct.category.trim(),
        image_url: newProduct.image_url.trim() || undefined,
      });
      toast.success('Product added');
      setShowModal(false);
      setNewProduct(initialProduct);
      await loadProducts();
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to create product');
    } finally {
      setSaving(false);
    }
  };

  const onPickImage = async (file?: File) => {
    if (!file) return;
    setUploadingImage(true);
    try {
      const res = await api.uploadProductImage(file);
      const url = res.data?.data?.url as string | undefined;
      if (!url) {
        throw new Error('Image upload did not return URL');
      }
      setNewProduct((prev) => ({ ...prev, image_url: url }));
      toast.success('Image uploaded');
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to upload image');
    } finally {
      setUploadingImage(false);
    }
  };

  const toggleUserStatus = async (u: AdminUser) => {
    try {
      await api.updateUserStatus(u.id, !u.is_active);
      await loadUsers();
      toast.success('User status updated');
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to update user');
    }
  };

  const setCampaignStatus = async (
    type: 'campaign' | 'beneficiary',
    id: string,
    status: string
  ) => {
    try {
      if (type === 'campaign') {
        await api.updateCampaignStatus(id, status);
        await loadCampaigns();
      } else {
        await api.updateBeneficiaryCampaignStatus(id, status);
        await loadBeneficiaryCampaigns();
      }
      toast.success('Campaign status updated');
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to update status');
    }
  };

  const removeCampaign = async (c: Campaign) => {
    const ok = window.confirm(`Delete campaign "${c.title}"?`);
    if (!ok) return;
    try {
      await api.deleteCampaign(c.id);
      await loadCampaigns();
      toast.success('Campaign deleted');
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to delete campaign');
    }
  };

  const removeBeneficiaryCampaign = async (c: Campaign) => {
    const ok = window.confirm(`Delete beneficiary campaign "${c.title}"?`);
    if (!ok) return;
    try {
      await api.deleteBeneficiaryCampaign(c.id);
      await loadBeneficiaryCampaigns();
      toast.success('Beneficiary campaign deleted');
    } catch (error: any) {
      toast.error(
        error?.response?.data?.error || 'Failed to delete beneficiary campaign'
      );
    }
  };

  const toggleMerchStatus = async (p: Product) => {
    try {
      await api.updateMerchandiseStatus(p.id, !p.is_active);
      await loadProducts();
      toast.success('Merch status updated');
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to update merch');
    }
  };

  const removeMerch = async (p: Product) => {
    const ok = window.confirm(`Remove "${p.name}" from merchandise?`);
    if (!ok) return;
    try {
      await api.deleteMerchandise(p.id);
      await loadProducts();
      toast.success('Merch removed');
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to remove merch');
    }
  };

  const deleteFeedPost = async (postId: string) => {
    try {
      await api.deleteAdminFeedPost(postId);
      await loadFeedPosts();
      toast.success('Feed post removed');
    } catch (error: any) {
      toast.error(error?.response?.data?.error || 'Failed to remove post');
    }
  };

  if (!isAuthenticated) {
    return (
      <div className="page centered">
        <form className="card login-card" onSubmit={onLogin}>
          <h1>Kindora Admin</h1>
          <p className="sub">Use test admin credentials to continue.</p>
          <label>Email</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          <label>Password</label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          <button className="btn primary" disabled={loadingLogin}>
            {loadingLogin ? 'Signing in...' : 'Sign in'}
          </button>
          <p className="hint">admin@gmail.com / admin123</p>
        </form>
      </div>
    );
  }

  return (
    <div className="page">
      <header className="topbar">
        <div>
          <h2>Product Management</h2>
          <p className="sub">Manage merchandise for mobile app merch page.</p>
        </div>
        <div className="top-actions">
          <span className="welcome">{user?.email}</span>
          <button className="btn ghost" onClick={logout}>
            Logout
          </button>
          <button className="btn primary" onClick={() => setShowModal(true)}>
            + Add Product
          </button>
        </div>
      </header>

      <div className="top-actions" style={{ marginBottom: 12 }}>
        <button
          className={`btn ${activeTab === 'products' ? 'primary' : 'ghost'}`}
          onClick={() => setActiveTab('products')}
        >
          Merch
        </button>
        <button
          className={`btn ${activeTab === 'users' ? 'primary' : 'ghost'}`}
          onClick={() => setActiveTab('users')}
        >
          Users
        </button>
        <button
          className={`btn ${activeTab === 'campaigns' ? 'primary' : 'ghost'}`}
          onClick={() => setActiveTab('campaigns')}
        >
          Campaigns
        </button>
        <button
          className={`btn ${activeTab === 'beneficiary' ? 'primary' : 'ghost'}`}
          onClick={() => setActiveTab('beneficiary')}
        >
          Beneficiary Campaigns
        </button>
        <button
          className={`btn ${activeTab === 'feed' ? 'primary' : 'ghost'}`}
          onClick={() => setActiveTab('feed')}
        >
          Feed
        </button>
      </div>

      <main className="card">
        {activeTab === 'products' && (loadingProducts ? (
          <p>Loading products...</p>
        ) : products.length === 0 ? (
          <p>No products found.</p>
        ) : (
          <table className="table">
            <thead>
              <tr>
                <th>Image</th>
                <th>Name</th>
                <th>Category</th>
                <th>Price</th>
                <th>Stock</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {products.map((p) => (
                <tr key={p.id}>
                  <td>
                    {p.image_url ? (
                      <img className="thumb" src={p.image_url} alt={p.name} />
                    ) : (
                      <div className="thumb placeholder">No Image</div>
                    )}
                  </td>
                  <td>{p.name}</td>
                  <td>{p.category}</td>
                  <td>${Number(p.price).toFixed(2)}</td>
                  <td>{p.stock_quantity}</td>
                  <td>{p.is_active ? 'Active' : 'Inactive'}</td>
                  <td>
                    <button className="btn ghost" onClick={() => toggleMerchStatus(p)}>
                      {p.is_active ? 'Deactivate' : 'Activate'}
                    </button>
                    <button
                      className="btn ghost"
                      style={{ marginLeft: 8 }}
                      onClick={() => removeMerch(p)}
                    >
                      Remove
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ))}

        {activeTab === 'users' && (
          <table className="table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Role</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {users.map((u) => (
                <tr key={u.id}>
                  <td>{u.full_name || '-'}</td>
                  <td>{u.email}</td>
                  <td>{u.role}</td>
                  <td>{u.is_active ? 'Active' : 'Inactive'}</td>
                  <td>
                    <button className="btn ghost" onClick={() => toggleUserStatus(u)}>
                      {u.is_active ? 'Disable' : 'Enable'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {activeTab === 'campaigns' && (
          <table className="table">
            <thead>
              <tr>
                <th>Title</th>
                <th>Status</th>
                <th>Raised / Target</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {campaigns.map((c) => (
                <tr key={c.id}>
                  <td>{c.title}</td>
                  <td>{c.status}</td>
                  <td>
                    {Number(c.raised_amount || 0).toFixed(2)} /{' '}
                    {Number(c.target_amount || 0).toFixed(2)}
                  </td>
                  <td>
                    <select
                      value={c.status}
                      onChange={(e) =>
                        setCampaignStatus('campaign', c.id, e.target.value)
                      }
                    >
                      <option value="active">active</option>
                      <option value="paused">paused</option>
                      <option value="completed">completed</option>
                      <option value="cancelled">cancelled</option>
                    </select>
                    <button
                      className="btn ghost"
                      style={{ marginLeft: 8 }}
                      onClick={() => removeCampaign(c)}
                    >
                      Remove
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {activeTab === 'beneficiary' && (
          <table className="table">
            <thead>
              <tr>
                <th>Title</th>
                <th>Status</th>
                <th>Raised / Target</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {beneficiaryCampaigns.map((c) => (
                <tr key={c.id}>
                  <td>{c.title}</td>
                  <td>{c.status}</td>
                  <td>
                    {Number(c.raised_amount || 0).toFixed(2)} /{' '}
                    {Number(c.target_amount || 0).toFixed(2)}
                  </td>
                  <td>
                    <select
                      value={c.status}
                      onChange={(e) =>
                        setCampaignStatus('beneficiary', c.id, e.target.value)
                      }
                    >
                      <option value="active">active</option>
                      <option value="paused">paused</option>
                      <option value="completed">completed</option>
                      <option value="cancelled">cancelled</option>
                    </select>
                    <button
                      className="btn ghost"
                      style={{ marginLeft: 8 }}
                      onClick={() => removeBeneficiaryCampaign(c)}
                    >
                      Remove
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {activeTab === 'feed' && (
          <>
            <div className="top-actions" style={{ marginBottom: 8 }}>
              <button className="btn ghost" onClick={loadFeedPosts}>
                Refresh Feed
              </button>
            </div>
            <table className="table">
              <thead>
                <tr>
                  <th>Time</th>
                  <th>User</th>
                  <th>Content</th>
                  <th>Media</th>
                  <th>Preview</th>
                  <th>Likes</th>
                  <th>Comments</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {feedPosts.map((p) => (
                  <tr key={p.id}>
                    <td>{p.created_at ? new Date(p.created_at).toLocaleString() : '-'}</td>
                    <td>{p.user_name || p.user_email || '-'}</td>
                    <td>{p.content || '-'}</td>
                    <td>{p.media_type || 'none'}</td>
                    <td>
                      {p.media_url ? (
                        p.media_type === 'image' ? (
                          <a href={p.media_url} target="_blank" rel="noreferrer">
                            <img
                              src={p.media_url}
                              alt="Post media"
                              style={{
                                width: 56,
                                height: 56,
                                objectFit: 'cover',
                                borderRadius: 8,
                                border: '1px solid #e5e7eb',
                              }}
                            />
                          </a>
                        ) : (
                          <a href={p.media_url} target="_blank" rel="noreferrer">
                            View
                          </a>
                        )
                      ) : (
                        '-'
                      )}
                    </td>
                    <td>{p.likes_count ?? 0}</td>
                    <td>{p.comments_count ?? 0}</td>
                    <td>
                      <button className="btn ghost" onClick={() => deleteFeedPost(p.id)}>
                        Remove
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </>
        )}
      </main>

      {showModal && (
        <div className="modal-backdrop" onClick={() => setShowModal(false)}>
          <form
            className="modal"
            onSubmit={onCreateProduct}
            onClick={(e) => e.stopPropagation()}
          >
            <h3>Add New Product</h3>
            <input
              placeholder="Product Name *"
              value={newProduct.name}
              onChange={(e) =>
                setNewProduct({ ...newProduct, name: e.target.value })
              }
              required
            />
            <textarea
              placeholder="Description"
              value={newProduct.description}
              onChange={(e) =>
                setNewProduct({ ...newProduct, description: e.target.value })
              }
            />
            <div className="row">
              <input
                placeholder="Price *"
                type="number"
                min="0.01"
                step="0.01"
                value={newProduct.price}
                onChange={(e) =>
                  setNewProduct({ ...newProduct, price: e.target.value })
                }
                required
              />
              <input
                placeholder="Stock Quantity *"
                type="number"
                min="0"
                step="1"
                value={newProduct.stock_quantity}
                onChange={(e) =>
                  setNewProduct({
                    ...newProduct,
                    stock_quantity: e.target.value,
                  })
                }
                required
              />
            </div>
            <select
              value={newProduct.category}
              onChange={(e) =>
                setNewProduct({ ...newProduct, category: e.target.value })
              }
              required
            >
              <option value="">Category *</option>
              {categories.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
            <div className="image-upload">
              <input
                type="file"
                accept="image/*"
                onChange={(e) => onPickImage(e.target.files?.[0])}
                disabled={uploadingImage || saving}
              />
              {uploadingImage && <p className="hint">Uploading image...</p>}
              {!uploadingImage && newProduct.image_url && (
                <img
                  className="thumb"
                  src={newProduct.image_url}
                  alt="Uploaded product"
                />
              )}
            </div>
            <div className="modal-actions">
              <button
                type="button"
                className="btn ghost"
                onClick={() => setShowModal(false)}
              >
                Cancel
              </button>
              <button
                type="submit"
                className="btn primary"
                disabled={saving || uploadingImage}
              >
                {saving ? 'Saving...' : 'Save Product'}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}


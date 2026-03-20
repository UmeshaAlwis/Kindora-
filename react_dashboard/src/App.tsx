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
    }
  }, [isAuthenticated]);

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

      <main className="card">
        {loadingProducts ? (
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
                </tr>
              ))}
            </tbody>
          </table>
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


-- Estructura base de datos para CarFix
-- Marketplace de repuestos automotrices en San Fernando de Apure

CREATE DATABASE IF NOT EXISTS carfix CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE carfix;

-- SISTEMA DE USUARIOS Y PERFILES --

-- Tabla de usuarios con roles extendidos
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(256) NOT NULL,
  role ENUM('admin', 'business', 'customer') NOT NULL,
  profile_image VARCHAR(255),
  phone VARCHAR(20),
  address TEXT,
  description TEXT,
  rating DECIMAL(3,2) DEFAULT 0,
  is_verified BOOLEAN DEFAULT 0,
  last_login DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla para negocios (extiende a usuarios con role='business')
CREATE TABLE businesses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  business_name VARCHAR(150) NOT NULL,
  rif VARCHAR(20),
  location_lat DECIMAL(10,8),
  location_lng DECIMAL(11,8),
  logo VARCHAR(255),
  cover_image VARCHAR(255),
  schedule JSON, -- Horario de atención
  social_media JSON, -- Redes sociales
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Métodos de pago para negocios
CREATE TABLE business_payment_methods (
  id INT AUTO_INCREMENT PRIMARY KEY,
  business_id INT NOT NULL,
  payment_type ENUM('zelle', 'pagomovil', 'transferencia', 'efectivo', 'otro') NOT NULL,
  account_details JSON NOT NULL, -- Información de la cuenta, teléfono, etc.
  is_active BOOLEAN DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

-- CATÁLOGO DE PRODUCTOS --

-- Categorías de repuestos
CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  image VARCHAR(255),
  parent_id INT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Marcas de vehículos
CREATE TABLE brands (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  logo VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Modelos de vehículos
CREATE TABLE models (
  id INT AUTO_INCREMENT PRIMARY KEY,
  brand_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE
);

-- Vehículos (combinación de marca, modelo y año)
CREATE TABLE vehicles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  model_id INT NOT NULL,
  year INT NOT NULL,
  engine VARCHAR(100),
  transmission VARCHAR(50),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (model_id) REFERENCES models(id) ON DELETE CASCADE
);

-- Repuestos
CREATE TABLE spare_parts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  business_id INT NOT NULL,
  category_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  oem_code VARCHAR(100),
  reference_codes TEXT,
  price DECIMAL(10,2) NOT NULL,
  stock INT DEFAULT 0,
  featured BOOLEAN DEFAULT 0,
  discount_percentage DECIMAL(5,2) DEFAULT 0,
  description TEXT,
  condition ENUM('new', 'used', 'refurbished') DEFAULT 'new',
  weight DECIMAL(8,2),
  dimensions VARCHAR(100),
  sales_count INT DEFAULT 0,
  views_count INT DEFAULT 0,
  status ENUM('active', 'inactive', 'out_of_stock') DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- Imágenes de repuestos (múltiples por repuesto)
CREATE TABLE spare_part_images (
  id INT AUTO_INCREMENT PRIMARY KEY,
  spare_part_id INT NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  is_main BOOLEAN DEFAULT 0,
  display_order INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (spare_part_id) REFERENCES spare_parts(id) ON DELETE CASCADE
);

-- Compatibilidad entre repuestos y vehículos
CREATE TABLE spare_part_vehicle (
  id INT AUTO_INCREMENT PRIMARY KEY,
  spare_part_id INT NOT NULL,
  vehicle_id INT NOT NULL,
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (spare_part_id) REFERENCES spare_parts(id) ON DELETE CASCADE,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
);

-- PROMOCIONES Y MARKETING --

-- Promociones y ofertas de temporada
CREATE TABLE promotions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  business_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  discount_type ENUM('percentage', 'fixed_amount') DEFAULT 'percentage',
  discount_value DECIMAL(10,2) NOT NULL,
  promotion_type ENUM('seasonal', 'clearance', 'featured', 'flash_sale') DEFAULT 'seasonal',
  banner_image VARCHAR(255),
  active BOOLEAN DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

-- Relación entre repuestos y promociones
CREATE TABLE spare_part_promotion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  spare_part_id INT NOT NULL,
  promotion_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (spare_part_id) REFERENCES spare_parts(id) ON DELETE CASCADE,
  FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE
);

-- INTERACCIÓN DE USUARIOS --

-- Reseñas y calificaciones de productos
CREATE TABLE reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  spare_part_id INT NOT NULL,
  rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title VARCHAR(100),
  comment TEXT,
  purchase_verified BOOLEAN DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (spare_part_id) REFERENCES spare_parts(id) ON DELETE CASCADE
);

-- Imágenes de reseñas
CREATE TABLE review_images (
  id INT AUTO_INCREMENT PRIMARY KEY,
  review_id INT NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE
);

-- Lista de favoritos de usuarios
CREATE TABLE wishlists (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  spare_part_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (spare_part_id) REFERENCES spare_parts(id) ON DELETE CASCADE
);

-- Historial de búsquedas
CREATE TABLE search_history (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  search_query VARCHAR(255) NOT NULL,
  search_filters JSON,
  results_count INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- CARRITOS Y PEDIDOS --

-- Carrito de compras
CREATE TABLE shopping_carts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Items del carrito
CREATE TABLE cart_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cart_id INT NOT NULL,
  spare_part_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (cart_id) REFERENCES shopping_carts(id) ON DELETE CASCADE,
  FOREIGN KEY (spare_part_id) REFERENCES spare_parts(id) ON DELETE CASCADE
);

-- Pagos
CREATE TABLE payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  business_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  payment_method_id INT NOT NULL,
  reference_number VARCHAR(100),
  payment_status ENUM('pending', 'completed', 'rejected', 'refunded') DEFAULT 'pending',
  payment_date DATETIME,
  proof_image VARCHAR(255),
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (business_id) REFERENCES businesses(id),
  FOREIGN KEY (payment_method_id) REFERENCES business_payment_methods(id)
);

-- Pedidos
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  business_id INT NOT NULL,
  order_number VARCHAR(50) NOT NULL UNIQUE,
  status ENUM('pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
  shipping_address TEXT,
  shipping_phone VARCHAR(20),
  shipping_notes TEXT,
  payment_id INT,
  subtotal DECIMAL(10,2) NOT NULL,
  shipping_cost DECIMAL(10,2) DEFAULT 0,
  discount DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (business_id) REFERENCES businesses(id),
  FOREIGN KEY (payment_id) REFERENCES payments(id)
);

-- Detalles del pedido
CREATE TABLE order_details (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  spare_part_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  discount DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (spare_part_id) REFERENCES spare_parts(id)
);

-- Seguimiento de pedidos
CREATE TABLE order_tracking (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  status VARCHAR(50) NOT NULL,
  notes TEXT,
  created_by INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- GESTIÓN DE INVENTARIO Y REPORTES --

-- Historiales de importación de inventario
CREATE TABLE inventory_imports (
  id INT AUTO_INCREMENT PRIMARY KEY,
  business_id INT NOT NULL,
  filename VARCHAR(255) NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  status ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',
  report JSON,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

-- Registra cada movimiento de inventario (entradas, salidas, ajustes)
CREATE TABLE inventory_movements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  business_id INT NOT NULL,
  spare_part_id INT NOT NULL,
  movement_type ENUM('purchase', 'sale', 'return', 'adjustment', 'import') NOT NULL,
  quantity INT NOT NULL,  -- positivo para entradas, negativo para salidas
  reference_id INT,  -- ID de orden, importación, etc. relacionado con este movimiento
  reference_type VARCHAR(50),  -- 'order', 'import', 'manual_adjustment', etc.
  previous_stock INT NOT NULL,
  current_stock INT NOT NULL,
  notes TEXT,
  created_by INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
  FOREIGN KEY (spare_part_id) REFERENCES spare_parts(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Almacena reportes generados
CREATE TABLE reports (
  id INT AUTO_INCREMENT PRIMARY KEY,
  business_id INT NOT NULL,
  report_type VARCHAR(50) NOT NULL,  -- 'inventory', 'sales', 'finance', 'customer', etc.
  report_name VARCHAR(100) NOT NULL,
  parameters JSON,  -- Filtros y parámetros utilizados para generar el reporte
  file_path VARCHAR(255),  -- Ruta al archivo PDF/Excel generado
  created_by INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Registra recibos, facturas y otros documentos comerciales
CREATE TABLE documents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  business_id INT NOT NULL,
  document_type ENUM('invoice', 'receipt', 'delivery_note', 'return_form') NOT NULL,
  document_number VARCHAR(50) NOT NULL,
  related_id INT NOT NULL,  -- ID de orden, pago, etc.
  related_type VARCHAR(50) NOT NULL,  -- 'order', 'payment', etc.
  total_amount DECIMAL(12,2) NOT NULL,
  file_path VARCHAR(255),  -- Ruta al PDF generado
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

-- COMUNICACIÓN --

-- Mensajes entre usuarios
CREATE TABLE messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sender_id INT NOT NULL,
  receiver_id INT NOT NULL,
  subject VARCHAR(200),
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Notificaciones
CREATE TABLE notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(100) NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT 0,
  related_id INT, -- ID relacionado (puede ser order_id, payment_id, etc.)
  related_type VARCHAR(50), -- Tipo de relación (order, payment, etc.)
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ESTADÍSTICAS Y CONFIGURACIÓN --

-- Estadísticas de dashboards (almacenamiento de datos agregados)
CREATE TABLE dashboard_stats (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  stat_date DATE NOT NULL,
  stat_type VARCHAR(50) NOT NULL,
  value JSON NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Configuración del sistema
CREATE TABLE system_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) NOT NULL UNIQUE,
  setting_value TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- AUDITORÍA --

-- Para registro de auditoría de cambios importantes en el sistema
CREATE TABLE audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  action VARCHAR(50) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
  entity_id INT NOT NULL,
  old_values JSON,
  new_values JSON,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Índices para mejorar el rendimiento
ALTER TABLE spare_parts ADD INDEX idx_featured (featured);
ALTER TABLE spare_parts ADD INDEX idx_category (category_id);
ALTER TABLE spare_parts ADD INDEX idx_business (business_id);
ALTER TABLE spare_parts ADD INDEX idx_price (price);
ALTER TABLE spare_parts ADD INDEX idx_stock (stock);
ALTER TABLE spare_parts ADD INDEX idx_sales (sales_count);
ALTER TABLE vehicles ADD INDEX idx_model_year (model_id, year);
ALTER TABLE spare_part_vehicle ADD INDEX idx_compatibility (spare_part_id, vehicle_id);
ALTER TABLE orders ADD INDEX idx_user (user_id);
ALTER TABLE orders ADD INDEX idx_business (business_id);
ALTER TABLE orders ADD INDEX idx_status (status);
ALTER TABLE reviews ADD INDEX idx_product_rating (spare_part_id, rating);
ALTER TABLE inventory_movements ADD INDEX idx_movement_type (movement_type);
ALTER TABLE audit_logs ADD INDEX idx_entity_action (entity_type, action);

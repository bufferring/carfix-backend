
## 🗺️ Technical Roadmap

### 🌟 Phase 1: Core Platform
**🚀 Objective:** Functional MVP with Basic Flows  
**🔧 Key Technologies:**  
![Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=flat&logo=laravel&logoColor=white)
![Livewire](https://img.shields.io/badge/Livewire-4E5AEE?style=flat&logo=livewire&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white)

📋 Main Tasks

- [ ] Initial architecture with Laravel 12
- [ ] Multi-role authentication system (Admin/Salesman/Customer)
- [ ] Complete CRUD for:
  - 🚗 Vehicles (Brand, Model, Year)
  - 🔩 Spare Parts (OEM, Price, Stock)
  - 🔄 Compatibility (N-N relationships)
- [ ] Easy payment integration:
  - 💳 QR code generation for payments
- [ ] Basic REST API with Sanctum

---

### 🎨 Phase 2: User Experience
**🚀 Objective:** UI/UX and Performance Optimization  
**🔧 Key Technologies:**  
![Next.js](https://img.shields.io/badge/NextJs-000000?style=flat&logo=next.js&logoColor=white)
![Meilisearch](https://img.shields.io/badge/Meilisearch-000000?style=flat&logo=meilisearch&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=flat&logo=redis&logoColor=white)

📋 Main Tasks

- [ ] Advanced search engine:
  - 🔍 Predictive autocomplete
  - 🎯 Compatibility-based search
  - 📊 Search history
- [ ] Interactive components:
  - 🖼️ Image gallery with Zoom
  - 📈 Parts comparator
- [ ] Optimizations:
  - 🚀 Redis caching
  - 🖼️ Image optimization (WebP)
  - 📱 PWA (Progressive Web App)
- [ ] Internationalization:
  - 💵 Currency conversion

---

### 📊 Phase 3: Business Intelligence
**🚀 Objective:** Advanced Analytics & Automation  
**🔧 Key Technologies:**  
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Metabase](https://img.shields.io/badge/Metabase-509EE3?style=flat&logo=metabase&logoColor=white)
![Horizon](https://img.shields.io/badge/Laravel_Horizon-FF2D20?style=flat&logo=laravel&logoColor=white)

📋 Main Tasks

- [ ] Recommendation system:
  - 🤖 ML with Python (scikit-learn)
  - 🔄 "Customers also bought..."
- [ ] Analytical dashboards:
  - 📈 Real-time sales
  - 📊 Conversion metrics
  - 📦 Inventory management
- [ ] Automations:
  - ⚠️ Predictive stock alerts
  - 📧 Remarketing campaigns
  - 🤖 Basic chatbot
- [ ] Metabase integration
- [ ] PDF/Excel report generation

---

### 💼 Additional features
- [ ] More payment integration:
  - 💳 Stripe/PayPal
- [ ] Email notification system

# 🗂️ DATABASE (SQL)

```
-- Estructura base de datos para CarFix (references in Spanish for your DB Teachers)
-- Marketplace de repuestos automotrices en San Fernando de Apure

CREATE DATABASE IF NOT EXISTS carfix CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE carfix;

-- SISTEMA DE USUARIOS Y PERFILES --

-- Tabla de usuarios con roles extendidos
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL UNIQUE,
  `password` VARCHAR(256) NOT NULL,
  `role` ENUM('admin', 'business', 'customer') NOT NULL,
  `profile_image` VARCHAR(255),
  `phone` VARCHAR(20),
  `address` TEXT,
  `description` TEXT,
  `rating` DECIMAL(3,2) DEFAULT 0,
  `is_verified` BOOLEAN DEFAULT 0,
  `last_login` DATETIME,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla para negocios (extiende a usuarios con role='business')
CREATE TABLE IF NOT EXISTS `businesses` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL UNIQUE,
  `business_name` VARCHAR(150) NOT NULL,
  `rif` VARCHAR(20),
  `location_lat` DECIMAL(10,8),
  `location_lng` DECIMAL(11,8),
  `logo` VARCHAR(255),
  `cover_image` VARCHAR(255),
  `schedule` JSON, -- Horario de atención
  `social_media` JSON, -- Redes sociales
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

-- Métodos de pago para negocios
CREATE TABLE IF NOT EXISTS `business_payment_methods` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `business_id` INT NOT NULL,
  `payment_type` ENUM('zelle', 'pagomovil', 'transferencia', 'efectivo', 'otro') NOT NULL,
  `account_details` JSON NOT NULL, -- Información de la cuenta, teléfono, etc.
  `is_active` BOOLEAN DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`business_id`) REFERENCES `businesses`(`id`) ON DELETE CASCADE
);

-- CATÁLOGO DE PRODUCTOS --

-- Categorías de repuestos
CREATE TABLE IF NOT EXISTS `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  `image` VARCHAR(255),
  `parent_id` INT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`parent_id`) REFERENCES `categories`(`id`) ON DELETE SET NULL
);

-- Marcas de vehículos
CREATE TABLE IF NOT EXISTS `brands` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `logo` VARCHAR(255),
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Modelos de vehículos
CREATE TABLE IF NOT EXISTS `models` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `brand_id` INT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`brand_id`) REFERENCES `brands`(`id`) ON DELETE CASCADE
);

-- Vehículos (combinación de marca, modelo y año)
CREATE TABLE IF NOT EXISTS `vehicles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `model_id` INT NOT NULL,
  `year` INT NOT NULL,
  `engine` VARCHAR(100),
  `transmission` VARCHAR(50),
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`model_id`) REFERENCES `models`(`id`) ON DELETE CASCADE
);

-- Repuestos
CREATE TABLE IF NOT EXISTS `spare_parts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `business_id` INT NOT NULL,
  `category_id` INT NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `oem_code` VARCHAR(100),
  `reference_codes` TEXT,
  `price` DECIMAL(10,2) NOT NULL,
  `stock` INT DEFAULT 0,
  `featured` BOOLEAN DEFAULT 0,
  `discount_percentage` DECIMAL(5,2) DEFAULT 0,
  `description` TEXT,
  `part_condition` ENUM('new', 'used', 'refurbished') DEFAULT 'new',
  `weight` DECIMAL(8,2),
  `dimensions` VARCHAR(100),
  `sales_count` INT DEFAULT 0,
  `views_count` INT DEFAULT 0,
  `status` ENUM('active', 'inactive', 'out_of_stock') DEFAULT 'active',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`business_id`) REFERENCES `businesses`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE CASCADE
);

-- Imágenes de repuestos (múltiples por repuesto)
CREATE TABLE IF NOT EXISTS `spare_part_images` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `spare_part_id` INT NOT NULL,
  `image_url` VARCHAR(255) NOT NULL,
  `is_main` BOOLEAN DEFAULT 0,
  `display_order` INT DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`spare_part_id`) REFERENCES `spare_parts`(`id`) ON DELETE CASCADE
);

-- Compatibilidad entre repuestos y vehículos
CREATE TABLE IF NOT EXISTS `spare_part_vehicle` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `spare_part_id` INT NOT NULL,
  `vehicle_id` INT NOT NULL,
  `notes` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`spare_part_id`) REFERENCES `spare_parts`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`) ON DELETE CASCADE
);

-- PROMOCIONES Y MARKETING --

-- Promociones y ofertas de temporada
CREATE TABLE IF NOT EXISTS `promotions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `business_id` INT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `discount_type` ENUM('percentage', 'fixed_amount') DEFAULT 'percentage',
  `discount_value` DECIMAL(10,2) NOT NULL,
  `promotion_type` ENUM('seasonal', 'clearance', 'featured', 'flash_sale') DEFAULT 'seasonal',
  `banner_image` VARCHAR(255),
  `active` BOOLEAN DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`business_id`) REFERENCES `businesses`(`id`) ON DELETE CASCADE
);

-- Relación entre repuestos y promociones
CREATE TABLE IF NOT EXISTS `spare_part_promotion` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `spare_part_id` INT NOT NULL,
  `promotion_id` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`spare_part_id`) REFERENCES `spare_parts`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`promotion_id`) REFERENCES `promotions`(`id`) ON DELETE CASCADE
);

-- INTERACCIÓN DE USUARIOS --

-- Reseñas y calificaciones de productos
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `spare_part_id` INT NOT NULL,
  `rating` TINYINT NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
  `title` VARCHAR(100),
  `comment` TEXT,
  `purchase_verified` BOOLEAN DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`spare_part_id`) REFERENCES `spare_parts`(`id`) ON DELETE CASCADE
);

-- Imágenes de reseñas
CREATE TABLE IF NOT EXISTS `review_images` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `review_id` INT NOT NULL,
  `image_url` VARCHAR(255) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`review_id`) REFERENCES `reviews`(`id`) ON DELETE CASCADE
);

-- Lista de favoritos de usuarios
CREATE TABLE IF NOT EXISTS `wishlists` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `spare_part_id` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`spare_part_id`) REFERENCES `spare_parts`(`id`) ON DELETE CASCADE
);

-- Historial de búsquedas
CREATE TABLE IF NOT EXISTS `search_history` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT,
  `search_query` VARCHAR(255) NOT NULL,
  `search_filters` JSON,
  `results_count` INT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
);

-- CARRITOS Y PEDIDOS --

-- Carrito de compras
CREATE TABLE IF NOT EXISTS `shopping_carts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

-- Items del carrito
CREATE TABLE IF NOT EXISTS `cart_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `cart_id` INT NOT NULL,
  `spare_part_id` INT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`cart_id`) REFERENCES `shopping_carts`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`spare_part_id`) REFERENCES `spare_parts`(`id`) ON DELETE CASCADE
);

-- Pagos
CREATE TABLE IF NOT EXISTS `payments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `business_id` INT NOT NULL,
  `amount` DECIMAL(12,2) NOT NULL,
  `payment_method_id` INT NOT NULL,
  `reference_number` VARCHAR(100),
  `payment_status` ENUM('pending', 'completed', 'rejected', 'refunded') DEFAULT 'pending',
  `payment_date` DATETIME,
  `proof_image` VARCHAR(255),
  `notes` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`business_id`) REFERENCES `businesses`(`id`),
  FOREIGN KEY (`payment_method_id`) REFERENCES `business_payment_methods`(`id`)
);

-- Pedidos
CREATE TABLE IF NOT EXISTS `orders` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `business_id` INT NOT NULL,
  `order_number` VARCHAR(50) NOT NULL UNIQUE,
  `status` ENUM('pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
  `shipping_address` TEXT,
  `shipping_phone` VARCHAR(20),
  `shipping_notes` TEXT,
  `payment_id` INT,
  `subtotal` DECIMAL(10,2) NOT NULL,
  `shipping_cost` DECIMAL(10,2) DEFAULT 0,
  `discount` DECIMAL(10,2) DEFAULT 0,
  `total` DECIMAL(10,2) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`business_id`) REFERENCES `businesses`(`id`),
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`)
);

-- Detalles del pedido
CREATE TABLE IF NOT EXISTS `order_details` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` INT NOT NULL,
  `spare_part_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  `discount` DECIMAL(10,2) DEFAULT 0,
  `total` DECIMAL(10,2) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`spare_part_id`) REFERENCES `spare_parts`(`id`)
);

-- Seguimiento de pedidos
CREATE TABLE IF NOT EXISTS `order_tracking` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` INT NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `notes` TEXT,
  `created_by` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`)
);

-- GESTIÓN DE INVENTARIO Y REPORTES --

-- Historiales de importación de inventario
CREATE TABLE IF NOT EXISTS `inventory_imports` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `business_id` INT NOT NULL,
  `filename` VARCHAR(255) NOT NULL,
  `file_path` VARCHAR(255) NOT NULL,
  `status` ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',
  `report` JSON,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`business_id`) REFERENCES `businesses`(`id`) ON DELETE CASCADE
);

-- Registra cada movimiento de inventario (entradas, salidas, ajustes)
CREATE TABLE IF NOT EXISTS `inventory_movements` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `business_id` INT NOT NULL,
  `spare_part_id` INT NOT NULL,
  `movement_type` ENUM('purchase', 'sale', 'return', 'adjustment', 'import') NOT NULL,
  `quantity` INT NOT NULL,  -- positivo para entradas, negativo para salidas
  `reference_id` INT,  -- ID de orden, importación, etc. relacionado con este movimiento
  `reference_type` VARCHAR(50),  -- 'order', 'import', 'manual_adjustment', etc.
  `previous_stock` INT NOT NULL,
  `current_stock` INT NOT NULL,
  `notes` TEXT,
  `created_by` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`business_id`) REFERENCES `businesses`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`spare_part_id`) REFERENCES `spare_parts`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`)
);

-- Almacena reportes generados
CREATE TABLE IF NOT EXISTS `reports` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `business_id` INT NOT NULL,
  `report_type` VARCHAR(50) NOT NULL,  -- 'inventory', 'sales', 'finance', 'customer', etc.
  `report_name` VARCHAR(100) NOT NULL,
  `parameters` JSON,  -- Filtros y parámetros utilizados para generar el reporte
  `file_path` VARCHAR(255),  -- Ruta al archivo PDF/Excel generado
  `created_by` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`business_id`) REFERENCES `businesses`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`)
);

-- Registra recibos, facturas y otros documentos comerciales
CREATE TABLE IF NOT EXISTS `documents` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `business_id` INT NOT NULL,
  `document_type` ENUM('invoice', 'receipt', 'delivery_note', 'return_form') NOT NULL,
  `document_number` VARCHAR(50) NOT NULL,
  `related_id` INT NOT NULL,  -- ID de orden, pago, etc.
  `related_type` VARCHAR(50) NOT NULL,  -- 'order', 'payment', etc.
  `total_amount` DECIMAL(12,2) NOT NULL,
  `file_path` VARCHAR(255),  -- Ruta al PDF generado
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`business_id`) REFERENCES `businesses`(`id`) ON DELETE CASCADE
);

-- COMUNICACIÓN --

-- Mensajes entre usuarios
CREATE TABLE IF NOT EXISTS `messages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `sender_id` INT NOT NULL,
  `receiver_id` INT NOT NULL,
  `subject` VARCHAR(200),
  `message` TEXT NOT NULL,
  `is_read` BOOLEAN DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`sender_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`receiver_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

-- Notificaciones
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `type` VARCHAR(50) NOT NULL,
  `title` VARCHAR(100) NOT NULL,
  `message` TEXT NOT NULL,
  `is_read` BOOLEAN DEFAULT 0,
  `related_id` INT, -- ID relacionado (puede ser order_id, payment_id, etc.)
  `related_type` VARCHAR(50), -- Tipo de relación (order, payment, etc.)
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

-- ESTADÍSTICAS Y CONFIGURACIÓN --

-- Estadísticas de dashboards (almacenamiento de datos agregados)
CREATE TABLE IF NOT EXISTS `dashboard_stats` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `stat_date` DATE NOT NULL,
  `stat_type` VARCHAR(50) NOT NULL,
  `value` JSON NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);

-- Configuración del sistema
CREATE TABLE IF NOT EXISTS `system_settings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `setting_key` VARCHAR(100) NOT NULL UNIQUE,
  `setting_value` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- AUDITORÍA --

-- Para registro de auditoría de cambios importantes en el sistema
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT,
  `action` VARCHAR(50) NOT NULL,
  `entity_type` VARCHAR(50) NOT NULL,
  `entity_id` INT NOT NULL,
  `old_values` JSON,
  `new_values` JSON,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
);

-- Índices para mejorar el rendimiento
ALTER TABLE `spare_parts` ADD INDEX `idx_featured` (`featured`);
ALTER TABLE `spare_parts` ADD INDEX `idx_category` (`category_id`);
ALTER TABLE `spare_parts` ADD INDEX `idx_business` (`business_id`);
ALTER TABLE `spare_parts` ADD INDEX `idx_price` (`price`);
ALTER TABLE `spare_parts` ADD INDEX `idx_stock` (`stock`);
ALTER TABLE `spare_parts` ADD INDEX `idx_sales` (`sales_count`);
ALTER TABLE `vehicles` ADD INDEX `idx_model_year` (`model_id`, `year`);
ALTER TABLE `spare_part_vehicle` ADD INDEX `idx_compatibility` (`spare_part_id`, `vehicle_id`);
ALTER TABLE `orders` ADD INDEX `idx_user` (`user_id`);
ALTER TABLE `orders` ADD INDEX `idx_business` (`business_id`);
ALTER TABLE `orders` ADD INDEX `idx_status` (`status`);
ALTER TABLE `reviews` ADD INDEX `idx_product_rating` (`spare_part_id`, `rating`);
ALTER TABLE `inventory_movements` ADD INDEX `idx_movement_type` (`movement_type`);
ALTER TABLE `audit_logs` ADD INDEX `idx_entity_action` (`entity_type`, `action`);
```

# 📊 ER DIAGRAM (MERMAID)
```mermaid
flowchart TD
    %% Estilo
    classDef table fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#333,font-family:Arial
    
    %% SISTEMA DE USUARIOS
    
    Users["Users
    --
    id INT PK
    name VARCHAR(100)
    email VARCHAR(150)
    password VARCHAR(256)
    role ENUM
    profile_image VARCHAR(255)"]
    class Users table

    Businesses["Businesses
    --
    id INT PK
    user_id INT FK
    business_name VARCHAR(150)
    rif VARCHAR(20)
    location_lat DECIMAL
    location_lng DECIMAL"]
    class Businesses table

    BusinessPaymentMethods["Business Payment Methods
    --
    id INT PK
    business_id INT FK
    payment_type ENUM
    account_details JSON
    is_active BOOLEAN"]
    class BusinessPaymentMethods table

    %% CATÁLOGO
    
    Categories["Categories
    --
    id INT PK
    name VARCHAR(100)
    description TEXT
    image VARCHAR(255)
    parent_id INT FK"]
    class Categories table
    
    Brands["Brands
    --
    id INT PK
    name VARCHAR(100)
    logo VARCHAR(255)"]
    class Brands table

    Models["Models
    --
    id INT PK
    brand_id INT FK
    name VARCHAR(100)"]
    class Models table

    Vehicles["Vehicles
    --
    id INT PK
    model_id INT FK
    year INT
    engine VARCHAR(100)"]
    class Vehicles table

    SpareParts["Spare Parts
    --
    id INT PK
    business_id INT FK
    category_id INT FK
    name VARCHAR(200)
    oem_code VARCHAR(100)
    price DECIMAL(10,2)
    stock INT
    featured BOOLEAN
    condition ENUM"]
    class SpareParts table

    SparePartImages["Spare Part Images
    --
    id INT PK
    spare_part_id INT FK
    image_url VARCHAR(255)
    is_main BOOLEAN"]
    class SparePartImages table

    SparePartVehicle["Spare Part Vehicle
    --
    id INT PK
    spare_part_id INT FK
    vehicle_id INT FK"]
    class SparePartVehicle table

    %% PROMOCIONES
    
    Promotions["Promotions
    --
    id INT PK
    business_id INT FK
    name VARCHAR(100)
    start_date DATE
    end_date DATE
    discount_type ENUM
    promotion_type ENUM"]
    class Promotions table

    SparePartPromotion["Spare Part Promotion
    --
    id INT PK
    spare_part_id INT FK
    promotion_id INT FK"]
    class SparePartPromotion table

    %% INTERACCIÓN

    Reviews["Reviews
    --
    id INT PK
    user_id INT FK
    spare_part_id INT FK
    rating TINYINT
    comment TEXT"]
    class Reviews table

    ReviewImages["Review Images
    --
    id INT PK
    review_id INT FK
    image_url VARCHAR(255)"]
    class ReviewImages table

    ShoppingCarts["Shopping Carts
    --
    id INT PK
    user_id INT FK"]
    class ShoppingCarts table

    CartItems["Cart Items
    --
    id INT PK
    cart_id INT FK
    spare_part_id INT FK
    quantity INT"]
    class CartItems table

    %% VENTAS

    Payments["Payments
    --
    id INT PK
    user_id INT FK
    business_id INT FK
    amount DECIMAL(12,2)
    payment_method_id INT FK
    payment_status ENUM"]
    class Payments table

    Orders["Orders
    --
    id INT PK
    user_id INT FK
    business_id INT FK
    order_number VARCHAR(50)
    status ENUM
    payment_id INT FK
    total DECIMAL(10,2)"]
    class Orders table

    OrderDetails["Order Details
    --
    id INT PK
    order_id INT FK
    spare_part_id INT FK
    quantity INT
    unit_price DECIMAL(10,2)"]
    class OrderDetails table

    OrderTracking["Order Tracking
    --
    id INT PK
    order_id INT FK
    status VARCHAR(50)
    created_by INT FK"]
    class OrderTracking table

    %% INVENTARIO Y REPORTES

    InventoryImports["Inventory Imports
    --
    id INT PK
    business_id INT FK
    filename VARCHAR(255)
    status ENUM"]
    class InventoryImports table

    InventoryMovements["Inventory Movements
    --
    id INT PK
    business_id INT FK
    spare_part_id INT FK
    movement_type ENUM
    quantity INT
    previous_stock INT
    current_stock INT"]
    class InventoryMovements table

    Reports["Reports
    --
    id INT PK
    business_id INT FK
    report_type VARCHAR(50)
    parameters JSON
    file_path VARCHAR(255)"]
    class Reports table

    Documents["Documents
    --
    id INT PK
    business_id INT FK
    document_type ENUM
    related_id INT
    file_path VARCHAR(255)"]
    class Documents table

    %% COMUNICACIÓN

    Messages["Messages
    --
    id INT PK
    sender_id INT FK
    receiver_id INT FK
    message TEXT
    is_read BOOLEAN"]
    class Messages table

    Notifications["Notifications
    --
    id INT PK
    user_id INT FK
    type VARCHAR(50)
    title VARCHAR(100)
    is_read BOOLEAN"]
    class Notifications table

    %% AUDITORÍA

    AuditLogs["Audit Logs
    --
    id INT PK
    user_id INT FK
    action VARCHAR(50)
    entity_type VARCHAR(50)
    entity_id INT
    old_values JSON
    new_values JSON"]
    class AuditLogs table

    %% SISTEMA DE USUARIOS
    Users --> |"1:1"| Businesses
    Businesses --> |"1:N"| BusinessPaymentMethods

    %% CATÁLOGO
    Categories --> |"1:N"| SpareParts
    Categories --> |"1:N"| Categories
    
    Brands --> |"1:N"| Models
    Models --> |"1:N"| Vehicles
    
    SpareParts --> |"1:N"| SparePartImages
    SpareParts --> |"N:M"| Vehicles
    SparePartVehicle --> |"N:1"| SpareParts
    SparePartVehicle --> |"N:1"| Vehicles
    
    Businesses --> |"1:N"| SpareParts
    
    %% PROMOCIONES
    Businesses --> |"1:N"| Promotions
    Promotions --> |"N:M"| SpareParts
    SparePartPromotion --> |"N:1"| SpareParts
    SparePartPromotion --> |"N:1"| Promotions
    
    %% INTERACCIÓN
    Users --> |"1:N"| Reviews
    SpareParts --> |"1:N"| Reviews
    Reviews --> |"1:N"| ReviewImages
    
    Users --> |"1:N"| ShoppingCarts
    ShoppingCarts --> |"1:N"| CartItems
    CartItems --> |"N:1"| SpareParts
    
    %% VENTAS
    Users --> |"1:N"| Orders
    Businesses --> |"1:N"| Orders
    Orders --> |"1:N"| OrderDetails
    OrderDetails --> |"N:1"| SpareParts
    Orders --> |"N:1"| Payments
    Payments --> |"N:1"| BusinessPaymentMethods
    Orders --> |"1:N"| OrderTracking
    
    %% INVENTARIO Y REPORTES
    Businesses --> |"1:N"| InventoryImports
    Businesses --> |"1:N"| InventoryMovements
    SpareParts --> |"1:N"| InventoryMovements
    Businesses --> |"1:N"| Reports
    Businesses --> |"1:N"| Documents
    
    %% COMUNICACIÓN
    Users --> |"1:N"| Messages
    Users --> |"1:N"| Notifications
    
    %% AUDITORÍA
    Users --> |"1:N"| AuditLogs
```


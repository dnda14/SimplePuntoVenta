# 🛒 Producto Calculador - Sales Point App

A Flutter-based point of sale (POS) application for small businesses. This app allows users to manage product inventory, create sales receipts (boletas), and process transactions with an intuitive interface.

---

## 📱 Features

### Core Functionality
- ✅ **Product Search** - Fuzzy search to quickly find products
- ✅ **Flexible Pricing** - Support for unit, package, and box pricing
- ✅ **Shopping Cart** - Add, edit, and remove items from boleta
- ✅ **Real-time Totals** - Live calculation of subtotals and final total
- ✅ **Receipt Generation** - Create detailed sales receipts
- ✅ **Transaction Processing** - Complete sales with confirmation

### User Interface
- 🎨 **Material Design 3** - Modern, clean interface
- 📱 **Responsive Layout** - Works on different screen sizes
- 🔄 **Real-time Updates** - Instant UI updates using Provider
- 🎯 **Intuitive Navigation** - Easy-to-use workflow
- 💡 **Visual Feedback** - SnackBars, badges, and loading indicators

### Advanced Features
- 🔍 **Smart Search** - Fuzzy matching for product names
- 📦 **Multiple Unit Types** - Handle units, packages, and boxes
- ✏️ **Editable Cart** - Modify quantities and remove items
- 🧮 **Automatic Grouping** - Groups similar items in receipt
- 💾 **State Management** - Uses Provider for efficient state handling

---

## 🏗️ Architecture

### State Management
- **Provider Pattern** - Centralized state management with `BoletaProvider`
- **Reactive UI** - Automatic updates when cart changes
- **Clean Separation** - Business logic separated from UI

### File Structure
lib/
├── main.dart # App entry point with Provider setup
├── boleta_provider.dart # State management for shopping cart
├── home_screen.dart # Main product selection screen
├── boleta_screen.dart # Receipt/cart management screen
├── producto.dart # Product model with pricing tiers
├── item_boleta.dart # Cart item model
└── producto_service.dart # Product data loading service


### Data Models
- **Producto** - Product with flexible pricing (unit/pack/box)
- **ItemBoleta** - Cart item with quantity and type
- **BoletaProvider** - Cart state management with CRUD operations

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions

### Installation
1. Clone the repository
```bash
git clone <repository-url>
cd producto_calculador
```
2. Install dependencies
```powershell
flutter pub get
```
3.Create product data file
Create assets/productos.json with your product data:
```json
[
  {
    "nombre": "Coca Cola 500ml",
    "precioUnidad": 2.50,
    "precioPaquete": 12.00,
    "precioCaja": 48.00,
    "unidXPaquete": 6,
    "paqueteXCja": 4
  },
  {
    "nombre": "Pan Frances",
    "precioUnidad": 0.30
  }
]
```
1. Update pubspec.yml
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  logger: ^2.0.2+1

flutter:
  assets:
    - assets/productos.json
```

5. Run the app
```powershell
flutter run
```
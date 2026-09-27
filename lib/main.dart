import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ColonelPOS());
}

class ColonelPOS extends StatelessWidget {
  const ColonelPOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colonel POS V6',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
        scaffoldBackgroundColor: const Color(0xfff7f7f7),
      ),
      home: const LoginPage(),
    );
  }
}

/* =========================
   MODELS
========================= */

class Product {
  String id;
  String name;
  double price;
  int stock;
  String category;
  bool active;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.stock = 0,
    this.category = 'Menu',
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'category': category,
        'active': active,
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'],
        name: j['name'],
        price: (j['price'] as num).toDouble(),
        stock: j['stock'] ?? 0,
        category: j['category'] ?? 'Menu',
        active: j['active'] ?? true,
      );
}

class AppUser {
  String username;
  String password;
  String role;
  bool active;

  AppUser({
    required this.username,
    required this.password,
    required this.role,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'role': role,
        'active': active,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        username: j['username'],
        password: j['password'],
        role: j['role'],
        active: j['active'] ?? true,
      );
}

class CartItem {
  Product product;
  int qty;

  CartItem({
    required this.product,
    required this.qty,
  });

  double get total => product.price * qty;
}

class Sale {
  String id;
  String date;
  String cashier;
  List<Map<String, dynamic>> items;
  double subtotal;
  double discount;
  double total;
  String payment;
  double cash;
  double change;
  bool returned;

  Sale({
    required this.id,
    required this.date,
    required this.cashier,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.payment,
    required this.cash,
    required this.change,
    this.returned = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'cashier': cashier,
        'items': items,
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'payment': payment,
        'cash': cash,
        'change': change,
        'returned': returned,
      };

  factory Sale.fromJson(Map<String, dynamic> j) => Sale(
        id: j['id'],
        date: j['date'],
        cashier: j['cashier'],
        items: List<Map<String, dynamic>>.from(
          (j['items'] as List).map((e) => Map<String, dynamic>.from(e)),
        ),
        subtotal: (j['subtotal'] as num).toDouble(),
        discount: (j['discount'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
        payment: j['payment'],
        cash: (j['cash'] as num).toDouble(),
        change: (j['change'] as num).toDouble(),
        returned: j['returned'] ?? false,
      );
}

/* =========================
   STORAGE
========================= */

class Store {
  static String name = 'Colonel Fried Chicken';
  static String address = '';
  static String phone = '';
  static String qrisInfo = '';

  static List<Product> products = [];
  static List<AppUser> users = [];
  static List<Sale> sales = [];

  static Future<void> init() async {
    final p = await SharedPreferences.getInstance();

    name = p.getString('store_name') ?? 'Colonel Fried Chicken';
    address = p.getString('store_address') ?? '';
    phone = p.getString('store_phone') ?? '';
    qrisInfo = p.getString('qris_info') ?? '';

    final productsRaw = p.getString('products');

    if (productsRaw == null) {
      products = [
        Product(id: '1', name: 'Dada', price: 12000, stock: 20),
        Product(id: '2', name: 'Paha Atas', price: 12000, stock: 20),
        Product(id: '3', name: 'Paha Bawah', price: 9000, stock: 20),
        Product(id: '4', name: 'Sayap', price: 9000, stock: 20),
        Product(id: '5', name: 'Paket Dada', price: 15500, stock: 20),
        Product(id: '6', name: 'Paket Paha Atas', price: 15500, stock: 20),
        Product(id: '7', name: 'Paket Paha Bawah', price: 12500, stock: 20),
        Product(id: '8', name: 'Paket Sayap', price: 12500, stock: 20),
        Product(id: '9', name: 'Sambal Geprek', price: 3000, stock: 50),
        Product(id: '10', name: 'Kentang Goreng', price: 8000, stock: 20),
        Product(id: '11', name: 'Air Mineral', price: 4000, stock: 50),
        Product(id: '12', name: 'Es Teh', price: 4000, stock: 50),
      ];
      await saveProducts();
    } else {
      products = (jsonDecode(productsRaw) as List)
          .map((e) => Product.fromJson(e))
          .toList();
    }

    final usersRaw = p.getString('users');

    if (usersRaw == null) {
      users = [
        AppUser(
          username: 'admin',
          password: '1234',
          role: 'Admin',
        ),
        AppUser(
          username: 'kasir',
          password: '1234',
          role: 'Kasir',
        ),
      ];
      await saveUsers();
    } else {
      users = (jsonDecode(usersRaw) as List)
          .map((e) => AppUser.fromJson(e))
          .toList();
    }

    final salesRaw = p.getString('sales');

    if (salesRaw == null) {
      sales = [];
    } else {
      sales = (jsonDecode(salesRaw) as List)
          .map((e) => Sale.fromJson(e))
          .toList();
    }
  }

  static Future<void> saveProducts() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'products',
      jsonEncode(products.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> saveUsers() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'users',
      jsonEncode(users.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> saveSales() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'sales',
      jsonEncode(sales.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> saveSettings() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('store_name', name);
    await p.setString('store_address', address);
    await p.setString('store_phone', phone);
    await p.setString('qris_info', qrisInfo);
  }
}

/* =========================
   LOGIN
========================= */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool obscure = true;

  Future<void> login() async {
    setState(() => loading = true);

    await Store.init();

    final user = Store.users.where(
      (u) =>
          u.username == username.text.trim() &&
          u.password == password.text &&
          u.active,
    );

    if (user.isEmpty) {
      setState(() => loading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username/password salah atau user tidak aktif'),
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(user: user.first),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'CP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      Store.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'POINT OF SALE V6',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: username,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: password,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => obscure = !obscure);
                          },
                          icon: Icon(
                            obscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: loading ? null : login,
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('LOGIN'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================
   DASHBOARD
========================= */

class DashboardPage extends StatefulWidget {
  final AppUser user;

  const DashboardPage({
    super.key,
    required this.user,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(user: widget.user),
      POSPage(user: widget.user),
      ReportsPage(user: widget.user),
      if (widget.user.role == 'Admin') AdminPage(user: widget.user),
    ];

    final labels = [
      'Dashboard',
      'Kasir',
      'Laporan',
      if (widget.user.role == 'Admin') 'Admin',
    ];

    final icons = [
      Icons.dashboard,
      Icons.point_of_sale,
      Icons.receipt_long,
      if (widget.user.role == 'Admin') Icons.admin_panel_settings,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(Store.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                  (_) => false,
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() => index = i);
        },
        destinations: [
          for (int i = 0; i < labels.length; i++)
            NavigationDestination(
              icon: Icon(icons[i]),
              label: labels[i],
            ),
        ],
      ),
    );
  }
}

/* =========================
   HOME
========================= */

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({
    super.key,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double get omzet => Store.sales
      .where((s) => !s.returned)
      .fold(0, (sum, s) => sum + s.total);

  int get transactions =>
      Store.sales.where((s) => !s.returned).length;

  int get items => Store.sales
      .where((s) => !s.returned)
      .fold<int>(0, (sum, s) {
        return sum +
            s.items.fold<int>(
              0,
              (a, b) => a + ((b['qty'] ?? 0) as int),
            );
      });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Store.init();
        setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Selamat datang, ${widget.user.username}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount:
                MediaQuery.of(context).size.width > 700 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              statCard(
                'Omzet',
                rupiah(omzet),
                Icons.payments,
              ),
              statCard(
                'Transaksi',
                '$transactions',
                Icons.receipt,
              ),
              statCard(
                'Item Terjual',
                '$items',
                Icons.shopping_cart,
              ),
              statCard(
                'QRIS',
                '${Store.sales.where((s) => s.payment == 'QRIS').length}',
                Icons.qr_code,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Ringkasan Stok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...Store.products
              .where((p) => p.active && p.stock <= 5)
              .map(
                (p) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.warning_amber,
                      color: Colors.orange,
                    ),
                    title: Text(p.name),
                    trailing: Text(
                      '${p.stock}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          if (Store.products.where((p) => p.active && p.stock <= 5).isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text('Tidak ada stok yang hampir habis'),
              ),
            ),
        ],
      ),
    );
  }

  Widget statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   POS
========================= */

class POSPage extends StatefulWidget {
  final AppUser user;

  const POSPage({
    super.key,
    required this.user,
  });

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final List<CartItem> cart = [];
  final discountController = TextEditingController(text: '0');

  String category = 'Semua';

  double get subtotal =>
      cart.fold(0, (sum, item) => sum + item.total);

  double get discount =>
      double.tryParse(discountController.text) ?? 0;

  double get total =>
      (subtotal - discount).clamp(0, double.infinity);

  List<Product> get displayedProducts {
    return Store.products.where((p) {
      if (!p.active) return false;
      if (category == 'Semua') return true;
      return p.category == category;
    }).toList();
  }

  void addProduct(Product p) {
    if (p.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${p.name} stok habis')),
      );
      return;
    }

    final existing = cart.where((e) => e.product.id == p.id);

    if (existing.isEmpty) {
      setState(() {
        cart.add(CartItem(product: p, qty: 1));
      });
    } else {
      final item = existing.first;

      if (item.qty >= p.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok tidak mencukupi')),
        );
        return;
      }

      setState(() => item.qty++);
    }
  }

  void decrease(CartItem item) {
    setState(() {
      if (item.qty > 1) {
        item.qty--;
      } else {
        cart.remove(item);
      }
    });
  }

  Future<void> checkout() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => PaymentDialog(
        total: total,
        onPay: (payment, cash) async {
          final change = cash - total;

          if (payment == 'Cash' && cash < total) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Uang tunai kurang')),
            );
            return;
          }

          for (final item in cart) {
            item.product.stock -= item.qty;
          }

          final now = DateTime.now();

          final sale = Sale(
            id: 'TRX-${now.millisecondsSinceEpoch}',
            date: now.toIso8601String(),
            cashier: widget.user.username,
            items: cart
                .map(
                  (e) => {
                    'name': e.product.name,
                    'qty': e.qty,
                    'price': e.product.price,
                    'total': e.total,
                  },
                )
                .toList(),
            subtotal: subtotal,
            discount: discount,
            total: total,
            payment: payment,
            cash: cash,
            change: change,
          );

          Store.sales.insert(0, sale);

          await Store.saveProducts();
          await Store.saveSales();

          if (!mounted) return;

          Navigator.pop(context);

          setState(() {
            cart.clear();
            discountController.text = '0';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Transaksi berhasil. Kembalian: ${rupiah(change)}',
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.of(context).size.width >= 700;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: tablet
          ? Row(
              children: [
                Expanded(flex: 3, child: productArea()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: cartArea()),
              ],
            )
          : Column(
              children: [
                Expanded(child: productArea()),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  child: cartArea(),
                ),
              ],
            ),
    );
  }

  Widget productArea() {
    final categories = <String>{'Semua'};
    for (final p in Store.products) {
      categories.add(p.category);
    }

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) {
                        setState(() => category = c);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.of(context).size.width >= 900 ? 4 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.05,
            ),
            itemCount: displayedProducts.length,
            itemBuilder: (_, i) {
              final p = displayedProducts[i];

              return Card(
                child: InkWell(
                  onTap: () => addProduct(p),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.fastfood,
                          size: 35,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(rupiah(p.price)),
                        Text(
                          'Stok: ${p.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            color: p.stock <= 5
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget cartArea() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Keranjang',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: cart.isEmpty
                  ? const Center(
                      child: Text('Belum ada item'),
                    )
                  : ListView(
                      children: cart
                          .map(
                            (item) => ListTile(
                              dense: true,
                              title: Text(item.product.name),
                              subtitle: Text(
                                '${rupiah(item.product.price)} x ${item.qty}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        decrease(item),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Text('${item.qty}'),
                                  IconButton(
                                    onPressed: () =>
                                        addProduct(item.product),
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Diskon',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text(rupiah(subtotal)),
              ],
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Diskon'),
                Text(rupiah(discount)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  rupiah(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: checkout,
                icon: const Icon(Icons.payment),
                label: const Text('BAYAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   PAYMENT
========================= */

class PaymentDialog extends StatefulWidget {
  final double total;
  final Future<void> Function(String payment, double cash) onPay;

  const PaymentDialog({
    super.key,
    required this.total,
    required this.onPay,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String payment = 'Cash';
  final cashController = TextEditingController();

  double get cash =>
      double.tryParse(cashController.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final change = cash - widget.total;

    return AlertDialog(
      title: const Text('Pembayaran'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total ${rupiah(widget.total)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 15),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Cash',
                  label: Text('Cash'),
                  icon: Icon(Icons.payments),
                ),
                ButtonSegment(
                  value: 'QRIS',
                  label: Text('QRIS'),
                  icon: Icon(Icons.qr_code),
                ),
              ],
              selected: {payment},
              onSelectionChanged: (s) {
                setState(() => payment = s.first);
              },
            ),
            const SizedBox(height: 15),
            if (payment == 'Cash') ...[
              TextField(
                controller: cashController,
                autofocus: true,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Uang diterima',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kembalian: ${rupiah(change < 0 ? 0 : change)}',
              ),
            ] else ...[
              const Icon(
                Icons.qr_code_2,
                size: 100,
              ),
              Text(
                Store.qrisInfo.isEmpty
                    ? 'QRIS belum dikonfigurasi'
                    : Store.qrisInfo,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () async {
            await widget.onPay(
              payment,
              payment == 'QRIS'
                  ? widget.total
                  : cash,
            );
          },
          child: const Text('SELESAI'),
        ),
      ],
    );
  }
}

/* =========================
   REPORTS
========================= */

class ReportsPage extends StatefulWidget {
  final AppUser user;

  const ReportsPage({
    super.key,
    required this.user,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String filter = 'Hari Ini';

  List<Sale> get filtered {
    final now = DateTime.now();

    return Store.sales.where((s) {
      final d = DateTime.tryParse(s.date);

      if (d == null) return false;

      if (filter == 'Semua') return true;

      if (filter == 'Hari Ini') {
        return d.year == now.year &&
            d.month == now.month &&
            d.day == now.day;
      }

      if (filter == 'Minggu') {
        final start = now.subtract(
          Duration(days: now.weekday - 1),
        );
        return d.isAfter(
              DateTime(start.year, start.month, start.day),
            ) ||
            d.isAtSameMomentAs(
              DateTime(start.year, start.month, start.day),
            );
      }

      if (filter == 'Bulan') {
        return d.year == now.year && d.month == now.month;
      }

      return true;
    }).toList();
  }

  double get omzet =>
      filtered.where((s) => !s.returned).fold(
            0,
            (sum, s) => sum + s.total,
          );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            children: [
              for (final f in [
                'Hari Ini',
                'Minggu',
                'Bulan',
                'Semua',
              ])
                ChoiceChip(
                  label: Text(f),
                  selected: filter == f,
                  onSelected: (_) {
                    setState(() => filter = f);
                  },
                ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            title: const Text('Omzet'),
            subtitle: Text(
              '${filtered.length} transaksi',
            ),
            trailing: Text(
              rupiah(omzet),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('Belum ada transaksi'),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final s = filtered[i];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Icon(
                          s.returned
                              ? Icons.assignment_return
                              : Icons.receipt_long,
                        ),
                        title: Text(s.id),
                        subtitle: Text(
                          '${s.cashier} • ${s.payment}\n'
                          '${formatDate(s.date)}',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          rupiah(s.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          showSaleDetail(context, s);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void showSaleDetail(BuildContext context, Sale sale) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(sale.id),
        content: SizedBox(
          width: 450,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Kasir: ${sale.cashier}'),
              Text('Tanggal: ${formatDate(sale.date)}'),
              Text('Pembayaran: ${sale.payment}'),
              const Divider(),
              ...sale.items.map(
                (i) => ListTile(
                  dense: true,
                  title: Text(i['name']),
                  subtitle: Text(
                    '${i['qty']} x ${rupiah((i['price'] as num).toDouble())}',
                  ),
                  trailing: Text(
                    rupiah((i['total'] as num).toDouble()),
                  ),
                ),
              ),
              const Divider(),
              Text('Subtotal: ${rupiah(sale.subtotal)}'),
              Text('Diskon: ${rupiah(sale.discount)}'),
              Text(
                'TOTAL: ${rupiah(sale.total)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (sale.payment == 'Cash') ...[
                Text('Cash: ${rupiah(sale.cash)}'),
                Text('Kembalian: ${rupiah(sale.change)}'),
              ],
            ],
          ),
        ),
        actions: [
          if (widget.user.role == 'Admin' && !sale.returned)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                authorizeReturn(sale);
              },
              icon: const Icon(Icons.assignment_return),
              label: const Text('RETUR'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void authorizeReturn(Sale sale) {
    final u = TextEditingController();
    final p = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Otorisasi Retur Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: u,
              decoration: const InputDecoration(
                labelText: 'Username Admin',
              ),
            ),
            TextField(
              controller: p,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Admin',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final ok = Store.users.any(
                (x) =>
                    x.username == u.text.trim() &&
                    x.password == p.text &&
                    x.role == 'Admin' &&
                    x.active,
              );

              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Otorisasi Admin gagal'),
                  ),
                );
                return;
              }

              sale.returned = true;

              for (final item in sale.items) {
                final product = Store.products.where(
                  (p) => p.name == item['name'],
                );

                if (product.isNotEmpty) {
                  product.first.stock += item['qty'] as int;
                }
              }

              await Store.saveProducts();
              await Store.saveSales();

              if (!mounted) return;

              Navigator.pop(context);
              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Retur berhasil. Transaksi asli tetap tersimpan.',
                  ),
                ),
              );
            },
            child: const Text('OTORISASI'),
          ),
        ],
      ),
    );
  }
}

/* =========================
   ADMIN
========================= */

class AdminPage extends StatelessWidget {
  final AppUser user;

  const AdminPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        adminTile(
          context,
          'Menu & Harga',
          Icons.restaurant_menu,
          const ProductManagementPage(),
        ),
        adminTile(
          context,
          'Stok',
          Icons.inventory_2,
          const StockPage(),
        ),
        adminTile(
          context,
          'Pengguna',
          Icons.people,
          const UserManagementPage(),
        ),
        adminTile(
          context,
          'Pengaturan Toko',
          Icons.settings,
          const SettingsPage(),
        ),
        adminTile(
          context,
          'Analitik Penjualan',
          Icons.analytics,
          const AnalyticsPage(),
        ),
        adminTile(
          context,
          'Backup',
          Icons.backup,
          const BackupPage(),
        ),
      ],
    );
  }

  Widget adminTile(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}

/* =========================
   PRODUCTS
========================= */

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() =>
      _ProductManagementPageState();
}

class _ProductManagementPageState
    extends State<ProductManagementPage> {
  void editProduct(Product? product) {
    final name = TextEditingController(
      text: product?.name ?? '',
    );
    final price = TextEditingController(
      text: product?.price.toStringAsFixed(0) ?? '',
    );
    final stock = TextEditingController(
      text: product?.stock.toString() ?? '0',
    );
    final category = TextEditingController(
      text: product?.category ?? 'Menu',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          product == null ? 'Tambah Menu' : 'Edit Menu',
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                ),
              ),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                ),
              ),
              TextField(
                controller: stock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                ),
              ),
              TextField(
                controller: category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final n = double.tryParse(price.text) ?? 0;
              final s = int.tryParse(stock.text) ?? 0;

              if (product == null) {
                Store.products.add(
                  Product(
                    id: DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(),
                    name: name.text,
                    price: n,
                    stock: s,
                    category: category.text,
                  ),
                );
              } else {
                product.name = name.text;
                product.price = n;
                product.stock = s;
                product.category = category.text;
              }

              await Store.saveProducts();

              if (!mounted) return;

              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu & Harga'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => editProduct(null),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: Store.products.length,
        itemBuilder: (_, i) {
          final p = Store.products[i];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            child: ListTile(
              title: Text(p.name),
              subtitle: Text(
                '${rupiah(p.price)} • Stok ${p.stock}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => editProduct(p),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* =========================
   STOCK
========================= */

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  void adjust(Product p) {
    final c = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Stok ${p.name}'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Jumlah stok baru',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final value = int.tryParse(c.text);

              if (value == null) return;

              p.stock = value;

              await Store.saveProducts();

              if (!mounted) return;

              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok'),
      ),
      body: ListView.builder(
        itemCount: Store.products.length,
        itemBuilder: (_, i) {
          final p = Store.products[i];

          return Card(
            child: ListTile(
              leading: Icon(
                p.stock <= 5
                    ? Icons.warning_amber
                    : Icons.inventory_2,
                color: p.stock <= 5
                    ? Colors.orange
                    : null,
              ),
              title: Text(p.name),
              subtitle: Text(
                'Stok saat ini: ${p.stock}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => adjust(p),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* =========================
   USERS
========================= */

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() =>
      _UserManagementPageState();
}

class _UserManagementPageState
    extends State<UserManagementPage> {
  void addUser() {
    final username = TextEditingController();
    final password = TextEditingController();

    String role = 'Kasir';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialog) {
          return AlertDialog(
            title: const Text('Tambah User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                ),
                TextField(
                  controller: password,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(
                      value: 'Kasir',
                      child: Text('Kasir'),
                    ),
                    DropdownMenuItem(
                      value: 'Admin',
                      child: Text('Admin'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setDialog(() => role = v);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () async {
                  if (username.text.trim().isEmpty ||
                      password.text.isEmpty) {
                    return;
                  }

                  Store.users.add(
                    AppUser(
                      username: username.text.trim(),
                      password: password.text,
                      role: role,
                    ),
                  );

                  await Store.saveUsers();

                  if (!mounted) return;

                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengguna'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addUser,
        child: const Icon(Icons.person_add),
      ),
      body: ListView.builder(
        itemCount: Store.users.length,
        itemBuilder: (_, i) {
          final u = Store.users[i];

          return Card(
            child: SwitchListTile(
              value: u.active,
              onChanged: (v) async {
                u.active = v;
                await Store.saveUsers();
                setState(() {});
              },
              title: Text(u.username),
              subtitle: Text(u.role),
              secondary: const Icon(Icons.person),
            ),
          );
        },
      ),
    );
  }
}

/* =========================
   SETTINGS
========================= */

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController name;
  late TextEditingController address;
  late TextEditingController phone;
  late TextEditingController qris;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: Store.name);
    address = TextEditingController(text: Store.address);
    phone = TextEditingController(text: Store.phone);
    qris = TextEditingController(text: Store.qrisInfo);
  }

  Future<void> save() async {
    Store.name = name.text.trim().isEmpty
        ? 'Colonel Fried Chicken'
        : name.text.trim();

    Store.address = address.text.trim();
    Store.phone = phone.text.trim();
    Store.qrisInfo = qris.text.trim();

    await Store.saveSettings();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil disimpan'),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Toko'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Nama toko',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: address,
            decoration: const InputDecoration(
              labelText: 'Alamat',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telepon',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: qris,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Info QRIS / Merchant',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: save,
            icon: const Icon(Icons.save),
            label: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }
}

/* =========================
   ANALYTICS
========================= */

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  Map<String, int> itemSales() {
    final result = <String, int>{};

    for (final sale in Store.sales) {
      if (sale.returned) continue;

      for (final item in sale.items) {
        final name = item['name'] as String;
        final qty = item['qty'] as int;

        result[name] = (result[name] ?? 0) + qty;
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final items = itemSales().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analitik Penjualan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            'Produk Terjual',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Card(
              child: ListTile(
                title: Text('Belum ada data penjualan'),
              ),
            ),
          ...items.map(
            (e) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${e.value}'),
                ),
                title: Text(e.key),
                subtitle: const Text('Jumlah terjual'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Jam Transaksi',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...hourAnalysis(),
        ],
      ),
    );
  }

  List<Widget> hourAnalysis() {
    final hours = <int, int>{};

    for (final sale in Store.sales) {
      if (sale.returned) continue;

      final d = DateTime.tryParse(sale.date);

      if (d != null) {
        hours[d.hour] = (hours[d.hour] ?? 0) + 1;
      }
    }

    final sorted = hours.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .map(
          (e) => Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: Text('${e.key}:00'),
              trailing: Text(
                '${e.value} transaksi',
              ),
            ),
          ),
        )
        .toList();
  }
}

/* =========================
   BACKUP
========================= */

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Data'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Backup HP'),
              subtitle: const Text(
                'Data tersimpan secara lokal di perangkat',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Backup Cloud'),
              subtitle: const Text(
                'Disiapkan untuk sinkronisasi cloud tahap berikutnya',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Backup Email'),
              subtitle: const Text(
                'Disiapkan untuk ekspor melalui email',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   HELPERS
========================= */

String rupiah(double value) {
  final s = value.round().toString();

  final chars = s.split('');
  final result = StringBuffer();

  for (int i = 0; i < chars.length; i++) {
    final pos = chars.length - i;

    result.write(chars[i]);

    if (pos > 1 && pos % 3 == 1) {
      result.write('.');
    }
  }

  return 'Rp $result';
}

String formatDate(String iso) {
  final d = DateTime.tryParse(iso);

  if (d == null) return iso;

  String two(int n) => n.toString().padLeft(2, '0');

  return '${two(d.day)}/${two(d.month)}/${d.year} '
      '${two(d.hour)}:${two(d.minute)}';
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/callapi.dart';
import '../data/product.dart';

class AdminControlPanel extends StatefulWidget {
	const AdminControlPanel({super.key});

	@override
	State<AdminControlPanel> createState() => _AdminControlPanelState();
}

class _AdminControlPanelState extends State<AdminControlPanel> {
	late Future<List<Product>> _productsFuture;
	final _searchController = TextEditingController();
	String _searchQuery = '';

	@override
	void initState() {
		super.initState();
		_loadProducts();
		_searchController.addListener(() {
			setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
		});
	}

	@override
	void dispose() {
		_searchController.dispose();
		super.dispose();
	}

	void _loadProducts() {
		_productsFuture = ProductService.fetchProducts();
	}

	Future<void> _refresh() async {
		setState(_loadProducts);
		await _productsFuture;
	}

	List<Product> _filteredProducts(List<Product> products) {
		if (_searchQuery.isEmpty) {
			return products;
		}

		return products.where((product) {
			return product.productName.toLowerCase().contains(_searchQuery) ||
					product.id.toString().contains(_searchQuery);
		}).toList();
	}

	Future<void> _openProductForm([Product? product]) async {
		final saved = await showDialog<bool>(
			context: context,
			builder: (_) => _ProductFormDialog(product: product),
		);

		if (saved == true && mounted) {
			await _refresh();
			_showMessage(product == null ? 'เพิ่มสินค้าแล้ว' : 'แก้ไขสินค้าแล้ว');
		}
	}

	Future<void> _deleteProduct(Product product) async {
		final confirmed = await showDialog<bool>(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('ลบสินค้า'),
				content: Text('ต้องการลบ "${product.productName}" หรือไม่?'),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context, false),
						child: const Text('ยกเลิก'),
					),
					FilledButton(
						style: FilledButton.styleFrom(backgroundColor: Colors.red),
						onPressed: () => Navigator.pop(context, true),
						child: const Text('ลบสินค้า'),
					),
				],
			),
		);

		if (confirmed != true || !mounted) {
			return;
		}

		try {
			final success = await ProductService.deleteProduct(product.id);
			if (!mounted) return;
			if (success) {
				await _refresh();
				_showMessage('ลบสินค้าแล้ว');
			} else {
				_showMessage('API ไม่สามารถลบสินค้าได้', isError: true);
			}
		} catch (error) {
			if (mounted) _showMessage(error.toString(), isError: true);
		}
	}

	void _showMessage(String message, {bool isError = false}) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: isError ? Colors.red : Colors.green.shade700,
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('จัดการสินค้า'),
				backgroundColor: Colors.green.shade700,
				foregroundColor: Colors.white,
				actions: [
					IconButton(
						tooltip: 'รีเฟรชข้อมูล',
						onPressed: _refresh,
						icon: const Icon(Icons.refresh),
					),
				],
			),
			floatingActionButton: FloatingActionButton.extended(
				onPressed: _openProductForm,
				icon: const Icon(Icons.add),
				label: const Text('เพิ่มสินค้า'),
			),
			body: FutureBuilder<List<Product>>(
				future: _productsFuture,
				builder: (context, snapshot) {
					if (snapshot.connectionState == ConnectionState.waiting) {
						return const Center(child: CircularProgressIndicator());
					}

					if (snapshot.hasError) {
						return _ErrorState(
							message: snapshot.error.toString(),
							onRetry: _refresh,
						);
					}

					final products = snapshot.data ?? const <Product>[];
					final filteredProducts = _filteredProducts(products);
					  return _buildContent(products, filteredProducts);
				},
			),
		);
	}

	Widget _buildContent(List<Product> products, List<Product> filteredProducts) {
		return LayoutBuilder(
			builder: (context, constraints) {
				return ListView(
					padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
					children: [
						_SummaryRow(
							productCount: products.length,
							totalStock: products.fold(0, (total, product) => total + product.stock),
						),
						const SizedBox(height: 20),
						TextField(
							controller: _searchController,
							decoration: InputDecoration(
								labelText: 'ค้นหาสินค้า',
								prefixIcon: const Icon(Icons.search),
								suffixIcon: _searchQuery.isEmpty
										? null
										: IconButton(
												onPressed: _searchController.clear,
												icon: const Icon(Icons.clear),
											),
								border: const OutlineInputBorder(),
							),
						),
						const SizedBox(height: 16),
						if (filteredProducts.isEmpty)
							const Padding(
								padding: EdgeInsets.all(32),
								child: Center(child: Text('ไม่พบสินค้า')),
							)
						else if (constraints.maxWidth >= 760)
							_DesktopProductTable(products: filteredProducts, onEdit: _openProductForm, onDelete: _deleteProduct)
						else
							...filteredProducts.map(
								(product) => _ProductListTile(
									product: product,
									onEdit: () => _openProductForm(product),
									onDelete: () => _deleteProduct(product),
								),
							),
					],
				);
			},
		);
	}
}

class _SummaryRow extends StatelessWidget {
	const _SummaryRow({required this.productCount, required this.totalStock});

	final int productCount;
	final int totalStock;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Expanded(child: _SummaryCard(title: 'สินค้าทั้งหมด', value: '$productCount', icon: Icons.inventory_2_outlined)),
				const SizedBox(width: 12),
				Expanded(child: _SummaryCard(title: 'สต็อกรวม', value: '$totalStock', icon: Icons.warehouse_outlined)),
			],
		);
	}
}

class _SummaryCard extends StatelessWidget {
	const _SummaryCard({required this.title, required this.value, required this.icon});

	final String title;
	final String value;
	final IconData icon;

	@override
	Widget build(BuildContext context) {
		return Card(
			child: Padding(
				padding: const EdgeInsets.all(16),
				child: Row(
					children: [
						Icon(icon, color: Colors.green.shade700, size: 30),
						const SizedBox(width: 12),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(title, style: Theme.of(context).textTheme.bodySmall),
									Text(value, style: Theme.of(context).textTheme.titleLarge),
								],
							),
						),
					],
				),
			),
		);
	}
}

class _DesktopProductTable extends StatelessWidget {
	const _DesktopProductTable({required this.products, required this.onEdit, required this.onDelete});

	final List<Product> products;
	final ValueChanged<Product> onEdit;
	final ValueChanged<Product> onDelete;

	@override
	Widget build(BuildContext context) {
		return Card(
			clipBehavior: Clip.antiAlias,
			child: SingleChildScrollView(
				scrollDirection: Axis.horizontal,
				child: DataTable(
					columns: const [
						DataColumn(label: Text('รูปภาพ')),
						DataColumn(label: Text('รหัสสินค้า')),
						DataColumn(label: Text('สินค้า')),
						DataColumn(label: Text('ประเภท')),
						DataColumn(label: Text('ราคา')),
						DataColumn(label: Text('ราคาโปร')),
						DataColumn(label: Text('Stock')),
						DataColumn(label: Text('จัดการ')),
					],
					rows: products.map((product) {
						return DataRow(cells: [
							DataCell(_ProductThumbnail(product: product)),
							  DataCell(Text(product.productId)),
							  DataCell(Text('${product.productBrand} ${product.productName}'.trim())),
							  DataCell(Text(product.productType)),
							DataCell(Text('${product.price.toStringAsFixed(2)} ฿')),
							  DataCell(Text('${product.proPrice.toStringAsFixed(2)} ฿')),
							  DataCell(Text('${product.stock}')),
							DataCell(_ActionButtons(onEdit: () => onEdit(product), onDelete: () => onDelete(product))),
						]);
					}).toList(),
				),
			),
		);
	}
}

class _ProductListTile extends StatelessWidget {
	const _ProductListTile({required this.product, required this.onEdit, required this.onDelete});

	final Product product;
	final VoidCallback onEdit;
	final VoidCallback onDelete;

	@override
	Widget build(BuildContext context) {
		return Card(
			child: ListTile(
				leading: _ProductThumbnail(product: product),
				title: Text('${product.productBrand} ${product.productName}'.trim()),
				subtitle: Text(
					'${product.productType} | ${product.price.toStringAsFixed(2)} ฿ | '
					'โปร ${product.proPrice.toStringAsFixed(2)} ฿ | stock ${product.stock}',
				),
				trailing: _ActionButtons(onEdit: onEdit, onDelete: onDelete),
			),
		);
	}
}

class _ProductThumbnail extends StatelessWidget {
	const _ProductThumbnail({required this.product});

	final Product product;

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: 56,
			height: 56,
			child: product.imageUrl.isEmpty
					? const Icon(Icons.image_not_supported_outlined)
					: Image.network(product.imageUrl, fit: BoxFit.contain, errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined)),
		);
	}
}

class _ActionButtons extends StatelessWidget {
	const _ActionButtons({required this.onEdit, required this.onDelete});

	final VoidCallback onEdit;
	final VoidCallback onDelete;

	@override
	Widget build(BuildContext context) {
		return Row(
			mainAxisSize: MainAxisSize.min,
			children: [
				IconButton(tooltip: 'แก้ไข', onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
				IconButton(tooltip: 'ลบ', onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.red)),
			],
		);
	}
}

class _ErrorState extends StatelessWidget {
	const _ErrorState({required this.message, required this.onRetry});

	final String message;
	final VoidCallback onRetry;

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Padding(
				padding: const EdgeInsets.all(24),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						const Icon(Icons.cloud_off, size: 48),
						const SizedBox(height: 12),
						const Text('โหลดข้อมูลสินค้าไม่สำเร็จ'),
						const SizedBox(height: 8),
						Text(message, textAlign: TextAlign.center),
						const SizedBox(height: 12),
						OutlinedButton(onPressed: onRetry, child: const Text('ลองใหม่')),
					],
				),
			),
		);
	}
}

class _ProductFormDialog extends StatefulWidget {
	const _ProductFormDialog({this.product});

	final Product? product;

	@override
	State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
	final _formKey = GlobalKey<FormState>();
	late final TextEditingController _productIdController;
	late final TextEditingController _brandController;
	late final TextEditingController _nameController;
	late final TextEditingController _typeController;
	late final TextEditingController _imageController;
	late final TextEditingController _priceController;
	late final TextEditingController _proPriceController;
	late final TextEditingController _proNameController;
	late final TextEditingController _stockController;
	XFile? _selectedImage;
	bool _isSaving = false;

	@override
	void initState() {
		super.initState();
		_productIdController = TextEditingController(text: widget.product?.productId ?? '');
		_brandController = TextEditingController(text: widget.product?.productBrand ?? '');
		_nameController = TextEditingController(text: widget.product?.productName ?? '');
		_typeController = TextEditingController(text: widget.product?.productType ?? '');
		_imageController = TextEditingController(text: widget.product?.image ?? '');
		_priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
		_proPriceController = TextEditingController(text: widget.product?.proPrice.toString() ?? '0');
		_proNameController = TextEditingController(text: widget.product?.proName ?? '');
		_stockController = TextEditingController(text: widget.product?.stock.toString() ?? '0');
	}

	@override
	void dispose() {
		_productIdController.dispose();
		_brandController.dispose();
		_nameController.dispose();
		_typeController.dispose();
		_imageController.dispose();
		_priceController.dispose();
		_proPriceController.dispose();
		_proNameController.dispose();
		_stockController.dispose();
		super.dispose();
	}

	Future<void> _pickImage() async {
		final picker = ImagePicker();
		final picked = await picker.pickImage(
			source: ImageSource.gallery,
			maxWidth: 1200,
			imageQuality: 85,
		);

		if (picked != null && mounted) {
			setState(() => _selectedImage = picked);
			_imageController.text = picked.name;
		}
	}

	Future<void> _save() async {
		if (!_formKey.currentState!.validate()) return;
		setState(() => _isSaving = true);
		try {
			final name = _nameController.text.trim();
			final productId = _productIdController.text.trim();
			final brand = _brandController.text.trim();
			final type = _typeController.text.trim();
			final hasSelectedNewImage = _selectedImage != null;
			final image = hasSelectedNewImage
					? _imageController.text.trim()
					: (_imageController.text.trim().isEmpty && widget.product != null
							? widget.product!.image
							: _imageController.text.trim());
			final price = double.parse(_priceController.text.trim());
			final proPrice = double.parse(_proPriceController.text.trim());
			final proName = _proNameController.text.trim();
			final stock = int.parse(_stockController.text.trim());
			final saved = widget.product == null
						? await ProductService.createProduct(
							productId: productId,
							brand: brand,
							name: name,
							type: type,
							price: price,
							proPrice: proPrice,
							proName: proName,
							stock: stock,
								image: image,
								imageFile: _selectedImage,
						)
					: await ProductService.updateProduct(
							id: widget.product!.id,
							productId: productId,
							brand: brand,
							name: name,
							type: type,
							image: image,
							price: price,
							proPrice: proPrice,
							proName: proName,
							stock: stock,
							imageFile: _selectedImage,
						);
			if (!mounted) return;
			if (saved) Navigator.pop(context, true);
		} catch (error) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()), backgroundColor: Colors.red));
			}
		} finally {
			if (mounted) setState(() => _isSaving = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		final isEditing = widget.product != null;
		return AlertDialog(
			title: Text(isEditing ? 'แก้ไขสินค้า' : 'เพิ่มสินค้า'),
			content: Form(
				key: _formKey,
				child: SingleChildScrollView(
					child: SizedBox(
						width: 420,
						child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							TextFormField(
								controller: _productIdController,
								decoration: const InputDecoration(labelText: 'รหัสสินค้า', border: OutlineInputBorder()),
								validator: _required,
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _brandController,
								decoration: const InputDecoration(labelText: 'แบรนด์', border: OutlineInputBorder()),
								validator: _required,
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _nameController,
								decoration: const InputDecoration(labelText: 'ชื่อสินค้า', border: OutlineInputBorder()),
								validator: _required,
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _typeController,
								decoration: const InputDecoration(labelText: 'ประเภทสินค้า', border: OutlineInputBorder()),
								validator: _required,
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _imageController,
								decoration: InputDecoration(
									labelText: 'ชื่อไฟล์รูปภาพ',
									border: const OutlineInputBorder(),
									suffixIcon: IconButton(
										tooltip: 'เลือกรูปภาพ',
										onPressed: _pickImage,
										icon: const Icon(Icons.photo_library_outlined),
									),
								),
								validator: _required,
							),
							if (_selectedImage != null) ...[
								const SizedBox(height: 8),
								FutureBuilder<List<int>>(
									future: _selectedImage!.readAsBytes(),
									builder: (context, snapshot) {
										if (!snapshot.hasData) {
											return const SizedBox(
												height: 120,
												child: Center(child: CircularProgressIndicator()),
											);
										}

										return SizedBox(
											height: 120,
											width: double.infinity,
											child: Image.memory(
												Uint8List.fromList(snapshot.data!),
												fit: BoxFit.contain,
											),
										);
									},
								),
							],
							const SizedBox(height: 12),
							TextFormField(
								controller: _priceController,
								keyboardType: const TextInputType.numberWithOptions(decimal: true),
								decoration: const InputDecoration(labelText: 'ราคา', suffixText: '฿', border: OutlineInputBorder()),
								validator: (value) {
									final price = double.tryParse(value?.trim() ?? '');
									return price == null || price < 0 ? 'กรุณากรอกราคาที่ถูกต้อง' : null;
								},
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _proPriceController,
								keyboardType: const TextInputType.numberWithOptions(decimal: true),
								decoration: const InputDecoration(labelText: 'ราคาโปรโมชั่น', suffixText: '฿', border: OutlineInputBorder()),
								validator: _numberValidator,
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _proNameController,
								decoration: const InputDecoration(labelText: 'ชื่อโปรโมชั่น', border: OutlineInputBorder()),
								validator: _required,
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _stockController,
								keyboardType: TextInputType.number,
								decoration: const InputDecoration(labelText: 'จำนวนสินค้าใน stock', border: OutlineInputBorder()),
								validator: (value) {
									final stock = int.tryParse(value?.trim() ?? '');
									return stock == null || stock < 0 ? 'กรุณากรอก stock ที่ถูกต้อง' : null;
								},
							),
						],
					),
				),
			),
			),
			actions: [
				TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: const Text('ยกเลิก')),
				FilledButton.icon(
					onPressed: _isSaving ? null : _save,
					icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
					label: const Text('บันทึก'),
				),
			],
		);
	}

	String? _required(String? value) {
		return value == null || value.trim().isEmpty ? 'กรุณากรอกข้อมูล' : null;
	}

	String? _numberValidator(String? value) {
		final number = double.tryParse(value?.trim() ?? '');
		return number == null || number < 0 ? 'กรุณากรอกตัวเลขที่ถูกต้อง' : null;
	}
}

import 'package:e_commerce_app/feature/authen/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce_app/feature/authen/presentation/screen/login_screen.dart';
import 'package:e_commerce_app/feature/product/domain/entity/product_entity.dart';
import 'package:e_commerce_app/feature/product/presentation/cubit/product_cubit.dart';
import 'package:e_commerce_app/feature/product/presentation/screen/product_detail_screen.dart';
import 'package:e_commerce_app/feature/product/presentation/screen/product_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _priceController = TextEditingController();
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();
  final _categoryIdController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _categoryIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = GetIt.instance<ProductCubit>()..getProducts();
        return cubit;
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLogoutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: const LoginScreen(),
                ),
              ),
              (route) => false,
            );
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F7F9),
          appBar: AppBar(
            title: const Text('San pham'),
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'Them san pham',
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductFormScreen(),
                    ),
                  );
                  if (result != null) {
                    _showSnackBar('Tao san pham thanh cong');
                  }
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return IconButton(
                    tooltip: 'Dang xuat',
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(LogoutRequested());
                          },
                    icon: isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.logout),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _ProductFilterBar(
                priceController: _priceController,
                priceMinController: _priceMinController,
                priceMaxController: _priceMaxController,
                categoryIdController: _categoryIdController,
                onApply: () => _applyFilters(context),
                onClear: () => _clearFilters(context),
              ),
              Expanded(
                child: BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading || state is ProductInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ProductFailure) {
                      return _ProductError(message: state.message);
                    }

                    if (state is ProductSuccess) {
                      if (state.products.isEmpty) {
                        return const Center(child: Text('Chua co san pham.'));
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => context.read<ProductCubit>().goToPage(state.currentPage),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.maxWidth;
                                  final crossAxisCount = width >= 1000
                                      ? 4
                                      : width >= 720
                                          ? 3
                                          : 2;

                                  return GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: state.products.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: width >= 720 ? 0.72 : 0.62,
                                    ),
                                    itemBuilder: (context, index) {
                                      return _ProductCard(
                                          product: state.products[index]);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          _PaginationBar(
                            currentPage: state.currentPage,
                            hasNext: state.hasNext,
                            hasPrevious: state.hasPrevious,
                            onPrevious: () => context.read<ProductCubit>().previousPage(),
                            onNext: () => context.read<ProductCubit>().nextPage(),
                            onGoToPage: (page) => context.read<ProductCubit>().goToPage(page),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _applyFilters(BuildContext context) {
    final price = num.tryParse(_priceController.text.trim());
    final priceMin = num.tryParse(_priceMinController.text.trim());
    final priceMax = num.tryParse(_priceMaxController.text.trim());
    final categoryId = int.tryParse(_categoryIdController.text.trim());

    FocusScope.of(context).unfocus();
    context.read<ProductCubit>().applyFilters(
          price: price,
          priceMin: priceMin,
          priceMax: priceMax,
          categoryId: categoryId,
        );
  }

  void _clearFilters(BuildContext context) {
    _priceController.clear();
    _priceMinController.clear();
    _priceMaxController.clear();
    _categoryIdController.clear();
    FocusScope.of(context).unfocus();
    context.read<ProductCubit>().clearFilters();
  }
}

class _ProductFilterBar extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController priceMinController;
  final TextEditingController priceMaxController;
  final TextEditingController categoryIdController;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const _ProductFilterBar({
    required this.priceController,
    required this.priceMinController,
    required this.priceMaxController,
    required this.categoryIdController,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Row(
          children: [
            _FilterField(
              controller: priceController,
              label: 'Gia',
            ),
            const SizedBox(width: 8),
            _FilterField(
              controller: priceMinController,
              label: 'Gia min',
            ),
            const SizedBox(width: 8),
            _FilterField(
              controller: priceMaxController,
              label: 'Gia max',
            ),
            const SizedBox(width: 8),
            _FilterField(
              controller: categoryIdController,
              label: 'Category ID',
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Loc',
              onPressed: onApply,
              icon: const Icon(Icons.filter_alt),
            ),
            const SizedBox(width: 4),
            IconButton.outlined(
              tooltip: 'Xoa filter',
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _FilterField({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF7F7F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _ProductError extends StatelessWidget {
  final String message;

  const _ProductError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade600,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: context.read<ProductCubit>().getProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Thu lai'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final bool hasNext;
  final bool hasPrevious;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onGoToPage;

  const _PaginationBar({
    required this.currentPage,
    required this.hasNext,
    required this.hasPrevious,
    required this.onPrevious,
    required this.onNext,
    required this.onGoToPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          // Nút Previous
          IconButton(
            tooltip: 'Trang truoc',
            onPressed: hasPrevious ? onPrevious : null,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: hasPrevious
                  ? const Color(0xFF0F766E).withAlpha(25)
                  : null,
              foregroundColor: hasPrevious
                  ? const Color(0xFF0F766E)
                  : Colors.grey,
            ),
          ),

          const SizedBox(width: 8),

          // Các nút số trang – có thể scroll ngang
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageButtons(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Nút Next
          IconButton(
            tooltip: 'Trang sau',
            onPressed: hasNext ? onNext : null,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: hasNext
                  ? const Color(0xFF0F766E).withAlpha(25)
                  : null,
              foregroundColor: hasNext
                  ? const Color(0xFF0F766E)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageButtons() {
    final List<Widget> buttons = [];

    // Hiển thị tối đa 5 nút trang xung quanh trang hiện tại
    int start = (currentPage - 2).clamp(1, currentPage);
    int end = start + 4;

    // Luôn hiển thị trang 1
    if (start > 1) {
      buttons.add(_pageButton(1));
      if (start > 2) {
        buttons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: Colors.grey)),
        ));
      }
    }

    for (int i = start; i <= end; i++) {
      // Nếu không có trang tiếp theo và i > currentPage thì dừng
      if (!hasNext && i > currentPage) break;
      buttons.add(_pageButton(i));
    }

    if (hasNext && end < currentPage + 3) {
      buttons.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('...', style: TextStyle(color: Colors.grey)),
      ));
    }

    return buttons;
  }

  Widget _pageButton(int page) {
    final isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 36,
        height: 36,
        child: TextButton(
          onPressed: isActive ? null : () => onGoToPage(page),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: isActive ? const Color(0xFF0F766E) : null,
            foregroundColor: isActive ? Colors.white : const Color(0xFF374151),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isActive
                  ? BorderSide.none
                  : const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      product.imageCover,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Color(0xFFE5E7EB),
                          child: Center(
                            child: Icon(Icons.image_not_supported_outlined),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(150),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          product.categoryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result =
                              await Navigator.push<Map<String, dynamic>>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductFormScreen(
                                productId: product.id.toString(),
                                initialTitle: product.title,
                                initialPrice: product.price.toDouble(),
                                initialDescription: product.description,
                              ),
                            ),
                          );
                          if (result != null) {
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Cap nhat thanh cong')),
                            );
                          }
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xoa san pham'),
                              content: const Text('Ban co chac chan muon xoa?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Huy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Xoa'),
                                ),
                              ],
                            ),
                          );
                          if (!context.mounted) {
                            return;
                          }
                          if (confirm == true) {
                            final deleted = await context
                                .read<ProductCubit>()
                                .deleteProduct(product.id.toString());
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  deleted
                                      ? 'Xoa san pham thanh cong'
                                      : 'Khong xoa duoc san pham',
                                ),
                                backgroundColor:
                                    deleted ? null : Colors.red.shade700,
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Sua'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xoa', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.categoryName.isEmpty ? 'No category' : product.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F766E),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.price} \$',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

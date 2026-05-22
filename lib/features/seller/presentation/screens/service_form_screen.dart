import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../services/data/repositories/service_repository_impl.dart' as svc;

class ServiceFormScreen extends ConsumerStatefulWidget {
  const ServiceFormScreen({super.key, this.serviceId});

  final String? serviceId;

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  String _category = AppConstants.serviceCategories.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(svc.serviceRepositoryProvider);
      final data = {
        'seller_id': user.id,
        'title': _titleController.text,
        'description': _descController.text,
        'price': double.parse(_priceController.text),
        'category': _category,
        'is_active': true,
      };

      if (widget.serviceId != null) {
        await repo.updateService(widget.serviceId!, data);
      } else {
        await repo.createService(data);
      }

      if (mounted) {
        context.showSnack('Service saved');
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceId == null ? 'Add Service' : 'Edit Service'),
      ),
      body: ContentContainer(
        child: ListView(
          children: [
            AppTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Wedding Photography Package',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descController,
              label: 'Description',
              hint: 'Describe your service...',
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _priceController,
              label: 'Price (${AppConstants.currencySymbol})',
              hint: '15000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: AppConstants.serviceCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Save Service',
              isLoading: _isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

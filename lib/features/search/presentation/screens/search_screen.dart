import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/cards/service_card.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/loading/shimmer_loader.dart';
import '../../../services/presentation/providers/services_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ServicesFilter(search: _query.isEmpty ? null : _query);
    final servicesAsync = ref.watch(servicesProvider(filter));

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ContentContainer(
        child: Column(
          children: [
            AppTextField(
              controller: _controller,
              hint: 'Search services...',
              prefixIcon: Icons.search,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: servicesAsync.when(
                data: (services) => GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.columns(context),
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: services.length,
                  itemBuilder: (_, i) => ServiceCard(
                    service: services[i],
                    index: i,
                    onTap: () =>
                        context.push('/seller/${services[i].sellerId}'),
                  ),
                ),
                loading: () => const ShimmerGrid(),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

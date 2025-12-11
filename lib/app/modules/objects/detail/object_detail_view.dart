import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../widgets/glass_card.dart';
import 'object_detail_controller.dart';

class ObjectDetailView extends GetView<ObjectDetailController> {
  const ObjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Object Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            final obj = controller.object.value;
            if (obj == null) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Get.toNamed(AppRoutes.objectEdit, arguments: obj),
            );
          }),
          Obx(() {
            final obj = controller.object.value;
            if (obj == null) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(context),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Obx(() => _buildContent(context)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final obj = controller.object.value;
    if (obj == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text('Object not found', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, obj.name),
        const SizedBox(height: 24),
        _buildInfoSection(context, obj),
        if (obj.data != null && obj.data!.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildDataSection(context, obj.data!),
        ],
      ],
    );
  }


  Widget _buildHeader(BuildContext context, String name) {
    return GlassCard(
      gradient: AppColors.primaryGradient,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, dynamic obj) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Information', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildInfoRow('ID', obj.id ?? 'N/A'),
        _buildInfoRow('Name', obj.name),
        if (obj.createdAt != null) _buildInfoRow('Created', _formatDate(obj.createdAt)),
        if (obj.updatedAt != null) _buildInfoRow('Updated', _formatDate(obj.updatedAt)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(BuildContext context, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...data.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildInfoRow(entry.key, entry.value?.toString() ?? 'null'),
        )),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove this object?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This action can be undone for 5s.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.deleteObject();
    }
  }
}

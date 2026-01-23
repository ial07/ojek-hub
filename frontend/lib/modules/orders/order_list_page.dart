import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import 'package:get/get.dart';
import '../../routes.dart';
import 'orders_controller.dart';
import 'widgets/order_card.dart';

class OrderListPage extends GetView<OrdersController> {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Lowongan')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.createOrder),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Belum ada lowongan tersedia.'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: controller.refreshOrders,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              return OrderCard(order: controller.orders[index]);
            },
          ),
        );
      }),
    );
  }
}

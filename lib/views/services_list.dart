import 'package:flutter/material.dart';
import 'package:matchmatter/data/service.dart';

class ServicesList extends StatelessWidget {
  final List<Service> services;
  final String searchQuery;
  final Function(Service) onServiceSelected;

  const ServicesList({
    super.key,
    required this.services,
    required this.searchQuery,
    required this.onServiceSelected,
  });

  List<Service> _filterServices() {
    final query = searchQuery.toLowerCase();
    return services.where((service) {
      final serviceMatch = service.name.toLowerCase().contains(query);
      final permissionMatch = service.permissions.any((permission) =>
          permission.name.toLowerCase().contains(query) ||
          permission.data.toString().toLowerCase().contains(query));
      return serviceMatch || permissionMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = _filterServices();

    return ListView.builder(
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        final service = filteredServices[index];
        final tileColor = _getTileColor(service); // 提前计算背景颜色
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              onTap: () {
                onServiceSelected(service);
              },
              child: ListTile(
                tileColor: tileColor, // 设置背景颜色
                title: Text(
                  service.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTileColor(Service service) {
    // 根据服务属性设置背景颜色，这里仅作示例
    if (service.name.toLowerCase().contains('important')) {
      return Colors.red.withOpacity(0.1);
    } else if (service.name.toLowerCase().contains('secondary')) {
      return Colors.blue.withOpacity(0.1);
    } else {
      return const Color.fromARGB(255, 183, 216, 233).withOpacity(0.1); // 默认背景颜色
    }
  }
}

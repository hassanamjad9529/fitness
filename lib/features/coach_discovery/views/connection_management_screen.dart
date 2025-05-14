import 'package:fitness/features/dashboard/models/connection_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/connection_management_controller.dart';
import '../widgets/connection_request_card.dart';

class ConnectionManagementScreen extends StatelessWidget {
  const ConnectionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ConnectionManagementController controller = Get.put(ConnectionManagementController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Connections'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    _buildConnectionList(
                      controller.pendingConnections,
                      controller,
                      context,
                      showActions: true,
                    ),
                    _buildConnectionList(
                      controller.acceptedConnections,
                      controller,
                      context,
                      showActions: false,
                    ),
                    _buildConnectionList(
                      controller.rejectedConnections,
                      controller,
                      context,
                      showActions: false,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildConnectionList(
    List<ConnectionModel> connections,
    ConnectionManagementController controller,
    BuildContext context, {
    required bool showActions,
  }) {
    if (connections.isEmpty) {
      return const Center(child: Text('No connections found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: connections.length,
      itemBuilder: (context, index) {
        final connection = connections[index];
        final student = controller.studentDetails[connection.studentId];
        if (student == null) return const SizedBox.shrink();
        return ConnectionRequestCard(
          student: student,
          status: connection.status,
          onAccept: showActions ? () => controller.acceptConnection(connection.id) : null,
          onReject: showActions ? () => controller.rejectConnection(connection.id) : null,
        );
      },
    );
  }
}
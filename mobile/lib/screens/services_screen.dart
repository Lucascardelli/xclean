import 'package:flutter/material.dart';
import 'package:xclean/models/cleaning_service.dart';
import 'package:xclean/screens/schedule_service_screen.dart';
import 'package:xclean/services/cleaning_service.dart';
import 'package:xclean/utils/constants.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _serviceService = CleaningServiceService();
  List<CleaningService> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final services = await _serviceService.getAvailableServices();
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços Disponíveis'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadServices,
              child: _services.isEmpty
                  ? const Center(
                      child: Text('Nenhum serviço disponível no momento.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (service.images.isNotEmpty)
                                Image.network(
                                  service.images.first,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              Padding(
                                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            service.title,
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                        ),
                                        Text(
                                          'R\$ ${service.price.toStringAsFixed(2)}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      service.description,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Duração: ${service.duration} minutos',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 16, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              service.rating.toStringAsFixed(1),
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                            Text(
                                              ' (${service.totalRatings})',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ScheduleServiceScreen(
                                                service: service,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Agendar'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
} 
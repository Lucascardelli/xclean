import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user.dart';
import '../services/location_service.dart';
import '../widgets/star_rating.dart';

class NearbyProfessionalsScreen extends StatefulWidget {
  const NearbyProfessionalsScreen({Key? key}) : super(key: key);

  @override
  State<NearbyProfessionalsScreen> createState() => _NearbyProfessionalsScreenState();
}

class _NearbyProfessionalsScreenState extends State<NearbyProfessionalsScreen> {
  final LocationService _locationService = LocationService();
  List<User> _professionals = [];
  bool _isLoading = false;
  String _errorMessage = '';
  double _maxDistance = 10.0; // km
  double? _minRating;
  List<String> _selectedServices = [];
  
  final List<String> _availableServices = [
    'Limpeza',
    'Manutenção',
    'Instalação',
    'Inspeção',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Verificar permissão de localização
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Permissão de localização é necessária para buscar profissionais próximos';
          _isLoading = false;
        });
        return;
      }

      // Obter localização atual
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        setState(() {
          _errorMessage = 'Não foi possível obter sua localização';
          _isLoading = false;
        });
        return;
      }

      // Buscar profissionais próximos
      final professionals = await _locationService.getNearbyProfessionals(
        latitude: position.latitude,
        longitude: position.longitude,
        maxDistanceInKm: _maxDistance,
        services: _selectedServices.isEmpty ? null : _selectedServices,
        minRating: _minRating,
      );

      setState(() {
        _professionals = professionals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar profissionais: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profissionais Próximos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfessionals,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_professionals.isEmpty) {
      return const Center(
        child: Text('Nenhum profissional encontrado próximo a você'),
      );
    }

    return ListView.builder(
      itemCount: _professionals.length,
      itemBuilder: (context, index) {
        final professional = _professionals[index];
        return _buildProfessionalCard(professional);
      },
    );
  }

  Widget _buildProfessionalCard(User professional) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: professional.photoUrl != null
                      ? NetworkImage(professional.photoUrl!)
                      : null,
                  child: professional.photoUrl == null
                      ? Text(
                          professional.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        professional.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (professional.rating != null) ...[
                        StarRating(
                          rating: professional.rating!,
                          size: 16,
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (professional.city != null && professional.state != null)
                        Text(
                          '${professional.city}, ${professional.state}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (professional.services != null && professional.services!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: professional.services!.map((service) {
                  return Chip(
                    label: Text(service),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navegar para a tela de agendamento com o profissional selecionado
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => AppointmentScreen(
                  //       professionalId: professional.id,
                  //     ),
                  //   ),
                  // );
                },
                child: const Text('Agendar Serviço'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filtros'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Distância máxima (km):'),
                    Slider(
                      value: _maxDistance,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '${_maxDistance.round()} km',
                      onChanged: (value) {
                        setState(() {
                          _maxDistance = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Avaliação mínima:'),
                    DropdownButton<double?>(
                      value: _minRating,
                      isExpanded: true,
                      hint: const Text('Qualquer avaliação'),
                      items: [
                        const DropdownMenuItem<double?>(
                          value: null,
                          child: Text('Qualquer avaliação'),
                        ),
                        ...List.generate(5, (index) {
                          final rating = index + 1.0;
                          return DropdownMenuItem<double?>(
                            value: rating,
                            child: Text('${rating.toStringAsFixed(1)} ou mais'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _minRating = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Serviços:'),
                    ...List.generate(_availableServices.length, (index) {
                      final service = _availableServices[index];
                      return CheckboxListTile(
                        title: Text(service),
                        value: _selectedServices.contains(service),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedServices.add(service);
                            } else {
                              _selectedServices.remove(service);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadProfessionals();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 
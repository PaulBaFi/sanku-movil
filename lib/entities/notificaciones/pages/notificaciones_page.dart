import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/core/constants/app_dimensions.dart';
import 'package:sanku_pro/core/constants/app_strings.dart';
import 'package:sanku_pro/core/constants/app_text_styles.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/entities/notificaciones/services/notificaciones_firebase_service.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_button_text.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  late Future<List> _clasificacionesNotificacionesFuture;
  late Future<List> _mediosDeEnvioFuture;

  bool _enviarAutomaticoGlobal = false;

  @override
  void initState() {
    super.initState();
    _clasificacionesNotificacionesFuture = getClasificacionesDeNotificaciones();
    _mediosDeEnvioFuture = getMediosDeEnvio();
  }

  Future<void> _refreshClasificaciones() async {
    setState(() {
      _clasificacionesNotificacionesFuture =
          getClasificacionesDeNotificaciones();
    });
    await _clasificacionesNotificacionesFuture;
  }

  Future<void> _refreshMediosEnvio() async {
    setState(() {
      _mediosDeEnvioFuture = getMediosDeEnvio();
    });
    await _mediosDeEnvioFuture;
  }

  void _navigateToAddClasificacion() async {
    await context.push(AppRoutes.clasificacionesAddPage);
    await _refreshClasificaciones();
  }

  void _navigateToEditClasificacion(Map<String, dynamic> clasificacion) async {
    await context.push(AppRoutes.clasificacionesEditPage, extra: clasificacion);
    await _refreshClasificaciones();
  }

  void _navigateToAddMedioEnvio() async {
    await context.push(AppRoutes.medioEnvioAddPage);
    await _refreshMediosEnvio();
  }

  void _navigateToEditMedioEnvio(Map<String, dynamic> medioEnvio) async {
    await context.push(AppRoutes.medioEnvioEditPage, extra: medioEnvio);
    await _refreshMediosEnvio();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: WidgetAppBar(title: 'NOTIFICACIONES'),
      body: WidgetMainLayout(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleNotificaciones(text: 'Clasificación'),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingS,
                  ),
                  child: FutureBuilder(
                    future: _clasificacionesNotificacionesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData ||
                          (snapshot.data as List).isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppDimensions.paddingL),
                            child: Text(
                              'No hay clasificaciones de notificaciones.',
                              style: TextStyle(color: AppColors.textMutedLight),
                            ),
                          ),
                        );
                      }

                      final data = snapshot.data as List;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final clasificacionNotificacion =
                              data[index] as Map<String, dynamic>;
                          final id = clasificacionNotificacion['id'];
                          final nombre =
                              "${clasificacionNotificacion['clasificacion'] ?? ''}"
                                  .trim();

                          return Dismissible(
                            key: Key(id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS,
                                ),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmar eliminación'),
                                  content: Text(
                                    '¿Está seguro de que desea eliminar "$nombre"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                      ),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) async {
                              try {
                                await deleteClasificacionDeNotificacion(id);
                                await _refreshClasificaciones();

                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$nombre eliminada exitosamente',
                                      ),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error al eliminar: $e'),
                                      backgroundColor: AppColors.error,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingM,
                                vertical: AppDimensions.paddingXS,
                              ),
                              title: Text(
                                nombre.isEmpty ? 'Sin nombre' : nombre,
                                style: AppTextStyles.textTheme.titleSmall,
                              ),
                              onTap: () {
                                _navigateToEditClasificacion(
                                  clasificacionNotificacion,
                                );
                              },
                              trailing: const Icon(Icons.chevron_right_rounded),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                WidgetButtonText(
                  text: 'Añadir clasificación',
                  onPressed: _navigateToAddClasificacion,
                ),
                const Divider(color: AppColors.greyLight, thickness: 0.4),
                const SizedBox(height: 10),

                // SECCIÓN MEDIOS DE ENVÍO
                _titleNotificaciones(text: 'Medios de envío'),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingS,
                  ),
                  child: FutureBuilder(
                    future: _mediosDeEnvioFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData ||
                          (snapshot.data as List).isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppDimensions.paddingL),
                            child: Text(
                              'No hay medios de envío configurados.',
                              style: TextStyle(color: AppColors.textMutedLight),
                            ),
                          ),
                        );
                      }

                      final data = snapshot.data as List;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final medioEnvio =
                              data[index] as Map<String, dynamic>;
                          final id = medioEnvio['id'];
                          final nombre = "${medioEnvio['medioEnvio'] ?? ''}"
                              .trim();

                          return Dismissible(
                            key: Key(id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS,
                                ),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmar eliminación'),
                                  content: Text(
                                    '¿Está seguro de que desea eliminar "$nombre"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                      ),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) async {
                              try {
                                await deleteMedioDeEnvio(id);
                                await _refreshMediosEnvio();

                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$nombre eliminado exitosamente',
                                      ),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error al eliminar: $e'),
                                      backgroundColor: AppColors.error,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingM,
                                vertical: AppDimensions.paddingXS,
                              ),
                              title: Text(
                                nombre.isEmpty ? 'Sin nombre' : nombre,
                                style: AppTextStyles.textTheme.titleSmall,
                              ),
                              onTap: () {
                                _navigateToEditMedioEnvio(medioEnvio);
                              },
                              trailing: const Icon(Icons.chevron_right_rounded),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                WidgetButtonText(
                  text: 'Añadir medio de envío',
                  onPressed: _navigateToAddMedioEnvio,
                ),
                const Divider(color: AppColors.greyLight, thickness: 0.4),
                const SizedBox(height: 10),

                // SECCIÓN CONFIGURACIONES
                _titleNotificaciones(text: 'Configuraciones'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: AppDimensions.marginXS,
                  children: [
                    const Expanded(
                      child: Text(
                        'Enviar todas las notificaciones automáticamente',
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: _enviarAutomaticoGlobal,
                        onChanged: (value) {
                          setState(() {
                            _enviarAutomaticoGlobal = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.marginM),
                Text(
                  AppStrings.configuracionInfo,
                  style: AppTextStyles.textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }
}

// ignore: camel_case_types
class _titleNotificaciones extends StatelessWidget {
  const _titleNotificaciones({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text, style: AppTextStyles.textTheme.titleMedium),
        const SizedBox(height: AppDimensions.marginS),
      ],
    );
  }
}

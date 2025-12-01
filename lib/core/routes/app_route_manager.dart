import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/presentation/pages/auth/pages/forget_password_screen.dart';
import 'package:sanku_pro/presentation/pages/auth/services/auth_firebase_service.dart';
import 'app_routes_index.dart';

class RouteManager {
  static final List<String> publicRoutes = [
    AppRoutes.welcome,
    AppRoutes.signin,
    AppRoutes.signup,
  ];

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.welcome,

    // Agregar refreshListenable para reaccionar a cambios de autenticación
    refreshListenable: authService,

    // Agregar redirect para manejar la lógica de autenticación
    redirect: (context, state) {
      final isAuthenticated = authService.value.currentUser != null;
      final isGoingToPublicRoute = publicRoutes.contains(state.matchedLocation);

      // Si no está autenticado y NO va a una ruta pública, redirigir a welcome
      if (!isAuthenticated && !isGoingToPublicRoute) {
        return AppRoutes.welcome;
      }

      // Si está autenticado y va a una ruta pública, redirigir a home
      if (isAuthenticated && isGoingToPublicRoute) {
        return AppRoutes.home;
      }

      // No redirigir
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.signin,
        name: 'signin',
        builder: (context, state) => const SigninScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'change_password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.deleteAccount,
        name: 'delete_account',
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgetPassword,
        name: 'forget_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.profileScreen,
        name: 'profile_screen',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset_password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.updateUsername,
        name: 'update_username',
        builder: (context, state) => const UpdateUsernameScreen(),
      ),

      GoRoute(
        path: AppRoutes.usuarioDetalle,
        name: 'usuario_detalle',
        builder: (context, state) =>
            UsuarioDetallePage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.usuarios,
        name: 'usuarios',
        builder: (context, state) => const UsuariosPage(),
      ),
      GoRoute(
        path: AppRoutes.usuariosAdd,
        name: 'usuarios_add',
        builder: (context, state) => const UsuariosAddPage(),
      ),
      GoRoute(
        path: AppRoutes.usuariosEdit,
        name: 'usuarios_edit',
        builder: (context, state) =>
            UsuariosEditPage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.tipoEmpleado,
        name: 'tipo_empleado',
        builder: (context, state) => const TipoEmpleadoPage(),
      ),
      GoRoute(
        path: AppRoutes.tipoEmpleadoAdd,
        name: 'tipo_empleado_add',
        builder: (context, state) => const TipoEmpleadoAddPage(),
      ),
      GoRoute(
        path: AppRoutes.tipoEmpleadoEdit,
        name: 'tipo_empleado_edit',
        builder: (context, state) =>
            TipoEmpleadoEditPage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.especialidades,
        name: 'especialidades',
        builder: (context, state) => const EspecialidadesPage(),
      ),
      GoRoute(
        path: AppRoutes.especialidadesAdd,
        name: 'especialidad_add',
        builder: (context, state) => const EspecialidadesAddPage(),
      ),
      GoRoute(
        path: AppRoutes.especialidadesEdit,
        name: 'especialidad_edit',
        builder: (context, state) =>
            EspecialidadesEditPage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.empleadoDetalle,
        name: 'empleado_detalle',
        builder: (context, state) =>
            EmpleadoDetallePage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.empleados,
        name: 'empleados',
        builder: (context, state) => const EmpleadosPage(),
      ),
      GoRoute(
        path: AppRoutes.empleadosAdd,
        name: 'empleados_add',
        builder: (context, state) => const EmpleadosAddPage(),
      ),
      GoRoute(
        path: AppRoutes.empleadosEdit,
        name: 'empleados_edit',
        builder: (context, state) =>
            EmpleadosEditPage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.paquetes,
        name: 'paquetes',
        builder: (context, state) => const PaquetesPage(),
      ),
      GoRoute(
        path: AppRoutes.paqueteAdd,
        name: 'paquete_add',
        builder: (context, state) => const PaquetesAddPage(),
      ),
      GoRoute(
        path: AppRoutes.paqueteEdit,
        name: 'paquete_edit',
        builder: (context, state) =>
            PaquetesEditPage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.servicios,
        name: 'servicios',
        builder: (context, state) => const ServiciosPage(),
      ),
      GoRoute(
        path: AppRoutes.servicioAdd,
        name: 'servicio_add',
        builder: (context, state) => const ServiciosAddPage(),
      ),
      GoRoute(
        path: AppRoutes.servicioEdit,
        name: 'servicio_edit',
        builder: (context, state) =>
            ServiciosEditPage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.mediosPago,
        name: 'medios_pago',
        builder: (context, state) => const MediosPagoPage(),
      ),
      GoRoute(
        path: AppRoutes.medioPagoAdd,
        name: 'medio_pago_add',
        builder: (context, state) => const MedioPagoAddPage(),
      ),
      GoRoute(
        path: AppRoutes.medioPagoEdit,
        name: 'medio_pago_edit',
        builder: (context, state) =>
            MedioPagoEditPage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.notificaciones,
        name: 'notificaciones',
        builder: (context, state) => const NotificacionesPage(),
      ),
      GoRoute(
        path: AppRoutes.clasificacionesAddPage,
        name: 'clasificaciones_add',
        builder: (context, state) => const ClasificacionesAddPage(),
      ),
      GoRoute(
        path: AppRoutes.clasificacionesEditPage,
        name: 'clasificaciones_edit',
        builder: (context, state) =>
            ClasificacionesEditPage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.medioEnvioAddPage,
        name: 'medio_envio_add',
        builder: (context, state) => const MedioEnvioAddPage(),
      ),
      GoRoute(
        path: AppRoutes.medioEnvioEditPage,
        name: 'medio_envio_edit',
        builder: (context, state) =>
            MedioEnvioEditPage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.clienteDetalle,
        name: 'cliente_detalle',
        builder: (context, state) =>
            ClienteDetallePage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.clientes,
        name: 'clientes',
        builder: (context, state) => const ClientesPage(),
      ),
      GoRoute(
        path: AppRoutes.clienteAdd,
        name: 'cliente_add',
        builder: (context, state) => const ClientesAddPage(),
      ),
      GoRoute(
        path: AppRoutes.clienteEdit,
        name: 'cliente_edit',
        builder: (context, state) =>
            ClientesEditPage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.inscripciones,
        name: 'inscripciones',
        builder: (context, state) => const InscripcionesPage(),
      ),
      GoRoute(
        path: AppRoutes.inscripcionesDetalle,
        name: 'inscripciones_detalle',
        builder: (context, state) =>
            InscripcionesDetallePage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.inscripcionesAdd,
        name: 'inscripciones_add',
        builder: (context, state) => const InscripcionesAddPage(),
      ),
      GoRoute(
        path: AppRoutes.inscripcionesEdit,
        name: 'inscripciones_edit',
        builder: (context, state) =>
            InscripcionesEditPage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.pagos,
        name: 'pagos',
        builder: (context, state) => const PagosPage(),
      ),
      GoRoute(
        path: AppRoutes.pagoDetalle,
        name: 'pago_detalle',
        builder: (context, state) =>
            PagoDetallePage(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.agenda,
        name: 'agenda',
        builder: (context, state) => const AgendaPage(),
      ),

      GoRoute(
        path: '/clientes/:id/sesiones',
        name: 'cliente-sesiones',
        builder: (context, state) {
          final clienteId = state.pathParameters['id']!;
          final clienteNombre = state.uri.queryParameters['nombre'] ?? '';
          return ClienteSesionesPage(
            clienteId: clienteId,
            clienteNombre: clienteNombre,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => NotFoundPage(uri: state.uri.toString()),
  );
}

class NotFoundPage extends StatefulWidget {
  const NotFoundPage({super.key, required this.uri});

  final String uri;

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Error 404: Ruta no encontrada. ${widget.uri}')),
    );
  }
}

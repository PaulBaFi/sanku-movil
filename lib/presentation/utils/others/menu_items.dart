import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanku_pro/core/routes/app_routes.dart';
import 'package:sanku_pro/presentation/utils/others/open_menu.dart';

final List<Map<String, dynamic>> menuItems = [
  {
    'icon': Icons.badge_outlined,
    'label': 'Empleados',
    'action': (BuildContext context) => context.push(AppRoutes.empleados),
  },
  {
    'icon': Icons.group_outlined,
    'label': 'Usuarios',
    'action': (BuildContext context) => context.push(AppRoutes.usuarios),
  },
  {
    'icon': Icons.assignment_turned_in_outlined,
    'label': 'Inscripciones',
    'action': (BuildContext context) =>
        context.push(AppRoutes.inscripcionesAdd),
  },
  {
    'icon': Icons.payments_outlined,
    'label': 'Pagos',
    'action': (BuildContext context) => context.push(AppRoutes.pagos),
  },
  {
    'icon': Icons.calendar_month_outlined,
    'label': 'Agenda',
    'action': (BuildContext context) => context.push(AppRoutes.agenda),
  },
  {
    'icon': Icons.person_search_outlined,
    'label': 'Clientes',
    'action': (BuildContext context) => context.push(AppRoutes.clientes),
  },
  {
    'icon': Icons.notifications_active_outlined,
    'label': 'Notificaciones',
    'action': (BuildContext context) => context.push(AppRoutes.notificaciones),
  },

  // ESTE ES EL "VER MÁS"
  {
    'icon': Icons.more_horiz_outlined,
    'label': 'Ver más',
    'action': (BuildContext context) => openMenu(context, itemsSinVerMas),
  },
  {
    'icon': Icons.design_services_outlined,
    'label': 'Servicios',
    'action': (BuildContext context) => context.push(AppRoutes.servicios),
  },
  {
    'icon': Icons.account_balance_wallet_outlined,
    'label': 'Medios de pago',
    'action': (BuildContext context) => context.push(AppRoutes.mediosPago),
  },
  {
    'icon': Icons.inventory_outlined,
    'label': 'Paquetes',
    'action': (BuildContext context) => context.push(AppRoutes.paquetes),
  },
  {
    'icon': Icons.history_outlined,
    'label': 'Historiales',
    'action': (BuildContext context) => context.push(AppRoutes.inscripciones),
  },
  /*
  {
    'icon': Icons.track_changes_outlined,
    'label': 'Seguimiento',
    'action': (BuildContext context) => context.push(AppRoutes.seguimiento),
  },
  
  {
    'icon': Icons.event_available_outlined,
    'label': 'Sesiones',
    'action': (BuildContext context) => context.push(AppRoutes.sesiones),
  },
  {
    'icon': Icons.admin_panel_settings_outlined,
    'label': 'Roles',
    'action': (BuildContext context) => context.push(AppRoutes.roles),
  },
  */
  {
    'icon': Icons.work_outline_outlined,
    'label': 'Tipos de empleado',
    'action': (BuildContext context) => context.push(AppRoutes.tipoEmpleado),
  },
  /*
  {
    'icon': Icons.list_alt_outlined,
    'label': 'Lista de espera',
    'action': (BuildContext context) => context.push(AppRoutes.listaEspera),
  },
  */
  {
    'icon': Icons.local_hospital_outlined,
    'label': 'Especialidades',
    'action': (BuildContext context) => context.push(AppRoutes.especialidades),
  },
];

final itemsHastaVerMas = menuItems.take(8).toList();

final itemsSinVerMas = [...menuItems.sublist(0, 7), ...menuItems.sublist(8)];

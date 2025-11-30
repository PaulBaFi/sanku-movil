import 'package:flutter/material.dart';
import 'package:sanku_pro/core/constants/app_colors.dart';
import 'package:sanku_pro/presentation/components/custom_bottom_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_app_bar.dart';
import 'package:sanku_pro/presentation/widgets/widget_main_layout.dart';

class Session {
  final String time;
  final String therapist;
  final String license;
  final bool isProgrammed;
  final String sessionInfo;

  Session({
    required this.time,
    required this.therapist,
    required this.license,
    required this.isProgrammed,
    required this.sessionInfo,
  });
}

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  int selectedDay = 20;

  final Map<int, List<Session>> sessionsByDay = {
    8: [
      Session(
        time: '16:15',
        therapist: 'José Mendoza Soto',
        license: 'Lic. Diego Salazar',
        isProgrammed: true,
        sessionInfo: '4 / 8 sesiones',
      ),
    ],
    10: [
      Session(
        time: '14:00',
        therapist: 'José Mendoza Soto',
        license: 'Lic. Laura Rodriguez',
        isProgrammed: true,
        sessionInfo: '3 / 8 sesiones',
      ),
    ],
    20: [
      Session(
        time: '16:15',
        therapist: 'José Mendoza Soto',
        license: 'Lic. Diego Salazar',
        isProgrammed: true,
        sessionInfo: '4 / 8 sesiones',
      ),
      Session(
        time: '16:15',
        therapist: 'José Mendoza Soto',
        license: 'Lic. Laura Rodriguez',
        isProgrammed: true,
        sessionInfo: '4 / 8 sesiones',
      ),
      Session(
        time: '16:15',
        therapist: 'José Mendoza Soto',
        license: 'Lic. Laura Rodriguez',
        isProgrammed: true,
        sessionInfo: '4 / 8 sesiones',
      ),
      Session(
        time: '16:15',
        therapist: 'José Mendoza Soto',
        license: 'Lic. Diego Salazar',
        isProgrammed: true,
        sessionInfo: '4 / 8 sesiones',
      ),
      Session(
        time: '17:30',
        therapist: 'José Mendoza Soto',
        license: 'Lic. Laura Rodriguez',
        isProgrammed: true,
        sessionInfo: '4 / 8 sesiones',
      ),
      Session(
        time: '17:30',
        therapist: 'José Mendoza Soto',
        license: 'Lic. Laura Rodriguez',
        isProgrammed: false,
        sessionInfo: '4 / 8 sesiones',
      ),
      Session(
        time: '17:30',
        therapist: 'José Mendoza Soto',
        license: 'Lic. Diego Salazar',
        isProgrammed: true,
        sessionInfo: '4 / 8 sesiones',
      ),
      Session(
        time: '17:30',
        therapist: 'José Mendoza Soto',
        license: 'Lic. Laura Rodriguez',
        isProgrammed: true,
        sessionInfo: '4 / 8 sesiones',
      ),
    ],
    22: [
      Session(
        time: '10:00',
        therapist: 'José Mendoza Soto',
        license: 'Lic. Diego Salazar',
        isProgrammed: true,
        sessionInfo: '2 / 8 sesiones',
      ),
    ],
  };

  List<Session> get currentSessions => sessionsByDay[selectedDay] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(title: 'AGENDA'),
      body: WidgetMainLayout(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar sesión',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Calendar
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [8, 10, 13, 15, 17, 20, 22, 24].map((day) {
                  final isSelected = day == selectedDay;
                  final hasSessions = sessionsByDay.containsKey(day);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day;
                      });
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Oct.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                          if (hasSessions && !isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Sessions list
            Expanded(
              child: currentSessions.isEmpty
                  ? Center(
                      child: Text(
                        'No hay sesiones programadas',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: currentSessions.length,
                      itemBuilder: (context, index) {
                        final session = currentSessions[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                session.time,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.therapist,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      session.license,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: session.isProgrammed
                                              ? AppColors.success
                                              : AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        session.isProgrammed
                                            ? 'Programada'
                                            : 'Cancelada',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: session.isProgrammed
                                              ? AppColors.success
                                              : AppColors.error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    session.sessionInfo,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}

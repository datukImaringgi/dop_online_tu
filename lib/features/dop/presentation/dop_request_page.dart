import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/providers/user_session_provider.dart';
import '../data/dop_form_master_provider.dart';
import '../data/dop_list_provider.dart';

class DopRequestPage extends ConsumerStatefulWidget {
  const DopRequestPage({super.key});

  @override
  ConsumerState<DopRequestPage> createState() {
    return _DopRequestPageState();
  }
}

class _DopRequestPageState extends ConsumerState<DopRequestPage> {
  final formKey = GlobalKey<FormState>();

  final workPlanController = TextEditingController();
  final observerController = TextEditingController();
  final notesController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String? selectedJobSiteId;
  String? selectedUnitId;
  String? selectedDriverId;
  String? selectedRouteId;
  String? selectedJsaId;
  String? selectedControlRoomId;

  String selectedAreaType = 'site';
  String selectedShift = 'Day Shift';

  String? selectedLayer1UserId;
  String? selectedLayer2UserId;
  String? selectedLayer3UserId;
  String? selectedLayer4UserId;

  bool isSubmitting = false;

  @override
  void dispose() {
    workPlanController.dispose();
    observerController.dispose();
    notesController.dispose();
    super.dispose();
  }

  String getDayName(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    return days[date.weekday - 1];
  }

  String formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedDate = result;
    });
  }

  Future<void> pickStartTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: startTime ?? const TimeOfDay(hour: 7, minute: 0),
    );

    if (result == null) {
      return;
    }

    setState(() {
      startTime = result;
    });
  }

  Future<void> pickEndTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: endTime ?? const TimeOfDay(hour: 8, minute: 0),
    );

    if (result == null) {
      return;
    }

    setState(() {
      endTime = result;
    });
  }

  Map<String, dynamic>? findById(
      List<Map<String, dynamic>> items,
      String? id,
      ) {
    if (id == null) {
      return null;
    }

    for (final item in items) {
      if (item['id'] == id) {
        return item;
      }
    }

    return null;
  }

  Future<void> submitForm({
    required List<Map<String, dynamic>> units,
    required List<Map<String, dynamic>> drivers,
    required List<Map<String, dynamic>> routes,
    required List<Map<String, dynamic>> jsaProcedures,
    required List<Map<String, dynamic>> controlRooms,
    required List<Map<String, dynamic>> employees,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedJobSiteId == null) {
      showMessage('Job Site wajib dipilih');
      return;
    }

    if (selectedUnitId == null) {
      showMessage('Unit wajib dipilih');
      return;
    }

    if (selectedDriverId == null) {
      showMessage('Driver wajib dipilih');
      return;
    }

    if (selectedRouteId == null) {
      showMessage('Rute wajib dipilih');
      return;
    }

    if (selectedJsaId == null) {
      showMessage('Prosedur/JSA wajib dipilih');
      return;
    }

    if (selectedControlRoomId == null) {
      showMessage('Risk Intervention Centre (RIC) wajib dipilih');
      return;
    }

    if (startTime == null || endTime == null) {
      showMessage('Jam mulai dan akhir wajib diisi');
      return;
    }

    final companyAccess = await ref.read(currentCompanyAccessProvider.future);
    final profile = await ref.read(currentProfileProvider.future);
    final supabase = ref.read(supabaseProvider);
    final authUser = supabase.auth.currentUser;

    if (companyAccess == null || profile == null || authUser == null) {
      showMessage('Session user tidak valid');
      return;
    }

    final selectedUnit = findById(units, selectedUnitId);
    final selectedDriver = findById(drivers, selectedDriverId);
    final selectedRoute = findById(routes, selectedRouteId);
    final selectedJsa = findById(jsaProcedures, selectedJsaId);
    final selectedControlRoom = findById(controlRooms, selectedControlRoomId);

    if (selectedUnit == null ||
        selectedDriver == null ||
        selectedRoute == null ||
        selectedJsa == null ||
        selectedControlRoom == null) {
      showMessage('Data master tidak valid');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final header = await supabase
          .from('dop_headers')
          .insert({
        'company_id': companyAccess.companyId,
        'job_site_id': selectedJobSiteId,
        'dop_date': formatDate(selectedDate),
        'day_name': getDayName(selectedDate),
        'status': 'pending_safety',
        'created_by': authUser.id,
        'submitted_at': DateTime.now().toIso8601String(),
        'is_active': true,
      })
          .select('id')
          .single();

      final dopHeaderId = header['id'] as String;

      final procedureCode = selectedJsa['procedure_code'] as String? ?? '';
      final procedureName = selectedJsa['procedure_name'] as String? ?? '';

      String? getEmployeeNameById(String? companyUserId) {
        if (companyUserId == null) {
          return null;
        }

        for (final employee in employees) {
          if (employee['id'] == companyUserId) {
            final profile = employee['profiles'] as Map<String, dynamic>?;
            return profile?['full_name'] as String?;
          }
        }

        return null;
      }

      await supabase.from('dop_details').insert({
        'company_id': companyAccess.companyId,
        'dop_header_id': dopHeaderId,
        'work_plan': workPlanController.text.trim(),
        'unit_type': selectedUnit['unit_type'],
        'unit_number': selectedUnit['unit_number'],
        'start_time': formatTimeOfDay(startTime!),
        'end_time': formatTimeOfDay(endTime!),
        'driver_name': selectedDriver['driver_name'],
        'sid': selectedDriver['sid'],
        'sid_expired_date': selectedDriver['sid_expired_date'],
        'simper_expired_date': selectedDriver['simper_expired_date'],
        'route': selectedRoute['route_name'],
        'observer': observerController.text.trim(),
        'is_critical': true,
        'risk_level': 'High',
        'jsa_procedure': '$procedureCode - $procedureName',
        'shift': selectedShift,
        'layer_1': getEmployeeNameById(selectedLayer1UserId),
        'layer_2': getEmployeeNameById(selectedLayer2UserId),
        'layer_3': getEmployeeNameById(selectedLayer3UserId),
        'layer_4': getEmployeeNameById(selectedLayer4UserId),
        'control_room': selectedControlRoom['control_room_name'],
        'area_type': selectedAreaType,
        'transport_company': selectedUnit['owner_company'],
        'notes': notesController.text.trim(),
        'is_active': true,
      });

      await supabase.from('dop_approvals').insert({
        'company_id': companyAccess.companyId,
        'dop_header_id': dopHeaderId,
        'approval_level': 1,
        'approver_role': 'safety',
        'status': 'pending',
      });

      ref.invalidate(dopListProvider);

      if (mounted) {
        context.go('/dop-list');
      }
    } catch (error) {
      showMessage('Gagal submit DOP: $error');
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobSitesAsync = ref.watch(jobSitesProvider);
    final unitsAsync = ref.watch(unitsProvider);
    final driversAsync = ref.watch(driversProvider);
    final routesAsync = ref.watch(routesProvider);
    final jsaAsync = ref.watch(jsaProceduresProvider);
    final controlRoomsAsync = ref.watch(controlRoomsProvider);
    final employeesAsync = ref.watch(employeeOptionsProvider);

    final isLoading = jobSitesAsync.isLoading ||
        unitsAsync.isLoading ||
        driversAsync.isLoading ||
        routesAsync.isLoading ||
        jsaAsync.isLoading ||
        controlRoomsAsync.isLoading ||
        employeesAsync.isLoading;

    final hasError = jobSitesAsync.hasError ||
        unitsAsync.hasError ||
        driversAsync.hasError ||
        routesAsync.hasError ||
        jsaAsync.hasError ||
        controlRoomsAsync.hasError ||
        employeesAsync.hasError;

    final jobSites = jobSitesAsync.value ?? <Map<String, dynamic>>[];
    final units = unitsAsync.value ?? <Map<String, dynamic>>[];
    final drivers = driversAsync.value ?? <Map<String, dynamic>>[];
    final routes = routesAsync.value ?? <Map<String, dynamic>>[];
    final jsaProcedures = jsaAsync.value ?? <Map<String, dynamic>>[];
    final controlRooms = controlRoomsAsync.value ?? <Map<String, dynamic>>[];
    final employees = employeesAsync.value ?? <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : hasError
            ? const Center(
          child: Text(
            'Gagal membaca master data request form.',
            style: TextStyle(color: Colors.red),
          ),
        )
            : Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request Form DOP',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Input Daily Operation Plan Transportasi',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () {
                      context.go('/dop-list');
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () {
                      submitForm(
                        units: units,
                        drivers: drivers,
                        routes: routes,
                        jsaProcedures: jsaProcedures,
                        controlRooms: controlRooms,
                        employees: employees,
                      );
                    },
                    icon: isSubmitting
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.send),
                    label: Text(
                      isSubmitting ? 'Submitting...' : 'Submit',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _SectionCard(
                        title: 'Informasi DOP',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _DateField(
                                  label: 'Tanggal DOP',
                                  value:
                                  '${getDayName(selectedDate)}, ${formatDate(selectedDate)}',
                                  onTap: pickDate,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _DropdownField(
                                  label: 'Job Site',
                                  value: selectedJobSiteId,
                                  items: jobSites,
                                  valueKey: 'id',
                                  labelBuilder: (item) {
                                    return item['site_name']
                                    as String? ??
                                        '-';
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedJobSiteId = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Detail Pekerjaan',
                        children: [
                          TextFormField(
                            controller: workPlanController,
                            decoration: const InputDecoration(
                              labelText: 'Rencana Pekerjaan',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Rencana pekerjaan wajib diisi';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _SimpleDropdown(
                                  label: 'Area',
                                  value: selectedAreaType,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'jalan_negara',
                                      child:
                                      Text('Area Jalan Negara'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'site',
                                      child: Text('Area Site'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedAreaType = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _SimpleDropdown(
                                  label: 'Shift',
                                  value: selectedShift,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Day Shift',
                                      child: Text('Day Shift'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Night Shift',
                                      child: Text('Night Shift'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedShift = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _DropdownField(
                                  label: 'Unit',
                                  value: selectedUnitId,
                                  items: units,
                                  valueKey: 'id',
                                  labelBuilder: (item) {
                                    final unitNumber =
                                        item['unit_number']
                                        as String? ??
                                            '-';
                                    final unitType =
                                        item['unit_type']
                                        as String? ??
                                            '-';

                                    return '$unitNumber ($unitType)';
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedUnitId = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _DropdownField(
                                  label: 'Driver',
                                  value: selectedDriverId,
                                  items: drivers,
                                  valueKey: 'id',
                                  labelBuilder: (item) {
                                    final driverName =
                                        item['driver_name']
                                        as String? ??
                                            '-';
                                    final sid =
                                        item['sid'] as String? ?? '-';

                                    return '$driverName - $sid';
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDriverId = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _TimeField(
                                  label: 'Mulai',
                                  value: startTime == null
                                      ? '-'
                                      : formatTimeOfDay(startTime!),
                                  onTap: pickStartTime,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _TimeField(
                                  label: 'Akhir',
                                  value: endTime == null
                                      ? '-'
                                      : formatTimeOfDay(endTime!),
                                  onTap: pickEndTime,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _DropdownField(
                                  label: 'Rute',
                                  value: selectedRouteId,
                                  items: routes,
                                  valueKey: 'id',
                                  labelBuilder: (item) {
                                    return item['route_name']
                                    as String? ??
                                        '-';
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedRouteId = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextFormField(
                                  controller: observerController,
                                  decoration: const InputDecoration(
                                    labelText: 'Observer',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _DropdownField(
                                  label: 'Prosedur / JSA Terkait',
                                  value: selectedJsaId,
                                  items: jsaProcedures,
                                  valueKey: 'id',
                                  labelBuilder: (item) {
                                    final code =
                                        item['procedure_code']
                                        as String? ??
                                            '-';
                                    final name =
                                        item['procedure_name']
                                        as String? ??
                                            '-';

                                    return '$code - $name';
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedJsaId = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _DropdownField(
                                  label:
                                  'Risk Intervention Centre (RIC)',
                                  value: selectedControlRoomId,
                                  items: controlRooms,
                                  valueKey: 'id',
                                  labelBuilder: (item) {
                                    return item[
                                    'control_room_name']
                                    as String? ??
                                        '-';
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedControlRoomId = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Layer & Catatan',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _EmployeeDropdownField(
                                  label: 'Layer 1',
                                  value: selectedLayer1UserId,
                                  employees: employees,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLayer1UserId = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _EmployeeDropdownField(
                                  label: 'Layer 2',
                                  value: selectedLayer2UserId,
                                  employees: employees,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLayer2UserId = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _EmployeeDropdownField(
                                  label: 'Layer 3',
                                  value: selectedLayer3UserId,
                                  employees: employees,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLayer3UserId = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _EmployeeDropdownField(
                                  label: 'Layer 4',
                                  value: selectedLayer4UserId,
                                  employees: employees,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLayer4UserId = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Catatan',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, dynamic>> items;
  final String valueKey;
  final String Function(Map<String, dynamic> item) labelBuilder;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.valueKey,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        final itemValue = item[valueKey] as String;

        return DropdownMenuItem<String>(
          value: itemValue,
          child: Text(
            labelBuilder(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _SimpleDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String> onChanged;

  const _SimpleDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: (value) {
        if (value == null) {
          return;
        }

        onChanged(value);
      },
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(value),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(value),
      ),
    );
  }
}

class _EmployeeDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, dynamic>> employees;
  final ValueChanged<String?> onChanged;

  const _EmployeeDropdownField({
    required this.label,
    required this.value,
    required this.employees,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: employees.map((employee) {
        final employeeId = employee['id'] as String;
        final profile = employee['profiles'] as Map<String, dynamic>?;
        final fullName = profile?['full_name'] as String? ?? '-';
        final sid = profile?['sid'] as String? ?? '-';

        return DropdownMenuItem<String>(
          value: employeeId,
          child: Text(
            '$fullName - $sid',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
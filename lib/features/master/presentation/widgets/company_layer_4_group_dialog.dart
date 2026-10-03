import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/company_layer_4_group_provider.dart';
import '../../domain/company_layer_4_group_model.dart';

class CompanyLayer4GroupDialog
    extends ConsumerStatefulWidget {
  const CompanyLayer4GroupDialog({
    super.key,
  });

  @override
  ConsumerState<CompanyLayer4GroupDialog>
  createState() {
    return _CompanyLayer4GroupDialogState();
  }
}

class _CompanyLayer4GroupDialogState
    extends ConsumerState<
        CompanyLayer4GroupDialog> {
  String? selectedFirstCompanyId;
  String? selectedSecondCompanyId;

  bool isSaving = false;

  String? validateSelection() {
    final firstCompanyId =
    selectedFirstCompanyId?.trim();

    final secondCompanyId =
    selectedSecondCompanyId?.trim();

    if (firstCompanyId == null ||
        firstCompanyId.isEmpty) {
      return 'Perusahaan 1 wajib dipilih.';
    }

    if (secondCompanyId == null ||
        secondCompanyId.isEmpty) {
      return 'Perusahaan 2 wajib dipilih.';
    }

    if (firstCompanyId ==
        secondCompanyId) {
      return 'Perusahaan 1 dan Perusahaan 2 '
          'tidak boleh sama.';
    }

    return null;
  }

  Future<void> saveGroup() async {
    if (isSaving) {
      return;
    }

    final validationMessage =
    validateSelection();

    if (validationMessage != null) {
      showMessage(validationMessage);
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final repository = ref.read(
        companyLayer4GroupRepositoryProvider,
      );

      await repository.createGroup(
        firstCompanyId:
        selectedFirstCompanyId!,
        secondCompanyId:
        selectedSecondCompanyId!,
      );

      ref.invalidate(
        companyLayer4GroupsProvider,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      );

      if (message.contains(
        'duplicate key value',
      )) {
        showMessage(
          'Kedua perusahaan tersebut '
              'sudah memiliki Gabungan Layer 4.',
        );
        return;
      }

      showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(
      layer4GroupCompanyOptionsProvider,
    );

    return AlertDialog(
      titlePadding:
      const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        10,
      ),
      contentPadding:
      const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        12,
      ),
      actionsPadding:
      const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        16,
      ),
      title: const Row(
        children: [
          Icon(
            Icons.link_outlined,
            color: Color(0xFF2563EB),
            size: 21,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Tambah Gabungan Layer 4',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: companiesAsync.when(
          loading: () {
            return const SizedBox(
              height: 120,
              child: Center(
                child:
                CircularProgressIndicator(),
              ),
            );
          },
          error: (error, stackTrace) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                const Color(0xFFFEF2F2),
                borderRadius:
                BorderRadius.circular(8),
                border: Border.all(
                  color:
                  const Color(0xFFFECACA),
                ),
              ),
              child: Text(
                error.toString(),
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontSize: 12,
                ),
              ),
            );
          },
          data: (companies) {
            return buildForm(companies);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
            Navigator.of(context)
                .pop(false);
          },
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: isSaving ||
              companiesAsync.isLoading
              ? null
              : saveGroup,
          icon: isSaving
              ? const SizedBox(
            width: 15,
            height: 15,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(
            Icons.save_outlined,
            size: 17,
          ),
          label: Text(
            isSaving
                ? 'Menyimpan...'
                : 'Simpan Gabungan',
          ),
        ),
      ],
    );
  }

  Widget buildForm(
      List<Layer4GroupCompanyOption>
      companies,
      ) {
    final secondCompanyOptions =
    companies.where((company) {
      return company.id !=
          selectedFirstCompanyId;
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius:
            BorderRadius.circular(8),
            border: Border.all(
              color:
              const Color(0xFFBFDBFE),
            ),
          ),
          child: const Text(
            'Layer 4 aktif dari kedua '
                'perusahaan akan tersedia '
                'sebagai kandidat bersama '
                'pada Request Form DOP.',
            style: TextStyle(
              color: Color(0xFF1E40AF),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: selectedFirstCompanyId,
          isExpanded: true,
          decoration: buildDecoration(
            label: 'Perusahaan 1',
          ),
          items: buildCompanyItems(
            companies,
          ),
          onChanged: isSaving
              ? null
              : (value) {
            setState(() {
              selectedFirstCompanyId =
                  value;

              if (selectedSecondCompanyId ==
                  value) {
                selectedSecondCompanyId =
                null;
              }
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedSecondCompanyId,
          isExpanded: true,
          decoration: buildDecoration(
            label: 'Perusahaan 2',
          ),
          items: buildCompanyItems(
            secondCompanyOptions,
          ),
          onChanged: isSaving
              ? null
              : (value) {
            setState(() {
              selectedSecondCompanyId =
                  value;
            });
          },
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>>
  buildCompanyItems(
      List<Layer4GroupCompanyOption>
      companies,
      ) {
    return companies.map((company) {
      return DropdownMenuItem<String>(
        value: company.id,
        child: Text(
          company.companyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  InputDecoration buildDecoration({
    required String label,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(
        Icons.business_outlined,
        size: 18,
      ),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFCBD5E1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.3,
        ),
      ),
    );
  }
}
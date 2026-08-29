import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/dop_revision_repository.dart';
import '../../domain/dop_revision_data.dart';

class DopRevisionFormState {
  final bool isLoading;
  final bool hasLoaded;
  final DopRevisionData? revisionData;
  final String? errorMessage;

  const DopRevisionFormState({
    required this.isLoading,
    required this.hasLoaded,
    required this.revisionData,
    required this.errorMessage,
  });

  const DopRevisionFormState.initial()
      : isLoading = false,
        hasLoaded = false,
        revisionData = null,
        errorMessage = null;

  DopRevisionFormState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    DopRevisionData? revisionData,
    String? errorMessage,
    bool clearRevisionData = false,
    bool clearErrorMessage = false,
  }) {
    return DopRevisionFormState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      revisionData: clearRevisionData
          ? null
          : revisionData ?? this.revisionData,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class DopRevisionFormController
    extends StateNotifier<DopRevisionFormState> {
  final DopRevisionRepository repository;
  final String dopHeaderId;

  DopRevisionFormController({
    required this.repository,
    required this.dopHeaderId,
  }) : super(
    const DopRevisionFormState.initial(),
  );

  Future<void> loadRevision() async {
    if (state.isLoading || state.hasLoaded) {
      return;
    }

    if (dopHeaderId.trim().isEmpty) {
      state = state.copyWith(
        hasLoaded: false,
        errorMessage:
        'DOP revisi tidak valid.',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );

    try {
      final revisionData =
      await repository.loadRevision(
        dopHeaderId: dopHeaderId,
      );

      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        revisionData: revisionData,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: false,
        errorMessage:
        extractErrorMessage(error),
      );
    }
  }

  Future<void> reloadRevision() async {
    state = const DopRevisionFormState.initial();

    await loadRevision();
  }

  void clear() {
    state = const DopRevisionFormState.initial();
  }

  String extractErrorMessage(
      Object error,
      ) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst(
        'Exception: ',
        '',
      );
    }

    const postgrestPrefix =
        'PostgrestException(message: ';

    if (message.startsWith(postgrestPrefix)) {
      final cleanedMessage =
      message.replaceFirst(
        postgrestPrefix,
        '',
      );

      final commaIndex =
      cleanedMessage.indexOf(',');

      if (commaIndex > 0) {
        return cleanedMessage
            .substring(0, commaIndex)
            .trim();
      }

      return cleanedMessage.trim();
    }

    return message;
  }
}

DopRevisionFormController buildDopRevisionFormController(
    Ref ref,
    String dopHeaderId,
    ) {
  final repository = ref.watch(
    dopRevisionRepositoryProvider,
  );

  return DopRevisionFormController(
    repository: repository,
    dopHeaderId: dopHeaderId,
  );
}

final dopRevisionFormControllerProvider =
StateNotifierProvider.family<
    DopRevisionFormController,
    DopRevisionFormState,
    String>(
  buildDopRevisionFormController,
);
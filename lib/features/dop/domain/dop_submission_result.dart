class DopSubmissionResult {
  final String dopHeaderId;
  final String dopNumber;

  const DopSubmissionResult({
    required this.dopHeaderId,
    required this.dopNumber,
  });

  factory DopSubmissionResult.fromMap(
      Map<String, dynamic> map,
      ) {
    return DopSubmissionResult(
      dopHeaderId: map['dop_header_id'] as String,
      dopNumber: map['dop_number'] as String,
    );
  }
}
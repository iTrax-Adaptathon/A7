/// The independent, forward-looking plateau-risk signal from the domain layer.
class PlateauRiskAssessment {
  final bool atRisk;
  final String reason;
  final double riskScore;

  const PlateauRiskAssessment({
    required this.atRisk,
    required this.reason,
    required this.riskScore,
  });

  static const noRisk = PlateauRiskAssessment(
    atRisk: false,
    reason: '',
    riskScore: 0,
  );
}

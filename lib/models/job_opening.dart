class JobOpening {
  final String id;
  final String title;
  final String country;
  final String industry;
  final String description;
  final String salaryRange;
  final List<String> requirements;

  const JobOpening({
    required this.id,
    required this.title,
    required this.country,
    required this.industry,
    this.description = '',
    required this.salaryRange,
    required this.requirements,
  });
}

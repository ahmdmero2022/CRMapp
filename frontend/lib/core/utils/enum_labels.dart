import '../../l10n/generated/app_localizations.dart';

String leadStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'new':
      return l10n.leadStatusNew;
    case 'contacted':
      return l10n.leadStatusContacted;
    case 'qualified':
      return l10n.leadStatusQualified;
    case 'unqualified':
      return l10n.leadStatusUnqualified;
    case 'converted':
      return l10n.leadStatusConverted;
    default:
      return status;
  }
}

String dealStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'won':
      return l10n.dealStatusWon;
    case 'lost':
      return l10n.dealStatusLost;
    default:
      return l10n.dealStatusOpen;
  }
}

String taskPriorityLabel(AppLocalizations l10n, String priority) {
  switch (priority) {
    case 'low':
      return l10n.priorityLow;
    case 'high':
      return l10n.priorityHigh;
    default:
      return l10n.priorityMedium;
  }
}

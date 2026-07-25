// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get none => 'None';

  @override
  String get requiredField => 'Required';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get appTitle => 'CRM App';

  @override
  String get authTagline => 'Track leads, manage your pipeline, and close more deals — all in one place.';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navContacts => 'Contacts';

  @override
  String get navCompanies => 'Companies';

  @override
  String get navLeads => 'Leads';

  @override
  String get navDeals => 'Deals';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navSettings => 'Settings';

  @override
  String get signOut => 'Sign out';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to manage your pipeline, contacts, and deals.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordTooShort => 'At least 6 characters';

  @override
  String get signIn => 'Sign in';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get createOneLink => 'Create one';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'Set up your workspace in a few seconds.';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get createAccount => 'Create account';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account?';

  @override
  String get signInLink => 'Sign in';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSubtitle => 'Choose how the CRM looks on this device.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get languageSubtitle => 'Choose your preferred language.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get settingsSecuritySection => 'Security';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String changePasswordSubtitleEmail(String email) {
    return 'Update the password for $email.';
  }

  @override
  String get changePasswordSubtitleGeneric => 'Update the password for your account.';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get currentPasswordRequired => 'Enter your current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm new password';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get updatePasswordButton => 'Update password';

  @override
  String get passwordUpdatedMessage => 'Password updated';

  @override
  String get companiesTitle => 'Companies';

  @override
  String get companiesSubtitle => 'Organizations you work with.';

  @override
  String get addCompany => 'Add Company';

  @override
  String get editCompany => 'Edit Company';

  @override
  String get searchCompaniesHint => 'Search companies...';

  @override
  String get noCompaniesFound => 'No companies found';

  @override
  String get deleteCompanyTitle => 'Delete company';

  @override
  String deleteCompanyMessage(String name) {
    return 'Delete $name?';
  }

  @override
  String get companyCreatedMessage => 'Company created';

  @override
  String get companyUpdatedMessage => 'Company updated';

  @override
  String get companyDeletedMessage => 'Company deleted';

  @override
  String get companyInfoTitle => 'Company Info';

  @override
  String get notesLabel => 'Notes';

  @override
  String contactsWithCount(int count) {
    return 'Contacts ($count)';
  }

  @override
  String get noContactsYet => 'No contacts yet.';

  @override
  String dealsWithCount(int count) {
    return 'Deals ($count)';
  }

  @override
  String get noDealsYetPlain => 'No deals yet.';

  @override
  String get companyNameLabel => 'Company name';

  @override
  String get companyLabel => 'Company';

  @override
  String get industryLabel => 'Industry';

  @override
  String get websiteLabel => 'Website';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get addressLabel => 'Address';

  @override
  String contactsCountShort(int count) {
    return '$count contacts';
  }

  @override
  String dealsCountShort(int count) {
    return '$count deals';
  }

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsSubtitle => 'Everyone you do business with.';

  @override
  String get addContact => 'Add Contact';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get searchContactsHint => 'Search contacts by name or email...';

  @override
  String get noContactsFoundTitle => 'No contacts found';

  @override
  String get noContactsFoundSubtitle => 'Try adjusting your search or add a new contact.';

  @override
  String get deleteContactTitle => 'Delete contact';

  @override
  String deleteContactMessage(String name) {
    return 'Delete $name? This cannot be undone.';
  }

  @override
  String get contactCreatedMessage => 'Contact created';

  @override
  String get contactUpdatedMessage => 'Contact updated';

  @override
  String get contactDeletedMessage => 'Contact deleted';

  @override
  String get contactInfoTitle => 'Contact Info';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get jobTitleLabel => 'Job title';

  @override
  String get dealsLabel => 'Deals';

  @override
  String get noDealsLinkedMessage => 'No deals linked to this contact yet.';

  @override
  String get tasksLabel => 'Tasks';

  @override
  String get addTaskLink => 'Add task';

  @override
  String get noTasksYetMessage => 'No tasks yet.';

  @override
  String get activityTimelineTitle => 'Activity Timeline';

  @override
  String get addNoteHint => 'Add a note...';

  @override
  String get postButton => 'Post';

  @override
  String get noActivityYetMessage => 'No activity yet.';

  @override
  String get someoneFallback => 'Someone';

  @override
  String get overviewTitle => 'Overview';

  @override
  String get overviewSubtitle => 'Here\'s what\'s happening with your business today.';

  @override
  String get statContacts => 'Contacts';

  @override
  String get statCompanies => 'Companies';

  @override
  String get statOpenDeals => 'Open Deals';

  @override
  String pipelineValueSubtitle(String value) {
    return '$value pipeline';
  }

  @override
  String get statWonRevenue => 'Won Revenue';

  @override
  String get statTotalLeads => 'Total Leads';

  @override
  String get statTasksDueToday => 'Tasks Due Today';

  @override
  String get statOverdueTasks => 'Overdue Tasks';

  @override
  String get pipelineByStageTitle => 'Pipeline by Stage';

  @override
  String get leadsByStatusTitle => 'Leads by Status';

  @override
  String get recentActivityTitle => 'Recent Activity';

  @override
  String get upcomingTasksTitle => 'Upcoming Tasks';

  @override
  String get viewAllLink => 'View all';

  @override
  String get noDealsYetTitle => 'No deals yet';

  @override
  String get noDealsYetSubtitle => 'Deals will appear here once you create some.';

  @override
  String get noLeadsYetTitle => 'No leads yet';

  @override
  String get noActivityYetTitle => 'No activity yet';

  @override
  String get allCaughtUpTitle => 'All caught up!';

  @override
  String get justNowLabel => 'just now';

  @override
  String minutesAgoLabel(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgoLabel(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgoLabel(int count) {
    return '${count}d ago';
  }

  @override
  String get dealsPipelineTitle => 'Deals Pipeline';

  @override
  String get dealsPipelineSubtitle => 'Drag cards between stages to update progress.';

  @override
  String get addDeal => 'Add Deal';

  @override
  String get editDeal => 'Edit Deal';

  @override
  String get dealTitleLabel => 'Deal title';

  @override
  String get valueDollarLabel => 'Value (\$)';

  @override
  String get primaryContactLabel => 'Primary contact';

  @override
  String get setExpectedCloseDate => 'Set expected close date';

  @override
  String closesOnLabel(String date) {
    return 'Closes $date';
  }

  @override
  String probabilityWithPercent(int percent) {
    return 'Probability: $percent%';
  }

  @override
  String get noDealsShort => 'No deals';

  @override
  String get deleteDealTitle => 'Delete deal';

  @override
  String deleteDealMessage(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get valueChipLabel => 'Value';

  @override
  String get probabilityChipLabel => 'Probability';

  @override
  String get statusChipLabel => 'Status';

  @override
  String get contactChipLabel => 'Contact';

  @override
  String get expectedCloseChipLabel => 'Expected close';

  @override
  String get activityLabel => 'Activity';

  @override
  String get dealStatusOpen => 'Open';

  @override
  String get dealStatusWon => 'Won';

  @override
  String get dealStatusLost => 'Lost';

  @override
  String probabilityPercentSuffix(int percent) {
    return '$percent% probability';
  }

  @override
  String get leadsTitle => 'Leads';

  @override
  String get leadsSubtitle => 'Prospects waiting to be qualified.';

  @override
  String get noLeadsFoundTitle => 'No leads found';

  @override
  String get addLead => 'Add Lead';

  @override
  String get editLead => 'Edit Lead';

  @override
  String get allFilterLabel => 'All';

  @override
  String get nameLabel => 'Name';

  @override
  String get sourceLabel => 'Source';

  @override
  String get sourceHint => 'e.g. Website, Referral';

  @override
  String get estimatedValueLabel => 'Estimated value (\$)';

  @override
  String get statusLabel => 'Status';

  @override
  String get deleteLeadTitle => 'Delete lead';

  @override
  String deleteLeadMessage(String name) {
    return 'Delete $name?';
  }

  @override
  String get convertLeadTitle => 'Convert lead';

  @override
  String convertLeadMessage(String name) {
    return 'Convert \"$name\" into a contact and a new deal in the pipeline?';
  }

  @override
  String get convertActionLabel => 'Convert';

  @override
  String get leadConvertedMessage => 'Lead converted to contact + deal';

  @override
  String viaSourceLabel(String source) {
    return 'via $source';
  }

  @override
  String get leadCreatedMessage => 'Lead created';

  @override
  String get leadUpdatedMessage => 'Lead updated';

  @override
  String get leadStatusNew => 'New';

  @override
  String get leadStatusContacted => 'Contacted';

  @override
  String get leadStatusQualified => 'Qualified';

  @override
  String get leadStatusUnqualified => 'Unqualified';

  @override
  String get leadStatusConverted => 'Converted';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksSubtitle => 'Stay on top of your follow-ups.';

  @override
  String get addTask => 'Add Task';

  @override
  String get pendingFilterLabel => 'Pending';

  @override
  String get completedFilterLabel => 'Completed';

  @override
  String get noTasksFoundTitle => 'No tasks found';

  @override
  String get deleteTaskTitle => 'Delete task';

  @override
  String deleteTaskMessage(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get taskCreatedMessage => 'Task created';

  @override
  String get titleLabel => 'Title';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get setDueDate => 'Set due date';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';
}

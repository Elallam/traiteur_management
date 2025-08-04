import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Traiteur Management'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @employeeDashboard.
  ///
  /// In en, this message translates to:
  /// **'Employee Dashboard'**
  String get employeeDashboard;

  /// No description provided for @occasions.
  ///
  /// In en, this message translates to:
  /// **'Occasions'**
  String get occasions;

  /// No description provided for @addOccasion.
  ///
  /// In en, this message translates to:
  /// **'Add Occasion'**
  String get addOccasion;

  /// No description provided for @editOccasion.
  ///
  /// In en, this message translates to:
  /// **'Edit Occasion'**
  String get editOccasion;

  /// No description provided for @occasionDetails.
  ///
  /// In en, this message translates to:
  /// **'Occasion Details'**
  String get occasionDetails;

  /// No description provided for @occasionName.
  ///
  /// In en, this message translates to:
  /// **'Occasion Name'**
  String get occasionName;

  /// No description provided for @occasionDate.
  ///
  /// In en, this message translates to:
  /// **'Occasion Date'**
  String get occasionDate;

  /// No description provided for @occasionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get occasionLocation;

  /// No description provided for @occasionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get occasionDescription;

  /// No description provided for @occasionGuests.
  ///
  /// In en, this message translates to:
  /// **'Number of Guests'**
  String get occasionGuests;

  /// No description provided for @occasionStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get occasionStatus;

  /// No description provided for @occasionBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get occasionBudget;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get addEmployee;

  /// No description provided for @editEmployee.
  ///
  /// In en, this message translates to:
  /// **'Edit Employee'**
  String get editEmployee;

  /// No description provided for @employeeManagement.
  ///
  /// In en, this message translates to:
  /// **'Employee Management'**
  String get employeeManagement;

  /// No description provided for @employeeName.
  ///
  /// In en, this message translates to:
  /// **'Employee Name'**
  String get employeeName;

  /// No description provided for @employeeRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get employeeRole;

  /// No description provided for @employeePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get employeePhone;

  /// No description provided for @employeeStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get employeeStatus;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @stockManagement.
  ///
  /// In en, this message translates to:
  /// **'Stock Management'**
  String get stockManagement;

  /// No description provided for @addArticle.
  ///
  /// In en, this message translates to:
  /// **'Add Article'**
  String get addArticle;

  /// No description provided for @editArticle.
  ///
  /// In en, this message translates to:
  /// **'Edit Article'**
  String get editArticle;

  /// No description provided for @articleName.
  ///
  /// In en, this message translates to:
  /// **'Article Name'**
  String get articleName;

  /// No description provided for @articleQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get articleQuantity;

  /// No description provided for @articlePrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get articlePrice;

  /// No description provided for @articleCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get articleCategory;

  /// No description provided for @articleDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get articleDescription;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// No description provided for @editMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit Meal'**
  String get editMeal;

  /// No description provided for @mealName.
  ///
  /// In en, this message translates to:
  /// **'Meal Name'**
  String get mealName;

  /// No description provided for @mealDescription.
  ///
  /// In en, this message translates to:
  /// **'Meal Description'**
  String get mealDescription;

  /// No description provided for @mealPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get mealPrice;

  /// No description provided for @mealCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get mealCategory;

  /// No description provided for @mealIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get mealIngredients;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @equipmentBooking.
  ///
  /// In en, this message translates to:
  /// **'Equipment Booking'**
  String get equipmentBooking;

  /// No description provided for @equipmentManagement.
  ///
  /// In en, this message translates to:
  /// **'Equipment Management'**
  String get equipmentManagement;

  /// No description provided for @addEquipment.
  ///
  /// In en, this message translates to:
  /// **'Add Equipment'**
  String get addEquipment;

  /// No description provided for @editEquipment.
  ///
  /// In en, this message translates to:
  /// **'Edit Equipment'**
  String get editEquipment;

  /// No description provided for @equipmentName.
  ///
  /// In en, this message translates to:
  /// **'Equipment Name'**
  String get equipmentName;

  /// No description provided for @equipmentType.
  ///
  /// In en, this message translates to:
  /// **'Equipment Type'**
  String get equipmentType;

  /// No description provided for @equipmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get equipmentStatus;

  /// No description provided for @equipmentAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get equipmentAvailability;

  /// No description provided for @equipmentCheckout.
  ///
  /// In en, this message translates to:
  /// **'Equipment Checkout'**
  String get equipmentCheckout;

  /// No description provided for @equipmentActivity.
  ///
  /// In en, this message translates to:
  /// **'Equipment Activity'**
  String get equipmentActivity;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @profitAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Profit Analytics'**
  String get profitAnalytics;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteConfirmation;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validationInvalidEmail;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordTooShort;

  /// No description provided for @validationInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get validationInvalidPhone;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @keyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Key Metrics'**
  String get keyMetrics;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @activeEvents.
  ///
  /// In en, this message translates to:
  /// **'Active Events'**
  String get activeEvents;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get stockValue;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @todaysEvents.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Events'**
  String get todaysEvents;

  /// No description provided for @noEventsToday.
  ///
  /// In en, this message translates to:
  /// **'No Events Today'**
  String get noEventsToday;

  /// No description provided for @enjoyFreeDay.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your free day!'**
  String get enjoyFreeDay;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @noRecentActivities.
  ///
  /// In en, this message translates to:
  /// **'No recent activities'**
  String get noRecentActivities;

  /// Shows when something was last updated
  ///
  /// In en, this message translates to:
  /// **'Updated {time} ago'**
  String updatedAgo(String time);

  /// No description provided for @quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// No description provided for @equipmentUtilization.
  ///
  /// In en, this message translates to:
  /// **'Equipment Utilization'**
  String get equipmentUtilization;

  /// No description provided for @averageOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Avg Order Value'**
  String get averageOrderValue;

  /// No description provided for @monthlyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Monthly Revenue'**
  String get monthlyRevenue;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @fullyBooked.
  ///
  /// In en, this message translates to:
  /// **'Fully Booked'**
  String get fullyBooked;

  /// No description provided for @mostUtilizedEquipment.
  ///
  /// In en, this message translates to:
  /// **'Most Utilized Equipment'**
  String get mostUtilizedEquipment;

  /// No description provided for @reportFilters.
  ///
  /// In en, this message translates to:
  /// **'Report Filters'**
  String get reportFilters;

  /// No description provided for @financialReport.
  ///
  /// In en, this message translates to:
  /// **'Financial Report'**
  String get financialReport;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @profitMargin.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin (%)'**
  String get profitMargin;

  /// No description provided for @completedEvents.
  ///
  /// In en, this message translates to:
  /// **'Completed Events'**
  String get completedEvents;

  /// No description provided for @equipmentStatusReport.
  ///
  /// In en, this message translates to:
  /// **'Equipment Status Report'**
  String get equipmentStatusReport;

  /// No description provided for @totalEquipment.
  ///
  /// In en, this message translates to:
  /// **'Total Equipment'**
  String get totalEquipment;

  /// No description provided for @checkedOut.
  ///
  /// In en, this message translates to:
  /// **'Checked Out'**
  String get checkedOut;

  /// No description provided for @lowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get lowStockAlerts;

  /// No description provided for @exportReports.
  ///
  /// In en, this message translates to:
  /// **'Export Reports'**
  String get exportReports;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @exportInfo.
  ///
  /// In en, this message translates to:
  /// **'Export Info'**
  String get exportInfo;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @noEquipmentAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Equipment Available'**
  String get noEquipmentAvailable;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @createNewEvent.
  ///
  /// In en, this message translates to:
  /// **'Create New Event'**
  String get createNewEvent;

  /// No description provided for @allGood.
  ///
  /// In en, this message translates to:
  /// **'All Good!'**
  String get allGood;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noAlertsMessage.
  ///
  /// In en, this message translates to:
  /// **'No alerts or notifications at the moment'**
  String get noAlertsMessage;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Message shown when generating a report
  ///
  /// In en, this message translates to:
  /// **'Generating {period} report...'**
  String generatingReport(String period);

  /// No description provided for @exportingToPdf.
  ///
  /// In en, this message translates to:
  /// **'Exporting to PDF...'**
  String get exportingToPdf;

  /// No description provided for @exportingToExcel.
  ///
  /// In en, this message translates to:
  /// **'Exporting to Excel...'**
  String get exportingToExcel;

  /// No description provided for @utilizationReport.
  ///
  /// In en, this message translates to:
  /// **'Utilization Report'**
  String get utilizationReport;

  /// Shows number of events in financial report
  ///
  /// In en, this message translates to:
  /// **'Based on {count} completed events'**
  String basedOnEvents(int count);

  /// Number of guests
  ///
  /// In en, this message translates to:
  /// **'{count} guests'**
  String guestsCount(int count);

  /// Number of items
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String itemsCount(int count);

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get december;

  /// No description provided for @dayAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get dayAbbreviation;

  /// No description provided for @hourAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hourAbbreviation;

  /// No description provided for @minuteAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minuteAbbreviation;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @searchEmployeeHint.
  ///
  /// In en, this message translates to:
  /// **'Search employees by name, email, or phone...'**
  String get searchEmployeeHint;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Sort by Name'**
  String get sortByName;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'Sort by Date'**
  String get sortByDate;

  /// No description provided for @sortByCheckouts.
  ///
  /// In en, this message translates to:
  /// **'Sort by Checkouts'**
  String get sortByCheckouts;

  /// No description provided for @totalEmployees.
  ///
  /// In en, this message translates to:
  /// **'Total Employees'**
  String get totalEmployees;

  /// No description provided for @activeCheckouts.
  ///
  /// In en, this message translates to:
  /// **'Active Checkouts'**
  String get activeCheckouts;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @totalCheckouts.
  ///
  /// In en, this message translates to:
  /// **'Total Checkouts'**
  String get totalCheckouts;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// No description provided for @noEmployeesFoundSearch.
  ///
  /// In en, this message translates to:
  /// **'No employees found matching \"{query}\"'**
  String noEmployeesFoundSearch(String query);

  /// No description provided for @noEmployeesFound.
  ///
  /// In en, this message translates to:
  /// **'No employees found'**
  String get noEmployeesFound;

  /// No description provided for @adjustSearchFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get adjustSearchFilters;

  /// No description provided for @addFirstEmployeeHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first employee to get started'**
  String get addFirstEmployeeHint;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @viewCheckouts.
  ///
  /// In en, this message translates to:
  /// **'View Checkouts'**
  String get viewCheckouts;

  /// No description provided for @employeeCheckoutsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Checkouts for {employeeName} - Coming soon'**
  String employeeCheckoutsComingSoon(String employeeName);

  /// No description provided for @employeeDeactivatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Employee deactivated successfully'**
  String get employeeDeactivatedSuccess;

  /// No description provided for @employeeActivatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Employee activated successfully'**
  String get employeeActivatedSuccess;

  /// No description provided for @failedToUpdateEmployeeStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update employee status'**
  String get failedToUpdateEmployeeStatus;

  /// No description provided for @deleteEmployee.
  ///
  /// In en, this message translates to:
  /// **'Delete Employee'**
  String get deleteEmployee;

  /// No description provided for @deleteEmployeeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {employeeName}? This action cannot be undone.'**
  String deleteEmployeeConfirmation(String employeeName);

  /// No description provided for @employeeDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Employee deleted successfully'**
  String get employeeDeletedSuccess;

  /// No description provided for @failedToDeleteEmployee.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete employee'**
  String get failedToDeleteEmployee;

  /// No description provided for @validationNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get validationNameTooShort;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @employeeUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Employee updated successfully'**
  String get employeeUpdatedSuccess;

  /// No description provided for @employeeCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Employee created successfully'**
  String get employeeCreatedSuccess;

  /// No description provided for @failedToUpdateEmployee.
  ///
  /// In en, this message translates to:
  /// **'Failed to update employee'**
  String get failedToUpdateEmployee;

  /// No description provided for @failedToCreateEmployee.
  ///
  /// In en, this message translates to:
  /// **'Failed to create employee'**
  String get failedToCreateEmployee;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @employeeInformation.
  ///
  /// In en, this message translates to:
  /// **'Employee Information'**
  String get employeeInformation;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @performanceStatistics.
  ///
  /// In en, this message translates to:
  /// **'Performance Statistics'**
  String get performanceStatistics;

  /// No description provided for @completedCheckouts.
  ///
  /// In en, this message translates to:
  /// **'Completed Checkouts'**
  String get completedCheckouts;

  /// No description provided for @overdueItems.
  ///
  /// In en, this message translates to:
  /// **'Overdue Items'**
  String get overdueItems;

  /// No description provided for @reliabilityScore.
  ///
  /// In en, this message translates to:
  /// **'Reliability Score'**
  String get reliabilityScore;

  /// No description provided for @currentCheckouts.
  ///
  /// In en, this message translates to:
  /// **'Current Checkouts'**
  String get currentCheckouts;

  /// No description provided for @equipmentId.
  ///
  /// In en, this message translates to:
  /// **'Equipment ID'**
  String get equipmentId;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @overdueByDays.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {days} days'**
  String overdueByDays(int days);

  /// No description provided for @employeeAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Employee Analytics'**
  String get employeeAnalytics;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @activeEmployees.
  ///
  /// In en, this message translates to:
  /// **'Active Employees'**
  String get activeEmployees;

  /// No description provided for @topPerformingEmployees.
  ///
  /// In en, this message translates to:
  /// **'Top Performing Employees'**
  String get topPerformingEmployees;

  /// No description provided for @reliability.
  ///
  /// In en, this message translates to:
  /// **'Reliability'**
  String get reliability;

  /// No description provided for @totalCheckoutsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} checkouts'**
  String totalCheckoutsCount(int count);

  /// No description provided for @employeesRequiringAttention.
  ///
  /// In en, this message translates to:
  /// **'Employees Requiring Attention'**
  String get employeesRequiringAttention;

  /// No description provided for @detailedAnalyticsExportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Detailed analytics export - Coming soon'**
  String get detailedAnalyticsExportComingSoon;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// No description provided for @articles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get articles;

  /// No description provided for @searchStockItems.
  ///
  /// In en, this message translates to:
  /// **'Search stock items...'**
  String get searchStockItems;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @stockData.
  ///
  /// In en, this message translates to:
  /// **'stock data'**
  String get stockData;

  /// No description provided for @totalArticles.
  ///
  /// In en, this message translates to:
  /// **'Total Articles'**
  String get totalArticles;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get totalValue;

  /// No description provided for @updateQuantity.
  ///
  /// In en, this message translates to:
  /// **'Update Quantity'**
  String get updateQuantity;

  /// No description provided for @newQuantity.
  ///
  /// In en, this message translates to:
  /// **'New Quantity'**
  String get newQuantity;

  /// No description provided for @quantityUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Quantity updated successfully'**
  String get quantityUpdatedSuccess;

  /// No description provided for @failedToUpdateQuantity.
  ///
  /// In en, this message translates to:
  /// **'Failed to update quantity'**
  String get failedToUpdateQuantity;

  /// No description provided for @deleteArticle.
  ///
  /// In en, this message translates to:
  /// **'Delete Article'**
  String get deleteArticle;

  /// No description provided for @deleteArticleConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{articleName}\"?'**
  String deleteArticleConfirmation(String articleName);

  /// No description provided for @articleDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Article deleted successfully'**
  String get articleDeletedSuccess;

  /// No description provided for @failedToDeleteArticle.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete article'**
  String get failedToDeleteArticle;

  /// No description provided for @noArticlesFound.
  ///
  /// In en, this message translates to:
  /// **'No articles found'**
  String get noArticlesFound;

  /// No description provided for @addFirstArticleHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first article to get started'**
  String get addFirstArticleHint;

  /// No description provided for @allCheckedOut.
  ///
  /// In en, this message translates to:
  /// **'All Checked Out'**
  String get allCheckedOut;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @equipmentCheckoutComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Equipment checkout - Coming soon'**
  String get equipmentCheckoutComingSoon;

  /// No description provided for @equipmentCheckoutHistoryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Equipment checkout history - Coming soon'**
  String get equipmentCheckoutHistoryComingSoon;

  /// No description provided for @deleteEquipment.
  ///
  /// In en, this message translates to:
  /// **'Delete Equipment'**
  String get deleteEquipment;

  /// No description provided for @deleteEquipmentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{equipmentName}\"?'**
  String deleteEquipmentConfirmation(String equipmentName);

  /// No description provided for @equipmentDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Equipment deleted successfully'**
  String get equipmentDeletedSuccess;

  /// No description provided for @failedToDeleteEquipment.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete equipment'**
  String get failedToDeleteEquipment;

  /// No description provided for @allOut.
  ///
  /// In en, this message translates to:
  /// **'All Out'**
  String get allOut;

  /// No description provided for @noEquipmentFound.
  ///
  /// In en, this message translates to:
  /// **'No equipment found'**
  String get noEquipmentFound;

  /// No description provided for @addFirstEquipmentHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first equipment to get started'**
  String get addFirstEquipmentHint;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @ingredientsLow.
  ///
  /// In en, this message translates to:
  /// **'Ingredients Low'**
  String get ingredientsLow;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutes(int count);

  /// No description provided for @ingredientsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients'**
  String ingredientsCount(int count);

  /// No description provided for @mealDisabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal disabled successfully'**
  String get mealDisabledSuccess;

  /// No description provided for @mealEnabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal enabled successfully'**
  String get mealEnabledSuccess;

  /// No description provided for @failedToUpdateMealAvailability.
  ///
  /// In en, this message translates to:
  /// **'Failed to update meal availability'**
  String get failedToUpdateMealAvailability;

  /// No description provided for @deleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal'**
  String get deleteMeal;

  /// No description provided for @deleteMealConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{mealName}\"?'**
  String deleteMealConfirmation(String mealName);

  /// No description provided for @mealDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted successfully'**
  String get mealDeletedSuccess;

  /// No description provided for @failedToDeleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete meal'**
  String get failedToDeleteMeal;

  /// No description provided for @noMealsFound.
  ///
  /// In en, this message translates to:
  /// **'No meals found'**
  String get noMealsFound;

  /// No description provided for @addFirstMealHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first meal to get started'**
  String get addFirstMealHint;

  /// No description provided for @stockAnalyticsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Stock analytics - Coming soon'**
  String get stockAnalyticsComingSoon;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @articleNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Article Name *'**
  String get articleNameRequired;

  /// No description provided for @validationEnterArticleName.
  ///
  /// In en, this message translates to:
  /// **'Please enter article name'**
  String get validationEnterArticleName;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get categoryRequired;

  /// No description provided for @pricePerUnitRequired.
  ///
  /// In en, this message translates to:
  /// **'Price per Unit *'**
  String get pricePerUnitRequired;

  /// No description provided for @validationEnterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get validationEnterPrice;

  /// No description provided for @validationEnterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter valid price'**
  String get validationEnterValidPrice;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity *'**
  String get quantityRequired;

  /// No description provided for @validationEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get validationEnterQuantity;

  /// No description provided for @validationEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter valid quantity'**
  String get validationEnterValidQuantity;

  /// No description provided for @unitRequired.
  ///
  /// In en, this message translates to:
  /// **'Unit *'**
  String get unitRequired;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @imageUrlOptional.
  ///
  /// In en, this message translates to:
  /// **'Image URL (Optional)'**
  String get imageUrlOptional;

  /// No description provided for @articleAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Article added successfully'**
  String get articleAddedSuccessfully;

  /// No description provided for @articleUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Article updated successfully'**
  String get articleUpdatedSuccessfully;

  /// No description provided for @failedToAddArticle.
  ///
  /// In en, this message translates to:
  /// **'Failed to add article'**
  String get failedToAddArticle;

  /// No description provided for @failedToUpdateArticle.
  ///
  /// In en, this message translates to:
  /// **'Failed to update article'**
  String get failedToUpdateArticle;

  /// No description provided for @equipmentNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Equipment Name *'**
  String get equipmentNameRequired;

  /// No description provided for @validationEnterEquipmentName.
  ///
  /// In en, this message translates to:
  /// **'Please enter equipment name'**
  String get validationEnterEquipmentName;

  /// No description provided for @totalQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Total Quantity *'**
  String get totalQuantityRequired;

  /// No description provided for @validationEnterTotalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter total quantity'**
  String get validationEnterTotalQuantity;

  /// No description provided for @availableQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Available Quantity *'**
  String get availableQuantityRequired;

  /// No description provided for @validationEnterAvailableQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter available quantity'**
  String get validationEnterAvailableQuantity;

  /// No description provided for @validationCannotExceedTotalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed total quantity'**
  String get validationCannotExceedTotalQuantity;

  /// No description provided for @equipmentAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Equipment added successfully'**
  String get equipmentAddedSuccessfully;

  /// No description provided for @equipmentUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Equipment updated successfully'**
  String get equipmentUpdatedSuccessfully;

  /// No description provided for @failedToAddEquipment.
  ///
  /// In en, this message translates to:
  /// **'Failed to add equipment'**
  String get failedToAddEquipment;

  /// No description provided for @failedToUpdateEquipment.
  ///
  /// In en, this message translates to:
  /// **'Failed to update equipment'**
  String get failedToUpdateEquipment;

  /// No description provided for @mealNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Meal Name *'**
  String get mealNameRequired;

  /// No description provided for @validationEnterMealName.
  ///
  /// In en, this message translates to:
  /// **'Please enter meal name'**
  String get validationEnterMealName;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get descriptionRequired;

  /// No description provided for @validationEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter description'**
  String get validationEnterDescription;

  /// No description provided for @sellingPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Selling Price *'**
  String get sellingPriceRequired;

  /// No description provided for @servingsRequired.
  ///
  /// In en, this message translates to:
  /// **'Servings *'**
  String get servingsRequired;

  /// No description provided for @validationEnterServings.
  ///
  /// In en, this message translates to:
  /// **'Enter servings'**
  String get validationEnterServings;

  /// No description provided for @validationEnterValidServings.
  ///
  /// In en, this message translates to:
  /// **'Enter valid servings'**
  String get validationEnterValidServings;

  /// No description provided for @preparationTimeMinutesRequired.
  ///
  /// In en, this message translates to:
  /// **'Preparation Time (minutes) *'**
  String get preparationTimeMinutesRequired;

  /// No description provided for @validationEnterPreparationTime.
  ///
  /// In en, this message translates to:
  /// **'Enter preparation time'**
  String get validationEnterPreparationTime;

  /// No description provided for @validationEnterValidTime.
  ///
  /// In en, this message translates to:
  /// **'Enter valid time'**
  String get validationEnterValidTime;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// No description provided for @sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get sellingPrice;

  /// No description provided for @selectArticle.
  ///
  /// In en, this message translates to:
  /// **'Select Article'**
  String get selectArticle;

  /// No description provided for @searchArticles.
  ///
  /// In en, this message translates to:
  /// **'Search Articles'**
  String get searchArticles;

  /// No description provided for @addArticleName.
  ///
  /// In en, this message translates to:
  /// **'Add {articleName}'**
  String addArticleName(String articleName);

  /// No description provided for @quantityUnit.
  ///
  /// In en, this message translates to:
  /// **'Quantity ({unit})'**
  String quantityUnit(String unit);

  /// No description provided for @availableQuantityUnit.
  ///
  /// In en, this message translates to:
  /// **'Available: {quantity} {unit}'**
  String availableQuantityUnit(int quantity, String unit);

  /// No description provided for @mealAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal added successfully'**
  String get mealAddedSuccessfully;

  /// No description provided for @mealUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal updated successfully'**
  String get mealUpdatedSuccessfully;

  /// No description provided for @failedToAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Failed to add meal'**
  String get failedToAddMeal;

  /// No description provided for @failedToUpdateMeal.
  ///
  /// In en, this message translates to:
  /// **'Failed to update meal'**
  String get failedToUpdateMeal;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get pricePerUnit;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @updateArticleQuantityTitle.
  ///
  /// In en, this message translates to:
  /// **'Update {articleName} quantity'**
  String updateArticleQuantityTitle(String articleName);

  /// No description provided for @newQuantityUnit.
  ///
  /// In en, this message translates to:
  /// **'New quantity ({unit})'**
  String newQuantityUnit(String unit);

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @totalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Total Quantity'**
  String get totalQuantity;

  /// No description provided for @prepTime.
  ///
  /// In en, this message translates to:
  /// **'Prep Time'**
  String get prepTime;

  /// No description provided for @equipmentCheckoutFunctionalityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Equipment checkout functionality - Coming soon'**
  String get equipmentCheckoutFunctionalityComingSoon;

  /// No description provided for @ingredientDetails.
  ///
  /// In en, this message translates to:
  /// **'{articleName} ({quantity} {unit})'**
  String ingredientDetails(String articleName, double quantity, String unit);

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

  /// No description provided for @updateEvent.
  ///
  /// In en, this message translates to:
  /// **'Update Event'**
  String get updateEvent;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get eventTitle;

  /// No description provided for @enterEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter event title'**
  String get enterEventTitle;

  /// No description provided for @describeEvent.
  ///
  /// In en, this message translates to:
  /// **'Describe the event'**
  String get describeEvent;

  /// No description provided for @eventDate.
  ///
  /// In en, this message translates to:
  /// **'Event Date'**
  String get eventDate;

  /// No description provided for @eventTime.
  ///
  /// In en, this message translates to:
  /// **'Event Time'**
  String get eventTime;

  /// No description provided for @eventAddress.
  ///
  /// In en, this message translates to:
  /// **'Event Address'**
  String get eventAddress;

  /// No description provided for @enterCompleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter complete address'**
  String get enterCompleteAddress;

  /// No description provided for @expectedGuests.
  ///
  /// In en, this message translates to:
  /// **'Expected Guests'**
  String get expectedGuests;

  /// No description provided for @numberOfGuests.
  ///
  /// In en, this message translates to:
  /// **'Number of guests'**
  String get numberOfGuests;

  /// No description provided for @clientInformation.
  ///
  /// In en, this message translates to:
  /// **'Client Information'**
  String get clientInformation;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientName;

  /// No description provided for @enterClientName.
  ///
  /// In en, this message translates to:
  /// **'Enter client name'**
  String get enterClientName;

  /// No description provided for @clientPhone.
  ///
  /// In en, this message translates to:
  /// **'Client Phone'**
  String get clientPhone;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @clientEmail.
  ///
  /// In en, this message translates to:
  /// **'Client Email'**
  String get clientEmail;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmailAddress;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional notes'**
  String get additionalNotes;

  /// No description provided for @selectedMeals.
  ///
  /// In en, this message translates to:
  /// **'Selected Meals'**
  String get selectedMeals;

  /// No description provided for @mealsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} meal(s) selected'**
  String mealsSelected(int count);

  /// No description provided for @pricePerServing.
  ///
  /// In en, this message translates to:
  /// **'{price} per serving'**
  String pricePerServing(String price);

  /// No description provided for @selectedEquipment.
  ///
  /// In en, this message translates to:
  /// **'Selected Equipment'**
  String get selectedEquipment;

  /// No description provided for @itemsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) selected'**
  String itemsSelected(int count);

  /// No description provided for @availableQuantityTotal.
  ///
  /// In en, this message translates to:
  /// **'Available: {available}/{total}'**
  String availableQuantityTotal(int available, int total);

  /// No description provided for @selectAtLeastOneMeal.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one meal'**
  String get selectAtLeastOneMeal;

  /// No description provided for @equipmentAvailabilityConflicts.
  ///
  /// In en, this message translates to:
  /// **'Equipment availability conflicts detected. Please resolve them first.'**
  String get equipmentAvailabilityConflicts;

  /// No description provided for @eventCreatedSuccessWithBooking.
  ///
  /// In en, this message translates to:
  /// **'Event created successfully with equipment booking confirmed'**
  String get eventCreatedSuccessWithBooking;

  /// No description provided for @failedToSaveEvent.
  ///
  /// In en, this message translates to:
  /// **'Failed to save event'**
  String get failedToSaveEvent;

  /// No description provided for @checkoutEquipment.
  ///
  /// In en, this message translates to:
  /// **'Checkout Equipment'**
  String get checkoutEquipment;

  /// No description provided for @returnEquipment.
  ///
  /// In en, this message translates to:
  /// **'Return Equipment'**
  String get returnEquipment;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEvent;

  /// No description provided for @duplicateEvent.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Event'**
  String get duplicateEvent;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @cancelEvent.
  ///
  /// In en, this message translates to:
  /// **'Cancel Event'**
  String get cancelEvent;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} day(s)'**
  String inDays(int days);

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @financialSummary.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @profitMarginValue.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin: {value}%'**
  String profitMarginValue(String value);

  /// No description provided for @totalPriceValue.
  ///
  /// In en, this message translates to:
  /// **'Total Price Value: {value}%'**
  String totalPriceValue(String value);

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @quantityValue.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {value}'**
  String quantityValue(int value);

  /// No description provided for @statusValue.
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String statusValue(String value);

  /// No description provided for @checkedOutDate.
  ///
  /// In en, this message translates to:
  /// **'Checked out: {date}'**
  String checkedOutDate(String date);

  /// No description provided for @returnedDate.
  ///
  /// In en, this message translates to:
  /// **'Returned: {date}'**
  String returnedDate(String date);

  /// No description provided for @eventCreated.
  ///
  /// In en, this message translates to:
  /// **'Event Created'**
  String get eventCreated;

  /// No description provided for @eventCreatedSystem.
  ///
  /// In en, this message translates to:
  /// **'Event was created in the system'**
  String get eventCreatedSystem;

  /// No description provided for @equipmentAssigned.
  ///
  /// In en, this message translates to:
  /// **'Equipment Assigned'**
  String get equipmentAssigned;

  /// No description provided for @equipmentItemsAssigned.
  ///
  /// In en, this message translates to:
  /// **'{count} equipment items assigned'**
  String equipmentItemsAssigned(int count);

  /// No description provided for @equipmentCheckedOut.
  ///
  /// In en, this message translates to:
  /// **'Equipment Checked Out'**
  String get equipmentCheckedOut;

  /// No description provided for @itemsCheckedOut.
  ///
  /// In en, this message translates to:
  /// **'{count} items checked out'**
  String itemsCheckedOut(int count);

  /// No description provided for @eventScheduled.
  ///
  /// In en, this message translates to:
  /// **'Event Scheduled'**
  String get eventScheduled;

  /// No description provided for @eventScheduledToTakePlace.
  ///
  /// In en, this message translates to:
  /// **'Event is scheduled to take place'**
  String get eventScheduledToTakePlace;

  /// No description provided for @eventCompleted.
  ///
  /// In en, this message translates to:
  /// **'Event Completed'**
  String get eventCompleted;

  /// No description provided for @eventTookPlace.
  ///
  /// In en, this message translates to:
  /// **'Event took place'**
  String get eventTookPlace;

  /// No description provided for @equipmentReturned.
  ///
  /// In en, this message translates to:
  /// **'Equipment Returned'**
  String get equipmentReturned;

  /// No description provided for @itemsReturned.
  ///
  /// In en, this message translates to:
  /// **'{count} items returned'**
  String itemsReturned(int count);

  /// No description provided for @markAsStatus.
  ///
  /// In en, this message translates to:
  /// **'Mark as {status}'**
  String markAsStatus(String status);

  /// No description provided for @eventStatusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Event is being planned'**
  String get eventStatusPlanned;

  /// No description provided for @eventStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Event is confirmed and ready'**
  String get eventStatusConfirmed;

  /// No description provided for @eventStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'Event is currently happening'**
  String get eventStatusInProgress;

  /// No description provided for @eventStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Event has been completed'**
  String get eventStatusCompleted;

  /// No description provided for @eventStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Event has been cancelled'**
  String get eventStatusCancelled;

  /// No description provided for @unknownStatus.
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get unknownStatus;

  /// No description provided for @statusUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Status updated to {status}'**
  String statusUpdatedTo(String status);

  /// No description provided for @failedToUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status'**
  String get failedToUpdateStatus;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @unkown.
  ///
  /// In en, this message translates to:
  /// **'Unkown'**
  String get unkown;

  /// No description provided for @checkoutDate.
  ///
  /// In en, this message translates to:
  /// **'Checkout Date'**
  String get checkoutDate;

  /// No description provided for @returnDate.
  ///
  /// In en, this message translates to:
  /// **'Return Date'**
  String get returnDate;

  /// No description provided for @checkoutEquipmentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will check out all assigned equipment for this event. Make sure the equipment is ready for pickup.'**
  String get checkoutEquipmentConfirmation;

  /// No description provided for @equipmentCheckedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Equipment checked out successfully'**
  String get equipmentCheckedOutSuccessfully;

  /// No description provided for @failedToCheckoutEquipment.
  ///
  /// In en, this message translates to:
  /// **'Failed to checkout equipment'**
  String get failedToCheckoutEquipment;

  /// No description provided for @returnEquipmentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will return all checked out equipment for this event. Make sure all equipment has been collected and is in good condition.'**
  String get returnEquipmentConfirmation;

  /// No description provided for @returnText.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnText;

  /// No description provided for @equipmentReturnedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Equipment returned successfully'**
  String get equipmentReturnedSuccessfully;

  /// No description provided for @failedToReturnEquipment.
  ///
  /// In en, this message translates to:
  /// **'Failed to return equipment'**
  String get failedToReturnEquipment;

  /// No description provided for @occasionManagement.
  ///
  /// In en, this message translates to:
  /// **'Occasion Management'**
  String get occasionManagement;

  /// No description provided for @allEvents.
  ///
  /// In en, this message translates to:
  /// **'All Events'**
  String get allEvents;

  /// No description provided for @newEvent.
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get newEvent;

  /// No description provided for @searchOccasions.
  ///
  /// In en, this message translates to:
  /// **'Search occasions...'**
  String get searchOccasions;

  /// No description provided for @noOccasionsFoundSearch.
  ///
  /// In en, this message translates to:
  /// **'No occasions found for \"{query}\"'**
  String noOccasionsFoundSearch(String query);

  /// No description provided for @noOccasionsFound.
  ///
  /// In en, this message translates to:
  /// **'No occasions found'**
  String get noOccasionsFound;

  /// No description provided for @addFirstEvent.
  ///
  /// In en, this message translates to:
  /// **'Add First Event'**
  String get addFirstEvent;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @eventIsToday.
  ///
  /// In en, this message translates to:
  /// **'Event is today!'**
  String get eventIsToday;

  /// No description provided for @margin.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get margin;

  /// No description provided for @requiresAttention.
  ///
  /// In en, this message translates to:
  /// **'Requires Attention'**
  String get requiresAttention;

  /// No description provided for @totalEvents.
  ///
  /// In en, this message translates to:
  /// **'Total Events'**
  String get totalEvents;

  /// No description provided for @totalProfit.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get totalProfit;

  /// No description provided for @viewCalendar.
  ///
  /// In en, this message translates to:
  /// **'View Calendar'**
  String get viewCalendar;

  /// No description provided for @analyticsDashboard.
  ///
  /// In en, this message translates to:
  /// **'Analytics Dashboard'**
  String get analyticsDashboard;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @duplicatingEvent.
  ///
  /// In en, this message translates to:
  /// **'Duplicating {eventName}'**
  String duplicatingEvent(String eventName);

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEvent;

  /// No description provided for @deleteEventConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{eventName}\"? This action cannot be undone.'**
  String deleteEventConfirmation(String eventName);

  /// No description provided for @eventDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Event deleted successfully'**
  String get eventDeletedSuccessfully;

  /// No description provided for @eventUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Event updated successfully'**
  String get eventUpdatedSuccessfully;

  /// No description provided for @isRunningLow.
  ///
  /// In en, this message translates to:
  /// **'is running low'**
  String get isRunningLow;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @equipmentFullyBooked.
  ///
  /// In en, this message translates to:
  /// **'Equipment Fully Booked'**
  String get equipmentFullyBooked;

  /// No description provided for @isFullyCheckedOut.
  ///
  /// In en, this message translates to:
  /// **'is fully checked out'**
  String get isFullyCheckedOut;

  /// No description provided for @refreshAlerts.
  ///
  /// In en, this message translates to:
  /// **'Refresh Alerts'**
  String get refreshAlerts;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @noUrgentAlerts.
  ///
  /// In en, this message translates to:
  /// **'No urgent alerts'**
  String get noUrgentAlerts;

  /// No description provided for @noEventAlerts.
  ///
  /// In en, this message translates to:
  /// **'No event alerts'**
  String get noEventAlerts;

  /// No description provided for @noEquipmentAlerts.
  ///
  /// In en, this message translates to:
  /// **'No equipment alerts'**
  String get noEquipmentAlerts;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @alertDismissed.
  ///
  /// In en, this message translates to:
  /// **'Alert dismissed'**
  String get alertDismissed;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @inHours.
  ///
  /// In en, this message translates to:
  /// **'in {hours} hour(s)'**
  String inHours(int hours);

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @restock.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get restock;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @allAlertsMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All alerts marked as read'**
  String get allAlertsMarkedAsRead;

  /// No description provided for @checkoutEquipmentForEvent.
  ///
  /// In en, this message translates to:
  /// **'Checkout equipment for this event'**
  String get checkoutEquipmentForEvent;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @equipmentItems.
  ///
  /// In en, this message translates to:
  /// **'Equipment Items'**
  String get equipmentItems;

  /// No description provided for @restockItem.
  ///
  /// In en, this message translates to:
  /// **'Restock Item'**
  String get restockItem;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStock;

  /// No description provided for @addQuantity.
  ///
  /// In en, this message translates to:
  /// **'Add Quantity'**
  String get addQuantity;

  /// No description provided for @addStock.
  ///
  /// In en, this message translates to:
  /// **'Add Stock'**
  String get addStock;

  /// No description provided for @eventReminders.
  ///
  /// In en, this message translates to:
  /// **'Event Reminders'**
  String get eventReminders;

  /// No description provided for @getNotifiedAboutUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Get notified about upcoming events'**
  String get getNotifiedAboutUpcomingEvents;

  /// No description provided for @equipmentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Equipment Alerts'**
  String get equipmentAlerts;

  /// No description provided for @equipmentCheckoutAndAvailabilityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Equipment checkout and availability alerts'**
  String get equipmentCheckoutAndAvailabilityAlerts;

  /// No description provided for @stockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Stock Alerts'**
  String get stockAlerts;

  /// No description provided for @lowStockAndInventoryAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low stock and inventory alerts'**
  String get lowStockAndInventoryAlerts;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @receivePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get receivePushNotifications;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @addedQuantityToItem.
  ///
  /// In en, this message translates to:
  /// **'Added {quantity} {unit} to {itemName}'**
  String addedQuantityToItem(int quantity, String unit, String itemName);

  /// No description provided for @failedToRestock.
  ///
  /// In en, this message translates to:
  /// **'Failed to restock'**
  String get failedToRestock;

  /// No description provided for @shareAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Share Analytics'**
  String get shareAnalytics;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @changePeriod.
  ///
  /// In en, this message translates to:
  /// **'Change Period'**
  String get changePeriod;

  /// No description provided for @quickInsights.
  ///
  /// In en, this message translates to:
  /// **'Quick Insights'**
  String get quickInsights;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @needsImprovement.
  ///
  /// In en, this message translates to:
  /// **'Needs Improvement'**
  String get needsImprovement;

  /// No description provided for @highestRevenueMonth.
  ///
  /// In en, this message translates to:
  /// **'Highest Revenue Month'**
  String get highestRevenueMonth;

  /// No description provided for @eventSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Event Success Rate'**
  String get eventSuccessRate;

  /// No description provided for @eventsCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Events completed successfully'**
  String get eventsCompletedSuccessfully;

  /// No description provided for @topPerformingEvents.
  ///
  /// In en, this message translates to:
  /// **'Top Performing Events'**
  String get topPerformingEvents;

  /// No description provided for @noCompletedEventsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No completed events in this period'**
  String get noCompletedEventsInPeriod;

  /// No description provided for @revenueTrend.
  ///
  /// In en, this message translates to:
  /// **'Revenue Trend'**
  String get revenueTrend;

  /// No description provided for @eventsCount.
  ///
  /// In en, this message translates to:
  /// **'Events Count'**
  String get eventsCount;

  /// No description provided for @profitMarginTrend.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin Trend'**
  String get profitMarginTrend;

  /// No description provided for @revenueChart.
  ///
  /// In en, this message translates to:
  /// **'Revenue Chart'**
  String get revenueChart;

  /// No description provided for @eventsCountChart.
  ///
  /// In en, this message translates to:
  /// **'Events Count Chart'**
  String get eventsCountChart;

  /// No description provided for @profitMarginChart.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin Chart'**
  String get profitMarginChart;

  /// No description provided for @noDataAvailableForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data available for this period'**
  String get noDataAvailableForPeriod;

  /// No description provided for @performanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Performance Summary'**
  String get performanceSummary;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @bestMonth.
  ///
  /// In en, this message translates to:
  /// **'Best Month'**
  String get bestMonth;

  /// No description provided for @avgProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Avg Profit Margin'**
  String get avgProfitMargin;

  /// No description provided for @growthRate.
  ///
  /// In en, this message translates to:
  /// **'Growth Rate'**
  String get growthRate;

  /// No description provided for @performanceByEventSize.
  ///
  /// In en, this message translates to:
  /// **'Performance by Event Size'**
  String get performanceByEventSize;

  /// No description provided for @smallEvents.
  ///
  /// In en, this message translates to:
  /// **'Small Events'**
  String get smallEvents;

  /// No description provided for @mediumEvents.
  ///
  /// In en, this message translates to:
  /// **'Medium Events'**
  String get mediumEvents;

  /// No description provided for @largeEvents.
  ///
  /// In en, this message translates to:
  /// **'Large Events'**
  String get largeEvents;

  /// No description provided for @eventsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} events'**
  String eventsCountLabel(int count);

  /// No description provided for @monthlyComparison.
  ///
  /// In en, this message translates to:
  /// **'Monthly Comparison'**
  String get monthlyComparison;

  /// No description provided for @noDataAvailableForMonthlyComparison.
  ///
  /// In en, this message translates to:
  /// **'No data available for monthly comparison'**
  String get noDataAvailableForMonthlyComparison;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @exportFunctionalityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Export functionality coming soon'**
  String get exportFunctionalityComingSoon;

  /// No description provided for @shareFunctionalityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share functionality coming soon'**
  String get shareFunctionalityComingSoon;

  /// No description provided for @settingsFunctionalityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Settings functionality coming soon'**
  String get settingsFunctionalityComingSoon;

  /// No description provided for @loginScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Traiteur Management'**
  String get loginScreenTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInToManage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your catering business'**
  String get signInToManage;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @passwordText.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordText;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @orText.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orText;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @copyrightText.
  ///
  /// In en, this message translates to:
  /// **'© 2024 Traiteur Management System'**
  String get copyrightText;

  /// No description provided for @versionText.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get versionText;

  /// No description provided for @loginFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailedMessage;

  /// No description provided for @pleaseEnterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address first'**
  String get pleaseEnterEmailFirst;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent successfully'**
  String get passwordResetEmailSent;

  /// No description provided for @failedToSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email'**
  String get failedToSendResetEmail;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @professionalCateringManagement.
  ///
  /// In en, this message translates to:
  /// **'Professional Catering Management'**
  String get professionalCateringManagement;

  /// No description provided for @loadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage;

  /// No description provided for @totalReturns.
  ///
  /// In en, this message translates to:
  /// **'Total Returns'**
  String get totalReturns;

  /// No description provided for @takeItemsForEvent.
  ///
  /// In en, this message translates to:
  /// **'Take items for event'**
  String get takeItemsForEvent;

  /// No description provided for @quickReturn.
  ///
  /// In en, this message translates to:
  /// **'Quick Return'**
  String get quickReturn;

  /// No description provided for @returnMultipleItems.
  ///
  /// In en, this message translates to:
  /// **'Return multiple items'**
  String get returnMultipleItems;

  /// No description provided for @noActiveCheckouts.
  ///
  /// In en, this message translates to:
  /// **'No active checkouts'**
  String get noActiveCheckouts;

  /// No description provided for @allEquipmentReturned.
  ///
  /// In en, this message translates to:
  /// **'All equipment has been returned.'**
  String get allEquipmentReturned;

  /// No description provided for @myActivity.
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get myActivity;

  /// No description provided for @noEquipmentToReturn.
  ///
  /// In en, this message translates to:
  /// **'No equipment to return'**
  String get noEquipmentToReturn;

  /// No description provided for @confirmReturn.
  ///
  /// In en, this message translates to:
  /// **'Confirm Return'**
  String get confirmReturn;

  /// No description provided for @confirmReturnEquipment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to return this equipment?'**
  String get confirmReturnEquipment;

  /// No description provided for @myEquipmentHistory.
  ///
  /// In en, this message translates to:
  /// **'My Equipment History'**
  String get myEquipmentHistory;

  /// No description provided for @equipmentOverdue.
  ///
  /// In en, this message translates to:
  /// **'Equipment Overdue'**
  String get equipmentOverdue;

  /// No description provided for @equipmentCheckedOutAgo.
  ///
  /// In en, this message translates to:
  /// **'Equipment checked out {duration} ago'**
  String equipmentCheckedOutAgo(String duration);

  /// No description provided for @noNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get noNewNotifications;

  /// No description provided for @atText.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get atText;

  /// No description provided for @failedToLoadActivityData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load activity data: {error}'**
  String failedToLoadActivityData(String error);

  /// No description provided for @unknownEquipment.
  ///
  /// In en, this message translates to:
  /// **'Unknown Equipment'**
  String get unknownEquipment;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @occasionId.
  ///
  /// In en, this message translates to:
  /// **'Occasion ID'**
  String get occasionId;

  /// No description provided for @equipmentOverdueForReturn.
  ///
  /// In en, this message translates to:
  /// **'This equipment is overdue for return'**
  String get equipmentOverdueForReturn;

  /// No description provided for @filterByDateRange.
  ///
  /// In en, this message translates to:
  /// **'Filter by date range'**
  String get filterByDateRange;

  /// No description provided for @clearDateFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear date filter'**
  String get clearDateFilter;

  /// No description provided for @searchEquipmentOrNotes.
  ///
  /// In en, this message translates to:
  /// **'Search equipment or notes...'**
  String get searchEquipmentOrNotes;

  /// No description provided for @showingDateRange.
  ///
  /// In en, this message translates to:
  /// **'Showing {startDate} - {endDate}'**
  String showingDateRange(String startDate, String endDate);

  /// No description provided for @noReturnedItems.
  ///
  /// In en, this message translates to:
  /// **'No returned items'**
  String get noReturnedItems;

  /// No description provided for @noEquipmentReturnedYet.
  ///
  /// In en, this message translates to:
  /// **'No equipment has been returned yet.'**
  String get noEquipmentReturnedYet;

  /// No description provided for @noOverdueItems.
  ///
  /// In en, this message translates to:
  /// **'No overdue items'**
  String get noOverdueItems;

  /// No description provided for @allEquipmentReturnedOnTime.
  ///
  /// In en, this message translates to:
  /// **'Great! All equipment is returned on time.'**
  String get allEquipmentReturnedOnTime;

  /// No description provided for @noActivityFound.
  ///
  /// In en, this message translates to:
  /// **'No activity found'**
  String get noActivityFound;

  /// No description provided for @noEquipmentActivityMatchesSearch.
  ///
  /// In en, this message translates to:
  /// **'No equipment activity matches your search.'**
  String get noEquipmentActivityMatchesSearch;

  /// No description provided for @out.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get out;

  /// No description provided for @inText.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get inText;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'ongoing'**
  String get ongoing;

  /// No description provided for @durationDaysHours.
  ///
  /// In en, this message translates to:
  /// **'{days}d {hours}h'**
  String durationDaysHours(int days, int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @chairs.
  ///
  /// In en, this message translates to:
  /// **'Chairs'**
  String get chairs;

  /// No description provided for @tables.
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get tables;

  /// No description provided for @utensils.
  ///
  /// In en, this message translates to:
  /// **'Utensils'**
  String get utensils;

  /// No description provided for @decorations.
  ///
  /// In en, this message translates to:
  /// **'Decorations'**
  String get decorations;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @failedToLoadEquipment.
  ///
  /// In en, this message translates to:
  /// **'Failed to load equipment: {error}'**
  String failedToLoadEquipment(String error);

  /// No description provided for @equipmentCheckoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Equipment Checkout'**
  String get equipmentCheckoutTitle;

  /// No description provided for @checkoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Checkout Confirmation'**
  String get checkoutConfirmation;

  /// No description provided for @confirmCheckoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to checkout the selected equipment?'**
  String get confirmCheckoutMessage;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @checkoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Equipment checked out successfully!'**
  String get checkoutSuccess;

  /// No description provided for @checkoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to checkout equipment.'**
  String get checkoutFailed;

  /// No description provided for @quantityUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Selected quantity for {equipmentName} is not available. Available: {availableQuantity}'**
  String quantityUnavailable(String equipmentName, int availableQuantity);

  /// No description provided for @selectedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Selected Quantity: {quantity}'**
  String selectedQuantity(int quantity);

  /// No description provided for @pleaseSelectEquipmentToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Please select equipment to checkout.'**
  String get pleaseSelectEquipmentToCheckout;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated.'**
  String get userNotAuthenticated;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @checkoutSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Checkout Successful'**
  String get checkoutSuccessful;

  /// No description provided for @successfullyCheckedOut.
  ///
  /// In en, this message translates to:
  /// **'Successfully checked out!'**
  String get successfullyCheckedOut;

  /// No description provided for @equipmentTypesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} types selected'**
  String equipmentTypesCount(int count);

  /// Indicates that a certain number of equipment types have been selected
  ///
  /// In en, this message translates to:
  /// **'{equipmentTypesString} selected'**
  String typesSelected(String equipmentTypesString);

  /// No description provided for @totalItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String totalItemsCount(int count);

  /// No description provided for @forText.
  ///
  /// In en, this message translates to:
  /// **'for'**
  String get forText;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @equipmentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Equipment Unavailable'**
  String get equipmentUnavailable;

  /// No description provided for @equipmentNotAvailableInRequestedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Some equipment is not available in the requested quantity.'**
  String get equipmentNotAvailableInRequestedQuantity;

  /// No description provided for @adjustQuantitiesOrRemoveUnavailableItems.
  ///
  /// In en, this message translates to:
  /// **'Please adjust quantities or remove unavailable items.'**
  String get adjustQuantitiesOrRemoveUnavailableItems;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @searchEquipment.
  ///
  /// In en, this message translates to:
  /// **'Search equipment...'**
  String get searchEquipment;

  /// No description provided for @tryAdjustingYourSearchTerms.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms.'**
  String get tryAdjustingYourSearchTerms;

  /// No description provided for @noEquipmentAvailableInCategory.
  ///
  /// In en, this message translates to:
  /// **'No equipment available in this category.'**
  String get noEquipmentAvailableInCategory;

  /// No description provided for @quantityToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Quantity to checkout'**
  String get quantityToCheckout;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryManagement;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @validationEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get validationEnterCategoryName;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {category}?'**
  String confirmDeleteCategory(Object category);

  /// No description provided for @validationSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get validationSelectCategory;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @financialTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get financialTabTitle;

  /// No description provided for @mealsTotal.
  ///
  /// In en, this message translates to:
  /// **'Meals Total'**
  String get mealsTotal;

  /// No description provided for @equipmentDepreciation.
  ///
  /// In en, this message translates to:
  /// **'Equipment Depreciation (%)'**
  String get equipmentDepreciation;

  /// No description provided for @transportCost.
  ///
  /// In en, this message translates to:
  /// **'Transport Cost'**
  String get transportCost;

  /// No description provided for @costBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Cost Breakdown'**
  String get costBreakdown;

  /// No description provided for @dhCurrency.
  ///
  /// In en, this message translates to:
  /// **'DH'**
  String get dhCurrency;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @mealsCost.
  ///
  /// In en, this message translates to:
  /// **'Meals Cost'**
  String get mealsCost;

  /// No description provided for @equipmentRental.
  ///
  /// In en, this message translates to:
  /// **'Equipment Rental'**
  String get equipmentRental;

  /// No description provided for @totalBaseCost.
  ///
  /// In en, this message translates to:
  /// **'Total Base Cost'**
  String get totalBaseCost;

  /// No description provided for @equipmentRentalPricing.
  ///
  /// In en, this message translates to:
  /// **'Equipment Rental Pricing'**
  String get equipmentRentalPricing;

  /// No description provided for @totalEquipmentRentalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Equipment Rental Price'**
  String get totalEquipmentRentalPrice;

  /// No description provided for @enterEquipmentRentalPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter Equipment Rental Price'**
  String get enterEquipmentRentalPrice;

  /// No description provided for @autoCalculate.
  ///
  /// In en, this message translates to:
  /// **'Auto Calculate'**
  String get autoCalculate;

  /// No description provided for @equipmentBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Equipment Breakdown'**
  String get equipmentBreakdown;

  /// No description provided for @transportConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Transport Configuration'**
  String get transportConfiguration;

  /// No description provided for @transportDeliveryCost.
  ///
  /// In en, this message translates to:
  /// **'Transport/Delivery Cost'**
  String get transportDeliveryCost;

  /// No description provided for @enterTransportCost.
  ///
  /// In en, this message translates to:
  /// **'Enter Transport Cost'**
  String get enterTransportCost;

  /// No description provided for @profitMarginConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin Configuration'**
  String get profitMarginConfiguration;

  /// No description provided for @profitMarginPercentage.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin Percentage'**
  String get profitMarginPercentage;

  /// No description provided for @enterProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Enter Profit Margin'**
  String get enterProfitMargin;

  /// No description provided for @finalPricingSummary.
  ///
  /// In en, this message translates to:
  /// **'Final Pricing Summary'**
  String get finalPricingSummary;

  /// No description provided for @baseCost.
  ///
  /// In en, this message translates to:
  /// **'Base Cost'**
  String get baseCost;

  /// No description provided for @profitAmount.
  ///
  /// In en, this message translates to:
  /// **'Profit Amount'**
  String get profitAmount;

  /// No description provided for @finalTotalPrice.
  ///
  /// In en, this message translates to:
  /// **'Final Total Price'**
  String get finalTotalPrice;

  /// No description provided for @estimatedPricePerGuest.
  ///
  /// In en, this message translates to:
  /// **'Estimated Price per Guest'**
  String get estimatedPricePerGuest;

  /// No description provided for @searchMeals.
  ///
  /// In en, this message translates to:
  /// **'Search Meals'**
  String get searchMeals;

  /// Error message when checkout request fails
  ///
  /// In en, this message translates to:
  /// **'Checkout request failed'**
  String get checkoutRequestFailed;

  /// Title for successful request submission
  ///
  /// In en, this message translates to:
  /// **'Request submitted'**
  String get requestSubmitted;

  /// Message shown when checkout request is successful
  ///
  /// In en, this message translates to:
  /// **'Checkout request submitted successfully'**
  String get checkoutRequestSubmittedSuccessfully;

  /// Message informing user that admin will review request
  ///
  /// In en, this message translates to:
  /// **'Admin will review your request shortly'**
  String get adminWillReviewRequest;

  /// Loading text when submitting request
  ///
  /// In en, this message translates to:
  /// **'Submitting request...'**
  String get submittingRequest;

  /// Text for submit request button
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @equipmentRequests.
  ///
  /// In en, this message translates to:
  /// **'Equipment Requests'**
  String get equipmentRequests;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get pendingApproval;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No Pending Requests'**
  String get noPendingRequests;

  /// No description provided for @allRequestsProcessed.
  ///
  /// In en, this message translates to:
  /// **'All requests have been processed'**
  String get allRequestsProcessed;

  /// No description provided for @reviewRequests.
  ///
  /// In en, this message translates to:
  /// **'Review Requests'**
  String get reviewRequests;

  /// No description provided for @viewAllRequests.
  ///
  /// In en, this message translates to:
  /// **'View All Requests'**
  String get viewAllRequests;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String hoursAgo(int count);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String minutesAgo(int count);

  /// No description provided for @requestSummary.
  ///
  /// In en, this message translates to:
  /// **'{itemCount, plural, =1{1 item} other{{itemCount} items}} • {totalQuantity} total'**
  String requestSummary(int itemCount, int totalQuantity);

  /// No description provided for @andMoreItems.
  ///
  /// In en, this message translates to:
  /// **'and {count, plural, =1{1 more item} other{{count} more items}}'**
  String andMoreItems(int count);

  /// No description provided for @andMoreRequests.
  ///
  /// In en, this message translates to:
  /// **'+{count, plural, =1{1 more request} other{{count} more requests}}'**
  String andMoreRequests(int count);

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @operationName.
  ///
  /// In en, this message translates to:
  /// **'Operation Name'**
  String get operationName;

  /// No description provided for @enterOperationName.
  ///
  /// In en, this message translates to:
  /// **'Enter operation name'**
  String get enterOperationName;

  /// No description provided for @operationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Operation name is required'**
  String get operationNameRequired;

  /// No description provided for @operationNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Operation name must be at least 2 characters'**
  String get operationNameMinLength;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @invalidAmountFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount format'**
  String get invalidAmountFormat;

  /// No description provided for @amountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be positive'**
  String get amountMustBePositive;

  /// No description provided for @transactionDate.
  ///
  /// In en, this message translates to:
  /// **'Transaction Date'**
  String get transactionDate;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @depositAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deposit added successfully'**
  String get depositAddedSuccess;

  /// No description provided for @withdrawalAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal added successfully'**
  String get withdrawalAddedSuccess;

  /// No description provided for @addTransactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add transaction: {error}'**
  String addTransactionFailed(Object error);

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @transactionUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully'**
  String get transactionUpdatedSuccess;

  /// No description provided for @updateTransactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update transaction: {error}'**
  String updateTransactionFailed(Object error);

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @cashRegister.
  ///
  /// In en, this message translates to:
  /// **'Cash Register'**
  String get cashRegister;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @loadingCashData.
  ///
  /// In en, this message translates to:
  /// **'Loading cash register data...'**
  String get loadingCashData;

  /// No description provided for @realtimeBalance.
  ///
  /// In en, this message translates to:
  /// **'Real-time Balance'**
  String get realtimeBalance;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @totalDeposits.
  ///
  /// In en, this message translates to:
  /// **'Total Deposits'**
  String get totalDeposits;

  /// No description provided for @transactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactionsCount(Object count);

  /// No description provided for @totalWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Total Withdrawals'**
  String get totalWithdrawals;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No Transactions'**
  String get noTransactions;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found. Add your first transaction!'**
  String get noTransactionsFound;

  /// No description provided for @noMatchingTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions match the selected filters.'**
  String get noMatchingTransactions;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// No description provided for @deposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get deposits;

  /// No description provided for @withdrawals.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get withdrawals;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @customRangeDisplay.
  ///
  /// In en, this message translates to:
  /// **'Custom Range: {startDate} - {endDate}'**
  String customRangeDisplay(Object endDate, Object startDate);

  /// No description provided for @cashFlowAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow Analytics'**
  String get cashFlowAnalytics;

  /// No description provided for @transactionCount.
  ///
  /// In en, this message translates to:
  /// **'Transaction Count'**
  String get transactionCount;

  /// No description provided for @averageDeposit.
  ///
  /// In en, this message translates to:
  /// **'Average Deposit'**
  String get averageDeposit;

  /// No description provided for @averageWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Average Withdrawal'**
  String get averageWithdrawal;

  /// No description provided for @netFlow.
  ///
  /// In en, this message translates to:
  /// **'Net Flow'**
  String get netFlow;

  /// No description provided for @chartComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Chart implementation coming soon'**
  String get chartComingSoon;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction: \"{transactionName}\"?'**
  String confirmDeleteMessage(Object transactionName);

  /// No description provided for @transactionDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeletedSuccess;

  /// No description provided for @deleteTransactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete transaction: {error}'**
  String deleteTransactionFailed(Object error);

  /// No description provided for @addedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by'**
  String get addedBy;

  /// No description provided for @transactionOptions.
  ///
  /// In en, this message translates to:
  /// **'Transaction Options'**
  String get transactionOptions;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This app needs camera and photo library permissions to add images. Please grant permissions in settings.'**
  String get permissionRequiredMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @imagePickerError.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get imagePickerError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

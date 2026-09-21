// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'log on';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create Account';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get phoneLogin => 'Phone';

  @override
  String get emailLogin => 'Email';

  @override
  String get emailTitle => 'E-mail';

  @override
  String get enterEmailHint => 'Please enter your email';

  @override
  String get enterPasswordHint => 'Enter your password';

  @override
  String get newPasswordHint => 'Set new password';

  @override
  String get confirmPasswordHint => 'Confirm password';

  @override
  String get enterEmailCodeHint => 'Enter code from the email';

  @override
  String get sendCode => 'sent code';

  @override
  String get emptyAccountOrPassword => 'Please fill in all fields';

  @override
  String get invalidAccountFormat => 'Please enter a valid email address';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get resetPasswordSuccess =>
      'Password reset successfully, please log in';

  @override
  String get hasAccountGoLogin => 'Already have an account? Log In';

  @override
  String get rememberPasswordGoLogin => 'Remember password? Log In';

  @override
  String get submitAndRegister => 'Submit and register';

  @override
  String get tokenParseError => 'Failed to parse login token, please try again';

  @override
  String get accountOrPasswordError => 'Incorrect account or password';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get selectCountry => 'Select Country/Region';

  @override
  String get agreePrefix => 'I have read and agree to ';

  @override
  String get userAgreement => 'User Agreement';

  @override
  String get andText => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get timesUnit => 'times';

  @override
  String get secondsUnit => 's';

  @override
  String get minutesUnit => 'mins';

  @override
  String get tabDevice => 'Devices';

  @override
  String get tabUsage => 'Statistics';

  @override
  String get tabUser => 'User';

  @override
  String get actionIdle => 'Idle';

  @override
  String get actionAddLitter => 'Add Litter';

  @override
  String get actionEmptyLitter => 'Empty Litter';

  @override
  String get actionResetting => 'Resetting';

  @override
  String get networkError => 'Network Error';

  @override
  String get selectCountryRegion => 'Select Country / Region';

  @override
  String get searchCountryHint => 'Search country or region code';

  @override
  String get noMatchingRegion => 'No matching region found';

  @override
  String get wifiConfigTitle => 'Configure Network';

  @override
  String get selectWifiTitle => 'Select Device Wi-Fi';

  @override
  String get wifiConfigDesc =>
      'Please select a Wi-Fi network and enter the password.';

  @override
  String get wifiPasswordHint => 'Please enter Wi-Fi password';

  @override
  String get searchingLabel => 'Search Device';

  @override
  String get startConfig => 'Start Provisioning';

  @override
  String get configProgress => 'Connecting device to network...';

  @override
  String get configStep1 => 'Sending network configuration to device';

  @override
  String get configStep2 => 'Device is connecting to router';

  @override
  String get configStep3 => 'Registering device with cloud';

  @override
  String get configSuccess => 'Device added successfully!';

  @override
  String get autoSearching => 'Searching for available devices...';

  @override
  String get noDeviceFoundDesc =>
      'No device connected currently, please tap below to connect.';

  @override
  String get searchingAvailable => 'Searching for available devices';

  @override
  String get networkSettings => 'Search & Provisioning Settings';

  @override
  String get filterUnknownDevices => 'Filter Unknown Devices';

  @override
  String get hideUnnamedDevices => 'Hide unnamed Bluetooth devices';

  @override
  String get autoFetchWifi => 'Auto Fetch Nearby Wi-Fi';

  @override
  String get autoFetchWifiDesc =>
      'Disable to skip scan command and use phone\'s current Wi-Fi';

  @override
  String get exactFilter => 'Exact Filter';

  @override
  String get exactFilterHint =>
      'Enter device names to include (leave empty for none)';

  @override
  String get saveAndResearch => 'Save and Rescan';

  @override
  String get searchAgain => 'Rescan';

  @override
  String get connect => 'Connect';

  @override
  String get preparingDeviceChannel => 'Preparing device channel';

  @override
  String get configError => 'Configuration error';

  @override
  String get reconfig => 'Reconfigure';

  @override
  String get deviceAddedDesc =>
      'Your device has successfully connected to the network and bound.';

  @override
  String get manageDevice => 'Manage Device';

  @override
  String get backToHome => 'Return to Home';

  @override
  String get noBlePermission => 'Bluetooth permission not granted';

  @override
  String get ensureBleOn => 'Please ensure Bluetooth is enabled';

  @override
  String get bleScanFailed => 'Bluetooth scan failed';

  @override
  String get bleConnectFailed => 'Failed to connect via Bluetooth';

  @override
  String get wifiOrPwdEmpty => 'Wi-Fi SSID or password cannot be empty';

  @override
  String get getMqttFailed => 'Failed to obtain MQTT configuration';

  @override
  String get bindDeviceFailed => 'Failed to bind device, please try again';

  @override
  String get wifiPwdError => 'Wi-Fi password incorrect or signal too weak';

  @override
  String get networkInterrupted => 'Network connection interrupted';

  @override
  String get configTimeoutOrError => 'Provisioning exception or timeout';

  @override
  String get bleConnectedLog => 'Bluetooth low-level connected';

  @override
  String get bleSubscribedLog => 'Characteristic subscribed successfully';

  @override
  String get wifiScanSuccessLog =>
      'Nearby Wi-Fi list retrieved, waiting for confirmation';

  @override
  String get wifiSkipScanLog =>
      'Device Wi-Fi scan disabled, using phone\'s current Wi-Fi';

  @override
  String get myDevices => 'My Devices';

  @override
  String get addDevice => 'Add Device';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get renameDevice => 'Rename Device';

  @override
  String get deleteDevice => 'Delete Device';

  @override
  String deleteDeviceConfirm(Object name) {
    return 'Are you sure you want to remove device \"$name\"? You will lose control after unbinding.';
  }

  @override
  String get deleteSuccess => 'Device unlinked successfully';

  @override
  String get deleteFailed => 'Failed to delete, please try again';

  @override
  String get deleting => 'Deleting...';

  @override
  String get enterNewDeviceName => 'Enter new device name';

  @override
  String get nameUpdated => 'Device name updated';

  @override
  String get todayToilet => 'Today Visits';

  @override
  String get averageDuration => 'Avg Duration';

  @override
  String get autoMode => 'Auto\nMode';

  @override
  String get dndMode => 'DND\nMode';

  @override
  String get timerMode => 'Timer\nMode';

  @override
  String get manualMode => 'Manual\nMode';

  @override
  String get actionClean => 'Clean';

  @override
  String get actionSmooth => 'Smooth';

  @override
  String get actionDeodorize => 'Deodorize';

  @override
  String get actionChildLock => 'Lock';

  @override
  String get todayLogs => 'Today\'s Activity';

  @override
  String get noLogs => 'No activity recorded';

  @override
  String get deviceSetting => 'Device Settings';

  @override
  String get firmwareVersion => 'Firmware Version';

  @override
  String get serialNumber => 'Serial Number';

  @override
  String get timezoneSetting => 'Time Zone';

  @override
  String get modeAndParams => 'Modes & Configurations';

  @override
  String get autoModeDelay => 'Auto Delay';

  @override
  String get dndTimeRange => 'DND Time Range';

  @override
  String get timerSchedule => 'Timer Schedule';

  @override
  String get moreTools => 'Tools & Support';

  @override
  String get firmwareUpgrade => 'Firmware Upgrade';

  @override
  String get firmwareUpgrading => 'Upgrading...';

  @override
  String get upgrading => 'Upgrading';

  @override
  String get wifiInfo => 'Wi-Fi Information';

  @override
  String get weighingCalibration => 'Scale Calibration';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String newFirmwareFound(Object version) {
    return 'New version ($version) detected. Upgrade now? The process takes 1-2 minutes.';
  }

  @override
  String get confirmUpgrade => 'Upgrade';

  @override
  String get upgradeDispatched => 'Upgrade command sent. Detecting status...';

  @override
  String get upgradeSuccess => 'Firmware upgrade completed!';

  @override
  String get upgradeTimeout => 'OTA upgrade timed out, please check device';

  @override
  String get deviceOfflineError => 'Device is offline';

  @override
  String get deviceOperatingError => 'Device is operating, please wait';

  @override
  String get operationSuccess => 'Success';

  @override
  String get operationFailed => 'Operation failed';

  @override
  String get useGuide => 'User Guide';

  @override
  String get guideStep1 => '1. Ensure device is powered on and connected';

  @override
  String get guideStep2 => '2. Tap top-right + button to pair a new device';

  @override
  String get guideStep3 => '3. Swipe left on card to rename or delete';

  @override
  String get guideStep4 => '4. Pull down to refresh device status';

  @override
  String get iUnderstand => 'Got it';

  @override
  String catToiletLog(Object seconds) {
    return 'Cat toilet visit: ${seconds}s';
  }

  @override
  String get scaleCalibrationTitle => 'Scale Calibration';

  @override
  String get scaleStep1Title => 'Preparation';

  @override
  String get scaleStep1Desc =>
      '· Ensure no obstacles around the litter box\n· Ensure device is placed on a hard, flat floor';

  @override
  String get scaleStep2Title => 'Choose Reference Weight';

  @override
  String get scaleStep2Desc =>
      '· Ensure the reference object is between 1000g and 5000g';

  @override
  String get enterWeightInGrams => 'Enter weight in grams';

  @override
  String get selectObjectFromList => 'Place object stably in the center';

  @override
  String get scaleStep3Title => 'Place Reference Object';

  @override
  String get scaleStep3Desc =>
      'Place the reference object into the device chamber';

  @override
  String get scaleStep4Title => 'Calibration Completed';

  @override
  String get scaleStep4Desc => 'Weight sensor calibrated successfully';

  @override
  String get nextStep => 'Next Step';

  @override
  String get done => 'Done';

  @override
  String get invalidWeightError => 'Please enter a valid weight (> 0g)';

  @override
  String get timeZoneTitle => 'Device Time Zone';

  @override
  String get searchTimezoneHint => 'Search timezone (e.g. Asia/Shanghai)...';

  @override
  String useSystemTimezone(Object timezone) {
    return 'Use system timezone ($timezone)';
  }

  @override
  String get noTimerRecord => 'No timer record';

  @override
  String get addTimer => 'Add Timer';

  @override
  String get selectExecutionTime => 'Select Execution Time';

  @override
  String get saveTimersSuccess =>
      'Timers saved and synced to device successfully';

  @override
  String get saveTimersFailed => 'Failed to save timers, please check device';

  @override
  String get wifiInfoTitle => 'Wi-Fi Info';

  @override
  String get networkGood => 'Device network connection is good';

  @override
  String get networkUnstable => 'Device network is unstable or weak';

  @override
  String get wlanName => 'Wi-Fi Name (SSID)';

  @override
  String get wlanStrength => 'Signal Strength (RSSI)';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get macAddress => 'MAC Address';

  @override
  String get resetWifi => 'Reset Wi-Fi';

  @override
  String get resetWifiSuccess =>
      'Reset Wi-Fi command sent, device entering pairing mode';

  @override
  String get latestVersion => 'Latest';

  @override
  String get plasmaScheduleTitle => 'Plasma Deodorization Schedule';

  @override
  String get plasmaAlwaysOn => 'Always On';

  @override
  String get plasmaCycleMode => 'Cycle Mode';

  @override
  String get plasmaAlwaysOnDesc =>
      'Continuous plasma deodorization throughout the day';

  @override
  String get plasmaCycleModeDesc =>
      'Periodic activation based on set intervals';

  @override
  String get fineGrainedAdjust => 'Second-level Adjustment';

  @override
  String get runDuration => 'Run Time';

  @override
  String get intervalDuration => 'Interval Time';

  @override
  String get plasmaDurationWarning =>
      'Run and interval times should not be less than 30s';

  @override
  String get dataStatistics => 'Data Statistics';

  @override
  String get toiletTimes => 'Toilet Visits';

  @override
  String get toiletDuration => 'Toilet Duration';

  @override
  String get timesTrend => 'Visits Trend';

  @override
  String get durationTrend => 'Duration Trend';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get user => 'User';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get avatar => 'Avatar';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get nickname => 'Nickname';

  @override
  String get editNickname => 'Edit Nickname';

  @override
  String get enterNewNickname => 'Enter new nickname';

  @override
  String get nicknameUpdated => 'Nickname updated successfully';

  @override
  String get accountLabel => 'Account';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get notBound => 'Not Bound';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get logout => 'Log Out';

  @override
  String get appVersion => 'Version';

  @override
  String get feedback => 'Feedback';

  @override
  String get aboutUs => 'About Us';

  @override
  String get languageSetting => 'Language';

  @override
  String get followSystem => 'System Default';

  @override
  String deleteAccountConfirm(Object account) {
    return 'Account data will be permanently deleted and cannot be recovered. A verification code will be sent to $account.';
  }

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get logoutConfirm =>
      'Are you sure you want to log out of your account?';

  @override
  String get officialEmailLabel => 'Email: ';

  @override
  String get officialWebsiteLabel => 'Website: ';

  @override
  String get contactUsDesc =>
      'If you have any questions or suggestions, please feel free to contact us:';

  @override
  String get avatarUploadFailed =>
      'Failed to upload avatar, please check permissions and network';

  @override
  String get noCurrentAccount => 'Current account not found';

  @override
  String get deleteAccountFailed =>
      'Failed to delete account, please try again later';

  @override
  String get feedbackTitleHint => 'Enter feedback title (Optional)';

  @override
  String get feedbackContentHint =>
      'Please describe your issue or suggestion in detail...';

  @override
  String get submitSuccess => 'Feedback submitted successfully, thank you!';
}

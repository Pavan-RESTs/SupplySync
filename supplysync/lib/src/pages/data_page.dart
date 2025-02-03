import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:supplysync/core/utils/firebase_helper_functions.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/constants/globla_classes.dart';
import '../../../../../../core/constants/sizes.dart';
import '../functions/input_page_functions.dart';
import '../widgets/CustomDropDownSelectOnly.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/display_table.dart';

class DataPage extends StatefulWidget {
  DataPage({super.key});

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  void _showProfileDialog(String companyName, String companyType) async {
    try {
      // Fetch profile data based on company type
      final collectionId = companyType == 'Supplier'
          ? 'supplier_data_table'
          : 'retailer_data_table';

      final profileData = await FireBaseHelperFunctions.getDataFromDocument(
          collectionId, companyName);

      if (!mounted) return;

      final theme = Theme.of(context);

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          companyType == 'Supplier'
                              ? Icons.local_shipping_outlined
                              : Icons.store_outlined,
                          color: theme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Company Profile',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            Text(
                              companyType,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                        ),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 0,
                          color: Colors.grey[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildProfileRow('Name', profileData['name']),
                                _buildProfileRow(
                                    'Contact', profileData['contact_no']),
                                _buildProfileRow(
                                    'Address', profileData['address']),
                                if (companyType == 'Retailer')
                                  _buildProfileRow(
                                    'Due Amount',
                                    NumberFormat.currency(
                                      symbol: '₹',
                                      locale: 'en_IN',
                                      decimalDigits: 0,
                                    ).format(profileData['due_amount'] ?? 0),
                                    isAmount: true,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      // Show error snackbar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProfileRow(String label, String? value,
      {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                fontFamily: 'Roboto',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: isAmount
                    ? (double.tryParse(
                                    value?.replaceAll(RegExp(r'[^0-9.]'), '') ??
                                        '0') ??
                                0) >
                            0
                        ? Colors.red
                        : Colors.black
                    : Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String selectedTable = '';
  String selectedProfile = '';
  String selectedSelectOnly = '';
  List<String> companyNames = [];
  Map<String, String> companyTypeMap = {};

  final List<String> tableNames = [
    'Warehouse',
    'Supplier',
    'Retailer',
    'Turnover'
  ];
  Future<void> _loadCompanyNames() async {
    try {
      final List<String> supplierNames =
          await FireBaseHelperFunctions.fetchAllUserDetails(
              'supplier_data_table');
      final List<String> retailerNames =
          await FireBaseHelperFunctions.fetchAllUserDetails(
              'retailer_data_table');

      // Store the original name to type mapping
      Map<String, String> newCompanyTypeMap = {};
      for (var name in supplierNames) {
        newCompanyTypeMap[name] = 'Supplier';
      }
      for (var name in retailerNames) {
        newCompanyTypeMap[name] = 'Retailer';
      }

      // Create display names with tags
      final List<String> modifiedSupplierNames =
          supplierNames.map((name) => '$name (Supplier)').toList();
      final List<String> modifiedRetailerNames =
          retailerNames.map((name) => '$name (Retailer)').toList();

      setState(() {
        companyNames = [...modifiedSupplierNames, ...modifiedRetailerNames];
        companyTypeMap = newCompanyTypeMap;
      });
    } catch (e) {
      print('Error loading company names: $e');
    }
  }

  String _getOriginalName(String displayName) {
    return displayName.replaceAll(RegExp(r' \((?:Supplier|Retailer)\)$'), '');
  }

  DateTime _startDate = DateTime(2025, 2, 1);
  DateTime _endDate = DateTime.now();

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate ? _startDate : _endDate;
    DateTime firstDate = DateTime(2022, 1, 1);
    DateTime lastDate = DateTime.now();
    lastDate = DateTime(lastDate.year, lastDate.month, lastDate.day);

    DateTime? pickedDate = await showDatePickerDialog(
      padding: EdgeInsets.all(18),
      context: context,

      initialDate: initialDate,
      minDate: firstDate,
      maxDate: lastDate,
      width: 350,
      height: 350,
      currentDate: DateTime.now(), // Use the current date
      selectedDate: initialDate, // Use the initial date as the selected date
      currentDateDecoration: BoxDecoration(
        color: IColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      currentDateTextStyle: TextStyle(
        color: IColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      daysOfTheWeekTextStyle: TextStyle(
        color: Colors.grey[500],
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      disabledCellsTextStyle: TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
      enabledCellsDecoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      enabledCellsTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 14,
      ),
      selectedCellDecoration: BoxDecoration(
        color: IColors.primary,
        shape: BoxShape.circle,
      ),
      selectedCellTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      leadingDateTextStyle: TextStyle(
        color: IColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      slidersColor: IColors.primary,
      highlightColor: IColors.primary.withOpacity(0.5),
      slidersSize: 20,
      splashColor: IColors.primary.withOpacity(0.3),
      splashRadius: 40,
      centerLeadingDate: true,
    );

    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCompanyNames();
    _endDate = DateTime(_endDate.year, _endDate.month, _endDate.day);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: GlobalClasses.screenWidth / 50),
            child: ElevatedButton(
              onPressed: () async {
                InputPageFunctions.showLogoutConfirmationDialog(context);
              },
              child: Icon(Iconsax.logout),
            ),
          ),
        ],
        title: Text(
          "Information",
          style: Theme.of(context).textTheme.headlineLarge!.apply(
              color: IColors.textWhite, fontWeightDelta: -3, fontSizeDelta: -1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: GlobalClasses.screenHeight / 26,
              horizontal: ISizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profiles",
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .apply(fontWeightDelta: -4),
              ),
              SizedBox(height: GlobalClasses.screenHeight / 50),
              Container(
                width: double.infinity,
                child: CustomDropDown(
                  hintText: "Name of the company",
                  names: companyNames,
                  onChanged: (value) {
                    setState(() {
                      selectedProfile = value;
                      // Extract company name and type
                      final match = RegExp(r'(.*) \((Supplier|Retailer)\)$')
                          .firstMatch(value);
                      if (match != null) {
                        final companyName = match.group(1)!;
                        final companyType = match.group(2)!;
                        _showProfileDialog(companyName, companyType);
                      }
                    });
                  },
                ),
              ),
              SizedBox(height: GlobalClasses.screenHeight / 30),
              const Divider(color: Colors.grey, thickness: 0.7),
              SizedBox(height: GlobalClasses.screenHeight / 55),
              Text("Database",
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .apply(fontWeightDelta: -4)),
              SizedBox(height: GlobalClasses.screenHeight / 50),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _pickDate(context, true),
                    child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(ISizes.inputFieldRadius),
                            border: Border.all(color: Colors.grey)),
                        child:
                            Text("Start: ${dateFormatter.format(_startDate)}")),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () => _pickDate(context, false),
                    child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(ISizes.inputFieldRadius),
                            border: Border.all(color: Colors.grey)),
                        child: Text("End: ${dateFormatter.format(_endDate)}")),
                  ),
                  // Container(
                  //     width: GlobalClasses.screenWidth / 8,
                  //     height: GlobalClasses.screenHeight / 18,
                  //     child: ElevatedButton(
                  //         onPressed: () {}, child: Icon(Icons.download)))
                ],
              ),
              SizedBox(height: GlobalClasses.screenHeight / 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: GlobalClasses.screenWidth / 2.4,
                    child: CustomDropDown(
                      actionIcon: Icon(
                        Icons.table_chart_outlined,
                        size: 24,
                        color: Colors.black,
                      ),
                      hintText: "Table Name",
                      names: tableNames,
                      onChanged: (value) {
                        String selected = '';
                        if (value == 'Warehouse') {
                          selected = 'warehouse_transaction';
                        } else if (value == 'Retailer') {
                          selected = 'retailer_transaction';
                        } else if (value == 'Supplier') {
                          selected = 'supplier_transaction';
                        } else if (value == 'Turnover') {
                          selected = 'turnover_transaction';
                        }
                        setState(() {
                          selectedTable = selected;
                        });
                      },
                    ),
                  ),
                  Container(
                    width: GlobalClasses.screenWidth / 2.4,
                    child: CustomDropDownSelectOnly(
                      hintText: "Select Only",
                      names: companyNames,
                      onChanged: (value) {
                        setState(() {
                          selectedSelectOnly = _getOriginalName(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: GlobalClasses.screenHeight / 50,
              ),
              DisplayTable(
                key: UniqueKey(),
                k: 100,
                collectionId: selectedTable,
                startDate: _startDate,
                endDate: _endDate.add(Duration(days: 1)),
                specificCompanyName: selectedSelectOnly.isNotEmpty
                    ? _getOriginalName(selectedSelectOnly)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

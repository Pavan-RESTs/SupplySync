import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supplysync/core/constants/colors.dart';
import 'package:supplysync/core/utils/firebase_helper_functions.dart';

class DisplayTable extends StatefulWidget {
  final String collectionId;
  final int k;
  final List<String>? excludeColumns;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? specificCompanyName;
  final VoidCallback? onDownloadCSV;

  const DisplayTable({
    Key? key,
    required this.collectionId,
    required this.k,
    this.excludeColumns,
    this.startDate,
    this.endDate,
    this.specificCompanyName,
    this.onDownloadCSV,
  }) : super(key: key);

  @override
  _DisplayTableState createState() => _DisplayTableState();
}

class _DisplayTableState extends State<DisplayTable> {
  late Future<List<Map<String, dynamic>>> _documents;
  int? _sortColumnIndex;
  bool _isAscending = true;

  final currencyFormatter = NumberFormat.currency(
    symbol: '₹',
    locale: 'en_IN',
    decimalDigits: 0,
  );

  final inputDateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  final outputDateFormat = DateFormat('dd MMM yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _documents = _fetchFilteredDocuments();
  }

  Future<List<Map<String, dynamic>>> _fetchFilteredDocuments() async {
    print("Start Date: ${widget.startDate}");
    print("End Date: ${widget.endDate}");
    List<Map<String, dynamic>> documents =
        await FireBaseHelperFunctions.fetchTopKDocuments(
            widget.collectionId, widget.k);

    // Filter by date range if specified
    if (widget.startDate != null || widget.endDate != null) {
      documents = documents.where((doc) {
        if (doc['datetime'] == null) return false;
        try {
          final docDate = inputDateFormat.parse(doc['datetime']);
          if (widget.startDate != null && docDate.isBefore(widget.startDate!)) {
            return false;
          }
          if (widget.endDate != null && docDate.isAfter(widget.endDate!)) {
            return false;
          }
          return true;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Filter by company name if specified
    if (widget.specificCompanyName != null &&
        widget.specificCompanyName!.isNotEmpty) {
      documents = documents.where((doc) {
        if (widget.collectionId.startsWith('turnover_transaction')) {
          // For turnover transactions, check both supplier_name and company_name
          String? supplierName = doc['supplier_name']?.toString().toLowerCase();
          String? companyName = doc['company_name']?.toString().toLowerCase();
          String searchName = widget.specificCompanyName!.toLowerCase();

          return supplierName == searchName || companyName == searchName;
        } else {
          // For other transactions, check company_name
          return doc['company_name']?.toString().toLowerCase() ==
              widget.specificCompanyName!.toLowerCase();
        }
      }).toList();
    }

    // Trigger the CSV download callback if provided
    if (widget.onDownloadCSV != null) {
      _downloadCSV(documents);
    }

    return documents;
  }

  Future<void> _downloadCSV(List<Map<String, dynamic>> documents) async {
    try {
      // Convert documents to CSV
      List<List<dynamic>> csvData = [
        documents.first.keys.toList(), // Header row
        ...documents.map((doc) => doc.values.toList()) // Data rows
      ];

      String csv = const ListToCsvConverter().convert(csvData);

      // Get the directory to save the file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/filtered_data.csv';
      final file = File(filePath);

      // Write the CSV content to the file
      await file.writeAsString(csv);

      // Convert the file path to an XFile
      final xFile = XFile(filePath);

      // Share the file
      await Share.shareXFiles([xFile], text: 'Filtered Data CSV');
    } catch (e) {
      print('Error downloading CSV: $e');
    }
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> d) getField,
      int columnIndex, String key) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _isAscending = !_isAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _isAscending = true;
      }

      _documents = _documents.then((documents) {
        documents.sort((a, b) {
          final aValue = getField(a);
          final bValue = getField(b);
          return _isAscending
              ? Comparable.compare(aValue, bValue)
              : Comparable.compare(bValue, aValue);
        });
        return documents;
      });
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = inputDateFormat.parse(dateStr);
      return outputDateFormat.format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget formatValueAlert(dynamic value, String columnName) {
    if (value == null) return const Text('N/A');

    // Format currency values
    if (columnName.toLowerCase().contains('price') ||
        columnName.toLowerCase().contains('amount') ||
        columnName.toLowerCase().contains('profit_loss')) {
      return Text(
        currencyFormatter.format(value),
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    // Format date values
    if (columnName.toLowerCase().contains('date') ||
        columnName.toLowerCase().contains('time')) {
      return Text(
        formatDate(value.toString()),
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    // Default format
    return Text(
      value.toString(),
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget formatValueTable(dynamic value, String columnName, String docId) {
    if (value == null) return const Text('N/A');

    // Format currency values for "price", "amount", or "profit_loss"
    if (columnName.toLowerCase().contains('price') ||
        columnName.toLowerCase().contains('amount') ||
        columnName.toLowerCase().contains('profit_loss')) {
      Color textColor = Colors.black;

      // Handle "profit_loss" for turnover_transaction
      if (columnName.toLowerCase() == 'profit_loss') {
        textColor = value >= 0 ? Colors.green : Colors.red;
      }

      // Handle "total_amount" for warehouse_transaction based on type
      if (columnName.toLowerCase() == 'total_amount' &&
          widget.collectionId.startsWith('warehouse_transaction')) {
        final type = docId.substring(0, 2) == 'rt'
            ? 'retailer'
            : 'supplier'; // Assuming 'type' is the field for retailer or other types.
        textColor = type == 'retailer' ? Colors.green : Colors.red;
      }

      return Text(
        currencyFormatter.format(value),
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      );
    }

    // Format date values for "date" or "time" columns
    if (columnName.toLowerCase().contains('date') ||
        columnName.toLowerCase().contains('time')) {
      return Text(
        formatDate(value.toString()),
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    // Default format for other values
    return Text(
      value.toString(),
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black12),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _documents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: SpinKitFadingCircle(
                  color: IColors.primary,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No data available'),
              ),
            );
          }

          final documents = snapshot.data!;
          final columns = _getColumns(documents.first);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.black12,
                dataTableTheme: DataTableThemeData(
                  headingTextStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                  ),
                  dataTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              child: DataTable(
                border: TableBorder.all(
                  color: Colors.black12,
                  width: 1,
                ),
                columnSpacing: 24.0,
                headingRowHeight: 56.0,
                dataRowHeight: 52.0,
                showCheckboxColumn: false,
                sortAscending: _isAscending,
                sortColumnIndex: _sortColumnIndex,
                columns: columns.map((columnName) {
                  return DataColumn(
                    label: Text(
                      _formatColumnName(columnName),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    onSort: (columnIndex, _) {
                      _sort<dynamic>(
                          (d) => d[columnName] ?? '', columnIndex, columnName);
                    },
                  );
                }).toList(),
                rows: documents.map((doc) {
                  return DataRow(
                    cells: columns.map((columnName) {
                      // Special handling for company/supplier name column
                      final isCompanyNameColumn = (widget.collectionId
                                  .startsWith('turnover_transaction')
                              ? 'supplier_name'
                              : 'company_name') ==
                          columnName;

                      if (isCompanyNameColumn) {
                        return DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (doc['STID'] != null)
                                const Icon(Icons.arrow_downward,
                                    color: Colors.red, size: 16)
                              else if (doc['RTID'] != null)
                                const Icon(Icons.arrow_upward,
                                    color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                doc[columnName]?.toString() ?? 'N/A',
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            _showDetailDialog(context, doc);
                          },
                        );
                      }
                      // Regular cells remain the same
                      return DataCell(
                        formatValueTable(doc[columnName], columnName,
                            doc['STID'] ?? doc['RTID'] ?? doc['TTID'] ?? ''),
                        onTap: () {
                          _showDetailDialog(context, doc);
                        },
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _getColumns(Map<String, dynamic> firstDoc) {
    // Determine columns based on collection type
    if (widget.collectionId.startsWith('turnover_transaction')) {
      final desiredOrder = [
        'company_name',
        'datetime',
        'turnover_amount',
        'purchase_amount',
        'profit_loss',
      ];

      return desiredOrder
          .where((column) => firstDoc.containsKey(column))
          .toList();
    }

    // Existing columns for other transaction types
    final desiredOrder = [
      'company_name',
      'datetime',
      'quantity_small',
      'quantity_medium',
      'quantity_large',
      'price_small',
      'price_medium',
      'price_large',
      'total_amount',
    ];

    final availableColumns =
        desiredOrder.where((column) => firstDoc.containsKey(column)).toList();

    if (widget.excludeColumns != null) {
      availableColumns
          .removeWhere((column) => widget.excludeColumns!.contains(column));
    }

    return availableColumns;
  }

  String _formatColumnName(String name) {
    // Convert snake_case to Title Case
    return name
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  void _showDetailDialog(BuildContext context, Map<String, dynamic> data) {
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
            maxHeight: 600,
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
                        Icons.description_outlined,
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
                            'Record Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          if (data['datetime'] != null)
                            Text(
                              formatDate(data['datetime']),
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
                      // Group the data into categories
                      ...groupAndBuildDataSections(data),
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
  }

  List<Widget> groupAndBuildDataSections(Map<String, dynamic> data) {
    // Determine the desired order based on collection type
    final basicInfoFields =
        widget.collectionId.startsWith('turnover_transaction')
            ? ['supplier_name', 'datetime']
            : ['company_name', 'datetime'];

    final quantitiesFields =
        widget.collectionId.startsWith('turnover_transaction')
            ? ['purchase_amount']
            : ['quantity_small', 'quantity_medium', 'quantity_large'];

    final pricingFields = widget.collectionId.startsWith('turnover_transaction')
        ? ['profit_loss', 'turnover_transaction_amount']
        : ['price_small', 'price_medium', 'price_large'];
    final summaryFields = widget.collectionId.startsWith('turnover_transaction')
        ? ['profit_loss', 'turnover_transaction_amount']
        : ['total_amount'];

    // Group data into categories
    final Map<String, Map<String, dynamic>> groupedData = {
      'Basic Information': {},
      'Quantity': {},
      'Price': {},
      'Summary': {}
    };

    // Populate groups
    basicInfoFields.forEach((key) {
      if (data.containsKey(key)) {
        groupedData['Basic Information']![key] = data[key];
      }
    });

    quantitiesFields.forEach((key) {
      if (data.containsKey(key)) {
        groupedData['Quantity']![key] = data[key];
      }
    });

    pricingFields.forEach((key) {
      if (data.containsKey(key)) {
        groupedData['Price']![key] = data[key];
      }
    });
    summaryFields.forEach((key) {
      if (data.containsKey(key)) {
        groupedData['Summary']![key] = data[key];
      }
    });

    return groupedData.entries.where((e) => e.value.isNotEmpty).map((category) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              category.key,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Roboto',
              ),
            ),
          ),
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
                children: category.value.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _formatColumnName(entry.key),
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
                          child: formatValueAlert(entry.value, entry.key),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }
}

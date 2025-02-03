import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supplysync/core/constants/globla_classes.dart';
import 'package:supplysync/core/utils/firebase_helper_functions.dart';
import 'package:supplysync/core/utils/helper_functions.dart';
import 'package:supplysync/core/utils/validators.dart';

import '../functions/input_page_functions.dart';
import 'custom_dropdown.dart';

class FieldSubmissionRetailer extends StatelessWidget {
  const FieldSubmissionRetailer({
    super.key,
    required this.title,
    required this.onCompanySelected,
    required this.quantityControllers,
    required this.priceControllers,
    required this.selectedValue,
  });

  final String title;
  final Function(String) onCompanySelected;
  final List<TextEditingController> quantityControllers;
  final List<TextEditingController> priceControllers;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {
    const String collectionId = 'retailer_data_table';
    final Future<List<Map<dynamic, dynamic>>> data =
        FireBaseHelperFunctions.getDataFromCollection(collectionId);
    final List<String> names = InputPageFunctions.getMapSync(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .apply(fontWeightDelta: -4),
        ),
        SizedBox(height: GlobalClasses.screenHeight / 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomDropDown(
              hintText: "Name of the company",
              names: names,
              onChanged: (value) {
                onCompanySelected(value);
              },
            ),
            SizedBox(
              height: 55,
              width: GlobalClasses.screenWidth / 3.7,
              child: ElevatedButton(
                onPressed: () async {
                  if (await IValidators.validateRetailerTransactionForm(context,
                      quantityControllers, priceControllers, selectedValue)) {
                    final DateTime now = DateTime.now();
                    final String formattedDateTime =
                        "${now.year}-${now.month}-${now.day}_${now.hour}:${now.minute}:${now.second}";
                    final String itid =
                        "rt_${selectedValue.replaceAll(' ', '-')}_$formattedDateTime";
                    final int quantitySmall =
                        int.parse(quantityControllers[0].text);
                    final int quantityMedium =
                        int.parse(quantityControllers[1].text);
                    final int quantityLarge =
                        int.parse(quantityControllers[2].text);
                    final double priceSmall =
                        double.parse(priceControllers[0].text);
                    final double priceMedium =
                        double.parse(priceControllers[1].text);
                    final double priceLarge =
                        double.parse(priceControllers[2].text);
                    final double totalAmount = (quantitySmall * priceSmall) +
                        (quantityMedium * priceMedium) +
                        (quantityLarge * priceLarge);

                    final Map<String, dynamic> data = {
                      "RTID": itid,
                      "datetime": DateFormat('dd/MM/yyyy HH:mm:ss').format(now),
                      "quantity_small": quantitySmall,
                      "quantity_medium": quantityMedium,
                      "quantity_large": quantityLarge,
                      "price_small": priceSmall,
                      "price_medium": priceMedium,
                      "price_large": priceLarge,
                      "total_amount": totalAmount,
                      "company_name": selectedValue,
                    };
                    String collId = 'retailer_transaction';
                    try {
                      FireBaseHelperFunctions.updateQuantityData(
                          'retailer_data_table',
                          selectedValue,
                          {'due_amount': totalAmount},
                          true);

                      FireBaseHelperFunctions.addData(collId, itid, data);
                      FireBaseHelperFunctions.addData(
                          'warehouse_transaction', itid, data);
                      FireBaseHelperFunctions.updateQuantityData(
                          'metadata',
                          'warehouse_stocks',
                          {
                            'small': quantitySmall,
                            'medium': quantityMedium,
                            'large': quantityLarge,
                          },
                          false);
                      FireBaseHelperFunctions.updateQuantityData(
                          'metadata',
                          'transaction_status',
                          {
                            'small': quantitySmall,
                            'medium': quantityMedium,
                            'large': quantityLarge,
                          },
                          false);
                      FireBaseHelperFunctions.updateQuantityData(
                          'metadata',
                          'transaction_status',
                          {'sold_amount': totalAmount},
                          true);

                      for (int i = 0; i < quantityControllers.length; i++) {
                        quantityControllers[i].clear();
                        priceControllers[i].clear();
                      }
                      await Future.delayed(const Duration(milliseconds: 500));

                      Map<String, dynamic> activeTransactionStatusMap =
                          await FireBaseHelperFunctions.getDataFromDocument(
                        'metadata',
                        'transaction_status',
                      );
                      Map<String, dynamic> currentActiveTransactionMap =
                          await FireBaseHelperFunctions.getDataFromDocument(
                        'supplier_transaction',
                        activeTransactionStatusMap['active_transaction'],
                      );

                      if (((activeTransactionStatusMap['small'] == null &&
                              activeTransactionStatusMap['medium'] == null &&
                              activeTransactionStatusMap['large'] == null) ||
                          (activeTransactionStatusMap['small'] == 0 &&
                              activeTransactionStatusMap['medium'] == 0 &&
                              activeTransactionStatusMap['large'] == 0))) {
                        dynamic earliestPendingTransactionMap =
                            await InputPageFunctions
                                .getEarliestTransactionDocument();

                        if (earliestPendingTransactionMap == null) {
                          FireBaseHelperFunctions.updateData(
                            'supplier_transaction',
                            activeTransactionStatusMap['active_transaction'],
                            {'transaction_status': 'expired'},
                          );
                          await Future.delayed(
                              const Duration(milliseconds: 100));

                          FireBaseHelperFunctions.deleteDocument(
                              'metadata', 'transaction_status');
                          await Future.delayed(
                              const Duration(milliseconds: 100));

                          FireBaseHelperFunctions.addData(
                              'turnover_transaction',
                              activeTransactionStatusMap['active_transaction'],
                              {
                                'STID': activeTransactionStatusMap[
                                    'active_transaction'],
                                'company_name':
                                    currentActiveTransactionMap['company_name'],
                                'purchase_amount':
                                    currentActiveTransactionMap['total_amount'],
                                'turnover_amount':
                                    activeTransactionStatusMap['sold_amount'],
                                'profit_loss': activeTransactionStatusMap[
                                        'sold_amount'] -
                                    currentActiveTransactionMap['total_amount'],
                                'datetime': DateFormat('dd/MM/yyyy HH:mm:ss')
                                    .format(now),
                              });
                          await Future.delayed(
                              const Duration(milliseconds: 100));

                          IHelper.showSnackBar(
                              'Success', 'Transaction updated successfully');
                          return;
                        }

                        FireBaseHelperFunctions.updateData(
                          'supplier_transaction',
                          activeTransactionStatusMap['active_transaction'],
                          {'transaction_status': 'expired'},
                        );
                        await Future.delayed(const Duration(milliseconds: 100));

                        FireBaseHelperFunctions.updateData(
                          'supplier_transaction',
                          earliestPendingTransactionMap['STID'],
                          {'transaction_status': 'active'},
                        );

                        FireBaseHelperFunctions.updateData(
                            'metadata', 'transaction_status', {
                          'small':
                              earliestPendingTransactionMap['quantity_small'],
                          'medium':
                              earliestPendingTransactionMap['quantity_medium'],
                          'large':
                              earliestPendingTransactionMap['quantity_large'],
                          'sold_amount': 0,
                          'active_transaction':
                              earliestPendingTransactionMap['STID']
                        });
                        await Future.delayed(const Duration(milliseconds: 100));

                        FireBaseHelperFunctions.addData('turnover_transaction',
                            activeTransactionStatusMap['active_transaction'], {
                          'STID':
                              activeTransactionStatusMap['active_transaction'],
                          'company_name':
                              currentActiveTransactionMap['company_name'],
                          'purchase_amount':
                              currentActiveTransactionMap['total_amount'],
                          'turnover_amount':
                              activeTransactionStatusMap['sold_amount'],
                          'profit_loss':
                              activeTransactionStatusMap['sold_amount'] -
                                  currentActiveTransactionMap['total_amount'],
                          'datetime':
                              DateFormat('dd/MM/yyyy HH:mm:ss').format(now),
                        });
                      }
                      IHelper.showSnackBar(
                          'Success', 'Transaction updated successfully');
                    } catch (e) {
                      IHelper.showSnackBar(
                          'Error', 'An unexpected error has occurred');
                      return;
                    }
                  }
                },
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
        SizedBox(height: GlobalClasses.screenHeight / 30),
      ],
    );
  }
}

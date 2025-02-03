import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supplysync/core/constants/globla_classes.dart';
import 'package:supplysync/core/utils/firebase_helper_functions.dart';
import 'package:supplysync/core/utils/helper_functions.dart';
import 'package:supplysync/core/utils/validators.dart';

import '../functions/input_page_functions.dart';
import 'custom_dropdown.dart';

class FieldSubmissionSupplier extends StatelessWidget {
  const FieldSubmissionSupplier({
    super.key,
    required this.title,
    required this.onCompanySelected,
    required this.quantityControllers,
    required this.priceControllers,
    required this.selectedValue,
    required this.onTransactionComplete,
  });

  final String title;

  final Function(String) onCompanySelected;
  final List<TextEditingController> quantityControllers;
  final List<TextEditingController> priceControllers;
  final String selectedValue;
  final VoidCallback onTransactionComplete;

  @override
  Widget build(BuildContext context) {
    const String collectionId = 'supplier_data_table';
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
                  if (IValidators.validateSupplierTransactionForm(context,
                      quantityControllers, priceControllers, selectedValue)) {
                    final DateTime now = DateTime.now();
                    final String formattedDateTime =
                        "${now.year}-${now.month}-${now.day}_${now.hour}:${now.minute}:${now.second}";

                    final String itid =
                        "st_${selectedValue.replaceAll(' ', '-')}_$formattedDateTime";
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

                    String transactionStatus = 'active';
                    if (await FireBaseHelperFunctions.documentExists(
                        'metadata', 'transaction_status')) {
                      transactionStatus = 'pending';
                    } else {
                      dynamic data = {
                        'active_transaction': itid,
                        'small': quantitySmall,
                        'medium': quantityMedium,
                        'large': quantityLarge,
                        'sold_amount': 0,
                      };
                      FireBaseHelperFunctions.addData(
                          'metadata', 'transaction_status', data);
                    }

                    final Map<String, dynamic> dataSupplierTransaction = {
                      "STID": itid,
                      "datetime": DateFormat('dd/MM/yyyy HH:mm:ss').format(now),
                      "quantity_small": quantitySmall,
                      "quantity_medium": quantityMedium,
                      "quantity_large": quantityLarge,
                      "price_small": priceSmall,
                      "price_medium": priceMedium,
                      "price_large": priceLarge,
                      "total_amount": totalAmount,
                      "company_name": selectedValue,
                      "transaction_status": transactionStatus,
                    };
                    final Map<String, dynamic> dataWarehouseTransaction = {
                      "STID": itid,
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
                    String collId = 'supplier_transaction';
                    try {
                      FireBaseHelperFunctions.addData(
                          collId, itid, dataSupplierTransaction);
                      FireBaseHelperFunctions.addData('warehouse_transaction',
                          itid, dataWarehouseTransaction);
                      FireBaseHelperFunctions.updateQuantityData(
                          'metadata',
                          'warehouse_stocks',
                          {
                            'small': quantitySmall,
                            'medium': quantityMedium,
                            'large': quantityLarge,
                          },
                          true);

                      IHelper.showSnackBar(
                          'Success', 'Transaction updated successfully');
                      for (int i = 0; i < quantityControllers.length; i++) {
                        quantityControllers[i].clear();
                        priceControllers[i].clear();
                      }
                      onTransactionComplete();
                    } catch (e) {
                      IHelper.showSnackBar(
                          'Error', 'An unexpected error has occured');
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

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supplysync/core/constants/globla_classes.dart';
import 'package:supplysync/core/constants/sizes.dart';

import '../../../../../../core/constants/colors.dart';
import '../functions/input_page_functions.dart';
import '../widgets/display_table.dart';
import '../widgets/field_submission_supplier.dart';
import '../widgets/tagged_input_fields.dart';

class SupplierForm extends StatefulWidget {
  const SupplierForm({super.key});

  @override
  State<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  Key _tableKey = UniqueKey();

  void refresh() {
    setState(() {
      _tableKey = UniqueKey(); // Generate a new key to force re-build
    });
  }

  TextEditingController qSmall = TextEditingController();
  TextEditingController qMedium = TextEditingController();
  TextEditingController qLarge = TextEditingController();
  TextEditingController pSmall = TextEditingController();
  TextEditingController pMedium = TextEditingController();
  TextEditingController pLarge = TextEditingController();
  String selectedValue = '';

  @override
  Widget build(BuildContext context) {
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
          "Supplier Entry",
          style: Theme.of(context).textTheme.headlineLarge!.apply(
              color: IColors.textWhite, fontWeightDelta: -3, fontSizeDelta: -1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: GlobalClasses.screenHeight / 26,
            horizontal: ISizes.defaultSpace,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaggedInputFields(
                title: "Quantity",
                controllers: [qSmall, qMedium, qLarge],
              ),
              TaggedInputFields(
                title: "Price per unit",
                controllers: [pSmall, pMedium, pLarge],
              ),
              FieldSubmissionSupplier(
                title: "Supplier Info",
                onCompanySelected: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
                quantityControllers: [qSmall, qMedium, qLarge],
                priceControllers: [pSmall, pMedium, pLarge],
                selectedValue: selectedValue,
                onTransactionComplete: refresh,
              ),
              const Divider(color: Colors.black, thickness: 0.7),
              SizedBox(height: GlobalClasses.screenHeight / 40),
              Text(
                "Recent transactions",
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .apply(fontWeightDelta: -4),
              ),
              SizedBox(height: GlobalClasses.screenHeight / 30),
              DisplayTable(
                key: _tableKey, // Add this key

                collectionId: 'warehouse_transaction',
                k: 10,
                excludeColumns: const ['RTID', 'STID'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

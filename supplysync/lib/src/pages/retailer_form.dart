import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supplysync/core/constants/colors.dart';

import '../../../../../../core/constants/globla_classes.dart';
import '../../../../../../core/constants/sizes.dart';
import '../../../../../../core/utils/firebase_helper_functions.dart';
import '../functions/input_page_functions.dart';
import '../widgets/custom_quantity_card.dart';
import '../widgets/field_submission_retailer.dart';
import '../widgets/tagged_input_fields.dart';

class RetailerForm extends StatefulWidget {
  const RetailerForm({super.key});

  @override
  State<RetailerForm> createState() => _RetailerFormState();
}

class _RetailerFormState extends State<RetailerForm> {
  TextEditingController qSmall = TextEditingController();
  TextEditingController qMedium = TextEditingController();
  TextEditingController qLarge = TextEditingController();
  TextEditingController pSmall = TextEditingController();
  TextEditingController pMedium = TextEditingController();
  TextEditingController pLarge = TextEditingController();
  String selectedValue = '';

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> getQuantityLocal() {
    return FireBaseHelperFunctions.getDataFromDocument(
        'metadata', 'transaction_status');
  }

  Future<Map<String, dynamic>> getQuantityGlobal() {
    return FireBaseHelperFunctions.getDataFromDocument(
        'metadata', 'warehouse_stocks');
  }

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
          "Retailer Entry",
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
              // Tagged Input Fields for Quantity and Price
              TaggedInputFields(
                title: "Quantity",
                controllers: [qSmall, qMedium, qLarge],
              ),
              TaggedInputFields(
                title: "Price per unit",
                controllers: [pSmall, pMedium, pLarge],
              ),
              // Field Submission
              FieldSubmissionRetailer(
                title: "Retailer Info",
                onCompanySelected: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
                quantityControllers: [qSmall, qMedium, qLarge],
                priceControllers: [pSmall, pMedium, pLarge],
                selectedValue: selectedValue,
              ),
              const Divider(color: Colors.black, thickness: 0.7),
              SizedBox(height: GlobalClasses.screenHeight / 40),
              Text(
                "Available stocks",
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .apply(fontWeightDelta: -4),
              ),
              SizedBox(height: GlobalClasses.screenHeight / 50),
              Text(
                "Active Transaction Stocks",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .apply(fontWeightDelta: -2),
              ),
              SizedBox(
                height: GlobalClasses.screenHeight / 80,
              ),
              // Handling missing or error data for Local Quantity
              StreamBuilder<Map<String, dynamic>>(
                stream: FireBaseHelperFunctions.getDocumentStream(
                    'metadata', 'transaction_status'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: SpinKitFadingCircle(
                      size: GlobalClasses.screenHeight / 18,
                      color: IColors.primary,
                    ));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error fetching data'));
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No data available'));
                  }

                  // Extract data from Firestore
                  Map<String, dynamic> data = snapshot.data!;
                  String smallQuantity = (data['small'] ?? 0).toString();
                  String mediumQuantity = (data['medium'] ?? 0).toString();
                  String largeQuantity = (data['large'] ?? 0).toString();

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomQuantityCard(
                        type: 'Small',
                        quantity: smallQuantity,
                        imagePath: 'assets/icons/small_cube.png',
                      ),
                      CustomQuantityCard(
                        type: 'Medium',
                        quantity: mediumQuantity,
                        imagePath: 'assets/icons/medium_cube.png',
                      ),
                      CustomQuantityCard(
                        type: 'Large',
                        quantity: largeQuantity,
                        imagePath: 'assets/icons/large_cube.png',
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: GlobalClasses.screenHeight / 50),
              Text(
                "Overall stocks",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .apply(fontWeightDelta: -2),
              ),
              SizedBox(
                height: GlobalClasses.screenHeight / 80,
              ),
              // Handling missing or error data for Global Quantity
              StreamBuilder<Map<String, dynamic>>(
                stream: FireBaseHelperFunctions.getDocumentStream(
                    'metadata', 'warehouse_stocks'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: SpinKitFadingCircle(
                      size: GlobalClasses.screenHeight / 18,
                      color: IColors.primary,
                    ));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error fetching data'));
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No data available'));
                  }

                  // Extract data from Firestore
                  Map<String, dynamic> data = snapshot.data!;
                  String smallQuantity = (data['small'] ?? 0).toString();
                  String mediumQuantity = (data['medium'] ?? 0).toString();
                  String largeQuantity = (data['large'] ?? 0).toString();

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomQuantityCard(
                        type: 'Small',
                        quantity: smallQuantity,
                        imagePath: 'assets/icons/small_cube.png',
                      ),
                      CustomQuantityCard(
                        type: 'Medium',
                        quantity: mediumQuantity,
                        imagePath: 'assets/icons/medium_cube.png',
                      ),
                      CustomQuantityCard(
                        type: 'Large',
                        quantity: largeQuantity,
                        imagePath: 'assets/icons/large_cube.png',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

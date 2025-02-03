import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supplysync/core/constants/globla_classes.dart';
import 'package:supplysync/core/constants/sizes.dart';
import 'package:supplysync/core/utils/firebase_helper_functions.dart';
import 'package:supplysync/core/utils/validators.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/utils/helper_functions.dart';
import '../functions/input_page_functions.dart';
import '../widgets/custom_dropdown.dart';

class AccountForm extends StatefulWidget {
  const AccountForm({super.key});

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  TextEditingController amount = TextEditingController();
  final List<DataTab> _listEnterpriseType = [
    DataTab(title: "Supplier"),
    DataTab(title: "Retailer"),
  ];
  TextEditingController enterpriseName = TextEditingController();
  TextEditingController contactNo = TextEditingController();
  TextEditingController address = TextEditingController();

  String? selectedCompanyName;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const String collectionId = 'retailer_data_table';
    final Future<List<Map<dynamic, dynamic>>> data =
        FireBaseHelperFunctions.getDataFromCollection(collectionId);
    final List<String> names = InputPageFunctions.getMapSync(data);
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
          "Accounts",
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
                "Supplier/Retailer Registration",
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .apply(fontWeightDelta: -4),
              ),
              const SizedBox(height: ISizes.spaceBtwInputFields),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: GlobalClasses.screenWidth / 2.35,
                    child: TextFormField(
                      controller: enterpriseName,
                      decoration:
                          const InputDecoration(hintText: "Enterprise Name"),
                    ),
                  ),
                  SizedBox(
                    width: GlobalClasses.screenWidth / 2.35,
                    child: TextFormField(
                      controller: contactNo,
                      decoration:
                          const InputDecoration(hintText: "Contact Number"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ISizes.spaceBtwInputFields),
              TextFormField(
                controller: address,
                decoration: const InputDecoration(hintText: "Address"),
              ),
              const SizedBox(height: ISizes.spaceBtwInputFields),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 55,
                    child: FlutterToggleTab(
                      width: GlobalClasses.screenWidth / 8,
                      borderRadius: ISizes.buttonRadius,
                      selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                      unSelectedTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                      dataTabs: _listEnterpriseType,
                      selectedIndex: selectedIndex,
                      selectedLabelIndex: (index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 55,
                    width: GlobalClasses.screenWidth / 3,
                    child: ElevatedButton(
                      onPressed: () {
                        if (IValidators.validateAccountForm(
                          context,
                          enterpriseName,
                          contactNo,
                          address,
                        )) {
                          String collectionId =
                              '${_listEnterpriseType[selectedIndex].title.toString().toLowerCase()}_data_table';
                          String documentId = enterpriseName.text.trim();
                          Map<String, dynamic> data = {
                            'name': enterpriseName.text.trim(),
                            'contact_no': contactNo.text.trim(),
                            'address': address.text.trim(),
                          };
                          if (_listEnterpriseType[selectedIndex]
                                  .title
                                  .toString()
                                  .toLowerCase() ==
                              'retailer') {
                            data = {
                              'name': enterpriseName.text.trim(),
                              'contact_no': contactNo.text.trim(),
                              'address': address.text.trim(),
                              'due_amount': 0,
                            };
                          }
                          try {
                            FireBaseHelperFunctions.addData(
                                collectionId, documentId, data);
                            IHelper.showSnackBar(
                                'Success', 'Transaction updated successfully');
                            enterpriseName.clear();
                            contactNo.clear();
                            address.clear();
                            setState(() {
                              selectedIndex = 0;
                            });
                          } catch (e) {
                            IHelper.showSnackBar(
                                'Error', 'An unexpected error has occured');
                          }
                        }
                      },
                      child: const Text("Submit"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ISizes.spaceBtwInputFields * 1.5),
              const Divider(color: Colors.black, thickness: 0.7),
              const SizedBox(height: ISizes.spaceBtwItems),
              Text(
                "Account Updation",
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .apply(fontWeightDelta: -4),
              ),
              const SizedBox(height: ISizes.spaceBtwInputFields),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: GlobalClasses.screenWidth / 2,
                        child: CustomDropDown(
                          hintText: "Name of the company",
                          names: names,
                          onChanged: (value) {
                            setState(() {
                              selectedCompanyName = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 55,
                        width: GlobalClasses.screenWidth / 2.9,
                        child: TextFormField(
                          controller: amount,
                          decoration: const InputDecoration(hintText: "Amount"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ISizes.spaceBtwInputFields),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          if (!RegExp(r'^[0-9]+$')
                              .hasMatch(amount.text.trim())) {
                            IHelper.showSnackBar(
                                'Error', 'Amount must be an integer');
                            amount.clear();
                            return;
                          }
                          FireBaseHelperFunctions.updateQuantityData(
                              collectionId,
                              selectedCompanyName!,
                              {'due_amount': int.parse(amount.text.trim())},
                              false);
                          amount.clear();
                          IHelper.showSnackBar(
                              'Success', 'Transaction updated successfully');
                        } catch (e) {
                          IHelper.showSnackBar(
                              'Error', 'An unexpected error has occured');
                        }
                      },
                      child: const Text("Update"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

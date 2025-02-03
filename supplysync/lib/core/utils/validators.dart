import 'package:flutter/cupertino.dart';
import 'package:supplysync/core/utils/firebase_helper_functions.dart';
import 'package:supplysync/core/utils/helper_functions.dart';

class IValidators {
  static bool validateSupplierTransactionForm(
    BuildContext context,
    List<TextEditingController> quantityControllers,
    List<TextEditingController> priceControllers,
    String selectedValue,
  ) {
    for (var controller in [...quantityControllers, ...priceControllers]) {
      if (controller.text.isEmpty) {
        IHelper.showSnackBar(
            'Error', "All quantity and price fields must be filled");
        return false;
      }

      if (int.tryParse(controller.text) == null) {
        IHelper.showSnackBar(
            'Error', "All quantity and price fields must be integers");
        return false;
      }
    }

    if (selectedValue.isEmpty) {
      IHelper.showSnackBar('Error', "Please select a company");
      return false;
    }

    return true;
  }

  static Future<bool> validateRetailerTransactionForm(
    BuildContext context,
    List<TextEditingController> quantityControllers,
    List<TextEditingController> priceControllers,
    String selectedValue,
  ) async {
    Map<String, dynamic> data =
        await FireBaseHelperFunctions.getDataFromDocument(
            'metadata', 'transaction_status');

    for (var controller in [...quantityControllers, ...priceControllers]) {
      if (controller.text.isEmpty) {
        IHelper.showSnackBar(
            'Error', "All quantity and price fields must be filled");
        return false;
      }

      if (int.tryParse(controller.text) == null) {
        IHelper.showSnackBar(
            'Error', "All quantity and price fields must be integers");
        return false;
      }
    }

    if (selectedValue.isEmpty) {
      IHelper.showSnackBar('Error', "Please select a company");
      return false;
    }
    int small = data['small'] == null ? 0 : data['small'];
    int medium = data['medium'] == null ? 0 : data['medium'];
    int large = data['large'] == null ? 0 : data['large'];

    if (int.parse(quantityControllers[0].text.trim()) > small ||
        int.parse(quantityControllers[1].text.trim()) > medium ||
        int.parse(quantityControllers[2].text.trim()) > large) {
      IHelper.showSnackBar('Error', "Quantity exceeds the limit");
      return false;
    }

    return true;
  }

  static bool validateAccountForm(
    BuildContext context,
    TextEditingController enterpriseName,
    TextEditingController contactNo,
    TextEditingController address,
  ) {
    if (enterpriseName.text.isEmpty) {
      IHelper.showSnackBar('Error', "Enterprise Name cannot be empty");
      return false;
    }

    if (contactNo.text.isEmpty) {
      IHelper.showSnackBar('Error', "Contact Number cannot be empty");
      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(contactNo.text)) {
      IHelper.showSnackBar('Error', "Contact Number must be numeric");
      return false;
    }

    if (address.text.isEmpty) {
      IHelper.showSnackBar('Error', "Address cannot be empty");
      return false;
    }

    return true;
  }
}

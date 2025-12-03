import 'package:family_home/src/app_config/app_styles.dart';
import 'package:family_home/src/controllers/record_controller.dart';
import 'package:family_home/src/models/guest_record_model.dart';
import 'package:family_home/src/services/firestore_services.dart';
import 'package:family_home/src/view/home_page.dart';
import 'package:family_home/src/widget/custom_button.dart';
import 'package:family_home/src/widget/custom_datepicker.dart';
import 'package:family_home/src/widget/custom_dropdown.dart';
import 'package:family_home/src/widget/custom_textformfield.dart';
import 'package:family_home/src/widget/custom_time_picker.dart';
import 'package:family_home/src/widget/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AddRecord extends StatefulWidget {
  final bool? isUpdate;
  final String? recordId;
  const AddRecord({super.key, this.isUpdate, this.recordId});

  @override
  State<AddRecord> createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  GuestRecordController recordController = Get.find<GuestRecordController>();
  final _formKey = GlobalKey<FormState>();
  String? selectedRoomNo; 

  //text controllers:
  final TextEditingController nameCon = TextEditingController();
  final TextEditingController addressCon = TextEditingController();
  final TextEditingController checkinDateCon = TextEditingController();
  final TextEditingController checkinTimeCon = TextEditingController();
  final TextEditingController citizenshipNoCon = TextEditingController();
  final TextEditingController occupationCon = TextEditingController();
  final TextEditingController noPeopleCon = TextEditingController();
  final TextEditingController relationCon = TextEditingController();
  final TextEditingController reasonCon = TextEditingController();
  final TextEditingController contactCon = TextEditingController();
  final TextEditingController checkoutDateCon = TextEditingController();
  final TextEditingController checkoutTimeCon = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch available rooms
    initialize();
    
    // If editing existing record, set the selected room
    if (widget.recordId != null) {
      _loadRecordData();
    }
  }

  initialize() async{
    await recordController.getAvailableRooms();
  }

  Future<void> _loadRecordData() async {
    if (widget.recordId == null) return;
    
    final controller = Get.find<GuestRecordController>();
    final record = await controller.getRecordById(widget.recordId!);
    
    if (record != null && mounted) {
      setState(() {
        nameCon.text = record.name;
        addressCon.text = record.address;
        checkinDateCon.text = record.checkinDate;
        checkinTimeCon.text = record.checkinTime;
        citizenshipNoCon.text = record.citizenshipNo;
        occupationCon.text = record.occupation;
        noPeopleCon.text = record.noPeople;
        relationCon.text = record.relation;
        reasonCon.text = record.reason;
        contactCon.text = record.contact;
        selectedRoomNo = record.roomNo; // Set selected room
        checkoutDateCon.text = record.checkoutDate ?? '';
        checkoutTimeCon.text = record.checkoutTime ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        centerTitle: true,
        title: Text(
          "Guest Record",
          style: interBold(size: 18.sp, color: txtBlack),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                /// ---------- FORM START ----------
                _buildForm(),

                SizedBox(height: 30.h),

                /// ---------- SUBMIT BUTTON ----------
                CustomButton(
                  color: darkBlue,
                  text: widget.isUpdate == true ? "Update" : "Submit",
                  onTap: () async{
                    if (!_formKey.currentState!.validate()) return;

                    final model = GuestRecordModel(
                      name: nameCon.text.trim(),
                      address: addressCon.text.trim(),
                      checkinDate: checkinDateCon.text.trim(),
                      checkinTime: checkinTimeCon.text.trim(),
                      citizenshipNo: citizenshipNoCon.text.trim(),
                      occupation: occupationCon.text.trim(),
                      noPeople: noPeopleCon.text.trim(),
                      relation: relationCon.text.trim(),
                      reason: reasonCon.text.trim(),
                      contact: contactCon.text.trim(),
                      roomNo: selectedRoomNo ?? '',
                      checkoutDate: null,
                      checkoutTime: null,
                    );

                    final firestore = FirestoreService();

                    if (widget.isUpdate == true && model.id != null) {
                      await firestore.updateRecord(model.id!, model);
                    } else {
                      await firestore.addRecord(model);
                    }

                    // Go back or show success
                    showToast("Record saved successfully");

                    Get.offAll(HomePage());
                  },
                  
                  height: 55.h,
                  width: double.infinity,
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Section: Personal Details
          sectionHeader("Guest Information"),
          SizedBox(height: 14.h),

          CustomTextFormField(
            controller: nameCon,
            headingText: "Full Name",
            headingTextStyle: interMedium(size: 13.sp),
            hintText: "Enter full name",
            hintStyle: interRegular(size: 14.sp, color: txtGrey7),
          ),

          SizedBox(height: 18.h),

          CustomTextFormField(
            controller: addressCon,
            headingText: "Address",
            headingTextStyle: interMedium(size: 13.sp),
            hintText: "City, district",
            hintStyle: interRegular(size: 14.sp, color: txtGrey7),
          ),

          SizedBox(height: 30.h),

          /// Section: Stay Details
          sectionHeader("Stay Details"),
          SizedBox(height: 14.h),

          CustomDatepicker(
            controller: checkinDateCon,
            labelText: 'Check-in Date',
            firstDate: DateTime(1900, 1, 1),
            onChanged: (value) {
              setState(() {});
            },
          ),

          SizedBox(height: 18.h),

          CustomTimePicker(
            controller: checkinTimeCon,
            headingText: "Check-in Time",
          ),

          SizedBox(height: 18.h),

          Obx(() => recordController.availableRooms.isEmpty ? SizedBox() : CustomDropdown(
                  headingText: "Room Number",
                  headingTextStyle: interMedium(size: 13.sp),
                  hintText: "Select room number",
                  hintStyle: interRegular(size: 14.sp, color: txtGrey7),
                  items: recordController.availableRooms,
                  value: selectedRoomNo,
                  onChanged: (value) {
                    setState(() {
                      selectedRoomNo = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a room number';
                    }
                    return null;
                  },
                  isRequired: true,
                )),
          SizedBox(height: 30.h),


          // /// Section: Checkout Details
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     sectionHeader("Checkout Details"),
          //     SizedBox(height: 14.h),
              
          //     CustomDatepicker(
          //       controller: checkoutDateCon,
          //       labelText: 'Check-out Date',
          //       firstDate: DateTime(1900, 1, 1),
          //       onChanged: (value) {
          //         setState(() {});
          //       },
          //     ),
              
          //     SizedBox(height: 18.h),
              
          //     CustomTimePicker(
          //       controller: checkoutTimeCon,
          //       defaultTime: const TimeOfDay(hour: 12, minute: 0),
          //       fixedToDefault: true,
          //       headingText: "Check-out Time",
          //     ),
          //   ],
          // ),

          // SizedBox(height: 30.h),


          /// Section: Identification
          sectionHeader("Identification"),
          SizedBox(height: 14.h),

          CustomTextFormField(
            controller: citizenshipNoCon,
            headingText: "Citizenship Number",
            headingTextStyle: interMedium(size: 13.sp),
            hintText: "e.g. 01-12345",
            hintStyle: interRegular(size: 14.sp, color: txtGrey7),
          ),

          SizedBox(height: 18.h),

          CustomTextFormField(
            controller: occupationCon,
            headingText: "Occupation",
            headingTextStyle: interMedium(size: 13.sp),
            hintText: "Job/Work",
            hintStyle: interRegular(size: 14.sp, color: txtGrey7),
          ),

          SizedBox(height: 30.h),

          /// Section: Additional Info
          sectionHeader("Additional Information"),
          SizedBox(height: 14.h),

          CustomTextFormField(
            controller: noPeopleCon,
            headingText: "Number of People",
            headingTextStyle: interMedium(size: 13.sp),
            hintText: "How many?",
            hintStyle: interRegular(size: 14.sp, color: txtGrey7),
          ),

          SizedBox(height: 18.h),

          CustomTextFormField(
            controller: relationCon,
            headingText: "Relation",
            headingTextStyle: interMedium(size: 13.sp),
            hintText: "Relation between guests",
            hintStyle: interRegular(size: 14.sp, color: txtGrey7),
          ),

          SizedBox(height: 18.h),

          CustomTextFormField(
            controller: reasonCon,
            headingText: "Reason of Stay",
            headingTextStyle: interMedium(size: 13.sp),
            hintText: "Business, travel, etc.",
            hintStyle: interRegular(size: 14.sp, color: txtGrey7),
          ),

          SizedBox(height: 18.h),

          CustomTextFormField(
            controller: contactCon,
            headingText: "Contact Number",
            keyboardType: TextInputType.phone,
            maxLength: 10,
            headingTextStyle: interMedium(size: 13.sp),
            hintText: "98XXXXXXXX",
            hintStyle: interRegular(size: 14.sp, color: txtGrey7),
          ),

          
        ],
      ),
    );
  }

  /// SECTION TITLE WIDGET
  Widget sectionHeader(String title) {
    return Text(
      title,
      style: interBold(size: 16.sp, color: txtBlack),
    );
  }

}

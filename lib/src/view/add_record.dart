import 'dart:developer';

import 'package:family_home/src/app_config/app_styles.dart';
import 'package:family_home/src/controllers/record_controller.dart';
import 'package:family_home/src/models/guest_record_model.dart';
import 'package:family_home/src/view/home_page.dart';
import 'package:family_home/src/widget/custom_datepicker.dart';
import 'package:family_home/src/widget/custom_dropdown.dart';
import 'package:family_home/src/widget/custom_textformfield.dart';
import 'package:family_home/src/widget/custom_time_picker.dart';
import 'package:family_home/src/widget/custom_toast.dart';
import 'package:flutter/foundation.dart';
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
  GuestRecordController recordController = Get.put(GuestRecordController());
  final _formKey = GlobalKey<FormState>();
  String? selectedRoomNo; 
  String? statusCon; 
  String? selectedCheckinDate;

  //text controllers:
  final TextEditingController nameCon           = TextEditingController();
  final TextEditingController addressCon        = TextEditingController();
  final TextEditingController checkinDateCon    = TextEditingController();
  final TextEditingController checkinTimeCon    = TextEditingController();
  final TextEditingController citizenshipNoCon  = TextEditingController();
  final TextEditingController occupationCon     = TextEditingController();
  final TextEditingController noPeopleCon       = TextEditingController();
  final TextEditingController relationCon       = TextEditingController();
  final TextEditingController reasonCon         = TextEditingController();
  final TextEditingController contactCon        = TextEditingController();
  final TextEditingController checkoutDateCon   = TextEditingController();
  final TextEditingController checkoutTimeCon   = TextEditingController();

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
        contactCon.text = record.contact;
        selectedRoomNo = record.roomNo; 
        checkoutDateCon.text = record.checkoutDate ?? '';
        statusCon = record.status ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: _appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: kIsWeb 
            ? Padding(
              padding: EdgeInsets.all(60.w),
              child: _buildWebFormLayout(),
            )
            : Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                /// ---------- FORM START ----------
                _buildForm(),

                SizedBox(height: 30.h),

                // /// ---------- SUBMIT BUTTON ----------
                // CustomButton(
                //   color: darkBlue,
                //   text: widget.isUpdate == true ? "Update" : "Submit",
                //   onTap: () async{
                //     if (!_formKey.currentState!.validate()) return;

                //     final model = GuestRecordModel(
                //       name: nameCon.text.trim(),
                //       address: addressCon.text.trim(),
                //       checkinDate: checkinDateCon.text.trim(),
                //       checkinTime: checkinTimeCon.text.trim(),
                //       citizenshipNo: citizenshipNoCon.text.trim(),
                //       occupation: occupationCon.text.trim(),
                //       noPeople: noPeopleCon.text.trim(),
                //       relation: relationCon.text.trim(),
                //       reason: reasonCon.text.trim(),
                //       contact: contactCon.text.trim(),
                //       roomNo: selectedRoomNo ?? '',
                //       status: statusCon ?? '',
                //       checkoutDate: checkoutDateCon.text.trim(),
                //       checkoutTime: checkoutTimeCon.text.trim(),
                //       hasCheckedOut : false,
                //     );

                //     final firestore = FirestoreService();

                //     if (widget.isUpdate == true && model.id != null) {
                //       await firestore.updateRecord(model.id!, model);
                //     } else {
                //       await firestore.addRecord(model);
                //     }

                //     // Go back or show success
                //     showToast("Record saved successfully");

                //     Get.offAll(HomePage());
                //   },
                  
                //   height: 55.h,
                //   width: double.infinity,
                // ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _appBar(){
    return AppBar(
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

      actions: [
        TextButton(
          onPressed: () async {
            // Prevent multiple taps
            if (recordController.isLoading.isTrue) return;
            
            // Validations
            if (!_formKey.currentState!.validate()) {
              showErrorToast("Please fill all required fields");
              return;
            }
            
            // Check if room is selected
            if (selectedRoomNo == null || selectedRoomNo!.isEmpty) {
              showErrorToast("Please select a room number");
              return;
            }
            
            // Check if status is selected
            if (statusCon == null || statusCon!.isEmpty) {
              showErrorToast("Please select booking status");
              return;
            }
            
            // Check if checkin date is selected
            if (checkinDateCon.text.isEmpty) {
              showErrorToast("Please select check-in date");
              return;
            }
            
            // Check if checkin time is selected
            if (checkinTimeCon.text.isEmpty) {
              showErrorToast("Please select check-in time");
              return;
            }

            try {
              // Show loading
              recordController.isLoading.value = true;
              
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
                roomNo: selectedRoomNo!, // Use non-null since we validated
                status: statusCon!, // Use non-null since we validated
                checkoutDate: checkoutDateCon.text.trim().isNotEmpty 
                    ? checkoutDateCon.text.trim() 
                    : null,
                checkoutTime: checkoutTimeCon.text.trim().isNotEmpty 
                    ? checkoutTimeCon.text.trim() 
                    : null,
                hasCheckedOut: false,
              );

              if (widget.isUpdate == true && widget.recordId != null) {
                bool success = await recordController.updateRecord(widget.recordId!, model);
                if (success) {
                  showToast("Record updated successfully");
                  Get.offAll(const HomePage());
                }
              } else {
                String? recordId = await recordController.addRecord(model);
                if (recordId != null) {
                  showToast("Record added successfully");
                  Get.offAll(const HomePage());
                }
              }
              
            } catch (e) {
              log("Error saving record: $e");
              showErrorToast("Failed to save record");
            } finally {
              // Hide loading
              recordController.isLoading.value = false;
            }
          },
          child: Obx(() {
            if (recordController.isLoading.isTrue) {
              return SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: txtBlue,
                ),
              );
            }
            return Text(
              "Submit",
              style: interBold(size: 16.sp, color: txtBlue),
            );
          }),
        )],
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

          SizedBox(height: 18.h),

          // Booking Status
          CustomDropdown(
            headingText: "Status",
            headingTextStyle: interMedium(size: 13.sp),
            hintText: "Select booking status",
            hintStyle: interRegular(size: 14.sp, color: txtGrey7),
            items:  const ["Booked", "Checked In"],
            isRequired: true,
            value: statusCon,
            onChanged: (value) {
              setState(() {
                statusCon = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select status';
              }
              return null;
            },
          ),

          SizedBox(height: 30.h),

          /// Section: Stay / Checkin Details 
          sectionHeader("Stay Details"),
          SizedBox(height: 14.h),

          CustomDatepicker(
            controller: checkinDateCon,
            labelText: 'Check-in Date',
            firstDate: DateTime.now(),
            onChanged: (value) {
              selectedCheckinDate = value;
              recordController.getAvailableRooms(checkinDate: value);
            }
          ),

          SizedBox(height: 18.h),

          CustomTimePicker(
            controller: checkinTimeCon,
            headingText: "Check-in Time",
          ),

          SizedBox(height: 18.h),

          Obx(() => recordController.availableRooms.isEmpty ? SizedBox() 
          : recordController.isAvailableRoomLoading.isTrue ? Center(
            child: Column(
              children: [
                SizedBox(
                  width: 180.w,
                  child: LinearProgressIndicator(
                    color: black,
                    backgroundColor: grey,
                  ),
                ),
               const Text('checking for available rooms')
              ],
            ))
          : CustomDropdown(
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

          /// Section: Checkout Details
          Visibility(
            visible: checkinDateCon.text.isNotEmpty,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionHeader("Checkout Details"),
                SizedBox(height: 14.h),
                
                CustomDatepicker(
                  controller: checkoutDateCon,
                  labelText: 'Check-out Date',
                  firstDate: checkinDateCon.text.isNotEmpty 
                    ? DateTime.parse(checkinDateCon.text) 
                    : DateTime.now(),
                  onChanged: (value) {
                    setState(() {});
                  },
                  isRequired: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Check-out Date';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 18.h),
                
                CustomTimePicker(
                  controller: checkoutTimeCon,
                  defaultTime: const TimeOfDay(hour: 12, minute: 0),
                  fixedToDefault: true,
                  headingText: "Check-out Time",

                ),
              ],
            ),
          ),

          SizedBox(height: 30.h),


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

  Widget _buildWebFormLayout() {
  return Form(
    key: _formKey,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              /////////////////////////////////////////////////////
              /// Left column - Personal details, identification///
              /////////////////////////////////////////////////////
    
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
    
            SizedBox(height: 18.h),
    
            // Booking Status
            CustomDropdown(
              headingText: "Status",
              headingTextStyle: interMedium(size: 13.sp),
              hintText: "Select booking status",
              hintStyle: interRegular(size: 14.sp, color: txtGrey7),
              items:  const ["Booked", "Checked In"],
              isRequired: true,
              value: statusCon,
              onChanged: (value) {
                setState(() {
                  statusCon = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select status';
                }
                return null;
              },
            ),
    
              SizedBox(height: 32.h),
    
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
    
            SizedBox(height: 32.h),
    
            /// Section: Stay / Checkin Details 
              sectionHeader("Stay Details"),
              SizedBox(height: 14.h),
    
              CustomDatepicker(
                controller: checkinDateCon,
                labelText: 'Check-in Date',
                firstDate: DateTime.now(),
                onChanged: (value) {
                  selectedCheckinDate = value;
                  recordController.getAvailableRooms(checkinDate: value);
                }
              ),
    
              SizedBox(height: 18.h),
    
              CustomTimePicker(
                controller: checkinTimeCon,
                headingText: "Check-in Time",
              ),
    
              SizedBox(height: 18.h),
    
              Obx(() => recordController.availableRooms.isEmpty ? SizedBox() 
              : recordController.isAvailableRoomLoading.isTrue ? Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 180.w,
                      child: LinearProgressIndicator(
                        color: black,
                        backgroundColor: grey,
                      ),
                    ),
                  const Text('checking for available rooms')
                  ],
                ))
              : CustomDropdown(
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
    
            ],
          ),
        ),
        SizedBox(width: 40.w),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              ///////////////////////////////////////////////////
              /// Right column - Stay details, additional info///
              ///////////////////////////////////////////////////
    
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
    
              SizedBox(height: 32.h),
    
              /// Section: Checkout Details
              Visibility(
                visible: checkinDateCon.text.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionHeader("Checkout Details"),
                    SizedBox(height: 14.h),
                    
                    CustomDatepicker(
                      controller: checkoutDateCon,
                      labelText: 'Check-out Date',
                      firstDate: checkinDateCon.text.isNotEmpty 
                        ? DateTime.parse(checkinDateCon.text) 
                        : DateTime.now(),
                      onChanged: (value) {
                        setState(() {});
                      },
                      isRequired: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select Check-out Date';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 18.h),
                    
                    CustomTimePicker(
                      controller: checkoutTimeCon,
                      defaultTime: const TimeOfDay(hour: 12, minute: 0),
                      fixedToDefault: true,
                      headingText: "Check-out Time",
                    ),
    
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
              ],
            ),
          ),
        ],
      ),
  );
  }
}

import 'package:family_home/src/app_config/app_styles.dart';
import 'package:family_home/src/controllers/menu_controller.dart';
import 'package:family_home/src/models/menu_model.dart';
import 'package:family_home/src/widget/custom_button.dart';
import 'package:family_home/src/widget/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ManageMenu extends StatefulWidget {
  const ManageMenu({super.key});

  @override
  State<ManageMenu> createState() => _ManageMenuState();
}

class _ManageMenuState extends State<ManageMenu> {
  final MenusController menuController = Get.put(MenusController());

  @override
  void initState() {
    super.initState();
    menuController.getAllMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        child: Icon(Icons.add, color: white, size: 24.w),
        onPressed: () => _showAddDialog(),
      ),
      body: menuList(),
    );
  }

  //app bar
  _appBar() {
    return AppBar(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: txtBlack),
      title: Text(
        "Manage Menu",
        style: interBold(size: 18.sp, color: txtBlack),
      ),
    );
  }

  //floating action button function
  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();

    String selectedCategory = menuController.categories.first;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------- TITLE ----------
              Center(
                child: Text(
                  "Add Menu Item",
                  style: interBold(size: 18.sp, color: txtBlack),
                ),
              ),

              SizedBox(height: 20.h),

              /// ---------- FORM ----------
              Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: nameController,
                      headingText: "Item Name *",
                      validator: (value) =>
                          (value == null || value.isEmpty) ? "Please enter item name" : null,
                    ),
                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: descriptionController,
                      headingText: "Description *",
                      maxLines: 3,
                      validator: (value) =>
                          (value == null || value.isEmpty) ? "Please enter description" : null,
                    ),
                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: priceController,
                      headingText: "Price (Rs.) *",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Please enter price";
                        if (double.tryParse(value) == null) return "Enter valid price";
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    StatefulBuilder(
                      builder: (context, setStateSB) {
                        return _buildCategoryDropdown(
                          value: selectedCategory,
                          onChanged: (v) {
                            setStateSB(() {
                              selectedCategory = v!;
                            });
                          },
                        );
                      },
                    ),

                  ],
                ),
              ),

              SizedBox(height: 24.h),

              /// ---------- BUTTONS ----------
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Cancel",
                        style: interMedium(size: 14.sp, color: txtGrey2),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final newItem = MenuItemModel(
                            name: nameController.text,
                            description: descriptionController.text,
                            price: double.parse(priceController.text),
                            category: selectedCategory,
                          );

                          await menuController.addMenuItem(newItem);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Add Item",
                        style: interMedium(size: 14.sp, color: Colors.white),
                      ),
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

  // MENU LIST
  Widget menuList() {
    return Obx(() {
      if (menuController.isLoading.isTrue) {
        return const Center(child: CircularProgressIndicator());
      }

      if (menuController.menuItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 80.w, color: txtGrey2),
              SizedBox(height: 16.h),
              Text(
                "No menu items found",
                style: interMedium(size: 16.sp, color: txtGrey2),
              ),
              SizedBox(height: 8.h),
              Text(
                "Add your first menu item using the + button",
                style: interRegular(size: 14.sp, color: txtGrey2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => menuController.getAllMenuItems(),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemCount: menuController.menuItems.length,
          itemBuilder: (context, index) {
            final menuItem = menuController.menuItems[index];
            return _buildMenuItemCard(menuItem);
          },
        ),
      );
    });
  }

  // ============ HELPER WIDGETS ============
  Widget _buildCategoryDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: interRegular(size: 12.sp, color: txtGrey7),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xff808084)),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              icon: Icon(Icons.arrow_drop_down, color: txtGrey2),
              items: menuController.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category, style: interRegular(size: 14.sp)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildMenuItemCard(MenuItemModel menuItem) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Item Image/Icon
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                    image: menuItem.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(menuItem.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: menuItem.imageUrl == null
                      ? Icon(Icons.restaurant, color: orange, size: 30.w)
                      : null,
                ),
                SizedBox(width: 16.w),
                
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuItem.name,
                        style: interBold(size: 16.sp, color: txtBlack),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        menuItem.description,
                        style: interRegular(size: 14.sp, color: txtGrey2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              menuItem.category,
                              style: interMedium(
                                size: 12.sp,
                                color: orange,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Rs. ${menuItem.price.toStringAsFixed(2)}',
                            style: interBold(size: 16.sp, color: orange),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Action Buttons
            SizedBox(height: 12.h),
            Divider(color: Colors.grey.shade200),
            SizedBox(height: 8.h),
            
            Row(
              children: [
                // Edit Button
                Expanded(
                  child: CustomButton(
                    text: "Edit Item",
                    color: txtBlue,
                    onTap: () => _showEditDialog(menuItem),
                    height: 40.h,
                    width: 40.w,
                  ),
                ),
                SizedBox(width: 8.w),
                
                // Delete Button
                Expanded(
                  child: CustomButton(
                    text: "Delete",
                    color: Colors.red,
                    onTap: () => _showDeleteDialog(menuItem),
                    height: 40.h,
                    width: 50.w,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  //edit menu items
  void _showEditDialog(MenuItemModel menuItem) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: menuItem.name);
  final descriptionController =
      TextEditingController(text: menuItem.description);
  final priceController =
      TextEditingController(text: menuItem.price.toString());
  String selectedCategory = menuItem.category;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- TITLE ----------
            Center(
              child: Text(
                "Edit Menu Item",
                style: interBold(size: 18.sp, color: txtBlack),
              ),
            ),

            SizedBox(height: 20.h),

            /// ---------- FORM ----------
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextFormField(
                    controller: nameController,
                    headingText: "Item Name *",
                    validator: (value) =>
                        (value == null || value.isEmpty)
                            ? "Please enter item name"
                            : null,
                  ),
                  SizedBox(height: 16.h),

                  CustomTextFormField(
                    controller: descriptionController,
                    headingText: "Description *",
                    maxLines: 3,
                    validator: (value) =>
                        (value == null || value.isEmpty)
                            ? "Please enter description"
                            : null,
                  ),
                  SizedBox(height: 16.h),

                  CustomTextFormField(
                    controller: priceController,
                    headingText: "Price (Rs.) *",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter price";
                      }
                      if (double.tryParse(value) == null) {
                        return "Enter valid price";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  StatefulBuilder(
                    builder: (context, setStateSB) {
                      return _buildCategoryDropdown(
                        value: selectedCategory,
                        onChanged: (v) {
                          setStateSB(() {
                            selectedCategory = v!;
                          });
                        },
                      );
                    },
                  ),

                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// ---------- BUTTONS ----------
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      "Cancel",
                      style: interMedium(size: 14.sp, color: txtGrey2),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: CustomButton(
                    onTap: () async {
                      if (formKey.currentState!.validate() &&
                          menuItem.id != null) {
                        final updatedItem = menuItem.copyWith(
                          name: nameController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text),
                          category: selectedCategory,
                        );

                        await menuController.updateMenuItem(
                            menuItem.id!, updatedItem);
                      }
                    },
                    color: orange,
                    text: "Update",
                    height: 50.h,
                    width: 140.w,
                    isLoading: menuController.isLoading.isTrue
                      ? true
                      : false,
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


  //delete menu item
  void _showDeleteDialog(MenuItemModel menuItem) {
    Get.defaultDialog(
      title: "Delete Menu Item",
      middleText: "Are you sure you want to delete '${menuItem.name}'?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: txtBlack,
      onConfirm: () async {
        if (menuItem.id != null) {
          await menuController.deleteMenuItem(menuItem.id!, menuItem.name);
        }
      },
    );
  }
}
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class AppUI {
  static const Color primaryWhite = Colors.white;
  static const Color purplePrimary = Color(0xFFD465E5);
  static const Color purpleSecondary = Color(0xFF6A4CC9);
  static const Color textColor = Color(0xFF333333);
  static const Color hintColor = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color errorColor = Color(0xFFF44336);
  static const Color successColor = Color(0xFF4CAF50);

  static const Color purpleLight = Color(0xFFE8A5F0);
  static const Color purpleDark = Color(0xFF5A3FB5);
  static const Color purpleAccent = Color(0xFFC97AE8);

  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: textColor,
  );

  static const TextStyle captionText = TextStyle(
    fontSize: 14,
    color: hintColor,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: primaryWhite,
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: primaryWhite,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration inputDecoration = BoxDecoration(
    color: primaryWhite,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: borderColor),
  );

  static Widget buildTextField({
    required String label,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    ValueChanged<String>? onChanged,
    Color focusBorderColor = purplePrimary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: bodyText.copyWith(fontWeight: FontWeight.w500),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: inputDecoration.copyWith(
            border: Border.all(
              color: errorText != null ? errorColor : borderColor,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: captionText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              errorText: errorText,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: focusBorderColor, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    double width = double.infinity,
    IconData? icon,
    bool useGradient = true,
  }) {
    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        gradient: useGradient
            ? LinearGradient(
                colors: [purplePrimary, purpleSecondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: useGradient ? null : purplePrimary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: purplePrimary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: primaryWhite,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: primaryWhite, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: buttonText,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    bool outlined = false,
    double width = double.infinity,
    bool useGradient = false,
  }) {
    return Container(
      width: width,
      height: 50,
      decoration: outlined
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: purplePrimary, width: 2),
            )
          : BoxDecoration(
              gradient: useGradient
                  ? LinearGradient(
                      colors: [purpleLight, purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: useGradient ? null : purpleLight.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: useGradient
                  ? [
                      BoxShadow(
                        color: purpleAccent.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: buttonText.copyWith(
                color: outlined ? purplePrimary : textColor,
                fontWeight: FontWeight.w600,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      ),
    );
  }

  static Widget gradientButton({
    required String text,
    required VoidCallback onPressed,
    List<Color> colors = const [purplePrimary, purpleSecondary],
    double width = double.infinity,
    double height = 50,
    IconData? icon,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: purplePrimary.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: primaryWhite, size: 22),
                  const SizedBox(width: 10),
                ],
                Text(
                  text,
                  style: buttonText.copyWith(fontSize: 16),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    VoidCallback? onTap,
    Color backgroundColor = primaryWhite,
    bool useGradientBorder = false,
  }) {
    return Container(
      decoration: cardDecoration.copyWith(
        color: backgroundColor,
        border: useGradientBorder
            ? Border.all(
                width: 2,
                style: BorderStyle.solid,
                color: Colors.transparent,
              )
            : null,
        gradient: useGradientBorder
            ? LinearGradient(
                colors: [purplePrimary, purpleSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }

  static AppBar appBar({
    required String title,
    List<Widget>? actions,
    bool centerTitle = true,
    Widget? leading,
    bool useGradient = true,
  }) {
    return AppBar(
      backgroundColor: useGradient ? null : primaryWhite,
      flexibleSpace: useGradient
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [purplePrimary, purpleSecondary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            )
          : null,
      elevation: 2,
      centerTitle: centerTitle,
      leading: leading,
      title: Text(
        title,
        style: headingSmall.copyWith(
          color: useGradient ? primaryWhite : textColor,
        ),
        textDirection: TextDirection.rtl,
      ),
      actions: actions,
      iconTheme: IconThemeData(
        color: useGradient ? primaryWhite : purplePrimary,
      ),
    );
  }

  static BottomNavigationBar bottomNavBar({
    required int currentIndex,
    required ValueChanged<int> onTap,
    required List<BottomNavigationBarItem> items,
  }) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      backgroundColor: primaryWhite,
      selectedItemColor: purplePrimary,
      unselectedItemColor: hintColor,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'موافق',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool useGradient = true,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: primaryWhite,
            borderRadius: BorderRadius.circular(16),
            border: useGradient
                ? Border.all(
                    width: 3,
                    style: BorderStyle.solid,
                    color: Colors.transparent,
                  )
                : null,
            gradient: useGradient
                ? LinearGradient(
                    colors: [Colors.white, purpleLight.withOpacity(0.1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: headingMedium.copyWith(color: purpleDark),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: bodyText,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (cancelText != null) ...[
                    Expanded(
                      child: secondaryButton(
                        text: cancelText,
                        onPressed: () {
                          Navigator.pop(context);
                          onCancel?.call();
                        },
                        outlined: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: gradientButton(
                      text: confirmText,
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm?.call();
                      },
                      height: 45,
                      colors: [purplePrimary, purpleAccent],
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

  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool isError = false,
    bool useGradient = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: buttonText.copyWith(fontSize: 14),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: isError
            ? errorColor
            : useGradient
                ? null
                : successColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  static Widget loadingIndicator({
    double size = 50,
    bool useGradient = true,
  }) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: useGradient
              ? LinearGradient(
                  colors: [purplePrimary, purpleSecondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(
            color: primaryWhite,
            strokeWidth: 3,
            backgroundColor: useGradient ? Colors.transparent : purpleLight,
          ),
        ),
      ),
    );
  }

  static Widget divider({
    bool useGradient = false,
    double thickness = 1,
  }) {
    return Container(
      height: thickness,
      decoration: BoxDecoration(
        gradient: useGradient
            ? LinearGradient(
                colors: [purplePrimary, purpleSecondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: useGradient ? null : borderColor,
      ),
    );
  }

  static Widget iconCircle({
    required IconData icon,
    Color iconColor = primaryWhite,
    bool useGradient = true,
    double size = 40,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: useGradient
            ? LinearGradient(
                colors: [purplePrimary, purpleSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: useGradient ? null : purplePrimary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: purplePrimary.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.6,
        ),
      ),
    );
  }

  static Widget gradientBadge({
    required String text,
    Color textColor = primaryWhite,
    List<Color> colors = const [purplePrimary, purpleSecondary],
    double fontSize = 12,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  static Widget gradientHeaderCard({
    required String title,
    required Widget content,
    EdgeInsets padding = const EdgeInsets.all(16),
    Color backgroundColor = primaryWhite,
  }) {
    return Container(
      decoration: cardDecoration.copyWith(color: backgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [purplePrimary, purpleSecondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: headingSmall.copyWith(color: primaryWhite),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: padding,
            child: content,
          ),
        ],
      ),
    );
  }
}

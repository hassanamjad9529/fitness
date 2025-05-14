import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? trailingIcon;
  final TextInputType? keyboardType;
  final VoidCallback? onTapField;
  final TextStyle? textStyle;
  final String? displayText;
  final String? value;
  final double? borderRadius;
  final bool isDOBField;
  final String? Function(String?)? validator;
  final int? maxLines; // Add maxLines parameter

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.displayText,
    this.textStyle,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.trailingIcon,
    this.onTapField,
    this.value,
    this.borderRadius = 15.0,
    this.isDOBField = false,
    this.validator,
    this.maxLines, // Add to constructor
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  bool _isTextNotEmpty = false;
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _isObscured = widget.obscureText;

    if (widget.displayText != null) {
      _controller.text = widget.displayText!;
    } else if (widget.value != null) {
      _controller.text = widget.value!;
    }

    _controller.addListener(() {
      setState(() {
        _isTextNotEmpty = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.displayText != oldWidget.displayText &&
        widget.displayText != null) {
      _controller.text = widget.displayText!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 3),
          child: Text(
            widget.label,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        GestureDetector(
          onTap: widget.onTapField,
          child: AbsorbPointer(
            absorbing: widget.onTapField != null,
            child: SizedBox(
              // Remove fixed height to allow TextFormField to expand for errors
              child: TextFormField(
                controller: _controller,
                obscureText: _isObscured,
                keyboardType: widget.keyboardType,
                style: widget.textStyle,
                validator: widget.validator,
                maxLines: widget.maxLines ?? 1,
                decoration: InputDecoration(
                  labelStyle: TextStyle(fontSize: 10, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.isDOBField ? 50.0 : widget.borderRadius!,
                    ),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.isDOBField ? 50.0 : widget.borderRadius!,
                    ),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.isDOBField ? 50.0 : widget.borderRadius!,
                    ),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  suffixIcon:
                      widget.trailingIcon != null
                          ? Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Icon(
                              widget.trailingIcon,
                              color: Colors.black,
                            ),
                          )
                          : widget.obscureText
                          ? IconButton(
                            icon:
                                _isObscured
                                    ? Icon(
                                      Icons.visibility_off_outlined,
                                      size: 15,
                                      color: Colors.black,
                                    )
                                    : Icon(
                                      Icons.visibility_outlined,
                                      size: 15,
                                      color: Colors.black,
                                    ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          )
                          : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class RegisterCouponTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final String hint;
  final TextInputType inputType;
  final VoidCallback onClickSearch;

  const RegisterCouponTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onClickSearch,
    this.inputType = TextInputType.text,
    this.enabled = true,
  });

  @override
  State<RegisterCouponTextField> createState() => _RegisterCouponTextField();
}

class _RegisterCouponTextField extends State<RegisterCouponTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        color: Color(0xFFF02062),
      ),
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(padding: EdgeInsets.only(left: 20)),
          Text("쿠폰번호 등록",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
          const Padding(padding: EdgeInsets.only(left: 12)),
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    color: Color(0xFFFFFFFF),
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 50),
                      child: TextFormField(
                        cursorColor: Color(0xFFF02062),
                        controller: widget.controller,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: widget.hint,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          isDense: true,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                      onTap: () {
                      widget.onClickSearch();
                      },
                      child: Image.asset("assets/icons/ic_register_coupon.png")
                  ),
                )
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(left: 20)),
        ],
      ),
    );
  }
}

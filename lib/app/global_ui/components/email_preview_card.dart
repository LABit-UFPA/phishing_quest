import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phishing_quest/app/data/models/email_content.model.dart';

/// E-mail estatico, como o que acompanha algumas questoes do quiz. As
/// cores sao neutras: destacar remetente ou links entregaria a resposta.
class EmailPreviewCard extends StatelessWidget {
  final EmailContent email;
  final EdgeInsets? margin;

  const EmailPreviewCard({
    required this.email,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: const Color(0xFFFAFAFA),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Header
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRow('De:', email.sender),
                if (email.recipient.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  _buildHeaderRow('Para:', email.recipient),
                ],
                SizedBox(height: 6.h),
                _buildHeaderRow('Assunto:', email.subject, isBold: true),
              ],
            ),
          ),
          // Email Body
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Text(
              email.body,
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 13.sp,
                height: 1.6,
                fontFamily: 'serif',
              ),
            ),
          ),
          // Links section
          if (email.links.isNotEmpty) ...[
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, size: 14.sp, color: const Color(0xFF64748B)),
                      SizedBox(width: 6.w),
                      Text(
                        'Links no e-mail:',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ...email.links.map((link) => Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: LinkDestination(link: link),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderRow(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60.w,
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontSize: 12.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Texto do link e o destino real logo abaixo, para o jogador comparar
/// os dois (texto diferente do destino e uma das pistas).
class LinkDestination extends StatelessWidget {
  final EmailLink link;
  final VoidCallback? onTap;

  const LinkDestination({required this.link, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final showDestination = link.text != link.href;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB).withOpacity(0.06),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(Icons.open_in_new, size: 14.sp, color: const Color(0xFF2563EB)),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.text,
                    style: TextStyle(
                      color: const Color(0xFF2563EB),
                      fontSize: 12.sp,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF2563EB),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showDestination)
                    Text(
                      link.href,
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 10.sp,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

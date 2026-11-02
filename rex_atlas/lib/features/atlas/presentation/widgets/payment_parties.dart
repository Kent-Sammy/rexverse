import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../domain/models/models.dart';
import 'atlas_brand.dart';

/// Display strings for a draft's recipient, shared by review/confirm/result.
class RecipientInfo {
  const RecipientInfo({
    required this.name,
    required this.subtitle,
    required this.initials,
    required this.logo,
    required this.smallLogo,
    required this.institution,
  });

  final String name;
  final String subtitle;
  final String initials;
  final Widget logo;
  final Widget smallLogo;
  final String institution;

  factory RecipientInfo.of(PaymentDraft d) => switch (d) {
    TransferDraft(:final beneficiary) => RecipientInfo(
      name: beneficiary.accountName,
      subtitle: beneficiary.maskedLabel,
      initials: InitialsAvatar.fromName(beneficiary.accountName),
      logo: BankLogo(
        code: beneficiary.bank.code,
        shortName: beneficiary.bank.shortName,
      ),
      smallLogo: BankLogo(
        code: beneficiary.bank.code,
        shortName: beneficiary.bank.shortName,
        size: 12.5,
      ),
      institution: beneficiary.bank.shortName,
    ),
    AirtimeDraft(:final phoneNumber, :final network) => RecipientInfo(
      name: phoneNumber,
      subtitle: '$network Airtime',
      initials: network.substring(0, network.length < 2 ? 1 : 2).toUpperCase(),
      logo: BankLogo(code: 'net-$network', shortName: network),
      smallLogo: BankLogo(code: 'net-$network', shortName: network, size: 12.5),
      institution: network,
    ),
  };
}

/// Label/value row used inside review and confirmation cards.
class AmountRow extends StatelessWidget {
  const AmountRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final labelStyle = isTotal
        ? RexTypography.rowLabel.copyWith(fontSize: 14)
        : RexTypography.rowLabel;
    final valueStyle = isTotal
        ? RexTypography.rowTotal
        : RexTypography.rowValue;
    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class CardDivider extends StatelessWidget {
  const CardDivider({super.key, this.color = RexColors.divider});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(height: 1, color: color);
}

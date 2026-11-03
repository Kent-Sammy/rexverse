import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/naira.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../domain/models/models.dart';
import 'atlas_brand.dart';

/// How a payment is presented across the review, confirmation and result
/// cards. One place per payment type keeps the cards generic.
class RecipientInfo {
  const RecipientInfo({
    required this.name,
    required this.subtitle,
    required this.avatar,
    required this.institution,
    required this.caption,
    required this.successTitle,
    required this.failureTitle,
    required this.successSuffix,
    required this.repeatLabel,
    required this.repeatUtterance,
    required this.purpose,
    this.logo,
    this.smallLogo,
    this.rows = const [],
    this.feeLabel = 'Transfer Fee',
    String? confirmName,
    String? confirmSubtitle,
  }) : confirmName = confirmName ?? name,
       confirmSubtitle = confirmSubtitle ?? subtitle;

  /// "to …" line on the confirmation card (bills show the biller).
  final String confirmName;
  final String confirmSubtitle;

  final String name;
  final String subtitle;

  /// Left-hand avatar (initials for people, a product icon otherwise).
  final Widget avatar;
  final Widget? logo;
  final Widget? smallLogo;
  final String institution;

  /// Confirmation card caption, e.g. "Send Money", "Pay Bill".
  final String caption;
  final String successTitle;
  final String failureTitle;

  /// Text after the bold amount in the success message.
  final String successSuffix;
  final String repeatLabel;
  final String repeatUtterance;

  /// Fingerprint sheet wording: "authorize this {purpose}".
  final String purpose;
  final List<(String, String)> rows;
  final String feeLabel;

  static Widget _disc(Widget icon, Color bg, {double size = 35}) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    child: icon,
  );

  static Widget _initials(String name) =>
      InitialsAvatar(initials: InitialsAvatar.fromName(name), size: 35);

  factory RecipientInfo.of(PaymentDraft d) => switch (d) {
    TransferDraft(:final beneficiary) => RecipientInfo(
      name: beneficiary.accountName,
      subtitle: beneficiary.maskedLabel,
      avatar: _initials(beneficiary.accountName),
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
      caption: 'Send Money',
      successTitle: 'Transfer Successful!',
      failureTitle: 'Transfer Failed',
      successSuffix:
          ' has been sent to ${beneficiary.accountName} at ${beneficiary.bank.shortName}.',
      repeatLabel: 'Make another transfer',
      repeatUtterance: 'Make another transfer',
      purpose: 'transfer',
    ),
    AirtimeDraft(:final phoneNumber, :final network) => RecipientInfo(
      name: phoneNumber,
      subtitle: '$network Airtime',
      avatar: InitialsAvatar(
        initials: network
            .substring(0, network.length < 2 ? 1 : 2)
            .toUpperCase(),
        size: 35,
      ),
      logo: BankLogo(code: 'net-$network', shortName: network),
      smallLogo: BankLogo(code: 'net-$network', shortName: network, size: 12.5),
      institution: network,
      caption: 'Buy Airtime',
      successTitle: 'Airtime Purchase Successful!',
      failureTitle: 'Airtime Purchase Failed',
      successSuffix: ' airtime has been sent to $phoneNumber ($network).',
      repeatLabel: 'Buy more airtime',
      repeatUtterance: 'Buy Airtime',
      purpose: 'purchase',
      feeLabel: 'Service Fee',
    ),
    SavingsDraft(:final plan) => RecipientInfo(
      name: plan.displayName,
      subtitle: plan.tagline,
      avatar: _disc(
        plan == SavingsPlan.rexSave
            ? const RexSvgIcon(RexSvg.wallet, size: 20)
            : const RexSvgIcon(
                RexSvg.piggyBank,
                size: 18,
                color: RexColors.iconOrange,
              ),
        RexColors.tileOrange,
      ),
      institution: plan.displayName,
      caption: 'Save Money',
      successTitle: 'Savings Successful!',
      failureTitle: 'Savings Failed',
      successSuffix: d.bonusKobo > 0
          ? ' has been added to ${plan.displayName}, plus a ${Naira.fixed(d.bonusKobo)} bonus.'
          : ' has been added to your ${plan.displayName}.',
      repeatLabel: 'Save more',
      repeatUtterance: 'Save Money',
      purpose: 'deposit',
      feeLabel: 'Fee',
      rows: [
        if (d.annualRatePct > 0)
          ('Interest', '${d.annualRatePct.toStringAsFixed(0)}% p.a.'),
        if (d.lockedUntil == null) ('Withdrawals', 'Any time'),
        if (d.bonusKobo > 0) ('Upfront bonus', Naira.fixed(d.bonusKobo)),
        if (d.lockedUntil != null)
          ('Locked until', RexDates.short(d.lockedUntil!)),
      ],
    ),
    VaultDraft() => RecipientInfo(
      name: 'RexVault',
      subtitle:
          'Fixed lock · ${d.tenorDays == 365 ? '1 year' : '${d.tenorDays} days'}',
      avatar: _disc(
        const RexSvgIcon(RexSvg.briefcase, size: 20),
        RexColors.tileCyan,
      ),
      institution: 'RexVault',
      caption: 'Lock Funds',
      successTitle: 'Funds Locked!',
      failureTitle: 'Lock Failed',
      successSuffix:
          ' is locked in RexVault until ${RexDates.short(d.maturity)}. '
          "You'll earn about ${Naira.fixed(d.interestKobo)}.",
      repeatLabel: 'Lock more funds',
      repeatUtterance: 'Lock funds in RexVault',
      purpose: 'lock',
      feeLabel: 'Fee',
      rows: [
        ('Interest rate', '${d.annualRatePct.toStringAsFixed(0)}% p.a.'),
        ('Expected interest', Naira.fixed(d.interestKobo)),
        ('Matures on', RexDates.short(d.maturity)),
      ],
    ),
    BillDraft(:final biller, :final package) => RecipientInfo(
      name: d.customer.name,
      subtitle: '${biller.shortName} · ${d.customerId}',
      avatar: _initials(d.customer.name),
      logo: _billLogo(biller.category, 35),
      smallLogo: _billLogo(biller.category, 12.5),
      institution: biller.shortName,
      caption: 'Pay Bill',
      successTitle: 'Payment Successful!',
      failureTitle: 'Payment Failed',
      successSuffix: package == null
          ? ' ${biller.shortName} electricity for meter ${d.customerId} is paid.'
          : ' paid. Your ${biller.shortName} ${package.name} plan for ${d.customerId} is active.',
      repeatLabel: 'Pay another bill',
      repeatUtterance: 'Pay a bill',
      purpose: 'payment',
      feeLabel: 'Service Fee',
      confirmName: biller.name,
      confirmSubtitle:
          '${biller.customerIdLabel[0].toUpperCase()}${biller.customerIdLabel.substring(1)} ${d.customerId}',
      rows: [
        ('Biller', biller.name),
        if (package != null) ('Package', package.name),
        if (d.customer.address != null) ('Address', d.customer.address!),
      ],
    ),
  };

  static Widget _billLogo(BillCategory c, double size) {
    final icon = size * 0.55;
    return switch (c) {
      BillCategory.electricity => _disc(
        RexSvgIcon(RexSvg.light, size: icon),
        RexColors.tileOrange,
        size: size,
      ),
      BillCategory.cableTv => _disc(
        Icon(Icons.tv_rounded, size: icon, color: RexColors.iconBlue),
        RexColors.tileBlue,
        size: size,
      ),
      BillCategory.internet => _disc(
        RexSvgIcon(RexSvg.wifiSquare, size: icon),
        RexColors.tileBlue,
        size: size,
      ),
    };
  }
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

/// Product detail line (rate, maturity, meter number…) inside the cards.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: RexTypography.rowLabel.copyWith(
              fontSize: 13,
              color: RexColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: RexTypography.rowValue.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

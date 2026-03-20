import 'package:flutter/material.dart';
import 'package:kindora/l10n/app_localizations.dart';
import 'package:kindora/models/wallet_model.dart';
import 'package:kindora/services/wallet_service.dart';

class BeneficiaryWalletPage extends StatefulWidget {
  const BeneficiaryWalletPage({super.key});

  @override
  State<BeneficiaryWalletPage> createState() => _BeneficiaryWalletPageState();
}

class _BeneficiaryWalletPageState extends State<BeneficiaryWalletPage> {
  final WalletService _walletService = WalletService();

  double _balance = 0;
  double _totalEarnings = 0;
  bool _loading = true;
  List<WalletTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final summary = await _walletService.getBeneficiaryWalletSummary();
      final tx = await _walletService.getWalletTransactions(page: 1, limit: 50);
      if (!mounted) return;
      setState(() {
        _balance = summary['balance'] ?? 0;
        _totalEarnings = summary['total_earnings'] ?? 0;
        _transactions = tx;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wallet),
        backgroundColor: const Color(0xFF0C0C79),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0C79),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'LKR ${_balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Total Earnings: LKR ${_totalEarnings.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.95)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  if (_transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: Text('No wallet transactions yet')),
                    )
                  else
                    ..._transactions.map(
                      (t) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: t.type == 'credit'
                                ? Colors.green.withValues(alpha: 0.14)
                                : Colors.red.withValues(alpha: 0.14),
                            child: Icon(
                              t.type == 'credit' ? Icons.add : Icons.remove,
                              color: t.type == 'credit' ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(t.description),
                          subtitle: Text(t.timestamp.toLocal().toString()),
                          trailing: Text(
                            '${t.type == 'credit' ? '+' : '-'}LKR ${t.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: t.type == 'credit' ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/friend_provider.dart';
import '../models/friend_model.dart';
import '../core/theme/theme.dart'; // <-- pakai AppColors & AppTheme milikmu

class FriendListScreen extends StatelessWidget {
  const FriendListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FriendProvider(),
      child: const _FriendListScaffold(),
    );
  }
}

class _FriendListScaffold extends StatelessWidget {
  const _FriendListScaffold();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.greySurface, // sesuai desain (krem muda)
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            splashRadius: 22,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text('Daftar Teman', style: theme.textTheme.titleLarge),
          toolbarHeight: 56,
          scrolledUnderElevation: 0,
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendProvider>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== TabBar + Tombol Tambah =====
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  onTap: context.read<FriendProvider>().setTab,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black45,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(color: AppColors.purple, width: 3),
                  ),
                  tabs: const [
                    Tab(text: 'Semua teman'),
                    Tab(text: 'Hutang'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _AddButton(onTap: () {
                // TODO: aksi tambah teman
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tambah teman (dummy)')),
                );
              }),
            ],
          ),
        ),

        // ===== Search =====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: context.read<FriendProvider>().setQuery,
            decoration: const InputDecoration(
              hintText: 'Cari dengan nama atau nomer handphone',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ===== List Teman =====
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(), // tab dikontrol manual
            children: const [
              _FriendList(tab: 0),
              _FriendList(tab: 1),
            ],
          ),
        ),
      ],
    );
  }
}

class _FriendList extends StatelessWidget {
  final int tab; // 0 semua, 1 hutang (provider yg filter)
  const _FriendList({required this.tab});

  @override
  Widget build(BuildContext context) {
    // pastikan provider disinkronkan dengan tab saat TabBarView dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<FriendProvider>().tabIndex != tab) {
        context.read<FriendProvider>().setTab(tab);
      }
    });

    final items = context.watch<FriendProvider>().items;

    if (items.isEmpty) {
      return const Center(child: Text('Data teman tidak ditemukan'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _FriendTile(friend: items[i]),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final FriendModel friend;
  const _FriendTile({required this.friend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9E6E0)),
      ),
      child: Row(
        children: [
          // Avatar lingkaran + border ungu
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.purple, width: 2),
            ),
            child: const CircleAvatar(
              backgroundColor: Color(0xFFF2F0FC),
              child: Icon(Icons.person_rounded, color: AppColors.purple),
            ),
          ),
          const SizedBox(width: 12),
          // Nama & no HP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(friend.phone, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.yellow,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            '+ Tambah',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

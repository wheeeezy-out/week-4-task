import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entity Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomeScreen(),
    );
  }
}

class Entity {
  String id;
  String name;
  String email;
  String role;
  Entity({required this.id, required this.name, required this.email, required this.role});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<<HomeScreen> {
  final List<Entity> _entities = [];
  final _searchCtrl = TextEditingController();
  final _formKey = GlobalKey<<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _role = 'User';
  String? _editingId;

  List<Entity> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _entities;
    return _entities.where((e) => e.name.toLowerCase().contains(q) || e.email.toLowerCase().contains(q)).toList();
  }

  void _saveEntity() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      if (_editingId != null) {
        final e = _entities.firstWhere((e) => e.id == _editingId);
        e.name = _nameCtrl.text;
        e.email = _emailCtrl.text;
        e.role = _role;
      } else {
        _entities.add(Entity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          role: _role,
        ));
      }
    });
    Navigator.pop(context);
    _clearForm();
  }

  void _deleteEntity(String id) {
    setState(() => _entities.removeWhere((e) => e.id == id));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
  }

  void _editEntity(Entity e) {
    _editingId = e.id;
    _nameCtrl.text = e.name;
    _emailCtrl.text = e.email;
    _role = e.role;
    _showForm(title: 'Update Entity');
  }

  void _clearForm() {
    _editingId = null;
    _nameCtrl.clear();
    _emailCtrl.clear();
    _role = 'User';
  }

  void _showForm({String title = 'Add Entity'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)), validator: (v) => v!.contains('@') ? null : 'Valid email required'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge)),
                items: ['Admin', 'Manager', 'User'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => _role = v!,
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: _saveEntity, child: Text(title == 'Add Entity' ? 'ADD' : 'UPDATE'))),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ).whenComplete(_clearForm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entities'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchCtrl.clear())) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No entities found', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final e = _filtered[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(e.name[0].toUpperCase())),
                        title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${e.email} • ${e.role}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _editEntity(e)),
                            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _deleteEntity(e.id)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }
}
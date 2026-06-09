import 'package:flutter/material.dart';

void main() => runApp(const App());

class Entity {
  final String id;
  String name, email, role;
  Entity({required this.id, required this.name, required this.email, required this.role});
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Entity Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        ),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Entity> _items = [
    Entity(id: '1', name: 'Ada Lovelace', email: 'ada@calc.io', role: 'Engineer'),
    Entity(id: '2', name: 'Alan Turing', email: 'alan@enigma.io', role: 'Researcher'),
    Entity(id: '3', name: 'Grace Hopper', email: 'grace@cobol.io', role: 'Admiral'),
  ];
  String _query = '';

  List<Entity> get _filtered {
    final q = _query.toLowerCase().trim();
    if (q.isEmpty) return _items;
    return _items.where((e) =>
        e.name.toLowerCase().contains(q) ||
        e.email.toLowerCase().contains(q) ||
        e.role.toLowerCase().contains(q)).toList();
  }

  Future<void> _openForm({Entity? existing}) async {
    final result = await showModalBottomSheet<Entity>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: EntityForm(existing: existing),
      ),
    );
    if (result == null) return;
    setState(() {
      final i = _items.indexWhere((e) => e.id == result.id);
      if (i == -1) {
        _items.add(result);
      } else {
        _items[i] = result;
      }
    });
  }

  void _delete(Entity e) {
    setState(() => _items.removeWhere((x) => x.id == e.id));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted ${e.name}')));
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('Entity Manager'), centerTitle: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name, email, or role',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No records'))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final e = list[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(e.name.isEmpty ? '?' : e.name[0])),
                        title: Text(e.name),
                        subtitle: Text('${e.email}  ·  ${e.role}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(existing: e)),
                          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(e)),
                        ]),
                        onTap: () => _openForm(existing: e),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class EntityForm extends StatefulWidget {
  final Entity? existing;
  const EntityForm({super.key, this.existing});
  @override
  State<EntityForm> createState() => _EntityFormState();
}

class _EntityFormState extends State<EntityForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _email =
      TextEditingController(text: widget.existing?.email ?? '');
  late final TextEditingController _role =
      TextEditingController(text: widget.existing?.role ?? '');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _role.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Entity(
        id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        email: _email.text.trim(),
        role: _role.text.trim(),
      ),
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(editing ? 'Edit record' : 'New record',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: _req),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _role, decoration: const InputDecoration(labelText: 'Role'), validator: _req),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _submit, child: Text(editing ? 'Save changes' : 'Add record')),
          ),
        ]),
      ),
    );
  }
}
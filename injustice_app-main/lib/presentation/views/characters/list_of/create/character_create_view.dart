import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:injustice_app/domain/models/character_entity.dart';

class CharacterCreateView extends StatefulWidget {
  final Character? character;
  const CharacterCreateView({super.key, this.character});

  @override
  State<CharacterCreateView> createState() => _CharacterCreateViewState();
}

class _CharacterCreateViewState extends State<CharacterCreateView> {
  late final TextEditingController _nameController;

  CharacterClass selectedClass = CharacterClass.poderoso;
  CharacterRarity selectedRarity = CharacterRarity.prata;
  CharacterAlignment selectedAlignment = CharacterAlignment.heroi;

  // Variáveis para armazenar os valores numéricos
  int level = 1;
  int attack = 10;
  int health = 10;
  int stars = 1;
  int threat = 0;

  @override
  void initState() {
    super.initState();
    
    // 1. Identifica se é edição ou criação
    final isEditing = widget.character != null;
    
    _nameController = TextEditingController(text: widget.character?.name ?? '');
    
    if (isEditing) {
      selectedClass = widget.character!.characterClass;
      selectedRarity = widget.character!.rarity;
      selectedAlignment = widget.character!.alignment;
      level = widget.character!.level;
      attack = widget.character!.attack;
      health = widget.character!.health;
      stars = widget.character!.stars;
      threat = widget.character!.threat;
    }
  }

  void _save() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O nome não pode estar vazio')),
      );
      return;
    }

    final character = Character(
      // CRUCIAL: Mantém o ID original se for edição
      id: widget.character?.id ?? const Uuid().v4(),
      name: _nameController.text,
      characterClass: selectedClass,
      rarity: selectedRarity,
      level: level,
      threat: threat,
      attack: attack,
      health: health,
      stars: stars,
      alignment: selectedAlignment,
      // CRUCIAL: Mantém a data de criação original
      createdAt: widget.character?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, character);
  }

  // Widget de campo numérico melhorado
  Widget _numberField(String label, int value, Function(int) onChanged) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null) {
          onChanged(parsed); // Atualiza a variável local
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Define os textos baseados no estado (Edição vs Criação)
    final bool isEditing = widget.character != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Personagem' : 'Criar Personagem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CharacterClass>(
              value: selectedClass,
              decoration: const InputDecoration(labelText: 'Classe'),
              items: CharacterClass.values.map((e) {
                return DropdownMenuItem(value: e, child: Text(e.displayName));
              }).toList(),
              onChanged: (v) => setState(() => selectedClass = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CharacterRarity>(
              value: selectedRarity,
              decoration: const InputDecoration(labelText: 'Raridade'),
              items: CharacterRarity.values.map((e) {
                return DropdownMenuItem(value: e, child: Text(e.displayName));
              }).toList(),
              onChanged: (v) => setState(() => selectedRarity = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CharacterAlignment>(
              value: selectedAlignment,
              decoration: const InputDecoration(labelText: 'Alinhamento'),
              items: CharacterAlignment.values.map((e) {
                return DropdownMenuItem(value: e, child: Text(e.displayName));
              }).toList(),
              onChanged: (v) => setState(() => selectedAlignment = v!),
            ),
            const SizedBox(height: 12),
            
            // Campos numéricos: atualizam as variáveis da classe
            _numberField('Level (1-80)', level, (v) => level = v),
            const SizedBox(height: 12),
            _numberField('Ataque', attack, (v) => attack = v),
            const SizedBox(height: 12),
            _numberField('Vida', health, (v) => health = v),
            const SizedBox(height: 12),
            _numberField('Ameaça', threat, (v) => threat = v),
            const SizedBox(height: 12),
            _numberField('Estrelas (1-14)', stars, (v) => stars = v),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save, 
              child: Text(isEditing ? 'Atualizar Dados' : 'Salvar Personagem'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
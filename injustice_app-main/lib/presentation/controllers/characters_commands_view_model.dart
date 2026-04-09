import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../domain/models/character_entity.dart';
import '../commands/character_commands.dart';
import 'characters_state_viewmodel.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CharactersCommandsViewModel {
  final CharactersStateViewmodel state;
  
  // Comandos privados
  final GetAllCharactersCommand _getAllCharactersCommand;
  final CreateCharacterCommand _createCharacterCommand;
  final DeleteCharacterCommand _deleteCharacterCommand;
  final UpdateCharacterCommand _updateCharacterCommand;

  CharactersCommandsViewModel({
    required this.state,
    required GetAllCharactersCommand getAccountCommand,
    required CreateCharacterCommand createCharacterCommand,
    required DeleteCharacterCommand deleteCharacterCommand,
    required UpdateCharacterCommand updateCharacterCommand,
  })  : _getAllCharactersCommand = getAccountCommand,
        _createCharacterCommand = createCharacterCommand,
        _deleteCharacterCommand = deleteCharacterCommand,
        _updateCharacterCommand = updateCharacterCommand {
    
    // Inicializa os observers (Effects)
    _observeGetAllCharacters();
    _observeCreateCharacter();
    _observeDeleteCharacter();
    _observeUpdateCharacter();
  }

  // ========================================================
  //   GETTERS PARA WIDGETS
  // ========================================================
  GetAllCharactersCommand get getAllCharactersCommand => _getAllCharactersCommand;
  CreateCharacterCommand get createCharacterCommand => _createCharacterCommand;
  DeleteCharacterCommand get deleteCharacterCommand => _deleteCharacterCommand;
  UpdateCharacterCommand get updateCharacterCommand => _updateCharacterCommand;

  // ========================================================
  //   MÉTODO GENÉRICO DE OBSERVAÇÃO
  // ========================================================
  void _observeCommand<T>(
    Command<T, Failure> command, {
    required void Function(T data) onSuccess,
    void Function(Failure err)? onFailure,
  }) {
    effect(() {
      if (command.isExecuting.value) return;

      final result = command.result.value;
      if (result == null) return;

      result.fold(
        onSuccess: (data) {
          state.clearMessage();
          onSuccess(data); 
          command.clear();
        },
        onFailure: (err) {
          state.setMessage(err.msg);
          if (onFailure != null) onFailure(err);
          command.clear();
        },
      );
    });
  }

  // ========================================================
  //   OBSERVERS (ATUALIZAÇÃO DE ESTADO)
  // ========================================================

  void _observeGetAllCharacters() {
    _observeCommand<List<Character>>(
      _getAllCharactersCommand,
      onSuccess: (characters) => state.state.value = characters,
    );
  }

  void _observeCreateCharacter() {
    _observeCommand<Character>(
      _createCharacterCommand,
      onSuccess: (newCharacter) {
        final currentList = state.state.value;
        state.state.value = [...currentList, newCharacter];
      },
    );
  }

  void _observeDeleteCharacter() {
    _observeCommand<Character>(
      _deleteCharacterCommand,
      onSuccess: (deletedCharacter) {
        // Opcional: A UI geralmente remove antes, mas aqui garantimos a sincronia
        state.state.value = state.state.value
            .where((c) => c.id != deletedCharacter.id)
            .toList();
      },
      onFailure: (err) {
        // Se falhar no banco, recarregamos a lista para restaurar o item na UI
        fetchCharacters();
      },
    );
  }

  void _observeUpdateCharacter() {
    _observeCommand<Character>(
      _updateCharacterCommand,
      onSuccess: (updatedChar) {
        final currentList = state.state.value;
        // Substitui o personagem antigo pelo atualizado mantendo a ordem
        state.state.value = currentList.map((c) {
          return c.id == updatedChar.id ? updatedChar : c;
        }).toList();
      },
    );
  }

  // ========================================================
  //   MÉTODOS PÚBLICOS (CHAMADOS PELA VIEW)
  // ========================================================

  Future<void> fetchCharacters() async {
    state.clearMessage();
    await _getAllCharactersCommand.executeWith(());
  }

  Future<void> addCharacter(Character character) async {
    state.clearMessage();
    await _createCharacterCommand.executeWith((character: character));
  }

  Future<void> deleteCharacter(String id) async {
    state.clearMessage();
    await _deleteCharacterCommand.executeWith((id: id));
  }

  // No arquivo characters_commands_view_model.dart

Future<void> updateCharacter(Character character) async {
  state.clearMessage();
  
  if (character.id.isEmpty) {
    state.setMessage("Erro: ID do personagem inválido para atualização.");
    return;
  }

  // Certifique-se de que o executeWith está enviando o Record EXATAMENTE
  // como definido no seu CharacterParams (typedef)
  await _updateCharacterCommand.executeWith((character: character));
}
}
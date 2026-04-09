import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/character_facade_usecases_interface.dart';
import '../../domain/models/character_entity.dart';

// --- COMANDOS ---

final class CreateCharacterCommand
    extends ParameterizedCommand<Character, Failure, CharacterParams> {
  final ICharacterFacadeUseCases _characterFacadeUseCases;

  CreateCharacterCommand(this._characterFacadeUseCases);

  @override
  Future<CharacterResult> execute() async {
    if (parameter == null) {
      return Error(InputFailure('Parâmetro nulo para criar personagem.'));
    }
    return await _characterFacadeUseCases.saveCharacter(parameter!);
  }
}

final class DeleteCharacterCommand
    extends ParameterizedCommand<Character, Failure, CharacterIdParams> {
  final ICharacterFacadeUseCases _characterFacadeUseCases;

  DeleteCharacterCommand(this._characterFacadeUseCases);

  @override
  Future<CharacterResult> execute() async {
    if (parameter == null || parameter!.id.isEmpty) {
      return Error(InputFailure('Parâmetro nulo para deletar personagem.'));
    }
    return await _characterFacadeUseCases.deleteCharacter(parameter!);
  }
}

final class GetAllCharactersCommand
    extends ParameterizedCommand<List<Character>, Failure, NoParams> {
  final ICharacterFacadeUseCases _characterFacadeUseCases;

  GetAllCharactersCommand(this._characterFacadeUseCases);

  @override
  Future<ListCharacterResult> execute() async {
    return await _characterFacadeUseCases.getAllCharacters(());
  }
}

// CORRIGIDO: Agora segue o padrão ParameterizedCommand
// No arquivo character_commands.dart

final class UpdateCharacterCommand 
    extends ParameterizedCommand<Character, Failure, CharacterParams> {
  final ICharacterFacadeUseCases _characterFacadeUseCases;

  UpdateCharacterCommand(this._characterFacadeUseCases);

  @override
  Future<CharacterResult> execute() async {
    // 1. SEGURANÇA MÁXIMA: 
    // Em vez de confiar no sinal 'parameter' da classe pai, 
    // vamos usar uma verificação local e segura.
    final currentParam = parameter;

    if (currentParam == null) {
      // Se chegamos aqui e está nulo, retornamos um erro de Result
      // Isso impede o crash (tela branca/cinza) e permite que a View trate o erro.
      return Error(InputFailure('Não foi possível recuperar os dados do personagem para atualização.'));
    }

    // 2. CHAMADA DIRETA:
    // Passamos 'currentParam' que o Dart agora garante (via Smart Cast) que não é nulo.
    return await _characterFacadeUseCases.updateCharacter(currentParam);
  }
}

final class GetCharacterByIdCommand
    extends ParameterizedCommand<Character, Failure, CharacterIdParams> {
  final ICharacterFacadeUseCases _characterFacadeUseCases;

  GetCharacterByIdCommand(this._characterFacadeUseCases);

  @override
  Future<CharacterResult> execute() async {
    if (parameter == null || parameter!.id.isEmpty) {
      return Error(InputFailure('Parâmetro nulo para obter personagem por ID.'));
    }
    return await _characterFacadeUseCases.getCharacterById(parameter!);
  }
}
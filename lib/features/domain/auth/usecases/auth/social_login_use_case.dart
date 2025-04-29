import '../../../../data/auth/models/auth_response_model.dart';
import '../../repositories/auth_repository.dart';

class SocialLoginUseCase {
  final AuthRepository authRepository;

  SocialLoginUseCase(this.authRepository);

  Future<AuthResponseModel> call(String provider, String token) async {
    return await authRepository.socialLogin(provider, token);
  }
}

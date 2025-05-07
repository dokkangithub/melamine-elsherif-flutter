import '../../../../data/auth/models/auth_response_model.dart';
import '../../repositories/auth_repository.dart';

class SocialLoginUseCase {
  final AuthRepository authRepository;

  SocialLoginUseCase(this.authRepository);

  Future<AuthResponseModel> call( String socialProvider,
      String name,
      String email,
      String provider, {
        access_token = "",
        secret_token = "",
      }) async {
    return await authRepository.socialLogin(provider,name,email,provider,access_token: access_token,secret_token: secret_token);
  }
}

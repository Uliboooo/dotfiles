{ lib, buildGoModule, fetchFromGitHub, pkg-config, alsa-lib }:

buildGoModule rec {
  pname = "sampler";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "sqshq";
    repo = "sampler";
    rev = "v${version}";
    hash = "sha256-H7QllAqPp35wHeJ405YSfPX3S4lH0/hdQ8Ja2OGLVtE=";
  };

  vendorHash = "sha256-CbgXMV3kWKB3Yk4O/mnqBIQl/sFwTlfW85D44QNnsTY=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ alsa-lib ];

  meta = with lib; {
    description = "Tool for shell commands execution, visualization and alerting";
    homepage = "https://github.com/sqshq/sampler";
    license = licenses.gpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "sampler";
  };
}
